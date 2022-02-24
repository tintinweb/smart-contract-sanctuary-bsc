/**
 *Submitted for verification at BscScan.com on 2022-02-23
*/

pragma solidity ^0.8.7;
// SPDX-License-Identifier: MIT

contract Fee {

    address public owner;
    uint256 public balance;

    constructor() {
        owner = msg.sender;
    }

    receive() payable external {
        balance += msg.value;
    }


    function Withdraw (uint amount, address payable destAddr) public { 
        require (msg.sender == owner, "Only owner can withdraw");
        require (amount <= balance, "insufficient funds");

        destAddr.transfer(amount);
        balance -= amount;
    }

}