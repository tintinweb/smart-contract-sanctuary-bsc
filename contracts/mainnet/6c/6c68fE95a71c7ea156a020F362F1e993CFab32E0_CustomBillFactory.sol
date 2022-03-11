// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.9;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "./interfaces/IProFactoryStorage.sol";
import "./interfaces/ICustomBill.sol";
import "./interfaces/ICustomTreasury.sol";
import "./interfaces/IBillNft.sol";
import "./Policy.sol";

contract CustomBillFactory is Policy {
    /* ======== STATE VARIABLES ======== */

    address public treasury;
    address public immutable factoryStorage;
    address public immutable subsidyRouter;
    address public DAO; // solhint-disable-line
    address public billImplementationAddress;
    address public treasuryImplementationAddress;
    IBillNft public billNft;
    
    event CreatedBillAndTreasury(
        address initialOwner,
        address payoutToken,
        address principalToken,
        address customTreasury,
        address bill,
        address billNft,
        uint256[] tierCeilings,
        uint256[] fees
    );

    event CreatedBill(
        address initialOwner,
        address payoutToken,
        address principalToken,
        address customTreasury,
        address bill,
        address billNft,
        uint256[] tierCeilings,
        uint256[] fees
    );

    event SetTreasury(address newTrasury);
    event SetDao(address newDao);
    event SetBillNft(address newBillNftAddress);
    event SetBillImplementation(address newBillImplementation);
    event SetTreasuryImplementation(address newTrasuryImplementation);

    /* ======== CONSTRUCTION ======== */

    constructor(
        address _treasury,
        address _factoryStorage,
        address _subsidyRouter,
        address _DAO, // solhint-disable-line
        address _billImplementationAddress,
        address _treasuryImplementationAddress
    ) {
        require(_treasury != address(0), "Treasury cannot be zero address");
        treasury = _treasury;
        require(_factoryStorage != address(0), "factoryStorage can't 0 address");
        factoryStorage = _factoryStorage;
        require(_subsidyRouter != address(0), "Subsidy router can't 0 address");
        subsidyRouter = _subsidyRouter;
        require(_DAO != address(0), "DAO cannot be zero address");
        DAO = _DAO;
        _policy = _DAO;
        require(_billImplementationAddress != address(0), "billImplementationAddress can't 0 address");
        billImplementationAddress = _billImplementationAddress;
        require(_treasuryImplementationAddress != address(0), "treasuryImplementationAddress can't 0 address");
        treasuryImplementationAddress = _treasuryImplementationAddress;
    }

    /* ======== POLICY FUNCTIONS ======== */

    /**
        @notice deploys custom treasury and custom bill contracts and returns address of both
        @param _payoutToken address
        @param _principalToken address
        @param _initialOwner address
        @param _payoutAddress address
        @param _tierCeilings uint256[]
        @param _fees uint256[]
        @param _feeInPayout bool
        @return _treasury address
        @return _bill address
     */
    function createBillAndTreasury(
        address _payoutToken,
        address _principalToken,
        address _initialOwner,
        address _payoutAddress,
        uint256[] calldata _tierCeilings,
        uint256[] calldata _fees,
        bool _feeInPayout
    ) external onlyPolicy returns (address _treasury, address _bill) {
        ICustomTreasury customTreasury = ICustomTreasury(Clones.clone(treasuryImplementationAddress));
        customTreasury.initialize(_payoutToken, _initialOwner, _payoutAddress);
        
        ICustomBill bill = ICustomBill(Clones.clone(billImplementationAddress));
        bill.initialize(
            [address(customTreasury),
            _principalToken,
            treasury,
            subsidyRouter,
            DAO,
            address(billNft),
            _initialOwner],
            _tierCeilings,
            _fees,
            _feeInPayout
        );

        billNft.addMinter(address(bill));

        emit CreatedBillAndTreasury(
            _initialOwner,
            _payoutToken,
            _principalToken,
            address(customTreasury),
            address(bill),
            address(billNft),
            _tierCeilings,
            _fees
        );

        return
            IProFactoryStorage(factoryStorage).pushBill(
                _payoutToken,
                _principalToken,
                address(customTreasury),
                address(bill),
                address(billNft),
                _tierCeilings,
                _fees
            );
    }

    /**
        @notice deploys custom bill contract and returns address of the bill and its treasury
        @param _payoutToken address
        @param _principalToken address
        @param _customTreasury address
        @param _tierCeilings uint256[]
        @param _fees uint256[]
        @param _feeInPayout bool
        @return _treasury address
        @return _bill address
     */
    function createBill(
        address _payoutToken,
        address _principalToken,
        address _customTreasury,
        address _initialOwner,
        uint256[] calldata _tierCeilings,
        uint256[] calldata _fees,
        bool _feeInPayout
    ) external onlyPolicy returns (address _treasury, address _bill) {
        ICustomBill bill = ICustomBill(Clones.clone(billImplementationAddress));
        bill.initialize(
            [_customTreasury,
            _principalToken,
            treasury,
            subsidyRouter,
            DAO,
            address(billNft),
            _initialOwner],
            _tierCeilings,
            _fees,
            _feeInPayout
        );        

        billNft.addMinter(address(bill));

        emit CreatedBill(
            _initialOwner,
            _payoutToken,
            _principalToken,
            _customTreasury,
            address(bill),
            address(billNft),
            _tierCeilings,
            _fees
        );

        return
            IProFactoryStorage(factoryStorage).pushBill(
                _payoutToken,
                _principalToken,
                _customTreasury,
                address(bill),
                address(billNft),
                _tierCeilings,
                _fees
            );
    }

    function setBillNft(IBillNft _billNft) external onlyPolicy {
        billNft = _billNft;
        emit SetBillNft(address(_billNft));
    }

    function setTreasury(address _treasury) external onlyPolicy {
        treasury = _treasury;
        emit SetTreasury(_treasury);
    }

    function setDao(address _dao) external onlyPolicy {
        DAO = _dao;
        emit SetDao(_dao);
    }

    function setBillImplementation(address __billImplementation) external onlyPolicy {
        billImplementationAddress = __billImplementation;
        emit SetBillImplementation(billImplementationAddress);
    }

    function setTreasuryImplementation(address _treasuryImplementation) external onlyPolicy {
        treasuryImplementationAddress = _treasuryImplementation;
        emit SetTreasuryImplementation(treasuryImplementationAddress);
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.9;

interface IProFactoryStorage {
    function pushBill(
        address _payoutToken,
        address _principalToken,
        address _customTreasury,
        address _customBill,
        address _nftAddress,
        uint256[] calldata _tierCeilings,
        uint256[] calldata _fees
    ) external returns (address _treasury, address _bill);
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.9;

interface IPolicy {
    function policy() external view returns (address);

    function renouncePolicy() external;

    function pushPolicy(address newPolicy_) external;

    function pullPolicy() external;
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.9;

interface ICustomTreasury {
    function deposit(
        address _principalTokenAddress,
        uint256 _amountPrincipalToken,
        uint256 _amountPayoutToken
    ) external;

    function initialize(address _payoutToken, address _initialOwner, address _payoutAddress) external;

    function valueOfToken(address _principalTokenAddress, uint256 _amount)
        external
        view
        returns (uint256 value_);

   function payoutToken()
        external
        view
        returns (address token);
    
    function sendPayoutTokens(uint _amountPayoutToken) external;
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.9;

interface ICustomBill {
    function initialize(
        address[7] calldata _config,
            /* address _customTreasury,
            address _principalToken,
            address _treasury,
            address _subsidyRouter,
            address _DAO,
            address _billNft,
            address _initialOwner, */
        uint[] memory _tierCeilings, 
        uint[] memory _fees,
        bool _feeInPayout
    ) external;

    function redeem(
        uint256 billId
    ) external returns (uint256);
}

// SPDX-License-Identifier: GPL-3.0

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

pragma solidity 0.8.9;

interface IBillNft is IERC721Enumerable {
    function addMinter(
        address minter
    ) external;

    function mint(
        address to,
        address billAddress
    ) external returns (uint256);
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.9;

import "./interfaces/IPolicy.sol";

contract Policy is IPolicy {
    address internal _policy;
    address internal _newPolicy;

    event PolicyTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    event PolicyPushed(
        address indexed newPolicy
    );

    constructor() {
        _policy = msg.sender;
        emit PolicyTransferred(address(0), _policy);
    }

    function policy() public view override returns (address) {
        return _policy;
    }

    function newPolicy() public view returns (address) {
        return _newPolicy;
    }

    modifier onlyPolicy() {
        require(_policy == msg.sender, "Caller is not the owner");
        _;
    }

    function renouncePolicy() public virtual override onlyPolicy {
        emit PolicyTransferred(_policy, address(0));
        _policy = address(0);
        _newPolicy = address(0);
    }

    function pushPolicy(address newPolicy_) public virtual override onlyPolicy {
        require(
            newPolicy_ != address(0),
            "New owner is the zero address"
        );
        emit PolicyPushed(newPolicy_);
        _newPolicy = newPolicy_;
    }

    function pullPolicy() public virtual override {
        require(msg.sender == _newPolicy, "msg.sender is not new policy");
        emit PolicyTransferred(_policy, _newPolicy);
        _policy = _newPolicy;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/Clones.sol)

pragma solidity ^0.8.0;

/**
 * @dev https://eips.ethereum.org/EIPS/eip-1167[EIP 1167] is a standard for
 * deploying minimal proxy contracts, also known as "clones".
 *
 * > To simply and cheaply clone contract functionality in an immutable way, this standard specifies
 * > a minimal bytecode implementation that delegates all calls to a known, fixed address.
 *
 * The library includes functions to deploy a proxy using either `create` (traditional deployment) or `create2`
 * (salted deterministic deployment). It also includes functions to predict the addresses of clones deployed using the
 * deterministic method.
 *
 * _Available since v3.4._
 */
library Clones {
    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create opcode, which should never revert.
     */
    function clone(address implementation) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create2 opcode and a `salt` to deterministically deploy
     * the clone. Using the same `implementation` and `salt` multiple time will revert, since
     * the clones cannot be deployed twice at the same address.
     */
    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(address implementation, bytes32 salt)
        internal
        view
        returns (address predicted)
    {
        return predictDeterministicAddress(implementation, salt, address(this));
    }
}