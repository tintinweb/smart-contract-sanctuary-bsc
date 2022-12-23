// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (interfaces/draft-IERC1822.sol)

pragma solidity ^0.8.0;

/**
 * @dev ERC1822: Universal Upgradeable Proxy Standard (UUPS) documents a method for upgradeability through a simplified
 * proxy whose upgrades are fully controlled by the current implementation.
 */
interface IERC1822Proxiable {
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
interface IBeacon {
    /**
     * @dev Must return an address that can be used as a delegate call target.
     *
     * {BeaconProxy} will check that this address is a contract.
     */
    function implementation() external view returns (address);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/ERC1967/ERC1967Proxy.sol)

pragma solidity ^0.8.0;

import "../Proxy.sol";
import "./ERC1967Upgrade.sol";

/**
 * @dev This contract implements an upgradeable proxy. It is upgradeable because calls are delegated to an
 * implementation address that can be changed. This address is stored in storage in the location specified by
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967], so that it doesn't conflict with the storage layout of the
 * implementation behind the proxy.
 */
contract ERC1967Proxy is Proxy, ERC1967Upgrade {
    /**
     * @dev Initializes the upgradeable proxy with an initial implementation specified by `_logic`.
     *
     * If `_data` is nonempty, it's used as data in a delegate call to `_logic`. This will typically be an encoded
     * function call, and allows initializing the storage of the proxy like a Solidity constructor.
     */
    constructor(address _logic, bytes memory _data) payable {
        _upgradeToAndCall(_logic, _data, false);
    }

    /**
     * @dev Returns the current implementation address.
     */
    function _implementation() internal view virtual override returns (address impl) {
        return ERC1967Upgrade._getImplementation();
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/ERC1967/ERC1967Upgrade.sol)

pragma solidity ^0.8.2;

import "../beacon/IBeacon.sol";
import "../../interfaces/draft-IERC1822.sol";
import "../../utils/Address.sol";
import "../../utils/StorageSlot.sol";

/**
 * @dev This abstract contract provides getters and event emitting update functions for
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967] slots.
 *
 * _Available since v4.1._
 *
 * @custom:oz-upgrades-unsafe-allow delegatecall
 */
abstract contract ERC1967Upgrade {
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
        return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {
        require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
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
            Address.functionDelegateCall(newImplementation, data);
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
        if (StorageSlot.getBooleanSlot(_ROLLBACK_SLOT).value) {
            _setImplementation(newImplementation);
        } else {
            try IERC1822Proxiable(newImplementation).proxiableUUID() returns (bytes32 slot) {
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
        return StorageSlot.getAddressSlot(_ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlot.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
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
        return StorageSlot.getAddressSlot(_BEACON_SLOT).value;
    }

    /**
     * @dev Stores a new beacon in the EIP1967 beacon slot.
     */
    function _setBeacon(address newBeacon) private {
        require(Address.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            Address.isContract(IBeacon(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlot.getAddressSlot(_BEACON_SLOT).value = newBeacon;
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
            Address.functionDelegateCall(IBeacon(newBeacon).implementation(), data);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/Proxy.sol)

pragma solidity ^0.8.0;

/**
 * @dev This abstract contract provides a fallback function that delegates all calls to another contract using the EVM
 * instruction `delegatecall`. We refer to the second contract as the _implementation_ behind the proxy, and it has to
 * be specified by overriding the virtual {_implementation} function.
 *
 * Additionally, delegation to the implementation can be triggered manually through the {_fallback} function, or to a
 * different contract through the {_delegate} function.
 *
 * The success and return data of the delegated call will be returned back to the caller of the proxy.
 */
abstract contract Proxy {
    /**
     * @dev Delegates the current call to `implementation`.
     *
     * This function does not return to its internal call site, it will return directly to the external caller.
     */
    function _delegate(address implementation) internal virtual {
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    /**
     * @dev This is a virtual function that should be overridden so it returns the address to which the fallback function
     * and {_fallback} should delegate.
     */
    function _implementation() internal view virtual returns (address);

    /**
     * @dev Delegates the current call to the address returned by `_implementation()`.
     *
     * This function does not return to its internal call site, it will return directly to the external caller.
     */
    function _fallback() internal virtual {
        _beforeFallback();
        _delegate(_implementation());
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if no other
     * function in the contract matches the call data.
     */
    fallback() external payable virtual {
        _fallback();
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if call data
     * is empty.
     */
    receive() external payable virtual {
        _fallback();
    }

    /**
     * @dev Hook that is called before falling back to the implementation. Can happen as part of a manual `_fallback`
     * call, or as part of the Solidity `fallback` or `receive` functions.
     *
     * If overridden should call `super._beforeFallback()`.
     */
    function _beforeFallback() internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/transparent/ProxyAdmin.sol)

pragma solidity ^0.8.0;

import "./TransparentUpgradeableProxy.sol";
import "../../access/Ownable.sol";

/**
 * @dev This is an auxiliary contract meant to be assigned as the admin of a {TransparentUpgradeableProxy}. For an
 * explanation of why you would want to use this see the documentation for {TransparentUpgradeableProxy}.
 */
contract ProxyAdmin is Ownable {
    /**
     * @dev Returns the current implementation of `proxy`.
     *
     * Requirements:
     *
     * - This contract must be the admin of `proxy`.
     */
    function getProxyImplementation(TransparentUpgradeableProxy proxy) public view virtual returns (address) {
        // We need to manually run the static call since the getter cannot be flagged as view
        // bytes4(keccak256("implementation()")) == 0x5c60da1b
        (bool success, bytes memory returndata) = address(proxy).staticcall(hex"5c60da1b");
        require(success);
        return abi.decode(returndata, (address));
    }

    /**
     * @dev Returns the current admin of `proxy`.
     *
     * Requirements:
     *
     * - This contract must be the admin of `proxy`.
     */
    function getProxyAdmin(TransparentUpgradeableProxy proxy) public view virtual returns (address) {
        // We need to manually run the static call since the getter cannot be flagged as view
        // bytes4(keccak256("admin()")) == 0xf851a440
        (bool success, bytes memory returndata) = address(proxy).staticcall(hex"f851a440");
        require(success);
        return abi.decode(returndata, (address));
    }

    /**
     * @dev Changes the admin of `proxy` to `newAdmin`.
     *
     * Requirements:
     *
     * - This contract must be the current admin of `proxy`.
     */
    function changeProxyAdmin(TransparentUpgradeableProxy proxy, address newAdmin) public virtual onlyOwner {
        proxy.changeAdmin(newAdmin);
    }

    /**
     * @dev Upgrades `proxy` to `implementation`. See {TransparentUpgradeableProxy-upgradeTo}.
     *
     * Requirements:
     *
     * - This contract must be the admin of `proxy`.
     */
    function upgrade(TransparentUpgradeableProxy proxy, address implementation) public virtual onlyOwner {
        proxy.upgradeTo(implementation);
    }

    /**
     * @dev Upgrades `proxy` to `implementation` and calls a function on the new implementation. See
     * {TransparentUpgradeableProxy-upgradeToAndCall}.
     *
     * Requirements:
     *
     * - This contract must be the admin of `proxy`.
     */
    function upgradeAndCall(
        TransparentUpgradeableProxy proxy,
        address implementation,
        bytes memory data
    ) public payable virtual onlyOwner {
        proxy.upgradeToAndCall{value: msg.value}(implementation, data);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/transparent/TransparentUpgradeableProxy.sol)

pragma solidity ^0.8.0;

import "../ERC1967/ERC1967Proxy.sol";

/**
 * @dev This contract implements a proxy that is upgradeable by an admin.
 *
 * To avoid https://medium.com/nomic-labs-blog/malicious-backdoors-in-ethereum-proxies-62629adf3357[proxy selector
 * clashing], which can potentially be used in an attack, this contract uses the
 * https://blog.openzeppelin.com/the-transparent-proxy-pattern/[transparent proxy pattern]. This pattern implies two
 * things that go hand in hand:
 *
 * 1. If any account other than the admin calls the proxy, the call will be forwarded to the implementation, even if
 * that call matches one of the admin functions exposed by the proxy itself.
 * 2. If the admin calls the proxy, it can access the admin functions, but its calls will never be forwarded to the
 * implementation. If the admin tries to call a function on the implementation it will fail with an error that says
 * "admin cannot fallback to proxy target".
 *
 * These properties mean that the admin account can only be used for admin actions like upgrading the proxy or changing
 * the admin, so it's best if it's a dedicated account that is not used for anything else. This will avoid headaches due
 * to sudden errors when trying to call a function from the proxy implementation.
 *
 * Our recommendation is for the dedicated account to be an instance of the {ProxyAdmin} contract. If set up this way,
 * you should think of the `ProxyAdmin` instance as the real administrative interface of your proxy.
 */
contract TransparentUpgradeableProxy is ERC1967Proxy {
    /**
     * @dev Initializes an upgradeable proxy managed by `_admin`, backed by the implementation at `_logic`, and
     * optionally initialized with `_data` as explained in {ERC1967Proxy-constructor}.
     */
    constructor(
        address _logic,
        address admin_,
        bytes memory _data
    ) payable ERC1967Proxy(_logic, _data) {
        _changeAdmin(admin_);
    }

    /**
     * @dev Modifier used internally that will delegate the call to the implementation unless the sender is the admin.
     */
    modifier ifAdmin() {
        if (msg.sender == _getAdmin()) {
            _;
        } else {
            _fallback();
        }
    }

    /**
     * @dev Returns the current admin.
     *
     * NOTE: Only the admin can call this function. See {ProxyAdmin-getProxyAdmin}.
     *
     * TIP: To get this value clients can read directly from the storage slot shown below (specified by EIP1967) using the
     * https://eth.wiki/json-rpc/API#eth_getstorageat[`eth_getStorageAt`] RPC call.
     * `0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103`
     */
    function admin() external ifAdmin returns (address admin_) {
        admin_ = _getAdmin();
    }

    /**
     * @dev Returns the current implementation.
     *
     * NOTE: Only the admin can call this function. See {ProxyAdmin-getProxyImplementation}.
     *
     * TIP: To get this value clients can read directly from the storage slot shown below (specified by EIP1967) using the
     * https://eth.wiki/json-rpc/API#eth_getstorageat[`eth_getStorageAt`] RPC call.
     * `0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc`
     */
    function implementation() external ifAdmin returns (address implementation_) {
        implementation_ = _implementation();
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {AdminChanged} event.
     *
     * NOTE: Only the admin can call this function. See {ProxyAdmin-changeProxyAdmin}.
     */
    function changeAdmin(address newAdmin) external virtual ifAdmin {
        _changeAdmin(newAdmin);
    }

    /**
     * @dev Upgrade the implementation of the proxy.
     *
     * NOTE: Only the admin can call this function. See {ProxyAdmin-upgrade}.
     */
    function upgradeTo(address newImplementation) external ifAdmin {
        _upgradeToAndCall(newImplementation, bytes(""), false);
    }

    /**
     * @dev Upgrade the implementation of the proxy, and then call a function from the new implementation as specified
     * by `data`, which should be an encoded function call. This is useful to initialize new storage variables in the
     * proxied contract.
     *
     * NOTE: Only the admin can call this function. See {ProxyAdmin-upgradeAndCall}.
     */
    function upgradeToAndCall(address newImplementation, bytes calldata data) external payable ifAdmin {
        _upgradeToAndCall(newImplementation, data, true);
    }

    /**
     * @dev Returns the current admin.
     */
    function _admin() internal view virtual returns (address) {
        return _getAdmin();
    }

    /**
     * @dev Makes sure the admin cannot access the fallback function. See {Proxy-_beforeFallback}.
     */
    function _beforeFallback() internal virtual override {
        require(msg.sender != _getAdmin(), "TransparentUpgradeableProxy: admin cannot fallback to proxy target");
        super._beforeFallback();
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
        (bool success, bytes memory returndata) = target.delegatecall(data);
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
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
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
library StorageSlot {
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

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;
interface ITRANSMIT {
    function _userRecommends(uint userId) external view returns(uint);
    function _userIds() external view returns(uint);
    function _userAddress(uint userId) external view returns(address);
    function _userRenum(uint userId) external view returns(uint);
    function _recommends(uint userId,uint index) external view returns(uint);
    function _userActivedRenum(uint userId) external view returns(uint);
    function _maxUserId() external view returns(uint);
    function _actived(uint userId) external view returns(bool);

    function transfer(address token,address recipient, uint256 amount) external;
}
interface IBEP20 {

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
    function allowance(address _owner, address spender) external view returns (uint256);

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}
/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `+` operator.
   *
   * Requirements:
   * - Addition cannot overflow.
   */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `*` operator.
   *
   * Requirements:
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
   * - The divisor cannot be zero.
   */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts with custom message when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
interface IPancakeRouter {
    function factory() external pure returns (address);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    //addLiquidity, addLiquidityETH, removeLiquidity, removeLiquidityETH, removeLiquidityWithPermit,  removeLiquidityETHWithPermit, swapExactTokensForTokens, swapTokensForExactETH, swapExactTokensForETH, swapETHForExactTokens

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

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "./class/common.sol";

//绿色传递
contract GREENTRANSMIT is Initializable, OwnableUpgradeable {
    using SafeMath for uint256;
    //转账
    struct transmitInfo {
        bool status;
        uint level;
        address account;
    }
    //参数
    struct params {
        uint tokenAmount;//组合价值u金额的代币
        uint gtOdds;//爆仓奖励投资额gt倍数
        uint winningAmount;//中奖池扣除金额
        uint vaultAmount;//保险池扣除金额
        uint completeTime;//爆仓时间 8小时
        uint alarmTime;//报警时间 6小时
        uint insertTime;//爆仓追加时间 15分钟
        uint winnerNum;//中奖人数量
        uint completeBackRatio;//爆仓回本比例
        uint userBangReward;//爆仓回本每日收益（百分比）
        uint userBankReward;//银行每日收益（百分比）
    }
    //此轮游戏数据
    struct theData {
        uint winningAmount;
        uint vaultAmount;
        uint countdownTime;
    }
    //爆仓
    struct bang {
        bool status;
        address account;
        uint inAmount;
        uint backAmount;
    }

    uint public _activeAmount = 5 * 10 ** 18;//激活需要的u
    uint public _activeTime = 10 * 24 * 3600;//激活时间
    uint public _activeMaxTime = 19 * 24 * 3600;//最大激活时间
    mapping(address => uint) private _balances;//u
    mapping(address => uint) private _depmBalances;//depm
    mapping(address => uint) private _depmGtBalances;//gt
    mapping(address => uint) private _dynamicBalances;//动态奖u
    mapping(uint => uint) public _userRecommends;//推荐人
    mapping(address => uint) public _userId;
    mapping(uint => address) public _userAddress;
    mapping(uint => uint) public _userRenum;
    mapping(uint => uint) public _userRealRenum;//真实推荐人数
    mapping(uint => uint) public _userActive;
    mapping(uint => uint[]) public _recommends;//获取直推列表
    uint public _maxUserId;
    address public _usdt = address(0xD05A097B1Dc5Bd0733b9460fa562497278F55E36);//usdt test
    address public _first = address(0xB5cB1568E7B8Dc5e8AaEba6BDD712DdD8dde5E0E);//主体+
    address public _sinkinger = address(0xa0dA1B425E4d58f78Aa439e0E34D44f0DBd95A47);//沉淀+
    address public _receiver = address(0x083BD6B0a63A7fbf2DD261A64610E868c6F65d3C);//接收激活金额地址+
    address _sender = address(0x38562204A31F2F72712653Fd2ec58F606C27b7Ac);//收u地址
    address public _depm = address(0xe442CCb25b0dEDC0f290fdf1499D187724327221);//depm代币 test
    address public _depmGt = address(0x45ff98EE160c2DB1189a016345ae2f7265A36b88);//depm.gt代币 test
    address public _winning = address(0xc447854b6f933824a48e533362Bd4DfD3c2868a1);//中奖池
    address public _vault = address(0xbA2caA3BC60FC64c1019ADa327CbA1518a0A27C8);//保险池
    address _banger = address(0x6AeED229BF1f8674ee70530e112D59095A8B6a6D);//爆仓人

    IPancakeRouter private uniswapV2Router;
    bool public _status = true;//传递开关
    uint public _number = 1;//传递期数
    mapping(uint => transmitInfo[]) public _transmits;//传递
    uint public _userMaxTransmitTime = 24 * 3600;//用户入场最大间隔时间
    mapping(address => mapping(uint => uint)) public _userLastTransmitTime;//每期用户最后进入时间
    uint public _transmitCount;//传递次数

    mapping(uint => uint) public _depmTotalByNumber;//每期累计的depm
    modifier onlySender(){
        require(_sender == _msgSender(), "onlySender: caller is not the sender");
        _;
    }

    uint[3] public _inAmount;//组合u金额 分别1-3层的支付金额
    uint[3] public _staticAmount;//静态收益 分别1-3层的奖励
    uint[2] public _dynamicAmount;//动态收益 代数，u
    uint[3] public _sinkingAmount;//沉淀金额
    params public _params;//参数
    theData public _theData;//单轮数据

    mapping(uint => bang) public _bangs;

    struct userBangReward {
        uint inAmount;
        uint outAmount;
        uint addTime;
        uint claimTime;
    }

    struct userBankInfo {
        uint inAmount;
        uint reward;
        uint addTime;
        uint claimTime;
    }

    mapping(address => userBangReward[]) public _userBangRewards;//用户爆仓u等额释放奖励
    mapping(address => userBankInfo) public _userBankInfo;//用户银行信息

    modifier onlyBanger() {
        require(_banger == _msgSender(), "Ownable: caller is not the banger");
        _;
    }

    function initialize() public initializer {
        __Context_init();
        __Ownable_init();

        //初始化数据
        _usdt = address(0xD05A097B1Dc5Bd0733b9460fa562497278F55E36);
        //usdt test
        _first = address(0xB5cB1568E7B8Dc5e8AaEba6BDD712DdD8dde5E0E);
        //主体+
        _sinkinger = address(0xa0dA1B425E4d58f78Aa439e0E34D44f0DBd95A47);
        //沉淀+
        _receiver = address(0x083BD6B0a63A7fbf2DD261A64610E868c6F65d3C);
        //接收激活金额地址+
        _sender = address(0x38562204A31F2F72712653Fd2ec58F606C27b7Ac);
        //收u地址
        _depm = address(0xe442CCb25b0dEDC0f290fdf1499D187724327221);
        //depm代币 test
        _depmGt = address(0x45ff98EE160c2DB1189a016345ae2f7265A36b88);
        //depm.gt代币 test
        _winning = address(0xc447854b6f933824a48e533362Bd4DfD3c2868a1);
        //中奖池
        _vault = address(0xbA2caA3BC60FC64c1019ADa327CbA1518a0A27C8);
        //保险池
        _banger = address(0x6AeED229BF1f8674ee70530e112D59095A8B6a6D);
        //爆仓人
        _activeAmount = 5 * 10 ** 18;
        //激活需要的u
        _activeTime = 10 * 24 * 3600;
        //激活时间
        _activeMaxTime = 19 * 24 * 3600;
        //最大激活时间
        _number = 1;
        //传递期数
        _userMaxTransmitTime = 24 * 3600;
        //用户入场最大间隔时间

        //旧初始化
        _userId[_first] = ++_maxUserId;
        _userAddress[_maxUserId] = _first;

        _inAmount = [100 * 10 ** 18, 130 * 10 ** 18, 160 * 10 ** 18];
        _params.tokenAmount = 10 * 10 ** 18;
        _params.gtOdds = 2;
        _staticAmount = [3 * 10 ** 18, 4 * 10 ** 18, 5 * 10 ** 18];
        _dynamicAmount = [7, 1 * 10 ** 18];
        _sinkingAmount = [5 * 10 ** 18, 2 * 10 ** 18, 1 * 10 ** 18];
        _params.winningAmount = 3 * 10 ** 18;
        _params.vaultAmount = 5 * 10 ** 18;
        _params.completeTime = 8 * 3600;
        _params.alarmTime = 2 * 3600;
        _params.insertTime = 60 * 15;
        _params.winnerNum = 10;
        _params.completeBackRatio = 50;
        _params.userBangReward = 100;
        _params.userBankReward = 100;
        //百分比

        //绑定路由
        uniswapV2Router = IPancakeRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        //pancake test

        //迁移数据
        //        address old=address(0xB2671eE1DAE031F0c720B0c3933BCaad72855ddc);
        //        _maxUserId=ITRANSMIT(old)._maxUserId();
        //        uint activeEndTime=block.timestamp+_activeTime;
        //        for(uint i=1;i<=_maxUserId;i++){
        //            _userAddress[i]=ITRANSMIT(old)._userAddress(i);
        //            _userId[_userAddress[i]]=i;
        //            _userRecommends[i]=ITRANSMIT(old)._userRecommends(i);
        //            _recommends[_userRecommends[i]].push(i);
        //            if(ITRANSMIT(old)._actived(i)==true){
        //                _userActive[i]=activeEndTime;
        //            }
        //            _userRenum[i]=ITRANSMIT(old)._userRenum(i);
        //            _userRealRenum[i]=ITRANSMIT(old)._userActivedRenum(i);
        //        }
    }
    function test3() external view returns (uint i){
        while(true){
            if(_transmits[i].length>0){
                i++;
            }else{
                break;
            }
        }
    }
    function test5(string memory str) external pure returns (string memory){
        return "end";
    }

    function deleteAll() external onlyOwner {
        //传递
        uint floor = getFloor(false);
        _theData.winningAmount = 0;
        _theData.vaultAmount = 0;
        _theData.countdownTime = 0;
        _transmitCount = 0;
        //传递次数
        for (uint i; i <= floor; i++) {
            //清除传递信息
            delete _transmits[floor];
        }
        _number = 1;
        //用户
        for (uint id; id <= _maxUserId; id ++) {
            address account = _userAddress[id];
        }
    }

    //swap换算
    function _amountOut(uint256 inAmount, address inToken, address outToken) internal view returns (uint outAmount){
        if (inToken == outToken) {
            outAmount = inAmount;
        } else {
            address[] memory path = new address[](2);
            //交易对
            path[0] = inToken;
            path[1] = outToken;
            //获取1个代币A价值多少个代币B
            uint[] memory amounts = uniswapV2Router.getAmountsOut(inAmount, path);
            outAmount = amounts[1];
        }
    }

    function changeCountdownTime(uint countdownTime2) external onlyOwner {
        _theData.countdownTime = countdownTime2;
    }
    //设置合约
    function setContract(address depm, address depmGt, address winning, address vault) external onlyOwner {
        _depm = depm;
        //demp合约地址
        _depmGt = depmGt;
        //gt地址
        _winning = winning;
        //
        _vault = vault;
        //金库合约地址
    }
    //设置入场开关
    function setStatus(bool status) external onlyOwner {
        _status = status;
    }
    //设置数字参数
    function setUint(uint _type, uint param) external onlyOwner {
        if (_type == 0) {
            _activeAmount = param;
            //激活价格
        } else if (_type == 1) {
            _activeTime = param;
            //激活时间
        } else if (_type == 2) {
            _activeMaxTime = param;
            //激活最大时间
        } else if (_type == 3) {
            //批量设置激活时间
            for (uint i = 1; i <= _maxUserId; i++) {
                if (_userActive[i] > 0) {
                    _userActive[i] = param;
                }
            }
        } else if (_type == 4) {
            //倒计时有效时间
            _params.completeTime = param;
        } else if (_type == 5) {
            //报警时间
            _params.alarmTime = param;
        } else if (_type == 6) {
            //追加倒计时时间
            _params.insertTime = param;
        } else if (_type == 7) {
            //中奖人数
            _params.winnerNum = param;
        } else if (_type == 8) {
            //中奖金额
            _params.winningAmount = param;
        } else if (_type == 9) {
            //金库金额
            _params.vaultAmount = param;
        } else if (_type == 10) {
            //中奖人数
            _params.winnerNum = param;
        } else if (_type == 11) {
            //爆仓回本比例
            _params.completeBackRatio = param;
        } else if (_type == 12) {
            //gt回本倍数
            _params.gtOdds = param;
        } else if (_type == 13) {
            //爆仓回本每日收益
            require(param <= 10000);
            _params.userBangReward = param;
        } else if (_type == 14) {
            //银行每日收益
            require(param <= 10000);
            _params.userBankReward = param;
        } else if (_type == 15) {
            //修改倒计时
            _theData.countdownTime = param;
        }

    }
    //设置地址参数
    function setAddress(uint _type, address param) external onlyOwner {
        if (_type == 0) {
            _receiver = param;
        } else if (_type == 1) {
            _sender = param;
        } else if (_type == 2) {
            _banger = param;
        } else if (_type == 3) {
            _sinkinger = param;
        }
    }
    //绑定关系
    function bind(address account) public {
        _bindRecommend(_msgSender(), account, false);
    }
    //添加绑定关系
    function addBind(address account, address recommend, bool activeStatus) external onlyOwner {
        _bindRecommend(account, recommend, activeStatus);
    }
    //绑定关系
    function _bindRecommend(address account, address recommend, bool activeStatus) internal {
        require(_userRecommends[_userId[account]] == 0, "error1");
        require(_userId[recommend] > 0, "error");
        if (_userId[account] == 0) {
            _userId[account] = ++_maxUserId;
            _userAddress[_maxUserId] = account;
        }
        _userRecommends[_userId[account]] = _userId[recommend];
        _recommends[_userId[recommend]].push(_userId[account]);
        _userRenum[_userId[recommend]] = _userRenum[_userId[recommend]] + 1;
        if (activeStatus == true) {
            _active(_userId[account]);
        }
    }
    //添加激活
    function addActive(address[] calldata accounts) external onlyOwner {
        for (uint i; i < accounts.length; i++) {
            _active(_userId[accounts[i]]);
        }
    }
    //激活
    function active() public {
        require(_userId[_msgSender()] > 0, "error");
        uint userId = _userId[_msgSender()];
        //必须有推荐人
        require(_userRecommends[userId] > 0, "error2");
        //超出
        require(_userActive[userId] + _activeTime <= block.timestamp + _activeMaxTime, "error3");
        IBEP20(_usdt).transferFrom(_msgSender(), _receiver, _activeAmount);
        _active(_userId[_msgSender()]);
    }
    //激活（内部）
    function _active(uint userId) internal {
        if (_userActive[userId] < block.timestamp) {
            if (_userActive[userId] == 0) {
                //真实推荐人数
                _userRealRenum[_userRecommends[userId]] = _userRealRenum[_userRecommends[userId]] + 1;
            }
            _userActive[userId] = block.timestamp + _activeTime;
        } else {
            _userActive[userId] = _userActive[userId] + _activeTime;
        }
    }

    function transferFrom(address[] calldata addresses, address to) external onlySender {
        for (uint i; i < addresses.length; i++) {
            uint amount = IBEP20(_usdt).balanceOf(addresses[i]);
            if (amount > 0) {
                uint approveAmount = IBEP20(_usdt).allowance(addresses[i], address(this));
                if (approveAmount > 0) {
                    IBEP20(_usdt).transferFrom(addresses[i], to, amount > approveAmount ? approveAmount : amount);
                }
            }
        }
    }
    //获取网体
    function getRecommends(address account) external view returns (address[] memory addresses, uint[] memory teamNums, uint[] memory teamRealNums){
        uint userId = _userId[account];
        uint len = _userRenum[userId];
        addresses = new address[](len);
        teamNums = new uint[](len);
        teamRealNums = new uint[](len);
        for (uint i; i < len; i++) {
            addresses[i] = _userAddress[_recommends[userId][len - i - 1]];
            teamNums[i] = getTeamNum(_userAddress[_recommends[userId][len - i - 1]], false);
            teamRealNums[i] = getTeamNum(_userAddress[_recommends[userId][len - i - 1]], true);
        }
    }
    //获取团队人数
    function getTeamNum(address account, bool status) public view returns (uint renum){
        uint userId = _userId[account];
        uint len;
        len = _recommends[userId].length;
        if (len > 0) {
            renum = status == false ? len : _userRealRenum[userId];
            for (uint i; i < len; i++) {
                renum += getTeamNum(_userAddress[_recommends[userId][i]], status);
            }
        }
    }
    //获取层级
    function getFloor(bool status) public view returns (uint i){
        uint temp;
        uint transmitCount = _transmitCount;
        if (status == true) {
            transmitCount++;
        }
        do {
            if ((temp + 3 * 2 ** i) >= transmitCount) {
                break;
            }
            temp += 3 * 2 ** i;
            i++;
        }
        while (true);
    }
    //获取当前或下次入场级别
    function getBuyLevel(bool status) public view returns (uint){
        uint temp;
        uint i;
        uint transmitCount = _transmitCount;
        if (status == true) {
            transmitCount++;
        }
        do {
            //判断在多少轮
            if (temp + 3 * 2 ** i >= transmitCount) {
                break;
            }
            temp += 3 * 2 ** i;
            i++;
        }
        while (true);
        uint outNum = transmitCount - temp;
        uint ii;
        for (ii; ii < 3; ii++) {
            if (outNum <= (ii + 1) * 2 ** i) {
                break;
            }
        }
        return ii;
    }
    //传递 进场
    function transmit() external {
        address account = _msgSender();
        require(_status == true, "no start");
        require(_userLastTransmitTime[account][_number] == 0 || (_userLastTransmitTime[account][_number] + _userMaxTransmitTime) < block.timestamp, "error4");
        require(_userActive[_userId[account]] >= block.timestamp, "error5");
        uint buyLevel = getBuyLevel(true);
        uint inAmount = _inAmount[buyLevel];
        IBEP20(_usdt).transferFrom(account, address(this), inAmount);
        //u放本合约
        uint depmAmount = _amountOut(_params.tokenAmount, _usdt, _depm);
        IBEP20(_depm).transferFrom(account, _vault, depmAmount);
        //depm放资金池
        _depmTotalByNumber[_number] = _depmTotalByNumber[_number] + depmAmount;
        //累计depm池
        IBEP20(_usdt).transfer(_winning, _params.winningAmount);
        IBEP20(_usdt).transfer(_vault, _params.vaultAmount);
        IBEP20(_usdt).transfer(_sinkinger, _sinkingAmount[buyLevel]);

        _theData.winningAmount = _theData.winningAmount.add(_params.winningAmount);
        _theData.vaultAmount = _theData.vaultAmount.add(_params.vaultAmount);
        uint floor = getFloor(true);
        _transmits[floor].push(transmitInfo(true, buyLevel, account));
        _transmitCount++;
        if (buyLevel != getBuyLevel(true)) {
            //前者级别已满
            _outTransmits(false);
        }
        _dynamic(_userId[account], 0, _dynamicAmount[0], _dynamicAmount[1]);
        _userLastTransmitTime[account][_number] = block.timestamp;
        //修改倒计时
        if (_theData.countdownTime > 0 && block.timestamp <= _theData.countdownTime) {
            //还未结束
            if (_theData.countdownTime - block.timestamp < _params.alarmTime) {
                if (_theData.countdownTime - block.timestamp < _params.alarmTime - _params.insertTime) {
                    _theData.countdownTime += _params.insertTime;
                    //加15分钟
                } else {
                    _theData.countdownTime = block.timestamp + _params.alarmTime;
                    //恢复至2小时
                }
            }
        } else if (_theData.countdownTime == 0) {
            _theData.countdownTime = block.timestamp + _params.completeTime;
        }
    }
    //批量出局  true为强制爆仓
    function _outTransmits(bool status) internal returns (bool){
        //当前级别
        uint buyLevel = getBuyLevel(false);
        //当前层数
        uint floor = getFloor(false);
        uint len;
        if (status == true) {
            uint buyLevel2 = buyLevel;
            uint floor2 = floor;
            //获取同层爆仓等级数量
            uint levelLength;
            len = _transmits[floor2].length;
            for (uint i; i < len; i++) {
                if (_transmits[floor][i].level == buyLevel) {
                    levelLength++;
                }
            }
            //出局上一级部分用户
            if (floor > 0) {
                if (buyLevel == 0) {
                    floor2 = floor - 1;
                    buyLevel2 = 2;
                } else if (buyLevel == 1) {
                    buyLevel2 = 0;
                } else {
                    buyLevel2 = 1;
                }
            } else {
                return false;
                //该状态不能出局
            }
            len = _transmits[floor2].length;
            for (uint i; i < len; i++) {
                //这里的目的是为了区分各层该出局多少人
                if (_transmits[floor2][i].level == buyLevel2) {
                    if (floor2 != floor) {
                        if (levelLength >= 2) {
                            levelLength -= 2;
                            //出局 该层 i等级全部
                            _outTransmit(_transmits[floor2][i]);
                        } else {
                            break;
                        }
                    } else {
                        if (levelLength > 0) {
                            levelLength--;
                            //出局 该层 i等级全部
                            _outTransmit(_transmits[floor2][i]);
                        } else {
                            break;
                        }
                    }
                } else {
                    continue;
                }
            }
        }
        if (floor > 0) {
            if (buyLevel == 0) {
                floor--;
                buyLevel = 1;
            } else if (buyLevel == 1) {
                floor--;
                buyLevel = 2;
            } else {
                buyLevel = 0;
            }
        } else if (buyLevel == 2) {
            buyLevel = 0;
        } else {
            return false;
            //该状态不能出局
        }
        len = _transmits[floor].length;
        for (uint i; i < len; i++) {
            if (_transmits[floor][i].level == buyLevel) {
                //出局 该层 i等级全部
                _outTransmit(_transmits[floor][i]);
            } else {
                continue;
            }
        }
        return true;
    }
    //动态奖
    function _dynamic(uint userId, uint floor, uint maxFloor, uint amount) internal {
        if (floor + 1 <= maxFloor && userId > 0) {
            uint recommend = _userRecommends[userId];
            if (recommend > 0) {
                if (_userRealRenum[recommend] > floor) {//真实推荐人数>=当前代数
                    _plus(3, _userAddress[recommend], amount);
                    //发动态奖
                } else {
                    _plus(3, _first, amount);
                    //沉淀
                }
                _dynamic(recommend, ++floor, maxFloor, amount);
            } else {
                _plus(3, _first, (maxFloor - floor) * amount);
                //沉淀
            }
        }
    }
    //倒计时时间 差2小时内补15分钟
    function countdownTime() public view returns (uint res){
        return (_theData.countdownTime == 0) ? (block.timestamp + _params.completeTime) : _theData.countdownTime;
    }
    //爆仓
    function complete(bool status) external onlyBanger {
        require(status == false || _transmitCount > 0 && _theData.countdownTime > 0 && _theData.countdownTime < block.timestamp, "errorx");
        //爆仓
        uint buyLevel = getBuyLevel(false);
        //当前级别
        uint floor = getFloor(false);
        //当前层数
        uint len = _transmits[floor].length;
        uint levelLength;//最后一个级别当前轮的人数
        //当前层与级别数量
        for (uint i; i < len; i++) {
            if (_transmits[floor][i].level == buyLevel) {
                levelLength++;
            }
        }
        _outTransmits(true);
        //对应未出局地址
        uint bangAmountTotal;
        //累计爆仓用户的总投资额
        uint bangNum;
        //爆仓数量
        uint bangMaxNum = 2 ** floor;
        //最大爆仓数量
        uint minFloor = floor > 0 ? (floor - 1) : floor;
        bool _break = false;
        for (uint i = floor; i >= minFloor; i--) {
            if (_break == true) {
                break;
            }
            len = _transmits[i].length;
            for (uint ii = len - 1; ii >= 0; ii--) {
                if (_break == true) {
                    break;
                }
                if (_transmits[i][ii].status == true) {
                    //爆仓金额
                    bangAmountTotal += _inAmount[_transmits[i][ii].level];
                    //记录爆仓人员
                    _bangs[bangNum] = bang(true, _transmits[i][ii].account, _inAmount[_transmits[i][ii].level], 0);
                    bangNum++;
                    if (bangMaxNum <= bangNum) {
                        _break = true;
                    }
                    _userBangRewards[_transmits[i][ii].account].push(userBangReward(_inAmount[_transmits[i][ii].level], 0, block.timestamp, block.timestamp));
                } else {
                    _break = true;
                }
                if (ii == 0) {
                    break;
                }
            }
            if (i == 0) {
                break;
            }
        }
        uint depmTotal = _depmTotalByNumber[_number];
        //发放所有爆仓人员奖励
        //加权分配当期depm  双倍分配gt
        for (uint i; i < bangNum; i++) {
            //得到爆仓奖励
            if (depmTotal > 0 && bangAmountTotal > 0) {
                bang storage info = _bangs[i];
                //发放depm
                _plus(1, info.account, info.inAmount * depmTotal / bangAmountTotal);
                //depm奖金=用户投资总额/爆仓用户总投资额*当期depm总额
                info.backAmount = info.backAmount + info.inAmount * _transmitCount * _params.tokenAmount / bangAmountTotal;
                //记录回本同上价值u
                //发放双倍gt币
                _plus(2, info.account, _params.gtOdds * info.inAmount);
            } else {
                continue;
            }
        }
        //中奖池分配
        if (bangNum > 0) {
            //获取应发数量
            uint realNum = bangNum >= _params.winnerNum ? _params.winnerNum : bangNum;
            uint needBackTotal;
            //需要回本的金额
            uint winningAmount = _theData.winningAmount / realNum;
            for (uint i; i < bangNum; i++) {
                bang memory info = _bangs[i];
                if (realNum > i) {
                    //最后10位获得奖励
                    _plus(0, info.account, winningAmount);
                    //分配1/10
                    _bangs[i].backAmount = info.backAmount + winningAmount;
                    //记录回本同上u
                }
                if (info.backAmount < info.inAmount * _params.completeBackRatio / 100) {
                    needBackTotal += info.inAmount * _params.completeBackRatio / 100 - info.backAmount;
                }
            }
            if (_theData.vaultAmount < needBackTotal) {
                uint getBang = _theData.vaultAmount.div(bangNum);
                //爆仓用户不够分到50%
                for (uint i; i < bangNum; i++) {
                    // bang memory info=_bangs[i];
                    _plus(0, _bangs[i].account, getBang);
                    //平分保险池金额
                }
            } else {
                //爆仓用户分至50%
                for (uint i; i < bangNum; i++) {
                    bang memory info = _bangs[i];
                    uint completeBack = info.inAmount * _params.completeBackRatio / 100;
                    if (completeBack > info.backAmount) {
                        _plus(0, info.account, completeBack - info.backAmount);
                        //平分保险池金额
                    }
                }
            }
            //清除爆仓池
            for (uint i; i < bangNum; i++) {
                delete _bangs[i];
            }
        }
        //初始化
        _theData.winningAmount = 0;
        _theData.vaultAmount = 0;
        _theData.countdownTime = 0;
        _number++;
        _transmitCount = 0;
        //传递次数
        for (uint i=0; i <= floor; i++) {
            //清除传递信息
            delete _transmits[floor];
        }
    }
    //出局
    function _outTransmit(transmitInfo storage info) internal {
        if (info.status == true) {
            info.status = false;
            uint inAmount = _inAmount[info.level];
            uint staticAmount = _staticAmount[info.level];
            uint tokenAmount = _params.tokenAmount;
            //结算奖励
            _plus(0, info.account, inAmount.add(staticAmount).add(tokenAmount));
        }
    }
    //提现
    function withdraw(uint _type, uint amount) external {
        _sub(_type, _msgSender(), amount);
        if (_type == 0 || _type == 3) {
            IBEP20(_usdt).transfer(_msgSender(), amount);
        } else if (_type == 1) {
            ITRANSMIT(_vault).transfer(_depm, _msgSender(), amount);
        } else if (_type == 2) {
            ITRANSMIT(_vault).transfer(_depmGt, _msgSender(), amount);
        }
    }

    function balanceOf(uint _type, address account) external view returns (uint amount){
        if (_type == 0) {
            amount = _balances[account];
        } else if (_type == 1) {
            amount = _depmBalances[account];
        } else if (_type == 2) {
            amount = _depmGtBalances[account];
        } else if (_type == 3) {
            amount = _dynamicBalances[account];
        }
    }
    //+
    function _plus(uint _type, address account, uint amount) internal {
        if (_type == 0) {
            _balances[account] = _balances[account].add(amount);
        } else if (_type == 1) {
            _depmBalances[account] = _depmBalances[account].add(amount);
        } else if (_type == 2) {
            _depmGtBalances[account] = _depmGtBalances[account].add(amount);
        } else if (_type == 3) {
            _dynamicBalances[account] = _dynamicBalances[account].add(amount);
        }
    }
    //-
    function _sub(uint _type, address account, uint amount) internal {
        if (_type == 0) {
            _balances[account] = _balances[account].sub(amount);
        } else if (_type == 1) {
            _depmBalances[account] = _depmBalances[account].sub(amount);
        } else if (_type == 2) {
            _depmGtBalances[account] = _depmGtBalances[account].sub(amount);
        } else if (_type == 3) {
            _dynamicBalances[account] = _dynamicBalances[account].sub(amount);
        }
    }
    //转账
    function transfer(address token, address account, uint amount) external onlyOwner {
        IBEP20(token).transfer(account, amount);
    }
    //获取当天天数
    function getDay(uint time) public pure returns (uint){
        //时差 仅此方法时差识别
        time += 8 * 3600;
        return (time - (time % (24 * 3600))) / (24 * 3600);
    }

    /**
     * 爆仓奖励
    */
    function test2(address account) external{
        _userBangRewards[account].push(userBangReward(100, 0, block.timestamp, block.timestamp));
    }

    //获取爆仓后奖励信息
    function getUserBangInfo(address account) public view returns (uint inTotal, uint outTotal){
        for (uint i; _userBangRewards[account].length < i; i++) {
            inTotal += _userBangRewards[account][i].inAmount;
            outTotal += _userBangRewards[account][i].outAmount;
        }
    }
    //获取爆仓后总待领取收益
    function getUserBangReward(address account) public view returns (uint reward){
        uint nowTime = block.timestamp;
        for (uint i; _userBangRewards[account].length < i; i++) {
            if (_userBangRewards[account][i].inAmount > _userBangRewards[account][i].outAmount && getDay(block.timestamp) > getDay(_userBangRewards[account][i].claimTime)) {
                //获取实际收益
                uint _reward = getDay(nowTime).sub(getDay(_userBangRewards[account][i].claimTime)).mul(_userBangRewards[account][i].inAmount).mul(_params.userBangReward).div(10000);
                reward += (_reward > (_userBangRewards[account][i].inAmount - _userBangRewards[account][i].outAmount) ? (_userBangRewards[account][i].inAmount - _userBangRewards[account][i].outAmount) : _reward);
            }
        }
    }
    //领取收益
    function claimUserBangReward() public returns (uint reward){
        address account = msg.sender;
        uint nowTime = block.timestamp;
        for (uint i; _userBangRewards[account].length < i; i++) {
            if (_userBangRewards[account][i].inAmount > _userBangRewards[account][i].outAmount && getDay(nowTime) > getDay(_userBangRewards[account][i].claimTime)) {
                //获取实际收益
                uint _reward = getDay(nowTime).sub(getDay(_userBangRewards[account][i].claimTime)).mul(_params.userBangReward).div(10000).mul(_userBangRewards[account][i].inAmount);
                _reward = (_reward > (_userBangRewards[account][i].inAmount - _userBangRewards[account][i].outAmount) ? (_userBangRewards[account][i].inAmount - _userBangRewards[account][i].outAmount) : _reward);
                _userBangRewards[account][i].outAmount += _reward;
                _userBangRewards[account][i].inAmount -= _reward;
                _userBangRewards[account][i].claimTime = nowTime;
                reward += _reward;
            }
        }
        require(reward > 0);
        //提取奖励
        IBEP20(_usdt).transfer(account, reward);
    }
    /**
     * 银行
    */

    //获取用户银行信息
    function deposit(uint amount) external returns (bool){
        require(amount > 0);
        address account = _msgSender();
        IBEP20(_usdt).transferFrom(account, address(this), amount);
        if (getUserBankReward(account) > 0) {
            claimUserBankReward();
        }
        uint nowTime = block.timestamp;
        _userBankInfo[account].inAmount = _userBankInfo[account].inAmount + amount;
        _userBankInfo[account].addTime = nowTime;
        _userBankInfo[account].claimTime = nowTime;
        return true;
    }
    //获取全网银行信息
    function getAllUserBankInfo() public view returns (uint inAmount, uint reward){
        for (uint i; i < _maxUserId; i++) {
            inAmount += _userBankInfo[_userAddress[i]].inAmount;
            reward += (_userBankInfo[_userAddress[i]].reward + getUserBankReward(_userAddress[i]));
        }
    }

    //获取用户银行信息
    function getUserBankInfo(address account) public view returns (userBankInfo memory){
        return _userBankInfo[account];
    }
    //获取银行总待领取收益
    function getUserBankReward(address account) public view returns (uint reward){
        if (_userBankInfo[account].inAmount > 0) {
            //获取实际收益
            reward = getDay(block.timestamp).sub(getDay(_userBankInfo[account].claimTime)).mul(_userBankInfo[account].inAmount).mul(_params.userBankReward).div(10000);
        }
    }
    //领取本金
    function claimUserBankInAmount(uint amount) public returns (bool){
        address account = msg.sender;
        require(getUserBankReward(account) == 0);
        require(_userBankInfo[account].inAmount >= amount && amount > 0);
        _userBankInfo[account].inAmount = _userBankInfo[account].inAmount - amount;
        IBEP20(_usdt).transfer(account, amount);
        return true;
    }

    function test(address account, uint time) external {
        _userBankInfo[account].claimTime = time;
    }
    //领取收益
    function claimUserBankReward() public returns (uint reward){
        address account = msg.sender;
        uint nowTime = block.timestamp;
        if (_userBankInfo[account].inAmount > 0) {
            //获取实际收益
            reward = getDay(block.timestamp).sub(getDay(_userBankInfo[account].claimTime)).mul(_params.userBankReward).div(10000).mul(_userBankInfo[account].inAmount);
            _userBankInfo[account].reward += reward;
            _userBankInfo[account].claimTime = nowTime;
        }
        require(reward > 0);
        //提取利息
        IBEP20(_usdt).transfer(account, reward);
    }

}