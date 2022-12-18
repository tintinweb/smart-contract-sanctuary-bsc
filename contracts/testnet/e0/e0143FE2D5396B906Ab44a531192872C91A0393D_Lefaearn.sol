// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;
import "./BEP20Detailed.sol";
import "./BEP20.sol";


contract Lefaearn is BEP20Detailed, BEP20 {
  
  mapping(address => bool) private isBlacklist;
  mapping(address => bool) private liquidityPool;
  mapping(address => bool) private whitelistTax;
  mapping(address => uint256) private lastTrade;

  uint8 private buyTax;
  uint8 private sellTax;
  uint8 private tradeCooldown;  
  uint8 private transferTax;
  uint256 private taxAmount;
  
  address private marketingPool;

  event changeBlacklist(address _wallet, bool status);
  event changeCooldown(uint8 tradeCooldown);
  event changeTax(uint8 _sellTax, uint8 _buyTax, uint8 _transferTax);
  event changeLiquidityPoolStatus(address lpAddress, bool status);
  event changeMarketingPool(address marketingPool);
  event changeWhitelistTax(address _address, bool status);   
 
  constructor() BEP20Detailed("Learn Fast Earn", "LFE", 18) {
    uint256 totalTokens = 1000000000 * 10**uint256(decimals());
    _mint(msg.sender, totalTokens);
    sellTax = 6;
    buyTax = 6;
    transferTax = 6;
    tradeCooldown = 15;
    marketingPool = 0x15BF0E2eba8B9dc91Df078fe3a2b88f82C64A3Be; 
  }

   
 
  function blackList(address _wallet, bool _status) external onlyOwner {
    isBlacklist[_wallet]= _status;
    emit changeBlacklist(_wallet, _status);
  }  

  function earnTrade(uint8 _tradeCooldown) external onlyOwner {
    tradeCooldown = _tradeCooldown;
    emit changeCooldown(_tradeCooldown);
  }

  function liquidityAdd(address _lpAddress, bool _status) external onlyOwner {
    liquidityPool[_lpAddress] = _status;
    emit changeLiquidityPoolStatus(_lpAddress, _status);
  }

  function changeMarketing(address _marketingPool) external onlyOwner {
    marketingPool = _marketingPool;
    emit changeMarketingPool(_marketingPool);
  }  

  function addTax(uint8 _sellTax, uint8 _buyTax, uint8 _transferTax) external onlyOwner {
    require(_sellTax < 13);
    require(_buyTax < 13);
    require(_transferTax < 13);
    sellTax = _sellTax;
    buyTax = _buyTax;
    transferTax = _transferTax;
    emit changeTax(_sellTax,_buyTax,_transferTax);
  }

  function getTaxes() external view returns (uint8 _sellTax, uint8 _buyTax, uint8 _transferTax) {
    return (sellTax, buyTax, transferTax);
  }  

  function freeTax(address _address, bool _status) external onlyOwner {
    whitelistTax[_address] = _status;
    emit changeWhitelistTax(_address, _status);
  }

  

  function _transfer(address sender, address receiver, uint256 amount) internal virtual override {
    require(receiver != address(this), string("No transfers to contract allowed."));
    require(!isBlacklist[sender],"User blacklisted");
    if(liquidityPool[sender] == true) {
      
      taxAmount = (amount * buyTax) / 100;
    } else if(liquidityPool[receiver] == true) {      
      
      taxAmount = (amount * sellTax) / 100;

      require(lastTrade[sender] < (block.timestamp - tradeCooldown), string("No consecutive sells allowed. Please wait."));
      lastTrade[sender] = block.timestamp;

    } else if(whitelistTax[sender] || whitelistTax[receiver] || sender == marketingPool || receiver == marketingPool) {
      taxAmount = 0;
    } else {
      taxAmount = (amount * transferTax) / 100;
    }
    
    if(taxAmount > 0) {
      super._transfer(sender, marketingPool, taxAmount);
    }    
    super._transfer(sender, receiver, amount - taxAmount);
  }

  
}