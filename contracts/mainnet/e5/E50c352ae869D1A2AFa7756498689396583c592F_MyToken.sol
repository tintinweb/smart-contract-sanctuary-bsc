// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./ERC20.sol";

contract MyToken is ERC20 {
     address owner;
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        // Mint 100 tokens to msg.sender
        // Similar to how
        // 1 dollar = 100 cents
        // 1 token = 1 * (10 ** decimals)
        _mint(msg.sender, 10000000 * 10 ** uint(decimals()));
         owner = msg.sender;
    }
    function mint(address to, uint256 amount) public {
        // Only the contract owner can mint new tokens
        require(msg.sender == owner, "Only the contract owner can mint tokens");

        // Increase the balance of the target address
         _mint(to, amount);
    }
    
     function burn(uint256 amount) public returns (bool) {
    _burn(msg.sender, amount);
    return true;
  }

    function changeOwner(address _newOwner) public {
        // Ensure that only the current owner can call the function
        require(msg.sender == owner, "Only the owner can change the owner");

        // Change the owner to the new address
        owner = _newOwner;
    }
}