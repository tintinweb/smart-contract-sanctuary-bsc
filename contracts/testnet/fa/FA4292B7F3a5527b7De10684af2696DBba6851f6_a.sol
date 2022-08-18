/**
 *Submitted for verification at BscScan.com on 2022-08-17
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract a {

    uint256 sum;

    function add(uint256 _firstNumber, uint256 _secondNumber) public {
        sum = _firstNumber + _secondNumber;
    }

    function result() public view returns (uint256) {
        return sum;
    }
}