/**
 *Submitted for verification at BscScan.com on 2022-05-17
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

contract variable {
  string private a;
  uint256 private b;
  
  constructor(string memory _a) {
      a = _a;
  }

  function get() public view returns(string memory){
      return a;  }
}