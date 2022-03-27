// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract DynamicArray {
    uint a = 123;         // slot_0
    address owner;        // slot_1
    uint64[] user;        // slot_2 这个插槽存储的是数组的长度

    function addUser(uint64 uid) public {
        user.push(uid);
    }

    function getUserArrayLength() public view returns (uint) {
        return user.length;
    }
}