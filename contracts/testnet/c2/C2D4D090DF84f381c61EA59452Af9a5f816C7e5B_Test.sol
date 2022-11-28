/**
 *Submitted for verification at BscScan.com on 2022-11-27
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.17;

contract Test {

    uint256 len = 0;

   function getBlock() external {
       len = 0;
       uint block_now = block.number;
       while (block_now == block.number) {
         len++;
      }
   }
}