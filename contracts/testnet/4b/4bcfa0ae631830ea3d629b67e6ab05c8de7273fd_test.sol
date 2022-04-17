/**
 *Submitted for verification at BscScan.com on 2022-04-16
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

struct IntervalReward {
        uint startEpoch;
        uint endEpoch;
        uint reward;
    }

interface IReward {
    function pendingReward(uint tokenId) external view returns (IntervalReward[] memory intervalRewards);
}

contract test {
    address public reward;
    event LogPengingReward(uint tokenId, uint time, IntervalReward[] reward);

    constructor (address reward_) {
        reward = reward_;
    }

    function checkPendingReward(uint tokenId) external returns (IntervalReward[] memory rewards) {
        rewards = IReward(reward).pendingReward(tokenId);
        emit LogPengingReward(tokenId, block.timestamp, rewards);
        return rewards;
    }
}