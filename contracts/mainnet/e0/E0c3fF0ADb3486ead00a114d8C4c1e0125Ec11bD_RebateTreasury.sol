/**
 *Submitted for verification at BscScan.com on 2022-09-09
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;



// Part: IOracle

interface IOracle {
    function update() external;

    function consult(address _token, uint256 _amountIn) external view returns (uint144 amountOut);

    function twap(address _token, uint256 _amountIn) external view returns (uint144 _amountOut);
}

// Part: IRebateManager

interface IRebateManager {
    function mainTokenRebateAllowance(address _recipient) external returns(uint256);

    function shareTokenRebateAllowance(address _recipient) external returns(uint256);

}

// Part: IRewardPool

interface IRewardPool {

    function deposit(uint256 _pid, uint256 _amount) external;

    function depositFor(uint256 _pid, uint256 _amount, address _recipient) external;

    function withdraw(uint256 _pid, uint256 _amount) external;

    function pendingShare(uint256 _pid, address _user) external view returns (uint256);

    function userInfo(uint _pid, address _user) external view returns (uint amount, uint rewardDebt);

}

// Part: ITreasury

interface ITreasury {
    function epoch() external view returns (uint256);

    function nextEpochPoint() external view returns (uint256);

    function getToastPrice() external view returns (uint256);

    function buyBonds(uint256 amount, uint256 targetPrice) external;

    function redeemBonds(uint256 amount, uint256 targetPrice) external;

    function toastPriceOne() external view returns(uint256);

    function daoFund() external view returns(address);
    
    function devFund() external view returns(address);
}

// Part: IUniswapV2Factory

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function createPair(address tokenA, address tokenB) external returns (address pair);
}

// Part: IUniswapV2Pair

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(address indexed sender, uint256 amount0In, uint256 amount1In, uint256 amount0Out, uint256 amount1Out, address indexed to);
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to) external returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

// Part: IUniswapV2Router

interface IUniswapV2Router {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline) external payable
    returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// Part: openzeppelin/[email protected]/Address

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
        // This method relies in extcodesize, which returns 0 for contracts in
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
        return _functionCallWithValue(target, data, 0, errorMessage);
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
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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

// Part: openzeppelin/[email protected]/Context

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

// Part: openzeppelin/[email protected]/IERC20

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

// Part: openzeppelin/[email protected]/SafeMath

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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
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
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
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
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
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
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
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
        require(b != 0, errorMessage);
        return a % b;
    }
}

// Part: openzeppelin/[email protected]/Ownable

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
contract Ownable is Context {
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
}

// Part: openzeppelin/[email protected]/Pausable

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor () internal {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// Part: openzeppelin/[email protected]/SafeERC20

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

// File: RebateTreasury.sol

contract RebateTreasury is Ownable, Pausable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    struct Asset {
        bool isAdded;
        uint256 multiplier; //basis of DENOMINATOR
        uint256 lpMultiplier; //basis of DENOMINATOR
        address oracle;
        bool isLP;
        address pair;
    }

    IERC20 public rebateToken;
    IOracle public toastOracle;
    ITreasury public treasury;

    mapping (address => Asset) public assets;

    uint256 public primaryBondThreshold = 200_000;
    uint256 public primaryBondFactor = 800_000;
    uint256 public secondaryBondThreshold = 700_000;
    uint256 public secondaryBondFactor = 150_000;
    uint256 public maxBondPremium = 100_000;

    uint256 public constant DENOMINATOR = 1_000_000;

    address public immutable DAI;
    IUniswapV2Router public immutable ROUTER;
    IRewardPool public immutable REWARD_POOL;
    uint256 public ssPID = 10_000;
    uint256 public lpPID = 10_000;
    IUniswapV2Pair public immutable REBATETOKEN_DAI_LP;

    bool public allowLPSwapping = false;
    bool public enableAllowances = false;
    address public rebateManager;

    //*===================== EVENTS =====================*//

    event AddLiquidity(address tokenA, address tokenB, uint256 amountInA, uint256 amountInB, uint256 amountOut);
    event SwapToken(address tokenA, address tokenB, uint256 amountInA, uint256 amountOut);
    event BondTokens(address bondAsset, uint256 amountIn, uint256 rebateAmount, uint256 amountOut);

    //*===================== MODIFIERS =====================*//

    modifier onlyAsset(address token) {
        require(assets[token].isAdded, "RebateTreasury: token is not a bondable asset");
        _;
    }

    //*===================== INITIALIZER =====================*//

    constructor(
        address _rebateToken,
        address _dai,
        address _toastOracle,
        address _treasury,
        address _router,
        address _rewardPool,
        uint256 _ssPid,
        uint256 _lpPid
    ) public {
        DAI = _dai;
        rebateToken = IERC20(_rebateToken);
        toastOracle = IOracle(_toastOracle);
        treasury = ITreasury(_treasury);

        ROUTER = IUniswapV2Router(_router);

        REWARD_POOL = IRewardPool(_rewardPool);
        ssPID = _ssPid;
        lpPID = _lpPid;

        REBATETOKEN_DAI_LP = IUniswapV2Pair(IUniswapV2Factory(IUniswapV2Router(_router).factory()).getPair(_rebateToken, _dai));
    }

    //*===================== USER FUNCTIONS =====================*//

    function bond(address _token, uint256 _amount, bool _intoLP, uint256 _slippage) external {
        require(_slippage <= DENOMINATOR, "Error: Slippage exceeds 100%");
        require( (_intoLP ? lpPID : ssPID) < 5_000, "Error: PID not set");

        //Calculate the number of bonds available to the user.
        uint256 bondLimit = rebateTokensAvailable();
        if (enableAllowances == true) {
            uint256 rebateAllowance = IRebateManager(rebateManager).mainTokenRebateAllowance(msg.sender);

            if (rebateAllowance < bondLimit) {
                bondLimit = rebateAllowance;
            }
        }

        //Convert bond token limit to input domain.
        uint256 _bondlimitInputAmount = bondLimit.mul(DENOMINATOR).div(getAssetPremium(_token, _intoLP));

        //Use slippage to calculate a users lower bound for input tokens.
        uint256 _amountInLowerBound = _amount.mul(DENOMINATOR.sub(_slippage)).div(DENOMINATOR);

        //Enforce requirements
        require(bondLimit > 1 ether, "Error: Insufficient tokens to bond");
        require(_bondlimitInputAmount >= _amountInLowerBound, "Error: Insufficient tokens to bond (Slippage)");

        //Truncate the input amount where appropriate.
        if (_amount > _bondlimitInputAmount) {
            _amount = _bondlimitInputAmount;
        }

        //Bond tokens for user.
        _bond(
            _token,
            _amount,
            _intoLP,
            msg.sender
        );
    }

    // Bond asset for discounted Tomb at bond rate
    function _bond(address _token, uint256 _amount, bool _intoLP, address _recipient) internal onlyAsset(_token) whenNotPaused {
        require(_amount > 0, "RebateTreasury: invalid bond amount");

        uint256 rebateTokenAmount = getRebateTokenReturn(_token, _amount, _intoLP);

        //Need to transfer into this account and then deposit for other pools.
        IERC20(_token).transferFrom(_recipient, address(this), _amount);

        if (_intoLP == false) {
            //Increase allowance and deposit directly.
            rebateToken.safeIncreaseAllowance(address(REWARD_POOL), rebateTokenAmount);
            REWARD_POOL.depositFor(ssPID, rebateTokenAmount, _recipient);
            emit BondTokens(_token, _amount, rebateTokenAmount, rebateTokenAmount);
        } else {
            //Check if enough DAI to swap..
            uint256 toastPrice = getToastPrice(); //Toast price in DAI... therefore TOAST_USD/DAI_USD

            //Manage token balances.
            uint256 daiBalance = IERC20(DAI).balanceOf(address(this));
            uint256 daiAmount = rebateTokenAmount.div(2).mul(toastPrice).div(1e18);

            //If not enough dai balance to create LP.
            if (daiAmount > daiBalance) {
                if (allowLPSwapping == false) {
                    revert("Error (RebateTreasury): Dai balance too low");
                }

                uint256 daiNeeded = daiAmount.sub(daiBalance);
                uint256 rebateTokenAmountToSwap = daiNeeded.mul(1e18).div(toastPrice).mul(110).div(100);

                //Define swap path in memory.
                address[] memory swapPath = new address[](2);
                swapPath[0] = address(rebateToken);
                swapPath[1] = DAI;

                //Increase allowance and swap to get required DAI amount.
                rebateToken.safeIncreaseAllowance(address(ROUTER), rebateTokenAmountToSwap);
                uint[] memory amounts = ROUTER.swapTokensForExactTokens(
                    daiNeeded, //amountOut
                    rebateTokenAmountToSwap, //amountInMax
                    swapPath, //path
                    address(this), //to
                    block.timestamp+40 //deadline
                );
                emit SwapToken(address(rebateToken), DAI, amounts[amounts.length-1], daiNeeded);
            }

            //Recalculate dai and rebateToken amounts for adding liquidity.
            daiBalance = IERC20(DAI).balanceOf(address(this));
            daiAmount = daiAmount > daiBalance ? daiBalance : daiAmount;
            rebateTokenAmount = rebateTokenAmount.div(2);

            //Add Liquidity.
            rebateToken.safeIncreaseAllowance(address(ROUTER), rebateTokenAmount);
            IERC20(DAI).safeIncreaseAllowance(address(ROUTER), daiAmount);
            (,, uint256 lpAmount) = ROUTER.addLiquidity(
                address(rebateToken), //tokenA
                DAI, //tokenB
                rebateTokenAmount, //amountADesired
                daiAmount, //amountBDesired
                0, //amountAMin
                0, //amountBMin
                address(this), //to
                block.timestamp+40 //deadline
            );
            emit AddLiquidity(address(rebateToken), DAI, rebateTokenAmount, daiAmount, lpAmount);
            
            //Deposit LP into pool.
            IERC20(address(REBATETOKEN_DAI_LP)).safeIncreaseAllowance(address(REWARD_POOL), lpAmount);
            REWARD_POOL.depositFor(lpPID, lpAmount, _recipient);

            //Emit event.
            emit BondTokens(_token, _amount, rebateTokenAmount.mul(2), lpAmount);
        }

    }

    //*===================== EXTERNAL FUNCTIONS =====================*//

    function rebateTokensAvailable() public view returns(uint256) {
        return rebateToken.balanceOf(address(this));
    }

    //*===================== BOND CALCULATION FUNCTIONS =====================*//

    function getAssetPremium(
        address _token,
        bool _intoLP
    ) public view onlyAsset(_token) returns (uint256 assetPremium) {
        uint256 toastPrice = getToastPrice();
        uint256 tokenPrice = getTokenPrice(_token);
        uint256 bondPremium = getBondPremium();

        //Calculate the asset premium - basis of DENOMINATOR (i.e. 1_000_000)
        assetPremium = tokenPrice.mul(bondPremium.add(DENOMINATOR)).div(DENOMINATOR).mul(assets[_token].multiplier).div(toastPrice);
        if (_intoLP == true) {
            assetPremium = assetPremium.mul(assets[_token].lpMultiplier).div(DENOMINATOR);
        }
    }

    function getRebateTokenReturn(
        address _token,
        uint256 _amount,
        bool _intoLP
    ) public view onlyAsset(_token) returns (uint256 rebateTokenReturn) {
        uint256 assetPremium = getAssetPremium(
            _token, _intoLP
        );
        rebateTokenReturn = _amount.mul(assetPremium).div(DENOMINATOR);
    }

    // Calculate premium for bonds based on bonding curve
    function getBondPremium() public view returns (uint256) {
        uint256 toastPrice = getToastPrice();

        //Calculate and convert rebateToken premium from ether basis to DENOMINATOR basis
        uint256 rebateTokenPremium = toastPrice.mul(DENOMINATOR).div(treasury.toastPriceOne()).sub(DENOMINATOR); 

        //Enforce bonding threshold.
        if (rebateTokenPremium < primaryBondThreshold) return 0;

        //Control flow between 2 bond premium calculation methods.
        uint256 bondPremium;
        //Primary method.
        if (rebateTokenPremium <= secondaryBondThreshold) {
            bondPremium = rebateTokenPremium.sub(primaryBondThreshold).mul(primaryBondFactor).div(DENOMINATOR);
        //Secondary method.
        } else {
            bondPremium = secondaryBondThreshold.sub(primaryBondThreshold).mul(primaryBondFactor).div(DENOMINATOR);
            bondPremium = bondPremium.add(rebateTokenPremium.sub(secondaryBondThreshold)).mul(secondaryBondFactor).div(DENOMINATOR);
        }

        //Bound the bondPremium.
        if (bondPremium > maxBondPremium) {
            bondPremium = maxBondPremium;
        }
        return bondPremium;
    }

    //Get TOAST price from Oracle
    function getToastPrice() public view returns (uint256) {
        return toastOracle.consult(address(rebateToken), 1e18);
    }

    //Get token price from Oracle
    function getTokenPrice(address token) public view onlyAsset(token) returns (uint256) {
        Asset memory asset = assets[token];

        //DAI is always pegged to 1 DAI.
        if (token == DAI) { return 1 ether;}

        //SS price calculations.
        IOracle Oracle = IOracle(asset.oracle);
        if (!asset.isLP) {
            return Oracle.consult(token, 1e18);
        }

        //LP price calculations.
        IUniswapV2Pair Pair = IUniswapV2Pair(asset.pair);
        uint256 totalPairSupply = Pair.totalSupply();
        address token0 = Pair.token0();
        address token1 = Pair.token1();
        (uint256 reserve0, uint256 reserve1,) = Pair.getReserves();

        if (token1 == DAI) {
            uint256 tokenPrice = Oracle.consult(token0, 1e18);
            return tokenPrice.mul(reserve0).div(totalPairSupply).add(
                reserve1.mul(1e18).div(totalPairSupply)
            );
        } else {
            uint256 tokenPrice = Oracle.consult(token1, 1e18);
            return tokenPrice.mul(reserve1).div(totalPairSupply).add(
                reserve0.mul(1e18).div(totalPairSupply)
            );
        }
    }

    //*===================== RESTRICTED FUNCTIONS =====================*//

    // Set bonding parameters of token
    function setAsset(
        address token,
        bool isAdded,
        uint256 multiplier,
        uint256 lpMultiplier,
        address oracle,
        bool isLP,
        address pair
    ) external onlyOwner {
        assets[token].isAdded = isAdded;
        assets[token].multiplier = multiplier;
        assets[token].lpMultiplier = lpMultiplier;
        assets[token].oracle = oracle;
        assets[token].isLP = isLP;
        assets[token].pair = pair;
    }

    // Set bond pricing parameters
    function setBondParameters(
        uint256 _primaryBondThreshold,
        uint256 _primaryBondFactor,
        uint256 _secondaryBondThreshold,
        uint256 _secondaryBondFactor,
        uint256 _maxBondPremium
    ) external onlyOwner {
        primaryBondThreshold = _primaryBondThreshold;
        primaryBondFactor = _primaryBondFactor;
        secondaryBondThreshold = _secondaryBondThreshold;
        secondaryBondFactor = _secondaryBondFactor;
        maxBondPremium = _maxBondPremium;
    }

    function setAllowLPSwapping(
        bool _allowLPSwapping
    ) external onlyOwner {
        allowLPSwapping = _allowLPSwapping;
    }

    function setEnableAllowances(
        bool _enableAllowances
    ) external onlyOwner {
        enableAllowances = _enableAllowances;
    }

    function setPIDs(
        uint256 _ssPid,
        uint256 _lpPid
    ) external onlyOwner {
        ssPID = _ssPid;
        lpPID = _lpPid;
    }

    function setRebateManager(
        address _rebateManager
    ) external onlyOwner {
        rebateManager = _rebateManager;
    }

    function setToastOracle(
        address _toastOracle
    ) external onlyOwner {
        toastOracle = IOracle(_toastOracle);
    }

    // Redeem assets for buyback
    function redeemAssetsForBuyback(address[] calldata tokens) external onlyOwner {        
        for (uint256 t = 0; t < tokens.length; t ++) {
            IERC20 token = IERC20(tokens[t]);
            token.transfer(treasury.daoFund(), token.balanceOf(address(this)));
        }
    }

    //Pause/Unpause functions.
    function pause() external onlyOwner {
        _pause();
        emit Paused(msg.sender);
    } 

    function unpause() external onlyOwner {
        _unpause();
        emit Unpaused(msg.sender);
    }

}