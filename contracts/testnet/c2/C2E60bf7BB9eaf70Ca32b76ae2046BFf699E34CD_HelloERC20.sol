// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";

contract HelloERC20 is ERC20 {
    constructor(string memory name, string memory symbol, uint8 decimal, uint256 totalSupply, uint256 initialSupply) ERC20(name, symbol, decimal, totalSupply, initialSupply) {
        _mint(msg.sender, 1000 * 10 ** decimals());

        // totalSupply += 1000;
        // balances[msg.sender] += 1000;
    }
}