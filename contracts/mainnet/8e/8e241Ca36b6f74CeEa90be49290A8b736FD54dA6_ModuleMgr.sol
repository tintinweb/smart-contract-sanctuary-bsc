// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Ownable.sol";

contract ModuleMgr is Ownable {
    address internal appWalletAddress;
    address internal farmLandAddress;
    address internal pairPriceAddress;
    address internal landBlindBoxDataAddress;
    address internal utopiaFarmAppDataAddress;

    constructor(address _auth) Ownable(_auth) {
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

    function setLandBlindBoxData(address _landBlindBoxDataAddress) external onlyOwner {
        require(_landBlindBoxDataAddress != landBlindBoxDataAddress, "the same");
        landBlindBoxDataAddress = _landBlindBoxDataAddress;
    }

    function getLandBlindBoxData() external view returns (address res) {
        res = landBlindBoxDataAddress;
    }

    function setUtopiaFarmAppData(address _utopiaFarmAppDataAddress) external onlyOwner {
        require(_utopiaFarmAppDataAddress != utopiaFarmAppDataAddress, "the same");
        utopiaFarmAppDataAddress = _utopiaFarmAppDataAddress;
    }

    function getUtopiaFarmAppData() external view returns (address res) {
        res = utopiaFarmAppDataAddress;
    }
}