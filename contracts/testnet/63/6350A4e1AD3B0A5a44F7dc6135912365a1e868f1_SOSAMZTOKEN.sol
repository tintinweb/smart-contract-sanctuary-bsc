/**
 *Submitted for verification at BscScan.com on 2022-04-30
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-06
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * @dev Interface of theIUniswapV2 AND Factory/Pair/Route.
 */
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

/**
 * @dev Interface of theIUniswapV2 Pair.
 */
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

/**
 * @dev Interface of theIUniswapV2 AND Route.
 */
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

/**
 * @dev Interface of theIUniswapV2 AND Factory.
 */
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

/**
 * @title BEP20 interface
 * @dev see https://eips.ethereum.org/EIPS/eip-20
 */
interface IBEP20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

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
    address public _owner;

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
}

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing BEP721 ids, or counting request ids.
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
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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

contract SOSAMZTOKEN is Context, IBEP20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    bool private inTransfer;
    mapping (address => bool) private _isExcluded;
    address[] private _excluded;

    address public LiquidAddress;
    address public CompanyAddress;
    address private WithdrawAddress;

    uint256 public     _TAX_FEE;
    uint256 public    _COMPANY_FEE;
    uint256 public _LIQUIDITY_FEE;

    uint256 private ORIG_TAX_FEE;
    uint256 private ORIG_COMPANY_FEE;
    uint256 private ORIG_LIQUIDITY_FEE;

    string private _name = "ArcadianTest";
    string private _symbol = "ARCT";
    uint8 private _decimals = 9;
   
    uint256 private constant MAX = ~uint256(0);
    uint256 private constant _tTotal = 200 * 10**6 * 10**9;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 public _maxTxAmount = 5000 * 10**9;

    uint256 private _tFeeTotal;
    uint256 private _tLiquidityTotal;
    uint256 private _tCompanyTotal;
    
    bool private inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = false;
    
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    constructor (
        uint256 _txFee, // Fee distribution to Holders
        uint256 _companyFee, // Fee distribution to Company
        uint256 _liquidityFee, // Fee distribution to liquidity
        address Owner_,
        address _LiquidAddr,
        address _CompanyAddr,
        address _WithdrawAddr,
        address Swap_Route
    ){
        _owner = Owner_;
        _rOwned[_msgSender()] = _rTotal;
        emit Transfer(address(0), _msgSender(), _tTotal);

        _TAX_FEE = _txFee; 
        _COMPANY_FEE = _companyFee;
        _LIQUIDITY_FEE = _liquidityFee;
        ORIG_TAX_FEE = _TAX_FEE;
        ORIG_COMPANY_FEE = _COMPANY_FEE;
        ORIG_LIQUIDITY_FEE = _LIQUIDITY_FEE;

        LiquidAddress = _LiquidAddr;
        CompanyAddress = _CompanyAddr;
        WithdrawAddress = _WithdrawAddr;
        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(Swap_Route); // PancakeSwap Router
        address PairCreated = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = PairCreated;
               
        _isExcluded[address(uniswapV2Router)] = true;
        _isExcluded[uniswapV2Pair] = true;
        _isExcluded[address(this)] = true;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {BEP20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IBEP20-balanceOf} and {IBEP20-transfer}.
     */
    function decimals() public view virtual returns (uint256) {
        return _decimals;
    }

    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }

    function totalBalance() external view returns(uint256) {
        return payable(address(this)).balance;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "TOKEN20: transfer amount exceeds allowance"));
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "TOKEN20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Enables the contract to receive BNB.
     */
    receive() external payable {}

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }
    
    function totalCompany() public view returns (uint256) {
        return _tCompanyTotal;
    }
    
    function totalLiquidity() public view returns (uint256) {
        return _tLiquidityTotal;
    }
	
	function updateFee(uint256 _txFee,uint256 _liquidityFee,uint256 _companyFee) public onlyOwner() {
        _TAX_FEE = _txFee; 
        _LIQUIDITY_FEE = _liquidityFee;
		_COMPANY_FEE = _companyFee;
		ORIG_TAX_FEE = _TAX_FEE;
		ORIG_LIQUIDITY_FEE = _LIQUIDITY_FEE;
		ORIG_COMPANY_FEE = _COMPANY_FEE;
	}

    function reflect(uint256 tAmount) public {
        address sender = _msgSender();
        require(!_isExcluded[sender], "Excluded addresses cannot call this function");
        (uint256 rAmount,) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rTotal = _rTotal.sub(rAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount,) = _getValues(tAmount);
            return rAmount;
        } else {
            (,uint256 rTransferAmount) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }

    function excludeAccountToFee(address account) external onlyOwner() {
        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeAccountToFee(address account) external onlyOwner() {
        require(_isExcluded[account], "Account is already excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "TOKEN20: approve from the zero address");
        require(spender != address(0), "TOKEN20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 tAmount = amount;
        uint256 feeTokenAmount = 0;
        uint isFirst = 1;
        
        // Remove fees for transfers to and from account transfer or to excluded account
        if(!inTransfer){
            inTransfer = true;
            if(sender != uniswapV2Pair && recipient != uniswapV2Pair || _isExcluded[sender] || inSwapAndLiquify){
                removeAllFee();
            }
            feeTokenAmount = _getTokenFeeTotal(tAmount);

            if (
                isFirst == 1 &&
                feeTokenAmount > 0 &&
                balanceOf(address(this)) >= feeTokenAmount &&
                sender != address(uniswapV2Pair) &&
                !inSwapAndLiquify &&
                swapAndLiquifyEnabled
            ){
                isFirst+=1;
                /* Swap liquidity */
                swapAndLiquify(tAmount);
            }

            if (_isExcluded[sender] && !_isExcluded[recipient]) {
                _transferFromExcluded(sender, recipient, tAmount);
            } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
                _transferToExcluded(sender, recipient, tAmount);
            } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
                _transferStandard(sender, recipient, tAmount);
            } else if (_isExcluded[sender] && _isExcluded[recipient]) {
                _transferBothExcluded(sender, recipient, tAmount);
            } else {                
                _transferStandard(sender, recipient, tAmount);
            }

            restoreAllFee();
            inTransfer = false;
        }
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount) = _getValues(tAmount);
        (uint256 tTransferAmount,,,) = _getTValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);       
        _reflectFee(tAmount, sender);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount) = _getValues(tAmount);
        (uint256 tTransferAmount,,,) = _getTValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);           
        _reflectFee(tAmount, sender);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount) = _getValues(tAmount);
        (uint256 tTransferAmount,,,) = _getTValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);   
        _reflectFee(tAmount, sender);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount) = _getValues(tAmount);
        (uint256 tTransferAmount,,,) = _getTValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);        
        _reflectFee(tAmount, sender);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _reflectFee(uint256 tAmount, address sender) private {
        (,uint256 tFee, uint256 tLiquidity, uint256 tCompany) = _getTValues(tAmount);
        (uint256 rFee, uint256 rLiquidity, uint256 rCompany) = _getRValues(tFee, tLiquidity, tCompany);
        _tFeeTotal = _tFeeTotal.add(tFee);
        _tLiquidityTotal = _tLiquidityTotal.add(tLiquidity);
        _tCompanyTotal = _tCompanyTotal.add(tCompany);
        _rTotal = _rTotal.sub(rFee).sub(rLiquidity).sub(rCompany);
        if(tLiquidity > 0){
            _sendToLiquidity(tLiquidity, sender);
        }
        if(tCompany > 0){
            _sendToCompany(tCompany, sender);
        }
        emit FeeTransaction(tFee, tLiquidity, tCompany);
    }

    function _sendToLiquidity(uint256 tLiquidity, address sender) private {
        uint256 currentRate = _getRate();
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
        _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity);
        emit Transfer(sender, address(this), tLiquidity);
    }

    function _sendToCompany(uint256 tCompany, address sender) private {
        uint256 currentRate = _getRate();
        uint256 rCompany = tCompany.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rCompany);
        _tOwned[address(this)] = _tOwned[address(this)].add(tCompany);
        emit Transfer(sender, address(this), tCompany);
    }

    function _getValues(uint256 tAmount) private view returns (uint256, uint256) {
        uint256 currentRate =  _getRate();
        (,uint256 tFee, uint256 tLiquidity,uint256 tCompany) = _getTValues(tAmount);
        (uint256 rFee, uint256 rLiquidity, uint256 rCompany) = _getRValues(tFee, tLiquidity, tCompany);
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rLiquidity).sub(rCompany);
        return (rAmount, rTransferAmount);
    }

    function _getTValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256) {
        uint256 tFee = tAmount.mul(_TAX_FEE).div(100);
        uint256 tLiquidity = tAmount.mul(_LIQUIDITY_FEE).div(100);
        uint256 tCompany = tAmount.mul(_COMPANY_FEE).div(100);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tLiquidity).sub(tCompany);
        return (tTransferAmount, tFee, tLiquidity, tCompany);
    }

    function _getRValues(uint256 tFee, uint256 tLiquidity,uint256 tCompany) private view returns (uint256, uint256, uint256) {
        uint256 currentRate =  _getRate();
        uint256 rFee = tFee.mul(currentRate);
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        uint256 rCompany = tCompany.mul(currentRate);
        return (rFee, rLiquidity, rCompany);
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

    function removeAllFee() private {
        if(_TAX_FEE == 0 && _LIQUIDITY_FEE == 0 && _COMPANY_FEE == 0) return;
        
        ORIG_TAX_FEE = _TAX_FEE;
        ORIG_LIQUIDITY_FEE = _LIQUIDITY_FEE;
        ORIG_COMPANY_FEE = _COMPANY_FEE;
        
        _TAX_FEE = 0;
        _LIQUIDITY_FEE = 0;
        _COMPANY_FEE = 0;
    }
    
    function restoreAllFee() private {
        _TAX_FEE = ORIG_TAX_FEE;
        _LIQUIDITY_FEE = ORIG_LIQUIDITY_FEE;
        _COMPANY_FEE = ORIG_COMPANY_FEE;
    }

    /* Internal Function to swap Tokens and add to Liquidity */
    function swapAndLiquify(uint256 tAmount) private lockTheSwap {
        /* Split the contract balance into halves */
        uint256 tokenAmount = _getTokenFeeTotal(tAmount);

        /* Swap tokens for BNB */
        swapTokensForBNB(tokenAmount); // <- This breaks the BNB -> WORTH swap when swap+liquify is triggered
    }

    /* Internal Function to swap tokens for BNB */
    function swapTokensForBNB(uint256 tokenAmount) private {
        _approve(address(this), address(uniswapV2Router), type(uint256).max);
        _approve(address(this), address(uniswapV2Pair), type(uint256).max);

        // estimated value min whit BNB
        address Wbnb = uniswapV2Router.WETH();
       (uint112 reserve0, uint112 reserve1) = getTokenReserves(uniswapV2Pair);
        bool reversed = isReversed(uniswapV2Pair, Wbnb);
        if (reversed) { uint112 temp = reserve0; reserve0 = reserve1; reserve1 = temp; }
        uint256 wbnbAmount = getAmountOut(tokenAmount, reserve1, reserve0);
        uint256 half = wbnbAmount.div(2);
        uint256 otherHalf = wbnbAmount.sub(half);
        
        if(half != 0){
            swapToken(uniswapV2Pair, reversed ? 0 : half, reversed ? half : 0, LiquidAddress);        
        }
        if(otherHalf != 0){
            swapToken(uniswapV2Pair, reversed ? 0 : otherHalf, reversed ? otherHalf : 0, CompanyAddress);        
        }
    }

    // gas optimization on swap operation using a liquidity pool
    function swapToken(address pair, uint amount0Out, uint amount1Out, address receiver) internal {
        bool failed = false;
        assembly {
        let emptyPointer := mload(0x40)
        mstore(emptyPointer, 0x022c0d9f00000000000000000000000000000000000000000000000000000000)
        mstore(add(emptyPointer, 0x04), amount0Out)
        mstore(add(emptyPointer, 0x24), amount1Out)
        mstore(add(emptyPointer, 0x44), receiver)
        mstore(add(emptyPointer, 0x64), 0x80)
        mstore(add(emptyPointer, 0x84), 0)
        failed := iszero(call(gas(), pair, 0, emptyPointer, 0xa4, 0, 0))
        }
        if (failed) revert("Unable to swap");
    }

    function sendFeeBNB(address recipient, uint256 withAmount) private {
        // prevent re-entrancy attacks
        payable(recipient).transfer(withAmount);
        emit BNBWithdrawn(recipient, withAmount);
    }

    function _getTokenFeeTotal(uint256 amount) private view returns (uint256){
        uint256 tokenFee = _COMPANY_FEE.add(_LIQUIDITY_FEE);
        uint256 tokenAmount = amount.mul(tokenFee).div(100);        
        return tokenAmount;
    }

    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) internal pure returns (uint256 amountOut) {
        require(amountIn > 0, 'Insufficient amount in');
        require(reserveIn > 0 && reserveOut > 0, 'Insufficient liquidity');
        uint256 amountInWithFee = amountIn * 9975;
        uint256 numerator = amountInWithFee  * reserveOut;
        uint256 denominator = (reserveIn * 10000) + amountInWithFee;
        amountOut = numerator / denominator;
    }

    // gas optimization on get reserves from liquidity pool
    function getTokenReserves(address pairAddress) internal view returns (uint112 reserve0, uint112 reserve1) {
        bool failed = false;
        assembly {
            let emptyPointer := mload(0x40)
            mstore(emptyPointer, 0x0902f1ac00000000000000000000000000000000000000000000000000000000)
            failed := iszero(staticcall(gas(), pairAddress, emptyPointer, 0x4, emptyPointer, 0x40))
            reserve0 := mload(emptyPointer)
            reserve1 := mload(add(emptyPointer, 0x20))
        }
        if (failed) revert("Unable to get reserves from pair");
    }

    // gas optimization on get Token0 from a pair liquidity pool
    function isReversed(address pair, address tokenA) internal view returns (bool) {
        address token0;
        bool failed = false;
        assembly {
            let emptyPointer := mload(0x40)
            mstore(emptyPointer, 0x0dfe168100000000000000000000000000000000000000000000000000000000)
            failed := iszero(staticcall(gas(), pair, emptyPointer, 0x04, emptyPointer, 0x20))
            token0 := mload(emptyPointer)
        }
        if (failed) revert("Unable to check direction of token from pair");
        return token0 != tokenA;
    }

    // gas optimization on get balanceOf fron BEP20 or ERC20 token
    function getTokenBalanceOf(address token, address holder) internal view returns (uint112 tokenBalance) {
        bool failed = false;
        assembly {
        let emptyPointer := mload(0x40)
        mstore(emptyPointer, 0x70a0823100000000000000000000000000000000000000000000000000000000)
        mstore(add(emptyPointer, 0x04), holder)
        failed := iszero(staticcall(gas(), token, emptyPointer, 0x24, emptyPointer, 0x40))
        tokenBalance := mload(emptyPointer)
        }
        if (failed) revert("Unable to get balance from wallet");
    }

    function setCompanyAdress(address _companyAddress) public onlyOwner() {
        CompanyAddress = _companyAddress;
    }

    function setLiquidityAdress(address _liquidityAddress) public onlyOwner() {
        LiquidAddress = _liquidityAddress;
    }

    function setWithAdress(address payable _WithdrawAddr) public onlyOwner() {
        WithdrawAddress = _WithdrawAddr;
    }

    function getWithdrawAddress() public view returns (address) {
        return WithdrawAddress;
    }
    
    /* Function     : Turns ON/OFF Liquidity swap */
    /* Parameters   : Set 'true' to turn ON and 'false' to turn OFF */
    /* Only Owner Function */
    function setSwapAndLiquifyEnabled(bool _enabled) external onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(swapAndLiquifyEnabled);
    }
  
    function withdToBNB() public onlyOwner(){
        require(WithdrawAddress != address(0), "To make the withdrawal, you need to register a valid address.");
        require(this.totalBalance() > 0, "You do not have enough balance for this withdrawal");
        payable(WithdrawAddress).transfer(this.totalBalance());
    }
  
    function withdTokens(address _contractAdd) public onlyOwner(){
        require(WithdrawAddress != address(0), "To make the withdrawal, you need to register a valid address.");
        IBEP20 ContractAdd = IBEP20(_contractAdd);
        uint256 dexBalance = ContractAdd.balanceOf(address(this));
        require(dexBalance > 0, "You do not have enough balance for this withdrawal");
        ContractAdd.transfer(WithdrawAddress, dexBalance);
    }

    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(uint256 tokenAmount, uint256 half, uint256 otherHalf);
    event FeeTransaction( uint256 tFee, uint256 tLiquidity, uint256 tCompany);
    event BNBWithdrawn(address beneficiary,uint256 value);
}