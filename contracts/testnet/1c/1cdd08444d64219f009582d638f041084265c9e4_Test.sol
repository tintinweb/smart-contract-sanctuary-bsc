/**
 *Submitted for verification at BscScan.com on 2022-11-27
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.17;

contract Test {
   function getBlock() public view returns (uint) {
       return block.number;
   }
}