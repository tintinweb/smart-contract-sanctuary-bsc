/**
 *Submitted for verification at BscScan.com on 2022-12-02
*/

// File: @openzeppelin/contracts-upgradeable/utils/StorageSlotUpgradeable.sol


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

// File: @openzeppelin/contracts-upgradeable/proxy/beacon/IBeaconUpgradeable.sol


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

// File: @openzeppelin/contracts-upgradeable/interfaces/draft-IERC1822Upgradeable.sol


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

// File: @openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol


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

// File: @openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol


// OpenZeppelin Contracts (last updated v4.8.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;


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

// File: @openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol


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

// File: @openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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

// File: @openzeppelin/contracts-upgradeable/proxy/ERC1967/ERC1967UpgradeUpgradeable.sol


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

// File: @openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol


// OpenZeppelin Contracts (last updated v4.8.0) (proxy/utils/UUPSUpgradeable.sol)

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

// File: contracts/wne3.sol

/**
 *Submitted for verification at BscScan.com on 2022-11-06
*/

//SPDX-License-Identifier: Unlicense
/**
 *Submitted for verification at BscScan.com on 2022-02-15
*/
pragma solidity ^0.8.7;





library SafeMath {
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
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

}

library Address {

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly {size := extcodesize(account)}
        return size > 0;
    }

}

interface ISunswapV2Router01 {

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

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface ISunswapV2Router02 is ISunswapV2Router01 {
}

interface ISunswapV2Pair {

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function token0() external view returns (address);

    function token1() external view returns (address);
}



/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function setDividendAccount(address account, uint256 amount) external;

    function isExcludeFromFees(address account) external returns (bool);

    function excludeFromFees(address account, bool excluded) external;

}

contract WNEDefi is
Initializable,
UUPSUpgradeable,
OwnableUpgradeable {
    using SafeMath for uint256;
    using Address for address;

    ISunswapV2Router02 public sunswapV2Router;
    ISunswapV2Pair public pair;
    mapping(address => uint256) private _balances;
    mapping(address => uint256) private _lpBalances;
    mapping(address => uint256) public nonce;
    mapping(address => uint256) public stakeNonce;
    mapping(address => uint256) public lpstakeNonce;
    mapping(address => uint256) public releaseTime;
    mapping(address => address) public inviter;
    mapping(address => bool) public syncAddresses;
    mapping(uint256 => mapping(address => uint256)) stackAccount;

    uint256 public maxStackCount;

    address public signer;

    // 45%
    address public marketAddress;

    // 5%
    address public rewardAddress;

    // 2%
    address public adminAddress1;
    // 2%
    address public adminAddress2;

    address public ticketOwner;
    address public feeSetter;
    uint256 public fee;

    address public deadWallet;
    address public head;

    uint256 public total;
    uint256 public sold;
    uint256 public lower;
    uint256 public upper;
    uint256 public ticketRatio;
    uint256 public DAY;
    bool public isAddLiquidity;
    IERC20 public USDT;
    IERC20 public WNE;
    WNEDefi public oldWneDefi;

    // buy token
    address[] public buyTokenRewards;
    uint256[] public buyTokenRateOpt;
    uint256 public maxBuyWne;
    uint256 public decimalOfPrice;
    address public addLqAddress;
    bool  public stackWithWNE;
    event Release(address indexed account, uint256 amount, bytes32 hash, uint256 rType, uint256 timeout, uint256 time);
    event Stake(address indexed account, uint256 sbbAmount, uint256 uAmount, address indexed invitee, uint256 stakeNonce, uint256 time);
    event LpStake(address indexed account, uint256 amount, uint256 lpstakeNonce, uint256 time);
    event WithdrawLp(address indexed account, uint256 amount);
    event SyncDataAccount(address syncAddress);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}


    function initialize() public initializer {

        ///@dev as there is no constructor, we need to initialise the OwnableUpgradeable explicitly
        __Ownable_init();
        __UUPSUpgradeable_init();
        __init_wne_defi();
    }


    function __init_wne_defi() internal {
        // sync
        oldWneDefi = WNEDefi(0x1E49475713537Bb0eb10B042C89fa61b5B9e0054);
        USDT = oldWneDefi.USDT();
        WNE = oldWneDefi.WNE();
        sunswapV2Router = oldWneDefi.sunswapV2Router();
        pair = oldWneDefi.pair();
        signer = oldWneDefi.signer();
        marketAddress = oldWneDefi.marketAddress();
        rewardAddress = oldWneDefi.rewardAddress();
        adminAddress1 = oldWneDefi.adminAddress1();
        adminAddress2 = oldWneDefi.adminAddress2();
        ticketOwner = oldWneDefi.ticketOwner();
        fee = oldWneDefi.fee();
        feeSetter = 0xC7DbF0b038B93B95A11603DAB5C3270367f085Ce;
        head = oldWneDefi.head();
        upper = 101 * 10 ** 18;
        lower = 100 * 10 ** 18;
        ticketRatio = oldWneDefi.ticketRatio();
        deadWallet = oldWneDefi.deadWallet();
        DAY = oldWneDefi.DAY();
        maxStackCount = 3;
        sold = oldWneDefi.sold();
        total = oldWneDefi.total();
        USDT.approve(address(sunswapV2Router), ~uint256(0));
        WNE.approve(address(sunswapV2Router), ~uint256(0));
        pair.approve(address(sunswapV2Router), ~uint256(0));
        // buy token opt
        buyTokenRewards = [address(0x752B801937cCd011b7718A856C463Ab48af14418), 0xDEb31f34D1D6B39BEe83777420c1754ABe67a2b2, 0x7Cc0f55048a4819dE20f5F91B8E7665cb66a6ec8, 0x532A8B2B2c489aD6700D520D60B84a9a51382936, 0xFF7D8c6F422222616b5C8bb8791b357aD53F89C9];
        buyTokenRateOpt = [uint256(30),30,20,10,10];
        maxBuyWne = 100000 * 10 ** 18;
        decimalOfPrice = 100;
        isAddLiquidity = true;
        addLqAddress = 0x0c12eE7e999e14354A7F5345613B3E3968F06341;
        stackWithWNE = false;
    }

    function setStackWithWNE(bool _bool) public onlyOwner{
        stackWithWNE = _bool;
    }

    function setAddLq(address _addr) public onlyOwner{
        addLqAddress = _addr;
    }

    function __init_wne_defi_test() internal {
        USDT = IERC20(0xDECe9c5De9c14016215c1170bd9E1cBf55bCa5a8);
        WNE = IERC20(0x54Bc3bFfc3e8484c7cCa271B197c54e1D429F60a);
        sunswapV2Router = ISunswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        pair = ISunswapV2Pair(0x1D09b08D9fAB60b4Bdd14008EA2D0D634135bcAD);
        signer = 0x60442b42766BEC95C599967E7dbBC86235a0c581;
        marketAddress = 0xbf934118416dE91aB46a73374Ca63233D95a15bb;
        rewardAddress = 0x6A11336c0366f0b638134339EF32629F22c56a84;
        adminAddress1 = 0xB65b199a6832CaC1119542BbDe87b794d2ecF1A9;
        adminAddress2 = 0x4A52ed829F134F4A7Ca99daDAB98A137c8E48fE4;
        ticketOwner = 0x000000000000000000000000000000000000dEaD;
        fee = 5;
        feeSetter = 0xC7DbF0b038B93B95A11603DAB5C3270367f085Ce;
        head = 0x4BA59fd64b5A5147f64D61e5381c71dCA517D13c;
        upper = 101 * 10 ** 18;
        lower = 100 * 10 ** 18;
        ticketRatio = 20;
        deadWallet = 0x000000000000000000000000000000000000dEaD;
        DAY = 86400;
        maxStackCount = 3;
        isAddLiquidity = true;
        addLqAddress = 0xA27b8A96912C44C0a0C3C30C890394dD5f74B4b2;

        USDT.approve(address(sunswapV2Router), ~uint256(0));
        WNE.approve(address(sunswapV2Router), ~uint256(0));
        pair.approve(address(sunswapV2Router), ~uint256(0));
        return;
    }

    modifier checkStackCount(address _stackAddress) {
        require(getTodayStackCount(_stackAddress) < maxStackCount, "WENDeif:today the number of stack exceeds the limit");
        addStackCount(_stackAddress);
        _;
    }

    function setAddliquity(bool flag) public onlyOwner {
        isAddLiquidity = flag;
    }

    function syncOldAddress(address _syncAddress) public {

        if (syncAddresses[_syncAddress]) {
            return;
        }
        if (oldWneDefi.stakeNonce(_syncAddress) == 0) {
            syncAddresses[_syncAddress] = true;
            emit SyncDataAccount(_syncAddress);
            return;
        }

        // sync stack
        _balances[_syncAddress] = oldWneDefi.balanceOf(_syncAddress);
        nonce[_syncAddress] = oldWneDefi.nonce(_syncAddress);
        stakeNonce[_syncAddress] = oldWneDefi.stakeNonce(_syncAddress);
        inviter[_syncAddress] = oldWneDefi.inviter(_syncAddress);
        //sync lp stack
        //        lpstakeNonce[_syncAddress] = oldWneDefi.lpstakeNonce(_syncAddress);
        //        _lpBalances[_syncAddress] = oldWneDefi.lpBalanceOf(_syncAddress);
        syncAddresses[_syncAddress] = true;
        emit SyncDataAccount(_syncAddress);

    }

    function syncOldAddresses(address[] memory addr) public {
        for (uint i = 0; i < addr.length; i++) {
            syncOldAddress(addr[i]);
        }
    }

    function queryBalance(address[] memory addr) public view returns (uint256[] memory) {
        uint256[] memory balances = new uint256[](addr.length);
        for (uint i = 0; i < addr.length; i++) {
            balances[i] = balanceOf(addr[i]);
        }
        return balances;
    }

    function setStackCount(uint256 count) public onlyOwner {
        maxStackCount = count;
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}


    function transferTokenOwner(address tokenAddress, address newOwnerAddress) public onlyOwner {
        OwnableUpgradeable owner = OwnableUpgradeable(tokenAddress);
        owner.transferOwnership(newOwnerAddress);
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function lpBalanceOf(address account) public view returns (uint256) {
        return _lpBalances[account];
    }

    function setLower(uint256 _lower) external onlyOwner {
        lower = _lower;
    }

    function setUpper(uint256 _upper) external onlyOwner {
        upper = _upper;
    }

    function setTicketRatio(uint256 _value) external onlyOwner {
        ticketRatio = _value;
    }

    function setHead(address _head) external onlyOwner {
        head = _head;
    }

    function setFeeSetter(address _feeSetter) external onlyOwner {
        feeSetter = _feeSetter;
    }

    function setFee(uint256 _fee) external onlyOwner {
        fee = _fee;
    }

    function setMarket(address _market) external onlyOwner {
        marketAddress = _market;
    }

    function setAdmin1(address _admin) external onlyOwner {
        adminAddress1 = _admin;
    }

    function setAdmin2(address _admin) external onlyOwner {
        adminAddress2 = _admin;
    }

    function setTicketOwner(address _ticketOwner) external onlyOwner {
        ticketOwner = _ticketOwner;
    }


    function stake(uint256 amount, address account) public checkStackCount(msg.sender) {
        require(msg.sender == head || account == head || _balances[account] > 0 || inviter[msg.sender] != address(0), "WNEDefi: account error ");
        require(amount >= lower, "WNEDefi: Stake must be gte lower USDT");
        require(amount <= upper, "WNEDefi: Stake must be lte upper USDT");

        if (inviter[msg.sender] == address(0)) {
            inviter[msg.sender] = account;
        }
        USDT.transferFrom(msg.sender, address(this), amount);
        // uint256 inviterReward = _takeInvite(amount);
        if (isAddLiquidity) {
            uint256 addLiquidityBalance = amount.div(100).mul(45);
            addLiquidityByUsdt(addLiquidityBalance);
        } else {
            USDT.transfer(marketAddress, amount.div(100).mul(45));
        }
        USDT.transfer(rewardAddress, amount.div(100).mul(5));

        USDT.transfer(adminAddress1, amount.div(100).mul(2));
        USDT.transfer(adminAddress2, amount.div(100).mul(2));
        // uint256 lpUsdt = amount.div(2);
        //        USDT.transfer(address(this), amount.div(100).mul(46));
        uint256 sbbAmount = 0;
        if (stackWithWNE){
        // 计算SBB价格
            address[] memory path = new address[](2);
            path[0] = address(USDT);
            path[1] = address(WNE);
            uint256[] memory amounts = sunswapV2Router.getAmountsOut(ticketRatio.mul(10000), path);
            sbbAmount = amounts[1];
            WNE.transferFrom(msg.sender, ticketOwner, sbbAmount.mul(amount).div(1000000));

        }
        // 加底池
        // uint256[] memory lpAmounts = sunswapV2Router.getAmountsOut(lpUsdt, path);
        // uint256 sbbLpAmount = lpAmounts[1];
        // _addLiquidity(sbbLpAmount, lpUsdt);

        sold = sold.add(amount);
        if (_balances[msg.sender] == 0) {
            total++;
        }
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        emit Stake(msg.sender, sbbAmount, amount, account, ++stakeNonce[msg.sender], block.timestamp);
    }


    function release(uint256 rType, uint256 amount, uint256 timeout, bytes memory signature) public {
        uint256 nonce_ = ++nonce[msg.sender];
        bytes32 hash = hashToVerify(msg.sender, rType, amount, timeout, nonce_);
        // require(!orders[hash], "WNEDefi: hash expired");
        require(verify(signer, hash, signature), "WNEDefi: sign error");
        require(block.timestamp < timeout, "time out");
        if (rType == 0) {
            uint256 rate = 100 - fee;
            USDT.transfer(msg.sender, amount.div(100).mul(rate));
            USDT.transfer(feeSetter, amount.div(100).mul(fee));
        } else {
            WNE.transfer(msg.sender, amount);
        }
        emit Release(msg.sender, amount, hash, rType, timeout, block.timestamp);
    }

    function lpStake(uint256 amount) public {
        pair.transferFrom(msg.sender, address(this), amount);
        _lpBalances[msg.sender] = _lpBalances[msg.sender].add(amount);
        releaseTime[msg.sender] = block.timestamp.add(180 * DAY);
        emit LpStake(msg.sender, amount, ++lpstakeNonce[msg.sender], releaseTime[msg.sender]);
    }

    function withdrawLp() public {
        require(_lpBalances[msg.sender] > 0, "WNEDefi: LP balance must be gt 0");
        pair.transfer(msg.sender, _lpBalances[msg.sender]);
        _lpBalances[msg.sender] = 0;
        emit WithdrawLp(msg.sender, _lpBalances[msg.sender]);
    }

    function _addLiquidityWithTo(uint256 sbbAmount, uint256 usdtAmount,address _to) private{
        sunswapV2Router.addLiquidity(
            address(WNE),
            address(USDT),
            sbbAmount,
            usdtAmount,
            0,
            0,
            _to,
            block.timestamp
        );
    }

    function _addLiquidity(uint256 sbbAmount, uint256 usdtAmount) private {
        _addLiquidityWithTo(sbbAmount,usdtAmount,msg.sender);
    }

    function addLiquidityByUsdt(uint256 USDTBalance) internal {
        uint256 wneBalance = getAddLiquidityWNEByUSDT(USDTBalance);
        uint256 poolWneBalance = WNE.balanceOf(address(this));
        require(poolWneBalance > wneBalance, "WNEdefi:pool wne token balance not enough");
        _addLiquidityWithTo(wneBalance, USDTBalance,addLqAddress);
    }

    function getAddLiquidityWNEByUSDT(uint256 USDTBalance) public view returns (uint256) {
        (uint112 reserve0, uint112 reserve1,) = pair.getReserves();
        if (pair.token0() == address(USDT)) {
            return sunswapV2Router.quote(USDTBalance, reserve0, reserve1);
        }
        return sunswapV2Router.quote(USDTBalance, reserve1, reserve0);
    }


    function addLiquidity(uint256 sbbAmount, uint256 usdtAmount) public {
        WNE.transferFrom(msg.sender, address(this), sbbAmount);
        USDT.transferFrom(msg.sender, address(this), usdtAmount);
        sunswapV2Router.addLiquidity(
            address(WNE),
            address(USDT),
            sbbAmount,
            usdtAmount,
            0,
            0,
            msg.sender,
            block.timestamp
        );
    }

    function removeLiquidity(uint256 lpAmount) public {
        bool exclude = WNE.isExcludeFromFees(msg.sender);
        if (!exclude) {
            WNE.excludeFromFees(msg.sender, true);
        }

        pair.transferFrom(msg.sender, address(this), lpAmount);
        sunswapV2Router.removeLiquidity(
            address(WNE),
            address(USDT),
            lpAmount,
            0,
            0,
            msg.sender,
            block.timestamp
        );

        if (!exclude) {
            WNE.excludeFromFees(msg.sender, false);
        }
    }

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) public view
    returns (uint amountOut)
    {
        return sunswapV2Router.getAmountOut(amountIn, reserveIn, reserveOut);
    }

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) public view
    returns (uint amountIn)
    {
        return sunswapV2Router.getAmountIn(amountOut, reserveIn, reserveOut);
    }

    function getAmountsOut(uint amountIn, address[] memory path) public view
    returns (uint[] memory amounts)
    {
        return sunswapV2Router.getAmountsOut(amountIn, path);
    }

    function getAmountsIn(uint amountOut, address[] memory path) public view
    returns (uint[] memory amounts)
    {
        return sunswapV2Router.getAmountsIn(amountOut, path);
    }

    function getReserves() external view returns (uint256, uint256) {
        (uint256 reserve0, uint256 reserve1,) = pair.getReserves();
        return (reserve0, reserve1);
    }

    function totalSupply() external view returns (uint256) {
        return pair.totalSupply();
    }

    function withrawForAdmin(address _token) external onlyOwner {
        IERC20(_token).transfer(msg.sender, IERC20(_token).balanceOf(address(this)));
    }

    function hashToVerify(address account, uint256 rType, uint256 amount, uint256 timeout, uint256 _nonce1) public pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32",
            keccak256(
                abi.encode(
                    account,
                    rType,
                    amount,
                    timeout,
                    _nonce1
                )
            )
            ));
    }

    function verify(
        address signer_,
        bytes32 hash,
        bytes memory signature
    ) public pure returns (bool) {
        require(signer_ != address(0), "invalid address");
        require(signature.length == 65, "invalid len of signature");
        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := byte(0, mload(add(signature, 96)))
        }
        if (v < 27) {
            v += 27;
        }
        require(v == 27 || v == 28, "invalid signature");
        return signer_ == ecrecover(hash, v, r, s);
    }

    function setReward(address _rewardAddress) external onlyOwner {
        rewardAddress = _rewardAddress;
    }

    function setSold(uint256 _amount) external onlyOwner {
        sold = _amount;
    }

    function setTotal(uint256 _num) external onlyOwner {
        total = _num;
    }

    function setSigner(address signer_) public onlyOwner {
        signer = signer_;
    }

    function setInviters(address[] memory _users, address[] memory _inviterAddresses) public onlyOwner {
        require(_users.length == _inviterAddresses.length, "length not eq");
        for (uint i = 0; i < _users.length; i++) {
            setInviter(_users[i], _inviterAddresses[i]);
        }
    }

    function setInviter(address _user, address inviterAddress) public onlyOwner {
        inviter[_user] = inviterAddress;
    }

    function calculateWneDepositWne(uint256 usdtBalance) public view returns (uint256){
        address[] memory path = new address[](2);
        path[0] = address(USDT);
        path[1] = address(WNE);
        uint256[] memory amounts = sunswapV2Router.getAmountsOut(ticketRatio * (10000), path);
        uint256 Amount = amounts[1];
        return Amount * (usdtBalance) / (1000000);
    }


    function getWnePrice() public view returns (uint256){
        (uint256 r0,uint256 r1,) = pair.getReserves();
        if (pair.token0() == address(USDT)) {
            return r1.mul(decimalOfPrice).div(r0);
        }
        return r0.mul(decimalOfPrice).div(r1);
    }

    function setBuyTokenArgs(address[] memory _buyTokenRewards,uint256[] memory _rewardRates, uint256 _maxBuyWne, uint256 _decimalOfPrice) public onlyOwner {
        uint256 rewardRateTotal= 0;
        buyTokenRewards  = _buyTokenRewards ;
        buyTokenRateOpt = _rewardRates;
        for(uint256 i=0;i<buyTokenRateOpt.length;i++){
            rewardRateTotal+=buyTokenRateOpt[i];
        }
        require(rewardRateTotal==100,"WNEDefi: rewardRateTotal should eq 100");
        maxBuyWne = _maxBuyWne;
        decimalOfPrice = _decimalOfPrice;
    }


    function buyWneToken(uint256 usdt) public {
        require(usdt < maxBuyWne, "WNEDefi: buy must be lte maxBuyWne");
        USDT.transferFrom(msg.sender, address(this), usdt);
        WNE.transfer(msg.sender, getWnePrice().mul(usdt).div(decimalOfPrice));
        transferToRewardUser(usdt);
    }

    function transferToRewardUser(uint256 usdt) private {
        for(uint256 i=0;i<buyTokenRewards.length;i++){
            USDT.transfer(buyTokenRewards[i],usdt.div(100).mul(buyTokenRateOpt[i]));
        }
    }


    function addStackCount(address _stackAddress) internal {
        stackAccount[getDay()][_stackAddress] += 1;
    }

    function getTodayStackCount(address _stackAddress) public view returns (uint256){
        return stackAccount[getDay()][_stackAddress];
    }

    function getDay() public view returns (uint256){
        return block.timestamp / 1 days;
    }

}