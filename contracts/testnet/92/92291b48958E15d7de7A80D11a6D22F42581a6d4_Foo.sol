/**
 *Submitted for verification at BscScan.com on 2022-08-24
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Foo {
    function getRange(uint n) public pure returns(uint[] memory) {
        uint[] memory result = new uint[](n);
        for (uint i = 0; i < n; i++)
            result[i] = i;
        return result;
    }
}