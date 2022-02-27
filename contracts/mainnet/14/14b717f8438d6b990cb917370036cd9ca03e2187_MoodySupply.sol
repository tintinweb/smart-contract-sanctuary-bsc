// SPDX-License-Identifier: MIT

/**
*  ███╗   ███╗ ██████╗  ██████╗ ██████╗ ██╗   ██╗
*  ████╗ ████║██╔═══██╗██╔═══██╗██╔══██╗╚██╗ ██╔╝
*  ██╔████╔██║██║   ██║██║   ██║██║  ██║ ╚████╔╝ 
*  ██║╚██╔╝██║██║   ██║██║   ██║██║  ██║  ╚██╔╝  
*  ██║ ╚═╝ ██║╚██████╔╝╚██████╔╝██████╔╝   ██║   
*  ╚═╝     ╚═╝ ╚═════╝  ╚═════╝ ╚═════╝    ╚═╝   
*
*  This token is a Tax and limits free on buy or sell.
*  Website: https://www.WeMoody.com
*  Twitter: https://www.twitter.com/MoodyCoin
*  Telegram: https://www.t.me/MoodyCoinChat
*  Github: https://www.github.com/MoodyCoin
*/

pragma solidity ^0.8.12;

import "./Moody.sol";

contract MoodySupply is Moody {
  constructor() Moody('Moody', 'MOD') {
    _mint(msg.sender, 1000000000 * 10 ** 18);
  }
}