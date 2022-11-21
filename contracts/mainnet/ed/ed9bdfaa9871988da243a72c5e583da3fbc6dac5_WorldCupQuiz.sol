pragma solidity ^0.8.0;
// SPDX-License-Identifier: GPL-3.0

import "./WorldCupQuizMode.sol";

contract WorldCupQuiz is WorldCupQuizMode {

    using SafeMath for uint256;
    using SafeERC20 for ERC20;

    constructor(){}

    function betU(uint256 _number, uint256 _goalA, uint256 _goalB, uint256 _amount, uint256 _betType) public nonReentrant {
        require(address(usdtContract) != address(0), "1");
        _amount = _amount * 10 ** 18;
        require(_amount >= lowerLimitU && _amount <= upperLimitU, "  2");
        usdtContract.transferFrom(msg.sender, address(this), _amount);
        _bet(_number, _goalA, _goalB, _amount, _betType, uint256(1));
    }


    function _bet(uint256 _number, uint256 _goalA, uint256 _goalB, uint256 _uAmount, uint256 _betType, uint256 a) private {
        require(tx.origin == _msgSender(), " ");
        ScreeningsInfo storage scc = screeningsInfos[_number];
        ScreeningsInfo2 storage sc2 = screeningsInfos2[_number];
        require(block.timestamp < scc.stopBetting.sub(600), "13");

        if (sc2.isNumber) {
            require(sc2.totalNumber < 100, "100");
        }

        BetInfo storage betInfoScreenings = screeningsBetInfosW[_number];
        BetInfo storage betInfoUser = userBetInfosW[msg.sender][_number];

        if (_betType == 1) {
            require(sc2.isResult, "14");
            betInfoScreenings.resultAmounts += _uAmount;
            betInfoScreenings.resultAmount[_goalA] += _uAmount;
            betInfoUser.resultAmount[_goalA] += _uAmount;
        } else if (_betType == 2) {
            require(sc2.isTotalGoal, "15");
            betInfoScreenings.totalGoalAmounts += _uAmount;
            betInfoScreenings.totalGoalAmount[_goalA] += _uAmount;
            betInfoUser.totalGoalAmount[_goalA] += _uAmount;
        } else if (_betType == 3) {
            require(sc2.isGoals, "16");
            betInfoScreenings.goalsAmounts += _uAmount;
            betInfoScreenings.goalsAmount[_goalA][_goalB] += _uAmount;
            betInfoUser.goalsAmount[_goalA][_goalB] += _uAmount;
        } else {
            require(false, "17");
        }
        sc2.totalAmount += _uAmount;

        if (!isPledge[_number][msg.sender]) {
            sc2.totalNumber += 1;
        }
        isPledge[_number][msg.sender] = true;

        rebate(_number, _uAmount, _betType);

        emit Bet(msg.sender, _number, _uAmount, uint256(0), _goalA, _goalB, _betType, a, block.timestamp);

    }

    function rebate(uint256 _number, uint256 _amount, uint256 _betType) private {
        BetInfo storage betInfoScreenings = screeningsBetInfosW[_number];
        (address inviter,) = invitation.getInvitation(msg.sender);
        uint256 number2 = 2;
        ScreeningsInfo2 storage scc2 = screeningsInfos2[_number];
        for (uint256 i = 0; i < 2; i++) {
            if (inviter != address(0)) {
                if (number2 > 0) {
                    uint256 rebateAmount = _amount.mul(number2).div(100);
                    uint256 amount = rebateAmount;
                    usdtContract.transfer(inviter, amount);
                    scc2.withdrawAmount += rebateAmount;
                    number2 -= 1;
                    if (_betType == 1) {
                        betInfoScreenings.resultWithdrawAmount += rebateAmount;
                    } else if (_betType == 2) {
                        betInfoScreenings.totalGoalWithdrawAmount += rebateAmount;
                    } else if (_betType == 3) {
                        betInfoScreenings.goalsWithdrawAmount += rebateAmount;
                    }
                    emit Rebate(msg.sender, inviter, _number, amount, block.timestamp);
                }

                (inviter,) = invitation.getInvitation(inviter);

            } else {
                i = 1000;
            }
        }

    }


    function withdraw(uint256 _number, uint256 _goalA, uint256 _goalB, uint256 _betType) public nonReentrant {
        require(tx.origin == _msgSender(), "  ");
        ScreeningsInfo storage screeningsInfo = screeningsInfos[_number];
        ScreeningsInfo2 storage screeningsInfo2 = screeningsInfos2[_number];
        require(screeningsInfo.stopWithdraw.add(stopDay.mul(86400)) > block.timestamp, "9");
        UserBetTokenIdInfo storage userInfo = userBetTokenIdInfos[msg.sender][_number];
        BetInfo storage userBet = userBetInfosW[msg.sender][_number];
        BetInfo storage screeningsBet = screeningsBetInfosW[_number];
        uint256 withdrawAmount = earningsOf(msg.sender, _number, _goalA, _goalB, _betType);
        if (withdrawAmount > 0) {

            usdtContract.transfer(msg.sender, withdrawAmount);
            screeningsInfo2.withdrawAmount += withdrawAmount;

            emit Withdraw(msg.sender, _number, _betType, _goalA, _goalB, withdrawAmount, block.timestamp);

        } else {
            if (isWithdrawContract) {
                uint256 agree;
                if (_betType == 1) {
                    agree = userBet.resultAmount[_goalA];

                } else if (_betType == 2) {
                    agree = userBet.totalGoalAmount[_goalA];

                } else if (_betType == 3) {
                    agree = userBet.goalsAmount[_goalA][_goalB];
                }
                if (agree >= wAmount) {
                    uint256 tokenId = worldCup.generateNFT(msg.sender);
                    require(tokenId > 0, "11");
                    emit WorldCupNFT(msg.sender, _number, _betType, _goalA, _goalB, tokenId, block.timestamp);
                }

            }

        }

        if (_betType == 1) {
            require(!userInfo.isWithdrawResult[_goalA], "8");
            userInfo.isWithdrawResult[_goalA] = true;
            userBet.resultAmount[_goalA] = 0;
            screeningsBet.resultWithdrawAmount += withdrawAmount;
        } else if (_betType == 2) {
            require(!userInfo.isWithdrawTotalGoal[_goalA], "8");
            userInfo.isWithdrawTotalGoal[_goalA] = true;
            userBet.totalGoalAmount[_goalA] = 0;
            screeningsBet.totalGoalWithdrawAmount += withdrawAmount;
        } else if (_betType == 3) {
            require(!userInfo.isWithdrawGals[_goalA][_goalB], "8");
            userInfo.isWithdrawGals[_goalA][_goalB] = true;
            userBet.goalsAmount[_goalA][_goalB] = 0;
            screeningsBet.goalsWithdrawAmount += withdrawAmount;
        }

    }


    function setPlayerGoals(uint256 number, uint256 _name, uint256 _goal) public onlyOwner {
        playerGoals[number][_name] = _goal;
        if (playerIdNumber[number][_name] <= 0) {
            playerId[number].push(_name);
            playerIdGoals[number].push(_goal);
            playerIdNumber[number][_name] = playerId[number].length;
        } else {
            uint256 i = playerIdNumber[number][_name] - 1;
            playerIdGoals[number][i] = _goal;
        }

        emit SetPlayerGoals(number, _name, _goal, block.timestamp);
    }

    function setTotalGoals(uint256 number, uint256 _totalGoals) public onlyOwner {
        ScreeningsInfo2 storage scc2 = screeningsInfos2[number];
        scc2.totalGoals = _totalGoals;
        emit SetTotalGoals(number, _totalGoals, block.timestamp);
    }

    function setScreeningsInfoTeam(uint256 _number, uint64 teamA, uint64 teamB) public onlyOwner {
        ScreeningsInfo storage screeningsInfo = screeningsInfos[_number];
        screeningsInfo.teamA = teamA;
        screeningsInfo.teamB = teamB;
        emit SetScreeningsInfoTeam(_number, uint256(teamA), uint256(teamB), block.timestamp);
    }


    function setScreeningsInfoGoals(uint256 _number, uint64 goalsA, uint64 goalsB) public onlyOwner {
        ScreeningsInfo storage screeningsInfo = screeningsInfos[_number];
        screeningsInfo.goalsA = goalsA;
        screeningsInfo.goalsB = goalsB;
        emit SetScreeningsInfoGoals(_number, goalsA, goalsB, block.timestamp);
    }


    function setSwitch(uint256 _number, bool _isTotalGoal, bool _isResult, bool _isGoals, bool _isNumber) public onlyOwner {
        ScreeningsInfo2 storage screeningsInfo = screeningsInfos2[_number];
        screeningsInfo.isTotalGoal = _isTotalGoal;
        screeningsInfo.isResult = _isResult;
        screeningsInfo.isGoals = _isGoals;
        screeningsInfo.isNumber = _isNumber;
    }


    function setPond(uint256 _number, uint256 _openNumber, uint256 _amounts) public onlyOwner {
        ScreeningsInfo2 storage screeningsInfo = screeningsInfos2[_number];
        screeningsInfo.openNumber = _openNumber;
        screeningsInfo.amounts = _amounts;
    }

    function setScreeningsInfoStopBetting(uint256 _number, uint128 stopBetting) public onlyOwner {
        ScreeningsInfo storage screeningsInfo = screeningsInfos[_number];
        screeningsInfo.stopBetting = stopBetting;
        emit SetScreeningsInfoStopBetting(_number, stopBetting, block.timestamp);
    }

    function setScreeningsInfoIsDistribute(uint256 _number, bool _isDistribute) public onlyOwner {
        ScreeningsInfo storage screeningsInfo = screeningsInfos[_number];
        screeningsInfo.isDistribute = _isDistribute;
        if (_isDistribute) {
            screeningsInfo.stopWithdraw = block.timestamp;
        } else {
            screeningsInfo.stopWithdraw = 0;
        }

        emit SetScreeningsInfoIsDistribute(_number, _isDistribute, block.timestamp);
    }

    function setDestroy(uint256 _number, address _addr) public onlyOwner {
        uint256 amount;
        if (!isDestroy[_number]) {
            ScreeningsInfo2 storage screeningsInfo2 = screeningsInfos2[_number];
            amount = screeningsInfo2.totalAmount.div(10);
            usdtContract.transfer(_addr, amount);
            isDestroy[_number] = true;
            emit SetDestroy(_addr,_number, amount, block.timestamp);
        }

    }


    function setContestType(uint256 _number, uint256 _contestType) public onlyOwner {
        ScreeningsInfo storage screeningsInfo = screeningsInfos[_number];
        screeningsInfo.contestType = _contestType;
        emit SetContestType(_number, _contestType, block.timestamp);
    }

    function setGrouping(uint256 _number, string memory _grouping) public onlyOwner {
        ScreeningsInfo storage screeningsInfo = screeningsInfos[_number];
        screeningsInfo.grouping = _grouping;
        emit SetGrouping(_number, _grouping, block.timestamp);
    }

    function setSpecialAmount(uint256 _type, uint256 _specialAmount) public onlyOwner {
        specialAmount[_type] = _specialAmount * 10 ** 18;
    }

    function setStopDay(uint256 _stopDay) public onlyOwner {
        stopDay = _stopDay;
    }

    function setWAmount(uint256 _wAmount) public onlyOwner {
        wAmount = _wAmount * 10 ** 18;
    }

    function setAllocationRatio(uint256 _allocationRatio) public onlyOwner {
        allocationRatio = _allocationRatio;
    }

    function setLimitUs(uint256 _lowerLimitU, uint256 _upperLimitU) public onlyOwner {
        lowerLimitU = _lowerLimitU * 10 ** 18;
        upperLimitU = _upperLimitU * 10 ** 18;
    }

    function setIsWithdrawContract(bool _isWithdrawContract) public onlyOwner {
        isWithdrawContract = _isWithdrawContract;
    }


    function extractToken(address _token, address _to, uint256 _amount) public onlyOwner {
        ERC20(_token).transfer(_to, _amount);
    }

    function setContract(address _invitationContract, address _worldCup, address _usdtContract) public onlyOwner {
        invitation = Invitation(_invitationContract);
        worldCup = WorldCup(_worldCup);
        usdtContract = ERC20(_usdtContract);
    }


}