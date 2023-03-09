// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./ERC20.sol";

contract FakeUsdt is ERC20 {
    constructor() ERC20("fakeUsdt", "FUSDT") {
        _mint(msg.sender, 100000000 * 10 ** decimals());
    }
}