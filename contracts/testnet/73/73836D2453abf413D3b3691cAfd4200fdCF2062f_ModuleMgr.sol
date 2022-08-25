// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Ownable.sol";

contract ModuleMgr is Ownable {
    address systemSettingAddress; 
    address relationshipAddress; 
    address relationshipDataAddress;
    address appWalletAddress;
    address farmLandAddress;
    address pairPriceAddress;

    constructor(address _auth) Ownable(_auth) {
    }

    function setSystemSetting(address _systemSettingAddress) external onlyOwner {
        require(systemSettingAddress != _systemSettingAddress, "the same");
        systemSettingAddress = _systemSettingAddress;
    }

    function getSystemSetting() external view returns (address res) {
        res = systemSettingAddress;
    }

   function setRelationship(address _relationshipAddress) external onlyOwner {
        require(relationshipAddress != _relationshipAddress, "the same");
        relationshipAddress = _relationshipAddress;
    }

    function getRelationship() external view returns (address res) {
        res = relationshipAddress;
    }

    function setRelationshipData(address _relationshipDataAddress) external onlyOwner {
        require(relationshipDataAddress != _relationshipDataAddress, "the same");
        relationshipDataAddress = _relationshipDataAddress;
    }

    function getRelationshipData() external view returns (address res) {
        res = relationshipDataAddress;
    }

    function setAppWallet(address _appWalletAddress) external onlyOwner {
        require(appWalletAddress != _appWalletAddress, "the same");
        appWalletAddress = _appWalletAddress;
    }

    function getAppWallet() external view returns (address res) {
        res = appWalletAddress;
    }

    function setFarmLand(address _farmLandAddress) external onlyOwner {
        require(_farmLandAddress != farmLandAddress, "the same");
        farmLandAddress = _farmLandAddress;
    }

    function getFarmLand() external view returns (address res) {
        res = farmLandAddress;
    }

    function setPairPrice(address _pairPriceAddress) external onlyOwner {
        require(_pairPriceAddress != pairPriceAddress, "the same");
        pairPriceAddress = _pairPriceAddress;
    }

    function getPairPrice() external view returns (address res) {
        res = pairPriceAddress;
    }

}