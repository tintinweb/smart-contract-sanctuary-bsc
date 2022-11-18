/**
 *Submitted for verification at BscScan.com on 2022-11-17
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

contract Test {
    uint256 private num1;

    constructor(uint256 _num1) {
        num1 = _num1;
    }

    function getNum1() external view returns (uint256) {
        return num1;
    }

    function resetNum1() external {
        num1 = 0;
    }

    function setNum1(uint256 _num1) external {
        num1 = _num1;
    }
}