/**
 *Submitted for verification at BscScan.com on 2022-11-30
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

contract SimpleBank {
    uint balance;
    mapping(address => uint) private balanceByAddress;

    constructor() {
        balance = 0;
    }

    function getBalance() public view returns (uint) {
        return balance;
    }

    function viewMyBalance() external view returns (uint) {
        return balanceByAddress[msg.sender];
    }

    function deposit() external payable {
        uint amount = msg.value;
        balanceByAddress[msg.sender] += amount;
        balance += amount;
    }

    function withdraw() external payable {
        uint amount = msg.value;
        address payable withdrawAddress = payable(msg.sender);
        uint currentBalance = balanceByAddress[withdrawAddress];
        require(
            currentBalance >= amount,
            "You don't have enough money to perform this transaction."
        );
        withdrawAddress.transfer(amount);

        balanceByAddress[withdrawAddress] -= amount;
        balance -= amount;
    }
}