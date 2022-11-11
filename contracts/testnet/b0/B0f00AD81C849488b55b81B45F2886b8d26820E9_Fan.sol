/**
 *Submitted for verification at BscScan.com on 2022-11-10
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Fan {
    mapping (address => uint) public balances;
    string public name = "Fan";
    string public symbol = "666";
    uint8 public decimals = 6;
    
    constructor() {
        balances[msg.sender] = 100;
    }
}