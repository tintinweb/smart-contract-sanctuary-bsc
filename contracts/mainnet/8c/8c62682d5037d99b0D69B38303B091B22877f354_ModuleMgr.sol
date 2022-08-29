// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Ownable.sol";

contract ModuleMgr is Ownable {
    address systemSettingAddress; 
    address farmLandAddress;
    address relationshipAddress; 
    address relationshipDataAddress;
    address appDataAddress;
    address appWalletAddress;
    address consolationWalletAddress;
    address consolationAddress;
    address couponAddress;

    constructor(address _systemAuthAddress) Ownable(_systemAuthAddress) {
    }

    function updateModuleSystemSetting(address _systemSettingAddress) external onlyOwner {
        require(systemSettingAddress != _systemSettingAddress, "the same");
        systemSettingAddress = _systemSettingAddress;
    }

    function updateModuleFarmLand(address _farmLandAddress) external onlyOwner {
        require(farmLandAddress != _farmLandAddress, "the same");
        farmLandAddress = _farmLandAddress;
    }

    function updateModuleRelationship(address _relationshipAddress) external onlyOwner {
        require(relationshipAddress != _relationshipAddress, "the same");
        relationshipAddress = _relationshipAddress;
    }

    function updateModuleRelationshipData(address _relationshipDataAddress) external onlyOwner {
        require(relationshipDataAddress != _relationshipDataAddress, "the same");
        relationshipDataAddress = _relationshipDataAddress;
    }

    function updateModuleAppData(address _appDataAddress) external onlyOwner {
        require(appDataAddress != _appDataAddress, "the same");
        appDataAddress = _appDataAddress;
    }

    function updateModuleAppWallet(address _appWalletAddress) external onlyOwner {
        require(appWalletAddress != _appWalletAddress, "the same");
        appWalletAddress = _appWalletAddress;
    }

    function getModuleSystemSetting() external view returns (address res) {
        res = systemSettingAddress;
    }

    function getModuleFarmLand() external view returns (address res) {
        res = farmLandAddress;
    }

    function getModuleRelationship() external view returns (address res) {
        res = relationshipAddress;
    }

    function getModuleRelationshipData() external view returns (address res) {
        res = relationshipDataAddress;
    }

    function getModuleAppData() external view returns (address res) {
        res = appDataAddress;
    }

    function getModuleAppWallet() external view returns (address res) {
        res = appWalletAddress;
    }

    function updateModuleConsolationWallet(address addr) external onlyOwner {
        require(consolationWalletAddress != addr, "the same");
        consolationWalletAddress = addr;
    }

    function getModuleConsolationWallet() external view returns (address res) {
        res = consolationWalletAddress;
    }

    function updateModuleConsolation(address addr) external onlyOwner {
        require(consolationAddress != addr, "the same");
        consolationAddress = addr;
    }

    function getModuleConsolation() external view returns (address res) {
        res = consolationAddress;
    }

    function updateModuleCoupon(address addr) external onlyOwner {
        require(couponAddress != addr, "the same");
        couponAddress = addr;
    }

    function getModuleCoupon() external view returns (address res) {
        res = couponAddress;
    }
}