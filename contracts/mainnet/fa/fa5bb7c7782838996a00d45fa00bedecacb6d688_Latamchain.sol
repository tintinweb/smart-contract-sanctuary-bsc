// Comunidad Latamchain
// SPDX-License-Identifier: GPL v3
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./ERC20Burnable.sol";

contract Latamchain is ERC20, ERC20Burnable {
    constructor() ERC20("Latamchain", "LATAM") {
        _mint(msg.sender, 1000000000 * 10 ** uint(decimals()));
    }
}