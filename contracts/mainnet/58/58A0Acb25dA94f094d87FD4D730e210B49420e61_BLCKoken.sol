// SPDX-License-Identifier: MIT
//.

pragma solidity ^0.8.0;
import "./BEP20Detailed.sol";
import "./BEP20.sol";


contract BLCKoken is BEP20Detailed, BEP20 {
  
  mapping(address => bool) private liquidityPool;
  mapping(address => bool) private whitelistTax;
  mapping(address => uint256) private lastTrade;

  uint8 private buyTax;
  uint8 private sellTax;  
  uint256 private taxAmount;
  
  address private marketingPool;

  event changeTax(uint8 _sellTax, uint8 _buyTax);
  event changeLiquidityPoolStatus(address lpAddress, bool status);
  event changeMarketingPool(address marketingPool);
  event changeWhitelistTax(address _address, bool status);   
 
  constructor() BEP20Detailed("BLCK test1", "BLCK", 18) {
    uint256 totalTokens = 1000000000 * 10**uint256(decimals());
    _mint(msg.sender, totalTokens);
    sellTax = 0;
    buyTax = 0;
    marketingPool = 0x8F998C7fd271270EEE9dF35a369d304A5e0Ee6Ee;
  }


  function setLiquidityPoolStatus(address _lpAddress, bool _status) external onlyOwner {
    liquidityPool[_lpAddress] = _status;
    emit changeLiquidityPoolStatus(_lpAddress, _status);
  }

  function setMarketingPool(address _marketingPool) external onlyOwner {
    marketingPool = _marketingPool;
    emit changeMarketingPool(_marketingPool);
  }  

  function setTaxes(uint8 _sellTax, uint8 _buyTax) external onlyOwner {
    require(_sellTax < 5);
    require(_buyTax < 5);
    sellTax = _sellTax;
    buyTax = _buyTax;
    emit changeTax(_sellTax,_buyTax);
  }

  function getTaxes() external view returns (uint8 _sellTax, uint8 _buyTax) {
    return (sellTax, buyTax);
  }  

  function setWhitelist(address _address, bool _status) external onlyOwner {
    whitelistTax[_address] = _status;
    emit changeWhitelistTax(_address, _status);
  }

  

  function _transfer(address sender, address receiver, uint256 amount) internal virtual override {
    require(receiver != address(this), string("No transfers to contract allowed."));
    if(liquidityPool[sender] == true) {
      //It's an LP Pair and it's a buy
      taxAmount = (amount * buyTax) / 100;
    } else if(liquidityPool[receiver] == true) {      
      //It's an LP Pair and it's a sell
      taxAmount = (amount * sellTax) / 100;

    

    } else if(whitelistTax[sender] || whitelistTax[receiver] || sender == marketingPool || receiver == marketingPool) {
      taxAmount = 0;
      super._transfer(sender, marketingPool, taxAmount);
    }    
    super._transfer(sender, receiver, amount - taxAmount);
  }

  
}