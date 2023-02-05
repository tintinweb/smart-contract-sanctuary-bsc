/**
 *Submitted for verification at BscScan.com on 2023-02-05
*/

// SPDX-License-Identifier: MIT


pragma solidity ^0.8.0;

contract Test {
    mapping(address => uint) public deposits;

    receive() external payable {
        deposits[msg.sender] += msg.value;
    }
}