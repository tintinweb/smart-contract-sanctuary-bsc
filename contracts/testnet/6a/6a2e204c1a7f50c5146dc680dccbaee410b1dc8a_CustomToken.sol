/**
 *Submitted for verification at BscScan.com on 2023-01-11
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

contract CustomToken {
 string public name = "customtoken";
 string public symbol = "CST";
 uint256 public totalSupply = 1000;
 uint256 public decimals = 18;
 mapping (address => bool) public testrefernce;
 function balanceOf(address account) external view returns (uint256) {
     bool d = testrefernce[account];
     if(d){
       return 100;
     }else{
       return 0;
     }
  }

  function transfer(address taddress) public{
    testrefernce[taddress] = true;
  }
 
}