// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.14;

interface IVaultHealer {

    function vaultInfo(uint vid) external view returns (address, uint8, bool, uint48,uint16,uint16);
    function numVaultsBase() external view returns (uint16);

}
contract VaultGetterV3 {

    IVaultHealer public immutable vaultHealer;

    constructor(address _vh) {
        vaultHealer = IVaultHealer(_vh);
    }

    struct VaultInfo {
        uint vid;
        address want;
        uint8 noAutoEarn;
        bool active; //not paused
        uint48 lastEarnBlock;
        uint16 numBoosts;
        uint16 numMaximizers; //number of maximizer vaults pointing here. For vid 0x0045, its maximizer will be 0x00450001, 0x00450002, ...
    }

    function _vaultInfo(uint vid) internal view returns (VaultInfo memory info) {
        info.vid = vid;
        (info.want,
            info.noAutoEarn, 
            info.active, 
            info.lastEarnBlock, 
            info.numBoosts, 
            info.numMaximizers
        ) = vaultHealer.vaultInfo(vid);
        if (address(info.want) == address(0) && info.lastEarnBlock == 0) info.vid = 0;
    }

    function _getBase(function(VaultInfo memory, uint) view returns (bool) includeCondition, uint blk) internal view returns (VaultInfo[] memory baseInfo, uint numVaultsTotal) {

        numVaultsTotal = vaultHealer.numVaultsBase();
        baseInfo = new VaultInfo[](numVaultsTotal);

        for (uint i; i < baseInfo.length; i++) {
            uint vid = i + 1;
            baseInfo[i] = _vaultInfo(vid);

            if (includeCondition(baseInfo[i], blk)) {
                numVaultsTotal += baseInfo[i].numMaximizers;
            } else {
                numVaultsTotal -= 1;
                delete baseInfo[i];
            }
        }
    }

    function _getVaults(function(VaultInfo memory, uint) view returns (bool) includeCondition, uint blk) internal view returns (VaultInfo[] memory vaultInfo) {

        (VaultInfo[] memory baseInfo, uint numVaultsTotal) = _getBase(includeCondition, blk);
        vaultInfo = new VaultInfo[](numVaultsTotal);
        uint k;

        for (uint i; i < baseInfo.length; i++) {
            uint vid = baseInfo[i].vid;
            if (vid > 0) {
                vaultInfo[k] = baseInfo[i];
                k++;

                for (uint j; j < baseInfo[i].numMaximizers; j++) {
                    uint mVid = (vid << 16) + j + 1;
                    vaultInfo[k] = _vaultInfo(mVid);
                    if (includeCondition(vaultInfo[k],blk)) {
                        k++;
                    }
                }
            }
        }
        assembly {
            mstore(vaultInfo, k) //reduce length of array to actual size
        }
    }

    function getAllVaults() external view returns (VaultInfo[] memory vaultInfo) {
        return _getVaults(includeAll, 0);
    }

    function getActiveVaults() external view returns (VaultInfo[] memory vaultInfo) {
        return _getVaults(includeActive, 0);
    }
    function getPausedVaults() external view returns (VaultInfo[] memory vaultInfo) {
        return _getVaults(includePaused, 0);
    }
    function getActiveVaultsLastEarnedBefore(uint blk) external view returns (VaultInfo[] memory vaultInfo) {
        return _getVaults(includeActiveLastEarnBefore, blk);
    }
    function getVaultsLastEarnedBefore(uint blk) external view returns (VaultInfo[] memory vaultInfo) {
        return _getVaults(includeLastEarnBefore, blk);
    }
    function getVaultsLastEarnedAfter(uint blk) external view returns (VaultInfo[] memory vaultInfo) {
        return _getVaults(includeLastEarnAfter, blk);
    }
    function getVaultsNoAutoEarn() external view returns (VaultInfo[] memory vaultInfo) {
        return _getVaults(includeNoAutoEarn, 0);
    }
    function includeAll(VaultInfo memory info, uint) internal pure returns (bool) { return info.vid > 0; }
    function includeActive(VaultInfo memory info, uint) internal pure returns (bool) { return info.vid > 0 && info.active; }
    function includePaused(VaultInfo memory info, uint) internal pure returns (bool) { return info.vid > 0 && !info.active; }
    function includeLastEarnBefore(VaultInfo memory info, uint blk) internal pure returns (bool) { return info.vid > 0 && info.lastEarnBlock < blk; }
    function includeLastEarnAfter(VaultInfo memory info, uint blk) internal pure returns (bool) { return info.vid > 0 && info.lastEarnBlock > blk; }
    function includeNoAutoEarn(VaultInfo memory info, uint) internal pure returns (bool) { return info.vid > 0 && info.noAutoEarn > 0; }
    function includeActiveLastEarnBefore(VaultInfo memory info, uint blk) internal pure returns (bool) { return includeActive(info, blk) && includeLastEarnBefore(info, blk); }

}