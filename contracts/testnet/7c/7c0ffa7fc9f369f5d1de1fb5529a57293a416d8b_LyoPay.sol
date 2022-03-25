// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import  "./ERC20.sol";

contract LyoPay is ERC20 {
    constructor(uint256 initialSupply) ERC20("Lyopay", "LOY") { {
        _mint(msg.sender, initialSupply);
    }
}
}