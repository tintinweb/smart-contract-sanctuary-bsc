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
// OpenZeppelin Contracts (last updated v4.8.1) (proxy/utils/Initializable.sol)

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
     * @dev Returns the highest version that has been initialized. See {reinitializer}.
     */
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    /**
     * @dev Returns `true` if the contract is currently initializing. See {onlyInitializing}.
     */
    function _isInitializing() internal view returns (bool) {
        return _initializing;
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
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

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
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
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
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
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
    constructor() {
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

/**
 * @author Musket
 */
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

import "../libraries/amm/Liquidity.sol";

interface IAutoMarketMakerCore {
    struct AddLiquidity {
        uint128 baseAmount;
        uint128 quoteAmount;
        uint32 indexedPipRange;
    }

    /// @notice Add liquidity and mint the NFT
    /// @param params Struct AddLiquidity
    /// @dev Depends on data struct with base amount, quote amount and index pip
    /// calculate the liquidity and increase liquidity at index pip
    /// @return baseAmountAdded the base amount will be added
    /// @return quoteAmountAdded the quote amount will be added
    /// @return liquidity calculate from quote and base amount
    /// @return feeGrowthBase tracking growth base
    /// @return feeGrowthQuote tracking growth quote
    function addLiquidity(AddLiquidity calldata params)
        external
        returns (
            uint128 baseAmountAdded,
            uint128 quoteAmountAdded,
            uint256 liquidity,
            uint256 feeGrowthBase,
            uint256 feeGrowthQuote
        );

    /// @notice the struct for remove liquidity avoid deep stack
    struct RemoveLiquidity {
        uint128 liquidity;
        uint32 indexedPipRange;
        uint256 feeGrowthBase;
        uint256 feeGrowthQuote;
    }

    /// @notice Remove liquidity in index pip of nft
    /// @param params Struct Remove liquidity
    /// @dev remove liquidity at index pip and decrease the data of liquidity info
    /// @return baseAmount base amount receive
    /// @return quoteAmount quote amount receive
    function removeLiquidity(RemoveLiquidity calldata params)
        external
        returns (uint128 baseAmount, uint128 quoteAmount);

    /// @notice estimate amount receive when remove liquidity in index pip
    /// @param params struct Remove liquidity
    /// @dev calculate amount of quote and base
    /// @return baseAmount base amount receive
    /// @return quoteAmount quote amount receive
    /// @return liquidityInfo newest of liquidity info
    function estimateRemoveLiquidity(RemoveLiquidity calldata params)
        external
        view
        returns (
            uint128 baseAmount,
            uint128 quoteAmount,
            Liquidity.Info memory liquidityInfo
        );

    /// @notice get liquidity info of any index pip range
    /// @param index want to get info
    /// @dev load data from storage and return
    /// @return sqrtMaxPip sqrt of max pip
    /// @return sqrtMinPip sqrt of min pip
    /// @return quoteReal quote real of liquidity of index
    /// @return baseReal base real of liquidity of index
    /// @return indexedPipRange index of liquidity info
    /// @return feeGrowthBase the growth of base
    /// @return feeGrowthQuote the growth of base
    /// @return sqrtK sqrt of k=quoteReal*baseReal,
    function liquidityInfo(uint256 index)
        external
        view
        returns (
            uint128 sqrtMaxPip,
            uint128 sqrtMinPip,
            uint128 quoteReal,
            uint128 baseReal,
            uint32 indexedPipRange,
            uint256 feeGrowthBase,
            uint256 feeGrowthQuote,
            uint128 sqrtK
        );

    /// @notice get current index pip range
    /// @dev load current index pip range from storage
    /// @return The current pip range
    function pipRange() external view returns (uint128);

    /// @notice get the tick space for external generate orderbook
    /// @dev load current tick space from storage
    /// @return the config tick space
    function tickSpace() external view returns (uint32);

    /// @notice get current index pip range
    /// @dev load current current index pip range from storage
    /// @return the current index pip range
    function currentIndexedPipRange() external view returns (uint256);

    /// @notice get percent fee will be share when market order fill
    /// @dev load config fee from storage
    /// @return the config fee
    function feeShareAmm() external view returns (uint32);
}

/**
 * @author Musket
 */
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

interface IFee {
    /// @notice decrease the fee base
    /// @param baseFee will be decreased
    /// @dev minus the fee base funding
    function decreaseBaseFeeFunding(uint256 baseFee) external;

    /// @notice decrease the fee quote
    /// @param quoteFee will be decreased
    /// @dev minus the fee quote funding
    function decreaseQuoteFeeFunding(uint256 quoteFee) external;

    /// @notice increase the fee base
    /// @param baseFee will be decreased
    /// @dev plus the fee base funding
    function increaseBaseFeeFunding(uint256 baseFee) external;

    /// @notice increase the fee quote`
    /// @param quoteFee will be decreased
    /// @dev plus the fee quote funding
    function increaseQuoteFeeFunding(uint256 quoteFee) external;

    /// @notice reset the fee funding to zero when Position claim fee
    /// @param baseFee will be decreased
    /// @param quoteFee will be decreased
    /// @dev reset baseFee and quoteFee to zero
    function resetFee(uint256 baseFee, uint256 quoteFee) external;

    /// @notice get the fee base funding and fee quote funding
    /// @dev load amount quote and base
    /// @return baseFeeFunding and quoteFeeFunding
    function getFee()
        external
        view
        returns (uint256 baseFeeFunding, uint256 quoteFeeFunding);
}

/**
 * @author Musket
 */
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./IAutoMarketMakerCore.sol";
import "./IMatchingEngineCore.sol";
import "./IFee.sol";

interface IMatchingEngineAMM is
    IFee,
    IAutoMarketMakerCore,
    IMatchingEngineCore
{
    struct InitParams {
        IERC20 quoteAsset;
        IERC20 baseAsset;
        uint256 basisPoint;
        uint128 maxFindingWordsIndex;
        uint128 initialPip;
        uint128 pipRange;
        uint32 tickSpace;
        address owner;
        address positionLiquidity;
        address spotHouse;
        address router;
        uint32 feeShareAmm;
    }

    struct ExchangedData {
        uint256 baseAmount;
        uint256 quoteAmount;
        uint256 feeQuoteAmount;
        uint256 feeBaseAmount;
    }

    /// @notice init the pair right after cloned
    /// @param params the init params with struct InitParams
    /// @dev save storage the init data
    function initialize(InitParams memory params) external;

    /// @notice get the base and quote amount can claim
    /// @param pip the pip of the order
    /// @param orderId id of order in pip
    /// @param exData the base amount
    /// @param basisPoint the basis point of price
    /// @param fee the fee percent
    /// @param feeBasis the basis fee froe calculate
    /// @return the Exchanged data
    /// @dev calculate the base and quote from order and pip
    function accumulateClaimableAmount(
        uint128 pip,
        uint64 orderId,
        ExchangedData memory exData,
        uint256 basisPoint,
        uint16 fee,
        uint128 feeBasis
    ) external view returns (ExchangedData memory);
}

/**
 * @author Musket
 */
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

interface IMatchingEngineCore {
    struct LiquidityOfEachPip {
        uint128 pip;
        uint256 liquidity;
    }

    /// @notice Emitted when market order filled
    /// @param isBuy side of order
    /// @param amount amount filled
    /// @param toPip fill to pip
    /// @param startPip fill start pip
    /// @param remainingLiquidity remaining liquidity in pip
    /// @param filledIndex number of index filled
    event MarketFilled(
        bool isBuy,
        uint256 indexed amount,
        uint128 toPip,
        uint256 startPip,
        uint128 remainingLiquidity,
        uint64 filledIndex
    );

    /// @notice Emitted when market order filled
    /// @param orderId side of order
    /// @param pip amount filled
    /// @param size fill to pip
    /// @param isBuy fill start pip
    event LimitOrderCreated(
        uint64 orderId,
        uint128 pip,
        uint128 size,
        bool isBuy
    );

    /// @notice Emitted limit order cancel
    /// @param size size of order
    /// @param pip of order
    /// @param orderId id of order cancel
    /// @param isBuy fill start pip
    event LimitOrderCancelled(
        bool isBuy,
        uint64 orderId,
        uint128 pip,
        uint256 size
    );

    /// @notice Emitted when update max finding word
    /// @param pairManager address of pair
    /// @param newMaxFindingWordsIndex new value
    event UpdateMaxFindingWordsIndex(
        address pairManager,
        uint128 newMaxFindingWordsIndex
    );

    /// @notice Emitted when update max finding word for limit order
    /// @param newMaxWordRangeForLimitOrder new value
    event MaxWordRangeForLimitOrderUpdated(
        uint128 newMaxWordRangeForLimitOrder
    );

    /// @notice Emitted when update max finding word for market order
    /// @param newMaxWordRangeForMarketOrder new value
    event MaxWordRangeForMarketOrderUpdated(
        uint128 newMaxWordRangeForMarketOrder
    );

    /// @notice Emitted when snap shot reserve
    /// @param pip pip snap shot
    /// @param timestamp time snap shot
    event ReserveSnapshotted(uint128 pip, uint256 timestamp);

    /// @notice Emitted when limit order updated
    /// @param pairManager address of pair
    /// @param orderId id of order
    /// @param pip at order
    /// @param size of order
    event LimitOrderUpdated(
        address pairManager,
        uint64 orderId,
        uint128 pip,
        uint256 size
    );

    /// @notice Emitted when order fill for swap
    /// @param sender address of trader
    /// @param amount0In amount 0 int
    /// @param amount1In amount 1 in
    /// @param amount0Out amount 0 out
    /// @param amount1Out amount 1 out
    /// @param to swap for address
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );

    /// @notice Update the order when partial fill
    /// @param pip the price of order
    /// @param orderId id of order in pip
    function updatePartialFilledOrder(uint128 pip, uint64 orderId) external;

    /// @notice Cancel the limit order
    /// @param pip the price of order
    /// @param orderId id of order in pip
    function cancelLimitOrder(uint128 pip, uint64 orderId)
        external
        returns (uint256 remainingSize, uint256 partialFilled);

    /// @notice Open limit order with size and price
    /// @param pip the price of order
    /// @param baseAmountIn amount of base asset
    /// @param isBuy side of the limit order
    /// @param trader the owner of the limit order
    /// @param quoteAmountIn amount of quote asset
    /// @param feePercent fee of the order
    /// @dev Calculate the order in insert to queue
    /// @return orderId id of order in pip
    /// @return baseAmountFilled when can fill market amount has filled
    /// @return quoteAmountFilled when can fill market amount has filled
    /// @return fee when can fill market amount has filled
    function openLimit(
        uint128 pip,
        uint128 baseAmountIn,
        bool isBuy,
        address trader,
        uint256 quoteAmountIn,
        uint16 feePercent
    )
        external
        returns (
            uint64 orderId,
            uint256 baseAmountFilled,
            uint256 quoteAmountFilled,
            uint256 fee
        );

    /// @notice Open market order with size is base and price
    /// @param size the amount want to open market order
    /// @param isBuy the side of market order
    /// @param trader the owner of the market order
    /// @param feePercent fee of the order
    /// @dev Calculate full the market order with limit order in queue
    /// @return mainSideOut the amount fill of main asset
    /// @return flipSideOut the amount fill of main asset convert to flip asset
    /// @return fee the amount of fee
    function openMarket(
        uint256 size,
        bool isBuy,
        address trader,
        uint16 feePercent
    )
        external
        returns (
            uint256 mainSideOut,
            uint256 flipSideOut,
            uint256 fee
        );

    /// @notice Open market order with size is base and price
    /// @param quoteAmount the quote amount want to open market order
    /// @param isBuy the side of market order
    /// @param trader the owner of the market order
    /// @param feePercent fee of the order
    /// @dev Calculate full the market order with limit order in queue
    /// @return mainSideOut the amount fill of main asset
    /// @return flipSideOut the amount fill of main asset convert to flip asset
    /// @return fee the amount of fee
    function openMarketWithQuoteAsset(
        uint256 quoteAmount,
        bool isBuy,
        address trader,
        uint16 feePercent
    )
        external
        returns (
            uint256 mainSideOut,
            uint256 flipSideOut,
            uint256 fee
        );

    /// @notice check at this pip has liquidity
    /// @param pip the price of order
    /// @dev load and check flag of liquidity
    /// @return the bool of has liquidity
    function hasLiquidity(uint128 pip) external view returns (bool);

    /// @notice Get detail pending order
    /// @param pip the price of order
    /// @param orderId id of order in pip
    /// @dev Load pending order and calculate the amount of base and quote asset
    /// @return isFilled the order is filled
    /// @return isBuy the side of the order
    /// @return size the size of order
    /// @return partialFilled the amount partial order is filled
    function getPendingOrderDetail(uint128 pip, uint64 orderId)
        external
        view
        returns (
            bool isFilled,
            bool isBuy,
            uint256 size,
            uint256 partialFilled
        );

    /// @notice Get amount liquidity pending at current price
    /// @return the amount liquidity pending
    function getLiquidityInCurrentPip() external view returns (uint128);

    function getLiquidityInPipRange(
        uint128 fromPip,
        uint256 dataLength,
        bool toHigher
    ) external view returns (LiquidityOfEachPip[] memory, uint128);

    function getAmountEstimate(
        uint256 size,
        bool isBuy,
        bool isBase
    ) external view returns (uint256 mainSideOut, uint256 flipSideOut);

    function calculatingQuoteAmount(uint256 quantity, uint128 pip)
        external
        view
        returns (uint256);

    /// @notice Get basis point of pair
    /// @return the basis point of pair
    function basisPoint() external view returns (uint256);

    /// @notice Get current price
    /// @return return the current price
    function getCurrentPip() external view returns (uint128);

    /// @notice Calculate the amount of quote asset
    /// @param quoteAmount the quote amount
    /// @param pip the price
    /// @return the base converted
    function quoteToBase(uint256 quoteAmount, uint128 pip)
        external
        view
        returns (uint256);
}

/**
 * @author Musket
 */
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

library Liquidity {
    struct Info {
        uint128 sqrtMaxPip;
        uint128 sqrtMinPip;
        uint128 quoteReal;
        uint128 baseReal;
        uint32 indexedPipRange;
        uint256 feeGrowthBase;
        uint256 feeGrowthQuote;
        uint128 sqrtK;
    }

    /// @notice Define the new pip range when the first time add liquidity
    /// @param self the liquidity info
    /// @param sqrtMaxPip the max pip
    /// @param sqrtMinPip the min pip
    /// @param indexedPipRange the index of liquidity info
    function initNewPipRange(
        Liquidity.Info storage self,
        uint128 sqrtMaxPip,
        uint128 sqrtMinPip,
        uint32 indexedPipRange
    ) internal {
        self.sqrtMaxPip = sqrtMaxPip;
        self.sqrtMinPip = sqrtMinPip;
        self.indexedPipRange = indexedPipRange;
    }

    /// @notice update the liquidity info when add liquidity
    /// @param self the liquidity info
    /// @param updater of struct Liquidity.Info, this is new value of liquidity info
    function updateAddLiquidity(
        Liquidity.Info storage self,
        Liquidity.Info memory updater
    ) internal {
        if (self.sqrtK == 0) {
            self.sqrtMaxPip = updater.sqrtMaxPip;
            self.sqrtMinPip = updater.sqrtMinPip;
            self.indexedPipRange = updater.indexedPipRange;
        }
        self.quoteReal = updater.quoteReal;
        self.baseReal = updater.baseReal;
        self.sqrtK = updater.sqrtK;
    }

    /// @notice growth fee base and quote
    /// @param self the liquidity info
    /// @param feeGrowthBase the growth of base
    /// @param feeGrowthQuote the growth of base
    function updateFeeGrowth(
        Liquidity.Info storage self,
        uint256 feeGrowthBase,
        uint256 feeGrowthQuote
    ) internal {
        self.feeGrowthBase = feeGrowthBase;
        self.feeGrowthQuote = feeGrowthQuote;
    }

    /// @notice update the liquidity info when after trade and save to storage
    /// @param self the liquidity info
    /// @param baseReserve the new value of baseReserve
    /// @param quoteReserve the new value of quoteReserve
    /// @param feeGrowth new growth value increase
    /// @param isBuy the side of trade
    function updateAMMReserve(
        Liquidity.Info storage self,
        uint128 quoteReserve,
        uint128 baseReserve,
        uint256 feeGrowth,
        bool isBuy
    ) internal {
        self.quoteReal = quoteReserve;
        self.baseReal = baseReserve;

        if (isBuy) {
            self.feeGrowthBase += feeGrowth;
        } else {
            self.feeGrowthQuote += feeGrowth;
        }
    }
}

/**
 * @author Musket
 */
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

library Convert {
    function Uint256ToUint128(uint256 x) internal pure returns (uint128) {
        return uint128(x);
    }

    function Uint256ToUint64(uint256 x) internal pure returns (uint64) {
        return uint64(x);
    }

    function Uint256ToUint32(uint256 x) internal pure returns (uint32) {
        return uint32(x);
    }

    function toI256(uint256 x) internal pure returns (int256) {
        return int256(x);
    }

    function toI128(uint256 x) internal pure returns (int128) {
        return int128(int256(x));
    }

    function abs(int256 x) internal pure returns (uint256) {
        return uint256(x >= 0 ? x : -x);
    }

    function abs256(int128 x) internal pure returns (uint256) {
        return uint256(uint128(x >= 0 ? x : -x));
    }

    function toU128(uint256 x) internal pure returns (uint128) {
        return uint128(x);
    }

    function Uint256ToUint40(uint256 x) internal pure returns (uint40) {
        return uint40(x);
    }
}

/**
 * @author Musket
 */
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

/// @title FixedPoint128
/// @notice A library for handling binary fixed point numbers, see https://en.wikipedia.org/wiki/Q_(number_format)
library FixedPoint128 {
    uint256 internal constant Q128 = 0x100000000000000000000000000000000;
    uint256 internal constant BUFFER = 10**24;
    uint256 internal constant Q_POW18 = 10**18;
    uint256 internal constant HALF_BUFFER = 10**12;
    uint32 internal constant BASIC_POINT_FEE = 10_000;
    uint8 internal constant MAX_FIND_INDEX_RANGE = 4;
}

/**
 * @author Musket
 */
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

/// @notice this library is used to reduce size contract when require condition
library Require {
    function _require(bool condition, string memory reason) internal pure {
        require(condition, reason);
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

library TradeConvert {
    /// @notice convert from base amount to quote amount by pip
    /// @param quantity the base amount
    /// @param pip the pip
    /// @param basisPoint the basis point to calculate amount
    /// @return quote amount
    function baseToQuote(
        uint256 quantity,
        uint128 pip,
        uint256 basisPoint
    ) internal pure returns (uint256) {
        // quantity * pip / baseBasisPoint / basisPoint / baseBasisPoint;
        // shorten => quantity * pip / basisPoint ;
        return (quantity * pip) / basisPoint;
    }

    /// @notice convert from quote amount to base amount by pip
    /// @param quoteAmount the base amount
    /// @param pip the pip
    /// @param basisPoint the basis point to calculate amount
    /// @return base amount
    function quoteToBase(
        uint256 quoteAmount,
        uint128 pip,
        uint256 basisPoint
    ) internal pure returns (uint256) {
        return (quoteAmount * basisPoint) / pip;
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

abstract contract Block {
    /// @notice get the block timestamp
    /// @return the block time stamp
    function _blockTimestamp() internal view virtual returns (uint64) {
        return uint64(block.timestamp);
    }

    /// @notice get the block number
    /// @return the block number
    function _blockNumber() internal view virtual returns (uint64) {
        return uint64(block.number);
    }
}

/**
 * @author Musket
 */
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

import "@positionex/matching-engine/contracts/interfaces/IMatchingEngineAMM.sol";
import "@positionex/matching-engine/contracts/libraries/helper/TradeConvert.sol";
import "@positionex/matching-engine/contracts/libraries/helper/Require.sol";
import "@positionex/matching-engine/contracts/libraries/helper/FixedPoint128.sol";
import "@positionex/matching-engine/contracts/libraries/helper/Convert.sol";

import "../libraries/types/SpotFactoryStorage.sol";
import "../libraries/types/SpotHouseStorage.sol";
import "../libraries/types/SpotHouseStorage.sol";
import "./Block.sol";
import "../interfaces/ISpotDex.sol";

abstract contract SpotDex is ISpotDex, SpotHouseStorage {
    using Convert for uint256;

    /**
     * @dev see {ISpotDex-openLimitOrder}
     */
    function openLimitOrder(
        IMatchingEngineAMM pairManager,
        Side side,
        uint256 quantity,
        uint128 pip
    ) public payable virtual {
        address trader = _msgSender();
        _openLimitOrder(pairManager, quantity, pip, trader, side);
    }

    /**
     * @dev see {ISpotDex-openBuyLimitOrderWithQuote}
     */
    function openBuyLimitOrderWithQuote(
        IMatchingEngineAMM pairManager,
        Side side,
        uint256 quoteAmount,
        uint128 pip
    ) public payable virtual {
        Require._require(side == Side.BUY, DexErrors.DEX_MUST_ORDER_BUY);
        _openBuyLimitOrderWithQuote(
            pairManager,
            quoteAmount,
            pip,
            _msgSender()
        );
    }

    /**
     * @dev see {ISpotDex-openMarketOrder}
     */
    function openMarketOrder(
        IMatchingEngineAMM pairManager,
        Side side,
        uint256 quantity
    ) public payable virtual {
        _openMarketOrder(pairManager, side, quantity, _msgSender());
    }

    /**
     * @dev see {ISpotDex-openMarketOrderWithQuote}
     */
    function openMarketOrderWithQuote(
        IMatchingEngineAMM pairManager,
        Side side,
        uint256 quoteAmount
    ) public payable virtual {
        _openMarketOrderWithQuote(pairManager, side, quoteAmount, _msgSender());
    }

    /**
     * @dev see {ISpotDex-cancelAllLimitOrder}
     */
    function cancelAllLimitOrder(IMatchingEngineAMM pairManager)
        public
        virtual
    {
        address _trader = _msgSender();
        uint256 refundQuote;
        uint256 refundBase;
        uint256 quoteFilled;
        uint256 baseFilled;
        uint256 basicPoint;

        (quoteFilled, baseFilled, basicPoint) = getAmountClaimable(
            pairManager,
            _trader
        );

        PendingLimitOrder[]
            memory _listPendingLimitOrder = getPendingLimitOrders(
                pairManager,
                _trader
            );

        Require._require(
            _listPendingLimitOrder.length > 0,
            DexErrors.DEX_NO_LIMIT_TO_CANCEL
        );

        uint128[] memory _listPips = new uint128[](
            _listPendingLimitOrder.length
        );

        uint64[] memory _orderIds = new uint64[](_listPendingLimitOrder.length);

        Side[] memory _listSides = new Side[](_listPendingLimitOrder.length);

        for (uint64 i = 0; i < _listPendingLimitOrder.length; i++) {
            PendingLimitOrder
                memory _pendingLimitOrder = _listPendingLimitOrder[i];

            if (_pendingLimitOrder.quantity == 0) {
                continue;
            }

            _listPips[i] = _pendingLimitOrder.pip;
            _orderIds[i] = _pendingLimitOrder.orderId;
            _listSides[i] = _pendingLimitOrder.isBuy ? Side.BUY : Side.SELL;

            (uint256 refundQuantity, ) = pairManager.cancelLimitOrder(
                _pendingLimitOrder.pip,
                _pendingLimitOrder.orderId
            );

            if (_pendingLimitOrder.isBuy) {
                refundQuote += _baseToQuote(
                    refundQuantity,
                    _pendingLimitOrder.pip,
                    basicPoint
                );
            } else {
                refundBase += refundQuantity;
            }
        }

        delete limitOrders[address(pairManager)][_trader];

        _withdrawCancelAll(
            pairManager,
            _trader,
            Asset.Quote,
            refundQuote,
            quoteFilled
        );
        _withdrawCancelAll(
            pairManager,
            _trader,
            Asset.Base,
            refundBase,
            baseFilled
        );

        emitAllLimitOrderCancelled(
            _trader,
            pairManager,
            _listPips,
            _orderIds,
            _listSides
        );
    }

    /**
     * @dev see {ISpotDex-cancelLimitOrder}
     */
    function cancelLimitOrder(
        IMatchingEngineAMM pairManager,
        uint64 orderIdx,
        uint128 pip
    ) public virtual {
        address _trader = _msgSender();
        uint256 basicPoint = _basisPoint(pairManager);

        SpotLimitOrder.Data[] storage _orders = limitOrders[
            address(pairManager)
        ][_trader];
        Require._require(
            orderIdx < _orders.length,
            DexErrors.DEX_INVALID_ORDER_ID
        );

        // save gas
        SpotLimitOrder.Data memory _order = _orders[orderIdx];

        Require._require(
            _order.baseAmount != 0 && _order.quoteAmount != 0,
            DexErrors.DEX_NO_LIMIT_TO_CANCEL
        );

        (bool isFilled, , , ) = pairManager.getPendingOrderDetail(
            _order.pip,
            _order.orderId
        );

        Require._require(
            isFilled == false,
            DexErrors.DEX_ORDER_MUST_NOT_FILLED
        );

        (uint256 refundQuantity, uint256 partialFilled) = pairManager
            .cancelLimitOrder(_order.pip, _order.orderId);

        if (_order.isBuy) {
            uint256 quoteAmount = _baseToQuote(
                refundQuantity,
                _order.pip,
                basicPoint
            );

            _withdraw(pairManager, _trader, Asset.Quote, quoteAmount, false);
            _withdraw(pairManager, _trader, Asset.Base, partialFilled, true);
        } else {
            _withdraw(pairManager, _trader, Asset.Base, refundQuantity, false);
            if (partialFilled > 0) {
                _withdraw(
                    pairManager,
                    _trader,
                    Asset.Quote,
                    _baseToQuote(partialFilled, _order.pip, basicPoint),
                    true
                );
            }
        }
        delete _orders[orderIdx];

        emitLimitOrderCancelled(
            _trader,
            pairManager,
            _order.pip,
            _order.isBuy ? Side.BUY : Side.SELL,
            _order.orderId
        );
    }

    /**
     * @dev see {ISpotDex-claimAsset}
     */
    function claimAsset(IMatchingEngineAMM pairManager) public virtual {
        address _trader = _msgSender();

        (
            uint256 quoteAmount,
            uint256 baseAmount,
            uint256 basicPoint
        ) = getAmountClaimable(pairManager, _trader);
        Require._require(
            quoteAmount > 0 || baseAmount > 0,
            DexErrors.DEX_NO_AMOUNT_TO_CLAIM
        );
        _clearLimitOrder(address(pairManager), _trader, basicPoint);

        _withdraw(pairManager, _trader, Asset.Quote, quoteAmount, true);
        _withdraw(pairManager, _trader, Asset.Base, baseAmount, true);

        emit AssetClaimed(_trader, pairManager, quoteAmount, baseAmount);
    }

    /**
     * @dev see {ISpotDex-getAmountClaimable}
     */
    function getAmountClaimable(IMatchingEngineAMM pairManager, address trader)
        public
        view
        virtual
        returns (
            uint256 quoteAmount,
            uint256 baseAmount,
            uint256 basisPoint
        )
    {
        address _pairManagerAddress = address(pairManager);

        SpotLimitOrder.Data[] memory listLimitOrder = limitOrders[
            _pairManagerAddress
        ][trader];
        uint256 i = 0;
        basisPoint = _basisPoint(pairManager);
        uint128 _feeBasis = FixedPoint128.BASIC_POINT_FEE;
        IMatchingEngineAMM.ExchangedData memory exData = IMatchingEngineAMM
            .ExchangedData({
                baseAmount: 0,
                quoteAmount: 0,
                feeQuoteAmount: 0,
                feeBaseAmount: 0
            });
        for (i; i < listLimitOrder.length; i++) {
            if (listLimitOrder[i].pip == 0 && listLimitOrder[i].orderId == 0)
                continue;
            exData = pairManager.accumulateClaimableAmount(
                listLimitOrder[i].pip,
                listLimitOrder[i].orderId,
                exData,
                basisPoint,
                listLimitOrder[i].fee,
                _feeBasis
            );
        }
        return (exData.quoteAmount, exData.baseAmount, basisPoint);
    }

    /**
     * @dev see {ISpotDex-getPendingLimitOrders}
     */
    function getPendingLimitOrders(
        IMatchingEngineAMM pairManager,
        address trader
    ) public view virtual returns (PendingLimitOrder[] memory) {
        address _pairManagerAddress = address(pairManager);
        SpotLimitOrder.Data[] storage listLimitOrder = limitOrders[
            _pairManagerAddress
        ][trader];
        PendingLimitOrder[]
            memory listPendingOrderData = new PendingLimitOrder[](
                listLimitOrder.length
            );
        uint256 index = 0;
        for (uint256 i = 0; i < listLimitOrder.length; i++) {
            (
                bool isFilled,
                bool isBuy,
                uint256 quantity,
                uint256 partialFilled
            ) = pairManager.getPendingOrderDetail(
                    listLimitOrder[i].pip,
                    listLimitOrder[i].orderId
                );
            if (!isFilled) {
                listPendingOrderData[index] = PendingLimitOrder({
                    isBuy: isBuy,
                    quantity: quantity,
                    partialFilled: partialFilled,
                    pip: listLimitOrder[i].pip,
                    blockNumber: listLimitOrder[i].blockNumber,
                    orderIdOfTrader: i,
                    orderId: listLimitOrder[i].orderId,
                    fee: listLimitOrder[i].fee
                });
                index++;
            }
        }
        for (uint256 i = 0; i < listPendingOrderData.length; i++) {
            if (listPendingOrderData[i].quantity != 0) {
                return listPendingOrderData;
            }
        }
        PendingLimitOrder[] memory blankListPendingOrderData;
        return blankListPendingOrderData;
    }

    /**
     * @dev see {ISpotDex-getBatchPendingLimitOrdersByTrader}
     */
    function getBatchPendingLimitOrdersByTrader(
        IMatchingEngineAMM pairManager,
        address[] memory traders
    ) public view returns (BatchPendingLimitOrder[] memory batchPendingOrders) {
        batchPendingOrders = new BatchPendingLimitOrder[](traders.length);
        for (uint256 i = 0; i < traders.length; i++) {
            batchPendingOrders[i].instance = traders[i];
            batchPendingOrders[i].pendingOrders = getPendingLimitOrders(
                pairManager,
                traders[i]
            );
        }
    }

    /**
     * @dev see {ISpotDex-getBatchPendingLimitOrdersByPair}
     */
    function getBatchPendingLimitOrdersByPair(
        IMatchingEngineAMM[] memory pairManagers,
        address trader
    ) public view returns (BatchPendingLimitOrder[] memory batchPendingOrders) {
        batchPendingOrders = new BatchPendingLimitOrder[](pairManagers.length);
        for (uint256 i = 0; i < pairManagers.length; i++) {
            batchPendingOrders[i].instance = address(pairManagers[i]);
            batchPendingOrders[i].pendingOrders = getPendingLimitOrders(
                pairManagers[i],
                trader
            );
        }
    }

    /**
     * @dev see {ISpotDex-getOrderIdOfTrader}
     */
    function getOrderIdOfTrader(
        address pairManager,
        address trader,
        uint128 pip,
        uint64 orderId
    ) public view returns (int256) {
        SpotLimitOrder.Data[] memory limitOrder = limitOrders[pairManager][
            trader
        ];

        for (uint256 i = 0; i < limitOrder.length; i++) {
            if (limitOrder[i].pip == pip && limitOrder[i].orderId == orderId) {
                return int256(i);
            }
        }
        return -1;
    }

    function _getQuoteAndBase(IMatchingEngineAMM _managerAddress)
        internal
        view
        virtual
        returns (SpotFactoryStorage.Pair memory pair)
    {}

    struct OpenLimitOrderState {
        uint64 orderId;
        uint256 sizeOut;
        uint256 quoteAmountFilled;
        uint256 feeAmount;
        uint256 basicPoint;
    }

    function _openLimitOrder(
        IMatchingEngineAMM _pairManager,
        uint256 _quantity,
        uint128 _pip,
        address _trader,
        Side _side
    ) internal {
        address _pairManagerAddress = address(_pairManager);
        OpenLimitOrderState memory state;
        uint256 quoteAmount;
        state.basicPoint = _basisPoint(_pairManager);
        uint16 fee = _getFee();
        bool isBuy = _side == Side.BUY ? true : false;
        if (!isBuy) {
            // Sell limit
            // deposit base asset
            // with token has RFI we need deposit first
            // and get real balance transferred
            _quantity = _deposit(
                _pairManager,
                _trader,
                Asset.Base,
                _quantity.Uint256ToUint128()
            );
        }
        (
            state.orderId,
            state.sizeOut,
            state.quoteAmountFilled,
            state.feeAmount
        ) = _pairManager.openLimit(
            _pip,
            _quantity.Uint256ToUint128(),
            isBuy,
            _trader,
            0,
            fee
        );
        if (isBuy) {
            // Buy limit
            quoteAmount =
                _baseToQuote(
                    (_quantity - state.sizeOut),
                    _pip,
                    state.basicPoint
                ) +
                state.quoteAmountFilled;

            // quoteAmount += _feeCalculator(quoteAmount, fee);
            // deposit quote asset
            // with token has RFI we need deposit first
            // and get real balance transferred
            uint256 quoteAmountTransferred = _deposit(
                _pairManager,
                _trader,
                Asset.Quote,
                quoteAmount
            );

            Require._require(
                quoteAmountTransferred == quoteAmount,
                DexErrors.DEX_MUST_NOT_TOKEN_RFI
            );
        } else {
            quoteAmount = _baseToQuote(
                _quantity - state.sizeOut,
                _pip,
                state.basicPoint
            );
        }

        if (_quantity > state.sizeOut) {
            limitOrders[_pairManagerAddress][_trader].push(
                SpotLimitOrder.Data({
                    pip: _pip,
                    orderId: state.orderId,
                    isBuy: isBuy,
                    quoteAmount: quoteAmount.Uint256ToUint128(),
                    baseAmount: (_quantity - state.sizeOut).Uint256ToUint128(),
                    blockNumber: block.number.Uint256ToUint40(),
                    fee: fee
                })
            );
        }

        if (isBuy) {
            // withdraw  base asset
            _withdraw(
                _pairManager,
                _trader,
                Asset.Base,
                state.sizeOut - state.feeAmount,
                false
            );
        }
        if (!isBuy) {
            // withdraw quote asset
            _withdraw(
                _pairManager,
                _trader,
                Asset.Quote,
                state.quoteAmountFilled - state.feeAmount,
                false
            );
        }

        emitLimitOrderOpened(
            state.orderId,
            _trader,
            _quantity - state.sizeOut,
            state.sizeOut,
            _pip,
            isBuy ? Side.BUY : Side.SELL,
            _pairManagerAddress
        );
    }

    function _openBuyLimitOrderWithQuote(
        IMatchingEngineAMM _pairManager,
        uint256 _quoteAmount,
        uint128 _pip,
        address _trader
    ) internal {
        address _pairManagerAddress = address(_pairManager);
        OpenLimitOrderState memory state;
        state.basicPoint = _basisPoint(_pairManager);

        uint16 fee = _getFee();

        uint256 quoteAmountTransferred = _deposit(
            _pairManager,
            _trader,
            Asset.Quote,
            _quoteAmount
        );

        (
            state.orderId,
            state.sizeOut,
            state.quoteAmountFilled,
            state.feeAmount
        ) = _pairManager.openLimit(
            _pip,
            _quoteToBase(quoteAmountTransferred, _pip, state.basicPoint)
                .Uint256ToUint128(),
            true,
            _trader,
            quoteAmountTransferred,
            fee
        );
        if (quoteAmountTransferred == state.quoteAmountFilled) {
            emitMarketOrderOpened(
                _trader,
                state.sizeOut,
                state.quoteAmountFilled,
                Side.BUY,
                _pairManager,
                _pairManager.getCurrentPip()
            );
        } else {
            uint256 amountBaseOpen = _quoteToBase(
                quoteAmountTransferred - state.quoteAmountFilled,
                _pip,
                state.basicPoint
            );
            limitOrders[_pairManagerAddress][_trader].push(
                SpotLimitOrder.Data({
                    pip: _pip,
                    orderId: state.orderId,
                    isBuy: true,
                    baseAmount: amountBaseOpen.Uint256ToUint128(),
                    quoteAmount: quoteAmountTransferred.Uint256ToUint128() -
                        state.quoteAmountFilled.Uint256ToUint128(),
                    blockNumber: block.number.Uint256ToUint40(),
                    fee: fee
                })
            );

            emitLimitOrderOpened(
                state.orderId,
                _trader,
                amountBaseOpen,
                state.sizeOut,
                _pip,
                Side.BUY,
                _pairManagerAddress
            );
        }
        _withdraw(_pairManager, _trader, Asset.Base, state.sizeOut, false);
    }

    struct OpenMarketState {
        uint256 mainSideOut;
        uint256 flipSideOut;
        uint256 feeAmount;
    }

    function _openMarketOrder(
        IMatchingEngineAMM _pairManager,
        Side _side,
        uint256 _quantity,
        address _trader
    ) internal {
        /// state.mainSideOut is base asset
        /// state.flipSideOut is quote asset
        OpenMarketState memory state;

        uint16 fee = _getFee();

        if (_side == Side.BUY) {
            (
                state.mainSideOut,
                state.flipSideOut,
                state.feeAmount
            ) = _pairManager.openMarket(_quantity, true, _trader, fee);
            Require._require(
                state.mainSideOut == _quantity,
                DexErrors.DEX_MARKET_NOT_FULL_FILL
            );

            // deposit quote asset
            uint256 amountTransferred = _deposit(
                _pairManager,
                _trader,
                Asset.Quote,
                state.flipSideOut
            );

            Require._require(
                amountTransferred == state.flipSideOut,
                DexErrors.DEX_MUST_NOT_TOKEN_RFI
            );

            // withdraw base asset
            // after BUY done, transfer base back to trader
            _withdraw(
                _pairManager,
                _trader,
                Asset.Base,
                _quantity - state.feeAmount,
                false
            );
        } else {
            // SELL market
            uint256 baseAmountTransferred = _deposit(
                _pairManager,
                _trader,
                Asset.Base,
                _quantity
            );

            (
                state.mainSideOut,
                state.flipSideOut,
                state.feeAmount
            ) = _pairManager.openMarket(
                baseAmountTransferred,
                false,
                _trader,
                fee
            );
            Require._require(
                state.mainSideOut == baseAmountTransferred,
                DexErrors.DEX_MARKET_NOT_FULL_FILL
            );

            _withdraw(
                _pairManager,
                _trader,
                Asset.Quote,
                state.flipSideOut - state.feeAmount,
                false
            );

            _quantity = baseAmountTransferred;
        }

        emitMarketOrderOpened(
            _trader,
            state.mainSideOut,
            state.flipSideOut,
            _side,
            _pairManager,
            _pairManager.getCurrentPip()
        );
    }

    function _openMarketOrderWithQuote(
        IMatchingEngineAMM _pairManager,
        Side _side,
        uint256 _quoteAmount,
        address _trader
    ) internal {
        /// state.mainSideOut is quote asset
        /// state.flipSideOut is base asset
        OpenMarketState memory state;

        uint16 fee = _getFee();

        if (_side == Side.BUY) {
            // deposit quote asset
            uint256 amountTransferred = _deposit(
                _pairManager,
                _trader,
                Asset.Quote,
                _quoteAmount
            );
            (
                state.mainSideOut,
                state.flipSideOut,
                state.feeAmount
            ) = _pairManager.openMarketWithQuoteAsset(
                amountTransferred,
                true,
                _trader,
                fee
            );

            Require._require(
                state.mainSideOut == amountTransferred,
                DexErrors.DEX_MARKET_NOT_FULL_FILL
            );

            // withdraw base asset
            // after BUY done, transfer base back to trader
            _withdraw(
                _pairManager,
                _trader,
                Asset.Base,
                state.flipSideOut - state.feeAmount,
                false
            );
        } else {
            // SELL market

            (
                state.mainSideOut,
                state.flipSideOut,
                state.feeAmount
            ) = _pairManager.openMarketWithQuoteAsset(
                _quoteAmount,
                false,
                _trader,
                fee
            );
            uint256 amountTransferred = _deposit(
                _pairManager,
                _trader,
                Asset.Base,
                state.flipSideOut
            );
            Require._require(
                state.mainSideOut == _quoteAmount,
                DexErrors.DEX_MARKET_NOT_FULL_FILL
            );
            Require._require(
                state.flipSideOut == amountTransferred,
                DexErrors.DEX_MUST_NOT_TOKEN_RFI
            );
            _withdraw(
                _pairManager,
                _trader,
                Asset.Quote,
                _quoteAmount - state.feeAmount,
                false
            );
        }
        emitMarketOrderOpened(
            _trader,
            state.flipSideOut,
            state.mainSideOut,
            _side,
            _pairManager,
            _pairManager.getCurrentPip()
        );
    }

    function _clearLimitOrder(
        address _pairManagerAddress,
        address _trader,
        uint256 basicPoint
    ) internal {
        if (limitOrders[_pairManagerAddress][_trader].length > 0) {
            SpotLimitOrder.Data[]
                memory subListLimitOrder = _clearAllFilledOrder(
                    IMatchingEngineAMM(_pairManagerAddress),
                    limitOrders[_pairManagerAddress][_trader],
                    basicPoint
                );
            delete limitOrders[_pairManagerAddress][_trader];
            for (uint256 i = 0; i < subListLimitOrder.length; i++) {
                if (subListLimitOrder[i].pip == 0) {
                    break;
                }
                limitOrders[_pairManagerAddress][_trader].push(
                    subListLimitOrder[i]
                );
            }
        }
    }

    function _clearAllFilledOrder(
        IMatchingEngineAMM _pairManager,
        SpotLimitOrder.Data[] memory listLimitOrder,
        uint256 basicPoint
    ) internal returns (SpotLimitOrder.Data[] memory) {
        SpotLimitOrder.Data[]
            memory subListLimitOrder = new SpotLimitOrder.Data[](
                listLimitOrder.length
            );
        uint256 index = 0;
        for (uint256 i = 0; i < listLimitOrder.length; i++) {
            (
                bool isFilled,
                ,
                uint256 size,
                uint256 partialFilled
            ) = _pairManager.getPendingOrderDetail(
                    listLimitOrder[i].pip,
                    listLimitOrder[i].orderId
                );
            if (!isFilled) {
                subListLimitOrder[index] = listLimitOrder[i];
                if (partialFilled > 0) {
                    subListLimitOrder[index].baseAmount = (size - partialFilled)
                        .Uint256ToUint128();
                    subListLimitOrder[index].quoteAmount = (
                        _baseToQuote(
                            size - partialFilled,
                            listLimitOrder[i].pip,
                            basicPoint
                        )
                    ).Uint256ToUint128();
                }
                _pairManager.updatePartialFilledOrder(
                    listLimitOrder[i].pip,
                    listLimitOrder[i].orderId
                );
                index++;
            }
        }

        return subListLimitOrder;
    }

    function emitMarketOrderOpened(
        address trader,
        uint256 quantity,
        uint256 openNational,
        SpotHouseStorage.Side side,
        IMatchingEngineAMM spotManager,
        uint128 currentPip
    ) internal {
        emit MarketOrderOpened(
            trader,
            quantity,
            openNational,
            side,
            spotManager,
            currentPip
        );
    }

    function emitLimitOrderOpened(
        uint64 orderId,
        address trader,
        uint256 quantity,
        uint256 sizeOut,
        uint128 pip,
        SpotHouseStorage.Side _side,
        address spotManager
    ) internal {
        emit LimitOrderOpened(
            orderId,
            trader,
            quantity,
            sizeOut,
            pip,
            _side,
            spotManager
        );
    }

    function emitLimitOrderCancelled(
        address _trader,
        IMatchingEngineAMM _pairManager,
        uint128 pip,
        SpotHouseStorage.Side _side,
        uint64 orderId
    ) internal {
        emit LimitOrderCancelled(_trader, _pairManager, pip, _side, orderId);
    }

    function emitAllLimitOrderCancelled(
        address _trader,
        IMatchingEngineAMM _pairManager,
        uint128[] memory _listPips,
        uint64[] memory _orderIds,
        SpotHouseStorage.Side[] memory _listSides
    ) internal {
        emit AllLimitOrderCancelled(
            _trader,
            _pairManager,
            _listPips,
            _orderIds,
            _listSides
        );
    }

    // INTERNAL FUNCTIONS

    function _baseToQuote(
        uint256 baseAmount,
        uint128 pip,
        uint256 basisPoint
    ) internal pure returns (uint256) {
        return TradeConvert.baseToQuote(baseAmount, pip, basisPoint);
    }

    function _quoteToBase(
        uint256 quoteAmount,
        uint128 pip,
        uint256 basisPoint
    ) internal pure returns (uint256) {
        return TradeConvert.quoteToBase(quoteAmount, pip, basisPoint);
    }

    function _basisPoint(IMatchingEngineAMM _pairManager)
        internal
        view
        returns (uint256)
    {
        return _pairManager.basisPoint();
    }

    // HOOK
    function _depositBNB(address _pairManagerAddress, uint256 _amount)
        internal
        virtual
    {}

    function _withdrawBNB(
        address _trader,
        address _pairManagerAddress,
        uint256 _amount
    ) internal virtual {}

    function _withdraw(
        IMatchingEngineAMM _pairManager,
        address _recipient,
        Asset asset,
        uint256 _amount,
        bool isTakeFee
    ) internal virtual {}

    function _deposit(
        IMatchingEngineAMM _pairManager,
        address _payer,
        Asset _asset,
        uint256 _amount
    ) internal virtual returns (uint256) {}

    function _withdrawCancelAll(
        IMatchingEngineAMM _pairManager,
        address _recipient,
        Asset asset,
        uint256 _amountRefund,
        uint256 _amountFilled
    ) internal virtual {}

    function _msgSender() internal view virtual returns (address) {}

    function _getFee() internal view virtual returns (uint16) {}
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

import "../libraries/liquidity/Liquidity.sol";

interface ILiquidityManager {
    enum ModifyType {
        INCREASE,
        DECREASE
    }

    struct AddLiquidityParams {
        IMatchingEngineAMM pool;
        uint128 amountVirtual;
        uint32 indexedPipRange;
        bool isBase;
    }

    //------------------------------------------------------------------------------------------------------------------
    // FUNCTIONS
    //------------------------------------------------------------------------------------------------------------------

    struct LiquidityDetail {
        uint128 baseVirtual;
        uint128 quoteVirtual;
        uint128 liquidity;
        uint128 power;
        uint256 indexedPipRange;
        uint128 feeBasePending;
        uint128 feeQuotePending;
        IMatchingEngineAMM pool;
    }

    /// @dev get all data of nft
    /// @param tokens array of tokens
    /// @return list array of struct LiquidityDetail
    function getAllDataDetailTokens(uint256[] memory tokens)
        external
        view
        returns (LiquidityDetail[] memory);

    /// @notice get data of tokens
    /// @param tokenId the id of token
    /// @return liquidity the value liquidity
    /// @return indexedPipRange the index pip range of token
    /// @return feeGrowthBase checkpoint of fee base
    /// @return feeGrowthQuote checkpoint of fee quote
    /// @return pool the pool liquidity provide
    function concentratedLiquidity(uint256 tokenId)
        external
        view
        returns (
            uint128 liquidity,
            uint32 indexedPipRange,
            uint256 feeGrowthBase,
            uint256 feeGrowthQuote,
            IMatchingEngineAMM pool
        );

    /// @dev get data of nft
    /// @notice provide liquidity for pool
    /// @param params struct of AddLiquidityParams
    function addLiquidity(AddLiquidityParams calldata params) external payable;

    /// @dev get data of nft
    /// @notice provide liquidity for pool with recipient nft id
    /// @param params struct of AddLiquidityParams
    /// @param recipient address to receive nft
    function addLiquidityWithRecipient(
        AddLiquidityParams calldata params,
        address recipient
    ) external payable;

    /// @dev remove liquidity
    /// @notice remove liquidity of token id and transfer asset
    /// @param nftTokenId id of token
    function removeLiquidity(uint256 nftTokenId) external;

    /// @dev remove liquidity
    /// @notice increase liquidity
    /// @param nftTokenId id of token
    /// @param amountModify amount increase
    /// @param isBase amount is base or quote
    function increaseLiquidity(
        uint256 nftTokenId,
        uint128 amountModify,
        bool isBase
    ) external payable;

    /// @dev decrease liquidity and transfer asset
    /// @notice increase liquidity
    /// @param nftTokenId id of token
    /// @param liquidity amount decrease
    function decreaseLiquidity(uint256 nftTokenId, uint128 liquidity) external;

    /// @dev shiftRange to other index of range
    /// @notice increase liquidity
    /// @param nftTokenId id of token
    /// @param targetIndex target index shift to
    /// @param amountNeeded amount need more
    /// @param isBase amount need more is base or quote
    function shiftRange(
        uint256 nftTokenId,
        uint32 targetIndex,
        uint128 amountNeeded,
        bool isBase
    ) external payable;

    /// @dev collect fee reward and transfer asset
    /// @notice collect fee reward
    /// @param nftTokenId id of token
    function collectFee(uint256 nftTokenId) external;

    /// @notice get liquidity detail of token id
    /// @param baseVirtual base amount with impairment loss
    /// @param quoteVirtual quote amount with impairment loss
    /// @param liquidity the amount of liquidity
    /// @param indexedPipRange index pip range provide liquidity
    /// @param feeBasePending amount fee base pending to collect
    /// @param feeQuotePending amount fee quote pending to collect
    /// @param pool provide liquidity
    function liquidity(uint256 nftTokenId)
        external
        view
        returns (
            uint128 baseVirtual,
            uint128 quoteVirtual,
            uint128 liquidity,
            uint128 power,
            uint256 indexedPipRange,
            uint128 feeBasePending,
            uint128 feeQuotePending,
            IMatchingEngineAMM pool
        );

    //------------------------------------------------------------------------------------------------------------------
    // EVENTS
    //------------------------------------------------------------------------------------------------------------------

    event LiquidityAdded(
        address indexed user,
        address indexed pool,
        uint256 indexed nftId,
        uint256 amountBaseAdded,
        uint256 amountQuoteAdded,
        uint64 indexedPipRange,
        uint256 addedLiquidity
    );

    event LiquidityRemoved(
        address indexed user,
        address indexed pool,
        uint256 indexed nftId,
        uint256 amountBaseRemoved,
        uint256 amountQuoteRemoved,
        uint64 indexedPipRange,
        uint128 removedLiquidity
    );

    event LiquidityModified(
        address indexed user,
        address indexed pool,
        uint256 indexed nftId,
        uint256 amountBaseModified,
        uint256 amountQuoteModified,
        // 0: increase
        // 1: decrease
        ModifyType modifyType,
        uint64 indexedPipRange,
        uint128 modifiedLiquidity
    );

    event LiquidityShiftRange(
        address indexed user,
        address indexed pool,
        uint256 indexed nftId,
        uint64 oldIndexedPipRange,
        uint128 liquidityRemoved,
        uint256 amountBaseRemoved,
        uint256 amountQuoteRemoved,
        uint64 newIndexedPipRange,
        uint128 newLiquidity,
        uint256 amountBaseAdded,
        uint256 amountQuoteAded
    );
}

/**
 * @author Musket
 */
pragma solidity ^0.8.9;

interface IPositionRouter {
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

    function isPosiDexSupportPair(address tokenA, address tokenB)
        external
        view
        returns (
            address baseToken,
            address quoteToken,
            address pairManager
        );

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

/**
 * @author Musket
 */
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

import "../libraries/types/SpotHouseStorage.sol";
import "@positionex/matching-engine/contracts/interfaces/IMatchingEngineAMM.sol";

interface ISpotDex {
    //------------------------------------------------------------------------------------------------------------------
    // EVENTS
    //------------------------------------------------------------------------------------------------------------------

    event MarketOrderOpened(
        address trader,
        uint256 quantity,
        uint256 openNational,
        SpotHouseStorage.Side side,
        IMatchingEngineAMM spotManager,
        uint128 currentPip
    );
    event LimitOrderOpened(
        uint64 orderId,
        address trader,
        uint256 quantity,
        uint256 sizeOut,
        uint128 pip,
        SpotHouseStorage.Side _side,
        address spotManager
    );

    event LimitOrderCancelled(
        address trader,
        IMatchingEngineAMM spotManager,
        uint128 pip,
        SpotHouseStorage.Side _side,
        uint64 orderId
    );

    event AllLimitOrderCancelled(
        address trader,
        IMatchingEngineAMM spotManager,
        uint128[] pips,
        uint64[] orderIds,
        SpotHouseStorage.Side[] sides
    );

    event AssetClaimed(
        address trader,
        IMatchingEngineAMM spotManager,
        uint256 quoteAmount,
        uint256 baseAmount
    );

    //------------------------------------------------------------------------------------------------------------------
    // FUNCTIONS
    //------------------------------------------------------------------------------------------------------------------

    /// @notice open limit order
    /// @param pairManager the pair want to open limit order
    /// @param side of order, 0 is buy, 1 is sell
    /// @param quantity the amount of base open order
    /// @param pip of limit order
    function openLimitOrder(
        IMatchingEngineAMM pairManager,
        SpotHouseStorage.Side side,
        uint256 quantity,
        uint128 pip
    ) external payable;

    /// @notice open limit order with input is quote asset
    /// @param pairManager the pair want to open limit order
    /// @param side of order, 0 is buy, 1 is sell
    /// @param quoteAmount the amount of quote open order
    /// @param pip of limit order
    function openBuyLimitOrderWithQuote(
        IMatchingEngineAMM pairManager,
        SpotHouseStorage.Side side,
        uint256 quoteAmount,
        uint128 pip
    ) external payable;

    /// @notice open market order with base asset
    /// @param pairManager the pair want to open limit order
    /// @param side of order, 0 is buy, 1 is sell
    /// @param quantity the amount of base open order
    function openMarketOrder(
        IMatchingEngineAMM pairManager,
        SpotHouseStorage.Side side,
        uint256 quantity
    ) external payable;

    /// @notice open market order with quote asset
    /// @param pairManager the pair want to open limit order
    /// @param side of order, 0 is buy, 1 is sell
    /// @param quoteAmount the amount of quote open order
    function openMarketOrderWithQuote(
        IMatchingEngineAMM pairManager,
        SpotHouseStorage.Side side,
        uint256 quoteAmount
    ) external payable;

    /// @notice cancel limit order is pending
    /// @param pairManager the pair want cancel order
    /// @param orderIdx the id of list orders are pending
    /// @param pip the pip of order
    function cancelLimitOrder(
        IMatchingEngineAMM pairManager,
        uint64 orderIdx,
        uint128 pip
    ) external;

    /// @notice cancel all limit order is pending of one pair
    /// @param pairManager the pair want cancel all order
    function cancelAllLimitOrder(IMatchingEngineAMM pairManager) external;

    /// @notice claim asset base and quote after the order filled or partial filled
    /// @param pairManager the pair want to claim asset
    function claimAsset(IMatchingEngineAMM pairManager) external;

    /// @notice get amount of assets can claim of trader and pair
    /// @param pairManager the pair want to get amount
    /// @param trader check
    /// @return quoteAsset amount of quote can claim
    /// @return baseAsset amount of base can claim
    /// @return basisPoint of pair
    function getAmountClaimable(IMatchingEngineAMM pairManager, address trader)
        external
        view
        returns (
            uint256 quoteAsset,
            uint256 baseAsset,
            uint256 basisPoint
        );

    /// @notice get all pending limit order of trader and pair
    /// @param pairManager the pair want to get pending limit
    /// @param trader check
    /// @return the array of list pending order
    function getPendingLimitOrders(
        IMatchingEngineAMM pairManager,
        address trader
    ) external view returns (SpotHouseStorage.PendingLimitOrder[] memory);

    struct BatchPendingLimitOrder {
        address instance;
        SpotHouseStorage.PendingLimitOrder[] pendingOrders;
    }

    /// @notice get batch pending order of multi traders in 1 pair
    /// @param pairManager the pair want to get batch pending
    /// @param traders array of traders
    /// @return batchPendingOrders the array of list pending order
    function getBatchPendingLimitOrdersByTrader(
        IMatchingEngineAMM pairManager,
        address[] memory traders
    )
        external
        view
        returns (BatchPendingLimitOrder[] memory batchPendingOrders);

    /// @notice get batch pending order of multi pairs by 1 trade
    /// @param pairManagers the array of pairs want to get batch pending
    /// @param trader array of traders
    /// @return batchPendingOrders the array of list pending order
    function getBatchPendingLimitOrdersByPair(
        IMatchingEngineAMM[] memory pairManagers,
        address trader
    )
        external
        view
        returns (BatchPendingLimitOrder[] memory batchPendingOrders);

    /// @notice get order id of trader in list pending order
    /// @param pairManager the pair of get limit pending
    /// @param trader the trader
    /// @param pip the pip want to get id
    /// @param orderId id of order in quote of pip
    /// @return the order id of trader in list pending orders
    function getOrderIdOfTrader(
        address pairManager,
        address trader,
        uint128 pip,
        uint64 orderId
    ) external view returns (int256);
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

interface ISpotFactory {
    event PairManagerInitialized(
        address quoteAsset,
        address baseAsset,
        uint256 basisPoint,
        uint128 maxFindingWordsIndex,
        uint128 initialPip,
        address owner,
        address pairManager,
        uint256 pipRange,
        uint256 tickSpace
    );

    event StakingForPairAdded(
        address pairManager,
        address stakingAddress,
        address ownerOfPair
    );

    struct Pair {
        address BaseAsset;
        address QuoteAsset;
    }

    /// @notice create new pair for dex
    /// @param quoteAsset address of quote asset
    /// @param baseAsset address of base asset
    /// @param basisPoint the basis point for pip and price
    /// @param maxFindingWordsIndex the max word can finding
    /// @param initialPip the pip start of the pair
    /// @param pipRange the range of liquidity index
    /// @param tickSpace tick space for generate orderbook
    function createPairManager(
        address quoteAsset,
        address baseAsset,
        uint256 basisPoint,
        uint128 maxFindingWordsIndex,
        uint128 initialPip,
        uint128 pipRange,
        uint32 tickSpace
    ) external;

    /// @notice get pair manager address
    /// @param quoteAsset the address of quote asset
    /// @param baseAsset the address of base asset
    /// @return pairManager the address of pair manager
    function getPairManager(address quoteAsset, address baseAsset)
        external
        view
        returns (address pairManager);

    /// @notice get the quote asset and base asset
    /// @param pairManager the address of pair
    /// @return struct of quote and base
    function getQuoteAndBase(address pairManager)
        external
        view
        returns (Pair memory);

    /// @notice check pair manager is exist
    /// @param pairManager the address of pair
    /// @return true if exist, false if not exist
    function isPairManagerExist(address pairManager)
        external
        view
        returns (bool);

    /// @notice check pair and assets is supported with random two token
    /// @param tokenA the first token
    /// @param tokenB the second token
    /// @return baseToken the address of base token
    /// @return quoteToken the address of quote token
    /// @return pairManager the address of pair
    function getPairManagerSupported(address tokenA, address tokenB)
        external
        view
        returns (
            address baseToken,
            address quoteToken,
            address pairManager
        );

    /// @notice get staking manager of pair
    /// @param owner the owner of pair
    /// @param pair the address of pair
    /// @return the address of contract staking manager
    function stakingManagerOfPair(address owner, address pair)
        external
        view
        returns (address);

    /// @notice get owner of pair
    /// @param pair the address of pair
    /// @return address owner of pair
    function ownerPairManager(address pair) external view returns (address);
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

import "@positionex/matching-engine/contracts/interfaces/IMatchingEngineAMM.sol";
import "../libraries/types/SpotHouseStorage.sol";
import "./ISpotDex.sol";
import "./ILiquidityManager.sol";

interface ISpotHouse is ISpotDex {}

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface IWBNB {
    function deposit() external payable;

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address src,
        address dst,
        uint256 wad
    ) external returns (bool);

    function withdraw(uint256) external;

    function approve(address guy, uint256 wad) external returns (bool);

    function balanceOf(address guy) external view returns (uint256);
}

/**
 * @author Musket
 */
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

interface IWithdrawBNB {
    function withdraw(address recipient, uint256 _amount) external;
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

library SpotLimitOrder {
    struct Data {
        uint128 pip;
        uint64 orderId;
        bool isBuy;
        uint40 blockNumber;
        uint16 fee;
        uint128 quoteAmount;
        uint128 baseAmount;
    }
}

/**
 * @author Musket
 */
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@positionex/matching-engine/contracts/libraries/helper/Require.sol";
import "@positionex/matching-engine/contracts/interfaces/IMatchingEngineAMM.sol";

import "../../interfaces/IPositionRouter.sol";
import {DexErrors} from "../helper/DexErrors.sol";
import "../helper/TransferHelper.sol";

abstract contract BuyBackAndBurn {
    IPositionRouter public positionRouter;

    IERC20 public posiToken;

    uint256 public totalBurned;

    event BuyBackAndBurned(
        IMatchingEngineAMM pair,
        address token,
        uint256 amountBought,
        uint256 amountPosiBurned
    );

    function _buyBackAndBurn(
        address[] memory pathBuyBack,
        uint256 amount,
        bool userEther
    ) internal returns (uint256[] memory) {
        Require._require(
            pathBuyBack[pathBuyBack.length - 1] == address(posiToken),
            DexErrors.DEX_MUST_POSI
        );

        if (
            !TransferHelper.isApprove(pathBuyBack[0], address(positionRouter))
        ) {
            TransferHelper.approve(pathBuyBack[0], address(positionRouter));
        }
        uint256[] memory amounts;

        if (userEther) {
            amounts = positionRouter.swapExactETHForTokens{value: amount}(
                0,
                pathBuyBack,
                _dead(),
                9999999999
            );
        } else {
            amounts = positionRouter.swapExactTokensForTokens(
                amount,
                0,
                pathBuyBack,
                _dead(),
                9999999999
            );
        }

        totalBurned += amounts[pathBuyBack.length - 1];
        return amounts;
    }

    function _dead() internal pure returns (address) {
        return 0x000000000000000000000000000000000000dEaD;
    }

    /// @notice buy back Posi token and burn it
    /// @param pairManager the pair of token need sell to buy posi
    /// @param pathBuyBack path to buy back
    function buyBackAndBurn(
        IMatchingEngineAMM pairManager,
        address[] memory pathBuyBack
    ) external virtual {}

    /// @notice set position router
    /// @param _positionRouter new address of position router
    function setPositionRouter(IPositionRouter _positionRouter) public virtual {
        positionRouter = _positionRouter;
    }

    /// @notice set position token
    /// @param _posiToken new address of position token
    function setPosiToken(IERC20 _posiToken) public virtual {
        posiToken = _posiToken;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

/**
 * @author Musket
 */
// SPDX-License-Identifier: BUSL-1.1

import "@positionex/matching-engine/contracts/libraries/helper/Require.sol";

pragma solidity ^0.8.9;

abstract contract StrategyFee {
    uint16 public defaultFeePercentage;

    struct FeeDiscount {
        uint32 minHold;
        uint32 maxHold;
        uint16 fee;
    }

    FeeDiscount[] public strategyFee;

    /// @notice init the strategy fee
    function _initStrategyFee(uint16 _defaultFeePercentage) internal {
        defaultFeePercentage = _defaultFeePercentage;
    }

    function condition() internal view virtual returns (uint16) {}

    /// @notice get discount of fee when open order
    /// @return return the discount
    function getFeeDiscount() internal view returns (uint16) {
        uint256 _condition = condition();
        if (strategyFee.length == 0 || _condition == 0) {
            return defaultFeePercentage;
        }

        uint16 feeDiscountPercent;

        for (uint256 i = 0; i < strategyFee.length; i++) {
            if (
                _condition >= strategyFee[i].minHold &&
                _condition <= strategyFee[i].maxHold
            ) {
                feeDiscountPercent = strategyFee[i].fee;
                break;
            }
        }
        return feeDiscountPercent;
    }

    /// @notice update the strategy discount percentage
    /// @notice newStrategyDiscount the array of struct FeeDiscount
    /// @dev only operator can call
    function updateDiscountStrategy(FeeDiscount[] memory newStrategyDiscount)
        public
        virtual
    {
        delete strategyFee;

        if (newStrategyDiscount.length != 0) {
            for (uint32 i = 0; i < newStrategyDiscount.length; i++) {
                FeeDiscount memory discount = newStrategyDiscount[i];
                strategyFee.push(discount);
            }
        }
    }

    /// @notice set the default fee
    /// @dev only operator can call
    /// @dev _defaultFeePercentage the new default fee
    function setFee(uint16 _defaultFeePercentage) public virtual {
        defaultFeePercentage = _defaultFeePercentage;
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

/// @notice list revert reason in dex
library DexErrors {
    string public constant DEX_ONLY_OWNER = "DEX_01";
    string public constant DEX_EMPTY_ADDRESS = "DEX_02";
    string public constant DEX_NEED_MORE_BNB = "DEX_03";
    string public constant DEX_MARKET_NOT_FULL_FILL = "DEX_04";
    string public constant DEX_MUST_NOT_TOKEN_RFI = "DEX_05";
    string public constant DEX_MUST_ORDER_BUY = "DEX_06";
    string public constant DEX_NO_LIMIT_TO_CANCEL = "DEX_07";
    string public constant DEX_ORDER_MUST_NOT_FILLED = "DEX_08";
    string public constant DEX_INVALID_ORDER_ID = "DEX_09";
    string public constant DEX_NO_AMOUNT_TO_CLAIM = "DEX_10";
    string public constant DEX_SPOT_MANGER_EXITS = "DEX_11";
    string public constant DEX_MUST_IDENTICAL_ADDRESSES = "DEX_12";
    string public constant DEX_MUST_BNB = "DEX_13";
    string public constant DEX_ONLY_COUNTER_PARTY = "DEX_14";
    string public constant DEX_INVALID_PAIR_INFO = "DEX_15";
    string public constant DEX_ONLY_ROUTER = "DEX_16";
    string public constant DEX_MAX_FEE = "DEX_17";
    string public constant DEX_ONLY_OPERATOR = "DEX_18";
    string public constant DEX_NOT_MUST_BNB = "DEX_19";
    string public constant DEX_MUST_POSI = "DEX_20";

    string public constant LQ_NOT_IMPLEMENT_YET = "LQ_01";
    string public constant LQ_EMPTY_STAKING_MANAGER = "LQ_02";
    string public constant LQ_NO_LIQUIDITY = "LQ_03";
    string public constant LQ_POOL_EXIST = "LQ_04";
    string public constant LQ_INDEX_RANGE_NOT_DIFF = "LQ_05";
    string public constant LQ_INVALID_NUMBER = "LQ_06";
    string public constant LQ_NOT_SUPPORT = "LQ_07";
    string public constant LQ_MUST_BASE = "LQ_08";
    string public constant LQ_MUST_QUOTE = "LQ_09";
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

library TransferHelper {
    /// @notice Transfers tokens from the targeted address to the given destination
    /// @notice Errors with 'STF' if transfer fails
    /// @param token The contract address of the token to be transferred
    /// @param from The originating address from which the tokens will be transferred
    /// @param to The destination address of the transfer
    /// @param value The amount to be transferred
    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(
                IERC20.transferFrom.selector,
                from,
                to,
                value
            )
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "STF"
        );
    }

    /// @notice Transfers tokens from the targeted address to the given destination
    /// @param token The contract address of the token to be transferred
    /// @param from The originating address from which the tokens will be transferred
    /// @param to The destination address of the transfer
    /// @param value The amount to be transferred
    function transferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        token.transferFrom(from, to, value);
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(
            success,
            "TransferHelper::safeTransferETH: ETH transfer failed"
        );
    }

    /// @notice check approve with token and spender
    /// @param token need check approve
    /// @param spender need grant permit to transfer token
    /// @return bool type after check
    function isApprove(address token, address spender)
        internal
        view
        returns (bool)
    {
        return
            IERC20(token).allowance(address(this), spender) > 0 ? true : false;
    }

    /// @notice approve token with spender
    /// @param token need  approve
    /// @param spender need grant permit to transfer token
    function approve(address token, address spender) internal {
        IERC20(token).approve(spender, type(uint256).max);
    }
}

/**
 * @author Musket
 */
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

import "@positionex/matching-engine/contracts/interfaces/IMatchingEngineAMM.sol";

library UserLiquidity {
    struct Data {
        uint128 liquidity;
        uint32 indexedPipRange;
        uint256 feeGrowthBase;
        uint256 feeGrowthQuote;
        IMatchingEngineAMM pool;
    }

    struct CollectFeeData {
        uint128 feeBaseAmount;
        uint128 feeQuoteAmount;
        uint256 newFeeGrowthBase;
        uint256 newFeeGrowthQuote;
    }

    /// @notice update the liquidity of user
    /// @param liquidity the liquidity of user
    /// @param indexedPipRange the index of liquidity info
    /// @param feeGrowthBase the growth of base
    /// @param feeGrowthQuote the growth of quote
    function updateLiquidity(
        Data storage self,
        uint128 liquidity,
        uint32 indexedPipRange,
        uint256 feeGrowthBase,
        uint256 feeGrowthQuote
    ) internal {
        self.liquidity = liquidity;
        self.indexedPipRange = indexedPipRange;
        self.feeGrowthBase = feeGrowthBase;
        self.feeGrowthQuote = feeGrowthQuote;
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../../interfaces/ISpotFactory.sol";

abstract contract SpotFactoryStorage is ISpotFactory {
    address public spotHouse;

    address public positionLiquidity;

    //  baseAsset address => quoteAsset address => spotManager address
    mapping(address => mapping(address => address)) internal pathPairManagers;

    mapping(address => Pair) internal allPairManager;

    mapping(address => bool) public allowedAddressAddPair;

    // pair manager => owner
    mapping(address => address) public override ownerPairManager;

    // owner => pair manager => staking manager
    mapping(address => mapping(address => address))
        public
        override stakingManagerOfPair;

    uint32 public feeShareAmm;
    address public positionRouter;

    mapping(uint32 => address) public mappingVersionTemplate;
    uint32 public latestVersion;

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

import "../exchange/SpotOrderData.sol";
import "../../interfaces/ISpotFactory.sol";
import "../../WithdrawBNB.sol";

contract SpotHouseStorage {
    using SpotLimitOrder for mapping(address => mapping(address => SpotLimitOrder.Data[]));

    ISpotFactory public spotFactory;

    address public WBNB;

    mapping(address => mapping(address => SpotLimitOrder.Data[]))
        public limitOrders;
    enum Side {
        BUY,
        SELL
    }

    enum Asset {
        Quote,
        Base,
        Fee
    }

    struct PendingLimitOrder {
        bool isBuy;
        uint256 quantity;
        uint256 partialFilled;
        uint128 pip;
        uint256 blockNumber;
        uint256 orderIdOfTrader;
        uint64 orderId;
        uint16 fee;
    }

    struct OpenLimitResp {
        uint64 orderId;
        uint256 sizeOut;
    }

    IWithdrawBNB public withdrawBNB;

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;

    address public operator;
}

/**
 * @author Musket
 * @author NiKa
 */
// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@positionex/matching-engine/contracts/interfaces/IMatchingEngineAMM.sol";
import "@positionex/matching-engine/contracts/libraries/helper/FixedPoint128.sol";

import "./interfaces/IWBNB.sol";
import "./libraries/types/SpotHouseStorage.sol";
import {DexErrors} from "./libraries/helper/DexErrors.sol";
import {TransferHelper} from "./libraries/helper/TransferHelper.sol";
import "./interfaces/ISpotHouse.sol";
import "./implement/SpotDex.sol";
import "./libraries/extensions/StrategyFee.sol";
import "./libraries/extensions/BuyBackAndBurn.sol";

contract SpotHouse is
    PausableUpgradeable,
    ReentrancyGuardUpgradeable,
    OwnableUpgradeable,
    StrategyFee,
    BuyBackAndBurn,
    SpotDex
{
    using Convert for uint256;

    /// @notice initalization the contract
    function initialize() public initializer {
        __ReentrancyGuard_init();
        __Ownable_init();
        __Pausable_init();
        _initStrategyFee(20);
        operator = msg.sender;
    }

    modifier onlyOperator() {
        Require._require(_msgSender() == operator, DexErrors.DEX_ONLY_OPERATOR);
        _;
    }

    function openLimitOrder(
        IMatchingEngineAMM pairManager,
        Side side,
        uint256 quantity,
        uint128 pip
    ) public payable override(SpotDex) nonReentrant {
        super.openLimitOrder(pairManager, side, quantity, pip);
    }

    function openBuyLimitOrderWithQuote(
        IMatchingEngineAMM pairManager,
        Side side,
        uint256 quoteAmount,
        uint128 pip
    ) public payable override(SpotDex) nonReentrant {
        super.openBuyLimitOrderWithQuote(pairManager, side, quoteAmount, pip);
    }

    function openMarketOrder(
        IMatchingEngineAMM pairManager,
        Side side,
        uint256 quantity
    ) public payable override(SpotDex) nonReentrant {
        super.openMarketOrder(pairManager, side, quantity);
    }

    function cancelAllLimitOrder(IMatchingEngineAMM pairManager)
        public
        override(SpotDex)
        nonReentrant
    {
        super.cancelAllLimitOrder(pairManager);
    }

    function cancelLimitOrder(
        IMatchingEngineAMM pairManager,
        uint64 orderIdx,
        uint128 pip
    ) public override(SpotDex) nonReentrant {
        super.cancelLimitOrder(pairManager, orderIdx, pip);
    }

    function claimAsset(IMatchingEngineAMM pairManager)
        public
        override(SpotDex)
        nonReentrant
    {
        super.claimAsset(pairManager);
    }

    //------------------------------------------------------------------------------------------------------------------
    // ONLY OWNER FUNCTIONS
    //------------------------------------------------------------------------------------------------------------------

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function setOperator(address _operator) external onlyOwner {
        operator = _operator;
    }

    //------------------------------------------------------------------------------------------------------------------
    // ONLY OPERATOR FUNCTIONS
    //------------------------------------------------------------------------------------------------------------------

    /**
     * @dev see {BuyBackAndBurn-setPositionRouter}
     */
    function setPositionRouter(IPositionRouter _positionRouter)
        public
        override(BuyBackAndBurn)
        onlyOperator
    {
        super.setPositionRouter(_positionRouter);
    }

    /**
     * @dev see {BuyBackAndBurn-setPosiToken}
     */
    function setPosiToken(IERC20 _posiToken)
        public
        override(BuyBackAndBurn)
        onlyOperator
    {
        super.setPosiToken(_posiToken);
    }

    function setFactory(address _factoryAddress) external onlyOperator {
        Require._require(
            _factoryAddress != address(0),
            DexErrors.DEX_EMPTY_ADDRESS
        );
        spotFactory = ISpotFactory(_factoryAddress);
    }

    function setWBNB(address _wbnb) external onlyOperator {
        WBNB = _wbnb;
    }

    function setWithdrawBNB(IWithdrawBNB _withdrawBNB) external onlyOperator {
        withdrawBNB = _withdrawBNB;
    }

    function claimFee(IMatchingEngineAMM pairManager, address recipient)
        external
        onlyOperator
    {
        SpotFactoryStorage.Pair memory _pairAddress = _getQuoteAndBase(
            pairManager
        );
        address pairManagerAddress = address(pairManager);

        (uint256 baseFeeFunding, uint256 quoteFeeFunding) = pairManager
            .getFee();

        baseFeeFunding =
            (baseFeeFunding * 9999) /
            FixedPoint128.BASIC_POINT_FEE;
        quoteFeeFunding =
            (quoteFeeFunding * 9999) /
            FixedPoint128.BASIC_POINT_FEE;

        if (_pairAddress.BaseAsset == WBNB) {
            _withdrawBNB(recipient, pairManagerAddress, baseFeeFunding);
        } else {
            TransferHelper.transferFrom(
                IERC20(_pairAddress.BaseAsset),
                pairManagerAddress,
                recipient,
                baseFeeFunding
            );
        }
        if (_pairAddress.QuoteAsset == WBNB) {
            _withdrawBNB(recipient, pairManagerAddress, quoteFeeFunding);
        } else {
            TransferHelper.transferFrom(
                IERC20(_pairAddress.QuoteAsset),
                pairManagerAddress,
                recipient,
                quoteFeeFunding
            );
        }

        pairManager.resetFee(baseFeeFunding, quoteFeeFunding);
    }

    function updateDiscountStrategy(FeeDiscount[] memory newStrategyDiscount)
        public
        override(StrategyFee)
        onlyOperator
    {
        super.updateDiscountStrategy(newStrategyDiscount);
    }

    function setFee(uint16 _defaultFeePercentage)
        public
        override(StrategyFee)
        onlyOperator
    {
        super.setFee(_defaultFeePercentage);
    }

    /**
     * @dev see {BuyBackAndBurn-buyBackAndBurn}
     */
    function buyBackAndBurn(
        IMatchingEngineAMM pairManager,
        address[] memory pathBuyBack
    ) external override(BuyBackAndBurn) onlyOperator {
        SpotFactoryStorage.Pair memory _pair = _getQuoteAndBase(pairManager);
        bool isBase = pathBuyBack[0] == _pair.BaseAsset;

        (uint256 baseFeeFunding, uint256 quoteFeeFunding) = pairManager
            .getFee();

        uint256 amount = isBase
            ? (baseFeeFunding * 9999) / FixedPoint128.BASIC_POINT_FEE
            : (quoteFeeFunding * 9999) / FixedPoint128.BASIC_POINT_FEE;

        bool userEther;
        if (pathBuyBack[0] == WBNB) {
            _withdrawBNB(address(this), address(pairManager), amount);
            userEther = true;
        } else {
            TransferHelper.transferFrom(
                IERC20(pathBuyBack[0]),
                address(pairManager),
                address(this),
                amount
            );
        }

        uint256[] memory amounts = _buyBackAndBurn(
            pathBuyBack,
            amount,
            userEther
        );

        if (isBase) {
            pairManager.decreaseBaseFeeFunding(amount);
        } else {
            pairManager.decreaseQuoteFeeFunding(amount);
        }

        emit BuyBackAndBurned(
            pairManager,
            pathBuyBack[0],
            amount,
            amounts[pathBuyBack.length - 1]
        );
    }

    //------------------------------------------------------------------------------------------------------------------
    // INTERNAL FUNCTIONS
    //------------------------------------------------------------------------------------------------------------------

    function _getQuoteAndBase(IMatchingEngineAMM _managerAddress)
        internal
        view
        override(SpotDex)
        returns (SpotFactoryStorage.Pair memory pair)
    {
        pair = spotFactory.getQuoteAndBase(address(_managerAddress));
        Require._require(
            pair.BaseAsset != address(0),
            DexErrors.DEX_EMPTY_ADDRESS
        );
    }

    function _getFee() internal view override(SpotDex) returns (uint16) {
        return getFeeDiscount();
    }

    function condition() internal pure override(StrategyFee) returns (uint16) {
        return 0;
    }

    function _msgSender()
        internal
        view
        override(ContextUpgradeable, SpotDex)
        returns (address)
    {
        return msg.sender;
    }

    function _depositBNB(address _pairManagerAddress, uint256 _amount)
        internal
        override(SpotDex)
    {
        Require._require(msg.value >= _amount, DexErrors.DEX_NEED_MORE_BNB);
        IWBNB(WBNB).deposit{value: _amount}();
        assert(IWBNB(WBNB).transfer(_pairManagerAddress, _amount));
    }

    function _withdrawBNB(
        address _trader,
        address _pairManagerAddress,
        uint256 _amount
    ) internal override(SpotDex) {
        IWBNB(WBNB).transferFrom(
            _pairManagerAddress,
            address(withdrawBNB),
            _amount
        );
        withdrawBNB.withdraw(_trader, _amount);
    }

    function _deposit(
        IMatchingEngineAMM _pairManager,
        address _payer,
        Asset _asset,
        uint256 _amount
    ) internal override(SpotDex) returns (uint256) {
        if (_amount == 0) return 0;
        SpotFactoryStorage.Pair memory _pairAddress = _getQuoteAndBase(
            _pairManager
        );

        address pairManagerAddress = address(_pairManager);
        if (_asset == Asset.Quote) {
            if (_pairAddress.QuoteAsset == WBNB) {
                _depositBNB(pairManagerAddress, _amount);
            } else {
                IERC20 quoteAsset = IERC20(_pairAddress.QuoteAsset);
                uint256 _balanceBefore = quoteAsset.balanceOf(
                    pairManagerAddress
                );

                TransferHelper.transferFrom(
                    quoteAsset,
                    _payer,
                    pairManagerAddress,
                    _amount
                );
                _amount =
                    quoteAsset.balanceOf(pairManagerAddress) -
                    _balanceBefore;
            }
        } else {
            if (_pairAddress.BaseAsset == WBNB) {
                _depositBNB(pairManagerAddress, _amount);
            } else {
                IERC20 baseAsset = IERC20(_pairAddress.BaseAsset);
                uint256 _balanceBefore = baseAsset.balanceOf(
                    pairManagerAddress
                );
                TransferHelper.transferFrom(
                    baseAsset,
                    _payer,
                    pairManagerAddress,
                    _amount
                );
                _amount =
                    baseAsset.balanceOf(pairManagerAddress) -
                    _balanceBefore;
            }
        }
        return _amount;
    }

    function _withdraw(
        IMatchingEngineAMM _pairManager,
        address _recipient,
        Asset asset,
        uint256 _amount,
        bool isTakeFee
    ) internal override(SpotDex) {
        if (_amount == 0) return;
        SpotFactoryStorage.Pair memory _pairAddress = _getQuoteAndBase(
            _pairManager
        );

        if (isTakeFee) {
            uint256 feeCalculatedAmount = _feeCalculator(_amount, _getFee());
            _amount -= feeCalculatedAmount;
            _increaseFee(_pairManager, feeCalculatedAmount, asset);
        }
        address pairManagerAddress = address(_pairManager);
        if (asset == Asset.Quote) {
            if (_pairAddress.QuoteAsset == WBNB) {
                _withdrawBNB(_recipient, pairManagerAddress, _amount);
            } else {
                TransferHelper.transferFrom(
                    IERC20(_pairAddress.QuoteAsset),
                    address(_pairManager),
                    _recipient,
                    _amount
                );
            }
        } else {
            if (_pairAddress.BaseAsset == WBNB) {
                _withdrawBNB(_recipient, pairManagerAddress, _amount);
            } else {
                TransferHelper.transferFrom(
                    IERC20(_pairAddress.BaseAsset),
                    address(_pairManager),
                    _recipient,
                    _amount
                );
            }
        }
    }

    function _withdrawCancelAll(
        IMatchingEngineAMM _pairManager,
        address _recipient,
        Asset asset,
        uint256 _amountRefund,
        uint256 _amountFilled
    ) internal override(SpotDex) {
        if (_amountFilled > 0) {
            uint256 feeCalculatedAmount = _feeCalculator(
                _amountFilled,
                _getFee()
            );
            _amountFilled -= feeCalculatedAmount;
            _increaseFee(_pairManager, feeCalculatedAmount, asset);
        }

        _withdraw(
            _pairManager,
            _recipient,
            asset,
            _amountRefund + _amountFilled,
            false
        );
    }

    // _feeCalculator calculate fee
    function _feeCalculator(uint256 _amount, uint16 _fee)
        internal
        pure
        returns (uint256 feeCalculatedAmount)
    {
        if (_fee == 0) {
            return 0;
        }
        feeCalculatedAmount = (_fee * _amount) / FixedPoint128.BASIC_POINT_FEE;
    }

    function _increaseFee(
        IMatchingEngineAMM _pairManager,
        uint256 _fee,
        Asset asset
    ) internal {
        if (asset == Asset.Quote && _fee > 0) {
            _pairManager.increaseQuoteFeeFunding(_fee);
        }
        if (asset == Asset.Base && _fee > 0) {
            _pairManager.increaseBaseFeeFunding(_fee);
        }
    }
}

/**
 * @author Musket
 */
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

import {DexErrors} from "./libraries/helper/DexErrors.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./interfaces/IWBNB.sol";
import "./interfaces/IWithdrawBNB.sol";

contract WithdrawBNB is IWithdrawBNB {
    using Address for address payable;
    IWBNB public WBNB;
    address public owner;
    mapping(address => bool) public counterParties;

    modifier onlyOwner() {
        require(msg.sender == owner, DexErrors.DEX_ONLY_OWNER);
        _;
    }

    modifier onlyCounterParty() {
        require(counterParties[msg.sender], DexErrors.DEX_ONLY_COUNTER_PARTY);
        _;
    }

    receive() external payable {
        assert(msg.sender == address(WBNB));
        // only accept BNB via fallback from the WBNB contract
    }

    constructor(IWBNB _WBNB) {
        owner = msg.sender;
        WBNB = _WBNB;
    }

    function setWBNB(IWBNB _newWBNB) external onlyOwner {
        WBNB = _newWBNB;
    }

    function transferOwner(address _newOwner) external onlyOwner {
        owner = _newOwner;
    }

    function setCounterParty(address _newCounterParty) external onlyOwner {
        counterParties[_newCounterParty] = true;
    }

    function revokeCounterParty(address _account) external onlyOwner {
        counterParties[_account] = false;
    }

    function withdraw(address recipient, uint256 amount)
        external
        override
        onlyCounterParty
    {
        WBNB.withdraw(amount);
        payable(recipient).sendValue(amount);
    }
}