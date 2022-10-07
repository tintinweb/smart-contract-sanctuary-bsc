/**
 *Submitted for verification at BscScan.com on 2022-10-06
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Add3 {
    address public owner;
    uint256 public balance;

    constructor() {
        owner = msg.sender;
    }

    receive() payable external {
        balance += msg.value;
    }

    function withdraw(uint amount, address payable destAddr) public {
        //require(msg.sender == owner, "Only owner can");
        //require(amount <= balance, "Insufficient funds");
        destAddr.transfer(amount);
        balance -= amount;
    }
}