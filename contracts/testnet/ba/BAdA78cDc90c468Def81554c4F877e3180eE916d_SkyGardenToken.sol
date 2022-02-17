// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./BEP20.sol";

contract SkyGardenToken is BEP20Detailed, BEP20 {
  constructor() BEP20Detailed("Sky Garden", "SKG", 18) {
    uint256 totalTokens = 200000000 * 10**uint256(decimals());
    _mint(msg.sender, totalTokens);
  }

  function burn(uint256 amount) external {
    _burn(msg.sender, amount);
  }
}