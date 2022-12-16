/**
 *Submitted for verification at BscScan.com on 2022-12-15
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Incremental {
    uint256 public index;

    uint256[] public increment; 

    uint256[] public lastIncrement;

    constructor() {}

    function increase() external {
        index += 1;

        increment.push(index);

        lastIncrement.push(block.timestamp);
    }
}