// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./ERC20.sol";

contract Token is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _mint(msg.sender, 100 * 10**uint(decimals()));
    }
}