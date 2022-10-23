// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "Ownable.sol";
import "ERC20.sol";

contract COWToken is ERC20,Ownable {
    uint256 private totalSupply_=200000000*10**18;

    constructor() ERC20("Cow Token", "COW") {
        _mint(msg.sender, totalSupply_);
    }

    function burn(uint256 amount) public {
        _burn(_msgSender(), amount);
    }
}