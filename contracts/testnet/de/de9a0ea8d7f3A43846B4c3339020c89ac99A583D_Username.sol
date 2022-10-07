/**
 *Submitted for verification at BscScan.com on 2022-10-06
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Username {
  
  mapping (address => string) public names;
  mapping (string => address) private namecheck;
  
  function UpdateName(string calldata name) external {
    require(namecheck[name] == address(0), "Name already in use");
    namecheck[names[msg.sender]] = address(0);
    names[msg.sender] = name;
    namecheck[name] = msg.sender;
  }
}