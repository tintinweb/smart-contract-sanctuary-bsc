// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "ERC20.sol";

contract MBBBM is ERC20 {
    constructor() ERC20("Arizona", "Arizona") {
        _mint(msg.sender, 21000000 * 10 ** decimals());
    }
}