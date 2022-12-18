// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20.sol";
import "./ERC20Burnable.sol";
import "./Ownable.sol";

contract COSMOS is Ownable, ERC20, ERC20Burnable {
    constructor() ERC20("COSMOS", "COS") {
        _mint(msg.sender, 100000000 * 10**decimals());
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}