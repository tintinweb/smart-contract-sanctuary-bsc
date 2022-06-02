/**
 *Submitted for verification at BscScan.com on 2022-06-02
*/

// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.8.0 <0.9.0;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
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
 * @title SafeMathInt
 * @dev Math operations for int256 with overflow safety checks.
 */
library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    /**
     * @dev Multiplies two int256 variables and fails on overflow.
     */
    function mul(int256 a, int256 b) internal pure returns (int256)
    {
        int256 c = a * b;

        
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    /**
     * @dev Division of two int256 variables and fails on overflow.
     */
    function div(int256 a, int256 b) internal pure returns (int256)
    {
        
        require(b != -1 || a != MIN_INT256);

        
        return a / b;
    }

    /**
     * @dev Subtracts two int256 variables and fails on overflow.
     */
    function sub(int256 a, int256 b) internal pure returns (int256)
    {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    /**
     * @dev Adds two int256 variables and fails on overflow.
     */
    function add(int256 a, int256 b) internal pure returns (int256)
    {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    /**
     * @dev Converts to absolute value, and fails on overflow.
     */
    function abs(int256 a) internal pure returns (int256)
    {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }
}









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
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}








abstract contract ERC20Detailed is Context, IERC20 {
    uint256 internal _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    mapping (address => uint256) internal _balances; 
    mapping (address => mapping (address => uint256)) internal _allowances;

    /**
     * @dev Sets the values for `name`, `symbol`, and `decimals`. All three of
     * these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory __name, string memory __symbol, uint8 __decimals) {
        _name = __name;
        _symbol = __symbol;
        _decimals = __decimals;        
        _totalSupply = 10**15 * 10**uint256(__decimals);
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
    
    /**
    * @dev See {IERC20-totalSupply}.
    */
    function totalSupply() public override view returns (uint256) {
        return _totalSupply;
    }
    
    /**
    * @dev See {IERC20-balanceOf}.
    */
    function balanceOf(address account) public override view returns (uint256) {
        return _balances[account];
    }
    
    /**
    * @dev See {IERC20-allowance}.
    */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    
    /**
    * @dev See {IERC20-approve}.
    *
    * Requirements:
    *
    * - `spender` cannot be the zero address.
    */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}








interface ILP {
    function sync() external;
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
    event Swap(address indexed sender, uint amount0In, uint amount1In, uint amount0Out, uint amount1Out, address indexed to);
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








interface IUniswapV2Router02 /*is IUniswapV2Router01*/ {

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
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address private _owner;
  address private _previousOwner;
  uint256 private _lockTime;

  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() {
    _owner = msg.sender;
  }

  /**
   * @return the address of the owner.
   */
  function owner() public view returns(address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(isOwner());
    _;
  }

  /**
   * @return true if `msg.sender` is the owner of the contract.
   */
  function isOwner() public view returns(bool) {
    return msg.sender == _owner;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(_owner);
    _owner = address(0);
  }

  function getUnlockTime() public view returns (uint256) {
    return _lockTime;
  }


  //Locks the contract for owner
  function lock() public onlyOwner {
    _previousOwner = _owner;
    _owner = address(0);
    emit OwnershipRenounced(_owner);

  }

  function unlock() public {
    require(_previousOwner == msg.sender, "You do not have permission to unlock");
    require(block.timestamp > _lockTime , "Contract is locked until 7 days");
    emit OwnershipTransferred(_owner, _previousOwner);
    _owner = _previousOwner;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}













contract ElonGlitch is ERC20Detailed, Ownable {
    using SafeMath for uint256;
    using SafeMathInt for int256;

    uint256 private constant DECIMALS = 9;
    bool private inDistributeTxnTax;
    
    mapping(address => bool) private _isExcludedFromTxnFees;
    mapping(address => bool) internal allowTransfer;
    mapping(address => bool) internal lpTokens;

    uint256 public buybackLimit = 10**18; 
    uint256 public buybackDivisor = 100;

    uint256 public numTokensSellDivisor = 1000;
    uint256 public transactionSellTax = 14; 
    uint256 public transactionBuyTax = 14; 
    
    bool public initialDistributionFinished;    
    bool public swapAndLiquifyEnabled = false;
    bool public buyBackEnabled = false;
    bool public topUpLpEnabled = false;

    
    address payable public marketingAddress;
    
    
    IUniswapV2Router02 public uniswapV2Router;
    IUniswapV2Pair public uniswapV2Pair;
    address public uniswapV2PairAddress;
    
    
    address public lp;
    ILP public lpContract;

    
    address public deadAddress = 0x000000000000000000000000000000000000dEaD;

    
    event LogTxnTaxChange(uint256 newTxnTax);
    event SwapEnabled(bool enabled);
    event DistributeTxnTax(uint256 toMarketing, uint256 toLp);

    
    modifier validRecipient(address to) {
        require(to != address(0x0));
        require(to != address(this));
        _;
    }
    
    modifier initialDistributionLock() {
        require(initialDistributionFinished || isOwner() || allowTransfer[msg.sender], "initialDistributionLock failed");
        _;
    }
    
    modifier lockTheSwap() {
        inDistributeTxnTax = true;
        _;
        inDistributeTxnTax = false;
    }

    
    constructor (address uniswapRouter, address payable _marketingAddress)
        payable
        ERC20Detailed("Elon Glitch", "ELG", uint8(DECIMALS))
    {
        marketingAddress = _marketingAddress;

        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(uniswapRouter);
        
        
        uniswapV2PairAddress = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        
        
        uniswapV2Router = _uniswapV2Router;
        
        
        setLP(uniswapV2PairAddress);
        
        IUniswapV2Pair _uniswapV2Pair = IUniswapV2Pair(uniswapV2PairAddress);
        uniswapV2Pair = _uniswapV2Pair;
                
        
        _balances[msg.sender] = _totalSupply;

        _isExcludedFromTxnFees[owner()] = true;
        _isExcludedFromTxnFees[address(this)] = true;
        _isExcludedFromTxnFees[address(marketingAddress)] = true;

        emit Transfer(address(0x0), msg.sender, _totalSupply);
    }

    function setLP(address _lp) public onlyOwner
    {
        lp = _lp;
        lpContract = ILP(_lp);
        lpTokens[_lp] = true;
    }
    
    function transfer(address recipient, uint256 amount) external override
        validRecipient(recipient)
        initialDistributionLock
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) external override
        validRecipient(recipient) 
        returns (bool) 
    {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    
    
    
    
    
    function _transfer(address from, address to, uint256 value) private validRecipient(to) initialDistributionLock returns (bool) 
    {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(value > 0, "Calculated value is zero.");

        uint256 _maxTxAmount = _totalSupply.div(10);
        if (from != owner() && to != owner()) {
            require(value <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
        }

        
        uint256 contractTokenBalance = balanceOf(address(this));
        uint256 numTokensSell = _totalSupply.div(numTokensSellDivisor);

        //console.log("ContractTokenBalance %s : Token threshold %s", contractTokenBalance, numTokensSell);

        if (!inDistributeTxnTax && swapAndLiquifyEnabled && !lpTokens[from]) {

            //console.log("Attempting to convert tax %s", numTokensSell);

            if (contractTokenBalance >= numTokensSell) {
                distributeTxnTax(contractTokenBalance); 
            }

            
            uint256 balance = address(this).balance; 

            if (buyBackEnabled && balance > buybackLimit) {
                buyBackTokens(buybackLimit.div(buybackDivisor));
            }
        }

        
        _tokenTransfer(from, to, value);

        return true;
    }
    
    function _tokenTransfer(address sender, address recipient, uint256 amount) private 
    {
        if (_isExcludedFromTxnFees[sender] || _isExcludedFromTxnFees[recipient]) {
            _transferWithoutTxnFee(sender, recipient, amount);
        }
        else {
            _transferWithTxnFee(sender, recipient, amount);
        }
    }
    
    function _transferWithoutTxnFee(address sender, address recipient, uint256 amount) private 
    {
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        
        emit Transfer(sender, recipient, amount);
    }
    
    function _transferWithTxnFee(address sender, address recipient, uint256 amount) private 
    {
        bool isBuyFromLp = lpTokens[sender];        
        
        (uint256 txnTransferAmount, uint256 txnFee) = _getTxnValues(amount, isBuyFromLp);
        
        
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");

        
        _balances[recipient] = _balances[recipient].add(txnTransferAmount);

        
        _takeFee(txnFee);

        emit Transfer(sender, recipient, amount);
    }
    
    
    function _getTxnValues(uint256 txnAmount, bool isBuyFromLp) private view returns (uint256, uint256) {
        uint256 txnFee = calculateFee(txnAmount, isBuyFromLp);
        uint256 txnTransferAmount = txnAmount.sub(txnFee);
        return (txnTransferAmount, txnFee);
    }
    
    function calculateFee(uint256 _amount, bool isBuyFromLp) private view returns (uint256) {
        if(isBuyFromLp) {
            return _amount.mul(transactionBuyTax).div(100);
        }
        else {
            return _amount.mul(transactionSellTax).div(100);
        }
    }
    
    function setInitialDistributionFinished() external onlyOwner {
        initialDistributionFinished = true;
    }
    
    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapEnabled(_enabled);
    }
    
    
    function distributeTxnTax(uint256 contractTokenBalance) private lockTheSwap {        
        
        
        
        
        uint256 initialBalance = address(this).balance;

        if(topUpLpEnabled)
        {
            uint256 fourFifths = contractTokenBalance.mul(4).div(5); 
            uint256 oneFifth = contractTokenBalance.sub(fourFifths); 

            swapTokensForEth(fourFifths); 

            
            uint256 newBalance = address(this).balance.sub(initialBalance);
            uint256 lpETH = newBalance.div(4);

            
            addLiquidity(oneFifth, lpETH);

            uint256 marketingETH = newBalance.sub(lpETH);

            
            transferToAddressETH(marketingAddress, marketingETH);

            emit DistributeTxnTax(marketingETH, lpETH);
        }
        else 
        {
            swapTokensForEth(contractTokenBalance);

            
            uint256 newBalance = address(this).balance.sub(initialBalance);

            
            transferToAddressETH(marketingAddress, newBalance);

            emit DistributeTxnTax(newBalance, 0);
        }
    }
    
    function buyBackTokens(uint256 amount) private lockTheSwap {
        if (amount > 0) {
            swapETHForTokens(amount);
        }
    }

    
    fallback() external payable {}
    receive() external payable {}
    
    function swapTokensForEth(uint256 tokenAmount) private {
        //console.log("Attempting to swap %s tokens for ETH", tokenAmount);

        
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            address(this),
            block.timestamp.add(300)
        );
    }
    
    function swapETHForTokens(uint256 amount) private {
        
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = address(this);

        
        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}
        (
            0, 
            path,
            deadAddress, 
            block.timestamp.add(300)
        );
    }
    
    function _takeFee(uint256 tFee) private {
        _balances[address(this)] = _balances[address(this)].add(tFee);
    }
    
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        
        uniswapV2Router.addLiquidityETH{value:ethAmount}(
            address(this),
            tokenAmount,
            0, 
            0, 
            address(this),
            block.timestamp.add(300)
        );
    }
    
    function transferToAddressETH(address payable recipient, uint256 amount) private {
        recipient.transfer(amount);
    }
    
    function enableTransfer(address _addr) external onlyOwner {
        allowTransfer[_addr] = true;
    }
    
    function addLpToken(address _addr) external onlyOwner {
        lpTokens[_addr] = true;
    }

    
    function setnumTokensSellDivisor(uint256 _numTokensSellDivisor) public onlyOwner
    {
        numTokensSellDivisor = _numTokensSellDivisor;
    }
    
    function airDrop(address[] calldata recipients, uint256[] calldata values) external onlyOwner
    {
        for (uint256 i = 0; i < recipients.length; i++) {
            _tokenTransfer(msg.sender, recipients[i], values[i]);
        }
    }
    
    function burnAutoLP() external onlyOwner {
        uint256 balance = uniswapV2Pair.balanceOf(address(this));
        uniswapV2Pair.transfer(owner(), balance);
    }
    
    function excludeAddress(address _addr) external onlyOwner {
        _isExcludedFromTxnFees[_addr] = true;
    }

    function burnBNB(address payable burnAddress) external onlyOwner {
        burnAddress.transfer(address(this).balance);
    }

    function setBuyBackEnabled(bool _enabled) public onlyOwner {
        buyBackEnabled = _enabled;
    }

    function setBuyBackLimit(uint256 _buybackLimit) public onlyOwner {
        buybackLimit = _buybackLimit;
    }

    function setBuyBackDivisor(uint256 _buybackDivisor) public onlyOwner {
        buybackDivisor = _buybackDivisor;
    }

    function manualSync() external {
        lpContract.sync();
    }

    function setTopUpLpEnabled(bool _enabled) external onlyOwner 
    {
        topUpLpEnabled = _enabled;
    }

    function setTransactionSellTax(uint256 _transactionSellTax) public onlyOwner
    {
        require(_transactionSellTax <= 15, "Tax must be less than 15%");
        transactionSellTax = _transactionSellTax;
    }

    function setTransactionBuyTax(uint256 _transactionBuyTax) public onlyOwner
    {
        require(_transactionBuyTax <= 15, "Tax must be less than 15%");
        transactionBuyTax = _transactionBuyTax;
    }
    
    
    
    
    
    function increaseAllowance(address spender, uint256 addedValue) public initialDistributionLock returns (bool)
    {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    
    
    
    function decreaseAllowance(address spender, uint256 subtractedValue) external initialDistributionLock returns (bool)
    {
        uint256 oldValue = _allowances[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            _allowances[msg.sender][spender] = 0;
        } 
        else {
            _allowances[msg.sender][spender] = oldValue.sub(subtractedValue);
        }

        emit Approval(msg.sender, spender, _allowances[msg.sender][spender]);
        return true;
    }
}