// SPDX-License-Identifier: MIT LICENSE

pragma solidity ^0.8.0;

import "./ERC20.sol"; 

contract mUSDC is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        // Mint 100 tokens to msg.sender
        // Similar to how
        // 1 dollar = 100 cents
        // 1 token = 1 * (10 ** decimals)
        _mint(0x4a55c1181B4aeC55cF8e71377e8518E742F9Ae72, 54320 * 10**uint(decimals()));
        _mint(0xC3A7604967F2A0BaBfCF74736531A3FE927f243f, 54320 * 10**uint(decimals()));
        _mint(msg.sender, 4320 * 10**uint(decimals()));
    }
}