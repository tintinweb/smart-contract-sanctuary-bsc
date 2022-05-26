/**
 *Submitted for verification at BscScan.com on 2022-05-26
*/

// SPDX-License-Identifier: MIT

// File oz342/token/ERC20/[email protected]
// License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
}

// File oz342/math/[email protected]
// License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
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
        uint256 c = a + b;
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
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
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
        require(b > 0, "SafeMath: modulo by zero");
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
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
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
        require(b > 0, errorMessage);
        return a / b;
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
        require(b > 0, errorMessage);
        return a % b;
    }
}

// File oz342/utils/[email protected]
// License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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

// File oz342/token/ERC20/[email protected]
// License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;



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
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
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
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// File oz342up/math/[email protected]
// License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
library SafeMathUpgradeable {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
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
        uint256 c = a + b;
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
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
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
        require(b > 0, "SafeMath: modulo by zero");
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
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
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
        require(b > 0, errorMessage);
        return a / b;
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
        require(b > 0, errorMessage);
        return a % b;
    }
}

// File oz342up/utils/[email protected]
// License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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

// File oz342up/proxy/[email protected]
// License-Identifier: MIT

// solhint-disable-next-line compiler-version
pragma solidity >=0.4.24 <0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {UpgradeableProxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {

    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /// @dev Returns true if and only if the function is running in the constructor
    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// File oz342up/utils/[email protected]
// License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}

// File oz342up/access/[email protected]
// License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;


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
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
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
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
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
    uint256[49] private __gap;
}

// File oz342up/utils/[email protected]
// License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
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
    uint256[49] private __gap;
}

// File oz342/proxy/IBeacon.[email protected]
// License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev This is the interface that {BeaconProxy} expects of its beacon.
 */
interface IBeacon {
    /**
     * @dev Must return an address that can be used as a delegate call target.
     *
     * {BeaconProxy} will check that this address is a contract.
     */
    function implementation() external view returns (address);
}

// File oz342/utils/[email protected]
// License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File oz342/access/[email protected]
// License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
    constructor () internal {
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
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
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

// File oz342/proxy/[email protected]
// License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;



/**
 * @dev This contract is used in conjunction with one or more instances of {BeaconProxy} to determine their
 * implementation contract, which is where they will delegate all function calls.
 *
 * An owner is able to change the implementation the beacon points to, thus upgrading the proxies that use this beacon.
 */
contract UpgradeableBeacon is IBeacon, Ownable {
    address private _implementation;

    /**
     * @dev Emitted when the implementation returned by the beacon is changed.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Sets the address of the initial implementation, and the deployer account as the owner who can upgrade the
     * beacon.
     */
    constructor(address implementation_) public {
        _setImplementation(implementation_);
    }

    /**
     * @dev Returns the current implementation address.
     */
    function implementation() public view virtual override returns (address) {
        return _implementation;
    }

    /**
     * @dev Upgrades the beacon to a new implementation.
     *
     * Emits an {Upgraded} event.
     *
     * Requirements:
     *
     * - msg.sender must be the owner of the contract.
     * - `newImplementation` must be a contract.
     */
    function upgradeTo(address newImplementation) public virtual onlyOwner {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Sets the implementation contract address for this beacon
     *
     * Requirements:
     *
     * - `newImplementation` must be a contract.
     */
    function _setImplementation(address newImplementation) private {
        require(Address.isContract(newImplementation), "UpgradeableBeacon: implementation is not a contract");
        _implementation = newImplementation;
    }
}

// File contracts/proxy/CustomBeacon.sol
// License-Identifier: MIT

pragma solidity =0.6.12;

contract CustomBeacon is UpgradeableBeacon {
    string public constant contractName = "CustomBeacon";
    string public constant contractVersion = "0.1";

    constructor(address implementation_)
        public
        UpgradeableBeacon(implementation_)
    {
        // solhint-disable-previous-line no-empty-blocks
    }
}

// File oz342/proxy/[email protected]
// License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev This abstract contract provides a fallback function that delegates all calls to another contract using the EVM
 * instruction `delegatecall`. We refer to the second contract as the _implementation_ behind the proxy, and it has to
 * be specified by overriding the virtual {_implementation} function.
 *
 * Additionally, delegation to the implementation can be triggered manually through the {_fallback} function, or to a
 * different contract through the {_delegate} function.
 *
 * The success and return data of the delegated call will be returned back to the caller of the proxy.
 */
abstract contract Proxy {
    /**
     * @dev Delegates the current call to `implementation`.
     *
     * This function does not return to its internall call site, it will return directly to the external caller.
     */
    function _delegate(address implementation) internal virtual {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    /**
     * @dev This is a virtual function that should be overriden so it returns the address to which the fallback function
     * and {_fallback} should delegate.
     */
    function _implementation() internal view virtual returns (address);

    /**
     * @dev Delegates the current call to the address returned by `_implementation()`.
     *
     * This function does not return to its internall call site, it will return directly to the external caller.
     */
    function _fallback() internal virtual {
        _beforeFallback();
        _delegate(_implementation());
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if no other
     * function in the contract matches the call data.
     */
    fallback () external payable virtual {
        _fallback();
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if call data
     * is empty.
     */
    receive () external payable virtual {
        _fallback();
    }

    /**
     * @dev Hook that is called before falling back to the implementation. Can happen as part of a manual `_fallback`
     * call, or as part of the Solidity `fallback` or `receive` functions.
     *
     * If overriden should call `super._beforeFallback()`.
     */
    function _beforeFallback() internal virtual {
    }
}

// File oz342/proxy/[email protected]
// License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;



/**
 * @dev This contract implements a proxy that gets the implementation address for each call from a {UpgradeableBeacon}.
 *
 * The beacon address is stored in storage slot `uint256(keccak256('eip1967.proxy.beacon')) - 1`, so that it doesn't
 * conflict with the storage layout of the implementation behind the proxy.
 *
 * _Available since v3.4._
 */
contract BeaconProxy is Proxy {
    /**
     * @dev The storage slot of the UpgradeableBeacon contract which defines the implementation for this proxy.
     * This is bytes32(uint256(keccak256('eip1967.proxy.beacon')) - 1)) and is validated in the constructor.
     */
    bytes32 private constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    /**
     * @dev Initializes the proxy with `beacon`.
     *
     * If `data` is nonempty, it's used as data in a delegate call to the implementation returned by the beacon. This
     * will typically be an encoded function call, and allows initializating the storage of the proxy like a Solidity
     * constructor.
     *
     * Requirements:
     *
     * - `beacon` must be a contract with the interface {IBeacon}.
     */
    constructor(address beacon, bytes memory data) public payable {
        assert(_BEACON_SLOT == bytes32(uint256(keccak256("eip1967.proxy.beacon")) - 1));
        _setBeacon(beacon, data);
    }

    /**
     * @dev Returns the current beacon address.
     */
    function _beacon() internal view virtual returns (address beacon) {
        bytes32 slot = _BEACON_SLOT;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            beacon := sload(slot)
        }
    }

    /**
     * @dev Returns the current implementation address of the associated beacon.
     */
    function _implementation() internal view virtual override returns (address) {
        return IBeacon(_beacon()).implementation();
    }

    /**
     * @dev Changes the proxy to use a new beacon.
     *
     * If `data` is nonempty, it's used as data in a delegate call to the implementation returned by the beacon.
     *
     * Requirements:
     *
     * - `beacon` must be a contract.
     * - The implementation returned by `beacon` must be a contract.
     */
    function _setBeacon(address beacon, bytes memory data) internal virtual {
        require(
            Address.isContract(beacon),
            "BeaconProxy: beacon is not a contract"
        );
        require(
            Address.isContract(IBeacon(beacon).implementation()),
            "BeaconProxy: beacon implementation is not a contract"
        );
        bytes32 slot = _BEACON_SLOT;

        // solhint-disable-next-line no-inline-assembly
        assembly {
            sstore(slot, beacon)
        }

        if (data.length > 0) {
            Address.functionDelegateCall(_implementation(), data, "BeaconProxy: function call failed");
        }
    }
}

// File contracts/proxy/CustomBeaconProxy.sol
// License-Identifier: MIT

pragma solidity =0.6.12;

contract CustomBeaconProxy is BeaconProxy {
    string internal constant _contractName = "CustomBeaconProxy";
    string internal constant _contractVersion = "0.1";

    constructor (address beacon) public payable BeaconProxy(beacon, "") {
        // solhint-disable-previous-line no-empty-blocks
    }
}

// File contracts/external/IPancakeFarmsPools.sol
// License-Identifier: MIT

pragma solidity =0.6.12;

interface IManualCake {
    function deposit(uint256 _pid, uint256 _amount) external;

    function withdraw(uint256 _pid, uint256 _amount) external;

    function enterStaking(uint256 _amount) external;

    function leaveStaking(uint256 _amount) external;

    function pendingCake(uint256 _pid, address _user)
        external
        view
        returns (uint256);

    function userInfo(uint256 _pid, address _user)
        external
        view
        returns (uint256, uint256);
}

interface IManualAsset {
    function deposit(uint256 _amount) external;

    function withdraw(uint256 _amount) external;

    function pendingReward(address _user) external view returns (uint256);

    function hasUserLimit() external view returns (bool);

    function poolLimitPerUser() external view returns (uint256);

    function userInfo(address _user) external view returns (uint256, uint256);

    function rewardToken() external view returns (address);

    function stakedToken() external view returns (address);
}

interface ICakePool {
    struct UserInfo {
        uint256 shares; // number of shares for a user.
        uint256 lastDepositedTime; // keep track of deposited time for potential penalty.
        uint256 cakeAtLastUserAction; // keep track of cake deposited at the last user action.
        uint256 lastUserActionTime; // keep track of the last user action time.
        uint256 lockStartTime; // lock start time.
        uint256 lockEndTime; // lock end time.
        uint256 userBoostedShare; // boost share, in order to give the user higher reward. The user only enjoys the reward, so the principal needs to be recorded as a debt.
        bool locked; //lock status.
        uint256 lockedAmount; // amount deposited during lock period.
    }

    function deposit(uint256 _amount, uint256 _lockDuration) external;

    function withdrawAll() external;

    function userInfo(address user)
        external
        view
        returns (
            uint256 shares,
            uint256 lastDepositedTime,
            uint256 cakeAtLastUserAction,
            uint256 lastUserActionTime,
            uint256 lockStartTime,
            uint256 lockEndTime,
            uint256 userBoostedShare,
            bool locked,
            uint256 lockedAmount
        );

    function MIN_LOCK_DURATION() external view returns (uint256);

    function MAX_LOCK_DURATION() external view returns (uint256);

    function MIN_DEPOSIT_AMOUNT() external view returns (uint256);

    function BOOST_WEIGHT() external view returns (uint256);

    function PRECISION_FACTOR() external view returns (uint256);

    function DURATION_FACTOR() external view returns (uint256);
}

// File contracts/mining/CakeFixedTermInvestor.sol
// License-Identifier: MIT

pragma solidity =0.6.12;
pragma experimental ABIEncoderV2;



interface ICakeFixedTermInvestor {
    function initialize() external;

    function approve(
        address token,
        address pool,
        uint256 amount
    ) external;

    function approveMax(address token, address pool) external;

    function approveNil(address token, address pool) external;

    function deposit(
        address pool,
        uint256 amount,
        uint256 lockDuration
    ) external;

    function depositAll(
        address token,
        address pool,
        uint256 lockDuration
    ) external returns (uint256 amount);

    function withdrawAll(address token, address pool)
        external
        returns (uint256 amount);

    function userInfo(address pool)
        external
        view
        returns (ICakePool.UserInfo memory);
}

contract CakeFixedTermInvestor is ICakeFixedTermInvestor, OwnableUpgradeable {
    using SafeERC20 for IERC20;

    string public constant contractName = "CakeFixedTermInvestor";
    string public constant contractVersion = "0.1";

    function initialize() external override initializer {
        __Ownable_init();
    }

    function approve(
        address token,
        address pool,
        uint256 amount
    ) external override onlyOwner {
        _approve(token, pool, amount);
    }

    function approveMax(address token, address pool)
        external
        override
        onlyOwner
    {
        _approve(token, pool, type(uint256).max);
    }

    function approveNil(address token, address pool)
        external
        override
        onlyOwner
    {
        _approve(token, pool, 0);
    }

    function deposit(
        address pool,
        uint256 amount,
        uint256 lockDuration
    ) external override onlyOwner {
        _deposit(pool, amount, lockDuration);
    }

    function depositAll(
        address token,
        address pool,
        uint256 lockDuration
    ) external override onlyOwner returns (uint256 amount) {
        amount = IERC20(token).balanceOf(address(this));
        _deposit(pool, amount, lockDuration);
    }

    function withdrawAll(address token, address pool)
        external
        override
        onlyOwner
        returns (uint256 amount)
    {
        ICakePool(pool).withdrawAll();
        amount = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(_msgSender(), amount);
    }

    function userInfo(address pool)
        external
        view
        override
        returns (ICakePool.UserInfo memory)
    {
        (
            uint256 shares,
            uint256 lastDepositedTime,
            uint256 cakeAtLastUserAction,
            uint256 lastUserActionTime,
            uint256 lockStartTime,
            uint256 lockEndTime,
            uint256 userBoostedShare,
            bool locked,
            uint256 lockedAmount
        ) = ICakePool(pool).userInfo(address(this));
        return
            ICakePool.UserInfo(
                shares,
                lastDepositedTime,
                cakeAtLastUserAction,
                lastUserActionTime,
                lockStartTime,
                lockEndTime,
                userBoostedShare,
                locked,
                lockedAmount
            );
    }

    function _approve(
        address token,
        address pool,
        uint256 amount
    ) internal {
        IERC20(token).approve(pool, amount);
    }

    function _deposit(
        address pool,
        uint256 amount,
        uint256 lockDuration
    ) internal {
        ICakePool(pool).deposit(amount, lockDuration);
    }
}

// File contracts/mining/MiningWithCakeFixedTermBase.sol
// License-Identifier: MIT

pragma solidity =0.6.12;








interface IMiningDataStructure {
    struct UserInfo {
        address userAddr;
        uint256 currentStaked;
        uint256 lockStartTime;
        uint256 lockEndTime;
        uint256 currentUnlocked;
        uint256 shares;
        uint256 boostWeight;
        uint256 rewardDebt;
        uint256 rewardLocked;
        uint256 rewardSettled;
        uint256 rewardWithdrawn;
        uint256 rewardReleased;
        uint256 rewardLockNum;
        uint256 lastReleaseTime;
        address investor;
    }

    struct PoolInfo {
        address stakeToken;
        address rewardToken;
        uint256 rewardPerBlock;
        uint256 lastRewardBlock;
        uint256 accRewardPerShare;
        uint256 currentStaked;
        uint256 currentUnlocked;
        uint256 totalShares;
        uint256 rewardSettled;
        uint256 rewardWithdrawn;
        uint256 rewardLockTime;
        uint256 minLockNum;
        uint256 maxLockNum;
        uint256 minRelease;
        address target;
        address receiver;
        address beacon;
        address investor;
        uint256 minStakeAmount;
    }

    struct AccRewardPerShareInfo {
        uint256 timestamp;
        uint256 blockNumber;
        uint256 accRewardPerShare;
    }

    event TokenStaked(
        uint256 indexed pool,
        address indexed _user,
        uint256 _amount,
        uint256 _prev,
        uint256 _currentReward,
        uint256 timestamp
    );

    event RewardWithdrawn(
        uint256 indexed pool,
        address indexed _user,
        uint256 _amount,
        uint256 _rewardLeft,
        uint256 timestamp
    );

    event TokenLocked(
        uint256 indexed pool,
        address indexed user,
        uint256 amount,
        uint256 lockStartTime,
        uint256 lockEndTime,
        uint256 timestamp
    );

    event TokenUnlocked(
        uint256 indexed pool,
        address indexed user,
        uint256 amount,
        uint256 timestamp
    );

    event TokenUnstaked(
        uint256 indexed pool,
        address indexed user,
        uint256 amount,
        uint256 timestamp
    );
}

interface IMiningWithCakeFixedTerm is IMiningDataStructure {
    function stake(uint256 amount, uint256 lockDuratiuon) external;

    function unlock(address addr) external;

    function unlockSelf() external;

    function unstake() external;

    function withdraw() external;

    function overview()
        external
        view
        returns (
            PoolInfo memory poolInfo,
            uint256 boostWeight,
            uint256 minDepositAmount,
            uint256 minLockDuration,
            uint256 maxLockDuration,
            uint256 unsettledReward,
            uint256 latestAccRewardPerShare
        );

    function getUserInfo(address user)
        external
        view
        returns (
            UserInfo memory userInfo,
            ICakePool.UserInfo memory targetInfo,
            uint256 unsettledReward,
            uint256 unsettledReleased
        );
}

abstract contract MiningDataStorage is
    IMiningDataStructure,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable
{
    using SafeMath for uint256;

    uint256 public constant SHARE_BASE = 1e18;

    mapping(uint256 => PoolInfo) internal pools;
    mapping(address => UserInfo) internal users;

    mapping(uint256 => AccRewardPerShareInfo) internal accRewardRecords;
    uint256 internal accRewardRecordCount;
}

abstract contract MiningWithCakeFixedTermBase is
    IMiningWithCakeFixedTerm,
    MiningDataStorage
{}

// File contracts/mining/MiningWithCakeFixedTerm.sol
// License-Identifier: MIT

pragma solidity =0.6.12;

contract MiningWithCakeFixedTerm is MiningWithCakeFixedTermBase {
    using SafeERC20 for IERC20;

    string public constant contractName = "MiningWithCakeFixedTerm";
    string public constant contractVersion = "0.1";

    function initialize(
        address stakeToken,
        address rewardToken,
        uint256 rewardPerBlock,
        uint256 rewardLockTime,
        uint256 minLockNum,
        uint256 maxLockNum,
        uint256 minRelease,
        address target,
        address receiver,
        address investor,
        uint256 minStakeAmount
    ) external initializer {
        __Ownable_init();
        __ReentrancyGuard_init();

        pools[0].stakeToken = stakeToken;
        pools[0].rewardToken = rewardToken;
        pools[0].rewardPerBlock = rewardPerBlock;
        pools[0].rewardLockTime = rewardLockTime;
        pools[0].minLockNum = minLockNum;
        pools[0].maxLockNum = maxLockNum;
        pools[0].minRelease = minRelease;
        pools[0].target = target;
        pools[0].receiver = receiver;
        pools[0].investor = investor;
        pools[0].minStakeAmount = minStakeAmount;

        pools[0].beacon = address(new CustomBeacon(investor));
        pools[0].lastRewardBlock = block.number;
    }

    function setRewardPerBlock(uint256 rewardPerBlock) external onlyOwner {
        _updatePool(pools[0]);
        pools[0].rewardPerBlock = rewardPerBlock;
    }

    function setReceiver(address receiver) external onlyOwner {
        pools[0].receiver = receiver;
    }

    function setMinRelease(uint256 minRelease) external onlyOwner {
        pools[0].minRelease = minRelease;
    }

    function setMinStakeAmount(uint256 minStakeAmount) external onlyOwner {
        pools[0].minStakeAmount = minStakeAmount;
    }

    function upgradeInvestor(address investor) external onlyOwner {
        CustomBeacon(pools[0].beacon).upgradeTo(investor);
        pools[0].investor = investor;
    }

    function stake(uint256 amount, uint256 lockDuration)
        external
        override
        nonReentrant
    {
        PoolInfo storage pool = pools[0];
        IERC20 token = IERC20(pool.stakeToken);
        ICakePool target = ICakePool(pool.target);
        UserInfo storage user = users[_msgSender()];
        uint256 prevAmount = user.currentStaked;

        if (user.lockEndTime > 0 && user.lockEndTime < block.timestamp) {
            _userUnlock(token, pool, user, target);
        }

        uint256 deposit = amount.add(user.currentUnlocked);
        pool.currentUnlocked = pool.currentUnlocked.sub(user.currentUnlocked);
        user.currentUnlocked = 0;

        require(
            deposit >= target.MIN_DEPOSIT_AMOUNT() &&
                lockDuration >= target.MIN_LOCK_DURATION() &&
                deposit >= pools[0].minStakeAmount &&
                lockDuration > 0,
            "Invalid stake!!"
        );

        token.safeTransferFrom(_msgSender(), address(this), amount);

        if (user.investor == address(0)) {
            user.investor = address(new CustomBeaconProxy(pool.beacon));
            ICakeFixedTermInvestor(user.investor).initialize();
            ICakeFixedTermInvestor(user.investor).approveMax(
                pool.stakeToken,
                pool.target
            );
            user.userAddr = _msgSender();
        }

        _updatePool(pool);
        _userDeposit(token, pool, user, deposit, lockDuration);
        _updateUserReward(pool, user);
        _updateUserReleased(pool, user);
        _updateRewardParams(pool, user, target);

        emit TokenStaked(
            0,
            user.userAddr,
            user.currentStaked,
            prevAmount,
            user.rewardLocked.add(user.rewardSettled).add(user.rewardReleased),
            block.timestamp
        );
    }

    function unlock(address addr) external override nonReentrant {
        PoolInfo storage pool = pools[0];
        IERC20 token = IERC20(pool.stakeToken);
        ICakePool target = ICakePool(pool.target);
        UserInfo storage user = users[addr];

        require(user.lockEndTime > 0, "Nothing to unlock!!");
        require(user.lockEndTime < block.timestamp, "Still in lock period!!");

        _userUnlock(token, pool, user, target);
    }

    function unlockSelf() external override nonReentrant {
        PoolInfo storage pool = pools[0];
        IERC20 token = IERC20(pool.stakeToken);
        ICakePool target = ICakePool(pool.target);
        UserInfo storage user = users[_msgSender()];

        require(user.lockEndTime > 0, "Nothing to unlock!!");
        require(user.lockEndTime < block.timestamp, "Still in lock period!!");

        _userUnlock(token, pool, user, target);
    }

    function unstake() external override nonReentrant {
        PoolInfo storage pool = pools[0];
        IERC20 token = IERC20(pool.stakeToken);
        ICakePool target = ICakePool(pool.target);
        UserInfo storage user = users[_msgSender()];

        _userUnlock(token, pool, user, target);

        require(user.currentUnlocked > 0, "No unlocked token!!");

        token.safeTransfer(user.userAddr, user.currentUnlocked);

        emit TokenUnstaked(
            0,
            user.userAddr,
            user.currentUnlocked,
            block.timestamp
        );

        pool.currentUnlocked = pool.currentUnlocked.sub(user.currentUnlocked);
        user.currentUnlocked = 0;
    }

    function withdraw() external override nonReentrant {
        PoolInfo storage pool = pools[0];
        IERC20 stakeToken = IERC20(pool.stakeToken);
        IERC20 rewardToken = IERC20(pool.rewardToken);
        ICakePool target = ICakePool(pool.target);
        UserInfo storage user = users[_msgSender()];

        if (user.lockEndTime > 0 && user.lockEndTime < block.timestamp) {
            _userUnlock(stakeToken, pool, user, target);
        }

        _updatePool(pool);
        _updateUserReward(pool, user);
        _updateUserReleased(pool, user);

        require(user.rewardReleased > 0, "No reward to withdraw!!");
        require(
            rewardToken.balanceOf(address(this)) >= user.rewardReleased,
            "Not enough reward token in pool!!"
        );
        rewardToken.safeTransfer(user.userAddr, user.rewardReleased);
        user.rewardWithdrawn = user.rewardWithdrawn.add(user.rewardReleased);
        pool.rewardSettled = pool.rewardSettled.sub(user.rewardReleased);
        pool.rewardWithdrawn = pool.rewardWithdrawn.add(user.rewardReleased);

        emit RewardWithdrawn(
            0,
            user.userAddr,
            user.rewardReleased,
            user.rewardSettled.add(user.rewardLocked),
            block.timestamp
        );

        user.rewardReleased = 0;
    }

    function overview()
        external
        view
        override
        returns (
            PoolInfo memory poolInfo,
            uint256 boostWeight,
            uint256 minDepositAmount,
            uint256 minLockDuration,
            uint256 maxLockDuration,
            uint256 unsettledReward,
            uint256 latestAccRewardPerShare
        )
    {
        poolInfo = pools[0];
        ICakePool target = ICakePool(poolInfo.target);
        boostWeight = target.BOOST_WEIGHT();
        minDepositAmount = target.MIN_DEPOSIT_AMOUNT();
        minLockDuration = target.MIN_LOCK_DURATION();
        maxLockDuration = target.MAX_LOCK_DURATION();
        (unsettledReward, latestAccRewardPerShare) = _unsettledPoolReward(
            pools[0]
        );
    }

    function getUserInfo(address user)
        external
        view
        override
        returns (
            UserInfo memory userInfo,
            ICakePool.UserInfo memory targetInfo,
            uint256 unsettledReward,
            uint256 unsettledReleased
        )
    {
        userInfo = users[user];
        if (userInfo.investor != address(0)) {
            targetInfo = ICakeFixedTermInvestor(userInfo.investor).userInfo(
                pools[0].target
            );
        } else {
            targetInfo = ICakePool.UserInfo(0, 0, 0, 0, 0, 0, 0, false, 0);
        }

        PoolInfo memory poolInfo = pools[0];
        (
            uint256 newReward,
            uint256 newAccRewardPerShare
        ) = _unsettledPoolReward(poolInfo);
        poolInfo.rewardSettled = poolInfo.rewardSettled.add(newReward);
        poolInfo.accRewardPerShare = newAccRewardPerShare;
        unsettledReward = _unsettledUserReward(poolInfo, userInfo);
        unsettledReleased = _unsettledUserReleased(poolInfo, userInfo);
    }

    function _updatePool(PoolInfo storage pool) internal {
        if (block.number > pool.lastRewardBlock) {
            uint256 newReward = 0;
            if (pool.totalShares > 0) {
                (newReward, pool.accRewardPerShare) = _unsettledPoolReward(
                    pool
                );
            }
            pool.rewardSettled = pool.rewardSettled.add(newReward);
            pool.lastRewardBlock = block.number;

            accRewardRecords[accRewardRecordCount].timestamp = block.timestamp;
            accRewardRecords[accRewardRecordCount].blockNumber = block.number;
            accRewardRecords[accRewardRecordCount].accRewardPerShare = pool
                .accRewardPerShare;
            accRewardRecordCount++;
        }
    }

    function _userDeposit(
        IERC20 token,
        PoolInfo storage pool,
        UserInfo storage user,
        uint256 amount,
        uint256 lockDuration
    ) internal {
        ICakeFixedTermInvestor investor = ICakeFixedTermInvestor(user.investor);
        token.safeTransfer(user.investor, amount);
        uint256 lockAmount = investor.depositAll(
            pool.stakeToken,
            pool.target,
            lockDuration
        );
        ICakePool.UserInfo memory targetInfo = investor.userInfo(pool.target);
        user.lockStartTime = targetInfo.lockStartTime;
        user.lockEndTime = targetInfo.lockEndTime;
        emit TokenLocked(
            0,
            user.userAddr,
            lockAmount,
            user.lockStartTime,
            user.lockEndTime,
            block.timestamp
        );
        user.currentStaked = user.currentStaked.add(amount);
        pool.currentStaked = pool.currentStaked.add(amount);
    }

    function _userUnlock(
        IERC20 token,
        PoolInfo storage pool,
        UserInfo storage user,
        ICakePool target
    ) internal {
        if (user.lockEndTime <= 0 || user.lockEndTime >= block.timestamp) {
            return;
        }

        ICakeFixedTermInvestor investor = ICakeFixedTermInvestor(user.investor);

        _updatePool(pool);
        uint256 unlockAmount = investor.withdrawAll(
            pool.stakeToken,
            pool.target
        );
        require(
            unlockAmount >= user.currentStaked,
            "withdrawn amount less than staked amount!!"
        );

        token.safeTransfer(pool.receiver, unlockAmount.sub(user.currentStaked));

        _updateUserReward(pool, user);
        _updateUserReleased(pool, user);

        user.rewardSettled = user.rewardSettled.add(user.rewardLocked);
        user.rewardLocked = 0;
        user.lockStartTime = 0;
        user.lockEndTime = 0;
        user.currentUnlocked = user.currentUnlocked.add(user.currentStaked);
        pool.currentUnlocked = pool.currentUnlocked.add(user.currentStaked);
        pool.currentStaked = pool.currentStaked.sub(user.currentStaked);
        user.currentStaked = 0;

        _updateRewardParams(pool, user, target);

        emit TokenUnlocked(
            0,
            user.userAddr,
            user.currentUnlocked,
            block.timestamp
        );
    }

    function _updateUserReward(PoolInfo storage pool, UserInfo storage user)
        internal
    {
        uint256 newReward = _unsettledUserReward(pool, user);
        user.rewardLocked = user.rewardLocked.add(newReward);
    }

    function _updateUserReleased(PoolInfo storage pool, UserInfo storage user)
        internal
    {
        if (
            user.rewardSettled > 0 &&
            user.lastReleaseTime > 0 &&
            block.timestamp > user.lastReleaseTime
        ) {
            uint256 released = _unsettledUserReleased(pool, user);
            user.rewardReleased = user.rewardReleased.add(released);
            user.rewardSettled = user.rewardSettled.sub(released);
        }
        user.lastReleaseTime = block.timestamp;
    }

    function _updateRewardParams(
        PoolInfo storage pool,
        UserInfo storage user,
        ICakePool target
    ) internal {
        pool.totalShares = pool.totalShares.sub(user.shares);
        user.boostWeight = (user.lockEndTime - user.lockStartTime)
            .mul(target.BOOST_WEIGHT())
            .div(target.DURATION_FACTOR());
        user.shares = user
            .currentStaked
            .mul(user.boostWeight)
            .div(target.PRECISION_FACTOR())
            .add(user.currentStaked);
        pool.totalShares = pool.totalShares.add(user.shares);
        user.rewardDebt = user.shares.mul(pool.accRewardPerShare).div(
            SHARE_BASE
        );

        if (user.lockEndTime > 0) {
            uint256 lockDiff = user.lockEndTime.sub(user.lockStartTime).sub(
                target.MIN_LOCK_DURATION()
            );
            uint256 maxDiff = target.MAX_LOCK_DURATION().sub(
                target.MIN_LOCK_DURATION()
            );
            uint256 lockNum = pool.maxLockNum.sub(
                pool.maxLockNum.sub(pool.minLockNum).mul(lockDiff).div(maxDiff)
            );
            if (
                (user.rewardSettled <= 0 &&
                    user.rewardLocked <= 0 &&
                    user.shares <= 0) || lockNum > user.rewardLockNum
            ) {
                user.rewardLockNum = lockNum;
            }
        }
    }

    function _unsettledPoolReward(PoolInfo memory pool)
        internal
        view
        returns (uint256 newReward, uint256 newAccRewardPerShare)
    {
        if (pool.totalShares <= 0) {
            return (0, pool.accRewardPerShare);
        }

        if (pool.lastRewardBlock <= 0 || pool.lastRewardBlock >= block.number) {
            return (0, pool.accRewardPerShare);
        }

        if (pool.rewardPerBlock <= 0) {
            return (0, pool.accRewardPerShare);
        }

        newReward = block.number.sub(pool.lastRewardBlock).mul(
            pool.rewardPerBlock
        );
        newAccRewardPerShare = pool.accRewardPerShare.add(
            newReward.mul(SHARE_BASE).div(pool.totalShares)
        );
    }

    function _unsettledUserReleased(PoolInfo memory pool, UserInfo memory user)
        internal
        view
        returns (uint256)
    {
        if (user.rewardSettled <= 0) {
            return 0;
        }

        if (
            user.lastReleaseTime <= 0 || user.lastReleaseTime >= block.timestamp
        ) {
            return 0;
        }

        uint256 releaseNum = block.timestamp.sub(user.lastReleaseTime).div(
            pool.rewardLockTime
        );
        releaseNum = releaseNum > user.rewardLockNum
            ? user.rewardLockNum
            : releaseNum;
        uint256 released = user.rewardSettled.mul(releaseNum).div(
            user.rewardLockNum
        );
        released = released > 0 && released < pool.minRelease
            ? pool.minRelease
            : released;
        released = released > user.rewardSettled
            ? user.rewardSettled
            : released;

        return released;
    }

    function _unsettledUserReward(PoolInfo memory pool, UserInfo memory user)
        internal
        pure
        returns (uint256)
    {
        if (user.shares <= 0) {
            return 0;
        }

        if (pool.accRewardPerShare <= 0) {
            return 0;
        }

        return
            user.shares.mul(pool.accRewardPerShare).div(SHARE_BASE).sub(
                user.rewardDebt
            );
    }
}