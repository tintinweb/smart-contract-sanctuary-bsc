// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Callerable.sol";

contract AppData is Callerable {

    struct GameData {
        uint32 roundIndex;
        address creator;
        uint256 securityDepositAmount;
        string name;
        string cover;
        address payment;
        uint8 optionCount;
        uint8 optionAnswerIndex;//option answer index, 0 - not answered yet, > 0 answered
        uint8 state; //0-wait for audit，1-audit passed，buying ticket，2-game started，stop buying ticket，3-game end, make result, 4-game audit rejected
        uint gameBeginTime;//game start time
        uint gameEndTime;//game end time
        bool exists;
    }

    struct OptionData {
        string optionName;
        string optionValue;
        uint256 inAmount;
        uint256 inCount;
        bool exists;
    }

    struct TicketData {
        uint8 optionIndex;
        uint256 amount;
        bool claimed;
        bool exists;
    }

    mapping(uint32 => GameData) private mapGame;
    mapping(address => uint32) private mapCreatorGame;
    mapping(address => mapping(uint32 => bool)) private mapCreatorReward;
    mapping(address => mapping(uint32 => TicketData)) mapUserTicket;

    //key: roundIndex => (indexOfNumber => userAddress)
    mapping(uint32 => mapping(uint256 => address)) mapRoundHistory;

    //options of Game
    //key: roundIndex => (optionIndex => (optionName => optionValue))
    mapping(uint32 => mapping(uint8 => OptionData)) private mapOption;

    uint32 private currentRoundIndex;

    function increaseCurrentRoundIndex(uint32 num) external onlyCaller {
        currentRoundIndex = currentRoundIndex + num;
    } 

    function getCurrentRoundIndex() external view returns (uint32 res) {
        res = currentRoundIndex;
    }

    function createGame(
        address creator, 
        string memory name, 
        string memory cover, 
        uint gameBeginTime,
        uint gameEndTime,
        address payment, 
        string[] memory optionNames, 
        string[] memory optionValues,
        uint256 securityDepositAmount
    ) external onlyCaller {
         mapGame[currentRoundIndex] = GameData(
            currentRoundIndex,
            creator,
            securityDepositAmount,
            name,
            cover,
            payment,
            uint8(optionNames.length),
            0,
            1,
            gameBeginTime,
            gameEndTime,
            true
        );
        for(uint8 i = 0; i < optionNames.length; ++i) {
            mapOption[currentRoundIndex][i] = OptionData(
                optionNames[i], 
                optionValues[i],
                0,
                0,
                true
            );
        }
        mapCreatorGame[creator] = currentRoundIndex;
    }

    function setGameState(uint32 roundIndex, uint8 st) external onlyCaller {
        require(mapGame[roundIndex].exists && 0 == mapGame[roundIndex].state, "state error");
        GameData storage gd = mapGame[roundIndex];
        gd.state = st;
    }

    function gameExists(uint32 roundIndex) external view returns (bool res) {
        res = mapGame[roundIndex].exists;
    }

    function optionExists(uint32 roundIndex, uint8 optionIndex) external view returns (bool res) {
       res = mapOption[roundIndex][optionIndex].exists;
    }

    function roundState(uint32 roundIndex) external view returns (uint8 res) {
        res = mapGame[roundIndex].state;
    }

    function roundPayment(uint32 roundIndex) external view returns (address res) {
        res = mapGame[roundIndex].payment;
    }

    function roundCreator(uint32 roundIndex) external view returns (address res) {
        res = mapGame[roundIndex].creator;
    }

    function roundSecurityDepositAmount(uint32 roundIndex) external view returns (uint256 res) {
        res =  mapGame[roundIndex].securityDepositAmount;
    }

    function increaseOptionInAmount(uint32 roundIndex, uint8 optionIndex, uint256 amount) external onlyCaller {
        OptionData storage od = mapOption[roundIndex][optionIndex];
        od.inAmount = od.inAmount + amount;
    }

    function increaseOptionInCount(uint32 roundIndex, uint8 optionIndex, uint256 count) external onlyCaller {
        OptionData storage od = mapOption[roundIndex][optionIndex];
        od.inCount = od.inCount + count;
    }

    function userTicketExists(uint32 roundIndex, address account) external view returns (bool res) {
        res = mapUserTicket[account][roundIndex].exists;
    }

    function userTicketClaimed(uint32 roundIndex, address account) external view returns (bool res) {
        res = mapUserTicket[account][roundIndex].claimed;
    }

    function userTicketAmount(uint32 roundIndex, address account) external view returns (uint256 res) {
        res =  mapUserTicket[account][roundIndex].amount;
    }

    function userWin(uint32 roundIndex, address account) external view returns (bool res) {
        TicketData memory utd = mapUserTicket[account][roundIndex];
        res = mapGame[roundIndex].optionAnswerIndex == utd.optionIndex;
    }

    function setUserRewardClaimState(uint32 roundIndex, address account, bool state) external onlyCaller {
        TicketData storage utd = mapUserTicket[account][roundIndex];
        utd.claimed = state;
    }

    function increaseUserTicketAmount(uint32 roundIndex, address account, uint256 amount) external onlyCaller {
        TicketData storage utd = mapUserTicket[account][roundIndex];
        require(utd.exists, "user ticket not exists");
        utd.amount = utd.amount + amount;
    }

    function createUserTicket(uint32 roundIndex, uint8 optionIndex, address account, uint256 amount) external onlyCaller {
        TicketData storage utd = mapUserTicket[account][roundIndex];
        require(!utd.exists, "user ticket exists");
        mapUserTicket[account][roundIndex] = TicketData(optionIndex, amount, false, true);
    }

    function setCreatorRewardState(uint32 roundIndex, address account, bool state) external onlyCaller {
        mapCreatorReward[account][roundIndex] = state;
    }

    function creatorRewardState(uint32 roundIndex, address account) external view returns (bool res) {
        res = mapCreatorReward[account][roundIndex];
    }

    function gameIsAnswered(uint32 roundIndex) external view returns (bool res) {
        res = _gameIsAnswered(roundIndex);
    }

    function _gameIsAnswered(uint32 roundIndex) internal view returns (bool res) {
        if(mapGame[roundIndex].exists && 3 == mapGame[roundIndex].state) {
            res = true;
        }
    }

    function getWinLostAmount(uint32 roundIndex) external view returns (uint256 winAmount, uint256 lostAmount) {
        (winAmount, lostAmount) = _getWinLostAmount(roundIndex);
    }

    function _getWinLostAmount(uint32 roundIndex) internal view returns (uint256 winAmount, uint256 lostAmount) {
        GameData memory gd = mapGame[roundIndex];
        for(uint8 i = 0; i < gd.optionCount; ++i) {
            if(gd.optionAnswerIndex != i) {
                lostAmount = lostAmount + mapOption[roundIndex][i].inAmount;
            } else {
                winAmount = winAmount + mapOption[roundIndex][i].inAmount;
            }
        }
    }

    function getGameInfo(uint32 roundIndex) external view returns 
    (
        address creator,
        uint256 securityDepositAmount,
        string memory name,
        string memory cover,
        address payment,
        uint8 optionCount,
        uint8 optionAnswerIndex,
        uint8 state,
        uint gameBeginTime,
        uint gameEndTime
    ) {
        if(mapGame[roundIndex].exists) {
            creator = mapGame[roundIndex].creator;
            securityDepositAmount = mapGame[roundIndex].securityDepositAmount;
            name = mapGame[roundIndex].name;
            cover = mapGame[roundIndex].cover;
            payment = mapGame[roundIndex].payment;
            optionCount = mapGame[roundIndex].optionCount;
            optionAnswerIndex = mapGame[roundIndex].optionAnswerIndex;
            state = mapGame[roundIndex].state;
            gameBeginTime = mapGame[roundIndex].gameBeginTime;
            gameEndTime = mapGame[roundIndex].gameEndTime;
        }
    }

    function getOptionList
    (
        uint32 roundIndex
    ) external 
        view 
        returns 
    (
        bool res, 
        string[] memory optionNames, 
        string[] memory optionsValues,
        uint256[] memory inAmounts
    ) {
        if(mapGame[roundIndex].exists) {
            res = mapGame[roundIndex].optionCount > 0;
            for(uint8 i = 0; i < mapGame[roundIndex].optionCount; ++i) {
                optionNames[i] = mapOption[roundIndex][i].optionName;
                optionsValues[i] =  mapOption[roundIndex][i].optionValue;
                inAmounts[i] = mapOption[roundIndex][i].inAmount;
            }
        }
    }

    function getOptionAmount(uint32 roundIndex, uint8 optionIndex) external view returns (uint256 res) {
        res = mapOption[roundIndex][optionIndex].inAmount;
    }

    function getNumberOfUser(uint32 roundIndex) external view returns (uint256 res) {
        res = _getNumberOfUser(roundIndex);
    }

    function _getNumberOfUser(uint32 roundIndex) internal view returns (uint256 res) {
        if(mapGame[roundIndex].exists) {
            uint256 count = mapGame[roundIndex].optionCount;
            for(uint8 i = 0; i < count; ++i) {
                res += mapOption[roundIndex][i].inCount;
            }
        }
    }

    function recordTicket(uint32 roundIndex, address account) external onlyCaller {
        uint256 number = _getNumberOfUser(roundIndex);
        mapRoundHistory[roundIndex][++number] = account;
    }

    function getTicketOfRound(uint32 roundIndex, uint256 ticketIndex) external view returns 
    (
        bool res,
        address account,
        uint256 amount,
        uint8 optionIndex
    ) {
        if(address(0) != mapRoundHistory[roundIndex][ticketIndex]) {
            res = true;
            account = mapRoundHistory[roundIndex][ticketIndex];
            amount = mapUserTicket[account][roundIndex].amount;
            optionIndex = mapUserTicket[account][roundIndex].optionIndex;
        } 
    }
}