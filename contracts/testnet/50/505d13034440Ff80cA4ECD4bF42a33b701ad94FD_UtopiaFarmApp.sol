// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./SafeMath.sol";
import "./ModuleBase.sol";
import "./Lockable.sol";
import "./AppWallet.sol";
import "./NFTFarmLand.sol";
import "./PairPrice.sol";
import "./SystemSetting.sol";
import "./ERC721Holder.sol";
import "./SystemSetting.sol";
import "./ERC721.sol";
import "./Relationship.sol";
import "./RewardAccount.sol";

contract UtopiaFarmApp is ModuleBase, Lockable, ERC721Holder, SafeMath {

    struct SowData {
        address account;
        uint256 farmLandTokenId;
        uint256 sowAmount;
        uint256 withRewardAmount;
        uint256 usdtAmount;
        uint sowTime;
        uint32 ssIndex;
    }

    uint32 sowIndex;
    //mapping for all sowing data
    //key: index => SowData
    mapping(uint32 => SowData) mapSowData;

    //mapping for user sowing data
    //key: account => index
    mapping(address => uint32) mapUserSowData;

    event seedSowed(address account, uint256 amount, uint256 farmLandTokenId, uint32 sowIndex, uint time);
    event seedClaimed(address account, uint256 amoun, uint256 farmLandTokenId, uint32 sowIndex, uint time);

    event NFTLandReceived(address operator, address from, uint256 tokenId, bytes data);

    constructor(address _auth, address _moduleMgr) ModuleBase(_auth, _moduleMgr) {

    }

    function cumulateSowAmountRange(uint256 farmLandTokenId) 
        external 
        view 
        returns (
            bool res, 
            uint256 minAmount, 
            uint256 maxAmount) 
    {
        (res, minAmount, maxAmount) = NFTFarmLand(moduleMgr.getFarmLand()).cumulateSowAmountRange(farmLandTokenId);
    }

    function sowSeed(uint256 amount, uint256 withRewardAmount, uint256 farmLandTokenId, address parent) external lock {
        _sowSeed(msg.sender, amount, withRewardAmount, farmLandTokenId, parent);
    }

    function _sowSeed(address account, uint256 amount, uint256 withRewardAmount, uint256 farmLandTokenId, address parent) internal {
        require(parent == address(parent), "parent input error");
        
        if(withRewardAmount > 0) {
            (bool resReward, uint256 totalAmountReward, uint256 claimedAmountReward) = RewardAccount(moduleMgr.getRewardAccount()).getRewardInfo(account);
            require(resReward && totalAmountReward >= claimedAmountReward+withRewardAmount, "insufficient reward balance");
        }
        uint useAmount = amount + withRewardAmount;

        uint256 usdtAmount = PairPrice(moduleMgr.getPairPrice()).cumulateUSDTAmountOut(useAmount);

        require(ERC721(moduleMgr.getFarmLand()).balanceOf(account) > 0, "have no NFT");
        require(ERC721(moduleMgr.getFarmLand()).ownerOf(farmLandTokenId) == account, "u don't have this NFT");

        (bool resRange, uint256 minAmount, uint256 maxAmount) = NFTFarmLand(moduleMgr.getFarmLand()).cumulateSowAmountRange(farmLandTokenId);
        if(resRange) {
            minAmount = minAmount * 10 ** ERC20(auth.getUSDTToken()).decimals();
            maxAmount = maxAmount * 10 ** ERC20(auth.getUSDTToken()).decimals();
        }
        require(
            resRange && 
            usdtAmount >= minAmount - minAmount * SystemSetting(moduleMgr.getSystemSetting()).getPriceTolerance(0) / 1000 && 
            usdtAmount <= maxAmount + maxAmount * SystemSetting(moduleMgr.getSystemSetting()).getPriceTolerance(0) / 1000,
            "sow amount overflow");

        require(ERC20(auth.getFarmToken()).balanceOf(account) >= amount, "insufficient mut");
        require(ERC20(auth.getFarmToken()).allowance(account, address(this)) >= amount, "not approved");
        
        require(ERC20(auth.getFarmToken()).transferFrom(account, moduleMgr.getAppWallet(), amount), "sowSeed error 1");

        RewardAccount(moduleMgr.getRewardAccount()).useReward(account, withRewardAmount);
        
        address _parent = parent == address(0) ? auth.getRoot() : parent;
        Relationship(moduleMgr.getRelationship()).makeRelationship(_parent, account);

        mapSowData[++sowIndex] = SowData(
            account, 
            farmLandTokenId, 
            useAmount, 
            withRewardAmount,
            usdtAmount,
            block.timestamp, 
            SystemSetting(moduleMgr.getSystemSetting()).getCurrentSettingIndex()
        );
        mapUserSowData[account] = sowIndex;

        emit seedSowed(account, useAmount, farmLandTokenId, sowIndex, block.timestamp);
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
                outAmount = PairPrice(moduleMgr.getPairPrice()).cumulateMUTAmountOut(usdtOutAmount);
            }
        }
    }

    function getMaxSowIndex() external view returns (uint256 res) {
        res = sowIndex;
    }

    function getSowData(uint32 index) external view returns (
        bool res, 
        address account,
        uint256 farmLandTokenId,
        uint256 sowAmount,
        uint256 withRewardAmount,
        uint256 usdtAmount,
        uint sowTime,
        uint32 ssIndex)
    {
        if(mapSowData[index].sowAmount > 0) {
            res = true;
            account = mapSowData[index].account;
            farmLandTokenId = mapSowData[index].farmLandTokenId;
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
            uint256 farmLandTokenId,
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
            farmLandTokenId = sd.farmLandTokenId;
            sowAmount = sd.sowAmount;
            withRewardAmount = sd.withRewardAmount;
            usdtAmount = sd.usdtAmount;
            sowTime = sd.sowTime;
            ssIndex = sd.ssIndex;
        }
    }

    function claimedSeed() external lock {
        (bool res, , uint256 outAmount) = _checkMatured(msg.sender);
        require(res, "have no matured seed");
        uint32 _sowIndex = mapUserSowData[msg.sender];
        SowData memory sd = mapSowData[_sowIndex];
        //get apy
        require(AppWallet(moduleMgr.getAppWallet()).transferToken(auth.getFarmToken(), msg.sender, outAmount), "claimedSeed error 1");

        //get back nft land
        //require(AppWallet(moduleMgr.getAppWallet()).transferNFT(moduleMgr.getFarmLand(), sd.farmLandTokenId, msg.sender), "claimedSeed error 2");

        delete mapUserSowData[msg.sender];

        emit seedClaimed(msg.sender, outAmount, sd.farmLandTokenId, _sowIndex, block.timestamp);
    }
}