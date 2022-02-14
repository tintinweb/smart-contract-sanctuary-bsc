// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20.sol";
import "./Ownable.sol";

contract Ares is Ownable, ERC20 {
    constructor(uint256 initialSupply) public ERC20("Ares", "ARES") {
        _mint(msg.sender, initialSupply * 10 ** 18);
    }

    function mint(address to, uint256 amount) public onlyOwner {
       _mint(to, amount);
    }
}