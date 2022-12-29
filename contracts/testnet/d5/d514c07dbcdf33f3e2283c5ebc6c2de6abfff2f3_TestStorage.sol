/**
 *Submitted for verification at BscScan.com on 2022-12-29
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.15;

contract Group {
    uint256 public number;

    constructor(uint256 num) {
        number = num;
    }

    function getNumber() public view returns (uint256) {
        return number;
    }

    function setNumber(uint256 num) public {
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

    function getNumber(uint256 groupIndex) public view returns (uint256) {
        return groups[groupIndex].getNumber();
    }

    function setNumber(uint256 groupIndex, uint256 num) public {
        groups[groupIndex].setNumber(num);
    }
}