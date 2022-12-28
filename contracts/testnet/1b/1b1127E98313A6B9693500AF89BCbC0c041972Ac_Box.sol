// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Box {
    uint private value;

    event ValueChanged(uint newValue);

    function store(uint newValue) public {
        value = newValue;
        emit ValueChanged(newValue);
    }

    function retrieve() public view returns(uint) {
        return value;
    }
}