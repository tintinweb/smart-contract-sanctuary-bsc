/**
 *Submitted for verification at BscScan.com on 2022-03-12
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;


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
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

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

    constructor () internal {
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
}

/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {

  /**
   * @dev Indicates that the contract has been initialized.
   */
  bool private initialized;

  /**
   * @dev Indicates that the contract is in the process of being initialized.
   */
  bool private initializing;

  /**
   * @dev Modifier to use in the initializer function of a contract.
   */
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  /// @dev Returns true if and only if the function is running in the constructor
  function isConstructor() private view returns (bool) {
    // extcodesize checks the size of the code stored in an address, and
    // address returns the current address. Since the code is still not
    // deployed when running a constructor, any checks on its code size will
    // yield zero, making it an effective way to detect if a contract is
    // under construction or not.
    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
}

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
contract ContextUpgradeSafe is Initializable {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.

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
contract OwnableUpgradeSafe is Initializable, ContextUpgradeSafe {
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
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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

interface IDollar {
    function poolBurnFrom(address _address, uint256 _amount) external;

    function poolMint(address _address, uint256 m_amount) external;
}

interface ITreasury {
    function hasPool(address _address) external view returns (bool);

    function minting_fee() external view returns (uint256);

    function redemption_fee() external view returns (uint256);

    function reserve_share_state() external view returns (uint8);

    function collateralReserve() external view returns (address);

    function profitSharingFund() external view returns (address);

    function darkInsuranceFund() external view returns (address);

    function globalCollateralBalance(uint256) external view returns (uint256);

    function globalCollateralValue(uint256) external view returns (uint256);

    function globalCollateralTotalValue() external view returns (uint256);

    function globalDarkBalance() external view returns (uint256);

    function globalDarkValue() external view returns (uint256);

    function globalShareBalance() external view returns (uint256);

    function globalShareValue() external view returns (uint256);

    function getEffectiveCollateralRatio() external view returns (uint256);

    function requestTransfer(address token, address receiver, uint256 amount) external;

    function requestBurnShare(uint256 _fee) external;

    function requestTransferDarkFee(uint256 _fee) external;

    function reserveReceiveDark(uint256 _amount) external;

    function reserveReceiveShare(uint256 _amount) external;

    function info()
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint8
        );
}

interface IOracle {
    function consult() external view returns (uint256);

    function consultTrue() external view returns (uint256);
}

interface IPool {
    function targetCollateralRatio() external view returns (uint256);

    function targetDarkOverDarkShareRatio() external view returns (uint256);

    function calcMintInput(uint256 _dollarAmount) external view returns (uint256 _mainCollateralAmount, uint256 _darkAmount, uint256 _shareAmount, uint256 _darkFee, uint256 _shareFee);

    function calcMintOutputFromCollaterals(uint256[] memory _collateralAmounts) external view returns (uint256 _dollarAmount, uint256 _darkAmount, uint256 _shareAmount, uint256 _darkFee, uint256 _shareFee);

    function calcMintOutputFromDark(uint256 _darkAmount) external view returns (uint256 _dollarAmount, uint256 _mainCollateralAmount, uint256 _shareAmount, uint256 _darkFee, uint256 _shareFee);

    function calcMintOutputFromShare(uint256 _shareAmount) external view returns (uint256 _dollarAmount, uint256 _mainCollateralAmount, uint256 _darkAmount, uint256 _darkFee, uint256 _shareFee);

    function calcRedeemOutput(uint256 _dollarAmount) external view returns (uint256[] memory _collateralAmounts, uint256 _darkAmount, uint256 _shareAmount, uint256 _darkFee, uint256 _shareFee);

    function getCollateralPrice(uint256 _index) external view returns (uint256);

    function getDollarPrice() external view returns (uint256);

    function getDarkPrice() external view returns (uint256);

    function getSharePrice() external view returns (uint256);

    function getRedemptionOpenTime(address _account) external view returns (uint256);

    function unclaimed_pool_collateral(uint256) external view returns (uint256);

    function unclaimed_pool_dark() external view returns (uint256);

    function unclaimed_pool_share() external view returns (uint256);

    function mintingLimitHourly() external view returns (uint256 _limit);

    function mintingLimitDaily() external view returns (uint256 _limit);

    function calcMintableDollarHourly() external view returns (uint256 _limit);

    function calcMintableDollarDaily() external view returns (uint256 _limit);

    function calcMintableDollar() external view returns (uint256 _dollarAmount);

    function calcRedeemableDollarHourly() external view returns (uint256 _limit);

    function calcRedeemableDollarDaily() external view returns (uint256 _limit);

    function calcRedeemableDollar() external view returns (uint256 _dollarAmount);

    function updateTargetCollateralRatio() external;

    function updateTargetDarkOverShareRatio() external;
}

interface ICollateralReserve {
    function fundBalance(address _token) external view returns (uint256);

    function transferTo(address _token, address _receiver, uint256 _amount) external;

    function burnToken(address _token, uint256 _amount) external;

    function receiveDarks(uint256 _amount) external;

    function receiveShares(uint256 _amount) external;
}

interface IBasisAsset {
    function decimals() external view returns (uint8);

    function cap() external view returns (uint256);

    function mint(address, uint256) external;

    function burn(uint256) external;

    function burnFrom(address, uint256) external;

    function isOperator() external returns (bool);

    function operator() external view returns (address);

    function transferOperator(address newOperator_) external;

    function transferOwnership(address newOwner_) external;
}

contract Pool is OwnableUpgradeSafe, ReentrancyGuard, IPool {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    /* ========== ADDRESSES ================ */
    address[] public collaterals;
    address public dollar;
    address public dark;
    address public share;
    address public treasury;

    address public oracleDollar;
    address public oracleDark;
    address public oracleShare;
    address[] public oracleCollaterals;

    /* ========== STATE VARIABLES ========== */

    mapping(address => uint256) public redeem_dark_balances;
    mapping(address => uint256) public redeem_share_balances;
    mapping(address => mapping(uint256 => uint256)) public redeem_collateral_balances;

    uint256[] private unclaimed_pool_collaterals_;
    uint256 private unclaimed_pool_dark_;
    uint256 private unclaimed_pool_share_;

    mapping(address => uint256) public last_redeemed;

    // Constants for various precisions
    uint256 private constant PRICE_PRECISION = 1e6;

    // Number of decimals needed to get to 18
    uint256[] private missing_decimals;

    // Number of seconds to wait before being able to collectRedemption()
    uint256 public redemption_delay;

    // AccessControl state variables
    bool public mint_paused = false;
    bool public redeem_paused = false;
    bool public contract_allowed = false;
    mapping(address => bool) public whitelisted;

    uint256 private targetCollateralRatio_;
    uint256 private targetDarkOverDarkShareRatio_;

    uint256 public updateStepTargetCR;
    uint256 public updateStepTargetDODSR;

    uint256 public updateCoolingTimeTargetCR;
    uint256 public updateCoolingTimeTargetDODSR;

    uint256 public lastUpdatedTargetCR;
    uint256 public lastUpdatedTargetDODSR;

    mapping(address => bool) public strategist;

    uint256 public constant T_ZERO_TIMESTAMP = 1646092800; // (Tuesday, 1 March 2022 00:00:00 GMT+0)

    mapping(uint256 => uint256) public totalMintedHourly; // hour_index => total_minted
    mapping(uint256 => uint256) public totalMintedDaily; // day_index => total_minted
    mapping(uint256 => uint256) public totalRedeemedHourly; // hour_index => total_redeemed
    mapping(uint256 => uint256) public totalRedeemedDaily; // day_index => total_redeemed

    uint256 private mintingLimitOnce_;
    uint256 private mintingLimitHourly_;
    uint256 private mintingLimitDaily_;

    /* =================== Added variables (need to keep orders for proxy to work) =================== */
    // ...

    /* ========== EVENTS ========== */

    event TreasuryUpdated(address indexed newTreasury);
    event StrategistStatusUpdated(address indexed account, bool status);
    event MintPausedUpdated(bool mint_paused);
    event RedeemPausedUpdated(bool redeem_paused);
    event ContractAllowedUpdated(bool contract_allowed);
    event WhitelistedUpdated(address indexed account, bool whitelistedStatus);
    event TargetCollateralRatioUpdated(uint256 targetCollateralRatio_);
    event TargetDarkOverShareRatioUpdated(uint256 targetDarkOverDarkShareRatio_);
    event Mint(address indexed account, uint256 dollarAmount, uint256[] collateralAmounts, uint256 darkAmount, uint256 shareAmount, uint256 darkFee, uint256 shareFee);
    event Redeem(address indexed account, uint256 dollarAmount, uint256[] collateralAmounts, uint256 darkAmount, uint256 shareAmount, uint256 darkFee, uint256 shareFee);
    event CollectRedemption(address indexed account, uint256[] collateralAmounts, uint256 darkAmount, uint256 shareAmount);

    /* ========== MODIFIERS ========== */

    modifier onlyTreasury() {
        require(msg.sender == treasury, "!treasury");
        _;
    }

    modifier onlyTreasuryOrOwner() {
        require(msg.sender == treasury || msg.sender == owner(), "!treasury && !owner");
        _;
    }

    modifier onlyStrategist() {
        require(strategist[msg.sender] || msg.sender == treasury || msg.sender == owner(), "!strategist && !treasury && !owner");
        _;
    }

    modifier checkContract() {
        if (!contract_allowed && !whitelisted[msg.sender]) {
            uint256 size;
            address addr = msg.sender;
            assembly {
                size := extcodesize(addr)
            }
            require(size == 0, "contract not allowed");
            require(tx.origin == msg.sender, "contract not allowed");
        }
        _;
    }

    /* ========== CONSTRUCTOR ========== */

    function initialize(
        address _dollar,
        address _dark,
        address _share,
        address[] memory _collaterals,
        address _treasury
    ) external initializer {
        require(_collaterals.length == 3, "invalid collaterals length");
        OwnableUpgradeSafe.__Ownable_init();

        dollar = _dollar; // DUSD
        dark = _dark; // DARK
        share = _share; // NESS
        collaterals = _collaterals; // USDC, USDT, DAI
        treasury = _treasury;
        oracleCollaterals = new address[](3);
        unclaimed_pool_collaterals_ = new uint256[](3);
        unclaimed_pool_dark_ = 0;
        unclaimed_pool_share_ = 0;
        missing_decimals = new uint256[](3);
        for (uint256 i = 0; i < 3; i++) {
            missing_decimals[i] = uint256(18).sub(uint256(IBasisAsset(_collaterals[i]).decimals()));
            unclaimed_pool_collaterals_[i] = 0;
        }

        targetCollateralRatio_ = 9000; // 90%
        targetDarkOverDarkShareRatio_ = 5000; // 50/50

        lastUpdatedTargetCR = block.timestamp;
        lastUpdatedTargetDODSR = block.timestamp;

        updateStepTargetCR = 25; // 0.25%
        updateStepTargetDODSR = 100; // 1%

        updateCoolingTimeTargetCR = 3000; // update every hour
        updateCoolingTimeTargetDODSR = 13800; // update every 4 hours

        mintingLimitOnce_ = 50000 ether;
        mintingLimitHourly_ = 100000 ether;
        mintingLimitDaily_ = 1000000 ether;

        redemption_delay = 30;
        mint_paused = false;
        redeem_paused = false;
        contract_allowed = false;
    }

    /* ========== VIEWS ========== */

    function info()
        external
        view
        returns (
            uint256[] memory,
            uint256,
            uint256,
            uint256,
            bool,
            bool
        )
    {
        return (
            unclaimed_pool_collaterals_, // unclaimed amount of COLLATERALs
            unclaimed_pool_dark_, // unclaimed amount of DARK
            unclaimed_pool_share_, // unclaimed amount of SHARE
            PRICE_PRECISION, // collateral price
            mint_paused,
            redeem_paused
        );
    }

    function targetCollateralRatio() external override view returns (uint256) {
        return targetCollateralRatio_;
    }

    function targetDarkOverDarkShareRatio() external override view returns (uint256) {
        return targetDarkOverDarkShareRatio_;
    }

    function unclaimed_pool_collateral(uint256 _index) external override view returns (uint256) {
        return unclaimed_pool_collaterals_[_index];
    }

    function unclaimed_pool_dark() external override view returns (uint256) {
        return unclaimed_pool_dark_;
    }

    function unclaimed_pool_share() external override view returns (uint256) {
        return unclaimed_pool_share_;
    }

    function collateralReserve() public view returns (address) {
        return ITreasury(treasury).collateralReserve();
    }

    function getCollateralPrice(uint256 _index) public view override returns (uint256) {
        address _oracle = oracleCollaterals[_index];
        return (_oracle == address(0)) ? PRICE_PRECISION : IOracle(_oracle).consult();
    }

    function getDollarPrice() public view override returns (uint256) {
        address _oracle = oracleDollar;
        return (_oracle == address(0)) ? PRICE_PRECISION : IOracle(_oracle).consult(); // DOLLAR: default = 1$
    }

    function getDarkPrice() public view override returns (uint256) {
        address _oracle = oracleDark;
        return (_oracle == address(0)) ? PRICE_PRECISION / 2 : IOracle(_oracle).consult(); // DARK: default = 0.5$
    }

    function getSharePrice() public view override returns (uint256) {
        address _oracle = oracleShare;
        return (_oracle == address(0)) ? PRICE_PRECISION * 2 / 5 : IOracle(_oracle).consult(); // NESS: default = 0.4$
    }

    function getTrueSharePrice() public view returns (uint256) {
        address _oracle = oracleShare;
        return (_oracle == address(0)) ? PRICE_PRECISION / 5 : IOracle(_oracle).consultTrue(); // NESS: default = 0.2$
    }

    function getRedemptionOpenTime(address _account) public view override returns (uint256) {
        uint256 _last_redeemed = last_redeemed[_account];
        return (_last_redeemed == 0) ? 0 : _last_redeemed.add(redemption_delay);
    }

    function mintingLimitOnce() public view returns (uint256 _limit) {
        _limit = mintingLimitOnce_;
        if (_limit > 0) {
            _limit = Math.max(_limit, IERC20(dollar).totalSupply().mul(25).div(10000)); // Max(50k, 0.25% of total supply)
        }
    }

    function mintingLimitHourly() public override view returns (uint256 _limit) {
        _limit = mintingLimitHourly_;
        if (_limit > 0) {
            _limit = Math.max(_limit, IERC20(dollar).totalSupply().mul(50).div(10000)); // Max(100K, 0.5% of total supply)
        }
    }

    function mintingLimitDaily() public override view returns (uint256 _limit) {
        _limit = mintingLimitDaily_;
        if (_limit > 0) {
            _limit = Math.max(_limit, IERC20(dollar).totalSupply().mul(500).div(10000)); // Max(1M, 5% of total supply)
        }
    }

    function calcMintableDollarHourly() public override view returns (uint256 _limit) {
        uint256 _mintingLimitHourly = mintingLimitHourly();
        if (_mintingLimitHourly == 0) {
            _limit = 1000000 ether;
        } else {
            uint256 _hourIndex = block.timestamp.sub(T_ZERO_TIMESTAMP).div(1 hours);
            uint256 _totalMintedHourly = totalMintedHourly[_hourIndex];
            if (_totalMintedHourly < _mintingLimitHourly) {
                _limit = _mintingLimitHourly.sub(_totalMintedHourly);
            }
        }
    }

    function calcMintableDollarDaily() public override view returns (uint256 _limit) {
        uint256 _mintingLimitDaily = mintingLimitDaily();
        if (_mintingLimitDaily == 0) {
            _limit = 1000000 ether;
        } else {
            uint256 _dayIndex = block.timestamp.sub(T_ZERO_TIMESTAMP).div(1 days);
            uint256 _totalMintedDaily = totalMintedDaily[_dayIndex];
            if (_totalMintedDaily < _mintingLimitDaily) {
                _limit = _mintingLimitDaily.sub(_totalMintedDaily);
            }
        }
    }

    function calcMintableDollar() public override view returns (uint256 _dollarAmount) {
        uint256 _mintingLimitOnce = mintingLimitOnce();
        _dollarAmount = (_mintingLimitOnce == 0) ? 1000000 ether : _mintingLimitOnce;
        if (_dollarAmount > 0) _dollarAmount = Math.min(_dollarAmount, calcMintableDollarHourly());
        if (_dollarAmount > 0) _dollarAmount = Math.min(_dollarAmount, calcMintableDollarDaily());
    }

    function calcRedeemableDollarHourly() public override view returns (uint256 _limit) {
        uint256 _mintingLimitHourly = mintingLimitHourly();
        if (_mintingLimitHourly == 0) {
            _limit = 1000000 ether;
        } else {
            uint256 _hourIndex = block.timestamp.sub(T_ZERO_TIMESTAMP).div(1 hours);
            uint256 _totalRedeemedHourly = totalRedeemedHourly[_hourIndex];
            if (_totalRedeemedHourly < _mintingLimitHourly) {
                _limit = _mintingLimitHourly.sub(_totalRedeemedHourly);
            }
        }
    }

    function calcRedeemableDollarDaily() public override view returns (uint256 _limit) {
        uint256 _mintingLimitDaily = mintingLimitDaily();
        if (_mintingLimitDaily == 0) {
            _limit = 1000000 ether;
        } else {
            uint256 _dayIndex = block.timestamp.sub(T_ZERO_TIMESTAMP).div(1 days);
            uint256 _totalRedeemedDaily = totalRedeemedDaily[_dayIndex];
            if (_totalRedeemedDaily < _mintingLimitDaily) {
                _limit = _mintingLimitDaily.sub(_totalRedeemedDaily);
            }
        }
    }

    function calcRedeemableDollar() public override view returns (uint256 _dollarAmount) {
        uint256 _mintingLimitOnce = mintingLimitOnce();
        _dollarAmount = (_mintingLimitOnce == 0) ? 1000000 ether : _mintingLimitOnce;
        if (_dollarAmount > 0) _dollarAmount = Math.min(_dollarAmount, calcRedeemableDollarHourly());
        if (_dollarAmount > 0) _dollarAmount = Math.min(_dollarAmount, calcRedeemableDollarDaily());
    }

    function calcTotalCollateralValue(uint256[] memory _collateralAmounts) public view returns (uint256 _totalCollateralValue) {
        for (uint256 i = 0; i < 3; i++) {
            _totalCollateralValue = _totalCollateralValue.add(_collateralAmounts[i].mul(10 ** missing_decimals[i]).mul(getCollateralPrice(i)).div(PRICE_PRECISION));
        }
    }

    function calcTotalMainCollateralAmount(uint256[] memory _collateralAmounts) public view returns (uint256 _totalMainCollateralAmount) {
        uint256 _totalCollateralValue = calcTotalCollateralValue(_collateralAmounts);
        _totalMainCollateralAmount = _totalCollateralValue.mul(PRICE_PRECISION).div(getCollateralPrice(0)).div(10 ** missing_decimals[0]);
    }

    function calcMintInput(uint256 _dollarAmount) public view override returns (uint256 _mainCollateralAmount, uint256 _darkAmount, uint256 _shareAmount,
        uint256 _darkFee, uint256 _shareFee) {
        uint256 _collateral_price = getCollateralPrice(0);
        uint256 _dark_price = getDarkPrice();
        uint256 _share_price = getTrueSharePrice();
        uint256 _targetCollateralRatio = targetCollateralRatio_;

        uint256 _dollarFullValue = _dollarAmount.mul(_collateral_price).div(PRICE_PRECISION);
        uint256 _collateralFullValue = _dollarFullValue.mul(_targetCollateralRatio).div(10000);
        _mainCollateralAmount = _collateralFullValue.mul(PRICE_PRECISION).div(_collateral_price).div(10 ** missing_decimals[0]);

        uint256 _required_darkShareValue = _dollarFullValue.sub(_collateralFullValue);

        uint256 _required_darkValue = _required_darkShareValue.mul(targetDarkOverDarkShareRatio_).div(10000);
        uint256 _required_shareValue = _required_darkShareValue.sub(_required_darkValue);

        uint256 _mintingFee = ITreasury(treasury).minting_fee();
        uint256 _feePercentOnDarkShare = _mintingFee.mul(10000).div(uint256(10000).sub(_targetCollateralRatio));
        {
            uint256 _required_darkAmount = _required_darkValue.mul(PRICE_PRECISION).div(_dark_price);
            _darkFee = _required_darkAmount.mul(_feePercentOnDarkShare).div(10000);
            _darkAmount = _required_darkAmount.add(_darkFee);
        }
        {
            uint256 _required_shareAmount = _required_shareValue.mul(PRICE_PRECISION).div(_share_price);
            _shareFee = _required_shareAmount.mul(_feePercentOnDarkShare).div(10000);
            _shareAmount = _required_shareAmount.add(_shareFee);
        }
    }

    function calcMintOutputFromCollaterals(uint256[] memory _collateralAmounts) public view override returns (uint256 _dollarAmount, uint256 _darkAmount, uint256 _shareAmount,
        uint256 _darkFee, uint256 _shareFee) {
        uint256 _collateral_price = getCollateralPrice(0);
        uint256 _dark_price = getDarkPrice();
        uint256 _share_price = getTrueSharePrice();
        uint256 _targetCollateralRatio = targetCollateralRatio_;

        uint256 _collateralFullValue = 0;
        for (uint256 i = 0; i < 3; i++) {
            uint256 _collateralAmount = _collateralAmounts[i];
            _collateralFullValue = _collateralFullValue.add(_collateralAmount.mul(10 ** missing_decimals[i]).mul(getCollateralPrice(i)).div(PRICE_PRECISION));
        }

        uint256 _dollarFullValue = _collateralFullValue.mul(10000).div(_targetCollateralRatio);
        _dollarAmount = _dollarFullValue.mul(PRICE_PRECISION).div(_collateral_price);

        uint256 _required_darkShareValue = _dollarFullValue.sub(_collateralFullValue);

        uint256 _required_darkValue = _required_darkShareValue.mul(targetDarkOverDarkShareRatio_).div(10000);
        uint256 _required_shareValue = _required_darkShareValue.sub(_required_darkValue);
        uint256 _mintingFee = ITreasury(treasury).minting_fee();
        uint256 _feePercentOnDarkShare = _mintingFee.mul(10000).div(uint256(10000).sub(_targetCollateralRatio));
        {
            uint256 _required_darkAmount = _required_darkValue.mul(PRICE_PRECISION).div(_dark_price);
            _darkFee = _required_darkAmount.mul(_feePercentOnDarkShare).div(10000);
            _darkAmount = _required_darkAmount.add(_darkFee);
        }
        {
            uint256 _required_shareAmount = _required_shareValue.mul(PRICE_PRECISION).div(_share_price);
            _shareFee = _required_shareAmount.mul(_feePercentOnDarkShare).div(10000);
            _shareAmount = _required_shareAmount.add(_shareFee);
        }
    }

    function calcMintOutputFromDark(uint256 _darkAmount) public view override returns (uint256 _dollarAmount, uint256 _mainCollateralAmount, uint256 _shareAmount,
        uint256 _darkFee, uint256 _shareFee) {
        if (_darkAmount > 0) {
            uint256 _dark_price = getDarkPrice();
            uint256 _share_price = getTrueSharePrice();
            {
                uint256 _required_darkValue = _darkAmount.mul(_dark_price).div(PRICE_PRECISION);
                uint256 _required_darkShareValue = _required_darkValue.mul(10000).div(targetDarkOverDarkShareRatio_);
                uint256 _required_shareValue = _required_darkShareValue.sub(_required_darkValue);
                _shareAmount = _required_shareValue.mul(PRICE_PRECISION).div(_share_price).add(1);
            }
            uint256 _targetReverseCR = uint256(10000).sub(targetCollateralRatio_);
            uint256 _darkShareFullValueWithoutFee;
            {
                uint256 _feePercentOnDarkShare = ITreasury(treasury).minting_fee().mul(10000).div(_targetReverseCR);
                uint256 _darkAmountWithoutFee = _darkAmount.mul(10000).div(_feePercentOnDarkShare.add(10000));
                if (_darkAmountWithoutFee > 1) _darkAmountWithoutFee = _darkAmountWithoutFee - 1;
                _darkFee = _darkAmount.sub(_darkAmountWithoutFee);
                uint256 _darkFullValueWithoutFee = _darkAmountWithoutFee.mul(_dark_price).div(PRICE_PRECISION);
                _darkShareFullValueWithoutFee = _darkFullValueWithoutFee.mul(10000).div(targetDarkOverDarkShareRatio_);
                uint256 _shareFullValueWithoutFee = _darkShareFullValueWithoutFee.sub(_darkFullValueWithoutFee);
                _shareFee = _shareAmount.sub(_shareFullValueWithoutFee.mul(PRICE_PRECISION).div(_share_price));
            }
            {
                uint256 _dollarFullValue = _darkShareFullValueWithoutFee.mul(10000).div(_targetReverseCR);
                uint256 _collateral_price = getCollateralPrice(0);
                _dollarAmount = _dollarFullValue.mul(PRICE_PRECISION).div(_collateral_price);

                uint256 _collateralFullValue = _dollarFullValue.sub(_darkShareFullValueWithoutFee);
                _mainCollateralAmount = _collateralFullValue.div(10 ** missing_decimals[0]).mul(PRICE_PRECISION).div(_collateral_price);
            }
        }
    }

    function calcMintOutputFromShare(uint256 _shareAmount) public view override returns (uint256 _dollarAmount, uint256 _mainCollateralAmount, uint256 _darkAmount,
        uint256 _darkFee, uint256 _shareFee) {
        if (_shareAmount > 0) {
            uint256 _dark_price = getDarkPrice();
            uint256 _share_price = getTrueSharePrice();
            uint256 _targetShareOverDarkShareRatio = uint256(10000).sub(targetDarkOverDarkShareRatio_);
            {
                uint256 _required_shareValue = _shareAmount.mul(_share_price).div(PRICE_PRECISION);
                uint256 _required_darkShareValue = _required_shareValue.mul(10000).div(_targetShareOverDarkShareRatio);
                uint256 _required_darkValue = _required_darkShareValue.sub(_required_shareValue);
                _darkAmount = _required_darkValue.mul(PRICE_PRECISION).div(_dark_price).add(1);
            }
            uint256 _targetReverseCR = uint256(10000).sub(targetCollateralRatio_);
            uint256 _darkShareFullValueWithoutFee;
            {
                uint256 _feePercentOnDarkShare = ITreasury(treasury).minting_fee().mul(10000).div(_targetReverseCR);
                uint256 _shareAmountWithoutFee = _shareAmount.mul(10000);
                _shareAmountWithoutFee = _shareAmountWithoutFee.div(_feePercentOnDarkShare.add(10000));
                if (_shareAmountWithoutFee > 1) _shareAmountWithoutFee = _shareAmountWithoutFee - 1;
                _shareFee = _shareAmount.sub(_shareAmountWithoutFee);
                uint256 _shareFullValueWithoutFee = _shareAmountWithoutFee.mul(_share_price).div(PRICE_PRECISION);
                _darkShareFullValueWithoutFee = _shareFullValueWithoutFee.mul(10000).div(_targetShareOverDarkShareRatio);
                uint256 _darkFullValueWithoutFee = _darkShareFullValueWithoutFee.sub(_shareFullValueWithoutFee);
                _darkFee = _darkAmount.sub(_darkFullValueWithoutFee.mul(PRICE_PRECISION).div(_dark_price));
            }
            {
                uint256 _dollarFullValue = _darkShareFullValueWithoutFee.mul(10000).div(_targetReverseCR);
                uint256 _collateral_price = getCollateralPrice(0);
                _dollarAmount = _dollarFullValue.mul(PRICE_PRECISION).div(_collateral_price);

                uint256 _collateralFullValue = _dollarFullValue.sub(_darkShareFullValueWithoutFee);
                _mainCollateralAmount = _collateralFullValue.div(10 ** missing_decimals[0]).mul(PRICE_PRECISION).div(_collateral_price);
            }
        }
    }

    function calcRedeemOutput(uint256 _dollarAmount) public view override returns (uint256[] memory _collateralAmounts, uint256 _darkAmount, uint256 _shareAmount,
        uint256 _darkFee, uint256 _shareFee) {
        uint256 _outputRatio = _dollarAmount.mul(1e18).div(IERC20(dollar).totalSupply());
        uint256 _collateralFullValue = 0;
        {
            _collateralAmounts = new uint256[](3);
            for (uint256 i = 0; i < 3; i++) {
                uint256 _collateral_bal = ITreasury(treasury).globalCollateralBalance(i);
                uint256 _collateralAmount = _collateral_bal.mul(_outputRatio).div(1e18);
                _collateralAmounts[i] = _collateralAmount;
                _collateralFullValue = _collateralFullValue.add(_collateralAmount.mul(10 ** missing_decimals[i]).mul(getCollateralPrice(i)).div(PRICE_PRECISION));
            }
        }
        uint256 _currentReverseCR;
        {
            uint256 _dollarFullValue = _dollarAmount.mul(getCollateralPrice(0)).div(PRICE_PRECISION);
            _currentReverseCR = (_dollarFullValue <= _collateralFullValue) ? 0 : _dollarFullValue.sub(_collateralFullValue).mul(10000).div(_dollarFullValue);
        }

        uint256 _dark_bal = ITreasury(treasury).globalDarkBalance();
        uint256 _share_bal = ITreasury(treasury).globalShareBalance();
        uint256 _dark_out = _dark_bal.mul(_outputRatio).div(1e18);
        uint256 _share_out = _share_bal.mul(_outputRatio).div(1e18);

        uint256 _redemptionFee = ITreasury(treasury).redemption_fee();
        if (_currentReverseCR == 0) {
            _darkFee = _dark_out;
            _shareFee = _share_out;
        } else {
            uint256 _feePercentOnDarkShare = _redemptionFee.mul(10000).div(_currentReverseCR);

            _darkFee = _dark_out.mul(_feePercentOnDarkShare).div(10000);
            _shareFee = _share_out.mul(_feePercentOnDarkShare).div(10000);
            _darkAmount = _dark_out.sub(_darkFee);
            _shareAmount = _share_out.sub(_shareFee);
        }
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function _increaseMintedStats(uint256 _dollarAmount) internal {
        uint256 _hourIndex = block.timestamp.sub(T_ZERO_TIMESTAMP).div(1 hours);
        uint256 _dayIndex = block.timestamp.sub(T_ZERO_TIMESTAMP).div(1 days);
        totalMintedHourly[_hourIndex] = totalMintedHourly[_hourIndex].add(_dollarAmount);
        totalMintedDaily[_dayIndex] = totalMintedDaily[_dayIndex].add(_dollarAmount);
    }

    function _increaseRedeemedStats(uint256 _dollarAmount) internal {
        uint256 _hourIndex = block.timestamp.sub(T_ZERO_TIMESTAMP).div(1 hours);
        uint256 _dayIndex = block.timestamp.sub(T_ZERO_TIMESTAMP).div(1 days);
        totalRedeemedHourly[_hourIndex] = totalRedeemedHourly[_hourIndex].add(_dollarAmount);
        totalRedeemedDaily[_dayIndex] = totalRedeemedDaily[_dayIndex].add(_dollarAmount);
    }

    function mint(
        uint256[] memory _collateralAmounts,
        uint256 _darkAmount,
        uint256 _shareAmount,
        uint256 _dollarOutMin
    ) external checkContract nonReentrant returns (uint256 _dollarOut, uint256[] memory _required_collateralAmounts, uint256 _required_darkAmount, uint256 _required_shareAmount,
        uint256 _darkFee, uint256 _shareFee) {
        require(mint_paused == false, "Minting is paused");
        uint256 _mintableDollarLimit = calcMintableDollar().add(100);
        require(_dollarOutMin < _mintableDollarLimit, "over minting cap");
        trimExtraToTreasury();
        uint256 _totalMainCollateralAmount = calcTotalMainCollateralAmount(_collateralAmounts);
        uint256 _mainCollateralAmount;

        (_dollarOut, _required_darkAmount, _required_shareAmount, _darkFee, _shareFee) = calcMintOutputFromCollaterals(_collateralAmounts);
        if (_required_shareAmount >= _shareAmount.add(100)) {
            (_dollarOut, _mainCollateralAmount, _required_darkAmount, _darkFee, _shareFee) = calcMintOutputFromShare(_shareAmount);
            require(_mainCollateralAmount <= _totalMainCollateralAmount, "invalid input quantities");
        }
        require(_dollarOut >= _dollarOutMin, "slippage");
        require(_dollarOut < _mintableDollarLimit, "over minting cap");

        (_mainCollateralAmount, _required_darkAmount, _required_shareAmount, _darkFee, _shareFee) = calcMintInput(_dollarOut);
        require(_mainCollateralAmount <= _totalMainCollateralAmount, "Not enough _collateralAmount"); // plus some dust for overflow
        require(_mainCollateralAmount.mul(13000).div(10000) >= _totalMainCollateralAmount, "_totalMainCollateralAmount is too big for _dollarOut");
        require(_required_darkAmount <= _darkAmount.add(100), "Not enough _darkAmount"); // plus some dust for overflow
        require(_required_shareAmount <= _shareAmount.add(100), "Not enough _shareAmount"); // plus some dust for overflow
        require(_dollarOut <= _totalMainCollateralAmount.mul(10 ** missing_decimals[0]).mul(13000).div(10000), "Insanely big _dollarOut"); // double check - we dont want to mint too much dollar

        _required_collateralAmounts = new uint256[](3);
        uint256 _slippageAmount = _totalMainCollateralAmount.sub(_mainCollateralAmount);
        if (_collateralAmounts[0] > _slippageAmount) {
            _required_collateralAmounts[0] = _collateralAmounts[0].sub(_slippageAmount);
        }
        _required_collateralAmounts[1] = _collateralAmounts[1];
        _required_collateralAmounts[2] = _collateralAmounts[2];

        for (uint256 i = 0; i < 3; i++) {
            _transferToReserve(collaterals[i], msg.sender, _required_collateralAmounts[i], 0);
        }
        _transferToReserve(dark, msg.sender, _required_darkAmount, _darkFee);
        _transferToReserve(share, msg.sender, _required_shareAmount, _shareFee);
        IDollar(dollar).poolMint(msg.sender, _dollarOut);
        _increaseMintedStats(_dollarOut);
        emit Mint(msg.sender, _dollarOut, _required_collateralAmounts, _required_darkAmount, _required_shareAmount, _darkFee, _shareFee);
    }

    function redeem(
        uint256 _dollarAmount,
        uint256[] memory _collateral_out_mins,
        uint256 _dark_out_min,
        uint256 _share_out_min
    ) external checkContract nonReentrant returns (uint256[] memory _collateral_outs, uint256 _dark_out, uint256 _share_out,
        uint256 _darkFee, uint256 _shareFee) {
        require(redeem_paused == false, "Redeeming is paused");
        uint256 _redeemableDollarLimit = calcRedeemableDollar().add(100);
        require(_dollarAmount < _redeemableDollarLimit, "over redeeming cap");
        trimExtraToTreasury();

        (_collateral_outs, _dark_out, _share_out, _darkFee, _shareFee) = calcRedeemOutput(_dollarAmount);
        require(_dark_out >= _dark_out_min, "short of dark");
        require(_share_out >= _share_out_min, "short of share");
        uint256 _totalCollateralValue = calcTotalCollateralValue(_collateral_outs);
        require(_totalCollateralValue <= _dollarAmount.mul(10100).div(10000), "Insanely big _collateral_out"); // double check - we dont want to redeem too much collateral

        for (uint256 i = 0; i < 3; i++) {
            uint256 _collateral_out = _collateral_outs[i];
            require(_collateral_out >= _collateral_out_mins[i], "short of collateral");
            redeem_collateral_balances[msg.sender][i] = redeem_collateral_balances[msg.sender][i].add(_collateral_out);
            unclaimed_pool_collaterals_[i] = unclaimed_pool_collaterals_[i].add(_collateral_out);
        }

        if (_dark_out > 0) {
            redeem_dark_balances[msg.sender] = redeem_dark_balances[msg.sender].add(_dark_out);
            unclaimed_pool_dark_ = unclaimed_pool_dark_.add(_dark_out);
        }

        if (_share_out > 0) {
            redeem_share_balances[msg.sender] = redeem_share_balances[msg.sender].add(_share_out);
            unclaimed_pool_share_ = unclaimed_pool_share_.add(_share_out);
        }

        IDollar(dollar).poolBurnFrom(msg.sender, _dollarAmount);

        ITreasury _treasury = ITreasury(treasury);
        _treasury.requestBurnShare(_shareFee);
        _treasury.requestTransferDarkFee(_darkFee);

        last_redeemed[msg.sender] = block.timestamp;
        _increaseRedeemedStats(_dollarAmount);
        emit Redeem(msg.sender, _dollarAmount, _collateral_outs, _dark_out, _share_out, _darkFee, _shareFee);
    }

    function collectRedemption() external {
        require(getRedemptionOpenTime(msg.sender) <= block.timestamp, "too early");
        trimExtraToTreasury();

        uint256[] memory _collateralAmounts = new uint256[](3);
        for (uint256 i = 0; i < 3; i++) {
            uint256 _collateralAmount = redeem_collateral_balances[msg.sender][i];
            _collateralAmounts[i] = _collateralAmount;
            if (_collateralAmount > 0) {
                redeem_collateral_balances[msg.sender][i] = 0;
                unclaimed_pool_collaterals_[i] = unclaimed_pool_collaterals_[i].sub(_collateralAmount);
                _requestTransferFromReserve(collaterals[i], msg.sender, _collateralAmount);
            }
        }

        uint256 _darkAmount = redeem_dark_balances[msg.sender];
        if (_darkAmount > 0) {
            redeem_dark_balances[msg.sender] = 0;
            unclaimed_pool_dark_ = unclaimed_pool_dark_.sub(_darkAmount);
            _requestTransferFromReserve(dark, msg.sender, _darkAmount);
        }

        uint256 _shareAmount = redeem_share_balances[msg.sender];
        if (_shareAmount > 0) {
            redeem_share_balances[msg.sender] = 0;
            unclaimed_pool_share_ = unclaimed_pool_share_.sub(_shareAmount);
            _requestTransferFromReserve(share, msg.sender, _shareAmount);
        }

        emit CollectRedemption(msg.sender, _collateralAmounts, _darkAmount, _shareAmount);
    }

    function trimExtraToTreasury() public returns (uint256 _collateralAmount, uint256 _darkAmount, uint256 _shareAmount) {
        uint256 _collateral_price = getCollateralPrice(0);
        uint256 _total_dollar_FullValue = IERC20(dollar).totalSupply().mul(_collateral_price).div(PRICE_PRECISION);
        ITreasury _treasury = ITreasury(treasury);
        uint256 _totalCollateralValue = _treasury.globalCollateralTotalValue();
        uint256 _dark_bal = _treasury.globalDarkBalance();
        uint256 _share_bal = _treasury.globalShareBalance();
        address _profitSharingFund = _treasury.profitSharingFund();
        if (_totalCollateralValue > _total_dollar_FullValue) {
            _collateralAmount = _totalCollateralValue.sub(_total_dollar_FullValue).div(10 ** missing_decimals[0]).mul(PRICE_PRECISION).div(_collateral_price);
            if (_collateralAmount > 0) {
                uint256 _mainCollateralBal = _treasury.globalCollateralValue(0).div(10 ** missing_decimals[0]);
                if (_collateralAmount > _mainCollateralBal) _collateralAmount = _mainCollateralBal;
                _requestTransferFromReserve(collaterals[0], _profitSharingFund, _collateralAmount);
            }
            if (_dark_bal > 0) {
                _darkAmount = _dark_bal;
                _requestTransferFromReserve(dark, _profitSharingFund, _darkAmount);
            }
            if (_share_bal > 0) {
                _shareAmount = _share_bal;
                _requestTransferFromReserve(share, _profitSharingFund, _shareAmount);
            }
        } else {
            uint256 _dark_price = getDarkPrice();
            uint256 _share_price = getTrueSharePrice();
            uint256 _total_reserve_value = _totalCollateralValue.add(_dark_bal.mul(_dark_price).div(PRICE_PRECISION)).add(_share_bal.mul(_share_price).div(PRICE_PRECISION));
            if (_total_reserve_value > _total_dollar_FullValue) {
                uint256 _extra_value_from_reserve = _total_reserve_value.sub(_total_dollar_FullValue);
                _shareAmount = _extra_value_from_reserve.mul(PRICE_PRECISION).div(_share_price);
                if (_shareAmount <= _share_bal) {
                    _requestTransferFromReserve(share, _profitSharingFund, _shareAmount);
                } else {
                    _shareAmount = _share_bal;
                    _requestTransferFromReserve(share, _profitSharingFund, _share_bal);
                    {
                        uint256 _transferred_value_of_share = _share_bal.mul(_share_price).div(PRICE_PRECISION);
                        _darkAmount = _extra_value_from_reserve.sub(_transferred_value_of_share).mul(PRICE_PRECISION).div(_dark_price);
                    }
                    if (_darkAmount > _dark_bal) _darkAmount = _dark_bal;
                    _requestTransferFromReserve(dark, _profitSharingFund, _darkAmount);
                }
            }
        }
    }

    /* ========== INTERNAL FUNCTIONS ========== */

    function _transferToReserve(address _token, address _sender, uint256 _amount, uint256 _fee) internal {
        if (_amount > 0) {
            address _reserve = collateralReserve();
            require(_reserve != address(0), "zero");
            IERC20(_token).safeTransferFrom(_sender, _reserve, _amount);
            if (_token == share) {
                ITreasury _treasury = ITreasury(treasury);
                _treasury.requestBurnShare(_fee);
                _treasury.reserveReceiveShare(_amount.sub(_fee));
            } else if (_token == dark) {
                ITreasury _treasury = ITreasury(treasury);
                _treasury.requestTransferDarkFee(_fee);
                _treasury.reserveReceiveDark(_amount.sub(_fee));
            }
        }
    }

    function _requestTransferFromReserve(address _token, address _receiver, uint256 _amount) internal {
        if (_amount > 0 && _receiver != address(0)) {
            ITreasury(treasury).requestTransfer(_token, _receiver, _amount);
        }
    }

    /* ========== RESTRICTED FUNCTIONS ========== */

    function setTreasury(address _treasury) external onlyOwner {
        require(_treasury != address(0), "zero");
        treasury = _treasury;
        emit TreasuryUpdated(_treasury);
    }

    function setStrategistStatus(address _account, bool _status) external onlyOwner {
        strategist[_account] = _status;
        emit StrategistStatusUpdated(_account, _status);
    }

    function toggleMinting() external onlyOwner {
        mint_paused = !mint_paused;
        emit MintPausedUpdated(mint_paused);
    }

    function toggleRedeeming() external onlyOwner {
        redeem_paused = !redeem_paused;
        emit RedeemPausedUpdated(redeem_paused);
    }

    function toggleContractAllowed() external onlyOwner {
        contract_allowed = !contract_allowed;
        emit ContractAllowedUpdated(contract_allowed);
    }

    function toggleWhitelisted(address _account) external onlyOwner {
        whitelisted[_account] = !whitelisted[_account];
        emit WhitelistedUpdated(_account, whitelisted[_account]);
    }

    function setMintingLimits(uint256 _mintingLimitOnce, uint256 _mintingLimitHourly, uint256 _mintingLimitDaily) external onlyOwner {
        mintingLimitOnce_ = _mintingLimitOnce;
        mintingLimitHourly_ = _mintingLimitHourly;
        mintingLimitDaily_ = _mintingLimitDaily;
    }

    function setOracleDollar(address _oracleDollar) external onlyOwner {
        require(_oracleDollar != address(0), "zero");
        oracleDollar = _oracleDollar;
    }

    function setOracleDark(address _oracleDark) external onlyOwner {
        require(_oracleDark != address(0), "zero");
        oracleDark = _oracleDark;
    }

    function setOracleShare(address _oracleShare) external onlyOwner {
        require(_oracleShare != address(0), "zero");
        oracleShare = _oracleShare;
    }

    function setOracleCollaterals(address[] memory _oracleCollaterals) external onlyOwner {
        require(_oracleCollaterals.length == 3, "length!=3");
        delete oracleCollaterals;
        for (uint256 i = 0; i < 3; i++) {
            oracleCollaterals.push(_oracleCollaterals[i]);
        }
    }

    function setOracleCollateral(uint256 _index, address _oracleCollateral) external onlyOwner {
        require(_oracleCollateral != address(0), "zero");
        oracleCollaterals[_index] = _oracleCollateral;
    }

    function setRedemptionDelay(uint256 _redemption_delay) external onlyOwner {
        redemption_delay = _redemption_delay;
    }

    function setTargetCollateralRatioConfig(uint256 _updateStepTargetCR, uint256 _updateCoolingTimeTargetCR) external onlyOwner {
        updateStepTargetCR = _updateStepTargetCR;
        updateCoolingTimeTargetCR = _updateCoolingTimeTargetCR;
    }

    function setTargetDarkOverShareRatioConfig(uint256 _updateStepTargetDODSR, uint256 _updateCoolingTimeTargetDODSR) external onlyOwner {
        updateStepTargetDODSR = _updateStepTargetDODSR;
        updateCoolingTimeTargetDODSR = _updateCoolingTimeTargetDODSR;
    }

    function setTargetCollateralRatio(uint256 _targetCollateralRatio) external onlyTreasuryOrOwner {
        require(_targetCollateralRatio <= 9500 && _targetCollateralRatio >= 7000, "OoR");
        lastUpdatedTargetCR = block.timestamp;
        targetCollateralRatio_ = _targetCollateralRatio;
        emit TargetCollateralRatioUpdated(_targetCollateralRatio);
    }

    function setTargetDarkOverDarkShareRatio(uint256 _targetDarkOverDarkShareRatio) external onlyTreasuryOrOwner {
        require(_targetDarkOverDarkShareRatio <= 8000 && _targetDarkOverDarkShareRatio >= 2000, "OoR");
        lastUpdatedTargetDODSR = block.timestamp;
        targetDarkOverDarkShareRatio_ = _targetDarkOverDarkShareRatio;
        emit TargetDarkOverShareRatioUpdated(_targetDarkOverDarkShareRatio);
    }

    function updateTargetCollateralRatio() external override onlyStrategist {
        if (lastUpdatedTargetCR.add(updateCoolingTimeTargetCR) <= block.timestamp) { // to avoid update too frequent
            lastUpdatedTargetCR = block.timestamp;
            uint256 _dollarPrice = getDollarPrice();
            if (_dollarPrice > PRICE_PRECISION) {
                // When DUSD is at or above $1, meaning the market’s demand for DUSD is high,
                // the system should be in de-collateralize mode by decreasing the collateral ratio, minimum to 70%
                targetCollateralRatio_ = Math.max(7000, targetCollateralRatio_.sub(updateStepTargetCR));
            } else {
                // When the price of DUSD is below $1, the function increases the collateral ratio, maximum to 95%
                targetCollateralRatio_ = Math.max(9500, targetCollateralRatio_.add(updateStepTargetCR));
            }
            emit TargetCollateralRatioUpdated(targetCollateralRatio_);
        }
    }

    function updateTargetDarkOverShareRatio() external override onlyStrategist {
        if (lastUpdatedTargetDODSR.add(updateCoolingTimeTargetDODSR) <= block.timestamp) { // to avoid update too frequent
            lastUpdatedTargetDODSR = block.timestamp;
            uint256 _darkCap = getDarkPrice().mul(IERC20(dark).totalSupply());
            uint256 _shareCap = getSharePrice().mul(IERC20(share).totalSupply());
            uint256 _targetRatio = _darkCap.mul(10000).div(_darkCap.add(_shareCap));
            uint256 _targetDarkOverDarkShareRatio = targetDarkOverDarkShareRatio_;
            // At the beginning the ratio between DARK/NESS will be 50%/50% and it will increase/decrease depending on Market cap of DARK and NESS.
            // The ratio will be updated every 4 hours by a step of 1%. Minimum and maximum ratio is 20%/80% and 80%/20% accordingly.
            if (_targetDarkOverDarkShareRatio < 8000 && _targetDarkOverDarkShareRatio.add(100) <= _targetRatio) {
                targetDarkOverDarkShareRatio_ = _targetDarkOverDarkShareRatio.add(100);
                emit TargetDarkOverShareRatioUpdated(targetDarkOverDarkShareRatio_);
            } else if (_targetDarkOverDarkShareRatio > 2000 && _targetDarkOverDarkShareRatio >= _targetRatio.add(100)) {
                targetDarkOverDarkShareRatio_ = _targetDarkOverDarkShareRatio.sub(100);
                emit TargetDarkOverShareRatioUpdated(targetDarkOverDarkShareRatio_);
            }
        }
    }

    /* ========== EMERGENCY ========== */

    function rescueStuckErc20(address _token) external onlyOwner {
        IERC20(_token).transfer(owner(), IERC20(_token).balanceOf(address(this)));
    }
}