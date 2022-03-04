/**
 *Submitted for verification at BscScan.com on 2022-03-04
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

contract Box {
    uint256 private _value2;

    constructor() {
        //
    }

    // Emitted when the stored value changes
    event ValueChanged(uint256 value);

    // Stores a new value in the contract
    function store2(uint256 value) public {
        _value2 = value;
        emit ValueChanged(value);
    }

    // Reads the last stored value
    function retrieve2() public view returns (uint256) {
        return _value2;
    }
}