//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract Setter {
    uint256 public number;

    function setNumber(uint num) public{
        number = num;
    }
}