// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (interfaces/draft-IERC1822.sol)

pragma solidity ^0.8.0;

/**
 * @dev ERC1822: Universal Upgradeable Proxy Standard (UUPS) documents a method for upgradeability through a simplified
 * proxy whose upgrades are fully controlled by the current implementation.
 */
interface IERC1822ProxiableUpgradeable {
    /**
     * @dev Returns the storage slot that the proxiable contract assumes is being used to store the implementation
     * address.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy.
     */
    function proxiableUUID() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/beacon/IBeacon.sol)

pragma solidity ^0.8.0;

/**
 * @dev This is the interface that {BeaconProxy} expects of its beacon.
 */
interface IBeaconUpgradeable {
    /**
     * @dev Must return an address that can be used as a delegate call target.
     *
     * {BeaconProxy} will check that this address is a contract.
     */
    function implementation() external view returns (address);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/ERC1967/ERC1967Upgrade.sol)

pragma solidity ^0.8.2;

import "../beacon/IBeaconUpgradeable.sol";
import "../../interfaces/draft-IERC1822Upgradeable.sol";
import "../../utils/AddressUpgradeable.sol";
import "../../utils/StorageSlotUpgradeable.sol";
import "../utils/Initializable.sol";

/**
 * @dev This abstract contract provides getters and event emitting update functions for
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967] slots.
 *
 * _Available since v4.1._
 *
 * @custom:oz-upgrades-unsafe-allow delegatecall
 */
abstract contract ERC1967UpgradeUpgradeable is Initializable {
    function __ERC1967Upgrade_init() internal onlyInitializing {
    }

    function __ERC1967Upgrade_init_unchained() internal onlyInitializing {
    }
    // This is the keccak-256 hash of "eip1967.proxy.rollback" subtracted by 1
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Emitted when the implementation is upgraded.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Returns the current implementation address.
     */
    function _getImplementation() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {
        require(AddressUpgradeable.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    /**
     * @dev Perform implementation upgrade
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Perform implementation upgrade with additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(newImplementation, data);
        }
    }

    /**
     * @dev Perform implementation upgrade with security checks for UUPS proxies, and additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCallUUPS(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        // Upgrades from old implementations will perform a rollback test. This test requires the new
        // implementation to upgrade back to the old, non-ERC1822 compliant, implementation. Removing
        // this special case will break upgrade paths from old UUPS implementation to new ones.
        if (StorageSlotUpgradeable.getBooleanSlot(_ROLLBACK_SLOT).value) {
            _setImplementation(newImplementation);
        } else {
            try IERC1822ProxiableUpgradeable(newImplementation).proxiableUUID() returns (bytes32 slot) {
                require(slot == _IMPLEMENTATION_SLOT, "ERC1967Upgrade: unsupported proxiableUUID");
            } catch {
                revert("ERC1967Upgrade: new implementation is not UUPS");
            }
            _upgradeToAndCall(newImplementation, data, forceCall);
        }
    }

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev Emitted when the admin account has changed.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    /**
     * @dev Returns the current admin.
     */
    function _getAdmin() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {AdminChanged} event.
     */
    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    /**
     * @dev The storage slot of the UpgradeableBeacon contract which defines the implementation for this proxy.
     * This is bytes32(uint256(keccak256('eip1967.proxy.beacon')) - 1)) and is validated in the constructor.
     */
    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    /**
     * @dev Emitted when the beacon is upgraded.
     */
    event BeaconUpgraded(address indexed beacon);

    /**
     * @dev Returns the current beacon.
     */
    function _getBeacon() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value;
    }

    /**
     * @dev Stores a new beacon in the EIP1967 beacon slot.
     */
    function _setBeacon(address newBeacon) private {
        require(AddressUpgradeable.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            AddressUpgradeable.isContract(IBeaconUpgradeable(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    /**
     * @dev Perform beacon upgrade with additional setup call. Note: This upgrades the address of the beacon, it does
     * not upgrade the implementation contained in the beacon (see {UpgradeableBeacon-_setImplementation} for that).
     *
     * Emits a {BeaconUpgraded} event.
     */
    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(IBeaconUpgradeable(newBeacon).implementation(), data);
        }
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function _functionDelegateCall(address target, bytes memory data) private returns (bytes memory) {
        require(AddressUpgradeable.isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return AddressUpgradeable.verifyCallResult(success, returndata, "Address: low-level delegate call failed");
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
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
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/UUPSUpgradeable.sol)

pragma solidity ^0.8.0;

import "../../interfaces/draft-IERC1822Upgradeable.sol";
import "../ERC1967/ERC1967UpgradeUpgradeable.sol";
import "./Initializable.sol";

/**
 * @dev An upgradeability mechanism designed for UUPS proxies. The functions included here can perform an upgrade of an
 * {ERC1967Proxy}, when this contract is set as the implementation behind such a proxy.
 *
 * A security mechanism ensures that an upgrade does not turn off upgradeability accidentally, although this risk is
 * reinstated if the upgrade retains upgradeability but removes the security mechanism, e.g. by replacing
 * `UUPSUpgradeable` with a custom implementation of upgrades.
 *
 * The {_authorizeUpgrade} function must be overridden to include access restriction to the upgrade mechanism.
 *
 * _Available since v4.1._
 */
abstract contract UUPSUpgradeable is Initializable, IERC1822ProxiableUpgradeable, ERC1967UpgradeUpgradeable {
    function __UUPSUpgradeable_init() internal onlyInitializing {
    }

    function __UUPSUpgradeable_init_unchained() internal onlyInitializing {
    }
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable state-variable-assignment
    address private immutable __self = address(this);

    /**
     * @dev Check that the execution is being performed through a delegatecall call and that the execution context is
     * a proxy contract with an implementation (as defined in ERC1967) pointing to self. This should only be the case
     * for UUPS and transparent proxies that are using the current contract as their implementation. Execution of a
     * function through ERC1167 minimal proxies (clones) would not normally pass this test, but is not guaranteed to
     * fail.
     */
    modifier onlyProxy() {
        require(address(this) != __self, "Function must be called through delegatecall");
        require(_getImplementation() == __self, "Function must be called through active proxy");
        _;
    }

    /**
     * @dev Check that the execution is not being performed through a delegate call. This allows a function to be
     * callable on the implementing contract but not through proxies.
     */
    modifier notDelegated() {
        require(address(this) == __self, "UUPSUpgradeable: must not be called through delegatecall");
        _;
    }

    /**
     * @dev Implementation of the ERC1822 {proxiableUUID} function. This returns the storage slot used by the
     * implementation. It is used to validate that the this implementation remains valid after an upgrade.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy. This is guaranteed by the `notDelegated` modifier.
     */
    function proxiableUUID() external view virtual override notDelegated returns (bytes32) {
        return _IMPLEMENTATION_SLOT;
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeTo(address newImplementation) external virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, new bytes(0), false);
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`, and subsequently execute the function call
     * encoded in `data`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, data, true);
    }

    /**
     * @dev Function that should revert when `msg.sender` is not authorized to upgrade the contract. Called by
     * {upgradeTo} and {upgradeToAndCall}.
     *
     * Normally, this function will use an xref:access.adoc[access control] modifier such as {Ownable-onlyOwner}.
     *
     * ```solidity
     * function _authorizeUpgrade(address) internal override onlyOwner {}
     * ```
     */
    function _authorizeUpgrade(address newImplementation) internal virtual;

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

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

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
import "../../../utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
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
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
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
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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
// OpenZeppelin Contracts v4.4.1 (utils/StorageSlot.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, and `uint256`._
 */
library StorageSlotUpgradeable {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        assembly {
            r.slot := slot
        }
    }
}

/**
                                                         __
     _____      __      ___    ___     ___     __       /\_\    ___
    /\ '__`\  /'__`\   /'___\ / __`\  /'___\ /'__`\     \/\ \  / __`\
    \ \ \_\ \/\ \_\.\_/\ \__//\ \_\ \/\ \__//\ \_\.\_  __\ \ \/\ \_\ \
     \ \ ,__/\ \__/.\_\ \____\ \____/\ \____\ \__/.\_\/\_\\ \_\ \____/
      \ \ \/  \/__/\/_/\/____/\/___/  \/____/\/__/\/_/\/_/ \/_/\/___/
       \ \_\
        \/_/

    The sweetest DeFi portfolio manager.

**/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "@openzeppelin/contracts-upgradeable-v4/proxy/utils/Initializable.sol";
import "./Roles.sol";

abstract contract AccessControlled is Initializable, Roles {
    event AuthorityUpdated(address indexed authority);

    function __AccessControlled_init(address _authority) public onlyInitializing {
        authority = IAuthority(_authority);

        emit AuthorityUpdated(_authority);
    }

    function setAuthority(address _newAuthority) external virtual requireRole(ROLE_DAO) {
        authority = IAuthority(_newAuthority);

        emit AuthorityUpdated(_newAuthority);
    }
}

/**
                                                         __
     _____      __      ___    ___     ___     __       /\_\    ___
    /\ '__`\  /'__`\   /'___\ / __`\  /'___\ /'__`\     \/\ \  / __`\
    \ \ \_\ \/\ \_\.\_/\ \__//\ \_\ \/\ \__//\ \_\.\_  __\ \ \/\ \_\ \
     \ \ ,__/\ \__/.\_\ \____\ \____/\ \____\ \__/.\_\/\_\\ \_\ \____/
      \ \ \/  \/__/\/_/\/____/\/___/  \/____/\/__/\/_/\/_/ \/_/\/___/
       \ \_\
        \/_/

    The sweetest DeFi portfolio manager.

**/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "@openzeppelin/contracts-upgradeable-v4/proxy/utils/UUPSUpgradeable.sol";
import "./AccessControlled.sol";

abstract contract ControlledUUPS is UUPSUpgradeable, AccessControlled {
    function __ControlledUUPS_init(address _authority) public onlyInitializing {
        __AccessControlled_init(_authority);
    }

    function _authorizeUpgrade(address) internal override requireRole(ROLE_DAO) {}
}

/**
                                                         __
     _____      __      ___    ___     ___     __       /\_\    ___
    /\ '__`\  /'__`\   /'___\ / __`\  /'___\ /'__`\     \/\ \  / __`\
    \ \ \_\ \/\ \_\.\_/\ \__//\ \_\ \/\ \__//\ \_\.\_  __\ \ \/\ \_\ \
     \ \ ,__/\ \__/.\_\ \____\ \____/\ \____\ \__/.\_\/\_\\ \_\ \____/
      \ \ \/  \/__/\/_/\/____/\/___/  \/____/\/__/\/_/\/_/ \/_/\/___/
       \ \_\
        \/_/

    The sweetest DeFi portfolio manager.

**/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "../interfaces/IAuthority.sol";

abstract contract Roles {
    IAuthority public authority;

    uint8 constant internal ROLE_DAO = 0;
    uint8 constant internal ROLE_OWNER = 1;
    uint8 constant internal ROLE_TREASURY = 2;
    uint8 constant internal ROLE_KEEPER = 3;
    uint8 constant internal ROLE_MANAGER = 4;
    uint8 constant internal ROLE_REWARD_DISTRIBUTOR = 5;

    modifier requireRole(uint8 _role) {
        require(
            authority.userRoles(_role, msg.sender),
            "Authority::requireRole: Unauthorized"
        );

        _;
    }
}

/**
                                                         __
     _____      __      ___    ___     ___     __       /\_\    ___
    /\ '__`\  /'__`\   /'___\ / __`\  /'___\ /'__`\     \/\ \  / __`\
    \ \ \_\ \/\ \_\.\_/\ \__//\ \_\ \/\ \__//\ \_\.\_  __\ \ \/\ \_\ \
     \ \ ,__/\ \__/.\_\ \____\ \____/\ \____\ \__/.\_\/\_\\ \_\ \____/
      \ \ \/  \/__/\/_/\/____/\/___/  \/____/\/__/\/_/\/_/ \/_/\/___/
       \ \_\
        \/_/

    The sweetest DeFi portfolio manager.

**/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "../interfaces/IPancakePair.sol";

library Permit {
    function approve(
        address _token,
        uint _inputTokenAmount,
        bytes calldata _signatureData
    ) internal {
        (uint8 v, bytes32 r, bytes32 s, uint deadline) = abi.decode(_signatureData, (uint8, bytes32, bytes32, uint));

        IPancakePair(_token).permit(
            msg.sender,
            address(this),
            _inputTokenAmount,
            deadline,
            v,
            r,
            s
        );
    }
}

/**
                                                         __
     _____      __      ___    ___     ___     __       /\_\    ___
    /\ '__`\  /'__`\   /'___\ / __`\  /'___\ /'__`\     \/\ \  / __`\
    \ \ \_\ \/\ \_\.\_/\ \__//\ \_\ \/\ \__//\ \_\.\_  __\ \ \/\ \_\ \
     \ \ ,__/\ \__/.\_\ \____\ \____/\ \____\ \__/.\_\/\_\\ \_\ \____/
      \ \ \/  \/__/\/_/\/____/\/___/  \/____/\/__/\/_/\/_/ \/_/\/___/
       \ \_\
        \/_/

    The sweetest DeFi portfolio manager.

**/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

interface IAuthority {
    event SetRole(uint8 indexed role, address indexed user, bool active);

    function dao() external view returns (address);

    function treasury() external view returns (address);

    function rewardDistributor() external view returns (address);

    function userRoles(uint8, address) external view returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.12;

interface IFarm {
    function poolLength() external view returns (uint256);

    function userInfo(uint256 _pid, address _user) external view returns (uint256);

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to) external view returns (uint256);

    // View function to see pending CAKEs on frontend.
    function pending(uint256 _pid, address _user) external view returns (uint256);
    function pendingReward(uint256 _pid, address _user) external view returns (uint256);
    function pendingCake(uint256 _pid, address _user) external view returns (uint256);
    function pendingBSW(uint256 _pid, address _user) external view returns (uint256);
    function pendingEarnings(uint256 _pid, address _user) external view returns (uint256);
    function pendingPACOCA(uint256 _pid, address _user) external view returns (uint256);

    // Deposit LP tokens to MasterChef for CAKE allocation.
    function deposit(uint256 _pid, uint256 _amount) external;
    function deposit(uint256 _pid, uint256 _amount, bool _withdrawRewards) external;
    function deposit(uint256 _pid, uint256 _amount, address _referrer) external;

    // Withdraw LP tokens from MasterChef.
    function withdraw(uint256 _pid, uint256 _amount) external;
    function withdraw(uint256 _pid, uint256 _amount, bool _withdrawRewards) external;

    // Stake CAKE tokens to MasterChef
    function enterStaking(uint256 _amount) external;

    // Withdraw CAKE tokens from STAKING.
    function leaveStaking(uint256 _amount) external;

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.12;

interface IPacocaVault {
    event Deposit(address indexed sender, uint256 amount, uint256 shares, uint256 lastDepositedTime);
    event Withdraw(address indexed sender, uint256 amount, uint256 shares);

    function deposit(uint256 _amount) external;

    function withdraw(uint256 _shares) external;

    function getPricePerFullShare() external view returns (uint256);

    function userInfo(address _user) external view returns (
        uint256 shares,
        uint256 lastDepositedTime,
        uint256 pacocaAtLastUserAction,
        uint256 lastUserActionTime
    );
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.12;

interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.12;

interface IPancakeRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.12;

import "./IPancakeRouter01.sol";

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

/**
                                                         __
     _____      __      ___    ___     ___     __       /\_\    ___
    /\ '__`\  /'__`\   /'___\ / __`\  /'___\ /'__`\     \/\ \  / __`\
    \ \ \_\ \/\ \_\.\_/\ \__//\ \_\ \/\ \__//\ \_\.\_  __\ \ \/\ \_\ \
     \ \ ,__/\ \__/.\_\ \____\ \____/\ \____\ \__/.\_\/\_\\ \_\ \____/
      \ \ \/  \/__/\/_/\/____/\/___/  \/____/\/__/\/_/\/_/ \/_/\/___/
       \ \_\
        \/_/

    The sweetest DeFi portfolio manager.

**/

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.9;

import "../interfaces/IZapStructs.sol";

interface IPeanutZap is IZapStructs {
    function initialize(
        address _treasury,
        address _owner,
        address _wNative
    ) external;

    function zapToken(
        ZapInfo calldata _zapInfo,
        address _inputToken,
        uint _inputTokenAmount
    ) external;

    function zapNative(
        ZapInfo calldata _zapInfo
    ) external payable;

    function unZapToken(
        UnZapInfo calldata _unZapInfo,
        address _outputToken
    ) external;

    function unZapTokenWithPermit(
        UnZapInfo calldata _unZapInfo,
        address _outputToken,
        bytes calldata _signatureData
    ) external;

    function unZapNative(
        UnZapInfo calldata _unZapInfo
    ) external;

    function unZapNativeWithPermit(
        UnZapInfo calldata _unZapInfo,
        bytes calldata _signatureData
    ) external;

    function zapPair(
        ZapPairInfo calldata _zapPairInfo
    ) external;

    function collectDust(
        address _token
    ) external;

    function collectDustMultiple(
        address[] calldata _tokens
    ) external;

    function setTreasury(
        address _treasury
    ) external;

    receive() external payable;
}

/**
                                                         __
     _____      __      ___    ___     ___     __       /\_\    ___
    /\ '__`\  /'__`\   /'___\ / __`\  /'___\ /'__`\     \/\ \  / __`\
    \ \ \_\ \/\ \_\.\_/\ \__//\ \_\ \/\ \__//\ \_\.\_  __\ \ \/\ \_\ \
     \ \ ,__/\ \__/.\_\ \____\ \____/\ \____\ \__/.\_\/\_\\ \_\ \____/
      \ \ \/  \/__/\/_/\/____/\/___/  \/____/\/__/\/_/\/_/ \/_/\/___/
       \ \_\
        \/_/

    The sweetest DeFi portfolio manager.

**/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

interface ISweetVault {

}

/**
                                                         __
     _____      __      ___    ___     ___     __       /\_\    ___
    /\ '__`\  /'__`\   /'___\ / __`\  /'___\ /'__`\     \/\ \  / __`\
    \ \ \_\ \/\ \_\.\_/\ \__//\ \_\ \/\ \__//\ \_\.\_  __\ \ \/\ \_\ \
     \ \ ,__/\ \__/.\_\ \____\ \____/\ \____\ \__/.\_\/\_\\ \_\ \____/
      \ \ \/  \/__/\/_/\/____/\/___/  \/____/\/__/\/_/\/_/ \/_/\/___/
       \ \_\
        \/_/

    The sweetest DeFi portfolio manager.

**/

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.9;

import "../interfaces/IPancakeRouter02.sol";

interface IZapStructs {
    struct InitialBalances {
        uint token0;
        uint token1;
        uint inputToken;
    }

    struct Pair {
        address token0;
        address token1;
    }

    struct ZapInfo {
        IPancakeRouter02 router;
        address[] pathToToken0;
        address[] pathToToken1;
        address outputToken;
        uint minToken0;
        uint minToken1;
    }

    struct UnZapInfo {
        IPancakeRouter02 router;
        address[] pathFromToken0;
        address[] pathFromToken1;
        address inputToken;
        uint inputTokenAmount;
        uint minOutputTokenAmount;
    }

    struct ZapPairInfo {
        IPancakeRouter02 routerSwap;
        IPancakeRouter02 routerIn;
        IPancakeRouter02 routerOut;
        address[] pathFromToken0; // (token0 of inputToken)
        address[] pathFromToken1; // (token1 of inputToken)
        address inputToken;
        address outputToken;
        uint inputTokenAmount;
        uint minTokenA;
        uint minTokenB;
    }
}

/**
                                                         __
     _____      __      ___    ___     ___     __       /\_\    ___
    /\ '__`\  /'__`\   /'___\ / __`\  /'___\ /'__`\     \/\ \  / __`\
    \ \ \_\ \/\ \_\.\_/\ \__//\ \_\ \/\ \__//\ \_\.\_  __\ \ \/\ \_\ \
     \ \ ,__/\ \__/.\_\ \____\ \____/\ \____\ \__/.\_\/\_\\ \_\ \____/
      \ \ \/  \/__/\/_/\/____/\/___/  \/____/\/__/\/_/\/_/ \/_/\/___/
       \ \_\
        \/_/

    The sweetest DeFi portfolio manager.

**/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "@openzeppelin/contracts-upgradeable-v4/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable-v4/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "./interfaces/IFarm.sol";
import "./interfaces/IPancakeRouter02.sol";
import "./interfaces/IPacocaVault.sol";
import "./interfaces/IPeanutZap.sol";
import "./interfaces/ISweetVault.sol";
import "./helpers/Permit.sol";
import "./access/ControlledUUPS.sol";

contract SweetVault_v4 is ISweetVault, IZapStructs, ControlledUUPS, ReentrancyGuardUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    struct UserInfo {
        // How many assets the user has provided.
        uint stake;
        // How many staked $PACOCA user had at his last action
        uint autoPacocaShares;
        // Pacoca shares not entitled to the user
        uint rewardDebt;
        // Timestamp of last user deposit
        uint lastDepositedTime;
    }

    struct FarmInfo {
        uint pid;
        address farm;
        address stakedToken;
        address rewardToken;
    }

    // Addresses
    address public constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public constant PACOCA = 0x55671114d774ee99D653D6C12460c780a67f1D18;
    IPacocaVault public AUTO_PACOCA;

    // Runtime data
    mapping(address => UserInfo) public userInfo; // Info of users
    uint public accSharesPerStakedToken; // Accumulated AUTO_PACOCA shares per staked token, times 1e18.

    // Farm info
    FarmInfo public farmInfo;

    // Settings
    IPancakeRouter02 public router;
    address[] public pathToPacoca; // Path from staked token to PACOCA
    address[] public pathToWbnb; // Path from staked token to WBNB

    address payable public zap;

    uint public platformFee;
    uint public constant platformFeeUL = 1000;

    uint public earlyWithdrawFee;
    uint public constant earlyWithdrawFeeUL = 300;
    uint public constant withdrawFeePeriod = 3 days;

    event Deposit(address indexed user, uint amount);
    event Withdraw(address indexed user, uint amount);
    event EarlyWithdraw(address indexed user, uint amount, uint fee);
    event Earn(uint amount);
    event ClaimRewards(address indexed user, uint shares, uint amount);

    // Setting updates
    event SetPathToPacoca(address[] oldPath, address[] newPath);
    event SetPathToWbnb(address[] oldPath, address[] newPath);
    event SetPlatformFee(uint oldPlatformFee, uint newPlatformFee);
    event SetEarlyWithdrawFee(uint oldEarlyWithdrawFee, uint newEarlyWithdrawFee);

    function initialize(
        FarmInfo memory _farmInfo,
        address _autoPacoca,
        address _router,
        address[] memory _pathToPacoca,
        address[] memory _pathToWbnb,
        address payable _zap,
        address _authority
    ) public initializer {
        require(
            _pathToPacoca[0] == _farmInfo.rewardToken && _pathToPacoca[_pathToPacoca.length - 1] == PACOCA,
            "SweetVault: Incorrect path to PACOCA"
        );

        require(
            _pathToWbnb[0] == _farmInfo.rewardToken && _pathToWbnb[_pathToWbnb.length - 1] == WBNB,
            "SweetVault: Incorrect path to WBNB"
        );

        AUTO_PACOCA = IPacocaVault(_autoPacoca);

        farmInfo = _farmInfo;
        router = IPancakeRouter02(_router);
        pathToPacoca = _pathToPacoca;
        pathToWbnb = _pathToWbnb;

        zap = _zap;

        earlyWithdrawFee = 100;
        platformFee = 550;

        __ReentrancyGuard_init();
        __ControlledUUPS_init(_authority);
    }

    // 1. Harvest rewards
    // 2. Collect fees
    // 3. Convert rewards to $PACOCA
    // 4. Stake to pacoca auto-compound vault
    function earn(
        uint _minPlatformOutput,
        uint _minPacocaOutput
    ) external virtual requireRole(ROLE_KEEPER) {
        address rewardToken = farmInfo.rewardToken;

        harvest();

        // Collect platform fees
        _swap(
            _currentBalance(rewardToken) * platformFee / 10000,
            _minPlatformOutput,
            pathToWbnb,
            authority.rewardDistributor()
        );

        // Convert remaining rewards to PACOCA
        _swap(
            _currentBalance(rewardToken),
            _minPacocaOutput,
            pathToPacoca,
            address(this)
        );

        uint previousShares = totalAutoPacocaShares();
        uint pacocaBalance = _currentBalance(PACOCA);

        _approveTokenIfNeeded(
            PACOCA,
            pacocaBalance,
            address(AUTO_PACOCA)
        );

        AUTO_PACOCA.deposit(pacocaBalance);

        uint currentShares = totalAutoPacocaShares();
        uint newShares = currentShares - previousShares;

        accSharesPerStakedToken = accSharesPerStakedToken + (newShares * 1e18 / totalStake());

        emit Earn(pacocaBalance);
    }

    function harvest() internal virtual {
        FarmInfo memory _farmInfo = farmInfo;

        IFarm(_farmInfo.farm).withdraw(_farmInfo.pid, 0);
    }

    function deposit(uint _amount) external nonReentrant {
        require(_amount > 0, "SweetVault: amount must be greater than zero");

        IERC20Upgradeable(farmInfo.stakedToken).safeTransferFrom(
            address(msg.sender),
            address(this),
            _amount
        );

        _deposit(_amount);
    }

    function depositWithPermit(
        uint _amount,
        bytes calldata _signatureData
    ) external nonReentrant {
        require(_amount > 0, "SweetVault: amount must be greater than zero");

        Permit.approve(farmInfo.stakedToken, _amount, _signatureData);

        IERC20Upgradeable(farmInfo.stakedToken).safeTransferFrom(
            address(msg.sender),
            address(this),
            _amount
        );

        _deposit(_amount);
    }

    function zapAndDeposit(
        ZapInfo calldata _zapInfo,
        address _inputToken,
        uint _inputTokenAmount
    ) external payable nonReentrant {
        address stakedToken = farmInfo.stakedToken;
        uint initialStakedTokenBalance = _currentBalance(stakedToken);

        if (_inputToken == address(0)) {
            IPeanutZap(zap).zapNative{value : msg.value}(
                _zapInfo
            );
        } else {
            uint initialInputTokenBalance = _currentBalance(_inputToken);

            IERC20Upgradeable(_inputToken).safeTransferFrom(
                address(msg.sender),
                address(this),
                _inputTokenAmount
            );

            IERC20Upgradeable(_inputToken).approve(zap, _inputTokenAmount);

            IPeanutZap(zap).zapToken(
                _zapInfo,
                _inputToken,
                _currentBalance(_inputToken) - initialInputTokenBalance
            );
        }

        _deposit(_currentBalance(stakedToken) - initialStakedTokenBalance);
    }

    function zapPairWithPermitAndDeposit(
        ZapPairInfo calldata _zapPairInfo,
        bytes calldata _signature
    ) external payable nonReentrant {
        FarmInfo memory _farmInfo = farmInfo;

        require(
            _zapPairInfo.outputToken == _farmInfo.stakedToken,
            "zapPairWithPermitAndDeposit::Wrong output token"
        );

        uint inputPairInitialBalance = _currentBalance(_zapPairInfo.inputToken);
        uint outputPairInitialBalance = _currentBalance(_zapPairInfo.outputToken);

        Permit.approve(
            _zapPairInfo.inputToken,
            _zapPairInfo.inputTokenAmount,
            _signature
        );

        IERC20Upgradeable(_zapPairInfo.inputToken).safeTransferFrom(
            address(msg.sender),
            address(this),
            _zapPairInfo.inputTokenAmount
        );

        uint inputPairProfit = _currentBalance(_zapPairInfo.inputToken) - inputPairInitialBalance;

        IERC20Upgradeable(_zapPairInfo.inputToken).safeIncreaseAllowance(zap, inputPairProfit);

        IPeanutZap(zap).zapPair(_zapPairInfo);

        _deposit(_currentBalance(_zapPairInfo.outputToken) - outputPairInitialBalance);
    }

    function _deposit(uint _amount) internal virtual {
        UserInfo storage user = userInfo[msg.sender];
        FarmInfo memory _farmInfo = farmInfo;

        _approveTokenIfNeeded(
            _farmInfo.stakedToken,
            type(uint).max,
            _farmInfo.farm
        );

        _stake(_amount);

        _updateAutoPacocaShares(user);
        user.stake = user.stake + _amount;
        _updateRewardDebt(user);
        user.lastDepositedTime = block.timestamp;

        emit Deposit(msg.sender, _amount);
    }

    // _stake function is removed from deposit so it can be overridden for different platforms
    function _stake(uint _amount) internal virtual {
        IFarm(farmInfo.farm).deposit(farmInfo.pid, _amount);
    }

    function withdraw(uint _amount) external virtual nonReentrant {
        UserInfo storage user = userInfo[msg.sender];
        address stakedToken = farmInfo.stakedToken;

        require(_amount > 0, "SweetVault: amount must be greater than zero");
        require(user.stake >= _amount, "SweetVault: withdraw amount exceeds balance");

        uint currentAmount = _withdrawUnderlying(_amount);

        if (block.timestamp < user.lastDepositedTime + withdrawFeePeriod) {
            uint currentWithdrawFee = (currentAmount * earlyWithdrawFee) / 10000;

            IERC20Upgradeable(stakedToken).safeTransfer(authority.treasury(), currentWithdrawFee);

            currentAmount = currentAmount - currentWithdrawFee;

            emit EarlyWithdraw(msg.sender, _amount, currentWithdrawFee);
        }

        _updateAutoPacocaShares(user);
        user.stake = user.stake - _amount;
        _updateRewardDebt(user);

        // Withdraw pacoca rewards if user leaves
        if (user.stake == 0 && user.autoPacocaShares > 0) {
            _claimRewards(user.autoPacocaShares, false);
        }

        IERC20Upgradeable(stakedToken).safeTransfer(msg.sender, currentAmount);

        emit Withdraw(msg.sender, currentAmount);
    }

    function _withdrawUnderlying(uint _amount) internal virtual returns (uint) {
        FarmInfo memory _farmInfo = farmInfo;

        IFarm(_farmInfo.farm).withdraw(_farmInfo.pid, _amount);

        return _amount;
    }

    function claimRewards(uint _shares) external nonReentrant {
        _claimRewards(_shares, true);
    }

    function _claimRewards(uint _shares, bool _update) internal {
        UserInfo storage user = userInfo[msg.sender];

        if (_update) {
            _updateAutoPacocaShares(user);
            _updateRewardDebt(user);
        }

        require(user.autoPacocaShares >= _shares, "SweetVault: claim amount exceeds balance");

        user.autoPacocaShares = user.autoPacocaShares - _shares;

        uint pacocaBalanceBefore = _currentBalance(PACOCA);

        AUTO_PACOCA.withdraw(_shares);

        uint withdrawAmount = _currentBalance(PACOCA) - pacocaBalanceBefore;

        _safePACOCATransfer(msg.sender, withdrawAmount);

        emit ClaimRewards(msg.sender, _shares, withdrawAmount);
    }

    function getExpectedOutputs() external view returns (
        uint platformOutput,
        uint pacocaOutput
    ) {
        uint wbnbOutput = _getExpectedOutput(pathToWbnb);
        uint pacocaOutputWithoutFees = _getExpectedOutput(pathToPacoca);
        uint pacocaOutputFees = pacocaOutputWithoutFees * platformFee / 10000;

        platformOutput = wbnbOutput * platformFee / 10000;
        pacocaOutput = pacocaOutputWithoutFees - pacocaOutputFees;
    }

    function _getExpectedOutput(
        address[] memory _path
    ) internal virtual view returns (uint) {
        FarmInfo memory _farmInfo = farmInfo;

        // TODO pending as separate function
        uint pending = IFarm(_farmInfo.farm).pendingCake(_farmInfo.pid, address(this));

        uint rewards = _currentBalance(_farmInfo.rewardToken) + pending;

        if (rewards == 0) {
            return 0;
        }

        uint[] memory amounts = router.getAmountsOut(rewards, _path);

        return amounts[amounts.length - 1];
    }

    function balanceOf(
        address _user
    ) external view returns (
        uint stake,
        uint pacoca,
        uint autoPacocaShares
    ) {
        UserInfo memory user = userInfo[_user];

        uint pendingShares = (user.stake * accSharesPerStakedToken / 1e18) - user.rewardDebt;

        stake = user.stake;
        autoPacocaShares = user.autoPacocaShares + pendingShares;
        pacoca = autoPacocaShares * AUTO_PACOCA.getPricePerFullShare() / 1e18;
    }

    function _approveTokenIfNeeded(
        address _token,
        uint _amount,
        address _spender
    ) internal {
        IERC20Upgradeable tokenERC20 = IERC20Upgradeable(_token);
        uint allowance = tokenERC20.allowance(address(this), _spender);

        if (allowance < _amount) {
            tokenERC20.safeIncreaseAllowance(_spender, type(uint).max - allowance);
        }
    }

    function _currentBalance(address _token) internal view returns (uint) {
        return IERC20Upgradeable(_token).balanceOf(address(this));
    }

    function totalStake() public view virtual returns (uint) {
        FarmInfo memory _farmInfo = farmInfo;

        return IFarm(_farmInfo.farm).userInfo(_farmInfo.pid, address(this));
    }

    function totalAutoPacocaShares() public view returns (uint) {
        (uint shares, , ,) = AUTO_PACOCA.userInfo(address(this));

        return shares;
    }

    // Safe PACOCA transfer function, just in case if rounding error causes pool to not have enough
    function _safePACOCATransfer(address _to, uint _amount) internal {
        uint balance = _currentBalance(PACOCA);

        if (_amount > balance) {
            IERC20Upgradeable(PACOCA).transfer(_to, balance);
        } else {
            IERC20Upgradeable(PACOCA).transfer(_to, _amount);
        }
    }

    function _swap(
        uint _inputAmount,
        uint _minOutputAmount,
        address[] memory _path,
        address _to
    ) internal virtual {
        _approveTokenIfNeeded(
            farmInfo.rewardToken,
            _inputAmount,
            address(router)
        );

        router.swapExactTokensForTokens(
            _inputAmount,
            _minOutputAmount,
            _path,
            _to,
            block.timestamp
        );
    }

    function _updateAutoPacocaShares(UserInfo storage _user) internal {
        uint totalSharesEarned = (_user.stake * accSharesPerStakedToken) / 1e18;

        _user.autoPacocaShares = _user.autoPacocaShares + totalSharesEarned - _user.rewardDebt;
    }

    function _updateRewardDebt(UserInfo storage _user) internal {
        _user.rewardDebt = (_user.stake * accSharesPerStakedToken) / 1e18;
    }

    function setPathToPacoca(address[] memory _path) external requireRole(ROLE_OWNER) {
        require(
            _path[0] == farmInfo.rewardToken && _path[_path.length - 1] == PACOCA,
            "SweetVault: Incorrect path to PACOCA"
        );

        address[] memory oldPath = pathToPacoca;

        pathToPacoca = _path;

        emit SetPathToPacoca(oldPath, pathToPacoca);
    }

    function setPathToWbnb(address[] memory _path) external requireRole(ROLE_OWNER) {
        require(
            _path[0] == farmInfo.rewardToken && _path[_path.length - 1] == WBNB,
            "SweetVault: Incorrect path to WBNB"
        );

        address[] memory oldPath = pathToWbnb;

        pathToWbnb = _path;

        emit SetPathToWbnb(oldPath, pathToWbnb);
    }

    function setPlatformFee(uint _platformFee) external requireRole(ROLE_OWNER) {
        require(_platformFee <= platformFeeUL, "SweetVault: Platform fee too high");

        uint oldPlatformFee = platformFee;

        platformFee = _platformFee;

        emit SetPlatformFee(oldPlatformFee, platformFee);
    }

    function setEarlyWithdrawFee(uint _earlyWithdrawFee) external requireRole(ROLE_OWNER) {
        require(
            _earlyWithdrawFee <= earlyWithdrawFeeUL,
            "SweetVault: Early withdraw fee too high"
        );

        uint oldEarlyWithdrawFee = earlyWithdrawFee;

        earlyWithdrawFee = _earlyWithdrawFee;

        emit SetEarlyWithdrawFee(oldEarlyWithdrawFee, earlyWithdrawFee);
    }
}

/**
                                                         __
     _____      __      ___    ___     ___     __       /\_\    ___
    /\ '__`\  /'__`\   /'___\ / __`\  /'___\ /'__`\     \/\ \  / __`\
    \ \ \_\ \/\ \_\.\_/\ \__//\ \_\ \/\ \__//\ \_\.\_  __\ \ \/\ \_\ \
     \ \ ,__/\ \__/.\_\ \____\ \____/\ \____\ \__/.\_\/\_\\ \_\ \____/
      \ \ \/  \/__/\/_/\/____/\/___/  \/____/\/__/\/_/\/_/ \/_/\/___/
       \ \_\
        \/_/

    The sweetest DeFi portfolio manager.

**/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "./SweetVault_v4.sol";

contract SweetVault_v5 is SweetVault_v4 {
    function setZap(address payable _zap) external requireRole(ROLE_DAO) {
        zap = _zap;
    }
}

/**
                                                         __
     _____      __      ___    ___     ___     __       /\_\    ___
    /\ '__`\  /'__`\   /'___\ / __`\  /'___\ /'__`\     \/\ \  / __`\
    \ \ \_\ \/\ \_\.\_/\ \__//\ \_\ \/\ \__//\ \_\.\_  __\ \ \/\ \_\ \
     \ \ ,__/\ \__/.\_\ \____\ \____/\ \____\ \__/.\_\/\_\\ \_\ \____/
      \ \ \/  \/__/\/_/\/____/\/___/  \/____/\/__/\/_/\/_/ \/_/\/___/
       \ \_\
        \/_/

    The sweetest DeFi portfolio manager.

**/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "./SweetVault_v6.sol";

// TODO write test as first initialization didn't work
contract SweetVault_v6_Baby is SweetVault_v6 {
    function _getExpectedOutput(
        address[] memory _path
    ) internal virtual override view returns (uint) {
        FarmInfo memory _farmInfo = farmInfo;

        uint pending = IFarm(_farmInfo.farm).pendingReward(_farmInfo.pid, address(this));

        uint rewards = _currentBalance(_farmInfo.rewardToken) + pending;

        if (rewards == 0) {
            return 0;
        }

        uint[] memory amounts = router.getAmountsOut(rewards, _path);

        return amounts[amounts.length - 1];
    }
}

/**
                                                         __
     _____      __      ___    ___     ___     __       /\_\    ___
    /\ '__`\  /'__`\   /'___\ / __`\  /'___\ /'__`\     \/\ \  / __`\
    \ \ \_\ \/\ \_\.\_/\ \__//\ \_\ \/\ \__//\ \_\.\_  __\ \ \/\ \_\ \
     \ \ ,__/\ \__/.\_\ \____\ \____/\ \____\ \__/.\_\/\_\\ \_\ \____/
      \ \ \/  \/__/\/_/\/____/\/___/  \/____/\/__/\/_/\/_/ \/_/\/___/
       \ \_\
        \/_/

    The sweetest DeFi portfolio manager.

**/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "@openzeppelin/contracts-upgradeable-v4/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "./SweetVault_v5.sol";

contract SweetVault_v6 is SweetVault_v5 {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    function withdrawAndUnZap(
        UnZapInfo memory _unZapInfo,
        address _outputToken
    ) external virtual nonReentrant {
        uint initialStakedTokenBalance = _currentBalance(_unZapInfo.inputToken);

        _withdraw(_unZapInfo.inputTokenAmount, address(this));

        uint profit = _currentBalance(_unZapInfo.inputToken) - initialStakedTokenBalance;

        IERC20Upgradeable(_unZapInfo.inputToken).approve(zap, profit);

        _unZapInfo.inputTokenAmount = profit;

        if (_outputToken == address(0)) {
            uint initialOutputTokenBalance = address(this).balance;

            IPeanutZap(zap).unZapNative(_unZapInfo);

            payable(msg.sender).transfer(address(this).balance - initialOutputTokenBalance);
        } else {
            uint initialOutputTokenBalance = _currentBalance(_outputToken);

            IPeanutZap(zap).unZapToken(_unZapInfo, _outputToken);

            IERC20Upgradeable(_outputToken).safeTransfer(
                msg.sender,
                _currentBalance(_outputToken) - initialOutputTokenBalance
            );
        }
    }

    function withdraw(uint _amount) external override virtual nonReentrant {
        _withdraw(_amount, msg.sender);
    }

    function _withdraw(uint _amount, address _to) internal virtual {
        UserInfo storage user = userInfo[msg.sender];
        address stakedToken = farmInfo.stakedToken;

        require(_amount > 0, "SweetVault: amount must be greater than zero");
        require(user.stake >= _amount, "SweetVault: withdraw amount exceeds balance");

        uint currentAmount = _withdrawUnderlying(_amount);

        if (block.timestamp < user.lastDepositedTime + withdrawFeePeriod) {
            uint currentWithdrawFee = (currentAmount * earlyWithdrawFee) / 10000;

            IERC20Upgradeable(stakedToken).safeTransfer(authority.treasury(), currentWithdrawFee);

            currentAmount = currentAmount - currentWithdrawFee;

            emit EarlyWithdraw(msg.sender, _amount, currentWithdrawFee);
        }

        _updateAutoPacocaShares(user);
        user.stake = user.stake - _amount;
        _updateRewardDebt(user);

        // Withdraw pacoca rewards if user leaves
        if (user.stake == 0 && user.autoPacocaShares > 0) {
            _claimRewards(user.autoPacocaShares, false);
        }

        IERC20Upgradeable(stakedToken).safeTransfer(_to, currentAmount);

        emit Withdraw(msg.sender, currentAmount);
    }

    receive() external payable {}
}