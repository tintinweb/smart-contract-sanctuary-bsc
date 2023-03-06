// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "ERC20.sol";
import "ERC20Burnable.sol";
import "Ownable.sol";

contract DecentralizedGamberCompany is ERC20, ERC20Burnable, Ownable {
    constructor() ERC20("Decentralized Gamber Company", "DGC") {
        _mint(msg.sender, 2225000 * 10 ** decimals());
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}