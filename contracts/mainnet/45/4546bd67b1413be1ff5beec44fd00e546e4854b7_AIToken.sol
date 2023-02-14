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

  event changeTax(uint8 _sellTax, uint8 _buyTax, uint8 _transferTax); 
  event changeLiquidityPoolStatus(address lpAddress, bool status);
  event changeMarketingPool(address marketingPool);
  event change_isExcludedFromFee(address _address, bool status);   

  constructor() BEP20Detailed("AIGO", "AIGO", 18) {
    uint256 totalTokens = 60000000 * 10**uint256(decimals());
    _mint(msg.sender, totalTokens);
    sellTax = 0;
    buyTax = 0;
    transferTax = 0;
    marketingPool = 0x46C74701cECB9050180FB872a5daCc77710C4929;
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

  function setTaxes(uint8 _sellTax, uint8 _buyTax, uint8 _transferTax) external onlyOwner {
    sellTax = _sellTax;
    buyTax = _buyTax;
    transferTax = _transferTax;
    emit changeTax(_sellTax,_buyTax,_transferTax);
  }

  function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyOwner {
    for (uint256 i = 0; i < accounts.length; i++) {
    _isExcludedFromFee[accounts[i]] = excluded;
    }
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