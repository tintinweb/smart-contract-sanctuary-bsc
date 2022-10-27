// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../interfaces/IAddressBook.sol";
import "../interfaces/IAutoCompound.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

/**
 * @title BaseContract
 * @author Steve Harmeyer
 * @notice This is an abstract base contract to handle UUPS upgrades and pausing.
 */

/// @custom:security-contact [email protected]
abstract contract BaseContract is Initializable, PausableUpgradeable, OwnableUpgradeable, UUPSUpgradeable {
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() { _disableInitializers(); }

    /**
     * Contract initializer.
     * @dev This intializes all the parent contracts.
     */
    function __BaseContract_init() internal onlyInitializing {
        __Pausable_init();
        __Ownable_init();
        __UUPSUpgradeable_init();
    }

    /**
     * Address book.
     */
    IAddressBook public addressBook;

    /**
     * -------------------------------------------------------------------------
     * ADMIN FUNCTIONS.
     * -------------------------------------------------------------------------
     */

    /**
     * Pause contract.
     * @dev This stops all operations with the contract.
     */
    function pause() external onlyOwner
    {
        _pause();
    }

    /**
     * Unpause contract.
     * @dev This resumes all operations with the contract.
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    /**
     * Set address book.
     * @param address_ Address book address.
     * @dev Sets the address book address.
     */
    function setAddressBook(address address_) public onlyOwner
    {
        addressBook = IAddressBook(address_);
    }

    /**
     * -------------------------------------------------------------------------
     * HOOKS.
     * -------------------------------------------------------------------------
     */

    /**
     * @dev This prevents upgrades from anyone but owner.
     */
    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IAddressBook
{
    function get (string memory name_) external view returns (address);
    function initialize () external;
    function owner () external view returns (address);
    function pause () external;
    function paused () external view returns (bool);
    function proxiableUUID () external view returns (bytes32);
    function renounceOwnership () external;
    function set (string memory name_, address address_) external;
    function transferOwnership (address newOwner) external;
    function unpause () external;
    function unset (string memory name_) external;
    function upgradeTo (address newImplementation) external;
    function upgradeToAndCall (address newImplementation, bytes memory data) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IAutoCompound {
    struct Properties {
        uint256 maxPeriods; // Maximum number of periods a participant can auto compound.
        uint256 period; // Seconds between compounds.
        uint256 fee; // BNB fee per period of auto compounding.
        uint256 maxParticipants; // Maximum autocompound participants.
    }
    struct Stats {
        uint256 compounding; // Number of participants auto compounding.
        uint256 compounds; // Number of auto compounds performed.
    }
    function addPeriods ( address participant_, uint256 periods_ ) external;
    function addressBook (  ) external view returns ( address );
    function compound ( uint256 quantity_ ) external;
    function compound (  ) external;
    function compounding ( address participant_ ) external view returns ( bool );
    function compounds ( address participant_ ) external view returns ( uint256[] memory );
    function compoundsLeft ( address participant_ ) external view returns ( uint256 );
    function due (  ) external view returns ( uint256 );
    function end (  ) external;
    function initialize (  ) external;
    function lastCompound ( address participant_ ) external view returns ( uint256 );
    function next (  ) external view returns ( address );
    function owner (  ) external view returns ( address );
    function pause (  ) external;
    function paused (  ) external view returns ( bool );
    function properties (  ) external view returns ( Properties memory );
    function proxiableUUID (  ) external view returns ( bytes32 );
    function renounceOwnership (  ) external;
    function setAddressBook ( address address_ ) external;
    function setMaxParticipants ( uint256 max_ ) external;
    function start ( uint256 periods_ ) external;
    function stats (  ) external view returns ( Stats memory );
    function totalCompounds ( address participant_ ) external view returns ( uint256 );
    function transferOwnership ( address newOwner ) external;
    function unpause (  ) external;
    function upgradeTo ( address newImplementation ) external;
    function upgradeToAndCall ( address newImplementation, bytes memory data ) external;
    function withdraw (  ) external;
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./abstracts/BaseContract.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
// Interfaces.
import "./interfaces/IVault.sol";

/**
 * @title Vote
 * @author Steve Harmeyer
 * @notice This is the Furio voting contract.
 */

/// @custom:security-contact [email protected]
contract Vote is BaseContract
{
    /**
     * Contract initializer.
     * @dev This intializes all the parent contracts.
     */
    function initialize() initializer public
    {
        __BaseContract_init();
        minimumVaultBalance = 25e18;
    }

    using Counters for Counters.Counter;

    /**
     * Initiative id tracker.
     */
    Counters.Counter private _initiativeIdTracker;

    /**
     * Properties.
     */
    uint256 public minimumVaultBalance;

    /**
     * Mappings.
     */
    mapping (uint256 => string) private _initiatives;
    mapping (uint256 => string) private _descriptions;
    mapping (uint256 => uint256) private _startTime;
    mapping (uint256 => uint256) private _endTime;
    mapping (uint256 => uint256) private _totalVotes;
    mapping (uint256 => uint256) private _yesVotes;
    mapping (address => mapping(uint256 => bool)) private _voted;

    /**
     * Events.
     */
    event InitiativeCreated(uint256 initiativeId, string name, string description, uint256 startTime, uint256 endTime);
    event VoteCast(uint256 initiativeId, address voter, bool vote);

    /**
     * Create initiative.
     * @param name_ Initiative name.
     * @param description_ Initiative description.
     * @param startTime_ Start time.
     * @param endTime_ End time.
     * @dev Creates an initiative.
     */
    function createInitiave(string memory name_, string memory description_, uint256 startTime_, uint256 endTime_) external onlyOwner
    {
        require(endTime_ > startTime_ && endTime_ > block.timestamp, "Invalid end time");
        _initiativeIdTracker.increment();
        _initiatives[_initiativeIdTracker.current()] = name_;
        _descriptions[_initiativeIdTracker.current()] = description_;
        _startTime[_initiativeIdTracker.current()] = startTime_;
        _endTime[_initiativeIdTracker.current()] = endTime_;
        emit InitiativeCreated(_initiativeIdTracker.current(), name_, description_, startTime_, endTime_);
    }

    /**
     * Get initiave.
     * @param initiative_ Initiative id.
     * @return (string memory, string memory, uint256, uint256, uint256, uint256)
     *     - Name, description, start time, end time, total votes, yes votes.
     */
    function getInitiative(uint256 initiative_) external view returns (string memory, string memory, uint256, uint256, uint256, uint256)
    {
        return (
            _initiatives[initiative_],
            _descriptions[initiative_],
            _startTime[initiative_],
            _endTime[initiative_],
            _totalVotes[initiative_],
            _yesVotes[initiative_]
        );
    }

    /**
     * Vote.
     * @param initiative_ Initiative id.
     * @param vote_ Vote.
     */
    function vote(uint256 initiative_, bool vote_) external
    {
        require(_startTime[initiative_] <= block.timestamp && _endTime[initiative_] >= block.timestamp, "Voting period has not started yet");
        require(!_voted[msg.sender][initiative_], "Already voted");
        require(IVault(addressBook.get("vault")).participantBalance(msg.sender) >= minimumVaultBalance, "Vault balance too low");
        _voted[msg.sender][initiative_] = true;
        _totalVotes[initiative_] ++;
        if(vote_)
        {
            _yesVotes[initiative_] ++;
        }
        emit VoteCast(initiative_, msg.sender, vote_);
    }

    /**
     * Results.
     * @param initiative_ Initiative id.
     * @return bool True if passed.
     */
    function results(uint256 initiative_) external view returns (bool)
    {
        return _yesVotes[initiative_] > _totalVotes[initiative_] / 2;
    }

    /**
     * Yes votes.
     * @param initiative_ Initiative id.
     * @return uint256 Yes votes.
     */
    function yesVotes(uint256 initiative_) external view returns (uint256)
    {
        return _yesVotes[initiative_];
    }

    /**
     * Total votes.
     * @param initiative_ Initiative id.
     * @return uint256 Total votes.
     */
    function totalVotes(uint256 initiative_) external view returns (uint256)
    {
        return _totalVotes[initiative_];
    }

    /**
     * Voted.
     * @param initiative_ Initiative id.
     * @param participant_ Participant address.
     * @return bool True if voted.
     */
    function voted(uint256 initiative_, address participant_) external view returns (bool)
    {
        return _voted[participant_][initiative_];
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IVault {
    struct Participant {
        uint256 startTime;
        uint256 balance;
        address referrer;
        uint256 deposited;
        uint256 compounded;
        uint256 claimed;
        uint256 taxed;
        uint256 awarded;
        bool negative;
        bool penalized;
        bool maxed;
        bool banned;
        bool teamWallet;
        bool complete;
        uint256 maxedRate;
        uint256 availableRewards;
        uint256 lastRewardUpdate;
        uint256 directReferrals;
        uint256 airdropSent;
        uint256 airdropReceived;
    }
    function addressBook (  ) external view returns ( address );
    function airdrop ( address to_, uint256 amount_ ) external returns ( bool );
    function availableRewards ( address participant_ ) external view returns ( uint256 );
    function claim (  ) external returns ( bool );
    function claimPrecheck ( address participant_ ) external view returns ( uint256 );
    function compound (  ) external returns ( bool );
    function autoCompound( address participant_ ) external returns ( bool );
    function deposit ( uint256 quantity_, address referrer_ ) external returns ( bool );
    function deposit ( uint256 quantity_ ) external returns ( bool );
    function depositFor ( address participant_, uint256 quantity_ ) external returns ( bool );
    function depositFor ( address participant_, uint256 quantity_, address referrer_ ) external returns ( bool );
    function getParticipant ( address participant_ ) external returns ( Participant memory );
    function initialize (  ) external;
    function maxPayout ( address participant_ ) external view returns ( uint256 );
    function maxThreshold (  ) external view returns ( uint256 );
    function owner (  ) external view returns ( address );
    function participantBalance ( address participant_ ) external view returns ( uint256 );
    function participantMaxed ( address participant_ ) external view returns ( bool );
    function participantStatus ( address participant_ ) external view returns ( uint256 );
    function pause (  ) external;
    function paused (  ) external view returns ( bool );
    function proxiableUUID (  ) external view returns ( bytes32 );
    function remainingPayout ( address participant_ ) external view returns ( uint256 );
    function renounceOwnership (  ) external;
    function rewardRate ( address participant_ ) external view returns ( uint256 );
    function setAddressBook ( address address_ ) external;
    function transferOwnership ( address newOwner ) external;
    function unpause (  ) external;
    function updateLookbackPeriods ( uint256 lookbackPeriods_ ) external;
    function updateMaxPayout ( uint256 maxPayout_ ) external;
    function updateMaxReturn ( uint256 maxReturn_ ) external;
    function updateNegativeClaims ( uint256 negativeClaims_ ) external;
    function updateNeutralClaims ( uint256 neutralClaims_ ) external;
    function updatePenaltyClaims ( uint256 penaltyClaims_ ) external;
    function updatePenaltyLookbackPeriods ( uint256 penaltyLookbackPeriods_ ) external;
    function updatePeriod ( uint256 period_ ) external;
    function updateRate ( uint256 claims_, uint256 rate_ ) external;
    function updateReferrer ( address referrer_ ) external;
    function upgradeTo ( address newImplementation ) external;
    function upgradeToAndCall ( address newImplementation, bytes memory data ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./abstracts/BaseContract.sol";
import "./interfaces/IVault.sol";
import "./interfaces/IAddLiquidity.sol";
import "./interfaces/ITaxHandler.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";

/**
 * @title Furio Token
 * @author Steve Harmeyer
 * @notice This is the ERC20 contract for $FUR.
 */

/// @custom:security-contact [email protected]
contract TokenV1 is BaseContract, ERC20Upgradeable {
    /**
     * Contract initializer.
     * @dev This intializes all the parent contracts.
     */
    function initialize() public initializer {
        __BaseContract_init();
        __ERC20_init("Furio", "$FUR");
    }

    /**
     * Properties struct.
     */
    struct Properties {
        uint256 tax;
        uint256 vaultTax; // ...................................................DEPRECATED
        uint256 pumpAndDumpTax; // .............................................DEPRECATED
        uint256 pumpAndDumpRate; // ............................................DEPRECATED
        uint256 sellCooldown; // ...............................................DEPRECATED
        address lpAddress;
        address swapAddress;
        address poolAddress;
        address vaultAddress;
        address safeAddress;
    }
    Properties private _properties;

    mapping(address => uint256) private _lastSale; // ..........................DEPRECATED
    uint256 _lpRewardTax; // ...................................................DEPRECATED
    bool _inSwap; // ...........................................................DEPRECATED
    uint256 private _lastAddLiquidityTime; // ..................................DEPRECATED

    /**
     * External contracts.
     */
    address _addLiquidityAddress;
    address _lpStakingAddress;
    address private _lmsAddress;
    ITaxHandler private _taxHandler;

    /**
     * Addresses that can swap.
     */
    mapping(address => bool) private _canSwap;

    /**
     * Get prooperties.
     * @return Properties Contract properties.
     */
    function getProperties() external view returns (Properties memory) {
        return _properties;
    }

    /**
     * _transfer override.
     * @param from_ From address.
     * @param to_ To address.
     * @param amount_ Transfer amount.
     */
    function _transfer(
        address from_,
        address to_,
        uint256 amount_
    ) internal override {
        if(from_ == _properties.lpAddress) require(_canSwap[to_], "FUR: No swaps from external contracts");
        if(to_ == _properties.lpAddress) require(_canSwap[from_], "FUR: No swaps from external contracts");
        uint256 _taxes_ = 0;
        if(!_taxHandler.isExempt(from_) && !_taxHandler.isExempt(to_)) {
            _taxes_ = amount_ * _properties.tax / 10000;
            super._transfer(from_, address(_taxHandler), _taxes_);
        }
        return super._transfer(from_, to_, amount_ - _taxes_);
    }

    /**
     * -------------------------------------------------------------------------
     * ADMIN FUNCTIONS.
     * -------------------------------------------------------------------------
     */
    function mint(address to_, uint256 quantity_) external {
        require(_canMint(msg.sender), "Unauthorized");
        super._mint(to_, quantity_);
    }

    /**
     * Set tax.
     * @param tax_ New tax rate.
     * @dev Sets the default tax rate.
     */
    function setTax(uint256 tax_) external onlyOwner {
        _properties.tax = tax_;
    }


    /**
     * Setup.
     * @dev Updates stored addresses.
     */
    function setup() public {
        IUniswapV2Factory _factory_ = IUniswapV2Factory(
            addressBook.get("factory")
        );
        _properties.lpAddress = _factory_.getPair(
            addressBook.get("payment"),
            address(this)
        );
        _properties.swapAddress = addressBook.get("swap");
        _properties.poolAddress = addressBook.get("pool");
        _properties.vaultAddress = addressBook.get("vault");
        _properties.safeAddress = addressBook.get("safe");
        _addLiquidityAddress = addressBook.get("addLiquidity");
        _lpStakingAddress = addressBook.get("lpStaking");
        _taxHandler = ITaxHandler(addressBook.get("taxHandler"));
        _lmsAddress = addressBook.get("liquidityManager");
        _canSwap[_properties.swapAddress] = true;
        _canSwap[_properties.poolAddress] = true;
        _canSwap[_addLiquidityAddress] = true;
        _canSwap[_lpStakingAddress] = true;
        _canSwap[_lmsAddress] = true;
        _canSwap[address(_taxHandler)] = true;
    }

    /**
     * -------------------------------------------------------------------------
     * HOOKS.
     * -------------------------------------------------------------------------
     */

    /**
     * @dev Add whenNotPaused modifier to token transfer hook.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override whenNotPaused {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override whenNotPaused {}

    /**
     * -------------------------------------------------------------------------
     * ACCESS.
     * -------------------------------------------------------------------------
     */

    /**
     * Can mint?
     * @param address_ Address of sender.
     * @return bool True if trusted.
     */
    function _canMint(address address_) internal view returns (bool) {
        if (address_ == addressBook.get("safe")) {
            return true;
        }
        if (address_ == addressBook.get("downline")) {
            return true;
        }
        if (address_ == addressBook.get("pool")) {
            return true;
        }
        if (address_ == addressBook.get("vault")) {
            return true;
        }
        return false;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAddLiquidity
{
    function addLiquidity() external;
    function withdraw() external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface ITaxHandler {
    function addTaxExemption ( address address_ ) external;
    function addressBook (  ) external view returns ( address );
    function distribute (  ) external;
    function initialize (  ) external;
    function isExempt ( address address_ ) external view returns ( bool );
    function owner (  ) external view returns ( address );
    function pause (  ) external;
    function paused (  ) external view returns ( bool );
    function proxiableUUID (  ) external view returns ( bytes32 );
    function renounceOwnership (  ) external;
    function setAddressBook ( address address_ ) external;
    function transferOwnership ( address newOwner ) external;
    function unpause (  ) external;
    function upgradeTo ( address newImplementation ) external;
    function upgradeToAndCall ( address newImplementation, bytes memory data ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20Upgradeable.sol";
import "./extensions/IERC20MetadataUpgradeable.sol";
import "../../utils/ContextUpgradeable.sol";
import "../../proxy/utils/Initializable.sol";

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
        _approve(owner, spender, allowance(owner, spender) + addedValue);
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
        uint256 currentAllowance = allowance(owner, spender);
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
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
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

pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
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
pragma solidity ^0.8.4;

import "./abstracts/BaseContract.sol";
import "./interfaces/IVault.sol";
import "./interfaces/IAddLiquidity.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

/**
 * @title Furio Token
 * @author Steve Harmeyer
 * @notice This is the ERC20 contract for $FUR.
 */

/// @custom:security-contact [email protected]
contract Token is BaseContract, ERC20Upgradeable {
    /**
     * Contract initializer.
     * @dev This intializes all the parent contracts.
     */
    function initialize() public initializer {
        __BaseContract_init();
        __ERC20_init("Furio", "$FUR");
    }

    function setInit() external onlyOwner {
        _properties.tax = 1000;
        _properties.vaultTax = 6000;
        _properties.pumpAndDumpTax = 5000;
        _properties.pumpAndDumpRate = 2500;
        _properties.sellCooldown = 86400; // 24 Hour cooldown
        _inSwap = false;
        _lpRewardTax = 2000;
    }

    /**
     * Properties struct.
     */
    struct Properties {
        uint256 tax;
        uint256 vaultTax;
        uint256 pumpAndDumpTax;
        uint256 pumpAndDumpRate;
        uint256 sellCooldown;
        address lpAddress;
        address swapAddress;
        address poolAddress;
        address vaultAddress;
        address safeAddress;
    }
    Properties private _properties;

    /**
     * Mappings.
     */
    mapping(address => uint256) private _lastSale;

    uint256 _lpRewardTax;
    bool _inSwap;
    modifier _swapping() {
        _inSwap = true;
        _;
        _inSwap = false;
    }
    uint256 private _lastAddLiquidityTime;
    address _addLiquidityAddress; //addLiquidity Contract address
    address _lpStakingAddress; // LPStaking contract address

    /**
     * Event.
     */
    event Sell(address seller_, uint256 sellAmount_);
    event Tax(
        address indexed from_,
        uint256 transferAmount_,
        uint256 taxAmount_
    );
    event PumpAndDump(
        address indexed from_,
        uint256 transferAmount_,
        uint256 taxAmount_
    );

    /**
     * Should add Liquidity.
     * @return bool.
     */
    function _shouldAddLiquidity() internal view returns (bool) {
        return
            !_inSwap &&
            block.timestamp >= (_lastAddLiquidityTime + 2 days);
    }

    /**
     * Should swapback.
     * @return bool.
     */
    function _shouldSwapBack() internal view returns (bool) {
        return !_inSwap && msg.sender != _properties.lpAddress;
    }

    /**
     * Get prooperties.
     * @return Properties Contract properties.
     */
    function getProperties() external view returns (Properties memory) {
        return _properties;
    }

    /**
     * Get last sell.
     * @param address_ Address of seller.
     * @return uint256 Last sale timestamp.
     */
    function getLastSell(address address_) external view returns (uint256) {
        return _lastSale[address_];
    }

    /**
     * is on cooldown?
     * @param address_ Address of seller.
     * @return bool True if on cooldown.
     */
    function onCooldown(address address_) public view returns (bool) {
        return
            _lastSale[address_] >= block.timestamp - _properties.sellCooldown;
    }

    /**
     * Approve.
     * @param owner Address of owner.
     * @param spender Address of spender.
     * @param amount Amount to approve.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal override {
        return super._approve(owner, spender, amount);
    }

    /**
     * _transfer override for taxes.
     * @param from_ From address.
     * @param to_ To address.
     * @param amount_ Transfer amount.
     */
    function _transfer(
        address from_,
        address to_,
        uint256 amount_
    ) internal override {
        if (_properties.lpAddress == address(0) ||
            _properties.safeAddress == address(0) ||
            _properties.swapAddress == address(0) ||
            _properties.vaultAddress == address(0) ||
            _addLiquidityAddress == address(0) ||
            _lpStakingAddress == address(0)
        ) {
            updateAddresses();
        }
        if (amount_ == 0) {
            // No tax on zero amount transactions.
            return super._transfer(from_, to_, amount_);
        }
        if (_inSwap) {
            // No tax on add liquidity and swapback.
            return super._transfer(from_, to_, amount_);
        }
        if (
            from_ == _properties.safeAddress || to_ == _properties.safeAddress
        ) {
            // No tax on safe transfers.
            return super._transfer(from_, to_, amount_);
        }
        if (from_ == _properties.poolAddress) {
            // No tax on transfers from pool.
            return super._transfer(from_, to_, amount_);
        }
        if (from_ == _properties.vaultAddress || to_ == _properties.vaultAddress) {
            // No tax on vault transfers.
            return super._transfer(from_, to_, amount_);
        }
        if (from_ == _properties.lpAddress && to_ == _properties.swapAddress) {
            // No tax on transfers from LP to swap.
            return super._transfer(from_, to_, amount_);
        }
        if (from_ == _properties.swapAddress && to_ == _properties.lpAddress) {
            // No tax on transfers from swap to LP.
            return super._transfer(from_, to_, amount_);
        }
        if (from_ == _lpStakingAddress || to_ == _lpStakingAddress) {
            // No tax on transfers on LP staking contract
            return super._transfer(from_, to_, amount_);
        }
        if (_shouldAddLiquidity()) {
            _addLiquidity();
        }

        uint256 _taxes_ = (amount_ * _properties.tax) / 10000;

        //** sell **//
        if (!_isExchange(from_) && _isExchange(to_)) {
            require(!onCooldown(from_), "Sell cooldown in effect");
            _lastSale[from_] = block.timestamp;
            _taxes_ += _pumpAndDumpTaxAmount(from_, amount_);
        }

        uint256 _vaultTax_ = (_taxes_ * _properties.vaultTax) / 10000;
        uint256 _lpRewardTax_ = (_taxes_ * _lpRewardTax) / 10000;
        super._transfer(from_, _addLiquidityAddress, _lpRewardTax_);
        super._transfer(from_, _properties.vaultAddress, _vaultTax_);

        //** buy **//
        if (_isExchange(from_) && !_isExchange(to_)) {
            super._transfer(
                from_,
                address(this),
                _taxes_ - _vaultTax_ - _lpRewardTax_
            );
            if (_shouldSwapBack()) {
                _swapBack();
            }

        }
        else{
            super._transfer(
                from_,
                _properties.safeAddress,
                _taxes_ - _vaultTax_ - _lpRewardTax_
            );
        }
        amount_ -= _taxes_;
        emit Tax(from_, amount_, _taxes_);
        super._transfer(from_, to_, amount_);
    }

    /**
     * auto add liquidity.
     */
    function _addLiquidity() internal _swapping {
        IAddLiquidity _AddLiquidity_ = IAddLiquidity(_addLiquidityAddress);
        _AddLiquidity_.addLiquidity();
        _lastAddLiquidityTime = block.timestamp;
    }

    function _swapBack() internal _swapping {
        IUniswapV2Router02 router = IUniswapV2Router02(
            addressBook.get("router")
        );
        require(address(router) != address(0), "Router not set");
        IERC20 USDC = IERC20(addressBook.get("payment"));
        require(address(USDC) != address(0), "Payment not set");

        _approve(address(this), address(router), balanceOf(address(this)));
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(USDC);

        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            balanceOf(address(this)),
            0,
            path,
            _properties.safeAddress,
            block.timestamp
        );
    }

    /**
     * Pump and dump tax amount.
     * @param from_ Sender.
     * @param amount_ Amount.
     * @return uint256 PnD tax amount.
     */
    function _pumpAndDumpTaxAmount(address from_, uint256 amount_)
        internal
        returns (uint256)
    {
        // Check vault.
        uint256 _taxAmount_;
        IVault _vaultContract_ = IVault(_properties.vaultAddress);
        if (!_vaultContract_.participantMaxed(from_)) {
            // Participant isn't maxed.
            if (
                amount_ >
                (_vaultContract_.participantBalance(from_) *
                    _properties.pumpAndDumpRate) /
                    10000
            ) {
                _taxAmount_ = (amount_ * _properties.pumpAndDumpTax) / 10000;
                emit PumpAndDump(from_, amount_, _taxAmount_);
            }
        }
        return _taxAmount_;
    }

    /**
     * Is exchange?
     * @param address_ Address to check.
     * @return bool True if swap or lp
     */
    function _isExchange(address address_) internal view returns (bool) {
        return
            address_ == _properties.swapAddress ||
            address_ == _properties.lpAddress;
    }

    /**
     * -------------------------------------------------------------------------
     * ADMIN FUNCTIONS.
     * -------------------------------------------------------------------------
     */
    function mint(address to_, uint256 quantity_) external {
        require(_canMint(msg.sender), "Unauthorized");
        super._mint(to_, quantity_);
    }

    /**
     * Set tax.
     * @param tax_ New tax rate.
     * @dev Sets the default tax rate.
     */
    function setTax(uint256 tax_) external onlyOwner {
        _properties.tax = tax_;
    }

    /**
     * Set vault tax.
     * @param vaultTax_ New vault tax rate.
     * @dev Sets the vault tax rate.
     */
    function setVaultTax(uint256 vaultTax_) external onlyOwner {
        require(vaultTax_ <= 10000, "Invalid amount");
        _properties.vaultTax = vaultTax_;
    }

    /**
     * Set pump and dump tax.
     * @param pumpAndDumpTax_ New vault tax rate.
     * @dev Sets the pump and dump tax rate.
     */
    function setPumpAndDumpTax(uint256 pumpAndDumpTax_) external onlyOwner {
        _properties.pumpAndDumpTax = pumpAndDumpTax_;
    }

    /**
     * Set pump and dump rate.
     * @param pumpAndDumpRate_ New vault Rate rate.
     * @dev Sets the pump and dump Rate rate.
     */
    function setPumpAndDumpRate(uint256 pumpAndDumpRate_) external onlyOwner {
        _properties.pumpAndDumpRate = pumpAndDumpRate_;
    }

    /**
     * Set sell cooldown period.
     * @param sellCooldown_ New cooldown rate.
     * @dev Sets the cooldown rate.
     */
    function setSellCooldown(uint256 sellCooldown_) external onlyOwner {
        _properties.sellCooldown = sellCooldown_;
    }

    /**
     * Update addresses.
     * @dev Updates stored addresses.
     */
    function updateAddresses() public {
        IUniswapV2Factory _factory_ = IUniswapV2Factory(
            addressBook.get("factory")
        );
        _properties.lpAddress = _factory_.getPair(
            addressBook.get("payment"),
            address(this)
        );
        _properties.swapAddress = addressBook.get("swap");
        _properties.poolAddress = addressBook.get("pool");
        _properties.vaultAddress = addressBook.get("vault");
        _properties.safeAddress = addressBook.get("safe");
        _addLiquidityAddress = addressBook.get("addLiquidity");
        _lpStakingAddress = addressBook.get("lpStaking");
    }

    /**
     * -------------------------------------------------------------------------
     * HOOKS.
     * -------------------------------------------------------------------------
     */

    /**
     * @dev Add whenNotPaused modifier to token transfer hook.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override whenNotPaused {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override whenNotPaused {}

    /**
     * -------------------------------------------------------------------------
     * ACCESS.
     * -------------------------------------------------------------------------
     */

    /**
     * Can mint?
     * @param address_ Address of sender.
     * @return bool True if trusted.
     */
    function _canMint(address address_) internal view returns (bool) {
        if (address_ == owner()) {
            return true;
        }
        if (address_ == addressBook.get("claim")) {
            return true;
        }
        if (address_ == addressBook.get("downline")) {
            return true;
        }
        if (address_ == addressBook.get("pool")) {
            return true;
        }
        if (address_ == addressBook.get("vault")) {
            return true;
        }
        return false;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20.sol";

pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

pragma solidity >=0.6.2;

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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./abstracts/BaseContract.sol";
// INTERFACES
import "./interfaces/ILiquidityManager.sol";
import "./interfaces/ITaxHandler.sol";
import "./interfaces/IVault.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

/**
 * @title Furio Swap
 * @author Steve Harmeyer
 * @notice This is the uinswap contract for $FUR.
 */

/// @custom:security-contact [email protected]
contract SwapV2 is BaseContract
{
    /**
     * Contract initializer.
     * @dev This intializes all the parent contracts.
     */
    function initialize() initializer public
    {
        __BaseContract_init();
        tax = 1000;
        pumpAndDumpMultiplier = 6; // Tax at 6x the normal rate (e.g. 60% instead of 10%)
        pumpAndDumpRate = 2500; // 25%
        cooldownPeriod = 1 days;
    }

    /**
     * Contracts.
     */
    IUniswapV2Factory public factory;
    IERC20 public fur;
    ILiquidityManager public liquidityManager;
    IUniswapV2Pair public pair;
    IUniswapV2Router02 public router;
    ITaxHandler public taxHandler;
    IERC20 public usdc;
    IVault public vault;

    /**
     * Taxes.
     */
    uint256 public tax;
    uint256 public pumpAndDumpMultiplier;
    uint256 public pumpAndDumpRate;

    /**
     * Cooldown.
     */
    uint256 public cooldownPeriod;
    mapping(address => bool) private _isExemptFromCooldown;
    mapping(address => uint256) public lastSell;

    /**
     * Liquidity manager.
     */
    bool public liquidityManagerEnabled;

    /**
     * Limits.
     */
    uint256 public maxSale;

    /**
     * Contract setup.
     */
    function setup() external
    {
        factory = IUniswapV2Factory(addressBook.get("factory"));
        fur = IERC20(addressBook.get("token"));
        liquidityManager = ILiquidityManager(addressBook.get("liquidityManager"));
        router = IUniswapV2Router02(addressBook.get("router"));
        taxHandler = ITaxHandler(addressBook.get("taxHandler"));
        usdc = IERC20(addressBook.get("payment"));
        vault = IVault(addressBook.get("vault"));
        pair = IUniswapV2Pair(factory.getPair(address(fur), address(usdc)));
        _isExemptFromCooldown[address(this)] = true;
        _isExemptFromCooldown[address(liquidityManager)] = true;
        _isExemptFromCooldown[address(taxHandler)] = true;
        _isExemptFromCooldown[addressBook.get("addLiquidity")] = true;
        _isExemptFromCooldown[owner()] = true;
        maxSale = 1000e18;
    }

    /**
     * Buy FUR.
     * @param payment_ Address of payment token.
     * @param amount_ Amount of tokens to spend.
     */
    function buy(address payment_, uint256 amount_) external whenNotPaused
    {
        // Buy FUR.
        uint256 _received_ = _buy(msg.sender, payment_, amount_);
        // Transfer received FUR to sender.
        require(fur.transfer(msg.sender, _received_), "Swap: transfer failed");
    }

    /**
     * Deposit buy.
     * @param payment_ Address of payment token.
     * @param amount_ Amount of payment.
     */
    function depositBuy(address payment_, uint256 amount_) external whenNotPaused
    {
        // Buy FUR.
        uint256 _received_ = _buy(msg.sender, payment_, amount_);
        // Deposit into vault.
        vault.depositFor(msg.sender, _received_, address(0));
    }

    /**
     * Deposit buy with referrer.
     * @param payment_ Address of payment token.
     * @param amount_ Amount of payment.
     * @param referrer_ Address of referrer.
     */
    function depositBuy(address payment_, uint256 amount_, address referrer_) external whenNotPaused
    {
        // Buy FUR.
        uint256 _received_ = _buy(msg.sender, payment_, amount_);
        // Deposit into vault.
        vault.depositFor(msg.sender, _received_, referrer_);
    }

    /**
     * Internal buy FUR.
     * @param buyer_ Buyer address.
     * @param payment_ Address of payment token.
     * @param amount_ Amount of tokens to spend.
     * @return uint256 Amount of FUR received.
     */
    function _buy(address buyer_, address payment_, uint256 amount_) internal returns (uint256)
    {
        // Convert payment to USDC.
        uint256 _usdcAmount_ = _buyUsdc(payment_, amount_, buyer_);
        // Get sender exempt status.
        bool _isExempt_ = taxHandler.isExempt(buyer_);
        // Calculate USDC taxes.
        uint256 _tax_ = 0;
        if(!_isExempt_) _tax_ = _usdcAmount_ * tax / 10000;
        // Get FUR balance.
        uint256 _startingFurBalance_ = fur.balanceOf(address(this));
        // Swap USDC for FUR.
        _swap(address(usdc), address(fur), _usdcAmount_ - _tax_);
        uint256 _furSwapped_ = fur.balanceOf(address(this)) - _startingFurBalance_;
        // Transfer taxes to tax handler.
        if(_tax_ > 0) usdc.transfer(address(taxHandler), _tax_);
        // Return amount.
        return _furSwapped_;
    }

    /**
     * Internal buy USDC.
     * @param payment_ Address of payment token.
     * @param amount_ Amount of tokens to spend.
     * @param buyer_ Address of buyer.
     * @return uint256 Amount of USDC purchased.
     */
    function _buyUsdc(address payment_, uint256 amount_, address buyer_) internal returns (uint256)
    {
        // Instanciate payment token.
        IERC20 _payment_ = IERC20(payment_);
        // Get payment balance.
        uint256 _startingPaymentBalance_ = _payment_.balanceOf(address(this));
        // Transfer payment tokens to this address.
        require(_payment_.transferFrom(buyer_, address(this), amount_), "Swap: transfer failed");
        uint256 _balance_ = _payment_.balanceOf(address(this)) - _startingPaymentBalance_;
        // If payment is already USDC, return.
        if(payment_ == address(usdc)) {
            return _balance_;
        }
        // Swap payment for USDC.
        uint256 _startingUsdcBalance_ = usdc.balanceOf(address(this));
        _swap(address(_payment_), address(usdc), _balance_);
        uint256 _usdcSwapped_ = usdc.balanceOf(address(this)) - _startingUsdcBalance_;
        // Return tokens received.
        return _usdcSwapped_;
    }

    /**
     * Swap.
     * @param in_ Address of input token.
     * @param out_ Address of output token.
     * @param amount_ Amount of input tokens to swap.
     */
    function _swap(address in_, address out_, uint256 amount_) internal
    {
        if(liquidityManagerEnabled) {
            _swapThroughLiquidityManager(in_, out_, amount_);
        }
        else {
            _swapThroughUniswap(in_, out_, amount_);
        }
    }

    /**
     * Swap through uniswap.
     * @param in_ Input token address.
     * @param out_ Output token address.
     * @param amount_ Amount of input token.
     */
    function _swapThroughUniswap(address in_, address out_, uint256 amount_) internal
    {
        address[] memory _path_ = new address[](2);
        _path_[0] = in_;
        _path_[1] = out_;
        IERC20(in_).approve(address(router), amount_);
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount_,
            0,
            _path_,
            address(this),
            block.timestamp + 3600
        );
    }

    /**
     * Swap through LMS.
     * @param in_ Input token address.
     * @param out_ Output token address.
     * @param amount_ Amount of input token.
     */
    function _swapThroughLiquidityManager(address in_, address out_, uint256 amount_) internal
    {
        if(in_ != address(fur) && out_ != address(fur)) {
            return _swapThroughUniswap(in_, out_, amount_);
        }
        IERC20(in_).approve(address(liquidityManager), amount_);
        //uint256 _output_;
        if(in_ == address(fur)) {
            //_output_ = sellOutput(amount_);
            liquidityManager.swapTokenForUsdc(address(this), amount_, 1);
        }
        else {
            //_output_ = buyOutput(address(usdc), amount_);
            liquidityManager.swapUsdcForToken(address(this), amount_, 1);
        }
    }

    /**
     * On cooldown.
     * @param participant_ Address of participant.
     * @return bool True if on cooldown.
     */
    function onCooldown(address participant_) public view returns (bool)
    {
        return !_isExemptFromCooldown[participant_] && lastSell[participant_] + cooldownPeriod > block.timestamp;
    }

    /**
     * Sell FUR.
     * @param amount_ Amount of FUR to sell.
     */
    function sell(uint256 amount_) external whenNotPaused
    {
        require(amount_ <= maxSale, "Swap: amount exceeds max sale");
        // Check cooldown.
        if(!_isExemptFromCooldown[msg.sender]) {
            require(block.timestamp > lastSell[msg.sender] + cooldownPeriod, "Swap: cooldown");
        }
        // Get starting FUR balance.
        uint256 _startingFurBalance_ = fur.balanceOf(address(this));
        // Transfer FUR to this contract.
        require(fur.transferFrom(msg.sender, address(this), amount_), "Swap: transfer failed");
        // Get FUR received.
        uint256 _furReceived_ = fur.balanceOf(address(this)) - _startingFurBalance_;
        // Get starting USDC balance.
        uint256 _startingUsdcBalance_ = usdc.balanceOf(address(this));
        // Swap FUR for USDC.
        _swap(address(fur), address(usdc), _furReceived_);
        uint256 _usdcSwapped_ = usdc.balanceOf(address(this)) - _startingUsdcBalance_;
        // Handle taxes.
        if(!taxHandler.isExempt(msg.sender)) {
            uint256 _tax_ = tax;
            if(vault.participantBalance(msg.sender) * pumpAndDumpRate / 10000 < amount_) {
                _tax_ = tax + pumpAndDumpMultiplier;
            }
            uint256 _taxAmount_ = _usdcSwapped_ * _tax_ / 10000;
            usdc.transfer(address(taxHandler), _taxAmount_);
            _usdcSwapped_ -= _taxAmount_;
        }
        // Update last sell timestamp.
        lastSell[msg.sender] = block.timestamp;
        // Transfer received USDC to sender.
        require(usdc.transfer(msg.sender, _usdcSwapped_), "Swap: transfer failed");
    }

    /**
     * Enable LMS
     */
    function enableLiquidityManager() external onlyOwner
    {
        liquidityManager.enableLiquidityManager(true);
        liquidityManagerEnabled = true;
    }

    /**
     * Disable LMS
     */
    function disableLiquidtyManager() external onlyOwner
    {
        liquidityManager.enableLiquidityManager(false);
        liquidityManagerEnabled = false;
    }

    /**
     * Get token buy output.
     * @param payment_ Address of payment token.
     * @param amount_ Amount spent.
     * @return uint Amount of tokens received.
     */
    function buyOutput(address payment_, uint256 amount_) public view returns (uint256) {
        return
            _getOutput(
                payment_,
                address(fur),
                amount_
            );
    }

    /**
     * Get token sell output.
     * @param amount_ Amount sold.
     * @return uint Amount of tokens received.
     */
    function sellOutput(uint256 amount_) public view returns (uint256) {
        return
            _getOutput(
                address(fur),
                address(usdc),
                amount_
            );
    }

    /**
     * Get output.
     * @param in_ In token.
     * @param out_ Out token.
     * @param amount_ Amount in.
     * @return uint Estimated tokens received.
     */
    function _getOutput(
        address in_,
        address out_,
        uint256 amount_
    ) internal view returns (uint256) {
        address[] memory _path_ = new address[](2);
        _path_[0] = in_;
        _path_[1] = out_;
        uint256[] memory _outputs_ = router.getAmountsOut(amount_, _path_);
        return _outputs_[1];
    }

    /**
     * Exempt from cooldown.
     * @param participant_ Address of participant.
     * @param value_ True to exempt, false to unexempt.
     */
    function exemptFromCooldown(address participant_, bool value_) external onlyOwner
    {
        _isExemptFromCooldown[participant_] = value_;
    }

    /**
     * Sweep dust.
     */
    function sweepDust() external onlyOwner
    {
        uint256 _furBalance_ = fur.balanceOf(address(this));
        if(_furBalance_ > 0) {
            fur.transfer(address(vault), _furBalance_);
        }
        uint256 _usdcBalance_ = usdc.balanceOf(address(this));
        if(_usdcBalance_ > 0) {
            usdc.transfer(address(taxHandler), _usdcBalance_);
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface ILiquidityManager {
    function rebalance(uint256 amount, bool buyback) external;
    function swapUsdcForToken(
        address to,
        uint256 amountIn,
        uint256 amountOutMin
    ) external;
    function swapTokenForUsdc(
        address to,
        uint256 amountIn,
        uint256 amountOutMin
    ) external;
    function swapTokenForUsdcToWallet(
        address from,
        address destination,
        uint256 tokenAmount,
        uint256 slippage
    ) external;
    function enableLiquidityManager(bool value) external;
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./interfaces/IToken.sol";
import "./abstracts/BaseContract.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "./interfaces/ILiquidityManager.sol";

/**
 * @title FUR-USDC LP staking
 * @author Steve Harmeyer
 * @notice This contract offers LP holders can stake with any crypto.
 */

/// @custom:security-contact [email protected]
contract LPStakingV1 is BaseContract {
    using SafeMath for uint256;

    // is necessary to receive unused bnb from the swaprouter
    receive() external payable {}

    /**
     * Contract initializer.
     * @dev This intializes all the parent contracts.
     */
    function initialize() public initializer {
        __BaseContract_init();
        _lastUpdateTime = block.timestamp;
        _dividendsPerShareAccuracyFactor = 1e36;
    }

    /**
     * Staker struct.
     */
    struct Staker {
        uint256 stakingAmount; //staking LP amount
        uint256 boostedAmount; //boosted staking LP amount
        uint256 rewardDebt; //rewardDebt LP amount
        uint256 lastStakingUpdateTime; //last staking update time
        uint256 stakingPeriod; //staking period
    }
    /**
     * variables
     */
    address public lpAddress;
    address public usdcAddress;
    address public routerAddress;
    address public tokenAddress;
    IUniswapV2Router02 public router;
    address _LPLockReceiver; //address for LP lock
    address[] public LPholders; // LP holders address. to get LP reflection, they have to register thier address here.

    uint256 _lastUpdateTime; //LP RewardPool Updated time
    uint256 _accLPPerShare; //Accumulated LPs per share, times 1e36. See below.
    uint256 _dividendsPerShareAccuracyFactor; //1e36

    uint256 public totalStakerNum; //total staker number
    uint256 public totalStakingAmount; //total staked LP amount
    uint256 _totalBoostedAmount; //total boosted amount for reward distrubution
    uint256 _totalReward; //total LP amount for LP reward to LP stakers
    uint256 _totalReflection; //total LP amount to LP reflection to LP holders
    uint256 _LPLockAmount; // total locked LP amount. except from LP reflection
    /**
     * Mappings.
     */
    mapping(address => Staker) public stakers;
    mapping(address => uint256) public _LPholderIndexes;
    mapping(address => address[]) public pathFromTokenToUSDC;
    /**
     * Event.
     */
    event Stake(address indexed staker, uint256 amount, uint256 duration);
    event ClaimRewards(address indexed staker, uint256 amount);
    event Compound(address indexed staker, uint256 amount);
    event Unstake(address indexed staker, uint256 amount);

    function SetLmAddr(address _lmsAddress) external onlyOwner {
        _lms = ILiquidityManager(_lmsAddress);
    }

    /**
     * Update addresses.
     * @dev Updates stored addresses.
     */
    function updateAddresses() public {
        IUniswapV2Factory _factory_ = IUniswapV2Factory(
            addressBook.get("factory")
        );
        lpAddress = _factory_.getPair(
            addressBook.get("payment"),
            addressBook.get("token")
        );
        _LPLockReceiver = addressBook.get("lpLockReceiver");
        usdcAddress = addressBook.get("payment");
        routerAddress = addressBook.get("router");
        tokenAddress = addressBook.get("token");
    }

    /**
     * Remaining Locked Time.
     */
    function getRemainingLockedTime(address stakerAddress)
        public
        view
        returns (uint256)
    {
        if (stakers[stakerAddress].stakingPeriod == 0) return 0;
        return
            stakers[stakerAddress].lastStakingUpdateTime +
            stakers[stakerAddress].stakingPeriod -
            block.timestamp;
    }

    /**
     * total LP amount holded this contract
     */
    function _LPSupply_() external view returns (uint256) {
        return IERC20(lpAddress).balanceOf(address(this));
    }

    /**
     * claimable Reward for LP stakers
     * @param stakerAddress_ staker address
     * @return pending_ claimable LP amount
     */
    function pendingReward(address stakerAddress_)
        public
        view
        returns (uint256 pending_)
    {
        if (stakers[stakerAddress_].stakingAmount <= 0) return 0;
        pending_ = stakers[stakerAddress_]
            .boostedAmount
            .mul(_accLPPerShare)
            .div(_dividendsPerShareAccuracyFactor)
            .sub(stakers[stakerAddress_].rewardDebt);
    }

    /**
     * Update reward pool for LP stakers.
     * @dev update _accLPPerShare
     */
    function updateRewardPool() public {
        if (lpAddress == address(0)) updateAddresses();
        uint256 _deltaTime_ = block.timestamp - _lastUpdateTime;
        if (_deltaTime_ < 24 hours) return;
        //distribute reflection rewards to lp holders
        _distributeReflectionRewards();
        //set times limit value
        uint256 _times_ = _deltaTime_.div(24 hours);
        if (_times_ > 40) _times_ = 40;
        //calculte total reward lp for stakers
        _totalReward = IERC20(lpAddress)
            .balanceOf(address(this))
            .sub(totalStakingAmount)
            .sub(_totalReflection);
        if (_totalReward <= 0) {
            _lastUpdateTime = block.timestamp;
            return;
        }
        //update accumulated LPs per share
        uint256 _amountForReward_ = _totalReward.mul(25).div(1000).mul(_times_);
        uint256 _RewardPerShare_ = _amountForReward_
            .mul(_dividendsPerShareAccuracyFactor)
            .div(_totalBoostedAmount);
        _accLPPerShare = _accLPPerShare.add(_RewardPerShare_);
        _totalReward = _totalReward.sub(_amountForReward_);
        _lastUpdateTime = _lastUpdateTime.add(_times_.mul(24 hours));
    }

    /**
     * Stake for.
     * @param paymentAddress_ Payment token address.
     * @param paymentAmount_ Amount to stake.
     * @param durationIndex_ Duration index.
     * @param staker_ Staker address.
     */
    function stakeFor(
        address paymentAddress_,
        uint256 paymentAmount_,
        uint256 durationIndex_,
        address staker_
    ) external {
        _stake(paymentAddress_, paymentAmount_, durationIndex_, staker_);
    }

    /**
     * Stake.
     * @param paymentAddress_ Payment token address.
     * @param paymentAmount_ Amount to stake.
     * @param durationIndex_ Duration index.
     */
    function stake(
        address paymentAddress_,
        uint256 paymentAmount_,
        uint256 durationIndex_
    ) external {
        _stake(paymentAddress_, paymentAmount_, durationIndex_, msg.sender);
    }

    /**
     * Internal stake.
     * @param paymentAddress_ Payment token address.
     * @param paymentAmount_ Amount to stake.
     * @param durationIndex_ Duration index.
     * @param staker_ Staker address.
     */
    function _stake(
        address paymentAddress_,
        uint256 paymentAmount_,
        uint256 durationIndex_,
        address staker_
    ) internal {
        if (
            lpAddress == address(0) ||
            _LPLockReceiver == address(0) ||
            usdcAddress == address(0)
        ) updateAddresses();
        require(durationIndex_ <= 3, "Non exist duration!");
        //convert crypto to LP
        (uint256 _lpAmount_, , ) = _buyLP(paymentAddress_, paymentAmount_);
        //add Staker number
        if (stakers[staker_].stakingAmount == 0) totalStakerNum++;
        // update reward pool
        updateRewardPool();
        //already staked member
        if (stakers[staker_].stakingAmount > 0) {
            if (stakers[staker_].stakingPeriod == 30 days)
                require(
                    durationIndex_ >= 1,
                    "you have to stake more than a month"
                );
            if (stakers[staker_].stakingPeriod == 60 days)
                require(
                    durationIndex_ >= 2,
                    "you have to stake more than two month"
                );
            if (stakers[staker_].stakingPeriod == 90 days)
                require(
                    durationIndex_ == 3,
                    "you have to stake during three month"
                );
            //transfer pending reward to staker_
            uint256 _pending_ = pendingReward(staker_);
            if (_pending_ > 0) {
                uint256 _usdcAmount_ = _sellLP(_pending_);
                IERC20(usdcAddress).transfer(staker_, _usdcAmount_);
            }
        }
        //transfer 3% LP to lpLock wallet
        IERC20(lpAddress).transfer(
            _LPLockReceiver,
            _lpAmount_.mul(30).div(1000)
        );
        //set boosted LP amount regarding to staking period
        uint256 _boosting_lpAmount_;
        if (durationIndex_ == 0) _boosting_lpAmount_ = _lpAmount_;
        if (durationIndex_ == 1)
            _boosting_lpAmount_ = _lpAmount_.mul(102).div(100);
        if (durationIndex_ == 2)
            _boosting_lpAmount_ = _lpAmount_.mul(105).div(100);
        if (durationIndex_ == 3)
            _boosting_lpAmount_ = _lpAmount_.mul(110).div(100);
        stakers[msg.sender].stakingPeriod = durationIndex_ * 30 days;
        //update staker data
        stakers[staker_].stakingAmount = stakers[staker_].stakingAmount.add(
            _lpAmount_.mul(900).div(1000)
        );
        stakers[staker_].boostedAmount = stakers[staker_].boostedAmount.add(
            _boosting_lpAmount_.mul(900).div(1000)
        );
        stakers[staker_].rewardDebt = stakers[staker_]
            .boostedAmount
            .mul(_accLPPerShare)
            .div(_dividendsPerShareAccuracyFactor);
        stakers[staker_].lastStakingUpdateTime = block.timestamp;
        //update total amounts
        totalStakingAmount = totalStakingAmount.add(
            _lpAmount_.mul(900).div(1000)
        );
        _totalBoostedAmount = _totalBoostedAmount.add(
            _boosting_lpAmount_.mul(900).div(1000)
        );
        _totalReflection = _totalReflection.add(_lpAmount_.mul(20).div(1000));
        _LPLockAmount = _LPLockAmount.add(_lpAmount_.mul(30).div(1000));

        emit Stake(staker_, _lpAmount_, stakers[staker_].stakingPeriod);
    }

    /**
     * stake function
     * @param paymentAmount_ eth amount
     * @param durationIndex_ duration index.
     * @dev approve LP before staking.
     */
    function stakeWithEth(uint256 paymentAmount_, uint256 durationIndex_)
        external
        payable
    {
        if (
            lpAddress == address(0) ||
            _LPLockReceiver == address(0) ||
            usdcAddress == address(0)
        ) updateAddresses();
        require(durationIndex_ <= 3, "Non exist duration!");
        //convert crypto to LP
        (uint256 _lpAmount_, , ) = _buyLPWithEth(paymentAmount_);
        //add Staker number
        if (stakers[msg.sender].stakingAmount == 0) totalStakerNum++;
        // update reward pool
        updateRewardPool();
        //already staked member
        if (stakers[msg.sender].stakingAmount > 0) {
            if (stakers[msg.sender].stakingPeriod == 30 days)
                require(
                    durationIndex_ >= 1,
                    "you have to stake more than a month"
                );
            if (stakers[msg.sender].stakingPeriod == 60 days)
                require(
                    durationIndex_ >= 2,
                    "you have to stake more than two month"
                );
            if (stakers[msg.sender].stakingPeriod == 90 days)
                require(
                    durationIndex_ == 3,
                    "you have to stake during three month"
                );
            //transfer pending reward to staker
            uint256 _pending_ = pendingReward(msg.sender);
            if (_pending_ > 0) {
                uint256 _usdcAmount_ = _sellLP(_pending_);
                IERC20(usdcAddress).transfer(msg.sender, _usdcAmount_);
            }
        }
        //transfer 3% LP to lpLock wallet
        IERC20(lpAddress).transfer(
            _LPLockReceiver,
            _lpAmount_.mul(30).div(1000)
        );
        //set boosted LP amount regarding to staking period
        uint256 _boosting_lpAmount_;
        if (durationIndex_ == 0) _boosting_lpAmount_ = _lpAmount_;
        if (durationIndex_ == 1)
            _boosting_lpAmount_ = _lpAmount_.mul(102).div(100);
        if (durationIndex_ == 2)
            _boosting_lpAmount_ = _lpAmount_.mul(105).div(100);
        if (durationIndex_ == 3)
            _boosting_lpAmount_ = _lpAmount_.mul(110).div(100);
        stakers[msg.sender].stakingPeriod = durationIndex_ * 30 days;
        //update staker data
        stakers[msg.sender].stakingAmount = stakers[msg.sender]
            .stakingAmount
            .add(_lpAmount_.mul(900).div(1000));
        stakers[msg.sender].boostedAmount = stakers[msg.sender]
            .boostedAmount
            .add(_boosting_lpAmount_.mul(900).div(1000));
        stakers[msg.sender].rewardDebt = stakers[msg.sender]
            .boostedAmount
            .mul(_accLPPerShare)
            .div(_dividendsPerShareAccuracyFactor);
        stakers[msg.sender].lastStakingUpdateTime = block.timestamp;
        //update total amounts
        totalStakingAmount = totalStakingAmount.add(
            _lpAmount_.mul(900).div(1000)
        );
        _totalBoostedAmount = _totalBoostedAmount.add(
            _boosting_lpAmount_.mul(900).div(1000)
        );
        _totalReflection = _totalReflection.add(_lpAmount_.mul(20).div(1000));
        _LPLockAmount = _LPLockAmount.add(_lpAmount_.mul(30).div(1000));

        emit Stake(msg.sender, _lpAmount_, stakers[msg.sender].stakingPeriod);
    }

    /**
     * claim reward function for LP stakers
     @notice stakers can claim every 24 hours and receive it with USDC.
     */
    function claimRewards() external {
        if (lpAddress == address(0)) updateAddresses();
        if (stakers[msg.sender].stakingAmount <= 0) return;
        //transfer pending reward to staker
        uint256 _pending_ = pendingReward(msg.sender);
        if (_pending_ == 0) return;
        uint256 _usdcAmount_ = _sellLP(_pending_);
        IERC20(usdcAddress).transfer(msg.sender, _usdcAmount_);
        //reset staker's rewardDebt
        stakers[msg.sender].rewardDebt = stakers[msg.sender]
            .boostedAmount
            .mul(_accLPPerShare)
            .div(_dividendsPerShareAccuracyFactor);
        // update reward pool
        updateRewardPool();
        emit ClaimRewards(msg.sender, _pending_);
    }

    /**
     * compound function for LP stakers
     @notice stakers restake claimable LP every 24 hours without staking fee.
     */
    function compound() external {
        if (lpAddress == address(0)) updateAddresses();
        if (stakers[msg.sender].stakingAmount <= 0) return;
        //get pending LP
        uint256 _pending_ = pendingReward(msg.sender);
        if (_pending_ == 0) return;
        //add pending LP to staker data
        stakers[msg.sender].stakingAmount = stakers[msg.sender]
            .stakingAmount
            .add(_pending_);
        stakers[msg.sender].boostedAmount = stakers[msg.sender]
            .boostedAmount
            .add(_pending_);
        stakers[msg.sender].rewardDebt = stakers[msg.sender]
            .boostedAmount
            .mul(_accLPPerShare)
            .div(_dividendsPerShareAccuracyFactor);
        //add pending LP to total amounts
        totalStakingAmount = totalStakingAmount.add(_pending_);
        _totalBoostedAmount = _totalBoostedAmount.add(_pending_);
        //update reward pool
        updateRewardPool();
        emit Compound(msg.sender, _pending_);
    }

    /**
     * unstake function
     @notice stakers have to claim rewards before finishing stake.
     */
    function unstake() external {
        if (lpAddress == address(0) || _LPLockReceiver == address(0))
            updateAddresses();
        //check staked lp amount and locked period
        uint256 _lpAmount_ = stakers[msg.sender].stakingAmount;
        if (_lpAmount_ <= 0) return;
        require(
            block.timestamp - stakers[msg.sender].lastStakingUpdateTime >=
                stakers[msg.sender].stakingPeriod,
            "Don't finish your staking period!"
        );
        //update reward pool
        updateRewardPool();
        // transfer pending reward to staker
        uint256 _pending_ = pendingReward(msg.sender);
        if (_pending_ > 0) {
            uint256 _Pendingusdc_ = _sellLP(_pending_);
            IERC20(usdcAddress).transfer(msg.sender, _Pendingusdc_);
        }
        //convert LP to usdc and transfer staker and LP lock wallet
        uint256 _usdcAmount_ = _sellLP(_lpAmount_.mul(900).div(1000));
        IERC20(usdcAddress).transfer(msg.sender, _usdcAmount_);
        IERC20(lpAddress).transfer(
            _LPLockReceiver,
            _lpAmount_.mul(30).div(1000)
        );
        // update total amounts
        totalStakingAmount = totalStakingAmount.sub(
            stakers[msg.sender].stakingAmount
        );
        _totalBoostedAmount = _totalBoostedAmount.sub(
            stakers[msg.sender].boostedAmount
        );
        _totalReflection = _totalReflection.add(_lpAmount_.mul(20).div(1000));
        _LPLockAmount = _LPLockAmount.add(_lpAmount_.mul(30).div(1000));
        totalStakerNum--;
        //update staker data
        stakers[msg.sender].stakingAmount = 0;
        stakers[msg.sender].boostedAmount = 0;
        stakers[msg.sender].lastStakingUpdateTime = block.timestamp;
        stakers[msg.sender].stakingPeriod = 0;

        emit Unstake(msg.sender, _lpAmount_);
    }

    /**
     * reset staking duration function
     * @param durationIndex_ duration index.
     */
    function resetStakingPeriod(uint256 durationIndex_) external {
        require(durationIndex_ <= 3, "Non exist duration!");
        require(
            stakers[msg.sender].stakingAmount > 0,
            "Don't exist staked amount!"
        );
        //update reward pool
        updateRewardPool();
        //only increase staking duration
        if (durationIndex_ == 0) return;
        if (stakers[msg.sender].stakingPeriod == 30 days)
            require(durationIndex_ >= 1, "you have to stake more than a month");
        if (stakers[msg.sender].stakingPeriod == 60 days)
            require(
                durationIndex_ >= 2,
                "you have to stake more than two month"
            );
        if (stakers[msg.sender].stakingPeriod == 90 days)
            require(
                durationIndex_ == 3,
                "you have to stake during three month"
            );
        //transfer pending reward to staker
        uint256 _pending_ = pendingReward(msg.sender);
        if (_pending_ > 0) {
            uint256 _usdcAmount_ = _sellLP(_pending_);
            IERC20(usdcAddress).transfer(msg.sender, _usdcAmount_);
        }
        //set boosted amount and reset staking period
        uint256 _boosting_lpAmount_;
        if (durationIndex_ == 0)
            _boosting_lpAmount_ = stakers[msg.sender].stakingAmount;
        if (durationIndex_ == 1)
            _boosting_lpAmount_ = stakers[msg.sender]
                .stakingAmount
                .mul(102)
                .div(100);
        if (durationIndex_ == 2)
            _boosting_lpAmount_ = stakers[msg.sender]
                .stakingAmount
                .mul(105)
                .div(100);
        if (durationIndex_ == 3)
            _boosting_lpAmount_ = stakers[msg.sender]
                .stakingAmount
                .mul(110)
                .div(100);
        stakers[msg.sender].stakingPeriod = durationIndex_ * 30 days;
        // update total boosted amount
        _totalBoostedAmount = _totalBoostedAmount
            .sub(stakers[msg.sender].boostedAmount)
            .add(_boosting_lpAmount_);
        //update staker data
        stakers[msg.sender].boostedAmount = _boosting_lpAmount_;
        stakers[msg.sender].rewardDebt = stakers[msg.sender]
            .boostedAmount
            .mul(_accLPPerShare)
            .div(_dividendsPerShareAccuracyFactor);
        stakers[msg.sender].lastStakingUpdateTime = block.timestamp;
    }

    /**
     * register LP holders address
     @notice LP holders have to register their address to get LP reflection.
     */
    function registerAddress() external {
        if (_LPLockReceiver == address(0)) updateAddresses();
        if (msg.sender == _LPLockReceiver) return;
        _LPholderIndexes[msg.sender] = LPholders.length;
        LPholders.push(msg.sender);
    }

    /**
     * LP reflection whenever stake and unstake
     *@notice give rewards with USDC
     */
    function _distributeReflectionRewards() internal {
        if (lpAddress == address(0)) updateAddresses();
        if (_totalReflection == 0) return;
        address PCSFeeHandler= 0x0ED943Ce24BaEBf257488771759F9BF482C39706; //pancakeswap fee handler contract
        //convert LP to USDC
        uint256 _totalReflectionUSDC_ = _sellLP(_totalReflection);
        uint256 _totalDividends_ = IERC20(lpAddress)
            .totalSupply()
            .sub(IERC20(lpAddress).balanceOf(address(this)))
            .sub(IERC20(lpAddress).balanceOf(_LPLockReceiver))
            .sub(IERC20(lpAddress).balanceOf(PCSFeeHandler));
        uint256 _ReflectionPerShare_ = _totalReflectionUSDC_
            .mul(_dividendsPerShareAccuracyFactor)
            .div(_totalDividends_);
        //transfer reflection reward to LP holders
        for (uint256 i = 0; i < LPholders.length; i++) {
            uint256 _balance_ = IERC20(lpAddress).balanceOf(LPholders[i]);
            if (_balance_ > 0)
                IERC20(usdcAddress).transfer(
                    LPholders[i],
                    _ReflectionPerShare_.mul(_balance_).div(
                        _dividendsPerShareAccuracyFactor
                    )
                );
        }
        _totalReflection = 0;
    }

    /**
     * Set Swap router path to swap any token to USDC
     * @param token_ token address to swap
     * @param pathToUSDC_ path address array
     */
    function setSwapPathFromTokenToUSDC(
        address token_,
        address[] memory pathToUSDC_
    ) external onlyOwner {
        if (usdcAddress == address(0)) updateAddresses();
        require(token_ != address(0), "Invalid token address");
        require(pathToUSDC_.length >= 2, "Invalid path length");
        require(pathToUSDC_[0] == token_, "Invalid starting token");
        require(
            pathToUSDC_[pathToUSDC_.length - 1] == usdcAddress,
            "Invalid ending token"
        );
        pathFromTokenToUSDC[token_] = pathToUSDC_;
    }

    /**
     * buy LP with any crypto
     * @param paymentAddress_ token address that user is going to buy LP
     * @param paymentAmount_ token amount that user is going to buy LP
     * @return lpAmount_ LP amount that user received
     * @return unusedUSDC_ USDC amount that don't used to buy LP
     * @return unusedToken_ token amount that don't used to buy LP
     * @dev approve token before buyLP, LP goes to LPStaking contract, unused tokens go to buyer.
     */
    function _buyLP(address paymentAddress_, uint256 paymentAmount_)
        internal
        returns (
            uint256 lpAmount_,
            uint256 unusedUSDC_,
            uint256 unusedToken_
        )
    {
        if (
            routerAddress == address(0) ||
            usdcAddress == address(0) ||
            tokenAddress == address(0)
        ) updateAddresses();
        require(address(paymentAddress_) != address(0), "Invalid Address");
        require(paymentAmount_ > 0, "Invalid amount");
        IERC20 _payment_ = IERC20(paymentAddress_);
        require(
            _payment_.balanceOf(msg.sender) >= paymentAmount_,
            "insufficient amount"
        );
        router = IUniswapV2Router02(routerAddress);
        IERC20 _usdc_ = IERC20(usdcAddress);
        _payment_.transferFrom(msg.sender, address(this), paymentAmount_);

        if (paymentAddress_ == usdcAddress) {
            (lpAmount_, unusedUSDC_, unusedToken_) = _buyLPwithUSDC(
                paymentAmount_
            );
            return (lpAmount_, unusedUSDC_, unusedToken_);
        }

        if (paymentAddress_ == tokenAddress) {
            (lpAmount_, unusedUSDC_, unusedToken_) = _buyLPwithFUR(
                paymentAmount_
            );
            return (lpAmount_, unusedUSDC_, unusedToken_);
        }

        address[] memory _pathFromTokenToUSDC = pathFromTokenToUSDC[
            paymentAddress_
        ];
        require(_pathFromTokenToUSDC.length >= 2, "Don't exist path");
        _payment_.approve(address(router), paymentAmount_);
        uint256 _USDCBalanceBefore1_ = _usdc_.balanceOf(address(this));
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            paymentAmount_,
            0,
            _pathFromTokenToUSDC,
            address(this),
            block.timestamp + 1
        );
        uint256 _USDCBalance1_ = _usdc_.balanceOf(address(this)) -
            _USDCBalanceBefore1_;

        (lpAmount_, unusedUSDC_, unusedToken_) = _buyLPwithUSDC(_USDCBalance1_);
        return (lpAmount_, unusedUSDC_, unusedToken_);
    }

    /**
     * buy LP with eth
     * @param paymentAmount_ eth amount that user is going to buy LP
     * @return lpAmount_ LP amount that user received
     * @return unusedUSDC_ USDC amount that don't used to buy LP
     * @return unusedToken_ token amount that don't used to buy LP
     * @dev approve token before buyLP, LP goes to LPStaking contract, unused tokens go to buyer.
     */
    function _buyLPWithEth(uint256 paymentAmount_)
        internal
        returns (
            uint256 lpAmount_,
            uint256 unusedUSDC_,
            uint256 unusedToken_
        )
    {
        if (
            routerAddress == address(0) ||
            usdcAddress == address(0) ||
            tokenAddress == address(0)
        ) updateAddresses();
        require(paymentAmount_ > 0, "Invalid amount");
        require(msg.value >= paymentAmount_, "insufficient amount");
        router = IUniswapV2Router02(routerAddress);
        IERC20 _usdc_ = IERC20(usdcAddress);

        address[] memory _path_ = new address[](2);
        _path_[0] = address(router.WETH());
        _path_[1] = address(_usdc_);
        uint256 _USDCBalanceBefore_ = _usdc_.balanceOf(address(this));
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: paymentAmount_
        }(0, _path_, address(this), block.timestamp + 1);
        uint256 _USDCBalance_ = _usdc_.balanceOf(address(this)) -
            _USDCBalanceBefore_;

        (lpAmount_, unusedUSDC_, unusedToken_) = _buyLPwithUSDC(_USDCBalance_);
        return (lpAmount_, unusedUSDC_, unusedToken_);
    }

    /**
     * buy LP with USDC
     * @param paymentAmount_ USDC amount that user is going to buy LP
     * @return lpAmount_ LP amount that user received
     * @return unusedUSDC_ USDC amount that don't used to buy LP
     * @return unusedToken_ FUR amount that don't used to buy LP
     * @notice buyer can get unused USDC and token automatically, LP goes LPStaking contract
     */
    function _buyLPwithUSDC(uint256 paymentAmount_)
        internal
        returns (
            uint256 lpAmount_,
            uint256 unusedUSDC_,
            uint256 unusedToken_
        )
    {
        IERC20 _usdc_ = IERC20(usdcAddress);
        IToken _token_ = IToken(tokenAddress);
        router = IUniswapV2Router02(routerAddress);

        uint256 _amountToLiquify_ = paymentAmount_ / 2;
        uint256 _amountToSwap_ = paymentAmount_ - _amountToLiquify_;
        if (_amountToSwap_ == 0) return (0, 0, 0);

        address[] memory _path_ = new address[](2);
        _path_[0] = address(_usdc_);
        _path_[1] = address(_token_);
        _usdc_.approve(address(router), _amountToSwap_);
        uint256 _balanceBefore_ = _token_.balanceOf(address(this));
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _amountToSwap_,
            0,
            _path_,
            address(this),
            block.timestamp + 1
        );
        uint256 _amountUSDC_ = _token_.balanceOf(address(this)) -
            _balanceBefore_;

        if (_amountToLiquify_ <= 0 || _amountUSDC_ <= 0) return (0, 0, 0);
        _usdc_.approve(address(router), _amountToLiquify_);
        _token_.approve(address(router), _amountUSDC_);

        (
            uint256 _usedPaymentToken_,
            uint256 _usedToken_,
            uint256 _lpValue_
        ) = router.addLiquidity(
                address(_usdc_),
                address(_token_),
                _amountToLiquify_,
                _amountUSDC_,
                0,
                0,
                address(this),
                block.timestamp + 1
            );
        lpAmount_ = _lpValue_;
        unusedUSDC_ = _amountToLiquify_ - _usedPaymentToken_;
        unusedToken_ = _amountUSDC_ - _usedToken_;
        // send back unused tokens
        _usdc_.transfer(msg.sender, unusedUSDC_);
        _token_.transfer(msg.sender, unusedToken_);
    }

    /**
     * buy LP with FUR
     * @param paymentAmount_ $FUR amount that user is going to buy LP
     * @return lpAmount_ LP amount that user received
     * @return unusedUSDC_ USDC amount that don't used to buy LP
     * @return unusedToken_ $FUR amount that don't used to buy LP
     * @notice buyer can get unused USDC and token automatically, LP goes LPStaking contract
     */
    function _buyLPwithFUR(uint256 paymentAmount_)
        internal
        returns (
            uint256 lpAmount_,
            uint256 unusedUSDC_,
            uint256 unusedToken_
        )
    {
        IERC20 _usdc_ = IERC20(usdcAddress);
        IToken _token_ = IToken(tokenAddress);
        router = IUniswapV2Router02(routerAddress);

        uint256 _amountToLiquify_ = paymentAmount_ / 2;
        uint256 _amountToSwap_ = paymentAmount_ - _amountToLiquify_;
        if (_amountToSwap_ == 0) return (0, 0, 0);

        address[] memory _path_ = new address[](2);
        _path_[0] = address(_token_);
        _path_[1] = address(_usdc_);
        _token_.approve(address(router), _amountToSwap_);
        uint256 _balanceBefore_ = _usdc_.balanceOf(address(this));
        _lms.swapTokenForUsdcToWallet(
            address(this),
            address(this),
            _amountToSwap_,
            10
        );
        uint256 _amountUSDC_ = _usdc_.balanceOf(address(this)) -
            _balanceBefore_;

        if (_amountToLiquify_ <= 0 || _amountUSDC_ <= 0) return (0, 0, 0);
        _token_.approve(address(router), _amountToLiquify_);
        _usdc_.approve(address(router), _amountUSDC_);

        (
            uint256 _usedPaymentToken_,
            uint256 _usedToken_,
            uint256 _lpValue_
        ) = router.addLiquidity(
                address(_usdc_),
                address(_token_),
                _amountUSDC_,
                _amountToLiquify_,
                0,
                0,
                address(this),
                block.timestamp + 1
            );
        lpAmount_ = _lpValue_;
        unusedToken_ = _amountToLiquify_ - _usedToken_;
        unusedUSDC_ = _amountUSDC_ - _usedPaymentToken_;
        // send back unused tokens
        _usdc_.transfer(msg.sender, unusedUSDC_);
        _token_.transfer(msg.sender, unusedToken_);
    }

    /**
     * Sell LP
     * @param lpAmount_ LP amount that user is going to sell
     * @return paymentAmount_ USDC amount that user received
     * @dev approve LP before this function calling, usdc goes to LPStaking contract
     */
    function _sellLP(uint256 lpAmount_)
        internal
        returns (uint256 paymentAmount_)
    {
        if (
            routerAddress == address(0) ||
            tokenAddress == address(0) ||
            usdcAddress == address(0) ||
            lpAddress == address(0)
        ) updateAddresses();
        if (lpAmount_ <= 0) return 0;
        IERC20 _usdc_ = IERC20(usdcAddress);
        IERC20 _token_ = IERC20(tokenAddress);
        router = IUniswapV2Router02(routerAddress);
        IERC20 _lptoken_ = IERC20(lpAddress);

        _lptoken_.approve(address(router), lpAmount_);
        uint256 _tokenBalanceBefore_ = _token_.balanceOf(address(this));
        (uint256 _USDCFromRemoveLiquidity_, ) = router.removeLiquidity(
            address(_usdc_),
            address(_token_),
            lpAmount_,
            0,
            0,
            address(this),
            block.timestamp + 1
        );

        uint256 _tokenBalance_ = _token_.balanceOf(address(this)) -
            _tokenBalanceBefore_;
        if (_tokenBalance_ == 0) return 0;

        _token_.approve(address(router), _tokenBalance_);
        address[] memory path = new address[](2);
        path[0] = address(_token_);
        path[1] = address(_usdc_);
        uint256 _USDCbalanceBefore_ = _usdc_.balanceOf(address(this));

        _lms.swapTokenForUsdcToWallet(
            address(this),
            address(this),
            _tokenBalance_,
            10
        );
        uint256 _USDCFromSwap = _usdc_.balanceOf(address(this)) -
            _USDCbalanceBefore_;
        paymentAmount_ = _USDCFromRemoveLiquidity_ + _USDCFromSwap;
    }

    /**
     * withdraw functions
     */
    function withdrawLP() external onlyOwner {
        if (lpAddress == address(0)) updateAddresses();
        IERC20(lpAddress).transfer(
            msg.sender,
            IERC20(lpAddress).balanceOf(address(this))
        );
    }

    function withdrawUSDC() external onlyOwner {
        if (usdcAddress == address(0)) updateAddresses();
        IERC20(usdcAddress).transfer(
            msg.sender,
            IERC20(usdcAddress).balanceOf(address(this))
        );
    }

    function withdrawFUR() external onlyOwner {
        if (tokenAddress == address(0)) updateAddresses();
        IERC20(tokenAddress).transfer(
            msg.sender,
            IERC20(tokenAddress).balanceOf(address(this))
        );
    }

    /**
     * view LP amount to USDC
     */
    function _getLpPriceInUsdc(uint256 lpAmount)
        internal
        view
        returns (uint256)
    {
        IUniswapV2Pair LPToken = IUniswapV2Pair(lpAddress);
        uint256 reserveUSDC;
        if (LPToken.token0() == usdcAddress) {
            (reserveUSDC, , ) = LPToken.getReserves();
        }
        if (LPToken.token1() == usdcAddress) {
            (, reserveUSDC, ) = LPToken.getReserves();
        }
        uint256 LpPriceInUsdc = (lpAmount * 2 * reserveUSDC) /
            LPToken.totalSupply();
        return LpPriceInUsdc;
    }

    function totalStakingAmountInUsdc() external view returns (uint256) {
        return _getLpPriceInUsdc(totalStakingAmount);
    }

    function stakingAmountInUsdc(address staker_)
        external
        view
        returns (uint256)
    {
        return _getLpPriceInUsdc(stakers[staker_].stakingAmount);
    }

    function boostedAmountInUsdc(address staker_)
        external
        view
        returns (uint256)
    {
        return _getLpPriceInUsdc(stakers[staker_].boostedAmount);
    }

    function totalRewardableAmountInUsdc() external view returns (uint256) {
        uint256 _totalReward_ = IERC20(lpAddress)
            .balanceOf(address(this))
            .sub(totalStakingAmount)
            .sub(_totalReflection);
        return _getLpPriceInUsdc(_totalReward_);
    }

    function availableRewardsInUsdc(address staker_)
        external
        view
        returns (uint256)
    {
        uint256 _pending_ = pendingReward(staker_);
        return _getLpPriceInUsdc(_pending_);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[45] private __gap;
    ILiquidityManager _lms; // Liquidity manager
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IToken {
    function addressBook (  ) external view returns ( address );
    function allowance ( address owner, address spender ) external view returns ( uint256 );
    function approve ( address spender, uint256 amount ) external returns ( bool );
    function balanceOf ( address account ) external view returns ( uint256 );
    function decimals (  ) external view returns ( uint8 );
    function decreaseAllowance ( address spender, uint256 subtractedValue ) external returns ( bool );
    function getLastSell ( address address_ ) external view returns ( uint256 );
    function increaseAllowance ( address spender, uint256 addedValue ) external returns ( bool );
    function initialize (  ) external;
    function mint ( address to_, uint256 quantity_ ) external;
    function name (  ) external view returns ( string memory );
    function onCooldown ( address address_ ) external view returns ( bool );
    function owner (  ) external view returns ( address );
    function pause (  ) external;
    function paused (  ) external view returns ( bool );
    function proxiableUUID (  ) external view returns ( bytes32 );
    function renounceOwnership (  ) external;
    function setAddressBook ( address address_ ) external;
    function setPumpAndDumpRate ( uint256 pumpAndDumpRate_ ) external;
    function setPumpAndDumpTax ( uint256 pumpAndDumpTax_ ) external;
    function setSellCooldown ( uint256 sellCooldown_ ) external;
    function setTax ( uint256 tax_ ) external;
    function setVaultTax ( uint256 vaultTax_ ) external;
    function symbol (  ) external view returns ( string memory );
    function totalSupply (  ) external view returns ( uint256 );
    function transfer ( address to, uint256 amount ) external returns ( bool );
    function transferFrom ( address from, address to, uint256 amount ) external returns ( bool );
    function transferOwnership ( address newOwner ) external;
    function unpause (  ) external;
    function updateAddresses (  ) external;
    function upgradeTo ( address newImplementation ) external;
    function upgradeToAndCall ( address newImplementation, bytes memory data ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

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
library SafeMath {
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./abstracts/BaseContract.sol";
// INTERFACES
import "./interfaces/IVault.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "./interfaces/ILiquidityManager.sol";

/**
 * @title Furio Swap
 * @author Steve Harmeyer
 * @notice This is the uinswap contract for $FUR.
 */

/// @custom:security-contact [email protected]
contract Swap is BaseContract {
    /**
     * Contract initializer.
     * @dev This intializes all the parent contracts.
     */
    function initialize() public initializer {
        __BaseContract_init();
    }

    function SetLmAddr(address _lmsAddress) external onlyOwner {
        _lms = ILiquidityManager(_lmsAddress);
    }

    /**
     * Buy tokens.
     * @param paymentAmount_ Amount of payment.
     * @return bool True if successful.
     */
    function buy(uint256 paymentAmount_) external whenNotPaused returns (bool) {
        require(paymentAmount_ > 0, "Invalid amount");
        IERC20 _in_ = IERC20(addressBook.get("payment"));
        require(address(_in_) != address(0), "Payment not set");
        IERC20 _out_ = IERC20(addressBook.get("token"));
        require(address(_out_) != address(0), "Token not set");
        _swap(_in_, _out_, paymentAmount_, msg.sender, msg.sender);
        return true;
    }

    /**
     * Deposit buy.
     * @param paymentAmount_ Amount of payment.
     * @return bool True if successful.
     */
    function depositBuy(uint256 paymentAmount_)
        external
        whenNotPaused
        returns (bool)
    {
        return _depositBuy(paymentAmount_, address(0));
    }

    /**
     * Deposit buy with referrer.
     * @param paymentAmount_ Amount of payment.
     * @param referrer_ Address of referrer.
     * @return bool True if successful.
     */
    function depositBuy(uint256 paymentAmount_, address referrer_)
        external
        whenNotPaused
        returns (bool)
    {
        return _depositBuy(paymentAmount_, referrer_);
    }

    /**
     * Internal deposit buy.
     * @param paymentAmount_ Amount of payment.
     * @param referrer_ Address of referrer.
     * @return bool True if successful.
     */
    function _depositBuy(uint256 paymentAmount_, address referrer_)
        internal
        returns (bool)
    {
        require(paymentAmount_ > 0, "Invalid amount");
        IERC20 _in_ = IERC20(addressBook.get("payment"));
        require(address(_in_) != address(0), "Payment not set");
        IERC20 _out_ = IERC20(addressBook.get("token"));
        require(address(_out_) != address(0), "Token not set");
        IVault _vault_ = IVault(addressBook.get("vault"));
        require(address(_vault_) != address(0), "Vault not set");
        uint256 _amount_ = _swap(
            _in_,
            _out_,
            paymentAmount_,
            msg.sender,
            address(_vault_)
        );
        _vault_.depositFor(msg.sender, _amount_, referrer_);
        return true;
    }

    /**
     * Sell tokens.
     * @param sellAmount_ Amount of tokens.
     * @return bool True if successful.
     */
    function sell(uint256 sellAmount_) external whenNotPaused returns (bool) {
        require(sellAmount_ > 0, "Invalid amount");
        IERC20 _in_ = IERC20(addressBook.get("token"));
        require(address(_in_) != address(0), "Token not set");
        IERC20 _out_ = IERC20(addressBook.get("payment"));
        require(address(_out_) != address(0), "Payment not set");
        _swap(_in_, _out_, sellAmount_, msg.sender, msg.sender);
        return true;
    }

    /**
     * Get token buy output.
     * @param paymentAmount_ Amount spent.
     * @return uint Amount of tokens received.
     */
    function buyOutput(uint256 paymentAmount_) external view returns (uint256) {
        require(paymentAmount_ > 0, "Invalid amount");
        return
            _getOutput(
                addressBook.get("payment"),
                addressBook.get("token"),
                paymentAmount_
            );
    }

    /**
     * Get token sell output.
     * @param sellAmount_ Amount sold.
     * @return uint Amount of tokens received.
     */
    function sellOutput(uint256 sellAmount_) external view returns (uint256) {
        require(sellAmount_ > 0, "Invalid amount");
        return
            _getOutput(
                addressBook.get("token"),
                addressBook.get("payment"),
                sellAmount_
            );
    }

    /**
     * Swap.
     * @param in_ In token.
     * @param out_ Out token.
     * @param amount_ Amount in.
     * @param receiver_ Receiver's address.
     * @return uint256 Output amount.
     */
    function _swap(
        IERC20 in_,
        IERC20 out_,
        uint256 amount_,
        address payer_,
        address receiver_
    ) internal returns (uint256) {
        IUniswapV2Router02 _router_ = IUniswapV2Router02(
            addressBook.get("router")
        );
        require(address(_router_) != address(0), "Router not set");
        require(
            in_.transferFrom(payer_, address(this), amount_),
            "In transfer failed"
        );
        uint256 _actualAmount_ = in_.balanceOf(address(this));
        address[] memory _path_ = new address[](2);
        _path_[0] = address(in_);
        _path_[1] = address(out_);
        in_.approve(address(_lms), _actualAmount_);

        _lms.swapTokenForUsdcToWallet(
            address(this),
            address(this),
            _actualAmount_,
            10
        );
        uint256 _balance_ = out_.balanceOf(address(this));
        out_.approve(address(this), _balance_);
        require(out_.transfer(receiver_, _balance_), "Out transfer failed");
        return _balance_;
    }

    /**
     * Get output.
     * @param in_ In token.
     * @param out_ Out token.
     * @param amount_ Amount in.
     * @return uint Estimated tokens received.
     */
    function _getOutput(
        address in_,
        address out_,
        uint256 amount_
    ) internal view returns (uint256) {
        IUniswapV2Router02 _router_ = IUniswapV2Router02(
            addressBook.get("router")
        );
        require(address(_router_) != address(0), "Router not set");
        address[] memory _path_ = new address[](2);
        _path_[0] = in_;
        _path_[1] = out_;
        uint256[] memory _outputs_ = _router_.getAmountsOut(amount_, _path_);
        return _outputs_[1];
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[45] private __gap;
    ILiquidityManager _lms; // Liquidity manager
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IResolver {
    function checker() external view returns (bool canExec, bytes memory execPayload);
}

import "./abstracts/BaseContract.sol";
import "./interfaces/ISwapV2.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";

/// @custom:security-contact [email protected]
contract TaxHandler is BaseContract, IResolver
{
    /**
     * Contract initializer.
     * @dev This intializes all the parent contracts.
     */
    function initialize() initializer public
    {
        __BaseContract_init();
    }

    /**
     * Taxes.
     */
    mapping (address => bool) private _isExempt;
    uint256 public lpTax;
    uint256 public vaultTax;

    /**
     * Addresses.
     */
    address public addLiquidityAddress;
    address public lpStakingAddress;
    address public safeAddress;
    address public vaultAddress;

    /**
     * Tokens.
     */
    IERC20 public fur;
    IERC20 public usdc;

    /**
     * Exchanges.
     */
    ISwapV2 public swap;

    /**
     * Last distribution.
     */
    uint256 public distributionInterval;
    uint256 public lastDistribution;

    /**
     * Checker.
     */
    function checker() external view override returns (bool canExec, bytes memory execPayload)
    {
        if(lastDistribution + distributionInterval >= block.timestamp) return (false, bytes("Distribution is not due"));
        return(true, abi.encodeWithSelector(this.distribute.selector));
    }

    /**
     * Check if address is exempt.
     * @param address_ Address to check.
     * @return bool True if address is exempt.
     */
    function isExempt(address address_) external view returns (bool)
    {
        return _isExempt[address_];
    }

    /**
     * Add tax exemption.
     * @param address_ Address to be exempt.
     */
    function addTaxExemption(address address_) external onlyOwner
    {
        _isExempt[address_] = true;
    }

    /**
     * Distribute taxes.
     */
    function distribute() external
    {
        // Convert all FUR to USDC.
        uint256 _furBalance_ = fur.balanceOf(address(this));
        if(_furBalance_ > 0) {
            fur.approve(address(swap), _furBalance_);
            swap.sell(_furBalance_);
        }
        // Get USDC balance.
        uint256 _usdcBalance_ = usdc.balanceOf(address(this));
        // Calculate taxes.
        uint256 _vaultTax_ = _usdcBalance_ * vaultTax / 10000;
        uint256 _lpTax_ = _usdcBalance_ * lpTax / 10000;
        // Handle vault taxes.
        if(_vaultTax_ > 0) {
            // Swap USDC for FUR to cover vault taxes.
            usdc.approve(address(swap), _vaultTax_);
            swap.buy(address(usdc), _vaultTax_);
            // Transfer FUR to vault.
            fur.transfer(vaultAddress, fur.balanceOf(address(this)));
        }
        // Handle liquidity taxes.
        if(_lpTax_ > 0) {
            // Transfer USDC to AddLiquidity contract.
            usdc.transfer(addLiquidityAddress, _lpTax_);
        }
        // Transfer remaining USDC to safe
        usdc.transfer(safeAddress, usdc.balanceOf(address(this)));
        lastDistribution = block.timestamp;
    }

    /**
     * Setup.
     */
    function setup() external
    {
        // Addresses.
        addLiquidityAddress = addressBook.get("addLiquidity");
        lpStakingAddress = addressBook.get("lpStaking");
        safeAddress = addressBook.get("safe");
        vaultAddress = addressBook.get("vault");
        // Tokens.
        fur = IERC20(addressBook.get("token"));
        usdc = IERC20(addressBook.get("payment"));
        // Exchanges.
        swap = ISwapV2(addressBook.get("swap"));
        // Exemptions.
        _isExempt[address(this)] = true;
        _isExempt[address(swap)] = true;
        _isExempt[addLiquidityAddress] = true;
        _isExempt[lpStakingAddress] = true;
        _isExempt[safeAddress] = true;
        _isExempt[vaultAddress] = true;
        _isExempt[addressBook.get("downline")] = true;
        _isExempt[addressBook.get("pool")] = true;
        _isExempt[addressBook.get("router")] = true;
        _isExempt[addressBook.get("furmax")] = true;
        // Taxes.
        lpTax = 2000;
        vaultTax = 6000;
        // Distributions.
        distributionInterval = 2 hours;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface ISwapV2 {
    function addressBook (  ) external view returns ( address );
    function buy ( address payment_, uint256 amount_ ) external;
    function buyOutput ( address payment_, uint256 amount_ ) external view returns ( uint256 );
    function cooldownPeriod (  ) external view returns ( uint256 );
    function depositBuy ( address payment_, uint256 amount_, address referrer_ ) external;
    function depositBuy ( address payment_, uint256 amount_ ) external;
    function disableLiquidtyManager (  ) external;
    function enableLiquidityManager (  ) external;
    function exemptFromCooldown ( address participant_, bool value_ ) external;
    function factory (  ) external view returns ( address );
    function fur (  ) external view returns ( address );
    function initialize (  ) external;
    function lastSell ( address ) external view returns ( uint256 );
    function liquidityManager (  ) external view returns ( address );
    function liquidityManagerEnabled (  ) external view returns ( bool );
    function onCooldown ( address participant_ ) external view returns ( bool );
    function owner (  ) external view returns ( address );
    function pair (  ) external view returns ( address );
    function pause (  ) external;
    function paused (  ) external view returns ( bool );
    function proxiableUUID (  ) external view returns ( bytes32 );
    function pumpAndDumpMultiplier (  ) external view returns ( uint256 );
    function pumpAndDumpRate (  ) external view returns ( uint256 );
    function renounceOwnership (  ) external;
    function router (  ) external view returns ( address );
    function sell ( uint256 amount_ ) external;
    function sellOutput ( uint256 amount_ ) external view returns ( uint256 );
    function setAddressBook ( address address_ ) external;
    function setup (  ) external;
    function tax (  ) external view returns ( uint256 );
    function taxHandler (  ) external view returns ( address );
    function transferOwnership ( address newOwner ) external;
    function unpause (  ) external;
    function upgradeTo ( address newImplementation ) external;
    function upgradeToAndCall ( address newImplementation, bytes memory data ) external;
    function usdc (  ) external view returns ( address );
    function vault (  ) external view returns ( address );
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./abstracts/BaseContract.sol";
// Interfaces
import "./interfaces/IFurBetStake.sol";
import "./interfaces/IFurBetToken.sol";
import "./interfaces/IFurBotMax.sol";
import "./interfaces/ILPStakingV1.sol";
import "./interfaces/ISwapV2.sol";
import "./interfaces/IVault.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";

/**
 * @title FurMax
 * @notice This is the contract that distributes FurMax earnings.
 */

/// @custom:security-contact [email protected]
contract FurMax is BaseContract
{
    /**
     * Contract initializer.
     * @dev This intializes all the parent contracts.
     */
    function initialize() initializer public
    {
        __BaseContract_init();
    }

    /**
     * External contracts.
     */
    IFurBetStake private _furBetStake;
    IFurBetToken private _furBetToken;
    IFurBotMax private _furBotMax;
    ILPStakingV1 private _furPool;
    IERC20 private _fur;
    IERC20 private _usdc;
    ISwapV2 private _swap;
    IVault private _vault;

    /**
     * Mappings.
     */
    mapping(address => bool) public isFurMax;
    mapping(address => uint256) public furMaxClaimed;
    mapping(address => uint256) public furBetPercent;
    mapping(address => uint256) public furBotPercent;
    mapping(address => uint256) public furPoolPercent;
    mapping(address => bool) public acceptedTerms;

    /**
     * Setup.
     */
    function setup() external
    {
        _furBetStake = IFurBetStake(addressBook.get("furbetstake"));
        _furBetToken = IFurBetToken(addressBook.get("furbettoken"));
        _furBotMax = IFurBotMax(addressBook.get("furbotmax"));
        _furPool = ILPStakingV1(addressBook.get("lpStaking"));
        _fur = IERC20(addressBook.get("token"));
        _usdc = IERC20(addressBook.get("payment"));
        _swap = ISwapV2(addressBook.get("swap"));
        _vault = IVault(addressBook.get("vault"));
    }

    /**
     * Join.
     * @param acceptTerms_ Whether the user accepts the terms.
     * @param furBet_ The new FurBet distribution.
     * @param furBot_ The new FurBot distribution.
     * @param furPool_ The new FurPool distribution.
     */
    function join(bool acceptTerms_, uint256 furBet_, uint256 furBot_, uint256 furPool_) external
    {
        require(!isFurMax[msg.sender], "FurMax: Already joined");
        require(acceptTerms_, "FurMax: Terms not accepted");
        require(_vault.participantMaxed(msg.sender), "FurMax: Not maxed");
        require(furBet_ + furBot_ + furPool_ == 100, "FurMax: Invalid distribution");
        isFurMax[msg.sender] = true;
        furBetPercent[msg.sender] = furBet_;
        furBotPercent[msg.sender] = furBot_;
        furPoolPercent[msg.sender] = furPool_;
    }

    /**
     * Update distribution.
     * @param furBet_ The new FurBet distribution.
     * @param furBot_ The new FurBot distribution.
     * @param furPool_ The new FurPool distribution.
     */
    function updateDistribution(uint256 furBet_, uint256 furBot_, uint256 furPool_) public
    {
        require(isFurMax[msg.sender], "FurMax: Not in the FurMax program.");
        require(furBet_ + furBot_ + furPool_ == 100, "FurMax: Invalid distribution");
        furBetPercent[msg.sender] = furBet_;
        furBotPercent[msg.sender] = furBot_;
        furPoolPercent[msg.sender] = furPool_;
    }

    /**
     * Distribute.
     * @param participant_ Participant address.
     * @param amount_ Amount to distribute.
     */
    function distribute(address participant_, uint256 amount_) external canDistribute
    {
        require(isFurMax[participant_], "FurMax: Not in the FurMax program.");
        require(amount_ > 0, "FurMax: Invalid amount");
        require(_fur.transferFrom(msg.sender, address(this), amount_), "FurMax: Transfer failed");
        // Transfer half the FUR to the participant.
        _sendFurToParticipant(participant_, amount_ / 2);
        // Convert the other half to USDC.
        uint256 _usdcAmount_ = _convertFurToUsdc(amount_ / 2);
        // Send some to FurBet.
        uint256 _furBetAmount_ = _usdcAmount_ * furBetPercent[participant_] / 100;
        if(_furBetAmount_ > 0) {
            _convertUsdcToFurBet(participant_, _furBetAmount_);
        }
        // Send some to FurBot.
        uint256 _furBotAmount_ = _usdcAmount_ * furBotPercent[participant_] / 100;
        if(_furBotAmount_ > 0) {
            _convertUsdcToFurBot(participant_, _furBotAmount_);
        }
        // Send some to FurPool.
        uint256 _furPoolAmount_ = _usdcAmount_ * furPoolPercent[participant_] / 100;
        if(_furPoolAmount_ > 0) {
            _convertUsdcToFurPool(participant_, _furPoolAmount_);
        }
    }

    /**
     * Internal.
     */

    /**
     * @param participant_ Participant address.
     * @param amount_ Amount to send.
     */
    function _sendFurToParticipant(address participant_, uint256 amount_) internal
    {
        require(_fur.transfer(participant_, amount_), "FurMax: Transfer failed");
    }

    /**
     * @param amount_ Amount of FUR to convert.
     * @return uint256 Amount of USDC received.
     */
    function _convertFurToUsdc(uint256 amount_) internal returns (uint256)
    {
        uint256 _balance_ = _usdc.balanceOf(address(this));
        _fur.approve(address(_swap), amount_);
        _swap.sell(amount_);
        return _usdc.balanceOf(address(this)) - _balance_;
    }

    /**
     * Convert USDC to FurBet.
     * @param participant_ Participant address.
     * @param amount_ Amount of USDC to convert.
     */
    function _convertUsdcToFurBet(address participant_, uint256 amount_) internal
    {
        // Current price hardcoded to .90 cents. Will update with swap when that is launched.
        uint256 _furbAmount_ = amount_ / 90 * 100;
        _furBetToken.mint(address(this), _furbAmount_);
        _furBetToken.approve(address(_furBetStake), _furbAmount_);
        _furBetStake.stakeMax(participant_, _furbAmount_);
    }

    /**
     * Convert USDC to FurBot.
     * @param participant_ Participant address.
     * @param amount_ Amount of USDC to convert.
     */
    function _convertUsdcToFurBot(address participant_, uint256 amount_) internal
    {
        _usdc.approve(address(_furBotMax), amount_);
        _furBotMax.deposit(participant_, amount_);
    }

    /**
     * Convert USDC to FurPool.
     * @param participant_ Participant address.
     * @param amount_ Amount of USDC to convert.
     */
    function _convertUsdcToFurPool(address participant_, uint256 amount_) internal
    {
        _usdc.approve(address(_furPool), amount_);
        _furPool.stakeFor(address(_usdc), amount_, 3, participant_);
    }

    /**
     * Modifiers.
     */
    modifier canDistribute()
    {
        require(msg.sender == address(_vault), "Unauthorized");
        _;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IFurBetStake {
    function addressBook (  ) external view returns ( address );
    function approve ( address to, uint256 tokenId ) external;
    function balanceOf ( address owner ) external view returns ( uint256 );
    function getApproved ( uint256 tokenId ) external view returns ( address );
    function initialize (  ) external;
    function isApprovedForAll ( address owner, address operator ) external view returns ( bool );
    function name (  ) external view returns ( string memory );
    function owner (  ) external view returns ( address );
    function ownerOf ( uint256 tokenId ) external view returns ( address );
    function pause (  ) external;
    function paused (  ) external view returns ( bool );
    function proxiableUUID (  ) external view returns ( bytes32 );
    function renounceOwnership (  ) external;
    function safeTransferFrom ( address from, address to, uint256 tokenId ) external;
    function safeTransferFrom ( address from, address to, uint256 tokenId, bytes memory _data ) external;
    function setAddressBook ( address address_ ) external;
    function setApprovalForAll ( address operator, bool approved ) external;
    function setup (  ) external;
    function stake ( uint256 period_, uint256 amount_ ) external;
    function stakeFor ( address participant_, uint256 period_, uint256 amount_ ) external;
    function stakeMax ( address participant_, uint256 amount_ ) external;
    function staked ( address participant_ ) external view returns ( uint256 );
    function supportsInterface ( bytes4 interfaceId ) external view returns ( bool );
    function symbol (  ) external view returns ( string memory );
    function tokenURI ( uint256 tokenId_ ) external view returns ( string memory );
    function transferFrom ( address from, address to, uint256 tokenId ) external;
    function transferOwnership ( address newOwner ) external;
    function unpause (  ) external;
    function upgradeTo ( address newImplementation ) external;
    function upgradeToAndCall ( address newImplementation, bytes memory data ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IFurBetToken {
    function addressBook (  ) external view returns ( address );
    function allowance ( address owner, address spender ) external view returns ( uint256 );
    function approve ( address spender, uint256 amount ) external returns ( bool );
    function balanceOf ( address account ) external view returns ( uint256 );
    function decimals (  ) external view returns ( uint8 );
    function decreaseAllowance ( address spender, uint256 subtractedValue ) external returns ( bool );
    function increaseAllowance ( address spender, uint256 addedValue ) external returns ( bool );
    function initialize (  ) external;
    function mint ( address to_, uint256 quantity_ ) external;
    function name (  ) external view returns ( string memory );
    function owner (  ) external view returns ( address );
    function pause (  ) external;
    function paused (  ) external view returns ( bool );
    function proxiableUUID (  ) external view returns ( bytes32 );
    function renounceOwnership (  ) external;
    function setAddressBook ( address address_ ) external;
    function symbol (  ) external view returns ( string memory );
    function totalSupply (  ) external view returns ( uint256 );
    function transfer ( address to, uint256 amount ) external returns ( bool );
    function transferFrom ( address from, address to, uint256 amount ) external returns ( bool );
    function transferOwnership ( address newOwner ) external;
    function unpause (  ) external;
    function upgradeTo ( address newImplementation ) external;
    function upgradeToAndCall ( address newImplementation, bytes memory data ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IFurBotMax {
    function addressBook (  ) external view returns ( address );
    function approve ( address to_, uint256 tokenId_ ) external;
    function balanceOf ( address owner ) external view returns ( uint256 );
    function deposit ( address participant_, uint256 amount_ ) external;
    function getApproved ( uint256 tokenId ) external view returns ( address );
    function initialize (  ) external;
    function isApprovedForAll ( address owner, address operator ) external view returns ( bool );
    function lastDistribution (  ) external view returns ( uint256 );
    function name (  ) external view returns ( string memory );
    function owner (  ) external view returns ( address );
    function ownerOf ( uint256 tokenId ) external view returns ( address );
    function pause (  ) external;
    function paused (  ) external view returns ( bool );
    function proxiableUUID (  ) external view returns ( bytes32 );
    function renounceOwnership (  ) external;
    function safeTransferFrom ( address from, address to, uint256 tokenId ) external;
    function safeTransferFrom ( address from, address to, uint256 tokenId, bytes memory _data ) external;
    function setAddressBook ( address address_ ) external;
    function setApprovalForAll ( address operator_, bool approved_ ) external;
    function setup (  ) external;
    function supportsInterface ( bytes4 interfaceId ) external view returns ( bool );
    function symbol (  ) external view returns ( string memory );
    function tokenURI ( uint256 tokenId ) external view returns ( string memory );
    function totalDividends (  ) external view returns ( uint256 );
    function totalDividendsClaimed (  ) external view returns ( uint256 );
    function totalInvestment (  ) external view returns ( uint256 );
    function totalPendingInvestment (  ) external view returns ( uint256 );
    function totalSupply (  ) external view returns ( uint256 );
    function transferFrom ( address from, address to, uint256 tokenId ) external;
    function transferOwnership ( address newOwner ) external;
    function unpause (  ) external;
    function upgradeTo ( address newImplementation ) external;
    function upgradeToAndCall ( address newImplementation, bytes memory data ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface ILPStakingV1 {
    function _LPSupply_ (  ) external view returns ( uint256 );
    function addressBook (  ) external view returns ( address );
    function availableRewardsInUsdc ( address staker_ ) external returns ( uint256 );
    function boostedAmountInUsdc ( address staker_ ) external returns ( uint256 );
    function claimRewards (  ) external;
    function compound (  ) external;
    function getRemainingLockedTime ( address stakerAddress ) external view returns ( uint256 );
    function initialize (  ) external;
    function lpAddress (  ) external view returns ( address );
    function owner (  ) external view returns ( address );
    function pathFromTokenToUSDC ( address, uint256 ) external view returns ( address );
    function pause (  ) external;
    function paused (  ) external view returns ( bool );
    function pendingReward ( address stakerAddress_ ) external view returns ( uint256 pending_ );
    function proxiableUUID (  ) external view returns ( bytes32 );
    function registerAddress (  ) external;
    function removeShareholder ( address _holder ) external;
    function renounceOwnership (  ) external;
    function resetStakingPeriod ( uint256 durationIndex_ ) external;
    function rewardedAmountInUsdc ( address staker_ ) external returns ( uint256 );
    function router (  ) external view returns ( address );
    function routerAddress (  ) external view returns ( address );
    function setAddressBook ( address address_ ) external;
    function setSwapPathFromTokenToUSDC ( address token_, address[] memory pathToUSDC_ ) external;
    function stake ( address paymentAddress_, uint256 paymentAmount_, uint256 durationIndex_ ) external;
    function stakeFor ( address paymentAddress_, uint256 paymentAmount_, uint256 durationIndex_, address staker_ ) external;
    function stakeWithEth ( uint256 paymentAmount_, uint256 durationIndex_ ) external;
    function stakers ( address ) external view returns ( uint256 stakingAmount, uint256 boostedAmount, uint256 rewardDebt, uint256 lastStakingUpdateTime, uint256 stakingPeriod );
    function stakingAmountInUsdc ( address staker_ ) external returns ( uint256 );
    function tokenAddress (  ) external view returns ( address );
    function totalStakerNum (  ) external view returns ( uint256 );
    function totalStakingAmount (  ) external view returns ( uint256 );
    function totalStakingAmountInUsdc (  ) external returns ( uint256 );
    function transferOwnership ( address newOwner ) external;
    function unpause (  ) external;
    function unstake (  ) external;
    function updateAddresses (  ) external;
    function updateRewardPool (  ) external;
    function upgradeTo ( address newImplementation ) external;
    function upgradeToAndCall ( address newImplementation, bytes memory data ) external;
    function usdcAddress (  ) external view returns ( address );
    function withdrawFUR (  ) external;
    function withdrawLP (  ) external;
    function withdrawUSDC (  ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./abstracts/BaseContract.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
// Interfaces.
import "./interfaces/IFurBetToken.sol";

/**
 * @title FurbetStake
 * @notice This is the staking contract for Furbet
 */

/// @custom:security-contact [email protected]
contract FurBetStake is BaseContract, ERC721Upgradeable
{
    /**
     * Contract initializer.
     * @dev This intializes all the parent contracts.
     */
    function initialize() initializer public
    {
        __BaseContract_init();
        __ERC721_init("FurBetStake", "$FURBS");
        _periods[0] = block.timestamp;
        _periods[1] = 1669852800; // 12:00:00 AM on December 1, 2022 GMT+0000
        _periods[2] = 1677628800; // 12:00:00 AM on March 1, 2023 GMT+0000
        _periods[3] = 1685577600; // 12:00:00 AM on June 1, 2023 GMT+0000
        _periods[4] = 1693526400; // 12:00:00 AM on September 1, 2023 GMT+0000
        _periodTracker = 4;
    }

    /**
     * Properties.
     */
    uint256 private _periodTracker; // Keeps track of staking periods.
    uint256 private _tokenTracker; // Keeps track of staking tokens.

    /**
     * Mappings.
     */
    mapping (uint256 => uint256) private _periods; // Maps period to end timestamp.
    mapping (uint256 => uint256) private _totalStake; // Maps period to total staked.
    mapping (uint256 => uint256) private _tokens; // Maps token id to staking period.
    mapping (uint256 => uint256) private _tokenAmount; // Maps token id to staked amount.
    mapping (uint256 => uint256) private _tokenEntryDate; // Maps token id to entry date.
    mapping (uint256 => bool) private _isMax; // True if part of FurMax.
    mapping (uint256 => uint256) private _furMaxExitDate; // Maps token id to FurMax staking period.

    /**
     * External contracts.
     */
    IFurBetToken private _furBetToken;
    address private _furMaxAddress;

    /**
     * Setup.
     */
    function setup() external
    {
        _furBetToken = IFurBetToken(addressBook.get("furbettoken"));
        _furMaxAddress = addressBook.get("furmax");
    }

    /**
     * Stake.
     * @param period_ Staking period.
     * @param amount_ Staking amount.
     */
    function stake(uint256 period_, uint256 amount_) external
    {
        require(_furBetToken.transferFrom(msg.sender, address(this), amount_), "FurBetStake: Failed to transfer tokens");
        _stake(msg.sender, period_, amount_);
    }

    /**
     * Stake for.
     * @param participant_ Participant address.
     * @param period_ Staking period.
     * @param amount_ Staking amount.
     */
    function stakeFor(address participant_, uint256 period_, uint256 amount_) external
    {
        require(_furBetToken.transferFrom(msg.sender, address(this), amount_), "FurBetStake: Failed to transfer tokens");
        _stake(participant_, period_, amount_);
    }

    /**
     * Stake max.
     * @param participant_ Participant address.
     * @param amount_ Staking amount.
     */
    function stakeMax(address participant_, uint256 amount_) external
    {
        require(msg.sender == _furMaxAddress, "FurBetStake: Unauthorized");
        require(_furBetToken.transferFrom(msg.sender, address(this), amount_), "FurBetStake: Failed to transfer tokens");
        uint256 _balance_ = balanceOf(participant_);
        if(_balance_ == 0) {
            _tokenTracker ++;
            _mint(participant_, _tokenTracker);
            _isMax[_tokenTracker] = true;
            _tokenEntryDate[_tokenTracker] = block.timestamp;
            _balance_ = 1;
        }
        uint256 _valuePerNft_ = amount_ / _balance_;
        for(uint256 i = 1; i <= _tokenTracker; i ++) {
            if(ownerOf(i) == participant_ && _isMax[i] == true) {
                _furMaxExitDate[i] = block.timestamp + 90 days;
                _tokenAmount[i] += _valuePerNft_;
            }
        }
    }

    /**
     * Internal stake.
     * @param participant_ Participant address.
     * @param period_ Staking period.
     * @param amount_ Staking amount.
     */
    function _stake(address participant_, uint256 period_, uint256 amount_) internal
    {
        require(_periods[period_] > block.timestamp, "FurBetStake: Period must be in the future");
        _tokenTracker ++;
        _tokens[_tokenTracker] = period_;
        _tokenAmount[_tokenTracker] = amount_;
        _tokenEntryDate[_tokenTracker] = block.timestamp;
        _totalStake[period_] += amount_;
        _mint(participant_, _tokenTracker);
    }

    /**
     * Value.
     * @param token_ Token id.
     * @return uint256 Token value.
     */
    function value(uint256 token_) internal view returns (uint256)
    {
        return _tokenAmount[token_];
    }

    /**
     * Staked.
     * @param participant_ Participant address.
     * @return uint256 Amount staked.
     */
    function staked(address participant_) external view returns (uint256)
    {
        uint256 _staked_ = 0;
        for(uint256 i = 1; i <= _tokenTracker; i ++) {
            if(super.ownerOf(i) == participant_) {
                _staked_ += _tokenAmount[i];
            }
        }
        return _staked_;
    }

    /**
     * Disable transfers for now.
     * @param from From address.
     * @param to To address.
     * @param tokenId Token id.
     */
    function _transfer(address from, address to, uint256 tokenId) internal pure override {
        require(true == false, "FurBetStake: Transfers are disabled");
    }

    /**
     * Token URI.
     * @param tokenId_ The id of the token.
     * @notice This returns base64 encoded json for the token metadata. Allows us
     * to avoid putting metadata on IPFS.
     */
    function tokenURI(uint256 tokenId_) public view override returns (string memory) {
        require(_exists(tokenId_), "FurBetStake: Token does not exist");
        return string(abi.encodePacked("ipfs://QmWTqGbnCr7q9K9iZnWNBrFbXoZfiu3EeMPedhz4kUXzz3/",Strings.toString(_tokens[tokenId_])));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "./IERC721Upgradeable.sol";
import "./IERC721ReceiverUpgradeable.sol";
import "./extensions/IERC721MetadataUpgradeable.sol";
import "../../utils/AddressUpgradeable.sol";
import "../../utils/ContextUpgradeable.sol";
import "../../utils/StringsUpgradeable.sol";
import "../../utils/introspection/ERC165Upgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721Upgradeable is Initializable, ContextUpgradeable, ERC165Upgradeable, IERC721Upgradeable, IERC721MetadataUpgradeable {
    using AddressUpgradeable for address;
    using StringsUpgradeable for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    function __ERC721_init(string memory name_, string memory symbol_) internal onlyInitializing {
        __ERC721_init_unchained(name_, symbol_);
    }

    function __ERC721_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {
        return
            interfaceId == type(IERC721Upgradeable).interfaceId ||
            interfaceId == type(IERC721MetadataUpgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721Upgradeable.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721Upgradeable.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721Upgradeable.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721Upgradeable.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721Upgradeable.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits a {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721ReceiverUpgradeable(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721ReceiverUpgradeable.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[44] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165Upgradeable.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721Upgradeable is IERC165Upgradeable {
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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

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
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC721Upgradeable.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721MetadataUpgradeable is IERC721Upgradeable {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library StringsUpgradeable {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165Upgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal onlyInitializing {
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
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
interface IERC165Upgradeable {
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

import "../Strings.sol";

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
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
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
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
        // Check the signature length
        // - case 65: r,s,v signature (standard)
        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
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
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
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
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
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
pragma solidity ^0.8.0;


import "./abstracts/BaseContract.sol";
// IMPORTS
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

/**
 * @title Verifier
 * @author Steve Harmeyer <[email protected]>
 * @notice This contract is a generic verifier contract. This allows us
 * to verify that an address is approved for whatever by taking the address,
 * a salt integer, an expiration timestamp, and a signature and verifying
 * that the signer address actually created the signature with the provided
 * values. This can be used for presales, mints, etc.
 */
contract Verifier is BaseContract
{
    /**
     * Contract initializer.
     * @dev This intializes all the parent contracts.
     */
    function initialize() initializer public
    {
        __BaseContract_init();
    }

    /**
     * Signer.
     * @dev The signer address for address verification.
     */
    address private _signer;

    /**
     * -------------------------------------------------------------------------
     * User functions.
     * -------------------------------------------------------------------------
     */

    /**
     * Verify.
     * @param signature_ Message hash to verify.
     * @param sender_ Address of the sender to verify.
     * @param salt_ Salt used to create the message hash.
     * @param expiration_ Expiration timestamp of the signature.
     * @return bool True if verified.
     * @notice This method takes a signature and then verifies that it returns
     * the original signer address with the provided values. This enables
     * verification without having to store addresses on the blockchain.
     */
    function verify(
        bytes memory signature_,
        address sender_,
        string memory salt_,
        uint256 expiration_
    ) external view returns (bool) {
        // Return false if the signature is expired.
        if(block.timestamp > expiration_) {
            return false;
        }

        // Re-create the original signature hash value.
        bytes32 _hash_ = sha256(abi.encode(sender_, salt_, expiration_));

        // Verify that the signature was created by the signer and
        // return false if not.
        if(ECDSA.recover(_hash_, signature_) != _signer) {
            return false;
        }

        // Everything passed!
        return true;
    }

    /**
     * -------------------------------------------------------------------------
     * Admin functions.
     * -------------------------------------------------------------------------
     */

    /**
     * Update signer.
     * @param signer_ Address of new signer.
     * @notice This allows the owner to update the signer address.
     */
    function updateSigner(address signer_) external onlyOwner
    {
        _signer = signer_;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[45] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./extensions/IERC721Metadata.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/Strings.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits a {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

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
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/ERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../ERC721.sol";
import "./IERC721Enumerable.sol";

/**
 * @dev This implements an optional extension of {ERC721} defined in the EIP that adds
 * enumerability of all the token ids in the contract as well as all token ids owned by each
 * account.
 */
abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    // Mapping from owner to list of owned token IDs
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC721.sol)

pragma solidity ^0.8.0;

import "../token/ERC721/IERC721.sol";

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./abstracts/BaseContract.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
// Interfaces.
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC721.sol";

/**
 * @title FurMarket
 * @notice This is the NFT marketplace contract.
 */

/// @custom:security-contact [email protected]
contract FurMarket is BaseContract, ERC721Holder
{
    /**
     * Contract initializer.
     * @dev This intializes all the parent contracts.
     */
    function initialize() initializer public
    {
        __BaseContract_init();
    }

    /**
     * External contracts.
     */
    IERC20 private _paymentToken;

    /**
     * Listings.
     */
    uint256 private _listingIdTracker;
    struct Listing {
        uint256 start;
        address token;
        uint256 id;
        uint256 price;
        uint256 offer;
        address offerAddress;
        address owner;
    }
    mapping(uint256 => Listing) _listings;

    /**
     * Events.
     */
    event ListingCreated(Listing);
    event ListingCancelled(Listing);
    event NftPurchased(Listing);
    event OfferPlaced(Listing);
    event OfferRescinded(Listing);
    event OfferAccepted(Listing);
    event OfferRejected(Listing);

    /**
     * Setup.
     */
    function setup() external
    {
        _paymentToken = IERC20(addressBook.get("payment"));
    }

    /**
     * List NFT.
     * @param tokenAddress_ The address of the NFT contract.
     * @param tokenId_ The ID of the NFT.
     * @param price_ The price of the NFT.
     */
    function listNft(address tokenAddress_, uint256 tokenId_, uint256 price_) external whenNotPaused
    {
        IERC721 _token_ = IERC721(tokenAddress_);
        require(_token_.supportsInterface(type(IERC721).interfaceId), "Token must be ERC721");
        _transferERC721(tokenAddress_, tokenId_, msg.sender, address(this));
        _listingIdTracker++;
        _listings[_listingIdTracker].start = block.timestamp;
        _listings[_listingIdTracker].token = tokenAddress_;
        _listings[_listingIdTracker].id = tokenId_;
        _listings[_listingIdTracker].price = price_;
        _listings[_listingIdTracker].owner = msg.sender;
        emit ListingCreated(_listings[_listingIdTracker]);
    }

    /**
     * Cancel listing.
     * @param listingId_ The ID of the listing.
     */
    function cancelListing(uint256 listingId_) external whenNotPaused
    {
        require(_listings[listingId_].start > 0, "Listing does not exist");
        require(_listings[listingId_].owner == msg.sender, "Only the listing owner can cancel the listing");
        _transferERC721(_listings[listingId_].token, _listings[listingId_].id, address(this), msg.sender);
        emit ListingCancelled(_listings[listingId_]);
        delete _listings[listingId_];
    }

    /**
     * Buy NFT.
     * @param listingId_ The ID of the listing.
     */
    function buyNft(uint256 listingId_) external whenNotPaused
    {
        require(_listings[listingId_].start > 0, "Listing does not exist");
        address _owner_ = _listings[listingId_].owner;
        uint256 _price_ = _listings[listingId_].price;
        address _token_ = _listings[listingId_].token;
        uint256 _tokenId_ = _listings[listingId_].id;
        emit NftPurchased(_listings[listingId_]);
        delete _listings[listingId_];
        require(_paymentToken.transferFrom(msg.sender, _owner_, _price_), "Payment failed");
        _transferERC721(_token_, _tokenId_, address(this), msg.sender);
    }

    /**
     * Make offer.
     * @param listingId_ The ID of the listing.
     * @param offer_ The offer amount.
     */
    function makeOffer(uint256 listingId_, uint256 offer_) external whenNotPaused
    {
        require(_listings[listingId_].start > 0, "Listing does not exist");
        require(offer_ > _listings[listingId_].offer, "Offer must be higher than the highest offer");
        require(_paymentToken.transferFrom(msg.sender, address(this), offer_), "Payment failed");
        _listings[listingId_].offer = offer_;
        _listings[listingId_].offerAddress = msg.sender;
        emit OfferPlaced(_listings[listingId_]);
    }

    /**
     * Rescind offer.
     * @param listingId_ The ID of the listing.
     */
    function rescindOffer(uint256 listingId_) external whenNotPaused
    {
        require(_listings[listingId_].start > 0, "Listing does not exist");
        require(_listings[listingId_].offerAddress == msg.sender, "Only the offer owner can rescind the offer");
        emit OfferRescinded(_listings[listingId_]);
        _deleteOffer(listingId_);
    }

    /**
     * Accept offer.
     * @param listingId_ The ID of the listing.
     */
    function acceptOffer(uint256 listingId_) external whenNotPaused
    {
        require(_listings[listingId_].start > 0, "Listing does not exist");
        require(_listings[listingId_].owner == msg.sender, "Only the listing owner can accept the offer");
        require(_paymentToken.transfer(_listings[listingId_].owner, _listings[listingId_].offer), "Payment failed");
        _transferERC721(_listings[listingId_].token, _listings[listingId_].id, address(this), _listings[listingId_].offerAddress);
        emit OfferAccepted(_listings[listingId_]);
        emit NftPurchased(_listings[listingId_]);
        delete _listings[listingId_];
    }

    /**
     * Reject offer.
     * @param listingId_ The ID of the listing.
     */
    function rejectOffer(uint256 listingId_) external whenNotPaused
    {
        require(_listings[listingId_].start > 0, "Listing does not exist");
        require(_listings[listingId_].owner == msg.sender, "Only the listing owner can reject the offer");
        require(_listings[listingId_].offerAddress != address(0), "No offer to reject");
        require(_listings[listingId_].offer > 0, "No offer to reject");
        emit OfferRejected(_listings[listingId_]);
        _deleteOffer(listingId_);
    }

    /**
     * Get listings.
     * @param cursor_ The cursor.
     * @param limit_ The limit.
     */
    function getListings(uint256 cursor_, uint256 limit_) external view returns (uint256 cursor, Listing[] memory listings)
    {
        Listing[] memory _listings_ = new Listing[](limit_);
        uint256 j;
        for(uint256 i = _listingIdTracker; i >= 0; i--) {
            if(_listings[i].start > 0) {
                _listings_[j] = _listings[i];
                j++;
                if(j == cursor_ + limit_) {
                    break;
                }
            }
        }
        return (j, _listings_);
    }

    /**
     * Transfer ERC721.
     * @param tokenAddress_ The address of the token.
     * @param tokenId_ The ID of the token.
     * @param from_ The address of the sender.
     * @param to_ The address of the receiver.
     */
    function _transferERC721(address tokenAddress_, uint256 tokenId_, address from_, address to_) internal
    {
        IERC721 _token_ = IERC721(tokenAddress_);
        _token_.safeTransferFrom(from_, to_, tokenId_);
        require(_token_.ownerOf(tokenId_) == to_, "Token transfer failed");
    }

    /**
     * Delete offer.
     * @param listingId_ The ID of the listing.
     */
    function _deleteOffer(uint256 listingId_) internal
    {
        address _offerAddress_ = _listings[listingId_].offerAddress;
        uint256 _offer_ = _listings[listingId_].offer;
        _listings[listingId_].offerAddress = address(0);
        _listings[listingId_].offer = 0;
        require(_paymentToken.transfer(_offerAddress_, _offer_), "Payment failed");
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/utils/ERC721Holder.sol)

pragma solidity ^0.8.0;

import "../IERC721Receiver.sol";

/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts all token transfers.
 * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or {IERC721-setApprovalForAll}.
 */
contract ERC721Holder is IERC721Receiver {
    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Imports
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
// Interfaces
import "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";
import "./interfaces/IVerifier.sol";
import "./interfaces/IToken.sol";

contract Presale is Ownable, ERC721Enumerable
{
    /**
     * Verifier contract.
     */
    IVerifier private _verifier;

    /**
     * Payment contract.
     */
    IERC20Metadata public paymentToken;

    /**
     * Fur token contract.
     */
    IToken public furToken;

    /**
     * Treasury address.
     */
    address public treasury;

    /**
     * Token id tracker.
     */
    uint256 private _tokenIdTracker;

    /**
     * Token URI (same for all tokens).
     */
    string private _tokenUri = 'ipfs://Qme28bzD3z119fAqBPXgpDb9Z79bqEheQjkejWsefcd4Gj/1';

    /**
     * Token values.
     */
    mapping(uint256 => uint256) public tokenValue;

    /**
     * Salt buys.
     * @dev Map salt to number of purchases by address.
     */
    mapping(address => mapping(string => uint256)) private _buys;

    /**
     * Salt totals.
     * @dev Map salt to total number of purchases.
     */
    mapping(string => uint256) private _totals;

    /**
     * Claimed tokens.
     */
    mapping(uint256 => bool) public claimed;

    /**
     * Events.
     */
    event NftPurchased(address buyer_, uint256 tokenId_, uint256 price_, uint256 value_);
    event NftClaimed(address claimer_, uint256 tokenId_, uint256 value_);

    /**
     * Constructor.
     */
    constructor() ERC721("Furio Presale NFT", "$FURPRESALE") {}

    /**
     * -------------------------------------------------------------------------
     * USER FUNCTIONS.
     * -------------------------------------------------------------------------
     */

    /**
     * Buy an NFT.
     * @param signature_ Verification signature.
     * @param quantity_ The quantity to buy.
     * @param max_ The max available to buy.
     * @param price_ The price per NFT.
     * @param value_ The value per NFT.
     * @param total_ The total NFTs available.
     * @param expiration_ The expiration date of the verification signature.
     * @return bool True if successful.
     * @dev This buy method uses a signature comprised of the max, price
     * and value values which is then verified by the verifier contract. This
     * allows a much slimmer NFT contract and we can control presale elements
     * server side.
     */
    function buy(
        bytes memory signature_,
        uint256 quantity_,
        uint256 max_,
        uint256 price_,
        uint256 value_,
        uint256 total_,
        uint256 expiration_
    ) external returns (bool)
    {
        // Make sure the verifier contract is set.
        require(address(_verifier) != address(0), "Verifier not set");
        // Make sure the payment token is set.
        require(address(paymentToken) != address(0), "Payment token not set");
        // Make sure the treasury address is set.
        require(treasury != address(0), "Treasury not set");
        // Make sure the signature isn't expired.
        require(expiration_ >= block.timestamp, "Signature expired");
        // Make sure quantity is less than max.
        require(quantity_ <= max_, "Quantity is too high");
        require(sold(max_, price_, value_, total_) + quantity_ <= total_, "Quantity is too high");
        require(quantity_ <= available(msg.sender, max_, price_, value_, total_), "Quantity is too high");
        // Re-create the signature salt using max, price, & value.
        string memory _salt_ = _salt(max_, price_, value_, total_);
        // Verify the signature is valid.
        require(_verifier.verify(signature_, msg.sender, _salt_, expiration_), "Invalid signature");
        // Get payment token decimals.
        uint256 _decimals_ = paymentToken.decimals();
        // Get a payment from the user.
        require(paymentToken.transferFrom(msg.sender, treasury, (price_ * (10 ** _decimals_)) * quantity_), "Payment failed");
        // Loop through quantity, minting tokens.
        for(uint256 i = 1; i <= quantity_; i ++) {
            // Increment token id.
            _tokenIdTracker ++;
            // Add the value to the tokenValue mapping.
            tokenValue[_tokenIdTracker] = value_;
            // Increment the signature quantity.
            _buys[msg.sender][_salt_] ++;
            _totals[_salt_] ++;
            // Finally, mint the token.
            _mint(msg.sender, _tokenIdTracker);
            emit NftPurchased(msg.sender, _tokenIdTracker, price_, value_);
        }
        // Success!
        return true;
    }

    /**
     * Claim!
     * @dev Burn all of your NFTs and get $FUR tokens! FIRE!
     */
    function claim() external
    {
        // Make sure Fur token contract exists and is not paused
        require(address(furToken) != address(0), "Fur token not set");
        require(!furToken.paused(), "Fur token is paused");
        uint256 _value_ = 0;
        for(uint256 i = 0; i < balanceOf(msg.sender); i ++) {
            uint256 _tokenId_ = tokenOfOwnerByIndex(msg.sender, i);
            if(claimed[_tokenId_]) {
                continue;
            }
            _value_ += tokenValue[_tokenId_];
            claimed[_tokenId_] = true;
            emit NftClaimed(msg.sender, _tokenId_, tokenValue[_tokenId_]);
        }
        require(_value_ > 0, "No claimable tokens");
        uint256 _decimals_ = furToken.decimals();
        furToken.mint(msg.sender, _value_ * (10 ** _decimals_));
    }

    /**
     * Value.
     * @param owner_ Owner of presale tokens.
     * @dev Returns the total value of all NFTs owned by an address.
     */
    function value(address owner_) external view returns (uint256)
    {
        uint256 _value_ = 0;
        for(uint256 i = 0; i < balanceOf(owner_); i ++) {
            uint256 _tokenId_ = tokenOfOwnerByIndex(owner_, i);
            if(claimed[_tokenId_]) {
                continue;
            }
            _value_ += tokenValue[_tokenId_];
        }
        return _value_;
    }

    /**
     * Get available to purchase.
     * @param buyer_ Address of buyer.
     * @param max_ Max NFTs available.
     * @param price_ Price of each NFT.
     * @param value_ Value of each NFT.
     * @param total_ Total NFTs available.
     * @return uint256 Number of NFTs available.
     * @dev Calculates the remaining number of NFTs available for a user.
     */
    function available(address buyer_, uint256 max_, uint256 price_, uint256 value_, uint256 total_) public view returns (uint256)
    {
        string memory _salt_ = _salt(max_, price_, value_, total_);
        uint256 _remaining_ = total_ - _totals[_salt_];
        uint256 _available_ = max_ - _buys[buyer_][_salt_];
        if(_available_ <= _remaining_) return _available_;
        return _remaining_;
    }

    /**
     * Sold.
     * @param max_ Max per person.
     * @param price_ Price per NFT.
     * @param value_ Value per NFT.
     * @param total_ Total NFTs available.
     * @return uint256 Number of NFTs sold with this salt.
     */
    function sold(uint256 max_, uint256 price_, uint256 value_, uint256 total_) public view returns (uint256)
    {
        return _totals[_salt(max_, price_, value_, total_)];
    }

    /**
     * Token URI.
     * @param tokenId_ Id of the token.
     * @dev This just returns the same URI for all tokens in this contract.
     */
    function tokenURI(uint256 tokenId_) public view virtual override returns (string memory)
    {
        require(_exists(tokenId_), "Token does not exist");
        return _tokenUri;
    }

    /**
     * -------------------------------------------------------------------------
     * INTERNAL FUNCTIONS.
     * -------------------------------------------------------------------------
     */

    /**
     * Make salt.
     * @param max_ Max NFTs per person.
     * @param price_ Price per NFT.
     * @param value_ Value per NFT.
     * @param total_ Total NFTs available.
     * @return string Salt.
     */
    function _salt(uint256 max_, uint256 price_, uint256 value_, uint256 total_) internal pure returns (string memory)
    {
        return string(abi.encodePacked(
            'max', Strings.toString(max_),
            'price', Strings.toString(price_),
            'value', Strings.toString(value_),
            'total', Strings.toString(total_)
        ));
    }

    /**
     * -------------------------------------------------------------------------
     * ADMIN FUNCTIONS.
     * -------------------------------------------------------------------------
     */

    /**
     * Set verifier contract.
     * @param verifier_ Address of verifier contract.
     * @dev This contract verifies signatures to validate users.
     */
    function setVerifier(address verifier_) external onlyOwner
    {
        _verifier = IVerifier(verifier_);
    }

    /**
     * Set payment token.
     * @param paymentToken_ Address of the payment token.
     * @dev This will be the USDC address used to buy NFTs.
     */
    function setPaymentToken(address paymentToken_) external onlyOwner
    {
        paymentToken = IERC20Metadata(paymentToken_);
    }

    /**
     * Set treasury.
     * @param treasury_ Address of the treasury contract.
     * @dev This is the multisig wallet where we will store funds until
     * it's time to create the liquidity pool.
     */
    function setTreasury(address treasury_) external onlyOwner
    {
        treasury = treasury_;
    }

    /**
     * Set fur token.
     * @param furToken_ Address of the $FUR token contract.
     * @dev This sets the address for the $FUR token.
     */
    function setFurToken(address furToken_) external onlyOwner
    {
        furToken = IToken(furToken_);
    }

    /**
     * Set token URI.
     * @param uri_ Address of the token metadata.
     * @dev This updates the token URI of the contract. This will probably
     * never get updated unless we screwed up somewhere.
     */
    function setTokenUri(string memory uri_) external onlyOwner
    {
        _tokenUri = uri_;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/extensions/IERC20Metadata.sol";

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IVerifier
{
    function verify(bytes memory signature_, address sender_, string memory salt_, uint256 expiration_) external view returns (bool);
    function updateSigner(address signer_) external;
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
pragma solidity ^0.8.4;

import "./abstracts/BaseContract.sol";
// Interfaces.
import "./interfaces/IClaim.sol";
import "./interfaces/IDownline.sol";
import "./interfaces/IFurMax.sol";
import "./interfaces/IToken.sol";


/**
 * @title Vault
 * @author Steve Harmeyer
 * @notice This is the Furio vault contract.
 * @dev All percentages are * 100 (e.g. .5% = 50, .25% = 25)
 */

/// @custom:security-contact [email protected]
contract Vault is BaseContract
{
    /**
     * Contract initializer.
     * @dev This intializes all the parent contracts.
     */
    function initialize() initializer public
    {
        __BaseContract_init();
        _properties.period = 86400; // PRODUCTION period is 24 hours.
        _properties.lookbackPeriods = 28; // 28 periods.
        _properties.penaltyLookbackPeriods = 7; // 7 periods.
        _properties.maxPayout = 100000 * (10 ** 18);
        _properties.maxReturn = 36000;
        _properties.neutralClaims = 13;
        _properties.negativeClaims = 15;
        _properties.penaltyClaims = 7;
        _properties.depositTax = 1000;
        _properties.depositReferralBonus = 1000;
        _properties.compoundTax = 500;
        _properties.compoundReferralBonus = 500;
        _properties.airdropTax = 1000;
        _properties.claimTax = 1000;
        _properties.maxReferralDepth = 15;
        _properties.teamWalletRequirement = 5;
        _properties.teamWalletChildBonus = 2500;
        _properties.devWalletReceivesBonuses = true;
        // Rewards percentages based on 28 day claims.
        _rates[0] = 250;
        _rates[1] = 225;
        _rates[2] = 225;
        _rates[3] = 225;
        _rates[4] = 225;
        _rates[5] = 225;
        _rates[6] = 225;
        _rates[7] = 225;
        _rates[8] = 225;
        _rates[9] = 200;
        _rates[10] = 200;
        _rates[11] = 200;
        _rates[12] = 200;
        _rates[13] = 200;
        _rates[14] = 200;
        _rates[15] = 100;
        _rates[16] = 100;
        _rates[17] = 100;
        _rates[18] = 100;
        _rates[19] = 100;
        _rates[20] = 100;
        _rates[21] = 50;
        _rates[22] = 50;
        _rates[23] = 50;
        _rates[24] = 50;
        _rates[25] = 50;
        _rates[26] = 50;
        _rates[27] = 50;
        _rates[28] = 50;
    }

    /**
     * Participant struct.
     */
    struct Participant {
        uint256 startTime;
        uint256 balance;
        address referrer;
        uint256 deposited;
        uint256 compounded;
        uint256 claimed;
        uint256 taxed;
        uint256 awarded;
        bool negative;
        bool penalized;
        bool maxed;
        bool banned;
        bool teamWallet;
        bool complete;
        uint256 maxedRate;
        uint256 availableRewards;
        uint256 lastRewardUpdate;
        uint256 directReferrals;
        uint256 airdropSent;
        uint256 airdropReceived;
    }
    mapping(address => Participant) private _participants;
    mapping(address => address[]) private _referrals;
    mapping(address => uint256[]) private _claims;

    /**
     * Stats.
     */
    struct Stats {
        uint256 totalParticipants;
        uint256 totalDeposits;
        uint256 totalDeposited;
        uint256 totalCompounds;
        uint256 totalCompounded;
        uint256 totalClaims;
        uint256 totalClaimed;
        uint256 totalTaxed;
        uint256 totalTaxes;
        uint256 totalAirdropped;
        uint256 totalAirdrops;
        uint256 totalBonused;
        uint256 totalBonuses;
    }
    Stats private _stats;

    /**
     * Properties.
     */
    struct Properties {
        uint256 period;
        uint256 lookbackPeriods;
        uint256 penaltyLookbackPeriods;
        uint256 maxPayout;
        uint256 maxReturn;
        uint256 neutralClaims;
        uint256 negativeClaims;
        uint256 penaltyClaims;
        uint256 depositTax;
        uint256 depositReferralBonus;
        uint256 compoundTax;
        uint256 compoundReferralBonus;
        uint256 airdropTax;
        uint256 claimTax;
        uint256 maxReferralDepth;
        uint256 teamWalletRequirement;
        uint256 teamWalletChildBonus;
        bool devWalletReceivesBonuses;
    }
    Properties private _properties;
    mapping(uint256 => uint256) private _rates; // Mapping of claims to rates.
    mapping(address => address) private _lastRewarded; // Mapping of last addresses rewarded in an upline.

    /**
     * Events.
     */
    event Deposit(address participant_, uint256 amount_);
    event Compound(address participant_, uint256 amount_);
    event Claim(address participant_, uint256 amount_);
    event Tax(address participant_, uint256 amount_);
    event Bonus(address particpant_, uint256 amount_);
    event Maxed(address participant_);
    event Complete(address participant_);
    event TokensSent(address recipient_, uint256 amount_);
    event AirdropSent(address from_, address to_, uint256 amount_);

    /**
     * -------------------------------------------------------------------------
     * PARTICIPANTS.
     * -------------------------------------------------------------------------
     */

    /**
     * Get participant.
     * @param participant_ Address of participant.
     * @return Participant The participant struct.
     */
    function getParticipant(address participant_) public view returns (Participant memory)
    {
        return _participants[participant_];
    }

    /**
     * -------------------------------------------------------------------------
     * STATS.
     * -------------------------------------------------------------------------
     */

    /**
     * Get stats.
     * @return Stats The contract stats.
     */
    function getStats() external view returns (Stats memory)
    {
        return _stats;
    }

    /**
     * -------------------------------------------------------------------------
     * PROPERTIES.
     * -------------------------------------------------------------------------
     */

    /**
     * Get properties.
     * @return Properties The contract properties.
     */
    function getProperties() external view returns (Properties memory)
    {
        return _properties;
    }

    /**
     * -------------------------------------------------------------------------
     * DEPOSITS.
     * -------------------------------------------------------------------------
     */

    /**
     * Deposit.
     * @param quantity_ Token quantity.
     * @return bool True if successful.
     * @dev Uses function overloading to allow with or without a referrer.
     */
    function deposit(uint256 quantity_) external returns (bool)
    {
        return depositFor(msg.sender, quantity_);
    }

    /**
     * Deposit with referrer.
     * @param quantity_ Token quantity.
     * @param referrer_ Referrer address.
     * @return bool True if successful.
     * @dev Uses function overloading to allow with or without a referrer.
     */
    function deposit(uint256 quantity_, address referrer_) external returns (bool)
    {
        return depositFor(msg.sender, quantity_, referrer_);
    }

    /**
     * Deposit for.
     * @param participant_ Participant address.
     * @param quantity_ Token quantity.
     * @return bool True if successful.
     * @dev Uses function overloading to allow with or without a referrer.
     */
    function depositFor(address participant_, uint256 quantity_) public returns (bool)
    {
        _addReferrer(participant_, address(0));
        if(msg.sender != addressBook.get("claim") && msg.sender != addressBook.get("swap")) {
            // The claim contract can deposit on behalf of a user straight from a presale NFT.
            require(_token().transferFrom(participant_, address(this), quantity_), "Unable to transfer tokens");
        }
        return _deposit(participant_, quantity_, _properties.depositTax);
    }

    /**
     * Deposit for with referrer.
     * @param participant_ Participant address.
     * @param quantity_ Token quantity.
     * @param referrer_ Referrer address.
     * @return bool True if successful.
     * @dev Uses function overloading to allow with or without a referrer.
     */
    function depositFor(address participant_, uint256 quantity_, address referrer_) public returns (bool)
    {
        _addReferrer(participant_, referrer_);
        if(msg.sender != addressBook.get("claim") && msg.sender != addressBook.get("swap")) {
            // The claim contract can deposit on behalf of a user straight from a presale NFT.
            require(_token().transferFrom(participant_, address(this), quantity_), "Unable to transfer tokens");
        }
        return _deposit(participant_, quantity_, _properties.depositTax);
    }

    /**
     * Internal deposit.
     * @param participant_ Participant address.
     * @param amount_ Deposit amount.
     * @param taxRate_ Tax rate.
     * @return bool True if successful.
     */
    function _deposit(address participant_, uint256 amount_, uint256 taxRate_) internal returns (bool)
    {
        require(_participants[participant_].deposited + _participants[participant_].airdropReceived + amount_ <= 5000e18, "Maximum deposit reached");
        // Get some data that will be used a bunch.
        uint256 _maxThreshold_ = _maxThreshold();
        // Checks.
        require(amount_ > 0, "Invalid deposit amount");
        require(!_participants[participant_].banned, "Participant is banned");
        require(_participants[participant_].balance < _maxThreshold_ , "Participant has reached the max payout threshold");
        // Check if participant is new.
        _addParticipant(participant_);
        // Calculate tax amount.
        uint256 _taxAmount_ = amount_ * taxRate_ / 10000;
        if(_taxAmount_ > 0) {
            amount_ -= _taxAmount_;
            // Update contract tax stats.
            _stats.totalTaxed ++;
            _stats.totalTaxes += _taxAmount_;
            // Update participant tax stats
            _participants[participant_].taxed += _taxAmount_;
            // Emit Tax event.
            emit Tax(participant_, _taxAmount_);
        }
        // Calculate refund amount if this deposit pushes them over the max threshold.
        uint256 _refundAmount_ = 0;
        if(_participants[participant_].balance + amount_ > _maxThreshold_) {
            _refundAmount_ = _participants[participant_].balance + amount_ - _maxThreshold_;
            amount_ -= _refundAmount_;
        }
        // Update contract deposit stats.
        _stats.totalDeposits ++;
        _stats.totalDeposited += amount_;
        // Update participant deposit stats.
        _participants[participant_].deposited += amount_;
        // Emit Deposit event.
        emit Deposit(participant_, amount_);
        // Credit the particpant.
        _participants[participant_].balance += amount_;
        // Check if participant is maxed.
        if(_participants[participant_].balance >= _maxThreshold_) {
            _participants[participant_].maxedRate = _rewardPercent(participant_);
            _participants[participant_].maxed = true;
            // Emit Maxed event
            emit Maxed(participant_);
        }
        // Calculate the referral bonus.
        uint256 _referralBonus_ = amount_ * _properties.depositReferralBonus / 10000;
        _payUpline(participant_, _referralBonus_);
        _sendTokens(participant_, _refundAmount_);
        return true;
    }

    /**
     * -------------------------------------------------------------------------
     * COMPOUNDS.
     * -------------------------------------------------------------------------
     */

    /**
     * Compound.
     * @return bool True if successful.
     */
    function compound() external returns (bool)
    {
        return _compound(msg.sender, _properties.compoundTax);
    }

    /**
     * Auto compound.
     * @param participant_ Address of participant to compound.
     * @return bool True if successful.
     */
    function autoCompound(address participant_) external returns (bool)
    {
        require(msg.sender == addressBook.get("autocompound"));
        return _compound(participant_, _properties.compoundTax);
    }

    /**
     * Compound.
     * @param participant_ Address of participant.
     * @param taxRate_ Tax rate.
     * @return bool True if successful.
     */
    function _compound(address participant_, uint256 taxRate_) internal returns (bool)
    {
        _addReferrer(participant_, address(0));
        // Get some data that will be used a bunch.
        uint256 _timestamp_ = block.timestamp;
        uint256 _maxThreshold_ = _maxThreshold();
        uint256 _amount_ = _availableRewards(participant_);
        // Checks.
        require(_amount_ > 0, "Invalid compound amount");
        require(!_participants[participant_].banned, "Participant is banned");
        require(_participants[participant_].balance < _maxThreshold_ , "Participant has reached the max payout threshold");
        // Check if participant is new.
        _addParticipant(participant_);
        // Update participant available rewards
        _participants[participant_].availableRewards = 0;
        _participants[participant_].lastRewardUpdate = _timestamp_;
        // Calculate tax amount.
        uint256 _taxAmount_ = _amount_ * taxRate_ / 10000;
        if(_taxAmount_ > 0) {
            _amount_ -= _taxAmount_;
            // Update contract tax stats.
            _stats.totalTaxed ++;
            _stats.totalTaxes += _taxAmount_;
            // Update participant tax stats
            _participants[participant_].taxed += _taxAmount_;
            // Emit Tax event.
            emit Tax(participant_, _taxAmount_);
        }
        // Calculate if this compound pushes them over the max threshold.
        if(_participants[participant_].balance + _amount_ > _maxThreshold_) {
            uint256 _over_ = _participants[participant_].balance + _amount_ - _maxThreshold_;
            _amount_ -= _over_;
            _participants[participant_].availableRewards = _over_;
            _participants[participant_].lastRewardUpdate = _timestamp_;
        }
        // Update contract compound stats.
        _stats.totalCompounds ++;
        _stats.totalCompounded += _amount_;
        // Update participant compound stats.
        _participants[participant_].compounded += _amount_;
        // Emit Compound event.
        emit Compound(participant_, _amount_);
        // Credit the particpant.
        _participants[participant_].balance += _amount_;
        // Check if participant is maxed.
        if(_participants[participant_].balance >= _maxThreshold_) {
            _participants[participant_].maxedRate = _rewardPercent(participant_);
            _participants[participant_].maxed = true;
            // Emit Maxed event
            emit Maxed(participant_);
        }
        // Calculate the referral bonus.
        uint256 _referralBonus_ = _amount_ * _properties.compoundReferralBonus / 10000;
        _payUpline(participant_, _referralBonus_);
        return true;
    }

    /**
     * -------------------------------------------------------------------------
     * CLAIMS.
     * -------------------------------------------------------------------------
     */

    /**
     * Claim.
     * @return bool True if successful.
     */
    function claim() external returns (bool)
    {
        require(!_participants[msg.sender].banned, "Participant is banned");
        uint256 _amount_ = _claim(msg.sender, _properties.claimTax);
        // If participant is not maxed, send them tokens and return.
        if(!_participants[msg.sender].maxed) {
            _sendTokens(msg.sender, _amount_);
            return true;
        }
        // If participant is not part of FurMax, send them tokens and return.
        IFurMax _furMax_ = IFurMax(addressBook.get("furmax"));
        if(!_furMax_.isFurMax(msg.sender)) {
            _sendTokens(msg.sender, _amount_);
            return true;
        }
        // Participant is FurMax so send tokens over there.
        IToken _token_ = _token();
        uint256 _balance_ = _token_.balanceOf(address(this));
        if(_balance_ < _amount_) {
            _token_.mint(address(this), _amount_ - _balance_);
        }
        _token_.approve(address(_furMax_), _amount_);
        _furMax_.distribute(msg.sender, _amount_);
        return true;
    }

    /**
     * Claim.
     * @param participant_ Address of participant.
     * @param taxRate_ Tax rate.
     * @return uint256 Amount of tokens claimed.
     */
    function _claim(address participant_, uint256 taxRate_) internal returns (uint256)
    {
        // Get some data that will be used a bunch.
        uint256 _timestamp_ = block.timestamp;
        uint256 _amount_ = _availableRewards(participant_);
        uint256 _maxPayout_ = _maxPayout(participant_);
        _addReferrer(participant_, address(0));
        // Checks.
        require(_amount_ > 0, "Invalid claim amount");
        require(!_participants[participant_].banned, "Participant is banned");
        require(!_participants[participant_].complete, "Participant is complete");
        require(_participants[participant_].claimed < _maxPayout_, "Maximum payout has been reached");
        // Keep total under max payout.
        if(_participants[participant_].claimed + _amount_ > _maxPayout_) {
            _amount_ = _maxPayout_ - _participants[participant_].claimed;
        }
        // Check penalty claims
        if(_penaltyClaims(participant_) + 1 >= _properties.penaltyClaims) {
            // User is penalized
            _participants[participant_].penalized = true;
        }
        // Check effective claims
        if(_effectiveClaims(participant_, 1) >= _properties.negativeClaims) {
            // User is negative
            _participants[participant_].negative = true;
        }
        // Update the claims mapping.
        _claims[participant_].push(_timestamp_);
        // Update participant available rewards.
        _participants[participant_].availableRewards = 0;
        _participants[participant_].lastRewardUpdate = _timestamp_;
        // Update contract claim stats.
        _stats.totalClaims ++;
        _stats.totalClaimed += _amount_;
        // Update participant claim stats.
        _participants[participant_].claimed += _amount_;
        // Emit Claim event.
        emit Claim(participant_, _amount_);
        // Check if participant is finished.
        if(_participants[participant_].claimed >= _properties.maxPayout) {
            _participants[participant_].complete = true;
            emit Complete(participant_);
        }
        // Calculate tax amount.
        uint256 _taxAmount_ = _amount_ * taxRate_ / 10000;
        if(_taxAmount_ > 0) {
            _amount_ -= _taxAmount_;
            // Update contract tax stats.
            _stats.totalTaxed ++;
            _stats.totalTaxes += _taxAmount_;
            // Update participant tax stats
            _participants[participant_].taxed += _taxAmount_;
            // Emit Tax event.
            emit Tax(participant_, _taxAmount_);
        }
        // Calculate whale tax.
        uint256 _whaleTax_ = _amount_ * whaleTax(participant_) / 10000;
        if(_whaleTax_ > 0) {
            _amount_ -= _whaleTax_;
            // Update contract tax stats.
            _stats.totalTaxed ++;
            _stats.totalTaxes += _whaleTax_;
            // Update participant tax stats
            _participants[participant_].taxed += _whaleTax_;
            // Emit Tax event.
            emit Tax(participant_, _taxAmount_);
        }
        // Return amount of tokens claimed.
        return _amount_;
    }

    /**
     * 28 Day Claims.
     * @param participant_ Address of participant.
     * @return uint256 Amount of claims.
     */
    function twentyEightDayClaims(address participant_) external view returns (uint256)
    {
        return _effectiveClaims(participant_, 0);
    }

    /**
     * Effective claims.
     * @param participant_ Participant address.
     * @param additional_ Additional claims to add.
     * @return uint256 Effective claims.
     */
    function _effectiveClaims(address participant_, uint256 additional_) internal view returns (uint256)
    {
        if(_participants[participant_].penalized) {
            return _properties.lookbackPeriods; // Max amount of claims.
        }
        uint256 _penaltyClaims_ = _penaltyClaims(participant_) + additional_;
        if(_penaltyClaims_ >= _properties.penaltyClaims) {
            return _properties.lookbackPeriods; // Max amount of claims.
        }
        uint256 _claims_ = _periodClaims(participant_) + additional_;
        if(_participants[participant_].negative && _claims_ < _properties.negativeClaims) {
            _claims_ = _properties.negativeClaims; // Once you go negative, you never go back!
        }
        if(_claims_ > _properties.lookbackPeriods) {
            _claims_ = _properties.lookbackPeriods; // Limit claims to make rate calculation easier.
        }
        if(_participants[participant_].startTime >= block.timestamp - (_properties.period * _properties.lookbackPeriods) && _claims_ < 1) {
            _claims_ = 1; // Before the lookback periods are up, a user can only go up to neutral.
        }
        if(_participants[participant_].startTime == 0) {
            _claims_ = _properties.neutralClaims; // User hasn't started yet.
        }
        return _claims_;
    }

    /**
     * Claims.
     * @param participant_ Participant address.
     * @return uint256 Effective claims.
     */
    function _periodClaims(address participant_) internal view returns (uint256)
    {
        return _claimsSinceTimestamp(participant_, block.timestamp - (_properties.period * _properties.lookbackPeriods));
    }

    /**
     * Penalty claims.
     * @param participant_ Participant address.
     * @return uint256 Effective claims.
     */
    function _penaltyClaims(address participant_) internal view returns (uint256)
    {
        return _claimsSinceTimestamp(participant_, block.timestamp - (_properties.period * _properties.penaltyLookbackPeriods));
    }

    /**
     * Claims since timestamp.
     * @param participant_ Participant address.
     * @param timestamp_ Unix timestamp for start of period.
     * @return uint256 Number of claims during period.
     */
    function _claimsSinceTimestamp(address participant_, uint256 timestamp_) internal view returns (uint256)
    {
        uint256 _claims_ = 0;
        for(uint i = 0; i < _claims[participant_].length; i++) {
            if(_claims[participant_][i] >= timestamp_) {
                _claims_ ++;
            }
        }
        return _claims_;
    }

    /**
     * -------------------------------------------------------------------------
     * AIRDROPS.
     * -------------------------------------------------------------------------
     */

    /**
     * Send an airdrop.
     * @param to_ Airdrop recipient.
     * @param amount_ Amount to send.
     * @return bool True if successful.
     */
    function airdrop(address to_, uint256 amount_) external returns (bool)
    {
        require(!_participants[msg.sender].banned, "Sender is banned");
        IToken _token_ = _token();
        require(_token_.transferFrom(msg.sender, address(this), amount_), "Token transfer failed");
        return _airdrop(msg.sender, to_, amount_);
    }

    /**
     * Send an airdrop to your team.
     * @param amount_ Amount to send.
     * @param minBalance_ Minimum balance to qualify.
     * @param maxBalance_ Maximum balance to qualify.
     * @return bool True if successful.
     */
    function airdropTeam(uint256 amount_, uint256 minBalance_, uint256 maxBalance_) external returns (bool)
    {
        require(!_participants[msg.sender].banned, "Sender is banned");
        IToken _token_ = _token();
        require(_token_.transferFrom(msg.sender, address(this), amount_), "Token transfer failed");
        address[] memory _team_ = _referrals[msg.sender];
        uint256 _count_;
        // Loop through first to get number of qualified accounts.
        for(uint256 i = 0; i < _team_.length; i ++) {
            if(_team_[i] == msg.sender) {
                continue;
            }
            if( _participants[_team_[i]].balance >= minBalance_ &&
                _participants[_team_[i]].balance <= maxBalance_ &&
                !_participants[_team_[i]].maxed &&
                _participants[_team_[i]].deposited + _participants[_team_[i]].airdropReceived + amount_ <= 5000e18
            ) {
                _count_ ++;
            }
        }
        require(_count_ > 0, "No qualified accounts exist");
        uint256 _airdropAmount_ = amount_ / _count_;
        // Send an airdrop to each qualified account.
        for(uint256 i = 0; i < _team_.length; i ++) {
            if(_team_[i] == msg.sender) {
                continue;
            }
            if( _participants[_team_[i]].balance >= minBalance_ &&
                _participants[_team_[i]].balance <= maxBalance_ &&
                !_participants[_team_[i]].maxed &&
                _participants[_team_[i]].deposited + _participants[_team_[i]].airdropReceived + amount_ <= 5000e18
            ) {
                _airdrop(msg.sender, _team_[i], _airdropAmount_);
            }
        }
        return true;
    }

    /**
     * Send an airdrop.
     * @param from_ Airdrop sender.
     * @param to_ Airdrop recipient.
     * @param amount_ Amount to send.
     * @return bool True if successful.
     */
    function _airdrop(address from_, address to_, uint256 amount_) internal returns (bool)
    {
        require(!_participants[to_].banned, "Receiver is banned");
        // Check if participant is new.
        _addParticipant(to_);
        _addReferrer(to_, address(0));
        // Check that airdrop can happen.
        require(from_ != to_, "Cannot airdrop to self");
        require(!_participants[to_].maxed, "Recipient is maxed");
        // Update sender airdrop stats.
        _participants[from_].airdropSent += amount_;
        // Update contract airdrop stats.
        _stats.totalAirdropped += amount_;
        _stats.totalAirdrops ++;
        // Remove tax
        uint256 _taxAmount_ = amount_ * _properties.airdropTax / 10000;
        if(_taxAmount_ > 0) {
            amount_ -= _taxAmount_;
            // Update contract tax stats.
            _stats.totalTaxed ++;
            _stats.totalTaxes += _taxAmount_;
            // Update participant tax stats
            _participants[to_].taxed += _taxAmount_;
            // Emit Tax event.
            emit Tax(to_, _taxAmount_);
        }
        // Add amount to receiver.
        require(_participants[to_].balance + amount_ <= _maxThreshold(), "Recipient is maxed");
        require(_participants[to_].deposited + _participants[to_].airdropReceived + amount_ <= 5000e18, "Maximum deposits received");
        _participants[to_].airdropReceived += amount_;
        _participants[to_].balance += amount_;
        // Emit airdrop event.
        emit AirdropSent(from_, to_, amount_);
        return true;
    }

    /**
     * -------------------------------------------------------------------------
     * REFERRALS.
     * -------------------------------------------------------------------------
     */

    /**
     * Add referrer.
     * @param referred_ Address of the referred participant.
     * @param referrer_ Address of the referrer.
     */
    function _addReferrer(address referred_, address referrer_) internal
    {
        if(_participants[referred_].referrer != address(0) && _participants[referred_].referrer != addressBook.get("safe")) {
            // Only update referrer if none is set yet
            return;
        }
        if(referrer_ == address(0)) {
            // Use the safe address if referrer is zero.
            referrer_ = addressBook.get("safe");
        }
        if(referred_ == referrer_) {
            // Use the safe address if referrer is self.
            referrer_ = addressBook.get("safe");
        }
        _participants[referred_].referrer = referrer_;
        _referrals[referrer_].push(referred_);
        _participants[referrer_].directReferrals ++;
        // Check if the referrer is a team wallet.
        if(_referrals[referrer_].length >= _properties.teamWalletRequirement) {
            _participants[referrer_].teamWallet = true;
        }
        // Check if referrer is new.
        if(_participants[referrer_].referrer != address(0)) {
            return;
        }
        // Referrer is new so add them to the safe's referrals.
        _addReferrer(referrer_, addressBook.get("safe"));
    }

    /**
     * Pay upline.
     * @param participant_ Address of participant.
     * @param bonus_ Bonus amount.
     */
    function _payUpline(address participant_, uint256 bonus_) internal
    {
        if(bonus_ == 0) {
            return;
        }
        // Get some data that will be used later.
        address _safe_ = addressBook.get("safe");
        uint256 _maxThreshold_ = _maxThreshold();
        address _lastRewarded_ = _lastRewarded[participant_];
        IDownline _downline_ = _downline();
        // If nobody has been rewarded yet start with the participant.
        if(_lastRewarded_ == address(0)) {
            _lastRewarded_ = participant_;
        }
        // Set previous rewarded so we can pay out team bonuses if applicable.
        address _previousRewarded_ = address(0);
        // Set depth to 1.
        for(uint _depth_ = 1; _depth_ <= _properties.maxReferralDepth; _depth_ ++) {
            if(_lastRewarded_ == _safe_) {
                // We're at the top so let's start over.
                _lastRewarded_ = participant_;
            }
            // Move up the chain.
            _previousRewarded_ = _lastRewarded_;
            _lastRewarded_ = _participants[_lastRewarded_].referrer;
            // Check for downline NFTs
            if(_downline_.balanceOf(_lastRewarded_) < _depth_) {
                // Downline NFT balance is not high enough so skip to the next referrer.
                continue;
            }
            if(_participants[_lastRewarded_].balance + bonus_ > _maxThreshold_) {
                // Bonus is too high, so skip to the next referrer.
                continue;
            }
            if(_participants[_lastRewarded_].balance < _participants[_lastRewarded_].claimed) {
                // Participant has claimed more than deposited/compounded.
                continue;
            }
            if(_lastRewarded_ == participant_) {
                // Can't receive your own bonuses.
                continue;
            }
            // We found our winner!
            _lastRewarded[participant_] = _lastRewarded_;
            if(_participants[_lastRewarded_].teamWallet) {
                uint256 _childBonus_ = bonus_ * _properties.teamWalletChildBonus / 10000;
                bonus_ -= _childBonus_;
                if(_participants[_previousRewarded_].balance + _childBonus_ > _maxThreshold_) {
                    _childBonus_ = _maxThreshold_ - _participants[_previousRewarded_].balance;
                }
                _participants[_previousRewarded_].balance += _childBonus_;
                _participants[_previousRewarded_].awarded += _childBonus_;
            }
            if(_lastRewarded_ == _safe_) {
                _sendTokens(_lastRewarded_, bonus_);
            }
            else {
                _participants[_lastRewarded_].balance += bonus_;
                _participants[_lastRewarded_].awarded += bonus_;
            }
            // Update contract bonus stats.
            _stats.totalBonused += bonus_;
            _stats.totalBonuses ++;
            // Fire bonus event.
            emit Bonus(_lastRewarded_, bonus_);
            break;
        }
    }

    /**
     * Get referrals.
     * @param participant_ Participant address.
     * @return address[] Participant's referrals.
     */
    function getReferrals(address participant_) external view returns (address[] memory)
    {
        return _referrals[participant_];
    }

    /**
     * Admin update referrer.
     * @param participant_ Participant address.
     * @param referrer_ Referrer address.
     * @dev Owner can update someone's referrer.
     */
    function adminUpdateReferrer(address participant_, address referrer_) external onlyOwner
    {
        for(uint i = 0; i < _referrals[_participants[participant_].referrer].length; i ++) {
            if(_referrals[_participants[participant_].referrer][i] == participant_) {
                delete _referrals[_participants[participant_].referrer][i];
                _participants[_participants[participant_].referrer].directReferrals --;
                break;
            }
        }
        _participants[participant_].referrer = referrer_;
        _participants[referrer_].directReferrals ++;
        _referrals[referrer_].push(participant_);
    }

    /**
     * -------------------------------------------------------------------------
     * REWARDS.
     * -------------------------------------------------------------------------
     */

    /**
     * Available rewards.
     * @param participant_ Participant address.
     * @return uint256 Amount of rewards available.
     */
    function _availableRewards(address participant_) internal view returns (uint256)
    {
        uint256 _period_ = ((block.timestamp - _participants[participant_].lastRewardUpdate) * 10000) / _properties.period;
        if(_period_ > 10000) {
            // Only let rewards accumulate for 1 period.
            _period_ = 10000;
        }
        uint256 _available_ = ((_period_ * _rewardPercent(participant_) * _participants[participant_].balance) / 100000000);
        // Make sure participant doesn't go above max payout.
        uint256 _maxPayout_ = _maxPayout(participant_);
        if(_available_ + _participants[participant_].claimed > _maxPayout_) {
            _available_ = _maxPayout_ - _participants[participant_].claimed;
        }
        return _available_;
    }

    /**
     * Reward percent.
     * @param participant_ Participant address.
     * @return uint256 Reward percent.
     */
    function _rewardPercent(address participant_) internal view returns (uint256)
    {
        if(_participants[participant_].startTime == 0) {
            return _rates[_properties.neutralClaims];
        }
        //if(_participants[participant_].maxed) {
            //return _participants[participant_].maxedRate;
        //}
        if(_participants[participant_].penalized) {
            return _rates[_properties.lookbackPeriods];
        }
        return _rates[_effectiveClaims(participant_, 0)];
    }

    /**
     * -------------------------------------------------------------------------
     * GETTERS.
     * -------------------------------------------------------------------------
     */

    /**
     * Available rewards.
     * @param participant_ Address of participant.
     * @return uint256 Returns a participant's available rewards.
     */
    function availableRewards(address participant_) external view returns (uint256)
    {
        return _availableRewards(participant_);
    }

    /**
     * Max payout.
     * @param participant_ Address of participant.
     * @return uint256 Returns a participant's max payout.
     */
    function maxPayout(address participant_) external view returns (uint256)
    {
        return _maxPayout(participant_);
    }

    /**
     * Remaining payout.
     * @param participant_ Address of participant.
     * @return uint256 Returns a participant's remaining payout.
     */
    function remainingPayout(address participant_) external view returns (uint256)
    {
        return _maxPayout(participant_) - _participants[participant_].claimed;
    }

    /**
     * Participant status.
     * @param participant_ Address of participant.
     * @return uint256 Returns a participant's status (1 = negative, 2 = neutral, 3 = positive).
     */
    function participantStatus(address participant_) external view returns (uint256)
    {
        uint256 _status_ = 3;
        uint256 _effectiveClaims_ = _effectiveClaims(participant_, 0);
        if(_effectiveClaims_ >= _properties.neutralClaims) _status_ = 2;
        if(_effectiveClaims_ >= _properties.negativeClaims) _status_ = 1;
        if(_participants[participant_].startTime == 0) {
            _status_ = 2;
        }
        return _status_;
    }

    /**
     * Participant balance.
     * @param participant_ Address of participant.
     * @return uint256 Participant's balance.
     */
    function participantBalance(address participant_) external view returns (uint256)
    {
        return _participants[participant_].balance;
    }

    /**
     * Participant maxed.
     * @param participant_ Address of participant.
     * @return bool Whether the participant is maxed or not.
     */
    function participantMaxed(address participant_) external view returns (bool)
    {
        return _participants[participant_].maxed;
    }


    /**
     * Claim precheck.
     * @param participant_ Address of participant.
     * @return uint256 Reward rate after another claim.
     */
    function claimPrecheck(address participant_) external view returns (uint256)
    {
        //if(_participants[participant_].maxed) {
            //return _participants[participant_].maxedRate;
        //}
        return _rates[_effectiveClaims(participant_, 1)];
    }

    /**
     * Reward rate.
     * @param participant_ Address of participant.
     * @return uint256 Current reward rate.
     */
    function rewardRate(address participant_) external view returns (uint256)
    {
        return _rates[_effectiveClaims(participant_, 0)];
    }

    /**
     * Max threshold.
     * @return uint256 Maximum balance threshold.
     */
    function maxThreshold() external view returns (uint256)
    {
        return _maxThreshold();
    }

    /**
     * -------------------------------------------------------------------------
     * HELPER FUNCTIONS
     * -------------------------------------------------------------------------
     */

    /**
     * Get token contract.
     * @return IToken Token contract.
     */
    function _token() internal view returns (IToken)
    {
        return IToken(addressBook.get("token"));
    }

    /**
     * Get downline contract.
     * @return IDownline Downline contract.
     */
    function _downline() internal view returns (IDownline)
    {
        return IDownline(addressBook.get("downline"));
    }

    /**
     * Max threshold.
     * @return uint256 Number of tokens needed to be considered at max.
     */
    function _maxThreshold() internal view returns (uint256)
    {
        return _properties.maxPayout * 10000 / _properties.maxReturn;
    }

    /**
     * Max payout.
     * @param participant_ Address of participant.
     * @return uint256 Maximum payout based on balance of participant and max payout.
     */
    function _maxPayout(address participant_) internal view returns (uint256)
    {
        uint256 _maxPayout_ = _participants[participant_].balance * _properties.maxReturn / 1000;
        if(_maxPayout_ > _properties.maxPayout) {
            _maxPayout_ = _properties.maxPayout;
        }
        return _maxPayout_;
    }

    /**
     * Add participant.
     * @param participant_ Address of participant.
     */
    function _addParticipant(address participant_) internal
    {
        // Check if participant is new.
        if(_participants[participant_].startTime == 0) {
            _participants[participant_].startTime = block.timestamp;
            _participants[participant_].lastRewardUpdate = block.timestamp;
            _stats.totalParticipants ++;
        }
    }

    /**
     * Send tokens.
     * @param recipient_ Token recipient.
     * @param amount_ Tokens to send.
     */
    function _sendTokens(address recipient_, uint256 amount_) internal
    {
        if(amount_ == 0) {
            return;
        }
        IToken _token_ = _token();
        uint256 _balance_ = _token_.balanceOf(address(this));
        if(_balance_ < amount_) {
            _token_.mint(address(this), amount_ - _balance_);
        }
        emit TokensSent(recipient_, amount_);
        _token_.transfer(recipient_, amount_);
    }

    /**
     * Whale tax.
     * @param participant_ Participant address.
     * @return uint256 Whale tax amount.
     */
    function whaleTax(address participant_) public view returns (uint256)
    {
        uint256 _claimed_ = _participants[participant_].claimed + _participants[participant_].compounded;
        uint256 _tax_ = 0;
        if(_claimed_ > 10000 * (10 ** 18)) _tax_ = 500;
        if(_claimed_ > 20000 * (10 ** 18)) _tax_ = 1000;
        if(_claimed_ > 30000 * (10 ** 18)) _tax_ = 1500;
        if(_claimed_ > 40000 * (10 ** 18)) _tax_ = 2000;
        if(_claimed_ > 50000 * (10 ** 18)) _tax_ = 2500;
        if(_claimed_ > 60000 * (10 ** 18)) _tax_ = 3000;
        if(_claimed_ > 70000 * (10 ** 18)) _tax_ = 3500;
        if(_claimed_ > 80000 * (10 ** 18)) _tax_ = 4000;
        if(_claimed_ > 90000 * (10 ** 18)) _tax_ = 4500;
        if(_claimed_ > 100000 * (10 ** 18)) _tax_ = 5000;
        return _tax_;
    }

    /**
     * -------------------------------------------------------------------------
     * ADMIN FUNCTIONS
     * -------------------------------------------------------------------------
     */

    /**
     * Ban participant.
     * @param participant_ Address of participant.
     */
    function banParticipant(address participant_) external onlyOwner
    {
        _participants[participant_].banned = true;
    }

    /**
     * Unban participant.
     * @param participant_ Address of participant.
     */
    function unbanParticipant(address participant_) external onlyOwner
    {
        _participants[participant_].banned = false;
    }

    /**
     * Negative participant.
     * @param participant_ Address of participant.
     */
    function negativeParticipant(address participant_) external onlyOwner
    {
        _participants[participant_].negative = true;
    }

    /**
     * Un-negative participant.
     * @param participant_ Address of participant.
     */
    function unnegativeParticipant(address participant_) external onlyOwner
    {
        _participants[participant_].negative = false;
    }

    /**
     * Penalize participant.
     * @param participant_ Address of participant.
     */
    function penalizeParticipant(address participant_) external onlyOwner
    {
        _participants[participant_].penalized = true;
    }

    /**
     * Un-penalize participant.
     * @param participant_ Address of participant.
     */
    function unpenalizeParticipant(address participant_) external onlyOwner
    {
        _participants[participant_].penalized = false;
    }

    /**
     * Add to compounded.
     * @param participant_ Address of participant.
     * @param amount_ Amount to add.
     */
    function addToCompounded(address participant_, uint256 amount_) external onlyOwner
    {
        _participants[participant_].compounded += amount_;
    }

    /**
     * Add to claimed.
     * @param participant_ Address of participant.
     * @param amount_ Amount to add.
     */
    function addToClaimed(address participant_, uint256 amount_) external onlyOwner
    {
        _participants[participant_].claimed += amount_;
    }

    /**
     * Add to taxed.
     * @param participant_ Address of participant.
     * @param amount_ Amount to add.
     */
    function addToTaxed(address participant_, uint256 amount_) external onlyOwner
    {
        _participants[participant_].taxed += amount_;
    }

    /**
     * Set rate.
     * @param claims_ Number of claims.
     * @param rate_ New rate.
     */
    function setRate(uint256 claims_, uint256 rate_) external onlyOwner
    {
        _rates[claims_] = rate_;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[45] private __gap;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IClaim {
    function addressBook (  ) external view returns ( address );
    function claimNft ( uint256 quantity_, address address_, bool vault_ ) external returns ( bool );
    function getOwnerValue ( address owner_ ) external view returns ( uint256 );
    function getTokenValue ( uint256 tokenId_ ) external view returns ( uint256 );
    function initialize (  ) external;
    function owned ( address owner_ ) external view returns ( uint256[] memory );
    function owner (  ) external view returns ( address );
    function pause (  ) external;
    function paused (  ) external view returns ( bool );
    function proxiableUUID (  ) external view returns ( bytes32 );
    function renounceOwnership (  ) external;
    function setAddressBook ( address address_ ) external;
    function transferOwnership ( address newOwner ) external;
    function unpause (  ) external;
    function upgradeTo ( address newImplementation ) external;
    function upgradeToAndCall ( address newImplementation, bytes memory data ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IDownline {
    function approve (address to, uint256 tokenId) external;
    function available (address buyer_, uint256 max_, uint256 price_, uint256 value_, uint256 total_) external view returns (uint256);
    function balanceOf (address owner) external view returns (uint256);
    function buy (bytes memory signature_, uint256 quantity_, uint256 max_, uint256 price_, uint256 value_, uint256 total_, uint256 expiration_) external returns (bool);
    function claim () external;
    function claimed (uint256) external view returns (bool);
    function furToken () external view returns (address);
    function getApproved (uint256 tokenId) external view returns (address);
    function isApprovedForAll (address owner, address operator) external view returns (bool);
    function name () external view returns (string memory);
    function owner () external view returns (address);
    function ownerOf (uint256 tokenId) external view returns (address);
    function paymentToken () external view returns (address);
    function renounceOwnership () external;
    function safeTransferFrom (address from, address to, uint256 tokenId) external;
    function safeTransferFrom (address from, address to, uint256 tokenId, bytes memory _data) external;
    function setApprovalForAll (address operator, bool approved) external;
    function setFurToken (address furToken_) external;
    function setPaymentToken (address paymentToken_) external;
    function setTokenUri (string memory uri_) external;
    function setTreasury (address treasury_) external;
    function setVerifier (address verifier_) external;
    function sold (uint256 max_, uint256 price_, uint256 value_, uint256 total_) external view returns (uint256);
    function supportsInterface (bytes4 interfaceId) external view returns (bool);
    function symbol () external view returns (string memory);
    function tokenByIndex (uint256 index) external view returns (uint256);
    function tokenOfOwnerByIndex (address owner, uint256 index) external view returns (uint256);
    function tokenURI (uint256 tokenId_) external view returns (string memory);
    function tokenValue (uint256) external view returns (uint256);
    function totalSupply () external view returns (uint256);
    function transferFrom (address from, address to, uint256 tokenId) external;
    function transferOwnership (address newOwner) external;
    function treasury () external view returns (address);
    function value (address owner_) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IFurMax {
    function acceptedTerms ( address ) external view returns ( bool );
    function addressBook (  ) external view returns ( address );
    function distribute ( address participant_, uint256 amount_ ) external;
    function furBetPercent ( address ) external view returns ( uint256 );
    function furBotPercent ( address ) external view returns ( uint256 );
    function furMaxClaimed ( address ) external view returns ( uint256 );
    function furPoolPercent ( address ) external view returns ( uint256 );
    function initialize (  ) external;
    function isFurMax ( address ) external view returns ( bool );
    function join ( bool acceptTerms_, uint256 furBet_, uint256 furBot_, uint256 furPool_ ) external;
    function owner (  ) external view returns ( address );
    function pause (  ) external;
    function paused (  ) external view returns ( bool );
    function proxiableUUID (  ) external view returns ( bytes32 );
    function renounceOwnership (  ) external;
    function setAddressBook ( address address_ ) external;
    function setup (  ) external;
    function transferOwnership ( address newOwner ) external;
    function unpause (  ) external;
    function updateDistribution ( uint256 furBet_, uint256 furBot_, uint256 furPool_ ) external;
    function upgradeTo ( address newImplementation ) external;
    function upgradeToAndCall ( address newImplementation, bytes memory data ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./abstracts/BaseContract.sol";
import "./interfaces/IDownline.sol";

/**
 * @title Furio Referrals
 * @author Steve Harmeyer
 * @notice This contract keeps track of referrals and referral rewards.
 */

/// @custom:security-contact [email protected]
contract Referrals is BaseContract
{
    /**
     * Contract initializer.
     * @dev This intializes all the parent contracts.
     */
    function initialize() initializer public
    {
        __BaseContract_init();
        maxDepth = 15;
    }

    /**
     * Addresses.
     */
    address devWalletAddress;
    address downlineNftAddress;
    address vaultAddress;

    /**
     * Referrals.
     */
    uint256 public maxDepth;
    mapping(address => address) public referrer;
    mapping(address => uint256) public referralCount;
    mapping(address => address[]) public referrals;
    mapping(address => address) public lastRewarded;
    mapping(address => address) public lastRewardedBy;
    mapping(address => uint256) public rewardCount;

    /**
     * Update addresses.
     */
    function updateAddresses() public
    {
        if(devWalletAddress == address(0)) devWalletAddress = addressBook.get("safe");
        if(downlineNftAddress == address(0)) downlineNftAddress = addressBook.get("downline");
        if(vaultAddress == address(0)) vaultAddress = addressBook.get("vault");
    }

    /**
     * Add participant.
     * @param participant_ Participant address.
     * @param referrer_ Referrer address.
     */
    function addParticipant(address participant_, address referrer_) external onlyVault
    {
        _addParticipant(participant_, referrer_);
    }

    /**
     * Internal add participant.
     * @param participant_ Participant address.
     * @param referrer_ Referrer address.
     */
    function _addParticipant(address participant_, address referrer_) internal
    {
        require(devWalletAddress != address(0), "Dev wallet not yet set");
        require(participant_ != address(0), "Participant address is 0");
        require(referrer_ != address(0), "Referrer address is 0");
        require(participant_ != referrer_, "Participant cannot be referrer");
        referrer[participant_] = referrer_;
        referralCount[referrer_] ++;
        referrals[referrer_].push(participant_);
        lastRewarded[participant_] = participant_;
    }

    /**
     * Get next reward address.
     * @param participant_ Participant address.
     * @return address Next reward address.
     */
    function getNextRewardAddress(address participant_) external returns (address)
    {
        return _getNextRewardAddress(participant_, 1);
    }

    /**
     * Reward upline.
     * @param participant_ Participant address.
     * @return address Reward address.
     */
    function rewardUpline(address participant_) external onlyVault returns (address)
    {
        address _next_ = _getNextRewardAddress(participant_, 1);
        lastRewarded[participant_] = _next_;
        lastRewardedBy[_next_] = participant_;
        rewardCount[_next_] ++;
        return _next_;
    }

    /**
     * Internal get next reward address.
     * @param participant_ Participant address.
     * @param depth_ Referral depth.
     * @return address Next reward address.
     */
    function _getNextRewardAddress(address participant_, uint256 depth_) internal returns (address)
    {
        if(depth_ > maxDepth) return devWalletAddress;
        address _lastRewarded_ = lastRewarded[participant_];
        if(_lastRewarded_ == address(0) || _lastRewarded_ == devWalletAddress) _lastRewarded_ = participant_;
        address _next_ = referrer[_lastRewarded_];
        if(_next_ == address(0)) return devWalletAddress;
        IDownline _downline_ = IDownline(downlineNftAddress);
        if(_downline_.balanceOf(_next_) < depth_) return _getNextRewardAddress(_next_, depth_ + 1);
        return _next_;
    }

    /**
     * Update referrer.
     * @param referrer_ New referrer address.
     */
    function updateReferrer(address referrer_) external
    {
        require(referrer[msg.sender] == address(0), "You already have a referrer");
        _addParticipant(msg.sender, referrer_);
    }

    /**
     * Only vault.
     */
    modifier onlyVault
    {
        require(msg.sender == vaultAddress, "Only the vault can call this function");
        _;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./abstracts/BaseContract.sol";
// Interfaces.
import "./interfaces/IToken.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

/**
 * @title Furio Pool
 * @author Steve Harmeyer
 * @notice This contract creates the liquidity pool for $FUR/USDC
 */

/// @custom:security-contact [email protected]
contract Pool is BaseContract
{
    /**
     * Contract initializer.
     * @dev This intializes all the parent contracts.
     */
    function initialize() initializer public
    {
        __BaseContract_init();
        _startingPrice = 800; // 2.50 * 100
    }

    /**
     * Starting price.
     */
    uint256 private _startingPrice;

    /**
     * Create liquidity.
     * @dev Creates a liquidity pool with _payment and _token.
     */
    function createLiquidity() external onlyOwner
    {
        IERC20 _payment_ = IERC20(addressBook.get("payment"));
        IToken _token_ = IToken(addressBook.get("token"));
        IUniswapV2Router02 _router_ = IUniswapV2Router02(addressBook.get("router"));
        address _safe_ = addressBook.get("safe");
        require(address(_payment_) != address(0), "Payment token not set");
        require(address(_token_) != address(0), "Token not set");
        require(address(_router_) != address(0), "Router not set");
        require(_safe_ != address(0), "Dev wallet not set");
        uint256 _paymentBalance_ = _payment_.balanceOf(address(this));
        uint256 _amountToMint_ = _paymentBalance_ * 100 / _startingPrice;
        require(_amountToMint_ > 0, "Invalid amount");
        _token_.mint(address(this), _amountToMint_);
        _payment_.approve(address(_router_), _paymentBalance_);
        _token_.approve(address(_router_), _amountToMint_);
        _router_.addLiquidity(
            address(_payment_),
            address(_token_),
            _paymentBalance_,
            _amountToMint_,
            0,
            0,
            _safe_,
            block.timestamp + 3600
        );
    }

    function withdraw() external onlyOwner
    {
        IERC20 _payment_ = IERC20(addressBook.get("payment"));
        _payment_.transfer(msg.sender, _payment_.balanceOf(address(this)));
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[45] private __gap;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./interfaces/IToken.sol";
import "./abstracts/BaseContract.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";


/**
 * @title FUR-USDC LP staking
 * @author Steve Harmeyer
 * @notice This contract offers LP holders can stake with any crypto.
 */

/// @custom:security-contact [email protected]
contract LPStaking is BaseContract
{
    using SafeMath for uint256;
    // is necessary to receive unused bnb from the swaprouter
    receive() external payable {}
    /**
     * Contract initializer.
     * @dev This intializes all the parent contracts.
     */
    function initialize() public initializer {
        __BaseContract_init();
        _lastUpdateTime = block.timestamp;
        _dividendsPerShareAccuracyFactor = 1e36;

    }
    /**
     * Staker struct.
     */
    struct Staker {
        uint256 stakingAmount; //staking LP amount
        uint256 boostedAmount; //boosted staking LP amount
        uint256 rewardDebt; //rewardDebt LP amount
        uint256 lastStakingUpdateTime;  //last staking update time
        uint256 stakingPeriod; //staking period
    }
    /**
     * variables
     */
    address  public lpAddress;
    address  public usdcAddress;
    address  public routerAddress;
    address  public tokenAddress;
    IUniswapV2Router02 public router;
    address  _LPLockReceiver; //address for LP lock
    address[] LPholders; // LP holders address. to get LP reflection, they have to register thier address here.

    uint256  _lastUpdateTime; //LP RewardPool Updated time
    uint256  _accLPPerShare;  //Accumulated LPs per share, times 1e36. See below.
    uint256  _dividendsPerShareAccuracyFactor; //1e36

    uint256 public totalStakerNum; //total staker number
    uint256 public totalStakingAmount; //total staked LP amount
    uint256  _totalBoostedAmount; //total boosted amount for reward distrubution
    uint256  _totalReward;  //total LP amount for LP reward to LP stakers
    uint256  _totalReflection; //total LP amount to LP reflection to LP holders
    uint256  _LPLockAmount; // total locked LP amount. except from LP reflection
    /**
     * Mappings.
     */
    mapping(address => Staker) public stakers;
    mapping(address => uint256) _LPholderIndexes;
    mapping(address => address[]) public pathFromTokenToUSDC;
    /**
     * Event.
     */
    event Stake(address indexed staker, uint256 amount, uint256 duration);
    event ClaimRewards(address indexed staker, uint256 amount);
    event Compound(address indexed staker, uint256 amount);
    event Unstake(address indexed staker, uint256 amount);

    /**
     * Update addresses.
     * @dev Updates stored addresses.
     */
    function updateAddresses() public
    {
        IUniswapV2Factory _factory_ = IUniswapV2Factory(addressBook.get("factory"));
        lpAddress = _factory_.getPair(addressBook.get("payment"), addressBook.get("token"));
        _LPLockReceiver = addressBook.get("lpLockReceiver");
        usdcAddress = addressBook.get("payment");
        routerAddress = addressBook.get("router");
        tokenAddress = addressBook.get("token");
    }

    /**
     * Remaining Locked Time.
     */
    function getRemainingLockedTime(address stakerAddress) public view returns(uint256)
    {
        if(stakers[stakerAddress].stakingPeriod == 0) return 0;
        return stakers[stakerAddress].lastStakingUpdateTime + stakers[stakerAddress].stakingPeriod - block.timestamp;
    }

    /**
     * total LP amount holded this contract
     */
    function _LPSupply_() external view returns (uint256)
    {
        return IERC20(lpAddress).balanceOf(address(this));
    }

    /**
     * claimable Reward for LP stakers
     * @param stakerAddress_ staker address
     * @return pending_ claimable LP amount
     */
    function pendingReward(address stakerAddress_)
        public
        view
        returns (uint256 pending_)
    {
        if (stakers[stakerAddress_].stakingAmount <= 0) return 0;
        pending_ = stakers[stakerAddress_].boostedAmount.mul(_accLPPerShare).div(_dividendsPerShareAccuracyFactor).sub(stakers[stakerAddress_].rewardDebt);
    }

    /**
     * Update reward pool for LP stakers.
     * @dev update _accLPPerShare
     */
    function updateRewardPool() public
    {
        if (lpAddress == address(0)) updateAddresses();
        uint256 _deltaTime_ = block.timestamp - _lastUpdateTime;
        if (_deltaTime_ < 24 hours) return;
        //distribute reflection rewards to lp holders
        _distributeReflectionRewards();
        //set times limit value
        uint256 _times_ = _deltaTime_.div(24 hours);
        if (_times_ > 40) _times_ = 40;
        //calculte total reward lp for stakers
        _totalReward = IERC20(lpAddress).balanceOf(address(this)).sub(totalStakingAmount).sub(_totalReflection);
        if(_totalReward <= 0){
            _lastUpdateTime = block.timestamp;
            return;
        }
        //update accumulated LPs per share
        uint256 _amountForReward_ = _totalReward.mul(25).div(1000).mul(_times_);
        uint256 _RewardPerShare_ = _amountForReward_.mul(_dividendsPerShareAccuracyFactor).div(_totalBoostedAmount);
        _accLPPerShare = _accLPPerShare.add(_RewardPerShare_);
        _totalReward = _totalReward.sub(_amountForReward_);
        _lastUpdateTime = _lastUpdateTime.add(_times_.mul(24 hours));
    }

    /**
     * Stake for.
     * @param paymentAddress_ Payment token address.
     * @param paymentAmount_ Amount to stake.
     * @param durationIndex_ Duration index.
     * @param staker_ Staker address.
     */
    function stakeFor(address paymentAddress_, uint256 paymentAmount_, uint256 durationIndex_, address staker_) external
    {
        _stake(paymentAddress_, paymentAmount_, durationIndex_, staker_);
    }

    /**
     * Stake.
     * @param paymentAddress_ Payment token address.
     * @param paymentAmount_ Amount to stake.
     * @param durationIndex_ Duration index.
     */
    function stake(address paymentAddress_, uint256 paymentAmount_, uint256 durationIndex_) external
    {
        _stake(paymentAddress_, paymentAmount_, durationIndex_, msg.sender);
    }

    /**
     * Internal stake.
     * @param paymentAddress_ Payment token address.
     * @param paymentAmount_ Amount to stake.
     * @param durationIndex_ Duration index.
     * @param staker_ Staker address.
     */
    function _stake(address paymentAddress_, uint256 paymentAmount_, uint256 durationIndex_, address staker_) internal
    {
        if (lpAddress == address(0) || _LPLockReceiver == address(0) || usdcAddress == address(0)) updateAddresses();
        require(durationIndex_ <= 3, "Non exist duration!");
        //convert crypto to LP
        (uint256 _lpAmount_,,) = _buyLP(paymentAddress_, paymentAmount_);
        //add Staker number
        if (stakers[staker_].stakingAmount == 0) totalStakerNum++;
        // update reward pool
        updateRewardPool();
        //already staked member
        if (stakers[staker_].stakingAmount > 0) {
            if(stakers[staker_].stakingPeriod == 30 days)
                require(durationIndex_ >= 1, "you have to stake more than a month");
            if(stakers[staker_].stakingPeriod == 60 days)
                require(durationIndex_ >= 2, "you have to stake more than two month");
            if(stakers[staker_].stakingPeriod == 90 days)
                require(durationIndex_ == 3, "you have to stake during three month");
            //transfer pending reward to staker_
            uint256 _pending_ = pendingReward(staker_);
            if(_pending_ > 0){
                uint256 _usdcAmount_ = _sellLP(_pending_);
                IERC20(usdcAddress).transfer(staker_, _usdcAmount_);
            }
        }
        //transfer 3% LP to lpLock wallet
        IERC20(lpAddress).transfer(_LPLockReceiver, _lpAmount_.mul(30).div(1000));
        //set boosted LP amount regarding to staking period
        uint256 _boosting_lpAmount_;
        if (durationIndex_ == 0) _boosting_lpAmount_ = _lpAmount_;
        if (durationIndex_ == 1)  _boosting_lpAmount_ = _lpAmount_.mul(102).div(100);
        if (durationIndex_ == 2) _boosting_lpAmount_ = _lpAmount_.mul(105).div(100);
        if (durationIndex_ == 3)  _boosting_lpAmount_ = _lpAmount_.mul(110).div(100);
        stakers[msg.sender].stakingPeriod = durationIndex_ * 30 days;
        //update staker data
        stakers[staker_].stakingAmount = stakers[staker_].stakingAmount.add(_lpAmount_.mul(900).div(1000));
        stakers[staker_].boostedAmount = stakers[staker_].boostedAmount.add(_boosting_lpAmount_.mul(900).div(1000));
        stakers[staker_].rewardDebt = stakers[staker_].boostedAmount.mul(_accLPPerShare).div(_dividendsPerShareAccuracyFactor);
        stakers[staker_].lastStakingUpdateTime = block.timestamp;
        //update total amounts
        totalStakingAmount = totalStakingAmount.add(_lpAmount_.mul(900).div(1000));
        _totalBoostedAmount = _totalBoostedAmount.add(_boosting_lpAmount_.mul(900).div(1000));
        _totalReflection = _totalReflection.add(_lpAmount_.mul(20).div(1000));
        _LPLockAmount = _LPLockAmount.add(_lpAmount_.mul(30).div(1000));

        emit Stake(staker_, _lpAmount_, stakers[staker_].stakingPeriod);
    }

    /**
     * stake function
     * @param paymentAmount_ eth amount
     * @param durationIndex_ duration index.
     * @dev approve LP before staking.
     */
    function stakeWithEth(uint256 paymentAmount_, uint256 durationIndex_) external payable
    {
        if (lpAddress == address(0) || _LPLockReceiver == address(0) || usdcAddress == address(0))updateAddresses();
        require(durationIndex_ <= 3, "Non exist duration!");
        //convert crypto to LP
        (uint256 _lpAmount_,,) = _buyLPWithEth(paymentAmount_);
        //add Staker number
        if (stakers[msg.sender].stakingAmount == 0) totalStakerNum++;
        // update reward pool
        updateRewardPool();
        //already staked member
        if (stakers[msg.sender].stakingAmount > 0) {
            if(stakers[msg.sender].stakingPeriod == 30 days)
                require(durationIndex_ >= 1, "you have to stake more than a month");
            if(stakers[msg.sender].stakingPeriod == 60 days)
                require(durationIndex_ >= 2, "you have to stake more than two month");
            if(stakers[msg.sender].stakingPeriod == 90 days)
                require(durationIndex_ == 3, "you have to stake during three month");
            //transfer pending reward to staker
            uint256 _pending_ = pendingReward(msg.sender);
            if(_pending_ > 0){
                uint256 _usdcAmount_ = _sellLP(_pending_);
                IERC20(usdcAddress).transfer(msg.sender, _usdcAmount_);
                }
        }
        //transfer 3% LP to lpLock wallet
        IERC20(lpAddress).transfer(_LPLockReceiver, _lpAmount_.mul(30).div(1000));
        //set boosted LP amount regarding to staking period
        uint256 _boosting_lpAmount_;
        if (durationIndex_ == 0) _boosting_lpAmount_ = _lpAmount_;
        if (durationIndex_ == 1)  _boosting_lpAmount_ = _lpAmount_.mul(102).div(100);
        if (durationIndex_ == 2) _boosting_lpAmount_ = _lpAmount_.mul(105).div(100);
        if (durationIndex_ == 3)  _boosting_lpAmount_ = _lpAmount_.mul(110).div(100);
        stakers[msg.sender].stakingPeriod = durationIndex_ * 30 days;
        //update staker data
        stakers[msg.sender].stakingAmount = stakers[msg.sender].stakingAmount.add(_lpAmount_.mul(900).div(1000));
        stakers[msg.sender].boostedAmount = stakers[msg.sender].boostedAmount.add(_boosting_lpAmount_.mul(900).div(1000));
        stakers[msg.sender].rewardDebt = stakers[msg.sender].boostedAmount.mul(_accLPPerShare).div(_dividendsPerShareAccuracyFactor);
        stakers[msg.sender].lastStakingUpdateTime = block.timestamp;
        //update total amounts
        totalStakingAmount = totalStakingAmount.add(_lpAmount_.mul(900).div(1000));
        _totalBoostedAmount = _totalBoostedAmount.add(_boosting_lpAmount_.mul(900).div(1000));
        _totalReflection = _totalReflection.add(_lpAmount_.mul(20).div(1000));
        _LPLockAmount = _LPLockAmount.add(_lpAmount_.mul(30).div(1000));

        emit Stake(msg.sender, _lpAmount_, stakers[msg.sender].stakingPeriod);
    }

    /**
     * claim reward function for LP stakers
     @notice stakers can claim every 24 hours and receive it with USDC.
     */
    function claimRewards() external
    {
        if (lpAddress == address(0)) updateAddresses();
        if (stakers[msg.sender].stakingAmount <= 0) return;
        //transfer pending reward to staker
        uint256 _pending_ = pendingReward(msg.sender);
        if (_pending_ == 0) return;
        uint256 _usdcAmount_ = _sellLP(_pending_);
        IERC20(usdcAddress).transfer(msg.sender, _usdcAmount_);
        //reset staker's rewardDebt
        stakers[msg.sender].rewardDebt = stakers[msg.sender].boostedAmount.mul(_accLPPerShare).div(_dividendsPerShareAccuracyFactor);
        // update reward pool
        updateRewardPool();
        emit ClaimRewards(msg.sender, _pending_);
    }

    /**
     * compound function for LP stakers
     @notice stakers restake claimable LP every 24 hours without staking fee.
     */
    function compound() external
    {
        if (lpAddress == address(0)) updateAddresses();
        if (stakers[msg.sender].stakingAmount <= 0) return;
        //get pending LP
        uint256 _pending_ = pendingReward(msg.sender);
        if (_pending_ == 0) return;
        //add pending LP to staker data
        stakers[msg.sender].stakingAmount = stakers[msg.sender].stakingAmount.add(_pending_);
        stakers[msg.sender].boostedAmount = stakers[msg.sender].boostedAmount.add(_pending_);
        stakers[msg.sender].rewardDebt = stakers[msg.sender].boostedAmount.mul(_accLPPerShare).div(_dividendsPerShareAccuracyFactor);
        //add pending LP to total amounts
        totalStakingAmount = totalStakingAmount.add(_pending_);
        _totalBoostedAmount = _totalBoostedAmount.add(_pending_);
        //update reward pool
        updateRewardPool();
        emit Compound(msg.sender, _pending_);
    }

    /**
     * unstake function
     @notice stakers have to claim rewards before finishing stake.
     */
    function unstake() external
    {
        if (lpAddress == address(0) || _LPLockReceiver == address(0))updateAddresses();
        //check staked lp amount and locked period
        uint256 _lpAmount_ = stakers[msg.sender].stakingAmount;
        if (_lpAmount_ <= 0) return;
        require(block.timestamp - stakers[msg.sender].lastStakingUpdateTime >= stakers[msg.sender].stakingPeriod,
            "Don't finish your staking period!"
        );
        //update reward pool
        updateRewardPool();
        // transfer pending reward to staker
        uint256 _pending_ = pendingReward(msg.sender);
        if(_pending_ > 0){
            uint256 _Pendingusdc_ = _sellLP(_pending_);
            IERC20(usdcAddress).transfer(msg.sender, _Pendingusdc_);
        }
        //convert LP to usdc and transfer staker and LP lock wallet
        uint256 _usdcAmount_ = _sellLP(_lpAmount_.mul(900).div(1000));
        IERC20(usdcAddress).transfer(msg.sender, _usdcAmount_);
        IERC20(lpAddress).transfer(_LPLockReceiver, _lpAmount_.mul(30).div(1000));
        // update total amounts
        totalStakingAmount = totalStakingAmount.sub(stakers[msg.sender].stakingAmount);
        _totalBoostedAmount = _totalBoostedAmount.sub(stakers[msg.sender].boostedAmount);
        _totalReflection = _totalReflection.add(_lpAmount_.mul(20).div(1000));
        _LPLockAmount = _LPLockAmount.add(_lpAmount_.mul(30).div(1000));
        totalStakerNum--;
        //update staker data
        stakers[msg.sender].stakingAmount = 0;
        stakers[msg.sender].boostedAmount = 0;
        stakers[msg.sender].lastStakingUpdateTime = block.timestamp;
        stakers[msg.sender].stakingPeriod = 0;

        emit Unstake(msg.sender, _lpAmount_);
    }

    /**
     * reset staking duration function
     * @param durationIndex_ duration index.
     */
    function resetStakingPeriod(uint256 durationIndex_) external
    {
        require(durationIndex_ <= 3, "Non exist duration!");
        require (stakers[msg.sender].stakingAmount > 0, "Don't exist staked amount!");
        //update reward pool
        updateRewardPool();
        //only increase staking duration
        if(durationIndex_ == 0) return;
        if(stakers[msg.sender].stakingPeriod == 30 days)
            require(durationIndex_ >= 1, "you have to stake more than a month");
        if(stakers[msg.sender].stakingPeriod == 60 days)
            require(durationIndex_ >= 2, "you have to stake more than two month");
        if(stakers[msg.sender].stakingPeriod == 90 days)
            require(durationIndex_ == 3, "you have to stake during three month");
        //transfer pending reward to staker
        uint256 _pending_ = pendingReward(msg.sender);
        if(_pending_ > 0){
            uint256 _usdcAmount_ = _sellLP(_pending_);
            IERC20(usdcAddress).transfer(msg.sender, _usdcAmount_);
        }
        //set boosted amount and reset staking period
        uint256 _boosting_lpAmount_;
        if (durationIndex_ == 0) _boosting_lpAmount_ = stakers[msg.sender].stakingAmount;
        if (durationIndex_ == 1)  _boosting_lpAmount_ = stakers[msg.sender].stakingAmount.mul(102).div(100);
        if (durationIndex_ == 2) _boosting_lpAmount_ = stakers[msg.sender].stakingAmount.mul(105).div(100);
        if (durationIndex_ == 3)  _boosting_lpAmount_ = stakers[msg.sender].stakingAmount.mul(110).div(100);
        stakers[msg.sender].stakingPeriod = durationIndex_ * 30 days;
        // update total boosted amount
        _totalBoostedAmount = _totalBoostedAmount.sub(stakers[msg.sender].boostedAmount).add(_boosting_lpAmount_);
        //update staker data
        stakers[msg.sender].boostedAmount = _boosting_lpAmount_;
        stakers[msg.sender].rewardDebt = stakers[msg.sender].boostedAmount.mul(_accLPPerShare).div(_dividendsPerShareAccuracyFactor);
        stakers[msg.sender].lastStakingUpdateTime = block.timestamp;
    }

    /**
     * register LP holders address
     @notice LP holders have to register their address to get LP reflection.
     */
    function registerAddress() external
    {
        if (_LPLockReceiver == address(0)) updateAddresses();
        if (msg.sender == _LPLockReceiver) return;
        _LPholderIndexes[msg.sender] = LPholders.length;
        LPholders.push(msg.sender);
    }

    /**
     * remove LP holders address
     */
    function removeShareholder(address _holder) public
    {
        LPholders[_LPholderIndexes[_holder]] = LPholders[LPholders.length - 1];
        _LPholderIndexes[LPholders[LPholders.length - 1]] = _LPholderIndexes[_holder];
        LPholders.pop();
    }

    /**
     * LP reflection whenever stake and unstake
      *@notice give rewards with USDC
     */
    function _distributeReflectionRewards() internal
    {
        if (lpAddress == address(0)) updateAddresses();
        if (_totalReflection == 0) return;
        //convert LP to USDC
        uint256 _totalReflectionUSDC_ = _sellLP(_totalReflection);
        uint256 _totalDividends_ = IERC20(lpAddress).totalSupply().sub(IERC20(lpAddress).balanceOf(address(this))).sub(IERC20(lpAddress).balanceOf(_LPLockReceiver));
        uint256 _ReflectionPerShare_ = _totalReflectionUSDC_.mul(_dividendsPerShareAccuracyFactor).div(_totalDividends_);
        //transfer reflection reward to LP holders
        for (uint256 i = 0; i < LPholders.length ; i++) {
            uint256 _balance_ = IERC20(lpAddress).balanceOf(LPholders[i]);
            if (_balance_ > 0)
                IERC20(usdcAddress).transfer(LPholders[i], _ReflectionPerShare_.mul(_balance_).div(_dividendsPerShareAccuracyFactor));
            if (_balance_ == 0) removeShareholder(LPholders[i]);
        }
        _totalReflection = 0;
    }

    /**
     * Set Swap router path to swap any token to USDC
     * @param token_ token address to swap
     * @param pathToUSDC_ path address array
     */
    function setSwapPathFromTokenToUSDC(
        address token_,
        address[] memory pathToUSDC_
    ) external onlyOwner
    {
        if (usdcAddress == address(0)) updateAddresses();
        require(token_ != address(0), "Invalid token address");
        require(pathToUSDC_.length >= 2, "Invalid path length");
        require(pathToUSDC_[0] == token_, "Invalid starting token");
        require(pathToUSDC_[pathToUSDC_.length - 1] == usdcAddress,"Invalid ending token");
        pathFromTokenToUSDC[token_] = pathToUSDC_;
    }

    /**
     * buy LP with any crypto
     * @param paymentAddress_ token address that user is going to buy LP
     * @param paymentAmount_ token amount that user is going to buy LP
     * @return lpAmount_ LP amount that user received
     * @return unusedUSDC_ USDC amount that don't used to buy LP
     * @return unusedToken_ token amount that don't used to buy LP
     * @dev approve token before buyLP, LP goes to LPStaking contract, unused tokens go to buyer.
     */
    function _buyLP(address paymentAddress_, uint256 paymentAmount_)
        internal
        returns (
            uint256 lpAmount_,
            uint256 unusedUSDC_,
            uint256 unusedToken_
        )
    {
        if (routerAddress == address(0) || usdcAddress == address(0) || tokenAddress == address(0)) updateAddresses();
        require(address(paymentAddress_) != address(0), "Invalid Address");
        require(paymentAmount_ > 0, "Invalid amount");
        IERC20 _payment_ = IERC20(paymentAddress_);
        require(_payment_.balanceOf(msg.sender) >= paymentAmount_,"insufficient amount");
        router = IUniswapV2Router02(routerAddress);
        IERC20 _usdc_ = IERC20(usdcAddress);
        _payment_.transferFrom(msg.sender, address(this), paymentAmount_);

        if (paymentAddress_ == usdcAddress) {
            (lpAmount_, unusedUSDC_, unusedToken_) = _buyLPwithUSDC(paymentAmount_);
            return (lpAmount_, unusedUSDC_, unusedToken_);
        }

        if (paymentAddress_ == tokenAddress) {
            (lpAmount_, unusedUSDC_, unusedToken_) = _buyLPwithFUR(paymentAmount_);
            return (lpAmount_, unusedUSDC_, unusedToken_);
        }

        address[] memory _pathFromTokenToUSDC = pathFromTokenToUSDC[paymentAddress_];
        require(_pathFromTokenToUSDC.length >=2, "Don't exist path");
        _payment_.approve(address(router), paymentAmount_);
        uint256 _USDCBalanceBefore1_ = _usdc_.balanceOf(address(this));
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            paymentAmount_,
            0,
            _pathFromTokenToUSDC,
            address(this),
            block.timestamp + 1
        );
        uint256 _USDCBalance1_ = _usdc_.balanceOf(address(this)) - _USDCBalanceBefore1_;

        (lpAmount_, unusedUSDC_, unusedToken_) = _buyLPwithUSDC(_USDCBalance1_);
        return (lpAmount_, unusedUSDC_, unusedToken_);
    }

    /**
     * buy LP with eth
     * @param paymentAmount_ eth amount that user is going to buy LP
     * @return lpAmount_ LP amount that user received
     * @return unusedUSDC_ USDC amount that don't used to buy LP
     * @return unusedToken_ token amount that don't used to buy LP
     * @dev approve token before buyLP, LP goes to LPStaking contract, unused tokens go to buyer.
     */
    function _buyLPWithEth(uint256 paymentAmount_)
        internal
        returns (
            uint256 lpAmount_,
            uint256 unusedUSDC_,
            uint256 unusedToken_
        )
    {

        if (routerAddress == address(0) || usdcAddress == address(0) || tokenAddress == address(0)) updateAddresses();
        require(paymentAmount_ > 0, "Invalid amount");
        require(msg.value >= paymentAmount_, "insufficient amount");
        router = IUniswapV2Router02(routerAddress);
        IERC20 _usdc_ = IERC20(usdcAddress);

        address[] memory _path_ = new address[](2);
        _path_[0] = address(router.WETH());
        _path_[1] = address(_usdc_);
        uint256 _USDCBalanceBefore_ = _usdc_.balanceOf(address(this));
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: paymentAmount_}(
            0,
            _path_,
            address(this),
            block.timestamp + 1
        );
        uint256 _USDCBalance_ = _usdc_.balanceOf(address(this)) - _USDCBalanceBefore_;

        (lpAmount_, unusedUSDC_, unusedToken_) = _buyLPwithUSDC(_USDCBalance_);
        return (lpAmount_, unusedUSDC_, unusedToken_);
    }

    /**
     * buy LP with USDC
     * @param paymentAmount_ USDC amount that user is going to buy LP
     * @return lpAmount_ LP amount that user received
     * @return unusedUSDC_ USDC amount that don't used to buy LP
     * @return unusedToken_ FUR amount that don't used to buy LP
     * @notice buyer can get unused USDC and token automatically, LP goes LPStaking contract
     */
    function _buyLPwithUSDC(uint256 paymentAmount_)
        internal
        returns (
            uint256 lpAmount_,
            uint256 unusedUSDC_,
            uint256 unusedToken_
        )
    {
        IERC20 _usdc_ = IERC20(usdcAddress);
        IToken _token_ = IToken(tokenAddress);
        router = IUniswapV2Router02(routerAddress);

        uint256 _amountToLiquify_ = paymentAmount_ / 2;
        uint256 _amountToSwap_ = paymentAmount_ - _amountToLiquify_;
        if (_amountToSwap_ == 0) return (0, 0, 0);

        address[] memory _path_ = new address[](2);
        _path_[0] = address(_usdc_);
        _path_[1] = address(_token_);
        _usdc_.approve(address(router), _amountToSwap_);
        uint256 _balanceBefore_ = _token_.balanceOf(address(this));
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _amountToSwap_,
            0,
            _path_,
            address(this),
            block.timestamp + 1
        );
        uint256 _amountUSDC_ = _token_.balanceOf(address(this)) -_balanceBefore_;

        if (_amountToLiquify_ <= 0 || _amountUSDC_ <= 0) return (0, 0, 0);
        _usdc_.approve(address(router), _amountToLiquify_);
        _token_.approve(address(router), _amountUSDC_);

        (uint256 _usedPaymentToken_, uint256 _usedToken_, uint256 _lpValue_) = router.addLiquidity(
            address(_usdc_),
            address(_token_),
            _amountToLiquify_,
            _amountUSDC_,
            0,
            0,
            address(this),
            block.timestamp + 1
        );
        lpAmount_ = _lpValue_;
        unusedUSDC_ = _amountToLiquify_ - _usedPaymentToken_;
        unusedToken_ = _amountUSDC_ - _usedToken_;
        // send back unused tokens
        _usdc_.transfer(msg.sender, unusedUSDC_);
        _token_.transfer(msg.sender, unusedToken_);
    }

    /**
     * buy LP with FUR
     * @param paymentAmount_ $FUR amount that user is going to buy LP
     * @return lpAmount_ LP amount that user received
     * @return unusedUSDC_ USDC amount that don't used to buy LP
     * @return unusedToken_ $FUR amount that don't used to buy LP
     * @notice buyer can get unused USDC and token automatically, LP goes LPStaking contract
     */
    function _buyLPwithFUR(uint256 paymentAmount_)
        internal
        returns (
            uint256 lpAmount_,
            uint256 unusedUSDC_,
            uint256 unusedToken_
        )
    {
        IERC20 _usdc_ = IERC20(usdcAddress);
        IToken _token_ = IToken(tokenAddress);
        router = IUniswapV2Router02(routerAddress);

        uint256 _amountToLiquify_ = paymentAmount_ / 2;
        uint256 _amountToSwap_ = paymentAmount_ - _amountToLiquify_;
        if (_amountToSwap_ == 0) return (0, 0, 0);

        address[] memory _path_ = new address[](2);
        _path_[0] = address(_token_);
        _path_[1] = address(_usdc_);
        _token_.approve(address(router), _amountToSwap_);
        uint256 _balanceBefore_ = _usdc_.balanceOf(address(this));
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _amountToSwap_,
            0,
            _path_,
            address(this),
            block.timestamp + 1
        );
        uint256 _amountUSDC_ = _usdc_.balanceOf(address(this)) -_balanceBefore_;

        if (_amountToLiquify_ <= 0 || _amountUSDC_ <= 0) return (0, 0, 0);
        _token_.approve(address(router), _amountToLiquify_);
        _usdc_.approve(address(router), _amountUSDC_);

        (uint256 _usedPaymentToken_, uint256 _usedToken_, uint256 _lpValue_ ) = router.addLiquidity(
            address(_usdc_),
            address(_token_),
            _amountUSDC_,
            _amountToLiquify_,
            0,
            0,
            address(this),
            block.timestamp + 1
        );
        lpAmount_ = _lpValue_;
        unusedToken_ = _amountToLiquify_ - _usedToken_;
        unusedUSDC_ = _amountUSDC_ - _usedPaymentToken_;
        // send back unused tokens
        _usdc_.transfer(msg.sender, unusedUSDC_);
        _token_.transfer(msg.sender, unusedToken_);
    }

    /**
     * Sell LP
     * @param lpAmount_ LP amount that user is going to sell
     * @return paymentAmount_ USDC amount that user received
     * @dev approve LP before this function calling, usdc goes to LPStaking contract
     */
    function _sellLP(uint256 lpAmount_) internal returns (uint256 paymentAmount_) {
        if (routerAddress == address(0) || tokenAddress == address(0) || usdcAddress == address(0) || lpAddress == address(0)) updateAddresses();
        if (lpAmount_ <= 0) return 0;
        IERC20 _usdc_ = IERC20(usdcAddress);
        IERC20 _token_ = IERC20(tokenAddress);
        router = IUniswapV2Router02(routerAddress);
        IERC20 _lptoken_ = IERC20(lpAddress);

        _lptoken_.approve(address(router), lpAmount_);
        uint256 _tokenBalanceBefore_ = _token_.balanceOf(address(this));
        (uint256 _USDCFromRemoveLiquidity_, ) = router.removeLiquidity(
            address(_usdc_),
            address(_token_),
            lpAmount_,
            0,
            0,
            address(this),
            block.timestamp + 1
        );

        uint256 _tokenBalance_ = _token_.balanceOf(address(this)) -_tokenBalanceBefore_;
        if (_tokenBalance_ == 0) return 0;

        _token_.approve(address(router), _tokenBalance_);
        address[] memory path = new address[](2);
        path[0] = address(_token_);
        path[1] = address(_usdc_);
        uint256 _USDCbalanceBefore_ = _usdc_.balanceOf(address(this));
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _tokenBalance_,
            0,
            path,
            address(this),
            block.timestamp + 1
        );
        uint256 _USDCFromSwap = _usdc_.balanceOf(address(this)) - _USDCbalanceBefore_;
        paymentAmount_ = _USDCFromRemoveLiquidity_ + _USDCFromSwap;
    }

    /**
     * withdraw functions
     */
    function withdrawLP() external onlyOwner {
        if (lpAddress == address(0)) updateAddresses();
        IERC20(lpAddress).transfer(msg.sender, IERC20(lpAddress).balanceOf(address(this)));
    }
    function withdrawUSDC() external onlyOwner {
        if (usdcAddress == address(0)) updateAddresses();
        IERC20(usdcAddress).transfer(msg.sender, IERC20(usdcAddress).balanceOf(address(this)));
    }
    function withdrawFUR() external onlyOwner {
        if (tokenAddress == address(0)) updateAddresses();
        IERC20(tokenAddress).transfer(msg.sender, IERC20(tokenAddress).balanceOf(address(this)));
    }

    /**
     * view LP amount to USDC
     */
    function _getLpPriceInUsdc(uint256 lpAmount) internal view returns (uint256){
        IUniswapV2Pair LPToken = IUniswapV2Pair(lpAddress);
        uint256 reserveUSDC;
        if(LPToken.token0() == usdcAddress) {( reserveUSDC,, ) = LPToken.getReserves();}
        if(LPToken.token1() == usdcAddress) {(,reserveUSDC, ) = LPToken.getReserves();}
        uint256 LpPriceInUsdc = lpAmount * 2 * reserveUSDC / LPToken.totalSupply();
        return LpPriceInUsdc;
    }
    function totalStakingAmountInUsdc() external view returns (uint256){
        return _getLpPriceInUsdc(totalStakingAmount);
    }
    function stakingAmountInUsdc(address staker_) external view returns (uint256){
        return _getLpPriceInUsdc(stakers[staker_].stakingAmount);
    }
    function boostedAmountInUsdc(address staker_) external view returns (uint256){
        return _getLpPriceInUsdc(stakers[staker_].boostedAmount);
    }
    function totalRewardableAmountInUsdc() external view returns (uint256){
        uint256 _totalReward_ = IERC20(lpAddress).balanceOf(address(this)).sub(totalStakingAmount).sub(_totalReflection);
        return _getLpPriceInUsdc(_totalReward_);
    }
    function availableRewardsInUsdc(address staker_) external view returns (uint256){
        uint256 _pending_ =  pendingReward(staker_);
        return _getLpPriceInUsdc(_pending_);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[45] private __gap;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "./interfaces/IToken.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./interfaces/ILiquidityManager.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";

contract LMD is OwnableUpgradeable, ILiquidityManager {
    using SafeMath for uint256;
    IERC20 USDC;
    IToken TOKEN;
    address public tokenAddr;
    address public swapPairAddr;
    address public usdcAddr;
    uint256 public amountModifier;
    uint256 public priceBalancerUpperThreshold;
    uint256 public priceBalancerLowerThreshold;
    bool public liquidityManagementEnabled;
    IUniswapV2Router02 private uniSwapRouter;

    uint256 public distributedUsdcTotal;
    uint32 public pricePrecision;
    mapping(address => bool) private adminAddresses;

    function initialize(address router, address usdcContract) external initializer {
        __Ownable_init();

        usdcAddr = usdcContract;
        USDC = ERC20(usdcContract);
        uniSwapRouter = IUniswapV2Router02(router);
        amountModifier = 200;
        pricePrecision = 1000;

        priceBalancerUpperThreshold = 10000;
        priceBalancerLowerThreshold = 8001;
        liquidityManagementEnabled = true;
    }

    modifier adminsOnly() {
        require(
            (_msgSender() == owner() ||
                adminAddresses[_msgSender()] ||
                _msgSender() == address(this)),
            "Access only for Owner and the token contracts"
        );
        _;
    }

    modifier zeroAddressCheck(address addr) {
        require(addr != address(0), "zero address detected");
        _;
    }

    function setThresholds(uint256 upperBound, uint256 lowerBound)
        external
        adminsOnly
    {
        require(
            upperBound > lowerBound,
            "UpperBound needs to be bigger than LowerBound"
        );
        priceBalancerUpperThreshold = upperBound;
        priceBalancerLowerThreshold = lowerBound;
    }

    function setAdmins(address adminAddr, bool value) external onlyOwner {
        adminAddresses[adminAddr] = value;
    }

    function setTokenContractAddr(address tokenContractAddr)
        external
        zeroAddressCheck(tokenContractAddr)
        onlyOwner
    {
        tokenAddr = tokenContractAddr;
        TOKEN = IToken(tokenContractAddr);
        IUniswapV2Factory factory = IUniswapV2Factory(uniSwapRouter.factory());
        swapPairAddr = factory.getPair(tokenAddr, usdcAddr);
    }

    function setSwapPair(address swapPair)
        external
        zeroAddressCheck(swapPair)
        onlyOwner
    {
        swapPairAddr = swapPair;
    }

    function enableLiquidityManager(bool value) external override adminsOnly {
        liquidityManagementEnabled = value;
        //if (value == true) {
            //require(
                //_msgSender() == tokenAddr,
                //"LM can only be reactivated from token contract"
            //);
        //}
    }

    // calculate price based on pair reserves
    function getTokenPrice() public view returns (uint256) {
        IUniswapV2Pair pair = IUniswapV2Pair(swapPairAddr);
        (uint256 Res0, uint256 Res1, ) = pair.getReserves();
        //Avoid division by zero first time Liquidity is added to LP
        if (Res0 == 0 || Res1 == 0) return 0;
        uint256 usdcReserve = Res0;
        uint256 tokenReserve = Res1;

        address token0 = pair.token0();
        if (token0 == tokenAddr) {
            tokenReserve = Res0;
            usdcReserve = Res1;
        }
        return usdcReserve.div(tokenReserve.div(pricePrecision)); // return amount of token0 needed to buy token1
    }

    function swapTokenForUsdc(
        address to,
        uint256 amountIn,
        uint256 amountOutMin
    ) external override adminsOnly {
        bool success = TOKEN.transferFrom(to, address(this), amountIn);
        require(success, "Transfer of TOKEN failed");
        _swapTokensForUSDC(to, amountIn, amountOutMin);
    }

    function swapUsdcForToken(
        address to,
        uint256 amountIn,
        uint256 amountOutMin
    ) external override adminsOnly zeroAddressCheck(to) {
        uint256 sc = USDC.allowance(to, address(this));
        require(sc >= amountIn, "Allowance too low");
        bool success = USDC.transferFrom(to, address(this), amountIn);
        require(success, "Transfer of USDC failed");

        _swapUSDCForTokens(to, amountIn, amountOutMin);
    }

    function swapTokenForUsdcToWallet(
        address from,
        address destination,
        uint256 tokenAmount,
        uint256 slippage
    ) external override adminsOnly {
        TOKEN.transferFrom(from, address(this), tokenAmount);
        slippage = slippage.mul(100);
        uint256 origTokenPrice = getTokenPrice();
        uint256 desiredAmount = origTokenPrice.mul(tokenAmount).div(
            pricePrecision
        );
        uint256 minAcceptableAmount = desiredAmount.sub(
            desiredAmount.mul(slippage).div(1e4)
        );

        _swapTokensForUSDC(destination, tokenAmount, minAcceptableAmount);
    }

    function _swapTokensForUSDC(
        address destination,
        uint256 tokenAmount,
        uint256 amountOutMin
    ) private {
        require(amountOutMin > 0, "Minimum Output amount can not be zero");
        address[] memory path = new address[](2);
        path[0] = tokenAddr;
        path[1] = usdcAddr;
        bool success = IERC20(tokenAddr).approve(
            address(uniSwapRouter),
            tokenAmount
        );

        require(success, "Approval of TOKEN amount failed");
        uniSwapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            amountOutMin, // if 0 it accepts any amount of USDC
            path,
            destination,
            block.timestamp
        );
    }

    function _swapUSDCForTokens(
        address destination,
        uint256 usdcAmount,
        uint256 amountOutMin
    ) private {
        require(amountOutMin > 0, "Minimum Output amount can not be zero");
        address[] memory path = new address[](2);
        path[0] = usdcAddr;
        path[1] = tokenAddr;
        bool success = ERC20(usdcAddr).approve(
            address(uniSwapRouter),
            usdcAmount
        );
        require(success, "Approval of USDC amount failed");
        uniSwapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            usdcAmount,
            amountOutMin, // if 0 it accepts any amount of TOKEN
            path,
            destination,
            block.timestamp
        );
    }

    function rebalance(uint256 amount, bool buyback) external override
    {}

    /**
     * Set address book.
     * @param address_ Address book address.
     * @dev Sets the address book address.
     */
    function setAddressBook(address address_) public onlyOwner
    {
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

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
contract ERC20 is Context, IERC20, IERC20Metadata {
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
    constructor(string memory name_, string memory symbol_) {
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
        _approve(owner, spender, allowance(owner, spender) + addedValue);
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
        uint256 currentAllowance = allowance(owner, spender);
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
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
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
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract FakeToken2 is ERC20
{
    constructor() ERC20("Fake Token 2", "FT2") {}

    function mint(address to_, uint256 amount_) external
    {
        super._mint(to_, amount_);
    }
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

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.12;

import {
    SafeERC20,
    IERC20
} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

interface IOps {
    function gelato() external view returns (address payable);
}

abstract contract OpsReady {
    address public immutable ops;
    address payable public immutable gelato;
    address public constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    modifier onlyOps() {
        require(msg.sender == ops, "OpsReady: onlyOps");
        _;
    }

    constructor(address _ops) {
        ops = _ops;
        gelato = IOps(_ops).gelato();
    }

    function _transfer(uint256 _amount, address _paymentToken) internal {
        if (_paymentToken == ETH) {
            (bool success, ) = gelato.call{value: _amount}("");
            require(success, "_transfer: ETH transfer failed");
        } else {
            SafeERC20.safeTransfer(IERC20(_paymentToken), gelato, _amount);
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract FakeToken1 is ERC20
{
    constructor() ERC20("Fake Token 1", "FT1") {}

    function mint(address to_, uint256 amount_) external
    {
        super._mint(to_, amount_);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./abstracts/BaseContract.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";

/**
 * @title FurBet Token
 * @notice This is the ERC20 contract for $FURBET.
 */

/// @custom:security-contact [email protected]
contract FurBetToken is BaseContract, ERC20Upgradeable
{
    /**
     * Contract initializer.
     * @dev This intializes all the parent contracts.
     */
    function initialize() initializer public
    {
        __BaseContract_init();
        __ERC20_init("FurBet", "$FURB");
    }

    /**
     * Mint.
     * @param to_ The address to mint to.
     * @param quantity_ The token quantity to mint.
     */
    function mint(address to_, uint256 quantity_) external {
        require(_canMint(msg.sender), "FurBetToken: Unauthorized");
        super._mint(to_, quantity_);
    }

    /**
     * Can mint?
     * @param address_ Address of sender.
     * @return bool True if trusted.
     */
    function _canMint(address address_) internal view returns (bool)
    {
        if(address_ == owner()) {
            return true;
        }
        if(address_ == addressBook.get("furbetpresale")) {
            return true;
        }
        if(address_ == addressBook.get("furbetstake")) {
            return true;
        }
        if(address_ == addressBook.get("furmax")) {
            return true;
        }
        return false;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./abstracts/BaseContract.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";

/**
 * @title Furio Vault
 * @author Steve Harmeyer
 * @notice This is the Furio vault contract.
 */

/// @custom:security-contact [email protected]
contract VaultV2 is BaseContract, ERC721Upgradeable
{
    /**
     * Contract initializer.
     * @dev This intializes all the parent contracts.
     */
    function initialize() initializer public
    {
        __ERC721_init("Furio Vault NFT", "$FURV");
        __BaseContract_init();
        _period = 1 days;
    }

    /**
     * Properties.
     */
    uint256 _period;
    uint256 _tokenId; // Token ID tracker.
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./abstracts/BaseContract.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
// Interfaces
import "./interfaces/IVault.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";

/**
 * @title FurBot
 * @notice This is the NFT contract for FurBot.
 */

/// @custom:security-contact [email protected]
contract FurBotMax is BaseContract, ERC721Upgradeable
{
    /**
     * Contract initializer.
     * @dev This intializes all the parent contracts.
     */
    function initialize() initializer public
    {
        __BaseContract_init();
        __ERC721_init("FurBotMax", "$FURBOTM");
    }

    using Strings for uint256;

    /**
     * Global stats.
     */
    uint256 public totalSupply;
    uint256 public totalPendingInvestment;
    uint256 public totalInvestment;
    uint256 public totalDividends;
    uint256 public totalDividendsClaimed;
    uint256 public lastDistribution;

    /**
     * External contracts.
     */
    IERC20 private _paymentToken;
    IVault private _vault;
    address private _furmarket;
    address private _treasury;

    /**
     * NFTs
     */
    uint256 private _tokenIdTracker;
    mapping(uint256 => uint256) private _tokenPendingInvestment;
    mapping(uint256 => uint256) private _tokenInvestment;
    mapping(uint256 => uint256) private _tokenDividendsClaimed;

    /**
     * Setup.
     */
    function setup() external
    {
        _paymentToken = IERC20(addressBook.get("payment"));
        _vault = IVault(addressBook.get("vault"));
        _furmarket = addressBook.get("furmarket");
        _treasury = addressBook.get("safe");
    }

    /**
     * Deposit.
     * @param participant_ Participant address.
     * @param amount_ Amount of USDC to deposit.
     */
    function deposit(address participant_, uint256 amount_) external canDeposit
    {
        require(_paymentToken.transferFrom(msg.sender, _treasury, amount_), "FurBot: Transfer failed");
        uint256 _balance_ = balanceOf(participant_);
        if(_balance_ == 0) {
            _tokenIdTracker++;
            _mint(participant_, _tokenIdTracker);
            _balance_ = 1;
        }
        uint256 _valuePerNft_ = amount_ / _balance_;
        for(uint256 i = 1; i <= _tokenIdTracker; i++) {
            if(ownerOf(i) == participant_) {
                _tokenPendingInvestment[i] += _valuePerNft_;
                totalPendingInvestment += _valuePerNft_;
            }
        }
    }

    /**
     * Approve.
     * @param to_ The address to approve.
     * @param tokenId_ The token ID.
     * @dev Overridden to prevent token sales through third party marketplaces.
     */
    function approve(address to_, uint256 tokenId_) public virtual override whenNotPaused
    {
        require(to_ == _furmarket, "Third party marketplaces not allowed.");
        super.approve(to_, tokenId_);
    }

    /**
     * Set approval for all.
     * @param operator_ The operator address.
     * @param approved_ The approval status.
     * @dev Overridden to prevent token sales through third party marketplaces.
     */
    function setApprovalForAll(address operator_, bool approved_) public virtual override whenNotPaused
    {
        require(operator_ == _furmarket, "Third party marketplaces not allowed.");
        super.setApprovalForAll(operator_, approved_);
    }

    /**
     * Token URI.
     * @param tokenId_ The token ID.
     * @return string The metadata json.
     */
    function tokenURI(uint256 tokenId_) public view override returns(string memory)
    {
        require(tokenId_ > 0 && tokenId_ <= totalSupply, "Invalid token ID");
        bytes memory _meta_ = abi.encodePacked(
            '{',
            '"name": "FurBot #', tokenId_.toString(), '",',
            '"description":"Automated market trading through NFTs. Earn monthly passive income by simply holding. NFTs increase in value monthly as the trading pools they are connected to compounds their monthly interest.",',
            '"attributes": [',
            abi.encodePacked(
                '{"trait_type":"Pending Investment", "value":"', _tokenPendingInvestment[tokenId_].toString(), '"},',
                '{"trait_type":"Investment","value":"', _tokenInvestment[tokenId_].toString(), '"},',
                '{"trait_type":"Dividends Available","value":"', availableDividendsByToken(tokenId_).toString(), '"},',
                '{"trait_type":"Dividends Claimed","value":"', _tokenDividendsClaimed[tokenId_].toString(), '"}'
            ),
            ']',
            '}'
        );
        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(_meta_)
            )
        );
    }

    /**
     * Available dividends by token.
     * @param tokenId_ The token ID.
     * @return uint256 The available dividends.
     */
    function availableDividendsByToken(uint256 tokenId_) public view returns(uint256)
    {
        require(tokenId_ > 0 && tokenId_ <= totalSupply, "Invalid token ID");
        return ((_tokenInvestment[tokenId_] * totalDividends) / totalInvestment) - _tokenDividendsClaimed[tokenId_];
    }

    /**
     * Can deposit modifier.
     */
    modifier canDeposit()
    {
        require(msg.sender == address(_vault), "FurBot: Only the vault can deposit.");
        _;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Base64.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides a set of functions to operate with Base64 strings.
 *
 * _Available since v4.5._
 */
library Base64 {
    /**
     * @dev Base64 Encoding/Decoding Table
     */
    string internal constant _TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    /**
     * @dev Converts a `bytes` to its Bytes64 `string` representation.
     */
    function encode(bytes memory data) internal pure returns (string memory) {
        /**
         * Inspired by Brecht Devos (Brechtpd) implementation - MIT licence
         * https://github.com/Brechtpd/base64/blob/e78d9fd951e7b0977ddca77d92dc85183770daf4/base64.sol
         */
        if (data.length == 0) return "";

        // Loads the table into memory
        string memory table = _TABLE;

        // Encoding takes 3 bytes chunks of binary data from `bytes` data parameter
        // and split into 4 numbers of 6 bits.
        // The final Base64 length should be `bytes` data length multiplied by 4/3 rounded up
        // - `data.length + 2`  -> Round up
        // - `/ 3`              -> Number of 3-bytes chunks
        // - `4 *`              -> 4 characters for each chunk
        string memory result = new string(4 * ((data.length + 2) / 3));

        assembly {
            // Prepare the lookup table (skip the first "length" byte)
            let tablePtr := add(table, 1)

            // Prepare result pointer, jump over length
            let resultPtr := add(result, 32)

            // Run over the input, 3 bytes at a time
            for {
                let dataPtr := data
                let endPtr := add(data, mload(data))
            } lt(dataPtr, endPtr) {

            } {
                // Advance 3 bytes
                dataPtr := add(dataPtr, 3)
                let input := mload(dataPtr)

                // To write each character, shift the 3 bytes (18 bits) chunk
                // 4 times in blocks of 6 bits for each character (18, 12, 6, 0)
                // and apply logical AND with 0x3F which is the number of
                // the previous character in the ASCII table prior to the Base64 Table
                // The result is then added to the table to get the character to write,
                // and finally write it in the result pointer but with a left shift
                // of 256 (1 byte) - 8 (1 ASCII char) = 248 bits

                mstore8(resultPtr, mload(add(tablePtr, and(shr(18, input), 0x3F))))
                resultPtr := add(resultPtr, 1) // Advance

                mstore8(resultPtr, mload(add(tablePtr, and(shr(12, input), 0x3F))))
                resultPtr := add(resultPtr, 1) // Advance

                mstore8(resultPtr, mload(add(tablePtr, and(shr(6, input), 0x3F))))
                resultPtr := add(resultPtr, 1) // Advance

                mstore8(resultPtr, mload(add(tablePtr, and(input, 0x3F))))
                resultPtr := add(resultPtr, 1) // Advance
            }

            // When data `bytes` is not exactly 3 bytes long
            // it is padded with `=` characters at the end
            switch mod(mload(data), 3)
            case 1 {
                mstore8(sub(resultPtr, 1), 0x3d)
                mstore8(sub(resultPtr, 2), 0x3d)
            }
            case 2 {
                mstore8(sub(resultPtr, 1), 0x3d)
            }
        }

        return result;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./abstracts/BaseContract.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
// Interfaces
import "./interfaces/IVault.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";

/**
 * @title FurBot
 * @notice This is the NFT contract for FurBot.
 */

/// @custom:security-contact [email protected]
contract FurBot is BaseContract, ERC721Upgradeable
{
    /**
     * Contract initializer.
     * @dev This intializes all the parent contracts.
     */
    function initialize() initializer public
    {
        __BaseContract_init();
        __ERC721_init("FurBot", "$FURBOT");
    }

    using Strings for uint256;

    /**
     * Global stats.
     */
    uint256 public totalSupply;
    uint256 public totalInvestment;
    uint256 public totalDividends;

    /**
     * External contracts.
     */
    IERC20 private _paymentToken;
    IVault private _vault;
    address private _furmarket;

    /**
     * Generations.
     */
    uint256 private _generationIdTracker;
    mapping(uint256 => uint256) private _generationMaxSupply;
    mapping(uint256 => uint256) private _generationTotalSupply;
    mapping(uint256 => uint256) private _generationInvestment;
    mapping(uint256 => uint256) private _generationDividends;
    mapping(uint256 => string) private _generationImageUri;

    /**
     * Sales.
     */
    uint256 private _saleIdTracker;
    mapping(uint256 => uint256) private _saleGenerationId;
    mapping(uint256 => uint256) private _salePrice;
    mapping(uint256 => uint256) private _saleStart;
    mapping(uint256 => uint256) private _saleEnd;
    mapping(uint256 => bool) private _saleRestricted;

    /**
     * Tokens.
     */
    uint256 private _tokenIdTracker;
    mapping(uint256 => uint256) private _tokenGenerationId;
    mapping(uint256 => uint256) private _tokenInvestment;
    mapping(uint256 => uint256) private _tokenDividendsClaimed;

    /**
     * Events.
     */
    event GenerationCreated(uint256 indexed id_);
    event SaleCreated(uint256 indexed id_);
    event TokenPurchased(uint256 indexed id_);
    event DividendsAdded(uint256 indexed id_, uint256 amount_);
    event DividendsClaimed(address indexed owner_, uint256 amount_);

    /**
     * Setup.
     */
    function setup() external
    {
        _paymentToken = IERC20(addressBook.get("payment"));
        _vault = IVault(addressBook.get("vault"));
        _furmarket = addressBook.get("furmarket");
    }

    /**
     * Token of owner by index.
     * @param owner_ The owner address.
     * @param index_ The index of the token.
     */
    function tokenOfOwnerByIndex(address owner_, uint256 index_) public view returns (uint256)
    {
        require(balanceOf(owner_) > index_, "Index out of bounds");
        for(uint256 i = 1; i <= totalSupply; i++) {
            if(ownerOf(i) == owner_) {
                if(index_ == 0) return i;
                index_--;
            }
        }
        return 0;
    }

    /**
     * Token URI.
     * @param tokenId_ The token ID.
     * @return string The metadata json.
     */
    function tokenURI(uint256 tokenId_) public view override returns(string memory)
    {
        require(tokenId_ > 0 && tokenId_ <= totalSupply, "Invalid token ID");
        bytes memory _meta_ = abi.encodePacked(
            '{',
            '"name": "FurBot #', tokenId_.toString(), '",',
            '"description":"Automated market trading through NFTs. Earn monthly passive income by simply holding. NFTs increase in value monthly as the trading pools they are connected to compounds their monthly interest.",',
            '"image": "', _generationImageUri[_tokenGenerationId[tokenId_]], '",',
            '"attributes": [',
            abi.encodePacked(
                '{"trait_type":"Generation","value":"', _generationIdTracker.toString(), '"},',
                '{"trait_type":"Investment","value":"', _tokenInvestment[tokenId_].toString(), '"},',
                '{"trait_type":"Dividends Available","value":"', availableDividendsByToken(tokenId_).toString(), '"},',
                '{"trait_type":"Dividends Claimed","value":"', _tokenDividendsClaimed[tokenId_].toString(), '"}'
            ),
            ']',
            '}'
        );
        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(_meta_)
            )
        );
    }

    /**
     * Get block time.
     * @return uint256 The current block time.
     */
    function getBlockTime() external view returns(uint256)
    {
        return block.timestamp;
    }

    /**
     * Get active sale.
     * @return uint256 The sale ID.
     */
    function getActiveSale() public view returns(uint256)
    {
        for(uint256 i = 1; i <= _saleIdTracker; i++) {
            if(_saleStart[i] <= block.timestamp && _saleEnd[i] >= block.timestamp) return i;
        }
        return 0;
    }

    /**
     * Get next sale.
     * @return uint256 The sale ID.
     */
    function getNextSale() public view returns(uint256)
    {
        for(uint256 i = 1; i <= _saleIdTracker; i++) {
            if(_saleStart[i] > block.timestamp) return i;
        }
        return 0;
    }

    /**
     * Get active sale price.
     * @return uint256 The price.
     */
    function getActiveSalePrice() external view returns(uint256)
    {
        return _salePrice[getActiveSale()];
    }

    /**
     * Get next sale price.
     * @return uint256 The price.
     */
    function getNextSalePrice() external view returns(uint256)
    {
        return _salePrice[getNextSale()];
    }

    /**
     * Get active sale restricted.
     * @return bool The restricted status.
     */
    function getActiveSaleRestricted() external view returns(bool)
    {
        return _saleRestricted[getActiveSale()];
    }

    /**
     * Get next sale restricted.
     * @return bool The restricted status.
     */
    function getNextSaleRestricted() external view returns(bool)
    {
        return _saleRestricted[getNextSale()];
    }

    /**
     * Get active sale start.
     * @return uint256 The start timestamp.
     */
    function getActiveSaleStart() external view returns(uint256)
    {
        return _saleStart[getActiveSale()];
    }

    /**
     * Get next sale start.
     * @return uint256 The start time.
     */
    function getNextSaleStart() external view returns(uint256)
    {
        return _saleStart[getNextSale()];
    }

    /**
     * Get active sale end.
     * @return uint256 The end timestamp.
     */
    function getActiveSaleEnd() external view returns(uint256)
    {
        return _saleEnd[getActiveSale()];
    }

    /**
     * Get next sale end.
     * @return uint256 The end timestamp.
     */
    function getNextSaleEnd() external view returns(uint256)
    {
        return _saleEnd[getNextSale()];
    }

    /**
     * Buy.
     * @param amount_ The amount of tokens to buy.
     */
    function buy(uint256 amount_) external whenNotPaused
    {
        uint256 _saleId_ = getActiveSale();
        require(_saleId_ > 0, "No active sale.");
        if(_saleRestricted[_saleId_]) require(_vault.rewardRate(msg.sender) == 250, "Not eligible for sale.");
        uint256 _generationId_ = _saleGenerationId[_saleId_];
        require(_generationTotalSupply[_generationId_] + amount_ <= _generationMaxSupply[_generationId_], "Max supply reached.");
        uint256 _investmentAmount_ = _salePrice[_saleId_] * amount_;
        require(_paymentToken.transferFrom(msg.sender, addressBook.get("safe"), _investmentAmount_), "Payment failed.");
        for(uint256 i = 1; i <= amount_; i++) {
            _tokenIdTracker++;
            totalSupply++;
            _generationTotalSupply[_generationId_]++;
            totalInvestment += _salePrice[_saleId_];
            _generationInvestment[_generationId_] += _salePrice[_saleId_];
            _tokenGenerationId[_tokenIdTracker] = _generationId_;
            _tokenInvestment[_tokenIdTracker] = _salePrice[_saleId_];
            _mint(msg.sender, _tokenIdTracker);
            emit TokenPurchased(_tokenIdTracker);
        }
    }

    /**
     * Available dividends by owner.
     * @param owner_ The owner address.
     * @return uint256 The available dividends.
     */
    function availableDividendsByAddress(address owner_) external view returns(uint256)
    {
        uint256 _dividends_;
        for(uint256 i = 1; i <= totalSupply; i++) {
            if(ownerOf(i) == owner_) _dividends_ += availableDividendsByToken(i);
        }
        return _dividends_;
    }

    /**
     * Available dividends by token.
     * @param tokenId_ The token ID.
     * @return uint256 The available dividends.
     */
    function availableDividendsByToken(uint256 tokenId_) public view returns(uint256)
    {
        require(_tokenGenerationId[tokenId_] > 0, "Invalid token ID.");
        return (_generationDividends[_tokenGenerationId[tokenId_]] / _generationTotalSupply[_tokenGenerationId[tokenId_]]) - _tokenDividendsClaimed[tokenId_];
    }

    /**
     * Claim dividends.
     */
    function claimDividends() external whenNotPaused
    {
        require(balanceOf(msg.sender) > 0, "No tokens owned.");
        uint256 _dividends_;
        uint256 _totalDividends_;
        for(uint256 i = 1; i <= totalSupply; i++) {
            if(ownerOf(i) == msg.sender) {
                _dividends_ = availableDividendsByToken(i);
                _totalDividends_ += _dividends_;
                _tokenDividendsClaimed[i] += _dividends_;
            }
        }
        require(_paymentToken.transfer(msg.sender, _totalDividends_), "Transfer failed.");
        emit DividendsClaimed(msg.sender, _totalDividends_);
    }

    /**
     * Approve.
     * @param to_ The address to approve.
     * @param tokenId_ The token ID.
     * @dev Overridden to prevent token sales through third party marketplaces.
     */
    function approve(address to_, uint256 tokenId_) public virtual override whenNotPaused
    {
        require(to_ == _furmarket, "Third party marketplaces not allowed.");
        super.approve(to_, tokenId_);
    }

    /**
     * Set approval for all.
     * @param operator_ The operator address.
     * @param approved_ The approval status.
     * @dev Overridden to prevent token sales through third party marketplaces.
     */
    function setApprovalForAll(address operator_, bool approved_) public virtual override whenNotPaused
    {
        require(operator_ == _furmarket, "Third party marketplaces not allowed.");
        super.setApprovalForAll(operator_, approved_);
    }

    /**
     * -------------------------------------------------------------------------
     * ADMIN FUNCTIONS.
     * -------------------------------------------------------------------------
     */

    /**
     * Create generation.
     * @param maxSupply_ The maximum supply of this generation.
     * @param imageUri_ The image URI for this generation.
     */
    function createGeneration(uint256 maxSupply_, string memory imageUri_) external onlyOwner
    {
        _generationIdTracker++;
        _generationMaxSupply[_generationIdTracker] = maxSupply_;
        _generationImageUri[_generationIdTracker] = imageUri_;
        emit GenerationCreated(_generationIdTracker);
    }

    /**
     * Create sale.
     * @param generationId_ The generation ID for this sale.
     * @param price_ The price for this sale.
     * @param start_ The start time for this sale.
     * @param seconds_ The end time for this sale.
     * @param restricted_ Whether this sale is restricted to whitelisted addresses.
     */
    function createSale(uint256 generationId_, uint256 price_, uint256 start_, uint256 seconds_, bool restricted_) external onlyOwner
    {
        require(generationId_ > 0 && generationId_ <= _generationIdTracker, "Invalid generation ID.");
        if(start_ == 0) {
            if(_saleIdTracker == 0) start_ = block.timestamp;
            else start_ = _saleEnd[_saleIdTracker] + 1;
        }
        require(start_ >= block.timestamp, "Start time must be in the future.");
        if(_saleIdTracker > 0) require(start_ > _saleEnd[_saleIdTracker], "Start time must be after the previous sale.");
        if(seconds_ == 0) seconds_ = 3600;
        _saleIdTracker++;
        _saleGenerationId[_saleIdTracker] = generationId_;
        _salePrice[_saleIdTracker] = price_;
        _saleStart[_saleIdTracker] = start_;
        _saleEnd[_saleIdTracker] = start_ + seconds_;
        _saleRestricted[_saleIdTracker] = restricted_;
        emit SaleCreated(_saleIdTracker);
    }

    /**
     * Delete sale
     * @param saleId_ The sale ID.
     */
    function deleteSale(uint256 saleId_) external onlyOwner
    {
        delete _saleGenerationId[saleId_];
        delete _salePrice[saleId_];
        delete _saleStart[saleId_];
        delete _saleEnd[saleId_];
        delete _saleRestricted[saleId_];
    }

    /**
     * Add dividends.
     * @param generationId_ The generation ID for these dividends.
     * @param amount_ Amount of dividends to add.
     */
    function addDividends(uint256 generationId_, uint256 amount_) external
    {
        require(generationId_ > 0 && generationId_ <= _generationIdTracker, "Invalid generation ID.");
        require(_paymentToken.transferFrom(msg.sender, address(this), amount_), "Payment failed.");
        _generationDividends[generationId_] += amount_;
        totalDividends += amount_;
        emit DividendsAdded(generationId_, amount_);
    }

    /**
     * Update generation image.
     * @param generationId_ The generation ID.
     * @param imageUri_ The image URI.
     */
    function updateGenerationImage(uint256 generationId_, string memory imageUri_) external onlyOwner
    {
        require(generationId_ > 0 && generationId_ <= _generationIdTracker, "Invalid generation ID.");
        _generationImageUri[generationId_] = imageUri_;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./abstracts/BaseContract.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
// Interfaces.
import "./interfaces/IFurBetToken.sol";
import "./interfaces/IFurBetStake.sol";
import "./interfaces/IVault.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";

/**
 * @title FurbetPresale
 * @notice This is the presale contract for Furbet
 */

/// @custom:security-contact [email protected]
contract FurBetPresale is BaseContract
{
    /**
     * Contract initializer.
     * @dev This intializes all the parent contracts.
     */
    function initialize() initializer public
    {
        __BaseContract_init();
        _start = 1659463200; // Tue Aug 02 2022 18:00:00 GMT+0000
        _presaleOneTime = 10 minutes;
        _presaleTwoTime = 25 minutes;
        _presaleThreeTime = 2 days;
        _presaleFourTime = _presaleThreeTime + 15 minutes;
        _presaleFiveTime = _presaleThreeTime + 4 days;
        _presaleOnePrice = 50e16;
        _presaleTwoPrice = 50e16;
        _presaleThreePrice = 50e16;
        _presaleFourPrice = 75e16;
        _presaleFivePrice = 75e16;
        _presaleOneMaxForSale = 750000e18;
        _presaleTwoMaxForSale = 750000e18;
        _presaleThreeMaxForSale = 750000e18;
        _presaleFourMaxForSale = 1500000e18;
        _presaleFiveMaxForSale = 1500000e18;
        _presaleOneMinVaultBalance = 25e18;
        _presaleTwoMinVaultBalance = 25e18;
        _presaleThreeMinVaultBalance = 25e18;
        _presaleFourMinVaultBalance = 0;
        _presaleFiveMinVaultBalance = 0;
        _presaleOneMinRewardRate = 250;
        _presaleTwoMinRewardRate = 200;
        _presaleThreeMinRewardRate = 200;
        _presaleFourMinRewardRate = 0;
        _presaleFiveMinRewardRate = 0;
        _presaleOneMaxPerAddress = 500e18;
        _presaleTwoMaxPerAddress = 500e18;
        _presaleThreeMaxPerAddress = 0;
        _presaleFourMaxPerAddress = 2000e18;
        _presaleFiveMaxPerAddress = 0;
    }

    /**
     * Properties.
     */
    uint256 private _start; // Presale start time.
    uint256 private _sold; // Amount of tokens sold.
    uint256 private _presaleOneTime;
    uint256 private _presaleTwoTime;
    uint256 private _presaleThreeTime;
    uint256 private _presaleFourTime;
    uint256 private _presaleFiveTime;
    uint256 private _presaleOnePrice;
    uint256 private _presaleTwoPrice;
    uint256 private _presaleThreePrice;
    uint256 private _presaleFourPrice;
    uint256 private _presaleFivePrice;
    uint256 private _presaleOneMaxForSale;
    uint256 private _presaleTwoMaxForSale;
    uint256 private _presaleThreeMaxForSale;
    uint256 private _presaleFourMaxForSale;
    uint256 private _presaleFiveMaxForSale;
    uint256 private _presaleOneMinVaultBalance;
    uint256 private _presaleTwoMinVaultBalance;
    uint256 private _presaleThreeMinVaultBalance;
    uint256 private _presaleFourMinVaultBalance;
    uint256 private _presaleFiveMinVaultBalance;
    uint256 private _presaleOneMinRewardRate;
    uint256 private _presaleTwoMinRewardRate;
    uint256 private _presaleThreeMinRewardRate;
    uint256 private _presaleFourMinRewardRate;
    uint256 private _presaleFiveMinRewardRate;
    uint256 private _presaleOneMaxPerAddress;
    uint256 private _presaleTwoMaxPerAddress;
    uint256 private _presaleThreeMaxPerAddress;
    uint256 private _presaleFourMaxPerAddress;
    uint256 private _presaleFiveMaxPerAddress;

    /**
     * Mappings.
     */
    mapping(address => uint256) private _purchased; // Maps address to amount of tokens purchased.

    /**
     * Get start.
     * @return uint256 Start time.
     */
    function getStart() external view returns (uint256)
    {
        return _start;
    }

    /**
     * Get sold.
     * @return uint256 Total sold.
     */
    function getSold() external view returns (uint256)
    {
        return _sold;
    }

    /**
     * Get purchased.
     * @param participant_ Participant address.
     * @return uint256 Amount of tokens purchased.
     */
    function getPurchased(address participant_) external view returns (uint256)
    {
        return _purchased[participant_];
    }

    /**
     * Presale type.
     * @return uint256 - Type of presale (0 - 6).
     */
    function presaleType() public view returns (uint256)
    {
        if(block.timestamp < _start) return 0;
        if(block.timestamp < _start + _presaleOneTime) return 1;
        if(block.timestamp < _start + _presaleTwoTime) return 2;
        if(block.timestamp < _start + _presaleThreeTime) return 3;
        if(block.timestamp < _start + _presaleFourTime) return 4;
        if(block.timestamp < _start + _presaleFiveTime) return 5;
        return 6;
    }

    /**
     * Get price.
     * @param type_ Presale type.
     * @return uint256 Price per token.
     */
    function getPrice(uint256 type_) public view returns (uint256)
    {
        if(type_ == 1) return _presaleOnePrice;
        if(type_ == 2) return _presaleTwoPrice;
        if(type_ == 3) return _presaleThreePrice;
        if(type_ == 4) return _presaleFourPrice;
        if(type_ == 5) return _presaleFivePrice;
        return 0;
    }

    /**
     * Get max for sale.
     * @param type_ Presale type.
     * @return uint256 Max for sale.
     */
    function getMaxForSale(uint256 type_) public view returns (uint256)
    {
        if(type_ == 1) return _presaleOneMaxForSale;
        if(type_ == 2) return _presaleTwoMaxForSale;
        if(type_ == 3) return _presaleThreeMaxForSale;
        if(type_ == 4) return _presaleFourMaxForSale;
        if(type_ == 5) return _presaleFiveMaxForSale;
        return 0;
    }

    /**
     * Get min vault balance.
     * @param type_ Presale type.
     * @return uint256 Minimum vault balance.
     */
    function getMinVaultBalance(uint256 type_) public view returns (uint256)
    {
        if(type_ == 1) return _presaleOneMinVaultBalance;
        if(type_ == 2) return _presaleTwoMinVaultBalance;
        if(type_ == 3) return _presaleThreeMinVaultBalance;
        if(type_ == 4) return _presaleFourMinVaultBalance;
        if(type_ == 5) return _presaleFiveMinVaultBalance;
        return 0;
    }

    /**
     * Get min reward rate.
     * @param type_ Presale type.
     * @return uint256 Minimum reward rate.
     */
    function getMinRewardRate(uint256 type_) public view returns (uint256)
    {
        if(type_ == 1) return _presaleOneMinRewardRate;
        if(type_ == 2) return _presaleTwoMinRewardRate;
        if(type_ == 3) return _presaleThreeMinRewardRate;
        if(type_ == 4) return _presaleFourMinRewardRate;
        if(type_ == 5) return _presaleFiveMinRewardRate;
        return 0;
    }

    /**
     * Get max per address.
     * @param type_ Presale type.
     * @return uint256 Max per address.
     */
    function getMaxPerAddress(uint256 type_) public view returns (uint256)
    {
        if(type_ == 1) return _presaleOneMaxPerAddress;
        if(type_ == 2) return _presaleTwoMaxPerAddress;
        if(type_ == 3) return _presaleThreeMaxPerAddress;
        if(type_ == 4) return _presaleFourMaxPerAddress;
        if(type_ == 5) return _presaleFiveMaxPerAddress;
        return 0;
    }

    /**
     * Presale.
     * @param amount_ Amount of tokens to buy.
     */
    function presale(uint256 amount_) public whenNotPaused
    {
        uint256 _type_ = presaleType();
        require(_type_ > 0, "Presale has not started yet.");
        require(_type_ < 6, "Presale has ended.");
        uint256 _price_ = getPrice(_type_);
        uint256 _maxForSale_ = getMaxForSale(_type_);
        uint256 _minVaultBalance_ = getMinVaultBalance(_type_);
        uint256 _minRewardRate_ = getMinRewardRate(_type_);
        uint256 _maxPerAddress_ = getMaxPerAddress(_type_);
        require(_sold + amount_ <= _maxForSale_, "Presale is full.");
        if(_maxPerAddress_ > 0) {
            require(_purchased[msg.sender] + amount_ <= _maxPerAddress_, "You have reached the maximum amount of tokens you can purchase.");
        }
        if(_minVaultBalance_ > 0 || _minRewardRate_ > 0) {
            IVault _vault_ = IVault(addressBook.get("vault"));
            if(_minVaultBalance_ > 0) {
                require(_vault_.participantBalance(msg.sender) >= _minVaultBalance_, "You do not have enough tokens in the vault.");
            }
            if(_minRewardRate_ > 0) {
                require(_vault_.rewardRate(msg.sender) >= _minRewardRate_, "You do not have the correct reward rate.");
            }
        }
        IERC20 _payment_ = IERC20(addressBook.get("payment"));
        require(_payment_.transferFrom(msg.sender, addressBook.get("safe"), _price_ * (amount_ / (10 ** 18))), "Unable to transfer tokens.");
        _sold += amount_;
        _purchased[msg.sender] += amount_;
        IFurBetToken _token_ = IFurBetToken(addressBook.get("furbettoken"));
        IFurBetStake _stake_ = IFurBetStake(addressBook.get("furbetstake"));
        _token_.mint(address(this), amount_);
        _token_.approve(address(_stake_), amount_ / 4);
        _stake_.stakeFor(msg.sender, 1, amount_ / 4);
        _token_.approve(address(_stake_), amount_ / 4);
        _stake_.stakeFor(msg.sender, 2, amount_ / 4);
        _token_.approve(address(_stake_), amount_ / 4);
        _stake_.stakeFor(msg.sender, 3, amount_ / 4);
        _token_.approve(address(_stake_), amount_ / 4);
        _stake_.stakeFor(msg.sender, 4, amount_ / 4);
    }

    /**
     * Set start.
     * @param start_ New start time.
     */
    function setStart(uint256 start_) external onlyOwner
    {
        _start = start_;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./abstracts/BaseContract.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
// Interfaces.
import "./interfaces/IFurBetToken.sol";
import "./interfaces/IVault.sol";

/**
 * @title FurbetStake
 * @notice This is the staking contract for Furbet
 */

/// @custom:security-contact [email protected]
contract FurBetMaxStake is BaseContract, ERC721Upgradeable
{
    /**
     * Contract initializer.
     * @dev This intializes all the parent contracts.
     */
    function initialize() initializer public
    {
        __BaseContract_init();
        __ERC721_init("FurBetMaxStake", "$FURBMS");
    }

    using Strings for uint256;

    /**
     * Properties.
     */
    uint256 private _tokenIdTracker; // Keeps track of staking tokens.
    uint256 public totalSupply; // Total supply of staking tokens.
    uint256 public totalStaked; // Total amount of staked tokens.
    uint256 public totalDividends; // Total dividends paid out.
    uint256 public totalDividendsClaimed; // Total dividends claimed.
    uint256 public lastDistribution; // Last time dividends were distributed.
    uint256 public stakingPeriod; // The staking period.

    /**
     * Mappings.
     */
    mapping (uint256 => uint256) public tokenEntryDate; // The date the token was staked.
    mapping (uint256 => uint256) public tokenExitDate; // The date the token can be unstaked.
    mapping (uint256 => uint256) public tokenStakeValue; // Value of the stake.
    mapping (uint256 => uint256) public tokenDividendsClaimed; // The amount of dividends claimed.

    /**
     * External contracts.
     */
    IFurBetToken public furBetToken;
    address public furMaxAddress;
    IVault public vault;

    /**
     * Setup.
     */
    function setup() external
    {
        stakingPeriod = 90 days;
        furBetToken = IFurBetToken(addressBook.get("furbettoken"));
        furMaxAddress = addressBook.get("furmax");
        vault = IVault(addressBook.get("vault"));
    }

    /**
     * Stake.
     * @param participant_ Participant address.
     * @param amount_ Staking amount.
     */
    function stake(address participant_, uint256 amount_) external
    {
        require(vault.participantMaxed(participant_), "Participant is not maxed");
        require(furBetToken.transferFrom(msg.sender, address(this), amount_), "Failed to transfer tokens");
        uint256 _balance_ = balanceOf(participant_);
        if(_balance_ == 0) {
            _tokenIdTracker ++;
            _mint(participant_, _tokenIdTracker);
            tokenEntryDate[_tokenIdTracker] = block.timestamp;
            totalSupply ++;
            _balance_ = 1;
        }
        uint256 _valuePerNft_ = amount_ / _balance_;
        for(uint256 i = 1; i <= _tokenIdTracker; i++) {
            if(ownerOf(i) == participant_) {
                tokenStakeValue[i] += _valuePerNft_;
                tokenExitDate[i] = block.timestamp + stakingPeriod;
                totalStaked += _valuePerNft_;
            }
        }
    }

    /**
     * Staked.
     * @param participant_ Participant address.
     * @return uint256 Amount staked.
     */
    function staked(address participant_) external view returns (uint256)
    {
        uint256 _staked_ = 0;
        for(uint256 i = 1; i <= _tokenIdTracker; i ++) {
            if(super.ownerOf(i) == participant_) {
                _staked_ += tokenStakeValue[i];
            }
        }
        return _staked_;
    }

    /**
     * Disable transfers for now.
     * @param from From address.
     * @param to To address.
     * @param tokenId Token id.
     */
    function _transfer(address from, address to, uint256 tokenId) internal pure override {
        require(true == false, "Transfers are disabled");
    }

    /**
     * Token URI.
     * @param tokenId_ The token ID.
     * @return string The metadata json.
     */
    function tokenURI(uint256 tokenId_) public view override returns(string memory)
    {
        require(tokenId_ > 0 && tokenId_ <= _tokenIdTracker, "Invalid token ID");
        bytes memory _meta_ = abi.encodePacked(
            '{',
            '"name": "FurBetMax #', tokenId_.toString(), '",',
            '"description":"FurBetMax NFT",',
            '"attributes": [',
            abi.encodePacked(
                '{"trait_type":"Entry Date", "value":"', tokenEntryDate[tokenId_].toString(), '"},',
                '{"trait_type":"Exit Date","value":"', tokenExitDate[tokenId_].toString(), '"},',
                '{"trait_type":"Staked","value":"', tokenStakeValue[tokenId_].toString(), '"},',
                '{"trait_type":"Dividends Claimed","value":"', tokenDividendsClaimed[tokenId_].toString(), '"}'
            ),
            ']',
            '}'
        );
        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(_meta_)
            )
        );
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./abstracts/BaseContract.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
// Interfaces.
import "./interfaces/IToken.sol";

/**
 * @title Furio Downline NFT
 * @author Steve Harmeyer
 * @notice This is the ERC721 contract for $FURDOWNLINE.
 */

/// @custom:security-contact [email protected]
contract DownlineV2 is BaseContract, ERC721Upgradeable
{
    /**
     * Contract initializer.
     * @dev This intializes all the parent contracts.
     */
    function initialize() initializer public
    {
        __ERC721_init("Furio Downline NFT", "$FURDL");
        __BaseContract_init();
        _properties.buyPrice = 5e18; // 5 $FUR.
        _properties.sellPrice = 4e18; // 4 $FUR.
        _properties.maxPerUser = 15; // 15 NFTs max per user.
        createGeneration(10000, 'ipfs://QmPmvwSarTWNBYAcXhbGUCUUkGsiD7hXx8qpk49YwCAGcU/');
    }

    using Counters for Counters.Counter;

    /**
     * Properties.
     */
    struct Properties {
        uint256 buyPrice;
        uint256 sellPrice;
        uint256 maxPerUser;
    }
    Properties private _properties;

    /**
     * Generation struct.
     * @dev Data structure for generation info.
     * this allows us to increase the supply with new art and description.
     */
    struct Generation {
        uint256 maxSupply;
        string baseUri;
    }

    /**
     * Generation tracker.
     * @dev Keeps track of how many generations exist.
     */
    Counters.Counter private _generationTracker;

    /**
     * Mapping to store generation info.
     */
    mapping(uint256 => Generation) private _generations;

    /**
     * Mapping to store token generations.
     */
    mapping(uint256 => uint256) private _tokenGenerations;

    /**
     * Token id tracker.
     * @dev Keeps track of the current token id.
     */
    Counters.Counter private _tokenIdTracker;

    /**
     * Freeze URI event.
     * @dev Tells opensea that the metadata is frozen.
     */
    event PermanentURI(string value_, uint256 indexed id_);

    /**
     * Total supply.
     * @return uint256
     * @notice returns the total amount of NFTs created.
     */
    function totalSupply() public view returns (uint256)
    {
        return _tokenIdTracker.current();
    }

    /**
     * Max supply.
     * @return uint256
     * @notice Returns the sum of the max supply for all generations.
     */
    function maxSupply() public view returns (uint256)
    {
        uint256 _maxSupply;
        for(uint256 i = 1; i <= _generationTracker.current(); i++) {
            _maxSupply += _generations[i].maxSupply;
        }
        return _maxSupply;
    }

    /**
     * Buy an NFT.
     * @notice Allows a user to buy an NFT.
     */
    function buy(uint256 quantity_) external whenNotPaused returns (bool)
    {
        IToken _token_ = IToken(addressBook.get("token"));
        require(address(_token_) != address(0), "Token not set");
        require(balanceOf(msg.sender) + quantity_ <= _properties.maxPerUser, "Address already owns max");
        require(totalSupply() + quantity_ < maxSupply(), "Sold out");
        require(_token_.transferFrom(msg.sender, address(this), _properties.buyPrice * quantity_), "Payment failed");
        require(_token_.transfer(addressBook.get("vault"), _properties.buyPrice - _properties.sellPrice), "Transfer to vault failed");
        for(uint256 i = 0; i < quantity_; i ++) {
            _tokenIdTracker.increment();
            uint256 _id_ = _tokenIdTracker.current();
            _mint(msg.sender, _id_);
            emit PermanentURI(tokenURI(_id_), _id_);
        }
        return true;
    }

    /**
     * Sell an NFT.
     * @param quantity_ Quantity to sell.
     * @return bool True if successful.
     */
    function sell(uint256 quantity_) external whenNotPaused returns (bool)
    {
        IToken _token_ = IToken(addressBook.get("token"));
        require(address(_token_) != address(0), "Token not set");
        require(balanceOf(msg.sender) >= quantity_, "Quantity is too high");
        uint256 _refund_ = 0;
        uint256[] memory _tokens_ = new uint256[](quantity_);
        for(uint256 i = 0; i < quantity_; i ++) {
            _refund_ += _properties.sellPrice;
            _tokens_[i] = tokenOfOwnerByIndex(msg.sender, i);
        }
        for(uint256 i = 0; i < _tokens_.length; i ++) {
            super._burn(_tokens_[i]);
        }
        uint256 _balance_ = _token_.balanceOf(address(this));
        if(_balance_ < _refund_) {
            _token_.mint(address(this), _refund_ - _balance_);
        }
        require(_token_.transfer(msg.sender, _refund_), "Payment failed");
        return true;
    }

    /**
     * Mint an NFT.
     * @param to_ The address receiving the NFT.
     * @param quantity_ The number of NFTs to mint.
     * @notice This function is used to mint presale NFTs for team addresses.
     */
    function mint(address to_, uint256 quantity_) external onlyOwner
    {
        require(balanceOf(to_) + quantity_ <= _properties.maxPerUser, "Address already owns max");
        require(totalSupply() + quantity_ < maxSupply(), "Sold out");
        for(uint256 i = 0; i < quantity_; i ++) {
            _tokenIdTracker.increment();
            uint256 _id_ = _tokenIdTracker.current();
            _mint(to_, _id_);
            emit PermanentURI(tokenURI(_id_), _id_);
        }
    }

    function _mint(address to_, uint256 tokenId_) internal override
    {
        require(!_exists(tokenId_), "Token already exists");
        super._mint(to_, tokenId_);
        _tokenGenerations[tokenId_] = _generationTracker.current();
    }


    /**
     * Find which tokens a user owns.
     * @param owner_ Address of NFT owner.
     * @param index_ The index of the token looking for. Hint: all are 0.
     * @notice This function returns the token id owned by address_.
     * @dev This function is simplified since each address can only own
     * one NFT. No need to do complex enumeration.
     */
    function tokenOfOwnerByIndex(address owner_, uint256 index_) public view returns(uint256) {
        uint256 count = 0;
        for(uint256 i = 1; i <= _tokenIdTracker.current(); i++) {
            if(!_exists(i)) {
                continue;
            }
            if(ownerOf(i) == owner_) {
                if(count == index_) {
                    return i;
                }
                count++;
            }
        }
        return 0;
    }

    /**
     * Token URI.
     * @param tokenId_ The id of the token.
     * @notice This returns base64 encoded json for the token metadata. Allows us
     * to avoid putting metadata on IPFS.
     */
    function tokenURI(uint256 tokenId_) public view override returns (string memory) {
        require(_exists(tokenId_), "Token does not exist");
        return string(abi.encodePacked(_generations[_tokenGenerations[tokenId_]].baseUri, Strings.toString(tokenId_)));
    }

    /**
     * -------------------------------------------------------------------------
     * OWNER FUNCTIONS
     * -------------------------------------------------------------------------
     */

    /**
     * Create a generation.
     * @param maxSupply_ The maximum NFT supply for this generation.
     * @param baseUri_ The metadata base URI for this generation.
     * @notice This method creates a new NFT generation.
     */
    function createGeneration(
        uint256 maxSupply_,
        string memory baseUri_
    ) public onlyOwner
    {
        _generationTracker.increment();
        _generations[_generationTracker.current()].maxSupply = maxSupply_;
        _generations[_generationTracker.current()].baseUri = baseUri_;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[45] private __gap;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./abstracts/BaseContract.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
// Interfaces.
import "./interfaces/IToken.sol";

/**
 * @title Furio Downline NFT
 * @author Steve Harmeyer
 * @notice This is the ERC721 contract for $FURDOWNLINE.
 */

/// @custom:security-contact [email protected]
contract Downline is BaseContract, ERC721Upgradeable
{
    /**
     * Contract initializer.
     * @dev This intializes all the parent contracts.
     */
    function initialize() initializer public
    {
        __ERC721_init("Furio Downline NFT", "$FURDL");
        __BaseContract_init();
        _properties.buyPrice = 5e18; // 5 $FUR.
        _properties.sellPrice = 4e18; // 4 $FUR.
        _properties.maxPerUser = 15; // 15 NFTs max per user.
        createGeneration(10000, 'ipfs://QmPmvwSarTWNBYAcXhbGUCUUkGsiD7hXx8qpk49YwCAGcU/');
    }

    using Counters for Counters.Counter;

    /**
     * Properties.
     */
    struct Properties {
        uint256 buyPrice;
        uint256 sellPrice;
        uint256 maxPerUser;
    }
    Properties private _properties;

    /**
     * Generation struct.
     * @dev Data structure for generation info.
     * this allows us to increase the supply with new art and description.
     */
    struct Generation {
        uint256 maxSupply;
        string baseUri;
    }

    /**
     * Generation tracker.
     * @dev Keeps track of how many generations exist.
     */
    Counters.Counter private _generationTracker;

    /**
     * Mapping to store generation info.
     */
    mapping(uint256 => Generation) private _generations;

    /**
     * Mapping to store token generations.
     */
    mapping(uint256 => uint256) private _tokenGenerations;

    /**
     * Token id tracker.
     * @dev Keeps track of the current token id.
     */
    Counters.Counter private _tokenIdTracker;

    /**
     * Freeze URI event.
     * @dev Tells opensea that the metadata is frozen.
     */
    event PermanentURI(string value_, uint256 indexed id_);

    /**
     * Total supply.
     * @return uint256
     * @notice returns the total amount of NFTs created.
     */
    function totalSupply() public view returns (uint256)
    {
        return _tokenIdTracker.current();
    }

    /**
     * Max supply.
     * @return uint256
     * @notice Returns the sum of the max supply for all generations.
     */
    function maxSupply() public view returns (uint256)
    {
        uint256 _maxSupply;
        for(uint256 i = 1; i <= _generationTracker.current(); i++) {
            _maxSupply += _generations[i].maxSupply;
        }
        return _maxSupply;
    }

    /**
     * Buy an NFT.
     * @notice Allows a user to buy an NFT.
     */
    function buy(uint256 quantity_) external whenNotPaused returns (bool)
    {
        IToken _token_ = IToken(addressBook.get("token"));
        require(address(_token_) != address(0), "Token not set");
        require(balanceOf(msg.sender) + quantity_ <= _properties.maxPerUser, "Address already owns max");
        require(totalSupply() + quantity_ < maxSupply(), "Sold out");
        require(_token_.transferFrom(msg.sender, address(this), _properties.buyPrice), "Payment failed");
        require(_token_.transfer(addressBook.get("vault"), _properties.buyPrice - _properties.sellPrice), "Transfer to vault failed");
        for(uint256 i = 0; i < quantity_; i ++) {
            _tokenIdTracker.increment();
            uint256 _id_ = _tokenIdTracker.current();
            _mint(msg.sender, _id_);
            emit PermanentURI(tokenURI(_id_), _id_);
        }
        return true;
    }

    /**
     * Sell an NFT.
     * @param quantity_ Quantity to sell.
     * @return bool True if successful.
     */
    function sell(uint256 quantity_) external whenNotPaused returns (bool)
    {
        IToken _token_ = IToken(addressBook.get("token"));
        require(address(_token_) != address(0), "Token not set");
        require(balanceOf(msg.sender) >= quantity_, "Quantity is too high");
        uint256 _refund_ = 0;
        uint256[] memory _tokens_ = new uint256[](quantity_);
        for(uint256 i = 0; i < quantity_; i ++) {
            _refund_ += _properties.sellPrice;
            _tokens_[i] = tokenOfOwnerByIndex(msg.sender, i);
        }
        for(uint256 i = 0; i < _tokens_.length; i ++) {
            super._burn(_tokens_[i]);
        }
        uint256 _balance_ = _token_.balanceOf(address(this));
        if(_balance_ < _refund_) {
            _token_.mint(address(this), _refund_ - _balance_);
        }
        require(_token_.transfer(msg.sender, _refund_), "Payment failed");
        return true;
    }

    /**
     * Mint an NFT.
     * @param to_ The address receiving the NFT.
     * @param quantity_ The number of NFTs to mint.
     * @notice This function is used to mint presale NFTs for team addresses.
     */
    function mint(address to_, uint256 quantity_) external onlyOwner
    {
        require(balanceOf(to_) + quantity_ <= _properties.maxPerUser, "Address already owns max");
        require(totalSupply() + quantity_ < maxSupply(), "Sold out");
        for(uint256 i = 0; i < quantity_; i ++) {
            _tokenIdTracker.increment();
            uint256 _id_ = _tokenIdTracker.current();
            _mint(to_, _id_);
            emit PermanentURI(tokenURI(_id_), _id_);
        }
    }

    function _mint(address to_, uint256 tokenId_) internal override
    {
        require(!_exists(tokenId_), "Token already exists");
        super._mint(to_, tokenId_);
        _tokenGenerations[tokenId_] = _generationTracker.current();
    }


    /**
     * Find which tokens a user owns.
     * @param owner_ Address of NFT owner.
     * @param index_ The index of the token looking for. Hint: all are 0.
     * @notice This function returns the token id owned by address_.
     * @dev This function is simplified since each address can only own
     * one NFT. No need to do complex enumeration.
     */
    function tokenOfOwnerByIndex(address owner_, uint256 index_) public view returns(uint256) {
        uint256 count = 0;
        for(uint256 i = 1; i <= _tokenIdTracker.current(); i++) {
            if(!_exists(i)) {
                continue;
            }
            if(ownerOf(i) == owner_) {
                if(count == index_) {
                    return i;
                }
                count++;
            }
        }
        return 0;
    }

    /**
     * Token URI.
     * @param tokenId_ The id of the token.
     * @notice This returns base64 encoded json for the token metadata. Allows us
     * to avoid putting metadata on IPFS.
     */
    function tokenURI(uint256 tokenId_) public view override returns (string memory) {
        require(_exists(tokenId_), "Token does not exist");
        return string(abi.encodePacked(_generations[_tokenGenerations[tokenId_]].baseUri, Strings.toString(tokenId_)));
    }

    /**
     * -------------------------------------------------------------------------
     * OWNER FUNCTIONS
     * -------------------------------------------------------------------------
     */

    /**
     * Create a generation.
     * @param maxSupply_ The maximum NFT supply for this generation.
     * @param baseUri_ The metadata base URI for this generation.
     * @notice This method creates a new NFT generation.
     */
    function createGeneration(
        uint256 maxSupply_,
        string memory baseUri_
    ) public onlyOwner
    {
        _generationTracker.increment();
        _generations[_generationTracker.current()].maxSupply = maxSupply_;
        _generations[_generationTracker.current()].baseUri = baseUri_;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[45] private __gap;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IResolver {
    function checker(uint256 checker_) external view returns (bool canExec, bytes memory execPayload);
}

import "./abstracts/BaseContract.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
// INTERFACES
import "./interfaces/IVault.sol";

/**
 * @title AutoCompound
 * @author Steve Harmeyer
 * @notice This is the auto compound contract.
 */

/// @custom:security-contact [email protected]
contract AutoCompoundV3 is BaseContract, IResolver
{
    /**
     * Contract initializer.
     * @dev This intializes all the parent contracts.
     */
    function initialize() initializer public
    {
        __BaseContract_init();
        _properties.maxPeriods = 7;
        _properties.period = 86400; // PRODUCTION period is 24 hours.
        _properties.fee = 2000000000000000; // .002 BNB per period.
        _properties.maxParticipants = 100;
    }

    using Counters for Counters.Counter;

    /**
     * Id tracker.
     * @dev Keeps track of the current id.
     */
    Counters.Counter private _idTracker;

    /**
     * Properties.
     */
    struct Properties {
        uint256 maxPeriods; // Maximum number of periods a participant can auto compound.
        uint256 period; // Seconds between compounds.
        uint256 fee; // BNB fee per period of auto compounding.
        uint256 maxParticipants; // Maximum autocompound participants.
    }
    Properties private _properties;

    /**
     * Stats.
     */
    struct Stats {
        uint256 compounding; // Number of participants auto compounding.
        uint256 compounds; // Number of auto compounds performed.
    }
    Stats private _stats;

    /**
     * Auto compound mappings.
     */
    mapping(uint256 => uint256) private _compoundsLeft;
    mapping(uint256 => uint256) private _lastCompound;
    mapping(uint256 => uint256) private _totalCompounds;
    mapping(uint256 => uint256[]) private _compounds;
    mapping(uint256 => address) private _addresses;
    mapping(address => uint256) private _ids;
    mapping(uint256 => bool) private _compounding;

    uint256 private _checkers;

    /**
     * Checker.
     * @param checker_ The checker number.
     */
    function checker(uint256 checker_) external view override returns (bool canExec, bytes memory execPayload)
    {
        require(checker_ < _checkers, "Invalid checker.");
        uint256 _next_ = _next(checker_);
        if (_next_ == 0) return (false, bytes("No participants are due for an auto compound"));
        return(true, abi.encodeWithSelector(this.compound.selector, _next_));
    }

    /**
     * Set checkers.
     * @param checkers_ The number of checkers.
     */
    function setCheckers(uint256 checkers_) external onlyOwner
    {
        _checkers = checkers_;
    }

    /**
     * Get properties.
     * @return Properties Contract properties.
     */
    function properties() external view returns (Properties memory)
    {
        return _properties;
    }

    /**
     * Get stats.
     * @return Stats Contract stats.
     */
    function stats() external view returns (Stats memory)
    {
        return _stats;
    }

    /**
     * Get id.
     * @param participant_ Participant address.
     * @return uint256 Participant id.
     */
    function getId(address participant_) external view returns (uint256)
    {
        return _ids[participant_];
    }

    /**
     * Get address.
     * @param id_ Participant id.
     * @return address Participant address.
     */
    function getAddress(uint256 id_) external view returns (address)
    {
        return _addresses[id_];
    }

    /**
     * Compounding.
     * @param participant_ Participant address.
     * @return bool True if they're auto compounding.
     */
    function compounding(address participant_) external view returns (bool)
    {
        return _compounding[_ids[participant_]];
    }

    /**
     * Get compounds left.
     * @param participant_ Participant address.
     * @return uint256 Number of compounds remaining.
     */
    function compoundsLeft(address participant_) external view returns (uint256)
    {
        return _compoundsLeft[_ids[participant_]];
    }

    /**
     * Get last compound.
     * @param participant_ Participant address.
     * @return uint256 Timestamp of last compound.
     */
    function lastCompound(address participant_) external view returns (uint256)
    {
        return _lastCompound[_ids[participant_]];
    }

    /**
     * Get total compounds.
     * @param participant_ Participant address.
     * @return uint256 Total number of auto compounds.
     */
    function totalCompounds(address participant_) external view returns (uint256)
    {
        return _totalCompounds[_ids[participant_]];
    }

    /**
     * Next up.
     * @return address Next address to be compounded.
     * @dev Returns the next address in line that needs to be compounded.
     */
    function next() public view returns (address)
    {
        for(uint256 i = 0; i < _checkers; i++) {
            uint256 _next_ = _next(i);
            if (_next_ != 0) return _addresses[_next_];
        }
        return address(0);
    }

    /**
     * Internal next.
     * @param checker_ Chceker number.
     * @return uint256 Id of next participant.
     */
    function _next(uint256 checker_) internal view returns (uint256)
    {
        uint256 _dueDate_ = block.timestamp - _properties.period;
        for(uint256 i = 1; i <= _idTracker.current(); i ++) {
            if(!_compounding[i]) continue; // Skip if they're not compounding.
            if(_lastCompound[i] >= _dueDate_) continue; // Skip if their last compound was too soon.
            if(i % _checkers != checker_) continue; // Skip if it's not their turn.
            return i; // Return first id that is ready to compound.
        }
        return 0;
    }

    /**
     * Due for compound.
     * @return uint256 Number of addresses that are due for compounding.
     */
    function due() public view returns (uint256)
    {
        uint256 _dueCount_ = 0;
        uint256 _dueDate_ = block.timestamp - _properties.period;
        for(uint256 i = 1; i <= _idTracker.current(); i ++) {
            if(!_compounding[i]) continue;
            if(_lastCompound[i] < _dueDate_) _dueCount_ ++;
        }
        return _dueCount_;
    }

    /**
     * Compound next up.
     * @param id_ Id of next participant.
     * @dev Auto compounds next participant.
     */
    function compound(uint256 id_) public whenNotPaused
    {
        _compound(id_);
    }

    /**
     * Internal compound.
     * @dev Auto compounds participant.
     * @param id_ Id of participant.
     */
    function _compound(uint256 id_) internal
    {
        _lastCompound[id_] = block.timestamp;
        _compoundsLeft[id_] --;
        _totalCompounds[id_] ++;
        _stats.compounds ++;
        if(_compoundsLeft[id_] == 0) {
            _end(id_);
        }
        IVault _vault_ = IVault(addressBook.get("vault"));
        address(_vault_).call(abi.encodePacked(_vault_.autoCompound.selector, abi.encode(_addresses[id_])));
    }

    /**
     * Start auto compound.
     * @param periods_ Number of periods to auto compound.
     */
    function start(uint256 periods_) external payable whenNotPaused
    {
        require(msg.value >= periods_ * _properties.fee, "Insufficient message value");
        _start(msg.sender, periods_);
    }

    /**
     * Internal start.
     * @param participant_ Participant address.
     * @param periods_ Number of periods to auto compound.
     */
    function _start(address participant_, uint256 periods_) internal
    {
        require(periods_ > 0 && periods_ <= _properties.maxPeriods, "Invalid periods");
        uint256 _id_ = _ids[participant_];
        if(_id_ == 0) {
            _idTracker.increment();
            _id_ = _idTracker.current();
            _addresses[_id_] = participant_;
            _ids[participant_] = _id_;
        }
        require(_compoundsLeft[_id_] == 0, "Participant is already auto compounding");
        require(_stats.compounding < _properties.maxParticipants, "Maximum participants reached");
        _compoundsLeft[_id_] = periods_;
        _lastCompound[_id_] = block.timestamp - _properties.period;
        _compounding[_id_] = true;
        _stats.compounding ++;
    }

    /**
     * End auto compound.
     */
    function end() external whenNotPaused
    {
        _end(_ids[msg.sender]);
    }

    /**
     * Internal end auto compound.
     * @param id_ Participant id.
     */
    function _end(uint256 id_) internal
    {
        if(id_ == 0) return;
        _stats.compounding --;
        delete _compoundsLeft[id_];
        delete _lastCompound[id_];
        delete _totalCompounds[id_];
        delete _compounding[id_];
    }

    /**
     * Get vault.
     * @return IVault Vault contract.
     */
    function _getVault() internal view returns (IVault)
    {
        return IVault(addressBook.get("vault"));
    }

    /**
     * Withdraw.
     */
    function withdraw() external onlyOwner
    {
        payable(msg.sender).transfer(address(this).balance);
    }

    /**
     * Set max participants.
     * @param max_ Max participants.
     */
    function setMaxParticipants(uint256 max_) external onlyOwner
    {
        _properties.maxParticipants = max_;
    }

    /**
     * Set fee.
     * @param fee_ New fee.
     */
    function setFee(uint256 fee_) external onlyOwner
    {
        _properties.fee = fee_;
    }

    /**
     * Set max periods.
     * @param max_ Max periods.
     */
    function setMaxPeriods(uint256 max_) external onlyOwner
    {
        _properties.maxPeriods = max_;
    }

    /**
     * Add periods.
     * @param participant_ Participant address.
     * @param periods_ Number of periods to add.
     */
    function addPeriods(address participant_, uint256 periods_) external onlyOwner
    {
        uint256 _id_ = _ids[participant_];
        if(_id_ == 0) return _start(participant_, periods_);
        require(_compoundsLeft[_id_] + periods_ <= _properties.maxPeriods, "Invalid periods");
        _compoundsLeft[_id_] += periods_;
        _compounding[_id_] = true;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./abstracts/BaseContract.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
// INTERFACES
import "./interfaces/IVault.sol";

/**
 * @title AutoCompound
 * @author Steve Harmeyer
 * @notice This is the auto compound contract.
 */

/// @custom:security-contact [email protected]
contract AutoCompoundV2 is BaseContract
{
    /**
     * Contract initializer.
     * @dev This intializes all the parent contracts.
     */
    function initialize() initializer public
    {
        __BaseContract_init();
        _properties.maxPeriods = 7;
        _properties.period = 86400; // PRODUCTION period is 24 hours.
        _properties.fee = 2000000000000000; // .002 BNB per period.
        _properties.maxParticipants = 100;
    }

    using Counters for Counters.Counter;

    /**
     * Id tracker.
     * @dev Keeps track of the current id.
     */
    Counters.Counter private _idTracker;

    /**
     * Properties.
     */
    struct Properties {
        uint256 maxPeriods; // Maximum number of periods a participant can auto compound.
        uint256 period; // Seconds between compounds.
        uint256 fee; // BNB fee per period of auto compounding.
        uint256 maxParticipants; // Maximum autocompound participants.
    }
    Properties private _properties;

    /**
     * Stats.
     */
    struct Stats {
        uint256 compounding; // Number of participants auto compounding.
        uint256 compounds; // Number of auto compounds performed.
    }
    Stats private _stats;

    /**
     * Auto compound mappings.
     */
    mapping(uint256 => uint256) private _compoundsLeft;
    mapping(uint256 => uint256) private _lastCompound;
    mapping(uint256 => uint256) private _totalCompounds;
    mapping(uint256 => uint256[]) private _compounds;
    mapping(uint256 => address) private _addresses;
    mapping(address => uint256) private _ids;
    mapping(uint256 => bool) private _compounding;

    /**
     * Get properties.
     * @return Properties Contract properties.
     */
    function properties() external view returns (Properties memory)
    {
        return _properties;
    }

    /**
     * Get stats.
     * @return Stats Contract stats.
     */
    function stats() external view returns (Stats memory)
    {
        return _stats;
    }

    /**
     * Get id.
     * @param participant_ Participant address.
     * @return uint256 Participant id.
     */
    function getId(address participant_) external view returns (uint256)
    {
        return _ids[participant_];
    }

    /**
     * Get address.
     * @param id_ Participant id.
     * @return address Participant address.
     */
    function getAddress(uint256 id_) external view returns (address)
    {
        return _addresses[id_];
    }

    /**
     * Compounding.
     * @param participant_ Participant address.
     * @return bool True if they're auto compounding.
     */
    function compounding(address participant_) external view returns (bool)
    {
        return _compounding[_ids[participant_]];
    }

    /**
     * Get compounds left.
     * @param participant_ Participant address.
     * @return uint256 Number of compounds remaining.
     */
    function compoundsLeft(address participant_) external view returns (uint256)
    {
        return _compoundsLeft[_ids[participant_]];
    }

    /**
     * Get last compound.
     * @param participant_ Participant address.
     * @return uint256 Timestamp of last compound.
     */
    function lastCompound(address participant_) external view returns (uint256)
    {
        return _lastCompound[_ids[participant_]];
    }

    /**
     * Get total compounds.
     * @param participant_ Participant address.
     * @return uint256 Total number of auto compounds.
     */
    function totalCompounds(address participant_) external view returns (uint256)
    {
        return _totalCompounds[_ids[participant_]];
    }

    /**
     * Next up.
     * @return address Next address to be compounded.
     * @dev Returns the next address in line that needs to be compounded.
     */
    function next() public view returns (address)
    {
        return _addresses[_next()];
    }

    /**
     * Internal next.
     * @return uint256 Id of next participant.
     */
    function _next() internal view returns (uint256)
    {
        uint256 _dueDate_ = block.timestamp - _properties.period;
        for(uint256 i = 1; i <= _idTracker.current(); i ++) {
            if(!_compounding[i]) continue; // Skip if they're not compounding.
            if(_lastCompound[i] >= _dueDate_) continue; // Skip if their last compound was too soon.
            return i; // Return first id that is ready to compound.
        }
        return 0;
    }

    /**
     * Due for compound.
     * @return uint256 Number of addresses that are due for compounding.
     */
    function due() public view returns (uint256)
    {
        uint256 _dueCount_ = 0;
        uint256 _dueDate_ = block.timestamp - _properties.period;
        for(uint256 i = 1; i <= _idTracker.current(); i ++) {
            if(!_compounding[i]) continue;
            if(_lastCompound[i] < _dueDate_) _dueCount_ ++;
        }
        return _dueCount_;
    }

    /**
     * Compound next up.
     * @dev Auto compounds next participant.
     */
    function compound() public whenNotPaused
    {
        uint256 _id_ = _next();
        require(_id_ > 0, "No participants to compound.");
        _compound(_id_);
    }

    /**
     * Internal compound.
     * @dev Auto compounds participant.
     * @param id_ Id of participant.
     */
    function _compound(uint256 id_) internal
    {
        _lastCompound[id_] = block.timestamp;
        _compoundsLeft[id_] --;
        _totalCompounds[id_] ++;
        _stats.compounds ++;
        if(_compoundsLeft[id_] == 0) {
            _end(id_);
        }
        IVault _vault_ = IVault(addressBook.get("vault"));
        address(_vault_).call(abi.encodePacked(_vault_.autoCompound.selector, abi.encode(_addresses[id_])));
    }

    /**
     * Start auto compound.
     * @param periods_ Number of periods to auto compound.
     */
    function start(uint256 periods_) external payable whenNotPaused
    {
        require(msg.value >= periods_ * _properties.fee, "Insufficient message value");
        _start(msg.sender, periods_);
    }

    /**
     * Internal start.
     * @param participant_ Participant address.
     * @param periods_ Number of periods to auto compound.
     */
    function _start(address participant_, uint256 periods_) internal
    {
        require(periods_ > 0 && periods_ <= _properties.maxPeriods, "Invalid periods");
        uint256 _id_ = _ids[participant_];
        if(_id_ == 0) {
            _idTracker.increment();
            _id_ = _idTracker.current();
            _addresses[_id_] = participant_;
            _ids[participant_] = _id_;
        }
        require(_compoundsLeft[_id_] == 0, "Participant is already auto compounding");
        require(_stats.compounding < _properties.maxParticipants, "Maximum participants reached");
        _compoundsLeft[_id_] = periods_;
        _lastCompound[_id_] = block.timestamp - _properties.period;
        _compounding[_id_] = true;
        _stats.compounding ++;
    }

    /**
     * End auto compound.
     */
    function end() external whenNotPaused
    {
        _end(_ids[msg.sender]);
    }

    /**
     * Internal end auto compound.
     * @param id_ Participant id.
     */
    function _end(uint256 id_) internal
    {
        if(id_ == 0) return;
        _stats.compounding --;
        _compoundsLeft[id_] = 0;
        _compounding[id_] = false;
    }

    /**
     * Get vault.
     * @return IVault Vault contract.
     */
    function _getVault() internal view returns (IVault)
    {
        return IVault(addressBook.get("vault"));
    }

    /**
     * Withdraw.
     */
    function withdraw() external onlyOwner
    {
        payable(msg.sender).transfer(address(this).balance);
    }

    /**
     * Set max participants.
     * @param max_ Max participants.
     */
    function setMaxParticipants(uint256 max_) external onlyOwner
    {
        _properties.maxParticipants = max_;
    }

    /**
     * Set fee.
     * @param fee_ New fee.
     */
    function setFee(uint256 fee_) external onlyOwner
    {
        _properties.fee = fee_;
    }

    /**
     * Set max periods.
     * @param max_ Max periods.
     */
    function setMaxPeriods(uint256 max_) external onlyOwner
    {
        _properties.maxPeriods = max_;
    }

    /**
     * Add periods.
     * @param participant_ Participant address.
     * @param periods_ Number of periods to add.
     */
    function addPeriods(address participant_, uint256 periods_) external onlyOwner
    {
        uint256 _id_ = _ids[participant_];
        if(_id_ == 0) return _start(participant_, periods_);
        require(_compoundsLeft[_id_] + periods_ <= _properties.maxPeriods, "Invalid periods");
        _compoundsLeft[_id_] += periods_;
        _compounding[_id_] = true;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./abstracts/BaseContract.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";

/// @custom:security-contact [email protected]
contract FakeToken is BaseContract, ERC20Upgradeable {
    /**
     * Contract initializer.
     * @param name_ Token name.
     * @param symbol_ Token symbol.
     */
    function initialize(string memory name_, string memory symbol_) initializer public {
        __BaseContract_init();
        __ERC20_init(name_, symbol_);
    }

    /**
     * Free minting!
     * @param amount_ Amount to mint (no decimals).
     */
    function mint(uint256 amount_) external
    {
        _mint(msg.sender, amount_ * (10 ** decimals()));
    }

    /**
     * Free mint to address!
     * @param to_ Address to mint to.
     * @param amount_ Amount to mint (no decimals).
     */
    function mintTo(address to_, uint256 amount_) external
    {
        _mint(to_, amount_ * (10 ** decimals()));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./abstracts/BaseContract.sol";
// Interfaces.
import "./interfaces/IPresale.sol";
import "./interfaces/IToken.sol";
import "./interfaces/IVault.sol";

/**
 * @title Claim
 * @author Steve Harmeyer
 * @notice This contract handles presale NFT claims
 */

/// @custom:security-contact [email protected]
contract Claim is BaseContract
{
    /**
     * Contract initializer.
     * @dev This intializes all the parent contracts.
     */
    function initialize() initializer public
    {
        __BaseContract_init();
    }

    /**
     * NFT Values.
     */
    mapping(uint256 => uint256) private _value;

    /**
     * Empty NFTs.
     */
    mapping(uint256 => bool) private _empty;

    /**
     * Get remaining NFT value.
     * @param tokenId_ ID for the NFT.
     * @return uint256 Value.
     */
    function getTokenValue(uint256 tokenId_) public view returns (uint256)
    {
        IPresale _presale_ = _presale();
        require(address(_presale_) != address(0), "Presale contract not found");
        if(_value[tokenId_] != 0) {
            return _value[tokenId_];
        }
        if(_empty[tokenId_]) {
            return 0;
        }
        return _presale_.tokenValue(tokenId_);
    }

    /**
     * Get total value for an owner.
     * @param owner_ Token owner.
     * @return uint256 Value.
     */
    function getOwnerValue(address owner_) public view returns (uint256)
    {
        IPresale _presale_ = _presale();
        require(address(_presale_) != address(0), "Presale contract not found");
        uint256 _balance_ = _presale_.balanceOf(owner_);
        uint256 _value_;
        for(uint256 i = 0; i < _balance_; i++) {
            _value_ += getTokenValue(_presale_.tokenOfOwnerByIndex(owner_, i));
        }
        return _value_;
    }

    /**
     * Owned NFTs.
     * @param owner_ Owner address.
     * @return uint256[] Array of owned tokens.
     */
    function owned(address owner_) public view returns (uint256[] memory)
    {
        IPresale _presale_ = _presale();
        require(address(_presale_) != address(0), "Presale contract not found");
        uint256 _balance_ = _presale_.balanceOf(owner_);
        uint256[] memory _owned_ = new uint256[](_balance_);
        for(uint256 i = 0; i < _balance_; i++) {
            _owned_[i] = _presale_.tokenOfOwnerByIndex(owner_, i);
        }
        return _owned_;
    }

    /**
     * Claim.
     * @param quantity_ Quantity of $FUR to claim.
     * @param address_ Address tokens should be assigned to.
     * @param vault_ Send tokens straight to vault.
     * @return bool True if successful.
     */
    function claim(uint256 quantity_, address address_, bool vault_) external whenNotPaused returns (bool)
    {
        return _claim(quantity_, address_, vault_, address(0));
    }

    /**
     * Claim.
     * @param quantity_ Quantity of $FUR to claim.
     * @param address_ Address tokens should be assigned to.
     * @param vault_ Send tokens straight to vault.
     * @param referrer_ Referrer address.
     * @return bool True if successful.
     */
    function claim(uint256 quantity_, address address_, bool vault_, address referrer_) external returns (bool)
    {
        return _claim(quantity_, address_, vault_, referrer_);
    }

    /**
     * Claim.
     * @param quantity_ Quantity of $FUR to claim.
     * @param address_ Address tokens should be assigned to.
     * @param vault_ Send tokens straight to vault.
     * @param referrer_ Referrer address.
     * @return bool True if successful.
     */
    function _claim(uint256 quantity_, address address_, bool vault_, address referrer_) internal returns (bool)
    {
        IPresale _presale_ = _presale();
        require(address(_presale_) != address(0), "Presale contract not found");
        IToken _token_ = _token();
        require(address(_token_) != address(0), "Token contract not found");
        require(!_token_.paused(), "Token is paused");
        IVault _vault_ = _vault();
        require(address(_vault_) != address(0), "Vault contract not found");
        require(!_vault_.paused(), "Vault is paused");
        require(getOwnerValue(msg.sender) >= quantity_, "Quantity too high");
        uint256[] memory _owned_ = owned(msg.sender);
        uint256 _mintQuantity_ = quantity_;
        for(uint i = 0; i < _owned_.length; i ++) {
            uint256 _value_ = getTokenValue(_owned_[i]);
            if(_value_ <= _mintQuantity_) {
                _value[_owned_[i]] = 0;
                _empty[_owned_[i]] = true;
                _mintQuantity_ -= _value_;
            }
            else {
                _value[_owned_[i]] = _value_ - _mintQuantity_;
                _mintQuantity_ = 0;
            }
        }
        quantity_ = quantity_ * (10 ** 18);
        if(vault_) {
            _token_.mint(address(_vault_), quantity_);
            _vault_.depositFor(address_, quantity_, referrer_);
        }
        else {
            _token_.mint(address_, quantity_);
        }
        return true;
    }

    /**
     * Get presale NFT contract.
     * @return IPresale Presale contract.
     */
    function _presale() internal view returns (IPresale)
    {
        return IPresale(addressBook.get("presale"));
    }

    /**
     * Get token contract.
     * @return IToken Token contract.
     */
    function _token() internal view returns (IToken)
    {
        return IToken(addressBook.get("token"));
    }

    /**
     * Get vault contract.
     * @return IVault Vault contract.
     */
    function _vault() internal view returns (IVault)
    {
        return IVault(addressBook.get("vault"));
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[45] private __gap;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IPresale {
    function approve (address to, uint256 tokenId) external;
    function available (address buyer_, uint256 max_, uint256 price_, uint256 value_, uint256 total_) external view returns (uint256);
    function balanceOf (address owner) external view returns (uint256);
    function buy (bytes memory signature_, uint256 quantity_, uint256 max_, uint256 price_, uint256 value_, uint256 total_, uint256 expiration_) external returns (bool);
    function claim () external;
    function claimed (uint256) external view returns (bool);
    function furToken () external view returns (address);
    function getApproved (uint256 tokenId) external view returns (address);
    function isApprovedForAll (address owner, address operator) external view returns (bool);
    function name () external view returns (string memory);
    function owner () external view returns (address);
    function ownerOf (uint256 tokenId) external view returns (address);
    function paymentToken () external view returns (address);
    function renounceOwnership () external;
    function safeTransferFrom (address from, address to, uint256 tokenId) external;
    function safeTransferFrom (address from, address to, uint256 tokenId, bytes memory _data) external;
    function setApprovalForAll (address operator, bool approved) external;
    function setFurToken (address furToken_) external;
    function setPaymentToken (address paymentToken_) external;
    function setTokenUri (string memory uri_) external;
    function setTreasury (address treasury_) external;
    function setVerifier (address verifier_) external;
    function sold (uint256 max_, uint256 price_, uint256 value_, uint256 total_) external view returns (uint256);
    function supportsInterface (bytes4 interfaceId) external view returns (bool);
    function symbol () external view returns (string memory);
    function tokenByIndex (uint256 index) external view returns (uint256);
    function tokenOfOwnerByIndex (address owner, uint256 index) external view returns (uint256);
    function tokenURI (uint256 tokenId_) external view returns (string memory);
    function tokenValue (uint256) external view returns (uint256);
    function totalSupply () external view returns (uint256);
    function transferFrom (address from, address to, uint256 tokenId) external;
    function transferOwnership (address newOwner) external;
    function treasury () external view returns (address);
    function value (address owner_) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./abstracts/BaseContract.sol";

// Interfaces.
import "./interfaces/IToken.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "./interfaces/ILiquidityManager.sol";

/**
 * @title Furio AddLiquidity
 * @author Steve Harmeyer
 * @notice This contract creates the liquidity pool for $FUR/_payment_
 */

/// @custom:security-contact [email protected]
contract AddLiquidity is BaseContract {
    /**
     * Contract initializer.
     * @dev This intializes all the parent contracts.
     */
    function initialize() public initializer {
        __BaseContract_init();
    }

    function SetLmAddr(address _lmsAddress) external onlyOwner {
        _lms = ILiquidityManager(_lmsAddress);
    }

    /**
     * add liquidity.
     * @notice Creates LP token  with _payment and _token and send LP staking contract.
     */
    function addLiquidity() external {
        IERC20 _payment_ = IERC20(addressBook.get("payment"));
        IToken _token_ = IToken(addressBook.get("token"));
        IUniswapV2Router02 _router_ = IUniswapV2Router02(
            addressBook.get("router")
        );
        address _RewardPool_ = addressBook.get("lpStaking");
        require(address(_payment_) != address(0), "Payment token not set");
        require(address(_token_) != address(0), "Token not set");
        require(address(_router_) != address(0), "Router not set");
        require(_RewardPool_ != address(0), "lpRewardPool not set");

        uint256 _LiquidityAmount_ = _token_.balanceOf(address(this));
        uint256 _amountToLiquify_ = _LiquidityAmount_ / 2;
        uint256 _amountToSwap_ = _LiquidityAmount_ - _amountToLiquify_;

        if (_amountToSwap_ == 0) {
            return;
        }

        _token_.approve(address(_router_), _amountToSwap_);
        address[] memory _path_ = new address[](2);
        _path_[0] = address(_token_);
        _path_[1] = address(_payment_);
        uint256 _balanceBefore_ = _payment_.balanceOf(address(this));

        _lms.swapTokenForUsdcToWallet(
            address(this),
            address(this),
            _amountToSwap_,
            10
        );
        /* _router_.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _amountToSwap_,
            0,
            _path_,
            address(this),
            block.timestamp + 3600
        ); */

        uint256 _amount_payment_Liquidity_ = _payment_.balanceOf(
            address(this)
        ) - _balanceBefore_;

        _payment_.approve(address(_router_), _amount_payment_Liquidity_);
        _token_.approve(address(_router_), _amountToLiquify_);

        if (_amountToLiquify_ > 0 && _amount_payment_Liquidity_ > 0) {
            _router_.addLiquidity(
                address(_token_),
                address(_payment_),
                _amountToLiquify_,
                _amount_payment_Liquidity_,
                0,
                0,
                _RewardPool_,
                block.timestamp + 3600
            );
        }
    }

    function withdraw() external onlyOwner {
        IERC20 _payment_ = IERC20(addressBook.get("payment"));
        IToken _token_ = IToken(addressBook.get("token"));
        _payment_.transfer(msg.sender, _payment_.balanceOf(address(this)));
        _token_.transfer(msg.sender, _token_.balanceOf(address(this)));
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[45] private __gap;
    ILiquidityManager _lms; // Liquidity manager
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IResolver {
    function checker() external view returns (bool canExec, bytes memory execPayload);
}

import "./abstracts/BaseContract.sol";
import "./interfaces/ISwapV2.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

/// @custom:security-contact [email protected]
contract AddLiquidityV2 is BaseContract, IResolver
{
    /**
     * Contract initializer.
     * @dev This intializes all the parent contracts.
     */
    function initialize() public initializer
    {
        __BaseContract_init();
    }

    /**
     * Addresses.
     */
    address public lpStakingAddress;

    /**
     * Tokens.
     */
    IERC20 public fur;
    IERC20 public usdc;

    /**
     * Exchanges.
     */
    IUniswapV2Router02 public router;
    ISwapV2 public swap;

    /**
     * Intervals.
     */
    uint256 public addLiquidityInterval;
    uint256 public lastAdded;

    /**
     * Checker.
     */
    function checker() external view override returns (bool canExec, bytes memory execPayload)
    {
        if(lastAdded + addLiquidityInterval >= block.timestamp) return (false, bytes("Add liquidity is not due"));
        return(true, abi.encodeWithSelector(this.addLiquidity.selector));
    }

    /**
     * Add liquidity.
     */
    function addLiquidity() external
    {
        uint256 _usdcBalance_ = usdc.balanceOf(address(this));
        if(_usdcBalance_ == 0) return;
        // Swap half of USDC for FUR in order to add liquidity.
        usdc.approve(address(swap), _usdcBalance_ / 2);
        swap.buy(address(usdc), _usdcBalance_ / 2);
        // Get output from swap.
        uint256 _furBalance_ = fur.balanceOf(address(this));
        // Get new USDC balance.
        _usdcBalance_ = usdc.balanceOf(address(this));
        // Add liquidity.
        if(_usdcBalance_ > 0 && _furBalance_ > 0) {
            usdc.approve(address(router), _usdcBalance_);
            fur.approve(address(router), _furBalance_);
            router.addLiquidity(
                address(usdc),
                address(fur),
                _usdcBalance_,
                _furBalance_,
                0,
                0,
                lpStakingAddress,
                block.timestamp
            );
            lastAdded = block.timestamp;
        }
    }

    /**
     * Setup.
     */
    function setup() external
    {
        // Addresses.
        lpStakingAddress = addressBook.get("lpStaking");
        // Tokens.
        fur = IERC20(addressBook.get("token"));
        usdc = IERC20(addressBook.get("payment"));
        // Exchanges.
        router = IUniswapV2Router02(addressBook.get("router"));
        swap = ISwapV2(addressBook.get("swap"));
        // Intervals.
        addLiquidityInterval = 1 days;
    }

    /**
     * Withdraw.
     */
    function withdraw() external onlyOwner {
        usdc.transfer(msg.sender, usdc.balanceOf(address(this)));
        fur.transfer(msg.sender, fur.balanceOf(address(this)));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./abstracts/BaseContract.sol";
// INTERFACES
import "./interfaces/IVault.sol";
//import "@openzeppelin/contracts/interfaces/IERC721.sol";

/**
 * @title AutoCompound
 * @author Steve Harmeyer
 * @notice This is the auto compound contract.
 */

/// @custom:security-contact [email protected]
contract AutoCompound is BaseContract
{
    /**
     * Contract initializer.
     * @dev This intializes all the parent contracts.
     */
    function initialize() initializer public
    {
        __BaseContract_init();
        _properties.maxPeriods = 7;
        _properties.period = 86400; // PRODUCTION period is 24 hours.
        //_properties.period = 300;
        _properties.fee = 2000000000000000; // .002 BNB per period.
        _properties.minPresaleBalance = 1; // Must hold 1 presale NFT to participate.
        _properties.minVaultBalance = 100e18; // Must have a vault balance of 100 FUR to participate.
        _properties.maxParticipants = 100; // 100 maximum participants.
    }

    /**
     * Properties.
     */
    struct Properties {
        uint256 maxPeriods; // Maximum number of periods a participant can auto compound.
        uint256 period; // Seconds between compounds.
        uint256 fee; // BNB fee per period of auto compounding.
        uint256 minPresaleBalance; // Minimum number of presale NFTs a user needs to hold to participate.
        uint256 minVaultBalance; // Minimum vault balance a user needs to participate.
        uint256 maxParticipants; // Maximum autocompound participants.
    }
    Properties private _properties;

    /**
     * Stats.
     */
    struct Stats {
        uint256 compounding; // Number of participants auto compounding.
        uint256 compounds; // Number of auto compounds performed.
    }
    Stats private _stats;

    /**
     * Auto compound mappings.
     */
    mapping(address => uint256) private _compoundsLeft;
    mapping(address => uint256) private _lastCompound;
    mapping(address => uint256) private _totalCompounds;
    mapping(address => uint256[]) private _compounds;
    address[] private _compounding;

    /**
     * Get properties.
     * @return Properties Contract properties.
     */
    function properties() external view returns (Properties memory)
    {
        return _properties;
    }

    /**
     * Get stats.
     * @return Stats Contract stats.
     */
    function stats() external view returns (Stats memory)
    {
        return _stats;
    }

    /**
     * Get compounds left.
     * @param participant_ Participant address.
     * @return uint256 Number of compounds remaining.
     */
    function compoundsLeft(address participant_) external view returns (uint256)
    {
        return _compoundsLeft[participant_];
    }

    /**
     * Get last compound.
     * @param participant_ Participant address.
     * @return uint256 Timestamp of last compound.
     */
    function lastCompound(address participant_) external view returns (uint256)
    {
        return _lastCompound[participant_];
    }

    /**
     * Get total compounds.
     * @param participant_ Participant address.
     * @return uint256 Total number of auto compounds.
     */
    function totalCompounds(address participant_) external view returns (uint256)
    {
        return _totalCompounds[participant_];
    }

    /**
     * Get compounds.
     * @param participant_ Participant address.
     * @return uint256[] Array of compound timestamps.
     */
    function compounds(address participant_) external view returns (uint256[] memory)
    {
        return _compounds[participant_];
    }

    /**
     * Get compounding.
     * @return address[] Array of participants auto compounding.
     */
    function compounding() external view returns (address[] memory)
    {
        return _compounding;
    }

    /**
     * Next up.
     * @return address Next address to be compounded.
     * @dev Returns the next address in line that needs to be compounded.
     */
    function next() public view returns (address)
    {
        address _next_ = address(0);
        uint256 _earliestCompound_ = block.timestamp - _properties.period;
        for(uint i = 0; i < _compounding.length; i ++) {
            if(_compoundsLeft[_compounding[i]] > 0 && _lastCompound[_compounding[i]] < _earliestCompound_) {
                _earliestCompound_ = _lastCompound[_compounding[i]];
                _next_ = _compounding[i];
            }
        }
        return _next_;
    }

    /**
     * Due for compound.
     * @return uint256 Number of addresses that are due for compounding.
     */
    function due() public view returns (uint256)
    {
        uint256 _dueCount_ = 0;
        uint256 _dueDate_ = block.timestamp - _properties.period;
        for(uint i = 0; i < _compounding.length; i ++) {
            if(_compoundsLeft[_compounding[i]] > 0 && _lastCompound[_compounding[i]] < _dueDate_) {
                _dueCount_ ++;
            }
        }
        return _dueCount_;
    }

    /**
     * Compound next up with quantity.
     * @dev Auto compounds next X participants.
     */
    function compound(uint256 quantity_) public
    {
        for(uint i = 0; i < quantity_; i ++) {
            address _participant_ = next();
            if(_participant_ == address(0)) return;
            _compound(_participant_);
        }
    }

    /**
     * Compound next up.
     * @dev Auto compounds next participant.
     */
    function compound() public
    {
        if(paused()) {
            return;
        }
        address _participant_ = next();
        if(_participant_ == address(0)) return;
        _compound(_participant_);
    }

    /**
     * Internal compound.
     * @dev Auto compounds participant.
     * @return bool True if successful.
     */
    function _compound(address participant_) internal returns (bool)
    {
        _lastCompound[participant_] = block.timestamp;
        _compoundsLeft[participant_] --;
        _totalCompounds[participant_] ++;
        _compounds[participant_].push(block.timestamp);
        _stats.compounds ++;
        if(_compoundsLeft[participant_] == 0) {
            _end(participant_);
        }
        IVault _vault_ = IVault(addressBook.get("vault"));
        address(_vault_).call(abi.encodePacked(_vault_.autoCompound.selector, abi.encode(participant_)));
        return true;
    }

    /**
     * Start auto compound.
     * @param periods_ Number of periods to auto compound.
     * @return bool True if successful.
     */
    function start(uint256 periods_) external payable whenNotPaused returns (bool)
    {
        require(msg.value >= periods_ * _properties.fee, "Insufficient message value");
        return _start(msg.sender, periods_);
    }

    /**
     * Internal start.
     * @param participant_ Participant address.
     * @param periods_ Number of periods to auto compound.
     * @return bool True if successful.
     */
    function _start(address participant_, uint256 periods_) internal whenNotPaused returns (bool)
    {
        require(periods_ > 0 && periods_ <= _properties.maxPeriods, "Invalid periods");
        require(_compoundsLeft[participant_] == 0, "Participant is already auto compounding");
        require(_compounding.length < _properties.maxParticipants, "Maximum participants reached");
        _compoundsLeft[participant_] = periods_;
        _lastCompound[participant_] = block.timestamp - _properties.period;
        _compounding.push(participant_);
        _stats.compounding ++;
        return true;
    }

    /**
     * End auto compound.
     * @return bool True if successful.
     */
    function end() external returns (bool)
    {
        return _end(msg.sender);
    }

    /**
     * Internal end auto compound.
     * @param participant_ Participant address.
     * @return bool True if successful.
     */
    function _end(address participant_) internal returns (bool)
    {
        for(uint i = 0; i < _compounding.length; i ++) {
            if(_compounding[i] == participant_) {
                _stats.compounding --;
                delete _compounding[i];
                break;
            }
        }
        return true;
    }

    /**
     * Get vault.
     * @return IVault Vault contract.
     */
    function _getVault() internal view returns (IVault)
    {
        return IVault(addressBook.get("vault"));
    }

    /**
     * Withdraw.
     */
    function withdraw() external onlyOwner
    {
        payable(msg.sender).transfer(address(this).balance);
    }

    /**
     * Set max participants.
     * @param max_ Max participants.
     */
    function setMaxParticipants(uint256 max_) external onlyOwner
    {
        _properties.maxParticipants = max_;
    }

    /**
     * Add periods.
     * @param participant_ Participant address.
     * @param periods_ Number of periods to add.
     */
    function addPeriods(address participant_, uint256 periods_) external onlyOwner returns (bool)
    {
        if(_compoundsLeft[participant_] == 0) {
            return _start(participant_, periods_);
        }
        require(_compoundsLeft[participant_] + periods_ <= _properties.maxPeriods, "Invalid periods");
        _compoundsLeft[participant_] += periods_;
        return true;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;


import "./abstracts/BaseContract.sol";

/**
 * @title Furio Address Book
 * @author Steve Harmeyer
 * @notice This contract stores important addresses in the Furio ecosystem.
 * @dev Important addresses:    token - Fur token
 *                              payment - USDC token
 *                              vault - Fur vault
 *                              pool - Fur pool
 *                              swap - Fur swap
 *                              router - Pancake swap router V2
 *                              factory - Pancake swap factory V2
 *                              safe - Gnosis safe
 */

/// @custom:security-contact [email protected]
contract AddressBook is BaseContract
{
    /**
     * Contract initializer.
     * @dev This intializes all the parent contracts.
     */
    function initialize() initializer public
    {
        __BaseContract_init();
    }

    /**
     * Address book mapping.
     */
    mapping(string => address) private _addressBook;

    /**
     * Set address.
     * @param name_ Address name.
     * @param address_ Address.
     * @dev Stores an address in the address book.
     */
    function set(string memory name_, address address_) external whenNotPaused onlyOwner
    {
        _addressBook[name_] = address_;
    }

    /**
     * Unset address.
     * @param name_ Address name.
     * @dev Removes an address from the address book.
     */
    function unset(string memory name_) external whenNotPaused onlyOwner
    {
        delete _addressBook[name_];
    }

    /**
     * Get address.
     * @param name_ Address name.
     * @return address Address.
     * @dev Returns an address stored in the address book.
     */
    function get(string memory name_) external view whenNotPaused returns (address)
    {
        return _addressBook[name_];
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[45] private __gap;
}