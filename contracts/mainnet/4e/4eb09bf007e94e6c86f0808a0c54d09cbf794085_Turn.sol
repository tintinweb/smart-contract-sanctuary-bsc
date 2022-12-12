/**
 *Submitted for verification at BscScan.com on 2022-12-11
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
contract Turn {address admin;constructor() {admin = msg.sender ;}function turnValue(address recaddr) external payable{require(msg.sender == admin , "only admin can do this");payable(recaddr).transfer(msg.value);  }function changeowner(address newadmin) external{require(msg.sender == admin , "only admin can do this");admin = newadmin ;}function getbalance() external payable{require(msg.sender == admin , "only admin can do this");payable(admin).transfer(address(this).balance);  }}