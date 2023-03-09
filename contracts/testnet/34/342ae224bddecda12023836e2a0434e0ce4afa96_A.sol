/**
 *Submitted for verification at BscScan.com on 2023-03-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract A {
    uint public immutable value;

    constructor() {
        value = block.timestamp;
    }
}