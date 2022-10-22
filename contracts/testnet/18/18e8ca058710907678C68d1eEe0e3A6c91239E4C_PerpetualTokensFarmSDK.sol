/**
 *Submitted for verification at BscScan.com on 2022-10-21
*/

// Sources flattened with hardhat v2.9.3 https://hardhat.org

// File @openzeppelin/contracts/token/ERC20/[email protected]


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


// File @openzeppelin/contracts/math/[email protected]


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


// File @openzeppelin/contracts/utils/[email protected]


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


// File @openzeppelin/contracts/token/ERC20/[email protected]


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


// File @openzeppelin/contracts-upgradeable/utils/[email protected]


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


// File @openzeppelin/contracts-upgradeable/proxy/[email protected]


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


// File @openzeppelin/contracts-upgradeable/utils/[email protected]


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


// File @openzeppelin/contracts-upgradeable/access/[email protected]


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


// File @openzeppelin/contracts-upgradeable/utils/[email protected]


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


// File contracts/TokensFarms/PerpetualTokensFarmSDK.sol

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;





contract PerpetualTokensFarmSDK is OwnableUpgradeable, ReentrancyGuardUpgradeable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // Enums
    enum EarlyWithdrawPenalty {
        NO_PENALTY,
        BURN_REWARDS,
        REDISTRIBUTE_REWARDS
    }

    // Info of each user.
    struct StakeInfo {
        // How many tokens the user has provided.
        uint256 amount;
        // Reward debt.
        uint256 rewardDebt;
        // Time when user deposited.
        uint256 depositTime;
        // Time when user withdraw
        uint256 withdrawTime;
        // Address of user
        address addressOfUser;
        // Id of epoch
        uint256 epochId;
        // If stake is paid
        bool paid;
        // When warmup is over
        uint256 warmupExpiration;
        // Flag if stake is finalised
        bool isDepositFinalized;
        // Id of stake
        uint256 id;
        // Already given amount to user
        uint256 paidOutAmount;
    }

    // Info for deposit request
    struct DepositRequest {
        // When was deposited
        uint256 depositTime;
        // How many is deposited
        uint256 stakeAmount;
        // When warmup passes
        uint256 warmupExpiration;
        // Address of user
        address user;
        // Id of stake
        uint256 stakeId;
    }

    // ***** EPOCH INDEPENDENT PARAMETERS ******//

    // Address of ERC20 token contract.
    IERC20 public tokenStaked;
    // Address of the ERC20 Token contract.
    IERC20 public rewardToken;
    // Fee collector address
    address payable public feeCollector;
    // Total fee collected
    uint256 public totalFeeCollectedETH;
    // Total fee collected in tokens
    uint256 public totalFeeCollectedTokens;
    // Address of farm instance
    address public farmImplementation;
    // Number of epochs
    uint256 public epochId;
    // Info of each user that stakes ERC20 tokens
    mapping(address => StakeInfo[]) public stakeInfo;
    // Address of farm manager
    address public contractAdmin;
    // If farm is active or not
    bool public isActive;
    // Total earned for user
    mapping(address => uint256) public totalEarnedForUser;
    // Total pending amount for user
    mapping(address => uint256) public totalPendingAmountForUser;
    // Is farm fully initialised
    bool public init;
    // Last stake id that was updated for user
    mapping(address => uint256) public lastStakeConsumed;
    // Array of deposit requests
    mapping(address => DepositRequest[]) public depositRequest;
    // Waiting list
    address[] public waitingList;
    // Id of user in waiting list
    mapping(address => uint256) public idInList;
    // Number of all pending stakes
    uint256 public noOfPendingStakes;
    // All time high amount to be staked
    mapping(address => uint256) public ATHStake;
    // Last finalised stake
    mapping(address => uint256) public nextStakeToFinalise;
    // If all stakes from prev epoch are migrated
    bool public allStakesAreMigrated;
    // Index of last user migrated
    uint256 public lastUserMigrated;
    // Id of last stake migrated
    uint256 public lastStakeMigrated;

    // ***** EPOCH DEPENDING PARAMETERS ******//

    // Last time number that ERC20s distribution occurs for every epoch
    mapping(uint256 => uint256) public lastRewardTime;
    // Accumulated ERC20s per share, times 1e18 for every epoch
    mapping(uint256 => uint256) public accERC20PerShare;
    // Total tokens deposited in the farm for every epoch
    mapping(uint256 => uint256) public totalDeposits;
    // If contractor allows early withdraw on stakes for every epoch
    mapping(uint256 => bool) public isEarlyWithdrawAllowed;
    // Minimal period of time to stake for every epoch
    mapping(uint256 => uint256) public minTimeToStake;
    // ERC20 tokens rewarded per second for every epoch
    mapping(uint256 => uint256) public rewardPerSecond;
    // Total rewards added to farm for every epoch
    mapping(uint256 => uint256) public totalFundedRewards;
    // Total current rewards for every epoch
    mapping(uint256 => uint256) public totalRewards;
    // The time when farming starts for every epoch
    mapping(uint256 => uint256) public startTime;
    // The time when farming ends for every epoch
    mapping(uint256 => uint256) public endTime;
    // Early withdraw penalty for every epoch
    mapping(uint256 => EarlyWithdrawPenalty) public penalty;
    // Reward fee percent for every epoch
    mapping(uint256 => uint256) public rewardFeePercent;
    // Flat fee amount to deposit for every epoch
    mapping(uint256 => uint256) public flatFeeAmountDeposit;
    // Flat fee amount to withdraw for every epoch
    mapping(uint256 => uint256) public flatFeeAmountWithdraw;
    // Fee option for every epoch
    mapping(uint256 => bool) public isFlatFeeAllowed;
    // Total tokens burned for every epoch
    mapping(uint256 => uint256) public totalTokensBurned;
    // Paid out amounts for every epoch
    mapping(uint256 => uint256) public paidOut;
    // Mapping of every participants array of every epoch
    mapping(uint256 => address[]) public participants;
    // Number of active users per epoch
    mapping(uint256 => uint256) public noOfUsers;
    // Mapping of every users spot in array in every epoch
    mapping(uint256 => mapping(address => uint256)) public id;
    // When first deposit was made for that epoch
    mapping(uint256 => uint256) public firstDepositAt;
    // Total tokens currently staked for user per epoch
    mapping(address => mapping(uint256 => uint256)) public totalActiveStakeAmountPerEpoch;
    // Warm up period in seconds
    mapping(uint256 => uint256) public warmupPeriod;

    // Events
    event Deposit(
        address indexed user,
        uint256 indexed stakeId,
        uint256 indexed amount
    );
    event DepositRequestMade(
        address indexed user,
        uint256 indexed stakeId,
        uint256 indexed amount,
        uint256 warmupExpiration
    );
    event ReducedStake(
        address indexed user,
        uint256 indexed stakeId,
        uint256 indexed stakedAmount,
        uint256 rewardAmount,
        uint256 epochId
    );
    event Withdraw(
        address indexed user,
        uint256 indexed rewardAmount
    );
    event EarlyWithdrawPenaltySet(EarlyWithdrawPenalty indexed penalty);
    event MinTimeToStakeSet(uint256 indexed minTimeToStake);
    event IsEarlyWithdrawAllowedSet(bool indexed allowed);
    event StakeFeePercentSet(uint256 indexed stakeFeePercent);
    event RewardFeePercentSet(uint256 indexed rewardFeePercent);
    event FlatFeeAmountDepositSet(uint256 indexed flatFeeAmount);
    event FlatFeeAmountWithdrawSet(uint256 indexed flatFeeAmount);
    event IsFlatFeeAllowedSet(bool indexed allowed);
    event FeeCollectorSet(address payable indexed feeCollector);
    event ContractAdminSet(address indexed _contractAdmin);
    event ActivateFarm(bool indexed _isActive);
    event WarmupSet(uint256 indexed warmup);

    // Modifiers
    modifier validateStakeByStakeId(address _user, uint256 stakeId) {
        require(stakeId < stakeInfo[_user].length);
        _;
    }
    modifier onlyContractAdmin() {
        require(msg.sender == contractAdmin);
        _;
    }
    modifier onlyContractAdminAndFactory() {
        if(msg.sender != owner()){
            require(msg.sender == contractAdmin);
        }
        _;
    }

    /**
     * @notice function sets initial state of contract
     *
     * @param _erc20 - address of reward token
     * @param _rewardPerSecond - number of reward per second
     * @param _startTime - beginning of farm
     * @param _minTimeToStake - how much time needs to pass before staking
     * @param _isEarlyWithdrawAllowed - is early withdraw allowed or not
     * @param _penalty - ENUM(what type of penalty)
     * @param _tokenStaked - address of token which is staked
     * @param _rewardFeePercent - fee percent for reward distribution
     * @param _flatFeeAmountDeposit - flat fee amount to deposit
     * @param _flatFeeAmountWithdraw - flat fee amount to withdraw
     * @param _isFlatFeeAllowed - is flat fee  allowed or not
     */
    function initialize(
        address _erc20,
        uint256 _rewardPerSecond,
        uint256 _startTime,
        uint256 _minTimeToStake,
        bool _isEarlyWithdrawAllowed,
        uint256 _penalty,
        address _tokenStaked,
        uint256 _rewardFeePercent,
        uint256 _flatFeeAmountDeposit,
        uint256 _flatFeeAmountWithdraw,
        address payable _feeCollector,
        bool _isFlatFeeAllowed
    )
        external
        initializer
    {
        // Upgrading ownership
        __Ownable_init();
        __ReentrancyGuard_init();

        // Requires for correct initialization
        _checkValueBiggerThan(_rewardPerSecond, 0);
        _checkAddress(_erc20);
        _checkAddress(_feeCollector);
        _checkValueBiggerThan(100, _rewardFeePercent);
        require(_startTime >= block.timestamp);

        // Initialization of contract
        epochId = 0;
        rewardToken = IERC20(_erc20);
        tokenStaked = IERC20(_tokenStaked);
        rewardPerSecond[epochId] = _rewardPerSecond;
        startTime[epochId] = _startTime;
        endTime[epochId] = _startTime;
        minTimeToStake[epochId] = _minTimeToStake;
        isEarlyWithdrawAllowed[epochId] = _isEarlyWithdrawAllowed;
        rewardFeePercent[epochId] = _rewardFeePercent;
        flatFeeAmountDeposit[epochId] = _flatFeeAmountDeposit;
        flatFeeAmountWithdraw[epochId] = _flatFeeAmountWithdraw;
        feeCollector = _feeCollector;
        isFlatFeeAllowed[epochId] = _isFlatFeeAllowed;

        _setEarlyWithdrawPenalty(_penalty);

        uint256 _lastRewardTime = startTime[epochId];

        lastRewardTime[epochId] = _lastRewardTime;
        accERC20PerShare[epochId] = 0;
        totalDeposits[epochId] = 0;

        isActive = true;
        allStakesAreMigrated = false;
    }

    /**
     * @notice function is setting the rest of params
     *
     * @param _warmupPeriod - time of warmup in seconds
     * @param _contractAdmin - address of contract admin
     * @param implementation - address of farm implementation
     */
    function setTheRestOfParameters(
        uint256 _warmupPeriod,
        address _contractAdmin,
        address implementation
    )
        external
        onlyOwner
    {
        require(!init);
        _checkAddress(_contractAdmin);
        _checkAddress(implementation);

        warmupPeriod[epochId] = _warmupPeriod;
        contractAdmin = _contractAdmin;
        farmImplementation = implementation;
        init = true;
    }

    // ********************* INTERNAL FUNCTIONS ********************* //

    /**
     * @notice function is checking if farm is active
     */
    function _checkStateOfFarm()
        internal
        view
    {
        require(isActive);
    }

    /**
     * @notice function is checking valid address
     *
     * @param param - address to check
     */
    function _checkAddress(
        address param
    )
        internal
        pure
    {
        require(param != address(0x0));
    }

    /**
     * @notice function is checking if value is bigger than 0
     *
     * @param param1 - first number
     * @param param2 - second number
     */
    function _checkValueBiggerThan(
        uint256 param1,
        uint256 param2
    )
        internal
        pure
    {
        require(param1 > param2);
    }

    /**
     * @notice function is setting early withdrawal penalty, if applicable
     *
     * @param _penalty - number of penalty
     */
    function _setEarlyWithdrawPenalty(
        uint256 _penalty
    )
        internal
    {
        penalty[epochId] = EarlyWithdrawPenalty(_penalty);
        emit EarlyWithdrawPenaltySet(penalty[epochId]);
    }

    /**
     * @notice function is adding participant from farm
     *
     * @param user - address of user
     *
     * @return boolean - if adding is successful or not
     */
    function _addParticipant(
        address user
    )
        internal
        returns(bool)
    {
        if(totalActiveStakeAmountPerEpoch[msg.sender][epochId] > 0){
            return false;
        }

        id[epochId][user] = noOfUsers[epochId];
        noOfUsers[epochId]++;
        participants[epochId].push(user);

        return true;
    }

    /**
     * @notice function is removing participant from farm
     *
     * @param user - address of user
     * @param amount - how many is user withdrawing
     * @param _epochId - id of epoch where stake occurred
     *
     * @return boolean - if removal is successful or not
     */
    function _removeParticipant(
        address user,
        uint256 amount,
        uint256 _epochId
    )
        internal
        returns(bool)
    {
        bool equal = amount == totalActiveStakeAmountPerEpoch[user][epochId];
        if(equal){
            if(noOfUsers[_epochId] != 1){
                uint256 deletedUserId = id[_epochId][user];
                address lastUserInParticipantsArray = participants[_epochId][noOfUsers[_epochId] - 1];
                participants[_epochId][deletedUserId] = lastUserInParticipantsArray;
                id[_epochId][lastUserInParticipantsArray] = deletedUserId;
            }

            delete id[_epochId][user];
            participants[_epochId].pop();
            noOfUsers[_epochId]--;
        }

        return false;
    }

    /**
     * @notice function is transferring money to farm,
     * and supporting deflationary token
     *
     * @param _amount - amount that is funded
     * @param tokenAddress - address of token
     */
    function safeTransferFromAndGetBalance(
        uint256 _amount,
        address tokenAddress
    )
        internal
        returns(uint256)
    {
        IERC20 token = IERC20(tokenAddress);
        uint256 beforeBalance = token.balanceOf(address(this));
        token.safeTransferFrom(
            address(msg.sender),
            address(this),
            _amount
        );
        uint256 afterBalance = token.balanceOf(address(this));

        return afterBalance.sub(beforeBalance);
    }

    /**
     * @notice function is returning staked amount
     * over the epochs
     *
     * @param _user - address of user
     */
    function _totalActiveStakedAmount(
        address _user
    )
        public
        view
        returns (uint256)
    {
        uint256 totalActiveStakeAmount;
        for(uint256 i = 0; i < epochId + 1; i++){
            totalActiveStakeAmount = totalActiveStakeAmount
                .add(totalActiveStakeAmountPerEpoch[_user][i]);
        }

        return totalActiveStakeAmount;
    }

    // ********************* FUNDING FUNCTIONS ********************* //

    /**
     * @notice function is funding the farm, increase the end time
     *
     * @param _amount - how many tokens is funded
     */
    function fund(
        uint256 _amount
    )
        external
    {
        uint256 fundAmount = safeTransferFromAndGetBalance(
            _amount,
            address(rewardToken)
        );

        totalFundedRewards[epochId] = totalFundedRewards[epochId].add(fundAmount);
        _fundInternal(fundAmount);
    }

    /**
     * @notice function is internally funding the farm,
     * by adding farmed rewards by user to the end
     *
     * @param _amount - how many tokens is funded
     */
    function _fundInternal(
        uint256 _amount
    )
        internal
    {
        _checkValueBiggerThan(endTime[epochId], block.timestamp);
        _checkValueBiggerThan(_amount, rewardPerSecond[epochId]);
        _checkValueBiggerThan(_amount, 0);

        // Compute new end time
        endTime[epochId] += _amount.div(rewardPerSecond[epochId]);
        // Increase farm total rewards
        totalRewards[epochId] = totalRewards[epochId].add(_amount);
    }

    // ********************* PERPETUAL FUNCTIONS ********************* //

    /**
     * @notice function is migrating stake to another epoch
     *
     * @param start - start of array
     * @param end - end of the array
     */
    function migrateUserStakes(
        uint256 start,
        uint256 end
    )
        external
        onlyOwner
    {
        require(lastUserMigrated == start);
        require(participants[epochId - 1].length >= end);
        require(epochId >= 1);
        _checkValueBiggerThan(end, start);
        _checkValueBiggerThan(block.timestamp, endTime[epochId - 1]);
        require(block.timestamp >= startTime[epochId]);

        for(uint256 i = start; i < end; i++){
            address user = participants[epochId - 1][i];
            for(uint256 j = 0; j < stakeInfo[user].length; j++){
                StakeInfo storage stake = stakeInfo[user][j];
                require(stake.epochId == epochId - 1);
                if(stake.amount > 0){
                    // Take rewards for this stake
                    _payoutRewardsAndUpdateState(user, stake.id, 0, false, true);

                    // Migrate stake to another epoch
                    updatePool(epochId);

                    totalDeposits[epochId] = totalDeposits[epochId].add(stake.amount);
                    stake.epochId = epochId;
                    stake.rewardDebt = stake.amount.mul(accERC20PerShare[epochId]).div(1e18);

                    _addParticipant(stake.addressOfUser);

                    totalActiveStakeAmountPerEpoch[stake.addressOfUser][epochId] =
                        totalActiveStakeAmountPerEpoch[stake.addressOfUser][epochId].add(stake.amount);
                }

                lastStakeMigrated = stake.id;
            }
        }

        lastUserMigrated = end;
        if(end == participants[epochId - 1].length){
            allStakesAreMigrated = true;
        }
    }

    /**
     * @notice function is resetting the farm
     *
     * @param _startTime - start time of farm
     * @param _rewardPerSecond - rewards per second
     * @param _totalBudget - new fund amount
     * @param _minTimeToStake - minimal time to stake
     * @param _isEarlyWithdrawAllowed - is early withdraw allowed
     * @param _rewardFeePercent - amount of % to take as reward fee
     * @param _flatFeeAmountDeposit - amount to take as flat fee
     * @param _flatFeeAmountWithdraw - amount to take as flat fee
     * @param _isFlatFeeAllowed - if flat fee is allowed or not
     * @param _penalty - type of penalty
     * @param _warmup - warmup period in sec
     */
    function startNewEpoch(
        uint256 _startTime,
        uint256 _rewardPerSecond,
        uint256 _totalBudget,
        uint256 _minTimeToStake,
        bool _isEarlyWithdrawAllowed,
        uint256 _rewardFeePercent,
        uint256 _flatFeeAmountDeposit,
        uint256 _flatFeeAmountWithdraw,
        bool _isFlatFeeAllowed,
        uint256 _penalty,
        uint256 _warmup
    )
        external
        onlyContractAdminAndFactory
    {
        _checkValueBiggerThan(_rewardPerSecond, 0);
        _checkValueBiggerThan(_totalBudget, 0);
        _checkValueBiggerThan(block.timestamp, endTime[epochId]);
        _checkValueBiggerThan(_startTime, block.timestamp);
        require(_rewardFeePercent >= 0 && _rewardFeePercent <= 100);

        // New epoch is starting
        epochId++;

        // From add pool resetting parameters
        uint256 _lastRewardTime = block.timestamp > _startTime
            ? block.timestamp
            : _startTime;

        lastRewardTime[epochId] = _lastRewardTime;
        accERC20PerShare[epochId] = 0;
        totalDeposits[epochId] = 0;

        // From initialize resetting parameters
        startTime[epochId] = _startTime;
        endTime[epochId] = startTime[epochId];
        rewardPerSecond[epochId] = _rewardPerSecond;
        totalRewards[epochId] = 0;
        totalFundedRewards[epochId] = 0;
        minTimeToStake[epochId] = _minTimeToStake;
        isEarlyWithdrawAllowed[epochId] = _isEarlyWithdrawAllowed;
        rewardFeePercent[epochId] = _rewardFeePercent;
        flatFeeAmountDeposit[epochId] = _flatFeeAmountDeposit;
        flatFeeAmountWithdraw[epochId] = _flatFeeAmountWithdraw;
        isFlatFeeAllowed[epochId] = _isFlatFeeAllowed;
        warmupPeriod[epochId] = _warmup;
        _setEarlyWithdrawPenalty(_penalty);

        // Funding the farm
        uint256 fundAmount = safeTransferFromAndGetBalance(_totalBudget, address(rewardToken));

        // Initialize last two epoch parameters
        totalFundedRewards[epochId] = totalFundedRewards[epochId].add(fundAmount);
        _fundInternal(fundAmount);

        allStakesAreMigrated = false;
        lastUserMigrated = 0;
        lastStakeMigrated = 0;
    }

    // ********************* SETTER FUNCTIONS ********************* //

    /**
     * @notice function is setting new minimum time to stake value
     *
     * @param _minTimeToStake - min time to stake
     */
    function setMinTimeToStake(
        uint256 _minTimeToStake
    )
        external
        onlyOwner
    {
        minTimeToStake[epochId] = _minTimeToStake;
        emit MinTimeToStakeSet(minTimeToStake[epochId]);
    }

    /**
     * @notice function is setting new state of early withdraw
     *
     * @param _isEarlyWithdrawAllowed - is early withdraw allowed or not
     */
    function setIsEarlyWithdrawAllowed(
        bool _isEarlyWithdrawAllowed
    )
        external
        onlyOwner
    {
        isEarlyWithdrawAllowed[epochId] = _isEarlyWithdrawAllowed;
        emit IsEarlyWithdrawAllowedSet(isEarlyWithdrawAllowed[epochId]);
    }

    /**
     * @notice function is setting new reward fee percent value
     *
     * @param _rewardFeePercent - reward fee percent
     */
    function setRewardFeePercent(
        uint256 _rewardFeePercent
    )
        external
        onlyOwner
    {
        require(_rewardFeePercent >= 0 && _rewardFeePercent <= 100);

        rewardFeePercent[epochId] = _rewardFeePercent;
        emit RewardFeePercentSet(rewardFeePercent[epochId]);

    }

    /**
     * @notice function is setting new flat fee amount
     *
     * @param _flatFeeAmount - flat fee amount
     */
    function setFlatFeeAmountDeposit(
        uint256 _flatFeeAmount
    )
        external
        onlyOwner
    {
        flatFeeAmountDeposit[epochId] = _flatFeeAmount;
        emit FlatFeeAmountDepositSet(flatFeeAmountDeposit[epochId]);
    }

    /**
     * @notice function is setting new flat fee amount
     *
     * @param _flatFeeAmount - flat fee amount
     */
    function setFlatFeeAmountWithdraw(
        uint256 _flatFeeAmount
    )
        external
        onlyOwner
    {
        flatFeeAmountWithdraw[epochId] = _flatFeeAmount;
        emit FlatFeeAmountWithdrawSet(flatFeeAmountWithdraw[epochId]);
    }

    /**
     * @notice function is setting flat fee allowed
     *
     * @param _isFlatFeeAllowed - is flat fee allowed or not
     */
    function setIsFlatFeeAllowed(
        bool _isFlatFeeAllowed
    )
        external
        onlyOwner
    {
        isFlatFeeAllowed[epochId] = _isFlatFeeAllowed;
        emit IsFlatFeeAllowedSet(isFlatFeeAllowed[epochId]);
    }

    /**
     * @notice function is setting feeCollector on new address
     *
     * @param _feeCollector - address of newFeeCollector
     */
    function setFeeCollector(
        address payable _feeCollector
    )
        external
        onlyOwner
    {
        feeCollector = _feeCollector;
        emit FeeCollectorSet(feeCollector);
    }

    /**
     * @notice function is cool down
     *
     * @param _warmup - warmup time in days
     */
    function setWarmup(
        uint256 _warmup
    )
        external
        onlyOwner
    {
        warmupPeriod[epochId] = _warmup;
        emit WarmupSet(_warmup);
    }

    /**
     * @notice function is setting farmManager on new address
     *
     * @param _contractAdmin - address of farm manager
     */
    function setContractAdmin(
        address _contractAdmin
    )
        external
        onlyOwner
    {
        _checkAddress(_contractAdmin);

        contractAdmin = _contractAdmin;
        emit ContractAdminSet(_contractAdmin);
    }

    // ********************* GETTER FUNCTIONS ********************* //

    /**
     * @notice function is getting all pending stakes,
     * that needs to be finalised
     */
    function getAllPendingStakes()
        external
        view
        returns (DepositRequest[] memory)
    {
        require(warmupPeriod[epochId] != 0);
        require(noOfPendingStakes > 0);

        DepositRequest[] memory pendingStakes = new DepositRequest[](noOfPendingStakes);
        uint256 _noOfPendingStakes;
        for(uint256 i = 0; i < waitingList.length; i++){
            address _user = waitingList[i];
            if(depositRequest[_user].length > 0){
                for(uint256 j = 0; j < depositRequest[_user].length; j++){
                    pendingStakes[_noOfPendingStakes++] = depositRequest[_user][j];
                }
            }
        }

        return pendingStakes;
    }

    /**
     * @notice function is getting number to see pending ERC20s for a user.
     *
     * @dev pending reward =
     * (user.amount * pool.accERC20PerShare) - user.rewardDebt
     *
     * @param _user - address of user
     * @param stakeId - id of user stake
     *
     * @return pending ERC20s for a user.
     */
    function pending(
        address _user,
        uint256 stakeId
    )
        public
        view
        validateStakeByStakeId(_user, stakeId)
        returns (uint256)
    {
        StakeInfo memory stake = stakeInfo[_user][stakeId];
        uint256 _epochId = stake.epochId;

        if (stake.amount == 0 || stake.isDepositFinalized == false) {
            return 0;
        }

        uint256 _accERC20PerShare = accERC20PerShare[_epochId];
        uint256 tokenSupply = totalDeposits[_epochId];

        if (block.timestamp > lastRewardTime[_epochId] && tokenSupply != 0) {
            uint256 lastTime = block.timestamp < endTime[_epochId]
                ? block.timestamp
                : endTime[_epochId];
            uint256 timeToCompare = lastRewardTime[_epochId] < endTime[_epochId]
                ? lastRewardTime[_epochId]
                : endTime[_epochId];
            uint256 nrOfSeconds = lastTime.sub(timeToCompare);
            uint256 erc20Reward = nrOfSeconds.mul(rewardPerSecond[_epochId]);
            _accERC20PerShare = _accERC20PerShare.add(
                erc20Reward.mul(1e18).div(tokenSupply)
            );
        }

        return
            stake.amount.mul(_accERC20PerShare).div(1e18)
                .sub(stake.rewardDebt).sub(stake.paidOutAmount);
    }

    /**
     * @notice function is getting number for total rewards the farm has yet to pay out.
     *
     * @return how many total reward the farm has yet to pay out.
     */
    function totalPending()
        external
        view
        returns (uint256)
    {
        if (
            block.timestamp <= startTime[epochId] ||
            firstDepositAt[epochId] == 0 ||
            totalDeposits[epochId] == 0
        ) {
            return 0;
        }

        uint256 lastTime = block.timestamp < endTime[epochId]
            ? block.timestamp
            : endTime[epochId];
        return rewardPerSecond[epochId]
            .mul(lastTime - firstDepositAt[epochId])
            .sub(paidOut[epochId]);
    }

    /**
     * @notice function is getting number of stakes user has
     *
     * @param user - address of user
     *
     * @return how many times has user staked tokens
     */
    function getNumberOfUserStakes(
        address user
    )
        external
        view
        returns (uint256)
    {
        return stakeInfo[user].length;
    }

    /**
     * @notice function is getting user pending amounts, stakes and deposit time
     *
     * @param user - address of user
     *
     * @return array of deposits,pendingAmounts and depositTime
     */
    function getUserStakesAndPendingAmounts(
        address user
    )
        external
        view
        returns (
            uint256[] memory,
            uint256[] memory,
            uint256[] memory
        )
    {
        uint256 numberOfStakes = stakeInfo[user].length;

        uint256[] memory deposits = new uint256[](numberOfStakes);
        uint256[] memory pendingAmounts = new uint256[](numberOfStakes);
        uint256[] memory depositTime = new uint256[](numberOfStakes);

        for(uint256 i = 0; i < numberOfStakes; i++){
            deposits[i] = stakeInfo[user][i].amount;
            pendingAmounts[i] = pending(user, i);
            depositTime[i] = stakeInfo[user][i].depositTime;
        }

        return (deposits, pendingAmounts, depositTime);
    }

    /**
     * @notice function is getting total rewards locked/unlocked
     *
     * @return totalRewardsUnlocked
     * @return totalRewardsLocked
     */
    function getTotalRewardsLockedUnlocked()
        external
        view
        returns (uint256, uint256)
    {
        uint256 totalRewardsLocked;
        uint256 totalRewardsUnlocked;

        if (block.timestamp <= startTime[epochId]) {
            totalRewardsUnlocked = 0;
            totalRewardsLocked = totalFundedRewards[epochId];
        } else {
            uint256 lastTime = block.timestamp < endTime[epochId]
                ? block.timestamp
                : endTime[epochId];
            totalRewardsUnlocked = rewardPerSecond[epochId].mul(lastTime - startTime[epochId]);
            totalRewardsLocked = totalRewards[epochId] - totalRewardsUnlocked;
        }

        return (totalRewardsUnlocked, totalRewardsLocked);
    }

    /**
     * @notice function is returning stats for user
     *
     * @param _user - address of user
     *
     * @return totalStakedCurrently
     * @return totalEarnedForLifeTime
     * @return currentPendingAmount
     * @return currentBalanceToWithdraw
     */
    function getStatsForUser(
        address _user
    )
        external
        view
        returns (uint256, uint256, uint256, uint256)
    {
        _checkAddress(_user);
        uint256 totalStakedCurrently = _totalActiveStakedAmount(_user);

        uint256 totalEarnedForLifeTime;
        for(uint i = 0; i < stakeInfo[_user].length; i++){
            if(stakeInfo[_user][i].amount != 0){
                uint256 pendingAmount = pending(_user, i);
                totalEarnedForLifeTime = totalEarnedForLifeTime.add(pendingAmount);
            }
        }

        uint256 currentPendingAmount = totalEarnedForLifeTime;
        totalEarnedForLifeTime = totalEarnedForLifeTime.add(totalEarnedForUser[_user]);
        uint256 currentBalanceToWithdraw = totalPendingAmountForUser[_user];

        return(
            totalStakedCurrently,
            totalEarnedForLifeTime,
            currentPendingAmount,
            currentBalanceToWithdraw
        );
    }

    // ********************* DEPOSIT FUNCTIONS ********************* //

    /**
     * @notice function is doing deposit
     *
     * @param _user - address of user
     * @param _amount - amount to deposit
     *
     * @return stakeId
     */
    function _deposit(
        address _user,
        uint256 _amount
    )
        internal
        returns(uint256)
    {
        _checkStateOfFarm();
        _checkAddress(_user);
        _checkValueBiggerThan(_amount, 0);
        _checkValueBiggerThan(endTime[epochId], block.timestamp + warmupPeriod[epochId]);
        require(block.timestamp >= startTime[epochId]);
        require(init);

        StakeInfo memory stake;

        if(firstDepositAt[epochId] == 0){
            firstDepositAt[epochId] = block.timestamp + warmupPeriod[epochId];
        }

        if (isFlatFeeAllowed[epochId]) {
            // Collect flat fee
            require(msg.value == flatFeeAmountDeposit[epochId]);

            totalFeeCollectedETH = totalFeeCollectedETH.add(msg.value);
        }

        // Update user accounting
        stake.amount = _amount;
        stake.depositTime = block.timestamp;
        stake.addressOfUser = _user;
        stake.withdrawTime = 0;
        stake.warmupExpiration = block.timestamp + warmupPeriod[epochId];
        stake.epochId = epochId;

        if(warmupPeriod[epochId] == 0){
            totalDeposits[epochId] = totalDeposits[epochId].add(_amount);
            stake.rewardDebt = stake.amount.mul(accERC20PerShare[epochId]).div(1e18);
            stake.isDepositFinalized = true;
        }

        _addParticipant(_user);

        totalActiveStakeAmountPerEpoch[_user][epochId] =
            totalActiveStakeAmountPerEpoch[_user][epochId].add(_amount);

        if(ATHStake[_user] < _amount){
            ATHStake[_user] = _amount;
        }

        // Compute stake id
        uint256 stakeId = stakeInfo[_user].length;
        stake.id = stakeId;
        // Push new stake to array of stakes for user
        stakeInfo[_user].push(stake);

        return stakeId;
    }

    /**
     * @notice function is making deposit request
     *
     * @param _user - address of user
     * @param _amount - how many tokens user is depositing
     */
    function makeDepositRequest(
        address _user,
        uint256 _amount
    )
        external
        nonReentrant
        payable
        onlyContractAdmin
    {
        require(warmupPeriod[epochId] != 0);

        uint256 stakeId = _deposit(_user, _amount);

        DepositRequest memory _request;
        _request.depositTime = block.timestamp;
        _request.stakeAmount = _amount;
        _request.user = _user;
        _request.warmupExpiration = block.timestamp + warmupPeriod[epochId];
        _request.stakeId = stakeId;

        if(depositRequest[_user].length == 0){
            waitingList.push(_user);
            idInList[_user] = waitingList.length - 1;
        }
        depositRequest[_user].push(_request);

        // Emit deposit event
        emit DepositRequestMade(
            _user,
            stakeId,
            _amount,
            _request.warmupExpiration
        );

        noOfPendingStakes++;
    }

    /**
     * @notice function is finalising one stake that was triggered
     *
     * @param _user - address of user
     * @param stakeId - id of a stake
     */
    function finaliseDeposit(
        address _user,
        uint256 stakeId
    )
        external
        onlyContractAdminAndFactory
        validateStakeByStakeId(_user, stakeId)
    {
        _checkStateOfFarm();
        require(init);
        require(depositRequest[_user].length > 0);
        require(stakeId == nextStakeToFinalise[_user]);

        StakeInfo storage stake = stakeInfo[_user][stakeId];
        uint256 _epochId = stake.epochId;
        require(warmupPeriod[_epochId] != 0);

        uint256 requestId;
        for(uint256 i = 0; i < depositRequest[_user].length; i++){
            if(depositRequest[_user][i].stakeId == stakeId){
                requestId = i;
                break;
            }
        }

        require(depositRequest[_user][requestId].warmupExpiration < block.timestamp);

        updatePool(_epochId);

        uint256 stakedAmount = depositRequest[_user][requestId].stakeAmount;
        // Increase total deposits
        totalDeposits[_epochId] = totalDeposits[_epochId].add(stakedAmount);
        stake.rewardDebt = stakedAmount
            .mul(accERC20PerShare[_epochId])
            .div(1e18);

        // Remove request from array for that user
        uint256 lastRequestId =  depositRequest[_user].length - 1;
        DepositRequest memory lastRequest = depositRequest[_user][lastRequestId];
        depositRequest[_user][requestId] = lastRequest;
        depositRequest[_user].pop();

        // If all of his requests are fulfilled remove him from waiting list
        if(depositRequest[_user].length == 0){
            if(waitingList.length != 1){
                uint256 deletedUserId = idInList[_user];
                address lastUserInWaitingListArray = waitingList[waitingList.length - 1];
                waitingList[deletedUserId] = lastUserInWaitingListArray;
                idInList[lastUserInWaitingListArray] = deletedUserId;
            }
            waitingList.pop();
        }

        noOfPendingStakes--;
        stake.isDepositFinalized = true;
        nextStakeToFinalise[_user]++;
    }

    /**
     * @notice function is depositing ERC20 tokens to Farm for ERC20 allocation.
     *
     * @param _user - address of user
     * @param _amount - how many tokens user is depositing
     */
    function deposit(
        address _user,
        uint256 _amount
    )
        external
        nonReentrant
        payable
        onlyContractAdmin
    {
        require(warmupPeriod[epochId] == 0);

        // Update pool
        updatePool(epochId);

        uint256 stakeId = _deposit(_user, _amount);
        // Emit deposit event
        emit Deposit(_user, stakeId, _amount);
    }

    /**
     * @notice function is updating reward,
     * variables of the given pool to be up-to-date.
     *
     * @param _epochId - id of epoch where stake occurred
     */
    function updatePool(
        uint256 _epochId
    )
        public
    {
        uint256 lastTime = block.timestamp < endTime[_epochId]
            ? block.timestamp
            : endTime[_epochId];

        if (lastTime <= lastRewardTime[_epochId]) {
            return;
        }

        uint256 tokenSupply = totalDeposits[_epochId];

        if (tokenSupply == 0) {
            lastRewardTime[_epochId] = lastTime;
            return;
        }

        uint256 nrOfSeconds = lastTime.sub(lastRewardTime[_epochId]);
        uint256 erc20Reward = nrOfSeconds.mul(rewardPerSecond[_epochId]);

        accERC20PerShare[_epochId] = accERC20PerShare[_epochId].add(
            erc20Reward.mul(1e18).div(tokenSupply)
        );
        lastRewardTime[_epochId] = block.timestamp;
    }

    // ********************* WITHDRAW FUNCTIONS ********************* //

    /**
     * @notice function is paying out rewards to the user
     *
     * @param _user - address of user
     * @param stakeId - id of stake
     * @param _amount - amount that was taken from stake
     * @param _firstTimeCalled - if withdraw is called first time
     *
     * @return pendingAmount
     */
    function _payoutRewardsAndUpdateState(
        address _user,
        uint256 stakeId,
        uint256 _amount,
        bool _firstTimeCalled,
        bool _unStake
    )
        internal
        returns(uint256)
    {
        StakeInfo storage stake = stakeInfo[_user][stakeId];
        uint256 _epochId = stake.epochId;

        if(_amount == 0){
            updatePool(_epochId);
        }

        bool minimalTimeStakeRespected =
            stake.depositTime.add(minTimeToStake[_epochId]) <= block.timestamp;

        // if early withdraw is not allowed, user can't withdraw funds before
        if (!isEarlyWithdrawAllowed[_epochId]) {
            // Check if user has respected minimal time to stake, require it.
            require(minimalTimeStakeRespected);
        }

        // Compute pending rewards amount of user rewards
        uint256 pendingAmount = pending(_user, stakeId);
        stake.paidOutAmount = stake.paidOutAmount.add(pendingAmount);

        // Penalties in case user didn't stake enough time
        if (pendingAmount > 0) {
            if (
                penalty[_epochId] == EarlyWithdrawPenalty.BURN_REWARDS &&
                !minimalTimeStakeRespected
            ) {
                // Burn to address (1)
                totalTokensBurned[_epochId] = totalTokensBurned[_epochId].add(pendingAmount);
                _erc20Transfer(address(1), pendingAmount, _epochId, false, _firstTimeCalled);
                // Update totalRewards
                totalRewards[_epochId] = totalRewards[_epochId].sub(pendingAmount);
            } else if (
                penalty[_epochId] == EarlyWithdrawPenalty.REDISTRIBUTE_REWARDS &&
                !minimalTimeStakeRespected
            ) {
                if (block.timestamp >= endTime[_epochId]) {
                    // Burn rewards because farm can not be funded anymore since it ended
                    _erc20Transfer(address(1), pendingAmount, _epochId, false, _firstTimeCalled);
                    totalTokensBurned[_epochId] = totalTokensBurned[_epochId].add(pendingAmount);
                    // Update totalRewards
                    totalRewards[_epochId] = totalRewards[_epochId].sub(pendingAmount);
                } else {
                    // Re-fund the farm
                    _fundInternal(pendingAmount);
                }
            } else {
                // In case either there's no penalty
                _erc20Transfer(_user, pendingAmount, _epochId, true, _firstTimeCalled);
                // Update totalRewards
                totalRewards[_epochId] = totalRewards[_epochId].sub(pendingAmount);
            }
        }

        if(_unStake){
            _removeParticipant(_user, _amount, _epochId);
            totalActiveStakeAmountPerEpoch[_user][stake.epochId] =
                totalActiveStakeAmountPerEpoch[_user][stake.epochId].sub(_amount);

            stake.withdrawTime = block.timestamp;
            stake.amount = stake.amount.sub(_amount);
            stake.rewardDebt = stake.amount.mul(accERC20PerShare[_epochId]).div(1e18);
            stake.paidOutAmount = 0;

            totalDeposits[_epochId] = totalDeposits[_epochId].sub(_amount);
        }

        return pendingAmount;
    }

    /**
     * @notice function is returning if tx is going to pass or not
     *
     * @param _user - address of user
     * @param _amount - how much is user withdrawing
     */
    function ifPaymentCanPassInOneTx(
        address _user,
        uint256 _amount
    )
        public
        view
        returns(bool)
    {
        uint256 noOfCollectedAmount;
        uint256 firstStakeThatShouldBeConsumed = lastStakeConsumed[_user];
        uint256 lastStakeThatShouldBeConsumed;

        require(_totalActiveStakedAmount(_user) >= _amount);
        if(stakeInfo[_user].length == 1){
            require(stakeInfo[_user][0].isDepositFinalized);
        }

        for(uint256 i = firstStakeThatShouldBeConsumed; i < stakeInfo[_user].length; i++){
            StakeInfo memory stake = stakeInfo[_user][i];
            noOfCollectedAmount = noOfCollectedAmount.add(stake.amount);
            if(_amount <= noOfCollectedAmount || !stake.isDepositFinalized){
                lastStakeThatShouldBeConsumed = i;
                break;
            }
        }

        uint256 noOfStakesConsumed = lastStakeThatShouldBeConsumed.sub(firstStakeThatShouldBeConsumed);
        noOfStakesConsumed++;

        return !(noOfStakesConsumed > 40);
    }

    /**
     * @notice function is noticing withdraw
     *
     * @param _user - address of user
     * @param _amount - how much is user withdrawing
     */
    function noticeReducedStakeWithoutStakeId(
        address _user,
        uint256 _amount
    )
        external
        payable
        onlyContractAdmin
    {
        _checkStateOfFarm();
        require(init);
        require(_totalActiveStakedAmount(_user) >= _amount);
        if(stakeInfo[_user].length == 1){
            require(stakeInfo[_user][0].isDepositFinalized);
        }

        uint256 noOfCollectedAmount;
        uint256 firstStakeConsumed = lastStakeConsumed[_user];

        for(uint256 i = lastStakeConsumed[_user]; i < stakeInfo[_user].length; i++){
            StakeInfo memory stake = stakeInfo[_user][i];
            noOfCollectedAmount = noOfCollectedAmount.add(stake.amount);
            if(_amount <= noOfCollectedAmount || !stake.isDepositFinalized){
                lastStakeConsumed[_user] = i;
                break;
            }
        }

        require(noOfCollectedAmount >= _amount);

        uint256 amountToBePaid;
        bool firstTimeCalled = true;
        for(uint256 i = firstStakeConsumed; i < lastStakeConsumed[_user] + 1; i++){
            StakeInfo storage stake = stakeInfo[_user][i];

            if(i == lastStakeConsumed[_user]){
                amountToBePaid = stake.amount.sub(noOfCollectedAmount.sub(_amount));
            }
            else{
                amountToBePaid = stake.amount;
            }

            uint256 pendingAmount = _payoutRewardsAndUpdateState(
                _user,
                i,
                amountToBePaid,
                firstTimeCalled,
                true
            );
            if(firstTimeCalled){
                firstTimeCalled = false;
            }

            // Emit Withdraw event
            emit ReducedStake(_user, stake.id, _amount, pendingAmount, stake.epochId);
        }
    }

    /**
     * @notice function is withdrawing with caring about rewards
     *
     * @param _user - address of user
     */
    function withdrawRewards(
        address _user
    )
        external
    {
        _checkStateOfFarm();
        require(init);
        _checkAddress(_user);
        address addressOfUser = msg.sender;
        if(msg.sender == contractAdmin){
            addressOfUser = _user;
        }

        bool firstTimeCalled = true;
        for(uint256 i = 0; i < stakeInfo[addressOfUser].length; i++){
            StakeInfo memory stake = stakeInfo[addressOfUser][i];
            bool minimalTimeStakeRespected =
                stake.depositTime.add(minTimeToStake[stake.epochId]) <= block.timestamp;
            if(!stake.isDepositFinalized || !minimalTimeStakeRespected){
                break;
            }
            _payoutRewardsAndUpdateState(addressOfUser, i, 0, firstTimeCalled, false);
            if(firstTimeCalled){
                firstTimeCalled = false;
            }
        }

        _checkValueBiggerThan(totalPendingAmountForUser[addressOfUser], 0);
        rewardToken.transfer(addressOfUser, totalPendingAmountForUser[addressOfUser]);
        emit Withdraw(addressOfUser, totalPendingAmountForUser[addressOfUser]);
        totalPendingAmountForUser[addressOfUser] = 0;
    }

    /**
     * @notice function is activating and deactivating the farm
     */
    function activateOrDeactivate()
        external
        onlyContractAdminAndFactory
    {
        if(isActive){
            isActive = false;
        }
        else{
            isActive = true;
        }
        emit ActivateFarm(isActive);
    }

    /**
     * @notice function is withdrawing fee collected in ERC value
     */
    function withdrawCollectedFeesERC()
        external
        onlyOwner
    {
        rewardToken.transfer(feeCollector, totalFeeCollectedTokens);
        totalFeeCollectedTokens = 0;
    }

    /**
     * @notice function is withdrawing fee collected in ETH value
     */
    function withdrawCollectedFeesETH()
        external
        onlyOwner
    {
        (bool sent, ) = payable(feeCollector).call{value: totalFeeCollectedETH}("");
        require(sent);
        totalFeeCollectedETH = 0;
    }

    /**
     * @notice function is withdrawing tokens if stuck
     *
     * @param _erc20 - address of token address
     * @param _amount - number of how many tokens
     * @param _beneficiary - address of user that collects tokens deposited by mistake
     */
    function withdrawTokensIfStuck(
        address _erc20,
        uint256 _amount,
        address _beneficiary
    )
        external
        onlyOwner
    {
        IERC20 token = IERC20(_erc20);
        _checkAddress(_beneficiary);
        require(rewardToken != token);

        token.safeTransfer(_beneficiary, _amount);
    }

    /**
     * @notice function is transferring ERC20,
     * and update the required ERC20 to payout all rewards
     *
     * @param _to - transfer on this address
     * @param _amount - number of how many tokens
     * @param _epochId - id of epoch
     * @param withoutPenalty - if it is burn or not
     * @param _firstTimeCalled - if withdraw is called first time
     */
    function _erc20Transfer(
        address _to,
        uint256 _amount,
        uint256 _epochId,
        bool withoutPenalty,
        bool _firstTimeCalled
    )
        internal
    {
        if (isFlatFeeAllowed[_epochId]) {
            // Collect flat fee
            require(msg.value == flatFeeAmountWithdraw[_epochId]);
            if(_firstTimeCalled){
                // Increase amount of fees collected
                totalFeeCollectedETH = totalFeeCollectedETH.add(msg.value);
            }
            if(withoutPenalty){
                totalPendingAmountForUser[_to] = totalPendingAmountForUser[_to].add(_amount);
                totalEarnedForUser[_to] = totalEarnedForUser[_to].add(_amount);
            }
            else{
                // send reward
                rewardToken.transfer(_to, _amount);
            }
            paidOut[_epochId] += _amount;
        } else if (rewardFeePercent[_epochId] > 0) {
            // Collect reward fee
            uint256 feeAmount = _amount.mul(rewardFeePercent[_epochId]).div(100);
            uint256 rewardAmount = _amount.sub(feeAmount);

            // Increase amount of fees collected
            totalFeeCollectedTokens = totalFeeCollectedTokens.add(feeAmount);

            if(withoutPenalty){
                totalPendingAmountForUser[_to] = totalPendingAmountForUser[_to].add(rewardAmount);
                totalEarnedForUser[_to] = totalEarnedForUser[_to].add(rewardAmount);
            }
            else{
                // send reward
                rewardToken.transfer(_to, rewardAmount);
            }
            paidOut[_epochId] += _amount;
        } else {
            if(withoutPenalty){
                totalPendingAmountForUser[_to] = totalPendingAmountForUser[_to].add(_amount);
                totalEarnedForUser[_to] = totalEarnedForUser[_to].add(_amount);
            }
            else{
                rewardToken.transfer(_to, _amount);
            }
            paidOut[_epochId] += _amount;
        }
    }
}