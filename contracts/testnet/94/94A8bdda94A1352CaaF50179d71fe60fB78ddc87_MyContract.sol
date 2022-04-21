/**
 *Submitted for verification at BscScan.com on 2022-04-21
*/

pragma solidity ^0.5.4;

interface IERC20 {
  function transfer(address recipient, uint256 amount) external;
  function balanceOf(address account) external view returns (uint256);
  function transferFrom(address sender, address recipient, uint256 amount) external ;
  function decimals() external view returns (uint8);
}


contract  MyContract {
  IERC20 usdt;
  constructor(IERC20 _usdt) public  {
    usdt = _usdt;
  }

  event TransferOut(address toAddr, uint amount);
  event TransferIn(address fromAddr, uint amount);
  
  
  function transferOut(address toAddr, uint amount) external {
    usdt.transfer(toAddr, amount);
    emit TransferOut(toAddr,amount);
  }
  
  function transferIn(address fromAddr, uint amount) external {
    usdt.transferFrom(msg.sender,fromAddr, amount);
    emit TransferIn(fromAddr,amount);
  }
  
}