// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20.sol";

contract HTTS is ERC20 {
    constructor(uint256 initialSupply) ERC20("HttttSss", "HTTS") {
        _mint(msg.sender, initialSupply);
    }
}