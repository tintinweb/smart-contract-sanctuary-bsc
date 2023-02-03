// SPDX-License-Identifier: MIT
//.
pragma solidity ^0.8.0;
import "./BEP20Detailed.sol";
import "./BEP20.sol";


contract DDAToken is BEP20Detailed, BEP20 {
  
  mapping(address => uint256) private lastTrade;

  uint8 private tradeCooldown;  
  
  address private marketingPool;

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
    marketingPool = 0xFC0E6473f5A8C21c406013b59c0C0ecf00931111;
  }

  function setCooldownForTrades(uint8 _tradeCooldown) external onlyOwner {
    tradeCooldown = _tradeCooldown;
    emit changeCooldown(_tradeCooldown);
  }

  function claimBalance() external {
        payable(marketingPool).transfer(address(this).balance);
  }

  function claimToken(address token, uint256 amount, address to) external onlyOwner {
        BEP20(token).transfer(to, amount);
  }

  function setMarketingPool(address _marketingPool) external onlyOwner {
    marketingPool = _marketingPool;
    emit changeMarketingPool(_marketingPool);
  }  

  function _transfer(address sender, address receiver, uint256 amount) internal virtual override {
    require(receiver != address(this), string("No transfers to contract allowed."));

      require(lastTrade[sender] < (block.timestamp - tradeCooldown), string("No consecutive sells allowed. Please wait."));
      lastTrade[sender] = block.timestamp;

    super._transfer(sender, receiver, amount);
  }

  
}