// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./ERC20.sol";

contract Recehan is ERC20 {
    constructor() ERC20("Recehan", "RECEH") {
        _mint(msg.sender, 2100000 * 10 ** decimals());
    }
}