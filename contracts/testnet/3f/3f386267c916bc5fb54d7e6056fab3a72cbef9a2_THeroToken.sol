// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "./BEP20.sol";

contract THeroToken is BEP20Detailed, BEP20 {
  constructor() BEP20Detailed("THero", "THR", 18) {    
    uint256 totalTokens = 100 * 10**6 * 10**uint256(decimals());

    /**
     *  mint 100 million tokens
     */
    _mint(msg.sender, totalTokens);
  }

  function burn(uint256 amount) external {
    _burn(msg.sender, amount);
  }
}