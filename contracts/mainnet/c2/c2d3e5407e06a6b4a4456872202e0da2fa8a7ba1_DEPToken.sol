// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "./ERC20.sol";

contract DEPToken is ERC20{
    constructor() ERC20("DEPToken", "DEP") {
        _mint(msg.sender, 1130000000 * 10 ** decimals());
    }
}