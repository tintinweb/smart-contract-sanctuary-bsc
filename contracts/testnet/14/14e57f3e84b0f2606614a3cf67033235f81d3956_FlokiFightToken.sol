// contracts/FlokiFightToken.sol
// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "ERC20.sol";
import "Ownable.sol";

contract FlokiFightToken is ERC20, Ownable {
    constructor(uint256 initialSupply) ERC20("FlokiFightToken", "FFight") {
        _mint(msg.sender, initialSupply);
    }
}