/**
 *Submitted for verification at BscScan.com on 2022-09-28
*/

pragma solidity ^0.8.15;
// SPDX-License-Identifier: MIT
contract ExampleCoin { 

   event blockNumber(uint timestamp);
    
    function findTimestamp() public {
      emit blockNumber(block.timestamp);
    }
}