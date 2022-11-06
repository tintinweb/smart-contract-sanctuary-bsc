// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./ABEP20.sol";
import "./BEP20Detailed.sol";

contract Laro is BEP20Detailed, BEP20 {
  constructor() BEP20Detailed("Laro", "LARO", 18) {
    uint256 totalTokens = 100000000 * 10**uint256(decimals());
    _mint(msg.sender, totalTokens);
    
  }
}