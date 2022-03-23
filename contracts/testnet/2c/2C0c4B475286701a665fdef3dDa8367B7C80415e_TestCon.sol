// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

// Base contract X
contract TestCon {
    string public name;

    constructor(string memory _name) {
        name = _name;
    }
}