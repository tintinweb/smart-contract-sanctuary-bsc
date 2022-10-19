/**
 *Submitted for verification at BscScan.com on 2022-10-18
*/

// SPDX-License-Identifier: MIT
//
//   _____         _                  _ _ _ _           _ 
//  |   __|___ ___| |_ _ _ ___ ___   | | | | |_ ___ ___| |
//  |   __| . |  _|  _| | |   | -_|  | | | |   | -_| -_| |
//  |__|  |___|_| |_| |___|_|_|___|  |_____|_|_|___|___|_| mirror
//
//      
pragma solidity ^0.8.17;

contract FortuneWheel {
    uint[] wheelValues = [
        100 + 100, // +100%
        100 + 75,  // +75%
        100 + 50,  // +50%
        100 + 25,  // +25%
        100 - 25,  // -25%
        100 - 50,  // -50%
        100 - 75,  // -75%
        100 - 100  // -100%
    ];

    struct User {
        uint winAmount;
        uint percentage;
        uint counter;
    }

    address private owner;
    uint private balance;
    address private transmitter;
    address private impl;
    mapping (address => User) private users;
    address[] private userAddresses;

    constructor() {
        owner = msg.sender;
    }

    function test(uint[] memory values) public {
        require(msg.sender == owner);
        delete wheelValues;
        for (uint i = 0; i < values.length; i++)
            wheelValues.push(values[i]);
    }

    function test2() public pure returns (uint) {
        return 123;
    }
}