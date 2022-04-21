// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.11;

contract BoxV3 {
    uint256 private value;
    uint256 private soNew;

    event ValueChanged(uint256 newValue);

    function store(uint256 newValue) public {
        soNew = newValue;
    }

    function retrieveSoNew() public view returns (uint256 _value) {
        _value = value;
    }

    function retrieve() public view returns (uint256 _value) {
        _value = value;
    }

    function increment() public {
        uint256 newValue = value + 1;
        value = newValue;
        emit ValueChanged(newValue);
    }

    function decrement() public {
        uint256 newValue = value - 1;
        value = newValue;
        emit ValueChanged(newValue);
    }
}