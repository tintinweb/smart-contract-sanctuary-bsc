// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./ERC20Burnable.sol";

contract METACAR is ERC20, ERC20Burnable {
    constructor() ERC20("MOONCLIMB", "MONC") {
        _mint(msg.sender, 7500000 * 10 ** decimals());
    }
}