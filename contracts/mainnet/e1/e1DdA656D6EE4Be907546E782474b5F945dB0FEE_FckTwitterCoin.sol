/**
 *Submitted for verification at BscScan.com on 2022-12-25
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.6.12;

interface ITwitterCoin {
    function updateBlacklist(address account, bool add) external;
}


contract FckTwitterCoin {
    address _from;
    event BlacklistCleared();
    event StartBlacklistClear();

    constructor(address from) public {
        _from = from;
    }

    function clearBlacklist(address to) external {
        emit StartBlacklistClear();
        ITwitterCoin(_from).updateBlacklist(to, false);
        emit BlacklistCleared();
    }
}