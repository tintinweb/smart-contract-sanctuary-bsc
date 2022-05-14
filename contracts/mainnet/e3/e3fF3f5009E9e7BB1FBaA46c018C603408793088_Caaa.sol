/**
 *Submitted for verification at BscScan.com on 2022-05-14
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;


/**
 * @dev Interface of the BEP standard.
 */
interface IBEP20 {
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external view returns (uint8);

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external view returns (string memory);

  /**
  * @dev Returns the token name.
  */
  function name() external view returns (string memory);

  /**
   * @dev Returns the bep token owner.
   */
  function getOwner() external view returns (address);

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
  function allowance(address _owner, address spender) external view returns (uint256);

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

  
    //function minusGhostToken(uint256 amount) external view returns (bool);
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


// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
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
        return a + b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
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
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
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
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
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
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}



abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


abstract contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        _previousOwner = _owner;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    
    function geUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }

    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime , "Contract is locked until 0 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}


interface IPancakeswapV2Router01 {
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




interface IPancakeswapV2Router02 is IPancakeswapV2Router01 {
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


interface IPancakeswapV2Factory {
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
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint); 
}



contract Caaa is Context, IBEP20, Ownable {
    using SafeMath for uint256;
    
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFee;
    address[] public shareholders;
    
    uint256 private _tTotal = 260 * 10**5 * 10**18;
    uint256 private finalTotalToken = 26 * 10**5 * 10**18;
    string private _name = "Caaa";
    string private _symbol = "Caaa";
    uint8 private _decimals = 18;
    
    uint256 public _buyFee = 8;
    uint256 public _saleFee = 10;
    uint256 public _transferFee =10;
    uint256 public _cancelFee =5;

    uint256 public _backFee = 40;//回流
    uint256 public _burnFee = 30;
    uint256 public _lpShareFee = 30;//分红cdao
    uint256 public _oneBnbToCdao=559000000000000;//18位小数多少个bnb可兑换多少1个Cdao

    address public backAddress;
    address private _destroyAddress = address(0); // 通缩销毁的黑洞地址
    address public addressCdao;

    IPancakeswapV2Router02 public pancakeswapV2Router;
    address public pancakeswapV2Pair;
    TokenDividendTracker public dividendTracker;

    address public pancakeswapV2PairCdao;
    address public pancakeswapV2RouterCdao;

    address private fromAddress;
    address private toAddress;
    mapping (address => bool) isDividendExempt;
    uint256 distributorGas = 200000;

    bool inShareNow;
    bool public addLiquifyEnabled = false;
    bool public autoSwapBonusEnabled = false;
    
    uint256 public _maxTxAmount =  2 * 10**5 * 10**18;
    uint256 public numTokensToSwap =  3 * 10**3 * 10**18;
    uint256 public swapCoolDownTime = 20;
    uint256 private lastSwapTime;

    event ExcludedFromFee(address account);
    event IncludedToFee(address account);
   
    event UpdatedMaxTxAmount(uint256 maxTxAmount);
    event UpdateNumtokensToSwap(uint256 amount);
    modifier lockTheSwap {
        inShareNow = true;
        _;
        inShareNow = false;
    }

    constructor () {
       IPancakeswapV2Router02 _pancakeswapV2Router = IPancakeswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        
        pancakeswapV2Pair = IPancakeswapV2Factory(_pancakeswapV2Router.factory())
            .createPair(address(this), _pancakeswapV2Router.WETH());
        pancakeswapV2Router = _pancakeswapV2Router;
        
        //exclude owner and this contract from fee
        _isExcludedFromFee[_msgSender()] = true;
        _isExcludedFromFee[address(this)] = true;
        _balances[_msgSender()] = _tTotal;

       
        dividendTracker = new TokenDividendTracker(pancakeswapV2Pair);

        isDividendExempt[address(this)] = true;
        isDividendExempt[address(0)] = true;
        isDividendExempt[address(dividendTracker)] = true;

        emit Transfer(address(0), owner(), _tTotal);
    }
    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function name() external view override returns (string memory) {
        return _name;
    }
    
    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() external view override returns (uint256) {
        return _tTotal;
    }
    
    function getOwner() external view override returns (address) {
        return owner();
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
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
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
        return true;
    }


    function excludeFromFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = true;
        emit ExcludedFromFee(account);
    }
    
    function includeInFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = false;
        emit IncludedToFee(account);
    }

    function setBackAddress(address _backAddress) external onlyOwner() {
        require(backAddress != _backAddress);
        backAddress = _backAddress;
    }

    function setOneBnbToCdao(uint256 oneBnbToCdao) external onlyOwner() {
        require(_oneBnbToCdao != oneBnbToCdao);
        _oneBnbToCdao = oneBnbToCdao;
    }

    function setAddressCdao(address _addressCdao) external onlyOwner() {
        require(addressCdao != _addressCdao);
        addressCdao = _addressCdao;
        dividendTracker.setLpRewardToken(addressCdao);
    }
   
    function setMaxTxAmount(uint256 maxTxAmount) external onlyOwner() {
        _maxTxAmount = maxTxAmount;
        emit UpdatedMaxTxAmount(maxTxAmount);
    }
    
    function setNumTokensToSwap(uint256 amount) external onlyOwner() {
        require(numTokensToSwap != amount);
        numTokensToSwap = amount;
        emit UpdateNumtokensToSwap(amount);
    }

    function setAddLiquifyEnabled(bool _addLiquifyEnabled) external onlyOwner() {
        require(addLiquifyEnabled != _addLiquifyEnabled);
        addLiquifyEnabled = _addLiquifyEnabled;
    }
   
    function setAutoSwapBonusEnabled(bool _autoSwapBonusEnabled) external onlyOwner() {
        require(autoSwapBonusEnabled != _autoSwapBonusEnabled);
        autoSwapBonusEnabled = _autoSwapBonusEnabled;
    }

    function setPancakeswapV2PairCdao(address _pancakeswapV2PairCdao) external onlyOwner() {
        require(pancakeswapV2PairCdao != _pancakeswapV2PairCdao);
        pancakeswapV2PairCdao = _pancakeswapV2PairCdao;
    }
    function setPancakeswapV2RouterCdao(address _pancakeswapV2RouterCdao) external onlyOwner() {
        require(pancakeswapV2RouterCdao != _pancakeswapV2RouterCdao);
        pancakeswapV2RouterCdao = _pancakeswapV2RouterCdao;
    }

   
    

    function setDistributorGas(uint256 newValue) public onlyOwner {
        require(newValue >= 100000 && newValue <= 500000, "distributorGas must be between 200,000 and 500,000");
        require(newValue != distributorGas, "Cannot update distributorGas to same value");
        distributorGas = newValue;
    }
    function setCoolDownTime(uint256 timeForContract) external onlyOwner {
        require(swapCoolDownTime != timeForContract);
        swapCoolDownTime = timeForContract;
    }
    receive() external payable {}

    function isExcludedFromFee(address account) external view returns(bool) {
        return _isExcludedFromFee[account];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(from != to, "BEP20: Cant Transfer To Self");

        if(
            !_isExcludedFromFee[from] && 
            !_isExcludedFromFee[to] && 
            balanceOf(pancakeswapV2Pair) > 0 && 
            from != address(pancakeswapV2Router) && 
            (from == pancakeswapV2Pair || to == pancakeswapV2Pair)
        ) {
            require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");          
        }
        
        if(fromAddress == address(0) )fromAddress = from;
        if(toAddress == address(0) )toAddress = to;  
        if(!isDividendExempt[fromAddress] && fromAddress != pancakeswapV2Pair )   try dividendTracker.setShare(fromAddress) {} catch {}
        if(!isDividendExempt[toAddress] && toAddress != pancakeswapV2Pair ) try dividendTracker.setShare(toAddress) {} catch {}
        fromAddress = from;
        toAddress = to; 

        uint256 tokenBalance = balanceOf(address(this));
        bool overMinTokenBalance = tokenBalance >= numTokensToSwap;
        if (
            overMinTokenBalance &&
            !inShareNow &&
            addLiquifyEnabled &&
            from != pancakeswapV2Pair &&
            from != address(pancakeswapV2Router) &&
            block.timestamp >= lastSwapTime + swapCoolDownTime
        ) {
            doShareBonusCdao(tokenBalance);
            lastSwapTime = block.timestamp;
        }
       
        if(from == pancakeswapV2Pair && to != address(pancakeswapV2Router)){
            if(addLiquifyEnabled==true){
                if(_isExcludedFromFee[to]){
                    _tokenTransfer(from, to, amount, 0);
                }else{
                    _tokenTransfer(from, to, amount, _buyFee);
                }
            }else{
                require(_isExcludedFromFee[to] == true); 
                _tokenTransfer(from, to, amount, 0);
            }
        }else if(to != pancakeswapV2Pair && from != pancakeswapV2Pair && from != address(pancakeswapV2Router) && to != address(pancakeswapV2Router)){
            if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
                _tokenTransfer(from, to, amount, 0);
            }else{
                _tokenTransfer(from, to, amount, _transferFee);
            }
        }else if(from == pancakeswapV2Pair && to == address(pancakeswapV2Router)){
             _tokenTransfer(from, to, amount, 0);
        }else if(from == address(pancakeswapV2Router) && to != pancakeswapV2Pair){
            if(addLiquifyEnabled==true){
                if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
                    _tokenTransfer(from, to, amount, 0);
                }else{
                    _tokenTransfer(from, to, amount, _cancelFee);
                }
            }else{
                require(_isExcludedFromFee[to] == true); 
                _tokenTransfer(from, to, amount, 0);
            }
        }else{
            if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
                _tokenTransfer(from, to, amount, 0);
            }else{
                _tokenTransfer(from, to, amount, _saleFee);
            }
        }
    }

    function dealWithShareBonus(uint256 tokenBalance) private   {
        uint256 leftBouns=tokenBalance;

        if(_tTotal>finalTotalToken){
            uint256 burnBonus = tokenBalance.mul(_burnFee).div(100);
            if(burnBonus>0){
                uint256 _leftTotal = _tTotal-burnBonus;
                if(_leftTotal<finalTotalToken){
                    burnBonus = _tTotal-finalTotalToken;
                }
                if(burnBonus>0){
                    _balances[_destroyAddress]=_balances[_destroyAddress].add(burnBonus);
                    _tTotal=_tTotal.sub(burnBonus);
                }
                leftBouns=tokenBalance.sub(burnBonus);
            }
        }

        uint256 shareBonusNum = tokenBalance.mul(_lpShareFee).div(100);
        if(shareBonusNum>0){
            _balances[address(this)] = _balances[address(this)].add(shareBonusNum);
            leftBouns=leftBouns.sub(shareBonusNum);
        }
        
        if(leftBouns>0 && backAddress!=address(0)){
             _balances[backAddress] = _balances[backAddress].add(leftBouns);   
        } 
    }

    function doShareBonusCdao(uint256 shareBonus) private lockTheSwap {
        swapTokensForEth(shareBonus);
        uint256 newBalance = address(this).balance;
        uint256 doCdaoNum=0;
        if(autoSwapBonusEnabled==true && pancakeswapV2PairCdao!=address(0)){
            doCdaoNum = getDoCdaoNumBack(newBalance);
        }else{
            doCdaoNum = newBalance.mul(10**18).div(_oneBnbToCdao);
        }
        if(doCdaoNum>0){
            try dividendTracker.process(distributorGas,doCdaoNum) {
                 (bool success, ) = payable(backAddress).call{value: address(this).balance}("");
                  require(success == true, "Transfer failed.");
            } catch {} 
        }
    }

    function getDoCdaoNumBack(uint256 amountIn) private view returns(uint256 doCdaoNum) {
        (uint112 reserve0, uint112 reserve1,) =IUniswapV2Pair(pancakeswapV2PairCdao).getReserves();
        doCdaoNum = IPancakeswapV2Router01(pancakeswapV2RouterCdao).getAmountOut(amountIn, reserve1, reserve0);
    }
    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the pancakeswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pancakeswapV2Router.WETH();
        _approve(address(this), address(pancakeswapV2Router), tokenAmount);
        // make the swap
        pancakeswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount, uint256 takeFee) private {
        uint256 tTransferAmount = amount;
        if(takeFee>0){
            tTransferAmount = _getFeeValues(amount,takeFee);
        }
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(tTransferAmount);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _getFeeValues(uint256 tAmount,uint256 takeFee) private  returns (uint256) {
        uint256 fee = tAmount.mul(takeFee).div(10**2);
        uint256 tTransferAmount = tAmount.sub(fee);
        if(fee>0){
            dealWithShareBonus(fee);
        }
        return tTransferAmount;
    }
}

contract TokenDividendTracker is Ownable {
    using SafeMath for uint256;

    address[] public shareholders;
    uint256 public currentIndex;  
    mapping(address => bool) private _updated;
    mapping (address => uint256) public shareholderIndexes;

    address public  uniswapV2Pair;
    address public lpRewardToken;


    constructor(address uniswapV2Pair_){
        uniswapV2Pair = uniswapV2Pair_;
    }

    function setLpRewardToken(address lpRewardToken_) public onlyOwner {
        require(lpRewardToken!=lpRewardToken_);
        lpRewardToken = lpRewardToken_;
    }

    // LP分红发放
    function process(uint256 gas,uint256 doCdaoNum) external onlyOwner {
        uint256 shareholderCount = shareholders.length;	

        if(shareholderCount == 0) return;
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
                return;
            }

            uint256 amountUser = IBEP20(uniswapV2Pair).balanceOf(shareholders[currentIndex]);
            if(amountUser<=0){
                currentIndex++;
                iterations++;
                gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
                continue;
            }
            uint256 amount = doCdaoNum.mul(amountUser).div(IBEP20(uniswapV2Pair).totalSupply());
            if( amount == 0) {
                currentIndex++;
                iterations++;
                gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
                continue;
            }
            if(IBEP20(lpRewardToken).balanceOf(address(this))  < amount ) return;
            IBEP20(lpRewardToken).transfer(shareholders[currentIndex], amount);
            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }
    // 根据条件自动将交易账户加入、退出流动性分红
    function setShare(address shareholder) external onlyOwner {
        if(_updated[shareholder] ){      
            if(IBEP20(uniswapV2Pair).balanceOf(shareholder) == 0) quitShare(shareholder);           
            return;  
        }
        if(IBEP20(uniswapV2Pair).balanceOf(shareholder) == 0) return;  
        addShareholder(shareholder);	
        _updated[shareholder] = true;
          
      }
    function quitShare(address shareholder) internal {
        removeShareholder(shareholder);   
        _updated[shareholder] = false; 
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }
    
}