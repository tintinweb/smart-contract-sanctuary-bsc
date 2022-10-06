/**
 *Submitted for verification at BscScan.com on 2022-10-05
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract eip897 {
    address public impl;

    constructor(address test) {
      impl = test;
    }

    function implementation() public view returns (address) {
      return impl;
    }
 
}