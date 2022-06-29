/**
 *Submitted for verification at BscScan.com on 2022-06-29
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract SimpleContract {
    uint256 foo;

    constructor() {}

    function setFoo(uint256 value) public {
        foo = value;
    }

    function getFoo() public view returns (uint256) {
        return foo;
    }
}