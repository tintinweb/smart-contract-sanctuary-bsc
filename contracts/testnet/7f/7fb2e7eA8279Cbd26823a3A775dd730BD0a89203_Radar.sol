// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20.sol";

contract Radar is ERC20 {
    constructor(uint256 initialSupply) ERC20("Radar", "RADAR") {
        _mint(msg.sender, initialSupply);
    }
}