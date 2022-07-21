/**
 *Submitted for verification at BscScan.com on 2022-07-20
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

contract TestContract {
    function getTimeStamp() public returns (uint) {
        return block.timestamp;
    }
}