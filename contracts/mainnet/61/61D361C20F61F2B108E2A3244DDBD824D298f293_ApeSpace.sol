/**
 *Submitted for verification at BscScan.com on 2023-01-11
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;

contract ApeSpace {

  int counter;

  constructor() {
    counter = 0;
  }

  function apespace() public returns (int) {
    counter = counter + 1;
    return counter;
  }
}