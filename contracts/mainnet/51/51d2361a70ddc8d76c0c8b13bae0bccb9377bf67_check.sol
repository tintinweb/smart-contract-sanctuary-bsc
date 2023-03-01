/**
 *Submitted for verification at BscScan.com on 2023-03-01
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


contract check {

    bool private initialized;
    uint256 private testValue;
    uint256 private startedAt;
    address private owner;

    constructor() {
        owner = msg.sender;
        startedAt = block.timestamp;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this.");
        _;
    }

    function initialize() public payable onlyOwner {
        require(!initialized && testValue == 0, "Contract already initialized.");
        initialized = true;
        testValue = 12345;
    }

    function checkTestValue() public returns(uint256 tValue, uint256 started) {
        require(initialized, "Not initialized yet.");
        return (testValue, startedAt);
    }

    function deleteContract() public onlyOwner {
        address sendTo = msg.sender;
        selfdestruct(payable(sendTo));
    }

    receive() external payable{}
}