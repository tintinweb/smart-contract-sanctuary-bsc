/**
 *Submitted for verification at BscScan.com on 2022-11-21
*/

// SPDX-License-Identifier: MIT
 pragma solidity ^0.8.0;
contract Counter {
    constructor() {
    }
    uint8 public count = 0;
    function increment() public {
        count++;
    }
    function decrement() public {
        count--;
    }
 
}