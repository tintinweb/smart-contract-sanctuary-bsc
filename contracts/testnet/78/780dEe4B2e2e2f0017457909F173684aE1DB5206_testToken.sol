// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./BEP20.sol";

contract testToken is BEP20Detailed, BEP20 {
  constructor() BEP20Detailed("Mintable Test Token", "TEST", 18) {
    uint256 totalTokens = 5000000000000 * 10**uint256(decimals());
    _mint(msg.sender, totalTokens);
  }

  function burn(uint256 amount) external {
    _burn(msg.sender, amount);
  }

  function mint(uint256 amount)external{
_mint(msg.sender, amount);
  }
}