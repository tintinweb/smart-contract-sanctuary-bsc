// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract BoxV2 {
    uint private value;
    uint private anotherValue;

    event ValueChanged(uint newValue);

    function store(uint newValue) public {
        value = newValue;
        emit ValueChanged(newValue);
    }

    function storeX2(uint newValue) public {
        anotherValue = newValue * 2;
        emit ValueChanged(newValue);
    }

    function retrieve() public view returns(uint) {
        return value;
    }

    function retrieveX2() public view returns(uint) {
        return value;
    }

    function increment() public {
        value = value + 1;
        anotherValue = anotherValue + 1;
    }
}