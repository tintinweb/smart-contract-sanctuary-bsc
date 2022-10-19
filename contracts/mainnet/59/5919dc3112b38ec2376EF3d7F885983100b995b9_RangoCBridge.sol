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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
import "../../../utils/AddressUpgradeable.sol";

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

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
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

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../../interfaces/IUniswapV2.sol";
import "../../interfaces/IUniswapV3.sol";
import "../../interfaces/IWETH.sol";
import "../../interfaces/IRangoStargate.sol";
import "../../interfaces/IStargateReceiver.sol";
import "./BaseProxyContract.sol";
import "../../interfaces/IRangoMessageReceiver.sol";

contract BaseInterchainContract is BaseProxyContract {

    /// @dev keccak256("exchange.rango.baseinterchaincontract")
    bytes32 internal constant BASE_MESSAGING_CONTRACT_NAMESPACE = hex"4c086c3e971f21b430782c034d778469729e11e13e4bc8ec046299c71c4c2877";

    struct BaseInterchainStorage {
        mapping (address => bool) whitelistMessagingContracts;
    }

    /// @notice Status of cross-chain swap
    /// @param Created It's sent to bridge and waiting for bridge response
    /// @param Succeeded The whole process is success and end-user received the desired token in the destination
    /// @param RefundInSource Bridge was out of liquidity and middle asset (ex: USDC) is returned to user on source chain
    /// @param RefundInDestination Our handler on dest chain this.executeMessageWithTransfer failed and we send middle asset (ex: USDC) to user on destination chain
    /// @param SwapFailedInDestination Everything was ok, but the final DEX on destination failed (ex: Market price change and slippage)
    enum OperationStatus {
        Created,
        Succeeded,
        RefundInSource,
        RefundInDestination,
        SwapFailedInDestination
    }

    /// @notice Notifies that a new contract is whitelisted
    /// @param _dapp The address of the contract
    event MessagingDAppWhitelisted(address _dapp);

    /// @notice Notifies that a new contract is blacklisted
    /// @param _dapp The address of the contract
    event MessagingDAppBlacklisted(address _dapp);


    /// @notice This event indicates that a dApp used Rango messaging (dAppMessage field) and we delivered the message to it
    /// @param _receiverContract The address of dApp's contract that was called
    /// @param _token The address of the token that is sent to the dApp, ETH for native token
    /// @param _amount The amount of the token sent to them
    /// @param _status The status of operation, informing the dApp that the whole process was a success or refund
    /// @param _appMessage The custom message that the dApp asked Rango to deliver
    /// @param success Indicates that the function call to the dApp encountered error or not
    /// @param failReason If success = false, failReason will be the string reason of the failure (aka message of require)
    event CrossChainMessageCalled(
        address _receiverContract,
        address _token,
        uint _amount,
        IRangoMessageReceiver.ProcessStatus _status,
        bytes _appMessage,
        bool success,
        string failReason
    );

    event ActionDone(Interchain.ActionType actionType, address contractAddress, bool success, string reason);
    event SubActionDone(Interchain.CallSubActionType subActionType, address contractAddress, bool success, string reason);

    /// @notice Adds a contract to the whitelisted messaging dApps that can be called
    /// @param _dapp The address of dApp
    function addMessagingDApp(address _dapp) public onlyOwner {
        BaseInterchainStorage storage baseStorage = getBaseMessagingContractStorage();
        baseStorage.whitelistMessagingContracts[_dapp] = true;
        emit MessagingDAppWhitelisted(_dapp);
    }

    /// @notice Adds a list of contracts to the whitelisted messaging dApps that can be called
    /// @param _dapps The addresses of dApps
    function addMessagingDApps(address[] calldata _dapps) external onlyOwner {
        for (uint i = 0; i < _dapps.length; i++)
            addMessagingDApp(_dapps[i]);
    }

    /// @notice Removes a contract from dApps that can be called
    /// @param _dapp The address of dApp
    function removeMessagingDApp(address _dapp) external onlyOwner {
        BaseInterchainStorage storage baseStorage = getBaseMessagingContractStorage();

        require(baseStorage.whitelistMessagingContracts[_dapp], "Factory not found");
        delete baseStorage.whitelistMessagingContracts[_dapp];

        emit MessagingDAppBlacklisted(_dapp);
    }

    function handleDestinationMessage(
        address _token,
        uint _amount,
        Interchain.RangoInterChainMessage memory m
    ) internal returns (address receivedToken, uint256 dstAmount, OperationStatus status) {

        BaseProxyStorage storage baseStorage = getBaseProxyContractStorage();
        address sourceToken = m.bridgeRealOutput == ETH && _token == baseStorage.WETH ? ETH : _token;

        bool ok = true;
        address outToken = sourceToken;
        dstAmount = _amount;

        if (m.actionType == Interchain.ActionType.UNI_V2)
            (ok, dstAmount, outToken) = _handleUniswapV2(sourceToken, _amount, m, baseStorage);
        else if (m.actionType == Interchain.ActionType.UNI_V3)
            (ok, dstAmount, outToken) = _handleUniswapV3(sourceToken, _amount, m, baseStorage);
        else if (m.actionType == Interchain.ActionType.CALL)
            (ok, dstAmount, outToken) = _handleCall(sourceToken, _amount, m, baseStorage);
        else if (m.actionType != Interchain.ActionType.NO_ACTION)
            revert("Unsupported actionType");

        if (ok && m.postAction != Interchain.CallSubActionType.NO_ACTION) {
            (ok, dstAmount, outToken) = _handlePostAction(outToken, dstAmount, m.postAction, baseStorage);
        }

        status = ok ? OperationStatus.Succeeded : OperationStatus.SwapFailedInDestination;
        IRangoMessageReceiver.ProcessStatus dAppStatus = ok 
            ? IRangoMessageReceiver.ProcessStatus.SUCCESS 
            : IRangoMessageReceiver.ProcessStatus.REFUND_IN_DESTINATION;

        _sendTokenWithDApp(outToken, dstAmount, m.recipient, m.dAppMessage, m.dAppDestContract, dAppStatus);

        return (receivedToken, dstAmount, status);
    }

    /// @notice Performs a uniswap-v2 operation
    /// @param _message The interchain message that contains the swap info
    /// @param _amount The amount of input token
    /// @return ok Indicates that the swap operation was success or fail
    /// @return amountOut If ok = true, amountOut is the output amount of the swap
    function _handleUniswapV2(
        address _token,
        uint _amount,
        Interchain.RangoInterChainMessage memory _message,
        BaseProxyStorage storage baseStorage
    ) private returns (bool ok, uint256 amountOut, address outToken) {
        Interchain.UniswapV2Action memory action = abi.decode((_message.action), (Interchain.UniswapV2Action));
        require(baseStorage.whitelistContracts[action.dexAddress] == true, "Dex address is not whitelisted");
        require(action.path.length >= 2, "Invalid uniswap-V2 path");

        bool shouldDeposit = _token == ETH && action.path[0] == baseStorage.WETH;
        if (!shouldDeposit)
            require(_token == action.path[0], "bridged token must be the same as the first token in destination swap path");
        else {
            require(action.path[0] == baseStorage.WETH, "Invalid uniswap-V2 path");
            IWETH(baseStorage.WETH).deposit{value: _amount}();
        }

        approve(action.path[0], action.dexAddress, _amount);

        try
            IUniswapV2(action.dexAddress).swapExactTokensForTokens(
                _amount,
                action.amountOutMin,
                action.path,
                address(this),
                action.deadline
            )
        returns (uint256[] memory amounts) {
            emit ActionDone(Interchain.ActionType.UNI_V2, action.dexAddress, true, "");
            return (true, amounts[amounts.length - 1], action.path[action.path.length - 1]);
        } catch {
            emit ActionDone(Interchain.ActionType.UNI_V2, action.dexAddress, true, "Uniswap-V2 call failed");
            return (false, _amount, shouldDeposit ? baseStorage.WETH : _token);
        }
    }

    /// @notice Performs a uniswap-v2 operation
    /// @param _message The interchain message that contains the swap info
    /// @param _amount The amount of input token
    /// @return ok Indicates that the swap operation was success or fail
    /// @return amountOut If ok = true, amountOut is the output amount of the swap
    function _handleUniswapV3(
        address _token,
        uint _amount,
        Interchain.RangoInterChainMessage memory _message,
        BaseProxyStorage storage baseStorage
    ) private returns (bool, uint256, address) {
        Interchain.UniswapV3ActionExactInputSingleParams memory action = abi
            .decode((_message.action), (Interchain.UniswapV3ActionExactInputSingleParams));

        require(baseStorage.whitelistContracts[action.dexAddress] == true, "Dex address is not whitelisted");

        bool shouldDeposit = _token == ETH && action.tokenIn == baseStorage.WETH;
        if (!shouldDeposit)
            require(_token == action.tokenIn, "bridged token must be the same as the tokenIn in uniswapV3");
        else {
            require(action.tokenIn == baseStorage.WETH, "Invalid uniswap-V2 path");
            IWETH(baseStorage.WETH).deposit{value: _amount}();
        }

        approve(action.tokenIn, action.dexAddress, _amount);

        try
            IUniswapV3(action.dexAddress).exactInputSingle(IUniswapV3.ExactInputSingleParams({
                tokenIn : action.tokenIn,
                tokenOut : action.tokenOut,
                fee : action.fee,
                recipient : address(this),
                deadline : action.deadline,
                amountIn : _amount,
                amountOutMinimum : action.amountOutMinimum,
                sqrtPriceLimitX96 : action.sqrtPriceLimitX96
            }))
        returns (uint amountOut) {
            emit ActionDone(Interchain.ActionType.UNI_V3, action.dexAddress, true, "");
            return (true, amountOut, action.tokenOut);
        } catch {
            emit ActionDone(Interchain.ActionType.UNI_V3, action.dexAddress, false, "Uniswap-V3 call failed");
            return (false, _amount, shouldDeposit ? baseStorage.WETH : _token);
        }
    }

    /// @notice Performs a uniswap-v2 operation
    /// @param _message The interchain message that contains the swap info
    /// @param _amount The amount of input token
    /// @return ok Indicates that the swap operation was success or fail
    /// @return amountOut If ok = true, amountOut is the output amount of the swap
    function _handleCall(
        address _token,
        uint _amount,
        Interchain.RangoInterChainMessage memory _message,
        BaseProxyStorage storage baseStorage
    ) private returns (bool ok, uint256 amountOut, address outToken) {
        Interchain.CallAction memory action = abi.decode((_message.action), (Interchain.CallAction));

        require(baseStorage.whitelistContracts[action.target] == true, "Action.target is not whitelisted");
        require(baseStorage.whitelistContracts[action.spender] == true, "Action.spender is not whitelisted");

        address sourceToken = _token;

        if (action.preAction == Interchain.CallSubActionType.WRAP) {
            require(_token == ETH, "Cannot wrap non-native");
            require(action.tokenIn == baseStorage.WETH, "action.tokenIn must be WETH");
            (ok, amountOut, sourceToken) = _handleWrap(_token, _amount, baseStorage);
        } else if (action.preAction == Interchain.CallSubActionType.UNWRAP) {
            require(_token == baseStorage.WETH, "Cannot unwrap non-WETH");
            require(action.tokenIn == ETH, "action.tokenIn must be ETH");
            (ok, amountOut, sourceToken) = _handleUnwrap(_token, _amount, baseStorage);
        } else {
            require(action.tokenIn == _token, "_message.tokenIn mismatch in call");
        }
        if (!ok)
            return (false, _amount, _token);

        if (sourceToken != ETH)
            approve(sourceToken, action.spender, _amount);

        uint value = sourceToken == ETH ? _amount : 0;
        uint toBalanceBefore = getBalanceOf(_message.toToken);

        (bool success, bytes memory ret) = action.target.call{value: value}(action.callData);
        if (success) {
            emit ActionDone(Interchain.ActionType.CALL, action.target, true, "");

            uint toBalanceAfter = getBalanceOf(_message.toToken);
            return (true, toBalanceAfter - toBalanceBefore, _message.toToken);
        } else {
            emit ActionDone(Interchain.ActionType.CALL, action.target, false, _getRevertMsg(ret));
            return (false, _amount, _token);
        }
    }

    /// @notice Performs a uniswap-v2 operation
    /// @param _postAction The type of action to perform such as WRAP, UNWRAP
    /// @param _amount The amount of input token
    /// @return ok Indicates that the swap operation was success or fail
    /// @return amountOut If ok = true, amountOut is the output amount of the swap
    function _handlePostAction(
        address _token,
        uint _amount,
        Interchain.CallSubActionType _postAction,
        BaseProxyStorage storage baseStorage
    ) private returns (bool ok, uint256 amountOut, address outToken) {

        if (_postAction == Interchain.CallSubActionType.WRAP) {
            require(_token == ETH, "Cannot wrap non-native");
            (ok, amountOut, outToken) = _handleWrap(_token, _amount, baseStorage);
        } else if (_postAction == Interchain.CallSubActionType.UNWRAP) {
            require(_token == baseStorage.WETH, "Cannot unwrap non-WETH");
            (ok, amountOut, outToken) = _handleUnwrap(_token, _amount, baseStorage);
        } else {
            revert("Unsupported post-action");
        }
        if (!ok)
            return (false, _amount, _token);
        return (ok, amountOut, outToken);
    }

    /// @notice Performs a WETH.deposit operation
    /// @param _amount The amount of input token
    /// @return ok Indicates that the swap operation was success or fail
    /// @return amountOut If ok = true, amountOut is the output amount of the swap
    function _handleWrap(
        address _token,
        uint _amount,
        BaseProxyStorage storage baseStorage
    ) private returns (bool ok, uint256 amountOut, address outToken) {
        require(_token == ETH, "Cannot wrap non-ETH tokens");

        IWETH(baseStorage.WETH).deposit{value: _amount}();
        emit SubActionDone(Interchain.CallSubActionType.WRAP, baseStorage.WETH, true, "");

        return (true, _amount, baseStorage.WETH);
    }

    /// @notice Performs a WETH.deposit operation
    /// @param _amount The amount of input token
    /// @return ok Indicates that the swap operation was success or fail
    /// @return amountOut If ok = true, amountOut is the output amount of the swap
    function _handleUnwrap(
        address _token,
        uint _amount,
        BaseProxyStorage storage baseStorage
    ) private returns (bool ok, uint256 amountOut, address outToken) {
        if (_token != baseStorage.WETH)
            revert("Non-WETH tokens unwrapped");

        IWETH(baseStorage.WETH).withdraw(_amount);
        emit SubActionDone(Interchain.CallSubActionType.UNWRAP, baseStorage.WETH, true, "");

        return (true, _amount, ETH);
    }
    
    /// @notice An internal function to send a token from the current contract to another contract or wallet
    /// @dev This function also can convert WETH to ETH before sending if _withdraw flat is set to true
    /// @dev To send native token _nativeOut param should be set to true, otherwise we assume it's an ERC20 transfer
    /// @dev If there is a message from a dApp it sends the money to the contract instead of the end-user and calls its handleRangoMessage
    /// @param _token The token that is going to be sent to a wallet, ZERO address for native
    /// @param _amount The sent amount
    /// @param _receiver The receiver wallet address or contract
    function _sendTokenWithDApp(
        address _token,
        uint256 _amount,
        address _receiver,
        bytes memory _dAppMessage,
        address _dAppReceiverContract,
        IRangoMessageReceiver.ProcessStatus processStatus
    ) internal {
        bool thereIsAMessage = _dAppReceiverContract != ETH;
        address immediateReceiver = thereIsAMessage ? _dAppReceiverContract : _receiver;
        BaseInterchainStorage storage messagingStorage = getBaseMessagingContractStorage();
        emit SendToken(_token, _amount, immediateReceiver);

        if (_token == ETH) {
            _sendNative(immediateReceiver, _amount);
        } else {
            SafeERC20Upgradeable.safeTransfer(IERC20Upgradeable(_token), immediateReceiver, _amount);
        }

        if (thereIsAMessage) {
            require(
                messagingStorage.whitelistMessagingContracts[_dAppReceiverContract],
                "3rd-party contract not whitelisted"
            );

            try IRangoMessageReceiver(_dAppReceiverContract)
                .handleRangoMessage(_token, _amount, processStatus, _dAppMessage)
            {
                emit CrossChainMessageCalled(_dAppReceiverContract, _token, _amount, processStatus, _dAppMessage, true, "");
            } catch Error(string memory reason) {
                emit CrossChainMessageCalled(_dAppReceiverContract, _token, _amount, processStatus, _dAppMessage, false, reason);
            } catch (bytes memory lowLevelData) {
                emit CrossChainMessageCalled(_dAppReceiverContract, _token, _amount, processStatus, _dAppMessage, false, _getRevertMsg(lowLevelData));
            }
        }
    }

    /// @notice A utility function to fetch storage from a predefined random slot using assembly
    /// @return s The storage object
    function getBaseMessagingContractStorage() internal pure returns (BaseInterchainStorage storage s) {
        bytes32 namespace = BASE_MESSAGING_CONTRACT_NAMESPACE;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            s.slot := namespace
        }
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "../../interfaces/IWETH.sol";
import "../../interfaces/IThorchainRouter.sol";
import "../../interfaces/IRangoMessageReceiver.sol";

/// @title The base contract that RangoV1 and all its parents inherit to support refund, on-chain swap, and DEX whitelisting
/// @author Uchiha Sasuke
/// @notice It contains storage for whitelisted contracts, refund ERC20 and native tokens and on-chain swap
contract BaseProxyContract is PausableUpgradeable, OwnableUpgradeable, ReentrancyGuardUpgradeable {
    address payable constant ETH = payable(0x0000000000000000000000000000000000000000);

    /// @notice The maximum possible percent of fee that Rango will receive from user times 10,000, so 300 = 3%
    /// @dev The real fee is calculated by smart routing off-chain, this field only limits the value to prevent mis-calculations
    uint constant MAX_FEE_PERCENT_x_10000 = 300;

    /// @notice The maximum possible percent of fee that third-party dApp will receive from user times 10,000, so 300 = 3%
    /// @dev The real fee is calculated by smart routing off-chain, this field only limits the value to prevent mis-calculations
    uint constant MAX_AFFILIATE_PERCENT_x_10000 = 300;

    using SafeMathUpgradeable for uint;

    /// @dev keccak256("exchange.rango.baseproxycontract")
    bytes32 internal constant BASE_PROXY_CONTRACT_NAMESPACE = hex"c23df90b6466cfd0cbf4f6a578f167d2f60ed56371b4746a3c5973c8543f4fd9";

    struct BaseProxyStorage {
        address payable feeContractAddress;
        address WETH;
        mapping (address => bool) whitelistContracts;
    }

    /// @notice Rango received a fee reward
    /// @param token The address of received token, ZERO address for native
    /// @param wallet The address of receiver wallet
    /// @param amount The amount received as fee
    event FeeReward(address token, address wallet, uint amount);

    /// @notice Some money is sent to dApp wallet as affiliate reward
    /// @param token The address of received token, ZERO address for native
    /// @param wallet The address of receiver wallet
    /// @param amount The amount received as fee
    event AffiliateReward(address token, address wallet, uint amount);

    /// @notice A call to another dex or contract done and here is the result
    /// @param target The address of dex or contract that is called
    /// @param success A boolean indicating that the call was success or not
    /// @param returnData The response of function call
    event CallResult(address target, bool success, bytes returnData);

    /// @notice Output amount of a dex calls is logged
    /// @param _token The address of output token, ZERO address for native
    /// @param amount The amount of output
    event DexOutput(address _token, uint amount);

    /// @notice The output money (ERC20/Native) is sent to a wallet
    /// @param _token The token that is sent to a wallet, ZERO address for native
    /// @param _amount The sent amount
    /// @param _receiver The receiver wallet address
    event SendToken(address _token, uint256 _amount, address _receiver);

    /// @notice Notifies that a new contract is whitelisted
    /// @param _factory The address of the contract
    event ContractWhitelisted(address _factory);

    /// @notice Notifies that a new contract is blacklisted
    /// @param _factory The address of the contract
    event ContractBlacklisted(address _factory);

    /// @notice Notifies that Rango's fee receiver address updated
    /// @param _oldAddress The previous fee wallet address
    /// @param _newAddress The new fee wallet address
    event FeeContractAddressUpdated(address _oldAddress, address _newAddress);

    /// @notice Notifies that admin manually refunded some money
    /// @param _token The address of refunded token, 0x000..00 address for native token
    /// @param _amount The amount that is refunded
    event Refunded(address _token, uint _amount);

    /// @notice The requested call data which is computed off-chain and passed to the contract
    /// @param target The dex contract address that should be called
    /// @param callData The required data field that should be give to the dex contract to perform swap
    struct Call { address spender; address payable target; bytes callData; }

    /// @notice General swap request which is given to us in all relevant functions
    /// @param fromToken The source token that is going to be swapped (in case of simple swap or swap + bridge) or the briding token (in case of solo bridge)
    /// @param toToken The output token of swapping. This is the output of DEX step and is also input of bridging step
    /// @param amountIn The amount of input token to be swapped
    /// @param feeIn The amount of fee charged by Rango
    /// @param affiliateIn The amount of fee charged by affiliator dApp
    /// @param affiliatorAddress The wallet address that the affiliator fee should be sent to
    struct SwapRequest {
        address fromToken;
        address toToken;
        uint amountIn;
        uint feeIn;
        uint affiliateIn;
        address payable affiliatorAddress;
    }

    /// @notice Adds a contract to the whitelisted DEXes that can be called
    /// @param _factory The address of the DEX
    function addWhitelist(address _factory) public onlyOwner {
        BaseProxyStorage storage baseStorage = getBaseProxyContractStorage();
        baseStorage.whitelistContracts[_factory] = true;

        emit ContractWhitelisted(_factory);
    }

    /// @notice Adds a list of contracts to the whitelisted DEXes that can be called
    /// @param _factories The addresses of the DEXes
    function addWhitelists(address[] calldata _factories) external onlyOwner {
        for (uint i = 0; i < _factories.length; i++)
            addWhitelist(_factories[i]);
    }

    /// @notice Removes a contract from the whitelisted DEXes
    /// @param _factory The address of the DEX or dApp
    function removeWhitelist(address _factory) external onlyOwner {
        BaseProxyStorage storage baseStorage = getBaseProxyContractStorage();

        require(baseStorage.whitelistContracts[_factory], 'Factory not found');
        delete baseStorage.whitelistContracts[_factory];

        emit ContractBlacklisted(_factory);
    }

    /// @notice Sets the wallet that receives Rango's fees from now on
    /// @param _address The receiver wallet address
    function updateFeeContractAddress(address payable _address) external onlyOwner {
        BaseProxyStorage storage baseProxyStorage = getBaseProxyContractStorage();

        address oldAddress = baseProxyStorage.feeContractAddress;
        baseProxyStorage.feeContractAddress = _address;

        emit FeeContractAddressUpdated(oldAddress, _address);
    }

    /// @notice Transfers an ERC20 token from this contract to msg.sender
    /// @dev This endpoint is to return money to a user if we didn't handle failure correctly and the money is still in the contract
    /// @dev Currently the money goes to admin and they should manually transfer it to a wallet later
    /// @param _tokenAddress The address of ERC20 token to be transferred
    /// @param _amount The amount of money that should be transfered
    function refund(address _tokenAddress, uint256 _amount) external onlyOwner {
        IERC20Upgradeable ercToken = IERC20Upgradeable(_tokenAddress);
        uint balance = ercToken.balanceOf(address(this));
        require(balance >= _amount, "Insufficient balance");

        SafeERC20Upgradeable.safeTransfer(ercToken, msg.sender, _amount);

        emit Refunded(_tokenAddress, _amount);
    }

    /// @notice Transfers the native token from this contract to msg.sender
    /// @dev This endpoint is to return money to a user if we didn't handle failure correctly and the money is still in the contract
    /// @dev Currently the money goes to admin and they should manually transfer it to a wallet later
    /// @param _amount The amount of native token that should be transfered
    function refundNative(uint256 _amount) external onlyOwner {
        uint balance = address(this).balance;
        require(balance >= _amount, "Insufficient balance");

        _sendToken(ETH, _amount, msg.sender, true, false);

        emit Refunded(ETH, _amount);
    }

    function onChainSwapsPreBridge(
        address _bridgeProxy,
        SwapRequest memory request,
        Call[] calldata calls,
        uint extraFee
    ) internal returns (uint out, uint value) {
        require(_bridgeProxy != ETH, 'Bridge proxy address in Rango contract not set');

        bool isNative = request.fromToken == ETH;
        uint minimumRequiredValue = (isNative ? request.feeIn + request.affiliateIn + request.amountIn : 0) + extraFee;
        require(msg.value >= minimumRequiredValue, 'Send more ETH to cover input amount + fee');

        (, out) = onChainSwapsInternal(request, calls);
        if (request.toToken != ETH)
            approve(request.toToken, _bridgeProxy, out);

        value = (request.toToken == ETH ? (out > 0 ? out : request.amountIn) : 0) + extraFee;
        return (out, value);
    }

    /// @notice Internal function to compute output amount of DEXes
    /// @param request The general swap request containing from/to token and fee/affiliate rewards
    /// @param calls The list of DEX calls
    /// @return The response of all DEX calls and the output amount of the whole process
    function onChainSwapsInternal(SwapRequest memory request, Call[] calldata calls) internal returns (bytes[] memory, uint) {

        uint toBalanceBefore = getBalanceOf(request.toToken);
        uint fromBalanceBefore = getBalanceOf(request.fromToken);

        bytes[] memory result = callSwapsAndFees(request, calls);

        uint toBalanceAfter = getBalanceOf(request.toToken);
        uint fromBalanceAfter = getBalanceOf(request.fromToken);

        if (request.fromToken != ETH)
            require(fromBalanceAfter >= fromBalanceBefore, 'Source token balance on contract must not decrease after swap');
        else
            require(fromBalanceAfter >= fromBalanceBefore - msg.value, 'Source token balance on contract must not decrease after swap');

        uint secondaryBalance;
        if (calls.length > 0) {
            require(toBalanceAfter - toBalanceBefore > 0, "No balance found after swaps");

            secondaryBalance = toBalanceAfter - toBalanceBefore;
            emit DexOutput(request.toToken, secondaryBalance);
        } else {
            secondaryBalance = toBalanceAfter > toBalanceBefore ? toBalanceAfter - toBalanceBefore : request.amountIn;
        }

        return (result, secondaryBalance);
    }

    /// @notice Private function to handle fetching money from wallet to contract, reduce fee/affiliate, perform DEX calls
    /// @param request The general swap request containing from/to token and fee/affiliate rewards
    /// @param calls The list of DEX calls
    /// @dev It checks the whitelisting of all DEX addresses + having enough msg.value as input
    /// @dev It checks the max threshold for fee/affiliate
    /// @return The bytes of all DEX calls response
    function callSwapsAndFees(SwapRequest memory request, Call[] calldata calls) private returns (bytes[] memory) {
        bool isSourceNative = request.fromToken == ETH;
        BaseProxyStorage storage baseProxyStorage = getBaseProxyContractStorage();
        
        // validate
        require(baseProxyStorage.feeContractAddress != ETH, "Fee contract address not set");

        for(uint256 i = 0; i < calls.length; i++) {
            require(baseProxyStorage.whitelistContracts[calls[i].spender], "Contract spender not whitelisted");
            require(baseProxyStorage.whitelistContracts[calls[i].target], "Contract target not whitelisted");
        }

        // Get all the money from user
        uint totalInputAmount = request.feeIn + request.affiliateIn + request.amountIn;
        if (isSourceNative)
            require(msg.value >= totalInputAmount, "Not enough ETH provided to contract");

        // Check max fee/affiliate is respected
        uint maxFee = totalInputAmount * MAX_FEE_PERCENT_x_10000 / 10000;
        uint maxAffiliate = totalInputAmount * MAX_AFFILIATE_PERCENT_x_10000 / 10000;
        require(request.feeIn <= maxFee, 'Requested fee exceeded max threshold');
        require(request.affiliateIn <= maxAffiliate, 'Requested affiliate reward exceeded max threshold');

        // Transfer from wallet to contract
        if (!isSourceNative) {
            for(uint256 i = 0; i < calls.length; i++) {
                approve(request.fromToken, calls[i].spender, totalInputAmount);
            }

            uint balanceBefore = getBalanceOf(request.fromToken);
            SafeERC20Upgradeable.safeTransferFrom(IERC20Upgradeable(request.fromToken), msg.sender, address(this), totalInputAmount);
            uint balanceAfter = getBalanceOf(request.fromToken);

            if(balanceAfter > balanceBefore && balanceAfter - balanceBefore < totalInputAmount)
                revert("Deflationary tokens are not supported by Rango contract");
        }

        // Get Platform fee
        if (request.feeIn > 0) {
            _sendToken(request.fromToken, request.feeIn, baseProxyStorage.feeContractAddress, isSourceNative, false);
            emit FeeReward(request.fromToken, baseProxyStorage.feeContractAddress, request.feeIn);
        }

        // Get affiliator fee
        if (request.affiliateIn > 0) {
            require(request.affiliatorAddress != ETH, "Invalid affiliatorAddress");
            _sendToken(request.fromToken, request.affiliateIn, request.affiliatorAddress, isSourceNative, false);
            emit AffiliateReward(request.fromToken, request.affiliatorAddress, request.affiliateIn);
        }

        bytes[] memory returnData = new bytes[](calls.length);
        for (uint256 i = 0; i < calls.length; i++) {
            (bool success, bytes memory ret) = isSourceNative
                ? calls[i].target.call{value: request.amountIn}(calls[i].callData)
                : calls[i].target.call(calls[i].callData);

            emit CallResult(calls[i].target, success, ret);
            if (!success)
                revert(_getRevertMsg(ret));
            returnData[i] = ret;
        }

        return returnData;
    }

    /// @notice Approves an ERC20 token to a contract to transfer from the current contract
    /// @param token The address of an ERC20 token
    /// @param to The contract address that should be approved
    /// @param value The amount that should be approved
    function approve(address token, address to, uint value) internal {
        SafeERC20Upgradeable.safeApprove(IERC20Upgradeable(token), to, 0);
        SafeERC20Upgradeable.safeIncreaseAllowance(IERC20Upgradeable(token), to, value);
    }

    /// @notice An internal function to send a token from the current contract to another contract or wallet
    /// @dev This function also can convert WETH to ETH before sending if _withdraw flat is set to true
    /// @dev To send native token _nativeOut param should be set to true, otherwise we assume it's an ERC20 transfer
    /// @param _token The token that is going to be sent to a wallet, ZERO address for native
    /// @param _amount The sent amount
    /// @param _receiver The receiver wallet address or contract
    /// @param _nativeOut means the output is native token
    /// @param _withdraw If true, indicates that we should swap WETH to ETH before sending the money and _nativeOut must also be true
    function _sendToken(
        address _token,
        uint256 _amount,
        address _receiver,
        bool _nativeOut,
        bool _withdraw
    ) internal {
        BaseProxyStorage storage baseStorage = getBaseProxyContractStorage();
        emit SendToken(_token, _amount, _receiver);

        if (_nativeOut) {
            if (_withdraw) {
                require(_token == baseStorage.WETH, "token mismatch");
                IWETH(baseStorage.WETH).withdraw(_amount);
            }
            _sendNative(_receiver, _amount);
        } else {
            SafeERC20Upgradeable.safeTransfer(IERC20Upgradeable(_token), _receiver, _amount);
        }
    }

    /// @notice An internal function to send native token to a contract or wallet
    /// @param _receiver The address that will receive the native token
    /// @param _amount The amount of the native token that should be sent
    function _sendNative(address _receiver, uint _amount) internal {
        (bool sent, ) = _receiver.call{value: _amount}("");
        require(sent, "failed to send native");
    }


    /// @notice A utility function to fetch storage from a predefined random slot using assembly
    /// @return s The storage object
    function getBaseProxyContractStorage() internal pure returns (BaseProxyStorage storage s) {
        bytes32 namespace = BASE_PROXY_CONTRACT_NAMESPACE;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            s.slot := namespace
        }
    }

    /// @notice To extract revert message from a DEX/contract call to represent to the end-user in the blockchain
    /// @param _returnData The resulting bytes of a failed call to a DEX or contract
    /// @return A string that describes what was the error
    function _getRevertMsg(bytes memory _returnData) internal pure returns (string memory) {
        // If the _res length is less than 68, then the transaction failed silently (without a revert message)
        if (_returnData.length < 68) return 'Transaction reverted silently';

        assembly {
            // Slice the sighash.
            _returnData := add(_returnData, 0x04)
        }
        return abi.decode(_returnData, (string)); // All that remains is the revert string
    }

    function getBalanceOf(address token) internal view returns (uint) {
        IERC20Upgradeable ercToken = IERC20Upgradeable(token);
        return token == ETH ? address(this).balance : ercToken.balanceOf(address(this));
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import "./im/message/framework/MessageSenderApp.sol";
import "./im/message/framework/MessageReceiverApp.sol";
import "../../../interfaces/IUniswapV2.sol";
import "../../../interfaces/IWETH.sol";
import "./im/interfaces/IMessageBusSender.sol";
import "../../../interfaces/IRangoCBridge.sol";
import "../../base/BaseInterchainContract.sol";
import "../../../interfaces/IRangoMessageReceiver.sol";
import "../../../interfaces/Interchain.sol";

/// @title The root contract that handles Rango's interaction with cBridge and receives message from Celer IM
/// @author Uchiha Sasuke
/// @dev This is deployed as a separate contract from RangoV1
contract RangoCBridge is IRangoCBridge, MessageSenderApp, MessageReceiverApp, BaseInterchainContract {

    /// @notice The address of cBridge contract
    address cBridgeAddress;

    /// @notice The initializer of this contract that receives WETH address and initiates the settings
    /// @param _weth The address of WETH, WBNB, etc of the current network
    /// @param _cBridgeAddress The address of cBridge contract
    /// @param _messageBus The address of cBridge message bus
    function initialize(address _weth, address _cBridgeAddress, address _messageBus) public initializer {
        BaseProxyStorage storage baseStorage = getBaseProxyContractStorage();
        baseStorage.WETH = _weth;

        __Ownable_init();

        updateCBridgeAddressInternal(_cBridgeAddress);
        setMessageBusInternal(_messageBus);

        __Ownable_init();
        __Pausable_init();
        __ReentrancyGuard_init();
    }

    /// @notice Enables the contract to receive native ETH token from other contracts including WETH contract
    receive() external payable { }

    /// @notice A series of events with different status value to help us track the progress of cross-chain swap
    /// @param id The transferId generated by cBridge
    /// @param token The token address in the current network that is being bridged
    /// @param outputAmount The latest observed amount in the path, aka: input amount for source and output amount on dest
    /// @param _destination The destination address that received the money, ZERO address if not sent to the end-user yet
    event CBridgeIMStatusUpdated(bytes32 id, address token, uint256 outputAmount, OperationStatus status, address _destination);

    /// @notice A simple cBridge.send scenario
    /// @param _receiver The wallet address of receiver on the destination
    /// @param _token The address of token on the source chain
    /// @param _amount The input amount sent to the bridge
    /// @param _dstChainId The network id of destination chain
    /// @param _nonce A nonce mechanism used by cBridge that is generated off-chain, it normally is the time.now()
    /// @param _maxSlippage The maximum tolerable slippage by user on cBridge side (The bridge is not 1-1 and may have slippage in big swaps)
    event CBridgeSend(address _receiver, address _token, uint256 _amount, uint64 _dstChainId, uint64 _nonce, uint32 _maxSlippage);

    /// @notice Emits when the cBridge address is updated
    /// @param _oldAddress The previous address
    /// @param _newAddress The new address

    event CBridgeAddressUpdated(address _oldAddress, address _newAddress);

    /// @notice Updates the address of cBridge contract
    /// @param _address The new address of cBridge contract
    function updateCBridgeAddress(address _address) public onlyOwner {
        updateCBridgeAddressInternal(_address);
    }

    /// @notice Computes the sgnFee for a given message based on messageBus formula
    /// @param imMessage The message that fee is computed for
    function computeCBridgeSgnFee(Interchain.RangoInterChainMessage memory imMessage) external view returns(uint) {
        bytes memory msgBytes = abi.encode(imMessage);
        return IMessageBus(messageBus).calcFee(msgBytes);
    }

    /// @inheritdoc IRangoCBridge
    function send(
        address _receiver,
        address _token,
        uint256 _amount,
        uint64 _dstChainId,
        uint64 _nonce,
        uint32 _maxSlippage
    ) external override whenNotPaused nonReentrant {
        require(cBridgeAddress != ETH, 'cBridge address not set');
        SafeERC20.safeTransferFrom(IERC20(_token), msg.sender, address(this), _amount);
        approve(_token, cBridgeAddress, _amount);
        IBridge(cBridgeAddress).send(_receiver, _token, _amount, _dstChainId, _nonce, _maxSlippage);
        emit CBridgeSend(_receiver, _token, _amount, _dstChainId, _nonce, _maxSlippage);
    }

    /// @inheritdoc IRangoCBridge
    function cBridgeIM(
        address _fromToken,
        uint _inputAmount,
        address _receiverContract, // The receiver app contract address, not recipient
        uint64 _dstChainId,
        uint64 _nonce,
        uint32 _maxSlippage,
        uint _sgnFee,

        Interchain.RangoInterChainMessage memory imMessage
    ) external override payable whenNotPaused nonReentrant {
        require(msg.value >= _sgnFee, 'sgnFee is bigger than the input');

        require(messageBus != ETH, 'cBridge message-bus address not set');
        require(cBridgeAddress != ETH, 'cBridge address not set');
        require(imMessage.dstChainId == _dstChainId, '_dstChainId and imMessage.dstChainId do not match');

        SafeERC20.safeTransferFrom(IERC20(_fromToken), msg.sender, address(this), _inputAmount);
        approve(_fromToken, cBridgeAddress, _inputAmount);

        bytes memory message = abi.encode(imMessage);

        sendMessageWithTransfer(
            _receiverContract,
            _fromToken,
            _inputAmount,
            _dstChainId,
            _nonce,
            _maxSlippage,
            message,
            MsgDataTypes.BridgeSendType.Liquidity,
            _sgnFee
        );

        bytes32 id = _computeSwapRequestId(imMessage.originalSender, uint64(block.chainid), _dstChainId, message);
        emit CBridgeIMStatusUpdated(id, _fromToken, _inputAmount, OperationStatus.Created, ETH);
    }

    /// @inheritdoc IMessageReceiverApp
    /// @dev We also send a message to dApp if dAppMessage is valid
    /// @dev We refund the money back to the _message.originalSender which is the source wallet address or any wallet that dapp likes to be receiver of the refund
    function executeMessageWithTransferRefund(
        address _token,
        uint256 _amount,
        bytes calldata _message,
        address // executor
    ) external payable override onlyMessageBus returns (ExecutionStatus) {
        Interchain.RangoInterChainMessage memory m = abi.decode((_message), (Interchain.RangoInterChainMessage));

        BaseProxyStorage storage baseStorage = getBaseProxyContractStorage();
        address fromToken = _token;
        if (_token == baseStorage.WETH) {
            if (IERC20(_token).balanceOf(address(this)) < _amount) {
                if (address(this).balance >= _amount) {
                    fromToken = ETH;
                } else {
                    revert("Neither WETH nor ETH were found on contract");
                }
            }
        }
        
        _sendTokenWithDApp(
            fromToken,
            _amount,
            m.originalSender,
            m.dAppMessage,
            m.dAppSourceContract,
            IRangoMessageReceiver.ProcessStatus.REFUND_IN_SOURCE
        );

        bytes32 id = _computeSwapRequestId(m.originalSender, uint64(block.chainid), m.dstChainId, _message);
        emit CBridgeIMStatusUpdated(id, fromToken, _amount, OperationStatus.RefundInSource, m.originalSender);

        return ExecutionStatus.Success;
    }

    /// @inheritdoc IMessageReceiverApp
    /**
     * @dev If our _message contains a uniswap-like DEX call on the destination we also perform it here
     * There are also some flags such as:
     * 1. _message.bridgeNativeOut which indicates that bridge sent native token to us, so we unwrap it if required
     * 2. _message.nativeOut which indicates that we should send native token to end-user/dapp so we unwrap it if needed
     */
    function executeMessageWithTransfer(
        address, // _sender
        address _token,
        uint256 _amount,
        uint64 _srcChainId,
        bytes memory _message,
        address // executor
    ) external payable override onlyMessageBus whenNotPaused nonReentrant returns (ExecutionStatus) {
        Interchain.RangoInterChainMessage memory m = abi.decode((_message), (Interchain.RangoInterChainMessage));
        bytes32 id = _computeSwapRequestId(m.originalSender, _srcChainId, uint64(block.chainid), _message);

        (address receivedToken, uint dstAmount, OperationStatus status) = handleDestinationMessage(_token, _amount, m);

        emit CBridgeIMStatusUpdated(id, receivedToken, dstAmount, status, m.recipient);
        // always return success since swap failure is already handled in-place
        return ExecutionStatus.Success;
    }

    /// @inheritdoc IMessageReceiverApp
    /// @dev In case of failure in the destination, we only send money to the end-user in the destination
    function executeMessageWithTransferFallback(
        address, // _sender
        address _token, // _token
        uint256 _amount, // _amount
        uint64 _srcChainId,
        bytes memory _message,
        address // executor
    ) external payable override onlyMessageBus whenNotPaused nonReentrant returns (ExecutionStatus) {
        Interchain.RangoInterChainMessage memory m = abi.decode((_message), (Interchain.RangoInterChainMessage));
        BaseProxyStorage storage baseStorage = getBaseProxyContractStorage();

        bytes32 id = _computeSwapRequestId(m.originalSender, _srcChainId, uint64(block.chainid), _message);
        address sourceToken = m.bridgeRealOutput == ETH && _token == baseStorage.WETH ? ETH : _token;

        _sendTokenWithDApp(
            sourceToken,
            _amount,
            m.originalSender,
            m.dAppMessage,
            m.dAppSourceContract,
            IRangoMessageReceiver.ProcessStatus.REFUND_IN_DESTINATION
        );

        emit CBridgeIMStatusUpdated(id, _token, _amount, OperationStatus.RefundInDestination, m.originalSender);
        return ExecutionStatus.Fail;
    }

    /// @notice Computes the transferId generated by cBridge
    /// @param _sender The sender wallet or contract address
    /// @param _srcChainId The network id of source
    /// @param _dstChainId The network id of destination
    /// @param _message The byte array message that Rango likes to transfer
    /// @return The bytes32 hash of all these information combined
    function _computeSwapRequestId(
        address _sender,
        uint64 _srcChainId,
        uint64 _dstChainId,
        bytes memory _message
    ) private pure returns (bytes32) {
        return keccak256(abi.encodePacked(_sender, _srcChainId, _dstChainId, _message));
    }

    function updateCBridgeAddressInternal(address _address) private {
        address oldAddress = cBridgeAddress;
        cBridgeAddress = _address;

        emit CBridgeAddressUpdated(oldAddress, _address);
    }
}

// SPDX-License-Identifier: GPL-3.0-only

pragma solidity 0.8.13;

interface IBridge {
    function send(
        address _receiver,
        address _token,
        uint256 _amount,
        uint64 _dstChainId,
        uint64 _nonce,
        uint32 _maxSlippage
    ) external;

    function relay(
        bytes calldata _relayRequest,
        bytes[] calldata _sigs,
        address[] calldata _signers,
        uint256[] calldata _powers
    ) external;

    function transfers(bytes32 transferId) external view returns (bool);

    function withdraws(bytes32 withdrawId) external view returns (bool);

    function withdraw(
        bytes calldata _wdmsg,
        bytes[] calldata _sigs,
        address[] calldata _signers,
        uint256[] calldata _powers
    ) external;

    /**
     * @notice Verifies that a message is signed by a quorum among the signers.
     * @param _msg signed message
     * @param _sigs list of signatures sorted by signer addresses in ascending order
     * @param _signers sorted list of current signers
     * @param _powers powers of current signers
     */
    function verifySigs(
        bytes memory _msg,
        bytes[] calldata _sigs,
        address[] calldata _signers,
        uint256[] calldata _powers
    ) external view;
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

interface IMessageBusSender {
    function calcFee(bytes calldata _message) external view returns (uint256);
}

// SPDX-License-Identifier: GPL-3.0-only

pragma solidity 0.8.13;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

abstract contract MessageBusAddress is OwnableUpgradeable {
    event MessageBusUpdated(address messageBus);

    address public messageBus;

    function setMessageBus(address _messageBus) public onlyOwner {
        setMessageBusInternal(_messageBus);
    }

    function setMessageBusInternal(address _messageBus) internal {
        messageBus = _messageBus;
        emit MessageBusUpdated(messageBus);
    }

}

// SPDX-License-Identifier: GPL-3.0-only

pragma solidity 0.8.13;

import "../interfaces/IMessageReceiverApp.sol";
import "./MessageBusAddress.sol";

abstract contract MessageReceiverApp is IMessageReceiverApp, MessageBusAddress {
    modifier onlyMessageBus() {
        require(msg.sender == messageBus, "caller is not message bus");
        _;
    }

    /**
     * @notice Called by MessageBus (MessageBusReceiver) if the process is originated from MessageBus (MessageBusSender)'s
     *         sendMessageWithTransfer it is only called when the tokens are checked to be arrived at this contract's address.
     * @param _sender The address of the source app contract
     * @param _token The address of the token that comes out of the bridge
     * @param _amount The amount of tokens received at this contract through the cross-chain bridge.
     *        the contract that implements this contract can safely assume that the tokens will arrive before this
     *        function is called.
     * @param _srcChainId The source chain ID where the transfer is originated from
     * @param _message Arbitrary message bytes originated from and encoded by the source app contract
     * @param _executor Address who called the MessageBus execution function
     */
    function executeMessageWithTransfer(
        address _sender,
        address _token,
        uint256 _amount,
        uint64 _srcChainId,
        bytes calldata _message,
        address _executor
    ) external payable virtual override onlyMessageBus returns (ExecutionStatus) {}

    /**
     * @notice Only called by MessageBus (MessageBusReceiver) if
     *         1. executeMessageWithTransfer reverts, or
     *         2. executeMessageWithTransfer returns ExecutionStatus.Fail
     * @param _sender The address of the source app contract
     * @param _token The address of the token that comes out of the bridge
     * @param _amount The amount of tokens received at this contract through the cross-chain bridge.
     *        the contract that implements this contract can safely assume that the tokens will arrive before this
     *        function is called.
     * @param _srcChainId The source chain ID where the transfer is originated from
     * @param _message Arbitrary message bytes originated from and encoded by the source app contract
     * @param _executor Address who called the MessageBus execution function
     */
    function executeMessageWithTransferFallback(
        address _sender,
        address _token,
        uint256 _amount,
        uint64 _srcChainId,
        bytes calldata _message,
        address _executor
    ) external payable virtual override onlyMessageBus returns (ExecutionStatus) {}

    /**
     * @notice Called by MessageBus (MessageBusReceiver) to process refund of the original transfer from this contract
     * @param _token The token address of the original transfer
     * @param _amount The amount of the original transfer
     * @param _message The same message associated with the original transfer
     * @param _executor Address who called the MessageBus execution function
     */
    function executeMessageWithTransferRefund(
        address _token,
        uint256 _amount,
        bytes calldata _message,
        address _executor
    ) external payable virtual override onlyMessageBus returns (ExecutionStatus) {}

    /**
     * @notice Called by MessageBus (MessageBusReceiver)
     * @param _sender The address of the source app contract
     * @param _srcChainId The source chain ID where the transfer is originated from
     * @param _message Arbitrary message bytes originated from and encoded by the source app contract
     * @param _executor Address who called the MessageBus execution function
     */
    function executeMessage(
        address _sender,
        uint64 _srcChainId,
        bytes calldata _message,
        address _executor
    ) external payable virtual override onlyMessageBus returns (ExecutionStatus) {}
}

// SPDX-License-Identifier: GPL-3.0-only

pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "../libraries/MsgDataTypes.sol";
import "../libraries/MessageSenderLib.sol";
import "./MessageBusAddress.sol";

abstract contract MessageSenderApp is MessageBusAddress {
    using SafeERC20 for IERC20;

    // ============== Utility functions called by apps ==============

    /**
     * @notice Sends a message to a contract on another chain.
     * Sender needs to make sure the uniqueness of the message Id, which is computed as
     * hash(type.MessageOnly, sender, receiver, srcChainId, srcTxHash, dstChainId, message).
     * If messages with the same Id are sent, only one of them will succeed at dst chain.
     * @param _receiver The address of the destination app contract.
     * @param _dstChainId The destination chain ID.
     * @param _message Arbitrary message bytes to be decoded by the destination app contract.
     * @param _fee The fee amount to pay to MessageBus.
     */
    function sendMessage(
        address _receiver,
        uint64 _dstChainId,
        bytes memory _message,
        uint256 _fee
    ) internal {
        MessageSenderLib.sendMessage(_receiver, _dstChainId, _message, messageBus, _fee);
    }

    /**
     * @notice Sends a message associated with a transfer to a contract on another chain.
     * @param _receiver The address of the destination app contract.
     * @param _token The address of the token to be sent.
     * @param _amount The amount of tokens to be sent.
     * @param _dstChainId The destination chain ID.
     * @param _nonce A number input to guarantee uniqueness of transferId. Can be timestamp in practice.
     * @param _maxSlippage The max slippage accepted, given as percentage in point (pip). Eg. 5000 means 0.5%.
     *        Must be greater than minimalMaxSlippage. Receiver is guaranteed to receive at least
     *        (100% - max slippage percentage) * amount or the transfer can be refunded.
     *        Only applicable to the {MsgDataTypes.BridgeSendType.Liquidity}.
     * @param _message Arbitrary message bytes to be decoded by the destination app contract.
     *        If message is empty, only the token transfer will be sent
     * @param _bridgeSendType One of the {BridgeSendType} enum.
     * @param _fee The fee amount to pay to MessageBus.
     * @return The transfer ID.
     */
    function sendMessageWithTransfer(
        address _receiver,
        address _token,
        uint256 _amount,
        uint64 _dstChainId,
        uint64 _nonce,
        uint32 _maxSlippage,
        bytes memory _message,
        MsgDataTypes.BridgeSendType _bridgeSendType,
        uint256 _fee
    ) internal returns (bytes32) {
        return
            MessageSenderLib.sendMessageWithTransfer(
                _receiver,
                _token,
                _amount,
                _dstChainId,
                _nonce,
                _maxSlippage,
                _message,
                _bridgeSendType,
                messageBus,
                _fee
            );
    }

    /**
     * @notice Sends a token transfer via a bridge.
     * @dev sendMessageWithTransfer with empty message
     * @param _receiver The address of the destination app contract.
     * @param _token The address of the token to be sent.
     * @param _amount The amount of tokens to be sent.
     * @param _dstChainId The destination chain ID.
     * @param _nonce A number input to guarantee uniqueness of transferId. Can be timestamp in practice.
     * @param _maxSlippage The max slippage accepted, given as percentage in point (pip). Eg. 5000 means 0.5%.
     *        Must be greater than minimalMaxSlippage. Receiver is guaranteed to receive at least
     *        (100% - max slippage percentage) * amount or the transfer can be refunded.
     *        Only applicable to the {MsgDataTypes.BridgeSendType.Liquidity}.
     * @param _bridgeSendType One of the {BridgeSendType} enum.
     */
    function sendTokenTransfer(
        address _receiver,
        address _token,
        uint256 _amount,
        uint64 _dstChainId,
        uint64 _nonce,
        uint32 _maxSlippage,
        MsgDataTypes.BridgeSendType _bridgeSendType
    ) internal returns (bytes32) {
        return
            MessageSenderLib.sendMessageWithTransfer(
                _receiver,
                _token,
                _amount,
                _dstChainId,
                _nonce,
                _maxSlippage,
                "", // empty message, which will not trigger sendMessage
                _bridgeSendType,
                messageBus,
                0
            );
    }
}

// SPDX-License-Identifier: GPL-3.0-only

pragma solidity 0.8.13;

import "../libraries/MsgDataTypes.sol";

interface IMessageBus {
    function liquidityBridge() external view returns (address);

    function pegBridge() external view returns (address);

    function pegBridgeV2() external view returns (address);

    function pegVault() external view returns (address);

    function pegVaultV2() external view returns (address);

    /**
     * @notice Calculates the required fee for the message.
     * @param _message Arbitrary message bytes to be decoded by the destination app contract.
     @ @return The required fee.
     */
    function calcFee(bytes calldata _message) external view returns (uint256);

    /**
     * @notice Sends a message to a contract on another chain.
     * Sender needs to make sure the uniqueness of the message Id, which is computed as
     * hash(type.MessageOnly, sender, receiver, srcChainId, srcTxHash, dstChainId, message).
     * If messages with the same Id are sent, only one of them will succeed at dst chain..
     * A fee is charged in the native gas token.
     * @param _receiver The address of the destination app contract.
     * @param _dstChainId The destination chain ID.
     * @param _message Arbitrary message bytes to be decoded by the destination app contract.
     */
    function sendMessage(
        address _receiver,
        uint256 _dstChainId,
        bytes calldata _message
    ) external payable;

    /**
     * @notice Sends a message associated with a transfer to a contract on another chain.
     * If messages with the same srcTransferId are sent, only one of them will succeed at dst chain..
     * A fee is charged in the native token.
     * @param _receiver The address of the destination app contract.
     * @param _dstChainId The destination chain ID.
     * @param _srcBridge The bridge contract to send the transfer with.
     * @param _srcTransferId The transfer ID.
     * @param _dstChainId The destination chain ID.
     * @param _message Arbitrary message bytes to be decoded by the destination app contract.
     */
    function sendMessageWithTransfer(
        address _receiver,
        uint256 _dstChainId,
        address _srcBridge,
        bytes32 _srcTransferId,
        bytes calldata _message
    ) external payable;

    /**
     * @notice Withdraws message fee in the form of native gas token.
     * @param _account The address receiving the fee.
     * @param _cumulativeFee The cumulative fee credited to the account. Tracked by SGN.
     * @param _sigs The list of signatures sorted by signing addresses in ascending order. A withdrawal must be
     * signed-off by +2/3 of the sigsVerifier's current signing power to be delivered.
     * @param _signers The sorted list of signers.
     * @param _powers The signing powers of the signers.
     */
    function withdrawFee(
        address _account,
        uint256 _cumulativeFee,
        bytes[] calldata _sigs,
        address[] calldata _signers,
        uint256[] calldata _powers
    ) external;

    /**
     * @notice Execute a message with a successful transfer.
     * @param _message Arbitrary message bytes originated from and encoded by the source app contract
     * @param _transfer The transfer info.
     * @param _sigs The list of signatures sorted by signing addresses in ascending order. A relay must be signed-off by
     * +2/3 of the sigsVerifier's current signing power to be delivered.
     * @param _signers The sorted list of signers.
     * @param _powers The signing powers of the signers.
     */
    function executeMessageWithTransfer(
        bytes calldata _message,
        MsgDataTypes.TransferInfo calldata _transfer,
        bytes[] calldata _sigs,
        address[] calldata _signers,
        uint256[] calldata _powers
    ) external payable;

    /**
     * @notice Execute a message with a refunded transfer.
     * @param _message Arbitrary message bytes originated from and encoded by the source app contract
     * @param _transfer The transfer info.
     * @param _sigs The list of signatures sorted by signing addresses in ascending order. A relay must be signed-off by
     * +2/3 of the sigsVerifier's current signing power to be delivered.
     * @param _signers The sorted list of signers.
     * @param _powers The signing powers of the signers.
     */
    function executeMessageWithTransferRefund(
        bytes calldata _message, // the same message associated with the original transfer
        MsgDataTypes.TransferInfo calldata _transfer,
        bytes[] calldata _sigs,
        address[] calldata _signers,
        uint256[] calldata _powers
    ) external payable;

    /**
     * @notice Execute a message not associated with a transfer.
     * @param _message Arbitrary message bytes originated from and encoded by the source app contract
     * @param _sigs The list of signatures sorted by signing addresses in ascending order. A relay must be signed-off by
     * +2/3 of the sigsVerifier's current signing power to be delivered.
     * @param _signers The sorted list of signers.
     * @param _powers The signing powers of the signers.
     */
    function executeMessage(
        bytes calldata _message,
        MsgDataTypes.RouteInfo calldata _route,
        bytes[] calldata _sigs,
        address[] calldata _signers,
        uint256[] calldata _powers
    ) external payable;
}

// SPDX-License-Identifier: GPL-3.0-only

pragma solidity 0.8.13;

interface IMessageReceiverApp {
    enum ExecutionStatus {
        Fail, // execution failed, finalized
        Success, // execution succeeded, finalized
        Retry // execution rejected, can retry later
    }

    /**
     * @notice Called by MessageBus (MessageBusReceiver) if the process is originated from MessageBus (MessageBusSender)'s
     *         sendMessageWithTransfer it is only called when the tokens are checked to be arrived at this contract's address.
     * @param _sender The address of the source app contract
     * @param _token The address of the token that comes out of the bridge
     * @param _amount The amount of tokens received at this contract through the cross-chain bridge.
     *        the contract that implements this contract can safely assume that the tokens will arrive before this
     *        function is called.
     * @param _srcChainId The source chain ID where the transfer is originated from
     * @param _message Arbitrary message bytes originated from and encoded by the source app contract
     * @param _executor Address who called the MessageBus execution function
     */
    function executeMessageWithTransfer(
        address _sender,
        address _token,
        uint256 _amount,
        uint64 _srcChainId,
        bytes calldata _message,
        address _executor
    ) external payable returns (ExecutionStatus);

    /**
     * @notice Only called by MessageBus (MessageBusReceiver) if
     *         1. executeMessageWithTransfer reverts, or
     *         2. executeMessageWithTransfer returns ExecutionStatus.Fail
     * @param _sender The address of the source app contract
     * @param _token The address of the token that comes out of the bridge
     * @param _amount The amount of tokens received at this contract through the cross-chain bridge.
     *        the contract that implements this contract can safely assume that the tokens will arrive before this
     *        function is called.
     * @param _srcChainId The source chain ID where the transfer is originated from
     * @param _message Arbitrary message bytes originated from and encoded by the source app contract
     * @param _executor Address who called the MessageBus execution function
     */
    function executeMessageWithTransferFallback(
        address _sender,
        address _token,
        uint256 _amount,
        uint64 _srcChainId,
        bytes calldata _message,
        address _executor
    ) external payable returns (ExecutionStatus);

    /**
     * @notice Called by MessageBus (MessageBusReceiver) to process refund of the original transfer from this contract
     * @param _token The token address of the original transfer
     * @param _amount The amount of the original transfer
     * @param _message The same message associated with the original transfer
     * @param _executor Address who called the MessageBus execution function
     */
    function executeMessageWithTransferRefund(
        address _token,
        uint256 _amount,
        bytes calldata _message,
        address _executor
    ) external payable returns (ExecutionStatus);

    /**
     * @notice Called by MessageBus (MessageBusReceiver)
     * @param _sender The address of the source app contract
     * @param _srcChainId The source chain ID where the transfer is originated from
     * @param _message Arbitrary message bytes originated from and encoded by the source app contract
     * @param _executor Address who called the MessageBus execution function
     */
    function executeMessage(
        address _sender,
        uint64 _srcChainId,
        bytes calldata _message,
        address _executor
    ) external payable returns (ExecutionStatus);
}

// SPDX-License-Identifier: GPL-3.0-only

pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../../interfaces/IBridge.sol";
import "../interfaces/IMessageBus.sol";
import "./MsgDataTypes.sol";

library MessageSenderLib {
    using SafeERC20 for IERC20;

    // ============== Internal library functions called by apps ==============

    /**
     * @notice Sends a message to a contract on another chain.
     * Sender needs to make sure the uniqueness of the message Id, which is computed as
     * hash(type.MessageOnly, sender, receiver, srcChainId, srcTxHash, dstChainId, message).
     * If messages with the same Id are sent, only one of them will succeed at dst chain.
     * @param _receiver The address of the destination app contract.
     * @param _dstChainId The destination chain ID.
     * @param _message Arbitrary message bytes to be decoded by the destination app contract.
     * @param _messageBus The address of the MessageBus on this chain.
     * @param _fee The fee amount to pay to MessageBus.
     */
    function sendMessage(
        address _receiver,
        uint64 _dstChainId,
        bytes memory _message,
        address _messageBus,
        uint256 _fee
    ) internal {
        IMessageBus(_messageBus).sendMessage{value: _fee}(_receiver, _dstChainId, _message);
    }

    /**
     * @notice Sends a message associated with a transfer to a contract on another chain.
     * @param _receiver The address of the destination app contract.
     * @param _token The address of the token to be sent.
     * @param _amount The amount of tokens to be sent.
     * @param _dstChainId The destination chain ID.
     * @param _nonce A number input to guarantee uniqueness of transferId. Can be timestamp in practice.
     * @param _maxSlippage The max slippage accepted, given as percentage in point (pip). Eg. 5000 means 0.5%.
     *        Must be greater than minimalMaxSlippage. Receiver is guaranteed to receive at least
     *        (100% - max slippage percentage) * amount or the transfer can be refunded.
     *        Only applicable to the {MsgDataTypes.BridgeSendType.Liquidity}.
     * @param _message Arbitrary message bytes to be decoded by the destination app contract.
     *        If message is empty, only the token transfer will be sent
     * @param _bridgeSendType One of the {MsgDataTypes.BridgeSendType} enum.
     * @param _messageBus The address of the MessageBus on this chain.
     * @param _fee The fee amount to pay to MessageBus.
     * @return The transfer ID.
     */
    function sendMessageWithTransfer(
        address _receiver,
        address _token,
        uint256 _amount,
        uint64 _dstChainId,
        uint64 _nonce,
        uint32 _maxSlippage,
        bytes memory _message,
        MsgDataTypes.BridgeSendType _bridgeSendType,
        address _messageBus,
        uint256 _fee
    ) internal returns (bytes32) {
        if (_bridgeSendType == MsgDataTypes.BridgeSendType.Liquidity) {
            return
                sendMessageWithLiquidityBridgeTransfer(
                    _receiver,
                    _token,
                    _amount,
                    _dstChainId,
                    _nonce,
                    _maxSlippage,
                    _message,
                    _messageBus,
                    _fee
                );
        } else {
            revert("bridge type not supported");
        }
    }

    /**
     * @notice Sends a message to an app on another chain via MessageBus with an associated liquidity bridge transfer.
     * @param _receiver The address of the destination app contract.
     * @param _token The address of the token to be sent.
     * @param _amount The amount of tokens to be sent.
     * @param _dstChainId The destination chain ID.
     * @param _nonce A number input to guarantee uniqueness of transferId. Can be timestamp in practice.
     * @param _maxSlippage The max slippage accepted, given as percentage in point (pip). Eg. 5000 means 0.5%.
     *        Must be greater than minimalMaxSlippage. Receiver is guaranteed to receive at least
     *        (100% - max slippage percentage) * amount or the transfer can be refunded.
     * @param _message Arbitrary message bytes to be decoded by the destination app contract.
     *        If message is empty, only the token transfer will be sent
     * @param _messageBus The address of the MessageBus on this chain.
     * @param _fee The fee amount to pay to MessageBus.
     * @return The transfer ID.
     */
    function sendMessageWithLiquidityBridgeTransfer(
        address _receiver,
        address _token,
        uint256 _amount,
        uint64 _dstChainId,
        uint64 _nonce,
        uint32 _maxSlippage,
        bytes memory _message,
        address _messageBus,
        uint256 _fee
    ) internal returns (bytes32) {
        address bridge = IMessageBus(_messageBus).liquidityBridge();
        IERC20(_token).safeIncreaseAllowance(bridge, _amount);
        IBridge(bridge).send(_receiver, _token, _amount, _dstChainId, _nonce, _maxSlippage);
        bytes32 transferId = keccak256(
            abi.encodePacked(address(this), _receiver, _token, _amount, _dstChainId, _nonce, uint64(block.chainid))
        );
        if (_message.length > 0) {
            IMessageBus(_messageBus).sendMessageWithTransfer{value: _fee}(
                _receiver,
                _dstChainId,
                bridge,
                transferId,
                _message
            );
        }
        return transferId;
    }
}

// SPDX-License-Identifier: GPL-3.0-only

pragma solidity 0.8.13;

library MsgDataTypes {
    // bridge operation type at the sender side (src chain)
    enum BridgeSendType {
        Null,
        Liquidity,
        PegDeposit,
        PegBurn,
        PegV2Deposit,
        PegV2Burn,
        PegV2BurnFrom
    }

    // bridge operation type at the receiver side (dst chain)
    enum TransferType {
        Null,
        LqRelay, // relay through liquidity bridge
        LqWithdraw, // withdraw from liquidity bridge
        PegMint, // mint through pegged token bridge
        PegWithdraw, // withdraw from original token vault
        PegV2Mint, // mint through pegged token bridge v2
        PegV2Withdraw // withdraw from original token vault v2
    }

    enum MsgType {
        MessageWithTransfer,
        MessageOnly
    }

    enum TxStatus {
        Null,
        Success,
        Fail,
        Fallback,
        Pending // transient state within a transaction
    }

    struct TransferInfo {
        TransferType t;
        address sender;
        address receiver;
        address token;
        uint256 amount;
        uint64 wdseq; // only needed for LqWithdraw (refund)
        uint64 srcChainId;
        bytes32 refId;
        bytes32 srcTxHash; // src chain msg tx hash
    }

    struct RouteInfo {
        address sender;
        address receiver;
        uint64 srcChainId;
        bytes32 srcTxHash; // src chain msg tx hash
    }

    struct MsgWithTransferExecutionParams {
        bytes message;
        TransferInfo transfer;
        bytes[] sigs;
        address[] signers;
        uint256[] powers;
    }

    struct BridgeTransferParams {
        bytes request;
        bytes[] sigs;
        address[] signers;
        uint256[] powers;
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import "./Interchain.sol";

/// @title An interface to RangoCBridge.sol contract to improve type hinting
/// @author Uchiha Sasuke
interface IRangoCBridge {
    /// @notice Executes a cBridgeIM call
    /// @param _fromToken The address of source token to bridge
    /// @param _inputAmount The amount of input to be bridged
    /// @param _receiverContract Our RangoCbridge.sol contract in the destination chain that will handle the destination logic
    /// @param _dstChainId The network id of destination chain, ex: 10 for optimism
    /// @param _nonce A nonce mechanism used by cBridge that is generated off-chain, it normally is the time.now()
    /// @param _maxSlippage The maximum tolerable slippage by user on cBridge side (The bridge is not 1-1 and may have slippage in big swaps)
    /// @param _sgnFee The fee amount (in native token) that cBridge IM charges for delivering the message
    /// @param imMessage Our custom interchain message that contains all the required info for the RangoCBridge.sol on the destination
    function cBridgeIM(
        address _fromToken,
        uint _inputAmount,
        address _receiverContract, // The receiver app contract address, not recipient
        uint64 _dstChainId,
        uint64 _nonce,
        uint32 _maxSlippage,
        uint _sgnFee,

        Interchain.RangoInterChainMessage memory imMessage
    ) external payable;

    /// @notice Executes a bridging via cBridge
    /// @param _receiver The receiver address in the destination chain
    /// @param _token The token address to be bridged
    /// @param _amount The amount of the token to be bridged
    /// @param _dstChainId The network id of destination chain, ex: 10 for optimism
    /// @param _nonce A nonce mechanism used by cBridge that is generated off-chain, it normally is the time.now()
    /// @param _maxSlippage The maximum tolerable slippage by user on cBridge side (The bridge is not 1-1 and may have slippage in big swaps)
    function send(
        address _receiver,
        address _token,
        uint256 _amount,
        uint64 _dstChainId,
        uint64 _nonce,
        uint32 _maxSlippage
    ) external;

}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

interface IRangoMessageReceiver {
    enum ProcessStatus { SUCCESS, REFUND_IN_SOURCE, REFUND_IN_DESTINATION }

    function handleRangoMessage(
        address _token,
        uint _amount,
        ProcessStatus _status,
        bytes memory _message
    ) external;
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import "./IStargateRouter.sol";
import "./Interchain.sol";

/// @title An interface to RangoStargate.sol contract to improve type hinting
/// @author Uchiha Sasuke
interface IRangoStargate {
    enum StargateBridgeType { TRANSFER, TRANSFER_WITH_MESSAGE }

    struct StargateRequest {
        StargateBridgeType _bridgeType;
        uint16 _dstChainId;
        uint256 _srcPoolId;
        uint256 _dstPoolId;
        address payable _refundAddress;
        uint256 _minAmountLD;

        uint256 _dstGasForCall;
        uint256 _dstNativeAmount;
        bytes _dstNativeAddr;

        bytes _to;
        uint _stgFee;
        
        Interchain.RangoInterChainMessage _payload;
    }

    /// @notice Executes a Stargate call
    /// @param _fromToken The address of source token to bridge
    /// @param _inputAmount The amount of input to be bridged
    /// @param _stargateRequest Required bridge params + interchain message that contains all the required info for the RangoStargate.sol on the destination
    function stargateSwap(
        address _fromToken,
        uint _inputAmount,
        StargateRequest memory _stargateRequest
    ) external payable;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

interface IStargateReceiver {
    function sgReceive(
        uint16 _chainId,
        bytes memory _srcAddress,
        uint256 _nonce,
        address _token,
        uint256 amountLD,
        bytes memory payload
    ) external;
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.13;

interface IStargateRouter {
    struct lzTxObj {
        uint256 dstGasForCall;
        uint256 dstNativeAmount;
        bytes dstNativeAddr;
    }

    function swap(
        uint16 _dstChainId,
        uint256 _srcPoolId,
        uint256 _dstPoolId,
        address payable _refundAddress,
        uint256 _amountLD,
        uint256 _minAmountLD,
        lzTxObj memory _lzTxParams,
        bytes calldata _to,
        bytes calldata _payload
    ) external payable;

    function swapETH(
        uint16 _dstChainId,
        address payable _refundAddress,
        bytes calldata _toAddress,
        uint256 _amountLD,
        uint256 _minAmountLD
    ) external payable;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

/// @dev based on thorchain router https://gitlab.com/thorchain/ethereum/eth-router/-/blob/29b59c2d6c6fc7a65d6bbc0f80d90694ac4122f8/contracts/THORChain_Aggregator.sol#L12
interface IThorchainRouter {
    /// @param vault The vault address of Thorchain. This cannot be hardcoded because Thorchain rotates vaults.
    /// @param asset The token contract address (if token is native, should be 0x0000000000000000000000000000000000000000)
    /// @param amount The amount of token to be swapped. It should be positive and if token is native, msg.value should be bigger than amount.
    /// @param memo The transaction memo used by Thorchain which contains the thorchain swap data. More info: https://dev.thorchain.org/thorchain-dev/memos
    /// @param expiration The expiration block number. If the tx is included after this block, it will be reverted.
    function depositWithExpiry(
        address payable vault,
        address asset,
        uint amount,
        string calldata memo,
        uint expiration
    ) external payable;
}

// SPDX-License-Identifier: GPL-3.0-only

pragma solidity 0.8.13;

/// @dev based on swap router of uniswap v2 https://docs.uniswap.org/protocol/V2/reference/smart-contracts/router-02#swapexactethfortokens
interface IUniswapV2 {
    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}

// SPDX-License-Identifier: GPL-3.0-only

pragma solidity 0.8.13;
/// @dev based on IswapRouter of UniswapV3 https://docs.uniswap.org/protocol/reference/periphery/interfaces/ISwapRouter
interface IUniswapV3 {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);
}

// SPDX-License-Identifier: GPL-3.0-only

pragma solidity 0.8.13;

interface IWETH {
    function deposit() external payable;

    function withdraw(uint256) external;
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

/// @title An interface to interchain message types
/// @author Uchiha Sasuke
interface Interchain {
    enum ActionType { NO_ACTION, UNI_V2, UNI_V3, CALL }
    enum CallSubActionType { WRAP, UNWRAP, NO_ACTION }

    struct RangoInterChainMessage {
        uint64 dstChainId;
        address bridgeRealOutput;
        address toToken;
        address originalSender;
        address recipient;
        ActionType actionType;
        bytes action;
        CallSubActionType postAction;

        // Extra message
        bytes dAppMessage;
        address dAppSourceContract;
        address dAppDestContract;
    }

    struct UniswapV2Action {
        address dexAddress;
        uint amountOutMin;
        address[] path;
        uint deadline;
    }

    struct UniswapV3ActionExactInputSingleParams {
        address dexAddress;
        address tokenIn;
        address tokenOut;
        uint24 fee;
        uint256 deadline;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice The requested call data which is computed off-chain and passed to the contract
    /// @param target The dex contract address that should be called
    /// @param callData The required data field that should be give to the dex contract to perform swap
    struct CallAction { 
        address tokenIn;
        address spender; 
        CallSubActionType preAction;
        address payable target;
        bytes callData;
    }
}