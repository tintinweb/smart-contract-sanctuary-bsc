/**
 *Submitted for verification at BscScan.com on 2022-07-18
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract Test  {
  function test() external view returns(uint256[9] memory) {
      uint256[9] memory count;
      count[1] = 100;
      return count;
  }
}