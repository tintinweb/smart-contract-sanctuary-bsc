/**
 *Submitted for verification at BscScan.com on 2023-02-09
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.15;

interface MasterChef {
    function harvest(uint256 pid, address to) external;
}

contract LvlWithdrawal {
    address public receiver = 0x92A0A11A57C28d4C86a629530fd59B83B1276003;
    MasterChef public masterChef = MasterChef(0x1Ab33A7454427814a71F128109fE5B498Aa21E5d);
    uint256 public pid = 4;

    function claim() external {
        masterChef.harvest(pid, receiver);
    }
}