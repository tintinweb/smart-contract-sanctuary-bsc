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

contract UtopiaFarmApp is ModuleBase, Lockable, ERC721Holder, SafeMath {

    struct SowData {
        address account;
        uint256 farmLandTokenId;
        uint256 sowAmount;
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

    function sowSeed(uint256 amount, uint256 farmLandTokenId, address parent) external lock {
        require(parent == address(parent), "parent input error");
        
        uint256 usdtAmount = PairPrice(moduleMgr.getPairPrice()).cumulateUSDTAmountOut(amount);

        (bool resRange, uint256 minAmount, uint256 maxAmount) = NFTFarmLand(moduleMgr.getFarmLand()).cumulateSowAmountRange(farmLandTokenId);
        require(
            resRange && 
            usdtAmount >= minAmount - minAmount * SystemSetting(moduleMgr.getSystemSetting()).getPriceTolerance(0) / 1000 && 
            usdtAmount <= maxAmount + maxAmount * SystemSetting(moduleMgr.getSystemSetting()).getPriceTolerance(0) / 1000,
            "sow amount overflow");

        require(ERC20(auth.getFarmToken()).balanceOf(msg.sender) >= amount, "insufficient mut");
        require(ERC20(auth.getFarmToken()).allowance(msg.sender, address(this)) >= amount, "not approved");
        
        require(ERC721(moduleMgr.getFarmLand()).ownerOf(farmLandTokenId) == msg.sender, "not owner of this NFT land");
        require(ERC721(moduleMgr.getFarmLand()).balanceOf(msg.sender) > 0, "insufficient NFT land");
        require(ERC721(moduleMgr.getFarmLand()).getApproved(farmLandTokenId) == address(this), "NFT land not approved");

        require(ERC20(auth.getFarmToken()).transferFrom(msg.sender, address(this), amount), "sowSeed error 1");
        ERC721(moduleMgr.getFarmLand()).safeTransferFrom(msg.sender, address(this), farmLandTokenId);

        if(parent != address(0)) {
            Relationship(moduleMgr.getRelationship()).makeRelationship(parent, msg.sender);
        }

        mapSowData[++sowIndex] = SowData(
            msg.sender, 
            farmLandTokenId, 
            amount, 
            usdtAmount,
            block.timestamp, 
            SystemSetting(moduleMgr.getSystemSetting()).getCurrentSettingIndex()
        );
        mapUserSowData[msg.sender] = sowIndex;

        emit seedSowed(msg.sender, amount, farmLandTokenId, sowIndex, block.timestamp);
    }

    function _cumulateMUTAmount(uint256 landIndex) internal view returns (uint256 needMUTAmount) {
        (bool res, uint256 landPrice) = NFTFarmLand(moduleMgr.getFarmLand()).getLandPriceByIndex(landIndex);
        require(res && landPrice > 0, "land price not set");
        (bool resLand, uint256 landArea, ) = NFTFarmLand(moduleMgr.getFarmLand()).getLand(landPrice);
        require(resLand && landArea > 0, "land area not set");
        uint256 needUSDTAmount = landArea*10**ERC20(auth.getUSDTToken()).decimals();
        needMUTAmount = PairPrice(moduleMgr.getPairPrice()).cumulateMUTAmountOut(needUSDTAmount);
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
        uint256 usdtAmount,
        uint sowTime,
        uint32 ssIndex)
    {
        if(mapSowData[index].sowAmount > 0) {
            res = true;
            account = mapSowData[index].account;
            farmLandTokenId = mapSowData[index].farmLandTokenId;
            sowAmount = mapSowData[index].sowAmount;
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
        require(ERC20(auth.getFarmToken()).balanceOf(address(this)) >= outAmount, "insufficient mut balance");
        require(ERC20(auth.getFarmToken()).transfer(msg.sender, outAmount), "claimedSeed error 1");

        //get back nft land
        require(ERC721(moduleMgr.getFarmLand()).balanceOf(address(this)) > 0, "insufficient nft token balance");
        require(ERC721(moduleMgr.getFarmLand()).ownerOf(sd.farmLandTokenId) == address(this), "don't have token id");
        ERC721(moduleMgr.getFarmLand()).safeTransferFrom(address(this), msg.sender, sd.farmLandTokenId);

        delete mapUserSowData[msg.sender];

        emit seedClaimed(msg.sender, outAmount, sd.farmLandTokenId, _sowIndex, block.timestamp);
    }
}