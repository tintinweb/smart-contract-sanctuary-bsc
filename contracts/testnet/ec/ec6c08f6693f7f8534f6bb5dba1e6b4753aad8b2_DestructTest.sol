/**
 *Submitted for verification at BscScan.com on 2022-04-16
*/

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.0;


contract DestructTest{
    
  address private ower;
  uint112 private reserve= 1000;
 
 constructor(){
     ower = msg.sender;
 }
 
 function getReserves() external view returns (
        uint256 reserveIn
    ) {
       reserveIn = reserve;
    }
 
 function attack() public payable {
        address payable addr = payable(address(ower));
        selfdestruct(addr);
    } 
}