/**
 *Submitted for verification at BscScan.com on 2022-09-29
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;


contract fix {


    mapping(address => bool) public istrade;


    constructor() {
        istrade[address(this)] = true;
    }
}