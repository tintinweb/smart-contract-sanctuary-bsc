// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./ERC20.sol";

contract BanthcoinMine is ERC20 {
    constructor() ERC20("Banthcoin Mine", "BCM") {
        _mint(msg.sender, 10000000 * 10 ** decimals());
    }
}