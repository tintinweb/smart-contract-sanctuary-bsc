// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./BEP20.sol";

contract RaijinToken is BEP20Detailed, BEP20 {
  constructor() BEP20Detailed("Raijin Ether Coin", "RCOIN", 18) {
    uint256 totalTokens = 1000000000 * 10**uint256(decimals());
    _mint(msg.sender, totalTokens);
  }

  function burn(uint256 amount) external {
    _burn(msg.sender, amount);
  }
}