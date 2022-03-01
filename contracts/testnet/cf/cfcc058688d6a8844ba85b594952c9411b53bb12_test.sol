/**
 *Submitted for verification at BscScan.com on 2022-03-01
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract test {
uint256 public a;
uint256 public b;
receive() external payable {}

 function pay(uint256 _multiple) public payable returns(uint256)  {

    require(msg.value>_multiple,"OK");
   a = msg.value;
    return a ;
 }

 function buy(uint256 _b) public   {

    b = _b + pay(_b);
    

 }

}