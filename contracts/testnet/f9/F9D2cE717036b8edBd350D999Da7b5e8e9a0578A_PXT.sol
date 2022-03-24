// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract PXT {

    uint256 public counter;

    constructor() {
        counter = 0;
    }

    function increment() public {
        counter = counter + 1;
    }
}