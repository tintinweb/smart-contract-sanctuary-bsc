// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract MutilTest {

    uint nonce = 0;

    function test(address token, address[] memory recipients, uint256[] memory amounts, bytes[] memory signatures) external {
        nonce++;
    }
}