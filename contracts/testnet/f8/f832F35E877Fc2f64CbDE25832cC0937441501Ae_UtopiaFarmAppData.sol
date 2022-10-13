// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./SafeMath.sol";
import "./ModuleBase.sol";
import "./PairPrice.sol";

contract UtopiaFarmAppData is ModuleBase, SafeMath{

    struct SowData {
        uint32 sowId;
        address account;
        uint256 sowAmount;
        uint256 withRewardAmount;
        uint256 usdtAmount;
        uint256 matureTime;
        uint256 profitPercent;
        uint sowTime;
    }

    uint32 roundIndex;
    //mapping for all sowing data
    //key: index => SowData
    mapping(uint32 => SowData) mapSowData;

    mapping(uint32 => uint32) mapSowIdRoundNumber;

    //mapping for sow status
    //key: sowId => status, status:1 sowing, 2:claimed
    mapping(uint32 => uint8) mapSowStatus;

    constructor(address _auth, address _moduleMgr) ModuleBase(_auth, _moduleMgr) {
    }

    function getCurrentRoundNumber() external view returns (uint32 res) {
        res = roundIndex;
    }

    function increaseRoundNumber(uint32 n) external onlyCaller {
        roundIndex += n;
    }

    function setSowStatus(uint32 sowId, uint8 status) external onlyCaller {
        mapSowStatus[sowId] = status;
    }

    function getSowStatus(uint32 sowId) external view returns (uint8 res) {
        res = mapSowStatus[sowId];
    }

    function newSowData(
        uint32 roundNumber, 
        uint32 sowId, 
        address account, 
        uint256 useAmount, 
        uint256 withRewardAmount, 
        uint256 usdtAmount, 
        uint256 matureTime, 
        uint256 profitPercent, 
        uint256 timestamp
    ) external onlyCaller {
        mapSowData[roundNumber] = SowData(
            sowId,
            account, 
            useAmount, 
            withRewardAmount,
            usdtAmount,
            matureTime,
            profitPercent,
            timestamp
        );
        mapSowIdRoundNumber[sowId] = roundNumber;
    }

    function checkMatured(address account, uint32 sowId) external view returns(bool res, uint256 sowAmount, uint256 outAmount) {
        (res, sowAmount, outAmount) = _checkMatured(account, sowId);
    }

    function _checkMatured(address account, uint32 sowId) internal view returns(bool res, uint256 sowAmount, uint256 outAmount) {
        uint32 roundNumber = mapSowIdRoundNumber[sowId];
        if(roundNumber > 0) {
            SowData memory sd = mapSowData[roundNumber];
            if(account == sd.account && block.timestamp >= add(sd.sowTime, sd.matureTime)) {
                res = true;
                sowAmount = sd.sowAmount;
                uint256 usdtOutAmount = add(sd.usdtAmount, div(mul(sd.usdtAmount, sd.profitPercent), 1000));
                outAmount = PairPrice(moduleMgr.getPairPrice()).cumulateUTOAmountIn(usdtOutAmount);
            }
        }
    }

    function getSowData(uint32 roundNumber) external view returns (
        bool res, 
        uint32 sowId,
        address account,
        uint256 sowAmount,
        uint256 withRewardAmount,
        uint256 usdtAmount,
        uint sowTime)
    {
        if(mapSowData[roundNumber].sowAmount > 0) {
            res = true;
            sowId = mapSowData[roundNumber].sowId;
            account = mapSowData[roundNumber].account;
            sowAmount = mapSowData[roundNumber].sowAmount;
            withRewardAmount = mapSowData[roundNumber].withRewardAmount;
            usdtAmount = mapSowData[roundNumber].usdtAmount;
            sowTime = mapSowData[roundNumber].sowTime;
        }
    }

    function getUserSowData(address account, uint32 sowId) 
        external 
        view 
        returns (
            bool res,
            uint256 sowAmount,
            uint256 withRewardAmount,
            uint256 usdtAmount,
            uint sowTime
        ) 
    {
        uint32 roundNumber = mapSowIdRoundNumber[sowId];
        if(roundNumber > 0) {
            SowData memory sd = mapSowData[roundNumber];
            if(account == sd.account){
                res = true;
                sowId = sd.sowId;
                sowAmount = sd.sowAmount;
                withRewardAmount = sd.withRewardAmount;
                usdtAmount = sd.usdtAmount;
                sowTime = sd.sowTime;
            }
        }
    }
}