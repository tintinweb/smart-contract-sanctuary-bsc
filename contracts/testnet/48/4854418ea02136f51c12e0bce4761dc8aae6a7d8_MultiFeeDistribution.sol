/**
 *Submitted for verification at BscScan.com on 2022-02-20
*/

/**
 *Submitted for verification at BscScan.com on 2021-03-23
 */
// SPDX-License-Identifier: NONE
// https://bscscan.com/address/0x4076CC26EFeE47825917D0feC3A79d0bB9a6bB5c
// 演练地址:https://testnet.bscscan.com/address/0x26916126aa5b5247637826e6932d0cf5147d4bec#code
pragma solidity 0.7.6;
pragma abicoder v2;

// Part: Address
// Part: OpenZeppelin/[email protected]/Address
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
    assembly {
      size := extcodesize(account)
    }
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
    (bool success, ) = recipient.call{value: amount}("");
    require(
      success,
      "Address: unable to send value, recipient may have reverted"
    );
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
  function functionCall(address target, bytes memory data)
    internal
    returns (bytes memory)
  {
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
    return
      functionCallWithValue(
        target,
        data,
        value,
        "Address: low-level call with value failed"
      );
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
    require(
      address(this).balance >= value,
      "Address: insufficient balance for call"
    );
    require(isContract(target), "Address: call to non-contract");

    // solhint-disable-next-line avoid-low-level-calls
    (bool success, bytes memory returndata) = target.call{value: value}(data);
    return _verifyCallResult(success, returndata, errorMessage);
  }

  /**
   * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
   * but performing a static call.
   *
   * _Available since v3.3._
   */
  function functionStaticCall(address target, bytes memory data)
    internal
    view
    returns (bytes memory)
  {
    return
      functionStaticCall(target, data, "Address: low-level static call failed");
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
  function functionDelegateCall(address target, bytes memory data)
    internal
    returns (bytes memory)
  {
    return
      functionDelegateCall(
        target,
        data,
        "Address: low-level delegate call failed"
      );
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

    // solhint-disable-next-line avoid-low-level-calls
    (bool success, bytes memory returndata) = target.delegatecall(data);
    return _verifyCallResult(success, returndata, errorMessage);
  }

  function _verifyCallResult(
    bool success,
    bytes memory returndata,
    string memory errorMessage
  ) private pure returns (bytes memory) {
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

// Part: Context

// Part: OpenZeppelin/[email protected]/Context

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

// Part: IERC20

// Part: OpenZeppelin/[email protected]/IERC20

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
  function allowance(address owner, address spender)
    external
    view
    returns (uint256);

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
  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);

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

// Part: Math

// Part: OpenZeppelin/[email protected]/Math

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
    return (a / 2) + (b / 2) + (((a % 2) + (b % 2)) / 2);
  }
}

// Part: ReentrancyGuard

// Part: OpenZeppelin/[email protected]/ReentrancyGuard

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

  constructor() internal {
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

// Part: SafeMath

// Part: OpenZeppelin/[email protected]/SafeMath

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
  function sub(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
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
  function div(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
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
  function mod(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    return a % b;
  }
}

// Part: IMintableToken

// Part: IMintableToken

interface IMintableToken is IERC20 {
  function mint(address _receiver, uint256 _amount) external returns (bool);
}

// Part: Ownable

// Part: OpenZeppelin/[email protected]/Ownable

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

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  constructor() internal {
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

// Part: SafeERC20

// Part: OpenZeppelin/[email protected]/SafeERC20

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

  function safeTransfer(
    IERC20 token,
    address to,
    uint256 value
  ) internal {
    _callOptionalReturn(
      token,
      abi.encodeWithSelector(token.transfer.selector, to, value)
    );
  }

  function safeTransferFrom(
    IERC20 token,
    address from,
    address to,
    uint256 value
  ) internal {
    _callOptionalReturn(
      token,
      abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
    );
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
    // solhint-disable-next-line max-line-length
    require(
      (value == 0) || (token.allowance(address(this), spender) == 0),
      "SafeERC20: approve from non-zero to non-zero allowance"
    );
    _callOptionalReturn(
      token,
      abi.encodeWithSelector(token.approve.selector, spender, value)
    );
  }

  function safeIncreaseAllowance(
    IERC20 token,
    address spender,
    uint256 value
  ) internal {
    uint256 newAllowance = token.allowance(address(this), spender).add(value);
    _callOptionalReturn(
      token,
      abi.encodeWithSelector(token.approve.selector, spender, newAllowance)
    );
  }

  function safeDecreaseAllowance(
    IERC20 token,
    address spender,
    uint256 value
  ) internal {
    uint256 newAllowance =
      token.allowance(address(this), spender).sub(
        value,
        "SafeERC20: decreased allowance below zero"
      );
    _callOptionalReturn(
      token,
      abi.encodeWithSelector(token.approve.selector, spender, newAllowance)
    );
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

    bytes memory returndata =
      address(token).functionCall(data, "SafeERC20: low-level call failed");
    if (returndata.length > 0) {
      // Return data is optional
      // solhint-disable-next-line max-line-length
      require(
        abi.decode(returndata, (bool)),
        "SafeERC20: ERC20 operation did not succeed"
      );
    }
  }
}

// File: <stdin>.sol

// File: EpsStaker.sol

// EPS Staking contract for http://ellipsis.finance/
// EPS staked within this contact entitles stakers to a portion of the admin fees generated by Ellipsis' AMM contracts
// Based on SNX MultiRewards by iamdefinitelyahuman - https://github.com/iamdefinitelyahuman/multi-rewards
contract MultiFeeDistribution is ReentrancyGuard, Ownable {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;
  using SafeERC20 for IMintableToken;

  /* ========== STATE VARIABLES ========== */

  struct Reward {
    uint256 periodFinish;
    uint256 rewardRate;
    uint256 lastUpdateTime;
    uint256 rewardPerTokenStored;
  }
  struct Balances {
    uint256 total;
    uint256 unlocked;
    uint256 locked;
    uint256 earned;
  }
  struct LockedBalance {
    uint256 amount;
    uint256 unlockTime;
  }
  struct RewardData {
    address token;
    uint256 amount;
  }
  //  Ellipsis (EPS) (@$0.1837)
  IMintableToken public stakingToken;
  address[] public rewardTokens;
  mapping(address => Reward) public rewardData;

  // Duration that rewards are streamed over
  uint256 public constant rewardsDuration = 86400 * 7;

  // Duration of lock/earned penalty period  "7862400"  91天
  uint256 public constant lockDuration = rewardsDuration * 13;

  // Addresses approved to call mint
  mapping(address => bool) public minters;
  // reward token -> distributor -> is approved to add rewards
  mapping(address => mapping(address => bool)) public rewardDistributors;

  // user -> reward token -> amount
  mapping(address => mapping(address => uint256)) public userRewardPerTokenPaid;
  mapping(address => mapping(address => uint256)) public rewards;
  // 179153064.577892914006870872，BUSD
  uint256 public totalSupply;
  // 112463237.304194827880897278，EPS
  uint256 public lockedSupply;

  // Private mappings for balance data
  mapping(address => Balances) public balances;
  mapping(address => LockedBalance[]) public userLocks;
  mapping(address => LockedBalance[]) public userEarnings;

  /* ========== CONSTRUCTOR ========== */

  constructor(address _stakingToken, address[] memory _minters) Ownable() {
    stakingToken = IMintableToken(_stakingToken);
    for (uint256 i; i < _minters.length; i++) {
      minters[_minters[i]] = true;
    }
    // First reward MUST be the staking token or things will break
    // related to the 50% penalty and distribution to locked balances
    rewardTokens.push(_stakingToken);
    rewardData[_stakingToken].lastUpdateTime = block.timestamp;
  }

  /* ========== ADMIN CONFIGURATION ========== */

  // Add a new reward token to be distributed to stakers
  function addReward(address _rewardsToken, address _distributor)
    public
    onlyOwner
  {
    require(rewardData[_rewardsToken].lastUpdateTime == 0);
    //0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56   BUSD
    //0xA7f552078dcC247C2684336020c03648500C6d9F   EPS
    rewardTokens.push(_rewardsToken);
    rewardData[_rewardsToken].lastUpdateTime = block.timestamp;
    rewardDistributors[_rewardsToken][_distributor] = true;
  }

  // Modify approval for an address to call notifyRewardAmount
  function approveRewardDistributor(
    address _rewardsToken,
    address _distributor,
    bool _approved
  ) external onlyOwner {
    require(rewardData[_rewardsToken].lastUpdateTime > 0,"wrong time");
    rewardDistributors[_rewardsToken][_distributor] = _approved;
  }

  /* ========== VIEWS ========== */
  /*
    计算每个币的奖励算法：如果总供应量为0,那么奖励算法为这个币单币储存奖励
    否则：就是单币存储奖励+（上一次可用奖励-上次奖励更新时间 ）*奖励分配比例乘以1e18除以总供应量

    根据差值计算奖励值
    */
  function _rewardPerToken(address _rewardsToken, uint256 _supply)
    internal
    view
    returns (uint256)
  {
    if (_supply == 0) {
      return rewardData[_rewardsToken].rewardPerTokenStored;
    }
    return
      rewardData[_rewardsToken].rewardPerTokenStored.add(
        lastTimeRewardApplicable(_rewardsToken) //取当前时间戳和periodFinish的较小值
          .sub(rewardData[_rewardsToken].lastUpdateTime)
          .mul(rewardData[_rewardsToken].rewardRate) //乘以奖励比例
          .mul(1e18) //乘以1e18
          .div(_supply) //
      );
  }

  /*
赚钱计算方法：用户余额 乘以 （  单币奖励数-单币用户已支付数量) 除以 1e18  加上  用户的奖励数量
赚钱的计算方法：_balance * [_rewardPerToken(_rewardsToken, supply) - userRewardPerTokenPaid[_user][_rewardsToken]  ]  /  1e18  +  rewards[_user][_rewardsToken]
*/
  function _earned(
    address _user,
    address _rewardsToken,
    uint256 _balance,
    uint256 supply
  ) internal view returns (uint256) {
    return
      _balance
        .mul(
        _rewardPerToken(_rewardsToken, supply).sub(
          userRewardPerTokenPaid[_user][_rewardsToken]
        )
      )
        .div(1e18)
        .add(rewards[_user][_rewardsToken]);
  }

  /*
    最近一次，也可以理解为最后一次，可分配奖励时间，获取当前时间戳和结束奖励时间的较小值
    */
  function lastTimeRewardApplicable(address _rewardsToken)
    public
    view
    returns (uint256)
  {
    return Math.min(block.timestamp, rewardData[_rewardsToken].periodFinish);
  }

  /*
    单币奖励数
    获取奖励供应量，
    如果是EPS则是锁定供应量，如果是BUSD，则是总供应量,BUSD的 decimals 是18，
    总供应量179546325.310392643311673304
    如果是EPS则是112254744.980059836500874958，EPS的 decimals 是18    
    3336781678677382472
    */
  function rewardPerToken(address _rewardsToken)
    external
    view
    returns (uint256)
  {
    uint256 supply =
      _rewardsToken == address(stakingToken) ? lockedSupply : totalSupply;
    return _rewardPerToken(_rewardsToken, supply);
  }

  /*
    获取区间内的奖励多少    
    */
  function getRewardForDuration(address _rewardsToken)
    external
    view
    returns (uint256)
  {
    return rewardData[_rewardsToken].rewardRate.mul(rewardsDuration);
  }

  /*
可申报奖励是多少？
获取所有币种的奖励信息，包括BUSD和EPS
如果是EPS，则根据 locked 计算，如果是BUSD，则根据 total 计算
supply，如果是EPS，则根据lockedSupply计算，如果是BUSD，则根据totalSupply计算
将内存中的 rewardTokens[i] 赋值给 rewards[i].token
计算 rewards[i].amount等于转去的数量，参数是:账户,这个币的地址，这个账户的余额，分别对应锁定的和总total，供应量，分别对应锁定的供应量和总供应量
*/
  // Address and claimable amount of all reward tokens for the given account
  function claimableRewards(address account)
    external
    view
    returns (RewardData[] memory rewards)
  {
    rewards = new RewardData[](rewardTokens.length);
    for (uint256 i = 0; i < rewards.length; i++) {
      // If i == 0 this is the stakingReward, distribution is based on locked balances
      uint256 balance =
        i == 0 ? balances[account].locked : balances[account].total;
      uint256 supply = i == 0 ? lockedSupply : totalSupply;
      rewards[i].token = rewardTokens[i];
      rewards[i].amount = _earned(account, rewards[i].token, balance, supply);
    }
    return rewards;
  }

  /*
        获取用户的total余额
    */
  // Total balance of an account, including unlocked, locked and earned tokens
  function totalBalance(address user) external view returns (uint256 amount) {
    return balances[user].total;
  }

  /*
    获取用户的非锁定余额
    获取用户赚取的锁定余额
    循环用户赚取的锁定余额
    如果解锁时间大于当前时间，（未解锁），则跳出当前循环
    否则将用户已经到了解锁时间的赚取余额加入解锁余额中
    */
  // Total withdrawable balance for an account to which no penalty is applied
  function unlockedBalance(address user)
    external
    view
    returns (uint256 amount)
  {
    amount = balances[user].unlocked;
    LockedBalance[] storage earnings = userEarnings[msg.sender];
    for (uint256 i = 0; i < earnings.length; i++) {
      if (earnings[i].unlockTime > block.timestamp) {
        break;
      }
      amount = amount.add(earnings[i].amount);
    }
    return amount;
  }

  // Information on the "earned" balances of a user
  // Earned balances may be withdrawn immediately for a 50% penalty
  /*
  用户赚取余额，
  获取用户赚取的余额，
  遍历用户赚取余额，如果所赚的钱的解锁时间大于当前时间，也就是赚钱还没解锁
  如果是遍历的下标是0，那么就会重新建立一个赚钱数组数据
  把赚钱数据的i数据赋值给赚钱数据earningsData
  下表自增，
  赚钱总量=total加上赚钱i的数量
  计算结果获得total的总数
  */
  function earnedBalances(address user)
    external
    view
    returns (uint256 total, LockedBalance[] memory earningsData)
  {
    LockedBalance[] storage earnings = userEarnings[user];
    uint256 idx;
    for (uint256 i = 0; i < earnings.length; i++) {
      if (earnings[i].unlockTime > block.timestamp) {
        if (idx == 0) {
          earningsData = new LockedBalance[](earnings.length - i);
        }
        earningsData[idx] = earnings[i];
        idx++;
        total = total.add(earnings[i].amount);
      }
    }
    return (total, earningsData);
  }

  /*
锁定余额，
获取用户锁定余额的数组信息
获取 idx;
for循环遍历数组，
如果锁定的解锁时间大于当前时间戳
如果是第一次循环，那么创建一个锁定余额数组
把锁定余额数组的i数据赋值给 lockData[idx]
idx++,idx自增
locked等于locked加上锁定的amount
*/
  // Information on a user's locked balances
  function lockedBalances(address user)
    external
    view
    returns (
      uint256 total,
      uint256 unlockable,
      uint256 locked,
      LockedBalance[] memory lockData
    )
  {
    LockedBalance[] storage locks = userLocks[user];
    uint256 idx;
    for (uint256 i = 0; i < locks.length; i++) {
      if (locks[i].unlockTime > block.timestamp) {
        if (idx == 0) {
          lockData = new LockedBalance[](locks.length - i);
        }
        lockData[idx] = locks[i];
        idx++;
        locked = locked.add(locks[i].amount);
      } else {
        unlockable = unlockable.add(locks[i].amount);
      }
    }
    return (balances[user].locked, unlockable, locked, lockData);
  }

  // Final balance received and penalty balance paid by user upon calling exit
  /*
  可取款余额 withdrawableBalance
  获取用户余额
  如果余额中的赚钱部分大于0
  定义了一个变量，无罚款金额
获取用户赚钱数据的长度
循环用户赚钱的数据
获取用户赚钱的amount参数
如果用户赚钱的数量是0，就跳出当前循环
如果用户的解绑时间大于当前时间，就停止循环
否则，给定义的无罚款金额赋值，无罚款金额等于0+用户所赚取的金额
penaltyAmount罚款金额 等于 （用户赚取 - 无罚款金额）然后除以2
获取 amount 等于余额的非锁定部分 加上余额的 赚钱部分，减去罚款金额

 */
  function withdrawableBalance(address user)
    public
    view
    returns (uint256 amount, uint256 penaltyAmount)
  {
    Balances storage bal = balances[user];
    if (bal.earned > 0) {
      uint256 amountWithoutPenalty;
      uint256 length = userEarnings[user].length;
      for (uint256 i = 0; i < length; i++) {
        uint256 earnedAmount = userEarnings[user][i].amount;
        if (earnedAmount == 0) continue;
        if (userEarnings[user][i].unlockTime > block.timestamp) {
          break;
        }
        amountWithoutPenalty = amountWithoutPenalty.add(earnedAmount);
      }
      penaltyAmount = bal.earned.sub(amountWithoutPenalty).div(2);
    }
    amount = bal.unlocked.add(bal.earned).sub(penaltyAmount);
    return (amount, penaltyAmount);
  }

  /* ========== MUTATIVE FUNCTIONS ========== */

  // Stake tokens to receive rewards
  // Locked tokens cannot be withdrawn for lockDuration and are eligible to receive stakingReward rewards
  /**
下注：数量，是否锁住
要求 require(amount > 0, "Cannot stake 0");存储金额是0
总供应量等于总供应量加上amount
获取用户的余额信息
用户的total增加amount
如果是锁定的
锁定的提供量 等于 锁定的供应量 增加 amount
用户余额之中锁定的余额等于余额锁定部分增加amount
解锁时间 等于 当前时间戳 加上 锁定期限
idx等于用户锁定的长度
如果idx等于0或者用户锁定[调用者][idx-1]的解锁时间小于当前设定的加上期限的解锁时间
那么用户锁定增加一个新值，当前投注的金额和当前投注锁定的时间;
那么当前 就以较长的那个锁定时间进行锁定，金额直接想加
如果不锁定 那么直接用户不锁定余额上面增加amount
从用户地址转入amount数量的eps
  **/
  function stake(uint256 amount, bool lock)
    external
    nonReentrant
    updateReward(msg.sender)
  {
    require(amount > 0, "Cannot stake 0");
    totalSupply = totalSupply.add(amount);
    Balances storage bal = balances[msg.sender];
    bal.total = bal.total.add(amount);
    if (lock) {
      lockedSupply = lockedSupply.add(amount);
      bal.locked = bal.locked.add(amount);
      uint256 unlockTime =
        block.timestamp.div(rewardsDuration).mul(rewardsDuration).add(
          lockDuration
        );
      uint256 idx = userLocks[msg.sender].length;
      if (idx == 0 || userLocks[msg.sender][idx - 1].unlockTime < unlockTime) {
        userLocks[msg.sender].push(
          LockedBalance({amount: amount, unlockTime: unlockTime})
        );
      } else {
        userLocks[msg.sender][idx - 1].amount = userLocks[msg.sender][idx - 1]
          .amount
          .add(amount);
      }
    } else {
      bal.unlocked = bal.unlocked.add(amount);
    }
    stakingToken.safeTransferFrom(msg.sender, address(this), amount);
    emit Staked(msg.sender, amount);
  }

  // Mint new tokens
  // Minted tokens receive rewards normally but incur a 50% penalty when
  // withdrawn before lockDuration has passed.
  /*  
铸造，铸币; 发明或创造，给用户user铸造amount数量的币，提前要走一个修改器
要求用户是可以增发的人
总供应量等于用户供应量加上amount
读取用户余额数据
用户余额的 total  +  amount
用户余额的赚钱earned等于用户的余额earned + amount
解锁时间 等于 当前时间 加上 锁定时间
获取用户赚钱，
把赚钱数组的长度赋值给idx
如果（idx==0或者最后一个的赚钱的解锁时间小于当前设置的解锁时间（当前时间加上锁定时间爱）
就给earnings新push一个LockedBalance({amount: amount, unlockTime: unlockTime})
否则，赚钱数组就是在最后一个直接加上一个amount
最后执行增发操作
触发增发事件
  */
  function mint(address user, uint256 amount) external updateReward(user) {
    require(minters[msg.sender],"wrong minter");
    totalSupply = totalSupply.add(amount);
    Balances storage bal = balances[user];
    bal.total = bal.total.add(amount);
    bal.earned = bal.earned.add(amount);
    uint256 unlockTime =
      block.timestamp.div(rewardsDuration).mul(rewardsDuration).add(
        lockDuration
      );
    LockedBalance[] storage earnings = userEarnings[user];
    uint256 idx = earnings.length;

    if (idx == 0 || earnings[idx - 1].unlockTime < unlockTime) {
      earnings.push(LockedBalance({amount: amount, unlockTime: unlockTime}));
    } else {
      earnings[idx - 1].amount = earnings[idx - 1].amount.add(amount);
    }
    stakingToken.mint(address(this), amount);
    emit Staked(user, amount);
  }

  // Withdraw staked tokens
  // First withdraws unlocked tokens, then earned tokens. Withdrawing earned tokens
  // incurs a 50% penalty which is distributed based on locked balances.
  /*
取钱数量为amount
要求amount大于0，
获取用户余额信息；赋值给bal
定义罚款金额
如果取款金额amount小于或者等于余额的非锁定部分
那么用户的非锁定部分等于他本身减去取款金额amount
否则 取款金额减去用户余额的解锁部分，剩余部分赋值给remaining，
要求余额的赚钱部分大于remaining
余额的解锁部分设置成0,余额的赚钱部分设置为他本身减去remaining，
循环遍历
获取调用者赚钱i的amount，
如果赚钱earnedAmount等于0，跳出当前循环；
否则，如果罚款金额等于0 并且用户赚钱数组i的解锁时间大于当前时间戳（未解锁）
那么remaining赋值给罚款金额，
要求用户赚钱部分大于remaining
用户赚钱部分等于他本身减去remaining；
如果用户的赚钱部分等于0,就清除用户赚钱数组的值
跳出循环
否则 remaining等于remaining乘以2
如果remaining 小于或者等于 赚钱数量
用户赚钱数量 等于 赚钱数量 减去remaining，停止循环
否则删除用户赚钱数量
remaining等于remaining本身减去赚钱数量
调整金额等于取款金额加上罚款金额
用户余额的total等于余额的total减去调整金额
总供应量等于他本身减去调整金额
转账给msg.sender,数量为amount
如果罚款金额>0
确认币和罚款金额和数量

  */
  function withdraw(uint256 amount)
    public
    nonReentrant
    updateReward(msg.sender)
  {
    require(amount > 0, "Cannot withdraw 0");
    Balances storage bal = balances[msg.sender];
    uint256 penaltyAmount;

    if (amount <= bal.unlocked) {
      bal.unlocked = bal.unlocked.sub(amount);
    } else {
      uint256 remaining = amount.sub(bal.unlocked);
      require(bal.earned >= remaining, "Insufficient unlocked balance");
      bal.unlocked = 0;
      bal.earned = bal.earned.sub(remaining);
      for (uint256 i = 0; ; i++) {
        uint256 earnedAmount = userEarnings[msg.sender][i].amount;
        if (earnedAmount == 0) continue;
        if (
          penaltyAmount == 0 &&
          userEarnings[msg.sender][i].unlockTime > block.timestamp
        ) {
          penaltyAmount = remaining;
          require(
            bal.earned >= remaining,
            "Insufficient balance after penalty"
          );
          bal.earned = bal.earned.sub(remaining);
          if (bal.earned == 0) {
            delete userEarnings[msg.sender];
            break;
          }
          remaining = remaining.mul(2);
        }
        if (remaining <= earnedAmount) {
          userEarnings[msg.sender][i].amount = earnedAmount.sub(remaining);
          break;
        } else {
          delete userEarnings[msg.sender][i];
          remaining = remaining.sub(earnedAmount);
        }
      }
    }

    uint256 adjustedAmount = amount.add(penaltyAmount);
    bal.total = bal.total.sub(adjustedAmount);
    totalSupply = totalSupply.sub(adjustedAmount);
    stakingToken.safeTransfer(msg.sender, amount);
    if (penaltyAmount > 0) {
      _notifyReward(address(stakingToken), penaltyAmount);
    }
    emit Withdrawn(msg.sender, amount);
  }

  /*
获取奖励
遍历奖励数组
获取用户奖励币的数量，如果奖励币的数量大于0,那么奖励币数量设置为0
转账奖励币
*/
  // Claim all pending staking rewards
  function getReward() public nonReentrant updateReward(msg.sender) {
    for (uint256 i; i < rewardTokens.length; i++) {
      address _rewardsToken = rewardTokens[i];
      uint256 reward = rewards[msg.sender][_rewardsToken];
      if (reward > 0) {
        rewards[msg.sender][_rewardsToken] = 0;
        IERC20(_rewardsToken).safeTransfer(msg.sender, reward);
        emit RewardPaid(msg.sender, _rewardsToken, reward);
      }
    }
  }

  /*
退出
获取调用者可取余额
删除调用者赚钱数组
获取调用者余额信息
余额的total减去余额的非锁定部分减去用户赚钱的部分
设置用户余额的非锁定部分等于0
设置用于余额的赚钱部分等于0
总供应量等于总供应量减去（数量和罚款金额之和）
投注币转账给调用者，转账数量是amount
如果罚款金额大于0，确认用户这个存储币的奖励，参数是储存币和可罚款金额
调用获取奖励函数
*/
  // Withdraw full unlocked balance and claim pending rewards
  function exit() external updateReward(msg.sender) {
    (uint256 amount, uint256 penaltyAmount) = withdrawableBalance(msg.sender);
    delete userEarnings[msg.sender];
    Balances storage bal = balances[msg.sender];
    bal.total = bal.total.sub(bal.unlocked).sub(bal.earned);
    bal.unlocked = 0;
    bal.earned = 0;

    totalSupply = totalSupply.sub(amount.add(penaltyAmount));
    stakingToken.safeTransfer(msg.sender, amount);
    if (penaltyAmount > 0) {
      _notifyReward(address(stakingToken), penaltyAmount);
    }
    getReward();
  }

  /*
取出过期的锁
获取用户锁定的余额，
获取用户余额信息
定义数量amount
锁定余额的长度
如果最后一次锁定的解锁时间小于当前时间戳，已经解锁
定义的amount变量等于用户锁定的数量
清除用户锁定余额
否则遍历锁定余额数组
如果锁定余额i的解锁时间大于当前时间戳，也就是未解锁，则停止循环
否则amount等于他本身加上锁定余额
删除锁定数组对应的i
用户余额的锁定值等于它本身减去amount
用户余额的总共值total，等于他本身减去amount
总供应量等于总供应量减去amount
锁定供应量等于锁定供应量减去amount
投注币的安全转账给调用者，数量为amount
*/
  // Withdraw all currently locked tokens where the unlock time has passed
  function withdrawExpiredLocks() external {
    LockedBalance[] storage locks = userLocks[msg.sender];
    Balances storage bal = balances[msg.sender];
    uint256 amount;
    uint256 length = locks.length;
    if (locks[length - 1].unlockTime <= block.timestamp) {
      amount = bal.locked;
      delete userLocks[msg.sender];
    } else {
      for (uint256 i = 0; i < length; i++) {
        if (locks[i].unlockTime > block.timestamp) break;
        amount = amount.add(locks[i].amount);
        delete locks[i];
      }
    }
    bal.locked = bal.locked.sub(amount);
    bal.total = bal.total.sub(amount);
    totalSupply = totalSupply.sub(amount);
    lockedSupply = lockedSupply.sub(amount);
    stakingToken.safeTransfer(msg.sender, amount);
  }

  /* ========== RESTRICTED FUNCTIONS ========== */
  /*
验证奖励
如果当前时间戳大于奖励币的奖励结束时间
那么 奖励币的奖比例等于奖励币除以奖励周期
否则获取奖励币的结束时间减去当前时间戳，得到剩余时间给remaining
用remaining乘以奖励比例得到leftover
计算奖励比例等于奖励加上leftover除以奖励周期
也就是当前的加上多余多出来的部分
设置奖励的最后一次更新时间等于当前时间戳
设置奖励的结束时间为当前时间戳加上奖励周期

*/
  function _notifyReward(address _rewardsToken, uint256 reward) internal {
    if (block.timestamp >= rewardData[_rewardsToken].periodFinish) {
      rewardData[_rewardsToken].rewardRate = reward.div(rewardsDuration);
    } else {
      uint256 remaining =
        rewardData[_rewardsToken].periodFinish.sub(block.timestamp);
      uint256 leftover = remaining.mul(rewardData[_rewardsToken].rewardRate);
      rewardData[_rewardsToken].rewardRate = reward.add(leftover).div(
        rewardsDuration
      );
    }

    rewardData[_rewardsToken].lastUpdateTime = block.timestamp;
    rewardData[_rewardsToken].periodFinish = block.timestamp.add(
      rewardsDuration
    );
  }

  /*
确认奖励金额
要求调用者是这个币的分配者
要求奖励大于0
从调用者钱包里转reward数量的奖励到当前合约地址
确认奖励
*/
  function notifyRewardAmount(address _rewardsToken, uint256 reward)
    external
    updateReward(address(0))
  {
    require(rewardDistributors[_rewardsToken][msg.sender]);
    require(reward > 0, "No reward");
    // handle the transfer of reward tokens via `transferFrom` to reduce the number
    // of transactions required and ensure correctness of the reward amount
    IERC20(_rewardsToken).safeTransferFrom(msg.sender, address(this), reward);
    _notifyReward(_rewardsToken, reward);
    emit RewardAdded(reward);
  }

  // Added to support recovering LP Rewards from other systems such as BAL to be distributed to holders
  /*
  拯救erc20代币，只能拥有者owner调用
  要求这个币不能是存储的币
  要求这个币最后一次更新时间等于0
  这个币安全转到owner地址，数量是amount
  */
  function recoverERC20(address tokenAddress, uint256 tokenAmount)
    external
    onlyOwner
  {
    require(
      tokenAddress != address(stakingToken),
      "Cannot withdraw staking token"
    );
    require(
      rewardData[tokenAddress].lastUpdateTime == 0,
      "Cannot withdraw reward token"
    );
    IERC20(tokenAddress).safeTransfer(owner(), tokenAmount);
    emit Recovered(tokenAddress, tokenAmount);
  }

  /* ========== MODIFIERS ========== */
  /*
更新奖励的修改器
获取存储币等于token
获取奖励单币，参数是投注币和锁定的供应量，赋值给单币奖励储存
获取最近奖励时间分配给最近更新时间
如果账号不等于0地址
账户的奖励等于赚取的币，参数是账户，币，这个币的锁定量，供应量
用户奖励单币支付量等于奖励币数量的奖励单币储存
余额等于账户的总量
总供应量等于供应量
遍历rewardTOkens
获取下标i对应的rewardstokens
获取单币奖励，参数是改token，总供应量，赋值给单币奖励量储存
获取最新的奖励应用时间，复制给奖励最新更新时间
如果账户不是0地址，那么获取赚钱数量，参数是account，币，余额，总供应量，赋值给该账户该币奖励数量
获取奖励数量的单币奖励储存给单币奖励支付，
走入方法
*/
  modifier updateReward(address account) {
    address token = address(stakingToken);
    uint256 balance;
    uint256 supply = lockedSupply;
    rewardData[token].rewardPerTokenStored = _rewardPerToken(token, supply);
    rewardData[token].lastUpdateTime = lastTimeRewardApplicable(token);
    if (account != address(0)) {
      // Special case, use the locked balances and supply for stakingReward rewards
      rewards[account][token] = _earned(
        account,
        token,
        balances[account].locked,
        supply
      );
      userRewardPerTokenPaid[account][token] = rewardData[token]
        .rewardPerTokenStored;
      balance = balances[account].total;
    }
    supply = totalSupply;
    for (uint256 i = 1; i < rewardTokens.length; i++) {
      token = rewardTokens[i];
      rewardData[token].rewardPerTokenStored = _rewardPerToken(token, supply);
      rewardData[token].lastUpdateTime = lastTimeRewardApplicable(token);
      if (account != address(0)) {
        rewards[account][token] = _earned(account, token, balance, supply);
        userRewardPerTokenPaid[account][token] = rewardData[token]
          .rewardPerTokenStored;
      }
    }
    _;
  }

  /* ========== EVENTS ========== */

  event RewardAdded(uint256 reward);
  event Staked(address indexed user, uint256 amount);
  event Withdrawn(address indexed user, uint256 amount);
  event RewardPaid(
    address indexed user,
    address indexed rewardsToken,
    uint256 reward
  );
  event RewardsDurationUpdated(address token, uint256 newDuration);
  event Recovered(address token, uint256 amount);
}