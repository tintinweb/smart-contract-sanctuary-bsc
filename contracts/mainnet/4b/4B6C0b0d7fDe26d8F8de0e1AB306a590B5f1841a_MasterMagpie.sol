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
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

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
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
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
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

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
     * @dev Moves `amount` of tokens from `from` to `to`.
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/extensions/draft-ERC20Permit.sol)

pragma solidity ^0.8.0;

import "./draft-IERC20Permit.sol";
import "../ERC20.sol";
import "../../../utils/cryptography/draft-EIP712.sol";
import "../../../utils/cryptography/ECDSA.sol";
import "../../../utils/Counters.sol";

/**
 * @dev Implementation of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on `{IERC20-approve}`, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 *
 * _Available since v3.4._
 */
abstract contract ERC20Permit is ERC20, IERC20Permit, EIP712 {
    using Counters for Counters.Counter;

    mapping(address => Counters.Counter) private _nonces;

    // solhint-disable-next-line var-name-mixedcase
    bytes32 private constant _PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    /**
     * @dev In previous versions `_PERMIT_TYPEHASH` was declared as `immutable`.
     * However, to ensure consistency with the upgradeable transpiler, we will continue
     * to reserve a slot.
     * @custom:oz-renamed-from _PERMIT_TYPEHASH
     */
    // solhint-disable-next-line var-name-mixedcase
    bytes32 private _PERMIT_TYPEHASH_DEPRECATED_SLOT;

    /**
     * @dev Initializes the {EIP712} domain separator using the `name` parameter, and setting `version` to `"1"`.
     *
     * It's a good idea to use the same `name` that is defined as the ERC20 token name.
     */
    constructor(string memory name) EIP712(name, "1") {}

    /**
     * @dev See {IERC20Permit-permit}.
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual override {
        require(block.timestamp <= deadline, "ERC20Permit: expired deadline");

        bytes32 structHash = keccak256(abi.encode(_PERMIT_TYPEHASH, owner, spender, value, _useNonce(owner), deadline));

        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ECDSA.recover(hash, v, r, s);
        require(signer == owner, "ERC20Permit: invalid signature");

        _approve(owner, spender, value);
    }

    /**
     * @dev See {IERC20Permit-nonces}.
     */
    function nonces(address owner) public view virtual override returns (uint256) {
        return _nonces[owner].current();
    }

    /**
     * @dev See {IERC20Permit-DOMAIN_SEPARATOR}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view override returns (bytes32) {
        return _domainSeparatorV4();
    }

    /**
     * @dev "Consume a nonce": return the current value and increment.
     *
     * _Available since v4.1._
     */
    function _useNonce(address owner) internal virtual returns (uint256 current) {
        Counters.Counter storage nonce = _nonces[owner];
        current = nonce.current();
        nonce.increment();
    }
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
interface IERC20Permit {
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
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

    function safePermit(
        IERC20Permit token,
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

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
// OpenZeppelin Contracts v4.4.1 (utils/cryptography/draft-EIP712.sol)

pragma solidity ^0.8.0;

import "./ECDSA.sol";

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
 */
abstract contract EIP712 {
    /* solhint-disable var-name-mixedcase */
    // Cache the domain separator as an immutable value, but also store the chain id that it corresponds to, in order to
    // invalidate the cached domain separator if the chain id changes.
    bytes32 private immutable _CACHED_DOMAIN_SEPARATOR;
    uint256 private immutable _CACHED_CHAIN_ID;
    address private immutable _CACHED_THIS;

    bytes32 private immutable _HASHED_NAME;
    bytes32 private immutable _HASHED_VERSION;
    bytes32 private immutable _TYPE_HASH;

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
    constructor(string memory name, string memory version) {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        bytes32 typeHash = keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
        _CACHED_CHAIN_ID = block.chainid;
        _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(typeHash, hashedName, hashedVersion);
        _CACHED_THIS = address(this);
        _TYPE_HASH = typeHash;
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        if (address(this) == _CACHED_THIS && block.chainid == _CACHED_CHAIN_ID) {
            return _CACHED_DOMAIN_SEPARATOR;
        } else {
            return _buildDomainSeparator(_TYPE_HASH, _HASHED_NAME, _HASHED_VERSION);
        }
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
        return ECDSA.toTypedDataHash(_domainSeparatorV4(), structHash);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.3) (utils/cryptography/ECDSA.sol)

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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBaseRewardPool {
    function stakingDecimals() external view returns (uint256);

    function totalStaked() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function rewardPerToken(address token) external view returns (uint256);

    function rewardTokenInfos()
        external
        view
        returns
        (
            address[] memory bonusTokenAddresses,
            string[] memory bonusTokenSymbols
        );

    function earned(address account, address token)
        external
        view
        returns (uint256);

    function allEarned(address account)
        external
        view
        returns (uint256[] memory pendingBonusRewards);

    function queueNewRewards(uint256 _rewards, address token)
        external
        returns (bool);

    function getReward(address _account, address _receiver) external returns (bool);

    function getRewards(address _account, address _receiver, address[] memory _rewardTokens) external;

    function updateFor(address account) external;

    function updateManager(address _rewardManager, bool _allowed) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IPoolHelper.sol";


interface IHarvesttablePoolHelper is IPoolHelper {
    function harvest() external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ILocker {
    function lockFor(uint256 _amount, address _for) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface IMasterMagpie {
    function poolLength() external view returns (uint256);

    function setPoolManagerStatus(address _address, bool _bool) external;

    function add(uint256 _allocPoint, address _stakingTokenToken, address _rewarder, address _helper, bool _helperNeedsHarvest) external;

    function set(address _stakingToken, uint256 _allocPoint, address _helper,
        address _rewarder, bool _helperNeedsHarvest) external;

    function createRewarder(address _stakingTokenToken, address mainRewardToken) external
        returns (address);

    // View function to see pending GMPs on frontend.
    function getPoolInfo(address token) external view
        returns (
            uint256 emission,
            uint256 allocpoint,
            uint256 sizeOfPool,
            uint256 totalPoint
        );

    function rewarderBonusTokenInfo(address _stakingToken) external view
        returns (address[] memory bonusTokenAddresses, string[] memory bonusTokenSymbols);

    function pendingTokens(address _stakingToken, address _user, address token) external view
        returns (
            uint256 _pendingGMP,
            address _bonusTokenAddress,
            string memory _bonusTokenSymbol,
            uint256 _pendingBonusToken
        );

    function allPendingTokens(address _stakingToken, address _user)external view
        returns (
            uint256 pendingMGP,
            address[] memory bonusTokenAddresses,
            string[] memory bonusTokenSymbols,
            uint256[] memory pendingBonusRewards
        );

    function massUpdatePools() external;

    function updatePool(address _stakingToken) external;

    function deposit(address _stakingToken, uint256 _amount) external;

    function withdraw(address _stakingToken, uint256 _amount) external;

    function depositFor(address _stakingToken, uint256 _amount, address sender) external;

    function withdrawFor(address _stakingToken, uint256 _amount, address _sender ) external;

    function depositVlMGPFor(uint256 _amount, address sender) external;

    function withdrawVlMGPFor(uint256 _amount, address sender) external;

    function multiclaimFor(address[] calldata _stakingTokens, address[][] calldata _rewardTokens, address user_address) external;

    function multiclaimOnBehalf(address[] memory _stakingTokens, address[][] calldata _rewardTokens, address user_address) external;

    function emergencyWithdraw(address _stakingToken, address sender) external;

    function updateEmissionRate(uint256 _gmpPerSec) external;

    function stakingInfo(address _stakingToken, address _user)
        external
        view
        returns (uint256 depositAmount, uint256 availableAmount);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPoolHelper {
    function totalStaked() external view returns (uint256);

    function balance(address _address) external view returns (uint256);

    function deposit(uint256 amount, uint256 minimumAmount) external;

    function withdraw(uint256 amount, uint256 minimumAmount) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IERC20, ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./ILocker.sol";

interface IVLMGP is ILocker {
    
    struct UserUnlocking {
        uint256 startTime;
        uint256 endTime;
        uint256 amountInCoolDown; // total amount comitted to the unlock slot, never changes except when reseting slot
    }    

    function MGP() external view returns(IERC20);
    function getUserUnlockingSchedule(address _user) external view returns (UserUnlocking[] memory slots);
    function getUserAmountInCoolDown(address _user) external view returns (uint256);
    function totalLocked() external view returns (uint256);
    function getFullyUnlock(address _user) external view returns(uint256 unlockedAmount);
    function getRewardablePercentWAD(address _user) external view returns(uint256 percent);
    function totalAmountInCoolDown() external view returns (uint256);
    function getUserNthUnlockSlot(address _user, uint256 n) external view returns (
        uint256 startTime,
        uint256 endTime,
        uint256 amountInCoolDown
    );

    function getUserUnlockSlotLength(address _user) external view returns (uint256);
    function getNextAvailableUnlockSlot(address _user) external view returns (uint256);
    function getUserTotalLocked(address _user) external view returns (uint256);
    function lock(uint256 _amount) external;
    function startUnlock(uint256 _amountToCoolDown) external;
    function cancelUnlock(uint256 _slotIndex) external;
    function unlock(uint256 slotIndex) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IBaseRewardPool.sol";

interface IvlmgpPBaseRewarder is IBaseRewardPool {
    
    function queueMGP(uint256 _amount, address _user, address _receiver) external returns(bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol';

/// @title MGP
/// @author Magpie Team
contract MGP is ERC20('Magpie Token', 'MGP'), ERC20Permit('Magpie Token') {
    constructor(address _receipient, uint256 _totalSupply) {
        _mint(_receipient, _totalSupply);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../interfaces/IMasterMagpie.sol";
import "../interfaces/IBaseRewardPool.sol";

/// @title A contract for managing rewards for a pool
/// @author Magpie Team
/// @notice You can use this contract for getting informations about rewards for a specific pools
contract BaseRewardPoolV2 is Ownable, IBaseRewardPool {
    using SafeERC20 for IERC20Metadata;
    using SafeERC20 for IERC20;

    /* ============ State Variables ============ */

    address public immutable stakingToken;
    address public immutable operator;          // master magpie
    uint256 public immutable stakingTokenDecimals;

    address[] public rewardTokens;

    struct Reward {
        address rewardToken;
        uint256 rewardPerTokenStored;
        uint256 queuedRewards;
        uint256 historicalRewards;
    }

    mapping(address => Reward) public rewards;                           // [rewardToken]
    // amount by [rewardToken][account], 
    mapping(address => mapping(address => uint256)) public userRewardPerTokenPaid;                 
    mapping(address => mapping(address => uint256)) public userRewards;  // amount by [rewardToken][account]
    mapping(address => bool) public isRewardToken;
    mapping(address => bool) public managers;

    /* ============ Events ============ */

    event RewardAdded(uint256 _reward, address indexed _token);
    event Staked(address indexed _user, uint256 _amount);
    event Withdrawn(address indexed _user, uint256 _amount);
    event RewardPaid(address indexed _user, address indexed _receiver, uint256 _reward, address indexed _token);
    event ManagerUpdated(address indexed _manager, bool _allowed);

    /* ============ Errors ============ */

    error OnlyManager();
    error OnlyMasterMagpie();
    error NotAllowZeroAddress();
    error MustBeRewardToken();

    /* ============ Constructor ============ */

    constructor(
        address _stakingToken,
        address _rewardToken,
        address _masterMagpie,
        address _rewardManager
    ) {
        if(
            _stakingToken == address(0) ||
            _masterMagpie  == address(0) ||
            _rewardManager  == address(0)
        ) revert NotAllowZeroAddress();

        stakingToken = _stakingToken;
        stakingTokenDecimals = IERC20Metadata(stakingToken).decimals();
        operator = _masterMagpie;

        if (_rewardToken != address(0)) {
            rewards[_rewardToken] = Reward({
                rewardToken: _rewardToken,
                rewardPerTokenStored: 0,
                queuedRewards: 0,
                historicalRewards: 0
            });
            rewardTokens.push(_rewardToken);
        }

        isRewardToken[_rewardToken] = true;
        managers[_rewardManager] = true;
    }

    /* ============ Modifiers ============ */

    modifier onlyManager() {
        if (!managers[msg.sender])
            revert OnlyManager();
        _;
    }

    modifier onlyMasterMagpie() {
        if (msg.sender != operator)
            revert OnlyMasterMagpie();
        _;
    }

    modifier updateReward(address _account) {
        _updateFor(_account);
        _;
    }

    modifier updateRewards(address _account, address[] memory _rewards) {
        uint256 length = _rewards.length;
        uint256 userShare = balanceOf(_account);
        
        for (uint256 index = 0; index < length; ++index) {
            address rewardToken = _rewards[index];
            // if a reward stopped queuing, no need to recalculate to save gas fee
            if (userRewardPerTokenPaid[rewardToken][_account] == rewardPerToken(rewardToken))
                continue;
            userRewards[rewardToken][_account] = _earned(_account, rewardToken, userShare);
            userRewardPerTokenPaid[rewardToken][_account] = rewardPerToken(rewardToken);
        }
        _;
    }    

    /* ============ External Getters ============ */

    /// @notice Returns current amount of staked tokens
    /// @return Returns current amount of staked tokens
    function totalStaked() public override virtual view returns (uint256) {
        return IERC20(stakingToken).balanceOf(operator);
    }

    /// @notice Returns amount of staked tokens in master magpie by account
    /// @param _account Address account
    /// @return Returns amount of staked tokens by account
    function balanceOf(address _account) public override virtual view returns (uint256) {
        (uint256 staked, ) =  IMasterMagpie(operator).stakingInfo(stakingToken, _account);
        return staked;
    }

    function stakingDecimals() external override view returns (uint256) {
        return stakingTokenDecimals;
    }

    /// @notice Returns amount of reward token per staking tokens in pool
    /// @param _rewardToken Address reward token
    /// @return Returns amount of reward token per staking tokens in pool
    function rewardPerToken(address _rewardToken)
        public
        override
        view
        returns (uint256)
    {
        return rewards[_rewardToken].rewardPerTokenStored;
    }

    function rewardTokenInfos()
        override
        external
        view
        returns
        (
            address[] memory bonusTokenAddresses,
            string[] memory bonusTokenSymbols
        )
    {
        uint256 rewardTokensLength = rewardTokens.length;
        bonusTokenAddresses = new address[](rewardTokensLength);
        bonusTokenSymbols = new string[](rewardTokensLength);
        for (uint256 i; i < rewardTokensLength; i++) {
            bonusTokenAddresses[i] = rewardTokens[i];
            bonusTokenSymbols[i] = IERC20Metadata(address(bonusTokenAddresses[i])).symbol();
        }
    }

    /// @notice Returns amount of reward token earned by a user
    /// @param _account Address account
    /// @param _rewardToken Address reward token
    /// @return Returns amount of reward token earned by a user
    function earned(address _account, address _rewardToken)
        public
        override
        view
        returns (uint256)
    {
        return _earned(_account, _rewardToken, balanceOf(_account));
    }

    /// @notice Returns amount of all reward tokens
    /// @param _account Address account
    /// @return pendingBonusRewards as amounts of all rewards.
    function allEarned(address _account)
        external
        override
        view
        returns (
            uint256[] memory pendingBonusRewards
        )
    {
        uint256 length = rewardTokens.length;
        pendingBonusRewards = new uint256[](length);
        for (uint256 i = 0; i < length; i++) {
            pendingBonusRewards[i] = earned(_account, rewardTokens[i]);
        }

        return pendingBonusRewards;
    }

    function getRewardLength() external view returns(uint256) {
        return rewardTokens.length;
    }    

    /* ============ External Functions ============ */

    /// @notice Updates the reward information for one account
    /// @param _account Address account
    function updateFor(address _account) override external {
        _updateFor(_account);
    }

    function getReward(address _account, address _receiver)
        public
        onlyMasterMagpie
        updateReward(_account)
        returns (bool)
    {
        uint256 length = rewardTokens.length;

        for (uint256 index = 0; index < length; ++index) {
            address rewardToken = rewardTokens[index];
            uint256 reward = userRewards[rewardToken][_account]; // updated during updateReward modifier
            if (reward > 0) {
                _sendReward(rewardToken, _account, _receiver, reward);
            }
        }

        return true;
    }

    function getRewards(address _account, address _receiver, address[] memory _rewardTokens) override
        external
        onlyMasterMagpie
        updateRewards(_account, _rewardTokens)
    {
        uint256 length = _rewardTokens.length;
        for (uint256 index = 0; index < length; ++index) {
            address rewardToken = _rewardTokens[index];
            uint256 reward = userRewards[rewardToken][_account]; // updated during updateReward modifier
            if (reward > 0) {
                _sendReward(rewardToken, _account, _receiver, reward);
            }
        }
    }

    /// @notice Sends new rewards to be distributed to the users staking. Only possible to donate already registered token
    /// @param _amountReward Amount of reward token to be distributed
    /// @param _rewardToken Address reward token
    function donateRewards(uint256 _amountReward, address _rewardToken) external {
        if (!isRewardToken[_rewardToken])
            revert MustBeRewardToken();

        _provisionReward(_amountReward, _rewardToken);
    }

    /* ============ Admin Functions ============ */

    function updateManager(address _rewardManager, bool _allowed) external onlyOwner {
        managers[_rewardManager] = _allowed;

        emit ManagerUpdated(_rewardManager, managers[_rewardManager]);
    }

    /// @notice Sends new rewards to be distributed to the users staking. Only callable by manager
    /// @param _amountReward Amount of reward token to be distributed
    /// @param _rewardToken Address reward token
    function queueNewRewards(uint256 _amountReward, address _rewardToken)
        override
        external
        onlyManager
        returns (bool)
    {
        if (!isRewardToken[_rewardToken]) {
            rewardTokens.push(_rewardToken);
            isRewardToken[_rewardToken] = true;
        }

        _provisionReward(_amountReward, _rewardToken);
        return true;
    }

    /* ============ Internal Functions ============ */

    function _provisionReward(uint256 _amountReward, address _rewardToken) internal {
        IERC20(_rewardToken).safeTransferFrom(
            msg.sender,
            address(this),
            _amountReward
        );
        Reward storage rewardInfo = rewards[_rewardToken];
        rewardInfo.historicalRewards =
            rewardInfo.historicalRewards +
            _amountReward;

        if (totalStaked() == 0) {
            rewardInfo.queuedRewards += _amountReward;
        } else {
            if (rewardInfo.queuedRewards > 0) {
                _amountReward += rewardInfo.queuedRewards;
                rewardInfo.queuedRewards = 0;
            }
            rewardInfo.rewardPerTokenStored =
                rewardInfo.rewardPerTokenStored +
                (_amountReward * 10**stakingTokenDecimals) /
                totalStaked();
        }
        emit RewardAdded(_amountReward, _rewardToken);
    }

    function _earned(address _account, address _rewardToken, uint256 _userShare) internal view returns (uint256) {
        return ((_userShare *
                (rewardPerToken(_rewardToken) -
                    userRewardPerTokenPaid[_rewardToken][_account])) /
                10**stakingTokenDecimals) + userRewards[_rewardToken][_account];
    }

    function _sendReward(address _rewardToken, address _account, address _receiver, uint256 _amount) internal {
        userRewards[_rewardToken][_account] = 0;
        IERC20(_rewardToken).safeTransfer(_receiver, _amount);
        emit RewardPaid(_account, _receiver, _amount, _rewardToken);
    }

    function _updateFor(address _account) internal {
        uint256 length = rewardTokens.length;
        for (uint256 index = 0; index < length; ++index) {
            address rewardToken = rewardTokens[index];
            // if a reward stopped queuing, no need to recalculate to save gas fee
            if (userRewardPerTokenPaid[rewardToken][_account] == rewardPerToken(rewardToken))
                continue;

            userRewards[rewardToken][_account] = earned(_account, rewardToken);
            userRewardPerTokenPaid[rewardToken][_account] = rewardPerToken(rewardToken);
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import { Address } from "@openzeppelin/contracts/utils/Address.sol";
import { ReentrancyGuardUpgradeable } from '@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol';
import { PausableUpgradeable } from '@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol';

import "../Mgp.sol";
import "./BaseRewardPoolV2.sol";
import "../interfaces/IBaseRewardPool.sol";
import "../interfaces/IvlmgpPBaseRewarder.sol";
import "../interfaces/IHarvesttablePoolHelper.sol";
import "../interfaces/IVLMGP.sol";
import "../interfaces/ILocker.sol";

// MasterMagpie is a boss. He says "go f your blocks lego boy, I'm gonna use timestamp instead".
// And to top it off, it takes no risks. Because the biggest risk is operator error.
// So we make it virtually impossible for the operator of this contract to cause a bug with people's harvests.
//
// Note that it's ownable and the owner wields tremendous power. The ownership
// will be transferred to a governance smart contract once MGP is sufficiently
// distributed and the community can show to govern itself.
//
/// @title A contract for managing all reward pools
/// @author Magpie Team
/// @notice You can use this contract for depositing MGP, MWOM, and Liquidity Pool tokens.
/// @dev All the ___For() function are function which are supposed to be called by other contract designed by Magpie's team

contract MasterMagpie is Initializable, OwnableUpgradeable, ReentrancyGuardUpgradeable, PausableUpgradeable {
    using SafeERC20 for IERC20;

    /* ============ Structs ============ */

    // Info of each user.
    struct UserInfo {
        uint256 amount; // How many staking tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        uint256 available; // in case of locking
        //
        // We do some fancy math here. Basically, any point in time, the amount of MGPs
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * pool.accMGPPerShare) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws staking tokens to a pool. Here's what happens:
        //   1. The pool's `accMGPPerShare` (and `lastRewardTimestamp`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }

    // Info of each pool.
    struct PoolInfo {
        address stakingToken; // Address of staking token contract to be staked.
        uint256 allocPoint; // How many allocation points assigned to this pool. MGPs to distribute per second.
        uint256 lastRewardTimestamp; // Last timestamp that MGPs distribution occurs.
        uint256 accMGPPerShare; // Accumulated MGPs per share, times 1e12. See below.
        address rewarder;
        address helper;
        bool    helperNeedsHarvest;
    }

    /* ============ State Variables ============ */

    // The MGP TOKEN!
    MGP public mgp;

    IVLMGP public vlmgp;

    // MGP tokens created per second.
    uint256 public mgpPerSec;

    // Registered staking tokens 
    address[] public registeredToken;
    // Info of each pool.
    mapping(address => PoolInfo) public tokenToPoolInfo;
    // Set of all staking tokens that have been added as pools
    mapping(address => bool) private openPools;
    // Info of each user that stakes staking tokens [_staking][_account]
    mapping(address => mapping(address => UserInfo)) private userInfo;
    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint;
    // The timestamp when MGP mining starts.
    uint256 public startTimestamp;

    mapping(address => bool) public PoolManagers;

    address public compounder;

    /* ==== variable added for first upgrade === */

    mapping(address => bool) public MPGRewardPool; // pools that emit MGP otherwise, vlMGP

    /* ==== variable added for second upgrade === */
    mapping(address => mapping (address => uint256)) public unClaimedMgp; // unclaimed mgp reward before lastRewardTimestamp
    mapping(address => address) public legacyRewarder; // old rewarder

    /* ============ Events ============ */

    event Add(
        uint256 _allocPoint,
        address indexed _stakingToken,
        IBaseRewardPool indexed _rewarder
    );
    event Set(
        address indexed _stakingToken,
        uint256 _allocPoint,
        IBaseRewardPool indexed _rewarder
    );
    event Deposit(
        address indexed _user,
        address indexed _stakingToken,
        uint256 _amount
    );
    event Withdraw(
        address indexed _user,
        address indexed _stakingToken,
        uint256 _amount
    );
    event UpdatePool(
        address indexed _stakingToken,
        uint256 _lastRewardTimestamp,
        uint256 _lpSupply,
        uint256 _accMGPPerShare
    );
    event HarvestMGP(
        address indexed _account,
        address indexed _receiver,
        uint256 _amount,
        bool isLock
    );
    event EmergencyWithdraw(
        address indexed _user,
        address indexed _stakingToken,
        uint256 _amount
    );
    event UpdateEmissionRate(address indexed _user, uint256 _oldMgpPerSec, uint256 _newMgpPerSec);
    event UpdatePoolAlloc(address _stakingToken, uint256 _oldAllocPoint, uint256 _newAllocPoint);
    event PoolManagerStatus(address _account, bool _status);
    event CompounderUpated(address _newCompounder, address _oldCompounder);
    event VLMGPUpdated(address _newVlmgp, address _oldVlmgp);
    event DepositNotAvailable(address indexed _user,  address indexed _stakingToken, uint256 _amount);
    event MGPSet(address _mgp);
    event LockFreePoolUpdated(address _stakingToken, bool _isRewardMGP);    

    /* ============ Errors ============ */

    error OnlyPoolManager();
    error OnlyPoolHelper();
    error OnlyActivePool();
    error PoolExsisted();
    error InvalidStakingToken();
    error WithdrawAmountExceedsStaked();
    error UnlockAmountExceedsLocked();
    error MustBeContractOrZero();
    error OnlyCompounder();
    error OnlyVlMgp();
    error MGPsetAlready();
    error MustBeContract();
    error LengthMismatch();

    /* ============ Constructor ============ */    

    function __MasterMagpie_init(
        address _mgp,
        uint256 _mgpPerSec,
        uint256 _startTimestamp
    ) public initializer {

        __Ownable_init();        
        mgp = MGP(_mgp);
        mgpPerSec = _mgpPerSec;
        startTimestamp = _startTimestamp;
        totalAllocPoint = 0;
        PoolManagers[owner()] = true;
    }

    /* ============ Modifiers ============ */
    
    modifier _onlyPoolManager() {
        if (!PoolManagers[msg.sender])
            revert OnlyPoolManager();
        _;
    }

    modifier _onlyPoolHelper(address _stakedToken) {
        if (msg.sender != tokenToPoolInfo[_stakedToken].helper)
            revert OnlyPoolHelper();
        _;            
    }

    modifier _onlyVlMgp() {
        if (msg.sender != address(vlmgp))
            revert OnlyVlMgp();
        _;
    }

    modifier _onlyCompounder() {
        if (msg.sender != compounder)
            revert OnlyCompounder();
        _;
    }

    /* ============ External Getters ============ */

    /// @notice Returns number of registered tokens, tokens having a registered pool.
    /// @return Returns number of registered tokens
    function poolLength() external view returns (uint256) {
        return registeredToken.length;
    }

    /// @notice Gives information about a Pool. Used for APR calculation and Front-End
    /// @param _stakingToken Staking token of the pool we want to get information from
    /// @return emission - Emissions of MGP from the contract, allocpoint - Allocated emissions of MGP to the pool,sizeOfPool - size of Pool, totalPoint total allocation points

    function getPoolInfo(address _stakingToken)
        external
        view
        returns (
            uint256 emission,
            uint256 allocpoint,
            uint256 sizeOfPool,
            uint256 totalPoint
        )
    {
        PoolInfo memory pool = tokenToPoolInfo[_stakingToken];
        return (
            (mgpPerSec * pool.allocPoint / totalAllocPoint),
            pool.allocPoint,
            _calLpSupply(_stakingToken),
            totalAllocPoint
        );
    }

    /// @notice Provides available amount for a specific user for a specific pool.
    /// @param _stakingToken Staking token of the pool
    /// @param _user Address of the user

    function stakingInfo(address _stakingToken, address _user)
        public
        view
        returns (uint256 stakedAmount, uint256 availableAmount)
    {
        return (userInfo[_stakingToken][_user].amount, userInfo[_stakingToken][_user].available);
    }

    /// @notice View function to see pending reward tokens on frontend.
    /// @param _stakingToken Staking token of the pool
    /// @param _user Address of the user
    /// @param _rewardToken Specific pending reward token, apart from MGP
    /// @return pendingMGP - Expected amount of MGP the user can claim, bonusTokenAddress - token, bonusTokenSymbol - token Symbol,  pendingBonusToken - Expected amount of token the user can claim
    function pendingTokens(
        address _stakingToken,
        address _user,
        address _rewardToken
    )
        external
        view
        returns (
            uint256 pendingMGP,
            address bonusTokenAddress,
            string memory bonusTokenSymbol,
            uint256 pendingBonusToken
        )
    {
        PoolInfo storage pool = tokenToPoolInfo[_stakingToken];
        pendingMGP = _calMGPReward(_stakingToken, _user);

        // If it's a multiple reward farm, we return info about the specific bonus token
        if (address(pool.rewarder) != address(0)) {
            (bonusTokenAddress, bonusTokenSymbol) = (
                _rewardToken,
                IERC20Metadata(_rewardToken).symbol()
            );
            pendingBonusToken = IBaseRewardPool(pool.rewarder).earned(
                _user,
                _rewardToken
            );
        }
    }

    function allPendingTokens(address _stakingToken, address _user)
        external view returns (
            uint256 pendingMGP,
            address[] memory bonusTokenAddresses,
            string[] memory bonusTokenSymbols,
            uint256[] memory pendingBonusRewards
        )
    {
        PoolInfo storage pool = tokenToPoolInfo[_stakingToken];
        pendingMGP = _calMGPReward(_stakingToken, _user);

        // If it's a multiple reward farm, we return all info about the bonus tokens
        if (address(pool.rewarder) != address(0)) {
            (bonusTokenAddresses, bonusTokenSymbols) = IBaseRewardPool(pool.rewarder).rewardTokenInfos();
            pendingBonusRewards = IBaseRewardPool(pool.rewarder).allEarned(_user);
        }
    }

    function allPendingLegacyRewards(address _stakingToken, address _user)
        external view returns (
            address[] memory bonusTokenAddresses,
            string[] memory bonusTokenSymbols,
            uint256[] memory pendingBonusRewards
        )
    {
        address rewarder = legacyRewarder[_stakingToken];
        // If it's a multiple reward farm, we return all info about the bonus tokens
        if (rewarder != address(0)) {
            (bonusTokenAddresses, bonusTokenSymbols) = IBaseRewardPool(rewarder).rewardTokenInfos();
            pendingBonusRewards = IBaseRewardPool(rewarder).allEarned(_user);
        }
    }

    function rewarderBonusTokenInfo(address _stakingToken) public view
        returns (address[] memory bonusTokenAddresses, string[] memory bonusTokenSymbols)
    {
        PoolInfo storage pool = tokenToPoolInfo[_stakingToken];
        if (address(pool.rewarder) == address(0)) {
            return (bonusTokenAddresses, bonusTokenSymbols);
        }

        (bonusTokenAddresses, bonusTokenSymbols) = IBaseRewardPool(pool.rewarder).rewardTokenInfos();
    }

    /* ============ External Functions ============ */
    /// @notice Deposits staking token to the pool, updates pool and distributes rewards
    /// @param _stakingToken Staking token of the pool
    /// @param _amount Amount to deposit to the pool
    function deposit(address _stakingToken, uint256 _amount) external whenNotPaused nonReentrant {
        _deposit(_stakingToken, msg.sender, _amount, false);
    }

    /// @notice Withdraw staking tokens from Master Mgapie.
    /// @param _stakingToken Staking token of the pool
    /// @param _amount amount to withdraw
    function withdraw(address _stakingToken, uint256 _amount) external whenNotPaused nonReentrant {
        _withdraw(_stakingToken, msg.sender, _amount, false);
    }

    /// @notice Deposit staking tokens to Master Magpie. Can only be called by pool helper
    /// @param _stakingToken Staking token of the pool
    /// @param _amount Amount to deposit
    /// @param _for Address of the user the pool helper is depositing for, and also harvested reward will be sent to
    function depositFor(
        address _stakingToken,
        uint256 _amount,
        address _for
    ) external whenNotPaused _onlyPoolHelper(_stakingToken) nonReentrant {
        _deposit(_stakingToken, _for, _amount, false);
    }

    /// @notice Withdraw staking tokens from Mastser Magpie for a specific user. Can only be called by pool helper
    /// @param _stakingToken Staking token of the pool
    /// @param _amount amount to withdraw   
    /// @param _for address of the user to withdraw for, and also harvested reward will be sent to
    function withdrawFor(
        address _stakingToken,
        uint256 _amount,
        address _for
    ) external whenNotPaused _onlyPoolHelper(_stakingToken) nonReentrant {
        _withdraw(_stakingToken, _for, _amount, false);
    }

    /// @notice Update reward variables of the given pool to be up-to-date.
    /// @param _stakingToken Staking token of the pool
    function updatePool(address _stakingToken) public whenNotPaused {
        PoolInfo storage pool = tokenToPoolInfo[_stakingToken];
        if (block.timestamp <= pool.lastRewardTimestamp || totalAllocPoint == 0) {
            return;
        }
        uint256 lpSupply = _calLpSupply(_stakingToken);
        if (lpSupply == 0) {
            pool.lastRewardTimestamp = block.timestamp;
            return;
        }        
        uint256 multiplier = block.timestamp - pool.lastRewardTimestamp;
        uint256 mgpReward = (multiplier * mgpPerSec * pool.allocPoint) / totalAllocPoint;
        
        pool.accMGPPerShare = pool.accMGPPerShare + ((mgpReward * 1e12) / lpSupply);
        pool.lastRewardTimestamp = block.timestamp;

        emit UpdatePool(
            _stakingToken,
            pool.lastRewardTimestamp,
            lpSupply,
            pool.accMGPPerShare
        );
    }    

    /// @notice Update reward variables for all pools. Be mindful of gas costs!
    function massUpdatePools() public whenNotPaused {
        for (uint256 pid = 0; pid < registeredToken.length; ++pid) {
            updatePool(registeredToken[pid]);
        }
    }

    /// @notice Claims for each of the pools with specified rewards to claim for each pool
    function multiclaimSpec(address[] calldata _stakingTokens, address[][] memory _rewardTokens)
        external whenNotPaused
    {
        _multiClaim(_stakingTokens, msg.sender, msg.sender, _rewardTokens);
    }

    /// @notice Claims for each of the pools with specified rewards to claim for each pool
    function multiclaimFor(address[] calldata _stakingTokens, address[][] memory _rewardTokens, address _account)
        external whenNotPaused
    {
        _multiClaim(_stakingTokens, _account, _account, _rewardTokens);
    }

    /// @notice Claims for each of the pools with specified rewards to claim for each pool. ONLY callable by compounder!!!!!!
    function multiclaimOnBehalf(address[] calldata _stakingTokens, address[][] memory _rewardTokens, address _account)
        external whenNotPaused _onlyCompounder
    {
        _multiClaim(_stakingTokens, _account, msg.sender, _rewardTokens);
    }

    /// @notice Claim for all rewards for the pools
    function multiclaim(address[] calldata _stakingTokens)
        external whenNotPaused
    {
        address[][] memory rewardTokens = new address[][](_stakingTokens.length);
        _multiClaim(_stakingTokens, msg.sender, msg.sender, rewardTokens);
    }

    function multiclaimLegacy(address[] calldata _stakingTokens) external whenNotPaused
    {
        uint256 length = _stakingTokens.length;

        for (uint256 i = 0; i < length; ++i) {
            address _stakingToken = _stakingTokens[i];
            if (legacyRewarder[_stakingToken] != address(0)) {
                IBaseRewardPool rewarder = IBaseRewardPool(legacyRewarder[_stakingToken]);
                rewarder.getReward(msg.sender, msg.sender);
            }
        }
    }

    /// @notice Withdraw all available tokens without caring about rewards. EMERGENCY ONLY. 
    ///         Locked Token can not be emergent withdraw.
    /// @param _stakingToken Staking token of the pool
    /// @dev withdrawFor of the rewarder with the third param at false is an emergency withdraw
    function emergencyWithdraw(address _stakingToken) external whenPaused {
        PoolInfo storage pool = tokenToPoolInfo[_stakingToken];
        UserInfo storage user = userInfo[_stakingToken][msg.sender];
        uint256 availableaAmount = user.available;
        user.available = 0;
        IERC20(pool.stakingToken).safeTransfer(address(msg.sender), availableaAmount);
        emit EmergencyWithdraw(msg.sender, _stakingToken, availableaAmount);
        user.amount = user.amount - availableaAmount;
        user.rewardDebt = (user.amount * pool.accMGPPerShare) / 1e12;
    }

    /* ============ VLMGP interaction Functions ============ */

    function depositVlMGPFor(
        uint256 _amount,
        address _for
    ) external whenNotPaused _onlyVlMgp() {
        _deposit(address(vlmgp), _for, _amount, true);
    }
    
    function withdrawVlMGPFor(
        uint256 _amount,
        address _for
    ) external whenNotPaused _onlyVlMgp() {
        _withdraw(address(vlmgp), _for, _amount, true);
    }

    /* ============ Internal Functions ============ */

    /// @notice internal function to deal with deposit staking token
    function _deposit(address _stakingToken, address _account, uint256 _amount, bool _isVlmgp) internal {
        updatePool(_stakingToken);

        PoolInfo storage pool = tokenToPoolInfo[_stakingToken];
        UserInfo storage user = userInfo[_stakingToken][_account];

        if (user.amount > 0) {
            _harvestMGP(_stakingToken, _account);
        }
        _harvestBaseRewarder(_stakingToken, _account);

        user.amount = user.amount + _amount;
        if (!_isVlmgp) {
            user.available = user.available + _amount;
            IERC20(pool.stakingToken).safeTransferFrom(address(msg.sender), address(this), _amount);
        }
        user.rewardDebt = (user.amount * pool.accMGPPerShare) / 1e12;

        if (_amount > 0)
            if (!_isVlmgp)
                emit Deposit(_account, _stakingToken, _amount);
            else
                emit DepositNotAvailable(_account, _stakingToken, _amount);
    }

    /// @notice internal function to deal with withdraw staking token
    function _withdraw(address _stakingToken, address _account, uint256 _amount, bool _isVlMgp) internal {
        _harvestAndUnstake(_stakingToken, _account, _amount, _isVlMgp);

        if (!_isVlMgp)
            IERC20(tokenToPoolInfo[_stakingToken].stakingToken).safeTransfer(address(msg.sender), _amount);
        emit Withdraw(_account, _stakingToken, _amount);
    }

    function _harvestAndUnstake(address _stakingToken, address _account, uint256 _amount, bool _isVlMgp) internal {
        updatePool(_stakingToken);

        UserInfo storage user = userInfo[_stakingToken][_account];

        if (!_isVlMgp && user.available < _amount)
            revert WithdrawAmountExceedsStaked();
        else if(user.amount < _amount && _isVlMgp)
            revert UnlockAmountExceedsLocked();
        
        _harvestMGP(_stakingToken, _account);
        _harvestBaseRewarder(_stakingToken, _account);

        user.amount = user.amount - _amount;
        
        if(!_isVlMgp)
            user.available = user.available - _amount;
        user.rewardDebt = (user.amount * tokenToPoolInfo[_stakingToken].accMGPPerShare) / 1e12;
    }

    function _multiClaim(address[] calldata _stakingTokens, address _user, address _receiver, address[][] memory _rewardTokens) internal nonReentrant {
        uint256 length = _stakingTokens.length;
        if (length != _rewardTokens.length) revert LengthMismatch();

        uint256 vlMGPPoolAmount;
        uint256 mWOmPoolAmount;
        uint256 defaultPoolAmount;

        for (uint256 i = 0; i < length; ++i) {
            address _stakingToken = _stakingTokens[i];
            UserInfo storage user = userInfo[_stakingToken][_user];
            
            updatePool(_stakingToken);
            uint256 claimableMgp = _calNewMGP(_stakingToken, _user) + unClaimedMgp[_stakingToken][_user];

            if (_stakingToken == address(vlmgp)) {
                vlMGPPoolAmount += claimableMgp;
            } else if (MPGRewardPool[_stakingToken]) {
                mWOmPoolAmount += claimableMgp;
            } else {
                defaultPoolAmount += claimableMgp;
            }

            unClaimedMgp[_stakingToken][_user] = 0;
            user.rewardDebt = (user.amount * tokenToPoolInfo[_stakingToken].accMGPPerShare) / 1e12;
            _claimBaseRewarder(_stakingToken, _user, _receiver, _rewardTokens[i]);
        }

        if (vlMGPPoolAmount > 0) {
            _sendMGPForVlMGPPool(_user, _receiver, vlMGPPoolAmount);
        }

        if (mWOmPoolAmount > 0) {
            _sendMGP(_user, _receiver, mWOmPoolAmount);
        }

        if (defaultPoolAmount > 0) {
            _sendVlMGPFor(_user, _receiver, defaultPoolAmount);
        }
    }

    /// @notice calculate MGP reward based at current timestamp, for frontend only
    function _calMGPReward(address _stakingToken, address _user) internal view returns(uint256 pendingMGP) {
        PoolInfo storage pool = tokenToPoolInfo[_stakingToken];
        UserInfo storage user = userInfo[_stakingToken][_user];
        uint256 accMGPPerShare = pool.accMGPPerShare;
        uint256 lpSupply = _calLpSupply(_stakingToken);

        if (block.timestamp > pool.lastRewardTimestamp && lpSupply != 0) {
            uint256 multiplier = block.timestamp - pool.lastRewardTimestamp;
            uint256 mgpReward = (multiplier * mgpPerSec * pool.allocPoint) /
            totalAllocPoint;
            accMGPPerShare = accMGPPerShare + (mgpReward * 1e12) / lpSupply;
        }

        pendingMGP = (user.amount * accMGPPerShare) / 1e12 - user.rewardDebt;
        pendingMGP += unClaimedMgp[_stakingToken][_user];
    }

    /// @notice Harvest MGP for an account
    /// only update the reward counting but not sending them to user
    function _harvestMGP(address _stakingToken, address _account) internal {
        // Harvest MGP
        uint256 pending = _calNewMGP(_stakingToken, _account);
        unClaimedMgp[_stakingToken][_account] += pending;
    }

    /// @notice calculate MGP reward based on current accMGPPerShare
    function _calNewMGP(address _stakingToken, address _account) view internal returns(uint256) {
        UserInfo storage user = userInfo[_stakingToken][_account];
        uint256 pending = (user.amount * tokenToPoolInfo[_stakingToken].accMGPPerShare) /
            1e12 -
            user.rewardDebt;
        return pending;
    }

    /// @notice Harvest reward token in BaseRewarder for an account. NOTE: Baserewarder use user staking token balance as source to
    /// calculate reward token amount
    function _claimBaseRewarder(address _stakingToken, address _account, address _receiver, address[] memory _rewardTokens) internal {
        IBaseRewardPool rewarder = IBaseRewardPool(tokenToPoolInfo[_stakingToken].rewarder);
        if (address(rewarder) != address(0)) {
            if (_rewardTokens.length > 0)
                rewarder.getRewards(_account, _receiver, _rewardTokens);
            else
                // if not specifiying any reward token, just claim them all
                rewarder.getReward(_account, _receiver);
        }
    }

    /// only update the reward counting on in base rewarder but not sending them to user
    function _harvestBaseRewarder(address _stakingToken, address _account) internal {
        IBaseRewardPool rewarder = IBaseRewardPool(tokenToPoolInfo[_stakingToken].rewarder);
        if (address(rewarder) != address(0))
            rewarder.updateFor(_account);
        // needs to sync legacy rewarder reward and paid per token  as well, TODO let's try to remove this 2 - 4 weeks after migration for gas optimization
        // if (address(legacyRewarder[_stakingToken]) != address(0))
        //     IBaseRewardPool(legacyRewarder[_stakingToken]).updateFor(_account);
    }

    function _sendMGPForVlMGPPool(address _account, address _receiver, uint256 _amount) internal {
        address vlMGPRewarder = tokenToPoolInfo[address(vlmgp)].rewarder;
        IERC20(mgp).safeApprove(vlMGPRewarder, _amount);
        IvlmgpPBaseRewarder(vlMGPRewarder).queueMGP(_amount, _account, _receiver);

        emit HarvestMGP(_account, _receiver, _amount, false);
    }

    function _sendMGP(address _account, address _receiver, uint256 _amount) internal {
        IERC20(mgp).safeTransfer(_receiver, _amount);

        emit HarvestMGP(_account, _receiver, _amount, false);
    }

    function _sendVlMGPFor(address _account, address _receiver, uint256 _amount) internal {
        IERC20(mgp).safeApprove(address(vlmgp), _amount);
        vlmgp.lockFor(_amount, _account);

        emit HarvestMGP(_account, _receiver, _amount, true);
    }

    function _calLpSupply(address _stakingToken) internal view returns (uint256) {
        if (_stakingToken == address(vlmgp))
            return IERC20(address(vlmgp)).totalSupply();

        return IERC20(_stakingToken).balanceOf(address(this));
    }

    /* ============ Admin Functions ============ */
    /// @notice Used to give edit rights to the pools in this contract to a Pool Manager
    /// @param _account Pool Manager Adress
    /// @param _allowedManager True gives rights, False revokes them
    function setPoolManagerStatus(address _account, bool _allowedManager)
        external
        onlyOwner
    {
        PoolManagers[_account] = _allowedManager;    

        emit PoolManagerStatus(_account, PoolManagers[_account]);
    }

    function setMgp(address _mgp) external onlyOwner {
        if(address(mgp) != address(0))
            revert MGPsetAlready();

        if (!Address.isContract(_mgp))
            revert MustBeContract();

        mgp = MGP(_mgp);
        emit MGPSet(_mgp);
    }

    function setCompounder(address _compounder)
        external
        onlyOwner
    {
        address oldCompounder = compounder;
        compounder = _compounder;
        emit CompounderUpated(compounder, oldCompounder);
    }

    function setVlmgp(address _vlmgp)
        external
        onlyOwner
    {
        address oldVlmgp = address(vlmgp);
        vlmgp = IVLMGP(_vlmgp);
        emit VLMGPUpdated(address(vlmgp), oldVlmgp);
    }

    function setMGPRewardPools(address _stakingToken, bool _isLockFree) external onlyOwner {
        MPGRewardPool[_stakingToken] = _isLockFree;

        emit LockFreePoolUpdated(_stakingToken, MPGRewardPool[_stakingToken]);
    }    

    /**
     * @dev pause pool, restricting certain operations
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @dev unpause pool, enabling certain operations
     */
    function unpause() external onlyOwner {
        _unpause();
    }   

    /// @notice Add a new rewarder to the pool. Can only be called by a PoolManager.
    /// @param _stakingToken Staking token of the pool
    /// @param mainRewardToken Token that will be rewarded for staking in the pool
    /// @return address of the rewarder created
    function createRewarder(address _stakingToken, address mainRewardToken)
        external
        _onlyPoolManager
        returns (address)
    {
        BaseRewardPoolV2 _rewarder = new BaseRewardPoolV2(
            _stakingToken,
            mainRewardToken,
            address(this),
            msg.sender
        );
        return address(_rewarder);
    }

    /// @notice Add a new pool. Can only be called by a PoolManager.
    /// @param _allocPoint Allocation points of MGP to the pool
    /// @param _stakingToken Staking token of the pool
    /// @param _rewarder Address of the rewarder for the pool
    /// @param _helper Address of the helper for the pool
    /// @param _helperNeedsHarvest Address of the helper for the pool
    function add(
        uint256 _allocPoint,
        address _stakingToken,
        address _rewarder,
        address _helper,
        bool _helperNeedsHarvest
    ) external _onlyPoolManager {
        if (!Address.isContract(address(_stakingToken)))
            revert InvalidStakingToken();

        if (!Address.isContract(address(_helper)) && address(_helper) != address(0))
            revert MustBeContractOrZero();

        if (!Address.isContract(address(_rewarder)) && address(_rewarder) != address(0))
            revert MustBeContractOrZero();

        if (openPools[_stakingToken])
            revert PoolExsisted();

        massUpdatePools();
        uint256 lastRewardTimestamp = block.timestamp > startTimestamp
            ? block.timestamp
            : startTimestamp;
        totalAllocPoint = totalAllocPoint + _allocPoint;
        registeredToken.push(_stakingToken);
        tokenToPoolInfo[_stakingToken] = PoolInfo({
            stakingToken: _stakingToken,
            allocPoint: _allocPoint,
            lastRewardTimestamp: lastRewardTimestamp,
            accMGPPerShare: 0,
            rewarder: _rewarder,
            helper: _helper,
            helperNeedsHarvest: _helperNeedsHarvest
        });
        openPools[_stakingToken] = true;
        emit Add(_allocPoint, _stakingToken, IBaseRewardPool(_rewarder));
    }

    /// @notice Updates the given pool's MGP allocation point, rewarder address and locker address if overwritten. Can only be called by a Pool Manager.
    /// @param _stakingToken Staking token of the pool
    /// @param _allocPoint Allocation points of MGP to the pool
    /// @param _rewarder Address of the rewarder for the pool
    function set(
        address _stakingToken,
        uint256 _allocPoint,
        address _helper,
        address _rewarder,
        bool _helperNeedsHarvest
    ) external _onlyPoolManager {
        if (!Address.isContract(address(_rewarder)) 
            && address(_rewarder) != address(0))
            revert MustBeContractOrZero();

        if (!Address.isContract(address(_helper)) 
            && address(_helper) != address(0))
            revert MustBeContractOrZero();            

        if (!openPools[_stakingToken])
            revert OnlyActivePool();

        massUpdatePools();

        totalAllocPoint = 
            totalAllocPoint - 
            tokenToPoolInfo[_stakingToken].allocPoint +
            _allocPoint;

        tokenToPoolInfo[_stakingToken].allocPoint = _allocPoint;
        tokenToPoolInfo[_stakingToken].rewarder = _rewarder;
        tokenToPoolInfo[_stakingToken].helper = _helper;
        tokenToPoolInfo[_stakingToken].helperNeedsHarvest = _helperNeedsHarvest;

        emit Set(
            _stakingToken,
            _allocPoint,
            IBaseRewardPool(tokenToPoolInfo[_stakingToken].rewarder)
        );
    }

    function setLegacyRewarder(address _stakingToken, address _legacyRewarder) external onlyOwner {
        legacyRewarder[_stakingToken] = _legacyRewarder;
    }

    /// @notice Update the emission rate of MGP for MasterMagpie
    /// @param _mgpPerSec new emission per second
    function updateEmissionRate(uint256 _mgpPerSec) public onlyOwner {        
        massUpdatePools();
        uint256 oldEmissionRate = mgpPerSec;
        mgpPerSec = _mgpPerSec;

        emit UpdateEmissionRate(msg.sender, oldEmissionRate, mgpPerSec);
    }

    function updatePoolsAlloc(address[] calldata _stakingTokens, uint256[] calldata _allocPoints) external onlyOwner {
        massUpdatePools();

        if (_stakingTokens.length != _allocPoints.length)
            revert LengthMismatch();

        for (uint256 i = 0; i < _stakingTokens.length; i++) {
            uint256 oldAllocPoint = tokenToPoolInfo[_stakingTokens[i]].allocPoint;

            totalAllocPoint = totalAllocPoint - oldAllocPoint + _allocPoints[i];

            tokenToPoolInfo[_stakingTokens[i]].allocPoint = _allocPoints[i];

            emit UpdatePoolAlloc(_stakingTokens[i], oldAllocPoint, _allocPoints[i]);
        }
    }

    // BaseRewarePool manager functions

    function updateRewarderManager(address _rewarder, address _manager, bool _allowed) external onlyOwner {
        IBaseRewardPool rewarder = IBaseRewardPool(_rewarder);
        rewarder.updateManager(_manager, _allowed);
    }
}