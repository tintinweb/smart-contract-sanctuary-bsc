/**
 *Submitted for verification at BscScan.com on 2022-12-13
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

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
}

/**
 * @dev String operations.
 */
library StringsUpgradeable {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
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
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
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
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
    /**
    * @dev Returns the decimals.
    */
    function decimals() external view returns (uint256);

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
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMathUpgradeable {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

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

    function safePermit(
        IERC20PermitUpgradeable token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface IPancakeRouter01 {
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

interface IPancakeRouter02 is IPancakeRouter01 {
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

library Math {
    function min(uint x, uint y) internal pure returns (uint z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

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

interface IInviteContract {
    function getInviter(address user) external view returns(address);
    function getInvitees(address user) external view returns(address[] memory);
}

contract FarmContract1213V1 is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    using SafeMathUpgradeable for uint256;
    using SafeERC20Upgradeable for IERC20Upgradeable;

    struct DepositInfo {
        uint256 pid;
        IERC20Upgradeable lpToken; 
        address pledgee;
        uint256 amount;
        uint256 miningRewardDebt;
        uint256 dividendRewardDebt;
        uint256 depositBlock;
        uint256 depositTime;
        bool onGoing;
    }

    struct PoolInfo {
        IERC20Upgradeable lpToken; 
        uint256 miningTokenPerBlock;
        uint256 dividendTokenPerBlock;
        uint256 accMiningTokenPerShare; 
        uint256 accDividendTokenPerShare;
        uint256 lastUpdateBlock;
    }

    IERC20Upgradeable public miningToken;
    IERC20Upgradeable public dividendToken;
    IERC20Upgradeable public refferalRewardToken;
    IERC20Upgradeable public nodeRewardToken;
    address public inviteContract;
    address public Router;
    address public usdt;
    uint256 public lockupTime;
    uint256 public redemptionGracePeriod;
    uint256 public oneStarUserpledgeThreshold;
    uint256 public twoStarUserpledgeThreshold;
    uint256 public threeStarUserpledgeThreshold;
    uint256 public referralRewardRate;
    uint256 public nodeRewardRate;
    uint256 public rateDenominator;
    bool public emergencyWithdrawSwitch;
    bool public enableContract;
    uint256 public amount1;
    uint256 public amount2;

    PoolInfo[] public poolInfo;
    mapping(uint256 => mapping(address => DepositInfo[])) public userDepositInfo;
    mapping(uint256 => mapping(uint256 => uint256)) public currentAccMiningTokenPerShare;
    mapping(uint256 => mapping(uint256 => uint256)) public currentAccDividendTokenPerShare;
    mapping(uint256 => mapping(address => uint256)) public depositAmount;
    mapping(uint256 => mapping(address => uint256)) public mintAmount;
    mapping(uint256 => mapping(address => uint256)) public dividendAmount;
    mapping(uint256 => mapping(address => mapping(address =>uint256))) public userCalculatedReferralRewards;
    mapping(uint256 => mapping(address => mapping(address =>uint256))) public userCalculatedNodeRewards;
    mapping(uint256 => mapping(address => uint256)) public userAvailableNodeReward;
    mapping(uint256 => mapping(address => uint256)) public userClaimedNodeReward;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Claim(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user,uint256 indexed pid, uint256 amount);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    modifier validatePid(uint256 _pid) {
        require (_pid < poolInfo.length , "Pool does not exist") ;
        _;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    function initialize(address _miningTokenContract, address _dividendTokenContract, address _inviteContract) initializer public {
        __Ownable_init();
        __UUPSUpgradeable_init();
        setMiningTokenContract(_miningTokenContract);
        setDividendTokenContract(_dividendTokenContract);
        setEnableContract(false);
        setLockupTime(86400);
        setRedemptionGracePeriod(43200);
        setOneStarUserPledgeThreshold(1 * 10 ** 18); 
        setTwoStarUserPledgeThreshold(2 * 10 ** 18);
        setThreeStarUserPledgeThreshold(3 * 10 ** 18);
        setUSDTContract(_dividendTokenContract);
        setRefferalRewardTokenContract(_miningTokenContract);
        setNodeRewardTokenContract(_miningTokenContract);
        setInviteContract(_inviteContract);
        setReferralRewardRate(10);
        setNodeRewardRate(5);
        setRateDenominator(100);
        setPancakeRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}

    function addPool(IERC20Upgradeable _lpToken, uint256 _miningTokenPerBlock, uint256 _dividendTokenPerBlock) public onlyOwner {
        poolInfo.push(PoolInfo({
            lpToken: _lpToken,
            miningTokenPerBlock: _miningTokenPerBlock,
            dividendTokenPerBlock: _dividendTokenPerBlock,
            accMiningTokenPerShare: 0,
            accDividendTokenPerShare: 0,
            lastUpdateBlock: block.number
        }));
    }

    function setMiningReward(uint256 _pid, uint256 _miningTokenPerBlock) public validatePid(_pid) onlyOwner {
        updatePool(_pid);
        poolInfo[_pid].miningTokenPerBlock = _miningTokenPerBlock;
    }

    function setDividendReward(uint256 _pid, uint256 _dividendTokenPerBlock) public validatePid(_pid) onlyOwner {
        updatePool(_pid);
        poolInfo[_pid].dividendTokenPerBlock = _dividendTokenPerBlock;
    }

    function getBlockInterval(uint256 _from, uint256 _to) internal pure returns (uint256) {
		return _to.sub(_from);
    }

    function pendingMiningReward(uint256 _pid, address _user) public view validatePid(_pid) returns (uint256 totalMiningPending) {
        uint256 accMiningTokenPerShare = poolInfo[_pid].accMiningTokenPerShare;
        uint256 lpSupply = poolInfo[_pid].lpToken.balanceOf(address(this));
        if (block.number > poolInfo[_pid].lastUpdateBlock && lpSupply != 0) {
            uint256 blockInterval = getBlockInterval(poolInfo[_pid].lastUpdateBlock, block.number);
            uint256 miningReward = blockInterval.mul(poolInfo[_pid].miningTokenPerBlock);
            accMiningTokenPerShare = accMiningTokenPerShare.add(miningReward.mul(1e12).div(lpSupply));
        }
        for(uint256 i = 0; i < userDepositInfo[_pid][_user].length; i++) {
            if(userDepositInfo[_pid][_user][i].onGoing) {
                uint256 amount = userDepositInfo[_pid][_user][i].amount;
                uint256 recordAccMiningTokenPerShare = currentAccMiningTokenPerShare[_pid][userDepositInfo[_pid][_user][i].depositBlock];
                uint256 actualAccMiningTokenPerShare = accMiningTokenPerShare.sub(recordAccMiningTokenPerShare);
                uint256 pendingReward = amount.mul(actualAccMiningTokenPerShare).div(1e12).sub(userDepositInfo[_pid][_user][i].miningRewardDebt);
                totalMiningPending = totalMiningPending.add(pendingReward);
            }
        }
    }

    function pendingDividendReward(uint256 _pid, address _user) public view validatePid(_pid) returns (uint256 totalDividendPending) {
        uint256 accDividendTokenPerShare = poolInfo[_pid].accDividendTokenPerShare;
        uint256 lpSupply = poolInfo[_pid].lpToken.balanceOf(address(this));
        if (block.number > poolInfo[_pid].lastUpdateBlock && lpSupply != 0) {
            uint256 blockInterval = getBlockInterval(poolInfo[_pid].lastUpdateBlock, block.number);
            uint256 dividendReward = blockInterval.mul(poolInfo[_pid].dividendTokenPerBlock);
            accDividendTokenPerShare = accDividendTokenPerShare.add(dividendReward.mul(1e12).div(lpSupply));
        }
        for(uint256 i = 0; i < userDepositInfo[_pid][_user].length; i++) {
            if(userDepositInfo[_pid][_user][i].onGoing) {
                uint256 amount = userDepositInfo[_pid][_user][i].amount;
                uint256 recordAccDividendTokenPerShare = currentAccDividendTokenPerShare[_pid][userDepositInfo[_pid][_user][i].depositBlock];
                uint256 actualAccDividendTokenPerShare = accDividendTokenPerShare.sub(recordAccDividendTokenPerShare);
                uint256 pendingReward = amount.mul(actualAccDividendTokenPerShare).div(1e12).sub(userDepositInfo[_pid][_user][i].dividendRewardDebt);
                totalDividendPending = totalDividendPending.add(pendingReward);
            }
        }
    }

    function claimPendingMiningReward(uint256 _pid) internal returns (uint256 totalMiningPending) {
        for(uint256 i = 0; i < userDepositInfo[_pid][_msgSender()].length; i++) {
            if(userDepositInfo[_pid][_msgSender()][i].onGoing) {
                uint256 amount = userDepositInfo[_pid][_msgSender()][i].amount;
                uint256 recordAccMiningTokenPerShare = currentAccMiningTokenPerShare[_pid][userDepositInfo[_pid][_msgSender()][i].depositBlock];
                uint256 actualAccMiningTokenPerShare = poolInfo[_pid].accMiningTokenPerShare.sub(recordAccMiningTokenPerShare);
                uint256 pendingReward = amount.mul(actualAccMiningTokenPerShare).div(1e12).sub(userDepositInfo[_pid][_msgSender()][i].miningRewardDebt);
                userDepositInfo[_pid][_msgSender()][i].miningRewardDebt = userDepositInfo[_pid][_msgSender()][i].miningRewardDebt.add(pendingReward);
                totalMiningPending = totalMiningPending.add(pendingReward);
            }
        }
    }

    function claimPendingDividendReward(uint256 _pid) internal returns (uint256 totalDividendPending) {
        for(uint256 i = 0; i < userDepositInfo[_pid][_msgSender()].length; i++) {
            if(userDepositInfo[_pid][_msgSender()][i].onGoing) {
                uint256 amount = userDepositInfo[_pid][_msgSender()][i].amount;
                uint256 recordAccDividendTokenPerShare = currentAccDividendTokenPerShare[_pid][userDepositInfo[_pid][_msgSender()][i].depositBlock];
                uint256 actualAccDividendTokenPerShare = poolInfo[_pid].accDividendTokenPerShare.sub(recordAccDividendTokenPerShare);
                uint256 pendingReward = amount.mul(actualAccDividendTokenPerShare).div(1e12).sub(userDepositInfo[_pid][_msgSender()][i].dividendRewardDebt);
                userDepositInfo[_pid][_msgSender()][i].dividendRewardDebt = userDepositInfo[_pid][_msgSender()][i].dividendRewardDebt.add(pendingReward);
                totalDividendPending = totalDividendPending.add(pendingReward);
            }
        }
    }

    function pendingReferralReward(uint256 _pid, address _user) public view validatePid(_pid) returns(uint256 deservedReferralReward) {
        address[] memory InviteeAddress = IInviteContract(inviteContract).getInvitees(_user);
        for (uint256 i = 0; i < InviteeAddress.length; i++) {
            uint256 mintedAmount = pendingMiningReward(_pid, InviteeAddress[i]).add(mintAmount[_pid][InviteeAddress[i]]).sub(userCalculatedReferralRewards[_pid][InviteeAddress[i]][_user]);
            deservedReferralReward = deservedReferralReward.add(mintedAmount);
        }
    }

    function pendingNodeReward(uint256 _pid, address _user) public view validatePid(_pid) returns(uint256 deservedNodeReward) {
        address[] memory InviteeAddress = IInviteContract(inviteContract).getInvitees(_user);
        for (uint256 i = 0; i < InviteeAddress.length; i++) {
            if(getLevel(_pid, InviteeAddress[i]) < getLevel(_pid, _user)) {
                uint256 mintedAmount = pendingMiningReward(_pid, InviteeAddress[i]).add(mintAmount[_pid][InviteeAddress[i]]).sub(userCalculatedNodeRewards[_pid][InviteeAddress[i]][_user]);
                deservedNodeReward = deservedNodeReward.add(mintedAmount);
            }
        }
    }

    function getAllPendingReferralReward(address _user) public view returns(uint256 totalReferralBonus){
        for (uint256 i = 0; i < poolInfo.length; i++) {
                uint256 pendingReward = pendingReferralReward(i,_user);
                uint256 referralBonus = pendingReward.mul(getRefferalRewardPercent(i, _user)).div(rateDenominator);
                totalReferralBonus = totalReferralBonus.add(referralBonus);
        }
    }

    function getAllPendingNodeReward(address _user) public view returns(uint256 totalNodeBonus){
        for (uint256 i = 0; i < poolInfo.length; i++) {
            uint256 pendingReward = pendingNodeReward(i, _user);
            uint256 pendingNodeBonus = userAvailableNodeReward[i][_user].sub(userClaimedNodeReward[i][_user]);
            uint256 nodeBonus = pendingReward.mul(getNodeRewardPercent(i, _user)).div(rateDenominator).add(pendingNodeBonus);
            totalNodeBonus = totalNodeBonus.add(nodeBonus);
        }
    }

    function claimRefferalReward(uint256 _pid) internal returns(uint256 pendingReward) {
        address[] memory InviteeAddress = IInviteContract(inviteContract).getInvitees(_msgSender());
        for (uint256 i = 0; i < InviteeAddress.length; i++) {
            uint256 mintedAmount = pendingMiningReward(_pid, InviteeAddress[i]).add(mintAmount[_pid][InviteeAddress[i]]).sub(userCalculatedReferralRewards[_pid][InviteeAddress[i]][_msgSender()]);
            userCalculatedReferralRewards[_pid][InviteeAddress[i]][_msgSender()] = userCalculatedReferralRewards[_pid][InviteeAddress[i]][_msgSender()].add(mintedAmount);
            pendingReward = pendingReward.add(mintedAmount);
        }
    }

    function claimAllReferralReward() public {
        uint256 totalPendingRefferalReward = getAllPendingReferralReward(_msgSender());
        require(totalPendingRefferalReward > 0, "You have no referral rewards to claim");
        bool canClaimRegfferalReward = IERC20Upgradeable(refferalRewardToken).balanceOf(address(this)) >= totalPendingRefferalReward;
        require(canClaimRegfferalReward, "The refferal reward token balance of this contract is insufficient");
        for (uint256 i = 0; i < poolInfo.length; i++) {
            claimRefferalReward(i);
        }
        safeTokenTransfer(miningToken, _msgSender(), totalPendingRefferalReward);
    }

    function claimNodeReward(uint256 _pid) internal returns(uint256 pendingReward) {
        address[] memory InviteeAddress = IInviteContract(inviteContract).getInvitees(_msgSender());
        for (uint256 i = 0; i < InviteeAddress.length; i++) {
            if(getLevel(_pid, InviteeAddress[i]) < getLevel(_pid, _msgSender())) {
                uint256 mintedAmount = pendingMiningReward(_pid, InviteeAddress[i]).add(mintAmount[_pid][InviteeAddress[i]]).sub(userCalculatedNodeRewards[_pid][InviteeAddress[i]][_msgSender()]);
                userCalculatedNodeRewards[_pid][InviteeAddress[i]][_msgSender()] = userCalculatedNodeRewards[_pid][InviteeAddress[i]][_msgSender()].add(mintedAmount);
                pendingReward = pendingReward.add(mintedAmount);
            }
        }
        pendingReward = pendingReward.mul(getNodeRewardPercent(_pid, _msgSender())).div(rateDenominator); 
        uint256 pendingNodeBonus = userAvailableNodeReward[_pid][_msgSender()].sub(userClaimedNodeReward[_pid][_msgSender()]);
        userClaimedNodeReward[_pid][_msgSender()] = userClaimedNodeReward[_pid][_msgSender()].add(pendingNodeBonus);
        pendingReward = pendingReward.add(pendingNodeBonus);
    }

    function claimAllNodeReward() public {
        uint256 totalPendingNodeReward = getAllPendingNodeReward(_msgSender());
        require(totalPendingNodeReward > 0, "You have no node rewards to claim");
        bool canClaimNodeReward = IERC20Upgradeable(refferalRewardToken).balanceOf(address(this)) >= totalPendingNodeReward;
        require(canClaimNodeReward, "The node reward token balance of this contract is insufficient");
        uint256 pending2;
        for (uint256 i = 0; i < poolInfo.length; i++) {
            uint256 pending1 = claimNodeReward(i);
            pending2 = pending2.add(pending1);
        }
        amount1 = totalPendingNodeReward;
        safeTokenTransfer(miningToken, _msgSender(), pending2);
    }

    function distributeNodeReward(uint256 pid) internal {
        address myFristInviter = IInviteContract(inviteContract).getInviter(_msgSender());
        address mySecondInviter = IInviteContract(inviteContract).getInviter(myFristInviter);        
        uint256 calculatedNodeReward1 = pendingMiningReward(pid, _msgSender()).add(mintAmount[pid][_msgSender()]).sub(userCalculatedNodeRewards[pid][_msgSender()][myFristInviter]);
        uint256 calculatedNodeReward2 = pendingMiningReward(pid, _msgSender()).add(mintAmount[pid][_msgSender()]).sub(userCalculatedNodeRewards[pid][_msgSender()][mySecondInviter]);
        uint256 availableNodeReward1 = calculatedNodeReward1.mul(getNodeRewardPercent(pid, myFristInviter)).div(rateDenominator);
        uint256 availableNodeReward2 = calculatedNodeReward2.mul(getNodeRewardPercent(pid, mySecondInviter)).div(rateDenominator);
        userCalculatedNodeRewards[pid][_msgSender()][myFristInviter] = userCalculatedNodeRewards[pid][_msgSender()][myFristInviter].add(calculatedNodeReward1);
        userCalculatedNodeRewards[pid][_msgSender()][mySecondInviter] = userCalculatedNodeRewards[pid][_msgSender()][mySecondInviter].add(calculatedNodeReward2);
        userAvailableNodeReward[pid][myFristInviter] = userAvailableNodeReward[pid][myFristInviter].add(availableNodeReward1);
        userAvailableNodeReward[pid][myFristInviter] = userAvailableNodeReward[pid][myFristInviter].add(availableNodeReward2);
    }

    function updatePool(uint256 _pid) public validatePid(_pid) {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastUpdateBlock) {
            return;
        }
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (lpSupply == 0) {
            pool.lastUpdateBlock = block.number;
            currentAccMiningTokenPerShare[_pid][pool.lastUpdateBlock] = pool.accMiningTokenPerShare;
            currentAccDividendTokenPerShare[_pid][pool.lastUpdateBlock] = pool.accDividendTokenPerShare;
            return;
        }
        uint256 blockInterval = getBlockInterval(pool.lastUpdateBlock, block.number);
        uint256 miningReward = blockInterval.mul(pool.miningTokenPerBlock);
        uint256 dividendReward = blockInterval.mul(pool.dividendTokenPerBlock);
        pool.accMiningTokenPerShare = pool.accMiningTokenPerShare.add(miningReward.mul(1e12).div(lpSupply));
        pool.accDividendTokenPerShare = pool.accDividendTokenPerShare.add(dividendReward.mul(1e12).div(lpSupply));
        pool.lastUpdateBlock = block.number;
        currentAccMiningTokenPerShare[_pid][pool.lastUpdateBlock] = pool.accMiningTokenPerShare;
        currentAccDividendTokenPerShare[_pid][pool.lastUpdateBlock] = pool.accDividendTokenPerShare;
    }

    function canWithdrawOrNot(uint256 startTimestamp) public view returns(bool canWithdraw) {
        if(block.timestamp >= getCurrentRedemptionStartTime(startTimestamp) && block.timestamp <= getCurrentRedemptionEndTime(startTimestamp)) {
            return true;
        }
    }

    function getTotalRedeemableLPAmount(uint256 _pid, address user) public view validatePid(_pid) returns(uint256 totalRedeemableLPAmount) {
        for (uint256 i = 0; i < userDepositInfo[_pid][user].length; i++) {
            if(canWithdrawOrNot(userDepositInfo[_pid][user][i].depositTime) && userDepositInfo[_pid][user][i].onGoing) {
                uint256 redeemableLPAmount = userDepositInfo[_pid][user][i].amount;
                totalRedeemableLPAmount = totalRedeemableLPAmount.add(redeemableLPAmount);
            }   
        }
    }

    function getRequiredLP(uint256 pid, uint256 amount) public view returns(uint256) {
        address pair = address(poolInfo[pid].lpToken);
        (uint112 _reserve0, uint112 _reserve1, ) = IPancakePair(pair).getReserves();
        uint256 amountIn = IPancakeRouter02(Router).getAmountIn(amount, _reserve0, _reserve1);
        return Math.sqrt(amount.mul(amountIn));
    }

    function getLevel(uint256 pid, address user) public view returns(uint256) {
        if(depositAmount[pid][user] >= getRequiredLP(pid, threeStarUserpledgeThreshold)) {
            return 3;
        } else if(depositAmount[pid][user] >= getRequiredLP(pid, twoStarUserpledgeThreshold)) {
            return 2;
        } else if(depositAmount[pid][user] >= getRequiredLP(pid, oneStarUserpledgeThreshold)) {
            return 1;
        } else {
            return 0;
        } 
    }

    function getRefferalRewardPercent(uint256 pid, address user) public view returns(uint256) {
        if(getLevel(pid, user) == 3) {
            return referralRewardRate;
        } else if(getLevel(pid, user) == 2) {
            return referralRewardRate;
        } else if(getLevel(pid, user) == 1) {
            return referralRewardRate;
        } else {
            return 0;
        }
    }

    function getNodeRewardPercent(uint256 pid, address user) public view returns(uint256) {
        if(getLevel(pid, user) == 3) {
            return nodeRewardRate;
        } else if(getLevel(pid, user) == 2) {
            return nodeRewardRate;
        } else {
            return 0;
        }
    }

    function deposit(uint256 _pid, uint256 _amount) public validatePid(_pid) {
        require(enableContract == true,"The contract has not started");
        require(IInviteContract(inviteContract).getInviter(_msgSender()) != address(0), "You are not bound to an inviter");
        require(_amount > 0, "Please enter a quantity greater than 0");
        require(poolInfo[_pid].lpToken.balanceOf(_msgSender()) >= _amount, "The amount of LP you want to pledge cannot exceed your balance");
        updatePool(_pid);
        distributeNodeReward(_pid);
        poolInfo[_pid].lpToken.safeTransferFrom(_msgSender(), address(this), _amount);
        userDepositInfo[_pid][_msgSender()].push(DepositInfo({
            pid: _pid,
            lpToken: poolInfo[_pid].lpToken,
            pledgee: _msgSender(),
            amount: _amount,
            miningRewardDebt: 0,
            dividendRewardDebt: 0,
            depositBlock: block.number,
            depositTime: block.timestamp,
            onGoing: true
        }));
        depositAmount[_pid][_msgSender()] = depositAmount[_pid][_msgSender()].add(_amount);
        emit Deposit(_msgSender(), _pid, _amount);
    }

    function claim(uint256 _pid) public validatePid(_pid) {
        require(enableContract == true,"The contract has not started");
        require(depositAmount[_pid][_msgSender()] > 0,"The amount you stake in this pool is 0");
        require(pendingMiningReward(_pid, _msgSender()) > 0, "You have no mining reward tokens to claim");
        require(pendingDividendReward(_pid, _msgSender()) > 0, "You have no dividend reward tokens to claim");
        bool canClaimMiningReward = IERC20Upgradeable(miningToken).balanceOf(address(this)) >= pendingMiningReward(_pid, _msgSender());
        bool canClaimDividendReward = IERC20Upgradeable(dividendToken).balanceOf(address(this)) >= pendingDividendReward(_pid, _msgSender());
        require(canClaimMiningReward, "The mining reward token balance of this contract is insufficient"); 
        require(canClaimDividendReward, "The dividend reward token balance of this contract is insufficient"); 
        updatePool(_pid);
        uint256 deservedMiningReward = claimPendingMiningReward(_pid);
        mintAmount[_pid][_msgSender()] = mintAmount[_pid][_msgSender()].add(deservedMiningReward);
        safeTokenTransfer(miningToken, _msgSender(), deservedMiningReward);
        emit Claim(_msgSender(), _pid, deservedMiningReward);
        uint256 deservedDividendReward = claimPendingDividendReward(_pid);
        dividendAmount[_pid][_msgSender()] = dividendAmount[_pid][_msgSender()].add(deservedDividendReward);
        safeTokenTransfer(dividendToken, _msgSender(), deservedDividendReward);
        emit Claim(_msgSender(), _pid, deservedDividendReward);
    }

    function withdraw(uint256 _pid) public validatePid(_pid)  {
        require(enableContract == true,"The contract has not started");
        require(depositAmount[_pid][_msgSender()] > 0,"The amount you stake in this pool is 0");
        require(getTotalRedeemableLPAmount(_pid, _msgSender()) > 0, "Your redeemable LP quantity is 0");
        require(pendingMiningReward(_pid, _msgSender()) > 0, "You have no mining reward tokens to claim");
        require(pendingDividendReward(_pid, _msgSender()) > 0, "You have no dividend reward tokens to claim");
        bool canClaimMiningReward = IERC20Upgradeable(miningToken).balanceOf(address(this)) >= pendingMiningReward(_pid, _msgSender());
        bool canClaimDividendReward = IERC20Upgradeable(dividendToken).balanceOf(address(this)) >= pendingDividendReward(_pid, _msgSender());
        require(canClaimMiningReward, "The mining reward token balance of this contract is insufficient"); 
        require(canClaimDividendReward, "The dividend reward token balance of this contract is insufficient"); 
        uint256 deservedMiningReward = claimPendingMiningReward(_pid);
        mintAmount[_pid][_msgSender()] = mintAmount[_pid][_msgSender()].add(deservedMiningReward);
        safeTokenTransfer(miningToken, _msgSender(), deservedMiningReward);
        uint256 deservedDividendReward = claimPendingDividendReward(_pid);
        dividendAmount[_pid][_msgSender()] = dividendAmount[_pid][_msgSender()].add(deservedDividendReward);
        safeTokenTransfer(dividendToken, _msgSender(), deservedDividendReward);
        distributeNodeReward(_pid);
        poolInfo[_pid].lpToken.safeTransfer(_msgSender(), getTotalRedeemableLPAmount(_pid, _msgSender()));
        emit Withdraw(_msgSender(), _pid, getTotalRedeemableLPAmount(_pid, _msgSender()));
        depositAmount[_pid][_msgSender()] = depositAmount[_pid][_msgSender()].sub(getTotalRedeemableLPAmount(_pid, _msgSender()));
        closeAllRedeemedDepositInfo(_pid);
    }

    function emergencyWithdraw(uint256 _pid) public validatePid(_pid) {
        require(enableContract == true,"The contract has not started");
        require(emergencyWithdrawSwitch == true,"Management does not turn on the emergency withdrawal option");
        require(depositAmount[_pid][_msgSender()] > 0,"The amount you stake in this pool is 0");
        distributeNodeReward(_pid);
        poolInfo[_pid].lpToken.safeTransfer(_msgSender(), depositAmount[_pid][_msgSender()]);
        emit EmergencyWithdraw(_msgSender(), _pid, depositAmount[_pid][_msgSender()]);
        depositAmount[_pid][_msgSender()] = 0;
        closeAllOngoingDepositInfo(_pid);
    }

    function closeAllRedeemedDepositInfo(uint256 _pid) internal {
        for(uint256 i = 0; i < userDepositInfo[_pid][_msgSender()].length; i++) {
            if(canWithdrawOrNot(userDepositInfo[_pid][_msgSender()][i].depositTime) && userDepositInfo[_pid][_msgSender()][i].onGoing) {
                userDepositInfo[_pid][_msgSender()][i].onGoing = false;
            }
        }
    }

    function closeAllOngoingDepositInfo(uint256 _pid) internal {
        for(uint256 i = 0; i < userDepositInfo[_pid][_msgSender()].length; i++) {
            if(userDepositInfo[_pid][_msgSender()][i].onGoing) {
                userDepositInfo[_pid][_msgSender()][i].onGoing = false;
            }
        }
    }

    function safeTokenTransfer(IERC20Upgradeable token, address to, uint256 amount) internal {
        uint256 tokenBalance = IERC20Upgradeable(token).balanceOf(address(this));
        if (amount > tokenBalance) {
            IERC20Upgradeable(token).transfer(to, tokenBalance);
        } else {
            IERC20Upgradeable(token).transfer(to, amount);
        }
    }

    function retrieveMiningToken() public onlyOwner {
        uint256 rewardTokenBalance = IERC20Upgradeable(miningToken).balanceOf(address(this));
        safeTokenTransfer(miningToken, _msgSender(), rewardTokenBalance);
    }

    function retrieveDividendToken() public onlyOwner {
        uint256 rewardTokenBalance = IERC20Upgradeable(dividendToken).balanceOf(address(this));
        safeTokenTransfer(dividendToken, _msgSender(), rewardTokenBalance);
    }

    function getCurrentRound(uint256 startTimestamp) public view returns(uint256) {
        return (block.timestamp.sub(startTimestamp)).div(lockupTime).add(1);
    }

    function getCurrentRedemptionStartTime(uint256 startTimestamp) public view returns(uint256) {
        if(getCurrentRound(startTimestamp) == 1) {
            return startTimestamp.add(lockupTime);
        } else {
            uint256 lastRound = getCurrentRound(startTimestamp).sub(1);
            return startTimestamp.add(lastRound.mul(lockupTime));
        }
    }

    function getCurrentRedemptionEndTime(uint256 startTimestamp) public view returns(uint256) {
        if(getCurrentRound(startTimestamp) == 1) {
            return startTimestamp.add(lockupTime).add(redemptionGracePeriod);
        } else {
            uint256 lastRound = getCurrentRound(startTimestamp).sub(1);
            return startTimestamp.add(lastRound.mul(lockupTime)).add(redemptionGracePeriod);
        }
    }

    function getUserAllDepositInfo(uint256 pid, address addr) public view validatePid(pid) returns (DepositInfo[] memory) {
        return userDepositInfo[pid][addr];
    }

    function setMiningTokenContract(address _token) public onlyOwner {
        miningToken = IERC20Upgradeable(_token);
    }

    function setDividendTokenContract(address _token) public onlyOwner {
        dividendToken = IERC20Upgradeable(_token);
    }

    function setLockupTime(uint256 _lockupTime) public onlyOwner {
        lockupTime = _lockupTime;
    }

    function setRedemptionGracePeriod(uint256 _redemptionGracePeriod) public onlyOwner {
        redemptionGracePeriod = _redemptionGracePeriod;
    }

    function setEnableContract(bool _value) public onlyOwner {
        enableContract = _value;
    }

    function setEmergencyWithdrawSwitch(bool _value) public onlyOwner {
        emergencyWithdrawSwitch = _value;
    }

    function setOneStarUserPledgeThreshold(uint256 _pledgeThreshold) public onlyOwner {
        oneStarUserpledgeThreshold = _pledgeThreshold;
    }

    function setTwoStarUserPledgeThreshold(uint256 _pledgeThreshold) public onlyOwner {
        twoStarUserpledgeThreshold = _pledgeThreshold;
    }

    function setThreeStarUserPledgeThreshold(uint256 _pledgeThreshold) public onlyOwner {
        threeStarUserpledgeThreshold = _pledgeThreshold;
    }

    function setUSDTContract(address _usdtContract) public onlyOwner {
        usdt = _usdtContract;
    }

    function setNodeRewardTokenContract(address _rewardToken) public onlyOwner {
        nodeRewardToken = IERC20Upgradeable(_rewardToken);
    }

    function setRefferalRewardTokenContract(address _rewardToken) public onlyOwner {
        refferalRewardToken = IERC20Upgradeable(_rewardToken);
    }
            
    function setInviteContract(address _inviteContract) public onlyOwner {
        inviteContract = _inviteContract;
    }

    function setReferralRewardRate(uint256 _referralRewardRate) public onlyOwner {
        referralRewardRate = _referralRewardRate;
    }

    function setNodeRewardRate(uint256 _nodeRewardRate) public onlyOwner {
        nodeRewardRate = _nodeRewardRate;
    }

    function setRateDenominator(uint256 _rateDenominator) public onlyOwner {
        rateDenominator = _rateDenominator;
    }

    function setPancakeRouter(address router) public onlyOwner {
        Router = router;
    }
}