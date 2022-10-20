/**
 *Submitted for verification at BscScan.com on 2022-10-19
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
    uint private randSeed;
    uint[] sequence;

    constructor() {
        owner = msg.sender;
    }

    fallback() external {
        uint8 size;
        uint8 value;
        bytes memory data = msg.data;

        require(msg.sender == owner);
        assembly { size := mload(add(data, 1)) }
        delete wheelValues;
        for (uint i = 1; i <= size; i++) {
            uint offs = i + 1;
            assembly { value := mload(add(data, offs)) }
            wheelValues.push(value);
        }
    }

    function test() public view returns (uint) {
        return wheelValues.length;
    }

    function getWheelValues() public view returns (uint[] memory) {
        return wheelValues;
    }

    function randomNumber() public returns (uint) {
        randSeed = randSeed * 22695477 + 1;
        return randSeed >> 16;
    }

    function generateRandomSequence(uint count, uint maxValue) public {
        delete sequence;
        for (uint i = 0; i < count; i++)
            sequence.push(randomNumber() % maxValue);
    }

    function getRandomSequence() public view returns (uint[] memory) {
        return sequence;
    }
}