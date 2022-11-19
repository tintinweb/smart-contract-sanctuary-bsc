// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControlEnumerable.sol)

pragma solidity ^0.8.0;

import "./IAccessControlUpgradeable.sol";

/**
 * @dev External interface of AccessControlEnumerable declared to support ERC165 detection.
 */
interface IAccessControlEnumerableUpgradeable is IAccessControlUpgradeable {
    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) external view returns (address);

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControlUpgradeable {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

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
// OpenZeppelin Contracts (last updated v4.8.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
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
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that functions marked with `initializer` can be nested in the context of a
     * constructor.
     *
     * Emits an {Initialized} event.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: setting the version to 255 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    /**
     * @dev Internal function that returns the initialized version. Returns `_initialized`
     */
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    /**
     * @dev Internal function that returns the initialized version. Returns `_initializing`
     */
    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (proxy/utils/UUPSUpgradeable.sol)

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
     * implementation. It is used to validate the implementation's compatibility when performing an upgrade.
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20PermitUpgradeable {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20MetadataUpgradeable is IERC20Upgradeable {
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

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
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
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
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
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
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/cryptography/draft-EIP712.sol)

pragma solidity ^0.8.0;

// EIP-712 is Final as of 2022-08-11. This file is deprecated.

import "./EIP712Upgradeable.sol";

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

import "../StringsUpgradeable.sol";

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSAUpgradeable {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV // Deprecated in v4.8
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", StringsUpgradeable.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/cryptography/EIP712.sol)

pragma solidity ^0.8.0;

import "./ECDSAUpgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.
 *
 * The encoding specified in the EIP is very generic, and such a generic implementation in Solidity is not feasible,
 * thus this contract does not implement the encoding itself. Protocols need to implement the type-specific encoding
 * they need in their contracts using a combination of `abi.encode` and `keccak256`.
 *
 * This contract implements the EIP 712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding
 * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA
 * ({_hashTypedDataV4}).
 *
 * The implementation of the domain separator was designed to be as efficient as possible while still properly updating
 * the chain id to protect against replay attacks on an eventual fork of the chain.
 *
 * NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method
 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
 *
 * _Available since v3.4._
 *
 * @custom:storage-size 52
 */
abstract contract EIP712Upgradeable is Initializable {
    /* solhint-disable var-name-mixedcase */
    bytes32 private _HASHED_NAME;
    bytes32 private _HASHED_VERSION;
    bytes32 private constant _TYPE_HASH = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

    /* solhint-enable var-name-mixedcase */

    /**
     * @dev Initializes the domain separator and parameter caches.
     *
     * The meaning of `name` and `version` is specified in
     * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP 712]:
     *
     * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.
     * - `version`: the current major version of the signing domain.
     *
     * NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart
     * contract upgrade].
     */
    function __EIP712_init(string memory name, string memory version) internal onlyInitializing {
        __EIP712_init_unchained(name, version);
    }

    function __EIP712_init_unchained(string memory name, string memory version) internal onlyInitializing {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        return _buildDomainSeparator(_TYPE_HASH, _EIP712NameHash(), _EIP712VersionHash());
    }

    function _buildDomainSeparator(
        bytes32 typeHash,
        bytes32 nameHash,
        bytes32 versionHash
    ) private view returns (bytes32) {
        return keccak256(abi.encode(typeHash, nameHash, versionHash, block.chainid, address(this)));
    }

    /**
     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
     * function returns the hash of the fully encoded EIP712 message for this domain.
     *
     * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
     *
     * ```solidity
     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
     *     keccak256("Mail(address to,string contents)"),
     *     mailTo,
     *     keccak256(bytes(mailContents))
     * )));
     * address signer = ECDSA.recover(digest, signature);
     * ```
     */
    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return ECDSAUpgradeable.toTypedDataHash(_domainSeparatorV4(), structHash);
    }

    /**
     * @dev The hash of the name parameter for the EIP712 domain.
     *
     * NOTE: This function reads from storage by default, but can be redefined to return a constant value if gas costs
     * are a concern.
     */
    function _EIP712NameHash() internal virtual view returns (bytes32) {
        return _HASHED_NAME;
    }

    /**
     * @dev The hash of the version parameter for the EIP712 domain.
     *
     * NOTE: This function reads from storage by default, but can be redefined to return a constant value if gas costs
     * are a concern.
     */
    function _EIP712VersionHash() internal virtual view returns (bytes32) {
        return _HASHED_VERSION;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library MathUpgradeable {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1);

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding rounding
    ) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10**64) {
                value /= 10**64;
                result += 64;
            }
            if (value >= 10**32) {
                value /= 10**32;
                result += 32;
            }
            if (value >= 10**16) {
                value /= 10**16;
                result += 16;
            }
            if (value >= 10**8) {
                value /= 10**8;
                result += 8;
            }
            if (value >= 10**4) {
                value /= 10**4;
                result += 4;
            }
            if (value >= 10**2) {
                value /= 10**2;
                result += 2;
            }
            if (value >= 10**1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (rounding == Rounding.Up && 10**result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256, rounded down, of a positive value.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result * 8) < value ? 1 : 0);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/StorageSlot.sol)

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
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

import "./math/MathUpgradeable.sol";

/**
 * @dev String operations.
 */
library StringsUpgradeable {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = MathUpgradeable.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, MathUpgradeable.log256(value) + 1);
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/structs/BitMaps.sol)
pragma solidity ^0.8.0;

/**
 * @dev Library for managing uint256 to bool mapping in a compact and efficient way, providing the keys are sequential.
 * Largely inspired by Uniswap's https://github.com/Uniswap/merkle-distributor/blob/master/contracts/MerkleDistributor.sol[merkle-distributor].
 */
library BitMapsUpgradeable {
    struct BitMap {
        mapping(uint256 => uint256) _data;
    }

    /**
     * @dev Returns whether the bit at `index` is set.
     */
    function get(BitMap storage bitmap, uint256 index) internal view returns (bool) {
        uint256 bucket = index >> 8;
        uint256 mask = 1 << (index & 0xff);
        return bitmap._data[bucket] & mask != 0;
    }

    /**
     * @dev Sets the bit at `index` to the boolean `value`.
     */
    function setTo(
        BitMap storage bitmap,
        uint256 index,
        bool value
    ) internal {
        if (value) {
            set(bitmap, index);
        } else {
            unset(bitmap, index);
        }
    }

    /**
     * @dev Sets the bit at `index`.
     */
    function set(BitMap storage bitmap, uint256 index) internal {
        uint256 bucket = index >> 8;
        uint256 mask = 1 << (index & 0xff);
        bitmap._data[bucket] |= mask;
    }

    /**
     * @dev Unsets the bit at `index`.
     */
    function unset(BitMap storage bitmap, uint256 index) internal {
        uint256 bucket = index >> 8;
        uint256 mask = 1 << (index & 0xff);
        bitmap._data[bucket] &= ~mask;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/structs/EnumerableSet.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableSet.js.

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 * Trying to delete such a structure from storage will likely result in data corruption, rendering the structure
 * unusable.
 * See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 * In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an
 * array of EnumerableSet.
 * ====
 */
library EnumerableSetUpgradeable {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        bytes32[] memory store = _values(set._inner);
        bytes32[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}

pragma solidity >=0.5.0;

interface IUniswapV2Pair {
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

//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./internal-upgradeable/BaseUpgradeable.sol";
import "./internal-upgradeable/ReferralUpgradeable.sol";
import "./internal-upgradeable/SignableUpgradeable.sol";
import "./internal-upgradeable/FundForwarderUpgradeable.sol";

import "./interfaces/IBet2WinUpgradeable.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/IERC20MetadataUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/draft-IERC20PermitUpgradeable.sol";

import {BetLogic} from "./libraries/Bet2WinLogic.sol";
import {Encoder} from "./libraries/Bet2WinEncoder.sol";

import "@openzeppelin/contracts-upgradeable/utils/structs/BitMapsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";

contract Bet2WinUpgradeable is
    BaseUpgradeable,
    ReferralUpgradeable,
    SignableUpgradeable,
    TransferableUpgradeable,
    FundForwarderUpgradeable,
    IBet2WinUpgradeable
{
    using Encoder for uint256;
    using FixedPointMathLib for uint256;
    using BitMapsUpgradeable for BitMapsUpgradeable.BitMap;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    /// @dev value is equal to keccak256("Bet2Win_v2")
    bytes32 public constant VERSION =
        0x8e3e823de2bb7c24984bbbe5a5f367858a2b2a0e1acc8a6596d09460976a21a4;

    uint256 public constant MAX_TEAM_SLOTS = 32;
    uint256 public constant REFERRAL_PERCENT = 200;
    uint256 public constant HOUSE_EDGE_PERCENT = 300;

    /// @dev size in USD
    uint256 public constant MINIMUM_SIZE = 1 ether;
    uint256 public constant MAXIMUM_SIZE = 10_000 ether;
    /// @dev odds can be up to 10x
    uint256 public constant MAXIMUM_ODD = 1000_000;
    uint256 public constant PERCENTAGE_FRACTION = 10_000;
    uint256 public constant WITHDRAWAL_THRESHOLD = 1 ether;

    /// @dev value is equal to keccak256("Permit(address user,address referrer,uint256 betId,uint256 amount,address paymentToken,uint256 deadline,uint256 nonce)")
    bytes32 private constant __PERMIT_TYPE_HASH =
        0xec561885ee9ae4b4f381365f2074cf03880c53581b096eb22f48087bfda5e58c;

    IERC20Upgradeable public rewardToken;
    IUniswapV2Pair public reward2USDPair;
    /// @dev convert native token to USD price
    AggregatorV3Interface public native2USD;

    uint8[] private __gameIds;
    uint8[] private __betTypes;
    uint8[] private __settleStatuses;
    mapping(uint8 => uint24[]) private __matchIds;
    EnumerableSetUpgradeable.AddressSet private __users;

    BitMapsUpgradeable.BitMap private __paidReceipts;

    //  concat(matchId, gameId) => settleStatus => scores
    mapping(uint32 => mapping(uint8 => uint256)) private __resolves;
    //  gambler => key(matchId, gameId, settleStatus, betType) => (sideAgainst, amount, odd)[32]
    mapping(address => mapping(uint48 => uint128[32])) private __bets;

    address public defaultReferrer;

    function initialize(
        uint16[] calldata levelBonusRates_,
        IAuthority authority_,
        ITreasury treasury_,
        IUniswapV2Pair pair_,
        IERC20Upgradeable rewardToken_,
        AggregatorV3Interface priceFeed_
    ) external initializer {
        native2USD = priceFeed_;
        rewardToken = rewardToken_;
        reward2USDPair = pair_;

        __Signable_init("Bet2Win", "2");
        __FundForwarder_init_unchained(treasury_);
        __Referral_init_unchained(levelBonusRates_);
        __Base_init_unchained(authority_, Roles.TREASURER_ROLE);
    }

    function recoverERC20(
        IERC20Upgradeable token_
    ) external override whenPaused {
        _safeERC20Transfer(
            token_,
            address(treasury()),
            token_.balanceOf(address(this))
        );
    }

    function updateRewardToken(
        IERC20Upgradeable token_
    ) external onlyRole(Roles.OPERATOR_ROLE) {
        rewardToken = token_;
    }

    function withdrawBonus() external {
        address sender = _msgSender();
        uint256 amount = bonuses[sender];
        require(amount >= WITHDRAWAL_THRESHOLD, "BET2WIN: NOT_ENOUGH_VALUE");

        delete bonuses[sender];

        _safeTransfer(rewardToken, sender, amount);
    }

    function updateRewardPair(
        IUniswapV2Pair pair_
    ) external onlyRole(Roles.OPERATOR_ROLE) {
        reward2USDPair = pair_;
    }

    function addReferrer(
        address referrer_,
        address referree_
    ) external override onlyRole(Roles.OPERATOR_ROLE) {
        _addReferrer(referrer_, referree_);
    }

    function updateLevelBonusRates(
        uint16[] calldata levelBonusRates_
    ) external override onlyRole(Roles.OPERATOR_ROLE) {
        _updateLevelBonusrates(levelBonusRates_);
    }

    function resolveMatch(
        uint32 gameId_,
        uint24 matchId_,
        uint8 status_,
        uint256 scores_
    ) external onlyRole(Roles.CROUPIER_ROLE) {
        assembly {
            mstore(0x00, or(shl(24, gameId_), matchId_))
            mstore(0x20, __resolves.slot)
            let key := keccak256(0x00, 0x40)
            mstore(0x00, status_)
            mstore(0x20, key)
            key := keccak256(0x00, 0x40)

            sstore(key, scores_)
        }
    }

    function placeBet(
        uint256 betId_,
        uint256 deadline_,
        bytes calldata signature_,
        Payment calldata payment_
    ) external payable whenNotPaused {
        address gambler = _msgSender();
        _checkBlacklist(gambler);
        _onlyEOA(gambler);

        __checkSignature(gambler, betId_, payment_, deadline_, signature_);
        __processPayment(gambler, payment_);
        __processBet(gambler, betId_, payment_);

        if (payment_.referrer != address(0))
            _addReferrer(payment_.referrer, gambler);
    }

    function settleBet(
        uint32 gameId_,
        uint24 matchId_,
        uint8 status_,
        uint8 betType_,
        uint8 side_
    ) external whenNotPaused {
        uint256 scores = __resolves[(gameId_ << 24) | matchId_][status_];
        require(scores != 0, "BET2WIN: UNSETTLE_BET");

        uint48 id = Encoder.toUniqueKey(gameId_, matchId_, status_, betType_);
        address gambler = _msgSender();
        uint256 betDetail = __bets[gambler][id][side_];
        require(betDetail != 0, "BET2WIN: UNEXIST_BET");

        uint256 payType;
        require(
            (payType = BetLogic.isValidClaim(
                side_,
                betDetail.sideAgainst(),
                betType_,
                betDetail.betData(),
                scores
            )) != 0,
            "BET2WIN: INVALID_CLAIM"
        );

        uint256 receipt = Encoder.receiptOf(gambler, id, side_);
        require(!__paidReceipts.get(receipt), "BET2WIN: ALREADY_PAID");
        __paidReceipts.set(receipt);

        uint256 received;
        uint256 betSize = betDetail.amount();
        uint256 percentageFraction = PERCENTAGE_FRACTION;
        uint256 referralPercent = REFERRAL_PERCENT;
        if (payType == BetLogic.REFUND) received = betSize;
        else if (payType == BetLogic.LOSE_HALF || payType == BetLogic.WIN_HALF)
            received = (betSize = betSize >> 1); // divide by 2

        if (payType == BetLogic.WIN_ALL || payType == BetLogic.WIN_HALF) {
            (uint256 res0, uint256 res1, ) = reward2USDPair.getReserves();

            uint256 remainOdd = betDetail.odd() -
                HOUSE_EDGE_PERCENT -
                referralPercent;
            betSize = betSize.mulDivDown(res0, res1);
            received = betSize.mulDivDown(remainOdd, percentageFraction);
        }

        _safeTransfer(rewardToken, gambler, received);

        _updateReferrerBonus(
            gambler,
            betSize.mulDivDown(referralPercent, percentageFraction)
        );

        emit BetSettled(gambler, id, side_, receipt, received);
    }

    function __processBet(
        address gambler_,
        uint256 betId_,
        Payment calldata payment_
    ) private {
        (
            uint8 gameId,
            uint24 matchId,
            uint24 odd,
            uint16 betData,
            uint8 settleStatus,
            uint8 side,
            uint8 sideAgainst,
            uint8 betType
        ) = Encoder.decodeBetId(betId_);

        require(
            sideAgainst < MAX_TEAM_SLOTS && odd < MAXIMUM_ODD,
            "BET2WIN: INVALID_ARGUMENT"
        );

        uint48 id = Encoder.toUniqueKey(gameId, matchId, settleStatus, betType);
        uint256 usdSize = payment_.amount;
        {
            uint256 betDetail = __bets[gambler_][id][side];
            if (betDetail != 0)
                require(odd <= betDetail.odd(), "BET2WIN: INVALID_ODD");

            unchecked {
                if (payment_.token == address(0)) {
                    AggregatorV3Interface _native2USD = native2USD;
                    (, int256 usdUnit, , , ) = _native2USD.latestRoundData();
                    usdSize = usdSize.mulDivDown(
                        uint256(usdUnit),
                        10 ** _native2USD.decimals()
                    );
                } else if (payment_.token == address(rewardToken)) {
                    (uint256 res0, uint256 res1, ) = reward2USDPair
                        .getReserves();
                    usdSize = usdSize.mulDivDown(res1, res0);
                }
            }
            require(
                usdSize >= MINIMUM_SIZE && usdSize <= MAXIMUM_SIZE,
                "BET2WIN: BETSIZE_OUT_OF_BOUNDS"
            );

            usdSize += betDetail.amount();
        }

        __bets[gambler_][id][side] = Encoder.toBetDetail(
            usdSize,
            sideAgainst,
            betData,
            odd
        );

        emit BetPlaced(gambler_, id, side, sideAgainst, odd, usdSize);
    }

    function __checkSignature(
        address gambler_,
        uint256 betId_,
        Payment calldata payment_,
        uint256 deadline_,
        bytes calldata signature_
    ) private {
        require(block.timestamp < deadline_, "BET2WIN: EXPIRED");
        bytes32 structHash = keccak256(
            abi.encode(
                __PERMIT_TYPE_HASH,
                gambler_,
                payment_.referrer,
                betId_,
                payment_.amount,
                payment_.token,
                deadline_,
                _useNonce(gambler_)
            )
        );
        require(
            _hasRole(Roles.SIGNER_ROLE, _recoverSigner(structHash, signature_)),
            "BET2WIN: INVALID_SIGNATURE"
        );
    }

    function __processPayment(
        address gambler_,
        Payment calldata payment_
    ) private {
        ITreasury _treasury = treasury();
        address paymentToken = payment_.token;
        require(
            _treasury.supportedPayment(paymentToken),
            "BET2WIN: UNSUPPORTED_PAYMENT"
        );

        if (paymentToken != address(0)) {
            if (
                IERC20Upgradeable(paymentToken).allowance(
                    gambler_,
                    address(this)
                ) < payment_.amount
            )
                IERC20PermitUpgradeable(paymentToken).permit(
                    gambler_,
                    address(this),
                    payment_.amount,
                    payment_.deadline,
                    payment_.v,
                    payment_.r,
                    payment_.s
                );
            if (msg.value != 0) _safeNativeTransfer(gambler_, msg.value);
        } else if (msg.value > payment_.amount) {
            unchecked {
                _safeNativeTransfer(gambler_, msg.value - payment_.amount);
            }
        }

        _safeTransferFrom(
            IERC20Upgradeable(paymentToken),
            gambler_,
            address(_treasury),
            payment_.amount
        );
    }

    function updateTreasury(
        ITreasury treasury_
    ) external override onlyRole(Roles.OPERATOR_ROLE) {
        emit TreasuryUpdated(treasury(), treasury_);
        _updateTreasury(treasury_);
    }

    function estimateRewardReceive(
        uint256 betSize_,
        uint256 odd_
    ) external view returns (uint256) {
        (uint256 res0, uint256 res1, ) = reward2USDPair.getReserves();
        IERC20Upgradeable _rewardToken = rewardToken;
        res0 *=
            10 ** IERC20MetadataUpgradeable(address(_rewardToken)).decimals();

        uint256 referralPercent = REFERRAL_PERCENT;
        uint256 remainOdd = odd_ - HOUSE_EDGE_PERCENT - referralPercent;

        uint256 amount = betSize_.mulDivDown(res0, res1);
        return amount.mulDivDown(remainOdd, PERCENTAGE_FRACTION);
    }

    function betIdOf(
        uint104 gameId_,
        uint96 matchId_,
        uint72 odd_,
        uint48 betData_,
        uint32 settleStatus_,
        uint24 side_,
        uint16 sideAgainst_,
        uint8 betType_
    ) external pure returns (uint256 betId) {
        assembly {
            betId := or(shl(96, gameId_), shl(72, matchId_))
            betId := or(betId, or(shl(48, odd_), shl(32, betData_)))
            betId := or(betId, or(shl(24, settleStatus_), shl(16, side_)))
            betId := or(betId, or(shl(8, sideAgainst_), betType_))
        }
    }

    uint256[38] private __gap;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts-upgradeable/access/IAccessControlEnumerableUpgradeable.sol";

import "../internal-upgradeable/interfaces/IBlacklistableUpgradeable.sol";

interface IAuthority is
    IBlacklistableUpgradeable,
    IAccessControlEnumerableUpgradeable
{
    event ProxyAccessGranted(address indexed proxy);

    function setRoleAdmin(bytes32 role, bytes32 adminRole) external;

    function pause() external;

    function unpause() external;

    function paused() external view returns (bool isPaused);

    function requestAccess(bytes32 role) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./IAuthority.sol";
import "../internal-upgradeable/interfaces/ISignableUpgradeable.sol";
import "../internal-upgradeable/interfaces/IFundForwarderUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/// @title Bet2Win interface for Bet2Win contract
/// @notice Contains Bet2Win Interface for contract interaction
interface IBet2WinUpgradeable is ISignableUpgradeable {
    struct Payment {
        address referrer;
        uint8 v;
        uint256 deadline;
        uint256 amount;
        address token;
        bytes32 r;
        bytes32 s;
    }

    event ReferreeAdded(address indexed user, address indexed referree);

    event BetPlaced(
        address indexed user,
        uint256 indexed id,
        uint256 indexed side,
        uint256 sideAgainst,
        uint256 odd,
        uint256 usdAmt
    );

    event BetSettled(
        address indexed to,
        uint256 indexed id,
        uint256 side,
        uint256 indexed receiptId,
        uint256 received
    );

    event MatchResolved(
        uint256 indexed gameId,
        uint256 indexed matchId,
        uint256 indexed status
    );

    /// @notice Update referree of a user
    /// @dev Caller must be croupier, referree address should not be blacklisted or contract address
    // function addReferree(address user_, address referree_) external;

    /// @notice Reveal which team won
    /// @dev Caller must be croupier, sideInFavor_ must not be 0 (default value)
    /// @param sideInFavor_ A number indexing a team in the match which won
    //         status_  Current state of the match, i.e FIRST_HALF, FULL_TIME, SECOND_HALF
    // function resolveMatch(
    //     uint256 gameId_,
    //     uint256 matchId_,
    //     uint256 status_,
    //     uint256 sideInFavor_
    // ) external;

    /// @notice Bet placing transaction
    /// @dev Caller is gamblers, not blacklisted, not proxy call
    /// @param betId_   A unique number from represent the encoded data from gameId, matchId, odd, settleStatus, side
    ///        amount_  Bet size
    // function placeBet(
    //     uint256 betId_,
    //     uint96 amount_,
    //     uint256 permitDeadline_,
    //     uint256 croupierDeadline_,
    //     uint8 v,
    //     bytes32 r,
    //     bytes32 s,
    //     IERC20Upgradeable paymentToken_,
    //     bytes calldata croupierSignature_
    // ) external payable;

    /// @notice Users claim bet rewards if they are eligible
    /// @dev Caller is gamblers, not blacklisted, not proxy call
    // function settleBet(
    //     uint256 gameId_,
    //     uint256 matchId_,
    //     uint256 status_
    // ) external;

    // function estimateRewardReceive(
    //     address user_,
    //     bool isNativePayment_,
    //     uint256 betSize_,
    //     uint256 odd_
    // ) external view returns (uint256);

    /// @notice Get all users for offchain filtering
    /// @return All users that have already placed bet
    //function users() external view returns (address[] memory);

    /// @notice Get bet data of specific match
    /// @return Struct bet containing bet info
    // function betOf(
    //     address gambler_,
    //     uint256 gameId_,
    //     uint256 matchId_
    // ) external view returns (Bet memory);

    //function matchesIds(uint8 gameId_) external view returns (uint256[] memory);

    //function gameIds() external view returns (uint256[] memory);

    /// @notice Encode bet data into a unique number
    /// @dev Input data must be in range of 48 bits
    /// @return betId   Unique key representing bet data
    // function betIdOf(
    //     uint256 gameId_,
    //     uint256 matchId_,
    //     uint256 odd_,
    //     uint256 settleStatus_,
    //     uint256 side_
    // ) external pure returns (uint256);

    /// @notice Create a unique from gameId_ and matchId_ for indexing
    /// @dev Params must stay in range of 48 bits
    /// @return key Unique key from gameId_, matchId_
    // function key(uint256 gameId_, uint256 matchId_)
    //     external
    //     pure
    //     returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "../internal-upgradeable/interfaces/IWithdrawableUpgradeable.sol";

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

interface ITreasury is IWithdrawableUpgradeable {
    event PaymentAdded(IERC20Upgradeable indexed token);
    event PaymentRemoved(IERC20Upgradeable indexed token);
    event PaymentsAdded(IERC20Upgradeable[] indexed tokens);
    event SafeReceived(address indexed from, uint256 value);

    function supportedPayment(address token_) external view returns (bool);

    function withdraw(
        IERC20Upgradeable token_,
        address to_,
        uint256 amount_,
        uint256 deadline_,
        bytes calldata signature_
    ) external;

    function payments() external view returns (address[] memory);

    function addPayments(IERC20Upgradeable[] calldata tokens_) external;

    function removePayment(IERC20Upgradeable token_) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "../interfaces/IAuthority.sol";

import "../libraries/Roles.sol";

abstract contract BaseUpgradeable is ContextUpgradeable, UUPSUpgradeable {
    bytes32 private _authority;

    event AuthorityUpdated(IAuthority indexed from, IAuthority indexed to);

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    modifier onlyWhitelisted() {
        _checkBlacklist(_msgSender());
        _;
    }

    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    modifier whenPaused() {
        _requirePaused();
        _;
    }

    function updateAuthority(
        IAuthority authority_
    ) external onlyRole(Roles.OPERATOR_ROLE) {
        IAuthority old = authority();
        require(old != authority_, "BASE: ALREADY_SET");
        __updateAuthority(authority_);
        emit AuthorityUpdated(old, authority_);
    }

    function authority() public view returns (IAuthority authority_) {
        /// @solidity memory-safe-assembly
        assembly {
            authority_ := sload(_authority.slot)
        }
    }

    function __Base_init(
        IAuthority authority_,
        bytes32 role_
    ) internal onlyInitializing {
        __Base_init_unchained(authority_, role_);
    }

    function __Base_init_unchained(
        IAuthority authority_,
        bytes32 role_
    ) internal onlyInitializing {
        if (role_ != 0) authority_.requestAccess(role_);
        __updateAuthority(authority_);
    }

    function _checkBlacklist(address account_) internal view {
        require(!authority().isBlacklisted(account_), "BASE: BLACKLISTED");
    }

    function _checkRole(bytes32 role_, address account_) internal view {
        require(authority().hasRole(role_, account_), "BASE: UNAUTHORIZED");
    }

    function __updateAuthority(IAuthority authority_) internal {
        /// @solidity memory-safe-assembly
        assembly {
            sstore(_authority.slot, authority_)
        }
    }

    function _requirePaused() internal view {
        require(authority().paused(), "BASE: NOT_PAUSED");
    }

    function _requireNotPaused() internal view {
        require(!authority().paused(), "BASE: PAUSED");
    }

    function _authorizeUpgrade(
        address implement_
    ) internal virtual override onlyRole(Roles.UPGRADER_ROLE) {}

    function _hasRole(
        bytes32 role_,
        address account_
    ) internal view returns (bool) {
        return authority().hasRole(role_, account_);
    }

    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";

import "./TransferableUpgradeable.sol";

import "./interfaces/IFundForwarderUpgradeable.sol";

abstract contract FundForwarderUpgradeable is
    ContextUpgradeable,
    TransferableUpgradeable,
    IFundForwarderUpgradeable
{
    bytes32 private _treasury;

    function __FundForwarder_init(
        ITreasury treasury_
    ) internal onlyInitializing {
        __FundForwarder_init_unchained(treasury_);
    }

    function __FundForwarder_init_unchained(
        ITreasury treasury_
    ) internal onlyInitializing {
        _updateTreasury(treasury_);
    }

    receive() external payable virtual {
        address treasury_;
        assembly {
            treasury_ := sload(_treasury.slot)
        }
        _safeNativeTransfer(treasury_, msg.value);
    }

    function updateTreasury(ITreasury) external virtual override;

    function treasury() public view returns (ITreasury treasury_) {
        assembly {
            treasury_ := sload(_treasury.slot)
        }
    }

    function _updateTreasury(ITreasury treasury_) internal {
        assembly {
            sstore(_treasury.slot, treasury_)
        }
    }

    function recoverERC20(IERC20Upgradeable token_) external virtual {
        _safeERC20Transfer(
            token_,
            address(treasury()),
            token_.balanceOf(address(this))
        );
    }

    function recoverNative() external {
        _safeNativeTransfer(address(treasury()), address(this).balance);
    }

    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IBlacklistableUpgradeable {
    event Blacklisted(address indexed account);
    event Whitelisted(address indexed account);

    function setUserStatus(address account_, bool status) external;

    function isBlacklisted(address account_) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "../../interfaces/ITreasury.sol";

interface IFundForwarderUpgradeable {
    event TreasuryUpdated(ITreasury indexed from, ITreasury indexed to);

    function updateTreasury(ITreasury treasury_) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IReferralUpgradeable {
    event LevelUpdated(address indexed referrer, uint256 indexed level);
    event ReferrerAdded(address indexed referree, address indexed referrer);

    function addReferrer(address referrer_, address referree_) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface ISignableUpgradeable {
    function nonces(address sender_) external view returns (uint256);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

interface IWithdrawableUpgradeable {
    event Withdrawn(
        IERC20Upgradeable indexed token,
        address indexed to,
        uint256 indexed value
    );
    event Received(address indexed sender, uint256 indexed value);

    function withdraw(
        IERC20Upgradeable from_,
        address to_,
        uint256 amount_
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";

abstract contract ProxyCheckerUpgradeable is ContextUpgradeable {
    modifier onlyEOA() {
        _onlyEOA(_msgSender());
        _;
    }

    function __ProxyChecker_init() internal onlyInitializing {}

    function __ProxyChecker_init_unchained() internal onlyInitializing {}

    function _onlyEOA(address sender_) internal view {
        _onlyEOA(sender_, _txOrigin());
    }

    function _onlyEOA(address msgSender_, address txOrigin_) internal view {
        require(
            !_isProxyCall(msgSender_, txOrigin_) && !_isProxy(msgSender_),
            "PROXY_CHECKER: PROXY_UNALLOWED"
        );
    }

    function _onlyProxy(address sender_) internal view {
        require(
            _isProxyCall(sender_, _txOrigin()) || _isProxy(sender_),
            "PROXY_CHECKER: EOA_UNALLOWED"
        );
    }

    function _onlyProxy(address msgSender_, address txOrigin_) internal view {
        require(
            _isProxyCall(msgSender_, txOrigin_) || _isProxy(msgSender_),
            "PROXY_CHECKER: EOA_UNALLOWED"
        );
    }

    function _isProxyCall(
        address msgSender_,
        address txOrigin_
    ) internal pure returns (bool) {
        return msgSender_ != txOrigin_;
    }

    function _isProxy(address caller_) internal view returns (bool) {
        return caller_.code.length != 0;
    }

    function _txOrigin() internal view returns (address) {
        return tx.origin;
    }

    uint256[50] private _gap;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./ProxyCheckerUpgradeable.sol";
import "./interfaces/IReferralUpgradeable.sol";

import "../libraries/FixedPointMathLib.sol";

abstract contract ReferralUpgradeable is
    ProxyCheckerUpgradeable,
    IReferralUpgradeable
{
    using FixedPointMathLib for uint256;

    uint256 private __maxDepth;
    uint16[] public levelBonusRates;

    mapping(address => uint256) public levels;
    mapping(address => uint256) public bonuses;
    mapping(address => address) public referrals;

    function __Referral_init(
        uint16[] calldata levelBonusRates_
    ) internal onlyInitializing {
        __Referral_init_unchained(levelBonusRates_);
    }

    function __Referral_init_unchained(
        uint16[] calldata levelBonusRates_
    ) internal onlyInitializing {
        _updateLevelBonusrates(levelBonusRates_);
    }

    function _updateLevelBonusrates(
        uint16[] calldata levelBonusRates_
    ) internal {
        uint256 length = levelBonusRates_.length;
        uint256 sum;
        for (uint256 i; i < length; ) {
            unchecked {
                sum += levelBonusRates_[i];
                ++i;
            }
        }

        require(sum == _denominator(), "REFERALL: INVALID_ARGUMENTS");

        levelBonusRates = levelBonusRates_;
    }

    function updateLevelBonusRates(
        uint16[] calldata levelBonusRates_
    ) external virtual;

    function addReferrer(address referrer_, address referree_) external virtual;

    function referralTree(
        address referee_
    ) external view returns (address[] memory referrers) {
        uint256 maxDepth = levelBonusRates.length;
        referrers = new address[](maxDepth);
        address referrer = referee_;
        for (uint256 i; i < maxDepth; ) {
            if ((referrer = referrals[referrer]) == address(0)) break;
            referrers[i] = referrer;
            unchecked {
                ++i;
            }
        }
    }

    function _addReferrer(address referrer_, address referree_) internal {
        require(!_isProxy(referrer_), "REFERRAL: PROXY_NOT_ALLOWED");
        require(
            referrals[referree_] == address(0),
            "REFERRAL: REFERRER_EXISTED"
        );
        referrals[referree_] = referrer_;

        uint256 level;
        uint256 maxDepth = levelBonusRates.length;
        for (uint256 i; i < maxDepth; ) {
            require(referrer_ != referree_, "REFERRAL: CIRCULAR_REF_UNALLOWED");

            unchecked {
                level = ++levels[referrer_];
                ++i;
            }

            emit LevelUpdated(referrer_, level);
            if ((referrer_ = referrals[referrer_]) == address(0)) break;
        }

        emit ReferrerAdded(referree_, referrer_);
    }

    function _updateReferrerBonus(address referree_, uint256 amount_) internal {
        uint16[] memory _levelBonusRates = levelBonusRates;
        uint256 maxDepth = _levelBonusRates.length;
        address referrer = referree_;
        uint256 denominator = _denominator();
        for (uint256 i; i < maxDepth; ) {
            if ((referrer = referrals[referrer]) == address(0)) break;
            unchecked {
                bonuses[referrer] += amount_.mulDivDown(
                    _levelBonusRates[i],
                    denominator
                );
                ++i;
            }
        }
    }

    function _denominator() internal pure virtual returns (uint256) {
        return 10_000;
    }

    uint256[45] private __gap;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts-upgradeable/utils/cryptography/draft-EIP712Upgradeable.sol";

import "./interfaces/ISignableUpgradeable.sol";

import "../libraries/Bytes32Address.sol";

abstract contract SignableUpgradeable is
    EIP712Upgradeable,
    ISignableUpgradeable
{
    using Bytes32Address for address;
    using ECDSAUpgradeable for bytes32;

    mapping(bytes32 => uint256) internal _nonces;

    function __Signable_init(
        string memory name,
        string memory version
    ) internal onlyInitializing {
        __EIP712_init_unchained(name, version);
    }

    function __Signable_init_unchained() internal onlyInitializing {}

    function nonces(
        address sender_
    ) external view virtual override returns (uint256) {
        return _nonce(sender_);
    }

    function _verify(
        address verifier_,
        bytes32 structHash_,
        bytes calldata signature_
    ) internal view virtual {
        _checkVerifier(verifier_, structHash_, signature_);
    }

    function _checkVerifier(
        address verifier_,
        bytes32 structHash_,
        bytes calldata signature_
    ) internal view virtual {
        require(
            _recoverSigner(structHash_, signature_) == verifier_,
            "SIGNABLE: INVALID_SIGNATURE"
        );
    }

    function _recoverSigner(
        bytes32 structHash_,
        bytes calldata signature_
    ) internal view returns (address) {
        return _hashTypedDataV4(structHash_).recover(signature_);
    }

    function _useNonce(address sender_) internal virtual returns (uint256) {
        unchecked {
            return _nonces[sender_.fillLast12Bytes()]++;
        }
    }

    function _nonce(address sender_) internal view virtual returns (uint256) {
        return _nonces[sender_.fillLast12Bytes()];
    }

    function DOMAIN_SEPARATOR()
        external
        view
        virtual
        override
        returns (bytes32)
    {
        return _domainSeparatorV4();
    }

    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

abstract contract TransferableUpgradeable is Initializable {
    function __Transferable_init() internal onlyInitializing {}

    function __Transferable_init_unchained() internal onlyInitializing {}

    function _safeTransferFrom(
        IERC20Upgradeable token_,
        address from_,
        address to_,
        uint256 value_
    ) internal virtual {
        __checkValidTransfer(to_, value_);
        bool success;
        if (address(token_) == address(0))
            success = __nativeTransfer(to_, value_);
        else success = __ERC20TransferFrom(token_, from_, to_, value_);

        require(success, "TRANSFERABLE: TRANSFER_FAILED");
    }

    function _safeTransfer(
        IERC20Upgradeable token_,
        address to_,
        uint256 value_
    ) internal virtual {
        __checkValidTransfer(to_, value_);
        bool success;
        if (address(token_) == address(0))
            success = __nativeTransfer(to_, value_);
        else success = __ERC20Transfer(token_, to_, value_);

        require(success, "TRANSFERABLE: TRANSFER_FAILED");
    }

    function _safeNativeTransfer(
        address to_,
        uint256 amount_
    ) internal virtual {
        __checkValidTransfer(to_, amount_);
        require(
            __nativeTransfer(to_, amount_),
            "TRANSFERABLE: TRANSFER_FAILED"
        );
    }

    function _safeERC20Transfer(
        IERC20Upgradeable token_,
        address to_,
        uint256 amount_
    ) internal virtual {
        __checkValidTransfer(to_, amount_);
        require(
            __ERC20Transfer(token_, to_, amount_),
            "TRANSFERABLE: TRANSFER_FAILED"
        );
    }

    function _safeERC20TransferFrom(
        IERC20Upgradeable token_,
        address from_,
        address to_,
        uint256 amount_
    ) internal virtual {
        __checkValidTransfer(to_, amount_);
        require(
            __ERC20TransferFrom(token_, from_, to_, amount_),
            "TRANSFERABLE: TRANSFER_FAILED"
        );
    }

    function __nativeTransfer(
        address to_,
        uint256 amount_
    ) private returns (bool success) {
        assembly {
            success := call(gas(), to_, amount_, 0, 0, 0, 0)
        }
    }

    function __ERC20Transfer(
        IERC20Upgradeable token_,
        address to_,
        uint256 value_
    ) internal virtual returns (bool success) {
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(
                freeMemoryPointer,
                0xa9059cbb00000000000000000000000000000000000000000000000000000000
            )
            mstore(add(freeMemoryPointer, 4), to_) // Append the "to" argument.
            mstore(add(freeMemoryPointer, 36), value_) // Append the "amount" argument.

            success := and(
                or(
                    and(eq(mload(0), 1), gt(returndatasize(), 31)),
                    iszero(returndatasize())
                ),
                call(gas(), token_, 0, freeMemoryPointer, 68, 0, 32)
            )
        }
    }

    function __ERC20TransferFrom(
        IERC20Upgradeable token_,
        address from_,
        address to_,
        uint256 value_
    ) internal virtual returns (bool success) {
        assembly {
            let freeMemoryPointer := mload(0x40)

            mstore(
                freeMemoryPointer,
                0x23b872dd00000000000000000000000000000000000000000000000000000000
            )
            mstore(add(freeMemoryPointer, 4), from_)
            mstore(add(freeMemoryPointer, 36), to_)
            mstore(add(freeMemoryPointer, 68), value_)

            success := and(
                or(
                    and(eq(mload(0), 1), gt(returndatasize(), 31)),
                    iszero(returndatasize())
                ),
                call(gas(), token_, 0, freeMemoryPointer, 100, 0, 32)
            )
        }
    }

    function __checkValidTransfer(address to_, uint256 value_) private view {
        require(
            value_ != 0 && to_ != address(0) && to_ != address(this),
            "TRANSFERABLE: INVALID_ARGUMENTS"
        );
    }

    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

library Encoder {
    uint256 internal constant AMOUNT_SHIFT = 32;
    uint256 internal constant BET_DATA_SHIFT = 17;
    uint256 internal constant SIDE_AGAINST_SHIFT = 27;

    function toUniqueKey(
        uint256 gameId_,
        uint256 matchId_,
        uint256 status_,
        uint256 betType_
    ) internal pure returns (uint48) {
        return
            uint48(
                (gameId_ << 40) | (matchId_ << 16) | (status_ << 8) | betType_
            );
    }

    function toBetDetail(
        uint256 betSize_,
        uint256 sideAgainst_,
        uint256 betData_,
        uint256 odd_
    ) internal pure returns (uint128) {
        return
            uint128(
                (betSize_ << AMOUNT_SHIFT) |
                    (sideAgainst_ << SIDE_AGAINST_SHIFT) |
                    (betData_ << BET_DATA_SHIFT) |
                    odd_
            );
    }

    function betData(uint256 betDetail_) internal pure returns (uint256) {
        return betDetail_ >> BET_DATA_SHIFT;
    }

    function odd(uint256 betDetail_) internal pure returns (uint256) {
        return (betDetail_ & ((1 << 17) - 1)) * 100;
    }

    function amount(uint256 betDetail_) internal pure returns (uint256) {
        return betDetail_ >> AMOUNT_SHIFT;
    }

    function sideAgainst(uint256 betDetail_) internal pure returns (uint256) {
        return betDetail_ >> SIDE_AGAINST_SHIFT;
    }

    function decodeBetId(
        uint256 betId_
    )
        internal
        pure
        returns (
            uint8 gameId,
            uint24 matchId,
            uint24 odd_,
            uint16 betData_,
            uint8 settleStatus,
            uint8 side,
            uint8 sideAgainst_,
            uint8 betType
        )
    {
        assembly {
            gameId := shr(96, betId_)
            matchId := shr(72, betId_)
            odd_ := shr(48, betId_)
            betData_ := shr(32, betId_)
            settleStatus := shr(24, betId_)
            side := shr(16, betId_)
            sideAgainst_ := shr(8, betId_)
            betType := betId_
        }
    }

    function receiptOf(
        address user_,
        uint256 id_,
        uint256 side_
    ) internal pure returns (uint256) {
        uint256 digest;
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, user_)
            mstore(add(ptr, 160), id_)
            mstore(add(ptr, 208), side_)
            digest := keccak256(ptr, 216)
        }
        return digest;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

library BetLogic {
    enum BetType {
        WIN,
        DRAW,
        OVER,
        UNDER,
        HANDICAP,
        BOTH_TEAM_SCORE,
        CORRECT_SCORE, //6
        PENALTY_SCORE,
        NUM_RED_CARD,
        NUM_YELLOW_CARD,
        TOTAL_SCORE, //10
        PENALTY_TOTAL,
        RED_CARD_TOTAL,
        YELLOW_CARD_TOTAL
    }

    uint256 internal constant LOSE_ALL = 0;

    uint256 internal constant WIN_ALL = 1;
    uint256 internal constant LOSE_HALF = 2; //
    uint256 internal constant WIN_HALF = 3; //
    uint256 internal constant REFUND = 4; //

    function isValidClaim(
        uint256 side,
        uint256 sideAgainst_,
        uint256 betType_,
        uint256 betData_,
        uint256 scores_
    ) internal pure returns (uint256 result) {
        uint256 sideInFavorResult = (scores_ >> (side << 3)) & 0xff;
        uint256 sideAgainstResult = (scores_ >> (sideAgainst_ << 3)) & 0xff;

        uint256 sideInFavorScore = (betData_ >> (side << 3)) & 0xff;
        uint256 sideAgainstScore = (betData_ >> (sideAgainst_ << 3)) & 0xff;
        unchecked {
            if (betType_ == uint8(BetType.HANDICAP)) {
                sideAgainstResult *= 100;
                sideInFavorResult *= 100 + betData_;

                if (sideInFavorResult == sideAgainstResult) return REFUND;

                if (sideInFavorResult == 25 + sideAgainstResult)
                    return WIN_HALF;
                if (sideInFavorResult + 25 == sideAgainstResult)
                    return LOSE_HALF;

                if (sideInFavorResult > 25 + sideAgainstResult) return WIN_ALL;
                if (sideInFavorResult + 25 < sideAgainstResult) return LOSE_ALL;
            }
            bool valid;
            if (betType_ >= uint8(BetType.TOTAL_SCORE)) {
                valid = betData_ >> 8 != 0
                    ? sideInFavorResult + sideAgainstResult >= uint8(betData_)
                    : sideInFavorResult + sideAgainstResult == betData_;
                return valid ? WIN_ALL : LOSE_ALL;
            }
            if (betType_ >= uint8(BetType.CORRECT_SCORE)) {
                valid =
                    sideAgainstScore == sideAgainstResult &&
                    sideInFavorScore == sideInFavorResult;
                return valid ? WIN_ALL : LOSE_ALL;
            }
            if (betType_ == uint8(BetType.OVER)) {
                valid =
                    sideInFavorResult + sideAgainstResult >= sideInFavorScore;
                return valid ? WIN_ALL : LOSE_ALL;
            }
            if (betType_ == uint8(BetType.UNDER)) {
                valid =
                    sideInFavorResult + sideAgainstResult < sideInFavorScore;
                return valid ? WIN_ALL : LOSE_ALL;
            }
            if (betType_ == uint8(BetType.WIN)) {
                valid = sideInFavorResult > sideAgainstResult;
                return valid ? WIN_ALL : LOSE_ALL;
            }
            if (betType_ == uint8(BetType.DRAW)) {
                valid = sideInFavorResult == sideAgainstResult;
                return valid ? WIN_ALL : LOSE_ALL;
            }

            if (betType_ == uint8(BetType.BOTH_TEAM_SCORE)) {
                valid = betData_ != 0
                    ? sideInFavorResult * sideAgainstResult != 0
                    : sideInFavorResult + sideAgainstResult == 0;
                return valid ? WIN_ALL : LOSE_ALL;
            }
        }

        return LOSE_ALL;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

library Bytes32Address {
    function fromFirst20Bytes(
        bytes32 bytesValue
    ) internal pure returns (address addr) {
        /// @solidity memory-safe-assembly
        assembly {
            addr := bytesValue
        }
    }

    function fillLast12Bytes(
        address addressValue
    ) internal pure returns (bytes32 value) {
        /// @solidity memory-safe-assembly
        assembly {
            value := addressValue
        }
    }

    function fromFirst160Bits(
        uint256 uintValue
    ) internal pure returns (address addr) {
        /// @solidity memory-safe-assembly
        assembly {
            addr := uintValue
        }
    }

    function fillLast96Bits(
        address addressValue
    ) internal pure returns (uint256 value) {
        /// @solidity memory-safe-assembly
        assembly {
            value := addressValue
        }
    }

    function fromLast160Bits(
        uint256 uintValue
    ) internal pure returns (address addr) {
        /// @solidity memory-safe-assembly
        assembly {
            addr := shr(0x60, uintValue)
        }
    }

    function fillFirst96Bits(
        address addressValue
    ) internal pure returns (uint256 value) {
        /// @solidity memory-safe-assembly
        assembly {
            value := shl(0x60, addressValue)
        }
    }
}

// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.17;

/// @notice Arithmetic library with operations for fixed-point numbers.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/FixedPointMathLib.sol)
/// @author Inspired by USM (https://github.com/usmfum/USM/blob/master/contracts/WadMath.sol)
library FixedPointMathLib {
    /*//////////////////////////////////////////////////////////////
                    SIMPLIFIED FIXED POINT OPERATIONS
    //////////////////////////////////////////////////////////////*/

    uint256 internal constant MAX_UINT256 = (1 << 256) - 1;
    uint256 internal constant WAD = 1e18; // The scalar of ETH and most ERC20s.

    function mulWadDown(uint256 x, uint256 y) internal pure returns (uint256) {
        return mulDivDown(x, y, WAD); // Equivalent to (x * y) / WAD rounded down.
    }

    function mulWadUp(uint256 x, uint256 y) internal pure returns (uint256) {
        return mulDivUp(x, y, WAD); // Equivalent to (x * y) / WAD rounded up.
    }

    function divWadDown(uint256 x, uint256 y) internal pure returns (uint256) {
        return mulDivDown(x, WAD, y); // Equivalent to (x * WAD) / y rounded down.
    }

    function divWadUp(uint256 x, uint256 y) internal pure returns (uint256) {
        return mulDivUp(x, WAD, y); // Equivalent to (x * WAD) / y rounded up.
    }

    /*//////////////////////////////////////////////////////////////
                    LOW LEVEL FIXED POINT OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function mulDivDown(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 z) {
        assembly {
            // Equivalent to require(denominator != 0 && (y == 0 || x <= type(uint256).max / y))
            if iszero(
                mul(denominator, iszero(mul(y, gt(x, div(MAX_UINT256, y)))))
            ) {
                revert(0, 0)
            }

            z := div(mul(x, y), denominator)
        }
    }

    function mulDivUp(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 z) {
        assembly {
            // Equivalent to require(denominator != 0 && (y == 0 || x <= type(uint256).max / y))
            if iszero(
                mul(denominator, iszero(mul(y, gt(x, div(MAX_UINT256, y)))))
            ) {
                revert(0, 0)
            }

            // Add 1 to the result if x * y mod denominator != 0.
            z := add(
                gt(mod(mul(x, y), denominator), 0),
                div(mul(x, y), denominator)
            )
        }
    }

    function rpow(
        uint256 x,
        uint256 n,
        uint256 scalar
    ) internal pure returns (uint256 z) {
        assembly {
            switch x
            case 0 {
                switch n
                case 0 {
                    // 0 ** 0 = 1
                    z := scalar
                }
                default {
                    // 0 ** n = 0
                    z := 0
                }
            }
            default {
                switch mod(n, 2)
                case 0 {
                    // If n is even, store scalar in z for now.
                    z := scalar
                }
                default {
                    // If n is odd, store x in z for now.
                    z := x
                }

                // Shifting right by 1 is like dividing by 2.
                let half := shr(1, scalar)

                for {
                    // Shift n right by 1 before looping to halve it.
                    n := shr(1, n)
                } n {
                    // Shift n right by 1 each iteration to halve it.
                    n := shr(1, n)
                } {
                    // Revert immediately if x ** 2 would overflow.
                    // Equivalent to iszero(eq(div(xx, x), x)) here.
                    if shr(128, x) {
                        revert(0, 0)
                    }

                    // Store x squared.
                    let xx := mul(x, x)

                    // Round to the nearest number.
                    let xxRound := add(xx, half)

                    // Revert if xx + half overflowed.
                    if lt(xxRound, xx) {
                        revert(0, 0)
                    }

                    // Set x to scaled xxRound.
                    x := div(xxRound, scalar)

                    // If n is even:
                    if mod(n, 2) {
                        // Compute z * x.
                        let zx := mul(z, x)

                        // If z * x overflowed:
                        if iszero(eq(div(zx, x), z)) {
                            // Revert if x is non-zero.
                            if iszero(iszero(x)) {
                                revert(0, 0)
                            }
                        }

                        // Round to the nearest number.
                        let zxRound := add(zx, half)

                        // Revert if zx + half overflowed.
                        if lt(zxRound, zx) {
                            revert(0, 0)
                        }

                        // Return properly scaled zxRound.
                        z := div(zxRound, scalar)
                    }
                }
            }
        }
    }

    /*//////////////////////////////////////////////////////////////
                        GENERAL NUMBER UTILITIES
    //////////////////////////////////////////////////////////////*/

    function sqrt(uint256 x) internal pure returns (uint256 z) {
        assembly {
            // Start off with z at 1.
            z := 1

            // Used below to help find a nearby power of 2.
            let y := x

            // Find the lowest power of 2 that is at least sqrt(x).
            if iszero(lt(y, 0x100000000000000000000000000000000)) {
                y := shr(128, y) // Like dividing by 2 ** 128.
                z := shl(64, z) // Like multiplying by 2 ** 64.
            }
            if iszero(lt(y, 0x10000000000000000)) {
                y := shr(64, y) // Like dividing by 2 ** 64.
                z := shl(32, z) // Like multiplying by 2 ** 32.
            }
            if iszero(lt(y, 0x100000000)) {
                y := shr(32, y) // Like dividing by 2 ** 32.
                z := shl(16, z) // Like multiplying by 2 ** 16.
            }
            if iszero(lt(y, 0x10000)) {
                y := shr(16, y) // Like dividing by 2 ** 16.
                z := shl(8, z) // Like multiplying by 2 ** 8.
            }
            if iszero(lt(y, 0x100)) {
                y := shr(8, y) // Like dividing by 2 ** 8.
                z := shl(4, z) // Like multiplying by 2 ** 4.
            }
            if iszero(lt(y, 0x10)) {
                y := shr(4, y) // Like dividing by 2 ** 4.
                z := shl(2, z) // Like multiplying by 2 ** 2.
            }
            if iszero(lt(y, 0x8)) {
                // Equivalent to 2 ** z.
                z := shl(1, z)
            }

            // Shifting right by 1 is like dividing by 2.
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))

            // Compute a rounded down version of z.
            let zRoundDown := div(x, z)

            // If zRoundDown is smaller, use it.
            if lt(zRoundDown, z) {
                z := zRoundDown
            }
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

library Roles {
    bytes32 internal constant FACTORY_ROLE =
        0xdfbefbf47cfe66b701d8cfdbce1de81c821590819cb07e71cb01b6602fb0ee27;
    bytes32 internal constant CROUPIER_ROLE =
        0xca4ff35aa85b5fefc8312f1391bd040d4b445859a4a611b13d905ef8daa4b19f;
    bytes32 internal constant PROXY_ROLE =
        0x77d72916e966418e6dc58a19999ae9934bef3f749f1547cde0a86e809f19c89b;
    bytes32 internal constant SIGNER_ROLE =
        0xe2f4eaae4a9751e85a3e4a7b9587827a877f29914755229b07a7b2da98285f70;
    bytes32 internal constant PAUSER_ROLE =
        0x65d7a28e3265b37a6474929f336521b332c1681b933f6cb9f3376673440d862a;
    bytes32 internal constant OPERATOR_ROLE =
        0x97667070c54ef182b0f5858b034beac1b6f3089aa2d3188bb1e8929f4fa9b929;
    bytes32 internal constant UPGRADER_ROLE =
        0x189ab7a9244df0848122154315af71fe140f3db0fe014031783b0946b8c9d2e3;
    bytes32 internal constant TREASURER_ROLE =
        0x3496e2e73c4d42b75d702e60d9e48102720b8691234415963a5a857b86425d07;
}