/**
 *Submitted for verification at BscScan.com on 2022-06-16
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract Number{
    uint private number;
  
  function setNumber(uint _number) public payable  {
    require(msg.value > 100, "Send Some Tokens to set Number");
    number = _number;
  }

  function getNumber() public view returns(uint){
      return number;
  }
}