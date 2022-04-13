/**
 *Submitted for verification at BscScan.com on 2022-04-13
*/

pragma solidity ^0.8.7;
// SPDX-License-Identifier: MIT

contract FeeCollector {
    address public owner;
    uint256 public balance;

    constructor() {
        owner = msg.sender;
    }

    receive() payable external {
        balance = balance + msg.value;

    }
}