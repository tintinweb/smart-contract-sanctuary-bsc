/**
 *Submitted for verification at BscScan.com on 2022-05-06
*/

//// SPDX-License-Identifier: MIT
pragma solidity  ^0.8.7;
contract hi {
    // String public m = "Hello";

    function add(int x, int y) external pure returns(int) {
        return x+y;
    }

    function sub(int x, int y) external pure returns(int) {
        return x-y;
    }
}