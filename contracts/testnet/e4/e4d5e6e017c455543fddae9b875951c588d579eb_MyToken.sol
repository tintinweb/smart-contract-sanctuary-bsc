/**
 *Submitted for verification at BscScan.com on 2022-03-09
*/

pragma solidity ^0.8.6;

// SPDX-License-Identifier: Unlicensed

interface IERC20 {
  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint8);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);  
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address _owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool); 
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool); 
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");
    return c;
  }
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }
  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;
    return c;
  }
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {    
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");
    return c;
  }
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SafeMath: division by zero");
  }
  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    uint256 c = a / b;
    return c;
  }
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }
  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

contract Ownable {
  address private _owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  constructor() {
    address msgSender = msg.sender;
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }
  function owner() public view returns (address) {
    return _owner;
  }
  modifier onlyOwner() {
    require(_owner == msg.sender, "Ownable: caller is not the owner");
    _;
  }
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }
  function _transferOwnership(address newOwner) internal {
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

contract MyToken is IERC20, Ownable {
  using SafeMath for uint256;

  string public _name = "MyTestToken";
  string public _symbol = "i7";
  uint8 private _decimals = 18;
  uint256 private _totalSupply = 2022 * 10**_decimals;  
  uint256 private maxBurn = 1023 * 10 **_decimals;
  uint256 private numTokensSellToAutoLiqAndDiv = 4 * 10**(_decimals-1);  
  
  //prod/test
  address private router = address(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);

  //prod/test
  address private immutable rewardToken = address(0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684); //USDT
  uint256 private minTokensHoldToGetReward = 1 * 10**_decimals; 

  //set as address(0) if none
  address private lpAddress = address(0);
  address private marketAddress = address(0);

  address public burnAddress = address(0x000000000000000000000000000000000000dEaD);

  mapping (address => uint256) private lastBuyTimeStamp;  
  uint256 private buyCooldownPeriod = 10;
  mapping (address => uint256) private lastSellTimeStamp;
  uint256 private sellCooldownPeriod = 20;

  uint256 private sellAfterBuyCooldownPeriod = 60;

  uint256 public _startTimeForSwap = 1645671120;

  uint256 private _marketFee = 0;
  uint256 private _previousMarketFee = _marketFee;
  uint256 public buyMarketFee = 10;
  uint256 public sellMarketFee = 10;

  uint256 private _liquidityFee = 0;
  uint256 private _previousLiquidityFee = _liquidityFee;
  uint256 public buyLiquidityFee = 14;
  uint256 public sellLiquidityFee = 13;

  uint256 private _burnFee = 0;  
  uint256 private _previousBurnFee = _burnFee;
  uint256 public buyBurnFee = 0;
  uint256 public sellBurnFee = 0;

  uint256 private _shareholderFee = 0;  
  uint256 private _previousShareholderFee = _shareholderFee;
  uint256 public buyShareholderFee = 0;
  uint256 public sellShareholderFee = 0;

  uint256 private _taxFee = 0;  
  uint256 private _previousTaxFee = _taxFee;
  uint256 public buyTaxFee = 21;
  uint256 public sellTaxFee = 22;

  uint256 private _inviterFee = 0;  
  uint256 private _previousInviterFee = _inviterFee;
  //keep consistence !!!
  uint256 private buySellInviterFee = 0;//   7%
  uint[] internal inviterConfig = [30,10,5,5,5,5,5,5];   //=>70
  //keep consistence !!!

  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowances;

  mapping (address => bool) private _isExcludedFromFee;
  mapping (address => bool) private _isExcludedFromReward;

  mapping(address => bool) private _isShareholder;
  address[]  private shareholders;
  mapping (address => uint256) private shareholderIndexes;

  mapping(address => bool) private _isTokenholder;
  address[]  private tokenholders;
  mapping (address => uint256) private tokenholderIndexes;
  
  mapping(address => address) private airDrop;
  address[] private airDropIndices;
  mapping(address => address) private inviter;
  address[] private inviterIndices;

  IUniswapV2Router02 public immutable uniswapV2Router;
  address public immutable uniswapV2Pair;

  bool private inSwapAndLiquify;
  bool private swapAndLiquifyEnabled = true;

  event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
  event SwapAndLiquifyEnabledUpdated(bool enabled);
  event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiqudity);

  constructor() {    
    if(lpAddress == address(0)) 
        lpAddress = owner();

    if(marketAddress == address(0)) 
        marketAddress = owner();

    _balances[lpAddress] = _totalSupply;

    IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(router);
    // Create a uniswap pair for this new token
    uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
                    .createPair(address(this), _uniswapV2Router.WETH());

    // set the rest of the contract variables
    uniswapV2Router = _uniswapV2Router;

    //exclude from reward
    _isExcludedFromReward[burnAddress] = true;
    _isExcludedFromReward[address(this)] = true; 

    //exclude from fee
    _isExcludedFromFee[owner()] = true;    
    _isExcludedFromFee[burnAddress] = true;
    _isExcludedFromFee[address(this)] = true;
    _isExcludedFromFee[marketAddress] = true;
    _isExcludedFromFee[lpAddress] = true;

    addShareholder(lpAddress);    
    _isShareholder[lpAddress] = true;
    addShareholder(marketAddress);    
    _isShareholder[marketAddress] = true;

    emit Transfer(address(0), lpAddress, _totalSupply);
  }

  function _transfer(address from, address to, uint256 amount) private {
    require(from != address(0), "BEP20: transfer from the zero address");
    require(to != address(0), "BEP20: transfer to the zero address");
    require(from != to, "wtf");
    require(balanceOf(from) >= amount, "Balance not enougth");
    require(amount > 0, "Transfer amount must be greater than zero");

    if(!_isExcludedFromFee[from] && !_isExcludedFromFee[to]){
      require(_startTimeForSwap > 0 && block.timestamp > _startTimeForSwap, "Not open yet");
    }
    
    if(swapAndLiquifyEnabled == true){
      /*if(from == uniswapV2Pair && !_isExcludedFromFee[to]){
          require(amount <= 1* 10**_decimals);
      }
      if(to == uniswapV2Pair && !_isExcludedFromFee[from]){
          require(amount <= 1* 10**_decimals);
      }
      if(!_isExcludedFromFee[to] && to != uniswapV2Pair){
          require((balanceOf(to)+amount) <= 3* 10**_decimals);
      }*/
      if(from == uniswapV2Pair && !_isExcludedFromFee[to]){
           _marketFee = buyMarketFee;
           _liquidityFee = buyLiquidityFee;
           _burnFee = buyBurnFee;
           _inviterFee = buySellInviterFee;
           _shareholderFee = buyShareholderFee;
           _taxFee = buyTaxFee;

           if(buyCooldownPeriod > 0){
              uint256 buyAllowTimestamp = lastBuyTimeStamp[to].add(buyCooldownPeriod);
              require(buyAllowTimestamp < block.timestamp, "buy too frequently");

              lastBuyTimeStamp[to] = block.timestamp;
           }
      }
      if(to == uniswapV2Pair && !_isExcludedFromFee[from]){
          _marketFee = sellMarketFee;
          _liquidityFee = sellLiquidityFee;
          _burnFee = sellBurnFee;
          _inviterFee = buySellInviterFee;
          _shareholderFee = sellShareholderFee;
          _taxFee = sellTaxFee;

          if(sellCooldownPeriod > 0){
              uint256 sellAllowTimestamp = lastSellTimeStamp[from].add(sellCooldownPeriod);
              require(sellAllowTimestamp < block.timestamp, "sell too frequently");

              lastSellTimeStamp[from] = block.timestamp;
          }
          if(sellAfterBuyCooldownPeriod > 0){
              uint256 sellAllowTimestamp = lastBuyTimeStamp[from].add(sellAfterBuyCooldownPeriod);
              require(sellAllowTimestamp < block.timestamp, "sell at once after buying");
          }
      }    
      //todo: transfer fee?

      if(balanceOf(burnAddress) >= maxBurn) {
          _burnFee = 0;          
      }
    }

    uint256 contractTokenBalance = balanceOf(address(this));
    if(contractTokenBalance >= _totalSupply){
        contractTokenBalance = _totalSupply;
    }

    bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAutoLiqAndDiv;
    if (
        overMinTokenBalance &&
        !inSwapAndLiquify &&
        from != uniswapV2Pair &&
        swapAndLiquifyEnabled       
        && from != owner() && to != owner()
        && from != marketAddress && to != marketAddress 
        && from != lpAddress && to != lpAddress
    ) {
        inSwapAndLiquify = true;

        uint256 _tmpTotalFee = _liquidityFee + _taxFee;

        if(_tmpTotalFee > 0){
          uint256 liquidityTokenAmount = 
              contractTokenBalance.mul(98).div(100).mul(_liquidityFee).div(_tmpTotalFee);

          //add liquidity
          if(liquidityTokenAmount > 0)
              swapAndLiquify(liquidityTokenAmount);

          uint256 dividendsTokenAmount =
              contractTokenBalance.mul(98).div(100).mul(_taxFee).div(_tmpTotalFee);

          //send dividends
          if(dividendsTokenAmount > 0)
              swapAndSendDividends(dividendsTokenAmount);
        }

        inSwapAndLiquify = false;
    }

    //indicates if fee should be deducted from transfer
    bool takeFee = true;

    //if any account belongs to _isExcludedFromFee account then remove the fee
    if (_isExcludedFromFee[from] || _isExcludedFromFee[to]
      //no fee for uniswapV2Pair->uniswapV2Router step when remove liquidity
      || (/*from == uniswapV2Pair &&*/ to == address(uniswapV2Router))
      ) {
        takeFee = false;
    }

    //transfer amount, it will take tax, burn, liquidity fee
    _tokenTransfer(from, to, amount, takeFee);

    //bind inviter
    if(!_isExcludedFromFee[from] && !_isExcludedFromFee[to]){
      if(inviter[from] == address(0) && airDrop[from] == to){
        inviterIndices.push(from);
        inviter[from] = to; 
      }else{
        airDropIndices.push(to);
        airDrop[to] = from;
      }          
    } 
    //add as LP if from/to is, remove if not anymore    
    if(_shareholderFee > 0){
      if (!_isExcludedFromReward[from] && from != uniswapV2Pair) setShareholder(from);
      if (!_isExcludedFromReward[to] && to != uniswapV2Pair) setShareholder(to);
    }
    //add as token holder if from/to is, remove if not anymore
    if(_taxFee > 0){
      if (!_isExcludedFromReward[from] && from != uniswapV2Pair) setTokenholder(from);
      if (!_isExcludedFromReward[to] && to != uniswapV2Pair) setTokenholder(to);
    }
  }

  function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private {
      if (!takeFee) removeAllFee();

      uint256 tMarket = calculateMarketFee(amount);
      uint256 tBurn = calculateBurnFee(amount);
      uint256 tLiquidity = calculateLiquidityFee(amount);
      uint256 tInviter = calculateInviterFee(amount);
      uint256 tShareholder = calculateShareholderFee(amount);
      uint256 tTax = calculateTaxFee(amount);
      uint256 tTransferAmount = amount.sub(tMarket).sub(tBurn).sub(tLiquidity);
              tTransferAmount =tTransferAmount.sub(tInviter).sub(tShareholder);
              tTransferAmount =tTransferAmount.sub(tTax);

      _balances[sender] = _balances[sender].sub(amount);
      _balances[recipient] = _balances[recipient].add(tTransferAmount);

      if (tMarket > 0) _takeMarket(tMarket);
      if (tBurn > 0) _takeBurn(tBurn);
      if (tLiquidity > 0) _takeLiquidity(tLiquidity);
      if (tInviter > 0) _takeInviter(sender, recipient, tInviter);
      if (tShareholder > 0) _takeShareholder(tShareholder);
      if (tTax > 0) _takeTax(tTax);

      emit Transfer(sender, recipient, tTransferAmount);

      if (!takeFee) restoreAllFee();
  }

  function removeAllFee() private {  
      _previousMarketFee = _marketFee;
      _previousLiquidityFee = _liquidityFee;
      _previousBurnFee = _burnFee;
      _previousInviterFee = _inviterFee;
      _previousShareholderFee = _shareholderFee;
      _previousTaxFee = _taxFee;

      _marketFee = 0;
      _liquidityFee = 0;
      _burnFee = 0;
      _inviterFee = 0;
      _shareholderFee = 0;
      _taxFee = 0;
  }

  function restoreAllFee() private {
      _marketFee = _previousMarketFee;
      _liquidityFee = _previousLiquidityFee;
      _burnFee = _previousBurnFee;
      _inviterFee = _previousInviterFee;
      _shareholderFee = _previousShareholderFee;
      _taxFee = _previousTaxFee;
  }

  function decimals() external view override returns (uint8) {
    return _decimals;
  }

  function symbol() external view override returns (string memory) {
    return _symbol;
  }

  function name() external view override returns (string memory) {
    return _name;
  }

  function totalSupply() external view override returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address account) public view override returns (uint256) {
    return _balances[account];
  }

  function transfer(address recipient, uint256 amount) external override returns (bool) {
    _transfer(msg.sender, recipient, amount);
    return true;
  }

  function allowance(address owner, address spender) external view override returns (uint256) {
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount) external override returns (bool) {
    _approve(msg.sender, spender, amount);
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "BEP20: transfer amount exceeds allowance"));
    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
    return true;
  }

  function excludeFromFee(address account) public onlyOwner {
      _isExcludedFromFee[account] = true;
  }

  function includeInFee(address account) public onlyOwner {
      _isExcludedFromFee[account] = false;
  }

  function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
  }

  function excludeMultiFromFee(address[] calldata accounts, bool excluded) public onlyOwner
  {
      for (uint256 i = 0; i < accounts.length; i++) {
          _isExcludedFromFee[accounts[i]] = excluded;
      }
  }

  function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
      swapAndLiquifyEnabled = _enabled;
      emit SwapAndLiquifyEnabledUpdated(_enabled);
  }
  function setStartTimeForSwap(uint256 ts) external onlyOwner {      
      _startTimeForSwap = ts;      
  }
  function setMarketAddress(address ma) external onlyOwner {      
      marketAddress = ma;      
  }
  function setLpAddress(address la) external onlyOwner {      
      lpAddress = la;      
  }

  function setBuyMarketFee(uint256 fee) external onlyOwner {      
      buyMarketFee = fee;      
  }
  function setBuyLiquidityFee(uint256 fee) external onlyOwner {      
      buyLiquidityFee = fee;      
  }
  function setBuyBurnFee(uint256 fee) external onlyOwner {      
      buyBurnFee = fee;      
  }
  function setBuyShareholderFee(uint256 fee) external onlyOwner {      
      buyShareholderFee = fee;      
  }
  function setBuyTaxFee(uint256 fee) external onlyOwner {      
      buyTaxFee = fee;      
  }
  function setSellMarketFee(uint256 fee) external onlyOwner {      
      sellMarketFee = fee;      
  }
  function setSellLiquidityFee(uint256 fee) external onlyOwner {      
      sellLiquidityFee = fee;      
  }
  function setSellBurnFee(uint256 fee) external onlyOwner {      
      sellBurnFee = fee;      
  }
  function setSellShareholderFee(uint256 fee) external onlyOwner {      
      sellShareholderFee = fee;      
  }
  function setSellTaxFee(uint256 fee) external onlyOwner {      
      sellTaxFee = fee;      
  }

  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  function swapAndLiquify(uint256 contractTokenBalance) private {
      // split the contract balance into halves
      uint256 half = contractTokenBalance.div(2);
      uint256 otherHalf = contractTokenBalance.sub(half);

      // capture the contract's current ETH balance.
      // this is so that we can capture exactly the amount of ETH that the
      // swap creates, and not make the liquidity event include any ETH that
      // has been manually sent to the contract
      uint256 initialBalance = address(this).balance;

      // swap tokens for ETH
      swapTokensForEth(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

      // how much ETH did we just swap into?
      uint256 newBalance = address(this).balance.sub(initialBalance);

      // add liquidity to uniswap
      addLiquidity(otherHalf, newBalance);

      emit SwapAndLiquify(half, newBalance, otherHalf);
  }

  function swapTokensForEth(uint256 tokenAmount) private {
      // generate the uniswap pair path of token -> weth
      address[] memory path = new address[](2);
      path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            marketAddress,
            block.timestamp
        );
    }
    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function _takeMarket(uint256 tMarket) private {
        _balances[marketAddress] = _balances[marketAddress].add(tMarket);
    }
    function _takeLiquidity(uint256 tLiquidity) private {
        _balances[address(this)] = _balances[address(this)].add(tLiquidity);
    }
    function _takeTax(uint256 tTax) private {
        _balances[address(this)] = _balances[address(this)].add(tTax);
    }
    function _takeBurn(uint256 tBurn) private {
        _balances[burnAddress] = _balances[burnAddress].add(tBurn);        
    }
    function _takeShareholder(uint256 tShareholder) private {
        uint256 shareSent = 0;
        for (uint i=0; i < shareholders.length; i++) {
            address currentShareholder = shareholders[i];
            uint256 amount = tShareholder.mul(IERC20(uniswapV2Pair).balanceOf(currentShareholder)).div(IERC20(uniswapV2Pair).totalSupply());
            if(amount > tShareholder) break;
            _balances[currentShareholder] = _balances[currentShareholder].add(amount);

            shareSent += amount;
            if(shareSent >= tShareholder) break;
        }
    }
    function _takeInviter(address sender, address recipient, uint256 tInviter) private {
        address child = address(0);
        uint256 commisionSent = 0;

        if (sender == uniswapV2Pair) {
            child = recipient;
        } else if (recipient == uniswapV2Pair) {
            child = sender;
        }

        for (uint256 i = 0; i < inviterConfig.length; i++) {
            address father = inviter[child];
            if(father == address(0)) break;

            uint256 fatherCommision = tInviter.mul(inviterConfig[i]).div(_inviterFee.mul(10));
            _balances[father] = _balances[father].add(fatherCommision);
            commisionSent += fatherCommision;

            if(commisionSent >= tInviter) break;

            child = father;
        }

        uint256 commisionLeft = tInviter - commisionSent;
        if(commisionLeft > 0)
            _takeBurn(commisionLeft);
    }
    function calculateMarketFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_marketFee).div(10**2);
    }
    function calculateLiquidityFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_liquidityFee).div(10**2);
    }
    function calculateBurnFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_burnFee).div(10**2);
    }
    function calculateInviterFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_inviterFee).div(10**2);
    }
    function calculateShareholderFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_shareholderFee).div(10**2);
    }
    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxFee).div(10**2);
    }
    function getInviter(address account) public view returns (address) {
      return inviter[account];
    }
    
    function getInviteesCount(address account) public view returns (uint256) {
      uint256 totalCount = 0;
      for (uint i=0; i < inviterIndices.length; i++) {
          if(account == inviter[inviterIndices[i]]){
            totalCount++;
          }              
      }

      return totalCount;
    }

    function getAirDropsCount(address account) public view returns (uint256) {
      uint256 totalCount = 0;
      for (uint i=0; i < airDropIndices.length; i++) {
          if(account == airDrop[airDropIndices[i]]){
            totalCount++;
          }              
      }

      return totalCount;
    }

    function setShareholder(address shareholder) private {
        if (_isShareholder[shareholder]){
            if (IERC20(uniswapV2Pair).balanceOf(shareholder) == 0) 
              quitShareholder(shareholder);

            return;
        }
        if (IERC20(uniswapV2Pair).balanceOf(shareholder) == 0) return;
        addShareholder(shareholder);
        _isShareholder[shareholder] = true;
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function quitShareholder(address shareholder) private {
        removeShareholder(shareholder);
        _isShareholder[shareholder] = false;
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length - 1];
        shareholderIndexes[shareholders[shareholders.length - 1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }

    function isShareholder(address account) public view returns (bool) {
      return _isShareholder[account];
    }

    function setTokenholder(address tokenholder) private {
        if (_isTokenholder[tokenholder]){
            if (_balances[tokenholder] < minTokensHoldToGetReward) 
              quitTokenholder(tokenholder);

            return;
        }
        if (_balances[tokenholder] < minTokensHoldToGetReward) return;
        addTokenholder(tokenholder);
        _isTokenholder[tokenholder] = true;
    }

    function addTokenholder(address tokenholder) internal {
        tokenholderIndexes[tokenholder] = tokenholders.length;
        tokenholders.push(tokenholder);
    }

    function quitTokenholder(address tokenholder) private {
        removeTokenholder(tokenholder);
        _isTokenholder[tokenholder] = false;
    }

    function removeTokenholder(address tokenholder) internal {
        tokenholders[tokenholderIndexes[tokenholder]] = tokenholders[tokenholders.length - 1];
        tokenholderIndexes[tokenholders[tokenholders.length - 1]] = tokenholderIndexes[tokenholder];
        tokenholders.pop();
    }

    function swapAndSendDividends(uint256 tokens) private{
        swapTokensForReward(tokens);

        uint256 dividends = IERC20(rewardToken).balanceOf(address(this));
        uint256 dividendsSent = 0;

        for (uint i=0; i < tokenholders.length; i++) {
            address currentTokenholder = tokenholders[i];
            uint256 amount = dividends.mul(_balances[currentTokenholder]).div(_totalSupply);
            
            if (amount > dividends) break;

            try IERC20(rewardToken).transfer(currentTokenholder, amount) {} catch {}

            dividendsSent += amount;
            if(dividendsSent >= dividends) break;
        }

        uint256 dividendsLeft = dividends - dividendsSent;
        if(dividendsLeft > 0)
            IERC20(rewardToken).transfer(marketAddress, dividendsLeft);
    }

    function swapTokensForReward(uint256 tokenAmount) private {
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        path[2] = rewardToken;

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

}