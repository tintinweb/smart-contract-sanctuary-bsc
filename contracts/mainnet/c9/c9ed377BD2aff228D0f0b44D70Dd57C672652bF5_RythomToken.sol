// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "ERC20.sol";

contract RythomToken is ERC20 {
    constructor() ERC20("Rythom Token", "RTN v2") {
        _mint(msg.sender, 12_000_000_000 * (10**uint256(decimals())));
    }
}