// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Test {

    uint256 value;
    event MyEvent(address from, uint256 value);

    function createEvent(uint256 val) public{
        value = val;
        emit MyEvent(msg.sender, val);
    }
}