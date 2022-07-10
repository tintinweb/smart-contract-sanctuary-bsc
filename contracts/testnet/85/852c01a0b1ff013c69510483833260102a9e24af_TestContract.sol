/**
 *Submitted for verification at BscScan.com on 2022-07-09
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.8;

contract TestContract {
    event Test();

    function test(string[] memory array) public {
        emit Test();
    }
}