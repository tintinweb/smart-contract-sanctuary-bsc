/**
 *Submitted for verification at BscScan.com on 2022-12-28
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8;

contract Percentages {
    function calculate(uint256 amount, uint256 bps) public pure returns (uint256) {
        return amount * bps / 10_000;
    }

    uint public timeOfDeath = 1 days;
    uint feedingLifespan = 2 days;

    constructor() {
        timeOfDeath = block.timestamp + 1 days;
    }

    function getTimeOfDeath() external view returns (uint){
        return timeOfDeath;
    }

    function getTimeOfDeathDiffWithNow() external view returns (uint){
        return timeOfDeath - block.timestamp;
    }

    function getOverallHealthByID() external view returns (uint){
        if(timeOfDeath < block.timestamp) return 0;
        else{
            // Calculate time remaining until timeOfDeath, compare it with max time value possible, calculate %
            uint256 healthValue = (((timeOfDeath - block.timestamp) / (feedingLifespan)) * 100);
            return healthValue;
        }
    }
}