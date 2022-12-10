pragma solidity ^0.8.0;
// SPDX-License-Identifier: GPL-3.0

import "./MatchMode.sol";

contract Match is MatchMode {

    using SafeMath for uint256;
    using SafeERC20 for ERC20;

    constructor(){}

    function splitPositionThroughAllConditions(uint number, uint amount)
    private
    {
        uint[] memory partition = generateBasicPartition(positionIds[number].length);
        conditionalTokens.splitPosition(collateralToken, bytes32(0), conditionIds[number], partition, amount);
    }

    function mergePositionsThroughAllConditions(uint number, uint amount)
    private
    {
        uint[] memory partition = generateBasicPartition(positionIds[number].length);
        conditionalTokens.mergePositions(collateralToken, bytes32(0), conditionIds[number], partition, amount);
    }

    function withdrawFees(uint number, address account) public {
        uint rawAmount = feePoolWeight[number].mul(balanceOf(account, number)) / totalSupplyOf(number);
        uint withdrawableAmount = rawAmount.sub(withdrawnFees[account][number]);
        if (withdrawableAmount > 0) {
            withdrawnFees[account][number] = rawAmount;
            totalWithdrawnFees[number] = totalWithdrawnFees[number].add(withdrawableAmount);
            require(collateralToken.transfer(account, withdrawableAmount), "withdrawal transfer failed");
        }
    }

    function _beforeTokenTransfer(address operator, address from, address to, uint256 id, uint256 amount, bytes memory data) override internal {
        if (from != address(0)) {
            withdrawFees(id, from);
        }

        uint totalSupply = totalSupplyOf(id);
        uint withdrawnFeesTransfer = totalSupply == 0 ?
        amount :
        feePoolWeight[id].mul(amount) / totalSupply;

        if (from != address(0)) {
            withdrawnFees[from][id] = withdrawnFees[from][id].sub(withdrawnFeesTransfer);
            totalWithdrawnFees[id] = totalWithdrawnFees[id].sub(withdrawnFeesTransfer);
        } else {
            feePoolWeight[id] = feePoolWeight[id].add(withdrawnFeesTransfer);
        }
        if (to != address(0)) {
            withdrawnFees[to][id] = withdrawnFees[to][id].add(withdrawnFeesTransfer);
            totalWithdrawnFees[id] = totalWithdrawnFees[id].add(withdrawnFeesTransfer);
        } else {
            feePoolWeight[id] = feePoolWeight[id].sub(withdrawnFeesTransfer);
        }
    }

    function addFunding(uint number, uint addedFunds, uint[] calldata distributionHint)
    external
    {
        require(addedFunds > 0, "funding must be non-zero");

        uint[] memory sendBackAmounts = new uint[](positionIds[number].length);
        uint poolShareSupply = totalSupplyOf(number);
        uint mintAmount;
        if (poolShareSupply > 0) {
            require(distributionHint.length == 0, "cannot use distribution hint after initial funding");
            uint[] memory poolBalances = getPoolBalances(number);
            uint poolWeight = 0;
            for (uint i = 0; i < poolBalances.length; i++) {
                uint balance = poolBalances[i];
                if (poolWeight < balance)
                    poolWeight = balance;
            }

            for (uint i = 0; i < poolBalances.length; i++) {
                uint remaining = addedFunds.mul(poolBalances[i]) / poolWeight;
                sendBackAmounts[i] = addedFunds.sub(remaining);
            }

            mintAmount = addedFunds.mul(poolShareSupply) / poolWeight;
        } else {
            if (distributionHint.length > 0) {
                require(distributionHint.length == positionIds[number].length, "hint length off");
                uint maxHint = 0;
                for (uint i = 0; i < distributionHint.length; i++) {
                    uint hint = distributionHint[i];
                    if (maxHint < hint)
                        maxHint = hint;
                }

                for (uint i = 0; i < distributionHint.length; i++) {
                    uint remaining = addedFunds.mul(distributionHint[i]) / maxHint;
                    require(remaining > 0, "must hint a valid distribution");
                    sendBackAmounts[i] = addedFunds.sub(remaining);
                }
            }

            mintAmount = addedFunds;
        }

        require(collateralToken.transferFrom(msg.sender, address(this), addedFunds), "funding transfer failed");
        require(collateralToken.approve(address(conditionalTokens), addedFunds), "approval for splits failed");
        splitPositionThroughAllConditions(number,addedFunds);

        _mint(msg.sender, number, mintAmount,"");

        conditionalTokens.safeBatchTransferFrom(address(this), msg.sender, positionIds[number], sendBackAmounts, "");

        // transform sendBackAmounts to array of amounts added
        for (uint i = 0; i < sendBackAmounts.length; i++) {
            sendBackAmounts[i] = addedFunds.sub(sendBackAmounts[i]);
        }

        // emit FPMMFundingAdded(msg.sender, sendBackAmounts, mintAmount);
    }

    function removeFunding(uint number, uint sharesToBurn)
    external
    {
        uint[] memory poolBalances = getPoolBalances(number);

        uint[] memory sendAmounts = new uint[](poolBalances.length);

        uint poolShareSupply = totalSupplyOf(number);
        for (uint i = 0; i < poolBalances.length; i++) {
            sendAmounts[i] = poolBalances[i].mul(sharesToBurn) / poolShareSupply;
        }

        uint collateralRemovedFromFeePool = collateralToken.balanceOf(address(this));

        _burn(msg.sender, number, sharesToBurn);
        collateralRemovedFromFeePool = collateralRemovedFromFeePool.sub(
            collateralToken.balanceOf(address(this))
        );

        conditionalTokens.safeBatchTransferFrom(address(this), msg.sender, positionIds[number], sendAmounts, "");

        // emit FPMMFundingRemoved(msg.sender, sendAmounts, collateralRemovedFromFeePool, sharesToBurn);
    }


    function buy(uint number, uint investmentAmount, uint outcomeIndex, uint minOutcomeTokensToBuy) external {
        require(conditionalTokens.payoutNumerators(conditionIds[number]).length > 0, "condition not prepared yet");
        uint outcomeTokensToBuy = calcBuyAmount(number, investmentAmount, outcomeIndex);
        require(outcomeTokensToBuy >= minOutcomeTokensToBuy, "minimum buy amount not reached");

        require(collateralToken.transferFrom(msg.sender, address(this), investmentAmount), "cost transfer failed");

        uint feeAmount = investmentAmount.mul(fee) / ONE;
        feePoolWeight[number] = feePoolWeight[number].add(feeAmount);
        uint investmentAmountMinusFees = investmentAmount.sub(feeAmount);
        require(collateralToken.approve(address(conditionalTokens), investmentAmountMinusFees), "approval for splits failed");
        splitPositionThroughAllConditions(number,investmentAmountMinusFees);

        conditionalTokens.safeTransferFrom(address(this), msg.sender, positionIds[number][outcomeIndex], outcomeTokensToBuy, "");

        // emit FPMMBuy(msg.sender, investmentAmount, feeAmount, outcomeIndex, outcomeTokensToBuy);
    }

    function sell(uint number, uint returnAmount, uint outcomeIndex, uint maxOutcomeTokensToSell) external {
        require(conditionalTokens.payoutDenominator(conditionIds[number]) <= 0, "Received the result of the condition");
        uint outcomeTokensToSell = calcSellAmount(number, returnAmount, outcomeIndex);
        require(outcomeTokensToSell <= maxOutcomeTokensToSell, "maximum sell amount exceeded");

        conditionalTokens.safeTransferFrom(msg.sender, address(this), positionIds[number][outcomeIndex], outcomeTokensToSell, "");

        uint feeAmount = returnAmount.mul(fee) / (ONE.sub(fee));
        feePoolWeight[number] = feePoolWeight[number].add(feeAmount);
        uint returnAmountPlusFees = returnAmount.add(feeAmount);
        mergePositionsThroughAllConditions(number,returnAmountPlusFees);

        require(collateralToken.transfer(msg.sender, returnAmount), "return transfer failed");

        // emit FPMMSell(msg.sender, returnAmount, feeAmount, outcomeIndex, outcomeTokensToSell);
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
        conditionIds[_number] = CTHelpers.getConditionId(owner(), bytes32(_number), 2);
        conditionalTokens.prepareCondition(owner(), bytes32(_number), 2);
        for (uint i; i < 2; i++) {
            uint id = getId(collateralToken, conditionIds[_number], i);
            positionIds[_number].push(id);
        }


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
            collateralToken.transfer(_addr, amount);
            isDestroy[_number] = true;
            emit SetDestroy(_addr, _number, amount, block.timestamp);
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


    function extractToken(address _token, address _to, uint256 _amount) public onlyOwner {
        ERC20(_token).transfer(_to, _amount);
    }

    function setContract(address _usdtContract,address _conditionalTokens) public onlyOwner {

        collateralToken = ERC20(_usdtContract);
        conditionalTokens = ConditionalTokens(_conditionalTokens);
    }



}