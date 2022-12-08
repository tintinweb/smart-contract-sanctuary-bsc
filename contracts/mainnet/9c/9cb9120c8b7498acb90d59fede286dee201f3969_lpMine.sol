/**
 *Submitted for verification at BscScan.com on 2022-12-08
*/

/**
 *Submitted for verification at BscScan.com on 2021-04-16
*/

// File: @openzeppelin/contracts/utils/Context.sol

// SPDX-License-Identifier: MIT

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

// File: @openzeppelin/contracts/access/Ownable.sol



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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol



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

// File: @openzeppelin/contracts/math/SafeMath.sol



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

// File: @openzeppelin/contracts/utils/Address.sol



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

// File: @openzeppelin/contracts/token/ERC20/SafeERC20.sol



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

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

   interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}
    
interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}


library UniswapV2Library {
    using SafeMath for uint;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'UniswapV2Library: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'UniswapV2Library: ZERO_ADDRESS');
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint160(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f' // init code hash
            )))));
    }

    // fetches and sorts the reserves for a pair
    function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        (uint reserve0, uint reserve1,) = IUniswapV2Pair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, 'UniswapV2Library: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        amountB = amountA.mul(reserveB) / reserveA;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(997);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {
        require(amountOut > 0, 'UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn.mul(amountOut).mul(1000);
        uint denominator = reserveOut.sub(amountOut).mul(997);
        amountIn = (numerator / denominator).add(1);
    }

    // performs chained getAmountOut calculations on any number of pairs
    function getAmountsOut(address factory, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    // performs chained getAmountIn calculations on any number of pairs
    function getAmountsIn(address factory, uint amountOut, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
}


pragma solidity >=0.6.0 <0.8.0;



contract lpMine is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 LPAmount; // How many LP or TOKEN tokens the user has provided.
        uint256 totalWithdrawUSDT;
        uint256 totalWithdrawIGS;
        uint256 usdtAmount;
        uint256 igsAmount;
        
        uint256 assumedIGSDividends;
        uint256 assumedUSDTDividends;

        uint256 igsDividendsDebt;
        uint256 usdtDividendsDebt;
    }

    struct PoolInfo {
        address lpToken; // Address of LP or TOKEN token contract.
        uint256 totalLp;
        address dividendPoolAddress;
        uint256 totalAssumedIGSDividends;
        uint256 totalAssumedUSDTDividends;
        uint256 totalDeptIGSDividends;
        uint256 totalDeptIGSDividendsByRemoveLp;
        uint256 totalDeptUSDTDividends;
        uint256 totalDeptUSDTDividendsByRemoveLp;
    }
    address public igsTokenAddress;
    address public usdtTokenAddress;
    address public defaultReferrerAddress=0xebdeA78F37588752AFED1681C8E068F23CFEc010;

    uint256 public tokenPerBlock;

    uint public lastUserId=1;

    ranking[] public rankingList;

    mapping(address => Player) public playerInfo;

    struct ranking{
           address addr;
           uint256 usdtAmount;
    }


    // Info of each pool.
    PoolInfo[] public poolInfos;
    mapping(address => mapping(uint256 => uint256)) public lpTokenRegistry;

    // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;


    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    
    event WithdrawIGSDividends(address indexed sender, address indexed recipient, uint256 amount);
    event WithdrawUSDTDividends(address indexed sender, address indexed recipient, uint256 amount);
    
    
    struct Player {
        uint256 id;
        address[] directRecommendAddress;
        address referrer;
        uint256 totalDepositOfDirectRecommend;
    }
    
    mapping(address => reward) public referralRewards;

    struct reward{
        uint usdtReward;
        uint igsReward;
    }

    IUniswapV2Router02 public uniswapV2Router;

    constructor() public {
        igsTokenAddress=0xD4AA889d3690b52aB4a1a5090142f133834358f2;
        usdtTokenAddress=0x55d398326f99059fF775485246999027B3197955;
        uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    }

    // ============ Modifiers ============

   modifier lpTokenExist(address _lpToken,uint256 _poolIndex) {
        require(lpTokenRegistry[_lpToken][_poolIndex] > 0, "Airdrop: LP token not exist");
        _;
    }

    modifier lpTokenNotExist(address _lpToken,uint256 _poolIndex) {
        require(
            lpTokenRegistry[_lpToken][_poolIndex] == 0,
            "Airdrop: LP token already exist"
        );
        _;
    }

    // ============ Helper ============

    function poolLength() external view returns (uint256) {
        return poolInfos.length;
    }

    function getPid(address _lpToken,uint256 _poolIndex)
        public
        view
        lpTokenExist(_lpToken,_poolIndex)
        returns (uint256)
    {
        return lpTokenRegistry[_lpToken][_poolIndex] - 1;
    }

    function getUserLpBalance(address _lpToken, address _user,uint256 _poolIndex)
        public
        view
        returns (uint256)
    {
        uint256 pid = getPid(_lpToken,_poolIndex);
        return userInfo[pid][_user].LPAmount;
    }

    // ============ Ownable ============

    
    function addLpToken(
        address _lpToken,
        address _dividendPoolAddress,
        uint256 _poolIndex
    ) public lpTokenNotExist(_lpToken,_poolIndex) onlyOwner {
        require(_lpToken != address(0), "Airdrop: zero address not allowed");
        
        poolInfos.push(
            PoolInfo({
                lpToken: _lpToken,
                totalLp:0,
                dividendPoolAddress: _dividendPoolAddress,
                totalAssumedIGSDividends:0,
                totalAssumedUSDTDividends:0,
                totalDeptIGSDividends:0,
                totalDeptIGSDividendsByRemoveLp:0,
                totalDeptUSDTDividends:0,
                totalDeptUSDTDividendsByRemoveLp:0
            })
        );
        lpTokenRegistry[_lpToken][_poolIndex] = poolInfos.length;
    }



    function setIGSTokenAddress(address _addr) public onlyOwner(){
           igsTokenAddress=_addr;
    }
    function setUSDTTokenAddress(address _addr) public onlyOwner(){
           usdtTokenAddress=_addr;
    }

    function updateFee(address _lpToken, uint256 _amount,uint256 _poolIndex) private{
        uint256 pid = getPid(_lpToken,_poolIndex);
        PoolInfo storage pool = poolInfos[pid];
        UserInfo storage user = userInfo[pid][msg.sender];
        uint256 IGSFeeBalance = IERC20(igsTokenAddress).balanceOf(pool.dividendPoolAddress).add(pool.totalAssumedIGSDividends).add(pool.totalDeptIGSDividends).sub(pool.totalDeptIGSDividendsByRemoveLp);
        uint256 USDTFeeBalance = IERC20(usdtTokenAddress).balanceOf(pool.dividendPoolAddress).add(pool.totalAssumedUSDTDividends).add(pool.totalDeptUSDTDividends).sub(pool.totalDeptUSDTDividendsByRemoveLp);
        uint256 oldTotalLp=pool.totalLp;
        uint256 newTotalLp=oldTotalLp.add(_amount);
        
        uint256 newAssumedIGSDividends;
        uint256 newAssumedUSDTDividends;
        if (oldTotalLp!=0){
            newAssumedIGSDividends=IGSFeeBalance.mul(newTotalLp).div(oldTotalLp).sub(IGSFeeBalance);
            newAssumedUSDTDividends=USDTFeeBalance.mul(newTotalLp).div(oldTotalLp).sub(USDTFeeBalance);
        }else{
            newAssumedIGSDividends=0;
            newAssumedIGSDividends=0;
        }

        user.assumedIGSDividends=user.assumedIGSDividends.add(newAssumedIGSDividends);
        pool.totalAssumedIGSDividends=pool.totalAssumedIGSDividends.add(newAssumedIGSDividends);
        
        user.assumedUSDTDividends=user.assumedUSDTDividends.add(newAssumedUSDTDividends);
        pool.totalAssumedUSDTDividends=pool.totalAssumedUSDTDividends.add(newAssumedUSDTDividends);  
    }
    

    function getIGSDividends(address _user,address _lpToken,uint256 _poolIndex) public view returns(uint256){
        uint256 pid = getPid(_lpToken,_poolIndex);
        PoolInfo storage pool = poolInfos[pid];
        UserInfo storage user = userInfo[pid][_user];
        uint256 igsFeeBalance = IERC20(igsTokenAddress).balanceOf(pool.dividendPoolAddress).add(pool.totalAssumedIGSDividends).add(pool.totalDeptIGSDividends).sub(pool.totalDeptIGSDividendsByRemoveLp);
        uint256 totalLp=pool.totalLp;
        uint256 lpBalance=getUserLpBalance(_lpToken,_user,_poolIndex);
        
        if (totalLp==0){
            return 0;
        }
        return lpBalance.mul(igsFeeBalance).div(totalLp).sub(user.assumedIGSDividends.add(user.igsDividendsDebt));
    }

    function getUSDTDividends(address _user,address _lpToken,uint256 _poolIndex) public  view returns(uint256){
        uint256 pid = getPid(_lpToken,_poolIndex);
        PoolInfo storage pool = poolInfos[pid];
        UserInfo storage user = userInfo[pid][_user];
        uint256 usdtFeeBalance = IERC20(usdtTokenAddress).balanceOf(pool.dividendPoolAddress).add(pool.totalAssumedUSDTDividends).add(pool.totalDeptUSDTDividends).sub(pool.totalDeptUSDTDividendsByRemoveLp);
        uint256 totalLp=pool.totalLp;
        uint256 lpBalance=getUserLpBalance(_lpToken,_user,_poolIndex);
        if (totalLp==0){
            return 0;
        }
        return lpBalance.mul(usdtFeeBalance).div(totalLp).sub(user.assumedUSDTDividends.add(user.usdtDividendsDebt));
    }

    function withdrawIGSDividends(address _lpToken,uint256 _poolIndex)public returns(uint256){
        require(msg.sender == tx.origin,"Address: The transferred address cannot be a contract");
        uint256 pid = getPid(_lpToken,_poolIndex);
        PoolInfo storage pool = poolInfos[pid];
        UserInfo storage user = userInfo[pid][msg.sender];
        uint256 igsDividendsBalance=getIGSDividends(msg.sender,_lpToken,_poolIndex);

        require(igsDividendsBalance!=0);

        address referalAddress=getReferralRelationship(msg.sender);
        if(getReferralRelationship(msg.sender)!=address(0)&&userInfo[pid][referalAddress].usdtAmount>1990*10**18&&pid==0){
            IERC20(igsTokenAddress).transferFrom(pool.dividendPoolAddress,address(msg.sender),igsDividendsBalance.mul(90).div(100));
            uint256 referrerFee = igsDividendsBalance.mul(10).div(100);
            referralRewards[referalAddress].igsReward=  referralRewards[referalAddress].igsReward.add(referrerFee);
            IERC20(igsTokenAddress).transferFrom(pool.dividendPoolAddress,referalAddress,referrerFee);
        }else{
            IERC20(igsTokenAddress).transferFrom(pool.dividendPoolAddress,address(msg.sender),igsDividendsBalance);
        }
        user.igsDividendsDebt=user.igsDividendsDebt.add(igsDividendsBalance);
        pool.totalDeptIGSDividends=pool.totalDeptIGSDividends.add(igsDividendsBalance);
        user.totalWithdrawIGS=user.totalWithdrawIGS.add(igsDividendsBalance);
        emit WithdrawIGSDividends(pool.dividendPoolAddress, msg.sender, igsDividendsBalance);
        return (user.igsDividendsDebt);
    }

    function withdrawUSDTDividends(address _lpToken,uint256 _poolIndex)public returns(uint256){
        require(msg.sender == tx.origin,"Address: The transferred address cannot be a contract");
        uint256 pid = getPid(_lpToken,_poolIndex);
        PoolInfo storage pool = poolInfos[pid];
        UserInfo storage user = userInfo[pid][msg.sender];
        uint256 usdtDividendsBalance=getUSDTDividends(msg.sender,_lpToken,_poolIndex);
        require(usdtDividendsBalance!=0);
        
        address referalAddress=getReferralRelationship(msg.sender);
        if(getReferralRelationship(msg.sender)!=address(0)&&userInfo[pid][referalAddress].usdtAmount>1990*10**18&&pid==0){
            IERC20(usdtTokenAddress).transferFrom(pool.dividendPoolAddress,address(msg.sender),usdtDividendsBalance.mul(90).div(100));
            uint256 referrerFee = usdtDividendsBalance.mul(10).div(100);
            referralRewards[referalAddress].usdtReward = referralRewards[referalAddress].usdtReward.add(referrerFee);

            IERC20(usdtTokenAddress).transferFrom(pool.dividendPoolAddress,referalAddress,referrerFee);
            
        }else{
            IERC20(usdtTokenAddress).transferFrom(pool.dividendPoolAddress,address(msg.sender),usdtDividendsBalance);
        }
        user.usdtDividendsDebt=user.usdtDividendsDebt.add(usdtDividendsBalance);
        pool.totalDeptUSDTDividends=pool.totalDeptUSDTDividends.add(usdtDividendsBalance);
        user.totalWithdrawUSDT=user.totalWithdrawUSDT.add(usdtDividendsBalance);
        emit WithdrawUSDTDividends(pool.dividendPoolAddress, msg.sender, usdtDividendsBalance);
        
        return (user.usdtDividendsDebt);
    }

    // ============ Deposit & Withdraw & Claim ============

    function deposit(address _lpToken, uint256 _amount) public {
        require(msg.sender == tx.origin,"Address: The transferred address cannot be a contract");
        require(isUserExists(msg.sender),"you are not registered");
        uint256 pid = getPid(_lpToken,1);
        PoolInfo storage pool = poolInfos[pid];
        UserInfo storage user = userInfo[pid][msg.sender];
        updateFee(_lpToken,_amount,1);
        require(_amount>0,"_amount error");
        uint256 usdtbyLp=consult(_lpToken,_amount);
            IERC20(pool.lpToken).safeTransferFrom(
                address(msg.sender),
                address(this),
                _amount
            );
        pool.totalLp=pool.totalLp.add(_amount);
        user.LPAmount = user.LPAmount.add(_amount);
        user.usdtAmount=user.usdtAmount.add(usdtbyLp.mul(2));
        if(user.usdtAmount>=19900*10**18){
            uint256 pid2 = getPid(_lpToken,2);
            PoolInfo storage pool2 = poolInfos[pid2];
            UserInfo storage user2 = userInfo[pid2][msg.sender];
            if(user2.LPAmount==0){
                updateFee(_lpToken,user.LPAmount,2);
                pool2.totalLp=pool2.totalLp.add(user.LPAmount);
            }else{
                updateFee(_lpToken,_amount,2);
                pool2.totalLp=pool2.totalLp.add(_amount);
            }
            user2.LPAmount=user.LPAmount;
            user2.usdtAmount=user.usdtAmount;
        }

        address referrer =getReferralRelationship(msg.sender);
        playerInfo[referrer].totalDepositOfDirectRecommend=playerInfo[referrer].totalDepositOfDirectRecommend.add(_amount);
        
        emit Deposit(msg.sender, pid, _amount);
    }

    function combinedLP(address _lpToken,uint256 _poolIndex) private returns(uint256 newLPBalance){
        uint256 pid = getPid(_lpToken,_poolIndex);
        PoolInfo storage pool = poolInfos[pid];
        UserInfo storage user = userInfo[pid][msg.sender];
        uint256 usdtDividendsBalance=getUSDTDividends(msg.sender,_lpToken,_poolIndex);
        uint256 igsDividendsBalance=getIGSDividends(msg.sender,_lpToken,_poolIndex);

        IERC20(usdtTokenAddress).transferFrom(pool.dividendPoolAddress,address(this),usdtDividendsBalance);
        IERC20(igsTokenAddress).transferFrom(pool.dividendPoolAddress,address(this),igsDividendsBalance);
        user.usdtDividendsDebt=user.usdtDividendsDebt.add(usdtDividendsBalance);
        user.igsDividendsDebt=user.igsDividendsDebt.add(igsDividendsBalance);
        pool.totalDeptUSDTDividends=pool.totalDeptUSDTDividends.add(usdtDividendsBalance);
        pool.totalDeptIGSDividends=pool.totalDeptIGSDividends.add(igsDividendsBalance);
        user.totalWithdrawIGS=user.totalWithdrawIGS.add(igsDividendsBalance);
        user.totalWithdrawUSDT=user.totalWithdrawUSDT.add(usdtDividendsBalance);


        if(IERC20(igsTokenAddress).balanceOf(address(this))>0){
            address[] memory path = new address[](2);
            path[0] = igsTokenAddress;
            path[1] = usdtTokenAddress;
            swapTokensForExactTokens(IERC20(igsTokenAddress).balanceOf(address(this)),path);
        }

        uint256 initialLPBalance = IERC20(pool.lpToken).balanceOf(address(this));

        swapAndLiquify(IERC20(usdtTokenAddress).balanceOf(address(this)));
        return newLPBalance = IERC20(pool.lpToken).balanceOf(address(this)).sub(initialLPBalance);
    }

    function reDeposit(address _lpToken,uint256 _poolIndex) public  {
        require(msg.sender == tx.origin,"Address: The transferred address cannot be a contract");
        require(isUserExists(msg.sender),"you are not registered");
        uint256 LPBalance=combinedLP(_lpToken,_poolIndex);

        uint256 pid = getPid(_lpToken,1);
        PoolInfo storage pool = poolInfos[pid];
        UserInfo storage user = userInfo[pid][msg.sender];
        updateFee(_lpToken,LPBalance,1);   
        uint256 usdtbyLp=consult(_lpToken,LPBalance);
        pool.totalLp=pool.totalLp.add(LPBalance);
        user.LPAmount = user.LPAmount.add(LPBalance);
        user.usdtAmount=user.usdtAmount.add(usdtbyLp.mul(2));
        if(user.usdtAmount>=19900*10**18){
            uint256 pid2 = getPid(_lpToken,2);
            PoolInfo storage pool2 = poolInfos[pid2];
            UserInfo storage user2 = userInfo[pid2][msg.sender];
            if(user2.LPAmount==0){
                updateFee(_lpToken,user.LPAmount,2);
                pool2.totalLp=pool2.totalLp.add(user.LPAmount);
            }else{
                updateFee(_lpToken,LPBalance,2);
                pool2.totalLp=pool2.totalLp.add(LPBalance);
            }
            user2.LPAmount=user.LPAmount;
            user2.usdtAmount=user.usdtAmount;
        }
        address referrer =getReferralRelationship(msg.sender);
        playerInfo[referrer].totalDepositOfDirectRecommend=playerInfo[referrer].totalDepositOfDirectRecommend.add(LPBalance);
        emit Deposit(msg.sender, pid, LPBalance);
    }

    function withdraw(address _lpToken) public {
        require(msg.sender == tx.origin,"Address: The transferred address cannot be a contract");
        require(isUserExists(msg.sender),"you are not registered");
        uint256 pid = getPid(_lpToken,1);
        PoolInfo storage pool = poolInfos[pid];
        UserInfo storage user = userInfo[pid][msg.sender];
        if (user.LPAmount > 0) {
            IERC20(pool.lpToken).safeTransfer(address(msg.sender), user.LPAmount);
            address referrer =getReferralRelationship(msg.sender);
            playerInfo[referrer].totalDepositOfDirectRecommend=playerInfo[referrer].totalDepositOfDirectRecommend.sub(user.LPAmount); 
        }
        if (user.usdtAmount > 19900*10**18) {
            uint256 pid2 = getPid(_lpToken,2);
            PoolInfo storage pool2 = poolInfos[pid2];
            UserInfo storage user2 = userInfo[pid2][msg.sender];
            pool2.totalLp=pool2.totalLp.sub(user2.LPAmount);
            user2.LPAmount = 0;
            user2.usdtAmount=0;
            pool2.totalDeptIGSDividendsByRemoveLp=pool2.totalDeptIGSDividendsByRemoveLp.add(user2.igsDividendsDebt);
            pool2.totalAssumedIGSDividends=pool2.totalAssumedIGSDividends.sub(user2.assumedIGSDividends);
            user2.assumedIGSDividends=0;
            user2.igsDividendsDebt=0;
            pool2.totalAssumedUSDTDividends=pool2.totalAssumedUSDTDividends.sub(user2.assumedUSDTDividends);
            pool2.totalDeptUSDTDividendsByRemoveLp=pool2.totalDeptUSDTDividendsByRemoveLp.add(user2.usdtDividendsDebt);
            user2.assumedUSDTDividends=0;
            user2.usdtDividendsDebt=0;
        }
        pool.totalLp=pool.totalLp.sub(user.LPAmount);
        pool.totalDeptIGSDividendsByRemoveLp=pool.totalDeptIGSDividendsByRemoveLp.add(user.igsDividendsDebt);
        pool.totalAssumedIGSDividends=pool.totalAssumedIGSDividends.sub(user.assumedIGSDividends);
        user.assumedIGSDividends=0;
        user.igsDividendsDebt=0;
        pool.totalAssumedUSDTDividends=pool.totalAssumedUSDTDividends.sub(user.assumedUSDTDividends);
        pool.totalDeptUSDTDividendsByRemoveLp=pool.totalDeptUSDTDividendsByRemoveLp.add(user.usdtDividendsDebt);
        user.LPAmount = 0;
        user.usdtAmount=0;
        user.assumedUSDTDividends=0;
        user.usdtDividendsDebt=0;
        emit Withdraw(msg.sender, pid, user.LPAmount);
    }
    function isUserExists(address user) public view returns (bool) {
        return (playerInfo[user].id != 0);
    }

    function bind(address _referrerAddress) public {
        require(msg.sender == tx.origin,"Address: The transferred address cannot be a contract");
        bool isExists =isUserExists(msg.sender);
        if(isExists){
            return;
        }
        require(isUserExists(_referrerAddress)||_referrerAddress==defaultReferrerAddress,"ReferrerAddress don't exist");
        Player storage player=playerInfo[msg.sender];
        if (!isExists){
            player.id=lastUserId;
            player.referrer=_referrerAddress;
            lastUserId++;
            playerInfo[_referrerAddress].directRecommendAddress.push(msg.sender);
         }
    }

    function getDirectRecommendAddress(address user) public view returns(address[] memory){
        return playerInfo[user].directRecommendAddress;
    }

    function getReferralRelationship(address user) public view returns(address){
        return playerInfo[user].referrer;
    }

    function consult(address _lpToken, uint256 _amountIn) public view returns (uint256 amountOut) {
        uint USDTBalance = IERC20(usdtTokenAddress).balanceOf(_lpToken);
        uint _totalSupply =IERC20(_lpToken).totalSupply();
        uint amount0 = _amountIn.mul(USDTBalance).div(_totalSupply);
        return amount0;
    }

    function getPrice() public view returns (uint){

        address[] memory path = new address[](2);
	    path[0] = igsTokenAddress;
	    path[1] = usdtTokenAddress;

        uint[] memory amount1 = uniswapV2Router.getAmountsOut(1*10**18,path);

        return amount1[1];
    }

    function swapAndLiquify(uint256 contractTokenBalance) private{
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);
        uint256 initialBalance = IERC20(igsTokenAddress).balanceOf(address(this));
        address[] memory path = new address[](2);
        path[0] = usdtTokenAddress;
        path[1] = igsTokenAddress;
        swapTokensForExactTokens(half,path); 
        uint256 newBalance = IERC20(igsTokenAddress).balanceOf(address(this)).sub(initialBalance);


        addLiquidity(otherHalf,newBalance);
    }

    function swapTokensForExactTokens(uint256 tokenAmount,address[] memory path) private {

        IERC20(igsTokenAddress).approve(
                address(uniswapV2Router),
                tokenAmount
        );
        IERC20(usdtTokenAddress).approve(
                address(uniswapV2Router),
                tokenAmount
        );
        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }
    function addLiquidity(uint256 usdtAmount,uint256 tokenAmount) private{

        IERC20(usdtTokenAddress).approve(
                address(uniswapV2Router),
                usdtAmount
        );
        IERC20(igsTokenAddress).approve(
                address(uniswapV2Router),
                tokenAmount
        );
        
        // add the liquidity
        uniswapV2Router.addLiquidity(
            address(usdtTokenAddress),
            address(igsTokenAddress),
            usdtAmount,
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp
        );
    }

}