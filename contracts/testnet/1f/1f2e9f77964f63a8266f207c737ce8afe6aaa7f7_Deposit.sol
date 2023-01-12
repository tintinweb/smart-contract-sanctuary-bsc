/**
 *Submitted for verification at BscScan.com on 2023-01-11
*/

pragma solidity ^0.6.12;
//SPDX-License-Identifier: UNLICENSED



contract Deposit {
    address payable public owner;

    constructor() public {
        owner = msg.sender;
    }

    function deposit() public payable {
        require(msg.value > 0, "Deposit must be greater than 0");
    }

    function withdraw() public {
        require(msg.sender == owner, "Only owner can withdraw funds");
        require(address(this).balance > 0, "No funds to withdraw");
        owner.transfer(address(this).balance);
    }
}