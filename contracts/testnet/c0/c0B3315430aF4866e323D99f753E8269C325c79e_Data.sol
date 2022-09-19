// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.16 <0.9.0;

contract Data {
    string name;
    uint256 age;

    constructor(string memory _name, uint256 _age) {
        name = _name;
        age = _age;
    }
}