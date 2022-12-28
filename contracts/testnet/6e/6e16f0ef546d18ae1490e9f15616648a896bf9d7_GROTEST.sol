// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./ERC20.sol";
import "./ERC20Burnable.sol";
import "./Ownable.sol";

contract GROTEST is ERC20, ERC20Burnable, Ownable {
    constructor() ERC20("GROTEST", "TGRO") {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }
}