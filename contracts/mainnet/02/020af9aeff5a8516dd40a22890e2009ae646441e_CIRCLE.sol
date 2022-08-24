// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";

contract CIRCLE is ERC20 {
    constructor() ERC20("CIRCLE", "CIRC") {
        _mint(msg.sender, 10000000000 * 10 ** decimals());
    }
}