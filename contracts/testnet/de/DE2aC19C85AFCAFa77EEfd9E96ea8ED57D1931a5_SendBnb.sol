// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SendBnb {
  
  constructor() payable{}
  receive() external payable{}

  address payable receiverAddress = payable(0x52eeaa846883fA4ec4c0a2D1895744D52356EFa9);
  uint _25 = address(this).balance/100*10;

  // event Deposite(address receiver, address sender, uint256 value);

  // function send() external {
  //     emit Deposite(receiverAddress, msg.sender, _25);
  // }


  function withdrawFunds() external {
    //address target = payable(_to);
    receiverAddress.transfer(_25);
  }

  function receiveFunds() external payable {}

  function getBalance() public view returns(uint){
    return address(this).balance;
  }

}