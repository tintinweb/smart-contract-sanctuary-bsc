/*************************************************************************************
 * 
 * Autor & Owner: BotPlenet
 *
 * 446576656c6f7065723a20416e746f6e20506f6c656e79616b61 *****************************/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import "./WhitelistClaim.sol";

contract BOTClaimSEED is WhitelistClaim {

    // Constants

    address private constant BOT_ADDRESS = 0x1Ab7E7DEdA201E5Ea820F6C02C65Fce7ec6bEd32;
    address private constant OWNER_ADDRESS = 0xb67bbdac128Fd882AA76EaE3Fb21B623B8A15977;
    uint256 private constant DEFAULT_TOTAL_PERIODS = 10;
    uint256 private constant FIRST_DATE_TO_CLAIM = 1651147200; // 12:00 UTC 28-04-2022

    // Constructor

    constructor() 
        WhitelistClaim(
            BOT_ADDRESS, 
            OWNER_ADDRESS, 
            (30 days),
            DEFAULT_TOTAL_PERIODS,
            FIRST_DATE_TO_CLAIM) {
    }
}