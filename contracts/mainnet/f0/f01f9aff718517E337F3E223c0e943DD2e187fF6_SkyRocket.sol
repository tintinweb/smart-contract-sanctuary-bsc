// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20.sol";
import "./ERC20Burnable.sol";

contract SkyRocket is ERC20, ERC20Burnable {
    constructor() ERC20("SKY", "Sky Rocket") {
        _mint(msg.sender, 1000000000000000 * 10**decimals());
    }
}