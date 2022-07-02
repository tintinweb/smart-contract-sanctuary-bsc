/**
 *Submitted for verification at BscScan.com on 2022-07-02
*/

/*
 * Waifu history analyser
 */

// SPDX-License-Identifier: none

pragma solidity 0.8.15;

interface PVE {
    function girlPveDefeats(uint256 ID) external view returns (uint256);
    function girlPveWins(uint256 ID) external view returns (uint256);
}

contract WaifuHistory {

    PVE pve = PVE(0xae07Dc32B2d3d086d072429484DcF05E19BF5691);

    struct History{ 
        uint256 wins;
        uint256 defeats;
        uint256 totalFights;
        uint256 winPercentage;
    }

	constructor(){}

    function getWinsAndLosses(uint256 waifuID) public view returns(History memory) {
        History memory history;
        history.wins = pve.girlPveWins(waifuID);
        history.defeats = pve.girlPveDefeats(waifuID);
        history.totalFights = history.wins + history.defeats;
        if(history.totalFights > 0) history.winPercentage = history.wins * 10000 / history.totalFights;
        else history.winPercentage = 0;
        return history;
    }
}