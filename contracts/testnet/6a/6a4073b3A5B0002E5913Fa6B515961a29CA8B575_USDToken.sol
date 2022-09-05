// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC20.sol";

contract USDToken is ERC20 {
    constructor(string memory _name, string memory _symbol, uint256 _supply) ERC20 (_name, _symbol) {
        super._mint(msg.sender, _supply);
    } 
}