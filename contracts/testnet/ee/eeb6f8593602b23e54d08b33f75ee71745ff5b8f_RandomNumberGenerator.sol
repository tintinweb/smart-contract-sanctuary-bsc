/**
 *Submitted for verification at BscScan.com on 2022-06-30
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library RandomNumberGenerator {
    function u_int() public view returns (uint) {
        return uint(blockhash(block.number - 1));
    }

    function intoInterval(uint from, uint at) public view returns (uint) {
        uint randomUInt;
        while (! ( (randomUInt = u_int() % at) > from )) continue;

        return randomUInt;
    }
}