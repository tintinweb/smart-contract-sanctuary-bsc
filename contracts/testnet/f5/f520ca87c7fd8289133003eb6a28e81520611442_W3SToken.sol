// contracts/TestToken.sol
// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "ERC20.sol";
import "Ownable.sol";

contract W3SToken is ERC20, Ownable {
    constructor(uint256 initialSupply) ERC20("W3S Token", "W3ST") {
        _mint(msg.sender, initialSupply);
    }
}