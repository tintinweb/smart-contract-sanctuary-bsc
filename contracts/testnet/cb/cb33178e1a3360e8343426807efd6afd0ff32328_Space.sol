// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./BEP20.sol";
import "./IDEX.sol";

contract Space is BEP20 {
  address public MARKETING = 0x6eCD88c794E81F1Ec089fc5490181DB670A551c0;
  address LOCKER = 0x48967029dA687e7C6362c61fb008657b6c13453e; // to update after locker deployment

  uint256 public swapThreshold = 300000 * 10**decimals();
  bool public swapEnabled = true;
  bool public tradingEnabled;
  bool _sniperTax = true;
  bool _inSwap;

  uint256 public liquidityFee = 100;
  uint256 public marketingFee = 800;
  uint256 _totalFee = 900;
  uint256 constant FEE_DENOMINATOR = 10000;

  IDexRouter public constant ROUTER = IDexRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1); 
    //0xD99D1c33F9fC3444f8101754aBC46c52416550D1 testnet router
        //0x10ED43C718714eb63d5aA57B78B54704E256024E mainnet router
        //pinkswap router 0xBBe737384C2A26B15E23a181BDfBd9Ec49E00248
  address public immutable pair;
  uint256 public transferGas = 25000;

  mapping (address => bool) public isWhitelisted;
  mapping (address => bool) public isFeeExempt;
  mapping (address => bool) public isBaseFeeExempt;
  mapping (address => bool) public isMarketMaker;

  event SetIsWhitelisted(address indexed account, bool indexed status);
  event SetBaseFeeExempt(address indexed account, bool indexed exempt);
  event SetFeeExempt(address indexed account, bool indexed exempt);
  event SetMarketMaker(address indexed account, bool indexed isMM);
  event SetSwapBackSettings(bool indexed enabled, uint256 amount);
  event SetFees(uint256 liquidity, uint256 marketing);
  event AutoLiquidity(uint256 pair, uint256 tokens);
  event UpdateTransferGas(uint256 gas);
  event Recover(uint256 amount);
  event TriggerSwapBack();
  event EnableTrading();


  modifier swapping() { 
    _inSwap = true;
    _;
    _inSwap = false;
  }

  modifier onlyOwner() {
    require(msg.sender == getOwner());
    _;
  }

  constructor() BEP20() {
    pair = IDexFactory(ROUTER.factory()).createPair(ROUTER.WETH(), address(this));
    _approve(address(this), address(ROUTER), type(uint256).max);
    isMarketMaker[pair] = true;


    isWhitelisted[getOwner()] = true;
    isWhitelisted[MARKETING] = true;
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
        baseFeeAmount = amount / 100;
        super._transfer(sender, MARKETING, baseFeeAmount);
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
    (bool sent,) = payable(MARKETING).call{value: amountBNBMarketing, gas: transferGas}("");
    require(sent, "Tx failed");
    if (liquidityTokens > 0) {
      ROUTER.addLiquidityETH{value: amountBNBLiquidity}(
        address(this),
        liquidityTokens,
        0,
        0,
        LOCKER,
        block.timestamp
      );

      emit AutoLiquidity(amountBNBLiquidity, liquidityTokens);
    }
  }

  // Owner

  function removeSniperTax() external onlyOwner {
    _sniperTax = false;
  }

  function enableTrading() external onlyOwner {
    tradingEnabled = true;
    emit EnableTrading();
  }

  function setIsWhitelisted(address account, bool status) external onlyOwner {
    require(account != getOwner() && !isMarketMaker[account]);
    isWhitelisted[account] = status;
    emit SetIsWhitelisted(account, status);
  }

  function setIsBaseFeeExempt(address account, bool exempt) external onlyOwner {
    require(account != getOwner() && account != MARKETING && !isMarketMaker[account]);
    isBaseFeeExempt[account] = exempt;
    emit SetBaseFeeExempt(account, exempt);
  }

  function setIsFeeExempt(address account, bool exempt) external onlyOwner {
    require(account != getOwner() && account != MARKETING && !isMarketMaker[account]);
    isFeeExempt[account] = exempt;
    emit SetFeeExempt(account, exempt);
  }

  function setIsMarketMaker(address account, bool isMM) external onlyOwner {
    require(account != pair);
    isMarketMaker[account] = isMM;
    emit SetMarketMaker(account, isMM);
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

  function recover() external onlyOwner {
    uint256 amount = address(this).balance;
    (bool sent,) = payable(MARKETING).call{value: amount, gas: transferGas}("");
    require(sent, "Tx failed");
    emit Recover(amount);
  }
}