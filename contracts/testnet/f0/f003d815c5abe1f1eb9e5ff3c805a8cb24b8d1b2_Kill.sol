/**
 *Submitted for verification at BscScan.com on 2022-10-23
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract Kill {
    constructor() payable{}

    function kill() external {
        selfdestruct(payable(msg.sender));
    }
    function testCall() external pure returns(uint) {
        return 123;
    }
}