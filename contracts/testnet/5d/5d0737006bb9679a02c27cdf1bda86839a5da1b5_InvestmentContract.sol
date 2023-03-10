/**
 *Submitted for verification at BscScan.com on 2023-03-09
*/

// SPDX-License-Identifier: MIT

// File: @openzeppelin/contracts/utils/Address.sol


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

// File: @openzeppelin/contracts/token/ERC20/extensions/draft-IERC20Permit.sol


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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol


// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;




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

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


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

// File: @openzeppelin/contracts/utils/Counters.sol


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

// File: SafeMath.sol


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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}
// File: Context.sol


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
// File: Ownable.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/extensions/ERC20Burnable.sol)

pragma solidity ^0.8.0;


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
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: InvestClean.sol



pragma solidity ^0.8.0;

// import "IERC20.sol";
// import "IERC20Metadata.sol";







contract InvestmentContract is Context, Ownable, ReentrancyGuard{
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public _token;

    string public _name;

    uint256 private _totalInvestments = 0;
    uint256 private _totalInvestmentPlans = 0;

    struct InvestmentPlans {
        uint256 _count;
        uint256 _roi;
        uint256 _refPercent;
        uint256 _minAmount;
        uint256 _maxAmount;
        uint256 _duration;
        bool status;
    }

       // Staker info
    struct UserStake {
        uint256 _count;
        uint256 _roi;
        uint256 _timeOfLastUpdate;
        uint256 _unclaimedRewards;
        uint256 _amount;
        uint256 _duration;
        uint256 _dateCreated;
        address _creator;
        address _referral;
    }

    mapping(address => uint256) private _userInvestCount;

    mapping(uint256 => UserStake) private _allInvestments;
    mapping(uint256 => InvestmentPlans) private _allInvestmentPlans;

    mapping(address => bool) private _blacklisted;

    bool private _canWithdrawBeforeEndOfInvestment = false;

    // Compounding frequency limit in seconds
    uint256 public compoundFreq = 14400; //4 hours

    // Mapping of address to UserInvestment info
    mapping(address => UserStake) internal stakers;
    mapping(address => mapping(uint256 => UserStake)) private _userStakes;

    constructor(string memory name_, IERC20 token_) {
        _name = name_;
        _token = token_;
    }

    modifier notBlacklisted() {
        require(!_blacklisted[_msgSender()], "You have been blacklisted");
        _;
    }

    function blacklistUser(address _address, bool _status)public virtual onlyOwner returns (bool)  {
        _blacklisted[_address] = _status;
        return true;
    }

    function userInvestCount(address _address) public view virtual returns (uint256) {
        return _userInvestCount[_address];
    }

    
    function totalInvestments() public view virtual onlyOwner returns (uint256) {
        return _totalInvestments;
    }

    function totalInvestmentPlans() public view virtual returns (uint256) {
        return _totalInvestmentPlans;
    }

    function blacklistStatus(address _address) public view virtual returns (bool) {
        return _blacklisted[_address];
    }

    function canWithdrawBeforeEndOfInvestment(bool _status)public virtual onlyOwner returns (bool)  {
        _canWithdrawBeforeEndOfInvestment = _status;
        return true;
    }

     function createInvestment(uint256 minAmount, uint256 maxAmount, uint256 duration, uint256 roi, uint256 refPercent) public virtual onlyOwner returns (bool) {
        
        require( _allInvestmentPlans[_totalInvestmentPlans]._roi == 0, "Investment Exist, Edit Instead");
        _allInvestmentPlans[_totalInvestmentPlans]._count = _totalInvestmentPlans;
        _allInvestmentPlans[_totalInvestmentPlans]._roi = roi;
        _allInvestmentPlans[_totalInvestmentPlans]._refPercent = refPercent;
        _allInvestmentPlans[_totalInvestmentPlans]._minAmount = minAmount;
        _allInvestmentPlans[_totalInvestmentPlans]._maxAmount = maxAmount;
        _allInvestmentPlans[_totalInvestmentPlans]._duration = duration;
        _allInvestmentPlans[_totalInvestmentPlans].status = true;

        _totalInvestmentPlans++;
        return true;

    }

    function editInvestment(uint256 count, uint256 minAmount, uint256 maxAmount, uint256 duration, uint256 roi, uint256 refPercent) public virtual onlyOwner returns (bool) {
        require( _allInvestmentPlans[count]._roi != 0, "Investment does not Exist, Please Create New");
        _allInvestmentPlans[count]._roi = roi;
        _allInvestmentPlans[count]._refPercent = refPercent;
        _allInvestmentPlans[count]._minAmount = minAmount;
        _allInvestmentPlans[count]._maxAmount = maxAmount;
        _allInvestmentPlans[count]._duration = duration;
        _allInvestmentPlans[count].status = true;
        return true;

    }

    function toggleInvestment(uint256 count,bool status) public virtual onlyOwner returns (bool) {
        _allInvestmentPlans[count].status = status;
        return true;
    }

    // If address has no Staker struct, initiate one. If address already was a stake,
    // calculate the rewards and add them to unclaimedRewards, reset the last time of
    // deposit and then add _amount to the already deposited amount.
    // Burns the amount staked.

    function deposit(uint256 count, uint256 amount, address referral) external nonReentrant notBlacklisted returns (bool){
        uint256 _roi = _allInvestmentPlans[count]._roi;
        uint256 _refPercent = _allInvestmentPlans[count]._refPercent;
        uint256 _minAmount = _allInvestmentPlans[count]._minAmount;
        uint256 _maxAmount = _allInvestmentPlans[count]._maxAmount;
        uint256 duration = _allInvestmentPlans[count]._duration;
        bool status = _allInvestmentPlans[count].status;

        uint256 am = amount;

        require(status, "Not Active");
        require(amount >= _minAmount && amount <= _maxAmount , "Amount not within range");
        require(
           _token.balanceOf(msg.sender) >= amount,
            "Can't stake more than you own"
        );

        uint256 currentCount = _userInvestCount[_msgSender()];
        uint256 refBonus = (amount * _refPercent) / 100;
        if (_userStakes[_msgSender()][currentCount]._amount == 0) {

        // Store Investment
        _userStakes[_msgSender()][currentCount]._count = currentCount;
        _userStakes[_msgSender()][currentCount]._roi = _roi;
        _userStakes[_msgSender()][currentCount]._amount = amount;
        _userStakes[_msgSender()][currentCount]._timeOfLastUpdate = block.timestamp;
        _userStakes[_msgSender()][currentCount]._unclaimedRewards = 0;
        _userStakes[_msgSender()][currentCount]._duration = duration;
        _userStakes[_msgSender()][currentCount]._dateCreated = block.timestamp;
        _userStakes[_msgSender()][currentCount]._referral = referral;
        _userStakes[_msgSender()][currentCount]._creator = _msgSender();

        // Increase Count
        _userInvestCount[_msgSender()]++;
        _totalInvestments++;

        _token.transferFrom(_msgSender(),address(this), amount);
        _token.safeTransfer(referral, refBonus);

        } else {
        uint256 rewards = calculateRewards(msg.sender, count);
        uint256 newAmount = _userStakes[_msgSender()][currentCount]._amount + amount;
        require(newAmount <= _maxAmount , "Amount greater than max");

            // Store Investment
            _userStakes[_msgSender()][currentCount]._amount += amount;
            _userStakes[_msgSender()][currentCount]._timeOfLastUpdate =  block.timestamp;
            _userStakes[_msgSender()][currentCount]._unclaimedRewards += rewards;

            _token.transferFrom(_msgSender(),address(this), am);

        }
        return true;
    }

        // Calculate the rewards since the last update on Deposit info
    function calculateRewards(address _staker, uint256 count)
        internal
        view
        returns (uint256)
    {

        uint256 amount = _userStakes[_staker][count]._amount;
        uint256 duration = _userStakes[_staker][count]._duration;
        uint256 timeOfLastUpdate = _userStakes[_staker][count]._timeOfLastUpdate;

        uint256 roi = _userStakes[_staker][count]._roi;
        uint256 rewardsPerHour = (roi * 100000) / (duration/ 3600);

        return (((((block.timestamp - timeOfLastUpdate) *
            amount) * rewardsPerHour) / 3600) / 10000000);
    }

    // Withdraw all stake and rewards and mints them to the msg.sender
    function withdrawAll(uint256 count) external nonReentrant notBlacklisted {

        uint256 amount = _userStakes[_msgSender()][count]._amount;
        uint256 duration = _userStakes[_msgSender()][count]._duration;
        uint256 dateCreated = _userStakes[_msgSender()][count]._dateCreated;
        
        require(amount > 0, "You have no deposit");
        require ((dateCreated + duration) < block.timestamp || _canWithdrawBeforeEndOfInvestment, "Investment is Still Active");

        uint256 _rewards = calculateRewards(msg.sender, count) +
            _userStakes[msg.sender][count]._unclaimedRewards;
        uint256 _deposit = _userStakes[msg.sender][count]._amount;
        _userStakes[msg.sender][count]._amount = 0;
        _userStakes[msg.sender][count]._timeOfLastUpdate = 0;
        uint256 _amount = _rewards + _deposit;
        _token.safeTransfer(msg.sender, _amount);

    }

        function getAllInvestmentPlans() public view virtual returns 
        (uint256[] memory, uint256[] memory, uint256[] memory,uint256[] memory,
        uint256[] memory,uint256[] memory,bool[] memory) {

        uint256[] memory count = new uint256[](_totalInvestmentPlans);
        uint256[] memory roi = new uint256[](_totalInvestmentPlans);
        uint256[] memory refPercent = new uint256[](_totalInvestmentPlans);
        uint256[] memory minAmount = new uint256[](_totalInvestmentPlans);
        uint256[] memory maxAmount = new uint256[](_totalInvestmentPlans);
        uint256[] memory duration = new uint256[](_totalInvestmentPlans);
        bool[] memory status = new bool[](_totalInvestmentPlans);

                for(uint i = 0; i<_totalInvestmentPlans; i++){

                        InvestmentPlans storage _allUserInvestmentPlans =  _allInvestmentPlans[i];

                        count[i] = _allUserInvestmentPlans._count;
                        roi[i] = _allUserInvestmentPlans._roi;
                        refPercent[i] = _allUserInvestmentPlans._refPercent;
                        minAmount[i] = _allUserInvestmentPlans._minAmount;
                        maxAmount[i] = _allUserInvestmentPlans._maxAmount;
                        duration[i] = _allUserInvestmentPlans._duration;
                        status[i] = _allUserInvestmentPlans.status;
                }

                return (count, roi ,refPercent, minAmount , maxAmount , duration, status);

    }

        function getUserInvestments(address _address) public notBlacklisted view virtual returns 
        ( uint256[] memory,  uint256[] memory, uint256[] memory, uint256[] memory, 
        uint256[] memory, uint256[] memory, uint256[] memory) {

        address userAdd = _address;

        require(_address == _msgSender() || _msgSender() == owner(), "Only Owner or Account Holder");
        uint256 currentCount = _userInvestCount[_address];

         uint256[] memory count = new uint256[](currentCount);
         uint256[] memory roi = new uint256[](currentCount);
         uint256[] memory amount = new uint256[](currentCount);
         uint256[] memory timeOfLastUpdate = new uint256[](currentCount);
         uint256[] memory unclaimedRewards = new uint256[](currentCount);
         uint256[] memory duration = new uint256[](currentCount);
         uint256[] memory rewards = new uint256[](currentCount);
        //  address[] memory referral = new address[](currentCount);


                for(uint256 i = 0; i<currentCount; i++){

                        uint256 _rewards = calculateRewards(userAdd, i) + _userStakes[userAdd][i]._unclaimedRewards;

                        UserStake storage _allUserInvestment = _userStakes[userAdd][i];

                        count[i] = _allUserInvestment._count;
                        roi[i] = _allUserInvestment._roi;
                        amount[i] = _allUserInvestment._amount;
                        timeOfLastUpdate[i] = _allUserInvestment._timeOfLastUpdate;
                        unclaimedRewards[i] = _allUserInvestment._unclaimedRewards;
                        duration[i] = _allUserInvestment._duration;
                        rewards[i] =_rewards;
                        // referral[i] = _allUserInvestment._referral;


                }
                
                return (count, roi , amount , timeOfLastUpdate, unclaimedRewards, duration, rewards);

    }



    // Compound the rewards and reset the last time of update for Deposit info
    function stakeRewards(uint256 count) external nonReentrant notBlacklisted {
        require(_userStakes[msg.sender][count]._amount > 0, "You have no deposit");
        require(
            compoundRewardsTimer(msg.sender, count) == 0,
            "Tried to compound rewards too soon"
        );
        uint256 rewards = calculateRewards(msg.sender, count) +
            _userStakes[msg.sender][count]._unclaimedRewards;
        _userStakes[msg.sender][count]._unclaimedRewards = 0;
        _userStakes[msg.sender][count]._amount += rewards;
        _userStakes[msg.sender][count]._timeOfLastUpdate = block.timestamp;
    }

    // Mints rewards for msg.sender
    function claimRewards(uint256 count) external nonReentrant  notBlacklisted {
        uint256 rewards = calculateRewards(msg.sender, count) +
            _userStakes[msg.sender][count]._unclaimedRewards;
        require(rewards > 0, "You have no rewards");
        _userStakes[msg.sender][count]._unclaimedRewards = 0;
        _userStakes[msg.sender][count]._timeOfLastUpdate = block.timestamp;
        _token.safeTransfer(msg.sender, rewards);
    }

    // Function useful for fron-end that returns user stake and rewards by address
    function getDepositInfo(address _user, uint256 count)
        public
        view
        returns (uint256 _stake, uint256 _rewards)
    {

        _stake = _userStakes[_user][count]._amount;
        _rewards =
            calculateRewards(_user, count) +
            _userStakes[_user][count]._unclaimedRewards;
        return (_stake, _rewards);
    }


    // Utility function that returns the timer for restaking rewards
    function compoundRewardsTimer(address _user, uint256 count)
        public
        view
        returns (uint256 _timer)
    {
        if (_userStakes[_user][count]._timeOfLastUpdate + compoundFreq <= block.timestamp) {
            return 0;
        } else {
            return
                (_userStakes[_user][count]._timeOfLastUpdate + compoundFreq) -
                block.timestamp;
        }
    }

}

// 100000000000000000000,1000000000000000000000,31536000,25,10

// 0,100000000000000000000,0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2