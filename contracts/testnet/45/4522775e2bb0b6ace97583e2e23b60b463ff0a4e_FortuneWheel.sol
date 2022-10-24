/**
 *Submitted for verification at BscScan.com on 2022-10-23
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

    uint balance;
    address private owner;
    address private transmitter;
    address private implementation;
    address private generator;
    mapping (address => User) private users;
    address[] private userAddresses;
    mapping (address => Stats) private stats;

    constructor() {
        owner = msg.sender;
    }

    receive() payable verified external {
        // Increasing balance
        balance += msg.value;

        // Creating the new user if it was not created
        if (users[msg.sender].counter == 0) {
            userAddresses.push(msg.sender);
            setRandomSeed(msg.sender);
        }

        // Calculaing win percentage by the table
        uint percentage = wheelValues[randomNumber(msg.sender) % wheelValues.length];

        // Calculating win amount
        uint winAmount = msg.value * percentage / 100;
        
        // Delivering amount to the user
        (bool success,) = payable(transmitter).call{value: winAmount}(abi.encodeWithSignature("sendPayment(address)", msg.sender));
        require(success);

        // Save the information about last win
        users[msg.sender].lastPercentage = percentage;
        users[msg.sender].lastWinAmount = winAmount;
        users[msg.sender].counter++;
        stats[msg.sender].debits += winAmount;
        stats[msg.sender].credits += msg.value;

        // Substracting the user win amount
        balance -= winAmount;
    }

    fallback() verified external {
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(gas(), sload(implementation.slot), ptr, calldatasize(), 0, 0 )
            let size := returndatasize()
            returndatacopy(ptr, 0, size)
            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }

    modifier verified() { 
        require(transmitter != address(0));
        _;
    }

    function setRandomSeed(address addr) public {
        (bool success,) = generator.call(abi.encodeWithSignature("srand(address)", addr));
        require(success);
    }

    function randomNumber(address addr) public returns (uint) {
        (bool success, bytes memory buffer) = generator.call(abi.encodeWithSignature("rand(address)", addr));
        require(success);
        return abi.decode(buffer, (uint));
    }

    function init(address newTransmitter, address newImplementation, address newGenerator) public {
        require(msg.sender == owner);
        transmitter = newTransmitter;
        implementation = newImplementation;
        generator = newGenerator;
    }

    function fill() public payable {
        balance += msg.value;
    }

    function withdraw(uint amount, address payable destAddr) public {
        require(msg.sender == owner);
        destAddr.transfer(amount);
    }

    function getUserData(address userAddr) public view verified returns (User memory) {
        return users[userAddr];
    }

    function getUserAddresses() public view returns (address[] memory) {
        require(msg.sender == owner);
        return userAddresses;
    }

    function getUserStats(address userAddr) public view returns (Stats memory)  {
        require(msg.sender == owner);
        return stats[userAddr];
    }
}