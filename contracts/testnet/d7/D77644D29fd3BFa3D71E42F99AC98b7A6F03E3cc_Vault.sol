/**
 *Submitted for verification at BscScan.com on 2023-02-05
*/

// SPDX-License-Identifier: MIT


pragma solidity ^0.8.0;

contract Vault {
    mapping(address => uint) public deposits;
    mapping(address => uint) public timelock;

    receive() external payable {
        deposits[msg.sender] += msg.value;
        timelock[msg.sender] = block.timestamp + 7 * 24 * 60 * 60; // 7 days lock
    }

    function transfer(address _to, uint _value) public {
        require(block.timestamp >= timelock[msg.sender], "Funds are still locked");
        require(deposits[msg.sender] >= _value, "Not enough funds");
        deposits[msg.sender] -= _value;
        deposits[_to] += _value;
    }
}