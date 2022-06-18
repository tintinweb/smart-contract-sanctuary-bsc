// created by iSStudioWorks
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import "./BEP20.sol";
import "./IDEX.sol";

contract FLOKiv2 is BEP20 { 

  uint256 public swapThreshold = 300_000_000_000_000 * 10**decimals();
  bool public swapEnabled = true;
  bool public tradingEnabled;
  bool _sniperTax = true;
  bool _inSwap;

  uint256 public liquidityFee = 100;
  uint256 public marketingFee = 800;
  uint256 baseFee = 100;
  uint256 _totalFee = 900;
  uint256 constant FEE_DENOMINATOR = 10000;

  address public routerAddr;
  IDexRouter public ROUTER;
  address public pair;
  uint256 public transferGas = 25000;

  mapping (address => bool) public isWhitelisted;
  mapping (address => bool) public isFeeExempt;
  mapping (address => bool) public isBaseFeeExempt;
  mapping (address => bool) public isRouter;
  mapping (address => bool) public isMarketMaker;

  event SetIsWhitelisted(address indexed account, bool indexed status);
  event SetBaseFeeExempt(address indexed account, bool indexed exempt);
  event SetFeeExempt(address indexed account, bool indexed exempt);
  event SetRouter(address indexed oldRouterAddr, address indexed rtrAddr, bool indexed isRtr);
  event SetMarketMaker(address indexed oldPairAddr, address indexed pairAddr, bool indexed isMM);
  event SetSwapBackSettings(bool indexed enabled, uint256 amount);
  event SetFees(uint256 liquidity, uint256 marketing);
  event SetBaseFee(uint256 base);
  event AutoLiquidity(uint256 pair, uint256 tokens);
  event UpdateTransferGas(uint256 gas);
  event RecoverContractFund(uint256 amount);
  event RecoverMarketingFund(address targetAddress, uint256 amountBNB, uint256 amountToken);
  event TriggerSwapBack();
  event EnableTrading();

  modifier swapping() { 
    _inSwap = true;
    _;
    _inSwap = false;
  }

  constructor() BEP20() {
    routerAddr = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
    ROUTER = IDexRouter(routerAddr);
        //0xD99D1c33F9fC3444f8101754aBC46c52416550D1 testnet PCS router
        //0x10ED43C718714eb63d5aA57B78B54704E256024E mainnet PCS router
        //pinkswap router 0xBBe737384C2A26B15E23a181BDfBd9Ec49E00248

    pair = IDexFactory(ROUTER.factory()).createPair(ROUTER.WETH(), address(this));
    _approve(address(this), address(ROUTER), type(uint256).max);
    isMarketMaker[pair] = true;

    //DON'T FORGET TO SET LPLocker AND Marketing(AND ALSO WHITELISTING Marketing) AFTER DEPLOYING THE CONTRACT!!!
    //DON'T FORGET TO SET ADMINS!!

    isWhitelisted[super.getOwner()] = true;
    isWhitelisted[address(this)] = true;
  }

  // Override

  function _transfer(address sender, address recipient, uint256 amount) internal override {
    if (isWhitelisted[sender] || isWhitelisted[recipient]) { super._transfer(sender, recipient, amount); return; }
    require(tradingEnabled, "Trading is disabled");

    if (_shouldSwapBack(recipient)) { _swapBack(); }
    uint256 amountAfterFees = _takeFee(sender, recipient, amount);

    super._transfer(sender, recipient, amountAfterFees);
  }

  // Public

  function getTotalFee() public view returns (uint256) {
    if (_sniperTax) { return FEE_DENOMINATOR - 200; }
    return _totalFee;
  }

  receive() external payable {}

  // Private

  function _takeFee(address sender, address recipient, uint256 amount) private returns (uint256) {
    if (amount > 0) {
      uint256 baseFeeAmount;
      if (!isBaseFeeExempt[sender] && !isBaseFeeExempt[recipient]) {
        baseFeeAmount = amount * baseFee / FEE_DENOMINATOR;
        super._transfer(sender, super.getMarketing(), baseFeeAmount);
      }

      uint256 feeAmount;
      if (!isFeeExempt[sender] && !isFeeExempt[recipient] && (isMarketMaker[recipient] || isMarketMaker[sender])) {
        feeAmount = amount * getTotalFee() / FEE_DENOMINATOR;
        super._transfer(sender, address(this), feeAmount);
      }

      return amount - baseFeeAmount - feeAmount;
    } else {
      return amount;
    }
  }

  function _shouldSwapBack(address recipient) private view returns (bool) {
    return isMarketMaker[recipient] // TODO: test swap logic with custom market maker "sell"
    && !_inSwap
    && swapEnabled
    && balanceOf(address(this)) >= swapThreshold;
  }

  function _swapBack() private swapping {
    address[] memory path = new address[](2);
    path[0] = address(this);
    path[1] = ROUTER.WETH();

    uint256 liquidityTokens = swapThreshold * liquidityFee / _totalFee / 2;
    uint256 amountToSwap = swapThreshold - liquidityTokens;
    uint256 balanceBefore = address(this).balance;

    ROUTER.swapExactTokensForETH(
      amountToSwap,
      0,
      path,
      address(this),
      block.timestamp
    );

    uint256 amountBNB = address(this).balance - balanceBefore;
    uint256 totalBNBFee = _totalFee - liquidityFee / 2;

    uint256 amountBNBLiquidity = amountBNB * liquidityFee / totalBNBFee / 2;
    uint256 amountBNBMarketing = amountBNB * marketingFee / totalBNBFee;
    (bool sent,) = payable(super.getMarketing()).call{value: amountBNBMarketing, gas: transferGas}("");
    require(sent, "Tx failed");
    if (liquidityTokens > 0) {
      ROUTER.addLiquidityETH{value: amountBNBLiquidity}(
        address(this),
        liquidityTokens,
        0,
        0,
        super.getLPLocker(),
        block.timestamp
      );

      emit AutoLiquidity(amountBNBLiquidity, liquidityTokens);
    }
  }



  // Owner & Admins

  //Trading Settings (only Owner)
  function removeSniperTax() external onlyOwner {
    _sniperTax = false;
  }

  function enableTrading() external onlyOwner {
    tradingEnabled = true;
    emit EnableTrading();
  }

  function setIsWhitelisted(address account, bool status) external onlyOwner {
    require(account != super.getOwner() && !isMarketMaker[account]);
    isWhitelisted[account] = status;
    emit SetIsWhitelisted(account, status);
  }

  function setIsBaseFeeExempt(address account, bool exempt) external onlyOwner {
    require(account != super.getOwner() && account != super.getMarketing() && !isMarketMaker[account]);
    isBaseFeeExempt[account] = exempt;
    emit SetBaseFeeExempt(account, exempt);
  }

  function setIsFeeExempt(address account, bool exempt) external onlyOwner {
    require(account != super.getOwner() && account != super.getMarketing() && !isMarketMaker[account]);
    isFeeExempt[account] = exempt;
    emit SetFeeExempt(account, exempt);
  }

  function whatIsBaseFee() external view returns (uint256) {
    return baseFee;
  }

  function setBaseFee(uint256 newBaseFee) external onlyOwner {
    require(newBaseFee < 100, "BaseFee cannot be more than 100 = 1%");
    baseFee = newBaseFee;
    emit SetBaseFee(baseFee);
  }

  function setFees(uint256 newLiquidityFee, uint256 newMarketingFee) external onlyOwner {
    liquidityFee = newLiquidityFee;
    marketingFee = newMarketingFee;
    _totalFee = liquidityFee + marketingFee;
    emit SetFees(liquidityFee, marketingFee);
  }

  function setSwapBackSettings(bool enabled, uint256 amount) external onlyOwner {
    uint256 tokenAmount = amount * 10**decimals();
    swapEnabled = enabled;
    swapThreshold = tokenAmount;
    emit SetSwapBackSettings(enabled, amount);
  }

  function updateTransferGas(uint256 newGas) external onlyOwner {
    require(newGas >= 21000 && newGas <= 100000);
    transferGas = newGas;
    emit UpdateTransferGas(newGas);
  }

  function triggerSwapBack() external onlyOwner {
    _swapBack();
    emit TriggerSwapBack();
  }

  //recover BNB that was accidentally sent to the contract address directly
  function recoverContractFund() external onlyOwner {
    uint256 amount = address(this).balance;
    (bool sent,) = payable(super.getMarketing()).call{value: amount, gas: transferGas}("");
    require(sent, "Tx failed");
    emit RecoverContractFund(amount);
  }


  //Set New Router and Pair

  function setIsRouter(address rtrAddr, bool isRtr) external onlyOwner {
    require(rtrAddr != routerAddr);
    address oldRouterAddr = routerAddr;
    routerAddr = rtrAddr;
    ROUTER = IDexRouter(routerAddr); 
        //0xD99D1c33F9fC3444f8101754aBC46c52416550D1 testnet PCS router
        //0x10ED43C718714eb63d5aA57B78B54704E256024E mainnet PCS router
        //pinkswap router 0xBBe737384C2A26B15E23a181BDfBd9Ec49E00248
    isRouter[rtrAddr] = isRtr;
    emit SetRouter(oldRouterAddr, rtrAddr, isRtr);
  }

  function setIsMarketMaker(address pairAddr, bool isMM) external onlyOwner {
    require(pairAddr != pair);
    address oldPairAddr = pair;
    pair = pairAddr;
    isMarketMaker[pairAddr] = isMM;
    emit SetMarketMaker(oldPairAddr, pairAddr, isMM);
  }
}