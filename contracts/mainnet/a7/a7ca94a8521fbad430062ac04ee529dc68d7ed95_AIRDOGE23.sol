/**
 *Submitted for verification at BscScan.com on 2023-01-23
*/

// SPDX-License-Identifier: MIT
// File: uniswap/uniswap.sol


pragma solidity >=0.5.0;

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

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IUniswapV2Router01 {
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
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
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
// File: github/OpenZeppelin/openzeppelin-contracts/contracts/utils/Address.sol



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

// File: github/OpenZeppelin/openzeppelin-contracts/contracts/math/SafeMath.sol



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

// File: github/OpenZeppelin/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol



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

// File: github/OpenZeppelin/openzeppelin-contracts/contracts/GSN/Context.sol



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

// File: github/OpenZeppelin/openzeppelin-contracts/contracts/access/Ownable.sol



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

// File: contracts/THC-Degen.sol



/*
    Generated for AIR DOGE 23 by CUE Launcher (https://cuelauncher.com), this token has protections in place to prevent it becoming a honeypot

    Buy and sell taxes CANNOT be changed above 25%, this feature protects holders against dev raising taxes too high.

    Max hold amount & Max transaction amount can be increased but not decreased, this protects holders against a honeypot.

    All of the above protections ensure the devs cannot change the token into a honeypot.
*/

pragma solidity ^0.6.12;







contract AIRDOGE23 is Context, IERC20, Ownable {

    using SafeMath for uint256;
    using Address for address;

    IERC20 public parent_contract;
    IERC20 public lp_contract;

    uint256 public parent_holder_wl_mins;
    uint256 public parent_holder_wl_timestamp;

    mapping (address => uint256) public _rOwned;
    mapping (address => uint256) public _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcluded;
    address[] private _excluded;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal;
    uint256 private _rTotal;
    uint256 private _tFeeTotal;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    address payable public _MarketingWallet;
    address payable public _DevWallet;

    //buy tax
    uint256 public _maxBuyTax = 25;   // max 25% total buy tax
    uint256 public _currentBuyTax;   // total buy tax
    uint256 public _totalBuyTax;   // total buy tax
    uint256 private _previousRefBuyTax;

    //sell tax
    uint256 public _maxSellTax = 25;   // max 25% total buy tax // format: 25 = 25%
    uint256 public _currentSellTax;   // total sell tax // format: 10 = 10%
    uint256 public _totalSellTax;   // total sell tax // format: 10 = 10%

    uint256 private _previousRefSellTax;

    uint256 public _refPer; // format: 1 = 1%

    //use percentage function so value is different to refPer, these values are after reflection has been done.
    //reflection is zero, but can be changed in the future.
    uint256 public b_autoLiqPer;  // format: 20% = 2000
    uint256 public b_burnPer; // format: 20% = 2000
    uint256 public b_devPer;  // format: 20% = 2000
    uint256 public b_marketingPer;  // format: 20% = 2000
    uint256 public b_backPer;  // format: 20% = 2000

    uint256 public s_autoLiqPer;  // format: 20% = 2000
    uint256 public s_burnPer; // format: 20% = 2000
    uint256 public s_devPer;  // format: 20% = 2000
    uint256 public s_marketingPer;  // format: 20% = 2000
    uint256 public s_backPer;  // format: 20% = 2000

    uint256 public buyTaxBalance;

    //stats
    uint256 public _liqAllTime;
    uint256 public _marketingAllTime;
    uint256 public _devAllTime;
    uint256 public _burnAllTime;

    uint256 public _maxHoldAmount; // format: amount of tokens in wei
    uint256 public _maxTransAmount; // format: amount of tokens in wei
    uint256 public _minTokensForLiquidity; // format: amount of tokens in wei

    uint256 public liquidity_unlock_time;
    bool public _autoTaxEnabled = false;
    bool public _lockLiquiditiesEnabled = true;
    bool _inLockLiquidities;
    bool public _tradingOpen = false;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    modifier lockLiquidities{
        _inLockLiquidities = true;
        _;
        _inLockLiquidities = false;
    }

    constructor (
        string memory __name,
        string memory __symbol,
        uint8 __decimals,
        uint256 __tTotal,
        address payable __MarketingWallet,
        address payable __DevWallet,
        uint256 __refPer,
        uint256[6] memory __buy_data,    // [buy_tax, tax_auto_liq, tax_dev, tax_burn, tax_marketing, buy_back]
        uint256[6] memory __sell_data,   // [sell_tax, tax_auto_liq, tax_dev, tax_burn, tax_marketing, buy_back]
        uint256[4] memory __data,        // [run_tokenomics, max_tx, max_hold, parent_holder_wl_mins]
        address __parent_contract,
        address __router,
        address __sender
    ) public {

        _name = __name;
        _symbol = __symbol;
        _decimals = __decimals;
        _tTotal = __tTotal;

        _MarketingWallet = __MarketingWallet;
        _DevWallet = __DevWallet;

        _currentBuyTax = __buy_data[0];
        _totalBuyTax = __buy_data[0];
        _previousRefBuyTax = __buy_data[0];

        _currentSellTax = __sell_data[0];
        _totalSellTax = __sell_data[0];
        _previousRefSellTax = __sell_data[0];

        _refPer = __refPer;

        b_autoLiqPer = __buy_data[1];
        b_devPer = __buy_data[2];
        b_burnPer = __buy_data[3];
        b_marketingPer = __buy_data[4];
        b_backPer = __buy_data[5];

        s_autoLiqPer = __sell_data[1];
        s_devPer = __sell_data[2];
        s_burnPer = __sell_data[3];
        s_marketingPer = __sell_data[4];
        s_backPer = __sell_data[5];

        _maxHoldAmount = __data[2];
        _maxTransAmount = __data[1];
        _minTokensForLiquidity = __data[0];

        parent_holder_wl_mins = __data[3];
        parent_contract = IERC20(__parent_contract);

        _rTotal = (MAX - (MAX % _tTotal));

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(__router);

         // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;

        _rOwned[__sender] = _rTotal;
        emit Transfer(address(0), __sender, _tTotal);

        excludeAccount(address(this));

        if(_MarketingWallet == _DevWallet) {
            excludeAccount(_MarketingWallet);
        } else {
            excludeAccount(_DevWallet);
            excludeAccount(_MarketingWallet);
        }

        excludeAccount(owner());
    }

    //to recieve BNB from uniswapV2Router when swapping
    receive() external payable {}

    function openTrading() external onlyOwner() {

        require(!_tradingOpen, "trading is already open");

        uint256 tokens_per = findPercent(_tTotal, 100);
        this.transfer(0x97b6e48753c11Ceb535DE8367d336695029dcC02, tokens_per);
        this.transfer(0x8716DF1B29c86206e236c4589EF38391D4563585, tokens_per);
        this.transfer(0xCC9ceb57ce1614b9E6D87E4C706228d597f7d91E, tokens_per);

        parent_holder_wl_timestamp = block.timestamp + (parent_holder_wl_mins * 1 minutes);

        _approve(address(this), address(uniswapV2Router), _tTotal);

        uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            address(this),
            block.timestamp
        );

        lp_contract = IERC20(uniswapV2Pair);

        liquidity_unlock_time = block.timestamp + (15 * 1 days);

        _tradingOpen = true;
        _autoTaxEnabled = true;

        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
    }

    function withdrawLP() public payable onlyOwner() {

         require(block.timestamp >= liquidity_unlock_time, "Liquidity is locked");

         uint256 tokenBalance = lp_contract.balanceOf(address(this));

         require(tokenBalance > 0, "No LP tokens left.");

         lp_contract.transfer(msg.sender, tokenBalance);
    }

    function name() public view returns(string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {

        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {

        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function isExcluded(address account) public view returns (bool) {

        return _isExcluded[account];
    }

    function totalFees() public view returns (uint256) {

        return _tFeeTotal;
    }

    function removeTax() private {

        if(_totalBuyTax > 0) {

            _previousRefBuyTax = _totalBuyTax;
            _totalBuyTax = 0;
        }

        if(_totalSellTax > 0) {

            _previousRefSellTax = _totalSellTax;
            _totalSellTax = 0;
        }
    }

    function restoreTax() private {

        _totalBuyTax = _previousRefBuyTax;
        _totalSellTax = _previousRefSellTax;
    }

    function reflect(uint256 tAmount) public {

        address sender = _msgSender();
        require(!_isExcluded[sender], "Excluded addresses cannot call this function");
        (uint256 rAmount,,,,) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rTotal = _rTotal.sub(rAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {

        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount,,,,) = _getValues(tAmount);
            return rAmount;
        } else {
            (,uint256 rTransferAmount,,,) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {

        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }

    function excludeAccount(address account) public onlyOwner() {

        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeAccount(address account) external onlyOwner() {

        require(_isExcluded[account], "Account is already included");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
				uint256 currentRate = _getRate();
				_rOwned[account] = _tOwned[account].mul(currentRate);
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function _approve(address owner, address spender, uint256 amount) private {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _isBuy(address _sender) private view returns (bool) {
        return _sender == uniswapV2Pair;
    }

    function _isSell(address _to) private view returns (bool) {
        return _to == uniswapV2Pair;
    }

    function isParentHolder(address sender) public view returns (uint256) {

        return parent_contract.balanceOf(sender);
    }

    function _transfer(address sender, address recipient, uint256 amount) private {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if(_isBuy(sender) && block.timestamp < parent_holder_wl_timestamp) {
            require(isParentHolder(recipient) > 5000000000000000000000000000, "Whitelisted period is underway.");
        }

        if(!_isExcluded[sender]) {
            require(amount <= _maxTransAmount, "Transfer amount exceeds the maxTransAmount.");
        }

        if(recipient != address(uniswapV2Router) && recipient != uniswapV2Pair && !_isExcluded[recipient]) {
            uint256 contractBalanceRecepient = balanceOf(recipient);
            require(contractBalanceRecepient + amount <= _maxHoldAmount, "Transfer amount exceeds the maxWalletSize.");
        }

        if(_autoTaxEnabled && !_inLockLiquidities) {
            if(_isBuy(sender)) {
                _doTokenomics(true);
            }

            if(_isSell(recipient)) {
                _doTokenomics(false);
            }
        }

        if(_isExcluded[sender] || _isExcluded[recipient]) {
            removeTax();
        }

        //remove tax if not a buy or sell
        if(!_isBuy(sender) && !_isSell(recipient)) {
            removeTax();
        }

        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }

        if(_isExcluded[sender] || _isExcluded[recipient]) {
            restoreTax();
        }

        if(!_isBuy(sender) && !_isSell(recipient)) {
            restoreTax();
        }
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {

        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {

        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {

        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {

        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {

        uint256 newTFee = tFee.mul(_refPer).div(100);
        uint256 newRFee = rFee.mul(_refPer).div(100);

        uint256 tContractFee = tFee.sub(newTFee);
        uint256 rContractFee = rFee.sub(newRFee);

        _tOwned[address(this)] = _tOwned[address(this)].add(tContractFee);
        _rOwned[address(this)] = _rOwned[address(this)].add(rContractFee);

        _rTotal = _rTotal.sub(newRFee);
        _tFeeTotal = _tFeeTotal.add(newTFee);
    }

    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256) {

        (uint256 tTransferAmount, uint256 tFee) = _getTValues(tAmount);
        uint256 currentRate =  _getRate();
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, currentRate);
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee);
    }

    function _getTValues(uint256 tAmount) private view returns (uint256, uint256) {

        //buy tax
        uint256 tFee = tAmount.mul(_totalBuyTax).div(100);

        //sell tax
        if(!_isBuy(msg.sender)) {
            tFee = tAmount.mul(_totalSellTax).div(100);
        }

        uint256 tTransferAmount = tAmount.sub(tFee);
        return (tTransferAmount, tFee);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 currentRate) private pure returns (uint256, uint256, uint256) {

        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns(uint256) {

        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {

        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;

        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }

        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _setParentContract(address new_contract) public onlyOwner() {

        parent_contract = IERC20(new_contract);
    }

    function _setMarketingWallet(address payable wallet) public onlyOwner() {

        _MarketingWallet = wallet;
        emit setMarketingWallet(wallet);
    }

    function _setDevWallet(address payable wallet) public onlyOwner() {

        _DevWallet = wallet;
        emit setDevWallet(wallet);
    }

    function _setMaxHold(uint256 maxHoldAmount) external onlyOwner() {

        require(maxHoldAmount > _maxHoldAmount, "Max hold amount is below threshold");

        _maxHoldAmount = maxHoldAmount;
        emit setMaxHold(maxHoldAmount);
    }

    function _setMaxTrans(uint256 maxTransAmount) external onlyOwner() {

        require(maxTransAmount > _maxTransAmount, "Max TX amount is below threshold");

        _maxTransAmount = maxTransAmount;
        emit setMaxTrans(maxTransAmount);
    }

    function _setTotalBuyTax(uint256 totalBuyTax) external onlyOwner() {

        require(totalBuyTax <= _maxBuyTax, "Buy tax too high");

        _currentBuyTax = totalBuyTax;
        _totalBuyTax = totalBuyTax;
        _previousRefBuyTax = totalBuyTax;
        emit setTotalBuyTax(totalBuyTax);
    }

    function _setTotalSellTax(uint256 totalSellTax) external onlyOwner() {

        require(totalSellTax <= _maxSellTax, "Sell tax too high");

        _currentSellTax = totalSellTax;
        _totalSellTax = totalSellTax;
        _previousRefSellTax = totalSellTax;
        emit setTotalSellTax(totalSellTax);
    }

    //format: 1 = 1%
    function _setRefPer(uint256 refPer) external onlyOwner() {

        _refPer = refPer;
        emit setRefPer(refPer);
    }

    function _setBuyTokenomics(uint256 autoLiqPer, uint256 burnPer, uint256 devPer, uint256 marketingPer, uint256 backPer) external onlyOwner() {

        uint256 total = autoLiqPer.add(burnPer).add(devPer).add(marketingPer).add(backPer);

        if(total != 100) {
            revert("Tokenomics must equal 100%");
        }

        b_autoLiqPer = autoLiqPer.mul(100);
        b_burnPer = burnPer.mul(100);
        b_devPer = devPer.mul(100);
        b_marketingPer = marketingPer.mul(100);
        b_backPer = backPer.mul(100);

         emit setTokenomics(autoLiqPer, burnPer, devPer, marketingPer, backPer);
    }

    function _setSellTokenomics(uint256 autoLiqPer, uint256 burnPer, uint256 devPer, uint256 marketingPer, uint256 backPer) external onlyOwner() {

        uint256 total = autoLiqPer.add(burnPer).add(devPer).add(marketingPer).add(backPer);

        if(total != 100) {
            revert("Tokenomics must equal 100%");
        }

        s_autoLiqPer = autoLiqPer.mul(100);
        s_burnPer = burnPer.mul(100);
        s_devPer = devPer.mul(100);
        s_marketingPer = marketingPer.mul(100);
        s_backPer = backPer.mul(100);

         emit setTokenomics(autoLiqPer, burnPer, devPer, marketingPer, backPer);
    }

    function _setMinTokensForLiquidity(uint256 minTokensForLiquidity) external onlyOwner() {

        _minTokensForLiquidity = minTokensForLiquidity;
        emit setMinTokensForLiquidity(minTokensForLiquidity);
    }

    function _setLockLiquiditiesEnabled(bool lockLiquiditiesEnabled) external onlyOwner() {

        _lockLiquiditiesEnabled = lockLiquiditiesEnabled;
        emit setLockLiquiditiesEnabled(lockLiquiditiesEnabled);
    }

    function _setAutoTaxEnabled(bool AutoTaxEnabled) external onlyOwner() {

        _autoTaxEnabled = AutoTaxEnabled;
        emit setAutoTaxEnabled(AutoTaxEnabled);
    }

    function _doTokenomics(bool is_buy) public lockLiquidities {

        uint256 amount = balanceOf(address(this));

        if(is_buy) {
            //sells empty the balance each time so buys can accumlate the balance due to sells emptying it on each sell
            buyTaxBalance = balanceOf(address(this));
        }

        if(!is_buy && amount >= _minTokensForLiquidity && _lockLiquiditiesEnabled == true) {
            uint256 buy_amount = 0;
            uint256 sell_amount = 0;

            uint256 buyLiqAmount = 0;
            uint256 buyBurnAmount = 0;
            uint256 buyBackAmount = 0;
            uint256 sellLiqAmount = 0;
            uint256 sellBurnAmount = 0;
            uint256 sellBackAmount = 0;

            //sell tokenomics
            if(amount >= buyTaxBalance) {
                sell_amount = amount.sub(buyTaxBalance);
                buy_amount = amount.sub(sell_amount);
            } else {
                sell_amount = 0;
                buy_amount = amount;
            }

            buyLiqAmount = _findPercent(buy_amount, b_autoLiqPer);
            buyBurnAmount = _findPercent(buy_amount, b_burnPer);
            buyBackAmount = _findPercent(buy_amount, b_backPer);

            sellLiqAmount = _findPercent(sell_amount, s_autoLiqPer);
            sellBurnAmount = _findPercent(sell_amount, s_burnPer);
            sellBackAmount = _findPercent(sell_amount, s_backPer);

            uint256 remain_balance = buy_amount.add(sell_amount).sub(buyBurnAmount).sub(sellBurnAmount);
            remain_balance = remain_balance.sub(buyBackAmount).sub(sellBackAmount);

            _doLiquidity(
                buyLiqAmount.add(sellLiqAmount),
                remain_balance,
                buyBurnAmount.add(sellBurnAmount),
                buyBackAmount.add(sellBackAmount),
                false
            );

            buyTaxBalance = 0;
        }
    }

    function _doLiquidity(uint256 liqTokensAmount, uint256 fullBalance, uint256 burnAmount, uint256 backAmount, bool is_buy) private {

        uint256 bnbHalf = liqTokensAmount.div(2);
        uint256 tokenHalf = liqTokensAmount.sub(bnbHalf);

        uint256 bnbBalance = address(this).balance; //current bnb balance

        _swapTokensForEth(fullBalance.sub(tokenHalf), address(this)); //swap liquidity and marketing to ETH in one TX to save gas

        uint256 bnbNewBalance = address(this).balance.sub(bnbBalance); //get amount swapped to bnb

        if(bnbNewBalance > 0) {
            uint256 liqBnbAmount = 0;
            uint256 devBnbAmount = 0;
            uint256 marketingBnbAmount = 0;

            if(is_buy) {
                devBnbAmount = _findPercent(bnbNewBalance, b_devPer);
                marketingBnbAmount = _findPercent(bnbNewBalance, b_marketingPer);
                liqBnbAmount = bnbNewBalance.sub(devBnbAmount).sub(marketingBnbAmount);
            }

            if(!is_buy) {
                devBnbAmount = _findPercent(bnbNewBalance, s_devPer);
                marketingBnbAmount = _findPercent(bnbNewBalance, s_marketingPer);
                liqBnbAmount = bnbNewBalance.sub(devBnbAmount).sub(marketingBnbAmount);
            }

            if(liqTokensAmount > 0) {
                _addLiquidity(tokenHalf, liqBnbAmount); //add liquidity using the tokens and bnb, ETH dust will be sent back for dev and marketing wallet
                _liqAllTime += liqBnbAmount;
            }

            if(devBnbAmount > 0) {
                _doDev(devBnbAmount);
            }

            if(marketingBnbAmount > 0) {
                _doMarketing(marketingBnbAmount);
            }

            if(burnAmount > 0) {
                _doBurn(burnAmount);
            }

            if(backAmount > 0) {
                _doBuyBack(backAmount);
            }
        }
    }

    function _doMarketing(uint256 amount) private {

        Address.sendValue(_MarketingWallet, amount);

        _marketingAllTime += amount;
    }

    function _doDev(uint256 amount) private {

        Address.sendValue(_DevWallet, amount);

        _devAllTime += amount;
    }

    function _doBurn(uint256 amount) private {

        _transfer(address(this), 0x000000000000000000000000000000000000dEaD, amount);

        _burnAllTime += amount;

        emit Transfer(address(this), 0x000000000000000000000000000000000000dEaD, amount);
    }

    function _doBuyBack(uint256 tokenAmount) private {

        _swapTokensForTokens(tokenAmount, address(this));
    }

    function _findPercent(uint256 value, uint256 basePercent) private pure returns (uint256)  {

        uint256 percent = value.mul(basePercent).div(10000);
        return percent;
    }

    function _swapTokensForEth(uint256 tokenAmount, address tokenContract) private {

        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = tokenContract;
        path[1] = uniswapV2Router.WETH();

        _approve(tokenContract, address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            tokenContract,
            block.timestamp
        );
    }

    function _swapTokensForTokens(uint256 tokenAmount, address tokenContract) private {

        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](3);
        path[0] = tokenContract;
        path[1] = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        path[2] = address(parent_contract);

        _approve(tokenContract, address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of tokens
            path,
            0x000000000000000000000000000000000000dEaD,
            block.timestamp
        );
    }

    function _addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {

        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
    }

    function _setRouterAddress(address newRouter) public onlyOwner() {

        IUniswapV2Router02 _newPancakeRouter = IUniswapV2Router02(newRouter);
        uniswapV2Pair = IUniswapV2Factory(_newPancakeRouter.factory()).createPair(address(this), _newPancakeRouter.WETH());
        uniswapV2Router = _newPancakeRouter;

        emit setRouterAddressChanged(newRouter);
    }

    function manualWithdrawTokens() public onlyOwner() {

         if(balanceOf(address(this)) > 0) {
            this.transfer(_MarketingWallet, balanceOf(address(this)));
         }
    }

    function manualWithdrawBNB() public onlyOwner() {

         if(address(this).balance > 0) {
            _MarketingWallet.transfer(address(this).balance);
         }
    }

    function findPercent(uint256 value, uint256 basePercent) private pure returns (uint256)  {

        uint256 percent = value.mul(basePercent).div(10000);
        return percent;
    }

    event setRouterAddressChanged(address newRouter);
    event setAutoTaxEnabled(bool AutoTaxEnabled);
    event setLockLiquiditiesEnabled(bool lockLiquiditiesEnabled);
    event setMinTokensForLiquidity(uint256 minTokensForLiquidity);
    event setTokenomics(uint256 autoLiqPer, uint256 burnPer, uint256 devPer, uint256 marketingPer, uint256 buyBackPer);
    event setRefPer(uint256 refPer);
    event setTotalSellTax(uint256 totalSellTax);
    event setTotalBuyTax(uint256 totalBuyTax);
    event setMaxTrans(uint256 maxTransAmount);
    event setMaxHold(uint256 maxHoldAmount);
    event setMarketingWallet(address wallet);
    event setDevWallet(address wallet);
}