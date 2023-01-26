// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@opengsn/contracts/src/BaseRelayRecipient.sol";

import "./ICaskChainlinkTopup.sol";
import "./ICaskChainlinkTopupManager.sol";

contract CaskChainlinkTopup is
ICaskChainlinkTopup,
Initializable,
OwnableUpgradeable,
PausableUpgradeable,
BaseRelayRecipient
{
    using SafeERC20 for IERC20Metadata;

    /** @dev contract to manage ChainlinkTopup executions. */
    ICaskChainlinkTopupManager public chainlinkTopupManager;

    /** @dev map of ChainlinkTopup ID to ChainlinkTopup info. */
    mapping(bytes32 => ChainlinkTopup) private chainlinkTopupMap; // chainlinkTopupId => ChainlinkTopup
    mapping(address => bytes32[]) private userChainlinkTopups; // user => chainlinkTopupId[]
    mapping(uint256 => ChainlinkTopupGroup) private chainlinkTopupGroupMap;

    uint256 public currentGroup;

    uint256[] public backfillGroups;

    /** @dev minimum amount to allow for a topup. */
    uint256 public minTopupAmount;

    uint256 public groupSize;

    function initialize(
        uint256 _groupSize
    ) public initializer {
        __Ownable_init();
        __Pausable_init();

        currentGroup = 1;
        groupSize = _groupSize;
    }
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    function versionRecipient() public pure override returns(string memory) { return "2.2.0"; }

    function _msgSender() internal view override(ContextUpgradeable, BaseRelayRecipient)
    returns (address sender) {
        sender = BaseRelayRecipient._msgSender();
    }

    function _msgData() internal view override(ContextUpgradeable, BaseRelayRecipient)
    returns (bytes calldata) {
        return BaseRelayRecipient._msgData();
    }

    modifier onlyUser(bytes32 _chainlinkTopupId) {
        require(_msgSender() == chainlinkTopupMap[_chainlinkTopupId].user, "!AUTH");
        _;
    }

    modifier onlyManager() {
        require(_msgSender() == address(chainlinkTopupManager), "!AUTH");
        _;
    }


    function createChainlinkTopup(
        uint256 _lowBalance,
        uint256 _topupAmount,
        uint256 _targetId,
        address _registry,
        TopupType _topupType
    ) external override whenNotPaused returns(bytes32) {
        require(_topupAmount >= minTopupAmount, "!INVALID(topupAmount)");
        require(_topupType == TopupType.Automation ||
                _topupType == TopupType.VRF ||
                _topupType == TopupType.Direct, "!INVALID(topupType)");
        if (_topupType != TopupType.Direct) {
            require(chainlinkTopupManager.registryAllowed(_registry), "!INVALID(registry)");
        }

        bytes32 chainlinkTopupId = keccak256(abi.encodePacked(_msgSender(), _targetId, _registry,
            block.number, block.timestamp));

        ChainlinkTopup storage chainlinkTopup = chainlinkTopupMap[chainlinkTopupId];
        chainlinkTopup.user = _msgSender();
        chainlinkTopup.lowBalance = _lowBalance;
        chainlinkTopup.topupAmount = _topupAmount;
        chainlinkTopup.createdAt = uint32(block.timestamp);
        chainlinkTopup.targetId = _targetId;
        chainlinkTopup.registry = _registry;
        chainlinkTopup.topupType = _topupType;
        chainlinkTopup.status = ChainlinkTopupStatus.Active;

        userChainlinkTopups[_msgSender()].push(chainlinkTopupId);

        _assignChainlinkTopupToGroup(chainlinkTopupId);

        chainlinkTopupManager.registerChainlinkTopup(chainlinkTopupId);

        require(chainlinkTopup.status == ChainlinkTopupStatus.Active, "!UNPROCESSABLE");

        emit ChainlinkTopupCreated(chainlinkTopupId, chainlinkTopup.user, chainlinkTopup.lowBalance,
            chainlinkTopup.topupAmount, chainlinkTopup.targetId, chainlinkTopup.registry, chainlinkTopup.topupType);

        return chainlinkTopupId;
    }

    function pauseChainlinkTopup(
        bytes32 _chainlinkTopupId
    ) external override onlyUser(_chainlinkTopupId) whenNotPaused {
        ChainlinkTopup storage chainlinkTopup = chainlinkTopupMap[_chainlinkTopupId];
        require(chainlinkTopup.status == ChainlinkTopupStatus.Active, "!NOT_ACTIVE");

        _removeChainlinkTopupFromGroup(_chainlinkTopupId);

        chainlinkTopup.status = ChainlinkTopupStatus.Paused;

        emit ChainlinkTopupPaused(_chainlinkTopupId, chainlinkTopup.user, chainlinkTopup.targetId,
            chainlinkTopup.registry, chainlinkTopup.topupType);
    }

    function resumeChainlinkTopup(
        bytes32 _chainlinkTopupId
    ) external override onlyUser(_chainlinkTopupId) whenNotPaused {
        ChainlinkTopup storage chainlinkTopup = chainlinkTopupMap[_chainlinkTopupId];
        require(chainlinkTopup.status == ChainlinkTopupStatus.Paused, "!NOT_PAUSED");

        _assignChainlinkTopupToGroup(_chainlinkTopupId);

        chainlinkTopup.numSkips = 0;
        chainlinkTopup.status = ChainlinkTopupStatus.Active;

        chainlinkTopupManager.registerChainlinkTopup(_chainlinkTopupId);

        emit ChainlinkTopupResumed(_chainlinkTopupId, chainlinkTopup.user, chainlinkTopup.targetId,
            chainlinkTopup.registry, chainlinkTopup.topupType);
    }

    function cancelChainlinkTopup(
        bytes32 _chainlinkTopupId
    ) external override onlyUser(_chainlinkTopupId) whenNotPaused {
        ChainlinkTopup storage chainlinkTopup = chainlinkTopupMap[_chainlinkTopupId];
        require(chainlinkTopup.status == ChainlinkTopupStatus.Active ||
                chainlinkTopup.status == ChainlinkTopupStatus.Paused, "!INVALID(status)");

        _removeChainlinkTopupFromGroup(_chainlinkTopupId);

        chainlinkTopup.status = ChainlinkTopupStatus.Canceled;

        emit ChainlinkTopupCanceled(_chainlinkTopupId, chainlinkTopup.user, chainlinkTopup.targetId,
            chainlinkTopup.registry, chainlinkTopup.topupType);
    }

    function getChainlinkTopup(
        bytes32 _chainlinkTopupId
    ) external override view returns (ChainlinkTopup memory) {
        return chainlinkTopupMap[_chainlinkTopupId];
    }

    function getChainlinkTopupGroup(
        uint256 _chainlinkTopupGroupId
    ) external override view returns (ChainlinkTopupGroup memory) {
        return chainlinkTopupGroupMap[_chainlinkTopupGroupId];
    }

    function getUserChainlinkTopup(
        address _user,
        uint256 _idx
    ) external override view returns (bytes32) {
        return userChainlinkTopups[_user][_idx];
    }

    function getUserChainlinkTopupCount(
        address _user
    ) external override view returns (uint256) {
        return userChainlinkTopups[_user].length;
    }

    function _removeChainlinkTopupFromGroup(
        bytes32 _chainlinkTopupId
    ) internal {
        ChainlinkTopup storage chainlinkTopup = chainlinkTopupMap[_chainlinkTopupId];

        uint256 groupId = chainlinkTopup.groupId;
        uint256 groupLen = chainlinkTopupGroupMap[groupId].chainlinkTopups.length;

        // remove topup from group list
        uint256 idx = groupLen;
        for (uint256 i = 0; i < groupLen; i++) {
            if (chainlinkTopupGroupMap[groupId].chainlinkTopups[i] == _chainlinkTopupId) {
                idx = i;
                break;
            }
        }
        if (idx < groupLen) {
            chainlinkTopupGroupMap[groupId].chainlinkTopups[idx] =
                chainlinkTopupGroupMap[groupId].chainlinkTopups[groupLen - 1];
            chainlinkTopupGroupMap[groupId].chainlinkTopups.pop();
        }

        backfillGroups.push(groupId);
    }

    function _findGroupId() internal returns(uint256) {
        uint256 chainlinkTopupGroupId;
        if (backfillGroups.length > 0) {
            chainlinkTopupGroupId = backfillGroups[backfillGroups.length-1];
            backfillGroups.pop();
        } else {
            chainlinkTopupGroupId = currentGroup;
        }
        if (chainlinkTopupGroupId != currentGroup &&
            chainlinkTopupGroupMap[chainlinkTopupGroupId].chainlinkTopups.length >= groupSize)
        {
            chainlinkTopupGroupId = currentGroup;
        }
        if (chainlinkTopupGroupMap[chainlinkTopupGroupId].chainlinkTopups.length >= groupSize) {
            currentGroup += 1;
            chainlinkTopupGroupId = currentGroup;
        }
        return chainlinkTopupGroupId;
    }

    function _assignChainlinkTopupToGroup(
        bytes32 _chainlinkTopupId
    ) internal {
        uint256 chainlinkTopupGroupId = _findGroupId();
        require(chainlinkTopupGroupId > 0, "!GROUP_ERROR");

        ChainlinkTopup storage chainlinkTopup = chainlinkTopupMap[_chainlinkTopupId];
        chainlinkTopup.groupId = chainlinkTopupGroupId;

        ChainlinkTopupGroup storage chainlinkTopupGroup = chainlinkTopupGroupMap[chainlinkTopupGroupId];
        chainlinkTopupGroup.chainlinkTopups.push(_chainlinkTopupId);
    }

    /************************** MANAGER FUNCTIONS **************************/

    function managerCommand(
        bytes32 _chainlinkTopupId,
        ManagerCommand _command
    ) external override onlyManager {

        ChainlinkTopup storage chainlinkTopup = chainlinkTopupMap[_chainlinkTopupId];

        if (_command == ManagerCommand.Pause) {

            chainlinkTopup.status = ChainlinkTopupStatus.Paused;

            _removeChainlinkTopupFromGroup(_chainlinkTopupId);

            emit ChainlinkTopupPaused(_chainlinkTopupId, chainlinkTopup.user, chainlinkTopup.targetId,
                chainlinkTopup.registry, chainlinkTopup.topupType);

        } else if (_command == ManagerCommand.Cancel) {

            chainlinkTopup.status = ChainlinkTopupStatus.Canceled;

            _removeChainlinkTopupFromGroup(_chainlinkTopupId);

            emit ChainlinkTopupCanceled(_chainlinkTopupId, chainlinkTopup.user, chainlinkTopup.targetId,
                chainlinkTopup.registry, chainlinkTopup.topupType);

        }
    }

    function managerProcessed(
        bytes32 _chainlinkTopupId,
        uint256 _amount,
        uint256 _buyQty,
        uint256 _fee
    ) external override onlyManager {
        ChainlinkTopup storage chainlinkTopup = chainlinkTopupMap[_chainlinkTopupId];

        chainlinkTopup.retryAfter = 0;
        chainlinkTopup.currentAmount += _amount;
        chainlinkTopup.currentBuyQty += _buyQty;
        chainlinkTopup.numTopups += 1;

        emit ChainlinkTopupProcessed(_chainlinkTopupId, chainlinkTopup.user, chainlinkTopup.targetId,
            chainlinkTopup.registry, chainlinkTopup.topupType, _amount, _buyQty, _fee);
    }

    function managerSkipped(
        bytes32 _chainlinkTopupId,
        uint32 _retryAfter,
        SkipReason _skipReason
    ) external override onlyManager {
        ChainlinkTopup storage chainlinkTopup = chainlinkTopupMap[_chainlinkTopupId];

        chainlinkTopup.retryAfter = _retryAfter;
        chainlinkTopup.numSkips += 1;

        emit ChainlinkTopupSkipped(_chainlinkTopupId, chainlinkTopup.user, chainlinkTopup.targetId,
            chainlinkTopup.registry, chainlinkTopup.topupType, _skipReason);
    }

    /************************** ADMIN FUNCTIONS **************************/

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function setManager(
        address _chainlinkTopupManager
    ) external onlyOwner {
        chainlinkTopupManager = ICaskChainlinkTopupManager(_chainlinkTopupManager);
    }

    function setTrustedForwarder(
        address _forwarder
    ) external onlyOwner {
        _setTrustedForwarder(_forwarder);
    }

    function setMinTopupAmount(
        uint256 _minTopupAmount
    ) external onlyOwner {
        minTopupAmount = _minTopupAmount;
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

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
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
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
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

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

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
    function __Ownable_init() internal onlyInitializing {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
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
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

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
    function __Pausable_init() internal onlyInitializing {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
// solhint-disable no-inline-assembly
pragma solidity >=0.6.9;

import "./interfaces/IRelayRecipient.sol";

/**
 * A base contract to be inherited by any contract that want to receive relayed transactions
 * A subclass must use "_msgSender()" instead of "msg.sender"
 */
abstract contract BaseRelayRecipient is IRelayRecipient {

    /*
     * Forwarder singleton we accept calls from
     */
    address private _trustedForwarder;

    function trustedForwarder() public virtual view returns (address){
        return _trustedForwarder;
    }

    function _setTrustedForwarder(address _forwarder) internal {
        _trustedForwarder = _forwarder;
    }

    function isTrustedForwarder(address forwarder) public virtual override view returns(bool) {
        return forwarder == _trustedForwarder;
    }

    /**
     * return the sender of this call.
     * if the call came through our trusted forwarder, return the original sender.
     * otherwise, return `msg.sender`.
     * should be used in the contract anywhere instead of msg.sender
     */
    function _msgSender() internal override virtual view returns (address ret) {
        if (msg.data.length >= 20 && isTrustedForwarder(msg.sender)) {
            // At this point we know that the sender is a trusted forwarder,
            // so we trust that the last bytes of msg.data are the verified sender address.
            // extract sender address from the end of msg.data
            assembly {
                ret := shr(96,calldataload(sub(calldatasize(),20)))
            }
        } else {
            ret = msg.sender;
        }
    }

    /**
     * return the msg.data of this call.
     * if the call came through our trusted forwarder, then the real sender was appended as the last 20 bytes
     * of the msg.data - so this method will strip those 20 bytes off.
     * otherwise (if the call was made directly and not through the forwarder), return `msg.data`
     * should be used in the contract instead of msg.data, where this difference matters.
     */
    function _msgData() internal override virtual view returns (bytes calldata ret) {
        if (msg.data.length >= 20 && isTrustedForwarder(msg.sender)) {
            return msg.data[0:msg.data.length-20];
        } else {
            return msg.data;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICaskChainlinkTopup {

    enum ChainlinkTopupStatus {
        None,
        Active,
        Paused,
        Canceled
    }

    enum ManagerCommand {
        None,
        Cancel,
        Pause
    }

    enum SkipReason {
        None,
        PaymentFailed,
        SwapFailed
    }

    enum TopupType {
        None,
        Automation,
        VRF,
        Direct
    }

    struct ChainlinkTopup {
        address user;
        uint256 groupId;
        uint256 lowBalance;
        uint256 topupAmount;
        uint256 currentAmount;
        uint256 currentBuyQty;
        uint256 numTopups;
        uint256 numSkips;
        uint32 createdAt;
        uint256 targetId;
        address registry;
        TopupType topupType;
        ChainlinkTopupStatus status;
        uint32 retryAfter;
    }

    struct ChainlinkTopupGroup {
        bytes32[] chainlinkTopups;
    }

    function createChainlinkTopup(
        uint256 _lowBalance,
        uint256 _topupAmount,
        uint256 _targetId,
        address _registry,
        TopupType _topupType
    ) external returns(bytes32);

    function getChainlinkTopup(bytes32 _chainlinkTopupId) external view returns (ChainlinkTopup memory);

    function getChainlinkTopupGroup(uint256 _chainlinkTopupGroupId) external view returns (ChainlinkTopupGroup memory);

    function getUserChainlinkTopup(address _user, uint256 _idx) external view returns (bytes32);

    function getUserChainlinkTopupCount(address _user) external view returns (uint256);

    function cancelChainlinkTopup(bytes32 _chainlinkTopupId) external;

    function pauseChainlinkTopup(bytes32 _chainlinkTopupId) external;

    function resumeChainlinkTopup(bytes32 _chainlinkTopupId) external;

    function managerCommand(bytes32 _chainlinkTopupId, ManagerCommand _command) external;

    function managerProcessed(bytes32 _chainlinkTopupId, uint256 _amount, uint256 _buyQty, uint256 _fee) external;

    function managerSkipped(bytes32 _chainlinkTopupId, uint32 _retryAfter, SkipReason _skipReason) external;

    event ChainlinkTopupCreated(bytes32 indexed chainlinkTopupId, address indexed user, uint256 lowBalance,
        uint256 topupAmount, uint256 targetId, address registry, TopupType topupType);

    event ChainlinkTopupPaused(bytes32 indexed chainlinkTopupId, address indexed user, uint256 targetId,
        address registry, TopupType topupType);

    event ChainlinkTopupResumed(bytes32 indexed chainlinkTopupId, address indexed user, uint256 targetId,
        address registry, TopupType topupType);

    event ChainlinkTopupSkipped(bytes32 indexed chainlinkTopupId, address indexed user, uint256 targetId,
        address registry, TopupType topupType, SkipReason skipReason);

    event ChainlinkTopupProcessed(bytes32 indexed chainlinkTopupId, address indexed user, uint256 targetId,
        address registry, TopupType topupType, uint256 amount, uint256 buyQty, uint256 fee);

    event ChainlinkTopupCanceled(bytes32 indexed chainlinkTopupId, address indexed user, uint256 targetId,
        address registry, TopupType topupType);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICaskChainlinkTopupManager {

    enum SwapProtocol {
        UniV2,
        UniV3,
        GMX,
        JoeV2
    }

    enum ChainlinkRegistryType {
        NONE,
        Automation_V1_2,
        Automation_V1_3,
        Automation_V2_0,
        VRF_V2
    }

    function registerChainlinkTopup(bytes32 _chainlinkTopupId) external;

    function registryAllowed(address _registry) external view returns(bool);

    /** @dev Emitted the feeDistributor is changed. */
    event SetFeeDistributor(address feeDistributor);

    /** @dev Emitted when a registry is allowed. */
    event RegistryAllowed(address registry);

    /** @dev Emitted when a registry is disallowed. */
    event RegistryDisallowed(address registry);

    /** @dev Emitted when manager parameters are changed. */
    event SetParameters();

    /** @dev Emitted when chainlink addresses are changed. */
    event SetChainlinkAddresses();
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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
    function __Context_init() internal onlyInitializing {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;

/**
 * a contract must implement this interface in order to support relayed transaction.
 * It is better to inherit the BaseRelayRecipient as its implementation.
 */
abstract contract IRelayRecipient {

    /**
     * return if the forwarder is trusted to forward relayed transactions to us.
     * the forwarder is required to verify the sender's signature, and verify
     * the call is not a replay.
     */
    function isTrustedForwarder(address forwarder) public virtual view returns(bool);

    /**
     * return the sender of this call.
     * if the call came through our trusted forwarder, then the real sender is appended as the last 20 bytes
     * of the msg.data.
     * otherwise, return `msg.sender`
     * should be used in the contract anywhere instead of msg.sender
     */
    function _msgSender() internal virtual view returns (address);

    /**
     * return the msg.data of this call.
     * if the call came through our trusted forwarder, then the real sender was appended as the last 20 bytes
     * of the msg.data - so this method will strip those 20 bytes off.
     * otherwise (if the call was made directly and not through the forwarder), return `msg.data`
     * should be used in the contract instead of msg.data, where this difference matters.
     */
    function _msgData() internal virtual view returns (bytes calldata);

    function versionRecipient() external virtual view returns (string memory);
}