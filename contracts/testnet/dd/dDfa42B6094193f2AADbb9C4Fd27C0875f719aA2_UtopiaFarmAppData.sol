// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./SafeMath.sol";
import "./ModuleBase.sol";
import "./SystemSetting.sol";
import "./PairPrice.sol";

contract UtopiaFarmAppData is ModuleBase, SafeMath{

    struct SowData {
        uint256 sowId;
        address account;
        uint256 sowAmount;
        uint256 withRewardAmount;
        uint256 usdtAmount;
        uint sowTime;
        uint32 ssIndex;
    }

    uint32 roundIndex;
    //mapping for all sowing data
    //key: index => SowData
    mapping(uint32 => SowData) mapSowData;

    //mapping for user sowing data
    //key: account => index
    mapping(address => uint32) mapUserSowData;

    //mapping for sowId, check if sowid
    mapping(uint256 => bool) mapSowId;

    constructor(address _auth, address _moduleMgr) ModuleBase(_auth, _moduleMgr) {
    }

    function getCurrentRoundNumber() external view returns (uint32 res) {
        res = roundIndex;
    }

    function increaseRoundNumber(uint32 n) external onlyCaller {
        roundIndex += n;
    }

    function setSowIdUsed(uint256 sowId) external onlyCaller {
        mapSowId[sowId] = true;
    }

    function isSowIdUsed(uint256 sowId) external view returns (bool res) {
        res = mapSowId[sowId];
    }

    function isUserSowing(address account) external view returns (bool res) {
        res = mapUserSowData[account] > 0;
    }

    function newSowData(uint32 roundNumber, uint256 sowId, address account, uint256 useAmount, uint256 withRewardAmount, uint256 usdtAmount, uint256 timestamp, uint32 ssIndex) external onlyCaller {
        mapSowData[roundNumber] = SowData(
            sowId,
            account, 
            useAmount, 
            withRewardAmount,
            usdtAmount,
            timestamp, 
            ssIndex
        );
    }

    function setUserSowData(address account, uint32 roundNumber) external onlyCaller {
        mapUserSowData[account] = roundNumber;
    }

    function checkMatured(address account) external view returns(bool res, uint256 sowAmount, uint256 outAmount) {
        (res, sowAmount, outAmount) = _checkMatured(account);
    }

    function _checkMatured(address account) internal view returns(bool res, uint256 sowAmount, uint256 outAmount) {
        if(mapUserSowData[account] > 0) {
            SowData memory sd = mapSowData[mapUserSowData[account]];
            if(block.timestamp >= add(sd.sowTime, SystemSetting(moduleMgr.getSystemSetting()).getMatureTime(sd.ssIndex))) {
                res = true;
                sowAmount = sd.sowAmount;
                uint256 cycleYieldsPercent = SystemSetting(moduleMgr.getSystemSetting()).getCycleYieldsPercent(sd.ssIndex);
                uint256 usdtOutAmount = add(sd.usdtAmount, div(mul(sd.usdtAmount, cycleYieldsPercent), 1000));
                outAmount = PairPrice(moduleMgr.getPairPrice()).cumulateUTOAmountIn(usdtOutAmount);
            }
        }
    }

    function getSowData(uint32 index) external view returns (
        bool res, 
        uint256 sowId,
        address account,
        uint256 sowAmount,
        uint256 withRewardAmount,
        uint256 usdtAmount,
        uint sowTime,
        uint32 ssIndex)
    {
        if(mapSowData[index].sowAmount > 0) {
            res = true;
            sowId = mapSowData[index].sowId;
            account = mapSowData[index].account;
            sowAmount = mapSowData[index].sowAmount;
            withRewardAmount = mapSowData[index].withRewardAmount;
            usdtAmount = mapSowData[index].usdtAmount;
            sowTime = mapSowData[index].sowTime;
            ssIndex = mapSowData[index].ssIndex;
        }
    }

    function getUserSowData(address account) 
        external 
        view 
        returns (
            bool res,
            uint256 sowId,
            uint256 sowAmount,
            uint256 withRewardAmount,
            uint256 usdtAmount,
            uint sowTime,
            uint32 ssIndex
        ) 
    {
        if(mapUserSowData[account] > 0) {
            SowData memory sd = mapSowData[mapUserSowData[account]];
            res = true;
            sowId = sd.sowId;
            sowAmount = sd.sowAmount;
            withRewardAmount = sd.withRewardAmount;
            usdtAmount = sd.usdtAmount;
            sowTime = sd.sowTime;
            ssIndex = sd.ssIndex;
        }
    }

    function getUserCurrentRoundIndex(address account) external view returns (uint32 res) {
        res = mapUserSowData[account];
    }

    function deleteUserSowData(address account) external onlyCaller {
        delete mapUserSowData[account];
    }
}