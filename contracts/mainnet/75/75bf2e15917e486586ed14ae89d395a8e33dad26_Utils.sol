// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

library Utils {
    uint constant internal SECOND_PER_YEAR = 12 * 30 * 24 * 3600;
    uint constant internal SECOND_PER_MONTH = 30 * 24 * 3600;

    uint constant internal EXP = 1000000000;

    function getYearAndMonthBy(uint now, uint startTime) view public returns (uint, uint) {
        require(startTime != 0, "startTime is 0");
        uint delta = now - startTime;
        uint y = delta / SECOND_PER_YEAR;
        uint m_x = delta % SECOND_PER_YEAR;
        uint m = m_x / SECOND_PER_MONTH;
        return (y + 1, m + 1);
    }

    // 第y年 m月的 每秒的奖励数量
    function getRewardPerSecond(uint y, uint m, uint rewardTotalAmount) view public returns (uint) {
        uint reward = getRewardByYearAndMonth(y, m, rewardTotalAmount);
        return reward / (30 * 24 * 3600);
    }

    function getRewardFactor() pure public returns (uint) {
        return EXP;
    }

    // 第y年 m月的奖励总数
    function getRewardByYearAndMonth(uint y, uint m, uint rewardTotalAmount) view public returns (uint) {
        uint yReward = getRewardByYear(y, rewardTotalAmount);
        if (m < 11) {
            return yReward * (m + 2) / 100;
        } else {
            return yReward * (m + 1) / 100;
        }
    }

    // 第y年的奖励总数
    function getRewardByYear(uint y, uint rewardTotalAmount) view public returns (uint) {
        return rewardTotalAmount / pow(2, y);
    }
    //a^b
    function pow(uint a, uint b) pure internal returns (uint) {
        for (uint i = 1; i < b; i++) {
            a = a * a;
        }
        return a;
    }
}