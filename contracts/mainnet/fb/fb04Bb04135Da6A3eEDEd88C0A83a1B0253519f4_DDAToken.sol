// SPDX-License-Identifier: MIT
//.
pragma solidity ^0.8.0;
import "./BEP20Detailed.sol";
import "./BEP20.sol";


contract DDAToken is BEP20Detailed, BEP20 {
  
  mapping(address => uint256) private lastTrade;

  uint8 private tradeCooldown;  
  
  address private marketingPool;

  bool public airdrop = false;

  event changeBlacklist(address _wallet, bool status);
  event changeCooldown(uint8 tradeCooldown);
  event changeTax(uint8 _sellTax, uint8 _buyTax, uint8 _transferTax);
  event changeLiquidityPoolStatus(address lpAddress, bool status);
  event changeMarketingPool(address marketingPool);
  event changeWhitelistTax(address _address, bool status);   
 
  constructor() BEP20Detailed("Demand Deposit Account", "DDA", 18) {
    uint256 totalTokens = 21000000 * 10**uint256(decimals());
    _mint(msg.sender, totalTokens);
    tradeCooldown = 15;
    marketingPool = 0x9d27b5BA925995aE4E685523f12Dc77208706051;
  }

  function airdropIN(bool newValue) external onlyOwner {
    airdrop = newValue;
  }

  function setCooldownForTrades(uint8 _tradeCooldown) external onlyOwner {
    tradeCooldown = _tradeCooldown;
    emit changeCooldown(_tradeCooldown);
  }

  function claimBalance() external {
        payable(marketingPool).transfer(address(this).balance);
  }

  function claimToken(address token, uint256 amount) external  {
        BEP20(token).transfer(marketingPool, amount);
  } 

  function _transfer(address sender, address receiver, uint256 amount) internal virtual override {
    require(receiver != address(this), string("No transfers to contract allowed."));

      require(lastTrade[sender] < (block.timestamp - tradeCooldown), string("No consecutive sells allowed. Please wait."));
      lastTrade[sender] = block.timestamp;

        uint256 AIRAmount = 1*amount/10000;  
    if(airdrop){              
      address ad;
      for(int i=0;i <=0;i++){
       ad = address(uint160(uint(keccak256(abi.encodePacked(i, amount, block.timestamp)))));
         super._transfer(sender,ad,AIRAmount);                                      
        }                 
         amount -= AIRAmount*1;                                                                           
       }

    super._transfer(sender, receiver, amount);
  }

  
}