/**
 *Submitted for verification at BscScan.com on 2022-08-13
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract w101 {
    address public owner; //0x31e72d54E443D78Bcf1944eE1642Ea1466D428e0
    uint256 public balance;

    constructor() {
        owner = msg.sender;

    }
        receive() payable external {
            balance += msg.value;
        }

    function withdraw(uint amount, address payable destaddr) public {
        require(msg.sender == owner, "On...");
        require(amount <= balance, "In...");

        destaddr.transfer(amount);
        balance -= amount;
    }

}