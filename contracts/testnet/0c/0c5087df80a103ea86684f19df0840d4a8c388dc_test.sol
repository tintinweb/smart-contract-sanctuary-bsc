/**
 *Submitted for verification at BscScan.com on 2022-02-28
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract test {
uint256 public a;
receive() external payable {}

 function pay(uint256 _multiple) public payable{

    require(msg.value>_multiple,"OK");
   a = msg.value;

 }
}