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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/cryptography/draft-EIP712.sol)

pragma solidity ^0.8.0;

// EIP-712 is Final as of 2022-08-11. This file is deprecated.

import "./EIP712.sol";

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/cryptography/ECDSA.sol)

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
        InvalidSignatureV // Deprecated in v4.8
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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/cryptography/EIP712.sol)

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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @notice A delegator allows delegation.
 */
contract Delegator {
    event Delegated(address delator, address delegatee);
    mapping(address => address) public delegation;
    mapping(address => address) public reverseDelegation;

    function delegate(address to
    ) external {
        address currentDelegation = delegation[msg.sender];
        if (to == address(0)) {
            require(currentDelegation != address(0), "D: nothing to delete");
            delete delegation[msg.sender];
            delete reverseDelegation[currentDelegation];
            emit Delegated(msg.sender, address(0));
            return;
        }
        require(reverseDelegation[to] == address(0), "D: to is already delegated to other");
        require(delegation[to] == address(0), "D: to has a delegation already");
        require(currentDelegation != to, "M: nothing will change");
        delegation[msg.sender] = to;
        delete reverseDelegation[currentDelegation];
        reverseDelegation[to] = msg.sender;
        emit Delegated(msg.sender, to);
    }
}

interface IQuantumPortalAuthorityMgr {
    enum Action { NONE, FINALIZE, SLASH }
    function validateAuthoritySignature(
        Action action,
        bytes32 msgHash,
        bytes32 salt,
        uint64 expiry,
        bytes memory signature
    ) external;
    function validateAuthoritySignatureSingleSigner(
        Action action,
        bytes32 msgHash,
        bytes32 salt,
        uint64 expiry,
        bytes memory signature
    ) external returns (address[] memory signers, bool quorumComplete);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IQuantumPortalStake {
    function delegatedStakeOf(address delegatee) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IQuantumPortalAuthorityMgr.sol";
import "foundry-contracts/contracts/signature/MultiSigCheckable.sol";

/**
 @notice Authority manager, provides authority signature verification, for 
    different actions.
 */
contract QuantumPortalAuthorityMgr is IQuantumPortalAuthorityMgr, MultiSigCheckable {
    string public constant NAME = "FERRUM_QUANTUM_PORTAL_AUTHORITY_MGR";
    string public constant VERSION = "000.010";

    // signers that have signed a message
    address[] public completedSigners;

    // mapping to check if an address exists in completedSigners
    mapping(address => bool) public alreadySigned;

    // the current msgHash we are checking
    bytes32 public currentMsgHash;

    // the current quorumId we are checking
    address public currentQuorumId;

    constructor() EIP712(NAME, VERSION) {}

    bytes32 constant VALIDATE_AUTHORITY_SIGNATURE =
        keccak256("ValidateAuthoritySignature(uint256 action,bytes32 msgHash,bytes32 salt,uint64 expiry)");

    /**
     @notice Validates an authority signature
             TODO: Update to differentiate between finalize and slash. For example more
             signers requred for slash
     */
    function validateAuthoritySignature(
        Action action,
        bytes32 msgHash,
        bytes32 salt,
        uint64 expiry,
        bytes memory signature
    ) external override {
        require(action != Action.NONE, "QPAM: action required");
        require(msgHash != bytes32(0), "QPAM: msgHash required");
        require(expiry != 0, "QPAM: expiry required");
        require(salt != 0, "QPAM: salt required");
        require(expiry > block.timestamp, "QPAM: signature expired");
        bytes32 message = keccak256(abi.encode(VALIDATE_AUTHORITY_SIGNATURE, uint256(action), msgHash, salt, expiry));
        verifyUniqueSalt(message, salt, 1, signature);
    }

    /**
     @notice Validates an authority signature
             Returns true if the signature is valid and 
     */
    function validateAuthoritySignatureSingleSigner(
        Action action,
        bytes32 msgHash,
        bytes32 salt,
        uint64 expiry,
        bytes memory signature
    ) external override returns (address[] memory signers, bool quorumComplete) {

        // ensure that the current msgHash matches the one in process or msgHash is empty
        if (currentMsgHash != bytes32(0)) {
            require(msgHash == currentMsgHash, "QPAM: msgHash different than expected");
        }

        require(action != Action.NONE, "QPAM: action required");
        require(msgHash != bytes32(0), "QPAM: msgHash required");
        require(expiry != 0, "QPAM: expiry required");
        require(salt != 0, "QPAM: salt required");
        require(expiry > block.timestamp, "QPAM: signature expired");
        bytes32 message = keccak256(abi.encode(VALIDATE_AUTHORITY_SIGNATURE, uint256(action), msgHash, salt, expiry));

        // Validate the message for only this signer
        bytes32 digest = _hashTypedDataV4(message);
        (bool result, address[] memory signers) = tryVerifyDigestWithAddressWithMinSigCheck(digest, 1, signature, false);
        require(result, "QPAM: Invalid signer");
        require(signers.length == 1, "QPAM: Wrong number of signers");
        address signer = signers[0];

        address signerQuorumId = quorumSubscriptions[signer].id;

        // if first signer, then set quorumId and msgHash
        if (completedSigners.length == 0) {
            currentMsgHash = msgHash;
            currentQuorumId = signerQuorumId;
        } else {
            // check the signer is part of the same quorum
            require(signerQuorumId == currentQuorumId, "QPAM: Signer quorum mismatch");

            // ensure not a duplicate signer
            require(!alreadySigned[signer], "QPAM: Already Signed!");
        }

        // insert signer to the signers list
        completedSigners.push(signer);
        alreadySigned[signer] = true;

        // if the quorum min length is complete, clear storage and return success
        if (completedSigners.length >= quorumSubscriptions[signer].minSignatures) {
            currentMsgHash = bytes32(0);
            currentQuorumId = address(0);

            // remove all signed mapping
            for (uint i=0; i<completedSigners.length; i++) {
                delete alreadySigned[completedSigners[i]];
            }
            delete completedSigners;
            return (completedSigners, true);
        } else { 
            return (completedSigners, false);
        }

    }

    /**
     @notice Clears the currentMsgHash to unblock invalid states
     */
    function clearCurrentMsgHash() external {
        currentMsgHash = bytes32(0);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IQuantumPortalStake.sol";
import "./QuantumPortalAuthorityMgr.sol";
import "./Delegator.sol";
import "../../../staking/StakeOpen.sol";

import "hardhat/console.sol";

/**
 @notice The QP stake, is a special type of open staking, with two exceptions:
    1 - Unstake will move assets to a locked state, for a period.
    2 - Authorities can slash
 */
contract QuantumPortalStake is StakeOpen, Delegator, IQuantumPortalStake {
    struct WithdrawItem {
        uint64 opensAt;
        uint128 amount;
    }
    struct Pair {
        uint64 start;
        uint64 end;
    }

    uint64 constant WITHDRAW_LOCK = 30 * 3600 * 24;
    address public STAKE_ID;
    address slashTarget;
    IQuantumPortalAuthorityMgr public auth;
    mapping(address => Pair) public withdrawItemsQueueParam;
    mapping(address => mapping (uint => WithdrawItem)) public withdrawItemsQueue;

    constructor() {
        bytes memory _data = IFerrumDeployer(msg.sender).initData();
        (address token, address authority) = abi.decode(_data, (address, address));
        address[] memory tokens = new address[](1);
        tokens[0] = token;
        _init(token, "QP Stake", tokens);
        STAKE_ID = token;
        auth = IQuantumPortalAuthorityMgr(authority);
    }

    function delegatedStakeOf(address delegatee
    ) external override view returns (uint256) {
        require(delegatee != address(0), "QPS: delegatee required");
        address staker = reverseDelegation[delegatee];
        require(staker != address(0), "QPS: delegatee not valid");
		return state.stakes[STAKE_ID][staker];
	}

    /**
     @notice This will first, release all the available withdraw items, 
     */
    function _withdraw(
        address to,
        address id,
        address staker,
        uint256 amount
    ) internal override nonZeroAddress(staker) {
        require(id == STAKE_ID, "QPS: bad id");
        require(to == msg.sender, "QPS: only withdraw to self");
        if (amount == 0) {
            return;
        }
        // Below assumed
        // StakingBasics.StakeInfo memory info = stakings[id];
        // require(
        //     info.stakeType == Staking.StakeType.OpenEnded,
        //     "SO: Not open ended stake"
        // );
        releaseWithdrawItems(staker, staker, 0);
        _withdrawOnlyUpdateStateAndPayRewards(to, id, staker, amount);

        // Lock balance
        WithdrawItem memory wi = WithdrawItem({
            opensAt: uint64(block.timestamp) + WITHDRAW_LOCK,
            amount: uint128(amount)
        });
        pushToQueue(staker, wi);
    }

    function releaseWithdrawItems(address staker, address receiver, uint256 max
    ) public returns(uint256 total) {
        require(staker != address(0), "QPS: staker requried");
        address token = baseInfo.baseToken[STAKE_ID];
        (Pair memory pair, WithdrawItem memory wi) = peekQueue(staker);
        console.log("PEEKED", wi.opensAt, block.timestamp);
        while(wi.opensAt != 0 && wi.opensAt < block.timestamp) {
            popFromQueue(staker, pair);
            console.log("Sending tokens ", wi.amount);
            sendToken(token, receiver, wi.amount);
            total += wi.amount;
            console.log("Total is", total);
            if (max != 0 && total >= max) {
                // Shortcut if total greater than 0
                return total;
            }
            (pair, wi) = peekQueue(staker);
            console.log("PEEKED", wi.opensAt, block.timestamp);
        }
    }

    bytes32 constant SLASH_STAKE =
        keccak256("SlashStake(address user,uint256 amount)");
    function slashUser(
        address user,
        uint256 amount,
        uint64 expiry,
        bytes32 salt,
        bytes memory multiSignature
    ) external returns (uint256) {
        bytes32 message = keccak256(abi.encode(SLASH_STAKE, user, amount));
        auth.validateAuthoritySignature(IQuantumPortalAuthorityMgr.Action.SLASH, message, salt, expiry, multiSignature);
        amount = slashWithdrawItem(user, amount);
        return slashStake(user, amount);
    }

    function slashStake(
        address staker,
        uint256 amount
    ) internal returns (uint256 remaining) {
		uint stake = state.stakes[STAKE_ID][staker];
        stake = amount < stake ? amount : stake;
        remaining = amount - stake;
        _withdrawOnlyUpdateStateAndPayRewards(slashTarget, STAKE_ID, staker, stake);
        address token = baseInfo.baseToken[STAKE_ID];
        sendToken(token, slashTarget, amount);
    }

    function slashWithdrawItem(
        address staker,
        uint256 amount
    ) internal returns (uint256) {
        uint released = releaseWithdrawItems(staker, slashTarget, amount);
        return amount > released ? amount - released : 0;
    }

    function pushToQueue(address staker, WithdrawItem memory wi) private {
        uint end = withdrawItemsQueueParam[staker].end;
        withdrawItemsQueueParam[staker].end = uint64(end) + 1;
        withdrawItemsQueue[staker][end] = wi; // starts from 0, so end is empty by now
    }

    function popFromQueue(address staker, Pair memory pair) private {
        withdrawItemsQueueParam[staker].start = pair.start + 1;
        delete withdrawItemsQueue[staker][pair.start];
    }

    function peekQueue(address staker) private returns (Pair memory pair, WithdrawItem memory wi) {
        pair = withdrawItemsQueueParam[staker];
        wi = withdrawItemsQueue[staker][pair.start];
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IStakeV2.sol";
import "./interfaces/IStakeInfo.sol";
import "./library/StakingBasics.sol";
import "./library/Admined.sol";
import "./vesting/VestingLibrary.sol";
import "./library/TokenReceivable.sol";
import "./library/StakingV2CommonSignatures.sol";
import "./factory/IStakingFactory.sol";
import "foundry-contracts/contracts/common/IFerrumDeployer.sol";
import "foundry-contracts/contracts/taxing/IGeneralTaxDistributor.sol";

abstract contract BaseStakingV2 is IStakeV2, IStakeInfo, TokenReceivable, Admined,
  StakingV2CommonSignatures {
  using SafeMath for uint256;
  using StakeFlags for uint16;
  address public /*immutable*/ factory;
  StakingBasics.StakeExtraInfo internal extraInfo;
  StakingBasics.StakeBaseInfo internal baseInfo;
  StakingBasics.StakeState internal state;
  StakingBasics.RewardState internal reward;
  VestingLibrary.VestingSchedule internal vesting;
  mapping(address => StakingBasics.StakeInfo) public stakings;
  event RewardPaid(address id, address staker, address to, address[] rewardTokens, uint256[] rewards);
  event BasePaid(address id, address staker, address to, address token, uint256 amountPaid);
  event Staked(address id, address tokenAddress, address staker, uint256 amount);
  event RewardAdded(address id, address rewardToken, uint256 rewardAmount);
  address public creationSigner;
  constructor() {
    bytes memory _data = IFerrumDeployer(msg.sender).initData();
    (factory) = abi.decode(_data, (address));
  }

  function setCreationSigner(address _signer) external onlyOwner {
    creationSigner = _signer;
  }

	// TODO: Make this a gov multisig request
	function setLockSeconds(address id, uint256 _lockSeconds) external onlyOwner {
		require(id != address(0), "BSV: id required");
    StakingBasics.StakeInfo memory stake = stakings[id];
    require(stake.stakeType != Staking.StakeType.None, "BSV2: Not initialized");
		extraInfo.lockSeconds[id] = uint64(_lockSeconds);
	}

	function rewardsTotal(address id, address rewardAddress) external view returns (uint256) {
		return reward.rewardsTotal[id][rewardAddress];
	}

	function lockSeconds(address id) external view returns (uint256) {
		return extraInfo.lockSeconds[id];
	}

  function setAllowedRewardTokens(address id, address[] memory tokens) internal {
    extraInfo.allowedRewardTokenList[id] = tokens;
    for(uint i=0; i < tokens.length; i++) {
      extraInfo.allowedRewardTokens[id][tokens[i]] = true;
    }
  }

  function ensureWithdrawAllowed(StakingBasics.StakeInfo memory stake) internal pure {
    require(
      !stake.flags.checkFlag(StakeFlags.Flag.IsRecordKeepingOnly) &&
      !stake.flags.checkFlag(StakeFlags.Flag.IsBaseSweepable), "BSV2: Record keeping only");
    require(stake.stakeType != Staking.StakeType.PublicSale, "BSV2: No withdraw on public sale");
  }

	function stakedBalance(address id) external override view returns (uint256) {
		return state.stakedBalance[id];
	}

	function stakeOf(address id, address staker) external override view returns (uint256) {
		return state.stakes[id][staker];
	}

	function fakeRewardOf(address id, address staker, address rewardToken)
	external view returns (uint256) {
		return reward.fakeRewards[id][staker][rewardToken];
	}

	function fakeRewardsTotal(address id, address rewardToken)
	external view returns (uint256) {
		return reward.fakeRewardsTotal[id][rewardToken];
	}

	function allowedRewardTokens(address id, address rewardToken) external view returns (bool) {
		return extraInfo.allowedRewardTokens[id][rewardToken];
	}

	function allowedRewardTokenList(address id) external view returns (address[] memory) {
		return extraInfo.allowedRewardTokenList[id];
	}

  function sweepBase(address id) external {
    StakingBasics.StakeInfo memory stake = stakings[id];
    require(stake.stakeType != Staking.StakeType.None, "BSV2: Not initialized");
    require(stake.flags.checkFlag(StakeFlags.Flag.IsBaseSweepable), "BSV2: Base not sweepable");
    address sweepTarget = extraInfo.sweepTargets[id];
    require(sweepTarget != address(0), "BSV2: No sweep target");
    uint256 currentSwept = state.stakeSwept[id];
    uint256 balance = state.stakedBalance[id];
    state.stakeSwept[id] = balance;
    sendToken(baseInfo.baseToken[id], sweepTarget, balance.sub(currentSwept));
  }

  function sweepRewards(address id, address[] memory rewardTokens) external {
    StakingBasics.StakeInfo memory stake = stakings[id];
    require(stake.stakeType != Staking.StakeType.None, "BSV2: Not initialized");
    require(stake.flags.checkFlag(StakeFlags.Flag.IsRewardSweepable), "BSV2: Reward not sweepable");
    require(block.timestamp > stake.endOfLife, "BSV2: Only after end of life");
    address sweepTarget = extraInfo.sweepTargets[id];
    require(sweepTarget != address(0), "BSV2: No sweep target");
    for(uint i=0; i<rewardTokens.length; i++) {
      _sweepSignleReward(id, rewardTokens[i], sweepTarget);
    }
  }

  function _sweepSignleReward(address id, address rewardToken, address sweepTarget) internal {
    uint256 totalRewards = reward.rewardsTotal[id][rewardToken];
    uint256 toPay = totalRewards.sub(reward.fakeRewardsTotal[id][rewardToken]);
    reward.fakeRewardsTotal[id][rewardToken] = totalRewards;
    sendToken(rewardToken, sweepTarget, toPay);
  }
	
  function baseToken(address id) external override view returns (address) {
    return baseInfo.baseToken[id];
  }

  function isTokenizable(address id) external override view returns(bool) {
    return stakings[id].flags.checkFlag(StakeFlags.Flag.IsTokenizable);
  }

  function name(address id) external override view returns (string memory _name) {
    _name = baseInfo.name[id];
  }

  modifier nonZeroAddress(address addr) {
    require(addr != address(0), "BaseStakingV2: zero address");
    _;
  }

  modifier onlyAdmin(address id) {
    require(admins[id][msg.sender] != StakingBasics.AdminRole.None, "BSV2: You are not admin");
    _;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IStakingFactory {
    event PoolCreated(
        address indexed stakingPoolAddress,
        address indexed stakingPoolId,
        string indexed symbol,
        address pool
    );


    function getPool(address pool, address id) external view returns (address);

    function createPool(
        address stakingPoolAddress,
        address stakingPoolId,
        string memory symbol
    ) external returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IRewardPool {
  function addMarginalReward(address rewardToken) external returns (uint256);
  function addMarginalRewardToPool(address poolId, address rewardToken) external returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IStakeInfo {
    function stakedBalance(address id) external view returns (uint256);
    function stakeOf(address id, address staker) view external returns (uint256);
    function isTokenizable(address id) external view returns (bool);
}

interface IStakeTransferrer {
	function transferFromOnlyPool(address stakingPoolId,
			address sender, address from, address to, uint256 value
		) external returns (bool);
	function approveOnlyPool(address id, address sender, address spender, uint value
		) external returns (bool);
  function transferOnlyPool(address id, address from, address to, uint256 amount
		) external;
	function allowance(address id, address owner, address spender
	  ) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Staking {
  enum StakeType { None, Unset, Timed, OpenEnded, PublicSale }
}

interface IStakeV2 {
  function stake(address to, address id) external returns (uint256);
  function stakeWithAllocation(
        address to,
        address id,
        uint256 allocation,
        bytes32 salt,
        bytes calldata allocatorSignature) external returns (uint256);
  function baseToken(address id) external returns(address);
  function name(address id) external returns (string memory);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "./StakingBasics.sol";

abstract contract Admined is Ownable {
  mapping (address => mapping(address => StakingBasics.AdminRole)) public admins;

  function setAdmin(address id, address admin, StakingBasics.AdminRole role) onlyOwner external {
    admins[id][admin] = role;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../interfaces/IStakeV2.sol";

library StakeFlags {
  enum Flag { RestrictRewards, IsBaseSweepable, IsRewardSweepable, IsTokenizable, IsFeeable,
    IsCustomFeeable, IsAllocatable, IsRecordKeepingOnly, IsMandatoryLocked }

  function checkFlag(uint16 dis, Flag f) internal pure returns (bool) {
    return dis & (1 >> uint16(f)) != 0;
  }

  function withFlag(uint16 dis, Flag f, bool value) internal pure returns (uint16 res) {
    if (value) {
      res = dis | uint16(1 << uint16(f));
    } else {
      res= dis & (uint16(1 << uint16(f)) ^ uint16(0));
    }
  }
}

library StakingBasics {
  enum AdminRole { None, StakeAdmin, StakeCreator }
  struct RewardState {
    mapping(address => mapping(address => uint256)) rewardsTotal;
    // Fake rewards acts differently for open ended vs timed staking.
    // For open ended, fake rewards is used to balance the rewards ratios going forward
    // for timed, fakeRewards reflect the amount of rewards paid to the user.
    mapping(address => mapping(address => uint256)) fakeRewardsTotal;
    mapping(address => mapping(address => mapping(address => uint256))) fakeRewards;
  }

  struct StakeBaseInfo {
    mapping(address => uint256) cap;
    mapping(address => address) baseToken;
    mapping(address => string) name;
  }

  struct StakeInfo {
    Staking.StakeType stakeType;
    bool restrictedRewards; // Packing redundant configs as booleans for gas saving
    uint32 contribStart;
    uint32 contribEnd;
    uint32 endOfLife; // No more reward paid after this time. Any reward left can be swept
    uint32 configHardCutOff;
    uint16 flags;
  }

  struct StakeExtraInfo {
    mapping(address => mapping(address => bool)) allowedRewardTokens;
    mapping(address => address[]) allowedRewardTokenList;
    mapping(address => address) allocators;
    mapping(address => address) feeTargets;
    mapping(address => address) sweepTargets;
    mapping(address => uint64) lockSeconds;
  }

  struct StakeState {
    mapping(address => uint256) stakedBalance;
    mapping(address => uint256) stakedTotal;
    mapping(address => uint256) stakeSwept;
    mapping(address => mapping(address => uint256)) stakes;
    mapping(address => mapping(address => uint256)) stakeDebts;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../interfaces/IStakeV2.sol";
import "foundry-contracts/contracts/signature/SigCheckable.sol";

// Todo: Use multisig checkable...
abstract contract StakingV2CommonSignatures is SigCheckable {
    bytes32 constant SIGNATURE_FOR_ID_METHOD =
        keccak256("SignatureForId(address id,uint8 stakeType,uint32 signatureLifetime,bytes32 salt)");
    function signatureForId(address id,
        Staking.StakeType stakeType,
        address signer,
        bytes32 salt,
        bytes calldata signature,
        uint32 signatureLifetime) internal {
        require(signatureLifetime < block.timestamp, "SignatureHelper: expired");
        uint8 stInt = uint8(stakeType);
        bytes32 message = keccak256(abi.encode(
            SIGNATURE_FOR_ID_METHOD,
            id,
            stInt,
            signatureLifetime,
            salt));
        address _signer = signerUnique(message, signature);
        require(_signer == signer, "SV2: Invalid signer");
    }

    bytes32 constant VERIFY_ALLOCATION_METHOD =
        keccak256("VerifyAllocation(address id,address allocatee,uint256 amount,bytes32 salt)");
    function verifyAllocation(
        address id,
        address allocatee,
        address allocator,
        uint256 amount,
        bytes32 salt,
        bytes calldata signature) internal view {
        bytes32 message = keccak256(abi.encode(
            VERIFY_ALLOCATION_METHOD,
            id,
            allocatee,
            amount,
            salt));
        (, address _signer) = signer(message, signature);
        require(_signer == allocator, "SV2: Invalid allocator");
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @notice Library for handling safe token transactions including fee per transaction tokens.
 */
abstract contract TokenReceivable is ReentrancyGuard {
  using SafeERC20 for IERC20;
  mapping(address => uint256) public inventory; // Amount of received tokens that are accounted for

  /**
   @notice Sync the inventory of a token based on amount changed
   @param token The token address
   @return amount The changed amount
   */
  function sync(address token) internal nonReentrant returns (uint256 amount) {
    uint256 inv = inventory[token];
    uint256 balance = IERC20(token).balanceOf(address(this));
    amount = balance - inv;
    inventory[token] = balance;
  }

  /**
   @notice Safely sends a token out and updates the inventory
   @param token The token address
   @param payee The payee
   @param amount The amount
   */
  function sendToken(address token, address payee, uint256 amount) internal nonReentrant {
    inventory[token] = inventory[token] - amount;
    IERC20(token).safeTransfer(payee, amount);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./interfaces/IStakeV2.sol";
import "./interfaces/IRewardPool.sol";
import "foundry-contracts/contracts/common/Sweepable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "./BaseStakingV2.sol";

/**
 * Open ended staking.
 * Supports multi-rewards.
 * Supports multi-stakes.
 * Supports min lock.
 * Cannot be tokenizable.
 */
contract StakeOpen is Sweepable, BaseStakingV2, IRewardPool {
    using SafeMath for uint256;
    using StakeFlags for uint16;
    mapping(address => mapping(address => uint256)) internal stakeTimes;

    string constant public VERSION = "000.001";

    constructor() EIP712("FERRUM_STAKING_V2_OPEN", VERSION) {}

    function initDefault(address token) external nonZeroAddress(token) {
        StakingBasics.StakeInfo storage info = stakings[token];
        require(
            stakings[token].stakeType == Staking.StakeType.None,
            "SO: Already exists"
        );
        info.stakeType = Staking.StakeType.OpenEnded;
        baseInfo.baseToken[token] = token;
        baseInfo.name[token] = "Default Stake Pool";
        address[] memory rewardTokens = new address[](1);
        rewardTokens[0] = token;
        setAllowedRewardTokens(token, rewardTokens);
    }

    function init(address token, string memory name, address[] calldata rewardTokens) external nonZeroAddress(token) onlyOwner {
        StakingBasics.StakeInfo storage info = stakings[token];
        require(
            stakings[token].stakeType == Staking.StakeType.None,
            "SO: Already exists"
        );
        info.stakeType = Staking.StakeType.OpenEnded;
        baseInfo.baseToken[token] = token;
        baseInfo.name[token] = name;
        setAllowedRewardTokens(token, rewardTokens);
    }

    function stakeWithAllocation(
        address staker,
        address id,
        uint256 allocation,
        bytes32 salt,
        bytes calldata allocatorSignature
    ) external virtual override returns (uint256) {
        require(allocation != 0, "StakeTimed: allocation is required");
        address allocator = extraInfo.allocators[id];
        require(allocator != address(0), "StakeTimed: no allocator");
        verifyAllocation(
            id,
            msg.sender,
            allocator,
            allocation,
            salt,
            allocatorSignature
        );
        return _stake(staker, id, allocation);
    }

    function stake(address to, address id)
        external
        virtual
        override
        returns (uint256 stakeAmount)
    {
        stakeAmount = _stake(to, id, 0);
    }

    /**
     * Default stake is an stake with the id of the token.
     */
    function stakeFor(address to, address id)
        external
        virtual
        nonZeroAddress(to)
        nonZeroAddress(id)
        returns (uint256)
    {
        return _stake(to, id, 0);
    }

    function _init(address token, string memory name, address[] memory rewardTokens
    ) internal {
        StakingBasics.StakeInfo storage info = stakings[token];
        require(
            stakings[token].stakeType == Staking.StakeType.None,
            "SO: Already exists"
        );
        info.stakeType = Staking.StakeType.OpenEnded;
        baseInfo.baseToken[token] = token;
        baseInfo.name[token] = name;
        setAllowedRewardTokens(token, rewardTokens);
    }

    function _stake(
        address to,
        address id,
        uint256 allocation
    ) internal returns (uint256) {
        StakingBasics.StakeInfo memory info = stakings[id];
        require(
            info.stakeType == Staking.StakeType.OpenEnded,
            "SO: Not open ended stake"
        );
        require(
            !info.flags.checkFlag(StakeFlags.Flag.IsAllocatable) ||
                allocation != 0,
            "SO: No allocation"
        ); // Break early to save gas for allocatable stakes
        address token = baseInfo.baseToken[id];
        uint256 amount = sync(token);
        require(amount != 0, "SO: amount is required");
        require(
            !info.flags.checkFlag(StakeFlags.Flag.IsAllocatable) ||
                amount <= allocation,
            "SO: Not enough allocation"
        );
        _stakeUpdateStateOnly(to, id, amount);
        return amount;
    }

    /**
     * First send the rewards to this contract, then call this method.
     * Designed to be called by smart contracts.
     */
    function addMarginalReward(address rewardToken)
        external
        override
        returns (uint256)
    {
        return _addReward(rewardToken, rewardToken);
    }

    function addMarginalRewardToPool(address id, address rewardToken)
        external
        override
        returns (uint256)
    {
        require(
            extraInfo.allowedRewardTokens[id][rewardToken],
            "SO: rewardToken not valid for this stake"
        );
        return _addReward(id, rewardToken);
    }

    function _addReward(address id, address rewardToken)
        internal
        virtual
        nonZeroAddress(id)
        nonZeroAddress(rewardToken)
        returns (uint256)
    {
        uint256 rewardAmount = sync(rewardToken);
        if (rewardAmount == 0) {
            return 0;
        } // No need to fail the transaction

        reward.rewardsTotal[id][rewardToken] = reward
        .rewardsTotal[id][rewardToken].add(rewardAmount);
        reward.fakeRewardsTotal[id][rewardToken] = reward
        .fakeRewardsTotal[id][rewardToken].add(rewardAmount);
        emit RewardAdded(id, rewardToken, rewardAmount);
        return rewardAmount;
    }

    function withdrawTimeOf(address id, address staker)
        external
        view
        returns (uint256)
    {
        return _withdrawTimeOf(id, staker);
    }

    function _withdrawTimeOf(address id, address staker)
        internal
        view
        returns (uint256)
    {
        uint256 lockSec = extraInfo.lockSeconds[id];
        uint256 stakeTime = stakeTimes[id][staker];
        return stakeTime + lockSec;
    }

    function rewardOf(
        address id,
        address staker,
        address[] calldata rewardTokens
    ) external view virtual returns (uint256[] memory amounts) {
        StakingBasics.StakeInfo memory info = stakings[id];
        require(
            info.stakeType != Staking.StakeType.None,
            "SO: Stake not found"
        );
        uint256 balance = state.stakes[id][staker];
        amounts = new uint256[](rewardTokens.length);
        if (balance == 0) {
            return amounts;
        }
        uint256 poolShareX128 = VestingLibrary.calculatePoolShare(
            balance,
            state.stakedBalance[id]
        );
        for (uint256 i = 0; i < rewardTokens.length; i++) {
            uint256 userFake = reward.fakeRewards[id][staker][rewardTokens[i]];
            uint256 fakeTotal = reward.fakeRewardsTotal[id][rewardTokens[i]];
            (amounts[i], ) = _calcSingleRewardOf(
                poolShareX128,
                fakeTotal,
                userFake
            );
        }
    }

    function withdrawRewards(address to, address id)
        external
        virtual
        nonZeroAddress(to)
        nonZeroAddress(id)
    {
        return
            _withdrawRewards(
                to,
                id,
                msg.sender,
                extraInfo.allowedRewardTokenList[id]
            );
    }

    /**
     * First withdraw all rewards, than withdarw it all, then stake back the remaining.
     */
    function withdraw(
        address to,
        address id,
        uint256 amount
    ) external virtual {
        _withdraw(to, id, msg.sender, amount);
    }

    function _stakeUpdateStateOnly(
        address staker,
        address id,
        uint256 amount
    ) internal {
        StakingBasics.StakeInfo memory info = stakings[id];
        require(
            info.stakeType == Staking.StakeType.OpenEnded,
            "SO: Not open ended stake"
        );
        uint256 stakedBalance = state.stakedBalance[id];
        address[] memory rewardTokens = extraInfo.allowedRewardTokenList[id];

        for (uint256 i = 0; i < rewardTokens.length; i++) {
            address rewardToken = rewardTokens[i];
            uint256 fakeTotal = reward.fakeRewardsTotal[id][rewardToken];
            uint256 curRew = stakedBalance != 0
                ? amount.mul(fakeTotal).div(stakedBalance)
                : fakeTotal;

            reward.fakeRewards[id][staker][rewardToken] = reward
            .fakeRewards[id][staker][rewardToken].add(curRew);

            if (stakedBalance != 0) {
                reward.fakeRewardsTotal[id][rewardToken] = fakeTotal.add(
                    curRew
                );
            }
        }

        state.stakedBalance[id] = stakedBalance.add(amount);

        uint256 newStake = state.stakes[id][staker].add(amount);
        uint256 lastStakeTime = stakeTimes[id][staker];
        if (lastStakeTime != 0) {
            uint256 timeDrift = amount.mul(block.timestamp - lastStakeTime).div(
                newStake
            );
            stakeTimes[id][staker] = lastStakeTime + timeDrift;
        } else {
            stakeTimes[id][staker] = block.timestamp;
        }
        state.stakes[id][staker] = newStake;
    }

    function _withdraw(
        address to,
        address id,
        address staker,
        uint256 amount
    ) internal virtual nonZeroAddress(staker) nonZeroAddress(id) {
        if (amount == 0) {
            return;
        }
        StakingBasics.StakeInfo memory info = stakings[id];
        require(
            info.stakeType == Staking.StakeType.OpenEnded,
            "SO: Not open ended stake"
        );
        require(
            _withdrawTimeOf(id, staker) <= block.timestamp,
            "SO: too early to withdraw"
        );
        _withdrawOnlyUpdateStateAndPayRewards(to, id, staker, amount);
        sendToken(baseInfo.baseToken[id], to, amount);
        // emit PaidOut(tokenAddress, staker, amount);
    }

    /*
     * @dev: Formula:
     * Calc total rewards: balance * fake_total / stake_balance
     * Calc faked rewards: amount  * fake_total / stake_balance
     * Calc pay ratio: (total rewards - debt) / total rewards [ total rewards should NEVER be less than debt ]
     * Pay: pay ratio * faked rewards
     * Debt: Reduce by (fake rewards - pay)
     * total fake: reduce by fake rewards
     * Return the pay amount as rewards
     */
    function _withdrawOnlyUpdateStateAndPayRewards(
        address to,
        address id,
        address staker,
        uint256 amount
    ) internal virtual returns (uint256) {
        uint256 userStake = state.stakes[id][staker];
        require(amount <= userStake, "SO: Not enough balance");
        address[] memory rewardTokens = extraInfo.allowedRewardTokenList[id];
        uint256 stakedBalance = state.stakedBalance[id];
        uint256 poolShareX128 = VestingLibrary.calculatePoolShare(
            amount,
            stakedBalance
        );

        for (uint256 i = 0; i < rewardTokens.length; i++) {
            _withdrawPartialRewards(
                to,
                id,
                staker,
                rewardTokens[i],
                poolShareX128
            );
        }

        state.stakes[id][staker] = userStake.sub(amount);
        state.stakedBalance[id] = stakedBalance.sub(amount);
        return amount;
    }

    function _withdrawPartialRewards(
        address to,
        address id,
        address staker,
        address rewardToken,
        uint256 poolShareX128
    ) internal {
        uint256 userFake = reward.fakeRewards[id][staker][rewardToken];
        uint256 fakeTotal = reward.fakeRewardsTotal[id][rewardToken];
        (uint256 actualPay, uint256 fakeRewAmount) = _calcSingleRewardOf(
            poolShareX128,
            fakeTotal,
            userFake
        );

        if (fakeRewAmount > userFake) {
            // We have some rew to return. But we don't so add it back

            userFake = 0;
            reward.fakeRewardsTotal[id][rewardToken] = fakeTotal
                .sub(fakeRewAmount);
        } else {
            userFake = userFake.sub(fakeRewAmount);
            reward.fakeRewardsTotal[id][rewardToken] = fakeTotal.sub(
                fakeRewAmount
            );
        }
        reward.fakeRewards[id][staker][rewardToken] = userFake;
        if (actualPay != 0) {
            sendToken(rewardToken, to, actualPay);
        }
    }

    function _withdrawRewards(
        address to,
        address id,
        address staker,
        address[] memory rewardTokens
    ) internal {
        uint256 userStake = state.stakes[id][staker];
        uint256 poolShareX128 = VestingLibrary.calculatePoolShare(
            userStake,
            state.stakedBalance[id]
        );
        for (uint256 i = 0; i < rewardTokens.length; i++) {
            address rewardToken = rewardTokens[i];
            uint256 userFake = reward.fakeRewards[id][staker][rewardToken];
            uint256 fakeTotal = reward.fakeRewardsTotal[id][rewardToken];
            (uint256 actualPay, ) = _calcSingleRewardOf(
                poolShareX128,
                fakeTotal,
                userFake
            );

            reward.rewardsTotal[id][rewardToken] = reward
            .rewardsTotal[id][rewardToken].sub(actualPay);
            reward.fakeRewards[id][staker][rewardToken] = userFake.add(
                actualPay
            );
            if (actualPay != 0) {
                sendToken(rewardToken, to, actualPay);
            }
        }
        // emit PaidOut(tokenAddress, address(rewardToken), _staker, 0, actualPay);
    }

    function _calcSingleRewardOf(
        uint256 poolShareX128,
        uint256 fakeRewardsTotal,
        uint256 userFake
    ) internal pure returns (uint256, uint256) {
        if (poolShareX128 == 0) {
            return (0, 0);
        }
        uint256 rew = VestingLibrary.calculateFakeRewardForWithdraw(
            fakeRewardsTotal,
            poolShareX128
        );
        return (rew > userFake ? rew.sub(userFake) : 0, rew); // Ignoring the overflow problem
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../library/StakingBasics.sol";
import "foundry-contracts/contracts/math/FullMath.sol";
import "foundry-contracts/contracts/math/SafeCast.sol";
import "foundry-contracts/contracts/math/FixedPoint128.sol";

library VestingLibrary {
  using SafeMath for uint256;
  uint256 constant YEAR_IN_SECONDS = 365 * 24 * 3600;
  enum PeriodType { Unlocked, NoWithdraw, LinearReward, LinearBase, LinearBaseLinearReward }
  struct VestingItem {
    uint160 amount;
    uint32 endTime;
    PeriodType periodType;
  }

  struct VestingSchedule {
    mapping(address => mapping(address => uint256)) maxApyX10000; // (display only) Max APY * 10000 (20% => 2,000). For display only
    mapping(address => mapping(address => uint256)) maxApyX128; // Max APY considering price of base / reward
    mapping(address => mapping(address => uint256)) rewardAdded; // Total amount of added rewards
    mapping(address => mapping(address => uint256)) rewardPaid; // Total amount of paid
    mapping(address => mapping(address => VestingItem[])) items;
  }

  function getPegPriceX128(address id,
    address rewardToken,
    mapping(address => mapping(address => uint256)) storage maxApyX10000,
    mapping(address => mapping(address => uint256)) storage maxApyX128)
    internal view returns (uint256 _maxApyX10000, uint256 baseRewRatioX128) {
    _maxApyX10000 = maxApyX10000[id][rewardToken];
    uint256 _maxApyX128 = maxApyX128[id][rewardToken];
    baseRewRatioX128 = FullMath.mulDiv(_maxApyX128, _maxApyX10000, 10000);
  }

  function setVestingSchedule(
    address id,
    address rewardToken,
    uint256 maxApyX10000,
    uint256 baseRewRatioX128, // Price of base over rew. E.g. rew FRMX, base FRM => $0.5*10^6/(10,000*10^18)
    uint32[] calldata endTimes,
    uint128[] calldata amounts,
    PeriodType[] calldata periodTypes,
    VestingSchedule storage vesting) internal {
    // Set the maxApy
    if (maxApyX10000 != 0) {
      uint256 _maxApyX128 = FullMath.mulDiv(maxApyX10000, baseRewRatioX128, 10000);
      vesting.maxApyX128[id][rewardToken] = _maxApyX128;
    }
    vesting.maxApyX10000[id][rewardToken] = maxApyX10000;

    for(uint i=0; i < endTimes.length; i++) {
      require(endTimes[i] != 0, "VestingLibrary: startTime required");
      if (periodTypes[i] == PeriodType.LinearBase || periodTypes[i] == PeriodType.LinearBaseLinearReward) {
        require(i == endTimes.length - 1, "VestingLibrary: linearBase only applies to the last period");
      }
      VestingItem memory vi = VestingItem({
        amount: SafeCast.toUint160(amounts[i]),
        endTime: endTimes[i],
        periodType: periodTypes[i]
        });
      vesting.items[id][rewardToken][i] = vi;
    }
  } 

  function rewardRequired(address id,
    address rewardToken,
    mapping(address => mapping(address => VestingItem[])) storage items,
    mapping(address => mapping(address => uint256)) storage rewardAdded) external view returns (uint256) {
    uint256 total = 0;
    uint256 len = items[id][rewardToken].length;
    require(len != 0 ,"VL: No vesting defined");
    for(uint i=0; i < len; i++) {
      uint256 vAmount = items[id][rewardToken][i].amount;
      total = total.add(vAmount);
    }
    return total.sub(rewardAdded[id][rewardToken]);
  }

  function calculatePoolShare(uint256 shareBalance, uint256 stakeBalance)
  internal pure returns (uint256 poolShareX128) {
      require(stakeBalance != 0, "VL: Balance zero");
      poolShareX128 = FullMath.mulDiv(shareBalance, FixedPoint128.Q128, stakeBalance);
  }

  function calculateMaxApy(uint256 baseTime, uint256 timeNow,
      uint256 maxApyX128, uint256 amount) internal pure returns (uint256) {
          require(timeNow > baseTime, "VL: Bad timing");
          return FullMath.mulDiv(amount, maxApyX128.mul(timeNow - baseTime),
            FixedPoint128.Q128.mul(YEAR_IN_SECONDS));
  }

  function calculateFeeX10000(uint256 amount, uint256 feeX10000) internal pure returns (uint256) {
    return FullMath.mulDiv(amount, feeX10000, 10000);
  }

  function calculateRatio(uint256 amount, uint256 feeX10000) internal pure returns (uint256) {
    return FullMath.mulDiv(amount, feeX10000, 10000);
  }

  function calculateFakeRewardForWithdraw(uint256 rewardAmount, uint256 remainingStakeRatioX128)
  internal pure returns (uint256) {
    return FullMath.mulDiv(rewardAmount, remainingStakeRatioX128, FixedPoint128.Q128);
  }

  function calculateRemainingStakeRatioX128(uint256 userBalance, uint256 withdrawAmount)
  internal pure returns (uint256) {
    return FullMath.mulDiv(userBalance.sub(withdrawAmount), FixedPoint128.Q128, userBalance);
  }

  function calculateVestedRewards(
      uint256 poolShareX128,
      uint256 stakingEnd,
      uint256 timeNow,
      uint256 maxApyRew,
      uint256 totalRewards,
      VestingItem[] memory items
      ) internal pure returns (uint256 reward, bool linearBase) {
      /*
        Stretch until the appropriate time, calculate piecewise rewards.
      */
      uint256 i=0;
      VestingItem memory item = items[0];
      uint256 lastTime = stakingEnd;
      while (item.endTime <= timeNow && i < items.length) {
        reward = reward.add(FullMath.mulDiv(poolShareX128, totalRewards, FixedPoint128.Q128));
        i++;
        if (i < items.length) {
          item = items[i];
        }
      }

      uint256 endTime = item.endTime; // To avoid too many type conversions
      // Partial take
      if (endTime > timeNow &&
        (item.periodType == PeriodType.LinearReward || item.periodType == PeriodType.LinearBaseLinearReward)) {
          reward = reward.add(FullMath.mulDiv(poolShareX128, totalRewards, FixedPoint128.Q128));
          uint256 letGoReward = FullMath.mulDiv(reward, timeNow.sub(endTime), lastTime.sub(endTime));
          reward = reward.sub(letGoReward);
          if (item.periodType == PeriodType.LinearBaseLinearReward) { linearBase = true; }
      }
      if (maxApyRew != 0 && reward != 0 && reward > maxApyRew) {
          // Dont give out more than the max_apy
          // maxApyRew to be calculated as calculateMaxApy()
          reward = maxApyRew;
      }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IFerrumDeployer {
    function initData() external returns (bytes memory);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract Sweepable is Ownable {
    using SafeERC20 for IERC20;
    bool public sweepFrozen;

    function freezeSweep() external onlyOwner {
        sweepFrozen = true;
    }

    function sweepToken(address token, address to, uint256 amount) external onlyOwner {
        require(!sweepFrozen, "S: Sweep is frozen");
        IERC20(token).safeTransfer(to, amount);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;
import "@openzeppelin/contracts/access/Ownable.sol";

contract WithAdmin is Ownable {
	address public admin;
	event AdminSet(address admin);

	function setAdmin(address _admin) external onlyOwner {
		admin = _admin;
		emit AdminSet(_admin);
	}

	modifier onlyAdmin() {
		require(msg.sender == admin || msg.sender == owner(), "WA: not admin");
		_;
	}
}

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.4.0;

/// @title FixedPoint128
/// @notice A library for handling binary fixed point numbers, see https://en.wikipedia.org/wiki/Q_(number_format)
library FixedPoint128 {
    uint256 internal constant Q128 = 0x100000000000000000000000000000000;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.0;

/// @title Contains 512-bit math functions
/// @notice Facilitates multiplication and division that can have overflow of an intermediate value without any loss of precision
/// @dev Handles "phantom overflow" i.e., allows multiplication and division where an intermediate value overflows 256 bits
library FullMath {
    /// @notice Calculates floor(a×b÷denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
    /// @param a The multiplicand
    /// @param b The multiplier
    /// @param denominator The divisor
    /// @return result The 256-bit result
    /// @dev Credit to Remco Bloemen under MIT license https://xn--2-umb.com/21/muldiv
    function mulDiv(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        // 512-bit multiply [prod1 prod0] = a * b
        // Compute the product mod 2**256 and mod 2**256 - 1
        // then use the Chinese Remainder Theorem to reconstruct
        // the 512 bit result. The result is stored in two 256
        // variables such that product = prod1 * 2**256 + prod0
        uint256 prod0; // Least significant 256 bits of the product
        uint256 prod1; // Most significant 256 bits of the product
        assembly {
            let mm := mulmod(a, b, not(0))
            prod0 := mul(a, b)
            prod1 := sub(sub(mm, prod0), lt(mm, prod0))
        }

        // Handle non-overflow cases, 256 by 256 division
        if (prod1 == 0) {
            require(denominator > 0);
            assembly {
                result := div(prod0, denominator)
            }
            return result;
        }

        // Make sure the result is less than 2**256.
        // Also prevents denominator == 0
        require(denominator > prod1);

        ///////////////////////////////////////////////
        // 512 by 256 division.
        ///////////////////////////////////////////////

        // Make division exact by subtracting the remainder from [prod1 prod0]
        // Compute remainder using mulmod
        uint256 remainder;
        assembly {
            remainder := mulmod(a, b, denominator)
        }
        // Subtract 256 bit number from 512 bit number
        assembly {
            prod1 := sub(prod1, gt(remainder, prod0))
            prod0 := sub(prod0, remainder)
        }

        // Factor powers of two out of denominator
        // Compute largest power of two divisor of denominator.
        // Always >= 1.
        uint256 twos = (type(uint256).max - denominator + 1) & denominator;
        // uint256 twos = -denominator & denominator;
        // Divide denominator by power of two
        assembly {
            denominator := div(denominator, twos)
        }

        // Divide [prod1 prod0] by the factors of two
        assembly {
            prod0 := div(prod0, twos)
        }
        // Shift in bits from prod1 into prod0. For this we need
        // to flip `twos` such that it is 2**256 / twos.
        // If twos is zero, then it becomes one
        assembly {
            twos := add(div(sub(0, twos), twos), 1)
        }
        prod0 |= prod1 * twos;

        // Invert denominator mod 2**256
        // Now that denominator is an odd number, it has an inverse
        // modulo 2**256 such that denominator * inv = 1 mod 2**256.
        // Compute the inverse by starting with a seed that is correct
        // correct for four bits. That is, denominator * inv = 1 mod 2**4
        uint256 inv = (3 * denominator) ^ 2;
        // Now use Newton-Raphson iteration to improve the precision.
        // Thanks to Hensel's lifting lemma, this also works in modular
        // arithmetic, doubling the correct bits in each step.
        inv *= 2 - denominator * inv; // inverse mod 2**8
        inv *= 2 - denominator * inv; // inverse mod 2**16
        inv *= 2 - denominator * inv; // inverse mod 2**32
        inv *= 2 - denominator * inv; // inverse mod 2**64
        inv *= 2 - denominator * inv; // inverse mod 2**128
        inv *= 2 - denominator * inv; // inverse mod 2**256

        // Because the division is now exact we can divide by multiplying
        // with the modular inverse of denominator. This will give us the
        // correct result modulo 2**256. Since the precoditions guarantee
        // that the outcome is less than 2**256, this is the final result.
        // We don't need to compute the high bits of the result and prod1
        // is no longer required.
        result = prod0 * inv;
        return result;
    }

    /// @notice Calculates ceil(a×b÷denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
    /// @param a The multiplicand
    /// @param b The multiplier
    /// @param denominator The divisor
    /// @return result The 256-bit result
    function mulDivRoundingUp(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        result = mulDiv(a, b, denominator);
        if (mulmod(a, b, denominator) > 0) {
            require(result < type(uint256).max);
            result++;
        }
    }
}

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.8.0;

/// @title Safe casting methods
/// @notice Contains methods for safely casting between types
library SafeCast {
    /// @notice Cast a uint256 to a uint160, revert on overflow
    /// @param y The uint256 to be downcasted
    /// @return z The downcasted integer, now type uint160
    function toUint160(uint256 y) internal pure returns (uint160 z) {
        require((z = uint160(y)) == y);
    }

    /// @notice Cast a int256 to a int128, revert on overflow or underflow
    /// @param y The int256 to be downcasted
    /// @return z The downcasted integer, now type int128
    function toInt128(int256 y) internal pure returns (int128 z) {
        require((z = int128(y)) == y);
    }

    /// @notice Cast a uint256 to a int256, revert on overflow
    /// @param y The uint256 to be casted
    /// @return z The casted integer, now type int256
    function toInt256(uint256 y) internal pure returns (int256 z) {
        require(y < 2**255);
        z = int256(y);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;

import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "../common/WithAdmin.sol";
import "./MultiSigLib.sol";

/**
 @notice
    Base class for contracts handling multisig transactions
      Rules:
      - First set up the master governance quorum (groupId 1). onlyOwner
	  - Owner can remove public or custom quorums, but cannot remove governance
	  quorums.
	  - Once master governance is setup, governance can add / remove any quorums
	  - All actions can only be submitted to chain by admin or owner
 */
abstract contract MultiSigCheckable is WithAdmin, EIP712 {
    uint16 public constant GOVERNANCE_GROUP_ID_MAX = 256;
    uint32 constant WEEK = 3600 * 24 * 7;
    struct Quorum {
        address id;
        uint64 groupId; // GroupId: 0 => General, 1 => Governance, >1 => Custom
        uint16 minSignatures;
        // If the quorum is owned, only owner can change its config.
        // Owner must be a governence q (id <256)
        uint8 ownerGroupId;
    }
    event QuorumCreated(Quorum quorum);
    event QuorumUpdated(Quorum quorum);
    event AddedToQuorum(address quorumId, address subscriber);
    event RemovedFromQuorum(address quorumId, address subscriber);

    mapping(bytes32 => bool) public usedHashes;
    mapping(address => Quorum) public quorumSubscriptions; // Repeating quorum defs to reduce reads
    mapping(address => Quorum) public quorums;
    mapping(address => uint256) public quorumsSubscribers;
    mapping(uint256 => bool) internal groupIds; // List of registered group IDs
    address[] public quorumList; // Only for transparency. Not used. To sanity check quorums offchain

    modifier governanceGroupId(uint64 expectedGroupId) {
        require(
            expectedGroupId < GOVERNANCE_GROUP_ID_MAX,
            "MSC: must be governance"
        );
        _;
    }

    modifier expiryRange(uint64 expiry) {
        require(block.timestamp < expiry, "CR: signature timed out");
        require(expiry < block.timestamp + WEEK, "CR: expiry too far");
        _;
    }

    /**
     @notice Force remove from quorum (if managed)
        to allow last resort option in case a quorum
        goes rogue. Overwrite if you don't need an admin control
        No check on minSig so if the no of members drops below
        minSig, the quorum becomes unusable.
     @param _address The address to be removed from quorum
     */
    function forceRemoveFromQuorum(address _address)
        external
        virtual
        onlyAdmin
    {
        Quorum memory q = quorumSubscriptions[_address];
        require(q.id != address(0), "MSC: subscription not found");
        _removeFromQuorum(_address, q.id);
    }

    bytes32 constant REMOVE_FROM_QUORUM_METHOD =
        keccak256("RemoveFromQuorum(address _address,bytes32 salt,uint64 expiry)");

    /**
     @notice Removes an address from the quorum. Note the number of addresses 
      in the quorum cannot drop below minSignatures.
      For owned quorums, only owning quorum can execute this action. For non-owned
      only quorum itself.
     @param _address The address to remove
     @param salt The signature salt
     @param expiry The expiry
     @param multiSignature The multisig encoded signature
     */
    function removeFromQuorum(
        address _address,
        bytes32 salt,
        uint64 expiry,
        bytes memory multiSignature
    ) external virtual {
        internalRemoveFromQuorum(_address, salt, expiry, multiSignature);
    }

    bytes32 constant ADD_TO_QUORUM_METHOD =
        keccak256(
            "AddToQuorum(address _address,address quorumId,bytes32 salt,uint64 expiry)"
        );

    /**
     @notice Adds an address to the quorum.
      For owned quorums, only owning quorum can execute this action. For non-owned
      only quorum itself.
     @param _address The address to be added
     @param quorumId The quorum ID
     @param salt The signature salt
     @param expiry The expiry
     @param multiSignature The multisig encoded signature
     */
    function addToQuorum(
        address _address,
        address quorumId,
        bytes32 salt,
        uint64 expiry,
        bytes memory multiSignature
    ) external expiryRange(expiry) {
        require(quorumId != address(0), "MSC: quorumId required");
        require(_address != address(0), "MSC: address required");
        require(salt != 0, "MSC: salt required");
        bytes32 message = keccak256(
            abi.encode(ADD_TO_QUORUM_METHOD, _address, quorumId, salt, expiry)
        );
        Quorum memory q = quorums[quorumId];
        require(q.id != address(0), "MSC: quorum not found");
        uint64 expectedGroupId = q.ownerGroupId != 0
            ? q.ownerGroupId
            : q.groupId;
        verifyUniqueSaltWithQuorumId(message, 
            q.ownerGroupId != 0 ? address(0) : q.id,
            salt, expectedGroupId, multiSignature);
        require(quorumSubscriptions[_address].id == address(0), "MSC: user already in a quorum");
        quorumSubscriptions[_address] = q;
        quorumsSubscribers[q.id] += 1;
        emit AddedToQuorum(quorumId, _address);
    }

    bytes32 constant UPDATE_MIN_SIGNATURE_METHOD =
        keccak256(
            "UpdateMinSignature(address quorumId,uint16 minSignature,bytes32 salt,uint64 expiry)"
        );

    /**
     @notice Updates the min signature for a quorum.
      For owned quorums, only owning quorum can execute this action. For non-owned
      only quorum itself.
     @param quorumId The quorum ID
     @param minSignature The new minSignature
     @param salt The signature salt
     @param expiry The expiry
     @param multiSignature The multisig encoded signature
     */
    function updateMinSignature(
        address quorumId,
        uint16 minSignature,
        bytes32 salt,
        uint64 expiry,
        bytes memory multiSignature
    ) external expiryRange(expiry) {
        require(quorumId != address(0), "MSC: quorumId required");
        require(minSignature > 0, "MSC: minSignature required");
        require(salt != 0, "MSC: salt required");
        Quorum memory q = quorums[quorumId];
        require(q.id != address(0), "MSC: quorumId not found");
        require(
            quorumsSubscribers[q.id] >= minSignature,
            "MSC: minSignature is too large"
        );
        bytes32 message = keccak256(
            abi.encode(
                UPDATE_MIN_SIGNATURE_METHOD,
                quorumId,
                minSignature,
                salt,
                expiry
            )
        );
        uint64 expectedGroupId = q.ownerGroupId != 0
            ? q.ownerGroupId
            : q.groupId;
        verifyUniqueSaltWithQuorumId(message, 
            q.ownerGroupId != 0 ? address(0) : q.id,
            salt, expectedGroupId, multiSignature);
        quorums[quorumId].minSignatures = minSignature;
    }

    bytes32 constant CANCEL_SALTED_SIGNATURE =
        keccak256("CancelSaltedSignature(bytes32 salt)");

    /**
     @notice Cancel a salted signature
        Remove this method if public can create groupIds.
        People can write bots to prevent a person to execute a signed message.
        This is useful for cases that the signers have signed a message
        and decide to change it.
        They can cancel the salt first, then issue a new signed message.
     @param salt The signature salt
     @param expectedGroupId Expected group ID for the signature
     @param multiSignature The multisig encoded signature
    */
    function cancelSaltedSignature(
        bytes32 salt,
        uint64 expectedGroupId,
        bytes memory multiSignature
    ) external virtual {
        require(salt != 0, "MSC: salt required");
        bytes32 message = keccak256(abi.encode(CANCEL_SALTED_SIGNATURE, salt));
        require(
            expectedGroupId != 0 && expectedGroupId < 256,
            "MSC: not governance groupId"
        );
        verifyUniqueSalt(message, salt, expectedGroupId, multiSignature);
    }

    /**
    @notice Initialize a quorum
        Override this to allow public creatig new quorums.
        If you allow public creating quorums, you MUST NOT have
        customized groupIds. Make sure groupId is created from
        hash of a quorum and is not duplicate.
    @param quorumId The unique quorumID
    @param groupId The groupID, which can be shared by quorums (if managed)
    @param minSignatures The minimum number of signatures for the quorum
    @param ownerGroupId The owner group ID. Can modify this quorum (if managed)
    @param addresses List of addresses in the quorum
    */
    function initialize(
        address quorumId,
        uint64 groupId,
        uint16 minSignatures,
        uint8 ownerGroupId,
        address[] calldata addresses
    ) public virtual onlyAdmin {
        _initialize(quorumId, groupId, minSignatures, ownerGroupId, addresses);
    }

    /**
     @notice Initializes a quorum
     @param quorumId The quorum ID
     @param groupId The group ID
     @param minSignatures The min signatures
     @param ownerGroupId The owner group ID
     @param addresses The initial addresses in the quorum
     */
    function _initialize(
        address quorumId,
        uint64 groupId,
        uint16 minSignatures,
        uint8 ownerGroupId,
        address[] memory addresses
    ) internal virtual {
        require(quorumId != address(0), "MSC: quorumId required");
        require(addresses.length > 0, "MSC: addresses required");
        require(minSignatures != 0, "MSC: minSignatures required");
        require(
            minSignatures <= addresses.length,
            "MSC: minSignatures too large"
        );
        require(quorums[quorumId].id == address(0), "MSC: already initialized");
        require(ownerGroupId == 0 || ownerGroupId != groupId, "MSC: self ownership not allowed");
        if (groupId != 0) {
            ensureUniqueGroupId(groupId);
        }
        Quorum memory q = Quorum({
            id: quorumId,
            groupId: groupId,
            minSignatures: minSignatures,
            ownerGroupId: ownerGroupId
        });
        quorums[quorumId] = q;
        quorumList.push(quorumId);
        for (uint256 i = 0; i < addresses.length; i++) {
            require(
                quorumSubscriptions[addresses[i]].id == address(0),
                "MSC: only one quorum per subscriber"
            );
            quorumSubscriptions[addresses[i]] = q;
        }
        quorumsSubscribers[quorumId] = addresses.length;
        emit QuorumCreated(q);
    }

    /**
     @notice Ensures groupID is unique. Override this method if your business
      logic requires special management of groupId and ownerGroupIds such that
      duplicate groupIds are allowed.
     @param groupId The groupId
     */
    function ensureUniqueGroupId(uint256 groupId
    ) internal virtual {
        require(groupId != 0, "MSC: groupId required");
        require(!groupIds[groupId], "MSC: groupId is not unique");
        groupIds[groupId] = true;
    }

    /**
     @notice Removes an address from the quorum. Note the number of addresses 
      in the quorum cannot drop below minSignatures.
      For owned quorums, only owning quorum can execute this action. For non-owned
      only quorum itself.
     @param _address The address to remove
     @param salt The signature salt
     @param expiry The expiry
     @param multiSignature The multisig encoded signature
     */
    function internalRemoveFromQuorum(
        address _address,
        bytes32 salt,
        uint64 expiry,
        bytes memory multiSignature
    ) internal virtual expiryRange(expiry) {
        require(_address != address(0), "MSC: address required");
        require(salt != 0, "MSC: salt required");
        Quorum memory q = quorumSubscriptions[_address];
        require(q.id != address(0), "MSC: subscription not found");
        bytes32 message = keccak256(
            abi.encode(REMOVE_FROM_QUORUM_METHOD, _address, salt, expiry)
        );
        uint64 expectedGroupId = q.ownerGroupId != 0
            ? q.ownerGroupId
            : q.groupId;
        verifyUniqueSaltWithQuorumId(message, 
            q.ownerGroupId != 0 ? address(0) : q.id,
            salt, expectedGroupId, multiSignature);
        uint256 subs = quorumsSubscribers[q.id];
        require(subs >= quorums[q.id].minSignatures + 1, "MSC: quorum becomes ususable");
        _removeFromQuorum(_address, q.id);
    }


    /**
     @notice Remove an address from the quorum
     @param _address the address
     @param qId The quorum ID
     */
    function _removeFromQuorum(address _address, address qId) internal {
        delete quorumSubscriptions[_address];
        quorumsSubscribers[qId] = quorumsSubscribers[qId] - 1;
        emit RemovedFromQuorum(qId, _address);
    }

    /**
     @notice Checking salt's uniqueness because same message can be signed with different people.
     @param message The message to verify
     @param salt The salt to be unique
     @param expectedGroupId The expected group ID
     @param multiSignature The signatures formatted as a multisig
     */
    function verifyUniqueSalt(
        bytes32 message,
        bytes32 salt,
        uint64 expectedGroupId,
        bytes memory multiSignature
    ) internal virtual {
        require(multiSignature.length != 0, "MSC: multiSignature required");
        (, bool result) = tryVerify(message, expectedGroupId, multiSignature);
        require(result, "MSC: Invalid signature");
        require(!usedHashes[salt], "MSC: Message already used");
        usedHashes[salt] = true;
    }

    function verifyUniqueSaltWithQuorumId(
        bytes32 message,
        address expectedQuorumId,
        bytes32 salt,
        uint64 expectedGroupId,
        bytes memory multiSignature
    ) internal virtual {
        require(multiSignature.length != 0, "MSC: multiSignature required");
        bytes32 digest = _hashTypedDataV4(message);
        (bool result, address[] memory signers) = tryVerifyDigestWithAddress(digest, expectedGroupId, multiSignature);
        require(result, "MSC: Invalid signature");
        require(!usedHashes[salt], "MSC: Message already used");
        require(
            expectedQuorumId == address(0) ||
            quorumSubscriptions[signers[0]].id == expectedQuorumId, "MSC: wrong quorum");
        usedHashes[salt] = true;
    }

    /**
     @notice Verifies the a unique un-salted message
     @param message The message hash
     @param expectedGroupId The expected group ID
     @param multiSignature The signatures formatted as a multisig
     */
    function verifyUniqueMessageDigest(
        bytes32 message,
        uint64 expectedGroupId,
        bytes memory multiSignature
    ) internal {
        require(multiSignature.length != 0, "MSC: multiSignature required");
        (bytes32 salt, bool result) = tryVerify(
            message,
            expectedGroupId,
            multiSignature
        );
        require(result, "MSC: Invalid signature");
        require(!usedHashes[salt], "MSC: Message digest already used");
        usedHashes[salt] = true;
    }

    /**
     @notice Tries to verify a digest message
     @param digest The digest
     @param expectedGroupId The expected group ID
     @param multiSignature The signatures formatted as a multisig
     @return result Identifies success or failure
     */
    function tryVerifyDigest(
        bytes32 digest,
        uint64 expectedGroupId,
        bytes memory multiSignature
    ) internal view returns (bool result) {
        (result, ) = tryVerifyDigestWithAddress(
            digest,
            expectedGroupId,
            multiSignature
        );
    }

    /**
     @notice Returns if the digest can be verified
     @param digest The digest
     @param expectedGroupId The expected group ID
     @param multiSignature The signatures formatted as a multisig. Note that this
        format requires signatures to be sorted in the order of signers (as bytes)
     @return result Identifies success or failure
     @return signers Lis of signers.
     */
    function tryVerifyDigestWithAddress(
        bytes32 digest,
        uint64 expectedGroupId,
        bytes memory multiSignature
    ) internal view returns (bool result, address[] memory signers) {
        (result, signers) = tryVerifyDigestWithAddressWithMinSigCheck(digest, expectedGroupId, multiSignature, true);
    }

    /**
     @notice Returns if the digest can be verified
     @param digest The digest
     @param expectedGroupId The expected group ID
     @param multiSignature The signatures formatted as a multisig. Note that this
        format requires signatures to be sorted in the order of signers (as bytes)
     @param checkForMinSigs If the minimum number of signatures check should be performed
     @return result Identifies success or failure
     @return signers Lis of signers.
     */
    function tryVerifyDigestWithAddressWithMinSigCheck(
        bytes32 digest,
        uint64 expectedGroupId,
        bytes memory multiSignature,
        bool checkForMinSigs
    ) internal view returns (bool result, address[] memory signers) {
        require(multiSignature.length != 0, "MSC: multiSignature required");
        MultiSigLib.Sig[] memory signatures = MultiSigLib.parseSig(
            multiSignature
        );
        require(signatures.length > 0, "MSC: no zero len signatures");
        signers = new address[](signatures.length);

        address _signer = ECDSA.recover(
            digest,
            signatures[0].v,
            signatures[0].r,
            signatures[0].s
        );
        signers[0] = _signer;
        address quorumId = quorumSubscriptions[_signer].id;
        if (quorumId == address(0)) {
            return (false, new address[](0));
        }
        require(
            expectedGroupId == 0 || quorumSubscriptions[_signer].groupId == expectedGroupId,
            "MSC: invalid groupId for signer"
        );
        Quorum memory q = quorums[quorumId];
        for (uint256 i = 1; i < signatures.length; i++) {
            _signer = ECDSA.recover(
                digest,
                signatures[i].v,
                signatures[i].r,
                signatures[i].s
            );
            quorumId = quorumSubscriptions[_signer].id;
            if (quorumId == address(0)) {
                return (false, new address[](0));
            }
            require(
                q.id == quorumId,
                "MSC: all signers must be of same quorum"
            );

            require(
                expectedGroupId == 0 || q.groupId == expectedGroupId,
                "MSC: invalid groupId for signer"
            );
            signers[i] = _signer;
            // This ensures there are no duplicate signers
            require(signers[i - 1] < _signer, "MSC: Sigs not sorted");
        }

        if (checkForMinSigs) {
            require(signatures.length >= q.minSignatures, "MSC: not enough signatures");
        }
        return (true, signers);
    }

    /**
     @notice Tries to verify a message hash
        @dev example message;

        bytes32 constant METHOD_SIG =
            keccak256("WithdrawSigned(address token,address payee,uint256 amount,bytes32 salt)");
        bytes32 message = keccak256(abi.encode(
          METHOD_SIG,
          token,
          payee,
          amount,
          salt
     @param message The message
     @param expectedGroupId The expected group ID
     @param multiSignature The signatures formatted as a multisig
    */
    function tryVerify(
        bytes32 message,
        uint64 expectedGroupId,
        bytes memory multiSignature
    ) internal view returns (bytes32 digest, bool result) {
        digest = _hashTypedDataV4(message);
        result = tryVerifyDigest(digest, expectedGroupId, multiSignature);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;

library MultiSigLib {
	struct Sig { uint8 v; bytes32 r; bytes32 s; }

	/**
	 * Signature is encoded as below:
	 * every two bytes32, is an (r, s) pair.
	 * last bytes32 is the v's array.
	 * If we have more than 32 sigs, more
	 * bytes at the end are dedicated to vs.
	 */
	function parseSig(bytes memory multiSig)
	internal pure returns (Sig[] memory sigs) {
		uint cnt = multiSig.length / 32;
		cnt = cnt * 32 * 2 / (2*32+1);
		uint vLen = (multiSig.length / 32) - cnt;
		require(cnt - (cnt / 2 * 2) == 0, "MSL: Invalid sig size");
		sigs = new Sig[](cnt / 2);
		uint rPtr = 0x20;
		uint sPtr = 0x40;
		uint vPtr = multiSig.length - (vLen * 0x20) + 1;
		for (uint i=0; i<cnt / 2; i++) {
			bytes32 r;
			bytes32 s;
			uint8 v;
			assembly {
					r := mload(add(multiSig, rPtr))
					s := mload(add(multiSig, sPtr))
					v := mload(add(multiSig, vPtr))
			}
			rPtr = rPtr + 0x40;
			sPtr = sPtr + 0x40;
			vPtr = vPtr + 1;

			sigs[i].v = v;
			sigs[i].r = r;
			sigs[i].s = s;
		}
	}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

/**
 @dev Make sure to define method signatures
 */
abstract contract SigCheckable is EIP712 {
    mapping(bytes32=>bool) public usedHashes;

    function signerUnique(
        bytes32 message,
        bytes memory signature) internal returns (address _signer) {
        bytes32 digest;
        (digest, _signer) = signer(message, signature);
        require(!usedHashes[digest], "Message already used");
        usedHashes[digest] = true;
    }

    /*
        @dev example message;

        bytes32 constant METHOD_SIG =
            keccak256("WithdrawSigned(address token,address payee,uint256 amount,bytes32 salt)");
        bytes32 message = keccak256(abi.encode(
          METHOD_SIG,
          token,
          payee,
          amount,
          salt
    */
    function signer(
        bytes32 message,
        bytes memory signature) internal view returns (bytes32 digest, address _signer) {
        digest = _hashTypedDataV4(message);
        _signer = ECDSA.recover(digest, signature);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IGeneralTaxDistributor {
    function distributeTax(address token) external returns (uint256);
    function distributeTaxAvoidOrigin(address token, address origin) external returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity >= 0.4.22 <0.9.0;

library console {
	address constant CONSOLE_ADDRESS = address(0x000000000000000000636F6e736F6c652e6c6f67);

	function _sendLogPayload(bytes memory payload) private view {
		uint256 payloadLength = payload.length;
		address consoleAddress = CONSOLE_ADDRESS;
		assembly {
			let payloadStart := add(payload, 32)
			let r := staticcall(gas(), consoleAddress, payloadStart, payloadLength, 0, 0)
		}
	}

	function log() internal view {
		_sendLogPayload(abi.encodeWithSignature("log()"));
	}

	function logInt(int256 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(int256)", p0));
	}

	function logUint(uint256 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256)", p0));
	}

	function logString(string memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string)", p0));
	}

	function logBool(bool p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
	}

	function logAddress(address p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address)", p0));
	}

	function logBytes(bytes memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes)", p0));
	}

	function logBytes1(bytes1 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes1)", p0));
	}

	function logBytes2(bytes2 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes2)", p0));
	}

	function logBytes3(bytes3 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes3)", p0));
	}

	function logBytes4(bytes4 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes4)", p0));
	}

	function logBytes5(bytes5 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes5)", p0));
	}

	function logBytes6(bytes6 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes6)", p0));
	}

	function logBytes7(bytes7 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes7)", p0));
	}

	function logBytes8(bytes8 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes8)", p0));
	}

	function logBytes9(bytes9 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes9)", p0));
	}

	function logBytes10(bytes10 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes10)", p0));
	}

	function logBytes11(bytes11 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes11)", p0));
	}

	function logBytes12(bytes12 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes12)", p0));
	}

	function logBytes13(bytes13 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes13)", p0));
	}

	function logBytes14(bytes14 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes14)", p0));
	}

	function logBytes15(bytes15 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes15)", p0));
	}

	function logBytes16(bytes16 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes16)", p0));
	}

	function logBytes17(bytes17 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes17)", p0));
	}

	function logBytes18(bytes18 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes18)", p0));
	}

	function logBytes19(bytes19 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes19)", p0));
	}

	function logBytes20(bytes20 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes20)", p0));
	}

	function logBytes21(bytes21 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes21)", p0));
	}

	function logBytes22(bytes22 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes22)", p0));
	}

	function logBytes23(bytes23 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes23)", p0));
	}

	function logBytes24(bytes24 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes24)", p0));
	}

	function logBytes25(bytes25 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes25)", p0));
	}

	function logBytes26(bytes26 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes26)", p0));
	}

	function logBytes27(bytes27 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes27)", p0));
	}

	function logBytes28(bytes28 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes28)", p0));
	}

	function logBytes29(bytes29 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes29)", p0));
	}

	function logBytes30(bytes30 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes30)", p0));
	}

	function logBytes31(bytes31 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes31)", p0));
	}

	function logBytes32(bytes32 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes32)", p0));
	}

	function log(uint256 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256)", p0));
	}

	function log(string memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string)", p0));
	}

	function log(bool p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
	}

	function log(address p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address)", p0));
	}

	function log(uint256 p0, uint256 p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256)", p0, p1));
	}

	function log(uint256 p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string)", p0, p1));
	}

	function log(uint256 p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool)", p0, p1));
	}

	function log(uint256 p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address)", p0, p1));
	}

	function log(string memory p0, uint256 p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256)", p0, p1));
	}

	function log(string memory p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string)", p0, p1));
	}

	function log(string memory p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool)", p0, p1));
	}

	function log(string memory p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address)", p0, p1));
	}

	function log(bool p0, uint256 p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256)", p0, p1));
	}

	function log(bool p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string)", p0, p1));
	}

	function log(bool p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool)", p0, p1));
	}

	function log(bool p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address)", p0, p1));
	}

	function log(address p0, uint256 p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256)", p0, p1));
	}

	function log(address p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string)", p0, p1));
	}

	function log(address p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool)", p0, p1));
	}

	function log(address p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address)", p0, p1));
	}

	function log(uint256 p0, uint256 p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256)", p0, p1, p2));
	}

	function log(uint256 p0, uint256 p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string)", p0, p1, p2));
	}

	function log(uint256 p0, uint256 p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool)", p0, p1, p2));
	}

	function log(uint256 p0, uint256 p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address)", p0, p1, p2));
	}

	function log(uint256 p0, string memory p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256)", p0, p1, p2));
	}

	function log(uint256 p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,string)", p0, p1, p2));
	}

	function log(uint256 p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool)", p0, p1, p2));
	}

	function log(uint256 p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,address)", p0, p1, p2));
	}

	function log(uint256 p0, bool p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256)", p0, p1, p2));
	}

	function log(uint256 p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string)", p0, p1, p2));
	}

	function log(uint256 p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool)", p0, p1, p2));
	}

	function log(uint256 p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address)", p0, p1, p2));
	}

	function log(uint256 p0, address p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256)", p0, p1, p2));
	}

	function log(uint256 p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,string)", p0, p1, p2));
	}

	function log(uint256 p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool)", p0, p1, p2));
	}

	function log(uint256 p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,address)", p0, p1, p2));
	}

	function log(string memory p0, uint256 p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256)", p0, p1, p2));
	}

	function log(string memory p0, uint256 p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,string)", p0, p1, p2));
	}

	function log(string memory p0, uint256 p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool)", p0, p1, p2));
	}

	function log(string memory p0, uint256 p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,address)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint256)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address)", p0, p1, p2));
	}

	function log(string memory p0, address p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint256)", p0, p1, p2));
	}

	function log(string memory p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string)", p0, p1, p2));
	}

	function log(string memory p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool)", p0, p1, p2));
	}

	function log(string memory p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address)", p0, p1, p2));
	}

	function log(bool p0, uint256 p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256)", p0, p1, p2));
	}

	function log(bool p0, uint256 p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string)", p0, p1, p2));
	}

	function log(bool p0, uint256 p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool)", p0, p1, p2));
	}

	function log(bool p0, uint256 p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address)", p0, p1, p2));
	}

	function log(bool p0, bool p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256)", p0, p1, p2));
	}

	function log(bool p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string)", p0, p1, p2));
	}

	function log(bool p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool)", p0, p1, p2));
	}

	function log(bool p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address)", p0, p1, p2));
	}

	function log(bool p0, address p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256)", p0, p1, p2));
	}

	function log(bool p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string)", p0, p1, p2));
	}

	function log(bool p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool)", p0, p1, p2));
	}

	function log(bool p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address)", p0, p1, p2));
	}

	function log(address p0, uint256 p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256)", p0, p1, p2));
	}

	function log(address p0, uint256 p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,string)", p0, p1, p2));
	}

	function log(address p0, uint256 p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool)", p0, p1, p2));
	}

	function log(address p0, uint256 p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,address)", p0, p1, p2));
	}

	function log(address p0, string memory p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint256)", p0, p1, p2));
	}

	function log(address p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string)", p0, p1, p2));
	}

	function log(address p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool)", p0, p1, p2));
	}

	function log(address p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address)", p0, p1, p2));
	}

	function log(address p0, bool p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256)", p0, p1, p2));
	}

	function log(address p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string)", p0, p1, p2));
	}

	function log(address p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool)", p0, p1, p2));
	}

	function log(address p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address)", p0, p1, p2));
	}

	function log(address p0, address p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint256)", p0, p1, p2));
	}

	function log(address p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string)", p0, p1, p2));
	}

	function log(address p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool)", p0, p1, p2));
	}

	function log(address p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address)", p0, p1, p2));
	}

	function log(uint256 p0, uint256 p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,string,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,string,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,string,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,string,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,address,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,address,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,address,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,address,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,string,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,string,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,string,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,string,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,address,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,address,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,address,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,string,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,address,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint256,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint256,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint256,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint256,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint256,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint256,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,string,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,address,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint256,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint256,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint256,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint256,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint256,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint256,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,address)", p0, p1, p2, p3));
	}

}