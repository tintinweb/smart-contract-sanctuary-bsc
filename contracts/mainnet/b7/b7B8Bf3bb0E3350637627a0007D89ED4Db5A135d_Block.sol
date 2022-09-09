/**
 *Submitted for verification at BscScan.com on 2022-09-09
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

contract Block {
    function getBlock() public view returns(uint256){
        return block.timestamp;
    }
}