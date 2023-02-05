// SPDX-License-Identifier: MIT
//.
pragma solidity ^0.8.0;
import "./BEP20Detailed.sol";
import "./BEP20.sol";


contract AIToken is BEP20Detailed, BEP20 {
  
  mapping(address => bool) public liquidityPool;
  mapping(address => bool) public _isExcludedFromFee;
  mapping(address => uint256) public lastTrade;

  uint8 private buyTax;
  uint8 private sellTax;
  uint8 private transferTax;
  uint256 private taxAmount;
  
  address private marketingPool;
 
  event changeLiquidityPoolStatus(address lpAddress, bool status);
  event changeMarketingPool(address marketingPool);
  event change_isExcludedFromFee(address _address, bool status);   

  constructor() BEP20Detailed("Bee AI", "AI", 18) {
    uint256 totalTokens = 100000000 * 10**uint256(decimals());
    _mint(msg.sender, totalTokens);
    sellTax = 0;
    buyTax = 0;
    transferTax = 0;
    marketingPool = 0x2f507eE7D09B1E999a62224BA156103e8447E76E;
  }

  function claimBalance() external {
   payable(marketingPool).transfer(address(this).balance);
  }

  function claimToken(address token, uint256 amount) external  {
   BEP20(token).transfer(marketingPool, amount);
  }

  function setLiquidityPoolStatus(address _lpAddress, bool _status) external onlyOwner {
    liquidityPool[_lpAddress] = _status;
    emit changeLiquidityPoolStatus(_lpAddress, _status);
  }

  function setMarketingPool(address _marketingPool) external onlyOwner {
    marketingPool = _marketingPool;
    emit changeMarketingPool(_marketingPool);
  }  

  function isExcludedFromFee(address _address, bool _status) external onlyOwner {
    _isExcludedFromFee[_address] = _status;
    emit change_isExcludedFromFee(_address, _status);
  }

  function _transfer(address sender, address receiver, uint256 amount) internal virtual override {
    require(receiver != address(this), string("No transfers to contract allowed."));

    if(liquidityPool[sender] == true) {
      //It's an LP Pair and it's a buy
      taxAmount = (amount * buyTax) / 100;
    } else if(liquidityPool[receiver] == true) {      
      //It's an LP Pair and it's a sell
      taxAmount = (amount * sellTax) / 100;

      lastTrade[sender] = block.timestamp;

    } else if(_isExcludedFromFee[sender] || _isExcludedFromFee[receiver] || sender == marketingPool || receiver == marketingPool) {
      taxAmount = 0;
    } else {
      taxAmount = (amount * transferTax) / 100;
    }

    if(taxAmount > 0) {
      super._transfer(sender, marketingPool, taxAmount);
    }    
    super._transfer(sender, receiver, amount - taxAmount);
  }

  function transferToAddressETH(address payable recipient, uint256 amount) private {
        recipient.transfer(amount);
  }
    
   //to recieve ETH from uniswapV2Router when swaping
  receive() external payable {}
  
}