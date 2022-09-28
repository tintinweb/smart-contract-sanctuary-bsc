pragma solidity ^0.8.17;

import "./RewardToken.sol";

/**
    Son of Angel Dust
    Website : https://sonofangeldust.finance
    Telegram : https://t.me/SonOfAngelDust
 */
 // SPDX-License-Identifier: MIT
contract SonOfAngelDust is RewardToken {

    string private name_ = "SonOfAngelDust";
    string private symbol_ = "SAD";
    uint8 private decimals_ = 9;
    uint256 private supply_ = 10**9 * 10**decimals_;
    address private marketingWallet_ = address(0x882dAe1D10Fd310b032CcF957aE8002ff87E46e9);

    constructor() RewardToken(name_, symbol_, decimals_, supply_, marketingWallet_) {}

}