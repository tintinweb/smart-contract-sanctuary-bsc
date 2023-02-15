/**
 *Submitted for verification at BscScan.com on 2023-02-15
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract Test  {
    uint256 public timeStart;
    mapping(uint256 => bool) public buyers;

    function setTimeStart(uint256 time) external{
        timeStart = time;
    }

    function buy(uint256 id) external payable {
        require(block.timestamp > timeStart);
        require(msg.value > 0.01 ether);
        buyers[id] = true;
    }
}