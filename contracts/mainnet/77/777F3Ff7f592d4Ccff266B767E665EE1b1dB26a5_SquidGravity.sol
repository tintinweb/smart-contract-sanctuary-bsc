pragma solidity ^0.8.16;

import "./DebasingToken.sol";

/**
    The SquidGravity token : debasing every hour.
    Visit the website : https://squidgravity.xyz/
    Chat with the community in the Telegram channel : https://t.me/squidgravity
 */
 // SPDX-License-Identifier: MIT
contract SquidGravity is DebasingToken {

    string private name_ = "SquidGravity";
    string private symbol_ = "SGRV";
    uint8 private decimals_ = 9;
    uint256 private supply_ = 10**12 * 10**decimals_;

    constructor() DebasingToken(name_, symbol_, decimals_, supply_) {}

}