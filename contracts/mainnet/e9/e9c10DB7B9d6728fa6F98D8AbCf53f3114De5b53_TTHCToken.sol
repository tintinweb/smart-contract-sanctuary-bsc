// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "./BEP20.sol";

contract TTHCToken is BEP20 {
    constructor() BEP20("TTHC", "TTHC") {
        _mint(msg.sender, 10000000000 * 10**18);
    }
}