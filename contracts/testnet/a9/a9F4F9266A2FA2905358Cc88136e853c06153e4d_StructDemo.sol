// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract StructDemo {
    struct User {
        uint16 age;
        uint16 height;  // slot_1 (包含 age 和 height 数据，从左到右分别是 age、height)
        bytes32 msg;    // slot_2
        uint16 weight;  // slot_3
    }

    uint16 a; // slot_0
    User u;
    uint16 b; // slot_4

    constructor() {
        a = 100;
        b = 4568;
    }

    function setUser(uint16 age, uint16 height, uint16 weight) public {
        u.age = age;
        u.height = height;
        u.weight = weight;
        u.msg = keccak256(abi.encodePacked(msg.sender));
    }

    function getUser() public view returns (User memory) {
        return u;
    }
}