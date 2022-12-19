// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./BEP20.sol";
import "./Ownable.sol";
import "./BEP20Burnable.sol";

contract BEP20Token is BEP20, BEP20Burnable, Ownable {
   
    constructor() BEP20("LUNA", "LN") {}

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}