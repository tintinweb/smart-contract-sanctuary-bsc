// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "./BEP20.sol";

contract COCKToken is BEP20Detailed, BEP20 {
  constructor() BEP20Detailed("CockBattle Coin", "COCK", 18) {
    uint256 totalTokens = 4200000000 * 10**uint256(decimals());
    _mint(msg.sender, totalTokens);
  }

  function burn(uint256 amount) external {
    _burn(msg.sender, amount);
  }
}