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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

import "./math/Math.sol";

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
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
            return toHexString(value, Math.log256(value) + 1);
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

//SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import '@openzeppelin/contracts/utils/Strings.sol';

contract DoraemiaoPresaleV2 is Initializable, ReentrancyGuardUpgradeable, OwnableUpgradeable, PausableUpgradeable {
	using SafeMath for uint256;
	using Strings for uint256;
	
	uint256 public totalTokensSold;
	uint256 public startTime;
	uint256 public endTime;
	uint256 public claimStart;
	address public saleToken;
	uint256 public baseDecimals;
	uint256 public maxTokensToBuy;
	uint256 public currentStep;
	uint256 public inviteFee;
	uint256 public feeDivisor;
	uint256 public maxStep;
	uint256 public inviteRewardClaimStart;
	
	address public feeWallet;
	
	IERC20Upgradeable public USDTInterface;
	//	Aggregator public aggregatorInterface;
	// https://docs.chain.link/docs/ethereum-addresses/ => (ETH / USD)
	
	uint256[3] public token_amount;
	uint256[3] public token_price;
	string[] private inviteCodeArr;
	address[] private inviteAddrArr;
	Invite[]   private _initInviteArr;
	
	struct Invite {
		string inviteCode;
		address inviteAddr;
	}
	
	struct InviteeData {
		address invitee;
		uint256 domAmount;
		uint256 usdtAmount;
		bool isFlag;
	}
	
	struct InvitationData {
		bool isFlag;
		uint256 count;
		uint256 totalDomAmount;
		uint256 totalUSDTAmount;
		uint256 totalInviteReward;
	}
	
	struct GetInvitationData {
		address inviteAddr;
		string inviteCode;
		uint256 count;
		uint256 totalDomAmount;
		uint256 totalUSDTAmount;
		uint256 totalInviteReward;
		address[] invitees;
	}
	
	struct ListInvitationData {
		string inviteCode;
		address inviteAddr;
		uint256 count;
		uint256 totalDomAmount;
		uint256 totalUSDTAmount;
		uint256 totalInviteReward;
		address[] invitees;
	}
	
	mapping(address => uint256) public userDeposits;
	mapping(address => bool) public hasClaimed;
	
	mapping(string => InvitationData) private inviteData;
	mapping(string => address[]) private invitees;
	mapping(string => mapping(address => InviteeData)) private inviteeData;
	mapping(string => address) private inviteCodeToInviteAddr;
	mapping(address => string) private inviteAddrToInviteCode;
	mapping(address => uint256) public inviteDeposits;
	mapping(address => bool) public hasInviteRewardClaimed;
	
	event SaleTimeSet(uint256 _start, uint256 _end, uint256 timestamp);
	event AddInvite(Invite[] _invites);
	event ChangeMaxTokensToBuy(uint256 _old, uint256 _new);
	
	event SaleTimeUpdated(
		bytes32 indexed key,
		uint256 prevValue,
		uint256 newValue,
		uint256 timestamp
	);
	
	event TokensBought(
		address indexed user,
		uint256 indexed tokensBought,
		address indexed purchaseToken,
		uint256 amountPaid,
		uint256 timestamp
	);
	
	event TokensAdded(
		address indexed token,
		uint256 noOfTokens,
		uint256 timestamp
	);
	event TokensClaimed(
		address indexed user,
		uint256 amount,
		uint256 timestamp
	);
	
	event ClaimStartUpdated(
		uint256 prevValue,
		uint256 newValue,
		uint256 timestamp
	);
	
	event InviteRewardClaimed(
		address indexed user,
		uint256 amount,
		uint256 timestamp
	);
	
	event InviteRewardClaimStartUpdated(
		uint256 prevValue,
		uint256 newValue,
		uint256 timestamp
	);
	
	/// @custom:oz-upgrades-unsafe-allow constructor
	constructor() initializer {}
	
	/**
	 * @dev To pause the presale
     */
	function pause() external onlyOwner {
		_pause();
	}
	
	/**
	 * @dev To unpause the presale
     */
	function unpause() external onlyOwner {
		_unpause();
	}
	
	function changeMaxStep(uint256 _maxStep) external onlyOwner {
		require(_maxStep < 3, "Invalid step");
		maxStep = _maxStep;
	}
	
	function changeInviteFee(uint256 _inviteFee) external onlyOwner {
		inviteFee = _inviteFee;
	}
	
	function changeFeeWallet(address _feeWallet) external onlyOwner {
		feeWallet = _feeWallet;
	}
	
	/**
	 * @dev To isExistInviteCode  whether there is an invitation code
     * @param _inviteCode invite code
     */
	function isExistInviteCode(string calldata _inviteCode) public view returns (bool)  {
		return inviteData[_inviteCode].isFlag;
	}
	
	/**
	 * @dev To isExistInviteAddr  whether there is an invitation address
     * @param _inviteAddr invite address
     */
	function isExistInviteAddr(address _inviteAddr) public view returns (bool)  {
		string memory code = inviteAddrToInviteCode[_inviteAddr];
		return inviteData[code].isFlag;
	}
	
	/**
	 * @dev To getInviteByInviteCode get invite info by invite code
     * @param _code invite code
     */
	function getInviteByInviteCode(string memory _code) external view returns (GetInvitationData memory) {
		require(inviteData[_code].isFlag, "invite code is not exist");
		
		GetInvitationData memory getInvitationData;
		getInvitationData.totalDomAmount = inviteData[_code].totalDomAmount;
		getInvitationData.totalUSDTAmount = inviteData[_code].totalUSDTAmount;
		getInvitationData.count = inviteData[_code].count;
		getInvitationData.invitees = invitees[_code];
		getInvitationData.inviteAddr = inviteCodeToInviteAddr[_code];
		getInvitationData.inviteCode = _code;
		getInvitationData.totalInviteReward = inviteData[_code].totalInviteReward;
		
		return getInvitationData;
	}
	
	/**
	 * @dev To getInviteInfoByInviteAddr get invite info by invite address
     * @param _addr invite address
     */
	function getInviteInfoByInviteAddr(address _addr) external view returns (GetInvitationData memory) {
		string memory _code = inviteAddrToInviteCode[_addr];
		require(inviteData[_code].isFlag, "invite address is not exist");
		
		GetInvitationData memory getInvitationData;
		getInvitationData.totalDomAmount = inviteData[_code].totalDomAmount;
		getInvitationData.totalUSDTAmount = inviteData[_code].totalUSDTAmount;
		getInvitationData.count = inviteData[_code].count;
		getInvitationData.invitees = invitees[_code];
		getInvitationData.inviteAddr = inviteCodeToInviteAddr[_code];
		getInvitationData.inviteCode = _code;
		getInvitationData.totalInviteReward = inviteData[_code].totalInviteReward;
		
		return getInvitationData;
	}
	
	/**
	 * @dev To listInviteInfo list invitee info
     */
	function listInviteInfo() external onlyOwner view returns (ListInvitationData[] memory)  {
		ListInvitationData[] memory listInvitationData = new ListInvitationData[](inviteCodeArr.length);
		for (uint256 i = 0; i < inviteCodeArr.length; i++) {
			ListInvitationData memory list = ListInvitationData(inviteCodeArr[i],
				inviteCodeToInviteAddr[inviteCodeArr[i]],
				inviteData[inviteCodeArr[i]].count,
				inviteData[inviteCodeArr[i]].totalDomAmount,
				inviteData[inviteCodeArr[i]].totalUSDTAmount,
				inviteData[inviteCodeArr[i]].totalInviteReward,
				invitees[inviteCodeArr[i]]);
			listInvitationData[i] = list;
		}
		
		return listInvitationData;
	}
	
	function _addInvite(Invite[] memory _inviteArr) internal {
		for (uint256 i = 0; i < _inviteArr.length; i++) {
			require(!inviteData[_inviteArr[i].inviteCode].isFlag, "invite code is exist");
			require(_inviteArr[i].inviteAddr != address(0), "invite address is nil");
			require(_inviteArr[i].inviteAddr != address(this), "invite address is nil");
			require(!inviteData[inviteAddrToInviteCode[_inviteArr[i].inviteAddr]].isFlag, "invite address is exist");
			
			
			inviteData[_inviteArr[i].inviteCode] = InvitationData(true, 0, 0, 0, 0);
			inviteCodeArr.push(_inviteArr[i].inviteCode);
			inviteAddrArr.push(_inviteArr[i].inviteAddr);
			
			inviteCodeToInviteAddr[_inviteArr[i].inviteCode] = _inviteArr[i].inviteAddr;
			inviteAddrToInviteCode[_inviteArr[i].inviteAddr] = _inviteArr[i].inviteCode;
		}
	}
	
	/**
	 * @dev To addInvite  add invite
	 * @param _inviteArr invite info
     */
	function addInvite(Invite[] memory _inviteArr) external onlyOwner {
		require(_inviteArr.length > 0, "invite data err");
		
		_addInvite(_inviteArr);
		emit AddInvite(_inviteArr);
	}
	
	/**
	 * @dev To changeMaxTokensToBuy change the max token by the owner
	 * @param _maxTokensBuy max token
     */
	function changeMaxTokensToBuy(uint256 _maxTokensBuy) external onlyOwner {
		uint256 _oldMaxTokensToBuy = maxTokensToBuy;
		maxTokensToBuy = _maxTokensBuy;
		
		emit ChangeMaxTokensToBuy(_oldMaxTokensToBuy, maxTokensToBuy);
	}
	
	/**
	 * @dev To changeTokenAmount change the total amount of each round of pre-order
	 * @param _tokenAmount token amount
     */
	function changeTokenAmount(uint256[3] memory _tokenAmount) external onlyOwner {
		require(_tokenAmount.length == 3);
		require(_tokenAmount[2] > _tokenAmount[1]);
		require(_tokenAmount[1] > _tokenAmount[0]);
		require(_tokenAmount[0] > 0);
		
		token_amount = _tokenAmount;
	}
	
	/**
	 * @dev To getPresaleSupply Each round of pre-order quantity
	 * @param _step number of pre-order rounds
     */
	function getPresaleSupply(uint256 _step) external view returns (uint256)  {
		require(_step < 3);
		if (_step == 0) {
			return token_amount[0];
		}
		
		return token_amount[_step] - token_amount[_step - 1];
	}
	
	/**
 * @dev To getPresalePrice Each round of pre-order usdt price
	 * @param _step number of pre-order rounds
     */
	function getPresalePrice(uint256 _step) external view returns (uint256)  {
		require(_step < 3);
		
		return token_price[_step];
	}
	
	/**
	 * @dev To getPresaleTotalSupply  total presale supply
     */
	function getPresaleTotalSupply() external view returns (uint256)  {
		uint256 len = token_amount.length;
		return token_amount[len - 1];
	}
	
	/**
	* @dev To getPresaleCurSupply  get current presale supply
	*/
	function getPresaleCurSupply() external view returns (uint256)  {
		if (currentStep == 0) {
			return totalTokensSold;
		}
		
		return totalTokensSold.sub(token_amount[currentStep - 1]);
	}
	
	/**
	 * @dev To calculate the price in USD for given amount of tokens.
     * @param _amount No of tokens
     */
	function calculatePrice(uint256 _amount)
	public
	view
	returns (uint256 totalValue)
	{
		uint256 USDTAmount;
		require(_amount <= maxTokensToBuy, "Amount exceeds max tokens to buy");
		if (_amount + totalTokensSold > token_amount[currentStep]) {
			require(currentStep < maxStep, "Insufficient token amount.");
			uint256 tokenAmountForCurrentPrice = token_amount[currentStep] -
			totalTokensSold;
			USDTAmount =
			tokenAmountForCurrentPrice *
			token_price[currentStep] +
			(_amount - tokenAmountForCurrentPrice) *
			token_price[currentStep + 1];
		} else USDTAmount = _amount * token_price[currentStep];
		return USDTAmount;
	}
	
	/**
    * @dev To update the sale end times
     * @param _endTime New end time
     */
	function changeSaleEndTimes(uint256 _endTime)
	external
	onlyOwner
	{
		require(block.timestamp < endTime, "Sale already ended");
		require(_endTime > 0, "Invalid parameters");
		require(block.timestamp < _endTime, "Invalid endTime");
		require(_endTime > startTime, "Invalid endTime");
		
		uint256 prevValue = endTime;
		endTime = _endTime;
		emit SaleTimeUpdated(
			bytes32("END"),
			prevValue,
			_endTime,
			block.timestamp
		);
	}
	
	/**
	 * @dev To update the sale start times
     * @param _startTime New start time
     */
	function changeSaleStartTimes(uint256 _startTime)
	external
	onlyOwner
	{
		require(_startTime > 0, "Invalid parameters");
		require(block.timestamp < startTime, "Sale already started");
		require(block.timestamp < _startTime, "Sale time in past");
		require(endTime > _startTime, "Invalid endTime");
		
		uint256 prevValue = startTime;
		startTime = _startTime;
		emit SaleTimeUpdated(
			bytes32("START"),
			prevValue,
			_startTime,
			block.timestamp
		);
	}
	
	modifier checkSaleState(uint256 amount) {
		require(
			block.timestamp >= startTime && block.timestamp <= endTime,
			"Invalid time for buying"
		);
		require(amount > 0, "Invalid sale amount");
		_;
	}
	
	function _addInvitee(string memory _inviteCode, uint256 amount, uint256 usdPrice, uint256 fee) internal {
		inviteData[_inviteCode].totalDomAmount += amount;
		inviteData[_inviteCode].totalUSDTAmount += usdPrice;
		inviteData[_inviteCode].totalInviteReward += fee;
		if (!inviteeData[_inviteCode][_msgSender()].isFlag) {
			inviteeData[_inviteCode][_msgSender()] = InviteeData(_msgSender(), amount, usdPrice, true);
			inviteData[_inviteCode].count += 1;
			invitees[_inviteCode].push(_msgSender());
		} else {
			inviteeData[_inviteCode][_msgSender()].domAmount += amount;
			inviteeData[_inviteCode][_msgSender()].usdtAmount += usdPrice;
		}
	}
	
	/**
	 * @dev To buy into a presale using USDT
     * @param amount No of tokens to buy
     */
	function buyWithUSDT(uint256 amount, string calldata _inviteCode)
	external
	checkSaleState(amount)
	whenNotPaused
	returns (bool)
	{
		uint256 usdPrice = calculatePrice(amount);
		//usdPrice = usdPrice / (10 ** 12);
		totalTokensSold += amount;
		if (totalTokensSold > token_amount[currentStep]) currentStep += 1;
		userDeposits[_msgSender()] += (amount * baseDecimals);
		uint256 ourAllowance = USDTInterface.allowance(
			_msgSender(),
			address(this)
		);
		require(usdPrice <= ourAllowance, "Make sure to add enough allowance");
		
		if (isExistInviteCode(_inviteCode)) {
			address _inviteAddr = inviteCodeToInviteAddr[_inviteCode];
			uint256 fee;
			fee = usdPrice.mul(inviteFee).div(feeDivisor);
			_addInvitee(_inviteCode, amount, usdPrice, fee);
			if (fee > 0) {
				inviteDeposits[_inviteAddr] += fee;
				usdPrice = usdPrice.sub(fee);
				bool success;
				(success,) = address(USDTInterface).call(
					abi.encodeWithSignature(
						"transferFrom(address,address,uint256)",
						_msgSender(),
						address(this),
						fee
					)
				);
			}
			
		}
		bool usdtSuccess;
		(usdtSuccess,) = address(USDTInterface).call(
			abi.encodeWithSignature(
				"transferFrom(address,address,uint256)",
				_msgSender(),
				feeWallet,
				usdPrice
			)
		);
		
		require(usdtSuccess, "Token payment failed");
		emit TokensBought(
			_msgSender(),
			amount,
			address(USDTInterface),
			usdPrice,
			block.timestamp
		);
		return true;
	}
	
	/**
	 * @dev Helper funtion to get USDT price for given amount
     * @param amount No of tokens to buy
     */
	function usdtBuyHelper(uint256 amount)
	external
	view
	returns (uint256 usdPrice)
	{
		usdPrice = calculatePrice(amount);
		//usdPrice = usdPrice / (10 ** 12);
	}
	
	/**
	 * @dev To set the claim start time and sale token address by the owner
     * @param _claimStart claim start time
     * @param noOfTokens no of tokens to add to the contract
     * @param _saleToken sale toke address
     */
	function startClaim(
		uint256 _claimStart,
		uint256 noOfTokens,
		address _saleToken
	) external onlyOwner returns (bool) {
		require(
			_claimStart > endTime && _claimStart > block.timestamp,
			"Invalid claim start time"
		);
		require(
			noOfTokens >= (totalTokensSold * baseDecimals),
			"Tokens less than sold"
		);
		require(_saleToken != address(0), "Zero token address");
		require(claimStart == 0, "Claim already set");
		claimStart = _claimStart;
		saleToken = _saleToken;
		bool success = IERC20Upgradeable(_saleToken).transferFrom(
			_msgSender(),
			address(this),
			noOfTokens
		);
		require(success, "Token transfer failed");
		emit TokensAdded(saleToken, noOfTokens, block.timestamp);
		return true;
	}
	
	/**
	 * @dev To change the claim start time by the owner
     * @param _claimStart new claim start time
     */
	function changeClaimStart(uint256 _claimStart)
	external
	onlyOwner
	returns (bool)
	{
		require(claimStart > 0, "Initial claim data not set");
		require(_claimStart > endTime, "Sale in progress");
		require(_claimStart > block.timestamp, "Claim start in past");
		uint256 prevValue = claimStart;
		claimStart = _claimStart;
		emit ClaimStartUpdated(prevValue, _claimStart, block.timestamp);
		return true;
	}
	
	/**
	 * @dev To claim tokens after claiming starts
     */
	function claim() external whenNotPaused returns (bool) {
		require(saleToken != address(0), "Sale token not added");
		require(block.timestamp >= claimStart, "Claim has not started yet");
		require(!hasClaimed[_msgSender()], "Already claimed");
		hasClaimed[_msgSender()] = true;
		uint256 amount = userDeposits[_msgSender()];
		require(amount > 0, "Nothing to claim");
		delete userDeposits[_msgSender()];
		bool success = IERC20Upgradeable(saleToken).transfer(
			_msgSender(),
			amount
		);
		require(success, "Token transfer failed");
		emit TokensClaimed(_msgSender(), amount, block.timestamp);
		return true;
	}
	
	
	/**
	 * @dev To startInviteRewardClaim change the claim enable by the owner
	 * @param _inviteRewardClaimStart new claim start
     */
	function startInviteRewardClaim(uint256 _inviteRewardClaimStart)
	external
	onlyOwner
	returns (bool)
	{
		require(_inviteRewardClaimStart > 0, "Initial invite reward claim data not set");
		require(
			_inviteRewardClaimStart > block.timestamp,
			"Invalid invite reward claim start time"
		);
		
		uint256 prevValue = inviteRewardClaimStart;
		inviteRewardClaimStart = _inviteRewardClaimStart;
		emit InviteRewardClaimStartUpdated(prevValue, inviteRewardClaimStart, block.timestamp);
		return true;
	}
	
	/**
	 * @dev To claimInviteReward tokens after claiming starts
     */
	function inviteRewardClaim() external whenNotPaused returns (bool) {
		require(inviteRewardClaimStart > 0 &&
			block.timestamp >= inviteRewardClaimStart, "Claim has not started yet");
		require(isExistInviteAddr(_msgSender()), "not inviter");

		uint256 amount = inviteDeposits[_msgSender()];
		require(amount > 0, "Nothing to claim");
		delete inviteDeposits[_msgSender()];
		
		(bool success,) = address(USDTInterface).call(
			abi.encodeWithSignature(
				"transfer(address,uint256)",
				_msgSender(),
				amount
			)
		);
		require(success, "Token transfer failed");
		emit InviteRewardClaimed(_msgSender(), amount, block.timestamp);
		return true;
	}
	
	/**
	 * @dev To inviteRewardClaimEnabled invite reward start enable
     */
	function inviteRewardClaimEnabled() external view returns (bool) {
		return block.timestamp >= inviteRewardClaimStart && inviteRewardClaimStart > 0;
	}
}