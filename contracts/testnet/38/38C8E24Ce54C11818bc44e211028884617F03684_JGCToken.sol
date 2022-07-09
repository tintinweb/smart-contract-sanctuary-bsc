// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./BEP20.sol";

contract JGCToken is BEP20Detailed, BEP20 {
  constructor() BEP20Detailed("Jewel Garden Crypto", "JGC", 18) {
    uint256 totalTokens = 300000000 * 10**uint256(decimals());
    _mint(msg.sender, totalTokens);
  }

  function burn(uint256 amount) external {
    _burn(msg.sender, amount);
  }
}