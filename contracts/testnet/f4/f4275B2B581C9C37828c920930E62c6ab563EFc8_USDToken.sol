// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC20.sol";

contract USDToken is ERC20 {
    constructor(string memory name_, string memory symbol_, uint256 _supply) ERC20(name_, symbol_) {
        super._mint(msg.sender, _supply);
    }
}