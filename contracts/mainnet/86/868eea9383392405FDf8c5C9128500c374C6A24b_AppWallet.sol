// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./SafeMath.sol";
import "./ERC20.sol";
import "./MUTFarmAppData.sol";
import "./ModuleBase.sol";

contract AppWallet is SafeMath, ModuleBase {

    constructor(address _auth, address _mgr) ModuleBase(_auth, _mgr) {
    }

    function transferToken(address erc20TokenAddress, address to, uint256 amount) external onlyCaller returns (bool res) {
        require(ERC20(erc20TokenAddress).balanceOf(address(this)) >= amount, "insufficient balance to withdraw token from AppWallet");
        (bool transfered) = ERC20(erc20TokenAddress).transfer(to, amount);
        require(transfered, "error while withdrawing token from AppWallet");
        res = true;
    }

    function transferCoin(address to, uint256 amount) external onlyCaller returns (bool res) {
        require(address(this).balance >= amount, "insufficient balance to withdraw coin from AppWallet");
        (bool sent, ) = to.call{value: amount}("");
        require(sent, "error while withdrawing coind from AppWallet");
        res = true;
    }

    function withdrawToken(address erc20TokenAddress, address to, uint256 amount) external onlyOwner returns (bool res) {
        require(ssAuth.getPayment() != erc20TokenAddress, "payment base fundation can not be withdrawed");
        require(ERC20(erc20TokenAddress).balanceOf(address(this)) >= amount, "insufficient balance in app wallet");
        (bool transfered) = ERC20(erc20TokenAddress).transfer(to, amount);
        require(transfered, "withdrawToken error");
        res = true;
    }

    //withdraw system fund
    function withdrawSysFund(uint256 amount, address to) external onlyOwner returns (bool res) {
        require(ERC20(ssAuth.getPayment()).balanceOf(address(this)) >= amount, "$$$%%%");
        require(MUTFarmAppData(moduleMgr.getModuleAppData()).getSysFundAmount() >= amount, "&&&***");
        require(ERC20(ssAuth.getPayment()).transfer(to, amount), "Failed to withdraw system fund");
        MUTFarmAppData(moduleMgr.getModuleAppData()).decreaseSysFundAmount(amount);
        res = true;
    }

    function withdrawCharity(uint256 amount, address to) external onlyOwner returns (bool res){
        require(ERC20(ssAuth.getPayment()).balanceOf(address(this)) >= amount, "$$$%%%");
        require(MUTFarmAppData(moduleMgr.getModuleAppData()).getCharityAmount() >= amount, "&&&***");
        require(ERC20(ssAuth.getPayment()).transfer(to, amount), "Failed to withdraw charity");
        MUTFarmAppData(moduleMgr.getModuleAppData()).decreaseCharityAmount(amount);
        res = true;
    }

    //collect user's forgotten money of seed
    function collectForgottenSeed(address account, uint32 roundNumber, address to) external onlyOwner returns (bool res) {
        require(MUTFarmAppData(moduleMgr.getModuleAppData()).isRoundExists(roundNumber), "Round not exists");
        require(MUTFarmAppData(moduleMgr.getModuleAppData()).isUserSeedExists(roundNumber, account), "money not available");
        (bool avaible, uint256 amount) = MUTFarmAppData(moduleMgr.getModuleAppData()).userForgottenSeedAvailable(account, roundNumber);
        require(avaible && amount > 0, "have no forgotten seed");
        require(ERC20(ssAuth.getPayment()).balanceOf(address(this)) >= amount, "insufficient balance");
        (bool transfered) = ERC20(ssAuth.getPayment()).transfer(to, amount);
        require(transfered, "error while withdrawing token from AppWallet");
        MUTFarmAppData(moduleMgr.getModuleAppData()).deleteUserSeedData(account, roundNumber);
        res = true;
    }

    function collectForgottenFomoReward(uint32 roundNumber, address to) external onlyOwner returns (bool res) {
        (
            bool res1,
            address account1,
            uint256 amount1
        ) = MUTFarmAppData(moduleMgr.getModuleAppData()).getLastInRewardAddress(roundNumber);
        if(res1 && !MUTFarmAppData(moduleMgr.getModuleAppData()).isFomoRewardTransfered(account1, roundNumber) 
        && MUTFarmAppData(moduleMgr.getModuleAppData()).getRoundLastTime(roundNumber) <= sub(block.timestamp, SystemSetting(moduleMgr.getModuleSystemSetting()).getFixedTimeForgotten(0))){
            _claimFomoReward(account1, amount1, to);
        }
        (
            bool res2,
            address account2,
            uint256 amount2
        ) = MUTFarmAppData(moduleMgr.getModuleAppData()).getMostInRewardAddress(roundNumber);
        if(res2 && !MUTFarmAppData(moduleMgr.getModuleAppData()).isFomoRewardTransfered(account2, roundNumber) 
        && MUTFarmAppData(moduleMgr.getModuleAppData()).getRoundLastTime(roundNumber) <= sub(block.timestamp, SystemSetting(moduleMgr.getModuleSystemSetting()).getFixedTimeForgotten(0))){
            _claimFomoReward(account2, amount2, to);
        }
        res = true;
    }

    function _claimFomoReward(address account, uint256 amount, address to) internal {
        require(address(0) != account, "ZERO address forbidden");
        require(account != ssAuth.getOwner(), "owner can not claim fomo rewards");
        require(
            MUTFarmAppData(moduleMgr.getModuleAppData()).fomoRewardClaimedDataExists(account),
            "fomo rewards unavailable for you"
        );
        (bool resClaimable, uint256 claimableAmount) = MUTFarmAppData(moduleMgr.getModuleAppData()).fomoRewardClaimable(account);
        require(resClaimable, "not claimable");
        require(claimableAmount >= amount, "insufficient amount to claim");
        require(
            ERC20(ssAuth.getPayment()).balanceOf(address(this)) >= claimableAmount,
            "Insufficient balance in this contract for reward claiming"
        );
        (bool transfered) = ERC20(ssAuth.getPayment()).transfer(to, claimableAmount);
        require(transfered, "error while _claimFomoReward token from AppWallet");

        MUTFarmAppData(moduleMgr.getModuleAppData()).increaseFomoRewardClaimedAmount(account, claimableAmount);
    }

    function collectLostSeed(uint32 roundNumber, address to) external onlyOwner returns (bool res) {
        (bool resAmount, uint256 amount) = MUTFarmAppData(moduleMgr.getModuleAppData()).checkLostSeed(roundNumber);
        require(resAmount && amount > 0, "no lost seed");
        require(ERC20(ssAuth.getPayment()).balanceOf(address(this)) >= amount, "insufficient balance");
        (bool transfered) = ERC20(ssAuth.getPayment()).transfer(to, amount);
        require(transfered, "error while _claimFomoReward token from AppWallet");
        res = true;
    }
}