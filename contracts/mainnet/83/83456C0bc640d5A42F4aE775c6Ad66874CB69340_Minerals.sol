/**
🐺 Wolf King 🐺
‼ ️The world's first multiple dividend mechanism‼ ️
‼ ️GameFi + metaverse game landing‼ ️
‼ ️Short-term goals, to the moon‼ ️

💎 Tax 10%
✅ 1% Burn
✅ 2% Reflow
✅ 1% Reflection
✅ 0.5% Marketing
✅ 0.5% Fund pool
✅ 5% Bonus

💎 5% Bonus
✅ 1~10 level: 0.3%
✅ 11~20 level: 0.2%

📖 Binding method:
🎯 The recommender can airdrop any amount of WOLF to the unheld WOLF address
✨ 20th Generation Market Dividend Rewards
⛳️ Sign a lifetime contract
🚀 Enjoy permanent benefits
🔐 100% smart contract control
📱 All information on the chain can be checked and cannot be tampered with

🛫 Follow us
🌐 Website: https://www.wolfkingtoken.com
✈️ Telegram: https://t.me/wolfkingtoken
*/

// SPDX-License-Identifier: MIT LICENSE

pragma solidity ^0.8.0;
import "./ERC20.sol";
import "./Ownable.sol";

contract Minerals is ERC20, Ownable {

  // a mapping from an address to whether or not it can mint / burn
  mapping(address => bool) controllers;
  
  constructor() ERC20("Minerals", "MAS") { }

  /**
   * mints $MAS to a recipient
   * @param to the recipient of the $MAS
   * @param amount the amount of $MAS to mint
   */
  function mint(address to, uint256 amount) external {
    require(controllers[msg.sender], "Only controllers can mint");
    _mint(to, amount);
  }

  /**
   * burns $MAS from a holder
   * @param from the holder of the $MAS
   * @param amount the amount of $MAS to burn
   */
  function burn(address from, uint256 amount) external {
    require(controllers[msg.sender], "Only controllers can burn");
    _burn(from, amount);
  }

  /**
   * enables an address to mint / burn
   * @param controller the address to enable
   */
  function addController(address controller) external onlyOwner {
    controllers[controller] = true;
  }

  /**
   * disables an address from minting / burning
   * @param controller the address to disbale
   */
  function removeController(address controller) external onlyOwner {
    controllers[controller] = false;
  }
}