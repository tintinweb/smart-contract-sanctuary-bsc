/**
 *Submitted for verification at BscScan.com on 2023-01-13
*/

// contracts/BoxV2.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
 
contract BoxV2 {
    uint256 private value;
    struct User {
      address id;
      uint256 balance;
      uint256 age;
    }
    mapping(uint256 => User) public user;
    uint256[50] __gap;
 
    // Emitted when the stored value changes
    event ValueChanged(uint256 newValue);
 
    // Stores a new value in the contract
    function store(uint256 newValue) public {
        value = newValue;
        emit ValueChanged(newValue);
    }
    
    // Reads the last stored value
    function retrieve() public view returns (uint256) {
        return value;
    }

    function getAge() public view returns (uint256) {
        return user[0].age;
    }function getBalance() public view returns (uint256) {
        return user[0].balance;
    }

    function storeAge() public  {
        user[0].age = value + 100;
    }
    
    // Increments the stored value by 1
    function increment() public {
        value = value + 1;
        emit ValueChanged(value);
    }
}