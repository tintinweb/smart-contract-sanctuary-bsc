// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract SUB {
    uint CarouselIndex;
    Carousel[10] public CarouselList;
    mapping(address => uint) JoinLogIndex;
    mapping(address => JoinLog[]) JoinLogList;
    mapping(uint => uint) WinLogIndex;
    mapping(uint => WinLog[10]) WinLogList;
    struct Carousel {
        address user;
        uint amount;
        uint gameType;
        uint gameId;
    }
    struct WinLog {
        address user;
        uint number;
        uint gameId;
    }
    struct JoinLog {
        address user;
        uint begAmount;
        uint winAmount;
        uint gameType;
        uint gameId;
        uint participants;
        uint roomAmount;
        uint betNumber;
    }

    function getJoinLogData(address user, uint offset, uint limit) public view returns (JoinLog[] memory) {
        JoinLog[] memory logs = new JoinLog[](limit);
        for (uint256 i; i < limit;i++ ) {
            logs[i] = JoinLogList[user][offset+i];
        }
        return logs;
    }

    function getWinLogData(uint t) public view returns (WinLog[10] memory) {
        return WinLogList[t];
    }

    function getCarouselData() public view returns (Carousel[10] memory) {
        return CarouselList;
    }

    function addCarousel(address user, uint amount, uint gameType, uint gameId) external {
        CarouselList[CarouselIndex] = Carousel(user, amount, gameType, gameId);
        CarouselIndex += 1;
        if (CarouselIndex == 10) {
            CarouselIndex = 0;
        }
    }

    function addJoinLogList(JoinLog memory joinLog) external {
        address user = joinLog.user;
        JoinLogList[user].push(joinLog);
        JoinLogIndex[user] +=1;
    }

    function addWinLogList(uint gameType, address user, uint number, uint gameId) external {
        WinLogList[gameType][WinLogIndex[gameType]] = WinLog(user, number, gameId);
        WinLogIndex[gameType] += 1;
        if (WinLogIndex[gameType] == 10) {
            WinLogIndex[gameType] = 0;
        }
    }
}