// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./SafeMath.sol";
import "./ERC20.sol";
import "./Ownable.sol";
import "./Lockable.sol";
import "./Auditable.sol";
import "./AppWallet.sol";
import "./Settings.sol";
import "./AppData.sol";

contract FIFAApp is Ownable, SafeMath, Lockable, Auditable {

    uint32 private currentRoundIndex;

    AppWallet appWallet;
    Settings settings;
    AppData appData;

    event gameCreated(address creator, uint32 roundIndex, uint time);
    event ticketBought(address buyer, uint32 roundIndex, uint32 optionIndex, uint256 amount, uint time);
    event gameAnswered(uint32 roundIndex, uint32 optionIndex, uint time);

    constructor() {
    }

    function setWallet(address to) external onlyOwner {
        appWallet = AppWallet(to);
    }

    function getWallet() external view returns (address res) {
        res = address(appWallet);
    }

    function setSettings(address to) external onlyOwner {
        settings = Settings(to);
    }

    function getSettings() external view returns (address res) {
        res = address(settings);
    }

    function setAppData(address to) external onlyOwner {
        appData = AppData(to);
    }

    function getAppData() external view returns (address res) {
        res = address(appData);
    }

    function createGame
    (
        string memory name, 
        string memory cover, 
        uint gameBeginTime,
        uint gameEndTime,
        address payment, 
        string[] memory optionNames, 
        string[] memory optionValues,
        uint256 securityDepositAmount
    ) external lock {
        require(optionNames.length == optionNames.length && optionNames.length > 2, "option setting error");
        require(optionNames.length <= 32, "too many options");
        require(securityDepositAmount >= settings.getSecurityDeposit(), "too small security Deposit Amount");
        require(ERC20(payment).balanceOf(msg.sender) >= securityDepositAmount, "bond error");
        require(ERC20(payment).allowance(msg.sender, address(this)) >= securityDepositAmount, "not approved");
        require(ERC20(payment).transferFrom(msg.sender, address(appWallet), securityDepositAmount), "create error");
 
        appData.increaseCurrentRoundIndex(1);
        
        appData.createGame(msg.sender, name, cover, gameBeginTime, gameEndTime, payment, optionNames, optionValues, securityDepositAmount);

        emit gameCreated(msg.sender, currentRoundIndex, block.timestamp);
    }

    function buyTicket(uint32 roundIndex, uint8 optionIndex, uint256 amount) external lock {
        require(appData.gameExists(roundIndex), "game not exists");
        require(appData.optionExists(roundIndex, optionIndex), "option not exists");
        if(0 == appData.roundState(roundIndex)) revert("game not audited");
        if(2 == appData.roundState(roundIndex)) revert("game in playing, can't buy ticket");
        if(3 == appData.roundState(roundIndex)) revert("game over, don't buy ticket");
        if(4 == appData.roundState(roundIndex)) revert("game audit rejected");
        // GameData memory gd = mapGame[roundIndex];
        uint256 minBuyAmount = settings.getMinBuy() * 10 ** ERC20(appData.roundPayment(roundIndex)).decimals();
        require(amount >= minBuyAmount, "too small amount to buy ticket");
        require(ERC20(appData.roundPayment(roundIndex)).balanceOf(msg.sender) >= amount, "insufficient balance");
        require(ERC20(appData.roundPayment(roundIndex)).allowance(msg.sender, address(this)) >= amount, "not approved");
        require(ERC20(appData.roundPayment(roundIndex)).transferFrom(msg.sender, address(appWallet), amount), "buy error");
        appData.increaseOptionInAmount(roundIndex, optionIndex, amount);
        if(appData.userTicketExists(roundIndex, msg.sender)) {
            appData.increaseUserTicketAmount(roundIndex, msg.sender, amount);
        } else {
            appData.createUserTicket(roundIndex, optionIndex, msg.sender, amount);
            appData.increaseOptionInCount(roundIndex, optionIndex, 1);
        }
        appData.recordTicket(roundIndex, msg.sender);
        emit ticketBought(msg.sender, roundIndex, optionIndex, amount, block.timestamp);
    }

    //owner answer
    function answerGame(uint32 roundIndex, uint8 optionIndex) external lock onlyOwner {
        require(appData.gameExists(roundIndex), "game not exists");
        require(2 == appData.roundState(roundIndex), "state error");
        require(appData.optionExists(roundIndex, optionIndex), "option not exists");
        appData.setGameState(roundIndex, 3);

        address creator = appData.roundCreator(roundIndex);
        //send reward to creator
        (bool resCRA, uint256 creatorRewardAmount, ) = _getCreatorAndPlatformRewardAmount(roundIndex, creator);
        if(resCRA) {
            require(ERC20(appData.roundPayment(roundIndex)).balanceOf(address(appWallet)) >= creatorRewardAmount, "insufficient");
            require(appWallet.transferToken(appData.roundPayment(roundIndex), creator, creatorRewardAmount), "answer Game error");
        }

        //send(refund) security deposit to creator
        uint256 securityDepositAmount = appData.roundSecurityDepositAmount(roundIndex);
        uint256 refundSecurityDepositAmount = securityDepositAmount * settings.getRefundCreatorPercent() / 100;
        require(ERC20(appData.roundPayment(roundIndex)).balanceOf(address(appWallet)) >= refundSecurityDepositAmount, "insufficient");
        require(appWallet.transferToken(appData.roundPayment(roundIndex), creator, refundSecurityDepositAmount), "answer Game error");

        appData.setCreatorRewardState(roundIndex, creator, true);
        emit gameAnswered(roundIndex, optionIndex, block.timestamp);
    }

    function checkWin(address account, uint32 roundIndex) external view returns (bool res, uint256 rewardAmount) {
        (res, rewardAmount) = _checkWin(account, roundIndex);
    }

    function userTicketClaimed(address account, uint32 roundIndex) external view returns (bool res) {
        res = appData.userTicketClaimed(roundIndex, account);
    }

    function claimReward(uint32 roundIndex) external lock {
        require(appData.gameExists(roundIndex), "game not exists");
        require(3 == appData.roundState(roundIndex), "game not answered");
        require(appData.userTicketExists(roundIndex, msg.sender), "have no ticket");
        require(!appData.userTicketClaimed(roundIndex, msg.sender), "claimed already");
        (bool win, uint256 rewardAmount) = _checkWin(msg.sender, roundIndex);
        require(win, "you lost");
        require(ERC20(appData.roundPayment(roundIndex)).balanceOf(address(appWallet)) >= rewardAmount, "insufficient");
        require(appWallet.transferToken(appData.roundPayment(roundIndex), msg.sender, rewardAmount), "claim error");
        appData.setUserRewardClaimState(roundIndex, msg.sender, true);
    }

    function _checkWin(address account, uint32 roundIndex) internal view returns (bool res, uint256 rewardAmount) {
        if(appData.gameExists(roundIndex) && 3 == appData.roundState(roundIndex) && appData.userTicketExists(roundIndex, account)) {
            if(appData.userWin(roundIndex, account)) {
                (uint256 winAmount, uint256 lostAmount) = appData.getWinLostAmount(roundIndex);
                res = true;
                rewardAmount = (lostAmount 
                - (lostAmount * settings.getCreatorPercent() / 100)
                - (lostAmount * settings.getPlatformPercent() / 100)) 
                * appData.userTicketAmount(roundIndex, account) / winAmount; 
            }
        }
    }

    function _getCreatorAndPlatformRewardAmount
    (
        uint32 roundIndex, 
        address creator
    ) internal view returns 
    (
        bool res, 
        uint256 creatorRewardAmount, 
        uint256 platformProfitAmount
    ) {
        if(appData.gameIsAnswered(roundIndex)) {
            if(!appData.creatorRewardState(roundIndex, creator)) {
                ( , uint256 lostAmount) = appData.getWinLostAmount(roundIndex);
                res = true;
                creatorRewardAmount = lostAmount * settings.getCreatorPercent() / 100;
                platformProfitAmount = lostAmount * settings.getPlatformPercent() / 100;
            }
        }
    }
}