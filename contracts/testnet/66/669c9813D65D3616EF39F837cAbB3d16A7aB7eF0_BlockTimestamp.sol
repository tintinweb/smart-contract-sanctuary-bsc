/**
 *Submitted for verification at BscScan.com on 2022-09-22
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

contract BlockTimestamp {
    function getTime(uint256 seconds_) external view returns (uint256) {
        return block.timestamp + seconds_;
    }
}