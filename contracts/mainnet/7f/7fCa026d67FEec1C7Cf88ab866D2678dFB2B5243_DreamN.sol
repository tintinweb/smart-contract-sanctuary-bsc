// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "./BEP20.sol";
import "./IDEX.sol";

contract DreamN is BEP20 {
  IDexRouter public constant ROUTER = IDexRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
  address public immutable pair;

  address public developmentWallet;
  address public marketingWallet;
  address public rewardWallet;

  uint256 public swapThreshold;
  bool public swapEnabled;

  bool sniperTax = true;
  bool tradingEnabled;
  bool inSwap;

  uint256 public buyTax = 500;
  uint256 public sellTax = 1500;
  uint256 public transferTax = 0;
  uint256 public rewardShare = 600;
  uint256 public marketingShare = 200;
  uint256 public developmentShare = 200;
  uint256 totalShares = 1000;
  uint256 constant TAX_DENOMINATOR = 10000;

  uint256 public transferGas = 25000;

  mapping (address => bool) public isWhitelisted;
  mapping (address => bool) public isCEX;
  mapping (address => bool) public isMarketMaker;

  event EnableTrading();
  event TriggerSwapBack();
  event Burn(uint256 amount);
  event RecoverBNB(uint256 amount);
  event RecoverBEP20(address indexed token, uint256 amount);
  event SetWhitelisted(address indexed account, bool indexed status);
  event SetCEX(address indexed account, bool indexed exempt);
  event SetMarketMaker(address indexed account, bool indexed isMM);
  event SetTaxes(uint256 reward, uint256 liquidity, uint256 marketing);
  event SetShares(uint256 rewardShare, uint256 developmentShare, uint256 marketingShare);
  event SetSwapBackSettings(bool enabled, uint256 amount);
  event SetTransferGas(uint256 newGas, uint256 oldGas);
  event SetDevelopmentWallet(address newWallet, address oldWallet);
  event SetMarketingWallet(address newWallet, address oldWallet);
  event SetRewardWallet(address newAddress, address oldAddress);
  event DepositDevelopment(address indexed wallet, uint256 amount);
  event DepositMarketing(address indexed wallet, uint256 amount);
  event DepositRewards(address indexed wallet, uint256 amount);

  modifier swapping() { 
    inSwap = true;
    _;
    inSwap = false;
  }

  constructor(
    address owner,
    address marketing,
    address development,
    address rewards
  ) BEP20(owner, marketing) {
    require(development != address(0) && rewards != address(0), "Parameter can't be zero address");

    pair = IDexFactory(ROUTER.factory()).createPair(ROUTER.WETH(), address(this));
    _approve(address(this), address(ROUTER), type(uint256).max);
    isMarketMaker[pair] = true;

    rewardWallet = rewards;
    marketingWallet = marketing;
    developmentWallet = development;
    isWhitelisted[marketingWallet] = true;
  }

  // Override

  function _transfer(address sender, address recipient, uint256 amount) internal override {
    if (isWhitelisted[sender] || isWhitelisted[recipient] || inSwap) {
      super._transfer(sender, recipient, amount);
      return;
    }
    require(tradingEnabled, "Trading is disabled");

    if (_shouldSwapBack(recipient)) { _swapBack(); }
    uint256 amountAfterTaxes = _takeTax(sender, recipient, amount);

    super._transfer(sender, recipient, amountAfterTaxes);
  }

  receive() external payable {}

  // Private

  function _takeTax(address sender, address recipient, uint256 amount) private returns (uint256) {
    if (amount == 0) { return amount; }

    uint256 taxAmount = amount * _getTotalTax(sender, recipient) / TAX_DENOMINATOR;
    if (taxAmount > 0) { super._transfer(sender, address(this), taxAmount); }

    return amount - taxAmount;
  }

  function _getTotalTax(address sender, address recipient) private view returns (uint256) {
    if (sniperTax) { return TAX_DENOMINATOR - 100; }
    if (isCEX[recipient]) { return 0; }
    if (isCEX[sender]) { return buyTax; }

    if (isMarketMaker[sender]) {
      return buyTax;
    } else if (isMarketMaker[recipient]) {
      return sellTax;
    } else {
      return transferTax;
    }
  }

  function _shouldSwapBack(address recipient) private view returns (bool) {
    return isMarketMaker[recipient] && swapEnabled && balanceOf(address(this)) >= swapThreshold;
  }

  function _swapBack() private swapping {
    address[] memory path = new address[](2);
    path[0] = address(this);
    path[1] = ROUTER.WETH();
    uint256 balanceBefore = address(this).balance;

    ROUTER.swapExactTokensForETH(
      swapThreshold,
      0,
      path,
      address(this),
      block.timestamp
    );

    uint256 amountBNB = address(this).balance - balanceBefore;
    uint256 amountBNBDevelopment = amountBNB * developmentShare / totalShares;
    uint256 amountBNBMarketing = amountBNB * marketingShare / totalShares;
    uint256 amountBNBRewards = amountBNB * rewardShare / totalShares;

    (bool developmentSuccess,) = payable(developmentWallet).call{value: amountBNBDevelopment, gas: transferGas}("");
    if (developmentSuccess) { emit DepositDevelopment(developmentWallet, amountBNBDevelopment); }

    (bool marketingSuccess,) = payable(marketingWallet).call{value: amountBNBMarketing, gas: transferGas}("");
    if (marketingSuccess) { emit DepositMarketing(marketingWallet, amountBNBMarketing); }

    (bool rewardSuccess,) = payable(rewardWallet).call{value: amountBNBRewards, gas: transferGas}("");
    if (rewardSuccess) { emit DepositRewards(rewardWallet, amountBNBRewards); }
  }

  // Owner

  function enableTrading() external onlyOwner {
    tradingEnabled = true;
    emit EnableTrading();
  }

  function removeSniperTax() external onlyOwner {
    sniperTax = false;
  }

  function triggerSwapBack() external onlyOwner {
    _swapBack();
    emit TriggerSwapBack();
  }

  function burnFromStorage(uint256 amount) external onlyOwner {
    uint256 tokenAmount = amount * 10**decimals();
    super._transfer(address(this), address(0xdead), tokenAmount);
    emit Burn(amount);
  }

  function recoverBNB() external onlyOwner {
    uint256 amount = address(this).balance;
    (bool sent,) = payable(marketingWallet).call{value: amount, gas: transferGas}("");
    require(sent, "Tx failed");
    emit RecoverBNB(amount);
  }

  function recoverBEP20(IBEP20 token, address recipient) external onlyOwner {
    require(address(token) != address(this), "Can't withdraw DreamN");
    uint256 amount = token.balanceOf(address(this));
    token.transfer(recipient, amount);
    emit RecoverBEP20(address(token), amount);
  }

  function setIsWhitelisted(address account, bool value) external onlyOwner {
    isWhitelisted[account] = value;
    emit SetWhitelisted(account, value);
  }

  function setIsCEX(address account, bool value) external onlyOwner {
    isCEX[account] = value;
    emit SetCEX(account, value);
  }

  function setIsMarketMaker(address account, bool value) external onlyOwner {
    require(account != pair, "Can't modify pair");
    isMarketMaker[account] = value;
    emit SetMarketMaker(account, value);
  }

  function setTaxes(uint256 newBuyTax, uint256 newSellTax, uint256 newTransferTax) external onlyOwner {
    require(newBuyTax <= 1000 && newSellTax <= 2000, "Too high taxes");
    buyTax = newBuyTax;
    sellTax = newSellTax;
    transferTax = newTransferTax;
    emit SetTaxes(buyTax, sellTax, transferTax);
  }

  function setShares(
    uint256 newRewardShare,
    uint256 newDevelopmentShare,
    uint256 newMarketingShare
  ) external onlyOwner {
    rewardShare = newRewardShare;
    developmentShare = newDevelopmentShare;
    marketingShare = newMarketingShare;
    totalShares = rewardShare + developmentShare + marketingShare;
    emit SetShares(rewardShare, developmentShare, marketingShare);
  }

  function setSwapBackSettings(bool enabled, uint256 amount) external onlyOwner {
    uint256 tokenAmount = amount * 10**decimals();
    swapEnabled = enabled;
    swapThreshold = tokenAmount;
    emit SetSwapBackSettings(enabled, amount);
  }

  function setTransferGas(uint256 newGas) external onlyOwner {
    require(newGas >= 21000 && newGas <= 50000, "Invalid gas parameter");
    emit SetTransferGas(newGas, transferGas);
    transferGas = newGas;
  }

  function setDevelopmentWallet(address newWallet) external onlyOwner {
    require(newWallet != address(0), "New development wallet is the zero address");
    emit SetDevelopmentWallet(newWallet, developmentWallet);
    developmentWallet = newWallet;
  }

  function setMarketingWallet(address newWallet) external onlyOwner {
    require(newWallet != address(0), "New marketing wallet is the zero address");
    emit SetMarketingWallet(newWallet, marketingWallet);
    marketingWallet = newWallet;
  }

  function setRewardWallet(address newAddress) external onlyOwner {
    require(newAddress != address(0), "New reward pool is the zero address");
    emit SetRewardWallet(newAddress, rewardWallet);
    rewardWallet = newAddress;
  }
}