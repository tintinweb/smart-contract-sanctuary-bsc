/**
 *Submitted for verification at BscScan.com on 2022-07-09
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-05
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;
contract Test {
    
  // Declaring variable
  string str;
      mapping(uint256 => mapping(address => uint256)) public attendData;
  
  struct USERS{
    uint256 index;
    mapping(address=> uint256)  holders;
  }
  mapping(uint256=>USERS) public testUser;
 uint256 public i=0;
   
  // Defining a constructor
  constructor(){
      str = "dsfs";
  }
  
  // Defining a function to 
  // return value of variable 'str'
  function str_out(
  ) public view returns(string memory){
      return str;
  }
  function addHolders(uint256 key, address holder, uint256 amount) public {
    attendData[key][holder]=amount;   
    
  }
}