// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Test {
    constructor() {}

    event MyEvent(address from, uint256 value);

    function createEvent(uint256 val) public{
        emit MyEvent(msg.sender, val);
    }
}