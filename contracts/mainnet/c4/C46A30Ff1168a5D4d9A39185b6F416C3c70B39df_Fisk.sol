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

// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.0;

interface IAddressesProvider {
  /***************************************************** */
  /*********************GETTERS************************* */
  /***************************************************** */
  function getAddress(bytes32 id) external view returns (address);

  function getSpent() external view returns (address);

  function getSpentLP() external view returns (address);

  function getEusd() external view returns (address);

  function getZapContract() external view returns (address);

  function getBscViaDuctContract() external returns (address);

  function getBarterRouter() external view returns (address);

  function getBarterFactory() external view returns (address);

  function getUpRightContract() external view returns (address);

  function getCropYardContract() external view returns (address);

  function getPrimeContract() external view returns (address);

  function getFiskContract() external view returns (address);

  function getWhitelistContract() external view returns (address);

  function getUprightStableContract() external view returns (address);

  function getUprightLpContract() external view returns (address);

  function getUprightSwapTokenContract() external view returns (address);

  function getUprightBstContract() external view returns (address);

  function getBorrowLendContract() external view returns (address);

  function getTokenomicsContract() external view returns (address);

  function getManagerContract() external view returns (address);

  function getManager() external view returns (address);

  /***************************************************** */
  /*********************SETTERS************************* */
  /***************************************************** */

  function setAddress(bytes32 id, address newAddress) external;
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.10;

// FIXME: seggregate errors
library Errors {
  /*********************************************************** */
  /****************************RBAC*************************** */
  /*********************************************************** */
  string public constant CALLER_NOT_ADMIN = "CALLER_NOT_ADMIN"; // 'The caller of the function is not a pool admin'
  string public constant CALLER_NOT_OWNER = "CALLER_NOT_OWNER"; // 'The caller of the function is not a pool admin'
  string public constant CALLER_NOT_MODERATOR = "CALLER_NOT_MODERATOR"; // 'The caller of the function is not a pool admin'
  string public constant CALLER_NOT_SWAP = "CALLER_NOT_SWAP"; // 'The caller of the function is not a pool admin'
  string public constant ACL_ADMIN_CANNOT_BE_ZERO = "ACL_ADMIN_CANNOT_BE_ZERO";

  /*********************************************************** */
  /*************************WHITELISTING********************** */
  /*********************************************************** */
  string public constant ALREADY_WHITELISTED = "ALREADY_WHITELISTED";
  string public constant CALLER_OR_POOL_NOT_WHITELISTED = "CALLER_OR_POOL_NOT_WHITELISTED";
  string public constant REF_NOT_WHITELISTED = "REF_NOT_WHITELISTED";
  string public constant CANNOT_BE_CALLED_BY_MEMBER = "CANNOT_BE_CALLED_BY_MEMBER";
  string public constant WRONG_LOACTION = "WRONG_LOACTION";
  /*********************************************************** */
  /****************************ERC20************************** */
  /*********************************************************** */
  string public constant AMOUNT_ZERO = "AMOUNT_ZERO";
  string public constant LOW_ALLOWANCE = "LOW_ALLOWANCE";
  string public constant INSUFFICIENT_AMOUNT = "INSUFFICIENT_AMOUNT";
  string public constant LOW_BALANCE = "LOW_BALANCE";
  /*********************************************************** */
  /*************************ZERO_ERROR************************ */
  /*********************************************************** */
  string public constant LP_AMOUNT_INVALID = "LP_AMOUNT_INVALID";
  string public constant AMOUNT_INVALID = "AMOUNT_INVALID";
  string public constant NO_TOKEN_IN_CONTRACT = "NO_TOKEN_IN_CONTRACT";
  /*********************************************************** */
  /**************************LOCKED*************************** */
  /*********************************************************** */
  string public constant LP_NOT_UNLOCABLE_YET = "LP_NOT_UNLOCABLE_YET";
  /*********************************************************** */
  /**************************STAKE*************************** */
  /*********************************************************** */
  string public constant WRONG_LP = "WRONG_LP";
  string public constant NOT_CLAIMABLE_YET = "NOT_CLAIMABLE_YET";
  string public constant NOT_UNSTAKABLE_YET = "NOT_UNSTAKABLE_YET";
  string public constant LOW_LOCK_DURATION = "LOW_LOCK_DURATION";
  /*********************************************************** */
  /**************************TRANSACTION************************ */
  /************************************************************ */
  string public constant TRANSACTION_FAILED = "TRANSACTION_FAILED";
  /*********************************************************** */
  /**************************VIA-DUCT************************* */
  /*********************************************************** */
  string public constant ZERO_AFTER_DEDUCTIONS = "ZERO_AFTER_DEDUCTIONS";
  string public constant ZERO_AFTER_VALUATIONS = "ZERO_AFTER_VALUATIONS";
  string public constant LOW_eUSD_BALANCE_IN_CONTRACT = "LOW_eUSD_BALANCE_IN_CONTRACT";
  /*********************************************************** */
  /**************************ACL****************************** */
  /*********************************************************** */
  string public constant CALLER_NOT_PRIME_CONTRACT = "CALLER_NOT_PRIME_CONTRACT";
  string public constant CALLER_NOT_WHITELIST_CONTRACT = "CALLER_NOT_WHITELIST_CONTRACT";
  string public constant CALLER_NOT_CROP_YARD_CONTRACT = "CALLER_NOT_CROP_YARD_CONTRACT";
  string public constant CALLER_NOT_BORROW_LEND_CONTRACT = "CALLER_NOT_BORROW_LEND_CONTRACT";

  string public constant CALLER_NOT_UPRIGHT_STABLE_CONTRACT = "CALLER_NOT_UPRIGHT_STABLE_CONTRACT";
  string public constant CALLER_NOT_UPRIGHT_LP_CONTRACT = "CALLER_NOT_UPRIGHT_LP_CONTRACT";
  string public constant CALLER_NOT_UPRIGHT_SWAP_TOKEN_CONTRACT = "CALLER_NOT_UPRIGHT_SWAP_TOKEN_CONTRACT";
  string public constant CALLER_NOT_UPRIGHT_BST_CONTRACT = "CALLER_NOT_UPRIGHT_BST_CONTRACT";

  string public constant CALLER_NOT_MANAGER_CONTRACT = "CALLER_NOT_MANAGER_CONTRACT";
  string public constant CALLER_NOT_MANAGER = "CALLER_NOT_MANAGER";

  string public constant CALLER_NOT_CROP_YARD_OR_UPRIGHT_CONTRACT = "CALLER_NOT_CROP_YARD_OR_UPRIGHT_CONTRACT";

  string public constant CALLER_NOT_BSC_VIADUCT_CONTRACT = "CALLER_NOT_BSC_VIADUCT_CONTRACT";
  string public constant CALLER_NOT_ROUTER_CONTRACT = "CALLER_NOT_ROUTER_CONTRACT";
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import { SafeERC20, IERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { SafeMath } from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import { IFisk } from "./interface/IFisk.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import { Errors } from "../../common/libraries/helpers/Errors.sol";
import { IAddressesProvider } from "../../common/configuration/AddressProvider/IAddressesProvider.sol";

contract Fisk is IFisk, ReentrancyGuard {
  using SafeERC20 for IERC20;
  using SafeMath for uint256;

  IAddressesProvider public immutable ADDRESSES_PROVIDER;

  // token_address => (account_address => amount)
  mapping(address => mapping(address => uint256)) private _allowance; // claim allowance
  mapping(address => uint256) private _game_amount; // game amount of user

  constructor(IAddressesProvider provider) {
    ADDRESSES_PROVIDER = provider;
  }

  uint256 public _total_farm_fees;
  uint256 public _total_whitelist_fees;
  /********************************** */
  uint256 public _total_bst_fees;
  uint256 public _total_stable_token_fees;
  uint256 public _total_swap_lp_fees;
  uint256 public _total_swap_token_fees;
  uint256 public _total_borrow_lend_fees;
  uint256 public _total_crop_yard_performance_fees;

  /********************************************* */
  modifier onlyPrime() {
    _onlyPrime();
    _;
  }

  function _onlyPrime() internal view virtual {
    require(ADDRESSES_PROVIDER.getPrimeContract() == msg.sender, Errors.CALLER_NOT_PRIME_CONTRACT);
  }

  modifier onlyWhitelist() {
    _onlyWhitelist();
    _;
  }

  function _onlyWhitelist() internal view virtual {
    require(ADDRESSES_PROVIDER.getWhitelistContract() == msg.sender, Errors.CALLER_NOT_WHITELIST_CONTRACT);
  }

  modifier onlyCropYard() {
    _onlyCropYard();
    _;
  }

  function _onlyCropYard() internal view virtual {
    require(ADDRESSES_PROVIDER.getCropYardContract() == msg.sender, Errors.CALLER_NOT_CROP_YARD_CONTRACT);
  }

  modifier onlyBorrowLend() {
    _onlyBorrowLend();
    _;
  }

  function _onlyBorrowLend() internal view virtual {
    require(ADDRESSES_PROVIDER.getBorrowLendContract() == msg.sender, Errors.CALLER_NOT_BORROW_LEND_CONTRACT);
  }

  modifier onlyUprightStableContract() {
    _onlyUprightStableContract();
    _;
  }

  function _onlyUprightStableContract() internal view virtual {
    require(ADDRESSES_PROVIDER.getUprightStableContract() == msg.sender, Errors.CALLER_NOT_UPRIGHT_STABLE_CONTRACT);
  }

  modifier onlyUprightLpContract() {
    _onlyUprightLpContract();
    _;
  }

  function _onlyUprightLpContract() internal view virtual {
    require(ADDRESSES_PROVIDER.getUprightLpContract() == msg.sender, Errors.CALLER_NOT_UPRIGHT_LP_CONTRACT);
  }

  modifier onlyUprightSwapTokenContract() {
    _onlyUprightSwapTokenContract();
    _;
  }

  function _onlyUprightSwapTokenContract() internal view virtual {
    require(ADDRESSES_PROVIDER.getUprightSwapTokenContract() == msg.sender, Errors.CALLER_NOT_UPRIGHT_SWAP_TOKEN_CONTRACT);
  }

  modifier onlyUprightBstContract() {
    _onlyUprightBstContract();
    _;
  }

  function _onlyUprightBstContract() internal view virtual {
    require(ADDRESSES_PROVIDER.getUprightBstContract() == msg.sender, Errors.CALLER_NOT_UPRIGHT_BST_CONTRACT);
  }

  modifier onlyManagerContract() {
    _onlyManagerContract();
    _;
  }

  function _onlyManagerContract() internal view virtual {
    require(ADDRESSES_PROVIDER.getManagerContract() == msg.sender, Errors.CALLER_NOT_MANAGER_CONTRACT);
  }

  modifier onlyCropYardOrUpright() {
    _onlyCropYardOrUpright();
    _;
  }

  function _onlyCropYardOrUpright() internal view virtual {
    require(
      ADDRESSES_PROVIDER.getCropYardContract() == msg.sender ||
        ADDRESSES_PROVIDER.getUprightStableContract() == msg.sender ||
        ADDRESSES_PROVIDER.getUprightLpContract() == msg.sender ||
        ADDRESSES_PROVIDER.getUprightSwapTokenContract() == msg.sender ||
        ADDRESSES_PROVIDER.getUprightBstContract() == msg.sender,
      Errors.CALLER_NOT_CROP_YARD_OR_UPRIGHT_CONTRACT
    );
  }

  /********************************************* */
  // OK
  function addCropYardFees(uint256 amount) public override nonReentrant onlyCropYard returns (bool) {
    _total_farm_fees += amount;
    return true;
  }

  // OK
  function addWhitelistFees(uint256 amount) public override nonReentrant onlyWhitelist returns (bool) {
    _total_whitelist_fees += amount;
    return true;
  }

  // OK
  function addCropYardPerformanceFees(uint256 amount) public override nonReentrant onlyCropYard returns (bool) {
    _total_crop_yard_performance_fees += amount;
    return true;
  }

  /*************************************************** */
  function addBorrowStakeTokenFees(uint256 amount) public override nonReentrant onlyUprightBstContract returns (bool) {
    _total_bst_fees += amount;
    return true;
  }

  function addStableTokensFees(uint256 amount) public override nonReentrant onlyUprightStableContract returns (bool) {
    _total_stable_token_fees += amount;
    return true;
  }

  function addSwapLpTokensFees(uint256 amount) public override nonReentrant onlyUprightLpContract returns (bool) {
    _total_swap_lp_fees += amount;
    return true;
  }

  function addSwapTokensFees(uint256 amount) public override nonReentrant onlyUprightSwapTokenContract returns (bool) {
    _total_swap_token_fees += amount;
    return true;
  }

  function addBorrowLendFees(uint256 amount) public override nonReentrant onlyBorrowLend returns (bool) {
    _total_borrow_lend_fees += amount;
    return true;
  }

  /******************************************************** */
  // from master for users
  function claim(address account, address token) public override nonReentrant onlyPrime returns (bool) {
    require(_allowance[token][account] > 0, Errors.LOW_ALLOWANCE);

    require(IERC20(token).balanceOf(address(this)) > _allowance[token][account], Errors.LOW_BALANCE);

    IERC20(token).transfer(account, _allowance[token][account]);

    emit claimedFisk(_allowance[token][account], account);

    _allowance[token][account] = 0;

    return true;
  }

  // for contracts , only
  function claimV2(address to, address token, uint256 amount) public override nonReentrant returns (bool) {
    require(_allowance[token][msg.sender] > 0, Errors.LOW_ALLOWANCE);

    require(IERC20(token).balanceOf(address(this)) > amount, Errors.LOW_BALANCE);

    IERC20(token).transfer(to, amount);

    emit claimedV2Fisk(amount, to);
    return true;
  }

  /******************************************************** */
  function allowance(address account, address token) public view virtual override returns (uint256) {
    return _allowance[token][account];
  }

  function approve(address account, uint256 amount, address token) public override nonReentrant onlyManagerContract returns (bool) {
    _allowance[token][account] += amount;
    return true;
  }

  function approvalRest(address account, address token) public override nonReentrant onlyManagerContract returns (bool) {
    _allowance[token][account] = 0;
    return true;
  }

  // send spent from here
  // callable from only , cropyard, and upright

  /********************************************************* */
  // NOTE: add RBCA ( stake , master, mod)
  // ok , cropyard
  function addGameAmount(address account, uint256 amount) public override nonReentrant onlyCropYardOrUpright returns (bool) {
    _game_amount[account] += amount;

    emit GameAmountAdded(account, amount);
    return true;
  }

  // NOTE: add RBCA
  function subGameAmount(address account, uint256 amount) public override nonReentrant onlyManagerContract returns (bool) {
    _game_amount[account] -= amount;

    emit GameAmountSub(account, amount);
    return true;
  }

  function getGameAmount(address account) public view virtual override returns (uint256) {
    return _game_amount[account];
  }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

interface IFisk {
  event claimedFisk(uint256 amount, address account);
  event claimedV2Fisk(uint256 amount, address account);
  event GameAmountAdded(address account, uint256 amount);
  event GameAmountSub(address account, uint256 amount);

  /********************************************************** */

  function addCropYardFees(uint256 amount) external returns (bool);

  function addWhitelistFees(uint256 amount) external returns (bool);

  function addCropYardPerformanceFees(uint256 amount) external returns (bool);

  /***********************STAKE*********************** */
  function addBorrowStakeTokenFees(uint256 amount) external returns (bool);

  function addStableTokensFees(uint256 amount) external returns (bool);

  function addSwapLpTokensFees(uint256 amount) external returns (bool);

  function addSwapTokensFees(uint256 amount) external returns (bool);

  function addBorrowLendFees(uint256 amount) external returns (bool);

  /*************************************************** */

  function claim(address account, address token) external returns (bool);

  function claimV2(address to, address token, uint256 amount) external returns (bool);

  function allowance(address account, address token) external returns (uint256);

  function approve(address account, uint256 amount, address token) external returns (bool);

  function approvalRest(address account, address token) external returns (bool);

  /****************************************************** */

  function addGameAmount(address account, uint256 amount) external returns (bool);

  function subGameAmount(address account, uint256 amount) external returns (bool);

  function getGameAmount(address account) external returns (uint256);
}