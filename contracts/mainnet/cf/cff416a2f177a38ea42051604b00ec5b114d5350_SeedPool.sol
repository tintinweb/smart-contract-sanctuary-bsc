/**
 *Submitted for verification at BscScan.com on 2022-09-20
*/

// Sources flattened with hardhat v2.9.3 https://hardhat.org

// File @openzeppelin/contracts-upgradeable/utils/[email protected]

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


// File @openzeppelin/contracts-upgradeable/proxy/utils/[email protected]

// License: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

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


// File @openzeppelin/contracts-upgradeable/interfaces/[email protected]

// License: MIT
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


// File @openzeppelin/contracts-upgradeable/proxy/beacon/[email protected]

// License: MIT
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


// File @openzeppelin/contracts-upgradeable/utils/[email protected]

// License: MIT
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


// File @openzeppelin/contracts-upgradeable/proxy/ERC1967/[email protected]

// License: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/ERC1967/ERC1967Upgrade.sol)

pragma solidity ^0.8.2;





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


// File @openzeppelin/contracts-upgradeable/proxy/utils/[email protected]

// License: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/UUPSUpgradeable.sol)

pragma solidity ^0.8.0;



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


// File @openzeppelin/contracts-upgradeable/utils/math/[email protected]

// License: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

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
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
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


// File @openzeppelin/contracts-upgradeable/utils/[email protected]

// License: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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


// File @openzeppelin/contracts-upgradeable/access/[email protected]

// License: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;


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


// File @openzeppelin/contracts-upgradeable/token/ERC721/[email protected]

// License: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721ReceiverUpgradeable {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}


// File contracts/interfaces/IERC20Receiver.sol

// License: MIT
pragma solidity 0.8.11;

/**
 * @title ERC20 token receiver interface
 *
 * @dev Interface for any contract that wants to support safe transfers
 *      from ERC20 token smart contracts.
 * @dev Inspired by ERC721 and ERC223 token standards
 *
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 * @dev See https://github.com/ethereum/EIPs/issues/223
 * @author Basil Gorin
 * Adapted for Syn City by Superpower Labs
 */
interface IERC20Receiver {
  /**
   * @notice Handle the receipt of a ERC20 token(s)
   * @dev The ERC20 smart contract calls this function on the recipient
   *      after a successful transfer (`safeTransferFrom`).
   *      This function MAY throw to revert and reject the transfer.
   *      Return of other than the magic value MUST result in the transaction being reverted.
   * @notice The contract address is always the message sender.
   *      A wallet/broker/auction application MUST implement the wallet interface
   *      if it will accept safe transfers.
   * @param _operator The address which called `safeTransferFrom` function
   * @param _from The address which previously owned the token
   * @param _value amount of tokens which is being transferred
   * @param _data additional data with no specified format
   * @return `bytes4(keccak256("onERC20Received(address,address,uint256,bytes)"))` unless throwing
   */
  function onERC20Received(
    address _operator,
    address _from,
    uint256 _value,
    bytes calldata _data
  ) external returns (bytes4);
}


// File contracts/token/TokenReceiver.sol

// License: MIT
pragma solidity 0.8.11;


//import "hardhat/console.sol";

contract TokenReceiver is IERC20Receiver, IERC721ReceiverUpgradeable {
  function onERC20Received(
    address,
    address,
    uint256,
    bytes calldata
  ) external pure override returns (bytes4) {
    return this.onERC20Received.selector;
  }

  function onERC721Received(
    address,
    address,
    uint256,
    bytes calldata
  ) public pure override returns (bytes4) {
    return this.onERC721Received.selector;
  }
}


// File contracts/utils/Constants.sol

// License: MIT
pragma solidity 0.8.11;

// Author: Francesco Sullo <[email protected]>
// (c) 2022+ SuperPower Labs Inc.

contract Constants {
  uint8 public constant S_SYNR_SWAP = 1;
  uint8 public constant SYNR_STAKE = 2;
  uint8 public constant SYNR_PASS_STAKE_FOR_BOOST = 3;
  uint8 public constant SYNR_PASS_STAKE_FOR_SEEDS = 4;
  uint8 public constant BLUEPRINT_STAKE_FOR_BOOST = 5;
  uint8 public constant BLUEPRINT_STAKE_FOR_SEEDS = 6;

  uint256[50] private __gap;
}


// File contracts/interfaces/ISideUser.sol

// License: MIT
pragma solidity 0.8.11;

interface ISideUser {
  event DepositSaved(address indexed user, uint16 indexed mainIndex);

  event DepositUnlocked(address indexed user, uint16 indexed mainIndex);

  struct Deposit {
    // @dev token type (0: sSYNR, 1: SYNR, 2: SYNR Pass)
    uint8 tokenType;
    // @dev locking period - from
    uint32 lockedFrom;
    // @dev locking period - until
    uint32 lockedUntil;
    // @dev token amount staked
    // SYNR maxTokenSupply is 10 billion * 18 decimals = 1e28
    // which is less type(uint96).max (~79e28)
    uint96 stakedAmount;
    // @dev tokenID if NFT
    uint16 tokenID;
    // @dev when the deposit is unlocked
    uint32 unlockedAt;
    // @dev mainIndex Since the process is asyncronous, the same deposit can be at a different index
    // on the main net and on the sidechain. This guarantees alignment
    uint16 mainIndex;
    // @dev pool token amount staked
    uint128 generator; //
    // @dev rewards ratio when staked
    uint32 rewardsFactor;
    // for two words,
    // 136 extra bits available
    // filled with extra variables
    // for future compatible changes
    uint32 extra1;
    uint32 extra2;
    uint32 extra3;
    uint24 extra4;
  }

  /// @dev Data structure representing token holder using a pool
  struct User {
    // @dev Total passes staked
    uint16 passAmount;
    uint16 passAmountForBoost;
    // @dev Total blueprints staked
    uint16 blueprintAmount;
    uint16 blueprintAmountForBoost;
    // @dev Total staked SYNR
    uint96 stakedAmount;
    // @dev SEED generator:
    uint128 generator;
    // @dev when claimed rewards last time
    uint32 lastRewardsAt;
    Deposit[] deposits;
    // @dev reserved for future custom tokens
    mapping(uint8 => uint16) extraNftAmounts;
  }
}


// File @openzeppelin/contracts/utils/introspection/[email protected]

// License: MIT
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


// File @openzeppelin/contracts/token/ERC721/[email protected]

// License: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

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


// File contracts/interfaces/ISideConf.sol

// License: MIT
pragma solidity 0.8.11;

// Author: Francesco Sullo <[email protected]>
// (c) 2022+ SuperPower Labs Inc.

interface ISideConf {
  struct Conf {
    uint8 status;
    uint8 coolDownDays; // cool down period for
    uint16 maximumLockupTime;
    uint32 poolInitAt; // the moment that the pool start operating, i.e., when initPool is first launched
    uint32 rewardsFactor; // initial ratio, decaying every decayInterval of a decayFactor
    uint32 decayInterval; // ex. 7 * 24 * 3600, 7 days
    uint32 lastRatioUpdateAt;
    uint32 swapFactor;
    uint32 stakeFactor;
    uint16 decayFactor; // ex. 9850 >> decays of 1.5% every 7 days
    uint16 taxPoints; // ex 250 = 2.5%
  }

  struct ExtraConf {
    uint32 sPSynrEquivalent; // 100,000
    uint32 sPBoostFactor; // 12500 > 112.5% > +12.5% of boost
    uint32 sPBoostLimit;
    uint32 bPSynrEquivalent;
    uint32 bPBoostFactor;
    uint32 bPBoostLimit;
    uint32 priceRatio;
    uint16 blueprintAmount;
    uint16 extra;
  }

  struct ExtraNftConf {
    IERC721 token;
    uint16 boostFactor; // 12500 > 112.5% > +12.5% of boost
    uint32 boostLimit;
  }
}


// File contracts/interfaces/ISidePool.sol

// License: MIT
pragma solidity 0.8.11;

// Author: Francesco Sullo <[email protected]>
// (c) 2022+ SuperPower Labs Inc.


interface ISidePool is ISideUser, ISideConf {
  event OracleUpdated(address oracle);
  event ImplementationUpgraded(address newImplementation);

  event PoolInitiatedOrUpdated(
    uint32 rewardsFactor,
    uint32 decayInterval,
    uint16 decayFactor,
    uint32 swapFactor,
    uint32 stakeFactor,
    uint16 taxPoints,
    uint8 coolDownDays
  );

  event PriceRatioUpdated(uint32 priceRatio);
  event ExtraConfUpdated(
    uint32 sPSynrEquivalent,
    uint32 sPBoostFactor,
    uint32 sPBoostLimit,
    uint32 bPSynrEquivalent,
    uint32 bPBoostFactor,
    uint32 bPBoostLimit
  );
  event PoolPaused(bool isPaused);
  event BridgeSet(address bridge);
  event BridgeRemoved(address bridge);

  function initPool(
    uint32 rewardsFactor,
    uint32 decayInterval,
    uint16 decayFactor,
    uint32 swapFactor,
    uint32 stakeFactor,
    uint16 taxPoints,
    uint8 coolDownDays
  ) external;

  function updateConf(
    uint32 decayInterval,
    uint16 decayFactor,
    uint32 swapFactor,
    uint32 stakeFactor,
    uint16 taxPoints,
    uint8 coolDownDays
  ) external;

  function updatePriceRatio(uint32 priceRatio_) external;

  function updateOracle(address oracle_) external;

  function pausePool(bool paused) external;

  // Split configuration in two struct to avoid following error calling initPool
  // CompilerError: Stack too deep when compiling inline assembly:
  // Variable value0 is 1 slot(s) too deep inside the stack.
  function updateExtraConf(
    uint32 sPSynrEquivalent,
    uint32 sPBoostFactor,
    uint32 sPBoostLimit,
    uint32 bPSynrEquivalent,
    uint32 bPBoostFactor,
    uint32 bPBoostLimit
  ) external;

  function shouldUpdateRatio() external view returns (bool);

  function updateRatio() external;

  function collectRewards() external;

  function pendingRewards(address user) external view returns (uint256);

  function untaxedPendingRewards(address user, uint256 timestamp) external view returns (uint256);

  function getDepositByIndex(address user, uint256 index) external view returns (Deposit memory);

  function getDepositsLength(address user) external view returns (uint256);

  function getDepositIndexByMainIndex(address user, uint256 mainIndex) external view returns (uint256, bool);

  function withdrawTaxes(uint256 amount, address beneficiary) external;

  function stake(
    uint256 tokenType,
    uint256 lockupTime,
    uint256 tokenAmountOrID
  ) external;

  function unstake(Deposit memory deposit) external;
}


// File @openzeppelin/contracts-upgradeable/token/ERC20/[email protected]

// License: MIT
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


// File @openzeppelin/contracts-upgradeable/token/ERC20/extensions/[email protected]

// License: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

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


// File @openzeppelin/contracts-upgradeable/token/ERC20/[email protected]

// License: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;




/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable, IERC20MetadataUpgradeable {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    function __ERC20_init(string memory name_, string memory symbol_) internal onlyInitializing {
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[45] private __gap;
}


// File @openzeppelin/contracts-upgradeable/token/ERC20/extensions/[email protected]

// License: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/extensions/ERC20Burnable.sol)

pragma solidity ^0.8.0;



/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
abstract contract ERC20BurnableUpgradeable is Initializable, ContextUpgradeable, ERC20Upgradeable {
    function __ERC20Burnable_init() internal onlyInitializing {
    }

    function __ERC20Burnable_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `amount`.
     */
    function burnFrom(address account, uint256 amount) public virtual {
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}


// File contracts/utils/Versionable.sol

// License: MIT
pragma solidity 0.8.11;

// Author: Francesco Sullo <[email protected]>
// (c) 2022+ SuperPower Labs Inc.

contract Versionable {
  function version() external pure virtual returns (uint256) {
    return 1;
  }
}


// File contracts/token/SideToken.sol

// License: MIT
pragma solidity 0.8.11;







contract SideToken is Versionable, Initializable, OwnableUpgradeable, ERC20Upgradeable, ERC20BurnableUpgradeable {
  event ImplementationUpgraded(address newImplementation);
  using AddressUpgradeable for address;

  mapping(address => bool) public minters;

  modifier onlyMinter() {
    require(minters[_msgSender()], "SideToken: not a minter");
    _;
  }

  // solhint-disable-next-line
  function __SideToken_init(string memory name, string memory symbol) internal initializer {
    __ERC20_init(name, symbol);
    __Ownable_init();
  }

  function mint(address to, uint256 amount) public virtual onlyMinter {
    _mint(to, amount);
  }

  function setMinter(address minter, bool enabled) external virtual onlyOwner {
    require(minter.isContract(), "SideToken: minter is not a contract");
    minters[minter] = enabled;
  }

  uint256[50] private __gap;
}


// File contracts/interfaces/IERC721Minimal.sol

// License: MIT
pragma solidity 0.8.11;

// Author: Francesco Sullo <[email protected]>
// Superpower Labs / Syn City

interface IERC721Minimal {
  function safeTransferFrom(
    address to,
    address receiver,
    uint256 tokenId
  ) external;
}


// File contracts/interfaces/ISidePoolViews.sol

// License: MIT
pragma solidity 0.8.11;

// Author: Francesco Sullo <[email protected]>
// (c) 2022+ SuperPower Labs Inc.


interface ISidePoolViews is ISideUser, ISideConf {
  event ImplementationUpgraded(address newImplementation);

  /**
   * @param deposit The deposit
   * @return the time it will be locked
   */
  function getLockupTime(Deposit memory deposit) external view returns (uint256);

  /**
   * @param conf The pool configuration
   * @param deposit The deposit
   * @return the weighted yield
   */
  function yieldWeight(Conf memory conf, Deposit memory deposit) external pure returns (uint256);

  /**
   * @param conf The pool configuration
   * @param deposit The deposit for which calculate the rewards
   * @param timestamp Current time of the stake
   * @param lastRewardsAt Last time rewards were collected
   * @return the Amount of untaxed reward
   */
  function calculateUntaxedRewards(
    Conf memory conf,
    Deposit memory deposit,
    uint256 timestamp,
    uint256 lastRewardsAt
  ) external view returns (uint256);

  /**
   * @notice Calculates the tax for claiming reward
   * @param rewards The rewards of the stake
   */
  function calculateTaxOnRewards(Conf memory conf, uint256 rewards) external view returns (uint256);

  function boostRewards(
    ExtraConf memory extraConf,
    uint256 rewards,
    uint256 stakedAmount,
    uint256 passAmountForBoost,
    uint256 blueprintAmountForBoost
  ) external pure returns (uint256);

  /**
   * @notice gets Percentage Vested at a certain timestamp
   * @param when timestamp where percentage will be calculated
   * @param lockedFrom timestamp when locked
   * @param lockedUntil timestamp when can unstake without penalty on MainPool
   * @return the percentage vested
   */
  function getVestedPercentage(
    uint256 when,
    uint256 lockedFrom,
    uint256 lockedUntil
  ) external pure returns (uint256);
}


// File contracts/pool/SidePool.sol

// License: MIT
pragma solidity 0.8.11;

// Author: Francesco Sullo <[email protected]>
// (c) 2022+ SuperPower Labs Inc.










//import "hardhat/console.sol";

//import "hardhat/console.sol";

abstract contract SidePool is
  ISidePool,
  Versionable,
  Constants,
  TokenReceiver,
  Initializable,
  OwnableUpgradeable,
  UUPSUpgradeable
{
  using SafeMathUpgradeable for uint256;
  using AddressUpgradeable for address;

  // users and deposits
  mapping(address => User) public users;
  Conf public conf;
  ExtraConf public extraConf;

  SideToken public rewardsToken;
  SideToken public stakedToken;
  IERC721Minimal public blueprint;

  uint256 public taxes;
  address public oracle;
  ISidePoolViews public poolViews;

  // set the storage to manage future changes
  // keeping the contract upgradeable
  ExtraNftConf[] public extraNftConf;

  modifier onlyOwnerOrOracle() {
    require(_msgSender() == owner() || (oracle != address(0) && _msgSender() == oracle), "SidePool: not owner nor oracle");
    _;
  }

  modifier whenActive() {
    require(conf.status == 1, "SidePool: not initiated or paused");
    _;
  }

  // solhint-disable-next-line
  function __SidePool_init(
    address stakedToken_,
    address rewardsToken_,
    address blueprint_,
    address poolViews_
  ) public initializer {
    __Ownable_init();
    require(stakedToken_.isContract(), "SidePool: stakedToken not a contract");
    require(rewardsToken_.isContract(), "SidePool: rewardsToken not a contract");
    require(blueprint_.isContract(), "SidePool: Blueprint not a contract");
    require(poolViews_.isContract(), "SidePool: poolViews_ not a contract");
    // in SeedFarm, stakedToken and rewardsToken are same token, SEED
    stakedToken = SideToken(stakedToken_);
    rewardsToken = SideToken(rewardsToken_);
    blueprint = IERC721Minimal(blueprint_);
    poolViews = ISidePoolViews(poolViews_);
  }

  function _authorizeUpgrade(address newImplementation) internal virtual override onlyOwner {
    emit ImplementationUpgraded(newImplementation);
  }

  function initPool(
    uint32 rewardsFactor_,
    uint32 decayInterval_,
    uint16 decayFactor_,
    uint32 swapFactor_,
    uint32 stakeFactor_,
    uint16 taxPoints_,
    uint8 coolDownDays_
  ) external override onlyOwner {
    require(conf.status == 0, "SidePool: already initiated");
    conf = Conf({
      rewardsFactor: rewardsFactor_,
      decayInterval: decayInterval_,
      decayFactor: decayFactor_,
      maximumLockupTime: 365,
      poolInitAt: uint32(block.timestamp),
      lastRatioUpdateAt: uint32(block.timestamp),
      swapFactor: swapFactor_,
      stakeFactor: stakeFactor_,
      taxPoints: taxPoints_,
      coolDownDays: coolDownDays_,
      status: 1
    });
    extraConf.blueprintAmount = 0;
    extraConf.priceRatio = 10000;
    emit PoolInitiatedOrUpdated(
      rewardsFactor_,
      decayInterval_,
      decayFactor_,
      swapFactor_,
      stakeFactor_,
      taxPoints_,
      coolDownDays_
    );
  }

  // put to zero any parameter that remains the same
  function updateConf(
    uint32 decayInterval_,
    uint16 decayFactor_,
    uint32 swapFactor_,
    uint32 stakeFactor_,
    uint16 taxPoints_,
    uint8 coolDownDays_
  ) external override onlyOwnerOrOracle whenActive {
    if (decayInterval_ > 0) {
      conf.decayInterval = decayInterval_;
    }
    if (decayFactor_ > 0) {
      conf.decayFactor = decayFactor_;
    }
    if (swapFactor_ > 0) {
      conf.swapFactor = swapFactor_;
    }
    if (stakeFactor_ > 0) {
      conf.stakeFactor = stakeFactor_;
    }
    if (taxPoints_ > 0) {
      conf.taxPoints = taxPoints_;
    }
    if (coolDownDays_ > 0) {
      conf.coolDownDays = coolDownDays_;
    }
    emit PoolInitiatedOrUpdated(0, decayInterval_, decayFactor_, swapFactor_, stakeFactor_, taxPoints_, coolDownDays_);
  }

  // put to zero any parameter that remains the same
  function updatePriceRatio(uint32 priceRatio_) external override onlyOwnerOrOracle whenActive {
    if (priceRatio_ > 0) {
      extraConf.priceRatio = priceRatio_;
    }
    emit PriceRatioUpdated(priceRatio_);
  }

  // put to zero any parameter that remains the same
  function updateOracle(address oracle_) external override onlyOwner {
    require(oracle_ != address(0), "SidePool: not a valid address");
    oracle = oracle_;
    emit OracleUpdated(oracle_);
  }

  // put to zero any parameter that remains the same
  function updateExtraConf(
    uint32 sPSynrEquivalent_,
    uint32 sPBoostFactor_,
    uint32 sPBoostLimit_,
    uint32 bPSynrEquivalent_,
    uint32 bPBoostFactor_,
    uint32 bPBoostLimit_
  ) external override onlyOwner whenActive {
    if (sPSynrEquivalent_ > 0) {
      extraConf.sPSynrEquivalent = sPSynrEquivalent_;
    }
    if (sPBoostFactor_ > 0) {
      require(sPBoostFactor_ > 9999, "SidePool: negative boost not allowed");
      extraConf.sPBoostFactor = sPBoostFactor_;
    }
    if (sPBoostLimit_ > 0) {
      require(sPBoostLimit_ >= extraConf.sPSynrEquivalent, "SidePool: invalid boost limit");
      extraConf.sPBoostLimit = sPBoostLimit_;
    }
    if (bPSynrEquivalent_ > 0) {
      extraConf.bPSynrEquivalent = bPSynrEquivalent_;
    }
    if (bPBoostFactor_ > 0) {
      require(bPBoostFactor_ > 9999, "SidePool: negative boost not allowed");
      extraConf.bPBoostFactor = bPBoostFactor_;
    }
    if (bPBoostLimit_ > 0) {
      require(bPBoostLimit_ >= extraConf.bPSynrEquivalent, "SidePool: invalid boost limit");
      extraConf.bPBoostLimit = bPBoostLimit_;
    }
    emit ExtraConfUpdated(sPSynrEquivalent_, sPBoostFactor_, sPBoostLimit_, bPSynrEquivalent_, bPBoostFactor_, bPBoostLimit_);
  }

  function pausePool(bool paused) external onlyOwner {
    conf.status = paused ? 2 : 1;
    emit PoolPaused(paused);
  }

  function shouldUpdateRatio() public view override returns (bool) {
    return
      block.timestamp.sub(conf.poolInitAt).div(conf.decayInterval) >
      uint256(conf.lastRatioUpdateAt).sub(conf.poolInitAt).div(conf.decayInterval);
  }

  function updateRatio() public override {
    if (shouldUpdateRatio()) {
      uint256 count = block.timestamp.sub(conf.poolInitAt).div(conf.decayInterval) -
        uint256(conf.lastRatioUpdateAt).sub(conf.poolInitAt).div(conf.decayInterval);
      uint256 ratio = uint256(conf.rewardsFactor);
      for (uint256 i = 0; i < count; i++) {
        ratio = ratio.mul(conf.decayFactor).div(10000);
      }
      conf.rewardsFactor = uint32(ratio);
      conf.lastRatioUpdateAt = uint32(block.timestamp);
    }
  }

  function _calculateBoost(
    uint256 boosted,
    uint256 amount,
    uint256 nftAmount,
    uint256 limit,
    uint256 factor
  ) internal pure returns (uint256, uint256) {
    limit = uint256(nftAmount).mul(limit).mul(1e18);
    if (limit < amount) {
      amount = limit;
    }

    return (amount, boosted.add(amount.mul(factor).div(10000)));
  }

  function collectRewards() public override whenActive {
    _collectRewards(_msgSender());
  }

  /**
   * @notice The reward is collected and the tax is substracted
   * @param user The user collecting the reward
   */
  function _collectRewards(address user) internal {
    uint256 rewards = untaxedPendingRewards(user, block.timestamp);
    if (rewards > 0) {
      uint256 tax = poolViews.calculateTaxOnRewards(conf, rewards);
      rewardsToken.mint(user, rewards.sub(tax));
      rewardsToken.mint(address(this), tax);
      taxes += tax;
      users[user].lastRewardsAt = uint32(block.timestamp);
    }
  }

  /**
   * @notice It returns the total amount of pending claimable rewards
   * @param user The user collecting the reward
   */
  function pendingRewards(address user) public view override returns (uint256) {
    uint256 rewards = untaxedPendingRewards(user, block.timestamp);
    if (rewards > 0) {
      uint256 tax = poolViews.calculateTaxOnRewards(conf, rewards);
      rewards = rewards.sub(tax);
    }
    return rewards;
  }

  /**
   * @param user_ The user collecting the reward
   * @param timestamp Current time of the stake
   * @return the pending rewards that have yet to be taxed
   */
  function untaxedPendingRewards(address user_, uint256 timestamp) public view override returns (uint256) {
    uint256 rewards;
    User storage user = users[user_];
    for (uint256 i = 0; i < user.deposits.length; i++) {
      rewards += poolViews.calculateUntaxedRewards(conf, user.deposits[i], timestamp, user.lastRewardsAt);
    }
    if (rewards > 0) {
      rewards = poolViews.boostRewards(
        extraConf,
        rewards,
        user.stakedAmount,
        user.passAmountForBoost,
        user.blueprintAmountForBoost
      );
    }
    return rewards;
  }

  /**
   * @notice Searches for deposit from the user and its index
   * @param user address of user who made deposit being searched
   * @param index index of the deposit being searched
   * @return the deposit
   */
  function getDepositByIndex(address user, uint256 index) external view override returns (Deposit memory) {
    if (users[user].deposits.length <= index || users[user].deposits[index].lockedFrom == 0) {
      Deposit memory deposit;
      return deposit;
    } else {
      return users[user].deposits[index];
    }
  }

  /**
   * @param user address of user
   * @return the amount of deposits a user has made
   */
  function getDepositsLength(address user) public view override returns (uint256) {
    return users[user].deposits.length;
  }

  function _calculateTokenAmount(uint256 amount, uint256 tokenType) internal view returns (uint256) {
    return amount.mul(tokenType == S_SYNR_SWAP ? conf.swapFactor : conf.stakeFactor).mul(extraConf.priceRatio).div(1000000);
  }

  function _getStakedAndLockedAmount(uint256 tokenType, uint256 tokenAmountOrID) internal view returns (uint256, uint256) {
    uint256 stakedAmount;
    uint256 generator;
    if (tokenType == S_SYNR_SWAP) {
      generator = _calculateTokenAmount(tokenAmountOrID, tokenType);
    } else if (tokenType == SYNR_STAKE) {
      generator = _calculateTokenAmount(tokenAmountOrID, tokenType);
      stakedAmount = tokenAmountOrID;
    } else if (tokenType == SYNR_PASS_STAKE_FOR_SEEDS) {
      stakedAmount = uint256(extraConf.sPSynrEquivalent).mul(1e18);
      generator = _calculateTokenAmount(stakedAmount, tokenType);
    } else if (tokenType == BLUEPRINT_STAKE_FOR_SEEDS) {
      stakedAmount = uint256(extraConf.bPSynrEquivalent).mul(1e18);
      generator = _calculateTokenAmount(stakedAmount, tokenType);
    } else if (tokenType != BLUEPRINT_STAKE_FOR_BOOST && tokenType != SYNR_PASS_STAKE_FOR_BOOST) {
      revert("SidePool: invalid tokenType");
    }
    return (stakedAmount, generator);
  }

  /**
   * @notice stakes if the pool is active
   * @param user address of user being updated
   * @param tokenType identifies the type of transaction being made
   * @param lockedFrom timestamp when locked
   * @param lockedUntil timestamp when can unstake without penalty on MainPool
   * @param tokenAmountOrID ammount of tokens being staked, in the case where a SYNR Pass is being staked, it identified its ID
   * @param mainIndex index of deposit being updated
   */
  function _stake(
    address user,
    uint256 tokenType,
    uint256 lockedFrom,
    uint256 lockedUntil,
    uint256 mainIndex,
    uint256 tokenAmountOrID
  ) internal virtual whenActive {
    (, bool exists) = getDepositIndexByMainIndex(user, mainIndex);
    require(!exists, "SidePool: payload already used");
    if (users[user].lastRewardsAt == 0) {
      users[user].lastRewardsAt = uint32(block.timestamp);
    }
    updateRatio();
    _collectRewards(user);
    uint256 tokenID;
    (uint256 stakedAmount, uint256 generator) = _getStakedAndLockedAmount(tokenType, tokenAmountOrID);
    // > is more gas efficient than >=
    if (tokenType > BLUEPRINT_STAKE_FOR_BOOST - 1) {
      users[user].blueprintAmount++;
      if (tokenType == BLUEPRINT_STAKE_FOR_BOOST) {
        users[user].blueprintAmountForBoost++;
      }
      tokenID = tokenAmountOrID;
      blueprint.safeTransferFrom(user, address(this), tokenAmountOrID);
      extraConf.blueprintAmount++;
    } else {
      users[user].passAmount++;
      if (tokenType == SYNR_PASS_STAKE_FOR_BOOST) {
        users[user].passAmountForBoost++;
      }
      tokenID = tokenAmountOrID;
    }
    users[user].stakedAmount = uint96(uint256(users[user].stakedAmount).add(stakedAmount));
    users[user].generator = uint128(uint256(users[user].generator).add(generator));
    if (tokenType == S_SYNR_SWAP) {
      lockedUntil = lockedFrom + uint256(conf.coolDownDays).mul(1 days);
    }
    uint256 index = users[user].deposits.length;
    Deposit memory deposit = Deposit({
      tokenType: uint8(tokenType),
      lockedFrom: uint32(lockedFrom),
      lockedUntil: uint32(lockedUntil),
      stakedAmount: uint96(stakedAmount),
      tokenID: uint16(tokenID),
      unlockedAt: 0,
      mainIndex: uint16(mainIndex),
      generator: uint128(generator),
      rewardsFactor: conf.rewardsFactor,
      extra1: 0,
      extra2: 0,
      extra3: 0,
      extra4: 0
    });
    users[user].deposits.push(deposit);
    emit DepositSaved(user, uint16(index));
  }

  /**
   * @notice Searches for deposit from the user and its index
   * @param user address of user who made deposit being searched
   * @param mainIndex index of the deposit being searched
   * @return the deposit
   */
  function getDepositIndexByMainIndex(address user, uint256 mainIndex) public view override returns (uint256, bool) {
    for (uint256 i; i < users[user].deposits.length; i++) {
      if (uint256(users[user].deposits[i].mainIndex) == mainIndex && users[user].deposits[i].lockedFrom > 0) {
        return (i, true);
      }
    }
    return (0, false);
  }

  /**
   * @notice unstakes a deposit
   * @param tokenType identifies the type of transaction being made
   * @param lockedFrom timestamp when locked
   * @param lockedUntil timestamp when can unstake without penalty on MainPool
   * @param mainIndex index of deposit
   * @param tokenAmountOrID ammount of tokens being staked, in the case where a SYNR Pass is being staked, it identified its ID
   */
  function _unstake(
    address user_,
    uint256 tokenType,
    uint256 lockedFrom,
    uint256 lockedUntil,
    uint256 mainIndex,
    uint256 tokenAmountOrID
  ) internal virtual whenActive {
    (uint256 index, bool exists) = getDepositIndexByMainIndex(user_, mainIndex);
    require(exists, "SidePool: deposit not found");
    Deposit storage deposit = users[user_].deposits[index];
    require(deposit.unlockedAt == 0, "SidePool: deposit already unlocked");
    // < is more gas efficient than <=
    require(tokenType < BLUEPRINT_STAKE_FOR_SEEDS + 1, "SidePool: unsupported tokenType");
    if (tokenType == SYNR_PASS_STAKE_FOR_SEEDS || tokenType == BLUEPRINT_STAKE_FOR_SEEDS) {
      require(lockedUntil < block.timestamp, "SidePool: SYNR Pass and Blueprint used to get SYNR cannot be early unstaked");
    }
    require(
      uint256(deposit.tokenType) == tokenType &&
        uint256(deposit.lockedFrom) == lockedFrom &&
        uint256(deposit.lockedUntil) == lockedUntil &&
        (
          tokenType == SYNR_STAKE
            ? uint256(deposit.stakedAmount) == tokenAmountOrID
            : uint256(deposit.tokenID) == tokenAmountOrID
        ),
      "SidePool: inconsistent deposit"
    );
    _collectRewards(user_);
    if (deposit.tokenType == S_SYNR_SWAP) {
      if (deposit.lockedUntil > block.timestamp) {
        uint256 vestedPercentage = poolViews.getVestedPercentage(block.timestamp, deposit.lockedFrom, deposit.lockedUntil);
        uint256 unstakedAmount = uint256(deposit.generator).mul(vestedPercentage).div(10000);
        stakedToken.mint(_msgSender(), unstakedAmount);
      } else {
        stakedToken.mint(_msgSender(), uint256(deposit.generator));
      }
    } else if (deposit.tokenType > BLUEPRINT_STAKE_FOR_BOOST - 1) {
      users[user_].blueprintAmount--;
      if (tokenType == BLUEPRINT_STAKE_FOR_BOOST) {
        users[user_].blueprintAmountForBoost--;
      }
      blueprint.safeTransferFrom(address(this), user_, uint256(deposit.tokenID));
      extraConf.blueprintAmount--;
    } else if (deposit.tokenType > SYNR_PASS_STAKE_FOR_BOOST - 1) {
      users[user_].passAmount--;
      if (tokenType == SYNR_PASS_STAKE_FOR_BOOST) {
        users[user_].passAmountForBoost--;
      }
    }
    if (deposit.stakedAmount > 0) {
      users[user_].stakedAmount = uint96(uint256(users[user_].stakedAmount).sub(deposit.stakedAmount));
    }
    if (deposit.generator > 0) {
      users[user_].generator = uint128(uint256(users[user_].generator).sub(deposit.generator));
    }
    deposit.unlockedAt = uint32(block.timestamp);
    emit DepositUnlocked(user_, uint16(index));
  }

  /**
   * @notice Withdraws taxes
   * @param amount amount of sSynr to be withdrawn
   * @param beneficiary address to which the withdrawn will go to
   */
  function withdrawTaxes(uint256 amount, address beneficiary) external virtual override onlyOwner {
    require(amount < taxes + 1, "SidePool: amount not available");
    require(beneficiary != address(0), "SidePool: beneficiary cannot be zero address");
    if (amount == 0) {
      amount = taxes;
    }
    taxes -= amount;
    rewardsToken.mint(beneficiary, amount);
  }

  function _unstakeDeposit(Deposit memory deposit) internal {
    _unstake(
      _msgSender(),
      uint256(deposit.tokenType),
      uint256(deposit.lockedFrom),
      uint256(deposit.lockedUntil),
      uint256(deposit.mainIndex),
      deposit.tokenType < SYNR_PASS_STAKE_FOR_BOOST ? uint256(deposit.stakedAmount) : uint256(deposit.tokenID)
    );
  }

  uint256[50] private __gap;
}


// File contracts/pool/SeedPool.sol

// License: MIT
pragma solidity 0.8.11;

// Author: Francesco Sullo <[email protected]>
// (c) 2022+ SuperPower Labs Inc.

//import "hardhat/console.sol";

contract SeedPool is SidePool {
  using SafeMathUpgradeable for uint256;
  using AddressUpgradeable for address;

  mapping(address => bool) public bridges;
  mapping(address => uint16) internal _mainIndexForBlueprint;

  modifier onlyBridge() {
    require(bridges[_msgSender()], "SeedPool: forbidden");
    _;
  }

  /// @custom:oz-upgrades-unsafe-allow constructor
  constructor() initializer {}

  function initialize(
    address seedToken_,
    address blueprint_,
    address poolViews_
  ) public initializer {
    __SidePool_init(seedToken_, seedToken_, blueprint_, poolViews_);
  }

  function _authorizeUpgrade(address newImplementation) internal virtual override onlyOwner {
    emit ImplementationUpgraded(newImplementation);
  }

  function setBridge(address bridge_, bool active) external virtual onlyOwner {
    require(bridge_.isContract(), "SeedPool: bridge_ not a contract");
    if (active) {
      bridges[bridge_] = true;
    } else {
      delete bridges[bridge_];
    }
  }

  function stake(
    uint256 tokenType,
    uint256 lockupTime,
    uint256 tokenAmountOrID
  ) external virtual override {
    require(tokenType >= BLUEPRINT_STAKE_FOR_BOOST, "SeedPool: unsupported token");
    require(users[_msgSender()].blueprintAmount < 30, "SeedPool: at most 30 blueprint can be staked");
    uint16 mainIndex = _mainIndexForBlueprint[_msgSender()];
    if (mainIndex == 0) {
      mainIndex = type(uint16).max;
    } else {
      mainIndex -= 1;
    }
    _mainIndexForBlueprint[_msgSender()] = mainIndex;
    _stake(_msgSender(), tokenType, block.timestamp, block.timestamp.add(lockupTime * 1 days), mainIndex, tokenAmountOrID);
  }

  function unstake(Deposit memory deposit) external override {
    require(deposit.tokenType == S_SYNR_SWAP || deposit.tokenType >= BLUEPRINT_STAKE_FOR_BOOST, "SeedPool: invalid tokenType");
    _unstakeDeposit(deposit);
  }

  function stakeViaBridge(
    address user,
    uint256 tokenType,
    uint256 lockedFrom,
    uint256 lockedUntil,
    uint256 mainIndex,
    uint256 tokenAmountOrID
  ) external onlyBridge {
    require(tokenType < BLUEPRINT_STAKE_FOR_BOOST, "SeedPool: unsupported token");
    _stake(user, tokenType, lockedFrom, lockedUntil, mainIndex, tokenAmountOrID);
  }

  function unstakeViaBridge(
    address user,
    uint256 tokenType,
    uint256 lockedFrom,
    uint256 lockedUntil,
    uint256 mainIndex,
    uint256 tokenAmountOrID
  ) external onlyBridge {
    require(tokenType != S_SYNR_SWAP && tokenType < BLUEPRINT_STAKE_FOR_BOOST, "SeedPool: unsupported token");
    _unstake(user, tokenType, lockedFrom, lockedUntil, mainIndex, tokenAmountOrID);
  }
}