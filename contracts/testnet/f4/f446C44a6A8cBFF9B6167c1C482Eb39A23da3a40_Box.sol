// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Box {
    uint private value;
    uint private anotherValue;

    event ValueChanged(uint newValue);

    function store(uint newValue, uint newAnotherValue) public {
        value = newValue;
        anotherValue = newAnotherValue;
        emit ValueChanged(newValue);
    }

    function retrieve() public view returns(uint) {
        return value;
    }

    function retrieveAnotherValue() public view returns(uint) {
        return anotherValue;
    }
}