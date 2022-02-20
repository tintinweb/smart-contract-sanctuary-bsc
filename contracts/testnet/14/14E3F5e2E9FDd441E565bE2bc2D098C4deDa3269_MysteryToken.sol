// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./Ownable.sol";
import "./SafeMath.sol";

interface IPancakeFactory {

  event PairCreated(address indexed token0, address indexed token1, address pair, uint);

  function createPair(address tokenA, address tokenB) external returns (address pair);

}


interface IPancakeRouter01 {
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


interface IPancakeRouter02 is IPancakeRouter01 {
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


contract MysteryToken is Ownable {

  using SafeMath for uint256;

  uint8 private _decimals;
  string private _symbol;
  string private _name;

  mapping (address => uint256) private _rOwned;
  mapping (address => uint256) private _tOwned;
  mapping (address => mapping (address => uint256)) private _allowances;

  mapping (address => bool) private _isAuthorized;
  bool private _tradingOpen;

  mapping (address => bool) private _isExcludedFromFee;

  mapping (address => bool) private _isExcluded;
  address[] private _excluded;

  uint256 private constant MAX = ~uint256(0);
  uint256 private _tTotal;
  uint256 private _rTotal;
  uint256 private _tFeeTotal;

  uint256 private _taxFee = 1;
  uint256 private _previousTaxFee = _taxFee;

  uint256 private _liquidityFee = 2;
  uint256 private _previousLiquidityFee = _liquidityFee;
  uint256 private _numTokensSellToAddToLiquidity = 1000000 * 10**18;
  bool private _inSwapAndLiquify;
  bool private _swapAndLiquifyEnabled = true;

  uint256 private _burnFee = 1;
  uint256 private _previousBurnFee = _burnFee;
  address public immutable deadAddress = 0x000000000000000000000000000000000000dEaD;

  uint256 private _marketingFee = 1;
  uint256 private _previousMarketingFee = _marketingFee;
  address private _marketingWallet = 0x6E2b272C312B237aD936060d6c43278C45cCA592;

  uint256 private _maxWalletToken;
  mapping (address => bool) private _isMaxWalletTokenExempt;

  IPancakeRouter02 public immutable pancakeswapV2Router;
  address public immutable pancakeswapV2Pair;


  event SwapAndLiquifyEnabledUpdated(bool enabled);
  event SwapAndLiquify(
    uint256 tokensSwapped,
    uint256 ethReceived,
    uint256 tokensIntoLiqudity
  );

  modifier lockTheSwap {
    _inSwapAndLiquify = true;
    _;
    _inSwapAndLiquify = false;
  }


  constructor(string memory token_name, string memory short_symbol, uint8 token_decimals, uint256 token_totalSupply){
    _name = token_name;
    _symbol = short_symbol;
    _decimals = token_decimals;
    _tTotal = token_totalSupply;
    _rTotal = (MAX - (MAX % _tTotal));

    _tradingOpen = false;

    _isAuthorized[_msgSender()] = true;

    _maxWalletToken = _tTotal.mul(3).div(100);
    _isMaxWalletTokenExempt[_msgSender()] = true;

    IPancakeRouter02 _pancakeswapV2Router = IPancakeRouter02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);//router testnet
    
    pancakeswapV2Pair = IPancakeFactory(_pancakeswapV2Router.factory())
      .createPair(address(this), _pancakeswapV2Router.WETH());

    pancakeswapV2Router = _pancakeswapV2Router;

    _rOwned[_msgSender()] = _rTotal;

    _isExcludedFromFee[owner()] = true;
    _isExcludedFromFee[address(this)] = true;

    emit Transfer(address(0), _msgSender(), _tTotal);
  }


  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);

  receive() external payable {}

  function totalSupply() external view returns (uint256) {
    return _tTotal;
  }

  function decimals() external view returns (uint8) {
    return _decimals;
  }

  function symbol() external view returns (string memory) {
    return _symbol;
  }

  function name() external view returns (string memory) {
    return _name;
  }

  function taxFee() external view returns (uint256) {
    return _taxFee;
  }

  function liquidityFee() external view returns (uint256) {
    return _liquidityFee;
  }

  function burnFee() external view returns (uint256) {
    return _burnFee;
  }

  function marketingFee() external view returns (uint256) {
    return _marketingFee;
  }

  function balanceOf(address account) public view returns (uint256) {
    if (_isExcluded[account]) return _tOwned[account];
    return _tokenFromReflection(_rOwned[account]);
  }

  function allowance(address owner, address spender) external view returns(uint256) {
    return _allowances[owner][spender];
  }

  function increaseAllowance(address spender, uint256 amount) external returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(amount));
    return true;
  }

  function decreaseAllowance(address spender, uint256 amount) external returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(amount));
    return true;
  }

  function approve(address spender, uint256 amount) external returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  function isAuthorized(address account) external view returns (bool) {
    return _isAuthorized[account];
  }

  function isTradingOpen() external view returns(bool){
    return _tradingOpen;
  }

  function getMaxWallet() external view returns (uint256) {
    return _maxWalletToken;
  }

  function isMaxWalletTokenExempt(address account) external view returns(bool) {
    return _isMaxWalletTokenExempt[account];
  }

  function isExcludedFromFee(address account) external view returns(bool) {
    return _isExcludedFromFee[account];
  }

  function isExcludedFromRewards(address account) external view returns(bool) {
    return _isExcluded[account];
  }

  function tokenFromReflection(uint256 rAmount) external view returns(uint256) {
    return _tokenFromReflection(rAmount);
  }

  function transfer(address recipient, uint256 amount) external returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  function transferFrom(address spender, address recipient, uint256 amount) external returns(bool){

    require(_allowances[spender][_msgSender()] >= amount, "MysteryToken: You cannot spend that much on this account");

    _transfer(spender, recipient, amount);

    _approve(spender, _msgSender(), _allowances[spender][_msgSender()].sub(amount, "MysteryToken: transfer amount exceeds allowance"));
    return true;
  }

  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "MysteryToken: approve cannot be done from zero address");
    require(spender != address(0), "MysteryToken: approve cannot be to zero address");

    _allowances[owner][spender] = amount;

    emit Approval(owner,spender,amount);
  }

  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "MysteryToken: transfer from zero address");
    require(recipient != address(0), "MysteryToken: transfer to zero address");
    require(amount > 0, "Transfer amount must be greater than zero");
    require(balanceOf(sender) >= amount, "MysteryToken: cant transfer more than your account holds");

    if(!_isAuthorized[sender] || !_isAuthorized[recipient]){
      require(_tradingOpen,"Trading not open yet");
    }

    if ((recipient != address(this) 
    && recipient != address(deadAddress) 
    && recipient != pancakeswapV2Pair 
    && recipient != _marketingWallet)
    || !_isMaxWalletTokenExempt[recipient]){
      uint256 balanceOfRecipient = balanceOf(recipient);
      require((balanceOfRecipient + amount) <= _maxWalletToken,"Total Holding is currently limited, you can not buy that much.");
    }

    uint256 contractTokenBalance = balanceOf(address(this));

    bool overMinTokenBalance = contractTokenBalance >= _numTokensSellToAddToLiquidity;
    if (
      overMinTokenBalance &&
      !_inSwapAndLiquify &&
      sender != pancakeswapV2Pair &&
      _swapAndLiquifyEnabled
    ) {
      contractTokenBalance = _numTokensSellToAddToLiquidity;
      swapAndLiquify(contractTokenBalance);
    }

    bool takeFee = true;
    if(_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]){
      takeFee = false;
    }

    _tokenTransfer(sender,recipient,amount,takeFee);

    emit Transfer(sender, recipient, amount);
  }


  function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {

    uint256 half = contractTokenBalance.div(2);
    uint256 otherHalf = contractTokenBalance.sub(half);

    uint256 initialBalance = address(this).balance;

    swapTokensForEth(half);

    uint256 newBalance = address(this).balance.sub(initialBalance);

    addLiquidity(otherHalf, newBalance);

    emit SwapAndLiquify(half, newBalance, otherHalf);
  }

  function swapTokensForEth(uint256 tokenAmount) private {

    address[] memory path = new address[](2);
    path[0] = address(this);
    path[1] = pancakeswapV2Router.WETH();

    _approve(address(this), address(pancakeswapV2Router), tokenAmount);

    pancakeswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
      tokenAmount,
      0,
      path,
      address(this),
      block.timestamp
    );
  }


  function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {

    _approve(address(this), address(pancakeswapV2Router), tokenAmount);

    pancakeswapV2Router.addLiquidityETH{value: ethAmount}(
      address(this),
      tokenAmount,
      0,
      0,
      owner(),
      block.timestamp
    );
  }


  function _tokenTransfer(address sender, address recipient, uint256 amount,bool takeFee) private {
    if(!takeFee)
      removeAllFee();

    uint256 burnAmount = _calculateBurnFee(amount);
    uint256 marketingAmount = _calculateMarketingFee(amount);

    if (_isExcluded[sender] && !_isExcluded[recipient]) {
      _transferFromExcluded(sender, recipient, amount.sub(burnAmount).sub(marketingAmount));
    } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
      _transferToExcluded(sender, recipient, amount.sub(burnAmount).sub(marketingAmount));
    } else if (_isExcluded[sender] && _isExcluded[recipient]) {
      _transferBothExcluded(sender, recipient, amount.sub(burnAmount).sub(marketingAmount));
    } else {
      _transferStandard(sender, recipient, amount.sub(burnAmount).sub(marketingAmount));
    }

    _transferBurnAndMarketingFee(sender, burnAmount, marketingAmount);

    if(!takeFee)
      restoreAllFee();
  }

  function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {

    (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee,, uint256 tLiquidity) = _getValues(tAmount);

    _tOwned[sender] = _tOwned[sender].sub(tAmount);
    _rOwned[sender] = _rOwned[sender].sub(rAmount);
    _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
    _takeLiquidity(tLiquidity);
    _reflectFee(rFee, tFee);
    emit Transfer(sender, recipient, tTransferAmount);
  }

  function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {

    (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee,, uint256 tLiquidity) = _getValues(tAmount);

    _rOwned[sender] = _rOwned[sender].sub(rAmount);
    _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
    _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
    _takeLiquidity(tLiquidity);
    _reflectFee(rFee, tFee);
    emit Transfer(sender, recipient, tTransferAmount);
  }

  function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {

    (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee,, uint256 tLiquidity) = _getValues(tAmount);

    _tOwned[sender] = _tOwned[sender].sub(tAmount);
    _rOwned[sender] = _rOwned[sender].sub(rAmount);
    _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
    _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
    _takeLiquidity(tLiquidity);
    _reflectFee(rFee, tFee);
    emit Transfer(sender, recipient, tTransferAmount);
  }

  function _transferStandard(address sender, address recipient, uint256 tAmount) private {

    (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee,, uint256 tLiquidity) = _getValues(tAmount);

    _rOwned[sender] = _rOwned[sender].sub(rAmount);
    _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
    _takeLiquidity(tLiquidity);
    _reflectFee(rFee, tFee);
    emit Transfer(sender, recipient, tTransferAmount);
  }

  function _transferBurnAndMarketingFee(address sender, uint256 burnAmount, uint256 marketingAmount) private {

    removeTaxAndLiquidityFee();

    if (_isExcluded[sender]) {
      _transferBothExcluded(sender, deadAddress, burnAmount);
      _transferFromExcluded(sender, _marketingWallet, marketingAmount);
    } else {
      _transferToExcluded(sender, deadAddress, burnAmount);
      _transferStandard(sender, _marketingWallet, marketingAmount);
    }

    restoreTaxAndLiquidityFee();
  }

  function _tokenFromReflection(uint256 rAmount) private view returns(uint256) {
    require(rAmount <= _rTotal, "Amount must be less than total reflections");
    uint256 currentRate =  _getRate();
    return rAmount.div(currentRate);
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

  function _takeLiquidity(uint256 tLiquidity) private {
    uint256 currentRate =  _getRate();
    uint256 rLiquidity = tLiquidity.mul(currentRate);
    _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
    if(_isExcluded[address(this)])
      _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity);
  }

  function _reflectFee(uint256 rFee, uint256 tFee) private {
    _rTotal = _rTotal.sub(rFee);
    _tFeeTotal = _tFeeTotal.add(tFee);
  }

  function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256) {
    (uint256 tTransferAmount, uint256 tFee, uint256 tBurn, uint256 tLiquidity) = _getTValues(tAmount);
    (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tBurn, tLiquidity, _getRate());
    return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tBurn, tLiquidity);
  }

  function _getTValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256) {
    uint256 tFee = _calculateTaxFee(tAmount);
    uint256 tBurn = _calculateBurnFee(tAmount);
    uint256 tLiquidity = _calculateLiquidityFee(tAmount);
    uint256 tTransferAmount = tAmount.sub(tFee).sub(tBurn).sub(tLiquidity);
    return (tTransferAmount, tFee, tBurn, tLiquidity);
  }

  function _getRValues(uint256 tAmount, uint256 tFee, uint256 tBurn, uint256 tLiquidity, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
    uint256 rAmount = tAmount.mul(currentRate);
    uint256 rFee = tFee.mul(currentRate);
    uint256 rBurn = tBurn.mul(currentRate);
    uint256 rLiquidity = tLiquidity.mul(currentRate);
    uint256 rTransferAmount = rAmount.sub(rFee).sub(rBurn).sub(rLiquidity);
    return (rAmount, rTransferAmount, rFee);
  }

  function _calculateTaxFee(uint256 amount) private view returns (uint256) {
    return amount.mul(_taxFee).div(100);
  }

  function _calculateBurnFee(uint256 amount) private view returns (uint256) {
    return amount.mul(_burnFee).div(100);
  }

  function _calculateLiquidityFee(uint256 amount) private view returns (uint256) {
    return amount.mul(_liquidityFee).div(100);
  }

  function _calculateMarketingFee(uint256 amount) private view returns (uint256) {
    return amount.mul(_marketingFee).div(100);
  }

  function removeAllFee() private {
    if(_taxFee == 0 && _marketingFee == 0 && _liquidityFee == 0 && _burnFee == 0) return;

    _previousTaxFee = _taxFee;
    _previousMarketingFee = _marketingFee;
    _previousBurnFee = _burnFee;
    _previousLiquidityFee = _liquidityFee;

    _taxFee = 0;
    _marketingFee = 0;
    _burnFee = 0;
    _liquidityFee = 0;
  }

  function restoreAllFee() private {
    _taxFee = _previousTaxFee;
    _marketingFee = _previousMarketingFee;
    _burnFee = _previousBurnFee;
    _liquidityFee = _previousLiquidityFee;
  }

  function removeTaxAndLiquidityFee() private {
    if(_taxFee == 0 && _liquidityFee == 0) return;

    _previousTaxFee = _taxFee;
    _previousLiquidityFee = _liquidityFee;

    _taxFee = 0;
    _liquidityFee = 0;
  }

  function restoreTaxAndLiquidityFee() private {
    _taxFee = _previousTaxFee;
    _liquidityFee = _previousLiquidityFee;
  }




  function tradingStatus(bool status) public onlyOwner {
    _tradingOpen = status;
  }

  function setTaxFee(uint256 newTaxFee) external onlyOwner() {
    _taxFee = newTaxFee;
  }

  function setLiquidityFee(uint256 newLiquidityFee) external onlyOwner() {
    _liquidityFee = newLiquidityFee;
  }

  function setBurnFee(uint256 newBurnFee) external onlyOwner() {
    _burnFee = newBurnFee;
  }

  function setMarketingFee(uint256 newMarketingFee) external onlyOwner() {
    _marketingFee = newMarketingFee;
  }

  function setMaxWalletToken(uint256 newMaxWalletToken) external onlyOwner {
    _maxWalletToken = newMaxWalletToken;
  }

  function excludeFromReward(address account) public onlyOwner() {

    require(account != address(pancakeswapV2Router), 'We can not exclude Pancake router.');
    require(!_isExcluded[account], "Account is already excluded");
    if(_rOwned[account] > 0) {
      _tOwned[account] = _tokenFromReflection(_rOwned[account]);
    }
    _isExcluded[account] = true;
    _excluded.push(account);
  }

  function includeInReward(address account) external onlyOwner() {
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

  function excludeFromFee(address account) public onlyOwner {
    _isExcludedFromFee[account] = true;
  }
  
  function includeInFee(address account) public onlyOwner {
    _isExcludedFromFee[account] = false;
  }

  function excludeFromMaxWalletTokenExempt(address account) public onlyOwner {
    require(_isMaxWalletTokenExempt[account], "Account is already excluded");
    _isMaxWalletTokenExempt[account] = false;
  }

  function includeInMaxWalletTokenExempt(address account) public onlyOwner {
    require(!_isMaxWalletTokenExempt[account], "Accout is alredy included");
    _isMaxWalletTokenExempt[account] = true;
  }

  function setMarketingWallet(address newWallet) external onlyOwner() {
    _marketingWallet = newWallet;
  }

  function setSwapAndLiquifyEnabled(bool enabled) external onlyOwner {
    _swapAndLiquifyEnabled = enabled;
    emit SwapAndLiquifyEnabledUpdated(enabled);
  }

}