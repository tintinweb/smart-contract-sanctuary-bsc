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

    function _getBase() internal view returns (VaultInfo[] memory baseInfo, uint numVaultsTotal) {

        numVaultsTotal = vaultHealer.numVaultsBase();
        baseInfo = new VaultInfo[](numVaultsTotal);

        for (uint i; i < baseInfo.length; i++) {
            VaultInfo memory info = _vaultInfo(i + 1);
            baseInfo[i] = info;

            numVaultsTotal += info.numMaximizers;
        }
    }

    function _getVaults(function(VaultInfo memory, uint, address) view returns (bool) includeCondition, uint blk, address token) internal view returns (uint[] memory vids) {

        (VaultInfo[] memory baseInfo, uint numVaultsTotal) = _getBase();
        vids = new uint[](numVaultsTotal);
        uint k;

        for (uint i; i < baseInfo.length; i++) {
            uint vid = baseInfo[i].vid;

            if (includeCondition(baseInfo[i], blk, token))
                vids[k++] = vid;

            for (uint j = 1; j <= baseInfo[i].numMaximizers; j++) {
                uint maxiVid = (vid << 16) + j;
                if (includeCondition(_vaultInfo(maxiVid),blk,token)) 
                    vids[k++] = maxiVid;
            }
        }
        assembly ("memory-safe") { mstore(vids, k) } //reduce length of array to actual size
    }

    function getAllVaults() external view returns (uint[] memory vids) {
        return _getVaults(includeAll, 0, address(0));
    }

    function getActiveVaults() external view returns (uint[] memory vids) {
        return _getVaults(includeActive, 0, address(0));
    }
    function getPausedVaults() external view returns (uint[] memory vids) {
        return _getVaults(includePaused, 0, address(0));
    }
    function getActiveVaultsLastEarnedBefore(uint blk) external view returns (uint[] memory vids) {
        return _getVaults(includeActiveLastEarnBefore, blk, address(0));
    }
    function getVaultsLastEarnedBefore(uint blk) external view returns (uint[] memory vids) {
        return _getVaults(includeLastEarnBefore, blk, address(0));
    }
    function getVaultsLastEarnedAfter(uint blk) external view returns (uint[] memory vids) {
        return _getVaults(includeLastEarnAfter, blk, address(0));
    }
    function getVaultsNoAutoEarn() external view returns (uint[] memory vids) {
        return _getVaults(includeNoAutoEarn, 0, address(0));
    }
    function getVaultsWant(address token) external view returns (uint[] memory vids) {
        return _getVaults(includeWant, 0, token);
    }
    function getBoostedVaults() external view returns (uint[] memory vids) {
        return _getVaults(includeBoosted, 0, address(0));
    }
    function getActiveVaultsWant(address token) external view returns (uint[] memory vids) {
        return _getVaults(includeActiveWant, 0, token);
    }
    function getActiveBoostedVaults() external view returns (uint[] memory vids) {
        return _getVaults(includeActiveBoosted, 0, address(0));
    }

    function includeAll(VaultInfo memory, uint, address) internal pure returns (bool) { return true; }
    function includeActive(VaultInfo memory info, uint, address) internal pure returns (bool) { return info.active; }
    function includePaused(VaultInfo memory info, uint, address) internal pure returns (bool) { return !info.active; }
    function includeLastEarnBefore(VaultInfo memory info, uint blk, address) internal pure returns (bool) { return info.lastEarnBlock < blk; }
    function includeLastEarnAfter(VaultInfo memory info, uint blk, address) internal pure returns (bool) { return info.lastEarnBlock > blk; }
    function includeNoAutoEarn(VaultInfo memory info, uint, address) internal pure returns (bool) { return info.noAutoEarn > 0; }
    function includeActiveLastEarnBefore(VaultInfo memory info, uint blk, address) internal pure returns (bool) { return info.active && info.lastEarnBlock < blk; }
    function includeWant(VaultInfo memory info, uint, address token) internal pure returns (bool) { return info.want == token; }
    function includeBoosted(VaultInfo memory info, uint, address) internal pure returns (bool) { return info.numBoosts > 0; }
    function includeActiveWant(VaultInfo memory info, uint, address token) internal pure returns (bool) { return info.active && info.want == token; }
    function includeActiveBoosted(VaultInfo memory info, uint, address) internal pure returns (bool) { return info.active && info.numBoosts > 0; }
}