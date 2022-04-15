// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20.sol";

contract ElephantCoin is ERC20 {
    constructor(uint256 initialSupply) ERC20("ElephantCoin", "ELE") {
        _mint(msg.sender, initialSupply);
    }
}