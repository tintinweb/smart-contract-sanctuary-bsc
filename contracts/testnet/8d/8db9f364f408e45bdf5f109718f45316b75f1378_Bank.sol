/**
 *Submitted for verification at BscScan.com on 2022-06-20
*/

// SPDX-License-Identifier: GPL-3.0
/**
 *Submitted for verification at BscScan.com on 2022-06-20
*/

pragma solidity ^0.8.4;

contract Bank {
    mapping(address => uint) public balance;
    address owner;
    address msg_sender;
    
    constructor() {
        owner = msg.sender; // address that deploys contract will be the owner
    }

    modifier setOwner {
        msg_sender = msg.sender;
        _;
    }
    
    function addBalance(uint _toAdd) setOwner public returns(uint) {
        if (msg_sender == owner) {
            // require(msg.sender == owner);
            balance[msg.sender] += _toAdd;
            return balance[msg.sender];
        } else {
            return 0;
        }     
    }
}