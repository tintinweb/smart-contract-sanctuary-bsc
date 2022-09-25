pragma solidity ^0.8.16;

import "./RewardToken.sol";

/**
    The BoboBonk contract.
    Visit the website : https://bobobonk.finance
    Say hi in the telegram : https://t.me/BoboBonkCoin
 */
 // SPDX-License-Identifier: MIT
contract BoboBonk is RewardToken {

    string private name_ = "BoboBonk";
    string private symbol_ = "BBB";
    uint8 private decimals_ = 9;
    uint256 private supply_ = 10**9 * 10**decimals_;
    address private marketingWallet_ = address(0x023248b8BB1CFa63398446946C410fda6Ec363BB);

    constructor() RewardToken(name_, symbol_, decimals_, supply_, marketingWallet_) {}

}