// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "./ICondition.sol";
import "@thirdweb-dev/contracts/extension/ContractMetadata.sol";
import "@thirdweb-dev/contracts/extension/Ownable.sol";

contract SimplePool is ICondition, ContractMetadata, Ownable {
    event TokensClaimed(address indexed claimer, uint256 quantityClaimed);
    event WithdrawRequested(
        address indexed requester,
        uint256 quantityRequested
    );

    struct ClaimPhase {
        Condition condition;
        uint256 claimProgress;
        /// @dev The max number of tokens a wallet can claim.
        uint256 maxWalletClaimCount;
        mapping(address => uint256) walletClaimCount;
        mapping(address => uint256) limitLastClaimTimestamp;
    }

    struct WithdrawRequestPhase {
        Condition condition;
        uint256 withdrawRequestProgress;
        // mapping(address => uint256) walletWithdrawCount;
        mapping(address => uint256) limitLastWithdrawRequestTimestamp;
    }

    address public immutable poolToken;
    address public immutable nativeToken;

    ClaimPhase public claimPhase;
    WithdrawRequestPhase public withdrawRequestPhase;

    bool contractReceivedPoolTokens = false;

    constructor(
        address _nativeToken,
        address _poolToken,
        string memory _contractURI,
        Condition memory _claimCondition,
        uint256 _maxWalletClaimCount
    ) {
        // Condition memory _withdrawRequestCondition
        nativeToken = _nativeToken;
        poolToken = _poolToken;
        contractURI = _contractURI;
        claimPhase.condition = _claimCondition;
        // withdrawRequestPhase.condition = _withdrawRequestCondition;
        claimPhase.maxWalletClaimCount = _maxWalletClaimCount;
        _setupOwner(msg.sender);
    }

    function claim(uint256 _quantityBeingClaimed) external payable {
        verifyClaim(_quantityBeingClaimed, msg.sender);
        claimPhase.condition.usedAmount += _quantityBeingClaimed;
        Condition memory claimCondition = claimPhase.condition;
        claimPhase.claimProgress = ((claimCondition.usedAmount * 100) /
            claimCondition.maxSupply);
        claimPhase.limitLastClaimTimestamp[msg.sender] = block.timestamp;
        claimPhase.walletClaimCount[msg.sender] += _quantityBeingClaimed;
        emit TokensClaimed(msg.sender, _quantityBeingClaimed);
    }

    function verifyClaim(uint256 _quantity, address _claimer) public view {
        Condition memory claimCondition = claimPhase.condition;

        require(
            claimCondition.startTimestamp < block.timestamp,
            "Sale hasn't started yet"
        );
        require(
            claimCondition.endTimestamp > block.timestamp,
            "Sale has already ended"
        );

        uint256 newUsedAmount = claimCondition.usedAmount + _quantity;

        require(
            (newUsedAmount) <= claimCondition.maxSupply,
            "Quantity exceeds supply"
        );

        uint256 amountClaimed = claimPhase.walletClaimCount[_claimer];

        require(
            (amountClaimed + _quantity) <= claimPhase.maxWalletClaimCount,
            "Quantity exceeds claim limit for wallet"
        );

        require(
            _quantity > 0 &&
                _quantity <= claimCondition.quantityLimitMaxPerTransaction &&
                _quantity >= claimCondition.quantityLimitMinPerTransaction,
            "Invalid quantity"
        );
    }

    function _canSetContractURI()
        internal
        view
        virtual
        override
        returns (bool)
    {
        return msg.sender == owner();
    }

    function _canSetOwner() internal view virtual override returns (bool) {
        return msg.sender == owner();
    }

    //
    // function sendTokensBatch() external {
    //     poolToken.transferBatch();
    // }
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

interface ICondition {
    struct Condition {
        uint256 startTimestamp;
        uint256 endTimestamp;
        uint256 maxSupply;
        uint256 usedAmount;
        uint256 quantityLimitMaxPerTransaction;
        uint256 quantityLimitMinPerTransaction;
        uint256 waitTimeInSecondsBetweenTransactions;
        uint256 pricePerToken;
    }
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "./interface/IContractMetadata.sol";

/**
 *  @title   Contract Metadata
 *  @notice  Thirdweb's `ContractMetadata` is a contract extension for any base contracts. It lets you set a metadata URI
 *           for you contract.
 *           Additionally, `ContractMetadata` is necessary for NFT contracts that want royalties to get distributed on OpenSea.
 */

abstract contract ContractMetadata is IContractMetadata {
    /// @notice Returns the contract metadata URI.
    string public override contractURI;

    /**
     *  @notice         Lets a contract admin set the URI for contract-level metadata.
     *  @dev            Caller should be authorized to setup contractURI, e.g. contract admin.
     *                  See {_canSetContractURI}.
     *                  Emits {ContractURIUpdated Event}.
     *
     *  @param _uri     keccak256 hash of the role. e.g. keccak256("TRANSFER_ROLE")
     */
    function setContractURI(string memory _uri) external override {
        if (!_canSetContractURI()) {
            revert("Not authorized");
        }

        _setupContractURI(_uri);
    }

    /// @dev Lets a contract admin set the URI for contract-level metadata.
    function _setupContractURI(string memory _uri) internal {
        string memory prevURI = contractURI;
        contractURI = _uri;

        emit ContractURIUpdated(prevURI, _uri);
    }

    /// @dev Returns whether contract metadata can be set in the given execution context.
    function _canSetContractURI() internal view virtual returns (bool);
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "./interface/IOwnable.sol";

/**
 *  @title   Ownable
 *  @notice  Thirdweb's `Ownable` is a contract extension to be used with any base contract. It exposes functions for setting and reading
 *           who the 'owner' of the inheriting smart contract is, and lets the inheriting contract perform conditional logic that uses
 *           information about who the contract's owner is.
 */

abstract contract Ownable is IOwnable {
    /// @dev Owner of the contract (purpose: OpenSea compatibility)
    address private _owner;

    /// @dev Reverts if caller is not the owner.
    modifier onlyOwner() {
        if (msg.sender != _owner) {
            revert("Not authorized");
        }
        _;
    }

    /**
     *  @notice Returns the owner of the contract.
     */
    function owner() public view override returns (address) {
        return _owner;
    }

    /**
     *  @notice Lets an authorized wallet set a new owner for the contract.
     *  @param _newOwner The address to set as the new owner of the contract.
     */
    function setOwner(address _newOwner) external override {
        if (!_canSetOwner()) {
            revert("Not authorized");
        }
        _setupOwner(_newOwner);
    }

    /// @dev Lets a contract admin set a new owner for the contract. The new owner must be a contract admin.
    function _setupOwner(address _newOwner) internal {
        address _prevOwner = _owner;
        _owner = _newOwner;

        emit OwnerUpdated(_prevOwner, _newOwner);
    }

    /// @dev Returns whether owner can be set in the given execution context.
    function _canSetOwner() internal view virtual returns (bool);
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

/**
 *  Thirdweb's `ContractMetadata` is a contract extension for any base contracts. It lets you set a metadata URI
 *  for you contract.
 *
 *  Additionally, `ContractMetadata` is necessary for NFT contracts that want royalties to get distributed on OpenSea.
 */

interface IContractMetadata {
    /// @dev Returns the metadata URI of the contract.
    function contractURI() external view returns (string memory);

    /**
     *  @dev Sets contract URI for the storefront-level metadata of the contract.
     *       Only module admin can call this function.
     */
    function setContractURI(string calldata _uri) external;

    /// @dev Emitted when the contract URI is updated.
    event ContractURIUpdated(string prevURI, string newURI);
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

/**
 *  Thirdweb's `Ownable` is a contract extension to be used with any base contract. It exposes functions for setting and reading
 *  who the 'owner' of the inheriting smart contract is, and lets the inheriting contract perform conditional logic that uses
 *  information about who the contract's owner is.
 */

interface IOwnable {
    /// @dev Returns the owner of the contract.
    function owner() external view returns (address);

    /// @dev Lets a module admin set a new owner for the contract. The new owner must be a module admin.
    function setOwner(address _newOwner) external;

    /// @dev Emitted when a new Owner is set.
    event OwnerUpdated(address indexed prevOwner, address indexed newOwner);
}