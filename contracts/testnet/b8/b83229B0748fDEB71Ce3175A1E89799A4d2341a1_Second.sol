// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {First} from "./1_First.sol";

contract Second {
    function test(uint a, uint b) public pure returns (uint) {
        uint c = First.sum(a, b);
        return c;
    }
}