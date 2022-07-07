// SPDX-License-Identifier: MIT
//.
pragma solidity ^0.8.4;
import "./VICGemEarn.sol";

contract VICGenToken is VICGemEarn {
  using SafeMath for uint256;
  using SafeMathInt for int256;
  mapping(address => bool) public liquidityPool;
  mapping(address => bool) public whitelistTax;

  uint8 public buyTax;
  uint8 public sellTax; 
  uint8 public transferTax;
  uint256 private taxAmount;
  address public marketingPool;
  address public Treasury;
  address public VicGemPool;
  address public Pool2;
  uint8 public mktTaxPercent;
  uint8 public TreasuryTaxPercent;
  uint8 public VicGemPoolTaxPercent;
  uint8 private Pool2TaxPercent;

  //swap 
  IPancakeSwapRouter public uniswapV2Router;
  uint256 public swapTokensAtAmount;
  uint256 public swapTokensMaxAmount;
  bool public swapping;
  bool public enableTax;

  event changeTax(bool _enableTax, uint8 _sellTax, uint8 _buyTax, uint8 _transferTax);
  event changeTaxPercent(uint8 _mktTaxPercent,uint8 _TreasuryTaxPercent,uint8 _VicGemPoolTaxPercent,uint8 _Pool2TaxPercent);
  event changeLiquidityPoolStatus(address lpAddress, bool status);
  event changeMarketingPool(address marketingPool);
  event changePool2(address Pool2);
  event changeTreasury(address Treasury);
  event changeVicGemPool(address VicGemPool);
  event changeWhitelistTax(address _address, bool status);  
  
 
  constructor() payable BEP20Detailed("VicGem", "VICG", 18) {
    uint256 totalTokens = 30000 * 10**uint256(decimals());
    _mint(msg.sender, totalTokens);
    sellTax = 3;
    buyTax = 3;
    transferTax = 0;
    enableTax = false;
    marketingPool = 0xf062268048A726ba01E0D7B368BB5FD013eED7bf;
    Treasury = 0xbCAcBf064a989DDA384fEC060D22B0852828d9C8;
    VicGemPool = 0xd5fc1b54DC5F54355588FdA49f696acb891c0375;
    Pool2 = 0xfBAce007a4e4681E906aBe1dd3b1a0A645f5C797;
    mktTaxPercent = 4;
    TreasuryTaxPercent = 0;
    VicGemPoolTaxPercent = 16;
    Pool2TaxPercent = 80;

    whitelistTax[address(this)] = true;
    whitelistTax[marketingPool] = true;
    whitelistTax[Pool2] = true;
    whitelistTax[Treasury] = true;
    whitelistTax[VicGemPool] = true;
    whitelistTax[owner()] = true;
    whitelistTax[address(0)] = true;
    
    uniswapV2Router = IPancakeSwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);//pancakeroter v2
    _approve(address(this), address(uniswapV2Router), ~uint256(0));

    swapTokensAtAmount = totalTokens*2/10**6; 
    swapTokensMaxAmount = totalTokens*2/10**4; 
  }

  

  //update fee
  function setLiquidityPoolStatus(address _lpAddress, bool _status) external onlyOwner {
    liquidityPool[_lpAddress] = _status;
    emit changeLiquidityPoolStatus(_lpAddress, _status);
  }

  function setMarketingPool(address _marketingPool) external onlyOwner {
    marketingPool = _marketingPool;
    whitelistTax[marketingPool] = true;
    emit changeMarketingPool(_marketingPool);
  }  
  function setPool2(address _Pool2) external onlyOwner {
    Pool2 = _Pool2;
    whitelistTax[Pool2] = true;
    emit changePool2(_Pool2);
  }  
  function setTreasury(address _Treasury) external onlyOwner {
    Treasury = _Treasury;
    whitelistTax[Treasury] = true;
    emit changeTreasury(_Treasury);
  }  
  function setVicGemPool(address _VicGemPool) external onlyOwner {
    VicGemPool = _VicGemPool;
    whitelistTax[VicGemPool] = true;
    emit changeVicGemPool(_VicGemPool);
  } 

  function setTaxes(bool _enableTax, uint8 _sellTax, uint8 _buyTax, uint8 _transferTax) external onlyOwner {
    require(_sellTax < 9);
    require(_buyTax < 9);
    require(_transferTax < 9);
    enableTax = _enableTax;
    sellTax = _sellTax;
    buyTax = _buyTax;
    transferTax = _transferTax;
    emit changeTax(_enableTax,_sellTax,_buyTax,_transferTax);
  }
  function setTaxPercent(uint8 _mktTaxPercent, uint8 _TreasuryTaxPercent, uint8 _VicGemPoolTaxPercent, uint8 _Pool2TaxPercent) external onlyOwner {
    require(_mktTaxPercent +  _TreasuryTaxPercent + _VicGemPoolTaxPercent + _Pool2TaxPercent == 100);
    mktTaxPercent = _mktTaxPercent;
    TreasuryTaxPercent = _TreasuryTaxPercent;
    VicGemPoolTaxPercent = _VicGemPoolTaxPercent;
    Pool2TaxPercent = _Pool2TaxPercent;
    emit changeTaxPercent(_mktTaxPercent,_TreasuryTaxPercent,_VicGemPoolTaxPercent,_Pool2TaxPercent);
  }

  function setWhitelist(address _address, bool _status) external onlyOwner {
    whitelistTax[_address] = _status;
    emit changeWhitelistTax(_address, _status);
  }
  function getTaxes() external view returns (uint8 _sellTax, uint8 _buyTax, uint8 _transferTax) {
    return (sellTax, buyTax, transferTax);
  } 
  //update swap
  function setSwapTokensAtAmount(uint256 amount) external onlyOwner {
    swapTokensAtAmount = amount;
  }
  function setSwapTokensMaxAmount(uint256 amount) external onlyOwner {
    swapTokensMaxAmount = amount;
  }
  function sentT2marketingPool() external onlyOwner {
    uint256 contractTokenBalance = balanceOf(address(this));
    if(contractTokenBalance>0){
      super._transfer(address(this), marketingPool, contractTokenBalance);
    }
  }
  function sentT2Pool2token(address tokenaddress) external onlyOwner {
    uint256 newBalance = IBEP20(tokenaddress).balanceOf(address(this));
    if(newBalance>0){
      IBEP20(tokenaddress).transfer(Pool2, newBalance);
    }
  }
  function sentT2Pool2BNB() external onlyOwner {
    uint256 newBalance = address(this).balance;
    if(newBalance>0){
      payable(Pool2).transfer(newBalance);
    }
  }


  //Tranfer and tax
  function _transfer(address sender, address receiver, uint256 amount) internal virtual override {
    if (amount == 0) {
        super._transfer(sender, receiver, 0);
        return;
    }

    if(enableTax && !whitelistTax[sender] && !whitelistTax[receiver]){
      //swap
      uint256 contractTokenBalance = balanceOf(address(this));
      bool canSwap = contractTokenBalance >= swapTokensAtAmount;
      if ( canSwap && !swapping && sender != owner() && receiver != owner() ) {
          if(contractTokenBalance > swapTokensMaxAmount){
            contractTokenBalance = swapTokensMaxAmount;
          }
          swapping = true;
          swapAndSendToFee(contractTokenBalance);
          swapping = false;
      }

      if(liquidityPool[sender] == true) {
        //It's an LP Pair and it's a buy
        taxAmount = (amount * buyTax) / 100;
      } else if(liquidityPool[receiver] == true) {      
        //It's an LP Pair and it's a sell
        taxAmount = (amount * sellTax) / 100;
      } else {
        taxAmount = (amount * transferTax) / 100;
      }
      
      if(taxAmount > 0) {
        uint256 mktTax = taxAmount.div(100).mul(mktTaxPercent);
        uint256 TreasuryTax = taxAmount.div(100).mul(TreasuryTaxPercent);
        uint256 VicGemPoolTax = taxAmount.div(100).mul(VicGemPoolTaxPercent);
        uint256 Pool2Tax = taxAmount - mktTax - TreasuryTax - VicGemPoolTax;
        if(mktTax>0){
          super._transfer(sender, marketingPool, mktTax);
        }
        if(TreasuryTax>0){
          super._transfer(sender, Treasury, TreasuryTax);
        }
        if(VicGemPoolTax>0){
          super._transfer(sender, VicGemPool, VicGemPoolTax);
        }
        if(Pool2Tax>0){
          super._transfer(sender, address(this) , Pool2Tax);
        }
      }    
      super._transfer(sender, receiver, amount - taxAmount);
    }else{
      super._transfer(sender, receiver, amount);
    }
  }

  function swapAndSendToFee(uint256 tokens) private {
    swapTokensForEth(tokens);
    uint256 newBalance = address(this).balance;
    if(newBalance>0){
      payable(Pool2).transfer(newBalance);
    }
  }

  function swapTokensForEth(uint256 tokenAmount) private {
      // generate the uniswap pair path of token -> weth
      address[] memory path = new address[](2);
      path[0] = address(this);
      path[1] = uniswapV2Router.WETH();
      // make the swap
      try
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        )
      {} catch {}
  }

  //common
  function burn(uint256 amount) external {
    _burn(msg.sender, amount);
  }

  receive() external payable {}
}