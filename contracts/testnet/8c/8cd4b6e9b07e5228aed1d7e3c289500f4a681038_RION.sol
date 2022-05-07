// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./ERC20Burnable.sol";

contract RION is ERC20, ERC20Burnable {
    constructor() ERC20("RION", "RION") {
        _mint(msg.sender, 1000000000 * 10 ** decimals());
    }
}