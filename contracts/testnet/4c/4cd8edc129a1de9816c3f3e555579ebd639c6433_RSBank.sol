/**
 *Submitted for verification at BscScan.com on 2022-12-21
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract RSBank 
{

  event Deposti (uint amount);
  event Withdraw (uint amount);

  address public owner = msg.sender;
  receive() external payable{
    emit Deposti(msg.value);
  }

  function withdraw() external{
    require(msg.sender == owner, "Nope!");
    emit Withdraw(address(this).balance);
    selfdestruct(payable(msg.sender));
  }

  function getBalance() external view returns(uint){
    return address(this).balance;
  }
}