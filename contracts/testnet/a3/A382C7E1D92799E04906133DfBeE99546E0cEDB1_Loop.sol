// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.16;

contract Loop {
    uint256 sum = 0;

    function customLoop(uint256 number) external {
        for (uint256 i = 0; i < number; i++) {
            sum += i;
        }
    }
}