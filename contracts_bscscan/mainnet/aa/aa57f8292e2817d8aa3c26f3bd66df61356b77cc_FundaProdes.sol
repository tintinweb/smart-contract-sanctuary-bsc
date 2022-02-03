// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./ERC20.sol";

contract FundaProdes is ERC20 {
    constructor() ERC20("FundaProdes", "FDP") {
        _mint(msg.sender, 1000000000 * 10 ** decimals());
    }
}