/**
 *Submitted for verification at BscScan.com on 2022-12-26
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract CCCTokenDistribution {

    uint256 balance;

    constructor(uint256 _balance) {
        balance = _balance;      
    }

    function test(uint256 _balance) public {
        balance += _balance;
    }
}