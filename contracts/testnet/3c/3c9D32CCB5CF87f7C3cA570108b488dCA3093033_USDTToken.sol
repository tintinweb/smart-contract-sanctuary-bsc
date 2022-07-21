// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC20.sol";

contract USDTToken is ERC20 {
    constructor(string memory _name, string memory _symbol, uint256 supply) ERC20(_name, _symbol) {
        _mint(msg.sender, supply);
    }
}