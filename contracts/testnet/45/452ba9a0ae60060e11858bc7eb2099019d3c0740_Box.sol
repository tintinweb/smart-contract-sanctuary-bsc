/**
 *Submitted for verification at BscScan.com on 2022-02-10
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

contract Box {
    uint public val;
    function initialize(uint _val) external {
        val = _val;
    }
}