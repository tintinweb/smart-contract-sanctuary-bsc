pragma solidity ^0.8.16;

import "./RewardToken.sol";

/**
    The IGWT contract.
    Visit the website : https://rewarding.gold
    Say hi in the telegram : https://t.me/InGoldWeTrustBSC
 */
 // SPDX-License-Identifier: MIT
contract IGWT is RewardToken {

    string private name_ = "In Gold We Trust";
    string private symbol_ = "IGWT";
    uint8 private decimals_ = 9;
    uint256 private supply_ = 10**12 * 10**decimals_;

    constructor() RewardToken(name_, symbol_, decimals_, supply_) {}

}