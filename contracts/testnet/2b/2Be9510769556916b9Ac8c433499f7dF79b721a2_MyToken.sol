// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./ERC20.sol";
import "./ERC20Burnable.sol";
import "./Ownable.sol";

contract MyToken is ERC20, ERC20Burnable, Ownable {
    constructor() ERC20("ATM", "ATM") {}

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}