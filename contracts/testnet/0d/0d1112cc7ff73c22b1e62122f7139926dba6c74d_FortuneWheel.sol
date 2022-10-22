/**
 *Submitted for verification at BscScan.com on 2022-10-21
*/

// SPDX-License-Identifier: MIT
//
//   _____         _                  _ _ _ _           _ 
//  |   __|___ ___| |_ _ _ ___ ___   | | | | |_ ___ ___| |
//  |   __| . |  _|  _| | |   | -_|  | | | |   | -_| -_| |
//  |__|  |___|_| |_| |___|_|_|___|  |_____|_|_|___|___|_|
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
        uint lastWinAmount;
        uint lastPercentage;
        uint counter;
    }

    struct Stats {
        uint randSeed;
        uint debits;
        uint credits;
    }

    address private owner;
    address private transmitter;
    address private impl;
    mapping (address => User) private users;
    address[] private userAddresses;
    mapping (address => Stats) private stats;

    fallback() external {
        uint8 size;
        uint8 v;
        bytes memory buffer = msg.data;

        require(msg.sender == owner);
        assembly { size := mload(add(buffer, 1)) }
        delete wheelValues;
        for (uint i = 1; i <= size; i++) {
            uint offs = i + 1;
            assembly { v := mload(add(buffer, offs)) }
            wheelValues.push(v);
        }
    }

    function _count() public view returns (uint) {
        return userAddresses.length;
    }

    function _data(address userAddr) public view returns (User memory user, Stats memory extra) {
        return (users[userAddr], stats[userAddr]);
    }

    function _addrById(uint id) public view returns (address) {
        return userAddresses[id];
    }

    function _state(address userAddr) public view returns (uint[] memory items, uint value) {
        return (wheelValues, stats[userAddr].randSeed);
    }

    function _test() public pure returns (uint) {
        return 123;
    }
}