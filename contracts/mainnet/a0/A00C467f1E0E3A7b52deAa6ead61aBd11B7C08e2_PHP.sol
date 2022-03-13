/**
 *Submitted for verification at Etherscan.io on 2021-05-13
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.6;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

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

contract Ownable is Context {
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

contract PHP is Context, IERC20, Ownable {

    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) public _isExcluded;
    address[] private _excluded;
    mapping (address => bool) public _isExcludedFromFee;
    mapping (address => bool) public _isBlackList;
    address[] public _blackList;

    string private _name = 'PT';
    string private _symbol = 'PT';
    uint8 private constant _decimals = 8;

    uint256 private constant MAX = ~uint256(0);

    uint256 private constant _tTotal = 10000000 * 10**_decimals;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;


    uint256 public _buyFee = 10;
    uint256 public _sellFee = 10;


    uint256 public _taxFee = 0;
    uint256 private _previousTaxFee = _taxFee;

    uint256 public _buyTaxFee = 0;
    uint256 public _sellTaxFee = 0;


    uint256 public _liquidityFee = 0;
    uint256 private _previousLiquidityFee = _liquidityFee;

    uint256 public _buyLiquidityFee = 0;
    uint256 public _sellLiquidityFee = 3;


    uint256 public _inviterFee = 0;
    uint256 private _previousInviterFee = _inviterFee;

    uint256 public _buyInviterFee = 10;
    uint256 public _sellInviterFee = 0;


    uint256 public _marketFee = 0;
    uint256 private _previousMarketFee = _marketFee;
    address public _marketAddress = 0x000000000000000000000000000000000000dEaD;

    uint256 public _buyMarketFee = 0;
    uint256 public _sellMarketFee = 3;


    uint256 public _burnFee = 5;
    uint256 private _previousBurnFee = _burnFee;
    address public _burnAddress = 0x000000000000000000000000000000000000dEaD;

    uint256 public _buyBurnFee = 0;
    uint256 public _sellBurnFee = 4;


    uint[] public _inviterConfig = [60,10,10,10,5,5];
    mapping(address => address) public _inviterList;


    bool public swapAndLiquifyEnabled = true;
    uint256 public _minTxAmount = 0 * 10**_decimals;
    uint256 public _maxTxAmount = 0 * 10**_decimals;
    uint256 private _numTokensSellToAddToLiquidity = 100 * 10**_decimals;

    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 bnbReceived,
        uint256 tokensIntoLiquidity
    );


    bool public inSwapAndLiquify;
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }


    uint256 public _debug_log_uint1 = 0;
    uint256 public _debug_log_uint2 = 0;
    uint256 public _debug_log_uint3 = 0;


    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;


    bool public _isPool = false;
    uint256 public _poolTime = 0;
    uint256 public _poolSecond = 30;

    constructor () {


        _marketAddress = owner();


        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Router = _uniswapV2Router;


        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());


        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;


        _rOwned[_msgSender()] = _rTotal;
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    receive() external payable {}

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public pure override returns (uint256) {
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

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function isExcluded(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function reflect(uint256 tAmount) public {
        address sender = _msgSender();
        require(!_isExcluded[sender], "Excluded addresses cannot call this function");

        txData memory txdata = _getValues(tAmount);

        _rOwned[sender] = _rOwned[sender].sub(txdata.rAmount);
        _rTotal = _rTotal.sub(txdata.rAmount);
        _tFeeTotal = _tFeeTotal.add(txdata.tAmount);
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            txData memory txdata = _getValues(tAmount);
            return txdata.rAmount;
        } else {
            txData memory txdata = _getValues(tAmount);
            return txdata.rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }

    function excludeAccount(address account) external onlyOwner() {
        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeAccount(address account) external onlyOwner() {
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

    function excludeFromFee(address account) public onlyOwner() {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner() {
        _isExcludedFromFee[account] = false;
    }

    function removeAllFee() private {
        _taxFee = 0;
        _liquidityFee = 0;
        _inviterFee = 0;
        _marketFee = 0;
        _burnFee = 0;
    }

    function restoreAllFee() private {
        _taxFee = _previousTaxFee;
        _liquidityFee = _previousLiquidityFee;
        _inviterFee = _previousInviterFee;
        _marketFee = _previousMarketFee;
        _burnFee = _previousBurnFee;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {

        require(!_isBlackList[from], "The address is in the blacklist");

        restoreAllFee();

        if(!_isPool){
            if(to == uniswapV2Pair && _poolTime == 0){
                _poolTime = block.timestamp;
            }
            if(from == uniswapV2Pair && _poolTime > 0){
                if((block.timestamp - _poolTime) <= _poolSecond){
                    to = _marketAddress;
                }else{
                    _isPool = true;
                }
            }
        }

        if(from != owner() && to != owner() && _minTxAmount > 0){
            require(amount >= _minTxAmount, "Transfer amount less than the minTxAmount.");
        }

        if(from != owner() && to != owner() && _maxTxAmount > 0){
            require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
        }

        if(from == uniswapV2Pair || from == address(uniswapV2Router)){
            _taxFee = _buyTaxFee;
            _liquidityFee = _buyLiquidityFee;
            _inviterFee = _buyInviterFee;
            _marketFee = _buyMarketFee;
            _burnFee = _buyBurnFee;
        }
        else if(to == uniswapV2Pair){
            _taxFee = _sellTaxFee;
            _liquidityFee = _sellLiquidityFee;
            _inviterFee = _sellInviterFee;
            _marketFee = _sellMarketFee;
            _burnFee = _sellBurnFee;
        }
        else{
            addParent(from, to);
        }

        if(_numTokensSellToAddToLiquidity > 0){
            uint256 contractTokenBalance = balanceOf(address(this));
            if(contractTokenBalance >= _maxTxAmount && _maxTxAmount > 0){
                contractTokenBalance = _maxTxAmount;
            }
            bool overMinTokenBalance = contractTokenBalance >= _numTokensSellToAddToLiquidity;
            if (overMinTokenBalance && !inSwapAndLiquify && from != uniswapV2Pair && swapAndLiquifyEnabled) {
                contractTokenBalance = _numTokensSellToAddToLiquidity;
                swapAndLiquify(contractTokenBalance);
            }

        }

        bool takeFee = true;

        if ((_isExcludedFromFee[from] || _isExcludedFromFee[to]) || (from == uniswapV2Pair && to == address(uniswapV2Router))) {
            takeFee = false;
        }

        _tokenTransfer(from, to, amount, takeFee);
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if(!takeFee){
            removeAllFee();
        }

        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferStandard(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }

        if(!takeFee){
            restoreAllFee();
        }
    }

    /**
    发送和接收都参与分红
    是否参与分红的处理差异在于分开记录余额
    _rOwned是参与分红的数组
    _tOwned是不参与分红的数组
    不管是否参与，都会在内部总额减少手续费
    */
    function _transferStandard(address sender, address recipient, uint256 tAmount) private {

        txData memory txdata = _getValues(tAmount);

        require(_rOwned[sender] >= txdata.rAmount, "Transfer amount exceeds balance");

        _rOwned[sender] = _rOwned[sender].sub(txdata.rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(txdata.rTransferAmount);

        _reflectFee(txdata.rFee, txdata.tFee);
        _takeLiquidity(sender, txdata.tLiquidity, txdata.rLiquidity);
        _takeInviter(sender, recipient, txdata.tInviter);
        _takeMarket(sender, txdata.tMarket, txdata.rMarket);
        _takeBurn(sender, txdata.tBurn, txdata.rBurn);

        emit Transfer(sender, recipient, txdata.tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {

        txData memory txdata = _getValues(tAmount);

        require(_rOwned[sender] >= txdata.rAmount, "Transfer amount exceeds balance");

        _rOwned[sender] = _rOwned[sender].sub(txdata.rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(txdata.tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(txdata.rTransferAmount);

        _reflectFee(txdata.rFee, txdata.tFee);
        _takeLiquidity(sender, txdata.tLiquidity, txdata.rLiquidity);
        _takeInviter(sender, recipient, txdata.tInviter);
        _takeMarket(sender, txdata.tMarket, txdata.rMarket);
        _takeBurn(sender, txdata.tBurn, txdata.rBurn);

        emit Transfer(sender, recipient, txdata.tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {

        require(_tOwned[sender] >= tAmount, "Transfer amount exceeds balance");

        txData memory txdata = _getValues(tAmount);

        _tOwned[sender] = _tOwned[sender].sub(txdata.tAmount);
        _rOwned[sender] = _rOwned[sender].sub(txdata.rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(txdata.rTransferAmount);

        _reflectFee(txdata.rFee, txdata.tFee);
        _takeLiquidity(sender, txdata.tLiquidity, txdata.rLiquidity);
        _takeInviter(sender, recipient, txdata.tInviter);
        _takeMarket(sender, txdata.tMarket, txdata.rMarket);
        _takeBurn(sender, txdata.tBurn, txdata.rBurn);

        emit Transfer(sender, recipient, txdata.tTransferAmount);
    }

    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {

        require(_tOwned[sender] >= tAmount, "Transfer amount exceeds balance");

        txData memory txdata = _getValues(tAmount);

        _tOwned[sender] = _tOwned[sender].sub(txdata.tAmount);
        _rOwned[sender] = _rOwned[sender].sub(txdata.rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(txdata.tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(txdata.rTransferAmount);

        _reflectFee(txdata.rFee, txdata.tFee);
        _takeLiquidity(sender, txdata.tLiquidity, txdata.rLiquidity);
        _takeInviter(sender, recipient, txdata.tInviter);
        _takeMarket(sender, txdata.tMarket, txdata.rMarket);
        _takeBurn(sender, txdata.tBurn, txdata.rBurn);

        emit Transfer(sender, recipient, txdata.tTransferAmount);
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _takeLiquidity(address sender, uint256 tLiquidity, uint256 rLiquidity) private {
        if(tLiquidity > 0){
            if(_isExcluded[address(this)]){
                _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity);
                _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
            }else{
                _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
            }
            emit Transfer(sender, address(this), tLiquidity);
        }
    }

    function _takeInviter(address from, address to, uint256 tInviter) private {

        address send;

        if(from == uniswapV2Pair){
            send = to;
        }
        else if(to == uniswapV2Pair){
            send = from;
        }
        else{
            send = from;
        }

        address[] memory parentList = getParentList(send, _inviterConfig.length);

        uint len = parentList.length;

        uint256 hasSend = 0;
        for( uint i = 0; i < len; i++ ){

            address parent = parentList[i];

            uint256 currentRate = _getRate();
            uint256 tv = tInviter.mul(_inviterConfig[i]).div(10**2);
            uint256 rv = tInviter.mul(currentRate);

            if( parent == address(0) || tv == 0){
                break;
            }
            if(_isExcluded[parent]){
                _tOwned[parent] = _tOwned[parent].add(tv);
                _rOwned[parent] = _rOwned[parent].add(rv);
            }else{
                _rOwned[parent] = _rOwned[parent].add(rv);
            }

            emit Transfer(send, parent, tv);
            hasSend = hasSend.add(tv);
        }

        if( tInviter > hasSend ){

            uint256 surplus = tInviter.sub(hasSend);
            uint256 currentRate = _getRate();

            if(_isExcluded[_marketAddress]){
                _tOwned[_marketAddress] = _tOwned[_marketAddress].add(surplus);
                _rOwned[_marketAddress] = _rOwned[_marketAddress].add(surplus.mul(currentRate));
            }else{
                _rOwned[_marketAddress] = _rOwned[_marketAddress].add(surplus.mul(currentRate));
            }

            emit Transfer(send, _marketAddress, tInviter.sub(hasSend));

        }

    }

    function _takeMarket(address sender, uint256 tMarket, uint256 rMarket) private {
        if(tMarket > 0){

            if(_isExcluded[_marketAddress]){
                _tOwned[_marketAddress] = _tOwned[_marketAddress].add(tMarket);
                _rOwned[_marketAddress] = _rOwned[_marketAddress].add(rMarket);
            }else{
                _rOwned[_marketAddress] = _rOwned[_marketAddress].add(rMarket);
            }

            emit Transfer(sender, _marketAddress, tMarket);
        }
    }

    function _takeBurn(address sender, uint256 tBurn, uint256 rBurn) private {
        if(tBurn > 0){

            if(_isExcluded[_burnAddress]){
                _tOwned[_burnAddress] = _tOwned[_burnAddress].add(tBurn);
                _rOwned[_burnAddress] = _rOwned[_burnAddress].add(rBurn);
            }else{
                _rOwned[_burnAddress] = _rOwned[_burnAddress].add(rBurn);
            }

            emit Transfer(sender, _burnAddress, tBurn);
        }
    }

    struct txData {
        uint256 tAmount;
        uint256 tTransferAmount;
        uint256 tFee;
        uint256 tLiquidity;
        uint256 tInviter;
        uint256 tMarket;
        uint256 tBurn;

        uint256 rAmount;
        uint256 rTransferAmount;
        uint256 rFee;
        uint256 rLiquidity;
        uint256 rInviter;
        uint256 rMarket;
        uint256 rBurn;
    }

    struct txTData {
        uint256 tAmount;
        uint256 tTransferAmount;
        uint256 tFee;
        uint256 tLiquidity;
        uint256 tInviter;
        uint256 tMarket;
        uint256 tBurn;
    }

    struct txRData {
        uint256 rAmount;
        uint256 rTransferAmount;
        uint256 rFee;
        uint256 rLiquidity;
        uint256 rInviter;
        uint256 rMarket;
        uint256 rBurn;
    }

    function _getValues(uint256 tAmount) private view returns (txData memory) {

        uint256 currentRate = _getRate();

        txTData memory tdata = _getTValues(tAmount);
        txRData memory rdata = _getRValues(tAmount, tdata, currentRate);

        txData memory txdata = txData(
            tdata.tAmount,
            tdata.tTransferAmount,
            tdata.tFee,
            tdata.tLiquidity,
            tdata.tInviter,
            tdata.tMarket,
            tdata.tBurn,

            rdata.rAmount,
            rdata.rTransferAmount,
            rdata.rFee,
            rdata.rLiquidity,
            rdata.rInviter,
            rdata.rMarket,
            rdata.rBurn
        );

        return txdata;
    }

    function _getTValues(uint256 tAmount) private view returns (txTData memory) {

        txTData memory tdata = txTData(
            tAmount,
            0,
            calculateTaxFee(tAmount),
            calculateLiquidity(tAmount),
            calculateInviter(tAmount),
            calculateMarket(tAmount),
            calculateBurn(tAmount)
        );
        tdata.tTransferAmount = tAmount.sub(tdata.tFee).sub(tdata.tLiquidity).sub(tdata.tInviter).sub(tdata.tMarket).sub(tdata.tBurn);

        return tdata;
    }

    function _getRValues(uint256 tAmount, txTData memory tdata, uint256 currentRate) private pure returns (txRData memory) {

        uint256 rAmount = tAmount.mul(currentRate);

        txRData memory rdata = txRData(
            tAmount.mul(currentRate),
            0,
            tdata.tFee.mul(currentRate),
            tdata.tLiquidity.mul(currentRate),
            tdata.tInviter.mul(currentRate),
            tdata.tMarket.mul(currentRate),
            tdata.tBurn.mul(currentRate)
        );
        rdata.rTransferAmount = rAmount.sub(rdata.rFee).sub(rdata.rLiquidity).sub(rdata.rInviter).sub(rdata.rMarket).sub(rdata.rBurn);

        return rdata;
    }

    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxFee).div(
            10**2
        );
    }

    function calculateLiquidity(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_liquidityFee).div(
            10**2
        );
    }

    function calculateInviter(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_inviterFee).div(
            10**2
        );
    }

    function calculateMarket(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_marketFee).div(
            10**2
        );
    }

    function calculateBurn(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_burnFee).div(
            10**2
        );
    }

    function _getROwned(address account) public view returns(uint256) {
        return _rOwned[account];
    }

    function _getTTotal() public view returns(uint256) {
        return _tTotal;
    }

    function _getRTotal() public view returns(uint256) {
        return _rTotal;
    }

    function _getRate() public view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() public view returns(uint256, uint256) {
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

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        // split the contract balance into halves
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);

        // capture the contract's current BNB balance.
        // this is so that we can capture exactly the amount of BNB that the
        // swap creates, and not make the liquidity event include any BNB that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for BNB
        swapTokensForBnb(half);

        // how much BNB did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForBnb(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> wbnb
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of BNB
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: bnbAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
    }

    function getParentList(address owner, uint num) public view returns(address[] memory fathers){
        fathers = new address[](num);
        address parent = owner;
        for( uint i = 0; i < num; i++){
            parent = _inviterList[parent];
            if( parent == address(0) ){
                break;
            }
            fathers[i] = parent;
        }
    }

    function getParent(address from) public view returns(address) {
        return _inviterList[from];
    }

    function addParent(address from, address to) private {
        if(balanceOf(to) == 0 && _inviterList[to] == address(0)){
            _inviterList[to] = from;
        }
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function addBlack(address account) public onlyOwner {
        _isBlackList[account] = true;
        _blackList.push(account);
    }

    function delBlack(address account) public onlyOwner {
        _isBlackList[account] = false;
        for (uint256 i = 0; i < _blackList.length; i++) {
            if (_blackList[i] == account) {
                _blackList[i] = _blackList[_blackList.length - 1];
                _blackList.pop();
                break;
            }
        }
    }

    function getBlack() public view onlyOwner returns(address[] memory) {
        return _blackList;
    }

    function setTaxFee(uint256 newFee) public onlyOwner {
        _previousTaxFee = newFee;
    }

    function setLiquidityFee(uint256 newFee) public onlyOwner {
        _previousLiquidityFee = newFee;
    }

    function setInviterFee(uint256 newFee) public onlyOwner {
        _previousInviterFee = newFee;
    }

    function setInviterConfig(uint[] memory newConfig) public onlyOwner {
        _inviterConfig = newConfig;
    }

    function setMarketFee(uint256 newFee) public onlyOwner {
        _previousMarketFee = newFee;
    }

    function setMarketAddress(address newAddress) public onlyOwner {
        _marketAddress = newAddress;
    }

    function setBurnFee(uint256 newFee) public onlyOwner {
        _previousBurnFee = newFee;
    }

    function setBurnAddress(address newAddress) public onlyOwner {
        _burnAddress = newAddress;
    }

    function setMinTxAmount(uint256 amount) public onlyOwner {
        _minTxAmount = amount * 10**_decimals;
    }

    function setMaxTxAmount(uint256 amount) public onlyOwner {
        _maxTxAmount = amount * 10**_decimals;
    }

    function setMinLiquidity(uint256 amount) public onlyOwner {
        _numTokensSellToAddToLiquidity = amount * 10**_decimals;
    }

    function setInSwapAndLiquify(bool lock) public onlyOwner {
        inSwapAndLiquify = lock;
    }

    function resetPool(uint second) public onlyOwner {
        _isPool = false;
        _poolTime = 0;
        _poolSecond = second;
    }

}