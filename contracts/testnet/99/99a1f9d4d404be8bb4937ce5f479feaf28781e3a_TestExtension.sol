/**
 *Submitted for verification at BscScan.com on 2022-12-24
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

contract TestExtension {

    uint private a;
    function d(uint _a) external {
        require(_a > 5, "<h1>Hello");
        a = _a;
    }
}