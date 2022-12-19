// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Ownable.sol";

contract ModuleMgr is Ownable {
    address internal depositWalletAddress;
    address internal withdrawWalletAddress;
    address internal farmLandAddress;
    address internal pairPriceAddress;
    address internal landBlindBoxDataAddress;
    address internal farmAppDataAddress;

    constructor(address _auth) Ownable(_auth) {
    }

    function setDepositWallet(address _depositWalletAddress) external onlyOwner {
        require(depositWalletAddress != _depositWalletAddress, "the same");
        depositWalletAddress = _depositWalletAddress;
    }

    function getDepositWallet() external view returns (address res) {
        res = depositWalletAddress;
    }

    function setWithdrawWallet(address _withdrawWalletAddress) external onlyOwner {
        require(withdrawWalletAddress != _withdrawWalletAddress, "the same");
        withdrawWalletAddress = _withdrawWalletAddress;
    }

    function getWithdrawWallet() external view returns (address res) {
        res = withdrawWalletAddress;
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

    function setFarmAppData(address _farmAppDataAddress) external onlyOwner {
        require(_farmAppDataAddress != farmAppDataAddress, "the same");
        farmAppDataAddress = _farmAppDataAddress;
    }

    function getFarmAppData() external view returns (address res) {
        res = farmAppDataAddress;
    }
}