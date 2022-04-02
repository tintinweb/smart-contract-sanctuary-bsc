/**
 *Submitted for verification at BscScan.com on 2022-04-01
*/

// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;
contract Storage {
    uint public val;
    constructor(uint v) {
        val = v;
    }
    function setValue(uint v) public {
        val = v;
    }
}