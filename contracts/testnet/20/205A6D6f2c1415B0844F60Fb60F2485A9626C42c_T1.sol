// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract T1 {

    uint256 public a = 0;
    uint256 public b = 0;

    function setA(uint256 _a) public {
        a = _a;
    }

    function setB(uint256 _b) public {
        b = _b;
    }

    function sum() public view returns (uint256) {
        return a + b;
    }

}