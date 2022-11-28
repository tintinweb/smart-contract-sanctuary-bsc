/**
 *Submitted for verification at BscScan.com on 2022-11-27
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.17;

contract Test {

   uint last_block = 0;
   uint updated_block = 0;

   function runBlock() external {
       last_block = 0;
       uint block_now = block.number;
       while (last_block >= 3) {
         last_block = block.number;
         updated_block = block_now;
      }
   }

   function getBlock() public view returns (uint[] memory) {
      uint[] memory blocks = new uint[](2);
      blocks[0] = last_block;
      blocks[1] = updated_block;

      return blocks;
   }
}