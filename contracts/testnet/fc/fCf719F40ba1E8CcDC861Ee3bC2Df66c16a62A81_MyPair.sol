/**
 *Submitted for verification at BscScan.com on 2022-09-05
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface Pair {
    function swap(uint input) external returns (uint);
}

contract MyPair {
    uint[2] reserves;

    constructor(uint a, uint b) {
        reserves[0] = a;
        reserves[1] = b;
    }

    function swap(uint input) public returns (uint) {
        uint output = reserves[1] - reserves[0] * reserves[1] / (reserves[0] + input);
        require(reserves[1] >= output);
        reserves[0] += input;
        reserves[1] -= output;
        emit Swap(input, output);
        return output;
    }

    event Swap(uint a, uint b);
}