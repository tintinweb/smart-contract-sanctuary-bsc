// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

contract myContract_v2 {
    uint96 public age;
    function inc() external {
        age += 1;
    }
}