// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC20.sol";

contract Multi is ERC20 {
    constructor () ERC20 ("Multi", "Multi") {
        _mint(msg.sender, 100000000000000000000000000);
    }
}