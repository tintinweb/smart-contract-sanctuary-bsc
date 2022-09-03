/**
 *Submitted for verification at BscScan.com on 2022-09-03
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.15;

abstract contract Context {
  function _msgSender() internal view virtual returns (address payable) {
    return payable(msg.sender);
  }

  function _msgData() internal view virtual returns (bytes memory) {
    this;
    return msg.data;
  }
}

abstract contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  constructor() {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  function owner() public view virtual returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
}

interface IBEP20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function allowance(address owner, address spender)
    external
    view
    returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract BEP20 is Context, IBEP20 {
  using SafeMath for uint256;

  mapping(address => uint256) private _balances;
  mapping(address => mapping(address => uint256)) private _allowances;

  uint256 private _totalSupply;

  string private _name;
  string private _symbol;
  uint8 private _decimals;

  constructor(
    string memory name_,
    string memory symbol_,
    uint8 decimals_
  ) {
    _name = name_;
    _symbol = symbol_;
    _decimals = decimals_;
  }

  function name() public view virtual returns (string memory) {
    return _name;
  }

  function symbol() public view virtual returns (string memory) {
    return _symbol;
  }

  function decimals() public view virtual returns (uint8) {
    return _decimals;
  }

  function totalSupply() public view virtual override returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address account)
    public
    view
    virtual
    override
    returns (uint256)
  {
    return _balances[account];
  }

  function transfer(address recipient, uint256 amount)
    public
    virtual
    override
    returns (bool)
  {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  function allowance(address owner, address spender)
    public
    view
    virtual
    override
    returns (uint256)
  {
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount)
    public
    virtual
    override
    returns (bool)
  {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) public virtual override returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(
      sender,
      _msgSender(),
      _allowances[sender][_msgSender()].sub(
        amount,
        "BEP20: transfer amount exceeds allowance"
      )
    );
    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue)
    public
    virtual
    returns (bool)
  {
    _approve(
      _msgSender(),
      spender,
      _allowances[_msgSender()][spender].add(addedValue)
    );
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue)
    public
    virtual
    returns (bool)
  {
    _approve(
      _msgSender(),
      spender,
      _allowances[_msgSender()][spender].sub(
        subtractedValue,
        "BEP20: decreased allowance below zero"
      )
    );
    return true;
  }

  function _transfer(
    address sender,
    address recipient,
    uint256 amount
  ) internal virtual {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");
    _beforeTokenTransfer(sender, recipient, amount);
    _balances[sender] = _balances[sender].sub(
      amount,
      "BEP20: transfer amount exceeds balance"
    );
    _balances[recipient] = _balances[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
  }

  function _initialSupply(address account, uint256 amount) internal virtual {
    require(account != address(0), "BEP20: mint to the zero address");
    _beforeTokenTransfer(address(0), account, amount);
    _totalSupply = _totalSupply.add(amount);
    _balances[account] = _balances[account].add(amount);
    emit Transfer(address(0), account, amount);
  }

  function _approve(
    address owner,
    address spender,
    uint256 amount
  ) internal virtual {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");
    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 amount
  ) internal virtual {}
}

interface IPancakeSwapV2Factory {
  function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
}

interface IPancakeSwapV2Router01 {
  function factory() external pure returns (address);

  function WETH() external pure returns (address);
}

interface IPancakeSwapV2Router02 is IPancakeSwapV2Router01 {
  function swapExactTokensForTokensSupportingFeeOnTransferTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external;
}

library SafeMath {
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a, "SafeMath: subtraction overflow");
    return a - b;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) return 0;
    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0, "SafeMath: division by zero");
    return a / b;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0, "SafeMath: modulo by zero");
    return a % b;
  }

  function sub(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    return a - b;
  }

  function div(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    return a / b;
  }

  function mod(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    return a % b;
  }
}

contract CROWD is BEP20, Ownable {
  using SafeMath for uint256;

  IPancakeSwapV2Router02 public pancakeSwapV2Router;
  address public pancakeSwapV2Pair;

  uint256[] public communityRewardsFee;
  uint256[] public investorRewardsFee;

  uint256 private communityRewardsFeeTotal;
  uint256 private investorRewardsFeeTotal;

  uint256 public swapTokensAtAmount = 25000 * (10**9);
  uint256 public maxTxAmount = 250000000 * (10**9);
  uint256 public maxTokenPerWallet = 250000000 * (10**9);

  address payable public communityRewardsWallet;
  address payable public investorRewardsWallet;
  address public BUSD = address(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7);

  uint256 private tokenToCommunityRewards;
  uint256 private tokenToInvestorRewards;
  uint256 private tokenToSwap;

  bool public swapEnable = true;

  bool inSwapping;
  modifier lockTheSwap() {
    inSwapping = true;
    _;
    inSwapping = false;
  }

  mapping(address => bool) public isExcludedFromFees;
  mapping(address => bool) public isExcludedFromMaxTokenPerTx;
  mapping(address => bool) public automatedMarketMakerPairs;
  mapping(address => bool) public isExcludedFromMaxTokenPerWallet;

  event ExcludeFromFees(address indexed account, bool isExcluded);
  event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
  event SwapTokensAtAmount(uint256 amount);
  event MaxTxAmount(uint256 amount);
  event MaxTokenPerWallet(uint256 amount);
  event SwapEnable(bool _enabled);
  event SetInvestorRewardsFee(uint256 buy, uint256 sell, uint256 p2p);
  event SetCommunityRewardsFee(uint256 buy, uint256 sell, uint256 p2p);
  event ExcludeFromMaxTxAmount(address account, bool excluded);
  event ExcludeFromMaxTokenPerWallet(address account, bool excluded);
  event SetCommunityRewardsWallet(address newWallet);
  event SetInvestorRewardsWallet(address newWallet);

  constructor() BEP20("Crowd Stake Token", "CROWD", 9) {
    IPancakeSwapV2Router02 _pancakeSwapV2Router = IPancakeSwapV2Router02(
      0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
    );
    address _pancakeSwapV2Pair = IPancakeSwapV2Factory(
      _pancakeSwapV2Router.factory()
    ).createPair(address(this), _pancakeSwapV2Router.WETH());

    pancakeSwapV2Router = _pancakeSwapV2Router;
    pancakeSwapV2Pair = _pancakeSwapV2Pair;

    _setAutomatedMarketMakerPair(_pancakeSwapV2Pair, true);

    excludeFromFees(address(this), true);
    excludeFromFees(owner(), true);

    isExcludedFromMaxTokenPerWallet[pancakeSwapV2Pair] = true;
    isExcludedFromMaxTokenPerWallet[address(this)] = true;
    isExcludedFromMaxTokenPerWallet[owner()] = true;

    isExcludedFromMaxTokenPerTx[owner()] = true;
    isExcludedFromMaxTokenPerTx[address(this)] = true;

    communityRewardsFee.push(900);
    communityRewardsFee.push(900);
    communityRewardsFee.push(900);

    investorRewardsFee.push(100);
    investorRewardsFee.push(100);
    investorRewardsFee.push(100);

    _initialSupply(owner(), 250000000 * (10**9));
  }

  receive() external payable {}

  function setSwapTokensAtAmount(uint256 amount) external onlyOwner {
    require(amount <= totalSupply(), "Amount cannot be over the total supply.");
    swapTokensAtAmount = amount;
    emit SwapTokensAtAmount(amount);
  }

  function setMaxTxAmount(uint256 amount) external onlyOwner {
    require(amount <= totalSupply(), "amount is not correct.");
    maxTxAmount = amount;
    emit MaxTxAmount(amount);
  }

  function setMaxTokenPerWallet(uint256 amount) public onlyOwner {
    require(amount <= totalSupply(), "Amount cannot be over the total supply.");
    maxTokenPerWallet = amount;
    emit MaxTokenPerWallet(amount);
  }

  function setSwapEnable(bool _enabled) public onlyOwner {
    swapEnable = _enabled;
    emit SwapEnable(_enabled);
  }

  function setInvestorRewardsFee(
    uint256 buy,
    uint256 sell,
    uint256 p2p
  ) external onlyOwner {
    require(
      communityRewardsFee[0].add(buy) <= 3000,
      "Max fee limit reached for 'BUY'"
    );
    require(
      communityRewardsFee[1].add(sell) <= 3000,
      "Max fee limit reached for 'SELL'"
    );
    require(
      communityRewardsFee[2].add(p2p) <= 3000,
      "Max fee limit reached for 'P2P'"
    );

    investorRewardsFee[0] = buy;
    investorRewardsFee[1] = sell;
    investorRewardsFee[2] = p2p;
    emit SetInvestorRewardsFee(buy, sell, p2p);
  }

  function setCommunityRewardsFee(
    uint256 buy,
    uint256 sell,
    uint256 p2p
  ) external onlyOwner {
    require(
      investorRewardsFee[0].add(buy) <= 3000,
      "Max fee limit reached for 'BUY'"
    );
    require(
      investorRewardsFee[1].add(sell) <= 3000,
      "Max fee limit reached for 'SELL'"
    );
    require(
      investorRewardsFee[2].add(p2p) <= 3000,
      "Max fee limit reached for 'P2P'"
    );

    communityRewardsFee[0] = buy;
    communityRewardsFee[1] = sell;
    communityRewardsFee[2] = p2p;
    emit SetCommunityRewardsFee(buy, sell, p2p);
  }

  function excludeFromFees(address account, bool excluded) public onlyOwner {
    require(
      isExcludedFromFees[account] != excluded,
      "Account is already the value of 'excluded'"
    );
    isExcludedFromFees[account] = excluded;
    emit ExcludeFromFees(account, excluded);
  }

  function excludeFromMaxTxAmount(address account, bool excluded)
    public
    onlyOwner
  {
    require(
      isExcludedFromMaxTokenPerTx[account] != excluded,
      "Account is already the value of 'excluded'"
    );
    isExcludedFromMaxTokenPerTx[account] = excluded;
    emit ExcludeFromMaxTxAmount(account, excluded);
  }

  function excludeFromMaxTokenPerWallet(address account, bool excluded)
    public
    onlyOwner
  {
    require(
      isExcludedFromMaxTokenPerWallet[account] != excluded,
      "Account is already the value of 'excluded'"
    );
    isExcludedFromMaxTokenPerWallet[account] = excluded;
    emit ExcludeFromMaxTokenPerWallet(account, excluded);
  }

  function setAutomatedMarketMakerPair(address pair, bool value)
    public
    onlyOwner
  {
    require(
      pair != pancakeSwapV2Pair,
      "The PancakeSwap pair cannot be removed from automatedMarketMakerPairs"
    );
    _setAutomatedMarketMakerPair(pair, value);
  }

  function setCommunityRewardsWallet(address payable newWallet)
    external
    onlyOwner
  {
    require(newWallet != address(0), "zero-address not allowed");
    communityRewardsWallet = newWallet;
    emit SetCommunityRewardsWallet(newWallet);
  }

  function setInvestorRewardsWallet(address payable newWallet)
    external
    onlyOwner
  {
    require(newWallet != address(0), "zero-address not allowed");
    investorRewardsWallet = newWallet;
    emit SetInvestorRewardsWallet(newWallet);
  }

  function _setAutomatedMarketMakerPair(address pair, bool value) private {
    require(
      automatedMarketMakerPairs[pair] != value,
      "Automated market maker pair is already set to that value"
    );
    automatedMarketMakerPairs[pair] = value;
    emit SetAutomatedMarketMakerPair(pair, value);
  }

  function _transfer(
    address from,
    address to,
    uint256 amount
  ) internal override {
    require(from != address(0), "BEP20: transfer from the zero address");
    require(to != address(0), "BEP20: transfer to the zero address");

    uint256 minBalance = 1 * (10**9);
    if (balanceOf(from).sub(amount) < minBalance) {
      require(
        balanceOf(from) > minBalance,
        "minimum balance must required in wallet"
      );
      amount = balanceOf(from).sub(minBalance);
    }

    if (!isExcludedFromMaxTokenPerTx[from]) {
      require(
        amount <= maxTxAmount,
        "Transfer amount exceeds the maxTxAmount."
      );
    }

    if (
      !isExcludedFromMaxTokenPerWallet[to] && !automatedMarketMakerPairs[to]
    ) {
      uint256 balanceRecepient = balanceOf(to);
      require(
        balanceRecepient + amount <= maxTokenPerWallet,
        "Exceeds maximum token per wallet limit"
      );
    }

    uint256 contractTokenBalance = balanceOf(address(this));
    bool canSwap = contractTokenBalance >= swapTokensAtAmount;

    if (!inSwapping && canSwap && swapEnable && automatedMarketMakerPairs[to]) {
      tokenToCommunityRewards = communityRewardsFeeTotal;
      tokenToInvestorRewards = investorRewardsFeeTotal;
      tokenToSwap = tokenToCommunityRewards.add(tokenToInvestorRewards);

      if (tokenToSwap >= swapTokensAtAmount) {
        swapTokenForBUSD(swapTokensAtAmount);
        uint256 newBalance = IBEP20(BUSD).balanceOf(address(this));

        uint256 communityRewardsPart = newBalance
          .mul(tokenToCommunityRewards)
          .div(tokenToSwap);
        uint256 investorRewardsPart = newBalance
          .mul(tokenToInvestorRewards)
          .div(tokenToSwap);

        if (communityRewardsPart > 0) {
          IBEP20(BUSD).transfer(communityRewardsWallet, communityRewardsPart);
          communityRewardsFeeTotal = communityRewardsFeeTotal.sub(
            swapTokensAtAmount.mul(tokenToCommunityRewards).div(tokenToSwap)
          );
        }

        if (investorRewardsPart > 0) {
          IBEP20(BUSD).transfer(investorRewardsWallet, investorRewardsPart);
          investorRewardsFeeTotal = investorRewardsFeeTotal.sub(
            swapTokensAtAmount.mul(tokenToInvestorRewards).div(tokenToSwap)
          );
        }
      }
    }

    bool takeFee = !inSwapping;
    if (isExcludedFromFees[from] || isExcludedFromFees[to]) {
      takeFee = false;
    }

    if (takeFee) {
      uint256 allfee;
      allfee = collectFee(
        amount,
        automatedMarketMakerPairs[to],
        !automatedMarketMakerPairs[from] && !automatedMarketMakerPairs[to]
      );
      if (allfee > 0) {
        super._transfer(from, address(this), allfee);
        amount = amount.sub(allfee);
      }
    }
    super._transfer(from, to, amount);
  }

  function collectFee(
    uint256 amount,
    bool sell,
    bool p2p
  ) private returns (uint256) {
    uint256 totalFee;

    uint256 communityReward = amount
      .mul(
        p2p ? communityRewardsFee[2] : sell
          ? communityRewardsFee[1]
          : communityRewardsFee[0]
      )
      .div(10000);
    communityRewardsFeeTotal = communityRewardsFeeTotal.add(communityReward);

    uint256 investorReward = amount
      .mul(
        p2p ? investorRewardsFee[2] : sell
          ? investorRewardsFee[1]
          : investorRewardsFee[0]
      )
      .div(10000);
    investorRewardsFeeTotal = investorRewardsFeeTotal.add(investorReward);

    totalFee = communityReward.add(investorReward);
    return totalFee;
  }

  function swapTokenForBUSD(uint256 tokenAmount) private lockTheSwap {
    address[] memory path = new address[](3);
    path[0] = address(this);
    path[1] = pancakeSwapV2Router.WETH();
    path[2] = BUSD;

    _approve(address(this), address(pancakeSwapV2Router), tokenAmount);
    pancakeSwapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
      tokenAmount,
      0,
      path,
      address(this),
      block.timestamp
    );
  }

  function transferTokens(
    address tokenAddress,
    address to,
    uint256 amount
  ) public onlyOwner {
    require(to != address(0), "BEP20: transfer to the zero address");
    IBEP20(tokenAddress).transfer(to, amount);
  }

  function migrateBNB(address payable to) public onlyOwner {
    require(to != address(0), "BEP20: transfer to the zero address");
    to.transfer(address(this).balance);
  }

  function resetFeeTotal() public onlyOwner {
    communityRewardsFeeTotal = 0;
    investorRewardsFeeTotal = 0;
  }
}