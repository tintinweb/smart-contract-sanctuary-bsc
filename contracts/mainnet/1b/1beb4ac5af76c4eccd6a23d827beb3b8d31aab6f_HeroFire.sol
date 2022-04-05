// SPDX-License-Identifier: MIT

 /**
   * HeroFire.io
   * Discord: https://discord.gg/wqTTA7bxVz
   * Twitter: https://twitter.com/HeroFire_io
   * Telegram Channel: https://t.me/HeroFireOfficial
   */

pragma solidity ^0.8.0;

import "BEP20.sol";

contract HeroFire is BEP20Detailed, BEP20 {
  constructor() BEP20Detailed("HeroFire", "HRF", 9) {
    uint256 totalTokens = 100000000 * 10**uint256(decimals());
    _mint(msg.sender, totalTokens);
  }

  function burn(uint256 amount) external {
    _burn(msg.sender, amount);
  }
}