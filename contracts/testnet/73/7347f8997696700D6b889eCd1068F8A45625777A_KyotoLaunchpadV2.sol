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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/cryptography/MerkleProof.sol)

pragma solidity ^0.8.0;

/**
 * @dev These functions deal with verification of Merkle Tree proofs.
 *
 * The tree and the proofs can be generated using our
 * https://github.com/OpenZeppelin/merkle-tree[JavaScript library].
 * You will find a quickstart guide in the readme.
 *
 * WARNING: You should avoid using leaf values that are 64 bytes long prior to
 * hashing, or use a hash function other than keccak256 for hashing leaves.
 * This is because the concatenation of a sorted pair of internal nodes in
 * the merkle tree could be reinterpreted as a leaf value.
 * OpenZeppelin's JavaScript library generates merkle trees that are safe
 * against this attack out of the box.
 */
library MerkleProofUpgradeable {
    /**
     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree
     * defined by `root`. For this, a `proof` must be provided, containing
     * sibling hashes on the branch from the leaf to the root of the tree. Each
     * pair of leaves and each pair of pre-images are assumed to be sorted.
     */
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    /**
     * @dev Calldata version of {verify}
     *
     * _Available since v4.7._
     */
    function verifyCalldata(
        bytes32[] calldata proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return processProofCalldata(proof, leaf) == root;
    }

    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merkle tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. When processing the proof, the pairs
     * of leafs & pre-images are assumed to be sorted.
     *
     * _Available since v4.4._
     */
    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

    /**
     * @dev Calldata version of {processProof}
     *
     * _Available since v4.7._
     */
    function processProofCalldata(bytes32[] calldata proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

    /**
     * @dev Returns true if the `leaves` can be simultaneously proven to be a part of a merkle tree defined by
     * `root`, according to `proof` and `proofFlags` as described in {processMultiProof}.
     *
     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * _Available since v4.7._
     */
    function multiProofVerify(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32 root,
        bytes32[] memory leaves
    ) internal pure returns (bool) {
        return processMultiProof(proof, proofFlags, leaves) == root;
    }

    /**
     * @dev Calldata version of {multiProofVerify}
     *
     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * _Available since v4.7._
     */
    function multiProofVerifyCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32 root,
        bytes32[] memory leaves
    ) internal pure returns (bool) {
        return processMultiProofCalldata(proof, proofFlags, leaves) == root;
    }

    /**
     * @dev Returns the root of a tree reconstructed from `leaves` and sibling nodes in `proof`. The reconstruction
     * proceeds by incrementally reconstructing all inner nodes by combining a leaf/inner node with either another
     * leaf/inner node or a proof sibling node, depending on whether each `proofFlags` item is true or false
     * respectively.
     *
     * CAUTION: Not all merkle trees admit multiproofs. To use multiproofs, it is sufficient to ensure that: 1) the tree
     * is complete (but not necessarily perfect), 2) the leaves to be proven are in the opposite order they are in the
     * tree (i.e., as seen from right to left starting at the deepest layer and continuing at the next layer).
     *
     * _Available since v4.7._
     */
    function processMultiProof(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
        // This function rebuild the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 totalHashes = proofFlags.length;

        // Check proof validity.
        require(leavesLen + proof.length - 1 == totalHashes, "MerkleProof: invalid multiproof");

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value for the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i] ? leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++] : proof[proofPos++];
            hashes[i] = _hashPair(a, b);
        }

        if (totalHashes > 0) {
            return hashes[totalHashes - 1];
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }

    /**
     * @dev Calldata version of {processMultiProof}.
     *
     * CAUTION: Not all merkle trees admit multiproofs. See {processMultiProof} for details.
     *
     * _Available since v4.7._
     */
    function processMultiProofCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
        // This function rebuild the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 totalHashes = proofFlags.length;

        // Check proof validity.
        require(leavesLen + proof.length - 1 == totalHashes, "MerkleProof: invalid multiproof");

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value for the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i] ? leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++] : proof[proofPos++];
            hashes[i] = _hashPair(a, b);
        }

        if (totalHashes > 0) {
            return hashes[totalHashes - 1];
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }

    function _hashPair(bytes32 a, bytes32 b) private pure returns (bytes32) {
        return a < b ? _efficientHash(a, b) : _efficientHash(b, a);
    }

    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/MerkleProofUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/IERC20MetadataUpgradeable.sol";

contract KyotoLaunchpadV2 is ReentrancyGuardUpgradeable {

    using SafeERC20Upgradeable for IERC20Upgradeable;
    uint256 private constant PERCENT_DENOMINATOR = 10000;

    struct Project {
        address projectOwner; // Address of the Project owner
        address paymentToken; // Address of the payment token
        uint256 targetAmount; // Funds targeted to be raised for the project
        uint256 minInvestmentAmount; // Minimum amount of payment token that can be invested
        address projectToken; // Address of the Project token
        uint256 tokensForDistribution; // Number of tokens to be distributed
        uint256 tokenPrice; // Token price in payment token (Decimals same as payment token)
        uint256 winnersOutTime; // Timestamp at which winners are announced
        uint256 projectOpenTime; // Timestamp at which the Project is open for investment
        uint256 projectCloseTime; // Timestamp at which the Project is closed
        bool cancelled; // Boolean indicating if Project is cancelled
    }

    struct ProjectInvestment {
        uint256 totalInvestment; // Total investment in payment token
        uint256 totalProjectTokensClaimed; // Total number of Project tokens claimed
        uint256 totalInvestors; // Total number of investors
        bool collected; // Boolean indicating if the investment raised in Project collected
    }

    struct Investor {
        uint256 investment; // Amount of payment tokens invested by the investor
        bool claimed; // Boolean indicating if user has claimed Project tokens
        bool refunded; // Boolean indicating if user is refunded
    }

    address public owner; // Owner of the Smart Contract
    address public potentialOwner; // Potential owner's address
    uint256 public feePercentage; // Percentage of Funds raised to be paid as fee
    uint256 public BNBFromFailedTransfers; // BNB left in the contract from failed transfers

    mapping(string => Project) private _projects; // Project ID => Project{}

    mapping(string => ProjectInvestment) private _projectInvestments; // Project ID => ProjectInvestment{}

    mapping(string => bytes32) private _projectMerkleRoots; // IDO ID => Its Merkle Root

    mapping(string => mapping(address => Investor)) private _projectInvestors; // Project ID => userAddress => Investor{}

    mapping(address => bool) private _paymentSupported; // tokenAddress => Is token supported as payment

    mapping(bytes32 => mapping(address => bool)) private _roles; // role => walletAddress => status

    bytes32 private constant ADMIN = keccak256(abi.encodePacked("ADMIN"));

    /* Events */
    event OwnerChange(address newOwner);
    event NominateOwner(address potentialOwner);
    event SetFeePercentage(uint256 feePercentage);
    event AddAdmin(address adminAddress);
    event RevokeAdmin(address adminAddress);
    event SetMerkleRoot(string projectID, bytes32 merkleRoot);
    event AddPaymentToken(address indexed paymentToken);
    event RemovePaymentToken(address indexed paymentToken);
    event ProjectAdd(
        string projectID,
        address projectOwner,
        address projectToken
    );
    event ProjectEdit(string projectID);
    event ProjectCancel(string projectID);
    event ProjectInvestmentCollect(string projectID);
    event ProjectInvest(
        string projectID,
        address indexed investor,
        uint256 investment
    );
    event ProjectInvestmentClaim(
        string projectID,
        address indexed investor,
        uint256 tokenAmount
    );
    event ProjectInvestmentRefund(
        string projectID,
        address indexed investor,
        uint256 refundAmount
    );
    event TransferOfBNBFail(address indexed receiver, uint256 indexed amount);

    /* Modifiers */
    modifier onlyOwner() {
        require(owner == msg.sender, "KyotoLaunchpad: Only owner allowed");
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == owner || _roles[ADMIN][msg.sender],
        "KyotoLaunchpad: not authorized");
        _;
    }

    modifier onlyValidProject(string calldata projectID) {
        require(projectExist(projectID), "KyotoLaunchpad: invalid Project");
        _;
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() public initializer {
        owner = msg.sender;
    }

    /* Owner Functions */

    /** @notice This internal function is used to add an address as an admin
        @dev Only the platform owner can call this function
        @param role Role to be granted
        @param newAdmin Address of the new admin
     */
    function _addAdmin(bytes32 role, address newAdmin) internal {
        require(
            newAdmin != address(0),
            "KyotoLaunchpad: admin address zero"
        );
        _roles[role][newAdmin] = true;
        emit AddAdmin(newAdmin);
    }

    /** @notice This internal function is used to remove an admin
        @dev Only the platform owner can call this function
        @param role Role to be revoked
        @param adminAddress Address of the admin
     */
    function _removeAdmin(bytes32 role, address adminAddress) internal {
        require(
            adminAddress != address(0),
            "KyotoLaunchpad: admin address zero"
        );
        _roles[role][adminAddress] = false;
        emit RevokeAdmin(adminAddress);
    }

    /** @notice This function is used to add an address as an admin
        @dev Only the platform owner can call this function
        @param newAdmin Address of the new admin
     */
    function grantRole(address newAdmin) external onlyOwner {
        _addAdmin(ADMIN, newAdmin);
    }

    /** @notice This function is used to remove an admin
        @dev Only the platform owner can call this function
        @param adminAddress Address of the admin
     */
    function revokeRole(address adminAddress) external onlyOwner {
        _removeAdmin(ADMIN, adminAddress);
    }

    /**
     * @notice This function is used to add a potential owner of the contract
     * @dev Only the owner can call this function
     * @param _potentialOwner Address of the potential owner
     */
    function addPotentialOwner(address _potentialOwner) external onlyOwner {
        require(
            _potentialOwner != address(0),
            "KyotoLaunchpad: potential owner zero"
        );
        require(
            _potentialOwner != owner,
            "KyotoLaunchpad: potential owner same as owner"
        );
        potentialOwner = _potentialOwner;
        emit NominateOwner(_potentialOwner);
    }

    /**
     * @notice This function is used to accept ownership of the contract
     */
    function acceptOwnership() external {
        require(
            msg.sender == potentialOwner,
            "KyotoLaunchpad: only potential owner"
        );
        owner = potentialOwner;
        delete potentialOwner;
        emit OwnerChange(owner);
    }

    /**
     * @notice This method is used to set Merkle Root of an IDO
     * @dev This method can only be called by the contract owner
     * @param projectID ID of the IDO
     * @param merkleRoot Merkle Root of the IDO
     */
    function addMerkleRoot(string calldata projectID, bytes32 merkleRoot) 
        external 
        onlyValidProject(projectID)
        onlyAdmin(){
        
        require(
            _projects[projectID].winnersOutTime <= block.timestamp,
            "KyotoLaunchPad: cannot update before whitelisting closes"
        );
        require(
            _projectMerkleRoots[projectID] == bytes32(0),
            "KyotoLaunchPad: merkle root already added"
        );
        _projectMerkleRoots[projectID] = merkleRoot;
        emit SetMerkleRoot(projectID, merkleRoot);
    }

    /**
     * @notice This method is used to set commission percentage for the launchpad
     * @param _feePercentage Percentage from raised funds to be set as fee
     */
    function setFee(uint256 _feePercentage) external onlyAdmin(){

        require(
            _feePercentage <= 10000,
            "KyotoLaunchpad: fee Percentage should be less than 10000"
        );
        feePercentage = _feePercentage;
        emit SetFeePercentage(_feePercentage);
    }

    /* Payment Token */
    /**
     * @notice This method is used to add Payment token
     * @param _paymentToken Address of payment token to be added
     */
    function addPaymentToken(address _paymentToken) external onlyAdmin(){
        require(
            !_paymentSupported[_paymentToken],
            "KyotoLaunchpad: token already added"
        );
        _paymentSupported[_paymentToken] = true;
        emit AddPaymentToken(_paymentToken);
    }

    /**
     * @notice This method is used to remove Payment token
     * @param _paymentToken Address of payment token to be removed
     */
    function removePaymentToken(address _paymentToken) external onlyAdmin(){
        require(
            _paymentSupported[_paymentToken],
            "KyotoLaunchpad: token not added"
        );
        _paymentSupported[_paymentToken] = false;
        emit RemovePaymentToken(_paymentToken);
    }

    /**
     * @notice This method is used to check if a payment token is supported
     * @param _paymentToken Address of the token
     */
    function isPaymentTokenSupported(address _paymentToken)
        external
        view
        returns (bool)
    {
        return _paymentSupported[_paymentToken];
    }

    /* Helper Functions */
    /**
     * @dev This helper method is used to validate whether the address is whitelisted or not
     * @param merkleRoot Merkle Root of the IDO
     * @param merkleProof Merkle Proof of the user for that IDO
     */
    function _isWhitelisted(bytes32 merkleRoot, bytes32[] calldata merkleProof)
        private
        view
        returns (bool)
    {
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        return MerkleProofUpgradeable.verify(merkleProof, merkleRoot, leaf);
    }

    /**
     * @notice Helper function to transfer tokens based on type
     * @param receiver Address of the receiver
     * @param paymentToken Address of the token to be transferred
     * @param amount Number of tokens to transfer
     */
    function transferTokens(
        address receiver,
        address paymentToken,
        uint256 amount
    ) internal {
        if (amount != 0) {
            if (paymentToken != address(0)) {
                IERC20Upgradeable(paymentToken).safeTransfer(receiver, amount);
            } else {
                (bool success, ) = payable(receiver).call{value: amount}("");
                if (!success) {
                    BNBFromFailedTransfers += amount;
                    emit TransferOfBNBFail(receiver, amount);
                }
            }
        }
    }

    /**
     * @notice Helper function to estimate Project token amount for payment
     * @param amount Amount of payment tokens
     * @param projectToken Address of the Project token
     * @param tokenPrice Price for Project token
     */
    function estimateProjectTokens(
        address projectToken,
        uint256 tokenPrice,
        uint256 amount
    ) public view returns (uint256 projectTokenCount) {
        uint256 projectTokenDecimals = uint256(
            IERC20MetadataUpgradeable(projectToken).decimals()
        );
        projectTokenCount = (amount * 10**projectTokenDecimals) / tokenPrice;
    }

    /**
     * @notice Helper function to estimate Project token amount for payment
     * @param projectID ID of the Project
     * @param amount Amount of payment tokens
     */
    function estimateProjectTokensById(
        string calldata projectID,
        uint256 amount
    )
        external
        view
        onlyValidProject(projectID)
        returns (uint256 projectTokenCount)
    {
        uint256 projectTokenDecimals = uint256(
            IERC20MetadataUpgradeable(_projects[projectID].projectToken)
                .decimals()
        );
        projectTokenCount =
            (amount * 10**projectTokenDecimals) /
            _projects[projectID].tokenPrice;
    }

    /* Project */
    /**
     * @notice This method is used to check if an Project exist
     * @param projectID ID of the Project
     */
    function projectExist(string calldata projectID)
        public
        view
        returns (bool)
    {
        return _projects[projectID].projectOwner != address(0) ? true : false;
    }

    /**
     * @notice This method is used to get Project details
     * @param projectID ID of the Project
     */
    function getProject(string calldata projectID)
        external
        view
        onlyValidProject(projectID)
        returns (Project memory)
    {
        return _projects[projectID];
    }

    /**
     * @notice This method is used to get Project Investment details
     * @param projectID ID of the Project
     */
    function getProjectInvestment(string calldata projectID)
        external
        view
        onlyValidProject(projectID)
        returns (ProjectInvestment memory)
    {
        return _projectInvestments[projectID];
    }

    /**
     * @notice This method is used to get Project Investment details of an investor
     * @param projectID ID of the Project
     * @param investor Address of the investor
     */
    function getInvestor(string calldata projectID, address investor)
        external
        view
        onlyValidProject(projectID)
        returns (Investor memory)
    {
        return _projectInvestors[projectID][investor];
    }

    /**
     * @notice This method is used to add a new Private project
     * @dev This method can only be called by the contract owner
     * @param projectID ID of the Project to be added
     * @param projectOwner Address of the Project owner
     * @param paymentToken Payment token to be used for the Project
     * @param targetAmount Targeted amount to be raised in Project
     * @param minInvestmentAmount Minimum amount of payment token that can be invested in Project
     * @param projectToken Address of Project token
     * @param tokenPrice Project token price in terms of payment token
     * @param winnersOutTime Announcement of whitelisted addresses
     * @param projectOpenTime Project open timestamp
     * @param projectCloseTime Project close timestamp
     */
    function addPrivateLaunch(
        string calldata projectID,
        address projectOwner,
        address paymentToken,
        uint256 targetAmount,
        uint256 minInvestmentAmount,
        address projectToken,
        uint256 tokenPrice,
        uint256 winnersOutTime,
        uint256 projectOpenTime,
        uint256 projectCloseTime
    ) external 
      nonReentrant
      onlyAdmin(){
        require(
            !projectExist(projectID),
            "KyotoLaunchpad: Project id already exist"
        );
        require(
            projectOwner != address(0),
            "KyotoLaunchpad: Project owner zero"
        );
        require(
            _paymentSupported[paymentToken],
            "KyotoLaunchpad: payment token not supported"
        );
        require(targetAmount != 0, "KyotoLaunchpad: target amount zero");
        require(tokenPrice != 0, "KyotoLaunchpad: token price zero");
        require(
            block.timestamp < winnersOutTime &&
                winnersOutTime <= projectOpenTime &&
                projectOpenTime < projectCloseTime,
            "KyotoLaunchpad: Project invalid timestamps"
        );

        if(projectToken != address(0)){  
            uint256 tokensForDistribution = estimateProjectTokens(
                projectToken,
                tokenPrice,
                targetAmount);

            _projects[projectID] = Project(
            projectOwner,
            paymentToken,
            targetAmount,
            minInvestmentAmount,
            projectToken,
            tokensForDistribution,
            tokenPrice,
            winnersOutTime,
            projectOpenTime,
            projectCloseTime,
            false
        );

            IERC20Upgradeable(projectToken).safeTransferFrom(
                projectOwner,
                address(this),
                tokensForDistribution
            );
        } else {
            _projects[projectID] = Project(
            projectOwner,
            paymentToken,
            targetAmount,
            minInvestmentAmount,
            projectToken,
            0,
            tokenPrice,
            winnersOutTime,
            projectOpenTime,
            projectCloseTime,
            false
            );
        }    
        emit ProjectAdd(projectID, projectOwner, projectToken);
    }

    /**
     * @notice This method is used to add a new Public project
     * @dev This method can only be called by the contract owner
     * @param projectID ID of the Project to be added
     * @param projectOwner Address of the Project owner
     * @param paymentToken Payment token to be used for the Project
     * @param targetAmount Targeted amount to be raised in Project
     * @param minInvestmentAmount Minimum amount of payment token that can be invested in Project
     * @param projectToken Address of Project token
     * @param tokenPrice Project token price in terms of payment token
     * @param presaleStartTime Beginning of pre-sale round. 0 for public launch
     * @param projectOpenTime Project open timestamp
     * @param projectCloseTime Project close timestamp
     */
    function addPublicLaunch(
        string calldata projectID,
        address projectOwner,
        address paymentToken,
        uint256 targetAmount,
        uint256 minInvestmentAmount,
        address projectToken,
        uint256 tokenPrice,
        uint256 presaleStartTime,
        uint256 projectOpenTime,
        uint256 projectCloseTime
    ) external 
      onlyAdmin()
      nonReentrant{
        require(
            !projectExist(projectID),
            "KyotoLaunchpad: Project id already exist"
        );
        require(
            projectOwner != address(0),
            "KyotoLaunchpad: Project owner zero"
        );
        require(
            _paymentSupported[paymentToken],
            "KyotoLaunchpad: payment token not supported"
        );
        require(targetAmount != 0, "KyotoLaunchpad: target amount zero");
        require(tokenPrice != 0, "KyotoLaunchpad: token price zero");
        require(presaleStartTime == 0, "KyotoLaunchpad: presale time not zero");
        require(block.timestamp < projectOpenTime 
                && projectOpenTime < projectCloseTime,
            "KyotoLaunchpad: Project invalid timestamps"
        );

        if(projectToken != address(0)){  
            uint256 tokensForDistribution = estimateProjectTokens(
                projectToken,
                tokenPrice,
                targetAmount);

            _projects[projectID] = Project(
            projectOwner,
            paymentToken,
            targetAmount,
            minInvestmentAmount,
            projectToken,
            tokensForDistribution,
            tokenPrice,
            presaleStartTime,
            projectOpenTime,
            projectCloseTime,
            false
        );

            IERC20Upgradeable(projectToken).safeTransferFrom(
                projectOwner,
                address(this),
                tokensForDistribution
            );
        } else {
            _projects[projectID] = Project(
            projectOwner,
            paymentToken,
            targetAmount,
            minInvestmentAmount,
            projectToken,
            0,
            tokenPrice,
            presaleStartTime,
            projectOpenTime,
            projectCloseTime,
            false
            );
        }   
        emit ProjectAdd(projectID, projectOwner, projectToken);
    }

    /**
     * @notice This method is used to add a new project with presale round
     * @dev This method can only be called by the contract owner
     * @param projectID ID of the Project to be added
     * @param projectOwner Address of the Project owner
     * @param paymentToken Payment token to be used for the Project
     * @param targetAmount Targeted amount to be raised in Project
     * @param minInvestmentAmount Minimum amount of payment token that can be invested in Project
     * @param projectToken Address of Project token
     * @param tokenPrice Project token price in terms of payment token
     * @param presaleStartTime Beginning of pre-sale round. 0 for public launch
     * @param projectOpenTime Project open timestamp
     * @param projectCloseTime Project close timestamp
     */
    function addPresaleLaunch(
        string calldata projectID,
        address projectOwner,
        address paymentToken,
        uint256 targetAmount,
        uint256 minInvestmentAmount,
        address projectToken,
        uint256 tokenPrice,
        uint256 presaleStartTime,
        uint256 projectOpenTime,
        uint256 projectCloseTime
    ) external 
      onlyAdmin()
      nonReentrant{
        require(
            !projectExist(projectID),
            "KyotoLaunchpad: Project id already exist"
        );
        require(
            projectOwner != address(0),
            "KyotoLaunchpad: Project owner zero"
        );
        require(
            _paymentSupported[paymentToken],
            "KyotoLaunchpad: payment token not supported"
        );
        require(targetAmount != 0, "KyotoLaunchpad: target amount zero");
        require(tokenPrice != 0, "KyotoLaunchpad: token price zero");
        require(
            block.timestamp < presaleStartTime &&
                presaleStartTime <= projectOpenTime &&
                projectOpenTime < projectCloseTime,
            "KyotoLaunchpad: Project invalid timestamps"
        );

        if(projectToken != address(0)){  
            uint256 tokensForDistribution = estimateProjectTokens(
                projectToken,
                tokenPrice,
                targetAmount);

            _projects[projectID] = Project(
            projectOwner,
            paymentToken,
            targetAmount,
            minInvestmentAmount,
            projectToken,
            tokensForDistribution,
            tokenPrice,
            presaleStartTime,
            projectOpenTime,
            projectCloseTime,
            false
        );

            IERC20Upgradeable(projectToken).safeTransferFrom(
                projectOwner,
                address(this),
                tokensForDistribution
            );
        } else {
            _projects[projectID] = Project(
            projectOwner,
            paymentToken,
            targetAmount,
            minInvestmentAmount,
            projectToken,
            0,
            tokenPrice,
            presaleStartTime,
            projectOpenTime,
            projectCloseTime,
            false
            );
        }    
        emit ProjectAdd(projectID, projectOwner, projectToken);
    }

    /**
     * @notice This method is used to edit a Private project
     * @dev This method can only be called by the contract owner
     * @param projectID ID of the Project to be added
     * @param projectOwner Address of the Project owner
     * @param paymentToken Payment token to be used for the Project
     * @param targetAmount Targeted amount to be raised in Project
     * @param minInvestmentAmount Minimum amount of payment token that can be invested in Project
     * @param projectToken Address of Project token
     * @param tokenPrice Project token price in terms of payment token
     * @param winnersOutTime Announcement of whitelisted addresses
     * @param projectOpenTime Project open timestamp
     * @param projectCloseTime Project close timestamp
     */
    function editPrivateProject(
        string calldata projectID,
        address projectOwner,
        address paymentToken,
        uint256 targetAmount,
        uint256 minInvestmentAmount,
        address projectToken,
        uint256 tokenPrice,
        uint256 winnersOutTime,
        uint256 projectOpenTime,
        uint256 projectCloseTime
    ) external 
      onlyAdmin()
      nonReentrant{
        require(
            projectExist(projectID),
            "KyotoLaunchpad: Project does not exist"
        );
        require(
            projectOwner != address(0),
            "KyotoLaunchpad: Project owner zero"
        );
        require(
            _paymentSupported[paymentToken],
            "KyotoLaunchpad: payment token not supported"
        );
        require(targetAmount != 0, "KyotoLaunchpad: target amount zero");
        require(tokenPrice != 0, "KyotoLaunchpad: token price zero");

        if(projectToken != address(0) && _projects[projectID].projectToken == address(0)){  
            uint256 tokensForDistribution = estimateProjectTokens(
                projectToken,
                tokenPrice,
                targetAmount);

            _projects[projectID] = Project(
            projectOwner,
            paymentToken,
            targetAmount,
            minInvestmentAmount,
            projectToken,
            tokensForDistribution,
            tokenPrice,
            winnersOutTime,
            projectOpenTime,
            projectCloseTime,
            false
        );

            IERC20Upgradeable(projectToken).safeTransferFrom(
                projectOwner,
                address(this),
                tokensForDistribution
            );
        } else {
            _projects[projectID] = Project(
            projectOwner,
            paymentToken,
            targetAmount,
            minInvestmentAmount,
            projectToken,
            0,
            tokenPrice,
            winnersOutTime,
            projectOpenTime,
            projectCloseTime,
            false
            );
        }   
        emit ProjectEdit(projectID);
    }

    /**
     * @notice This method is used to edit a Public project
     * @dev This method can only be called by the contract owner
     * @param projectID ID of the Project to be added
     * @param projectOwner Address of the Project owner
     * @param paymentToken Payment token to be used for the Project
     * @param targetAmount Targeted amount to be raised in Project
     * @param minInvestmentAmount Minimum amount of payment token that can be invested in Project
     * @param projectToken Address of Project token
     * @param tokenPrice Project token price in terms of payment token
     * @param presaleStartTime Beginning of pre-sale round. 0 for public launch
     * @param projectOpenTime Project open timestamp
     * @param projectCloseTime Project close timestamp
     */
    function editPublicProject(
        string calldata projectID,
        address projectOwner,
        address paymentToken,
        uint256 targetAmount,
        uint256 minInvestmentAmount,
        address projectToken,
        uint256 tokenPrice,
        uint256 presaleStartTime,
        uint256 projectOpenTime,
        uint256 projectCloseTime
    ) external
      onlyAdmin()
      nonReentrant{
        require(
            projectExist(projectID),
            "KyotoLaunchpad: Project does not exist"
        );
        require(
            projectOwner != address(0),
            "KyotoLaunchpad: Project owner zero"
        );
        require(
            _paymentSupported[paymentToken],
            "KyotoLaunchpad: payment token not supported"
        );
        require(targetAmount != 0, "KyotoLaunchpad: target amount zero");
        require(tokenPrice != 0, "KyotoLaunchpad: token price zero");

        if(projectToken != address(0) && _projects[projectID].projectToken == address(0)){  
            uint256 tokensForDistribution = estimateProjectTokens(
                projectToken,
                tokenPrice,
                targetAmount);

            _projects[projectID] = Project(
            projectOwner,
            paymentToken,
            targetAmount,
            minInvestmentAmount,
            projectToken,
            tokensForDistribution,
            tokenPrice,
            presaleStartTime,
            projectOpenTime,
            projectCloseTime,
            false
        );

            IERC20Upgradeable(projectToken).safeTransferFrom(
                projectOwner,
                address(this),
                tokensForDistribution
            );
        } else {
            _projects[projectID] = Project(
            projectOwner,
            paymentToken,
            targetAmount,
            minInvestmentAmount,
            projectToken,
            0,
            tokenPrice,
            presaleStartTime,
            projectOpenTime,
            projectCloseTime,
            false
            );
        }   
        emit ProjectEdit(projectID);
      }

    /**
     * @notice This method is used to edit a project with pre sale round
     * @dev This method can only be called by the contract owner
     * @param projectID ID of the Project to be added
     * @param projectOwner Address of the Project owner
     * @param paymentToken Payment token to be used for the Project
     * @param targetAmount Targeted amount to be raised in Project
     * @param minInvestmentAmount Minimum amount of payment token that can be invested in Project
     * @param projectToken Address of Project token
     * @param tokenPrice Project token price in terms of payment token
     * @param presaleStartTime Beginning of pre-sale round. 0 for public launch
     * @param projectOpenTime Project open timestamp
     * @param projectCloseTime Project close timestamp
     */
    function editPresaleProject(
        string calldata projectID,
        address projectOwner,
        address paymentToken,
        uint256 targetAmount,
        uint256 minInvestmentAmount,
        address projectToken,
        uint256 tokenPrice,
        uint256 presaleStartTime,
        uint256 projectOpenTime,
        uint256 projectCloseTime
    ) external
      onlyAdmin()
      nonReentrant{
        require(
            projectExist(projectID),
            "KyotoLaunchpad: Project does not exist"
        );
        require(
            projectOwner != address(0),
            "KyotoLaunchpad: Project owner zero"
        );
        require(
            _paymentSupported[paymentToken],
            "KyotoLaunchpad: payment token not supported"
        );
        require(targetAmount != 0, "KyotoLaunchpad: target amount zero");
        require(tokenPrice != 0, "KyotoLaunchpad: token price zero");

        if(projectToken != address(0) && _projects[projectID].projectToken == address(0)){  
            uint256 tokensForDistribution = estimateProjectTokens(
                projectToken,
                tokenPrice,
                targetAmount);

            _projects[projectID] = Project(
            projectOwner,
            paymentToken,
            targetAmount,
            minInvestmentAmount,
            projectToken,
            tokensForDistribution,
            tokenPrice,
            presaleStartTime,
            projectOpenTime,
            projectCloseTime,
            false
        );

            IERC20Upgradeable(projectToken).safeTransferFrom(
                projectOwner,
                address(this),
                tokensForDistribution
            );
        } else {
            _projects[projectID] = Project(
            projectOwner,
            paymentToken,
            targetAmount,
            minInvestmentAmount,
            projectToken,
            0,
            tokenPrice,
            presaleStartTime,
            projectOpenTime,
            projectCloseTime,
            false
            );
        }    
        emit ProjectEdit(projectID);
      }

    /**
     * @notice This method is used to cancel an Project
     * @dev This method can only be called by the contract owner
     * @param projectID ID of the Project
     */
    function cancelIDO(string calldata projectID)
        external
        onlyValidProject(projectID)
        onlyAdmin()
    {
        Project memory project = _projects[projectID];
        require(
            !project.cancelled,
            "KyotoLaunchpad: Project already cancelled"
        );
        require(
            block.timestamp < project.projectCloseTime,
            "KyotoLaunchpad: Project is closed"
        );

        _projects[projectID].cancelled = true;
        if(project.projectToken != address(0)){
            IERC20Upgradeable(project.projectToken).safeTransfer(
                project.projectOwner,
                project.tokensForDistribution
            );
        }
        emit ProjectCancel(projectID);
    }

    /**
     * @notice This method is used to distribute investment raised in Project
     * @dev This method can only be called by the contract owner
     * @param projectID ID of the Project
     */
    function collectIDOInvestment(string calldata projectID)
        external
        onlyValidProject(projectID)
        onlyAdmin()
    {
        Project memory project = _projects[projectID];
        require(project.projectToken != address(0),
                "KyotoLaunchpad: Project token not added yet");
        require(!project.cancelled, "KyotoLaunchpad: Project is cancelled");
        require(
            block.timestamp > project.projectCloseTime,
            "KyotoLaunchpad: Project is open"
        );

        ProjectInvestment memory projectInvestment = _projectInvestments[
            projectID
        ];

        require(
            !projectInvestment.collected,
            "KyotoLaunchpad: Project investment already collected"
        );

        _projectInvestments[projectID].collected = true;

        if(projectInvestment.totalInvestment == 0){
            IERC20Upgradeable(project.projectToken).safeTransfer(
            project.projectOwner,
            project.tokensForDistribution
        );
        }
        else{
            uint256 platformShare = feePercentage == 0
                ? 0
                : (feePercentage * projectInvestment.totalInvestment) /
                    PERCENT_DENOMINATOR;

            _projectInvestments[projectID].collected = true;

            transferTokens(owner, project.paymentToken, platformShare);
            transferTokens(
                project.projectOwner,
                project.paymentToken,
                projectInvestment.totalInvestment - platformShare
            );

            uint256 projectTokensLeftover = project.tokensForDistribution -
                estimateProjectTokens(
                    project.projectToken,
                    project.tokenPrice,
                    projectInvestment.totalInvestment
                );
            transferTokens(
                project.projectOwner,
                project.projectToken,
                projectTokensLeftover
            );
        } 

        emit ProjectInvestmentCollect(projectID);
    }

    /**
     * @notice This method is used to invest in a privately listed Project
     * @dev User must send _amount in order to invest in BNB
     * @dev User must be whitelisted to invest
     * @param projectID ID of the Project
     */
    function investPrivateLaunch(string calldata projectID, bytes32[] calldata merkleProof, uint256 _amount)
        external
        payable
    {
        require(
            projectExist(projectID),
            "KyotoLaunchpad: Project does not exist"
        );
        require(_amount != 0, "KyotoLaunchpad: investment zero");

        Project memory project = _projects[projectID];
        require(
            block.timestamp >= project.projectOpenTime,
            "KyotoLaunchpad: Project is not open"
        );
        require(
            block.timestamp < project.projectCloseTime,
            "KyotoLaunchpad: Project has closed"
        );
        require(!project.cancelled, "KyotoLaunchpad: Project cancelled");
        require(
            _amount >= project.minInvestmentAmount,
            "KyotoLaunchpad: amount less than minimum investment"
        );
        ProjectInvestment storage projectInvestment = _projectInvestments[
            projectID
        ];

        require(
            project.targetAmount >= projectInvestment.totalInvestment + _amount,
            "KyotoLaunchpad: amount exceeds target"
        );
        require(
            _projectMerkleRoots[projectID] != bytes32(0),
            "KyotoLaunchPad: whitelist not approved by admin yet"
        );
        require(
            _isWhitelisted(_projectMerkleRoots[projectID], merkleProof),
            "KyotoLaunchPad: user is not whitelisted"
        );

        projectInvestment.totalInvestment += _amount;
        if (_projectInvestors[projectID][msg.sender].investment == 0)
            ++projectInvestment.totalInvestors;
        _projectInvestors[projectID][msg.sender].investment += _amount;

        if (project.paymentToken == address(0)) {
            require(
                msg.value == _amount,
                "KyotoLaunchpad: msg.value not equal to amount"
            );
        } else {
            require(msg.value == 0, "KyotoLaunchpad: msg.value not zero");
            IERC20Upgradeable(project.paymentToken).safeTransferFrom(
                msg.sender,
                address(this),
                _amount
            );
        }

        emit ProjectInvest(projectID, msg.sender, _amount);
    }

    /**
     * @notice This method is used to invest in a publicly listed Project
     * @dev User must send _amount in order to invest in BNB
     * @param projectID ID of the Project
     */
    function investFairLaunch(string calldata projectID, uint256 _amount)
        external
        payable
    {
        require(
            projectExist(projectID),
            "KyotoLaunchpad: Project does not exist"
        );
        require(_amount != 0, "KyotoLaunchpad: investment zero");

        Project memory project = _projects[projectID];
        require(
            block.timestamp >= project.projectOpenTime,
            "KyotoLaunchpad: Project is not open"
        );
        require(
            block.timestamp < project.projectCloseTime,
            "KyotoLaunchpad: Project has closed"
        );
        require(!project.cancelled, "KyotoLaunchpad: Project cancelled");
        require(
            _amount >= project.minInvestmentAmount,
            "KyotoLaunchpad: amount less than minimum investment"
        );
        ProjectInvestment storage projectInvestment = _projectInvestments[
            projectID
        ];

        require(
            project.targetAmount >= projectInvestment.totalInvestment + _amount,
            "KyotoLaunchpad: amount exceeds target"
        );

        projectInvestment.totalInvestment += _amount;
        if (_projectInvestors[projectID][msg.sender].investment == 0)
            ++projectInvestment.totalInvestors;
        _projectInvestors[projectID][msg.sender].investment += _amount;

        if (project.paymentToken == address(0)) {
            require(
                msg.value == _amount,
                "KyotoLaunchpad: msg.value not equal to amount"
            );
        } else {
            require(msg.value == 0, "KyotoLaunchpad: msg.value not zero");
            IERC20Upgradeable(project.paymentToken).safeTransferFrom(
                msg.sender,
                address(this),
                _amount
            );
        }

        emit ProjectInvest(projectID, msg.sender, _amount);
    }

    /**
     * @notice This method is used to invest in a project with a presale round
     * @dev User must send _amount in order to invest in BNB
     * @dev User must be whitelisted to invest in presale round
     * @param projectID ID of the Project
     */
    function investPresale(string calldata projectID, bytes32[] calldata merkleProof, uint256 _amount)
        external
        payable
    {
        require(
            projectExist(projectID),
            "KyotoLaunchpad: Project does not exist"
        );
        require(_amount != 0, "KyotoLaunchpad: investment zero");
        Project memory project = _projects[projectID];
        require(
            block.timestamp >= project.winnersOutTime,
            "KyotoLaunchpad: Project is not open"
        );
        if(block.timestamp >= project.winnersOutTime && block.timestamp < project.projectOpenTime){
            require(
                _projectMerkleRoots[projectID] != bytes32(0),
                "KyotoLaunchPad: whitelist not approved by admin yet"
            );
            require(
                _isWhitelisted(_projectMerkleRoots[projectID], merkleProof),
                "KyotoLaunchPad: user is not whitelisted"
            );
        }
        require(
            block.timestamp < project.projectCloseTime,
            "KyotoLaunchpad: Project closed"
        );
        require(!project.cancelled, "KyotoLaunchpad: Project cancelled");
        require(
            _amount >= project.minInvestmentAmount,
            "KyotoLaunchpad: amount less than minimum investment"
        );
        ProjectInvestment storage projectInvestment = _projectInvestments[
            projectID
        ];

        require(
            project.targetAmount >= projectInvestment.totalInvestment + _amount,
            "KyotoLaunchpad: amount exceeds target"
        );

        projectInvestment.totalInvestment += _amount;
        if (_projectInvestors[projectID][msg.sender].investment == 0)
            ++projectInvestment.totalInvestors;
        _projectInvestors[projectID][msg.sender].investment += _amount;

        if (project.paymentToken == address(0)) {
            require(
                msg.value == _amount,
                "KyotoLaunchpad: msg.value not equal to amount"
            );
        } else {
            require(msg.value == 0, "KyotoLaunchpad: msg.value not zero");
            IERC20Upgradeable(project.paymentToken).safeTransferFrom(
                msg.sender,
                address(this),
                _amount
            );
        }

        emit ProjectInvest(projectID, msg.sender, _amount);
    }

    /**
     * @notice This method is used to refund investment if Project is cancelled
     * @param projectID ID of the Project
     */
    function refundInvestment(string calldata projectID)
        external
        onlyValidProject(projectID)
    {

        Project memory project = _projects[projectID];
        require(
            project.cancelled,
            "KyotoLaunchpad: Project is not cancelled"
        );

        Investor memory user = _projectInvestors[projectID][msg.sender];
        require(!user.refunded, "KyotoLaunchpad: already refunded");
        require(user.investment != 0, "KyotoLaunchpad: no investment found");

        _projectInvestors[projectID][msg.sender].refunded = true;
        transferTokens(msg.sender, project.paymentToken, user.investment);

        emit ProjectInvestmentRefund(projectID, msg.sender, user.investment);
    }

    /**
     * @notice This method is used to claim investment if Project is closed
     * @param projectID ID of the Project
     */
    function claimIDOTokens(string calldata projectID)
        external
        onlyValidProject(projectID)
    {
        Project memory project = _projects[projectID];

        require(!project.cancelled, "KyotoLaunchpad: Project is cancelled");
        require(
            block.timestamp > project.projectCloseTime,
            "KyotoLaunchpad: Project not closed yet"
        );

        Investor memory user = _projectInvestors[projectID][msg.sender];
        require(!user.claimed, "KyotoLaunchpad: already claimed");
        require(user.investment != 0, "KyotoLaunchpad: no investment found");

        uint256 projectTokens = estimateProjectTokens(
            project.projectToken,
            project.tokenPrice,
            user.investment
        );
        _projectInvestors[projectID][msg.sender].claimed = true;
        _projectInvestments[projectID]
            .totalProjectTokensClaimed += projectTokens;

        IERC20Upgradeable(project.projectToken).safeTransfer(
            msg.sender,
            projectTokens
        );

        emit ProjectInvestmentClaim(projectID, msg.sender, projectTokens);
    }

    /**
     * @notice This method is to collect any BNB left from failed transfers.
     * @dev This method can only be called by the contract owner
     */
    function collectBNBFromFailedTransfers() external onlyAdmin(){
        uint256 bnbToSend = BNBFromFailedTransfers;
        BNBFromFailedTransfers = 0;
        (bool success, ) = payable(owner).call{value: bnbToSend}("");
        require(success, "KyotoLaunchpad: BNB transfer failed");
    }
}