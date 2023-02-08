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
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
import "../extensions/draft-IERC20PermitUpgradeable.sol";
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
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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
abstract contract ReentrancyGuard {
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

    constructor() {
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)

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
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
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
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

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
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
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
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

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
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)

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
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
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

pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./lib/SafeMath.sol";
import "./interfaces/IStrategy.sol";

/**
 * @dev Implementation of a vault to deposit funds for yield optimizing.
 * This is the contract that receives funds and that users interface with.
 * The yield optimizing strategy itself is implemented in a separate 'Strategy.sol' contract.
 */
contract ChampionOptimizerVaultV1 is ERC20, Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    IERC20 public want;

    // The strategy currently in use by the vault.
    IStrategy public immutable strategy;

    event Earn(uint256 amount);
    event Deposit(address from, uint256 shares, uint256 amount);
    event Withdraw(address to, uint256 shares, uint256 amount);
    event RescuesTokenStuck(address token, uint256 amount);

    /**
     * @dev Sets the value of {token} to the token that the vault will
     * hold as underlying value. It initializes the vault's own 'moo' token.
     * This token is minted when someone does a deposit. It is burned in order
     * to withdraw the corresponding portion of the underlying assets.
     * @param _strategy the address of the strategy.
     * @param _name the name of the vault token.
     * @param _symbol the symbol of the vault token.
     */
    constructor(
        IStrategy _strategy,
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol) {
        strategy = _strategy;
        want = IERC20(_strategy.want());
    }

    /**
     * @dev It calculates the total underlying value of {token} held by the system.
     * It takes into account the vault contract balance, the strategy contract balance
     *  and the balance deployed in other contracts as part of the strategy.
     */
    function balance() public view returns (uint) {
        return want.balanceOf(address(this)).add(strategy.balanceOf());
    }

    /**
     * @dev Custom logic in here for how much the vault allows to be borrowed.
     * We return 100% of tokens for now. Under certain conditions we might
     * want to keep some of the system funds at hand in the vault, instead
     * of putting them to work.
     */
    function available() public view returns (uint256) {
        return want.balanceOf(address(this));
    }

    /**
     * @dev Function for various UIs to display the current value of one of our yield tokens.
     * Returns an uint256 with 18 decimals of how much underlying asset one vault share represents.
     */
    function getPricePerFullShare() public view returns (uint256) {
        return
            totalSupply() == 0 ? 1e18 : balance().mul(1e18).div(totalSupply());
    }

    /**
     * @dev A helper function to call deposit() with all the sender's funds.
     */
    function depositAll() external {
        deposit(want.balanceOf(msg.sender));
    }

    /**
     * @dev The entrypoint of funds into the system. People deposit with this function
     * into the vault. The vault is then in charge of sending funds into the strategy.
     */
    function deposit(uint _amount) public nonReentrant {
        if (msg.sender == tx.origin) {
            strategy.beforeDeposit();
        }
        uint256 _pool = balance();
        want.safeTransferFrom(msg.sender, address(this), _amount);
        earn();
        uint256 _after = balance();
        _amount = _after.sub(_pool); // Additional check for deflationary tokens
        uint256 shares = 0;
        if (totalSupply() == 0) {
            shares = _amount;
        } else {
            shares = (_amount.mul(totalSupply())).div(_pool);
        }
        _mint(msg.sender, shares);
        emit Deposit(msg.sender, shares, _amount);
    }

    /**
     * @dev Function to send funds into the strategy and put them to work. It's primarily called
     * by the vault's deposit() function.
     */
    function earn() public {
        uint _bal = available();
        want.safeTransfer(address(strategy), _bal);
        strategy.deposit();
        emit Earn(_bal);
    }

    /**
     * @dev A helper function to call withdraw() with all the sender's funds.
     */
    function withdrawAll() external {
        withdraw(balanceOf(msg.sender));
    }

    /**
     * @dev Function to exit the system. The vault will withdraw the required tokens
     * from the strategy and pay up the token holder. A proportional number of IOU
     * tokens are burned in the process.
     */
    function withdraw(uint256 _shares) public {
        uint256 r = (balance().mul(_shares)).div(totalSupply());
        _burn(msg.sender, _shares);

        uint b = want.balanceOf(address(this));
        if (b < r) {
            uint _withdraw = r.sub(b);
            strategy.withdraw(_withdraw);
            uint _after = want.balanceOf(address(this));
            uint _diff = _after.sub(b);
            if (_diff < _withdraw) {
                r = b.add(_diff);
            }
        }
        want.safeTransfer(msg.sender, r);
        emit Withdraw(msg.sender, _shares, r);
    }

    /**
     * @dev Rescues random funds stuck that the strat can't handle.
     * @param _token address of the token to rescue.
     */
    function inCaseTokensGetStuck(address _token) external onlyOwner {
        require(_token != address(want), "CoVault: STUCK_TOKEN_ONLY");
        uint256 amount = IERC20(_token).balanceOf(address(this));
        IERC20(_token).safeTransfer(msg.sender, amount);
        emit RescuesTokenStuck(_token, amount);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

interface IBribe {
    function _deposit(uint amount, uint tokenId) external;

    function _withdraw(uint amount, uint tokenId) external;

    function getRewardForOwner(uint tokenId, address[] memory tokens) external;

    function notifyRewardAmount(address token, uint amount) external;

    function left(address token) external view returns (uint);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

interface IFarming {
    function deposit(uint256 _pid, uint256 _amount) external;

    function withdraw(uint256 _pid, uint256 _amount) external;

    function userInfo(uint256 _pid, address _user) external view returns (uint256, uint256);

    function emergencyWithdraw(uint256 _pid) external;

    function shareToken() external view returns (address);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

interface IFeeConfig {
    struct FeeCategory {
        uint256 total;
        uint256 peanut;
        uint256 call;
        uint256 strategist;
        string label;
        bool active;
    }
    function getFees(address strategy) external view returns (FeeCategory memory);
    function stratFeeId(address strategy) external view returns (uint256);
    function setStratFeeId(uint256 feeId) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

interface IGasPrice {
    function maxGasPrice() external returns (uint);
    function enabled() external returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

interface IMinter {
    function _rewards_distributor() external view returns (address);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.9.0;

interface IPairFactory {
    function allPairsLength() external view returns (uint);
    function isPair(address pair) external view returns (bool);
    function pairCodeHash() external pure returns (bytes32);
    function getPair(address tokenA, address token, bool stable) external view returns (address);
    function createPair(address tokenA, address tokenB, bool stable) external returns (address pair);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

interface IRewardPool {
    function notifyRewardAmount() external;

    function stake(uint256 amount) external;

    function withdraw(uint256 amount) external;

    function getReward() external;

    function balanceOf(address account) external view returns (uint256);

    function earned(address account) external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

interface IRouteOracle {
    function resolveSwapExactTokensForTokens(
        uint256 amountIn,
        address tokenFrom,
        address tokenTo,
        address recipient
    ) external view returns ( address router, address nextToken, bytes memory sig);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

interface ISolidlyFactory {
    function allPairsLength() external view returns (uint);
    function isPair(address pair) external view returns (bool);
    function allPairs(uint index) external view returns (address);
    function pairCodeHash() external pure returns (bytes32);
    function getPair(address tokenA, address token, bool stable) external view returns (address);
    function createPair(address tokenA, address tokenB, bool stable) external returns (address pair);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

interface ISolidlyGauge {
    function getReward(uint256 tokenId, address[] memory rewards) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

interface ISolidlyRouter {
    // Routes
    struct Routes {
        address from;
        address to;
        bool stable;
    }

    function addLiquidity(
        address tokenA,
        address tokenB,
        bool stable,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        bool stable, 
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        bool stable, 
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token,
        bool stable,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokensSimple(
        uint amountIn, 
        uint amountOutMin, 
        address tokenFrom, 
        address tokenTo,
        bool stable, 
        address to, 
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactTokensForTokens(
        uint amountIn, 
        uint amountOutMin, 
        Routes[] memory route, 
        address to, 
        uint deadline
    ) external returns (uint[] memory amounts);

    function getAmountOut(uint amountIn, address tokenIn, address tokenOut) external view returns (uint amount, bool stable);

    function getAmountsOut(uint amountIn, Routes[] memory routes) external view returns (uint[] memory amounts);

    function quoteAddLiquidity(
        address tokenA,
        address tokenB,
        bool stable,
        uint amountADesired,
        uint amountBDesired
    ) external view returns (uint amountA, uint amountB, uint liquidity);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

interface IStrategy {
    function vault() external view returns (address);
    function want() external view returns (address);
    function beforeDeposit() external;
    function deposit() external;
    function withdraw(uint256) external;
    function balanceOf() external view returns (uint256);
    function balanceOfWant() external view returns (uint256);
    function balanceOfPool() external view returns (uint256);
    function harvest() external;
    function retireStrat() external;
    function panic() external;
    function pause() external;
    function unpause() external;
    function paused() external view returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

interface IThenaGauge {
    function balanceOf(address account) external view returns (uint);
    function claimFees() external returns (uint claimed0, uint claimed1);
    function deposit(uint amount) external;
    function depositAll(uint amount) external;
    function earned(address account) external view returns (uint);
    function getReward() external;
    function withdraw(uint amount) external;
    function withdrawAll() external;
    function withdrawAllAndHarvest(uint amount) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

interface IUniswapV2Callee {
    function uniswapV2Call(
        address sender,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

interface IUniswapV2ERC20 {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function createPair(address tokenA, address tokenB) external returns (address pair);
    
    function pairCodeHash() external pure returns (bytes32);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(address indexed sender, uint256 amount0In, uint256 amount1In, uint256 amount0Out, uint256 amount1Out, address indexed to);
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to) external returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

interface IUniswapV2Router {
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

    function addLiquidityAVAX(
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

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline) external payable
    returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

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

pragma solidity 0.8.13;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

interface IVault is IERC20 {
    function earn(address _bountyHunter) external returns (uint256);

    function deposit(address _user, uint256 _depositAmount) external;

    function withdraw(address _user, uint256 _withdrawAmount) external;

    function stakeToken() external view returns (address);

    function totalStakeTokens() external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

interface IVeDist {
    function claim(uint256 tokenId) external returns (uint);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

interface IVeToken {
    function create_lock(uint256 _value, uint256 _lockDuration) external returns (uint256 _tokenId);
    function increase_amount(uint256 tokenId, uint256 value) external;
    function increase_unlock_time(uint256 tokenId, uint256 duration) external;
    function withdraw(uint256 tokenId) external;
    function balanceOfNFT(uint256 tokenId) external view returns (uint256 balance);
    function locked(uint256 tokenId) external view returns (uint256 amount, uint256 endTime);
    function token() external view returns (address);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

interface IVoter {
    function vote(uint256 tokenId, address[] calldata poolVote, uint256[] calldata weights) external;
    function whitelist(address token, uint256 tokenId) external;
    function reset(uint256 tokenId) external;
    function gauges(address lp) external view returns (address);
    function _ve() external view returns (address);
    function minter() external view returns (address);
    function external_bribes(address _lp) external view returns (address);
    function internal_bribes(address _lp) external view returns (address);
    function votes(uint256 id, address lp) external view returns (uint256);
    function poolVote(uint256 id, uint256 index) external view returns (address);
    function lastVoted(uint256 id) external view returns (uint256);
    function weights(address lp) external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

interface IWETH is IERC20 {
    function deposit() external payable;

    function withdraw(uint256 wad) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

interface IWrappedBribeFactory {
    function oldBribeToNew(address _gauge) external view returns (address);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

library Babylonian {
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
        // else z = 0
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BConst {
  // uint256 internal constant WEIGHT_UPDATE_DELAY = 1 hours;
  // uint256 internal constant WEIGHT_CHANGE_PCT = BONE / 100;
  // uint256 internal constant BONE = 10**18;
  // uint256 internal constant MIN_BOUND_TOKENS = 2;
  // uint256 internal constant MAX_BOUND_TOKENS = 25;
  // uint256 internal constant EXIT_FEE = 1e16;
  // uint256 internal constant MIN_WEIGHT = BONE / 8;
  // uint256 internal constant MAX_WEIGHT = BONE * 25;
  // uint256 internal constant MAX_TOTAL_WEIGHT = BONE * 26;
  // uint256 internal constant MIN_BALANCE = BONE / 10**12;
  // uint256 internal constant INIT_POOL_SUPPLY = BONE * 10;
  // uint256 internal constant MIN_BPOW_BASE = 1 wei;
  // uint256 internal constant MAX_BPOW_BASE = (2 * BONE) - 1 wei;
  // uint256 internal constant BPOW_PRECISION = BONE / 10**10;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./BConst.sol";

contract BNum {
  uint256 internal constant BONE = 10**18;
  uint256 internal constant MIN_BPOW_BASE = 1 wei;
  uint256 internal constant MAX_BPOW_BASE = (2 * BONE) - 1 wei;
  uint256 internal constant BPOW_PRECISION = BONE / 10**10;

  function btoi(uint256 a) internal pure returns (uint256) {
    return a / BONE;
  }

  function bfloor(uint256 a) internal pure returns (uint256) {
    return btoi(a) * BONE;
  }

  function badd(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "DexETF: Add overflow");
    return c;
  }

  function bsub(uint256 a, uint256 b) internal pure returns (uint256) {
    (uint256 c, bool flag) = bsubSign(a, b);
    require(!flag, "DexETF: Sub overflow");
    return c;
  }

  function bsubSign(uint256 a, uint256 b)
    internal
    pure
    returns (uint256, bool)
  {
    if (a >= b) {
      return (a - b, false);
    } else {
      return (b - a, true);
    }
  }

  function bmul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c0 = a * b;
    require(a == 0 || c0 / a == b, "DexETF: Mul overflow");
    uint256 c1 = c0 + (BONE / 2);
    require(c1 >= c0, "DexETF: Mul overflow");
    uint256 c2 = c1 / BONE;
    return c2;
  }

  function bdiv(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0, "DexETF: Div zero");
    uint256 c0 = a * BONE;
    require(a == 0 || c0 / a == BONE, "DexETF: Div overflow");
    uint256 c1 = c0 + (b / 2);
    require(c1 >= c0, "DexETF: Div overflow");
    uint256 c2 = c1 / b;
    return c2;
  }

  function bpowi(uint256 a, uint256 n) internal pure returns (uint256) {
    uint256 z = n % 2 != 0 ? a : BONE;
    for (n /= 2; n != 0; n /= 2) {
      a = bmul(a, a);
      if (n % 2 != 0) {
        z = bmul(z, a);
      }
    }
    return z;
  }

  function bpow(uint256 base, uint256 exp) internal pure returns (uint256) {
    require(base >= MIN_BPOW_BASE, "DexETF: Bpow base too low");
    require(base <= MAX_BPOW_BASE, "DexETF: Bpow base too high");
    uint256 whole = bfloor(exp);
    uint256 remain = bsub(exp, whole);
    uint256 wholePow = bpowi(base, btoi(whole));
    if (remain == 0) {
      return wholePow;
    }
    uint256 partialResult = bpowApprox(base, remain, BPOW_PRECISION);
    return bmul(wholePow, partialResult);
  }

  function bpowApprox(
    uint256 base,
    uint256 exp,
    uint256 precision
  ) internal pure returns (uint256) {
    uint256 a = exp;
    (uint256 x, bool xneg) = bsubSign(base, BONE);
    uint256 term = BONE;
    uint256 sum = term;
    bool negative = false;
    for (uint256 i = 1; term >= precision; i++) {
      uint256 bigK = i * BONE;
      (uint256 c, bool cneg) = bsubSign(a, bsub(bigK, BONE));
      term = bmul(term, bmul(c, x));
      term = bdiv(term, bigK);
      if (term == 0) break;
      if (xneg) negative = !negative;
      if (cneg) negative = !negative;
      if (negative) {
        sum = bsub(sum, term);
      } else {
        sum = badd(sum, term);
      }
    }
    return sum;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./BNum.sol";

contract BTokenBase is BNum {
  mapping(address => uint256) internal _balance;
  mapping(address => mapping(address => uint256)) internal _allowance;
  uint256 internal _totalSupply;

  function _onTransfer(address from, address to, uint256 amount) internal virtual {}

  function _mint(uint256 amt) internal {
    address this_ = address(this);
    _balance[this_] = badd(_balance[this_], amt);
    _totalSupply = badd(_totalSupply, amt);
    _onTransfer(address(0), this_, amt);
  }

  function _burn(uint256 amt) internal {
    address this_ = address(this);
    require(_balance[this_] >= amt, "DexETF: insufficient balance");
    _balance[this_] = bsub(_balance[this_], amt);
    _totalSupply = bsub(_totalSupply, amt);
    _onTransfer(this_, address(0), amt);
  }

  function _move(address src, address dst, uint256 amt) internal {
    require(_balance[src] >= amt, "DexETF: insufficient balance");
    _balance[src] = bsub(_balance[src], amt);
    _balance[dst] = badd(_balance[dst], amt);
    _onTransfer(src, dst, amt);
  }

  function _push(address to, uint256 amt) internal {
    _move(address(this), to, amt);
  }

  function _pull(address from, uint256 amt) internal {
    _move(from, address(this), amt);
  }
}


contract BToken is BTokenBase, IERC20 {
  uint8 private constant DECIMALS = 18;
  string private _name;
  string private _symbol;

  function _initializeToken(string memory name_, string memory symbol_) internal {
    require(
      bytes(_name).length == 0 &&
      bytes(name_).length != 0 &&
      bytes(symbol_).length != 0,
      "DexETF: BToken already initialized"
    );
    _name = name_;
    _symbol = symbol_;
  }

  function name() external view returns (string memory) {
    return _name;
  }

  function symbol() external view returns (string memory) {
    return _symbol;
  }

  function decimals() external pure returns (uint8) {
    return DECIMALS;
  }

  function allowance(address owner, address spender) external override(IERC20) view returns (uint256) {
    return _allowance[owner][spender];
  }

  function balanceOf(address account) external override(IERC20) view returns (uint256) {
    return _balance[account];
  }

  function totalSupply() public override(IERC20) view returns (uint256) {
    return _totalSupply;
  }

  function approve(address spender, uint256 amount) external override(IERC20) returns (bool) {
    address caller = msg.sender;
    _allowance[caller][spender] = amount;
    emit Approval(caller, spender, amount);
    return true;
  }

  function increaseApproval(address dst, uint256 amt) external returns (bool) {
    address caller = msg.sender;
    _allowance[caller][dst] = badd(_allowance[caller][dst], amt);
    emit Approval(caller, dst, _allowance[caller][dst]);
    return true;
  }

  function decreaseApproval(address dst, uint256 amt) external returns (bool) {
    address caller = msg.sender;
    uint256 oldValue = _allowance[caller][dst];
    if (amt > oldValue) {
      _allowance[caller][dst] = 0;
    } else {
      _allowance[caller][dst] = bsub(oldValue, amt);
    }
    emit Approval(caller, dst, _allowance[caller][dst]);
    return true;
  }

  function transfer(address recipient, uint256 amount) external override(IERC20) returns (bool) {
    _move(msg.sender, recipient, amount);
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 amount) external override(IERC20) returns (bool) {
    address caller = msg.sender;
    require(caller == sender || amount <= _allowance[sender][caller], "DexETF: BToken bad caller");
    _move(sender, recipient, amount);
    if (caller != sender && _allowance[sender][caller] != type(uint256).max) {
      _allowance[sender][caller] = bsub(_allowance[sender][caller], amount);
      emit Approval(caller, recipient, _allowance[sender][caller]);
    }
    return true;
  }

  function _onTransfer(address from, address to, uint256 amount) internal override {
    emit Transfer(from, to, amount);
  }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "./Babylonian.sol";

// a library for handling binary fixed point numbers (https://en.wikipedia.org/wiki/Q_(number_format))
library FixedPoint {
    // range: [0, 2**112 - 1]
    // resolution: 1 / 2**112
    struct uq112x112 {
        uint224 _x;
    }

    // range: [0, 2**144 - 1]
    // resolution: 1 / 2**112
    struct uq144x112 {
        uint256 _x;
    }

    uint8 private constant RESOLUTION = 112;
    uint256 private constant Q112 = uint256(1) << RESOLUTION;
    uint256 private constant Q224 = Q112 << RESOLUTION;

    // encode a uint112 as a UQ112x112
    function encode(uint112 x) internal pure returns (uq112x112 memory) {
        return uq112x112(uint224(x) << RESOLUTION);
    }

    // encodes a uint144 as a UQ144x112
    function encode144(uint144 x) internal pure returns (uq144x112 memory) {
        return uq144x112(uint256(x) << RESOLUTION);
    }

    // divide a UQ112x112 by a uint112, returning a UQ112x112
    function div(uq112x112 memory self, uint112 x) internal pure returns (uq112x112 memory) {
        require(x != 0, "FixedPoint: DIV_BY_ZERO");
        return uq112x112(self._x / uint224(x));
    }

    // multiply a UQ112x112 by a uint, returning a UQ144x112
    // reverts on overflow
    function mul(uq112x112 memory self, uint256 y) internal pure returns (uq144x112 memory) {
        uint256 z;
        require(y == 0 || (z = uint256(self._x) * y) / y == uint256(self._x), "FixedPoint: MULTIPLICATION_OVERFLOW");
        return uq144x112(z);
    }

    // returns a UQ112x112 which represents the ratio of the numerator to the denominator
    // equivalent to encode(numerator).div(denominator)
    function fraction(uint112 numerator, uint112 denominator) internal pure returns (uq112x112 memory) {
        require(denominator > 0, "FixedPoint: DIV_BY_ZERO");
        return uq112x112((uint224(numerator) << RESOLUTION) / denominator);
    }

    // decode a UQ112x112 into a uint112 by truncating after the radix point
    function decode(uq112x112 memory self) internal pure returns (uint112) {
        return uint112(self._x >> RESOLUTION);
    }

    // decode a UQ144x112 into a uint144 by truncating after the radix point
    function decode144(uq144x112 memory self) internal pure returns (uint144) {
        return uint144(self._x >> RESOLUTION);
    }

    // take the reciprocal of a UQ112x112
    function reciprocal(uq112x112 memory self) internal pure returns (uq112x112 memory) {
        require(self._x != 0, "FixedPoint: ZERO_RECIPROCAL");
        return uq112x112(uint224(Q224 / self._x));
    }

    // square root of a UQ112x112
    function sqrt(uq112x112 memory self) internal pure returns (uq112x112 memory) {
        return uq112x112(uint224(Babylonian.sqrt(uint256(self._x)) << 56));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
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
        return a / b + (a % b == 0 ? 0 : 1);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

library Safe112 {
    function add(uint112 a, uint112 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "Safe112: addition overflow");

        return c;
    }

    function sub(uint112 a, uint112 b) internal pure returns (uint256) {
        return sub(a, b, "Safe112: subtraction overflow");
    }

    function sub(
        uint112 a,
        uint112 b,
        string memory errorMessage
    ) internal pure returns (uint112) {
        require(b <= a, errorMessage);
        uint112 c = a - b;

        return c;
    }

    function mul(uint112 a, uint112 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "Safe112: multiplication overflow");

        return c;
    }

    function div(uint112 a, uint112 b) internal pure returns (uint256) {
        return div(a, b, "Safe112: division by zero");
    }

    function div(
        uint112 a,
        uint112 b,
        string memory errorMessage
    ) internal pure returns (uint112) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint112 c = a / b;

        return c;
    }

    function mod(uint112 a, uint112 b) internal pure returns (uint256) {
        return mod(a, b, "Safe112: modulo by zero");
    }

    function mod(
        uint112 a,
        uint112 b,
        string memory errorMessage
    ) internal pure returns (uint112) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity 0.8.13;

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

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

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
library SafeMath8 {
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
    function add(uint8 a, uint8 b) internal pure returns (uint8) {
        uint8 c = a + b;
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
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint8 a, uint8 b) internal pure returns (uint8) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint8 a, uint8 b, string memory errorMessage) internal pure returns (uint8) {
        require(b <= a, errorMessage);
        uint8 c = a - b;

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
    function mul(uint8 a, uint8 b) internal pure returns (uint8) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint8 c = a * b;
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
    function div(uint8 a, uint8 b) internal pure returns (uint8) {
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
    function div(uint8 a, uint8 b, string memory errorMessage) internal pure returns (uint8) {
        require(b > 0, errorMessage);
        uint8 c = a / b;
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
     *
     * - The divisor cannot be zero.
     */
    function mod(uint8 a, uint8 b) internal pure returns (uint8) {
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
     *
     * - The divisor cannot be zero.
     */
    function mod(uint8 a, uint8 b, string memory errorMessage) internal pure returns (uint8) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../interfaces/IUniswapV2Pair.sol";
import "../interfaces/IUniswapV2Factory.sol";

library UniswapV2Library {
    using SafeMath for uint256;
    function calculatePair(
        address factory,
        address token0,
        address token1
    ) internal view returns (address pair) {
        IUniswapV2Factory _factory = IUniswapV2Factory(factory);
        pair = _factory.getPair(token0, token1);
    }

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, "UniswapV2Library: IDENTICAL_ADDRESSES");
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), "UniswapV2Library: ZERO_ADDRESS");
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(
        address factory,
        address tokenA,
        address tokenB
    ) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        uint256 temp = uint256(
                keccak256(
                    abi.encodePacked(
                        hex"ff",
                        factory,
                        keccak256(abi.encodePacked(token0, token1)),
                        hex"96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f" // init code hash
                    )
                )
            );
        pair = address(uint160(temp));
    }

    // fetches and sorts the reserves for a pair
    function getReserves(
        address factory,
        address tokenA,
        address tokenB
    ) internal view returns (uint256 reserveA, uint256 reserveB) {
        (address token0, ) = sortTokens(tokenA, tokenB);
        (uint256 reserve0, uint256 reserve1, ) = IUniswapV2Pair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) internal pure returns (uint256 amountB) {
        require(amountA > 0, "UniswapV2Library: INSUFFICIENT_AMOUNT");
        require(reserveA > 0 && reserveB > 0, "UniswapV2Library: INSUFFICIENT_LIQUIDITY");
        amountB = amountA.mul(reserveB) / reserveA;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256 amountOut) {
        require(amountIn > 0, "UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT");
        require(reserveIn > 0 && reserveOut > 0, "UniswapV2Library: INSUFFICIENT_LIQUIDITY");
        uint256 amountInWithFee = amountIn.mul(997);
        uint256 numerator = amountInWithFee.mul(reserveOut);
        uint256 denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256 amountIn) {
        require(amountOut > 0, "UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT");
        require(reserveIn > 0 && reserveOut > 0, "UniswapV2Library: INSUFFICIENT_LIQUIDITY");
        uint256 numerator = reserveIn.mul(amountOut).mul(1000);
        uint256 denominator = reserveOut.sub(amountOut).mul(997);
        amountIn = (numerator / denominator).add(1);
    }

    // performs chained getAmountOut calculations on any number of pairs
    function getAmountsOut(
        address factory,
        uint256 amountIn,
        address[] memory path
    ) internal view returns (uint256[] memory amounts) {
        require(path.length >= 2, "UniswapV2Library: INVALID_PATH");
        amounts = new uint256[](path.length);
        amounts[0] = amountIn;
        for (uint256 i; i < path.length - 1; i++) {
            (uint256 reserveIn, uint256 reserveOut) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    // performs chained getAmountIn calculations on any number of pairs
    function getAmountsIn(
        address factory,
        uint256 amountOut,
        address[] memory path
    ) internal view returns (uint256[] memory amounts) {
        require(path.length >= 2, "UniswapV2Library: INVALID_PATH");
        amounts = new uint256[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint256 i = path.length - 1; i > 0; i--) {
            (uint256 reserveIn, uint256 reserveOut) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "./FixedPoint.sol";
import "../interfaces/IUniswapV2Pair.sol";

// library with helper methods for oracles that are concerned with computing average prices
library UniswapV2OracleLibrary {
    using FixedPoint for *;

    // helper function that returns the current block timestamp within the range of uint32, i.e. [0, 2**32 - 1]
    function currentBlockTimestamp() internal view returns (uint32) {
        return uint32(block.timestamp % 2**32);
    }

    // produces the cumulative price using counterfactuals to save gas and avoid a call to sync.
    function currentCumulativePrices(address pair)
        internal
        view
        returns (
            uint256 price0Cumulative,
            uint256 price1Cumulative,
            uint32 blockTimestamp
        )
    {
        blockTimestamp = currentBlockTimestamp();
        price0Cumulative = IUniswapV2Pair(pair).price0CumulativeLast();
        price1Cumulative = IUniswapV2Pair(pair).price1CumulativeLast();

        // if time has elapsed since the last update on the pair, mock the accumulated price values
        (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast) = IUniswapV2Pair(pair).getReserves();
        if (blockTimestampLast != blockTimestamp) {
            // subtraction overflow is desired
            uint32 timeElapsed = blockTimestamp - blockTimestampLast;
            // addition overflow is desired
            // counterfactual
            price0Cumulative += uint256(FixedPoint.fraction(reserve1, reserve0)._x) * timeElapsed;
            // counterfactual
            price1Cumulative += uint256(FixedPoint.fraction(reserve0, reserve1)._x) * timeElapsed;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity =0.8.13;

// a library for handling binary fixed point numbers (https://en.wikipedia.org/wiki/Q_(number_format))

// range: [0, 2**112 - 1]
// resolution: 1 / 2**112

library UQ112x112 {
    uint224 constant Q112 = 2**112;

    // encode a uint112 as a UQ112x112
    function encode(uint112 y) internal pure returns (uint224 z) {
        z = uint224(y) * Q112; // never overflows
    }

    // divide a UQ112x112 by a uint112, returning a UQ112x112
    function uqdiv(uint224 x, uint112 y) internal pure returns (uint224 z) {
        z = x / uint224(y);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Operator is Context, Ownable {
    address private _operator;

    event OperatorTransferred(address indexed previousOperator, address indexed newOperator);

    constructor() {
        _operator = _msgSender();
        emit OperatorTransferred(address(0), _operator);
    }

    function operator() public view returns (address) {
        return _operator;
    }

    modifier onlyOperator() {
        require(_operator == msg.sender, "operator: caller is not the operator");
        _;
    }

    function isOperator() public view returns (bool) {
        return _msgSender() == _operator;
    }

    function transferOperator(address newOperator_) public onlyOwner {
        _transferOperator(newOperator_);
    }

    function _transferOperator(address newOperator_) internal {
        require(newOperator_ != address(0), "operator: zero address given for new operator");
        emit OperatorTransferred(address(0), newOperator_);
        _operator = newOperator_;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract OperatorUpgradeable is ContextUpgradeable, OwnableUpgradeable {
    address private _operator;

    event OperatorTransferred(address indexed previousOperator, address indexed newOperator);
    
    function __Operator_init() internal onlyInitializing {
        __Operator_init_unchained();
    }

    function __Operator_init_unchained() internal onlyInitializing {
        __Context_init();
        __Ownable_init();
        _operator = _msgSender();
        emit OperatorTransferred(address(0), _operator);
    }

    function operator() public view returns (address) {
        return _operator;
    }

    modifier onlyOperator() {
        require(_operator == msg.sender, "operator: caller is not the operator");
        _;
    }

    function isOperator() public view returns (bool) {
        return _msgSender() == _operator;
    }

    function transferOperator(address newOperator_) public onlyOwner {
        _transferOperator(newOperator_);
    }

    function _transferOperator(address newOperator_) internal {
        require(newOperator_ != address(0), "operator: zero address given for new operator");
        emit OperatorTransferred(address(0), newOperator_);
        _operator = newOperator_;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "./lib/SafeMath.sol";
import "./owner/Operator.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract ShareTokenRewardPool is Operator {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // Info of each user.
    struct UserInfo {
        uint256 amount;
        uint256 lastRewardTime;
        uint256[18] rewardDebt;
    }

    // Info of each pool.
    struct PoolInfo {
        IERC20 token; // Address of LP token contract.
        uint256 allocPoint; // How many allocation points assigned to this pool. ShareToken to distribute per block.
        uint256 lastRewardTime; // Last time that ShareToken distribution occurs.
        uint256[18] accRewardTokenPerShare; // Accumulated ShareToken per share, times 1e18. See below.
        bool isStarted; // if lastRewardTime has passed
        uint256 depositFeePercent;
    }

    struct RewardInfo {
        uint256 rewardForDao;
        uint256 rewardForDev;
        uint256 rewardForUser;
        uint256 rewardPerSecondForDao;
        uint256 rewardPerSecondForDev;
        uint256 rewardPerSecondForUser;
        uint256 startTime;
    }

    IERC20 public immutable shareToken;

    // Info of each pool.
    PoolInfo[] public poolInfo;

    // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;

    uint256 public totalAllocPoint;

    uint256 public immutable poolStartTime;
    uint256 public immutable poolEndTime;

    uint256 public constant runningTimeMonth = 18; // 18 months

    RewardInfo[18] public rewardInfos;
    uint256 public lastDaoRewardTime;
    uint256 public lastDevRewardTime;
    address public immutable devWallet;
	address public immutable daoWallet;
    address public immutable polWallet;

    uint256 constant public MONTH = 30 * 24 * 60 * 60;
    uint256 constant public firstMonthReward = 3666 ether;
    uint256 public totalUserReward = 0;
    uint256 public totalDevReward = 0;
    uint256 constant public devPercent = 1000; // 10%
    uint256 public totalDaoReward = 0;
    uint256 constant public daoPercent = 1000; // 10%
    uint256 constant rewardDecreaseEachMonthPercent = 2000; // 20%

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event RewardPaid(address indexed user, uint256 amount);
    event SetDepositFeePercent(uint256 oldValue, uint256 newValue);

    constructor(
        address _token,
        address _daoWallet,
        address _devWallet,
        address _polWallet,
        uint256 _poolStartTime
    ) {
        require(block.timestamp < _poolStartTime, "late");
        require(_token != address(0), "!_token");
        require(_daoWallet != address(0), "!_daoWallet");
        require(_devWallet != address(0), "!_devWallet");
        require(_polWallet != address(0), "!_polWallet");

        shareToken = IERC20(_token);

        daoWallet = _daoWallet;
        devWallet = _devWallet; 
        polWallet = _polWallet;

        totalAllocPoint = 0;
        poolStartTime = _poolStartTime;

        lastDaoRewardTime = poolStartTime;
        lastDevRewardTime = poolStartTime;
        uint256 runningTime = runningTimeMonth * MONTH;
        poolEndTime = poolStartTime + runningTime;

        uint256 devRewardFirstMonth = firstMonthReward * devPercent / 10000;
        uint256 daoRewardFirstMonth = firstMonthReward * daoPercent / 10000;
        uint256 userRewardFirstMonth = firstMonthReward - devRewardFirstMonth - daoRewardFirstMonth;
        uint256 startTime = poolStartTime;
        for (uint256 i = 0; i < runningTimeMonth; ++i) {
            rewardInfos[i].rewardForDev = devRewardFirstMonth;
            rewardInfos[i].rewardForDao = daoRewardFirstMonth;
            rewardInfos[i].rewardForUser = userRewardFirstMonth;
            rewardInfos[i].startTime = startTime;

            rewardInfos[i].rewardPerSecondForDev = devRewardFirstMonth / MONTH;
            rewardInfos[i].rewardPerSecondForDao = daoRewardFirstMonth / MONTH;
            rewardInfos[i].rewardPerSecondForUser = userRewardFirstMonth / MONTH;

            devRewardFirstMonth = devRewardFirstMonth - (devRewardFirstMonth * rewardDecreaseEachMonthPercent / 10000);
            daoRewardFirstMonth = daoRewardFirstMonth - (daoRewardFirstMonth * rewardDecreaseEachMonthPercent / 10000);
            userRewardFirstMonth = userRewardFirstMonth - (userRewardFirstMonth * rewardDecreaseEachMonthPercent / 10000);
            startTime = startTime + MONTH;

            totalDevReward = totalDevReward + rewardInfos[i].rewardForDev;
            totalDaoReward = totalDaoReward + rewardInfos[i].rewardForDao;
            totalUserReward = totalUserReward + rewardInfos[i].rewardForUser;
        }
    }

    function checkPoolDuplicate(IERC20 _token) internal view {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            require(poolInfo[pid].token != _token, "ShareTokenRewardPool: existing pool?");
        }
    }

    // Add a new pool. Can only be called by the Operator.
    function add(
        uint256 _allocPoint,
        address _token,
        uint256 _depositFee,
        uint256 _lastRewardTime
    ) external onlyOperator {
        require(_token != address(0), "!_token");
        require(_depositFee <= 100, 'Max percent is 1%');
        checkPoolDuplicate(IERC20(_token));
        massUpdatePools();
        if (block.timestamp < poolStartTime) {
            // chef is sleeping
            if (_lastRewardTime == 0) {
                _lastRewardTime = poolStartTime;
            } else {
                if (_lastRewardTime < poolStartTime) {
                    _lastRewardTime = poolStartTime;
                }
            }
        } else {
            // chef is cooking
            if (_lastRewardTime == 0 || _lastRewardTime < block.timestamp) {
                _lastRewardTime = block.timestamp;
            }
        }
        bool _isStarted = (_lastRewardTime <= poolStartTime) || (_lastRewardTime <= block.timestamp);
        poolInfo.push(PoolInfo({
            token : IERC20(_token),
            allocPoint : _allocPoint,
            lastRewardTime : _lastRewardTime,
            accRewardTokenPerShare : [uint256(0), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            isStarted : _isStarted,
            depositFeePercent: _depositFee
            }));
        if (_isStarted) {
            totalAllocPoint = totalAllocPoint.add(_allocPoint);
        }
    }

    // Update the given pool's ShareToken allocation point. Can only be called by the Operator.
    function set(uint256 _pid, uint256 _allocPoint) external onlyOperator {
        massUpdatePools();
        PoolInfo storage pool = poolInfo[_pid];
        if (pool.isStarted) {
            totalAllocPoint = totalAllocPoint.sub(pool.allocPoint).add(
                _allocPoint
            );
        }
        pool.allocPoint = _allocPoint;
    }

    function setDepositFeePercent(uint256 _pid, uint256 _value) external onlyOperator {
        require(_value <= 100, 'Max percent is 1%');
        PoolInfo storage pool = poolInfo[_pid];
        emit SetDepositFeePercent(pool.depositFeePercent, _value);
        pool.depositFeePercent = _value;
    }

    // View function to see pending on frontend.
    function pending(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo memory pool = poolInfo[_pid];
        uint256 daoReward = pendingDao(_user, lastDaoRewardTime, block.timestamp);
        uint256 devReward = pendingDev(_user, lastDevRewardTime, block.timestamp);
        uint256 userReward = pendingUser(_pid, _user, pool.lastRewardTime, block.timestamp);
        return userReward.add(daoReward).add(devReward);
    }

    function pendingUser(uint256 _pid, address _user, uint256 _fromTime, uint256 _toTime) public view returns (uint256) {
        if (_fromTime > _toTime) return 0;
        if (_toTime >= poolEndTime) {
            if (_fromTime >= poolEndTime) return 0;
            if (_fromTime <= poolStartTime) _fromTime = poolStartTime;
            _toTime = poolEndTime;
        } else {
            if (_toTime <= poolStartTime) return 0;
            if (_fromTime <= poolStartTime) _fromTime = poolStartTime;
        }

        uint256 reward = getUserReward(_pid, _user, _fromTime, _toTime);
        return reward;
    }

    function pendingDao(address _user, uint256 _fromTime, uint256 _toTime) internal view returns (uint256) {
        if (isDao(_user)) {
            if (_fromTime >= _toTime) return 0;
            if (_toTime >= poolEndTime) {
                if (_fromTime >= poolEndTime) return 0;
                if (_fromTime <= poolStartTime) _fromTime = poolStartTime;
                _toTime = poolEndTime;
                uint256 reward = getDaoReward(_fromTime, _toTime);
                return reward;
            } else {
                if (_toTime <= poolStartTime) return 0;
                if (_fromTime <= poolStartTime) _fromTime = poolStartTime;

                uint256 reward = getDaoReward(_fromTime, _toTime);
                return reward;
            }
        }

        return 0;
    }

    function pendingDev(address _user, uint256 _fromTime, uint256 _toTime) internal view returns (uint256) {
        if (isDev(_user)) {
            if (_fromTime >= _toTime) return 0;
            if (_toTime >= poolEndTime) {
                if (_fromTime >= poolEndTime) return 0;
                if (_fromTime <= poolStartTime) _fromTime = poolStartTime;
                _toTime = poolEndTime;
                uint256 reward = getDevReward(_fromTime, _toTime);
                return reward;
            } else {
                if (_toTime <= poolStartTime) return 0;
                if (_fromTime <= poolStartTime) _fromTime = poolStartTime;

                uint256 reward = getDevReward(_fromTime, _toTime);
                return reward;
            }
        }

        return 0;
    }

    function getDaoReward(uint256 _fromTime, uint256 _toTime) internal view returns (uint256) {
        uint256 fromMonth = getMonthFrom(_fromTime);
        uint256 toMonth = getMonthFrom(_toTime);
        uint256 reward = 0;
        for (uint256 i = fromMonth; i <= toMonth; ++i) {
            uint256 timeFrom = _fromTime;
            uint256 timeTo = poolEndTime;
            if (i < runningTimeMonth - 1) {
                timeTo = rewardInfos[i + 1].startTime > _toTime ? _toTime : rewardInfos[i + 1].startTime;
            }
            reward = reward + timeTo.sub(timeFrom).mul(rewardInfos[i].rewardPerSecondForDao);
            _fromTime = timeTo;
        } 
        
        return reward;
    }

    function getDevReward(uint256 _fromTime, uint256 _toTime) internal view returns (uint256) {
        uint256 fromMonth = getMonthFrom(_fromTime);
        uint256 toMonth = getMonthFrom(_toTime);
        uint256 reward = 0;
        for (uint256 i = fromMonth; i <= toMonth; ++i) {
            uint256 timeFrom = _fromTime;
            uint256 timeTo = poolEndTime;
            if (i < runningTimeMonth - 1) {
                timeTo = rewardInfos[i + 1].startTime > _toTime ? _toTime : rewardInfos[i + 1].startTime;
            }
            reward = reward + timeTo.sub(timeFrom).mul(rewardInfos[i].rewardPerSecondForDev);
            _fromTime = timeTo;
        } 
        
        return reward;
    }

    function getUserReward(uint256 _pid, address _user, uint256 _fromTime, uint256 _toTime) internal view returns (uint256) {
        UserInfo memory user = userInfo[_pid][_user];
        PoolInfo memory pool = poolInfo[_pid];
        uint256 reward = 0;
        uint256 userAmount = user.amount;
        uint256 lastUserRewardMonth = getMonthFrom(user.lastRewardTime);
        uint256 fromMonth = getMonthFrom(_fromTime);
        uint256 toMonth = getMonthFrom(_toTime);
        if (fromMonth > lastUserRewardMonth) {
            for (uint256 i = lastUserRewardMonth; i < fromMonth; ++i) {
                reward = reward + userAmount.mul( pool.accRewardTokenPerShare[i]).div(1e18).sub(user.rewardDebt[i]);
            }
        }
        uint256 tokenSupply = pool.token.balanceOf(address(this));
        for (uint256 i = fromMonth; i <= toMonth; ++i) {
            uint256 timeFrom = _fromTime;
            uint256 timeTo = poolEndTime;
            if (i < runningTimeMonth - 1) {
                timeTo = rewardInfos[i + 1].startTime > _toTime ? _toTime : rewardInfos[i + 1].startTime;
            }
            uint256 accRewardTokenPerShare = pool.accRewardTokenPerShare[i];
            if (tokenSupply > 0) {
                uint256 _generatedReward = timeTo.sub(timeFrom).mul(rewardInfos[i].rewardPerSecondForUser);
                uint256 _shareTokenReward = _generatedReward.mul(pool.allocPoint).div(totalAllocPoint);
                accRewardTokenPerShare = accRewardTokenPerShare.add(_shareTokenReward.mul(1e18).div(tokenSupply));
            }
            reward = reward + userAmount.mul(accRewardTokenPerShare).div(1e18).sub(user.rewardDebt[i]);
            _fromTime = timeTo;
        } 
        return reward;
    }

    function getUserRewardToClaim(uint256 _pid, address _user, uint256 _fromTime, uint256 _toTime) internal view returns (uint256) {
        PoolInfo memory pool = poolInfo[_pid];
        UserInfo memory user = userInfo[_pid][_user];
        uint256 reward = 0;
        uint256 userAmount = user.amount;
        uint256 fromMonth = getMonthFrom(_fromTime);
        uint256 toMonth = getMonthFrom(_toTime);

        for (uint256 i = fromMonth; i <= toMonth; ++i) {
            uint256 accRewardTokenPerShare = pool.accRewardTokenPerShare[i];
            reward = reward + userAmount.mul(accRewardTokenPerShare).div(1e18).sub(user.rewardDebt[i]);
        } 
        
        return reward;
    }

    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() public onlyOperator {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) internal {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.timestamp <= pool.lastRewardTime) {
            return;
        }
        uint256 tokenSupply = pool.token.balanceOf(address(this));
        if (tokenSupply == 0) {
            pool.lastRewardTime = block.timestamp;
            return;
        }
        if (!pool.isStarted) {
            pool.isStarted = true;
            totalAllocPoint = totalAllocPoint.add(pool.allocPoint);
        }
        
        if (totalAllocPoint > 0) {
            uint256 _fromTime = pool.lastRewardTime > poolEndTime ? poolEndTime : pool.lastRewardTime;
            uint256 _toTime = block.timestamp;
            uint256 fromMonth = getMonthFrom(_fromTime);
            uint256 toMonth = getMonthFrom(_toTime);
            for (uint256 i = fromMonth; i <= toMonth; ++i) {
                uint256 timeFrom = _fromTime;
                uint256 timeTo = poolEndTime;
                if (i < runningTimeMonth - 1) {
                    timeTo = rewardInfos[i + 1].startTime > _toTime ? _toTime : rewardInfos[i + 1].startTime;
                }

                uint256 _generatedReward = timeTo.sub(timeFrom).mul(rewardInfos[i].rewardPerSecondForUser);
                uint256 _shareTokenReward = _generatedReward.mul(pool.allocPoint).div(totalAllocPoint);
                pool.accRewardTokenPerShare[i] = pool.accRewardTokenPerShare[i].add(_shareTokenReward.mul(1e18).div(tokenSupply));

                _fromTime = timeTo;
            }
        }

        pool.lastRewardTime = block.timestamp;
    }

    // Deposit tokens.
    function deposit(uint256 _pid, uint256 _amount) external {
        address _sender = msg.sender;
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_sender];
        uint256 lastRewardTime = pool.lastRewardTime;
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 _pending = getUserRewardToClaim(_pid, _sender, user.lastRewardTime, block.timestamp);
            if (_pending > 0) {
                safeShareTokenTransfer(_sender, _pending);
                emit RewardPaid(_sender, _pending);
            }
        }
        user.lastRewardTime = block.timestamp;
        if (_amount > 0) {
            if (pool.depositFeePercent > 0) {
                uint256 feeAmount = _amount.mul(pool.depositFeePercent).div(10000);
                pool.token.safeTransferFrom(_sender, polWallet, feeAmount);
                _amount = _amount.sub(feeAmount);
            }

            pool.token.safeTransferFrom(_sender, address(this), _amount);
            user.amount = user.amount.add(_amount);
        }

        uint256 fromMonth = getMonthFrom(lastRewardTime);
        uint256 toMonth = getMonth();
        for (uint256 i = fromMonth; i <= toMonth; ++i) {
            user.rewardDebt[i] = user.amount.mul(pool.accRewardTokenPerShare[i]).div(1e18);
        }
        emit Deposit(_sender, _pid, _amount);
    }

    // Withdraw tokens.
    function withdraw(uint256 _pid, uint256 _amount) external {
        address _sender = msg.sender;
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_sender];
        require(user.amount >= _amount, "withdraw: not good");
        uint256 lastRewardTime = pool.lastRewardTime;
        updatePool(_pid);
        uint256 _pending = getUserRewardToClaim(_pid, _sender, user.lastRewardTime, block.timestamp);
        user.lastRewardTime = block.timestamp;
        uint256 _daoReward = pendingDao(_sender, lastDaoRewardTime, block.timestamp);
        uint256 _devReward = pendingDev(_sender, lastDevRewardTime, block.timestamp);
        uint256 _reward = 0;

        if (_daoReward > 0) {
            _reward = _reward.add(_daoReward);
            lastDaoRewardTime = block.timestamp;
        }

        if (_devReward > 0) {
            _reward = _reward.add(_devReward);
            lastDevRewardTime = block.timestamp;
        }

        if (_pending > 0) {
            _reward = _reward.add(_pending);
        }

        if (_reward > 0) {
            safeShareTokenTransfer(_sender, _reward);
            emit RewardPaid(_sender, _pending);
        }

        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.token.safeTransfer(_sender, _amount);
        }

        uint256 fromMonth = getMonthFrom(lastRewardTime);
        uint256 toMonth = getMonth();
        for (uint256 i = fromMonth; i <= toMonth; ++i) {
            user.rewardDebt[i] = user.amount.mul(pool.accRewardTokenPerShare[i]).div(1e18);
        }

        emit Withdraw(_sender, _pid, _amount);
    }

    function emergencyWithdraw(uint256 _pid) external {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 _amount = user.amount;
        user.amount = 0;
        for (uint256 i = 0; i < 18; ++i) {
            user.rewardDebt[i] = 0;
        }
        pool.token.safeTransfer(msg.sender, _amount);
        emit EmergencyWithdraw(msg.sender, _pid, _amount);
    }

    // Safe ShareToken transfer function, just in case if rounding error causes pool to not have enough ShareToken.
    function safeShareTokenTransfer(address _to, uint256 _amount) internal {
        uint256 _shareTokenBalance = shareToken.balanceOf(address(this));
        if (_shareTokenBalance > 0) {
            if (_amount > _shareTokenBalance) {
                shareToken.safeTransfer(_to, _shareTokenBalance);
            } else {
                shareToken.safeTransfer(_to, _amount);
            }
        }
    }

    function isDev(address _address) public view returns (bool) {
		return _address == devWallet;
	}

	function isDao(address _address) public view returns (bool) {
		return _address == daoWallet;
	}

    function getMonth() public view returns (uint256) {
        if (block.timestamp < poolStartTime) return 0;
        uint256 month = (block.timestamp - poolStartTime) / MONTH;
        return month > runningTimeMonth - 1 ? runningTimeMonth - 1 : month;
    }

    function getMonthFrom(uint256 _time) public view returns (uint256) {
        if (_time < poolStartTime) return 0;
        uint256 month = (_time - poolStartTime) / MONTH;
        return month > runningTimeMonth - 1 ? runningTimeMonth - 1 : month;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../interfaces/IUniswapV2Router.sol";
import "../interfaces/IUniswapV2Factory.sol";

contract ChamToken is ERC20 {
    using SafeERC20 for IERC20;

    address public immutable underlying;
    bool public constant underlyingIsMinted = false;

    mapping(address => uint256) private _balances;
    uint256 private _totalSupply;

    // init flag for setting immediate vault, needed for CREATE2 support
    bool private _init;

    // flag to enable/disable swapout vs vault.burn so multiple events are triggered
    bool private _vaultOnly;

    // delay for timelock functions
    uint public constant DELAY = 2 days;

    // set of minters, can be this bridge or other bridges
    mapping(address => bool) public isMinter;
    address[] public minters;

    // primary controller of the token contract
    address public vault;

    address public pendingMinter;
    uint public delayMinter;

    address public pendingVault;
    uint public delayVault;

    // logic
    address public operator;
    address public polWallet;

    mapping (address => bool) public marketLpPairs; // LP Pairs
    mapping(address => bool) public excludedAccountSellingLimitTime;

    uint256 public taxSellingPercent = 0;
    mapping(address => bool) public excludedSellingTaxAddresses;

    uint256 public taxBuyingPercent = 0;
    mapping(address => bool) public excludedBuyingTaxAddresses;

    modifier onlyOperator() {
        require(operator == msg.sender, "operator: caller is not the operator");
        _;
    }

    modifier onlyAuth() {
        require(isMinter[msg.sender], "AnyswapV6ERC20: FORBIDDEN");
        _;
    }

    modifier onlyVault() {
        require(msg.sender == vault, "AnyswapV6ERC20: FORBIDDEN");
        _;
    }

    function owner() external view returns (address) {
        return vault;
    }

    function mpc() external view returns (address) {
        return vault;
    }

    function setVaultOnly(bool enabled) external onlyVault {
        _vaultOnly = enabled;
    }

    function initVault(address _vault) external onlyVault {
        require(_init);
        _init = false;
        vault = _vault;
        isMinter[_vault] = true;
        minters.push(_vault);
    }

    function setVault(address _vault) external onlyVault {
        require(_vault != address(0), "AnyswapV6ERC20: address(0)");
        pendingVault = _vault;
        delayVault = block.timestamp + DELAY;
    }

    function applyVault() external onlyVault {
        require(pendingVault != address(0) && block.timestamp >= delayVault);
        vault = pendingVault;

        pendingVault = address(0);
        delayVault = 0;
    }

    function setMinter(address _auth) external onlyVault {
        require(_auth != address(0), "AnyswapV6ERC20: address(0)");
        pendingMinter = _auth;
        delayMinter = block.timestamp + DELAY;
    }

    function applyMinter() external onlyVault {
        require(pendingMinter != address(0) && block.timestamp >= delayMinter);
        isMinter[pendingMinter] = true;
        minters.push(pendingMinter);

        pendingMinter = address(0);
        delayMinter = 0;
    }

    // No time delay revoke minter emergency function
    function revokeMinter(address _auth) external onlyVault {
        isMinter[_auth] = false;
    }

    function getAllMinters() external view returns (address[] memory) {
        return minters;
    }

    function changeVault(address newVault) external onlyVault returns (bool) {
        require(newVault != address(0), "AnyswapV6ERC20: address(0)");
        emit LogChangeVault(vault, newVault, block.timestamp);
        vault = newVault;
        pendingVault = address(0);
        delayVault = 0;
        return true;
    }

    function mint(address to, uint256 amount) external onlyAuth returns (bool) {
        _mint(to, amount);
        return true;
    }

    function burn(address from, uint256 amount) external onlyAuth returns (bool) {
        _burn(from, amount);
        return true;
    }

    function Swapin(bytes32 txhash, address account, uint256 amount) external onlyAuth returns (bool) {
        if (underlying != address(0) && IERC20(underlying).balanceOf(address(this)) >= amount) {
            IERC20(underlying).safeTransfer(account, amount);
        } else {
            _mint(account, amount);
        }
        emit LogSwapin(txhash, account, amount);
        return true;
    }

    function Swapout(uint256 amount, address bindaddr) external returns (bool) {
        require(!_vaultOnly, "AnyswapV6ERC20: vaultOnly");
        require(bindaddr != address(0), "AnyswapV6ERC20: address(0)");
        if (underlying != address(0) && _balances[msg.sender] < amount) {
            IERC20(underlying).safeTransferFrom(msg.sender, address(this), amount);
        } else {
            _burn(msg.sender, amount);
        }
        emit LogSwapout(msg.sender, bindaddr, amount);
        return true;
    }

    event OperatorTransferred(address indexed previousOperator, address indexed newOperator);
    event LogChangeVault(address indexed oldVault, address indexed newVault, uint indexed effectiveTime);
    event LogSwapin(bytes32 indexed txhash, address indexed account, uint amount);
    event LogSwapout(address indexed account, address indexed bindaddr, uint amount);
    event SetPolWallet(address oldWallet, address newWallet);
    event SetTaxSellingPercent(uint256 oldValue, uint256 newValue);
    event SetTaxBuyingPercent(uint256 oldValue, uint256 newValue);

    constructor(address _underlying, address _vault, address _polWallet, address _wbnbAddress, address _router) ERC20("Champion", "CHAM") {
        require(_polWallet != address(0), "!_polWallet");
        require(_wbnbAddress != address(0), "!_wbnbAddress");
        require(_router != address(0), "!_router");

        underlying = _underlying;
        if (_underlying != address(0)) {
            require(decimals() == IERC20Metadata(_underlying).decimals());
        }

        // Use init to allow for CREATE2 across all chains
        _init = true;

        // Disable/Enable swapout for v1 tokens vs mint/burn for v3 tokens
        _vaultOnly = false;

        vault = _vault;

        operator = msg.sender;
        polWallet = _polWallet;

        IUniswapV2Router _dexRouter = IUniswapV2Router(_router);
		address dexPair = IUniswapV2Factory(_dexRouter.factory()).createPair(address(this), _wbnbAddress);
        setMarketLpPairs(dexPair, true);
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function deposit() external returns (uint) {
        uint _amount = IERC20(underlying).balanceOf(msg.sender);
        IERC20(underlying).safeTransferFrom(msg.sender, address(this), _amount);
        return _deposit(_amount, msg.sender);
    }

    function deposit(uint amount) external returns (uint) {
        IERC20(underlying).safeTransferFrom(msg.sender, address(this), amount);
        return _deposit(amount, msg.sender);
    }

    function deposit(uint amount, address to) external returns (uint) {
        IERC20(underlying).safeTransferFrom(msg.sender, address(this), amount);
        return _deposit(amount, to);
    }

    function depositVault(uint amount, address to) external onlyVault returns (uint) {
        return _deposit(amount, to);
    }

    function _deposit(uint amount, address to) internal returns (uint) {
        require(!underlyingIsMinted);
        require(underlying != address(0) && underlying != address(this));
        _mint(to, amount);
        return amount;
    }

    function withdraw() external returns (uint) {
        return _withdraw(msg.sender, _balances[msg.sender], msg.sender);
    }

    function withdraw(uint amount) external returns (uint) {
        return _withdraw(msg.sender, amount, msg.sender);
    }

    function withdraw(uint amount, address to) external returns (uint) {
        return _withdraw(msg.sender, amount, to);
    }

    function withdrawVault(address from, uint amount, address to) external onlyVault returns (uint) {
        return _withdraw(from, amount, to);
    }

    function _withdraw(address from, uint amount, address to) internal returns (uint) {
        require(!underlyingIsMinted);
        require(underlying != address(0) && underlying != address(this));
        _burn(from, amount);
        IERC20(underlying).safeTransfer(to, amount);
        return amount;
    }

    function _transfer(address from, address to, uint256 amount) internal virtual override {
		require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual override {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual override {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        require(polWallet != address(0),"require to set polWallet address");
        address sender = _msgSender();
        // Buying token
        if(marketLpPairs[sender] && !excludedBuyingTaxAddresses[to] && taxBuyingPercent > 0) {
            uint256 taxAmount = amount * taxBuyingPercent / 10000;
            if(taxAmount > 0)
            {
                amount = amount - taxAmount;
                _transfer(sender, polWallet, taxAmount);
            }
        }
        // Selling token
		if(marketLpPairs[to] && !excludedSellingTaxAddresses[sender]) {
            if (taxSellingPercent > 0) {
                uint256 taxAmount = amount * taxSellingPercent / 10000;
                if(taxAmount > 0)
                {
                    amount = amount - taxAmount;
                    _transfer(sender, polWallet, taxAmount);
                }
            }
		}

        _transfer(sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        require(polWallet != address(0),"require to set polWallet address");
        
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);

        // Buying token
        if(marketLpPairs[from] && !excludedBuyingTaxAddresses[to] && taxBuyingPercent > 0) {
            uint256 taxAmount = amount * taxBuyingPercent / 10000;
            if(taxAmount > 0)
            {
                amount = amount - taxAmount;
                _transfer(from, polWallet, taxAmount);
            }
        }
        // Selling token
		if(marketLpPairs[to] && !excludedSellingTaxAddresses[from]) {
            if (taxSellingPercent > 0) {
                uint256 taxAmount = amount * taxSellingPercent / 10000;
                if(taxAmount > 0)
                {
                    amount = amount - taxAmount;
                    _transfer(from, polWallet, taxAmount);
                }
            }
		}

        _transfer(from, to, amount);
        return true;
    }

    function setPolWallet(address _polWallet) external onlyOperator {
        require(_polWallet != address(0), "_polWallet address cannot be 0 address");
		emit SetPolWallet(polWallet, _polWallet);
        polWallet = _polWallet;
    }

    function setTaxSellingPercent(uint256 _value) external onlyOperator returns (bool) {
		require(_value <= 50, "Max tax is 0.5%");
		emit SetTaxSellingPercent(taxSellingPercent, _value);
        taxSellingPercent = _value;
        return true;
    }

    function setTaxBuyingPercent(uint256 _value) external onlyOperator returns (bool) {
		require(_value <= 50, "Max tax is 0.5%");
		emit SetTaxBuyingPercent(taxBuyingPercent, _value);
        taxBuyingPercent = _value;
        return true;
    }

    function excludeSellingTaxAddress(address _address) external onlyOperator returns (bool) {
        require(!excludedSellingTaxAddresses[_address], "Address can't be excluded");
        excludedSellingTaxAddresses[_address] = true;
        return true;
    }

    function includeSellingTaxAddress(address _address) external onlyOperator returns (bool) {
        require(excludedSellingTaxAddresses[_address], "Address can't be included");
        excludedSellingTaxAddresses[_address] = false;
        return true;
    }

    function excludeBuyingTaxAddress(address _address) external onlyOperator returns (bool) {
        require(!excludedBuyingTaxAddresses[_address], "Address can't be excluded");
        excludedBuyingTaxAddresses[_address] = true;
        return true;
    }

    function includeBuyingTaxAddress(address _address) external onlyOperator returns (bool) {
        require(excludedBuyingTaxAddresses[_address], "Address can't be included");
        excludedBuyingTaxAddresses[_address] = false;
        return true;
    }

    function excludeAccountSellingLimitTime(address _address) external onlyOperator returns (bool) {
        require(!excludedAccountSellingLimitTime[_address], "Address can't be excluded");
        excludedAccountSellingLimitTime[_address] = true;
        return true;
    }

    function includeAccountSellingLimitTime(address _address) external onlyOperator returns (bool) {
        require(excludedAccountSellingLimitTime[_address], "Address can't be included");
        excludedAccountSellingLimitTime[_address] = false;
        return true;
    }

    //Add new LP's for selling / buying fees
    function setMarketLpPairs(address _pair, bool _value) public onlyOperator {
        marketLpPairs[_pair] = _value;
    }

    function transferOperator(address newOperator_) public onlyOperator {
        require(newOperator_ != address(0), "operator: zero address given for new operator");
        emit OperatorTransferred(operator, newOperator_);
        operator = newOperator_;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20Token is ERC20 {
    constructor(string memory name_, string memory symbol_, uint256 initialSupply) ERC20(name_, symbol_) {
        _mint(msg.sender, initialSupply);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "../lib/SafeMath.sol";
import "../interfaces/IUniswapV2Router.sol";
import "../interfaces/IUniswapV2Factory.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../owner/Operator.sol";

contract MainToken is ERC20, Operator {
    using SafeMath for uint256;
	
	uint256 public constant INITIAL_SUPPLY = 0.001 ether;

    mapping(address => bool) public excludedAccountSellingLimitTime;

	mapping(address => uint256) private _balances;
	address[] public excluded;
	address public polWallet;
	uint256 private _totalSupply;
	uint256 private constant maxExclusion = 20;

	// Tax
    address public immutable taxOffice;
	mapping (address => bool) public marketLpPairs; // LP Pairs
    bool public enabledTax;

	uint256 public taxSellingPercent = 0;
	mapping(address => bool) public excludedTaxAddresses;

	uint256 public timeLimitSelling = 0;
    mapping(address => uint256) private _lastTimeSelling;

	uint256 public maximumAmountSellPercent = 10000; // 100%

    /* =================== Events =================== */
    event GrantExclusion(address indexed account);
	event RevokeExclusion(address indexed account);
	event EnableCalculateTax();
	event DisableCalculateTax();
	event SetPolWallet(address oldWallet, address newWallet);
	event SetTaxSellingPercent(uint256 oldValue, uint256 newValue);
	event SetTimeLimitSelling(uint256 oldValue, uint256 newValue);
	event SetMaximumAmountSellPercent(uint256 oldValue, uint256 newValue);

    constructor(address _polWallet, address _ethAddress, address _router) ERC20("SWORD BSC TOKEN", "SWDB") {
		require(_polWallet != address(0), "!_polWallet");
		require(_ethAddress != address(0), "!_ethAddress");
		require(_router != address(0), "!_router");
		_totalSupply = 0;
		polWallet = _polWallet;

        taxOffice = msg.sender;

		IUniswapV2Router _dexRouter = IUniswapV2Router(_router);
		address dexPair = IUniswapV2Factory(_dexRouter.factory()).createPair(address(this), _ethAddress);
        setMarketLpPairs(dexPair, true);
        _mint(msg.sender, INITIAL_SUPPLY);
    }

    modifier onlyTaxOffice() {
        require(taxOffice == msg.sender, "taxOffice: caller is not the taxOffice");
        _;
    }

	function getExcluded() external view returns (address[] memory)
	{
		return excluded;
	}

	function circulatingSupply() public view returns (uint256) {
		uint256 excludedSupply = 0;
		uint256 excludedLength = excluded.length;
		for (uint256 i = 0; i < excludedLength; i++) {
			excludedSupply = excludedSupply.add(balanceOf(excluded[i]));
		}
		return _totalSupply.sub(excludedSupply);
	}

	function grantRebaseExclusion(address account) external onlyOperator
	{
		require(excluded.length <= maxExclusion, 'Too many excluded accounts');
		excluded.push(account);
		emit GrantExclusion(account);
	}

	function revokeRebaseExclusion(address account) external onlyOperator
	{
		uint256 excludedLength = excluded.length;
		for (uint256 i = 0; i < excludedLength; i++) {
			if (excluded[i] == account) {
				excluded[i] = excluded[excludedLength - 1];
				excluded.pop();
				emit RevokeExclusion(account);
				return;
			}
		}
	}

    //---OVERRIDE FUNCTION---
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        require(polWallet != address(0),"require to set polWallet address");
        
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);

        // Selling token
		if(marketLpPairs[to] && !excludedTaxAddresses[from]) {
			require(excludedAccountSellingLimitTime[from] || block.timestamp > _lastTimeSelling[from].add(timeLimitSelling), "Selling limit time");
			uint256 maxAmountSell = circulatingSupply().mul(maximumAmountSellPercent).div(10000);
			require(amount <= maxAmountSell, "Over max selling amount");
			if (enabledTax) {
				if (taxSellingPercent > 0) {
					uint256 taxAmount = amount.mul(taxSellingPercent).div(10000);
					if(taxAmount > 0)
					{
						amount = amount.sub(taxAmount);
						_transfer(from, polWallet, taxAmount);
					}
				}
			}

            _lastTimeSelling[from] = block.timestamp;
		}

        _transfer(from, to, amount);
        return true;
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        require(polWallet != address(0),"require to set polWallet address");
        address sender = _msgSender();
        // Selling token
		if(marketLpPairs[to] && !excludedTaxAddresses[sender]) {
			require(excludedAccountSellingLimitTime[sender] || block.timestamp > _lastTimeSelling[sender].add(timeLimitSelling), "Selling limit time");
			uint256 maxAmountSell = circulatingSupply().mul(maximumAmountSellPercent).div(10000);
			require(amount <= maxAmountSell, "Over max selling amount");
			if (enabledTax) {
				if (taxSellingPercent > 0) {
					uint256 taxAmount = amount.mul(taxSellingPercent).div(10000);
					if(taxAmount > 0)
					{
						amount = amount.sub(taxAmount);
						_transfer(sender, polWallet, taxAmount);
					}
				}
			}

            _lastTimeSelling[sender] = block.timestamp;
		}

        _transfer(sender, to, amount);
        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal virtual override {
		require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            _balances[to] += amount;
        }
        
        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }
        
	function _mint(address account, uint256 amount) internal virtual override {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual override {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function mint(address recipient_, uint256 amount_) external onlyOperator returns (bool) {
        uint256 balanceBefore = balanceOf(recipient_);
        _mint(recipient_, amount_);
        uint256 balanceAfter = balanceOf(recipient_);
        return balanceAfter > balanceBefore;
    }

	function burn(uint256 amount) external {
		if (amount > 0) _burn(_msgSender(), amount);
    }

	//---END OVERRIDE FUNCTION---


	function isPolWallet(address _address) external view returns (bool) {
		return _address == polWallet;
	}
	
	function setPolWallet(address _polWallet) external onlyTaxOffice {
        require(_polWallet != address(0), "_polWallet address cannot be 0 address");
		emit SetPolWallet(polWallet, _polWallet);
        polWallet = _polWallet;
    }

	function excludeTaxAddress(address _address) external onlyTaxOffice returns (bool) {
        require(!excludedTaxAddresses[_address], "Address can't be excluded");
        excludedTaxAddresses[_address] = true;
        return true;
    }

    function includeTaxAddress(address _address) external onlyTaxOffice returns (bool) {
        require(excludedTaxAddresses[_address], "Address can't be included");
        excludedTaxAddresses[_address] = false;
        return true;
    }

	function enableCalculateTax() external onlyTaxOffice {
        enabledTax = true;
		emit EnableCalculateTax();
    }

    function disableCalculateTax() external onlyTaxOffice {
        enabledTax = false;
		emit DisableCalculateTax();
    }

	function setTaxSellingPercent(uint256 _value) external onlyTaxOffice returns (bool) {
		require(_value <= 50, "Max tax is 0.5%");
		emit SetTaxSellingPercent(taxSellingPercent, _value);
        taxSellingPercent = _value;
        return true;
    }

	function setTimeLimitSelling(uint256 _value) external onlyTaxOffice returns (bool) {
		require(_value <= 5 minutes, "Max limit time is 5 minutes");
		emit SetTimeLimitSelling(timeLimitSelling, _value);
        timeLimitSelling = _value;
        return true;
    }

	function setMaximumAmountSellPercent(uint256 _value) external onlyTaxOffice returns (bool) {
		require(_value <= 10000 && _value >= 50, "Value range [0.5-100%]");
		emit SetMaximumAmountSellPercent(maximumAmountSellPercent, _value);
        maximumAmountSellPercent = _value;
        return true;
    }

	function excludeAccountSellingLimitTime(address _address) external onlyTaxOffice returns (bool) {
        require(!excludedAccountSellingLimitTime[_address], "Address can't be excluded");
        excludedAccountSellingLimitTime[_address] = true;
        return true;
    }

    function includeAccountSellingLimitTime(address _address) external onlyTaxOffice returns (bool) {
        require(excludedAccountSellingLimitTime[_address], "Address can't be included");
        excludedAccountSellingLimitTime[_address] = false;
        return true;
    }

	//Add new LP's for selling / buying fees
    function setMarketLpPairs(address _pair, bool _value) public onlyTaxOffice {
        marketLpPairs[_pair] = _value;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "../lib/SafeMath.sol";
import "../interfaces/IUniswapV2Router.sol";
import "../interfaces/IUniswapV2Factory.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../owner/Operator.sol";

contract ShareToken is ERC20, Operator {
    using SafeMath for uint256;
	
	uint256 public constant INITIAL_SUPPLY = 100 ether;
    uint256 public constant FARMING_POOL_REWARD_ALLOCATION = 18000 ether;

    bool public rewardPoolDistributed = false;

	mapping(address => uint256) private _balances;
	address[] public excluded;
	address public polWallet;
	uint256 private _totalSupply;
	uint256 private constant maxExclusion = 20;

	// Tax
	mapping (address => bool) public marketLpPairs; // LP Pairs
    bool public enabledTax;

	uint256 public taxSellingPercent = 0;
	mapping(address => bool) public excludedTaxAddresses;

    /* =================== Events =================== */
    event GrantExclusion(address indexed account);
	event RevokeExclusion(address indexed account);
	event EnableCalculateTax();
	event DisableCalculateTax();
	event SetPolWallet(address oldWallet, address newWallet);
	event SetTaxSellingPercent(uint256 oldValue, uint256 newValue);
	event SetTimeLimitSelling(uint256 oldValue, uint256 newValue);
	event SetMaximumAmountSellPercent(uint256 oldValue, uint256 newValue);

    constructor(address _polWallet, address _ethAddress, address _router) ERC20("SHIELD TOKEN", "SHDB") {
		require(_polWallet != address(0), "!_polWallet");
		require(_ethAddress != address(0), "!_ethAddress");
		require(_router != address(0), "!_router");
		_totalSupply = 0;
		polWallet = _polWallet;
		IUniswapV2Router _dexRouter = IUniswapV2Router(_router);
		address dexPair = IUniswapV2Factory(_dexRouter.factory()).createPair(address(this), _ethAddress);
        setMarketLpPairs(dexPair, true);

        _mint(msg.sender, INITIAL_SUPPLY);
    }

	function getExcluded() external view returns (address[] memory)
	{
		return excluded;
	}

	function circulatingSupply() public view returns (uint256) {
		uint256 excludedSupply = 0;
		uint256 excludedLength = excluded.length;
		for (uint256 i = 0; i < excludedLength; i++) {
			excludedSupply = excludedSupply.add(balanceOf(excluded[i]));
		}
		return _totalSupply.sub(excludedSupply);
	}

	function grantRebaseExclusion(address account) external onlyOperator
	{
		require(excluded.length <= maxExclusion, 'Too many excluded accounts');
		excluded.push(account);
		emit GrantExclusion(account);
	}

	function revokeRebaseExclusion(address account) external onlyOperator
	{
		uint256 excludedLength = excluded.length;
		for (uint256 i = 0; i < excludedLength; i++) {
			if (excluded[i] == account) {
				excluded[i] = excluded[excludedLength - 1];
				excluded.pop();
				emit RevokeExclusion(account);
				return;
			}
		}
	}

    //---OVERRIDE FUNCTION---
    
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        require(polWallet != address(0),"require to set polWallet address");
        address sender = _msgSender();
        // Selling token
		if(marketLpPairs[to] && !excludedTaxAddresses[sender]) {
			if (enabledTax) {
				if (taxSellingPercent > 0) {
					uint256 taxAmount = amount.mul(taxSellingPercent).div(10000);
					if(taxAmount > 0)
					{
						amount = amount.sub(taxAmount);
						_transfer(sender, polWallet, taxAmount);
					}
				}
			}
		}
        _transfer(sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        require(polWallet != address(0),"require to set polWallet address");
        
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);

        // Selling token
		if(marketLpPairs[to] && !excludedTaxAddresses[from]) {
			if (enabledTax) {
				if (taxSellingPercent > 0) {
					uint256 taxAmount = amount.mul(taxSellingPercent).div(10000);
					if(taxAmount > 0)
					{
						amount = amount.sub(taxAmount);
						_transfer(from, polWallet, taxAmount);
					}
				}
			}
		}

        _transfer(from, to, amount);
        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal virtual override {
		require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }
        
	function _mint(address account, uint256 amount) internal virtual override {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual override {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

	function burn(uint256 amount) external {
		if (amount > 0) _burn(_msgSender(), amount);
    }

    //---END OVERRIDE FUNCTION---

	function isPolWallet(address _address) external view returns (bool) {
		return _address == polWallet;
	}
	
	function setPolWallet(address _polWallet) external onlyOperator {
        require(_polWallet != address(0), "_polWallet address cannot be 0 address");
		emit SetPolWallet(polWallet, _polWallet);
        polWallet = _polWallet;
    }

	function excludeTaxAddress(address _address) external onlyOperator returns (bool) {
        require(!excludedTaxAddresses[_address], "Address can't be excluded");
        excludedTaxAddresses[_address] = true;
        return true;
    }

    function includeTaxAddress(address _address) external onlyOperator returns (bool) {
        require(excludedTaxAddresses[_address], "Address can't be included");
        excludedTaxAddresses[_address] = false;
        return true;
    }

	function enableCalculateTax() external onlyOperator {
        enabledTax = true;
		emit EnableCalculateTax();
    }

    function disableCalculateTax() external onlyOperator {
        enabledTax = false;
		emit DisableCalculateTax();
    }

	function setTaxSellingPercent(uint256 _value) external onlyOperator returns (bool) {
		require(_value <= 50, "Max tax is 0.5%");
		emit SetTaxSellingPercent(taxSellingPercent, _value);
        taxSellingPercent = _value;
        return true;
    }

	//Add new LP's for selling / buying fees
    function setMarketLpPairs(address _pair, bool _value) public onlyOperator {
        marketLpPairs[_pair] = _value;
    }

    function distributeReward(address _farmingPoolAddress) external onlyOperator {
        require(!rewardPoolDistributed, "only can distribute once");
        require(_farmingPoolAddress != address(0), "!_farmingPoolAddress");
        rewardPoolDistributed = true;
        _mint(_farmingPoolAddress, FARMING_POOL_REWARD_ALLOCATION);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "../owner/Operator.sol";

contract CanPause is Operator {
    bool public isPause = false;

    modifier onlyOpen() {
        require(isPause == false, "RebateToken: in pause state");
        _;
    }
    // set pause state
    function setPause(bool _isPause) external onlyOperator {
        isPause = _isPause;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

contract ContractGuard {
    mapping(uint256 => mapping(address => bool)) private _status;

    function checkSameOriginReentranted() internal view returns (bool) {
        return _status[block.number][tx.origin];
    }

    function checkSameSenderReentranted() internal view returns (bool) {
        return _status[block.number][msg.sender];
    }

    modifier onlyOneBlock() {
        require(!checkSameOriginReentranted(), "ContractGuard: one block, one function");
        require(!checkSameSenderReentranted(), "ContractGuard: one block, one function");

        _status[block.number][tx.origin] = true;
        _status[block.number][msg.sender] = true;

        _;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract EmergencyWithdraw is OwnableUpgradeable {
  event Received(address sender, uint amount);

  /**
   * @dev allow contract to receive ethers
   */
  receive() external payable {
    emit Received(_msgSender(), msg.value);
  }

  /**
   * @dev get the eth balance on the contract
   * @return eth balance
   */
  function getEthBalance() external view returns (uint) {
    return address(this).balance;
  }

  /**
   * @dev withdraw eth balance
   */
  function emergencyWithdrawEthBalance(address _to, uint _amount) external onlyOwner {
    payable(_to).transfer(_amount);
  }

  /**
   * @dev get the token balance
   * @param _tokenAddress token address
   */
  function getTokenBalance(address _tokenAddress) external view returns (uint) {
    IERC20 erc20 = IERC20(_tokenAddress);
    return erc20.balanceOf(address(this));
  }

  /**
   * @dev withdraw token balance
   * @param _tokenAddress token address
   */
  function emergencyWithdrawTokenBalance(
    address _tokenAddress,
    address _to,
    uint _amount
  ) external onlyOwner {
    IERC20 erc20 = IERC20(_tokenAddress);
    erc20.transfer(_to, _amount);
  }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import '@openzeppelin/contracts/utils/math/SafeMath.sol';

import '../owner/Operator.sol';

contract Epoch is Operator {
    using SafeMath for uint256;

    uint256 private period;
    uint256 private startTime;
    uint256 private lastEpochTime;
    uint256 private epoch;

    /* ========== CONSTRUCTOR ========== */

    constructor(
        uint256 _period,
        uint256 _startTime,
        uint256 _startEpoch
    ) {
        period = _period;
        startTime = _startTime;
        epoch = _startEpoch;
        lastEpochTime = startTime.sub(period);
    }

    /* ========== Modifier ========== */

    modifier checkStartTime {
        require(block.timestamp >= startTime, 'Epoch: not started yet');

        _;
    }

    modifier checkEpoch {
        uint256 _nextEpochPoint = nextEpochPoint();
        if (block.timestamp < _nextEpochPoint) {
            require(msg.sender == operator(), 'Epoch: only operator allowed for pre-epoch');
            _;
        } else {
            _;

            for (;;) {
                lastEpochTime = _nextEpochPoint;
                ++epoch;
                _nextEpochPoint = nextEpochPoint();
                if (block.timestamp < _nextEpochPoint) break;
            }
        }
    }

    /* ========== VIEW FUNCTIONS ========== */

    function getCurrentEpoch() public view returns (uint256) {
        return epoch;
    }

    function getPeriod() public view returns (uint256) {
        return period;
    }

    function getStartTime() public view returns (uint256) {
        return startTime;
    }

    function getLastEpochTime() public view returns (uint256) {
        return lastEpochTime;
    }

    function nextEpochPoint() public view returns (uint256) {
        return lastEpochTime.add(period);
    }

    /* ========== GOVERNANCE ========== */

    function setPeriod(uint256 _period) external onlyOperator {
        require(_period >= 1 hours && _period <= 48 hours, '_period: out of range');
        period = _period;
    }

    function setEpoch(uint256 _epoch) external onlyOperator {
        epoch = _epoch;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "../owner/Operator.sol";

interface IBlackList {
    function isBlacklisted(address sender) external view returns (bool);
}

contract HasBlacklist is Operator {
    address public BL = 0x107Ac39903bDAD94cb562E686E0A5E116d3dc814;

    modifier notInBlackList(address sender) {
        bool isBlock = IBlackList(BL).isBlacklisted(sender);
        require(isBlock == false, "HasBlacklist: in blacklist");
        _;
    }

    // Set Blacklist 
    function setBL(address blacklist) external onlyOperator {
        BL = blacklist;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "../owner/Operator.sol";
import "../interfaces/IUniswapV2Factory.sol";

contract HasFactory is Operator {
    IUniswapV2Factory public FACTORY = IUniswapV2Factory(0x9Ad6C38BE94206cA50bb0d90783181662f0Cfa10);

    // set pol address
    function setFactory(address factory) external onlyOperator {
        FACTORY = IUniswapV2Factory(factory);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "../owner/Operator.sol";

contract HasPOL is Operator {
    address public POL = 0x409968A6E6cb006E8919de46A894138C43Ee1D22;
    
    // set pol address
    function setPolAddress(address _pol) external onlyOperator {
        POL = _pol;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "../owner/Operator.sol";
import "../interfaces/IUniswapV2Router.sol";

contract HasRouter is Operator {
    IUniswapV2Router public ROUTER = IUniswapV2Router(0x60aE616a2155Ee3d9A68541Ba4544862310933d4);
    
    function setRouter(address router) external onlyOperator {
        ROUTER = IUniswapV2Router(router);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

library StringUtils {
    function concat(string memory a, string memory b) internal pure returns (string memory) {
        return string(abi.encodePacked(a, b));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CeSolidManager is Ownable, Pausable {
    using SafeERC20 for IERC20;

    /**
     * @dev Peanutfi Contracts:
     * {keeper} - Address to manage a few lower risk features of the strat..
     */
    address public keeper;
    address public voter;

    event NewKeeper(address oldKeeper, address newKeeper);
    event NewVoter(address newVoter);

    /**
     * @dev Initializes the base strategy.
     * @param _keeper address to use as alternative owner.
     */
    constructor(
        address _keeper,
        address _voter
    ) {
        keeper = _keeper;
        voter = _voter;
    }

    // Checks that caller is either owner or keeper.
    modifier onlyManager() {
        require(msg.sender == owner() || msg.sender == keeper, "CeSolidManager: MANAGER_ONLY");
        _;
    }

    // Checks that caller is either owner or keeper.
    modifier onlyVoter() {
        require(msg.sender == voter, "CeSolidManager: VOTER_ONLY");
        _;
    }

    /**
     * @dev Updates address of the strat keeper.
     * @param _keeper new keeper address.
     */
    function setKeeper(address _keeper) external onlyManager {
        emit NewKeeper( keeper, _keeper);
        keeper = _keeper;
    }

    function setVoter(address _voter) external onlyManager {
        emit NewVoter(_voter);
        voter = _voter;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./CeSolidManager.sol";
import "../interfaces/IVoter.sol";
import "../interfaces/IVeToken.sol";
import "../interfaces/IVeDist.sol";
import "../interfaces/IMinter.sol";

contract CeSolidStaker is ERC20, CeSolidManager, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // Addresses used 
    IVoter public solidVoter;
    IVeToken public ve;
    IVeDist public veDist;

    // Want token and our NFT Token ID
    IERC20 public want;
    uint256 public tokenId;

    // Max Lock time, Max variable used for reserve split and the reserve rate. 
    uint16 public constant MAX = 10000;
    uint256 public constant MAX_LOCK = 365 days * 4;
    uint256 public reserveRate; 

    // Our on chain events.
    event CreateLock(address indexed user, uint256 veTokenId, uint256 amount, uint256 unlockTime);
    event Release(address indexed user, uint256 veTokenId, uint256 amount);
    event IncreaseTime(address indexed user, uint256 veTokenId, uint256 unlockTime);
    event DepositWant(uint256 amount);
    event Withdraw(uint256 amount);
    event ClaimVeEmissions(address indexed user, uint256 veTokenId, uint256 amount);
    event UpdatedReserveRate(uint256 newRate);

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _reserveRate,
        address _solidVoter,
        address _keeper,
        address _voter
    ) ERC20( _name, _symbol) CeSolidManager(_keeper, _voter){
        reserveRate = _reserveRate;
        solidVoter = IVoter(_solidVoter);
        ve = IVeToken(solidVoter._ve());
        want = IERC20(ve.token());
        IMinter _minter = IMinter(solidVoter.minter());
        veDist = IVeDist(_minter._rewards_distributor());

        want.safeApprove(address(ve), type(uint256).max);
    }

    // Deposit all want for a user.
    function depositAll() external {
        _deposit(want.balanceOf(msg.sender));
    }

    // Deposit an amount of want.
    function deposit(uint256 _amount) external {
        _deposit(_amount);
    }

     // Internal: Deposits Want and mint beWant, checks for ve increase opportunities first. 
    function _deposit(uint256 _amount) internal nonReentrant whenNotPaused {
        lock();
        uint256 _pool = balanceOfWant();
        want.safeTransferFrom(msg.sender, address(this), _amount);
        uint256 _after = balanceOfWant();
        _amount = _after - _pool; // Additional check for deflationary tokens.

        if (_amount > 0) {
            _mint(msg.sender, _amount);
            emit DepositWant(totalWant());
        }
    }

    // Deposit more in ve and up lock_time.
    function lock() public { 
        if (totalWant() > 0) {
            (,, bool shouldIncreaseLock) = lockInfo();
            if (balanceOfWant() > requiredReserve()) {
                uint256 availableBalance = balanceOfWant() - requiredReserve();
                ve.increase_amount(tokenId, availableBalance);
                if (shouldIncreaseLock) {
                    ve.increase_unlock_time(tokenId, MAX_LOCK);
                }
            } else {
                // Extend max lock
                if (shouldIncreaseLock) {
                    ve.increase_unlock_time(tokenId, MAX_LOCK);
                }
            }
        }
    }

    // Withdraw capable if we have enough Want in the contract. 
    function withdraw(uint256 _amount) external {
        require(_amount <= withdrawableBalance(), "Not enough Want");
        _burn(msg.sender, _amount);
        want.safeTransfer(msg.sender, _amount);
        emit Withdraw(totalWant());
    }

    // Total Want in ve contract and beVe contract. 
    function totalWant() public view returns (uint256) {
        return balanceOfWant() + balanceOfWantInVe();
    }

    // Our required Want held in the contract to enable withdraw capabilities.
    function requiredReserve() public view returns (uint256 reqReserve) {
        // We calculate allocation for reserve of the total staked in Ve.
        reqReserve = balanceOfWantInVe() * reserveRate / MAX;
    }

    // Calculate how much 'want' is held by this contract
    function balanceOfWant() public view returns (uint256) {
        return want.balanceOf(address(this));
    }

    // What is our end lock and seconds remaining in lock? 
    function lockInfo() public view returns (uint256 endTime, uint256 secondsRemaining, bool shouldIncreaseLock) {
        (, endTime) = ve.locked(tokenId);
        uint256 unlockTime = (block.timestamp + MAX_LOCK) / 1 weeks * 1 weeks;
        secondsRemaining = endTime > block.timestamp ? endTime - block.timestamp : 0;
        shouldIncreaseLock = unlockTime > endTime ? true : false;
    }

    // Withdrawable Balance for users
    function withdrawableBalance() public view returns (uint256) {
        return balanceOfWant();
    }

    // How many want we got earning? 
    function balanceOfWantInVe() public view returns (uint256 wants) {
        (wants, ) = ve.locked(tokenId);
    }

    // Claim veToken emissions and increases locked amount in veToken
    function claimVeEmissions() public virtual {
        uint256 _amount = veDist.claim(tokenId);
        emit ClaimVeEmissions(msg.sender, tokenId, _amount);
    }

    // Reset current votes
    function resetVote() external onlyVoter {
        solidVoter.reset(tokenId);
    }

    // Create a new veToken if none is assigned to this address
    function createLock(uint256 _amount, uint256 _lock_duration) external onlyManager {
        require(tokenId == 0, "veToken > 0");
        require(_amount > 0, "amount == 0");

        want.safeTransferFrom(address(msg.sender), address(this), _amount);
        tokenId = ve.create_lock(_amount, _lock_duration);
        _mint(msg.sender, _amount);

        emit CreateLock(msg.sender, tokenId, _amount, _lock_duration);
    }

    // Release expired lock of a veToken owned by this address
    function release() external onlyOwner {
        (uint endTime,,) = lockInfo();
        require(endTime <= block.timestamp, "!Unlocked");
        ve.withdraw(tokenId);
    
        emit Release(msg.sender, tokenId, balanceOfWant());
    }

    // Whitelist new token
    function whitelist(address _token) external onlyManager {
        solidVoter.whitelist(_token, tokenId);
    }

     // Adjust reserve rate 
    function adjustReserve(uint256 _rate) external onlyOwner { 
        require(_rate <= MAX, "Higher than max");
        reserveRate = _rate;
        emit UpdatedReserveRate(_rate);
    }

    // Pause deposits
    function pause() public onlyManager {
        _pause();
        want.safeApprove(address(ve), 0);
    }

    // Unpause deposits
    function unpause() external onlyManager {
        _unpause();
        want.safeApprove(address(ve), type(uint256).max);
    }

    // Confirmation required for receiving veToken to smart contract
    function onERC721Received(
        address operator,
        address from,
        uint _tokenId,
        bytes calldata data
    ) external view returns (bytes4) {
        operator;
        from;
        _tokenId;
        data;
        require(msg.sender == address(ve), "!veToken");
        return bytes4(keccak256("onERC721Received(address,address,uint,bytes)"));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../lib/Math.sol";

contract CeVeloRewardPool is Ownable {
    using SafeERC20 for IERC20;

    IERC20 public token;
    uint256 public duration;

    uint256 private _totalSupply;
    uint256 public periodFinish;
    uint256 public rewardRate;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    uint256 public rewardBalance;
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;
    mapping(address => uint256) private _balances;
    mapping(address => bool) public whitelist;

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event AddedWhiteList(address strategy);
    event RemovedWhitelist(address strategy);

    constructor(address _token, uint256 _duration) {
        token = IERC20(_token);
        duration = _duration;
    }

    modifier onlyWhitelist(address account) {
        require(whitelist[account] == true, "RewardPool: WHITE_LIST_ONLY");
        _;
    }

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return Math.min(block.timestamp, periodFinish);
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalSupply() == 0) {
            return rewardPerTokenStored;
        }
        return rewardPerTokenStored + (
                (lastTimeRewardApplicable() - lastUpdateTime)
                * rewardRate
                * 1e18
                / totalSupply()
            );
    }

    function earned(address account) public view returns (uint256) {
        return
            balanceOf(account)
                * (rewardPerToken() - userRewardPerTokenPaid[account])
                / 1e18
                + rewards[account];
    }

    function stake(uint256 amount) public updateReward(msg.sender) onlyWhitelist(msg.sender) {
        require(amount > 0, "RewardPool: ZERO_AMOUNT");
        _totalSupply = _totalSupply + amount;
        _balances[msg.sender] = _balances[msg.sender] + amount;
        emit Staked(msg.sender, amount);
    }

    function withdraw(uint256 amount) public updateReward(msg.sender) onlyWhitelist(msg.sender) {
        require(amount > 0, "RewardPool: ZERO_AMOUNT");
        _totalSupply = _totalSupply - amount;
        _balances[msg.sender] = _balances[msg.sender] - amount;
        emit Withdrawn(msg.sender, amount);
    }

    function getReward() public updateReward(msg.sender) {
        uint256 reward = earned(msg.sender);
        if (reward > 0) {
            if (reward > rewardBalance) {
                reward = rewardBalance;
            }
            rewardBalance = rewardBalance - reward;
            rewards[msg.sender] = 0;
            token.safeTransfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
    }

    // Add depositing strategy to whitelist
    function addWhitelist(address _strategy) external onlyOwner {
        whitelist[_strategy] = true;
        emit AddedWhiteList(_strategy);
    }

    // remove depositing strategy from whitelist
    function removeWhitelist(address _strategy) external onlyOwner {
        whitelist[_strategy] = false;
        emit RemovedWhitelist(_strategy);
    }

    function notifyRewardAmount()
        external
        updateReward(address(0))
    {
        uint256 balance = token.balanceOf(address(this));
        uint256 newRewards = balance - rewardBalance;
        if (newRewards > 0) {
            if (block.timestamp >= periodFinish) {
                rewardRate = newRewards / duration;
            } else {
                uint256 remaining = periodFinish - block.timestamp;
                uint256 leftover = remaining * rewardRate;
                rewardRate = (newRewards + leftover) / duration;
            }
            rewardBalance = rewardBalance + newRewards;
            lastUpdateTime = block.timestamp;
            periodFinish = block.timestamp + duration;
            emit RewardAdded(newRewards);
        }
    }

    function inCaseTokensGetStuck(address _token) external onlyOwner {
        if (totalSupply() != 0) {
            require(_token != address(token), "RewardPool: STUCK_TOKEN_ONLY");
        }
        uint256 amount = IERC20(_token).balanceOf(address(this));
        IERC20(_token).safeTransfer(msg.sender, amount);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "../interfaces/IUniswapV2Router.sol";

contract ChampionOptimizerCeFeeBatchV1 is Initializable, OwnableUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    IERC20Upgradeable public wNative;
    address public dfTreasury;
    address public coTreasury;
    address public strategist;
    address public chamStaker;

    // Fee constants
    uint constant public MAX_FEE = 1000;
    uint public dfTreasuryFee;
    uint public coTreasuryFee;
    uint public strategistFee;
    uint public chamStakerFee;

    event NewDfTreasury(address oldValue, address newValue);
    event NewCoTreasury(address oldValue, address newValue);
    event NewStrategist(address oldValue, address newValue);
    event NewChamStaker(address oldValue, address newValue);

    function initialize(
        address _wNative,
        address _dfTreasury,
        address _coTreasury,  
        address _chamStaker,
        address _strategist,
        uint256 _coTreasuryFee,
        uint256 _chamStakerFee,
        uint256 _strategistFee  
    ) public initializer {
        __Ownable_init();
        wNative  = IERC20Upgradeable(_wNative);
        dfTreasury = _dfTreasury;
        coTreasury = _coTreasury;
        chamStaker = _chamStaker;
        strategist = _strategist;

        chamStakerFee = _chamStakerFee;
        strategistFee = _strategistFee;
        coTreasuryFee = _coTreasuryFee;
        dfTreasuryFee = MAX_FEE - (chamStakerFee + strategistFee + coTreasuryFee);
    }

    // Main function. Divides profits.
    function harvest() public {
        uint256 wNativeBal = wNative.balanceOf(address(this));

        uint256 coTreasuryAmount = wNativeBal * coTreasuryFee / MAX_FEE;
        wNative.safeTransfer(coTreasury, coTreasuryAmount);

        uint256 dfTreasuryAmount = wNativeBal * dfTreasuryFee / MAX_FEE;
        wNative.safeTransfer(dfTreasury, dfTreasuryAmount);

        uint256 chamStakerAmount = wNativeBal * chamStakerFee / MAX_FEE;
        wNative.safeTransfer(chamStaker, chamStakerAmount);

        uint256 strategistAmount = wNativeBal * strategistFee / MAX_FEE;
        wNative.safeTransfer(strategist, strategistAmount);
    }

    // Manage the contract
    function setDfTreasury(address _dfTreasury) external onlyOwner {
        emit NewDfTreasury(dfTreasury, _dfTreasury);
        dfTreasury = _dfTreasury;
    }

    function setCoTreasury(address _coTreasury) external onlyOwner {
        emit NewDfTreasury(coTreasury, _coTreasury);
        coTreasury = _coTreasury;
    }

    function setStrategist(address _strategist) external onlyOwner {
        emit NewStrategist(strategist, _strategist);
        strategist = _strategist;
    }

    function setChamStaker(address _chamStaker) external onlyOwner {
        emit NewChamStaker(chamStaker, _chamStaker);
        chamStaker = _chamStaker;
    }

    function setFees(
        uint256 _coTreasuryFee,
        uint256 _chamStakerFee,
        uint256 _strategistFee
    ) public onlyOwner {
        require(
            MAX_FEE >= (_chamStakerFee + _coTreasuryFee + _strategistFee),
            "CoFeeBatch: FEE_TOO_HIGH"
        );
        coTreasuryFee = _coTreasuryFee;
        chamStakerFee = _chamStakerFee;
        strategistFee = _strategistFee;
        dfTreasuryFee = MAX_FEE - (chamStakerFee + _coTreasuryFee + _strategistFee);
    }
    
    // Rescue locked funds sent by mistake
    function inCaseTokensGetStuck(address _token, address _recipient) external onlyOwner {
        require(_token != address(wNative), "CoFeeBatch: NATIVE_TOKEN");

        uint256 amount = IERC20Upgradeable(_token).balanceOf(address(this));
        IERC20Upgradeable(_token).safeTransfer(_recipient, amount);
    }

    receive() external payable {}
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract ChampionOptimizerCeFeeConfigurator is OwnableUpgradeable {

    struct FeeCategory {
        uint256 total;      // total fee charged on each harvest
        uint256 co;   // split of total fee going to co fee batcher
        uint256 call;       // split of total fee going to harvest caller
        uint256 strategist; // split of total fee going to developer of the strategy
        string label;       // description of the type of fee category
        bool active;        // on/off switch for fee category
    }

    address public keeper;
    uint256 public totalLimit;
    uint256 constant DIVISOR = 1 ether;

    mapping(address => uint256) public stratFeeId;
    mapping(uint256 => FeeCategory) internal feeCategory;

    event SetStratFeeId(address indexed strategy, uint256 indexed id);
    event SetFeeCategory(
        uint256 indexed id,
        uint256 total,
        uint256 co,
        uint256 call,
        uint256 strategist,
        string label,
        bool active
    );
    event Pause(uint256 indexed id);
    event Unpause(uint256 indexed id);
    event SetKeeper(address indexed keeper);

    function initialize(
        address _keeper,
        uint256 _totalLimit
    ) public initializer {
        __Ownable_init();

        keeper = _keeper;
        totalLimit = _totalLimit;
    }

    // checks that caller is either operator or keeper
    modifier onlyManager() {
        require(msg.sender == owner() || msg.sender == keeper, "FeeConfigurator: MANAGER_ONLY");
        _;
    }

    // fetch fees for a strategy
    function getFees(address _strategy) external view returns (FeeCategory memory) {
        return getFeeCategory(stratFeeId[_strategy], false);
    }

    // fetch fees for a strategy, _adjust option to view fees as % of total harvest instead of % of total fee
    function getFees(address _strategy, bool _adjust) external view returns (FeeCategory memory) {
        return getFeeCategory(stratFeeId[_strategy], _adjust);
    }

    // fetch fee category for an id if active, otherwise return default category
    // _adjust == true: view fees as % of total harvest instead of % of total fee
    function getFeeCategory(uint256 _id, bool _adjust) public view returns (FeeCategory memory fees) {
        uint256 id = feeCategory[_id].active ? _id : 0;
        fees = feeCategory[id];
        if (_adjust) {
            uint256 _totalFee = fees.total;
            fees.co = fees.co * _totalFee / DIVISOR;
            fees.call = fees.call * _totalFee / DIVISOR;
            fees.strategist = fees.strategist * _totalFee / DIVISOR;
        }
    }

    // set a fee category id for a strategy that calls this function directly
    function setStratFeeId(uint256 _feeId) external {
        _setStratFeeId(msg.sender, _feeId);
    }

    // set a fee category id for a strategy by a manager
    function setStratFeeId(address _strategy, uint256 _feeId) external onlyManager {
        _setStratFeeId(_strategy, _feeId);
    }

    // set fee category ids for multiple strategies at once by a manager
    function setStratFeeId(address[] memory _strategies, uint256[] memory _feeIds) external onlyManager {
        uint256 stratLength = _strategies.length;
        for (uint256 i = 0; i < stratLength; i++) {
            _setStratFeeId(_strategies[i], _feeIds[i]);
        }
    }

    // internally set a fee category id for a strategy
    function _setStratFeeId(address _strategy, uint256 _feeId) internal {
        stratFeeId[_strategy] = _feeId;
        emit SetStratFeeId(_strategy, _feeId);
    }

    // set values for a fee category using the relative split for call and strategist
    // i.e. call = 0.01 ether == 1% of total fee
    // _adjust == true: input call and strat fee as % of total harvest
    function setFeeCategory(
        uint256 _id,
        uint256 _total,
        uint256 _call,
        uint256 _strategist,
        string memory _label,
        bool _active,
        bool _adjust
    ) external onlyOwner {
        require(_total <= totalLimit, "FeeConfigurator: TOTAL_LIMIT");
        if (_adjust) {
            _call = _call * DIVISOR / _total;
            _strategist = _strategist * DIVISOR / _total;
        }
        uint256 co = DIVISOR - _call - _strategist;

        FeeCategory memory category = FeeCategory(_total, co, _call, _strategist, _label, _active);
        feeCategory[_id] = category;
        emit SetFeeCategory(_id, _total, co, _call, _strategist, _label, _active);
    }

    // deactivate a fee category making all strategies with this fee id revert to default fees
    function pause(uint256 _id) external onlyManager {
        feeCategory[_id].active = false;
        emit Pause(_id);
    }

    // reactivate a fee category
    function unpause(uint256 _id) external onlyManager {
        feeCategory[_id].active = true;
        emit Unpause(_id);
    }

    // change keeper
    function setKeeper(address _keeper) external onlyManager {
        keeper = _keeper;
        emit SetKeeper(_keeper);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/IFeeConfig.sol";

contract StrategyCeManager is Ownable, Pausable {

    struct CommonAddresses {
        address vault;
        address uniRouter;
        address keeper;
        address strategist;
        address coFeeRecipient;
        address coFeeConfig;
    }

    // common addresses for the strategy
    address public vault;
    address public uniRouter;
    address public keeper;
    address public strategist;
    address public coFeeRecipient;
    IFeeConfig public coFeeConfig;

    uint256 constant DIVISOR = 1 ether;
    uint256 constant public WITHDRAWAL_FEE_CAP = 50;
    uint256 constant public WITHDRAWAL_MAX = 10000;
    uint256 public withdrawalFee = 10;

    event SetStratFeeId(uint256 feeId);
    event SetWithdrawalFee(uint256 withdrawalFee);
    event SetVault(address vault);
    event SetUniRouter(address uniRouter);
    event SetKeeper(address keeper);
    event SetStrategist(address strategist);
    event SetCoFeeRecipient(address coFeeRecipient);
    event SetCoFeeConfig(address coFeeConfig);

    constructor(CommonAddresses memory _commonAddresses) {
        vault = _commonAddresses.vault;
        uniRouter = _commonAddresses.uniRouter;
        keeper = _commonAddresses.keeper;
        strategist = _commonAddresses.strategist;
        coFeeRecipient = _commonAddresses.coFeeRecipient;
        coFeeConfig = IFeeConfig(_commonAddresses.coFeeConfig);
    }

    // checks that caller is either owner or keeper.
    modifier onlyManager() {
        require(msg.sender == owner() || msg.sender == keeper, "StrategyCeManager: MANAGER_ONLY");
        _;
    }

    // fetch fees from config contract
    function getFees() public view returns (IFeeConfig.FeeCategory memory) {
        return coFeeConfig.getFees(address(this));
    }

    function getStratFeeId() external view returns (uint256) {
        return coFeeConfig.stratFeeId(address(this));
    }

    function setStratFeeId(uint256 _feeId) external onlyManager {
        coFeeConfig.setStratFeeId(_feeId);
        emit SetStratFeeId(_feeId);
    }

    // adjust withdrawal fee
    function setWithdrawalFee(uint256 _fee) public onlyManager {
        require(_fee <= WITHDRAWAL_FEE_CAP, "StrategyCeManager: MAX_WITHDRAWAL_FEE");
        withdrawalFee = _fee;
        emit SetWithdrawalFee(_fee);
    }

    // set new vault (only for strategy upgrades)
    function setVault(address _vault) external onlyOwner {
        vault = _vault;
        emit SetVault(_vault);
    }

    // set new uniRouter
    function setUniRouter(address _uniRouter) external onlyOwner {
        uniRouter = _uniRouter;
        emit SetUniRouter(_uniRouter);
    }

    // set new keeper to manage strat
    function setKeeper(address _keeper) external onlyManager {
        keeper = _keeper;
        emit SetKeeper(_keeper);
    }

    // set new strategist address to receive strat fees
    function setStrategist(address _strategist) external {
        require(msg.sender == strategist, "StrategyCeManager: STRATEGIST_ONLY");
        strategist = _strategist;
        emit SetStrategist(_strategist);
    }

    // set new co fee address to receive co fees
    function setCoFeeRecipient(address _coFeeRecipient) external onlyOwner {
        coFeeRecipient = _coFeeRecipient;
        emit SetCoFeeRecipient(_coFeeRecipient);
    }

    // set new fee config address to fetch fees
    function setCoFeeConfig(address _coFeeConfig) external onlyOwner {
        coFeeConfig = IFeeConfig(_coFeeConfig);
        emit SetCoFeeConfig(_coFeeConfig);
    }

    function beforeDeposit() external virtual {}
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../interfaces/IRewardPool.sol";
import "./StrategyCeManager.sol";

contract StrategyCeVeloRewardPool is StrategyCeManager {
    using SafeERC20 for IERC20;

    // Tokens used
    address public want;

    // Third party contracts
    address public rewardPool;

    bool public harvestOnDeposit;
    uint256 public lastHarvest;

    event StratHarvest(address indexed harvester, uint256 wantHarvested, uint256 tvl);
    event Deposit(uint256 tvl);
    event Withdraw(uint256 tvl);
    event ChargedFees(uint256 callFees, uint256 coFees, uint256 strategistFees);

    constructor(
        address _want,
        address _rewardPool,
        CommonAddresses memory _commonAddresses
    ) StrategyCeManager(_commonAddresses) {
        want = _want;
        rewardPool = _rewardPool;
    }

    // puts the funds to work
    function deposit() public whenNotPaused {
        uint256 wantBal = balanceOfWant();

        if (wantBal > 0) {
            IRewardPool(rewardPool).stake(wantBal - balanceOfPool());
            emit Deposit(balanceOf());
        }
    }

    function withdraw(uint256 _amount) external {
        require(msg.sender == vault, "Strategy: VAULT_ONLY");

        if (balanceOfPool() > 0) {
            IRewardPool(rewardPool).withdraw(_amount);
        }

        if (tx.origin != owner() && !paused()) {
            uint256 withdrawalFeeAmount = _amount * withdrawalFee / WITHDRAWAL_MAX;
            _amount = _amount - withdrawalFeeAmount;
        }

        IERC20(want).safeTransfer(vault, _amount);

        emit Withdraw(balanceOf());
    }

    function beforeDeposit() external override {
        if (harvestOnDeposit) {
            require(msg.sender == vault, "Strategy: VAULT_ONLY");
            _harvest();
        }
    }

    function harvest() external virtual {
        _harvest();
    }

    // compounds earnings and charges performance fee
    function _harvest() internal whenNotPaused {
        uint256 before = balanceOfWant();
        IRewardPool(rewardPool).getReward();
        uint256 rewardBal = balanceOfWant() - before;
        if (rewardBal > 0) {
            deposit();

            lastHarvest = block.timestamp;
            emit StratHarvest(msg.sender, rewardBal, balanceOf());
            emit ChargedFees(0,0,0);
        }
    }

    // calculate the total underlying 'want' held by the strat.
    function balanceOf() public view returns (uint256) {
        return balanceOfWant();
    }

    // it calculates how much 'want' this contract holds.
    function balanceOfWant() public view returns (uint256) {
        return IERC20(want).balanceOf(address(this));
    }

    // it calculates how much 'want' the strategy has working in the farm.
    function balanceOfPool() public view returns (uint256) {
        return IRewardPool(rewardPool).balanceOf(address(this));
    }

    // returns rewards unharvested
    function rewardsAvailable() public view returns (uint256) {
        return IRewardPool(rewardPool).earned(address(this));
    }

    function setHarvestOnDeposit(bool _harvestOnDeposit) external onlyManager {
        harvestOnDeposit = _harvestOnDeposit;
        if (harvestOnDeposit == true) {
            setWithdrawalFee(0);
        } else {
            setWithdrawalFee(10);
        }
    }

    // called as part of strat migration. Sends all the available funds back to the vault.
    function retireStrat() external {
        require(msg.sender == vault, "Strategy: VAULT_ONLY");

        IRewardPool(rewardPool).withdraw(balanceOfPool());

        uint256 wantBal = balanceOfWant();
        IERC20(want).transfer(vault, wantBal);
    }

    // pauses deposits and withdraws all funds from third party systems.
    function panic() public onlyManager {
        pause();
        IRewardPool(rewardPool).withdraw(balanceOfPool());
    }

    function pause() public onlyManager {
        _pause();
    }

    function unpause() external onlyManager {
        _unpause();

        deposit();
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./CeSolidStaker.sol";
import "../interfaces/IRewardPool.sol";
import "../interfaces/IWrappedBribeFactory.sol";
import "../interfaces/ISolidlyRouter.sol";
import "../interfaces/IFeeConfig.sol";
import "../interfaces/ISolidlyGauge.sol";

contract VeloStaker is ERC20, CeSolidStaker {
    using SafeERC20 for IERC20;

    // Needed addresses
    IRewardPool public ceVeloRewardPool;
    IWrappedBribeFactory public bribeFactory = IWrappedBribeFactory(0x7955519E14fdF498E28831F4cC06af4B8e3086A8);
    address[] public activeVoteLps;
    ISolidlyRouter public router;
    address public coFeeRecipient;
    IFeeConfig public coFeeConfig;
    address public native;

    // Voted Gauges
    struct Gauges {
        address bribeGauge;
        address feeGauge;
        address[] bribeTokens;
        address[] feeTokens;
    }

    // Mapping our reward token to a route 
    ISolidlyRouter.Routes[] public veloToNativeRoute;
    mapping (address => ISolidlyRouter.Routes[]) public routes;
    mapping (address => bool) public lpInitialized;
    mapping (address => Gauges) public gauges;

    // Events
    event SetCeVeloRewardPool(address oldPool, address newPool);
    event SetRouter(address oldRouter, address newRouter);
    event SetBribeFactory(address oldFactory, address newFactory);
    event SetFeeRecipient(address oldRecipient, address newRecipient);
    event SetFeeId(uint256 id);
    event AddedGauge(address bribeGauge, address feeGauge, address[] bribeTokens, address[] feeTokens);
    event AddedRewardToken(address token);
    event RewardsHarvested(uint256 amount);
    event Voted(address[] votes, uint256[] weights);
    event ChargedFees(uint256 callFees, uint256 coFees, uint256 strategistFees);
    
    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _reserveRate,
        address _solidVoter,
        address _keeper,
        address _voter,
        address _ceVeloRewardPool,
        address _coFeeRecipient,
        address _coFeeConfig,
        address _router,
        ISolidlyRouter.Routes[] memory _veloToNativeRoute
    ) CeSolidStaker(
        _name,
        _symbol,
        _reserveRate,
        _solidVoter,
        _keeper,
        _voter
    ) {
        ceVeloRewardPool = IRewardPool(_ceVeloRewardPool);
        router = ISolidlyRouter(_router);
        coFeeRecipient = _coFeeRecipient;
        coFeeConfig = IFeeConfig(_coFeeConfig);

        native = _veloToNativeRoute[_veloToNativeRoute.length - 1].to; 
        for (uint i; i < _veloToNativeRoute.length;) {
            veloToNativeRoute.push(_veloToNativeRoute[i]);
            unchecked { ++i; }
        }
    }

    // Vote information 
    function voteInfo() external view returns (address[] memory lpsVoted, uint256[] memory votes, uint256 lastVoted) {
        uint256 len = activeVoteLps.length;
        lpsVoted = new address[](len);
        votes = new uint256[](len);
        for (uint i; i < len;) {
            lpsVoted[i] = solidVoter.poolVote(tokenId, i);
            votes[i] = solidVoter.votes(tokenId, lpsVoted[i]);
            unchecked { ++i; }
        }
        lastVoted = solidVoter.lastVoted(tokenId);
    }

    // Claim veToken emissions and increases locked amount in veToken
    function claimVeEmissions() public override {
        uint256 _amount = veDist.claim(tokenId);
        uint256 gap = totalWant() - totalSupply();
        if (gap > 0) {
            _mint(address(ceVeloRewardPool), gap);
            ceVeloRewardPool.notifyRewardAmount();
        }
        emit ClaimVeEmissions(msg.sender, tokenId, _amount);
    }

    // vote for emission weights
    function vote(address[] calldata _tokenVote, uint256[] calldata _weights, bool _withHarvest) external onlyVoter {
        // Check to make sure we set up our rewards
        for (uint i; i < _tokenVote.length;) {
            require(lpInitialized[_tokenVote[i]], "lp not lpInitialized");
            unchecked { ++i; }
        }

        if (_withHarvest) {
            harvest();
        }

        activeVoteLps = _tokenVote;
        // We claim first to maximize our voting power.
        claimVeEmissions();
        solidVoter.vote(tokenId, _tokenVote, _weights);
        emit Voted(_tokenVote, _weights);
    }

    // Add gauge
    function addGauge(address _lp, address[] calldata _bribeTokens, address[] calldata _feeTokens) external onlyManager {
        address gauge = solidVoter.gauges(_lp);
        gauges[_lp] = Gauges(
            bribeFactory.oldBribeToNew(solidVoter.external_bribes(gauge)),
            solidVoter.internal_bribes(gauge),
            _bribeTokens,
            _feeTokens
        );
        lpInitialized[_lp] = true;
        emit AddedGauge(solidVoter.external_bribes(_lp), solidVoter.internal_bribes(_lp), _bribeTokens, _feeTokens);
    }

    // Delete a reward token 
    function deleteRewardToken(address _token) external onlyManager {
        delete routes[_token];
    }

    // Add multiple reward tokens
    function addMultipleRewardTokens(ISolidlyRouter.Routes[][] calldata _routes) external onlyManager {
        for (uint i; i < _routes.length;) {
            addRewardToken(_routes[i]);
            unchecked { ++i; }
        }
    }

     // Add a reward token
    function addRewardToken(ISolidlyRouter.Routes[] calldata _route) public onlyManager {
        require(_route[0].from != address(want), "from cant be want");
        require(_route[_route.length - 1].to == address(want), "to has to be want");
        for (uint i; i < _route.length;) {
            routes[_route[0].from].push(_route[i]);
            unchecked { ++i; }
        }
        
        IERC20(_route[0].from).safeApprove(address(router), 0);
        IERC20(_route[0].from).safeApprove(address(router), type(uint256).max);
        emit AddedRewardToken(_route[0].from);
    }

    function getRewards(address _gauge, address[] calldata _tokens, ISolidlyRouter.Routes[][] calldata _routes) external nonReentrant onlyManager {
        uint256 before = balanceOfWant();
        ISolidlyGauge(_gauge).getReward(tokenId, _tokens);
        for (uint i; i < _routes.length;) {
            require(_routes[i][_routes[i].length - 1].to == address(want), "to != Want");
            require(_routes[i][0].from != address(want), "Can't sell Want");
            uint256 tokenBal = IERC20(_routes[i][0].from).balanceOf(address(this));
            if (tokenBal > 0) {
                IERC20(_routes[i][0].from).safeApprove(address(router), 0);
                IERC20(_routes[i][0].from).safeApprove(address(router), type(uint256).max);
                router.swapExactTokensForTokens(tokenBal, 0, _routes[i], address(this), block.timestamp);
            }
            unchecked { ++i; }
        }

        uint256 rewardBal = balanceOfWant() - before;

        _chargeFeesAndMint(rewardBal);
    }   

    // claim owner rewards such as trading fees and bribes from gauges swap to velo, notify reward pool
    function harvest() public {
        uint256 before = balanceOfWant();
        for (uint i; i < activeVoteLps.length;) {
            Gauges memory rewardsGauge = gauges[activeVoteLps[i]];
            ISolidlyGauge(rewardsGauge.bribeGauge).getReward(tokenId, rewardsGauge.bribeTokens);
            ISolidlyGauge(rewardsGauge.feeGauge).getReward(tokenId, rewardsGauge.feeTokens);
            
            for (uint j; j < rewardsGauge.bribeTokens.length;) {
                uint256 tokenBal = IERC20(rewardsGauge.bribeTokens[j]).balanceOf(address(this));
                if (tokenBal > 0 && rewardsGauge.bribeTokens[j] != address(want)) {
                    router.swapExactTokensForTokens(tokenBal, 0, routes[rewardsGauge.bribeTokens[j]], address(this), block.timestamp);
                }
                unchecked { ++j; }
            }

            for (uint k; k < rewardsGauge.feeTokens.length;) {
                uint256 tokenBal = IERC20(rewardsGauge.feeTokens[k]).balanceOf(address(this));
                if (tokenBal > 0 && rewardsGauge.feeTokens[k] != address(want)) {
                    router.swapExactTokensForTokens(tokenBal, 0, routes[rewardsGauge.feeTokens[k]], address(this), block.timestamp);
                }
                unchecked { ++k; }
            }
            unchecked { ++i; }
        }

        uint256 rewardBal = balanceOfWant() - before;
    
        _chargeFeesAndMint(rewardBal);
    }

    function _chargeFeesAndMint(uint256 _rewardBal) internal {
        // Charge our fees here since we send CeVelo to reward pool
        IFeeConfig.FeeCategory memory fees = coFeeConfig.getFees(address(this));
        uint256 feeBal = _rewardBal * fees.total / 1e18;
        if (feeBal > 0) {
            IERC20(want).safeApprove(address(router), feeBal);
            uint256[] memory amounts = router.swapExactTokensForTokens(feeBal, 0, veloToNativeRoute, address(coFeeRecipient), block.timestamp);
            IERC20(want).safeApprove(address(router), 0);
            emit ChargedFees(0, amounts[amounts.length - 1], 0);
        }

        uint256 gap = totalWant() - totalSupply();
        if (gap > 0) {
            _mint(address(ceVeloRewardPool), gap);
            ceVeloRewardPool.notifyRewardAmount();
            emit RewardsHarvested(gap);
        }
    }

    // Set our reward Pool to send our earned CeVelo
    function setCeVeloRewardPool(address _rewardPool) external onlyOwner {
        emit SetCeVeloRewardPool(address(ceVeloRewardPool), _rewardPool);
        ceVeloRewardPool = IRewardPool(_rewardPool);
    }

    // Set the wrapped bribe factory
    function setBribeFactory(address _bribeFactory) external onlyOwner {
        emit SetBribeFactory(address(bribeFactory), _bribeFactory);
        bribeFactory = IWrappedBribeFactory(_bribeFactory);
    }

    // Set fee id on fee config
    function setFeeId(uint256 id) external onlyManager {
        emit SetFeeId(id);
        coFeeConfig.setStratFeeId(id);
    }

    // Set fee recipient
    function setCoFeeRecipient(address _feeRecipient) external onlyOwner {
        emit SetFeeRecipient(address(coFeeRecipient), _feeRecipient);
        coFeeRecipient = _feeRecipient;
    }

    // Set our router to exchange our rewards, also update new veloToNative route. 
    function setRouterAndRoute(address _router, ISolidlyRouter.Routes[] calldata _route) external onlyOwner {
        emit SetRouter(address(router), _router);
        for (uint i; i < _route.length;) {
            veloToNativeRoute.push(_route[i]);
            unchecked { ++i; }
        }
        router = ISolidlyRouter(_router);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../lib/Math.sol";

contract ChamTHERewardPool is Ownable {
    using SafeERC20 for IERC20;

    IERC20 public token;
    uint256 public duration;

    uint256 private _totalSupply;
    uint256 public periodFinish;
    uint256 public rewardRate;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    uint256 public rewardBalance;
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;
    mapping(address => uint256) private _balances;
    mapping(address => bool) public whitelist;

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event AddedWhiteList(address strategy);
    event RemovedWhitelist(address strategy);

    constructor(address _token, uint256 _duration) {
        token = IERC20(_token);
        duration = _duration;
    }

    modifier onlyWhitelist(address account) {
        require(whitelist[account] == true, "RewardPool: WHITE_LIST_ONLY");
        _;
    }

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return Math.min(block.timestamp, periodFinish);
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalSupply() == 0) return rewardPerTokenStored;
        uint256 offsetTime = lastTimeRewardApplicable() - lastUpdateTime;
        uint256 offsetReward = offsetTime * rewardRate * 1e18;
        return rewardPerTokenStored + (offsetReward / totalSupply());
    }

    function earned(address account) public view returns (uint256) {
        return
            rewards[account] +
            (balanceOf(account) *
                (rewardPerToken() - userRewardPerTokenPaid[account])) /
            1e18;
    }

    function stake(
        uint256 amount
    ) public updateReward(msg.sender) onlyWhitelist(msg.sender) {
        require(amount > 0, "RewardPool: ZERO_AMOUNT");
        _totalSupply += amount;
        _balances[msg.sender] += amount;
        emit Staked(msg.sender, amount);
    }

    function withdraw(
        uint256 amount
    ) public updateReward(msg.sender) onlyWhitelist(msg.sender) {
        require(amount > 0, "RewardPool: ZERO_AMOUNT");
        _totalSupply -= amount;
        _balances[msg.sender] -= amount;
        emit Withdrawn(msg.sender, amount);
    }

    function getReward() public updateReward(msg.sender) {
        address sender = msg.sender;
        uint256 reward = earned(sender);
        if (reward > 0) {
            if (reward > rewardBalance) {
                reward = rewardBalance;
            }
            rewardBalance -= reward;
            rewards[sender] = 0;
            token.safeTransfer(sender, reward);
            emit RewardPaid(sender, reward);
        }
    }

    // Add depositing strategy to whitelist
    function addWhitelist(address _strategy) external onlyOwner {
        whitelist[_strategy] = true;
        emit AddedWhiteList(_strategy);
    }

    // remove depositing strategy from whitelist
    function removeWhitelist(address _strategy) external onlyOwner {
        whitelist[_strategy] = false;
        emit RemovedWhitelist(_strategy);
    }

    function notifyRewardAmount() external updateReward(address(0)) {
        uint256 timestamp = block.timestamp;
        uint256 balance = token.balanceOf(address(this));
        uint256 newRewards = balance - rewardBalance;
        if (newRewards > 0) {
            if (timestamp >= periodFinish) {
                rewardRate = newRewards / duration;
            } else {
                uint256 leftover = (periodFinish - timestamp) * rewardRate;
                rewardRate = (newRewards + leftover) / duration;
            }
            rewardBalance += newRewards;
            lastUpdateTime = timestamp;
            periodFinish = timestamp + duration;
            emit RewardAdded(newRewards);
        }
    }

    function inCaseTokensGetStuck(address _token) external onlyOwner {
        if (totalSupply() != 0) {
            require(_token != address(token), "RewardPool: STUCK_TOKEN_ONLY");
        }
        uint256 amount = IERC20(_token).balanceOf(address(this));
        IERC20(_token).safeTransfer(msg.sender, amount);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ChamTHESolidManager is Ownable, Pausable {
    using SafeERC20 for IERC20;

    /**
     * @dev Peanutfi Contracts:
     * {keeper} - Address to manage a few lower risk features of the strat..
     */
    address public keeper;
    address public voter;
    address public taxWallet;

    event NewKeeper(address oldKeeper, address newKeeper);
    event NewVoter(address oldVoter, address newVoter);
    event NewTaxWallet(address oldTaxWallet, address newTaxWallet);

    /**
     * @dev Initializes the base strategy.
     * @param _keeper address to use as alternative owner.
     */
    constructor(
        address _keeper,
        address _voter,
        address _taxWallet
    ) {
        keeper = _keeper;
        voter = _voter;
        taxWallet = _taxWallet;
    }

    // Checks that caller is either owner or keeper.
    modifier onlyManager() {
        require(msg.sender == owner() || msg.sender == keeper, "ChamTHESolidManager: MANAGER_ONLY");
        _;
    }

    // Checks that caller is either owner or keeper.
    modifier onlyVoter() {
        require(msg.sender == voter, "ChamTHESolidManager: VOTER_ONLY");
        _;
    }

    /**
     * @dev Updates address of the strat keeper.
     * @param _keeper new keeper address.
     */
    function setKeeper(address _keeper) external onlyManager {
        emit NewKeeper( keeper, _keeper);
        keeper = _keeper;
    }

    function setVoter(address _voter) external onlyManager {
        emit NewVoter(voter, _voter);
        voter = _voter;
    }

    function setTaxWallet(address _taxWallet) external onlyManager {
        emit NewTaxWallet(taxWallet, _taxWallet);
        taxWallet = _taxWallet;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./ChamTHESolidManager.sol";
import "../interfaces/IVoter.sol";
import "../interfaces/IVeToken.sol";
import "../interfaces/IVeDist.sol";
import "../interfaces/IMinter.sol";

contract ChamTHESolidStaker is ERC20, ChamTHESolidManager, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // Addresses used
    IVoter public solidVoter;
    IVeToken public ve;
    IVeDist public veDist;

    // Want token and our NFT Token ID
    IERC20 public want;
    uint256 public tokenId;

    // Max Lock time, Max variable used for reserve split and the reserve rate.
    uint16 public constant MAX = 10000;
    // Vote weight decays linearly over time. Lock time cannot be more than `MAX_LOCK` (2 years).
    uint256 public constant MAX_LOCK = 365 days * 2;
    uint256 public reserveRate;
    bool public isAutoIncreaseLock = true;

    bool public enabledPenaltyFee = false;
    uint256 public maxBurnRate = 50; // 0.5%
    uint256 public maxPegReserve = 0.9e18;

    // Our on chain events.
    event CreateLock(
        address indexed user,
        uint256 veTokenId,
        uint256 amount,
        uint256 unlockTime
    );
    event Release(address indexed user, uint256 veTokenId, uint256 amount);
    event AutoIncreaseLock(bool _enabled);
    event EnabledPenaltyFee(bool _enabled);
    event IncreaseTime(
        address indexed user,
        uint256 veTokenId,
        uint256 unlockTime
    );
    event DepositWant(uint256 amount);
    event Withdraw(uint256 amount);
    event ClaimVeEmissions(
        address indexed user,
        uint256 veTokenId,
        uint256 amount
    );
    event UpdatedReserveRate(uint256 newRate);
    event SetMaxBurnRate(uint256 oldRate, uint256 newRate);
    event SetMaxPegReserve(uint256 oldValue, uint256 newValue);

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _reserveRate,
        address _solidVoter,
        address _keeper,
        address _voter,
        address _taxWallet
    ) ERC20(_name, _symbol) ChamTHESolidManager(_keeper, _voter, _taxWallet) {
        reserveRate = _reserveRate;
        solidVoter = IVoter(_solidVoter);
        ve = IVeToken(solidVoter._ve());
        want = IERC20(ve.token());
        IMinter _minter = IMinter(solidVoter.minter());
        veDist = IVeDist(_minter._rewards_distributor());
        want.safeApprove(address(ve), type(uint256).max);
    }

    // Deposit all want for a user.
    function depositAll() external {
        _deposit(want.balanceOf(msg.sender));
    }

    // Deposit an amount of want.
    function deposit(uint256 _amount) external {
        _deposit(_amount);
    }

    // Internal: Deposits Want and mint CeWant, checks for ve increase opportunities first.
    function _deposit(uint256 _amount) internal nonReentrant whenNotPaused {
        lock();
        uint256 _balanceBefore = balanceOfWant();
        want.safeTransferFrom(msg.sender, address(this), _amount);
        _amount = balanceOfWant() - _balanceBefore; // Additional check for deflationary tokens.

        if (_amount > 0) {
            _mint(msg.sender, _amount);
            emit DepositWant(totalWant());
        }
    }

    // Deposit more in ve and up lock_time.
    function lock() public {
        if (totalWant() > 0) {
            (, , bool shouldIncreaseLock) = lockInfo();
            if (balanceOfWant() > requiredReserve()) {
                uint256 availableBalance = balanceOfWant() - requiredReserve();
                ve.increase_amount(tokenId, availableBalance);
            }
            // Extend max lock
            if (shouldIncreaseLock) ve.increase_unlock_time(tokenId, MAX_LOCK);
        }
    }

    // Withdraw capable if we have enough Want in the contract.
    function withdraw(uint256 _amount) external {
        require(
            _amount <= withdrawableBalance(),
            "ChamTHEStaker: INSUFFICIENCY_AMOUNT_OUT"
        );

        _burn(msg.sender, _amount);
        if (enabledPenaltyFee) {
            uint256 maxAmountBurning = ((totalSupply() + _amount) *
                maxBurnRate) / MAX;
            require(
                _amount <= maxAmountBurning,
                "ChamTHEStaker: Over max burning amount"
            );

            uint256 penaltyAmount = calculatePenaltyFee(_amount);
            if (penaltyAmount > 0) {
                _amount = _amount - penaltyAmount;

                // tax
                uint256 taxAmount = penaltyAmount / 2;
                if (taxAmount > 0) _mint(taxWallet, taxAmount);

                // transfer into a dead address
                uint256 burnAmount = penaltyAmount - taxAmount;
                if (burnAmount > 0) _mint(0x000000000000000000000000000000000000dEaD, burnAmount);
            }
        }

        want.safeTransfer(msg.sender, _amount);
        emit Withdraw(totalWant());
    }

    // Total Want in ve contract and CeVe contract.
    function totalWant() public view returns (uint256) {
        return balanceOfWant() + balanceOfWantInVe();
    }

    // Our required Want held in the contract to enable withdraw capabilities.
    function requiredReserve() public view returns (uint256 reqReserve) {
        // We calculate allocation for reserve of the total staked in Ve.
        reqReserve = (balanceOfWantInVe() * reserveRate) / MAX;
    }

    // Calculate how much 'want' is held by this contract
    function balanceOfWant() public view returns (uint256) {
        return want.balanceOf(address(this));
    }

    // What is our end lock and seconds remaining in lock?
    function lockInfo()
        public
        view
        returns (
            uint256 endTime,
            uint256 secondsRemaining,
            bool shouldIncreaseLock
        )
    {
        (, endTime) = ve.locked(tokenId);
        uint256 unlockTime = ((block.timestamp + MAX_LOCK) / 1 weeks) * 1 weeks;
        secondsRemaining = endTime > block.timestamp
            ? endTime - block.timestamp
            : 0;
        shouldIncreaseLock = isAutoIncreaseLock && unlockTime > endTime;
    }

    // Withdrawable Balance for users
    function withdrawableBalance() public view returns (uint256) {
        return balanceOfWant();
    }

    // How many want we got earning?
    function balanceOfWantInVe() public view returns (uint256 wants) {
        (wants, ) = ve.locked(tokenId);
    }

    // Claim veToken emissions and increases locked amount in veToken
    function claimVeEmissions() public virtual {
        uint256 _amount = veDist.claim(tokenId);
        emit ClaimVeEmissions(msg.sender, tokenId, _amount);
    }

    // Reset current votes
    function resetVote() external onlyVoter {
        solidVoter.reset(tokenId);
    }

    // Create a new veToken if none is assigned to this address
    function createLock(
        uint256 _amount,
        uint256 _lock_duration
    ) external onlyManager {
        require(tokenId == 0, "ChamTHEStaker: ASSIGNED");
        require(_amount > 0, "ChamTHEStaker: ZERO_AMOUNT");

        want.safeTransferFrom(address(msg.sender), address(this), _amount);
        tokenId = ve.create_lock(_amount, _lock_duration);
        _mint(msg.sender, _amount);

        emit CreateLock(msg.sender, tokenId, _amount, _lock_duration);
    }

    // Release expired lock of a veToken owned by this address
    function release() external onlyOwner {
        (uint endTime, , ) = lockInfo();
        require(endTime <= block.timestamp, "ChamTHEStaker: LOCKED");
        ve.withdraw(tokenId);

        emit Release(msg.sender, tokenId, balanceOfWant());
    }

    // Whitelist new token
    function whitelist(address _token) external onlyManager {
        solidVoter.whitelist(_token, tokenId);
    }

    // Adjust reserve rate
    function adjustReserve(uint256 _rate) external onlyOwner {
        // validation from 15-50%
        require(
            _rate >= 1500 && _rate <= 5000,
            "ChamTHEStaker: RATE_OUT_OF_RANGE"
        );
        reserveRate = _rate;
        emit UpdatedReserveRate(_rate);
    }

    // Enable/Disable Penalty Fee
    function setEnabledPenaltyFee(bool _enabled) external onlyOwner {
        enabledPenaltyFee = _enabled;
        emit EnabledPenaltyFee(_enabled);
    }

    // Enable/Disable auto increase lock
    function setAutoIncreaseLock(bool _enabled) external onlyOwner {
        isAutoIncreaseLock = _enabled;
        emit AutoIncreaseLock(_enabled);
    }

    function setMaxBurnRate(uint256 _rate) external onlyOwner {
        // validation from 0.5-100%
        require(
            _rate >= 50 && _rate <= MAX,
            "ChamTHEStaker: RATE_OUT_OF_RANGE"
        );
        emit SetMaxBurnRate(maxBurnRate, _rate);
        maxBurnRate = _rate;
    }

    function setMaxPegReserve(uint256 _value) external onlyOwner {
        // validation from 0.8-1
        require(
            _value >= 0.8e18 && _value <= 1e18,
            "ChamTHEStaker: VALUE_OUT_OF_RANGE"
        );
        emit SetMaxPegReserve(maxPegReserve, _value);
        maxPegReserve = _value;
    }

    // Pause deposits
    function pause() public onlyManager {
        _pause();
        want.safeApprove(address(ve), 0);
    }

    // Unpause deposits
    function unpause() external onlyManager {
        _unpause();
        want.safeApprove(address(ve), type(uint256).max);
    }

    // Confirmation required for receiving veToken to smart contract
    function onERC721Received(
        address operator,
        address from,
        uint _tokenId,
        bytes calldata data
    ) external view returns (bytes4) {
        operator;
        from;
        _tokenId;
        data;
        require(msg.sender == address(ve), "ChamTHEStaker: VE_ONLY");
        return
            bytes4(keccak256("onERC721Received(address,address,uint,bytes)"));
    }

    function calculatePenaltyFee(
        uint256 _amount
    ) public view returns (uint256) {
        uint256 pegReserve = (balanceOfWant() * 1e18) / requiredReserve();
        uint256 penaltyAmount = 0;
        if (pegReserve < maxPegReserve) {
            // penaltyRate = 0.5 x (1 - pegReserve) * 100%
            penaltyAmount = (_amount * (1e18 - pegReserve)) / (2 * 1e18 * 100);
        }
        return penaltyAmount;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../interfaces/IRewardPool.sol";
import "../vault-ce/StrategyCeManager.sol";

contract StrategyChamTHERewardPool is StrategyCeManager {
    using SafeERC20 for IERC20;

    // Tokens used
    address public want;

    // Third party contracts
    address public rewardPool;

    bool public harvestOnDeposit;
    uint256 public lastHarvest;

    event StratHarvest(address indexed harvester, uint256 wantHarvested, uint256 tvl);
    event Deposit(uint256 tvl);
    event Withdraw(uint256 tvl);
    event ChargedFees(uint256 callFees, uint256 coFees, uint256 strategistFees);

    constructor(
        address _want,
        address _rewardPool,
        CommonAddresses memory _commonAddresses
    ) StrategyCeManager(_commonAddresses) {
        want = _want;
        rewardPool = _rewardPool;
    }

    // puts the funds to work
    function deposit() public whenNotPaused {
        uint256 wantBal = balanceOfWant();

        if (wantBal > 0) {
            IRewardPool(rewardPool).stake(wantBal - balanceOfPool());
            emit Deposit(balanceOf());
        }
    }

    function withdraw(uint256 _amount) external {
        require(msg.sender == vault, "Strategy: VAULT_ONLY");

        if (balanceOfPool() > 0) {
            IRewardPool(rewardPool).withdraw(_amount);
        }

        if (tx.origin != owner() && !paused()) {
            uint256 withdrawalFeeAmount = _amount * withdrawalFee / WITHDRAWAL_MAX;
            _amount = _amount - withdrawalFeeAmount;
        }

        IERC20(want).safeTransfer(vault, _amount);

        emit Withdraw(balanceOf());
    }

    function beforeDeposit() external override {
        if (harvestOnDeposit) {
            require(msg.sender == vault, "Strategy: VAULT_ONLY");
            _harvest();
        }
    }

    function harvest() external virtual {
        _harvest();
    }

    // compounds earnings and charges performance fee
    function _harvest() internal whenNotPaused {
        uint256 before = balanceOfWant();
        IRewardPool(rewardPool).getReward();
        uint256 rewardBal = balanceOfWant() - before;
        if (rewardBal > 0) {
            deposit();

            lastHarvest = block.timestamp;
            emit StratHarvest(msg.sender, rewardBal, balanceOf());
            emit ChargedFees(0,0,0);
        }
    }

    // calculate the total underlying 'want' held by the strat.
    function balanceOf() public view returns (uint256) {
        return balanceOfWant();
    }

    // it calculates how much 'want' this contract holds.
    function balanceOfWant() public view returns (uint256) {
        return IERC20(want).balanceOf(address(this));
    }

    // it calculates how much 'want' the strategy has working in the farm.
    function balanceOfPool() public view returns (uint256) {
        return IRewardPool(rewardPool).balanceOf(address(this));
    }

    // returns rewards unharvested
    function rewardsAvailable() public view returns (uint256) {
        return IRewardPool(rewardPool).earned(address(this));
    }

    function setHarvestOnDeposit(bool _harvestOnDeposit) external onlyManager {
        harvestOnDeposit = _harvestOnDeposit;
        if (harvestOnDeposit == true) {
            setWithdrawalFee(0);
        } else {
            setWithdrawalFee(10);
        }
    }

    // called as part of strat migration. Sends all the available funds back to the vault.
    function retireStrat() external {
        require(msg.sender == vault, "Strategy: VAULT_ONLY");

        IRewardPool(rewardPool).withdraw(balanceOfPool());

        uint256 wantBal = balanceOfWant();
        IERC20(want).transfer(vault, wantBal);
    }

    // pauses deposits and withdraws all funds from third party systems.
    function panic() public onlyManager {
        pause();
        IRewardPool(rewardPool).withdraw(balanceOfPool());
    }

    function pause() public onlyManager {
        _pause();
    }

    function unpause() external onlyManager {
        _unpause();

        deposit();
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./ChamTHESolidStaker.sol";
import "../interfaces/IRewardPool.sol";
import "../interfaces/IWrappedBribeFactory.sol";
import "../interfaces/ISolidlyRouter.sol";
import "../interfaces/IFeeConfig.sol";
import "../interfaces/ISolidlyGauge.sol";

contract ThenaStaker is ERC20, ChamTHESolidStaker {
    using SafeERC20 for IERC20;

    // Needed addresses
    IRewardPool public chamTHERewardPool;
    address[] public activeVoteLps;
    ISolidlyRouter public router;
    address public coFeeRecipient;
    IFeeConfig public coFeeConfig;
    address public native;

    // Voted Gauges
    struct Gauges {
        address bribeGauge;
        address feeGauge;
        address[] bribeTokens;
        address[] feeTokens;
    }

    // Mapping our `reward token` to `want token` in routes for Router
    ISolidlyRouter.Routes[] public thenaToNativeRoute;
    mapping(address => ISolidlyRouter.Routes[]) public routes;
    mapping(address => bool) public lpInitialized;
    mapping(address => Gauges) public gauges;

    // Events
    event SetChamTHERewardPool(address oldPool, address newPool);
    event SetRouter(address oldRouter, address newRouter);
    event SetBribeFactory(address oldFactory, address newFactory);
    event SetFeeRecipient(address oldRecipient, address newRecipient);
    event SetFeeId(uint256 id);
    event AddedGauge(
        address gauge,
        address feeGauge,
        address[] bribeTokens,
        address[] feeTokens
    );
    event AddedRewardToken(address token);
    event RewardsHarvested(uint256 amount);
    event Voted(address[] votes, uint256[] weights);
    event ChargedFees(uint256 callFees, uint256 coFees, uint256 strategistFees);

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _reserveRate,
        address _solidVoter,
        address[] memory _manager,
        address _chamTHERewardPool,
        address _coFeeRecipient,
        address _coFeeConfig,
        address _router,
        ISolidlyRouter.Routes[] memory _thenaToNativeRoute
    )
        ChamTHESolidStaker(
            _name,
            _symbol,
            _reserveRate,
            _solidVoter,
            _manager[0],
            _manager[1],
            _manager[2]
        )
    {
        chamTHERewardPool = IRewardPool(_chamTHERewardPool);
        router = ISolidlyRouter(_router);
        coFeeRecipient = _coFeeRecipient;
        coFeeConfig = IFeeConfig(_coFeeConfig);

        native = _thenaToNativeRoute[_thenaToNativeRoute.length - 1].to;
        for (uint i; i < _thenaToNativeRoute.length; i++) {
            thenaToNativeRoute.push(_thenaToNativeRoute[i]);
        }
    }

    // Vote information
    function voteInfo()
        external
        view
        returns (
            address[] memory lpsVoted,
            uint256[] memory votes,
            uint256 lastVoted
        )
    {
        uint256 len = activeVoteLps.length;
        lpsVoted = new address[](len);
        votes = new uint256[](len);
        for (uint i; i < len; i++) {
            lpsVoted[i] = solidVoter.poolVote(tokenId, i);
            votes[i] = solidVoter.votes(tokenId, lpsVoted[i]);
        }
        lastVoted = solidVoter.lastVoted(tokenId);
    }

    // Claim veToken emissions and increases locked amount in veToken
    function claimVeEmissions() public override {
        uint256 _amount = veDist.claim(tokenId);
        uint256 gap = totalWant() - totalSupply();
        if (gap > 0) {
            _mint(address(chamTHERewardPool), gap);
            chamTHERewardPool.notifyRewardAmount();
        }
        emit ClaimVeEmissions(msg.sender, tokenId, _amount);
    }

    // vote for emission weights
    function vote(
        address[] calldata _tokenVote,
        uint256[] calldata _weights,
        bool _withHarvest
    ) external onlyVoter {
        // Check to make sure we set up our rewards
        for (uint i; i < _tokenVote.length; i++) {
            require(lpInitialized[_tokenVote[i]], "Staker: TOKEN_VOTE_INVALID");
        }

        if (_withHarvest) harvest();

        activeVoteLps = _tokenVote;
        // We claim first to maximize our voting power.
        claimVeEmissions();
        solidVoter.vote(tokenId, _tokenVote, _weights);
        emit Voted(_tokenVote, _weights);
    }

    // Add gauge
    function addGauge(
        address _lp,
        address[] calldata _bribeTokens,
        address[] calldata _feeTokens
    ) external onlyManager {
        address gauge = solidVoter.gauges(_lp);
        gauges[_lp] = Gauges(
            solidVoter.external_bribes(gauge),
            solidVoter.internal_bribes(gauge),
            _bribeTokens,
            _feeTokens
        );
        lpInitialized[_lp] = true;
        emit AddedGauge(
            solidVoter.external_bribes(_lp),
            solidVoter.internal_bribes(_lp),
            _bribeTokens,
            _feeTokens
        );
    }

    // Delete a reward token
    function deleteRewardToken(address _token) external onlyManager {
        delete routes[_token];
    }

    // Add multiple reward tokens
    function addMultipleRewardTokens(
        ISolidlyRouter.Routes[][] calldata _routes
    ) external onlyManager {
        for (uint i; i < _routes.length; i++) {
            addRewardToken(_routes[i]);
        }
    }

    // Add a reward token
    function addRewardToken(
        ISolidlyRouter.Routes[] calldata _route
    ) public onlyManager {
        require(
            _route[0].from != address(want),
            "Staker: ROUTE_FROM_IS_TOKEN_WANT"
        );
        require(
            _route[_route.length - 1].to == address(want),
            "Staker: ROUTE_TO_NOT_TOKEN_WANT"
        );
        for (uint i; i < _route.length; i++) {
            routes[_route[0].from].push(_route[i]);
        }
        IERC20(_route[0].from).safeApprove(address(router), 0);
        IERC20(_route[0].from).safeApprove(address(router), type(uint256).max);
        emit AddedRewardToken(_route[0].from);
    }

    function getRewards(
        address _bribe,
        address[] calldata _tokens,
        ISolidlyRouter.Routes[][] calldata _routes
    ) external nonReentrant onlyManager {
        uint256 before = balanceOfWant();
        ISolidlyGauge(_bribe).getReward(tokenId, _tokens);
        for (uint i; i < _routes.length; i++) {
            address tokenFrom = _routes[i][0].from;
            require(
                _routes[i][_routes[i].length - 1].to == address(want),
                "Staker: ROUTE_TO_NOT_TOKEN_WANT"
            );
            require(
                tokenFrom != address(want),
                "Staker: ROUTE_FROM_IS_TOKEN_WANT"
            );
            uint256 tokenBal = IERC20(tokenFrom).balanceOf(address(this));
            if (tokenBal > 0) {
                IERC20(tokenFrom).safeApprove(address(router), 0);
                IERC20(tokenFrom).safeApprove(
                    address(router),
                    type(uint256).max
                );
                router.swapExactTokensForTokens(
                    tokenBal,
                    0,
                    _routes[i],
                    address(this),
                    block.timestamp
                );
            }
        }
        uint256 rewardBal = balanceOfWant() - before;
        _chargeFeesAndMint(rewardBal);
    }

    // claim owner rewards such as trading fees and bribes from gauges swap to thena, notify reward pool
    function harvest() public {
        uint256 before = balanceOfWant();
        for (uint i; i < activeVoteLps.length; i++) {
            Gauges memory _gauges = gauges[activeVoteLps[i]];
            ISolidlyGauge(_gauges.bribeGauge).getReward(
                tokenId,
                _gauges.bribeTokens
            );
            ISolidlyGauge(_gauges.feeGauge).getReward(
                tokenId,
                _gauges.feeTokens
            );

            for (uint j; j < _gauges.bribeTokens.length; ++j) {
                address bribeToken = _gauges.bribeTokens[j];
                uint256 tokenBal = IERC20(bribeToken).balanceOf(address(this));
                if (tokenBal > 0 && bribeToken != address(want))
                    router.swapExactTokensForTokens(
                        tokenBal,
                        0,
                        routes[bribeToken],
                        address(this),
                        block.timestamp
                    );
            }

            for (uint k; k < _gauges.feeTokens.length; ++k) {
                address feeToken = _gauges.feeTokens[k];
                uint256 tokenBal = IERC20(feeToken).balanceOf(address(this));
                if (tokenBal > 0 && feeToken != address(want))
                    router.swapExactTokensForTokens(
                        tokenBal,
                        0,
                        routes[feeToken],
                        address(this),
                        block.timestamp
                    );
            }
        }
        uint256 rewardBal = balanceOfWant() - before;
        _chargeFeesAndMint(rewardBal);
    }

    function _chargeFeesAndMint(uint256 _rewardBal) internal {
        // Charge our fees here since we send CeThena to reward pool
        IFeeConfig.FeeCategory memory fees = coFeeConfig.getFees(address(this));
        uint256 feeBal = (_rewardBal * fees.total) / 1e18;
        if (feeBal > 0) {
            IERC20(want).safeApprove(address(router), feeBal);
            uint256[] memory amounts = router.swapExactTokensForTokens(
                feeBal,
                0,
                thenaToNativeRoute,
                address(coFeeRecipient),
                block.timestamp
            );
            IERC20(want).safeApprove(address(router), 0);
            emit ChargedFees(0, amounts[amounts.length - 1], 0);
        }

        uint256 gap = totalWant() - totalSupply();
        if (gap > 0) {
            _mint(address(chamTHERewardPool), gap);
            chamTHERewardPool.notifyRewardAmount();
            emit RewardsHarvested(gap);
        }
    }

    // Set our reward Pool to send our earned chamTHE
    function setChamTHERewardPool(address _rewardPool) external onlyOwner {
        emit SetChamTHERewardPool(address(chamTHERewardPool), _rewardPool);
        chamTHERewardPool = IRewardPool(_rewardPool);
    }

    // Set fee id on fee config
    function setFeeId(uint256 id) external onlyManager {
        emit SetFeeId(id);
        coFeeConfig.setStratFeeId(id);
    }

    // Set fee recipient
    function setCoFeeRecipient(address _feeRecipient) external onlyOwner {
        emit SetFeeRecipient(address(coFeeRecipient), _feeRecipient);
        coFeeRecipient = _feeRecipient;
    }

    // Set our router to exchange our rewards, also update new thenaToNative route.
    function setRouterAndRoute(
        address _router,
        ISolidlyRouter.Routes[] calldata _route
    ) external onlyOwner {
        emit SetRouter(address(router), _router);
        for (uint i; i < _route.length; i++) thenaToNativeRoute.pop();
        for (uint i; i < _route.length; i++) thenaToNativeRoute.push(_route[i]);
        router = ISolidlyRouter(_router);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "../interfaces/ISolidlyRouter.sol";
import "../interfaces/IThenaGauge.sol";
import "../interfaces/IGasPrice.sol";
import "../vault-lp/FeeManager.sol";

contract StrategySolidlyGaugeLPThena is FeeManager {
    using SafeERC20 for IERC20;

    // Tokens used
    IERC20 public immutable want;
    address public immutable native;
    address public immutable output;
    address public immutable lpToken0;
    address public immutable lpToken1;

    // Third party contracts
    IThenaGauge public immutable gauge;

    IGasPrice public immutable gasprice;
    bool public immutable stable;
    bool public harvestOnDeposit;
    uint256 public lastHarvest;

    address[] public rewards;
    ISolidlyRouter.Routes[] public outputToNativeRoute;
    ISolidlyRouter.Routes[] public outputToLp0Route;
    ISolidlyRouter.Routes[] public outputToLp1Route;

    uint256 immutable lp0Decimals;
    uint256 immutable lp1Decimals;

    event StratHarvest(
        address indexed harvester,
        uint256 wantHarvested,
        uint256 tvl
    );
    event Deposit(uint256 tvl);
    event Withdraw(uint256 tvl);
    event ChargedFees(uint256 callFees, uint256 coFees, uint256 strategistFees);
    event GiveAllowances();
    event RemoveAllowances();
    event SetHarvestOnDeposit(bool isEnabled);
    event RetireStrategy(address vault, uint256 amount);
    event Panic(uint256 balance);

    constructor(
        address _want,
        address _gauge,
        address _gasprice,
        CommonAddresses memory _commonAddresses,
        ISolidlyRouter.Routes[] memory _outputToNativeRoute,
        ISolidlyRouter.Routes[] memory _outputToLp0Route,
        ISolidlyRouter.Routes[] memory _outputToLp1Route
    ) StratManager(_commonAddresses) {
        want = IERC20(_want);
        gauge = IThenaGauge(_gauge);
        gasprice = IGasPrice(_gasprice);

        for (uint i; i < _outputToNativeRoute.length; ++i) {
            outputToNativeRoute.push(_outputToNativeRoute[i]);
        }
        for (uint i; i < _outputToLp0Route.length; ++i) {
            outputToLp0Route.push(_outputToLp0Route[i]);
        }
        for (uint i; i < _outputToLp1Route.length; ++i) {
            outputToLp1Route.push(_outputToLp1Route[i]);
        }

        output = _outputToNativeRoute[0].from;
        native = _outputToNativeRoute[_outputToNativeRoute.length - 1].to;
        lpToken0 = _outputToLp0Route[_outputToLp0Route.length - 1].to;
        lpToken1 = _outputToLp1Route[_outputToLp1Route.length - 1].to;

        bytes memory data;

        bool _stable;
        (, data) = address(want).call(abi.encodeWithSignature("stable()"));
        assembly {
            _stable := mload(add(data, 32))
        }
        stable = _stable;

        uint decimals;
        (, data) = lpToken0.call(abi.encodeWithSignature("decimals()"));
        assembly {
            decimals := mload(add(data, add(0x20, 0)))
        }
        lp0Decimals = 10 ** decimals;

        (, data) = lpToken1.call(abi.encodeWithSignature("decimals()"));
        assembly {
            decimals := mload(add(data, add(0x20, 0)))
        }
        lp1Decimals = 10 ** decimals;

        rewards.push(output);
        _giveAllowances();
    }

    modifier gasThrottle() {
        require(
            !gasprice.enabled() || tx.gasprice <= gasprice.maxGasPrice(),
            "Strategy: GAS_TOO_HIGH"
        );
        _;
    }

    // puts the funds to work
    function deposit() public whenNotPaused {
        uint256 wantBal = want.balanceOf(address(this));

        if (wantBal > 0) {
            gauge.deposit(wantBal);
            emit Deposit(balanceOf());
        }
    }

    function withdraw(uint256 _amount) external {
        address _vault = vault;
        require(msg.sender == _vault, "Strategy: VAULT_ONLY");

        uint256 wantBal = want.balanceOf(address(this));
        if (wantBal < _amount) {
            gauge.withdraw(_amount - wantBal);
            wantBal = want.balanceOf(address(this));
        }
        if (wantBal > _amount) {
            wantBal = _amount;
        }
        want.safeTransfer(_vault, wantBal);
        emit Withdraw(balanceOf());
    }

    function beforeDeposit() external virtual override {
        if (harvestOnDeposit) {
            require(msg.sender == vault, "Strategy: VAULT_ONLY");
            _harvest(tx.origin);
        }
    }

    function harvest() external virtual gasThrottle onlyEOA {
        _harvest(tx.origin);
    }

    function harvest(
        address callFeeRecipient
    ) external virtual gasThrottle onlyEOA {
        _harvest(callFeeRecipient);
    }

    function managerHarvest() external onlyManager {
        _harvest(tx.origin);
    }

    // compounds earnings and charges performance fee
    function _harvest(address callFeeRecipient) internal whenNotPaused {
        gauge.getReward();
        uint256 outputBal = IERC20(output).balanceOf(address(this));
        if (outputBal > 0) {
            chargeFees(callFeeRecipient);
            addLiquidity();
            uint256 wantHarvested = balanceOfWant();
            deposit();

            lastHarvest = block.timestamp;
            emit StratHarvest(msg.sender, wantHarvested, balanceOf());
        }
    }

    // performance fees
    function chargeFees(address callFeeRecipient) internal {
        uint256 outputBal = IERC20(output).balanceOf(address(this));
        uint256 toNative = (outputBal * totalPerformanceFee) / PERCENTAGE;
        ISolidlyRouter(uniRouter).swapExactTokensForTokens(
            toNative,
            0,
            outputToNativeRoute,
            address(this),
            block.timestamp
        );

        uint256 nativeBal = IERC20(native).balanceOf(address(this));

        uint256 callFeeAmount = (nativeBal * callFee) / MAX_FEE;
        IERC20(native).safeTransfer(callFeeRecipient, callFeeAmount);

        uint256 coFeeAmount = (nativeBal * coFee) / MAX_FEE;
        IERC20(native).safeTransfer(coFeeRecipient, coFeeAmount);

        uint256 strategistFeeAmount = (nativeBal * strategistFee) / MAX_FEE;
        IERC20(native).safeTransfer(strategist, strategistFeeAmount);

        emit ChargedFees(callFeeAmount, coFeeAmount, strategistFeeAmount);
    }

    // Adds liquidity to AMM and gets more LP tokens.
    function addLiquidity() internal {
        uint256 outputBal = IERC20(output).balanceOf(address(this));
        uint256 lp0Amt = outputBal / 2;
        uint256 lp1Amt = outputBal - lp0Amt;
        ISolidlyRouter router = ISolidlyRouter(uniRouter);

        if (stable) {
            uint256 out0 = lp0Amt;
            if (lpToken0 != output) {
                out0 =
                    (router.getAmountsOut(lp0Amt, outputToLp0Route)[
                        outputToLp0Route.length - 1
                    ] * 1e18) /
                    lp0Decimals;
            }

            uint256 out1 = lp1Amt;
            if (lpToken1 != output) {
                out1 =
                    (router.getAmountsOut(lp1Amt, outputToLp1Route)[
                        outputToLp1Route.length - 1
                    ] * 1e18) /
                    lp1Decimals;
            }

            (uint256 amountA, uint256 amountB, ) = router.quoteAddLiquidity(
                lpToken0,
                lpToken1,
                stable,
                out0,
                out1
            );

            amountA = (amountA * 1e18) / lp0Decimals;
            amountB = (amountB * 1e18) / lp1Decimals;
            uint256 ratio = (((out0 * 1e18) / out1) * amountB) / amountA;
            lp0Amt = (outputBal * 1e18) / (ratio + 1e18);
            lp1Amt = outputBal - lp0Amt;
        }

        if (lpToken0 != output) {
            router.swapExactTokensForTokens(
                lp0Amt,
                0,
                outputToLp0Route,
                address(this),
                block.timestamp
            );
        }

        if (lpToken1 != output) {
            router.swapExactTokensForTokens(
                lp1Amt,
                0,
                outputToLp1Route,
                address(this),
                block.timestamp
            );
        }

        uint256 lp0Bal = IERC20(lpToken0).balanceOf(address(this));
        uint256 lp1Bal = IERC20(lpToken1).balanceOf(address(this));
        router.addLiquidity(
            lpToken0,
            lpToken1,
            stable,
            lp0Bal,
            lp1Bal,
            1,
            1,
            address(this),
            block.timestamp
        );
    }

    // calculate the total 'want' held by the strat.
    function balanceOf() public view returns (uint256) {
        return balanceOfWant() + balanceOfPool();
    }

    // it calculates how much 'want' this contract holds.
    function balanceOfWant() public view returns (uint256) {
        return want.balanceOf(address(this));
    }

    // it calculates how much 'want' the strategy has working in the farm.
    function balanceOfPool() public view returns (uint256) {
        return gauge.balanceOf(address(this));
    }

    // returns rewards unharvested
    function rewardsAvailable() public view returns (uint256) {
        return gauge.earned(address(this));
    }

    // native reward amount for calling harvest
    function callReward() public view returns (uint256) {
        uint256 outputBal = rewardsAvailable();
        uint256 nativeOut;
        if (outputBal > 0) {
            uint256[] memory amountsOut = ISolidlyRouter(uniRouter)
                .getAmountsOut(outputBal, outputToNativeRoute);
            nativeOut = amountsOut[amountsOut.length - 1];
        }
        return
            (((nativeOut * totalPerformanceFee) / PERCENTAGE) * callFee) /
            MAX_FEE;
    }

    function setHarvestOnDeposit(bool _harvestOnDeposit) external onlyManager {
        harvestOnDeposit = _harvestOnDeposit;
        emit SetHarvestOnDeposit(_harvestOnDeposit);
    }

    // pauses deposits and withdraws all funds from third party systems.
    function panic() public onlyManager {
        pause();
        gauge.withdrawAll();
        uint256 wantBal = want.balanceOf(address(this));
        emit Panic(wantBal);
    }

    function pause() public onlyManager {
        _pause();
        _removeAllowances();
    }

    function unpause() external onlyManager {
        _unpause();
        _giveAllowances();
        deposit();
    }

    function _giveAllowances() internal {
        address _uniRouter = uniRouter;
        want.safeApprove(address(gauge), type(uint).max);
        IERC20(output).safeApprove(_uniRouter, type(uint).max);
        IERC20(lpToken0).safeApprove(_uniRouter, type(uint).max);
        IERC20(lpToken1).safeApprove(_uniRouter, type(uint).max);
        emit GiveAllowances();
    }

    function _removeAllowances() internal {
        address _uniRouter = uniRouter;
        want.safeApprove(address(gauge), 0);
        IERC20(output).safeApprove(_uniRouter, 0);
        IERC20(lpToken0).safeApprove(_uniRouter, 0);
        IERC20(lpToken1).safeApprove(_uniRouter, 0);
        emit RemoveAllowances();
    }

    function _solidlyToRoute(
        ISolidlyRouter.Routes[] memory _route
    ) internal pure returns (address[] memory) {
        address[] memory route = new address[](_route.length + 1);
        route[0] = _route[0].from;
        for (uint i; i < _route.length; ++i) {
            route[i + 1] = _route[i].to;
        }
        return route;
    }

    function outputToNative() external view returns (address[] memory) {
        ISolidlyRouter.Routes[] memory _route = outputToNativeRoute;
        return _solidlyToRoute(_route);
    }

    function outputToLp0() external view returns (address[] memory) {
        ISolidlyRouter.Routes[] memory _route = outputToLp0Route;
        return _solidlyToRoute(_route);
    }

    function outputToLp1() external view returns (address[] memory) {
        ISolidlyRouter.Routes[] memory _route = outputToLp1Route;
        return _solidlyToRoute(_route);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "../interfaces/IUniswapV2Router.sol";

contract ChampionOptimizerLpFeeBatchV1 is Initializable, OwnableUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    IERC20Upgradeable public wNative;
    address public chamStaker;
    address public dfTreasury;
    address public coTreasury;

    // Fee constants
    uint public constant MAX_FEE = 1000;
    uint public chamStakerFee;
    uint public dfTreasuryFee;
    uint public coTreasuryFee;

    event NewChamStaker(address oldValue, address newValue);
    event NewDfTreasury(address oldValue, address newValue);
    event NewCoTreasury(address oldValue, address newValue);

    function initialize(
        address _wNative,
        address _chamStaker,
        address _dfTreasury,
        address _coTreasury,
        uint256 _chamStakerFee,
        uint256 _coTreasuryFee
    ) public initializer {
        __Ownable_init();
        wNative = IERC20Upgradeable(_wNative);

        chamStaker = _chamStaker;
        dfTreasury = _dfTreasury;
        coTreasury = _coTreasury;

        chamStakerFee = _chamStakerFee;
        coTreasuryFee = _coTreasuryFee;

        dfTreasuryFee = MAX_FEE - (_chamStakerFee + _coTreasuryFee);
    }

    // Main function. Divides profits.
    function harvest() public {
        uint256 wNativeBal = wNative.balanceOf(address(this));

        uint256 chamStakerAmount = (wNativeBal * chamStakerFee) / MAX_FEE;
        wNative.safeTransfer(chamStaker, chamStakerAmount);

        uint256 dfTreasuryAmount = (wNativeBal * dfTreasuryFee) / MAX_FEE;
        wNative.safeTransfer(dfTreasury, dfTreasuryAmount);

        uint256 coTreasuryAmount = (wNativeBal * coTreasuryFee) / MAX_FEE;
        wNative.safeTransfer(coTreasury, coTreasuryAmount);
    }

    // Manage the contract
    function setChamStaker(address _chamStaker) external onlyOwner {
        emit NewChamStaker(chamStaker, _chamStaker);
        chamStaker = _chamStaker;
    }

    function setCoTreasury(address _coTreasury) external onlyOwner {
        emit NewCoTreasury(coTreasury, _coTreasury);
        coTreasury = _coTreasury;
    }

    function setDfTreasury(address _dfTreasury) external onlyOwner {
        emit NewDfTreasury(dfTreasury, _dfTreasury);
        dfTreasury = _dfTreasury;
    }

    function setFees(
        uint256 _chamStakerFee,
        uint256 _coTreasuryFee
    ) public onlyOwner {
        require(
            MAX_FEE >= (_chamStakerFee + _coTreasuryFee),
            "ChampionOptimizerLpFeeBatchV1: FEE_TOO_HIGH"
        );
        chamStakerFee = _chamStakerFee;
        coTreasuryFee = _coTreasuryFee;
        dfTreasuryFee = MAX_FEE - (_chamStakerFee + _coTreasuryFee);
    }

    // Rescue locked funds sent by mistake
    function inCaseTokensGetStuck(
        address _token,
        address _recipient
    ) external onlyOwner {
        require(_token != address(wNative), "ChampionOptimizerLpFeeBatchV1: NATIVE_TOKEN");

        uint256 amount = IERC20Upgradeable(_token).balanceOf(address(this));
        IERC20Upgradeable(_token).safeTransfer(_recipient, amount);
    }

    receive() external payable {}
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/IUniswapV2Router.sol";

contract ChampionOptimizerLpFeeBatchV2 is Ownable {
    using SafeERC20 for IERC20;

    IERC20 public wNative;
    address public chamStaker;
    address public dfTreasury;
    address public coTreasury;

    // Fee constants
    uint public constant MAX_FEE = 1000;
    uint public chamStakerFee;
    uint public dfTreasuryFee;
    uint public coTreasuryFee;

    event NewChamStaker(address oldValue, address newValue);
    event NewDfTreasury(address oldValue, address newValue);
    event NewCoTreasury(address oldValue, address newValue);

    constructor(
        address _wNative,
        address _chamStaker,
        address _dfTreasury,
        address _coTreasury,
        uint256 _chamStakerFee,
        uint256 _coTreasuryFee
    ) {
        wNative = IERC20(_wNative);

        chamStaker = _chamStaker;
        dfTreasury = _dfTreasury;
        coTreasury = _coTreasury;

        chamStakerFee = _chamStakerFee;
        coTreasuryFee = _coTreasuryFee;

        dfTreasuryFee = MAX_FEE - (_chamStakerFee + _coTreasuryFee);
    }

    // Main function. Divides profits.
    function harvest() public {
        uint256 wNativeBal = wNative.balanceOf(address(this));

        uint256 chamStakerAmount = (wNativeBal * chamStakerFee) / MAX_FEE;
        wNative.safeTransfer(chamStaker, chamStakerAmount);

        uint256 dfTreasuryAmount = (wNativeBal * dfTreasuryFee) / MAX_FEE;
        wNative.safeTransfer(dfTreasury, dfTreasuryAmount);

        uint256 coTreasuryAmount = (wNativeBal * coTreasuryFee) / MAX_FEE;
        wNative.safeTransfer(coTreasury, coTreasuryAmount);
    }

    // Manage the contract
    function setChamStaker(address _chamStaker) external onlyOwner {
        emit NewChamStaker(chamStaker, _chamStaker);
        chamStaker = _chamStaker;
    }

    function setCoTreasury(address _coTreasury) external onlyOwner {
        emit NewCoTreasury(coTreasury, _coTreasury);
        coTreasury = _coTreasury;
    }

    function setDfTreasury(address _dfTreasury) external onlyOwner {
        emit NewDfTreasury(dfTreasury, _dfTreasury);
        dfTreasury = _dfTreasury;
    }

    function setFees(
        uint256 _chamStakerFee,
        uint256 _coTreasuryFee
    ) public onlyOwner {
        require(
            MAX_FEE >= (_chamStakerFee + _coTreasuryFee),
            "ChampionOptimizerLpFeeBatchV1: FEE_TOO_HIGH"
        );
        chamStakerFee = _chamStakerFee;
        coTreasuryFee = _coTreasuryFee;
        dfTreasuryFee = MAX_FEE - (_chamStakerFee + _coTreasuryFee);
    }

    // Rescue locked funds sent by mistake
    function inCaseTokensGetStuck(
        address _token,
        address _recipient
    ) external onlyOwner {
        require(_token != address(wNative), "ChampionOptimizerLpFeeBatchV1: NATIVE_TOKEN");

        uint256 amount = IERC20(_token).balanceOf(address(this));
        IERC20(_token).safeTransfer(_recipient, amount);
    }

    receive() external payable {}
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import './StratManager.sol';

abstract contract FeeManager is StratManager {
    uint constant public PERCENTAGE = 10000;        // 100.00%
    uint constant public MAX_PERFORMANCE_FEE = 400; //   4.00%

    uint constant public MAX_FEE = 1000;            // 100.0% of totalPerformanceFee
    uint constant public MAX_CALL_FEE = 125;        //  12.5% of MAX_FEE
    uint constant public MAX_STRATEGIST_FEE = 125;  //  12.5% of MAX_FEE

    uint public totalPerformanceFee = 400;          //  4.00%
    uint public callFee = 125;                      //  12.5% of MAX_FEE
    uint public strategistFee = 125;                //  12.5% of MAX_FEE
    uint public coFee = MAX_FEE - (strategistFee + callFee);

    function setFees(uint _callFee, uint _strategistFee) public onlyManager {
        require(_callFee <= MAX_CALL_FEE, "FeeManager: MAX_CALL_FEE");
        require(_strategistFee <= MAX_STRATEGIST_FEE, "FeeManager: MAX_STRATEGIST_FEE");
        callFee = _callFee;
        strategistFee = _strategistFee;
        coFee = MAX_FEE - (_strategistFee + _callFee);
    }

    function setTotalPerformanceFee(uint _fee) public onlyManager {
        require(_fee <= MAX_PERFORMANCE_FEE, "FeeManager: MAX_PERFORMANCE_FEE");
        totalPerformanceFee = _fee;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;
import "@openzeppelin/contracts/access/Ownable.sol";

contract GasPrice is Ownable {

    uint public maxGasPrice = 10000000000; // 10 gwei
    bool public enabled = true;

    event NewMaxGasPrice(uint oldPrice, uint newPrice);

    function setMaxGasPrice(uint _maxGasPrice) external onlyOwner {
        emit NewMaxGasPrice(maxGasPrice, _maxGasPrice);
        maxGasPrice = _maxGasPrice;
    }

    function enable() external onlyOwner {
        enabled = true;
    }

    function disable() external onlyOwner {
        enabled = false;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../lib/SafeMath.sol";
import "../interfaces/IUniswapV2Pair.sol";
import "../interfaces/IUniswapV2Router.sol";
import "../interfaces/IGasPrice.sol";
import "../interfaces/IFarming.sol";
import "../utils/StringUtils.sol";
import "./FeeManager.sol";

contract StrategyDefenderRewardPool is FeeManager {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    address public gasprice;
    // Tokens used
    address public native;
    address public output;
    address public want;
    address public lpToken0;
    address public lpToken1;

    // Third party contracts
    address public masterChef;
    uint256 public poolId;

    bool public harvestOnDeposit;
    uint256 public lastHarvest;
    string public pendingRewardsFunctionName;

    // Routes
    address[] public outputToNativeRoute;
    address[] public outputToLp0Route;
    address[] public outputToLp1Route;

    event StratHarvest(
        address indexed harvester,
        uint256 wantHarvested,
        uint256 tvl
    );
    event Deposit(uint256 tvl);
    event Withdraw(uint256 tvl);
    event ChargedFees(
        uint256 callFees,
        uint256 coFees,
        uint256 strategistFees
    );

    modifier gasThrottle() {
        require(
            !IGasPrice(gasprice).enabled() ||
                tx.gasprice <= IGasPrice(gasprice).maxGasPrice(),
            "Strategy: GAS_TOO_HIGH"
        );
        _;
    }

    constructor(
        address _want,
        uint256 _poolId,
        address _masterChef,
        address _gasprice,
        CommonAddresses memory _commonAddresses,
        address[] memory _outputToNativeRoute,
        address[] memory _outputToLp0Route,
        address[] memory _outputToLp1Route
    ) StratManager(_commonAddresses) {
        want = _want;
        poolId = _poolId;
        masterChef = _masterChef;
        gasprice = _gasprice;
        output = _outputToNativeRoute[0];
        native = _outputToNativeRoute[_outputToNativeRoute.length - 1];
        outputToNativeRoute = _outputToNativeRoute;

        // setup lp routing
        lpToken0 = IUniswapV2Pair(want).token0();
        require(
            _outputToLp0Route[0] == output,
            "Strategy: outputToLp0Route[0] != output"
        );
        require(
            _outputToLp0Route[_outputToLp0Route.length - 1] == lpToken0,
            "Strategy: outputToLp0Route[last] != lpToken0"
        );
        outputToLp0Route = _outputToLp0Route;

        lpToken1 = IUniswapV2Pair(want).token1();
        require(
            _outputToLp1Route[0] == output,
            "Strategy: outputToLp1Route[0] != output"
        );
        require(
            _outputToLp1Route[_outputToLp1Route.length - 1] == lpToken1,
            "Strategy: outputToLp1Route[last] != lpToken1"
        );
        outputToLp1Route = _outputToLp1Route;

        _giveAllowances();
    }

    // puts the funds to work
    function deposit() public whenNotPaused {
        uint256 wantBal = IERC20(want).balanceOf(address(this));

        if (wantBal > 0) {
            IFarming(masterChef).deposit(poolId, wantBal);
            emit Deposit(balanceOf());
        }
    }

    function withdraw(uint256 _amount) external {
        require(msg.sender == vault, "Strategy: VAULT_ONLY");

        uint256 wantBal = IERC20(want).balanceOf(address(this));

        if (wantBal < _amount) {
            IFarming(masterChef).withdraw(poolId, _amount.sub(wantBal));
            wantBal = IERC20(want).balanceOf(address(this));
        }

        if (wantBal > _amount) {
            wantBal = _amount;
        }

        IERC20(want).safeTransfer(vault, wantBal);

        emit Withdraw(balanceOf());
    }

    function beforeDeposit() external override {
        if (harvestOnDeposit) {
            require(msg.sender == vault, "Strategy: VAULT_ONLY");
            _harvest(tx.origin);
        }
    }

    function harvest() external virtual gasThrottle {
        _harvest(tx.origin);
    }

    function harvest(address callFeeRecipient) external virtual gasThrottle {
        _harvest(callFeeRecipient);
    }

    function managerHarvest() external onlyManager {
        _harvest(tx.origin);
    }

    // compounds earnings and charges performance fee
    function _harvest(address callFeeRecipient) internal whenNotPaused {
        IFarming(masterChef).deposit(poolId, 0);
        uint256 outputBal = IERC20(output).balanceOf(address(this));
        if (outputBal > 0) {
            chargeFees(callFeeRecipient);
            addLiquidity();
            uint256 wantHarvested = balanceOfWant();
            deposit();

            lastHarvest = block.timestamp;
            emit StratHarvest(msg.sender, wantHarvested, balanceOf());
        }
    }

    // performance fees
    function chargeFees(address callFeeRecipient) internal {
        uint256 toNative = IERC20(output)
            .balanceOf(address(this))
            .mul(totalPerformanceFee)
            .div(PERCENTAGE);
        IUniswapV2Router(uniRouter).swapExactTokensForTokens(
            toNative,
            0,
            outputToNativeRoute,
            address(this),
            block.timestamp
        );

        uint256 nativeBal = IERC20(native).balanceOf(address(this));

        uint256 callFeeAmount = nativeBal.mul(callFee).div(MAX_FEE);
        IERC20(native).safeTransfer(callFeeRecipient, callFeeAmount);

        uint256 coFeeAmount = nativeBal.mul(coFee).div(MAX_FEE);
        IERC20(native).safeTransfer(coFeeRecipient, coFeeAmount);

        uint256 strategistFeeAmount = nativeBal.mul(strategistFee).div(MAX_FEE);
        IERC20(native).safeTransfer(strategist, strategistFeeAmount);

        emit ChargedFees(callFeeAmount, coFeeAmount, strategistFeeAmount);
    }

    // Adds liquidity to AMM and gets more LP tokens.
    function addLiquidity() internal {
        uint256 outputHalf = IERC20(output).balanceOf(address(this)).div(2);

        if (lpToken0 != output) {
            IUniswapV2Router(uniRouter).swapExactTokensForTokens(
                outputHalf,
                0,
                outputToLp0Route,
                address(this),
                block.timestamp
            );
        }

        if (lpToken1 != output) {
            IUniswapV2Router(uniRouter).swapExactTokensForTokens(
                outputHalf,
                0,
                outputToLp1Route,
                address(this),
                block.timestamp
            );
        }

        uint256 lp0Bal = IERC20(lpToken0).balanceOf(address(this));
        uint256 lp1Bal = IERC20(lpToken1).balanceOf(address(this));
        IUniswapV2Router(uniRouter).addLiquidity(
            lpToken0,
            lpToken1,
            lp0Bal,
            lp1Bal,
            1,
            1,
            address(this),
            block.timestamp
        );
    }

    // calculate the total underlying 'want' held by the strat.
    function balanceOf() public view returns (uint256) {
        return balanceOfWant().add(balanceOfPool());
    }

    // it calculates how much 'want' this contract holds.
    function balanceOfWant() public view returns (uint256) {
        return IERC20(want).balanceOf(address(this));
    }

    // it calculates how much 'want' the strategy has working in the farm.
    function balanceOfPool() public view returns (uint256) {
        (uint256 _amount, ) = IFarming(masterChef).userInfo(
            poolId,
            address(this)
        );
        return _amount;
    }

    function setPendingRewardsFunctionName(
        string calldata _pendingRewardsFunctionName
    ) external onlyManager {
        pendingRewardsFunctionName = _pendingRewardsFunctionName;
    }

    // returns rewards unharvested
    function rewardsAvailable() public view returns (uint256) {
        string memory signature = StringUtils.concat(
            pendingRewardsFunctionName,
            "(uint256,address)"
        );
        bytes memory result = Address.functionStaticCall(
            masterChef,
            abi.encodeWithSignature(signature, poolId, address(this))
        );
        return abi.decode(result, (uint256));
    }

    // native reward amount for calling harvest
    function callReward() public view returns (uint256) {
        uint256 outputBal = rewardsAvailable();
        uint256 nativeOut;
        if (outputBal > 0) {
            uint256[] memory amountOut = IUniswapV2Router(uniRouter)
                .getAmountsOut(outputBal, outputToNativeRoute);
            nativeOut = amountOut[amountOut.length - 1];
        }

        return
            nativeOut.mul(totalPerformanceFee).div(PERCENTAGE).mul(callFee).div(
                MAX_FEE
            );
    }

    function setHarvestOnDeposit(bool _harvestOnDeposit) external onlyManager {
        harvestOnDeposit = _harvestOnDeposit;
    }

    // called as part of strat migration. Sends all the available funds back to the vault.
    function retireStrat() external {
        require(msg.sender == vault, "Strategy: VAULT_ONLY");
        IFarming(masterChef).emergencyWithdraw(poolId);
        uint256 wantBal = IERC20(want).balanceOf(address(this));
        IERC20(want).transfer(vault, wantBal);
    }

    // pauses deposits and withdraws all funds from third party systems.
    function panic() public onlyManager {
        pause();
        IFarming(masterChef).emergencyWithdraw(poolId);
    }

    function pause() public onlyManager {
        _pause();
        _removeAllowances();
    }

    function unpause() external onlyManager {
        _unpause();
        _giveAllowances();
        deposit();
    }

    function _giveAllowances() internal {
        IERC20(want).safeApprove(masterChef, type(uint256).max);
        IERC20(output).safeApprove(uniRouter, type(uint256).max);

        IERC20(lpToken0).safeApprove(uniRouter, 0);
        IERC20(lpToken0).safeApprove(uniRouter, type(uint256).max);

        IERC20(lpToken1).safeApprove(uniRouter, 0);
        IERC20(lpToken1).safeApprove(uniRouter, type(uint256).max);
    }

    function _removeAllowances() internal {
        IERC20(want).safeApprove(masterChef, 0);
        IERC20(output).safeApprove(uniRouter, 0);
        IERC20(lpToken0).safeApprove(uniRouter, 0);
        IERC20(lpToken1).safeApprove(uniRouter, 0);
    }

    function outputToNative() external view returns (address[] memory) {
        return outputToNativeRoute;
    }

    function outputToLp0() external view returns (address[] memory) {
        return outputToLp0Route;
    }

    function outputToLp1() external view returns (address[] memory) {
        return outputToLp1Route;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../lib/SafeMath.sol";
import "../interfaces/IUniswapV2Pair.sol";
import "../interfaces/IUniswapV2Router.sol";
import "../interfaces/ISolidlyRouter.sol";
import "../interfaces/IGasPrice.sol";
import "../interfaces/IFarming.sol";
import "../utils/StringUtils.sol";
import "./FeeManager.sol";

contract StrategyThenaDefenderRewardPool is FeeManager {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    address public gasprice;
    // Tokens used
    address public native;
    address public output;
    address public want;
    address public eth;
    address public cham;

    address public thenaRouter;

    // Third party contracts
    address public masterChef;
    uint256 public poolId;

    bool public harvestOnDeposit;
    uint256 public lastHarvest;
    string public pendingRewardsFunctionName;

    // Routes
    address[] public outputToNativeRoute;
    address[] public outputToEthRoute;
    ISolidlyRouter.Routes[] public ethToChamRoute;

    event StratHarvest(
        address indexed harvester,
        uint256 wantHarvested,
        uint256 tvl
    );
    event Deposit(uint256 tvl);
    event Withdraw(uint256 tvl);
    event ChargedFees(
        uint256 callFees,
        uint256 coFees,
        uint256 strategistFees
    );

    modifier gasThrottle() {
        require(
            !IGasPrice(gasprice).enabled() ||
                tx.gasprice <= IGasPrice(gasprice).maxGasPrice(),
            "Strategy: GAS_TOO_HIGH"
        );
        _;
    }

    constructor(
        address _want,
        uint256 _poolId,
        address _masterChef,
        address _gasprice,
        address _eth,
        address _thenaRouter,
        CommonAddresses memory _commonAddresses,
        address[] memory _outputToNativeRoute
    ) StratManager(_commonAddresses) {
        want = _want;
        poolId = _poolId;
        masterChef = _masterChef;
        gasprice = _gasprice;
        output = _outputToNativeRoute[0];
        native = _outputToNativeRoute[_outputToNativeRoute.length - 1];
        thenaRouter = _thenaRouter;
        eth = _eth;

        outputToNativeRoute = _outputToNativeRoute;
        
        outputToEthRoute.push(output);
        outputToEthRoute.push(native);
        outputToEthRoute.push(eth);

        // setup lp routing
        address lpToken0 = IUniswapV2Pair(want).token0();
        if (lpToken0 != eth) {
            cham = lpToken0;
        } else {
            cham = IUniswapV2Pair(want).token1();
        }

        bytes memory _stable = Address.functionStaticCall(
            want,
            abi.encodeWithSignature("stable()")
        );
        ethToChamRoute.push(ISolidlyRouter.Routes({
            from : eth,
            to : cham,
            stable : abi.decode(_stable, (bool))
        }));

        _giveAllowances();
    }

    // puts the funds to work
    function deposit() public whenNotPaused {
        uint256 wantBal = IERC20(want).balanceOf(address(this));

        if (wantBal > 0) {
            IFarming(masterChef).deposit(poolId, wantBal);
            emit Deposit(balanceOf());
        }
    }

    function withdraw(uint256 _amount) external {
        require(msg.sender == vault, "Strategy: VAULT_ONLY");

        uint256 wantBal = IERC20(want).balanceOf(address(this));

        if (wantBal < _amount) {
            IFarming(masterChef).withdraw(poolId, _amount.sub(wantBal));
            wantBal = IERC20(want).balanceOf(address(this));
        }

        if (wantBal > _amount) {
            wantBal = _amount;
        }

        IERC20(want).safeTransfer(vault, wantBal);

        emit Withdraw(balanceOf());
    }

    function beforeDeposit() external override {
        if (harvestOnDeposit) {
            require(msg.sender == vault, "Strategy: VAULT_ONLY");
            _harvest(tx.origin);
        }
    }

    function harvest() external virtual gasThrottle {
        _harvest(tx.origin);
    }

    function harvest(address callFeeRecipient) external virtual gasThrottle {
        _harvest(callFeeRecipient);
    }

    function managerHarvest() external onlyManager {
        _harvest(tx.origin);
    }

    // compounds earnings and charges performance fee
    function _harvest(address callFeeRecipient) internal whenNotPaused {
        IFarming(masterChef).deposit(poolId, 0);
        uint256 outputBal = IERC20(output).balanceOf(address(this));
        if (outputBal > 0) {
            chargeFees(callFeeRecipient);
            addLiquidity();
            uint256 wantHarvested = balanceOfWant();
            deposit();

            lastHarvest = block.timestamp;
            emit StratHarvest(msg.sender, wantHarvested, balanceOf());
        }
    }

    // performance fees
    function chargeFees(address callFeeRecipient) internal {
        uint256 toNative = IERC20(output)
            .balanceOf(address(this))
            .mul(totalPerformanceFee)
            .div(PERCENTAGE);

        IUniswapV2Router(uniRouter).swapExactTokensForTokens(
            toNative,
            0,
            outputToNativeRoute,
            address(this),
            block.timestamp
        );

        uint256 nativeBal = IERC20(native).balanceOf(address(this));

        uint256 callFeeAmount = nativeBal.mul(callFee).div(MAX_FEE);
        IERC20(native).safeTransfer(callFeeRecipient, callFeeAmount);

        uint256 coFeeAmount = nativeBal.mul(coFee).div(MAX_FEE);
        IERC20(native).safeTransfer(coFeeRecipient, coFeeAmount);

        uint256 strategistFeeAmount = nativeBal.mul(strategistFee).div(MAX_FEE);
        IERC20(native).safeTransfer(strategist, strategistFeeAmount);

        emit ChargedFees(callFeeAmount, coFeeAmount, strategistFeeAmount);
    }

    // Adds liquidity to AMM and gets more LP tokens.
    function addLiquidity() internal {
        uint256 balanceOutput = IERC20(output).balanceOf(address(this));
        if (balanceOutput > 0) {
            // swap reward to ETH
            IUniswapV2Router(uniRouter).swapExactTokensForTokens(
                balanceOutput,
                0,
                outputToEthRoute,
                address(this),
                block.timestamp
            );

            uint256 ethHalf = IERC20(eth).balanceOf(address(this)).div(2);
            ISolidlyRouter(thenaRouter).swapExactTokensForTokens(
                ethHalf,
                0,
                ethToChamRoute,
                address(this),
                block.timestamp
            );

            uint256 ethBal = IERC20(eth).balanceOf(address(this));
            uint256 chamBal = IERC20(cham).balanceOf(address(this));
            ISolidlyRouter(thenaRouter).addLiquidity(
                eth,
                cham,
                false,
                ethBal,
                chamBal,
                1,
                1,
                address(this),
                block.timestamp
            );
        }
    }

    // calculate the total underlying 'want' held by the strat.
    function balanceOf() public view returns (uint256) {
        return balanceOfWant().add(balanceOfPool());
    }

    // it calculates how much 'want' this contract holds.
    function balanceOfWant() public view returns (uint256) {
        return IERC20(want).balanceOf(address(this));
    }

    // it calculates how much 'want' the strategy has working in the farm.
    function balanceOfPool() public view returns (uint256) {
        (uint256 _amount, ) = IFarming(masterChef).userInfo(
            poolId,
            address(this)
        );
        return _amount;
    }

    function setPendingRewardsFunctionName(
        string calldata _pendingRewardsFunctionName
    ) external onlyManager {
        pendingRewardsFunctionName = _pendingRewardsFunctionName;
    }

    // returns rewards unharvested
    function rewardsAvailable() public view returns (uint256) {
        string memory signature = StringUtils.concat(
            pendingRewardsFunctionName,
            "(uint256,address)"
        );
        bytes memory result = Address.functionStaticCall(
            masterChef,
            abi.encodeWithSignature(signature, poolId, address(this))
        );
        return abi.decode(result, (uint256));
    }

    // native reward amount for calling harvest
    function callReward() public view returns (uint256) {
        uint256 outputBal = rewardsAvailable();
        uint256 nativeOut;
        if (outputBal > 0) {
            uint256[] memory amountOut = IUniswapV2Router(uniRouter)
                .getAmountsOut(outputBal, outputToNativeRoute);
            nativeOut = amountOut[amountOut.length - 1];
        }

        return
            nativeOut.mul(totalPerformanceFee).div(PERCENTAGE).mul(callFee).div(
                MAX_FEE
            );
    }

    function setHarvestOnDeposit(bool _harvestOnDeposit) external onlyManager {
        harvestOnDeposit = _harvestOnDeposit;
    }

    // called as part of strat migration. Sends all the available funds back to the vault.
    function retireStrat() external {
        require(msg.sender == vault, "Strategy: VAULT_ONLY");
        IFarming(masterChef).emergencyWithdraw(poolId);
        uint256 wantBal = IERC20(want).balanceOf(address(this));
        IERC20(want).transfer(vault, wantBal);
    }

    // pauses deposits and withdraws all funds from third party systems.
    function panic() public onlyManager {
        pause();
        IFarming(masterChef).emergencyWithdraw(poolId);
    }

    function pause() public onlyManager {
        _pause();
        _removeAllowances();
    }

    function unpause() external onlyManager {
        _unpause();
        _giveAllowances();
        deposit();
    }

    function _giveAllowances() internal {
        IERC20(want).safeApprove(masterChef, type(uint256).max);
        IERC20(output).safeApprove(uniRouter, type(uint256).max);

        IERC20(cham).safeApprove(thenaRouter, 0);
        IERC20(cham).safeApprove(thenaRouter, type(uint256).max);

        IERC20(eth).safeApprove(thenaRouter, 0);
        IERC20(eth).safeApprove(thenaRouter, type(uint256).max);
    }

    function _removeAllowances() internal {
        IERC20(want).safeApprove(masterChef, 0);
        IERC20(output).safeApprove(uniRouter, 0);
        IERC20(eth).safeApprove(thenaRouter, 0);
        IERC20(cham).safeApprove(thenaRouter, 0);
    }

    function outputToNative() external view returns (address[] memory) {
        return outputToNativeRoute;
    }

    function setThenaRouter(address _thenaRouter) external onlyOwner {
        thenaRouter = _thenaRouter;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract StratManager is Ownable, Pausable {
    /**
     * @dev Initializes the base strategy.
     * @param keeper address to use as alternative owner.
     * @param strategist address where strategist fees go.
     * @param uniRouter router to use for swaps
     * @param vault address of parent vault.
     * @param coFeeRecipient address where to send ChampionOptimizer's fees.
     */
    struct CommonAddresses {
        address vault;
        address uniRouter;
        address keeper;
        address strategist;
        address coFeeRecipient;
    }

    /**
     * @dev Champion Optimizer Contracts:
     * {keeper} - Address to manage a few lower risk features of the strat
     * {strategist} - Address of the strategy author/deployer where strategist fee will go.
     * {vault} - Address of the vault that controls the strategy's funds.
     * {uniRouter} - Address of exchange to execute swaps.
     */
    address public keeper;
    address public strategist;
    address public uniRouter;
    address public vault;
    address public coFeeRecipient;
    bool public hadVault = false;

    constructor(CommonAddresses memory _commonAddresses) {
        keeper = _commonAddresses.keeper;
        strategist = _commonAddresses.strategist;
        uniRouter = _commonAddresses.uniRouter;
        vault = _commonAddresses.vault;
        coFeeRecipient = _commonAddresses.coFeeRecipient;
    }

    // checks that caller is either owner or keeper.
    modifier onlyManager() {
        require(msg.sender == owner() || msg.sender == keeper, "StratManager: MANAGER_ONLY");
        _;
    }

    // verifies that the caller is not a contract.
    modifier onlyEOA() {
        require(msg.sender == tx.origin, "StratManager: EOA_ONLY");
        _;
    }

    /**
     * @dev Updates address of the strat keeper.
     * @param _keeper new keeper address.
     */
    function setKeeper(address _keeper) external onlyManager {
        keeper = _keeper;
    }

    /**
     * @dev Updates address where strategist fee earnings will go.
     * @param _strategist new strategist address.
     */
    function setStrategist(address _strategist) external {
        require(msg.sender == strategist, "StratManager: STRATEGIST_ONLY");
        strategist = _strategist;
    }

    /**
     * @dev Updates parent vault.
     * @param _vault new vault address.
     */
    function setVault(address _vault) external onlyOwner {
        require(!hadVault, "StratManager: vault had been set up");
        vault = _vault;
        hadVault = true;
    }

    /**
     * @dev Updates CO fee recipient.
     * @param _coFeeRecipient new CO fee recipient address.
     */
    function setCoFeeRecipient(address _coFeeRecipient) external onlyOwner {
        coFeeRecipient = _coFeeRecipient;
    }

    /**
     * @dev Function to synchronize balances before new user deposit.
     * Can be overridden in the strategy.
     */
    function beforeDeposit() external virtual {}
}