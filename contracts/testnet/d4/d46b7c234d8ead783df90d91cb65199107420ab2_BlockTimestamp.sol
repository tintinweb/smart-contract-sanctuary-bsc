/**
 *Submitted for verification at BscScan.com on 2023-01-14
*/

pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT

contract BlockTimestamp {
    function getTimeStamp() external view returns(uint){
        return block.timestamp;
    }
}