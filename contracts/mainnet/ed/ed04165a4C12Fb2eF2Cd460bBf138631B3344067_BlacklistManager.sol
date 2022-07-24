/**
 *Submitted for verification at BscScan.com on 2022-07-24
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

interface AntiSnipe {
    function setBlacklistEnabled(address account, bool enabled) external;
    function setBlacklistEnabledMultiple(address[] memory accounts, bool enabled) external;
}

contract BlacklistManager {
    address public owner;
    AntiSnipe antiSnipe = AntiSnipe(0x7E0BD18C81d2d8aBD3Aaa86b7b85bdD9663d7ac6);

    modifier onlyOwner() {
        require(owner == msg.sender, "Caller =/= owner.");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function setAntisnipe(address antisnipe) external onlyOwner {
        antiSnipe = AntiSnipe(antisnipe);
    }

    function setBlacklistEnabled(address account, bool enabled) external onlyOwner {
        antiSnipe.setBlacklistEnabled(account, enabled);
    }

    function setBlacklistEnabledMultiple(address[] memory accounts, bool enabled) external onlyOwner {
        antiSnipe.setBlacklistEnabledMultiple(accounts, enabled);
    }
}