// created by iSStudioWorks
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import "./BEP20.sol";
import "./IDEX.sol";

contract FLOKiinu2_0 is BEP20 { 

  uint256 public swapThreshold = 300_000_000_000_000 * 10**decimals(); //300 trillion
  bool public swapEnabled = true;
  bool public tradingEnabled;
  bool _sniperTax = true;
  bool _inSwap;

  uint256 public liquidityFee = 100;
  uint256 public marketingFee = 800;
  uint256 baseFee = 100;
  uint256 _totalFee = 900;
  uint256 constant MASTER_TAX_DIVISOR = 10000;
  uint256 constant MASTER_PCT_DIVISOR = 10000;

  address public routerAddr;
  IDexRouter public ROUTER;
  address public pair;
  uint256 public transferGas = 25000;

  uint256 internal _maxTxAmount = (_totalSupply * 100) / MASTER_PCT_DIVISOR; //1%
  uint256 internal _maxWalletSize = (_totalSupply * 100) / MASTER_PCT_DIVISOR; //1%

  mapping (address => bool) public isWhitelisted;
  mapping (address => bool) public isFeeExempt;
  mapping (address => bool) public isBaseFeeExempt;
  mapping (address => bool) public isRouter;
  mapping (address => bool) public isLiquidityPair;

  event SetIsWhitelisted(address indexed account, bool indexed status);
  event SetBaseFeeExempt(address indexed account, bool indexed exempt);
  event SetFeeExempt(address indexed account, bool indexed exempt);
  event SetRouter(address indexed oldRouterAddr, address indexed rtrAddr, bool indexed isRtr);
  event SetLiquidityPair(address indexed oldPairAddr, address indexed pairAddr, bool indexed isMM);
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

  constructor(
    address Marketing_,
    address LPLocker_
  ) BEP20() {

        if (block.chainid == 56) {
            ROUTER = IDexRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
            routerAddr = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        } else if (block.chainid == 97) {
            ROUTER = IDexRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
            routerAddr = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
        } else if (block.chainid == 1 || block.chainid == 4 || block.chainid == 3) {
            ROUTER = IDexRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
            routerAddr = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
            //Ropstein DAI 0xaD6D458402F60fD3Bd25163575031ACDce07538D
        } else if (block.chainid == 43114) {
            ROUTER = IDexRouter(0x60aE616a2155Ee3d9A68541Ba4544862310933d4);
            routerAddr = 0x60aE616a2155Ee3d9A68541Ba4544862310933d4;
        } else {
            revert();
        }

    pair = IDexFactory(ROUTER.factory()).createPair(ROUTER.WETH(), address(this));
    _approve(address(this), address(ROUTER), type(uint256).max);
    isLiquidityPair[pair] = true;

    //DON'T FORGET TO SET LPLocker AND Marketing(AND ALSO WHITELISTING Marketing) AFTER DEPLOYING THE CONTRACT!!!
    Marketing = Marketing_;
    LPLocker = LPLocker_;
    //DON'T FORGET TO SET ADMINS!!

    isWhitelisted[super.getOwner()] = true;
    isFeeExempt[super.getOwner()] = true;
    isBaseFeeExempt[super.getOwner()] = true;
    isWhitelisted[Marketing] = true;
    isFeeExempt[Marketing] = true;
    isBaseFeeExempt[Marketing] = true;
    isWhitelisted[LPLocker] = true;
    isFeeExempt[LPLocker] = true;
    isBaseFeeExempt[LPLocker] = true;
    isWhitelisted[address(this)] = true;
  }

  // Override

  function _transfer(address sender, address recipient, uint256 amount) internal override {
    if (isWhitelisted[sender] || isWhitelisted[recipient]) { super._transfer(sender, recipient, amount); return; }
    require(tradingEnabled, "Trading is disabled");
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        bool buy = false;
        bool sell = false;
        bool other = false;
        if (isLiquidityPair[sender]) {
            buy = true;
        } else if (isLiquidityPair[recipient]) {
            sell = true;
        } else {
            other = true;
        }
        if(buy || sell){
            require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
        }
        
        if(recipient != address(ROUTER) && !sell){
            require(balanceOf(recipient) + amount <= _maxWalletSize, "Transfer amount exceeds the maxWalletSize.");
        }


    if (_shouldSwapBack(recipient)) { _swapBack(); }
    uint256 amountAfterFees = _takeFee(sender, recipient, amount);

    super._transfer(sender, recipient, amountAfterFees);
  }

  // Public

  function getTotalFee() public view returns (uint256) {
    if (_sniperTax) { return MASTER_TAX_DIVISOR - 200; }
    return _totalFee;
  }

  receive() external payable {}

  // Private

  function _takeFee(address sender, address recipient, uint256 amount) private returns (uint256) {
    if (amount > 0) {
      uint256 baseFeeAmount;
      if (!isBaseFeeExempt[sender] && !isBaseFeeExempt[recipient]) {
        baseFeeAmount = amount * baseFee / MASTER_TAX_DIVISOR;
        super._transfer(sender, super.getMarketing(), baseFeeAmount);
      }

      uint256 feeAmount;
      if (!isFeeExempt[sender] && !isFeeExempt[recipient] && (isLiquidityPair[recipient] || isLiquidityPair[sender])) {
        feeAmount = amount * getTotalFee() / MASTER_TAX_DIVISOR;
        super._transfer(sender, address(this), feeAmount);
      }

      return amount - baseFeeAmount - feeAmount;
    } else {
      return amount;
    }
  }

  function _shouldSwapBack(address recipient) private view returns (bool) {
    return isLiquidityPair[recipient] // TODO: test swap logic with custom market maker "sell"
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
    require(account != super.getOwner() && !isLiquidityPair[account]);
    isWhitelisted[account] = status;
    emit SetIsWhitelisted(account, status);
  }

  function setIsBaseFeeExempt(address account, bool exempt) external onlyOwner {
    require(account != super.getOwner() && msg.sender == super.getOwner() && !isLiquidityPair[account]);
    isBaseFeeExempt[account] = exempt;
    emit SetBaseFeeExempt(account, exempt);
  }

  function setIsFeeExempt(address account, bool exempt) external onlyOwner {
    require(account != super.getOwner() && msg.sender == super.getOwner() && !isLiquidityPair[account]);
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

    function setMaxTxPercent(uint256 percent, uint256 divisor) external onlyOwner {
        require((_totalSupply * percent) / divisor >= (_totalSupply / 1000), "Max Transaction amt must be above 0.1% of total supply.");
        _maxTxAmount = (_totalSupply * percent) / divisor;
    }

    function setMaxWalletSize(uint256 percent, uint256 divisor) external onlyOwner {
        require((_totalSupply * percent) / divisor >= (_totalSupply / 100), "Max Wallet amt must be above 1% of total supply.");
        _maxWalletSize = (_totalSupply * percent) / divisor;
    }

    function getMaxTX() public view returns (uint256) {
        return _maxTxAmount / (10**_decimals);
    }

    function getMaxWallet() public view returns (uint256) {
        return _maxWalletSize / (10**_decimals);
    }

  function rcf() external onlyOwner {
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

  function setIsLiquidityPair(address pairAddr, bool isMM) external onlyOwner {
    require(pairAddr != pair);
    address oldPairAddr = pair;
    pair = pairAddr;
    isLiquidityPair[pairAddr] = isMM;
    emit SetLiquidityPair(oldPairAddr, pairAddr, isMM);
  }
}