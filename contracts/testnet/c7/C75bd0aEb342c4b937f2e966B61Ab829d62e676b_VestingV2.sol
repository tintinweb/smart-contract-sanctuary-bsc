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
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20Upgradeable.sol";

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
        if (_initialized != type(uint8).max) {
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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

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
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
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

//**  vesting Contract interface */

pragma solidity ^0.8.10;

interface IVestingV2 {
    enum Type {
        Linear,
        Monthly,
        Interval
    }

    struct VestingInfo {
        string name;
        uint256 cliff;
        uint256 start;
        uint256 duration;
        uint256 initialUnlockPercent;
        bool revocable;
        Type vestType;
        uint256 interval;
        uint256 unlockPerInterval;
        uint256[] timestamps;
    }

    struct VestingPool {
        string name;
        uint256 cliff;
        uint256 start;
        uint256 duration;
        uint256 initialUnlockPercent;
        WhitelistInfo[] whitelistPool;
        mapping(address => HasWhitelist) hasWhitelist;
        bool revocable;
        Type vestType;
        uint256 interval;
        uint256 unlockPerInterval;
        uint256[] timestamps;
    }

    /**
     *
     * @dev WhiteInfo is the struct type which store whitelist information
     *
     */
    struct WhitelistInfo {
        address wallet;
        uint256 amount;
        uint256 distributedAmount;
        uint256 joinDate;
        uint256 revokeDate;
        bool revoke;
        bool disabled;
    }

    struct HasWhitelist {
        uint256 arrIdx;
        bool active;
    }

    event AddToken(address indexed token);
    event Claim(address indexed token, uint256 amount, uint256 indexed option, uint256 time);
    event AddWhitelist(address indexed wallet);
    event Revoked(address indexed wallet);
    event StatusChanged(address indexed wallet, bool status);

    function initialize(address _token, address _ico) external;

    function addVestingStrategy(
        string memory _name,
        uint256 _cliff,
        uint256 _start,
        uint256 _duration,
        uint256 _initialUnlockPercent,
        bool _revocable,
        uint256 _interval,
        uint16 _unlockPerInterval,
        uint8 _monthGap,
        Type _type
    ) external returns (bool);

    function setVestingStrategy(
        uint256 _strategy,
        string memory _name,
        uint256 _cliff,
        uint256 _start,
        uint256 _duration,
        uint256 _initialUnlockPercent,
        bool _revocable,
        uint256 _interval,
        uint16 _unlockPerInterval
    ) external returns (bool);

    function addWhitelist(address _wallet, uint256 _amount, uint256 _option) external returns (bool);

    function setToken(address _addr) external returns (bool);

    function setIcoContract(address _ico) external returns (bool);

    function batchAddWhitelist(
        address[] memory wallets,
        uint256[] memory amounts,
        uint256 option
    ) external returns (bool);

    /**
     *
     * @dev set the address as whitelist user address
     *
     * @param {address} address of the user
     *
     * @return {bool} return status of the whitelist
     *
     */
    function setWhitelist(address _wallet, uint256 _amount, uint256 _option) external returns (bool);

    function revoke(uint256 _option, address _wallet) external;

    function setVesting(uint256 _option, address _wallet, bool _status) external;

    function transferToken(address _addr, uint256 _amount) external returns (bool);

    function claimDistribution(uint256 _option, address _wallet) external returns (bool);

    function getWhitelist(uint256 _option, address _wallet) external view returns (WhitelistInfo memory);

    function getAllVestingPools() external view returns (VestingInfo[] memory);

    function getTotalToken(address _addr) external view returns (uint256);

    function hasWhitelist(uint256 _option, address _wallet) external view returns (bool);

    function getVestAmount(uint256 _option, address _wallet) external view returns (uint256);

    function getReleasableAmount(uint256 _option, address _wallet) external view returns (uint256);

    function getWhitelistPool(uint256 _option) external view returns (WhitelistInfo[] memory);

    function getVestingInfo(uint256 _strategy) external view returns (VestingInfo memory);
}

// SPDX-License-Identifier: MIT

//**  Wrapped AEG token interface */

pragma solidity ^0.8.10;

interface IWrappedAEG {
    //Mint tokens. Only accessible for vesting contract
    function mint(address to, uint256 amount) external returns (bool);

    //Burn tokens. Only accessible for vesting contract
    function burn(address from, uint256 amount) external returns (bool);
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

contract DateTime {
    /*
     *  Date and Time utilities for ethereum contracts
     *
     */
    struct DateTimeStruct {
        uint16 year;
        uint8 month;
        uint8 day;
        uint8 hour;
        uint8 minute;
        uint8 second;
        uint8 weekday;
    }

    /* solhint-disable var-name-mixedcase */

    uint256 internal DAY_IN_SECONDS;
    uint256 internal YEAR_IN_SECONDS;
    uint256 internal LEAP_YEAR_IN_SECONDS;
    uint256 internal HOUR_IN_SECONDS;
    uint256 internal MINUTE_IN_SECONDS;
    uint16 internal ORIGIN_YEAR;

    /* solhint-enable var-name-mixedcase */

    function __dateTimeInit() internal {
        DAY_IN_SECONDS = 86400;
        YEAR_IN_SECONDS = 31536000;
        LEAP_YEAR_IN_SECONDS = 31622400;

        HOUR_IN_SECONDS = 3600;
        MINUTE_IN_SECONDS = 60;

        ORIGIN_YEAR = 1970;
    }

    function getYear(uint256 timestamp) internal view returns (uint16) {
        uint256 secondsAccountedFor = 0;
        uint16 year;
        uint256 numLeapYears;

        // Year
        year = uint16(ORIGIN_YEAR + timestamp / YEAR_IN_SECONDS);
        numLeapYears = leapYearsBefore(year) - leapYearsBefore(ORIGIN_YEAR);

        secondsAccountedFor += LEAP_YEAR_IN_SECONDS * numLeapYears;
        secondsAccountedFor += YEAR_IN_SECONDS * (year - ORIGIN_YEAR - numLeapYears);

        while (secondsAccountedFor > timestamp) {
            if (isLeapYear(uint16(year - 1))) {
                secondsAccountedFor -= LEAP_YEAR_IN_SECONDS;
            } else {
                secondsAccountedFor -= YEAR_IN_SECONDS;
            }
            year -= 1;
        }
        return year;
    }

    function getMonth(uint256 timestamp) internal view returns (uint8) {
        return parseTimestamp(timestamp).month;
    }

    function getDay(uint256 timestamp) internal view returns (uint8) {
        return parseTimestamp(timestamp).day;
    }

    function getWeekday(uint256 timestamp) internal view returns (uint8) {
        return uint8((timestamp / DAY_IN_SECONDS + 4) % 7);
    }

    function toTimestamp(uint16 year, uint8 month, uint8 day) internal view returns (uint256 timestamp) {
        return toTimestamp(year, month, day, 0, 0, 0);
    }

    function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour) internal view returns (uint256 timestamp) {
        return toTimestamp(year, month, day, hour, 0, 0);
    }

    function toTimestamp(
        uint16 year,
        uint8 month,
        uint8 day,
        uint8 hour,
        uint8 minute
    ) internal view returns (uint256 timestamp) {
        return toTimestamp(year, month, day, hour, minute, 0);
    }

    function toTimestamp(
        uint16 year,
        uint8 month,
        uint8 day,
        uint8 hour,
        uint8 minute,
        uint8 second
    ) internal view returns (uint256 timestamp) {
        uint16 i;

        // Year
        for (i = ORIGIN_YEAR; i < year; i++) {
            if (isLeapYear(i)) {
                timestamp += LEAP_YEAR_IN_SECONDS;
            } else {
                timestamp += YEAR_IN_SECONDS;
            }
        }

        // Month
        uint8[12] memory monthDayCounts;
        monthDayCounts[0] = 31;
        if (isLeapYear(year)) {
            monthDayCounts[1] = 29;
        } else {
            monthDayCounts[1] = 28;
        }
        monthDayCounts[2] = 31;
        monthDayCounts[3] = 30;
        monthDayCounts[4] = 31;
        monthDayCounts[5] = 30;
        monthDayCounts[6] = 31;
        monthDayCounts[7] = 31;
        monthDayCounts[8] = 30;
        monthDayCounts[9] = 31;
        monthDayCounts[10] = 30;
        monthDayCounts[11] = 31;

        for (i = 1; i < month; i++) {
            timestamp += DAY_IN_SECONDS * monthDayCounts[i - 1];
        }

        // Day
        timestamp += DAY_IN_SECONDS * (day - 1);

        // Hour
        timestamp += HOUR_IN_SECONDS * (hour);

        // Minute
        timestamp += MINUTE_IN_SECONDS * (minute);

        // Second
        timestamp += second;

        return timestamp;
    }

    function parseTimestamp(uint256 timestamp) internal view returns (DateTimeStruct memory dt) {
        uint256 secondsAccountedFor = 0;
        uint256 buf;
        uint8 i;

        // Year
        dt.year = getYear(timestamp);
        buf = leapYearsBefore(dt.year) - leapYearsBefore(ORIGIN_YEAR);

        secondsAccountedFor += LEAP_YEAR_IN_SECONDS * buf;
        secondsAccountedFor += YEAR_IN_SECONDS * (dt.year - ORIGIN_YEAR - buf);

        // Month
        uint256 secondsInMonth;
        for (i = 1; i <= 12; i++) {
            secondsInMonth = DAY_IN_SECONDS * getDaysInMonth(i, dt.year);
            if (secondsInMonth + secondsAccountedFor > timestamp) {
                dt.month = i;
                break;
            }
            secondsAccountedFor += secondsInMonth;
        }

        // Day
        for (i = 1; i <= getDaysInMonth(dt.month, dt.year); i++) {
            if (DAY_IN_SECONDS + secondsAccountedFor > timestamp) {
                dt.day = i;
                break;
            }
            secondsAccountedFor += DAY_IN_SECONDS;
        }

        // Hour
        dt.hour = getHour(timestamp);

        // Minute
        dt.minute = getMinute(timestamp);

        // Second
        dt.second = getSecond(timestamp);

        // Day of week.
        dt.weekday = getWeekday(timestamp);
    }

    function getHour(uint256 timestamp) internal pure returns (uint8) {
        return uint8((timestamp / 60 / 60) % 24);
    }

    function getMinute(uint256 timestamp) internal pure returns (uint8) {
        return uint8((timestamp / 60) % 60);
    }

    function getSecond(uint256 timestamp) internal pure returns (uint8) {
        return uint8(timestamp % 60);
    }

    function isLeapYear(uint16 year) internal pure returns (bool) {
        if (year % 4 != 0) {
            return false;
        }
        if (year % 100 != 0) {
            return true;
        }
        if (year % 400 != 0) {
            return false;
        }
        return true;
    }

    function leapYearsBefore(uint256 year) internal pure returns (uint256) {
        year -= 1;
        return year / 4 - year / 100 + year / 400;
    }

    function getDaysInMonth(uint8 month, uint16 year) internal pure returns (uint8) {
        if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
            return 31;
        } else if (month == 4 || month == 6 || month == 9 || month == 11) {
            return 30;
        } else if (isLeapYear(year)) {
            return 29;
        } else {
            return 28;
        }
    }
}

// SPDX-License-Identifier: MIT

/**  vesting Contract */
/** Author : Aceson ( Vesting Contract 2022.8) */

pragma solidity ^0.8.15;

import "lib/openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";
import "lib/openzeppelin-contracts-upgradeable/contracts/interfaces/IERC20Upgradeable.sol";
import "lib/openzeppelin-contracts-upgradeable/contracts/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "./interfaces/IVestingV2.sol";
import "./interfaces/IWrappedAEG.sol";
import "./libraries/DateTime.sol";

contract VestingV2 is IVestingV2, OwnableUpgradeable, DateTime {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    VestingPool[] public vestingPools;

    IERC20Upgradeable public token;
    IWrappedAEG public wrappedToken;
    address public icoContract;

    modifier optionExists(uint256 _option) {
        require(_option < vestingPools.length, "Vesting option does not exist");
        _;
    }

    modifier userInWhitelist(uint256 _option, address _wallet) {
        require(_option < vestingPools.length, "Vesting option does not exist");
        require(vestingPools[_option].hasWhitelist[_wallet].active, "User is not in whitelist");
        _;
    }

    function initialize(address _token, address _ico) external initializer {
        require(_token != address(0), "Zero address");
        require(_ico != address(0), "Zero address");
        __Ownable_init();
        __dateTimeInit();
        token = IERC20Upgradeable(_token);
        icoContract = _ico;
    }

    function addVestingStrategy(
        string memory _name,
        uint256 _cliff,
        uint256 _start,
        uint256 _duration,
        uint256 _initialUnlockPercent,
        bool _revocable,
        uint256 _interval,
        uint16 _unlockPerInterval,
        uint8 _monthGap,
        Type _type
    ) external override onlyOwner returns (bool) {
        VestingPool storage newStrategy = vestingPools.push();
        require(_initialUnlockPercent <= 1000, "Value exceeds max");

        newStrategy.cliff = _start + _cliff;
        newStrategy.name = _name;
        newStrategy.start = _start;
        newStrategy.duration = _duration;
        newStrategy.initialUnlockPercent = _initialUnlockPercent;
        newStrategy.revocable = _revocable;
        newStrategy.vestType = _type;

        if (_type == Type.Interval) {
            require(_interval > 0, "Invalid interval");
            require(_unlockPerInterval > 0 && _unlockPerInterval <= 1000, "Invalid unlock per interval");

            newStrategy.interval = _interval;
            newStrategy.unlockPerInterval = _unlockPerInterval;
        } else if (_type == Type.Monthly) {
            require(_unlockPerInterval > 0 && _unlockPerInterval <= 1000, "Invalid unlock per interval");
            require(_monthGap > 0, "Invalid month gap");

            newStrategy.unlockPerInterval = _unlockPerInterval;

            uint8 day = getDay(newStrategy.cliff);
            uint8 month = getMonth(newStrategy.cliff);
            uint16 year = getYear(newStrategy.cliff);
            uint8 hour = getHour(newStrategy.cliff);
            uint8 minute = getMinute(newStrategy.cliff);
            uint8 second = getSecond(newStrategy.cliff);

            for (uint16 i = 0; i <= 1000; i += _unlockPerInterval) {
                month += _monthGap;

                while (month > 12) {
                    month = month - 12;
                    year++;
                }

                uint256 time = toTimestamp(year, month, day, hour, minute, second);
                newStrategy.timestamps.push(time);
            }
        }

        return true;
    }

    function setVestingStrategy(
        uint256 _strategy,
        string memory _name,
        uint256 _cliff,
        uint256 _start,
        uint256 _duration,
        uint256 _initialUnlockPercent,
        bool _revocable,
        uint256 _interval,
        uint16 _unlockPerInterval
    ) external override onlyOwner returns (bool) {
        require(_strategy < vestingPools.length, "Strategy does not exist");

        VestingPool storage vest = vestingPools[_strategy];

        require(vest.vestType != Type.Monthly, "Changing monthly not supported");
        require(_initialUnlockPercent <= 1000, "Value exceeds max");

        vest.cliff = _start + _cliff;
        vest.name = _name;
        vest.start = _start;
        vest.duration = _duration;
        vest.initialUnlockPercent = _initialUnlockPercent;
        vest.revocable = _revocable;

        if (vest.vestType == Type.Interval) {
            require(_unlockPerInterval > 0 && _unlockPerInterval <= 1000, "Invalid unlock per interval");
            vest.interval = _interval;
            vest.unlockPerInterval = _unlockPerInterval;
        }

        return true;
    }

    function setToken(address _addr) external onlyOwner returns (bool) {
        require(_addr != address(0), "Zero address");
        token = IERC20Upgradeable(_addr);
        return true;
    }

    function setWrappedToken(address _addr) external onlyOwner returns (bool) {
        require(_addr != address(0), "Zero address");
        wrappedToken = IWrappedAEG(_addr);
        return true;
    }

    function setIcoContract(address _ico) external onlyOwner returns (bool) {
        require(_ico != address(0), "Zero address");
        icoContract = _ico;
        return true;
    }

    function batchAddWhitelist(
        address[] memory wallets,
        uint256[] memory amounts,
        uint256 option
    ) external onlyOwner returns (bool) {
        require(wallets.length == amounts.length, "Sizes of inputs do not match");

        for (uint256 i = 0; i < wallets.length; i++) {
            addWhitelist(wallets[i], amounts[i], option);
        }

        return true;
    }

    /**
     *
     * @dev set the address as whitelist user address
     *
     * @param {address} address of the user
     *
     * @return {bool} return status of the whitelist
     *
     */
    function setWhitelist(
        address _wallet,
        uint256 _amount,
        uint256 _option
    ) external onlyOwner userInWhitelist(_option, _wallet) returns (bool) {
        uint256 idx = vestingPools[_option].hasWhitelist[_wallet].arrIdx;
        WhitelistInfo storage info = vestingPools[_option].whitelistPool[idx];

        if (info.amount >= _amount) {
            wrappedToken.burn(_wallet, info.amount - _amount);
        } else {
            wrappedToken.mint(_wallet, _amount - info.amount);
        }

        info.amount = _amount;
        return true;
    }

    function revoke(uint256 _option, address _wallet) external onlyOwner userInWhitelist(_option, _wallet) {
        uint256 idx = vestingPools[_option].hasWhitelist[_wallet].arrIdx;
        WhitelistInfo storage whitelist = vestingPools[_option].whitelistPool[idx];

        require(vestingPools[_option].revocable, "Strategy is not revocable");
        require(!whitelist.revoke, "already revoked");

        if (calculateReleasableAmount(_option, _wallet) > 0) {
            claimDistribution(_option, _wallet);
        }

        whitelist.revoke = true;
        whitelist.revokeDate = block.timestamp;
        wrappedToken.burn(_wallet, whitelist.amount - whitelist.distributedAmount);

        emit Revoked(_wallet);
    }

    function setVesting(
        uint256 _option,
        address _wallet,
        bool _status
    ) external onlyOwner userInWhitelist(_option, _wallet) {
        uint256 idx = vestingPools[_option].hasWhitelist[_wallet].arrIdx;
        WhitelistInfo storage whitelist = vestingPools[_option].whitelistPool[idx];
        require(whitelist.disabled != _status, "Identical status");

        whitelist.disabled = _status;
        if (_status) {
            wrappedToken.burn(_wallet, whitelist.amount - whitelist.distributedAmount);
        } else {
            wrappedToken.mint(_wallet, whitelist.amount - whitelist.distributedAmount);
        }

        emit StatusChanged(_wallet, _status);
    }

    function transferToken(address _addr, uint256 _amount) external onlyOwner returns (bool) {
        IERC20Upgradeable _token = IERC20Upgradeable(_addr);
        bool success = _token.transfer(address(owner()), _amount);
        return success;
    }

    function getWhitelist(
        uint256 _option,
        address _wallet
    ) external view userInWhitelist(_option, _wallet) returns (WhitelistInfo memory) {
        uint256 idx = vestingPools[_option].hasWhitelist[_wallet].arrIdx;
        return vestingPools[_option].whitelistPool[idx];
    }

    function getAllVestingPools() external view returns (VestingInfo[] memory) {
        VestingInfo[] memory infoArr = new VestingInfo[](vestingPools.length);

        for (uint256 i = 0; i < vestingPools.length; i++) {
            infoArr[i] = getVestingInfo(i);
        }

        return infoArr;
    }

    function getTotalToken(address _addr) external view returns (uint256) {
        IERC20Upgradeable _token = IERC20Upgradeable(_addr);
        return _token.balanceOf(address(this));
    }

    function hasWhitelist(uint256 _option, address _wallet) external view returns (bool) {
        return vestingPools[_option].hasWhitelist[_wallet].active;
    }

    function getVestAmount(uint256 _option, address _wallet) external view returns (uint256) {
        return calculateVestAmount(_option, _wallet);
    }

    function getReleasableAmount(uint256 _option, address _wallet) external view returns (uint256) {
        return calculateReleasableAmount(_option, _wallet);
    }

    function getWhitelistPool(uint256 _option) external view optionExists(_option) returns (WhitelistInfo[] memory) {
        return vestingPools[_option].whitelistPool;
    }

    function claimDistribution(uint256 _option, address _wallet) public returns (bool) {
        uint256 idx = vestingPools[_option].hasWhitelist[_wallet].arrIdx;
        WhitelistInfo storage whitelist = vestingPools[_option].whitelistPool[idx];

        require(!whitelist.disabled, "User is disabled from claiming token");

        uint256 releaseAmount = calculateReleasableAmount(_option, _wallet);

        require(releaseAmount > 0, "Zero amount to claim");

        whitelist.distributedAmount = whitelist.distributedAmount + releaseAmount;

        token.safeTransfer(_wallet, releaseAmount);

        wrappedToken.burn(_wallet, releaseAmount);

        emit Claim(_wallet, releaseAmount, _option, block.timestamp);

        return true;
    }

    function addWhitelist(
        address _wallet,
        uint256 _amount,
        uint256 _option
    ) public optionExists(_option) returns (bool) {
        require(msg.sender == owner() || msg.sender == icoContract, "Incorrect access");
        HasWhitelist storage whitelist = vestingPools[_option].hasWhitelist[_wallet];
        require(msg.sender == icoContract || !whitelist.active, "Use setWhitelist Function");
        WhitelistInfo[] storage pool = vestingPools[_option].whitelistPool;

        if (whitelist.active) {
            wrappedToken.mint(_wallet, _amount - pool[whitelist.arrIdx].amount);
            pool[whitelist.arrIdx].amount = _amount;
        } else {
            whitelist.active = true;
            whitelist.arrIdx = pool.length;

            pool.push(
                WhitelistInfo({
                    wallet: _wallet,
                    amount: _amount,
                    distributedAmount: 0,
                    joinDate: block.timestamp,
                    revokeDate: 0,
                    revoke: false,
                    disabled: false
                })
            );

            wrappedToken.mint(_wallet, _amount);
            emit AddWhitelist(_wallet);
        }

        return true;
    }

    function getVestingInfo(uint256 _strategy) public view optionExists(_strategy) returns (VestingInfo memory) {
        return
            VestingInfo({
                name: vestingPools[_strategy].name,
                cliff: vestingPools[_strategy].cliff,
                start: vestingPools[_strategy].start,
                duration: vestingPools[_strategy].duration,
                initialUnlockPercent: vestingPools[_strategy].initialUnlockPercent,
                revocable: vestingPools[_strategy].revocable,
                vestType: vestingPools[_strategy].vestType,
                interval: vestingPools[_strategy].interval,
                unlockPerInterval: vestingPools[_strategy].unlockPerInterval,
                timestamps: vestingPools[_strategy].timestamps
            });
    }

    function calculateVestAmount(
        uint256 _option,
        address _wallet
    ) internal view userInWhitelist(_option, _wallet) returns (uint256 amount) {
        uint256 idx = vestingPools[_option].hasWhitelist[_wallet].arrIdx;
        WhitelistInfo memory whitelist = vestingPools[_option].whitelistPool[idx];
        VestingPool storage vest = vestingPools[_option];

        // initial unlock
        uint256 initial = (whitelist.amount * vest.initialUnlockPercent) / 1000;

        if (whitelist.revoke) {
            return whitelist.distributedAmount;
        }

        if (block.timestamp < vest.start) {
            return 0;
        } else if (block.timestamp >= vest.start && block.timestamp < vest.cliff) {
            return initial;
        } else if (block.timestamp >= vest.cliff) {
            if (vestingPools[_option].vestType == Type.Interval) {
                return calculateVestAmountForInterval(whitelist, vest);
            } else if (vestingPools[_option].vestType == Type.Linear) {
                return calculateVestAmountForLinear(whitelist, vest);
            } else {
                return calculateVestAmountForMonthly(whitelist, vest);
            }
        }
    }

    function calculateVestAmountForLinear(
        WhitelistInfo memory whitelist,
        VestingPool storage vest
    ) internal view returns (uint256) {
        uint256 initial = (whitelist.amount * vest.initialUnlockPercent) / 1000;

        uint256 remaining = whitelist.amount - initial;

        if (block.timestamp >= vest.cliff + vest.duration) {
            return whitelist.amount;
        } else {
            return initial + ((remaining * (block.timestamp - vest.cliff)) / vest.duration);
        }
    }

    function calculateVestAmountForInterval(
        WhitelistInfo memory whitelist,
        VestingPool storage vest
    ) internal view returns (uint256) {
        uint256 initial = (whitelist.amount * vest.initialUnlockPercent) / 1000;
        uint256 remaining = whitelist.amount - initial;

        uint256 totalUnlocked = ((block.timestamp - vest.cliff) * vest.unlockPerInterval) / vest.interval;

        if (totalUnlocked >= 1000) {
            return whitelist.amount;
        } else {
            return initial + ((remaining * totalUnlocked) / 1000);
        }
    }

    function calculateVestAmountForMonthly(
        WhitelistInfo memory whitelist,
        VestingPool storage vest
    ) internal view returns (uint256) {
        uint256 initial = (whitelist.amount * vest.initialUnlockPercent) / 1000;
        uint256 remaining = whitelist.amount - initial;

        if (block.timestamp > vest.timestamps[vest.timestamps.length - 1]) {
            return whitelist.amount;
        } else {
            uint256 multi = findCurrentTimestamp(vest.timestamps, block.timestamp);
            uint256 totalUnlocked = multi * vest.unlockPerInterval;

            return initial + ((remaining * totalUnlocked) / 1000);
        }
    }

    function calculateReleasableAmount(
        uint256 _option,
        address _wallet
    ) internal view userInWhitelist(_option, _wallet) returns (uint256) {
        uint256 idx = vestingPools[_option].hasWhitelist[_wallet].arrIdx;
        return calculateVestAmount(_option, _wallet) - vestingPools[_option].whitelistPool[idx].distributedAmount;
    }

    function findCurrentTimestamp(uint256[] memory timestamps, uint256 target) internal pure returns (uint256 pos) {
        uint256 last = timestamps.length;
        uint256 first = 0;
        uint256 mid = 0;

        if (target < timestamps[first]) {
            return 0;
        }

        if (target >= timestamps[last - 1]) {
            return last - 1;
        }

        while (first < last) {
            mid = (first + last) / 2;

            if (timestamps[mid] == target) {
                return mid + 1;
            }

            if (target < timestamps[mid]) {
                if (mid > 0 && target > timestamps[mid - 1]) {
                    return mid;
                }

                last = mid;
            } else {
                if (mid < last - 1 && target < timestamps[mid + 1]) {
                    return mid + 1;
                }

                first = mid + 1;
            }
        }
        return mid + 1;
    }
}