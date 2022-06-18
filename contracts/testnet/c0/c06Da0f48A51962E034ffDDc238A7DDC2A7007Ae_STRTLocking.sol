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
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/utils/Initializable.sol)

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

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./adminProxyManager.sol";
import "./TransferHelper.sol";

contract STRTLocking is Initializable, UUPSUpgradeable, OwnableUpgradeable, adminProxyManager {
    address public constant DEAD = 0x000000000000000000000000000000000000dEaD;
    uint64 internal constant monthInSecond = 86400 * 30;

    uint64 internal lockPeriod; // in seconds
    uint64 public penalty_d2; // charged when unlock before due date (decimal 2)
    uint64 public fee_d2; // charged when unlock after due date (decimal 2)
    uint64 public interest_d2; // decimal 2
    uint128 public minLock; // minimum locked value
    uint128 public maxLock; // minimum locked value
    uint128 public apy_d2; // apy in 2 decimals
    uint128 public tokenLocked; // token locked value
    uint128 public compoundingPeriods; // how many times compounding included in year
    uint128 public terms = 1; // in year

    address[] public members;

    address public token;
    bool public lockPaused;
    
    modifier isLockPaused{
        require(!lockPaused, "paused");
        _;
    }

    struct Detail {
        uint256 index;
        uint128 amount;
        uint128 rewardPerMonth;
        uint64 start;
        uint64 end;
        uint64 lastClaimed;
        uint64 rewardEnded;
    }
    
    mapping(address => Detail[]) public summaries;
    mapping(address => uint128) public locked;
    mapping(address => uint128) internal memberIndex;
    
    event Locked (address indexed _member, uint128 _amount, uint64 _lockedAt);
    event Claimed (address indexed _member, uint128 _amount, uint64 _claimedAt);
    event Unlocked (address indexed _member, uint128 _amount, uint64 _unlockedAt);

    function init(
        address _token,
        uint64 _interest_d2,
        uint64 _lockDurationInMonth,
        uint128 _minLock,
        uint128 _maxLock,
        uint128 _compoundingPeriods,
        uint64 _penalty_d2,
        uint64 _fee_d2
    ) external initializer proxied {
        __UUPSUpgradeable_init();
        __Ownable_init();
        __adminProxyManager_init(msg.sender);

        token = _token;
        interest_d2 = _interest_d2;
        lockPeriod = _lockDurationInMonth * 30 * 86400;
        minLock = _minLock;
        maxLock = _maxLock;
        compoundingPeriods = _compoundingPeriods;
        penalty_d2 = _penalty_d2;
        fee_d2 = _fee_d2;

        _setApy_d2();
    }

    function _authorizeUpgrade(address newImplementation) internal virtual override proxied {}
    

    /* ========== VIEW AREA BEGIN ========== */

    /**
     * @dev Gets the lock duration in month
     */
    function lockDuration() external view virtual returns (uint64){
        return (lockPeriod / 86400) / 30;
    }

    /**
     * @dev Gets the pending reward of member in specific lock index
     * @param _member Member address
     * @param _lockIndex Index of lock
     */
    function pendingRewards(
        address _member,
        uint256 _lockIndex
    ) external view virtual returns(uint128 rewardAmount, uint64 claimableAt){
        if(!everLocked(_member)) return(0,0);

        Detail memory summary = summaries[_member][_lockIndex];

        uint64 startDate;
        if(summary.lastClaimed == 0){
            startDate = summary.start;
        } else {
            if(uint64(block.timestamp) - summary.lastClaimed < monthInSecond) return (0,0);
            startDate = summary.lastClaimed;
        }

        uint64 endDate;
        if(summary.rewardEnded > 0){
            endDate = summary.rewardEnded;
        } else {
            endDate = uint64(block.timestamp);
        }

        (rewardAmount, claimableAt) = calcReward(summary.rewardPerMonth, startDate, endDate);
    }

    /**
     * @dev Reward calculation
     * @param _reward Reward per month
     * @param _start Start calculation (epoch)
     * @param _end End calculation (epoch)
     */
    function calcReward(
        uint128 _reward,
        uint64 _start,
        uint64 _end
    ) internal view virtual returns (uint128 rewardAmount, uint64 claimableAt) {
        uint64 monthPassed = (_end - _start) / monthInSecond;

        if(monthPassed == 0) return(0,0);
        
        claimableAt = _start + (monthPassed * monthInSecond);
        rewardAmount = _reward * monthPassed;
    }

    /**
     * @dev Check whether member had locked progress
     * @param _member Member address
     */
    function everLocked(address _member) internal view virtual returns(bool){
        return (summaries[_member].length > 0);
    }

    /**
     * @dev Get members length
     */
    function getMembersLength() external view virtual returns(uint256){
        return members.length;
    }

    /**
     * @dev Check an address is VIP or not
     */
    function isVIP(address _member) external view virtual returns(bool){
        return locked[_member] >= minLock;
    }

    /**
     * @dev Gets the length locked progress of member
     * @param _member Member address
     */
    function getUserLockedLength(address _member) external view virtual returns(uint256){
        return summaries[_member].length;
    } 

    /**
     * @dev Gets the total locked before specified date of member
     * @param _member Member address
     */
    function getLockedTokensBeforeDate(address _member, uint64 _before) external view virtual returns (uint128 lockedTokens) {
        uint256 locksLength = summaries[_member].length;
        for (uint256 i = 0; i < locksLength; i++) {
            if (summaries[_member][i].start <= _before) {
                lockedTokens += summaries[_member][i].amount;
            }
        }
    }

    /* ========== VIEW AREA END ========== */

    
    /* ========== MAIN AREA BEGIN ========== */

    /**
     * @dev Locks specified amount of tokens
     * @param _amount Token amount to be locked
     * @param _member Member address
     */
    function lock(uint128 _amount, address _member) external virtual isLockPaused {
        _lock(_amount, _member);
        TransferHelper.safeTransferFrom(token, _member, address(this), _amount);
    }

    /**
     * @dev Claim rewards at specified lock index of member
     * @param _lockIndex Index of lock
     * @param _member Member address
     */
    function claim(uint256 _lockIndex, address _member) public virtual isLockPaused {
        uint128 reward = _claim(_lockIndex, _member);
        _releaseToken(reward, _member, 0, 0);

        if(locked[_member] == 0) _removeMember(_member);
    }

    /**
     * @dev Unlock and get the rewards token at specified lock index of member
     * @param _lockIndex Index of lock
     * @param _member Member address
     */
    function withdraw(uint256 _lockIndex, address _member) external virtual isLockPaused {
        require(summaries[_member][_lockIndex].end <= uint64(block.timestamp), "bad");

        _unlock(_lockIndex, _member);
        claim(_lockIndex, _member);
    }

    /**
     * @dev Lock logic
     * @param _amount Token amount to be locked
     * @param _member Member address
     */
    function _lock(uint128 _amount, address _member) internal virtual {
        uint128 memberLockedAmount = locked[_member];
        require(memberLockedAmount + _amount >= minLock, "bad");

        uint64 dateTimeNow = uint64(block.timestamp);

        if(!everLocked(_member)){
            members.push(_member);
            memberIndex[_member] = uint128(members.length - 1);
        }

        // adjust the amount based on max token locked
        uint128 max = maxLock;
        if(max > 0 && memberLockedAmount + _amount >= max) _amount = max - memberLockedAmount;

        uint128 reward = uint128((apy_d2 * _amount) / (10000 * 12));
    
        summaries[_member].push(Detail(uint128(summaries[_member].length), _amount, reward, dateTimeNow, dateTimeNow + lockPeriod, 0, 0));
        locked[_member] += _amount;
        tokenLocked += _amount;

        emit Locked(_member, _amount, dateTimeNow);
    }

    /**
     * @dev Unlock the token at specified lock index of member
     * @param _lockIndex Index of lock
     * @param _member Member address
     */
    function _unlock(uint256 _lockIndex, address _member) internal virtual isLockPaused {
        uint64 dateTimeNow = uint64(block.timestamp);
        Detail memory summary = summaries[_member][_lockIndex];

        require(everLocked(_member), "bad");

        locked[_member] -= summary.amount;
        tokenLocked -= summary.amount;

        uint64 charged_d2;
        uint64 startDate;

        if(summary.end > dateTimeNow){
            charged_d2 = penalty_d2;
            startDate = summary.start;

            _removeLockIndex(_lockIndex, _member);
            if(locked[_member] == 0) _removeMember(_member);
        } else {
            charged_d2 = fee_d2;
            summaries[_member][_lockIndex].rewardEnded = dateTimeNow;
        }

        _releaseToken(summary.amount, _member, charged_d2, startDate);

        emit Unlocked(_member, summary.amount, dateTimeNow);
    }

    /**
     * @dev Claim logic
     * @param _lockIndex Index of lock
     * @param _member Member address
     */
    function _claim(uint256 _lockIndex, address _member) internal virtual returns(uint128 reward) {
        uint64 dateTimeNow = uint64(block.timestamp);
        Detail memory summary = summaries[_member][_lockIndex];

        require(everLocked(_member) && summary.end <= dateTimeNow, "bad");

        uint64 startDate;
        if(summary.lastClaimed == 0){
            startDate = summary.start;
        } else {
            require(dateTimeNow - summary.lastClaimed >= monthInSecond, "wait");
            startDate = summary.lastClaimed;
        }

        uint64 endDate;
        if(summary.rewardEnded > 0){
            endDate = summary.rewardEnded;
            
            _removeLockIndex(_lockIndex, _member);
        } else {
            endDate = dateTimeNow;
        }

        (reward, summaries[_member][_lockIndex].lastClaimed) = calcReward(summary.rewardPerMonth, startDate, endDate);

        emit Claimed(_member, reward, dateTimeNow);
    }

    /**
     * @dev Released token to specified member & charged amount to dead address (The closer to the end of lock, the cheaper fee it is)
     * @param _amount Token amount to be released
     * @param _member Member address
     * @param _charged_d2 Charged percent (2 decimals)
     * @param _start Start date (epoch) 
     */
    function _releaseToken(uint128 _amount, address _member, uint64 _charged_d2, uint64 _start) internal virtual {
        uint128 chargedAmount;
        if(_charged_d2 > 0){
            if(_start > 0) _charged_d2 = _charged_d2 - ((uint64(block.timestamp) - _start) * _charged_d2 / lockPeriod);
            
            chargedAmount = (_amount * uint128(_charged_d2)) / 10000;
            TransferHelper.safeTransfer(token, DEAD, chargedAmount);
        }

        TransferHelper.safeTransfer(token, _member, _amount - chargedAmount);
    }

    /**
     * @dev Remove lock when it was unlocked & claimed
     * @param _lockIndexToRemove Index of lock to remove
     * @param _member Member address
     */
    function _removeLockIndex(uint256 _lockIndexToRemove, address _member) internal virtual {
        uint256 lockIndexToMove = summaries[_member].length - 1;

        Detail memory summaryToMove = summaries[_member][lockIndexToMove];
        summaryToMove.index = _lockIndexToRemove;

        summaries[_member][_lockIndexToRemove] = summaryToMove;

        summaries[_member].pop();
    }

    /**
     * @dev Remove members when s/he had no running locked
     * @param _member Member address
     */
    function _removeMember(address _member) internal virtual {
        require(!everLocked(_member), "bad");

        address memberToMove = members[members.length - 1];
        uint128 indexToRemove = memberIndex[_member];

        members[indexToRemove] = memberToMove;
        memberIndex[memberToMove] = indexToRemove;

        members.pop();
        delete memberIndex[_member];
    }

    /**
     * @dev Set APY
     */
    function _setApy_d2() internal virtual {
        uint256 rate = uint256(interest_d2);
        uint256 period = uint256(compoundingPeriods);
        uint256 duration = uint256(terms);

        apy_d2 = uint128( ((( 1000000 + (rate * 1000000 / (period * 10000)) )**(period*duration)) - (1000000**(period*duration)) ) * 10000 / (1000000**(period*duration)) );
    }

    /* ========== MAIN AREA END ========== */


    /* ========== ADMIN AREA BEGIN ========== */

    /**
     * @dev Update interest rate in percent 2 decimal
     * @param _interest_d2 Interest rate in percent 2 decimal (ex. 18% into 1800)
     */
    function updateInterest(uint64 _interest_d2) external virtual onlyOwner {
        interest_d2 = _interest_d2;

        _setApy_d2();
    }

    /**
     * @dev Update minimum locked
     * @param _minLock Minimum token to be locked
     */
    function updateMinLock(uint128 _minLock) external virtual onlyOwner {
        minLock = _minLock;
    }

    /**
     * @dev Update maximum locked
     * @param _maxLock Maximum token to be locked
     */
    function updateMaxLock(uint128 _maxLock) external virtual onlyOwner {
        maxLock = _maxLock;
    }

    /**
     * @dev Update compounding periods (can't be more than 12x)
     * @param _compoundingPeriods Maximum token to be locked
     */
    function updateCompoundingPeriods(uint128 _compoundingPeriods) external virtual onlyOwner {
        require(_compoundingPeriods <= 12, "bad");
        compoundingPeriods = _compoundingPeriods;

        _setApy_d2();
    }

    /**
     * @dev Update Penalty in percent 2 decimal (charged when unlock before lock end)
     * @param _penalty_d2 Penalty in percent 2 decimal (ex. 30% into 3000)
     */
    function updatePenalty(uint64 _penalty_d2) external virtual onlyOwner {
        penalty_d2 = _penalty_d2;
    }

    /**
     * @dev Update Fee in percent 2 decimal (charged when unlock after lock end)
     * @param _fee_d2 Fee in percent 2 decimal (ex. 3% into 300)
     */
    function updateFee(uint64 _fee_d2) external virtual onlyOwner {
        fee_d2 = _fee_d2;
    }

    /**
     * @dev Update Lock Duration in month
     * @param _lockDurationInMonth Lock Duration in month (ex. 3 month into 3)
     */
    function updateLockDuration(uint64 _lockDurationInMonth) external virtual onlyOwner {
        lockPeriod = _lockDurationInMonth * 30 * 86400;
    }

    /**
     * @dev Update Token address
     * @param _token Token address
     */
    function updateToken(address _token) external virtual onlyOwner {
        token = _token;
    }

    /**
     * @dev Toggle the lock, claim, relock, & unlock pause function
     */
    function toggleLocked() external virtual onlyOwner {
        lockPaused = !lockPaused;
    } 

    /* ========== ADMIN AREA END ========== */

}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
	function safeApprove(address token, address to, uint value) internal {
		// bytes4(keccak256(bytes('approve(address,uint256)')));
		(bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
		require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: APPROVE_FAILED");
	}

	function safeTransfer(address token, address to, uint value) internal {
		// bytes4(keccak256(bytes('transfer(address,uint256)')));
		(bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
		require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: TRANSFER_FAILED");
	}

	function safeTransferFrom(address token, address from, address to, uint value) internal {
		// bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
		(bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
		require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: TRANSFER_FROM_FAILED");
	}

	function safeTransferETH(address to, uint value) internal {
		(bool success,) = to.call{value:value}(new bytes(0));
		require(success, "TransferHelper: ETH_TRANSFER_FAILED");
	}
}

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "hardhat-deploy/solc_0.8/proxy/Proxied.sol";

contract adminProxyManager is Initializable, Proxied {
  function __adminProxyManager_init(address _sender) internal virtual onlyInitializing {
    assembly {
      sstore(0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103, _sender)
    }
  }

  function proxyAdmin() external view virtual returns(address) {
    return _proxyAdmin();
  }

  function transferProxyAdmin(address _newProxyAdmin) external virtual proxied {
    require(_newProxyAdmin != address(0) && _newProxyAdmin != _proxyAdmin(), "bad");

    assembly {
      sstore(0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103, _newProxyAdmin)
    }

  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Proxied {
    /// @notice to be used by initialisation / postUpgrade function so that only the proxy's admin can execute them
    /// It also allows these functions to be called inside a contructor
    /// even if the contract is meant to be used without proxy
    modifier proxied() {
        address proxyAdminAddress = _proxyAdmin();
        // With hardhat-deploy proxies
        // the proxyAdminAddress is zero only for the implementation contract
        // if the implementation contract want to be used as a standalone/immutable contract
        // it simply has to execute the `proxied` function
        // This ensure the proxyAdminAddress is never zero post deployment
        // And allow you to keep the same code for both proxied contract and immutable contract
        if (proxyAdminAddress == address(0)) {
            // ensure can not be called twice when used outside of proxy : no admin
            // solhint-disable-next-line security/no-inline-assembly
            assembly {
                sstore(
                    0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103,
                    0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
                )
            }
        } else {
            require(msg.sender == proxyAdminAddress);
        }
        _;
    }

    modifier onlyProxyAdmin() {
        require(msg.sender == _proxyAdmin(), "NOT_AUTHORIZED");
        _;
    }

    function _proxyAdmin() internal view returns (address ownerAddress) {
        // solhint-disable-next-line security/no-inline-assembly
        assembly {
            ownerAddress := sload(0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103)
        }
    }
}