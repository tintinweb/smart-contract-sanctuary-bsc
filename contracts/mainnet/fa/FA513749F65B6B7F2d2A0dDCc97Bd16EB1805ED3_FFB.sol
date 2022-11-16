// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "ERC20.sol";

contract FFB is ERC20 {
    constructor() ERC20("FIFA Fan Battle Token", "FFB") {
        _mint(msg.sender, 360000 * 10 ** decimals());
    }
}