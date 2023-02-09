// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC20.sol";

contract BBQToken is ERC20
{
    constructor(uint256 initialSupply) ERC20("BBQToken", "BBQ"){
        _mint(msg.sender, initialSupply);
        _burn(msg.sender, initialSupply);
    }
}