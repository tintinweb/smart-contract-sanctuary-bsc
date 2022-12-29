/**
 *Submitted for verification at BscScan.com on 2022-12-29
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Group {
    uint256 public number;

    constructor(uint256 num) {
        number = num;
    }
}

contract TestStorage {
    Group[] public groups;

    constructor() {
        groups.push(new Group(1));
        groups.push(new Group(2));
        groups.push(new Group(3));
    }
}