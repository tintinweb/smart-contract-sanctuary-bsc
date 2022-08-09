// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "../functioncall/interface/NonAtomicHiddenAuthParameters.sol";
import "../functioncall/interface/CrosschainFunctionCallInterface.sol";
import "../common/System.sol";

contract PosiBridge is
    NonAtomicHiddenAuthParameters,
    ReentrancyGuardUpgradeable,
    PausableUpgradeable,
    OwnableUpgradeable
{
    address public constant POSI_TOKEN_ADDRESS = 0x5CA42204cDaa70d5c773946e69dE942b85CA6706;
    // Simple Function Call bridge.
    CrosschainFunctionCallInterface private crosschainControl;

    uint256 posiChainId;

    uint256 minimumTransferAmount;
    address private posiChainTokenHubContract;
    address private posiCrosschainControlAddress;

    // Mapping of user address to deposited amount of that address.
    mapping(address => uint256) public depositedAmount;

    modifier onlyCrosschainBridge() {
        require(address(crosschainControl) == _msgSender(), "only crosschain bridge");
        _;
    }

    /**
     * Indicates a request to transfer some tokens has occurred on this blockchain.
     *
     * @param _destBcId           Blockchain the tokens are being transferred to.
     * @param _srcTokenContract   Address of the ERC 20 token contract on this blockchain.
     * @param _destTokenContract  Address of the ERC 20 token contract on the blockchain
     *                            the tokens are being transferred to.
     * @param _sender             Address sending the tokens.
     * @param _recipient          Address to transfer the tokens to on the target blockchain.
     * @param _amount             Number of tokens to transfer.
     */
    event TransferTo(
        uint256 _destBcId,
        address _srcTokenContract,
        address _destTokenContract,
        address _sender,
        address _recipient,
        uint256 _amount
    );

    /**
     * Indicates a transfer request has been received on this blockchain.
     *
     * @param _srcBcId            Blockchain the tokens are being transferred from.
     * @param _recipient          Address to transfer the tokens to on the this blockchain.
     * @param _amount             Number of tokens to transfer.
     */
    event ReceivedFrom(
        uint256 _srcBcId,
        address _srcTokenContract,
        address _destTokenContract,
        address _recipient,
        uint256 _amount
    );

    /**
     * Update the mapping between other blockchain id and an ERC 20
     * contract on that blockchain.
     *
     * @param _otherBcId            Blockchain ID where the corresponding ERC 20 contract resides.
     * @param _othercTokenContract  Address of ERC 20 contract on the other blockchain.
     */
    event TokenContractAddressMappingChanged(
        uint256 _otherBcId,
        address _othercTokenContract
    );

    /**
     * Indicate an administrative transfer has occurred.
     *
     * @param _recipient        Address to transfer the tokens to.
     * @param _amount           Number of tokens to transfer.
     */
    event AdminTransfer(
        address _recipient,
        uint256 _amount
    );


    function initialize(
        address _crosschainControl,
        address _posiChainTokenHubContract,
        address _posiCrosschainControlAddress,
        uint256 _minimumTransferAmount,
        uint256 _posiChainId
    ) public initializer {
        __ReentrancyGuard_init();
        __Ownable_init();
        __Pausable_init();

        crosschainControl = CrosschainFunctionCallInterface(_crosschainControl);
        posiChainTokenHubContract = _posiChainTokenHubContract;
        posiCrosschainControlAddress = _posiCrosschainControlAddress;
        minimumTransferAmount = _minimumTransferAmount;
        posiChainId = _posiChainId;
    }

    /**
     * Update Posi chain token hub contract.
     *
     * Requirements:
     * - the caller must be owner.
     *
     * @param _posiChainTokenHubContract     Address of contract bridge on Posichain.
     */
    function updatePosiChainTokenHubContract(
        address _posiChainTokenHubContract
    ) external onlyOwner {
        posiChainTokenHubContract = _posiChainTokenHubContract;
    }

    /**
     * Update BNB chain crosschain control contract.
     *
     * Requirements:
     * - the caller must be owner.
     *
     * @param _crosschainControlContract     Address of contract crosschain control on BNB chain.
     */
    function updateCrosschainBridgeContract(
        address _crosschainControlContract
    ) external onlyOwner {
        crosschainControl = CrosschainFunctionCallInterface(_crosschainControlContract);
    }

    /**
     * Update Posi chain crosschain control contract.
     *
     * Requirements:
     * - the caller must be owner.
     *
     * @param _posiCrosschainControlAddress     Address of contract crosschain control on Posichain.
     */
    function updatePosiCrosschainControlContract(
        address _posiCrosschainControlAddress
    ) external onlyOwner {
        posiCrosschainControlAddress = _posiCrosschainControlAddress;
    }

    /**
     * Update Posi chain id control contract.
     *
     * Requirements:
     * - the caller must be owner.
     *
     * @param _posiChainId     Address of contract crosschain control on Posichain.
     */
    function updatePosiChainId(
        uint256 _posiChainId
    ) external onlyOwner {
        posiChainId = _posiChainId;
    }

    /**
     * Update minimum transfer amount.
     *
     * Requirements:
     * - the caller must be owner.
     *
     * @param _minimumTransferAmount     Minimum transfer amount each transaction.
     */
    function updateMinimumTransferAmount(
        uint256 _minimumTransferAmount
    ) external onlyOwner {
        minimumTransferAmount = _minimumTransferAmount;
    }

    /**
     * Transfer POSI tokens to Posi blockchain
     *
     * NOTE: msg.sender must have called approve() on the token contract.
     *
     * @param _recipient        Address of account to transfer tokens to on the Posi blockchain.
     * @param _amount           The number of tokens to transfer.
     */
    function transferToOtherBlockchain(
        address _recipient,
        uint256 _amount
    ) public {
        require(_amount >= minimumTransferAmount, "must reach minimum transfer amount");

        address destBridgeContract = posiChainTokenHubContract;
        require(
            destBridgeContract != address(0),
            "Posi Bridge: Posichain bridge contract is not initialized"
        );

        address destTokenContract = address(0);

        // transfer token from msg.sender to this contract address
        if (
            !IERC20(POSI_TOKEN_ADDRESS).transferFrom(
                msg.sender,
                address(this),
                _amount
            )
        ) {
            revert("transferFrom failed");
        }

        // Posi token in BNB chain affected by RFI technology
        _amount = _amount * 99 / 100;
        // Update total deposited amount of transaction sender
        depositedAmount[msg.sender] += _amount;

        crosschainControl.crossBlockchainCall(
            posiChainId,
            destBridgeContract,
            abi.encodeWithSelector(
                this.receiveFromOtherBlockchain.selector,
                destTokenContract,
                _recipient,
                _amount
            )
        );

        emit TransferTo(
            posiChainId,
            POSI_TOKEN_ADDRESS,
            destTokenContract,
            msg.sender,
            _recipient,
            _amount
        );
    }

    /**
     * Transfer tokens that are owned by this contract to a recipient. The tokens have
     * effectively been transferred from another blockchain to this blockchain.
     *
     * @param _destTokenContract  Contract address of the token being transferred.
     * @param _recipient          Account to transfer ownership of the tokens to.
     * @param _amount             The number of tokens to be transferred.
     */
    function receiveFromOtherBlockchain(
        address _destTokenContract,
        address _recipient,
        uint256 _amount
    ) external onlyCrosschainBridge {
        // Decode and verify sourceBcId and sourceContract
        (
        uint256 sourceBcId,
        address sourceBridgeContract
        ) = decodeNonAtomicAuthParams();
        // The source blockchain id is validated at the function call layer. No need to check
        // that it isn't zero.

        require(
            sourceBridgeContract == posiChainTokenHubContract,
            "Posi Bridge: Incorrect source Posi Bridge"
        );

        // DestTokenContract must be posi token
        if (_destTokenContract != POSI_TOKEN_ADDRESS) {
            revert("Posi Bridge: Not support other token than posi");
        }

        if (!IERC20(_destTokenContract).transfer(_recipient, _amount)) {
            revert("transfer failed");
        }

        // reduce deposited amount of recipient when transfer _amount out
        if (depositedAmount[_recipient] > _amount) {
            depositedAmount[_recipient] -= _amount;
        } else {
            depositedAmount[_recipient] = 0;
        }

        emit ReceivedFrom(
            sourceBcId,
            sourceBridgeContract,
            _destTokenContract,
            _recipient,
            _amount
        );
    }

    /**
     * Transfer amount of token to anyone.
     * This amount need to be lower than total deposited amount of recipient
     * This is needed to provide refunds to customers
     * who have had failed transactions where the token transfer occurred on this
     * blockchain, but did not happen on the destination blockchain.
     *
     * This function needs to be used with extreme caution. A system with
     * users' funds escrowed into this contact while they are used on a rollup
     * or sidechain needs to be kept in perfect balance. That is, the number of
     * escrowed tokens must match the number of tokens on other blockchains.
     *
     * Requirements:
     * - the caller must have be GovernmentHub.
     *
     * @param _recipient        Address to transfer the tokens to.
     * @param _amount           Number of tokens to transfer.
     */
    function adminTransfer(
        address _recipient,
        uint256 _amount
    ) external onlyOwner {
        require(_amount < depositedAmount[_recipient], "refund amount is higher than total deposited");
        if (!IERC20(POSI_TOKEN_ADDRESS).transfer(_recipient, _amount)) {
            revert("transfer failed");
        }
        emit AdminTransfer(_recipient, _amount);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    function __Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuardUpgradeable is Initializable {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}

/*
 * Copyright 2021 ConsenSys AG.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
 * an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations under the License.
 *
 * SPDX-License-Identifier: Apache-2.0
 */
pragma solidity >=0.8;

abstract contract NonAtomicHiddenAuthParameters {
    /**
     * Add authentication parameters to the end of an existing function call.
     *
     * @param _functionCall       Function selector and an arbitrary list of parameters.
     * @param _sourceBlockchainId Blockchain identifier of the blockchain that is calling the function.
     * @param _sourceContract     The address of the contract that is calling the function.
     */
    function encodeNonAtomicAuthParams(
        bytes memory _functionCall,
        uint256 _sourceBlockchainId,
        address _sourceContract
    ) internal pure returns (bytes memory) {
        return
            bytes.concat(
                _functionCall,
                abi.encodePacked(_sourceBlockchainId, _sourceContract)
            );
    }

    /**
     * Extract authentication values from the end of the call data. The parameters are expected to have been
     * added to the end of the function call using encodeNonAtomicAuthParams.
     *
     * @return _sourceBlockchainId Blockchain identifier of the blockchain that is calling the function.
     * @return _sourceContract     The address of the contract that is calling the function.
     */
    function decodeNonAtomicAuthParams()
        internal
        pure
        returns (uint256 _sourceBlockchainId, address _sourceContract)
    {
        bytes calldata allParams = msg.data;
        uint256 len = allParams.length;

        assembly {
            calldatacopy(0x0, sub(len, 52), 32)
            _sourceBlockchainId := mload(0)
            calldatacopy(12, sub(len, 20), 20)
            _sourceContract := mload(0)
        }
    }
}

/*
 * Copyright 2021 ConsenSys Software Inc
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
 * an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations under the License.
 *
 * SPDX-License-Identifier: Apache-2.0
 */
pragma solidity >=0.8;

/**
 * Crosschain Function Call Interface allows applications to call functions on other blockchains
 * and to get information about the currently executing function call.
 *
 */
interface CrosschainFunctionCallInterface {
    /**
     * Call a function on another blockchain. All function call implementations must implement
     * this function.
     *
     * @param _bcId Blockchain identifier of blockchain to be called.
     * @param _contract The address of the contract to be called.
     * @param _functionCallData The function selector and parameter data encoded using ABI encoding rules.
     */
    function crossBlockchainCall(
        uint256 _bcId,
        address _contract,
        bytes calldata _functionCallData
    ) external;
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.0;

abstract contract System {

    bool public alreadyInit;

    // TODO CHANGE GENESIS ADDRESS
    address public constant POSITION_ADMIN_ADDR = 0x0000000000000000000000000000000000001001;
    address public constant GOVERNANCE_HUB_ADDR = 0x0000000000000000000000000000000000001002;
    address public constant SYSTEM_REWARD_ADDR = 0x0000000000000000000000000000000000001003;
    address public constant RELAYER_HUB_ADDR = 0x0000000000000000000000000000000000001004;
    address public constant RELAYER_INCENTIVE_ADDR = 0x0000000000000000000000000000000000001005;

    // NOTE: only init those two address on Posi chain
    address public constant TOKEN_HUB_ADDR = 0x0000000000000000000000000000000000001006;
    address public constant CROSS_CHAIN_ADDR = 0x0000000000000000000000000000000000001007;

    modifier onlyPositionAdmin() {
        require(
            msg.sender == POSITION_ADMIN_ADDR,
            "Only Position Admin Address"
        );
        _;
    }

    modifier onlyGovernmentHub() {
        require(
            msg.sender == GOVERNANCE_HUB_ADDR,
            "Only Governance Hub Contract"
        );
        _;
    }

    modifier onlySystemReward() {
        require(
            msg.sender == SYSTEM_REWARD_ADDR,
            "Only System Reward Contract"
        );
        _;
    }

    modifier onlyRelayerHub() {
        require(
            msg.sender == RELAYER_HUB_ADDR,
            "Only Relayer Hub Contract"
        );
        _;
    }

    modifier onlyRelayerIncentive() {
        require(
            msg.sender == RELAYER_INCENTIVE_ADDR,
            "Only Relayer Incentive Contract"
        );
        _;
    }

    modifier onlyTokenHub() {
        require(
            msg.sender == TOKEN_HUB_ADDR,
            "Only Token Hub Contract"
        );
        _;
    }

    modifier onlyCrosschain() {
        require(
            msg.sender == CROSS_CHAIN_ADDR,
            "Only Cross-chain Contract"
        );
        _;
    }


}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}