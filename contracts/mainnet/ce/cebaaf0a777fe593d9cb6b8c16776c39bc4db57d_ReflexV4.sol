/**
 *Submitted for verification at BscScan.com on 2022-12-03
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// OpenZeppelin Contracts (last updated v4.6.0) (proxy/utils/Initializable.sol)

// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

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
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
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
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
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
     */
    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, and for the lowest level
        // of initializers, because in other contexts the contract may have been reentered.
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}

// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/UUPSUpgradeable.sol)

// OpenZeppelin Contracts (last updated v4.5.0) (interfaces/draft-IERC1822.sol)

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

// OpenZeppelin Contracts (last updated v4.5.0) (proxy/ERC1967/ERC1967Upgrade.sol)

// OpenZeppelin Contracts v4.4.1 (proxy/beacon/IBeacon.sol)

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

// OpenZeppelin Contracts v4.4.1 (utils/StorageSlot.sol)

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

// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

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

interface IDexFactory {
    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
}

interface IDexRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

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

interface IReflexStaking {
    function stakedTokens(address user) external returns (uint256);
}

interface DividendDistributor {
    function setDistributionCriteria(
        uint256 _minPeriod,
        uint256 _minDistribution
    ) external;

    function setShare(address shareholder, uint256 amount) external;

    function deposit() external payable;

    function process(uint256 gas) external;

    function claimDividend(address _user) external;

    function getPaidEarnings(address shareholder)
    external
    view
    returns (uint256);

    function getUnpaidEarnings(address shareholder)
    external
    view
    returns (uint256);

    function totalDistributed() external view returns (uint256);

    function totalShares() external view returns (uint256);

    function totalDividends() external view returns (uint256);

    function shareholders(uint index) external view returns (address);

    function shares(address account) external view returns(uint256, uint256, uint256);

    function shareholderIndexes(address account) external view returns(uint256);

    function shareholderClaims(address account) external view returns(uint256);

    function processCount(uint) external;
    function getHolders() external;
}

// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

/// @title Reflex V2.1
/// @notice Reflex original V2 contract
/// @dev all variables have been set to internal and some are ignored on V3.
/// @author Oringally authored by BCX team, striped and modified by [email protected]
contract ReflexV2_1 is Initializable, UUPSUpgradeable, PausableUpgradeable, OwnableUpgradeable {
    /// @notice the storage for balances
    /// @dev used in V3 see _getBalancesStorage()
    mapping(address => uint256) internal _balances;
    /// @notice the storage for allowances
    /// @dev used in V3 see _getAllowanceStorage()
    mapping(address => mapping(address => uint256)) internal _allowances;
    /// @notice the constant storage the token name
    /// @dev used in V3 see _getNameStorage()
    string internal constant _name = "ReflexV2";
    /// @notice the constant storage the token symbol
    /// @dev used in V3 see symbol()
    string internal constant _symbol = "RFX";
    /// @notice the constant storage the token decimals
    /// @dev used in V3 see decimals()
    uint8 internal constant _decimals = 18;
    /// @notice the constant storage the total supply
    /// @dev used in V3 see _getTotalSupplyStorage()
//    uint256 internal constant _totalSupply = 1000000000000000 * 10 ** _decimals;

    address internal rewardToken;
    address private constant DEAD = address(0xdead);

    uint256 internal liquidityFee;
    uint256 internal buybackFee;
    uint256 internal reflectionFee;
    uint256 internal marketingFee;
    uint256 internal stakingFee;
    uint256 internal totalFee;
    uint256 internal feeDenominator;

    IDexRouter internal router;
    address internal pair;

    address internal marketingFeeReceiver;
    address internal stakingFeeReceiver;

    bool internal stakingEnabled;
    IReflexStaking internal stake;

    bool internal swapEnabled;
    uint256 internal swapThreshold;

    bool internal autoBuybackEnabled;
    uint256 internal autoBuybackThreshold;
    uint256 internal autoBuybackBlockPeriod;
    uint256 internal autoBuybackBlockLast;

    DividendDistributor internal distributor;
    uint256 internal distributorGas;

    bool internal antiWhaleEnabled;
    uint256 internal antiWhaleSellLimit;

    bool inSwap;

    mapping(address => bool) internal isFeeExempt;
    mapping(address => bool) internal isDividendExempt;
    mapping(address => bool) internal isBlacklisted;

    bool internal enableGetHoldersCall;

    function _authorizeUpgrade(address newImplementation) internal override virtual onlyOwner {}

}

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

/// @title bit library
/// @notice old school bit bits
library bits {

    /// @notice check if only a specific bit is set
    /// @param slot the bit storage slot
    /// @param bit the bit to be checked
    /// @return return true if the bit is set
    function only(uint slot, uint bit) internal pure returns (bool) {
        return slot == bit;
    }

    /// @notice checks if all bits ares set and cleared
    function all(uint slot, uint set_, uint cleared_) internal pure returns (bool) {
        return all(slot, set_) && !all(slot, cleared_);
    }

    /// @notice checks if any of the bits_ are set
    /// @param slot the bit storage to slot
    /// @param bits_ the or list of bits_ to slot
    /// @return true of any of the bits_ are set otherwise false
    function any(uint slot, uint bits_) internal pure returns(bool) {
        return (slot & bits_) != 0;
    }

    /// @notice checks if any of the bits are set and all of the bits are cleared
    function check(uint slot, uint set_, uint cleared_) internal pure returns(bool) {
        return slot != 0 ?  ((set_ == 0 || any(slot, set_)) && (cleared_ == 0 || !any(slot, cleared_))) : (set_ == 0 || any(slot, set_));
    }

    /// @notice checks if all of the bits_ are set
    /// @param slot the bit storage
    /// @param bits_ the list of bits_ required
    /// @return true if all of the bits_ are set in the sloted variable
    function all(uint slot, uint bits_) internal pure returns(bool) {
        return (slot & bits_) == bits_;
    }

    /// @notice set bits_ in this storage slot
    /// @param slot the storage slot to set
    /// @param bits_ the list of bits_ to be set
    /// @return a new uint with bits_ set
    /// @dev bits_ that are already set are not cleared
    function set(uint slot, uint bits_) internal pure returns(uint) {
        return slot | bits_;
    }

    function toggle(uint slot, uint bits_) internal pure returns (uint) {
        return slot ^ bits_;
    }

    function isClear(uint slot, uint bits_) internal pure returns(bool) {
        return !all(slot, bits_);
    }

    /// @notice clear bits_ in the storage slot
    /// @param slot the bit storage variable
    /// @param bits_ the list of bits_ to clear
    /// @return a new uint with bits_ cleared
    function clear(uint slot, uint bits_) internal pure returns(uint) {
        return slot & ~(bits_);
    }

    /// @notice clear & set bits_ in the storage slot
    /// @param slot the bit storage variable
    /// @param bits_ the list of bits_ to clear
    /// @return a new uint with bits_ cleared and set
    function reset(uint slot, uint bits_) internal pure returns(uint) {
        slot = clear(slot, type(uint).max);
        return set(slot, bits_);
    }

}

/// @notice Emitted when a check for
    error FlagsInvalid(address account, uint256 set, uint256 cleared);

/// @title UsingFlags contract
/// @notice Use this contract to implement unique permissions or attributes
/// @dev you have up to 255 flags you can use. Be careful not to use the same flag more than once. Generally a preferred approach is using
///      pure virtual functions to implement the flags in the derived contract.
abstract contract UsingFlags {
    /// @notice a helper library to check if a flag is set
    using bits for uint256;
    event FlagsChanged(address indexed account, uint256 from, uint256 to);

    /// @notice checks of the required flags are set or cleared
    /// @param account_ the account to check
    /// @param set_ the flags that must be set
    /// @param cleared_ the flags that must be cleared
    modifier requires(address account_, uint256 set_, uint256 cleared_) {
        if (!(_getFlags(account_).check(set_, cleared_))) revert FlagsInvalid(account_, set_, cleared_);
        _;
    }

    /// @notice getFlags returns the currently set flags
    /// @param account_ the account to check
    function getFlags(address account_) public virtual view returns (uint256) {
        return _getFlags(account_);
    }

    function _getFlags(address account_) internal virtual view returns (uint256) {
        return _getFlagStorage()[account_];
    }

    /// @notice set and clear flags for the given account
    /// @param account_ the account to modify flags for
    /// @param set_ the flags to set
    /// @param clear_ the flags to clear
    function _setFlags(address account_, uint256 set_, uint256 clear_) internal virtual {
        uint256 before = _getFlags(account_);
        _getFlagStorage()[account_] = _getFlags(account_).set(set_).clear(clear_);
        emit FlagsChanged(account_, before, _getFlags(account_));
    }

    function _checkFlags(address account_, uint set_, uint cleared_) internal view returns (bool) {
        return _checkFlags(_getFlags(account_), set_, cleared_);
    }

    function _checkFlags(uint flags_, uint set_, uint cleared_) internal pure returns (bool) {
        return flags_.check(set_, cleared_);
    }

    function _assertFlags(uint flags_, uint set_, uint cleared_) internal pure {
        if (!_checkFlags(flags_, set_, cleared_)) revert FlagsInvalid(address(0), set_, cleared_);
    }

    function _assertFlags(address account_, uint set_, uint cleared_) internal view {
        if (!_checkFlags(_getFlags(account_), set_, cleared_)) revert FlagsInvalid(account_, set_, cleared_);

    }

    /// @notice get the storage for flags
    function _getFlagStorage() internal view virtual returns (mapping(address => uint256) storage);
}

/// @title UsingFlagsWithStorage contract
/// @dev use this when creating a new contract
abstract contract UsingFlagsWithStorage is UsingFlags {
    using bits for uint256;

    /// @notice the mapping to store the flags
    mapping(address => uint256) internal _flags;

    function _getFlagStorage() internal view override returns (mapping(address => uint256) storage) {
        return _flags;
    }
}

    error AdminRequired();
    error Initialized();

abstract contract DefaultFlags is UsingFlags {
    using bits for uint256;

    uint constant TRANSFERS_ENABLED = 1; // 0
    uint constant PERMITS_ENABLED =  TRANSFERS_ENABLED << 1; // 1
    uint constant INITIALIZED = PERMITS_ENABLED << 1; // 2
    uint constant ADMIN = INITIALIZED << 1; // 3
    uint constant LIQUIDITY_PAIR = ADMIN << 1; // 5
    uint constant FEE_EXEMPT = LIQUIDITY_PAIR << 1; // 7
    uint constant BLOCKED = FEE_EXEMPT << 1; // 8
    uint constant REWARD_EXEMPT = BLOCKED << 1; // 9
    uint constant REWARD_SWAPPING_DISABLED = REWARD_EXEMPT << 1;
    uint constant REWARD_DISTRIBUTION_EXEMPT = REWARD_SWAPPING_DISABLED << 1;
    uint constant STAKING_POOL = REWARD_DISTRIBUTION_EXEMPT << 1;

    uint constant THIS_OFFSET = 223;
    uint constant SENDER_OFFSET = THIS_OFFSET - 32;
    uint constant SOURCE_OFFSET = SENDER_OFFSET - 32;
    uint constant TARGET_OFFSET = SOURCE_OFFSET - 32;

    uint constant THIS_TRANSFERS_ENABLED = TRANSFERS_ENABLED << THIS_OFFSET;
    uint constant THIS_PERMITS_ENABLED = PERMITS_ENABLED << THIS_OFFSET;
    uint constant THIS_INITIALIZED = INITIALIZED << THIS_OFFSET;
    uint constant THIS_REWARD_SWAPPING_DISABLED = REWARD_SWAPPING_DISABLED << THIS_OFFSET;

    uint constant THIS_FLAGS_MASK = ((1 << 32) - 1) << 224;

    uint constant SENDER_IS_ADMIN = ADMIN << SENDER_OFFSET;
    uint constant SENDER_FLAGS_MASK = ((1 << 32) - 1) << 192;

    uint constant SOURCE_IS_LIQUIDITY_PAIR = LIQUIDITY_PAIR << SOURCE_OFFSET;
    uint constant SOURCE_IS_FEE_EXEMPT = FEE_EXEMPT << SOURCE_OFFSET;
    uint constant SOURCE_IS_BLOCKED = BLOCKED << SOURCE_OFFSET;
    uint constant SOURCE_TRANSFERS_ENABLED = TRANSFERS_ENABLED << SOURCE_OFFSET;
    uint constant SOURCE_IS_REWARD_EXEMPT = REWARD_EXEMPT << SOURCE_OFFSET;
    uint constant SOURCE_IS_REWARD_DISTRIBUTION_EXEMPT = REWARD_DISTRIBUTION_EXEMPT << SOURCE_OFFSET;
    uint constant SOURCE_IS_STAKING_POOL = STAKING_POOL << SOURCE_OFFSET;
    uint constant TARGET_IS_LIQUIDITY_PAIR = LIQUIDITY_PAIR << TARGET_OFFSET;
    uint constant TARGET_IS_FEE_EXEMPT = FEE_EXEMPT << TARGET_OFFSET;
    uint constant TARGET_IS_BLOCKED = BLOCKED << TARGET_OFFSET;
    uint constant TARGET_IS_REWARD_EXEMPT = REWARD_EXEMPT << TARGET_OFFSET;
    uint constant TARGET_IS_REWARD_DISTRIBUTION_EXEMPT = REWARD_DISTRIBUTION_EXEMPT << TARGET_OFFSET;
    uint constant TARGET_IS_STAKING_POOL = STAKING_POOL << TARGET_OFFSET;

    uint constant PRECISION = 10 ** 5;

    modifier requiresAdmin() {
        if (!_getFlags(msg.sender).all(ADMIN)) revert AdminRequired();
        _;
    }

    /// @notice set and clear any arbitrary flag
    /// @dev only use this if you know what you are doing
    function setFlags(address account_, uint256 set_, uint256 clear_) external requiresAdmin {
        _setFlags(account_, set_, clear_);
    }

    /// @notice set and clear any arbitrary flag
    /// @dev only use this if you know what you are doing
    function clearAllFlags(address account_) external requiresAdmin {
        _getFlagStorage()[account_] = 0;
    }

    function _INITIALIZED_FLAG() internal pure virtual returns (uint256) {
        return 1 << 255;
    }

    function _TRANSFER_DISABLED_FLAG() internal pure virtual returns (uint256) {
        return _INITIALIZED_FLAG() >> 1; // 254
    }

    function _PROVIDER_FLAG() internal pure virtual returns (uint256) {
        return _TRANSFER_DISABLED_FLAG() >> 1; // 253
    }

    function _SERVICE_FLAG() internal pure virtual returns (uint256) {
        return _PROVIDER_FLAG() >> 1; // 252
    }

    function _NETWORK_FLAG() internal pure virtual returns (uint256) {
        return _SERVICE_FLAG() >> 1; // 251
    }

    function _SERVICE_EXEMPT_FLAG() internal pure virtual returns(uint256) {
        return _NETWORK_FLAG() >> 1; // 250
    }

    function _PROCESSING_FLAG() internal pure virtual returns (uint256) {
        return _SERVICE_EXEMPT_FLAG() >> 1; // 249
    }

    function _ADMIN_FLAG() internal virtual pure returns (uint256) {
        return _PROCESSING_FLAG() >> 1;  // 248
    }

    function _BLOCKED_FLAG() internal pure virtual returns (uint256) {
        return _ADMIN_FLAG() >> 1; // 247
    }

    function _ROUTER_FLAG() internal pure virtual returns (uint256) {
        return _BLOCKED_FLAG() >> 1;    // 246
    }

    function _SERVICE_FEE_EXEMPT_FLAG() internal pure virtual returns (uint256) {
        return _ROUTER_FLAG() >> 1;
    }

    function _isServiceFeeExempt(address from_, address to_) internal view virtual returns (bool) {
        return _getFlags(from_).all(_SERVICE_FEE_EXEMPT_FLAG()) || _getFlags(to_).all(_SERVICE_FEE_EXEMPT_FLAG());
    }

    function _SELL_LIMIT_DISABLED_FLAG() internal pure virtual returns (uint256) {
        return 1 << 128;
    }

    function _LP_PAIR_FLAG() internal pure virtual returns (uint256) {
        return _SELL_LIMIT_DISABLED_FLAG() >> 1;
    }

    function _REWARD_EXEMPT_FLAG() internal pure virtual returns (uint256) {
        return _LP_PAIR_FLAG() >> 1;
    }

    function _SELL_LIMIT_EXEMPT_FLAG() internal pure virtual returns (uint256) {
        return _REWARD_EXEMPT_FLAG() >> 1;
    }

    function _ACCOUNT_FLAG() internal pure virtual returns (uint256) {
        return _SELL_LIMIT_EXEMPT_FLAG() >> 1;
    }

    function _isLPPair(address from_, address to_) internal view virtual returns (bool) {
        return _isLPPair(from_) || _isLPPair(to_);
    }

    function _isLPPair(address account_) internal view virtual returns (bool) {
        return _getFlags(account_).check(_LP_PAIR_FLAG(), 0);
    }

    function _isServiceExempt(address from_, address to_) internal view virtual returns (bool) {
        return _getFlags(from_).all(_SERVICE_EXEMPT_FLAG()) || _getFlags(to_).all(_SERVICE_EXEMPT_FLAG());
    }

    function _isSellLimitEnabled() internal view virtual returns (bool) {
        return _getFlags(address(this)).check(0, _SELL_LIMIT_DISABLED_FLAG());
    }

    function _isRewardExempt(address account_) internal view virtual returns (bool) {
        return _getFlags(account_).check(_REWARD_EXEMPT_FLAG(), 0);
    }

    function _isSellLimitExempt(address account_) internal view virtual returns (bool) {
        return _isSellLimitEnabled() && _getFlags(account_).check(_SELL_LIMIT_EXEMPT_FLAG(), 0);
    }

    function _isRouter(address account_) internal view virtual returns (bool) {
        return _getFlags(account_).check(_ROUTER_FLAG(), 0);
    }

}

abstract contract DefaultFlagsWithStorage is UsingFlagsWithStorage, DefaultFlags {

}

/// @notice the spender isn't authorized to spend this amount
error ERC20AllowanceInsufficient(address account, address spender, uint256 amount);
/// @notice the amount trying being from the account is greater than the account's balance
error ERC20BalanceInsufficient(address account, uint256 amount);

error ERC20TransfersDisabled();

/// @title Using ERC20 an implementation of EIP-20
/// @dev this is purely the implementation and doesn't contain storage it can be used with existing upgradable contracts just map the existing storage.
abstract contract UsingERC20  {

    /// @notice the event emitted after the a transfer
    event Transfer(address indexed from, address indexed to, uint256 value);
    /// @notice the event emitted upon receiving approval
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /// @notice transfer tokens from sender to account
    /// @param target_ the address to transfer to
    /// @param amount_ the amount to transfer
    function transfer(address target_, uint256 amount_) external virtual returns (bool) {
        _assertSufficientBalance(msg.sender, amount_);
        return _transfer(msg.sender, target_, amount_);
    }

    /// @notice checks to see if the spender is approved to spend the given amount and transfer
    /// @param source_ the account to transfer from
    /// @param target_ the account to transfer to
    /// @param amount_ the amount to transfer
    function transferFrom(address source_, address target_, uint256 amount_) external virtual returns (bool) {
        _assertSufficientAllowance(source_, msg.sender, amount_);
        _assertSufficientBalance(source_, amount_);
        return _transferFrom(msg.sender, source_, target_, amount_);
    }

    /// @notice the allowance the spender is allowed to spend for an account
    /// @param account_ the account to check
    /// @param spender_ the trusted spender
    /// @return uint256 amount of the account that the spender_ can transfer
    function allowance(address account_, address spender_) external view virtual returns (uint256) {
        return _allowance(account_, spender_);
    }

    /// @notice returns the total supply of tokens
    function totalSupply() public view virtual returns (uint256) {
        return _getTotalSupplyStorage();
    }

    /// @notice check the balance of the given account
    /// @param account_ the account to check
    /// @return uint256 the balance of the account
    function balanceOf(address account_) external view virtual returns (uint256) {
        return _getBalancesStorage()[account_];
    }

    /// @notice the symbol of the token
    function symbol() public view virtual returns (string memory) {
        return _getSymbolStorage();
    }

    /// @notice the decimals of the token
    function decimals() public view virtual returns (uint8) {
        return _getDecimalStorage();
    }

    /// @notice the name of the token
    function name() public view virtual returns (string memory) {
        return _getNameStorage();
    }

    /// @notice approve the spender to spend the given amount for an account
    /// @param spender_ the account to approve
    /// @param amount_ the amount to approve
    function approve(address spender_, uint256 amount_) public virtual returns (bool) {
        _approve(msg.sender, spender_, amount_);
        return true;
    }

    function _allowance(address account_, address spender_) internal view virtual returns (uint256) {
        return _getAllowanceStorage()[account_][spender_];
    }

    /// @notice initialize the token
    /// @dev used internally if you use this in a public function be sure to use the initializer
    function _initializeERC20(address target_, uint totalSupply_) internal virtual {
        _mint(target_, totalSupply_);
    }

    /// @notice approve the spender to spend the given amount for an account
    /// @param spender_ the account to approve
    /// @param amount_ the amount to approve
    function _approve(address source_, address spender_, uint256 amount_) internal virtual {
        _getAllowanceStorage()[source_][spender_] = amount_;
        emit Approval(source_, spender_, amount_);
    }

    /// @notice used internally to get the balance of the account
    function _balanceOf(address account_) internal view virtual returns (uint256) {
        return _getBalancesStorage()[account_];
    }

    /// @notice checks to see if the spender is approved to spend the given amount and transfer
    /// @param source_ the account to transfer from
    /// @param target_ the account to transfer to
    /// @param amount_ the amount to transfer
    function _transferFrom(address spender_, address source_, address target_, uint256 amount_) internal virtual returns (bool) {
        unchecked {
            _getAllowanceStorage()[source_][spender_] -= amount_;
        }
        return _transfer(source_, target_, amount_);
    }

    function _assertSufficientBalance(address account_, uint256 amount_) internal view virtual {
        if (amount_ > _balanceOf(account_)) {
            revert ERC20BalanceInsufficient(account_, amount_);
        }
    }

    function _assertSufficientAllowance(address source_, address spender_, uint256 amount_) internal view virtual {
        if (_allowance(source_, spender_) < amount_ ) {
            revert ERC20AllowanceInsufficient(source_, spender_, amount_);
        }
    }

    function _transfer(address source_, address target_, uint256 amount_) internal virtual returns (bool) {
        _assertSufficientBalance(source_, amount_);
        return _transferUnchecked(source_, target_, amount_);
    }

    /// @notice transfer tokens to one account from another
    /// @param source_ the account to transfer from
    /// @param target_ the account to transfer to
    /// @param amount_ the amount to transfer
    /// @dev inherit from this function to implement custom taxation or other logic warning this function does zero checking for underflows and overflows
    function _transferUnchecked(address source_, address target_, uint256 amount_) internal virtual returns (bool) {
        unchecked {
            _getBalancesStorage()[source_] -= amount_;
            _getBalancesStorage()[target_] += amount_;
        }
        emit Transfer(source_, target_, amount_);
        return true;
    }

    /// @notice mint tokens and adjust the supply
    /// @param target_ the account to mint to
    /// @param amount_ the amount to mint
    function _mint(address target_, uint256 amount_) internal virtual {
        unchecked {
            _setTotalSupplyStorage(_getTotalSupplyStorage() + amount_);
            _getBalancesStorage()[target_] += amount_;
        }
        emit Transfer(address(0), target_, amount_);
    }

    /// @notice burn tokens and adjust the supply
    /// @param source_ the account to burn from
    /// @param amount_ the amount to burn
    function _burn(address source_, uint amount_) internal virtual {
        _assertSufficientBalance(source_, amount_);
        unchecked {
            _setTotalSupplyStorage(_getTotalSupplyStorage() - amount_);
            _getBalancesStorage()[source_] -= amount_;
        }
        emit Transfer(source_, address(0), amount_);
    }

    /// @notice get the storage for allowance
    /// @return mapping(address => mapping(address => uint256)) allowance storage
    function _getAllowanceStorage() internal view virtual returns (mapping(address => mapping(address => uint256)) storage);
    /// @notice get the storage for balances
    function _getNameStorage() internal view virtual returns (string memory);
    /// @return mapping(address => uint256) balances storage
    function _getBalancesStorage() internal view virtual returns (mapping(address => uint256) storage);
    function _getTotalSupplyStorage() internal view virtual returns (uint256);
    function _setTotalSupplyStorage(uint256 value) internal virtual;
    function _getSymbolStorage() internal view virtual returns (string memory);
    function _getDecimalStorage() internal view virtual returns (uint8);
}

/// @notice The signer of the permit doesn't match
    error PermitSignatureInvalid(address recovered, address expected, uint256 amount);
/// @notice the block.timestamp has passed the deadline
    error PermitExpired(address owner, address spender, uint256 amount, uint256 deadline);
    error PermitInvalidSignatureSValue();
    error PermitInvalidSignatureVValue();

/// @title Using EIP-2612 Permits
/// @author originally written by soliditylabs with modifications made by [email protected]
/// @dev reference implementation can be found here https://github.com/soliditylabs/ERC20-Permit/blob/main/contracts/ERC20Permit.sol.
///      This contract contains the implementation and lacks storage. Use this with existing upgradeable contracts.
abstract contract UsingPermit  {

    /// @notice initialize the permit function internally
    function _initializePermits() internal {
        _updateDomainSeparator(block.chainid);
    }

    /// @notice get the nonce for the given account
    /// @param account_ the account to get the nonce for
    /// @return the nonce
    function nonces(address account_) public view returns (uint256) {
        return _getNoncesStorage()[account_];
    }

    /// @notice the domain separator for a chain
    /// @param chainId_ the chain id to get the domain separator for
    function domainSeparators(uint256 chainId_) public view returns (bytes32) {
        return _getDomainSeparatorsStorage()[chainId_];
    }

    /// @notice check if the permit is valid
    function _permit(uint chainId_, address owner_, address spender_, uint256 amount_, uint256 deadline_, uint8 v_, bytes32 r_, bytes32 s_) internal virtual {
        if(block.timestamp > deadline_) revert PermitExpired(owner_, spender_, amount_, deadline_);
        bytes32 hashStruct;
        uint256 nonce = _getNoncesStorage()[owner_]++;
        assembly {
            let memPtr := mload(64)
            mstore(memPtr, 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9)
            mstore(add(memPtr, 32), owner_)
            mstore(add(memPtr, 64), spender_)
            mstore(add(memPtr, 96), amount_)
            mstore(add(memPtr, 128),nonce)
            mstore(add(memPtr, 160), deadline_)
            hashStruct := keccak256(memPtr, 192)
        }
        bytes32 eip712DomainHash = _domainSeparator(chainId_);
        bytes32 hash;
        assembly {
            let memPtr := mload(64)

            mstore(memPtr, 0x1901000000000000000000000000000000000000000000000000000000000000)
            mstore(add(memPtr, 2), eip712DomainHash)
            mstore(add(memPtr, 34), hashStruct)

            hash := keccak256(memPtr, 66)
        }
        address signer = _recover(hash, v_, r_, s_);
        if (signer != owner_) revert PermitSignatureInvalid(signer, owner_, amount_);
    }

    /// @notice add a new domain separator to the mapping
    /// @return the domain separator hash
    function _updateDomainSeparator(uint chainId_) internal virtual returns (bytes32) {
        bytes32 newDomainSeparator = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256(bytes(_getNameStorage())), // ERC-20 Name
                keccak256(bytes("1")),    // Version
                chainId_,
                address(this)
            )
        );
        _getDomainSeparatorsStorage()[chainId_] = newDomainSeparator;
        return newDomainSeparator;
    }

    /// @notice get the domain separator and add it to the mapping if it doesn't exist
    /// @return the new or cached domain separator
    function _domainSeparator(uint chainId_) internal virtual returns (bytes32) {
        bytes32 domainSeparator = _getDomainSeparatorsStorage()[chainId_];

        if (domainSeparator != 0x00) {
            return domainSeparator;
        }

        return _updateDomainSeparator(chainId_);
    }

    /// @notice recover the signer address from the signature
    function _recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (281): 0 < s < secp256k1n ÷ 2 + 1, and for v in (282): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (
            uint256(s) >
            0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0
        ) {
            revert PermitInvalidSignatureSValue();
        }

        if (v != 27 && v != 28) {
            revert PermitInvalidSignatureVValue();
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) revert PermitSignatureInvalid(signer, address(0), 0);
        return signer;
    }

    /// @notice the name used to compute the domain separator
    function _getNameStorage() internal view virtual returns (string memory);
    /// @notice get the nonce storage
    function _getNoncesStorage() internal view virtual returns (mapping(address => uint256) storage);
    /// @notice get the domain separator storage
    function _getDomainSeparatorsStorage() internal view virtual returns (mapping(uint256 => bytes32) storage);

}

abstract contract UsingPermitWithStorage is UsingPermit {
    /// @notice nonces per account to prevent re-use of permit
    mapping(address => uint256) internal _nonces;
    /// @notice the predefined type hash
    bytes32 public constant TYPE_HASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
    /// @notice a mapping of chainId and domain separators
    mapping(uint256 => bytes32) internal _domainSeparators;

    function _getNoncesStorage() internal view override returns (mapping(address => uint256) storage) {
        return _nonces;
    }

    function _getDomainSeparatorsStorage() internal view override returns (mapping(uint256 => bytes32) storage) {
        return _domainSeparators;
    }

}

library AddressSet {
    using AddressSet for Set;

    error KeyExists();
    error KeyError();

    struct Set {
        address[] items;
        mapping(address => uint) indices;
    }

    function add(Set storage set_, address item_) internal {
        if (set_.contains(item_)) revert KeyExists();
        set_.items.push(item_);
        set_.indices[item_] = set_.items.length;
    }

    function replace(Set storage set_, address oldItem_, address newItem_) internal {
        if (set_.indices[oldItem_] == 0) {
            revert KeyError();
        }
        set_.items[set_.indices[oldItem_] - 1] = newItem_;
        set_.indices[newItem_] = set_.indices[oldItem_];
        set_.indices[oldItem_] = 0;
    }

    function pop(Set storage set_) internal returns (address) {
        address last = set_.items[set_.length() - 1];
        delete set_.indices[last];
        return last;
    }

    function get(Set storage set_, uint index_) internal view returns (address) {
        return set_.items[index_];
    }

    function length(Set storage set_) internal view returns (uint) {
        return set_.items.length;
    }

    function remove(Set storage set_, address item_) internal  {
        if (set_.indices[item_] == 0) {
            revert KeyError();
        }
        uint index = set_.indices[item_];
        if (index != set_.length()) {
            set_.items[index - 1] = set_.items[set_.length() - 1];
            set_.indices[set_.items[index - 1]] = index;
        }
        set_.items.pop();
        set_.indices[item_] = 0;
    }

    function clear(Set storage set_) internal {
        for (uint i=0; i < set_.length(); i++) {
            address key = set_.items[i];
            set_.indices[key] = 0;
        }
        delete set_.items;
    }

    function contains(Set storage set_, address item_) internal view returns (bool) {
        return set_.indices[item_] > 0;
    }

    function indexOf(Set storage set_, address item_) internal view returns (uint) {
        return set_.indices[item_] - 1;
    }

    function slice(Set storage set_, uint begin_, uint end_) internal view returns (address[] memory) {
        address[] memory items = new address[](end_ - begin_);
        for (uint i = 0; i < end_ - begin_; i++) {
            items[i + begin_] = set_.items[i];
        }
        return items;
    }

}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

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

/// @notice the error thrown when attempting to modify the total supply
error ReflexFixedTotalSupply();
error ReflexExcessiveTransferFee();
error ArrayLengthMismatch();
error WithdrawFailed();
error PaymentFailed();
error InvalidFeeTypeName();

interface IRewards {
    struct ExternalSnapshot {
        uint balance;
        uint claimed;
        uint rewardBalance;
        uint timestamp;
    }
    function distribute(uint count_) external;
    function snapshot(address account_) external view returns (ExternalSnapshot memory);
    function process(address, uint96, address, uint96, uint) external;
    function removeAccount(address) external;
    function addAccount(address) external;
    function progress() external view returns (uint, uint);
}

interface IStaking is IERC20 {
    function autoStake(address account_, uint256 amount_) external;
    function directDepositRewards(uint256 amount_) external;
}

/// @title ReflexV4
/// @notice Reflex finance token contract
/// @dev note this contract ignores previous variables used in V2.1
contract ReflexV4 is ReflexV2_1, UsingERC20, UsingPermitWithStorage, DefaultFlagsWithStorage {
    using bits for uint256;
    using AddressSet for AddressSet.Set;

    event FeeAllocationSet(Fee buy, Fee sell, Fee transfer);

    uint96 constant SWAP_TOKENS_STATE = 0;
    uint96 constant INJECT_LIQUIDITY_STATE = 1;
    uint96 constant TOTAL_STATES = 2;

    struct Fee {
        uint24 value;
        uint24 burnAllocation;
        uint24 liquidityAllocation;
        uint24 rewardAllocation;
        uint24 stakingAllocation;
        uint24 maintenanceAllocation;
        uint112 _unused0;
    }

    IStaking _stakingPool;
    IRewards _rewards;
    address _maintenanceWallet;
    address _liquidityWallet;
    mapping(uint => AddressSet.Set) _flaggedAccounts;
    IUniswapV2Router02 _router;
    Fee _transferFee;
    Fee _buyFee;
    Fee _sellFee;
    IUniswapV2Pair _pair;
    uint96 _state;
    uint _totalSupply;
    address[] _pathToBNB;

    /// @notice add an admin to this contract
    /// @param admin_ the address to add as an admin
    function addAdmin(address admin_) external requiresAdmin {
        _flaggedAccounts[ADMIN].add(admin_);
        _setFlags(admin_, ADMIN, 0);
    }

    /// @notice remove an admin from this contract
    /// @param admin_ the admin to remove
    /// @dev requires existing admin privileges
    function removeAdmin(address admin_) external requiresAdmin {
        _flaggedAccounts[ADMIN].remove(admin_);
        _setFlags(admin_, 0, ADMIN);
    }

    function setRewardsAddress(address rewards_) external requiresAdmin {
        _rewards = IRewards(rewards_);
    }

    function getRewardsAddress() external view returns (address) {
        return address(_rewards);
    }

    /// @notice add a staking pool contract
    function addStakingContract(address stakingPool_) public requiresAdmin {
        _setFlags(stakingPool_, STAKING_POOL, 0);
        _flaggedAccounts[STAKING_POOL].add(stakingPool_);
        _stakingPool = IStaking(stakingPool_);
    }

    /// @notice get the address of the staking contract
    /// @dev this is going to be deprecated
    function getStakingContract() external view returns (address) {
        return address(_stakingPool);
    }

    /// @notice deposit vested tokens into the staking pool
    function depositTokensForStaking(uint256 amount_) external requiresAdmin {
        super._transfer(msg.sender, address(_stakingPool), amount_);
        _stakingPool.directDepositRewards(amount_);
    }

    /// @notice set the address of the maintenance
    function setMaintenanceWallet(address maintenanceWallet_) external requiresAdmin {
        address currentMaintenanceWallet = _maintenanceWallet;
        if (currentMaintenanceWallet != address(0)) {
            _setFlags(currentMaintenanceWallet, 0, FEE_EXEMPT);
            _flaggedAccounts[FEE_EXEMPT].remove(currentMaintenanceWallet);
        }
        _maintenanceWallet = maintenanceWallet_;
        _setFlags(maintenanceWallet_, FEE_EXEMPT | REWARD_EXEMPT, 0);
        _flaggedAccounts[FEE_EXEMPT].add(maintenanceWallet_);
    }

    /// @notice exempt account from fees
    /// @param account_ the account to exempt from fees
    /// @dev will revert if sender isn't admin or if the account is already exempted
    function exemptAccountFromFees(address account_) external requiresAdmin {
        _flaggedAccounts[FEE_EXEMPT].add(account_);
        _setFlags(account_, FEE_EXEMPT, 0);
    }

    /// @notice remove fee exemption from account
    /// @param account_ the address of the account to remove the exemption
    /// @dev will revert if sender isn't admin or if the account doesn't have exemption
    function unexemptAccountFromFees(address account_) external requiresAdmin {
        _flaggedAccounts[FEE_EXEMPT].remove(account_);
        _setFlags(account_, 0, FEE_EXEMPT);
    }

    /// @notice block an account from transferring
    /// @param account_ the account to block
    /// @dev requires existing admin privileges
    function blockAccount(address account_) external requiresAdmin {
        _flaggedAccounts[BLOCKED].add(account_);
        _setFlags(account_, BLOCKED, 0);
    }

    /// @notice unblock an account from transferring
    /// @param account_ the account to unblock
    /// @dev requires existing admin privileges
    function unblockAccount(address account_) external requiresAdmin {
        _flaggedAccounts[BLOCKED].remove(account_);
        _setFlags(account_, 0, BLOCKED);
    }

    /// @notice add a liquidity pair for applying buy and sell tax
    /// @param pair_ the address of the pair to add
    /// @dev the contract currently only adds to the initial liquidity pool and will need an upgrade to add to additional pools
    function addPair(address pair_) external requiresAdmin {
        _addPair(pair_);
    }

    /// @notice exempt account from rewards
    /// @param account_ the account to exempt from rewards
    function exemptAccountFromRewards(address account_) external requiresAdmin {
        _flaggedAccounts[REWARD_EXEMPT].add(account_);
        _setFlags(account_, REWARD_EXEMPT, 0);
        _rewards.removeAccount(account_);
    }

    /// @notice exempt account from rewards
    /// @param account_ the account to exempt from rewards
    function unexemptAccountFromRewards(address account_) external requiresAdmin {
        _flaggedAccounts[REWARD_EXEMPT].remove(account_);
        _setFlags(account_, 0, REWARD_EXEMPT);
        _rewards.addAccount(account_);
    }

    /// @notice set the fess for buying, selling and transferring
    /// @param buyFee_ the fee for buying
    /// @param sellFee_ the fee for selling
    /// @param transferFee_ the fee for transferring
    /// @dev fees are in 000.000 format i.e 1% = 1000
    function setFees(uint24 buyFee_, uint24 sellFee_, uint24 transferFee_) external requiresAdmin {
        _buyFee.value = buyFee_;
        _sellFee.value = sellFee_;
        _transferFee.value = transferFee_;
    }

    /// @notice set the buy fee allocation
    /// @param liquidityAllocation_ the allocation to liquidity
    /// @param burnAllocation_ the allocation to burn
    /// @param rewardsAllocation_ the allocation to rewards
    /// @dev note that the allocation is a percentage of the fee for example if the fee is 3% and allocations are evenly split it would be 33000, 33000, 34000
    function setBuyAllocations(uint24 liquidityAllocation_,  uint24 burnAllocation_, uint24 rewardsAllocation_, uint24 stakingAllocation_, uint24 maintenanceFee_) public requiresAdmin  {
        _setAllocations(_buyFee, liquidityAllocation_, burnAllocation_, rewardsAllocation_, stakingAllocation_, maintenanceFee_);
    }

    /// @notice set the sell fee allocation
    /// @param liquidityAllocation_ the allocation to liquidity
    /// @param burnAllocation_ the allocation to burn
    /// @param rewardsAllocation_ the allocation to rewards
    /// @dev note that the allocation is a percentage of the fee for example if the fee is 3% and allocations are evenly split it would be 33000, 33000, 34000
    function setSellAllocations(uint24 liquidityAllocation_,  uint24 burnAllocation_, uint24 rewardsAllocation_, uint24 stakingAllocation_, uint24 maintenanceFee_) public requiresAdmin  {
        _setAllocations(_sellFee, liquidityAllocation_, burnAllocation_, rewardsAllocation_, stakingAllocation_, maintenanceFee_);
    }

    /// @notice set the transfer fee allocation
    /// @param liquidityAllocation_ the allocation to liquidity
    /// @param burnAllocation_ the allocation to burn
    /// @param rewardsAllocation_ the allocation to rewards
    /// @dev note that the allocation is a percentage of the fee for example if the fee is 3% and allocations are evenly split it would be 33000, 33000, 34000
    function setTransferAllocations(uint24 liquidityAllocation_,  uint24 burnAllocation_, uint24 rewardsAllocation_, uint24 stakingAllocation_, uint24 maintenanceFee_) public requiresAdmin  {
        _setAllocations(_transferFee, liquidityAllocation_, burnAllocation_, rewardsAllocation_, stakingAllocation_, maintenanceFee_);
    }

    /// @notice get the buy fee
    function getBuyFeeAndAllocations() external view returns (Fee memory) {
        return _buyFee;
    }

    /// @notice get the sell fee
    function getSellFeeAndAllocations() external view returns (Fee memory) {
        return _sellFee;
    }

    /// @notice get the transfer fee
    function getTransferFeeAndAllocations() external view returns (Fee memory) {
        return _transferFee;
    }

    /// @notice remove a liquidity pair for applying buy and sell tax
    /// @param pair_ the address of the pair to remove
    /// @dev requires existing admin privileges
    function removePair(address pair_) external requiresAdmin {
        _flaggedAccounts[LIQUIDITY_PAIR].remove(pair_);
        _setFlags(pair_, 0, LIQUIDITY_PAIR | REWARD_EXEMPT);
    }

    /// @notice pause the contract from all transfers
    /// @dev requires existing admin privileges
    function pause() external requiresAdmin {
        _setFlags(address(this), 0, TRANSFERS_ENABLED);
    }

    /// @notice unpause the contract and allow transferring
    function unpause() external requiresAdmin {
        _setFlags(address(this), TRANSFERS_ENABLED, 0);
    }

    /// @notice check if the contract is paused
    /// @return true if the contract is paused
    function paused() public view override returns (bool) {
        return _checkFlags(_getFlags(address(this)), 0, TRANSFERS_ENABLED);
    }

    /// @notice withdraw BNB that was sent to the contract by mistake
    /// @param to_ the address to send the BNB to
    /// @param amount_ the amount of BNB to send
    /// @dev requires existing admin privileges
    function withdrawBNB(address to_, uint256 amount_) external requiresAdmin {
        (bool success,) = payable(to_).call{value: amount_}("");
        if (!success) revert WithdrawFailed();
    }

    /// @notice withdraw tokens that were sent to the contract by mistake
    /// @param token_ the address of the token to withdraw
    /// @param to_ the address to send the tokens to
    /// @param amount_ the amount of tokens to send
    /// @dev requires existing admin privileges
    function withdrawTokens(address token_, address to_,  uint256 amount_) external requiresAdmin {
        if (token_ == address(this)) {
            super._transfer(address(this), to_, amount_);
        } else {
            IERC20(token_).transfer(to_, amount_);
        }
    }

    receive() external payable {}

    /// @notice burn tokens permanently from the contract
    function burn(uint256 amount_) external {
        _burn(msg.sender, amount_);
    }

    function _setAllocations(Fee storage fee_, uint24 liquidityAllocation_,  uint24 burnAllocation_, uint24 rewardsAllocation_, uint24 stakingAllocation_, uint24 maintenanceAllocation_) internal  {
        fee_.liquidityAllocation = liquidityAllocation_;
        fee_.burnAllocation = burnAllocation_;
        fee_.rewardAllocation = rewardsAllocation_;
        fee_.stakingAllocation = stakingAllocation_;
        fee_.maintenanceAllocation = maintenanceAllocation_;
        emit FeeAllocationSet(_buyFee, _sellFee, _transferFee);
    }

    function _addPair(address pair_) internal {
        _flaggedAccounts[LIQUIDITY_PAIR].add(pair_);
        _flaggedAccounts[REWARD_EXEMPT].add(pair_);
        _setFlags(pair_, LIQUIDITY_PAIR | REWARD_EXEMPT, 0);
    }

    function _transfer(address source_, address target_, uint256 amount_) internal override(UsingERC20) returns (bool) {
        uint flags = _getTransferFlags(msg.sender, source_, target_);
        // check to ensure that transfers are enabled and that the sender and recipient are not blocked
        _assertFlags(flags, THIS_TRANSFERS_ENABLED | SENDER_IS_ADMIN | SOURCE_TRANSFERS_ENABLED, SOURCE_IS_BLOCKED | TARGET_IS_BLOCKED);
        if (flags.any(SOURCE_IS_STAKING_POOL)) {
            return _transferFromStakingPool(source_, target_, amount_, flags);
        } else if (flags.any(TARGET_IS_STAKING_POOL)) {
            return _transferToStakingPool(source_, target_, amount_, flags);
        } else if (!_checkFlags(flags, SOURCE_IS_FEE_EXEMPT | TARGET_IS_FEE_EXEMPT, 0)) {
            amount_ -= _process(source_, amount_, flags);
        }
        if (!flags.all(SOURCE_IS_REWARD_EXEMPT | TARGET_IS_REWARD_EXEMPT)) {
            _rewards.process(source_, uint96(amount_), target_, uint96(_balanceOf(address(_rewards))), flags);
        }

        return super._transfer(source_, target_, amount_);
    }

    function _transferToStakingPool(address source_, address target_, uint256 amount_, uint flags) internal returns (bool) {
        _stakingPool.autoStake(source_, amount_);
        return super._transfer(source_, target_, amount_);
    }

    function _transferFromStakingPool(address source_, address target_, uint256 amount_, uint flags) internal returns (bool) {
        return super._transfer(source_, target_, amount_);
    }

    function _process(address source_, uint amount_, uint flags_) internal returns (uint) {
        if (_checkFlags(flags_, SOURCE_IS_LIQUIDITY_PAIR, 0)) {
            // if the source is a liquidity pair, then the transfer is a sell
            amount_ = _applyFee(source_, amount_, _buyFee);
        } else {
            uint tokenBalance = _balanceOf(address(this));
            amount_ = _applyFee(source_, amount_, flags_.any(TARGET_IS_LIQUIDITY_PAIR) ? _sellFee : _transferFee);
            if (amount_ > 0) {
                uint96 state = _state % TOTAL_STATES;
                unchecked {
                    _state++;
                }
                uint balance = address(this).balance;
                if (state == INJECT_LIQUIDITY_STATE  && balance > 0) {
                    _executeLiquidityInjection(tokenBalance + _calculatePercentage(amount_, _sellFee.liquidityAllocation), balance);
                } else if (_executeSwap(amount_, address(this))) {
                    uint received = address(this).balance - balance;
                    _send(_maintenanceWallet, _calculatePercentage(received, _sellFee.maintenanceAllocation));
                    _send(address(_rewards), _calculatePercentage(received, _sellFee.rewardAllocation));
                }
            }
        }
        return amount_;
    }

    function _applyFee(address source_, uint amount_, Fee storage fee_) internal returns (uint) {
        if (fee_.value > 0) {
            amount_ = _calculatePercentage(amount_, fee_.value);
            super._transfer(source_, address(this), _calculatePercentage(amount_, fee_.maintenanceAllocation + fee_.rewardAllocation + fee_.liquidityAllocation));
            return amount_;
        }
        return 0;
    }

    function _send(address to_, uint amount_) internal {
        (bool success,) = payable(to_).call{value: amount_}("");
        if (!success) revert PaymentFailed();
    }

    function _calculatePercentage(uint amount_, uint24 percentage_) internal pure returns (uint) {
        return amount_ * percentage_ / PRECISION;
    }

    function _executeSwap(uint amount_,  address to_) internal returns (bool)  {
        try _router.swapExactTokensForETHSupportingFeeOnTransferTokens(amount_, 0, _pathToBNB, to_, block.timestamp + 1) {
            _burn(address(_pair), amount_);
            _pair.sync();
            return true;
        } catch {}
        return false;
    }

    function _executeLiquidityInjection(uint amount_, uint value_) internal {
        try _router.addLiquidityETH{value: value_}(address(this), amount_, 0, 0, _liquidityWallet, block.timestamp + 1) {} catch {}
    }

    function _assertSufficientBalance(address source_, uint amount_) internal view override(UsingERC20) {
        return UsingERC20._assertSufficientBalance(source_, amount_);
    }

    function _getTransferFlags(address sender_, address source_, address target_) internal view returns (uint) {
        return _getFlags(address(this)) << THIS_OFFSET |  _getFlags(sender_) << SENDER_OFFSET |  _getFlags(source_) << SOURCE_OFFSET | _getFlags(target_) << TARGET_OFFSET;
    }

    /// @notice the version of the contract
    function version() public view returns (string memory) {
        return "4";
    }

    /// @notice get the name of the token
    /// @return the name of the token
    function _getSymbolStorage() internal view override returns (string memory) {
        return _symbol;
    }

    /// @inheritdoc UsingERC20
    function _getBalancesStorage() internal view override returns (mapping(address => uint256) storage) {
        return _balances;
    }

    /// @inheritdoc UsingERC20
    function _getAllowanceStorage() internal view override returns (mapping(address => mapping(address => uint256)) storage) {
        return _allowances;
    }
    /// @inheritdoc UsingERC20
    function _getTotalSupplyStorage() internal view override returns (uint256) {
        return _totalSupply;
    }

    /// @inheritdoc UsingERC20
    function _getDecimalStorage() internal view override returns (uint8) {
        return _decimals;
    }

    /// @notice get the total supply of the token
    /// @dev since the v2.1 total supply is constant this function will revert if called in V3
    function _setTotalSupplyStorage(uint256 value) internal override {
       _totalSupply = value;
    }

    function _getNameStorage() internal view override(UsingERC20, UsingPermit) returns (string memory) {
        return _name;
    }

    function _authorizeUpgrade(address newImplementation) internal override virtual onlyOwner {}

}