/**
 *Submitted for verification at BscScan.com on 2022-09-16
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.15;

contract SimpleStorage {
  
  uint public number;

  function set(uint _number) external {
    number = _number;
  }

  function get() external view returns(uint) {
    return number;
  } 

}