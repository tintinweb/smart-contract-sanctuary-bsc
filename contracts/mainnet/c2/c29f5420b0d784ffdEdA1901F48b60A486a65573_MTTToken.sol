// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "./ERC20.sol";

contract MTTToken is ERC20 {
    constructor() ERC20("MetaThieves Token", "MTT") {
        // 20M tokens
        uint256 totalTokens = 20000000 * 10**uint256(decimals());
        _mint(msg.sender, totalTokens);
    }
}