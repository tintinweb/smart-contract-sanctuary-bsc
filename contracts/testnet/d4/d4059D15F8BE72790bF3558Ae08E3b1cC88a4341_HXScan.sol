/**
 *Submitted for verification at BscScan.com on 2022-12-19
*/

// SPDX-License-Identifier: UNLICENSED

// Telegram : https://t.me/hxscan
// Version : 1.0.0

pragma solidity ^0.8.17;

interface IHXScanBacker {
    function minSubs() external returns (uint);

    function price() external returns (uint);

    function trial() external returns (uint);

    function feeReferral() external returns (uint);

    function HXScanRegisterInternal(
        address wallet,
        uint idTelegram,
        uint referral
    ) external;
}

contract HXScan {
    address public owner;

    constructor(address new_owner) {
        owner = new_owner;
    }

    function HXScanRegister(uint idTelegram, uint referral) external {
        IHXScanBacker(owner).HXScanRegisterInternal(
            msg.sender,
            idTelegram,
            referral
        );
    }
}