/**
 *Submitted for verification at BscScan.com on 2023-02-14
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;


contract Test {

    event Created(string indexed name);

    constructor() {
        emit Created("Created");
    }

    function echo() public pure returns(string memory) {
        return "Hello test";
    }

}