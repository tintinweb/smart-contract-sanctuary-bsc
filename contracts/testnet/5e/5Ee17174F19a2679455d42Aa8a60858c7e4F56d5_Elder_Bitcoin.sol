// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./ERC20.sol";

contract Elder_Bitcoin is ERC20 {
    constructor(uint256 initialSupply) public ERC20 (){
        _mint(msg.sender,initialSupply);
    }
}