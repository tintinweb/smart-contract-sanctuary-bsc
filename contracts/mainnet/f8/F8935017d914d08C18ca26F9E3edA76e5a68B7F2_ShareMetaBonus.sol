// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "ERC20.sol";

contract ShareMetaBonus is ERC20 {
    constructor() ERC20("5ShareMetaBonus", "5SMB") {
        _mint(msg.sender, 1000000000 * 10 ** decimals());
    }
}