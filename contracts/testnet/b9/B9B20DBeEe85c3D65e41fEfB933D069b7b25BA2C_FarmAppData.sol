// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./SafeMath.sol";
import "./ModuleBase.sol";
import "./PairPrice.sol";
import "./ECDSA.sol";

contract FarmAppData is ModuleBase, SafeMath, ECDSA{

    address internal signer;

    struct SowData {
        uint32 sowId;
        address account;
        uint256 sowAmount;
        uint256 usdtAmount;
        uint256 matureTime;
        uint256 profitPercent;
        uint sowTime;
    }

    struct WithdrawData {
        address account;
        uint256 mmtAmount;
        uint256 usdtValue;
        uint256 withdrawTime;
        bool exists;
    }

    uint32 internal roundIndex;
    //mapping for all sowing data
    //key: index => SowData
    mapping(uint32 => SowData) internal mapSowData;

    mapping(uint32 => uint32) internal mapSowIdRoundNumber;

    //mapping for sow status
    //key: sowId => status, status:1 sowing, 2:claimed
    mapping(uint32 => uint8) internal mapSowStatus;

    //key: withdrawId => WithdrawData
    mapping(uint32 => WithdrawData) private mapWithdraw;
    //key: user wallet address => withdraw length
    mapping(address => uint32) mapUserWithdrawLength;
    //key: usre wallet address => (index of withdraw length => withdrawId)
    mapping(address => mapping(uint32 => uint32)) mapUserWithdrawData;

    constructor(address _auth, address _moduleMgr) ModuleBase(_auth, _moduleMgr) {
    }

    function setSigner(address _signer) external onlyOwner {
        signer = _signer;
    }

    function getSigner() external view returns (address res) {
        res = signer;
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
        uint256 sowAmount, 
        uint256 usdtAmount, 
        uint256 matureTime, 
        uint256 profitPercent, 
        uint256 timestamp
    ) external onlyCaller {
        mapSowData[roundNumber] = SowData(
            sowId,
            account, 
            sowAmount, 
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
                outAmount = PairPrice(moduleMgr.getPairPrice()).cumulateMMTAmountIn(usdtOutAmount);
            }
        }
    }

    function checkMatured(address account, uint32 sowId, uint256 shortenTime, bytes memory signature) external view returns(bool res, uint256 sowAmount, uint256 outAmount) {
        (res, sowAmount, outAmount) = _checkMatured(account, sowId, shortenTime, signature);
    }

    function _checkMatured(address account, uint32 sowId, uint256 shortenTime, bytes memory signature) internal view returns(bool res, uint256 sowAmount, uint256 outAmount) {
        string memory message = string(abi.encodePacked(Strings.addressToString(account),
                                                        Strings.uint256ToString(sowId),
                                                        Strings.uint256ToString(shortenTime)
                                                    ));
        if(_IsSignValid(message, signature)) {
            uint32 roundNumber = mapSowIdRoundNumber[sowId];
            if(roundNumber > 0) {
                SowData memory sd = mapSowData[roundNumber];
                if(account == sd.account && block.timestamp >= add(sd.sowTime, sub(sd.matureTime, shortenTime))) {
                    res = true;
                    sowAmount = sd.sowAmount;
                    uint256 usdtOutAmount = add(sd.usdtAmount, div(mul(sd.usdtAmount, sd.profitPercent), 1000));
                    outAmount = PairPrice(moduleMgr.getPairPrice()).cumulateMMTAmountIn(usdtOutAmount);
                }
            }
        }
    }

    function getSowData(uint32 roundNumber) external view returns (
        bool res, 
        uint32 sowId,
        address account,
        uint256 sowAmount,
        uint256 usdtAmount,
        uint sowTime)
    {
        if(mapSowData[roundNumber].sowAmount > 0) {
            res = true;
            sowId = mapSowData[roundNumber].sowId;
            account = mapSowData[roundNumber].account;
            sowAmount = mapSowData[roundNumber].sowAmount;
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
                usdtAmount = sd.usdtAmount;
                sowTime = sd.sowTime;
            }
        }
    }

    function setWithdrawData(uint32 withdrawId, address account, uint256 mmtAmount, uint256 usdtValue) external onlyCaller {
        mapWithdraw[withdrawId] = WithdrawData(account, mmtAmount, usdtValue, block.timestamp, true);
        mapUserWithdrawLength[account] ++;
        mapUserWithdrawData[account][mapUserWithdrawLength[account]] = withdrawId;
    }

    function getWithdrawStatus(uint32 withdrawId) external view returns (bool status) {
        status = mapWithdraw[withdrawId].exists;
    }

    function _IsSignValid(string memory message, bytes memory signature) internal view returns(bool) {
        return signer == recover(
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n",
                    Strings.toString(bytes(message).length),
                    message
                )
            ),
            signature
        );
    }

    function triggerWithdrawLimit(address account, uint256 usdtValue) external view returns (bool res) {
        if(usdtValue >= 2000*10**18) {
            res = true;
        } else {
            uint256 sum = 0;
            for(uint32 i = mapUserWithdrawLength[account]; i > 0; -- i) {
                uint32 withdrawId = mapUserWithdrawData[account][i];
                WithdrawData memory wd = mapWithdraw[withdrawId];
                if(block.timestamp <= wd.withdrawTime + 3600) {
                    sum += wd.usdtValue;
                    if(sum >= 2000*10**18) {
                        res = true;
                        break;
                    }
                } else {
                    break;
                }
            }
        }
    }
}