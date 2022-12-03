/**
 *Submitted for verification at BscScan.com on 2022-12-02
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;


contract CounterV1 {
    uint public count;

    function inc() external {
        count += 1;
    }
}