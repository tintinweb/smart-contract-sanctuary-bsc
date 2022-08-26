// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./SafeMath.sol";
import "./SystemSetting.sol";
import "./Relationship.sol";
import "./ModuleBase.sol";

contract MUTFarmAppData is SafeMath, ModuleBase {

    struct RoundData {
        uint256 inAmount;
        uint256 helpAmount;
        uint256 outAmount;
        uint256 lastTime;
        uint32 firstIndex;
        uint32 currentIndex;
        uint32 lastIndex;
    }

    struct SowNode {
        uint32 roundIndex;
        uint32 queueIndex;
        address account;
        uint256 sowAmount;
        uint256 withSharedProfit;
        uint256 withFomoReward;
        uint256 outAmount;
        uint256 soldAmount;
        uint256 claimedAmount;
        uint256 buyTime;
        uint32 ssIndex;
    }

    uint32 roundIndex;

    uint256 charityAmount;
    uint256 sysFundAmount;

    mapping(uint32 => SowNode) mapSowNode;

    mapping(uint256 => uint256) mapFomoPoolAmount;

    //mapping for fomo rewards transfered from pool to user's account(FomoRewardClaimData)
    //key: account => (roundNumber => yes/no)
    mapping(address => mapping(uint256 => bool)) mapFomoRewardTransfered;

    //container of user's fomo reward claimable
    //key: account => mapping(roundNumber => RewardClaimData)
    struct FomoRewardClaimData {
        uint256 totalAmount;
        uint256 claimedAmount;
        bool exists;
    }
    mapping(address => FomoRewardClaimData) mapFomoRewardClaimed;

    //total amount in queue
    uint256 totalQueueAmount;

    //queue of seed, using a mapping as container, key(queue index)
    //key: queue index = > 
    mapping(uint32 => SowNode) queueSeed;
    uint32 queueFirstIndex;
    uint32 queueLastIndex;

    //mapping for user seed
    //keys： roundIndex=>(account=>pointer to SowNode index))
    mapping(uint256 => mapping(address => uint32)) mapUserSeed;

    mapping(uint256 => RoundData) mapRound;

    event seedSoldEvent(address account, uint256 amount, uint timestamp);

    constructor(address ssAuthAddress, address moduleMgrAddress) ModuleBase(ssAuthAddress, moduleMgrAddress) {
    }

    function enqueue(
        address account,
        uint256 sowAmount,
        uint256 amount,
        uint256 withSharedProfit,
        uint256 withFomoReward
    ) external onlyCaller {
        _enqueue(account, sowAmount, amount, withSharedProfit, withFomoReward);
    }

    function _enqueue(
        address account,
        uint256 sowAmount,
        uint256 amount,
        uint256 withSharedProfit,
        uint256 withFomoReward
    ) internal {

        SowNode memory data = SowNode(
            roundIndex,
            queueLastIndex,
            account,
            sowAmount,
            withSharedProfit,
            withFomoReward,
            amount,
            0,
            0,
            block.timestamp,
            SystemSetting(moduleMgr.getModuleSystemSetting()).getCurrentSettingIndex()
        );
        queueSeed[queueLastIndex] = data;
    }

    function getQueueSize() external view returns (uint32 res) {
        res = queueLastIndex;
    }

    function getQueueFirstIndex() external view returns (uint32 res) {
        res = queueFirstIndex;
    }

    function getQueueLastIndex() external view returns (uint32 res) {
        res = queueLastIndex;
    }

    function getCurrentRoundIndex() external view returns (uint32 res) {
        res = roundIndex;
    }

    function isUserSeedExists(uint32 roundNumber, address account)
        external
        view
        returns (bool res)
    {
        res = mapUserSeed[roundNumber][account] > 0;
    }

    function increaseUserFomoRewardClaimed(address account, uint256 amount)
        external onlyCaller
    {
        FomoRewardClaimData storage frd = mapFomoRewardClaimed[account];
        require(
            frd.totalAmount >= add(frd.claimedAmount, amount),
            "amount overflow to claim"
        );
        frd.claimedAmount = add(frd.claimedAmount, amount);
    }

    function increaseQueueFirstIndex(uint32 num) external onlyCaller {
        queueFirstIndex += num;
    }

    function increaseQueueLastIndex(uint32 num) external onlyCaller {
        queueLastIndex += num;
    }

    function createNewRound(uint256 inAmount) external onlyCaller {
        _createNewRound(inAmount);
    }

    function _createNewRound(uint256 inAmount) internal {
        ++queueLastIndex;
        queueFirstIndex = queueLastIndex;
        ++roundIndex;
        totalQueueAmount = 0;
        mapRound[roundIndex] = RoundData(
            inAmount,
            0,
            0,
            block.timestamp,
            queueFirstIndex,
            queueFirstIndex,
            queueLastIndex
        );
    }

    function _createNewUserSeedData(
        address account,
        uint32 _queueIndex
    ) internal {
        mapUserSeed[roundIndex][account] = _queueIndex;
    }

    function resowSeed(address account, uint32 roundNumber) external onlyCaller returns(bool res, uint256 sowAmount, uint256 withdrawAmount) {
        require(mapUserSeed[roundNumber][account] > 0,
         "have no seeds");
        
        uint32 _queueIndex = mapUserSeed[roundNumber][account];
        SowNode memory sowNode = queueSeed[_queueIndex];

        require(block.timestamp > 
        sowNode.buyTime +
        SystemSetting(moduleMgr.getModuleSystemSetting()).getMatureTime(0), 
        "matured time not reached");

        require(sowNode.soldAmount >= sowNode.outAmount, 
        "no all seeds matured");
        uint256 resowbleAmount = sowNode.soldAmount - sowNode.claimedAmount;
        require(resowbleAmount >= SystemSetting(moduleMgr.getModuleSystemSetting()).getMinAmountBuy(0), 
        "too small amount to resow");
        if(resowbleAmount > SystemSetting(moduleMgr.getModuleSystemSetting()).getMaxAmountBuy(0)) {
            sowAmount = SystemSetting(moduleMgr.getModuleSystemSetting()).getMaxAmountBuy(0);
            withdrawAmount = resowbleAmount - sowAmount;
        } else {
            sowAmount = resowbleAmount;
        }
        delete mapUserSeed[roundNumber][account];

        if(roundIndex > 0 && queueFirstIndex > 0) {
            _transferFomoReward(roundIndex);
        }
        if ( _isRoundStop(roundIndex, SystemSetting(moduleMgr.getModuleSystemSetting()).getResetCountDownTimeLength(0)) || roundIndex == 0 ) {
            _createNewRound(sowAmount);
        } else {
            _updateRoundDataInAmount(sowAmount);
        }

        require(_distributeMony(account, sowAmount, 0, 0), "resow seed error");
        res = true;
    }

    function distributeMony(address account, uint256 amount, uint256 withSharedProfit, uint256 withFomoReward)
        external onlyCaller 
        returns (bool res) 
    {
        res = _distributeMony(account, amount, withSharedProfit, withFomoReward);
    }

    function _distributeMony(address account, uint256 amount, uint256 withSharedProfit, uint256 withFomoReward)
        internal
        returns (bool res)
    {
        //share profit upstream
        uint256 sharedAmount = Relationship(moduleMgr.getModuleRelationship()).sharedProfit(account, amount);
        //deposit charity
        uint256 charity = div(mul(amount, SystemSetting(moduleMgr.getModuleSystemSetting()).getCharityPercent(0)), 1000);
        charityAmount = add(charityAmount, charity);
        //deposit sysFund
        uint256 forSysFund = div(mul(amount,  SystemSetting(moduleMgr.getModuleSystemSetting()).getSysFundPercent(0)), 1000);
        sysFundAmount = add(sysFundAmount, forSysFund);
        //deposit fomoPool
        uint256 forFomoPool = div(mul(amount, SystemSetting(moduleMgr.getModuleSystemSetting()).getFomoPoolPercent(0)), 1000);
        mapFomoPoolAmount[roundIndex] = add(mapFomoPoolAmount[roundIndex], forFomoPool);
        uint256 paddingAmount = sub(amount, add(sharedAmount, add(forSysFund, add(forFomoPool, charity))));
        uint256 helpAmount = paddingAmount;
        while (true) {
            if (paddingAmount == 0) {
                break;
            }

            if(!_isFirstSeedDataExists()) {
                break;
            }
            uint256 firstNodeSeedAmount = _getFirstNodeSeedAmount();
            if(firstNodeSeedAmount == 0) {
                queueFirstIndex += 1;
                continue;
            }
            uint256 userSellAmount = 0;
            if (paddingAmount >= firstNodeSeedAmount) {
                userSellAmount = firstNodeSeedAmount;
            } else {
                userSellAmount = paddingAmount;
            }
            bool sold = _sellUserSeedInBuy(_getFirstNodeSeedAccount(), userSellAmount);
            if (sold) {
                paddingAmount = sub(paddingAmount, userSellAmount);
                _decreaseTotalQueueAmount(userSellAmount);
                _increaseRoundDataOutAmount(userSellAmount);
            } else {
                revert("sold Error revert");
            }
        }
        uint256 newAmount = add(amount, div(mul(amount, SystemSetting(moduleMgr.getModuleSystemSetting()).getCycleYieldsPercent(0)), 1000));
        _enqueue(account, amount, newAmount, withSharedProfit, withFomoReward);
        _createNewUserSeedData(account, queueLastIndex);
        _increaseTotalQueueAmount(newAmount);
        _updateRoundDataHelpAmount(helpAmount);
        res = true;
    }

    function _sellUserSeedInBuy(address account, uint256 amount)
        internal
        returns (bool res)
    {
        _sellUserSeed(account, amount);
        emit seedSoldEvent(account, amount, block.timestamp);
        res = true;
    }

    function updateRoundDataInAmount(uint256 addInAmount) external onlyCaller {
        _updateRoundDataInAmount(addInAmount);
    }

    function _updateRoundDataInAmount(uint256 addInAmount) internal {
        RoundData storage rd = mapRound[roundIndex];
        rd.inAmount = add(rd.inAmount, addInAmount);
        rd.lastTime = block.timestamp;
        rd.lastIndex = ++queueLastIndex;
    }

    function updateRoundDataHelpAmount(uint256 addInAmount) external onlyCaller {
        _updateRoundDataHelpAmount(addInAmount);
    }

    function _updateRoundDataHelpAmount(uint256 addInAmount) internal {
        RoundData storage rd = mapRound[roundIndex];
        rd.helpAmount = add(rd.helpAmount, addInAmount);
    }

    function increaseRoundDataOutAmount(uint256 amount) external onlyCaller {
        _increaseRoundDataOutAmount(amount);
    }

    function _increaseRoundDataOutAmount(uint256 amount) internal {
        RoundData storage rd = mapRound[roundIndex];
        rd.outAmount = add(rd.outAmount, amount);
    }

    function increaseCharityAmount(uint256 amount) external onlyCaller {
        charityAmount = add(charityAmount, amount);
    }

    function increaseSysFundAmount(uint256 amount) external onlyCaller {
        sysFundAmount = add(sysFundAmount, amount);
    }

    function increaseFomoPoolAmount(uint256 amount) external onlyCaller {
        mapFomoPoolAmount[roundIndex] = add(mapFomoPoolAmount[roundIndex], amount);
    }

    function isFirstSeedDataExists() external view returns (bool res) {
        res = _isFirstSeedDataExists();
    }

    function _isFirstSeedDataExists() internal view returns (bool res) {
        SowNode memory firstSeedData = queueSeed[queueFirstIndex];
        if (firstSeedData.queueIndex > 0) {
            address firstNodeSeedAccount = firstSeedData.account;
            if (mapUserSeed[roundIndex][firstNodeSeedAccount] > 0) {
                res = true;
            }
        }
    }

    function getFirstNodeSeedAmount() external view returns (uint256 res) {
        res = _getFirstNodeSeedAmount();
    }

    function _getFirstNodeSeedAmount() internal view returns (uint256 res) {
        SowNode memory firstSeedData = queueSeed[queueFirstIndex];
        res = sub(firstSeedData.outAmount, firstSeedData.soldAmount);
    }

    function getFirstNodeSeedAccount() external view returns (address addr) {
        addr = _getFirstNodeSeedAccount();
    }

    function _getFirstNodeSeedAccount() internal view returns (address addr) {
        SowNode memory firstSeedData = queueSeed[queueFirstIndex];
        addr = firstSeedData.account;
    }

    function increaseTotalQueueAmount(uint256 amount) external onlyCaller {
        _increaseTotalQueueAmount(amount);
    }

    function _increaseTotalQueueAmount(uint256 amount) internal {
        totalQueueAmount = add(totalQueueAmount, amount);
    }

    function decreaseTotalQueueAmount(uint256 amount) external onlyCaller {
        _decreaseTotalQueueAmount(amount);
    }

    function _decreaseTotalQueueAmount(uint256 amount) internal {
        require(
            totalQueueAmount >= amount,
            "amount overflow to decrease total queue amount"
        );
        totalQueueAmount = sub(totalQueueAmount, amount);
    }

    function sellUserSeed(address account, uint256 amount) external onlyCaller {
        _sellUserSeed(account, amount);
    }

    function _sellUserSeed(address account, uint256 amount) internal {
        uint32 userNodeIndex = mapUserSeed[roundIndex][account];
        require(userNodeIndex > 0, "user seed not exists");
        SowNode storage sud = queueSeed[userNodeIndex];
        require(sud.outAmount >= add(sud.soldAmount, amount), "Seed sold out");
        sud.soldAmount = add(sud.soldAmount, amount);
        if (sud.outAmount <= sud.soldAmount) {
            ++queueFirstIndex;
            RoundData storage rd = mapRound[roundIndex];
            rd.currentIndex = queueFirstIndex;
        }
    }

    function getSeedNodeData(uint32 index)
        external
        view
        returns (
            bool res,
            address account,
            uint256 sowAmount,
            uint256 amount,
            uint256 withSharedProfit,
            uint256 withFomoReward,
            uint256 buyTime,
            uint32 ssIndex
        )
    {
        if (index >= 1 && index <= queueLastIndex) {
            account = queueSeed[index].account;
            sowAmount = queueSeed[index].sowAmount;
            amount = queueSeed[index].outAmount;
            withSharedProfit = queueSeed[index].withSharedProfit;
            withFomoReward = queueSeed[index].withFomoReward;
            ssIndex = queueSeed[index].ssIndex;
            buyTime = queueSeed[index].buyTime;
            res = true;
        }
    }

    function getSeedUserData(uint32 roundNumber, address account)
        external
        view
        returns (
            bool res,
            uint256 _roundIndex,
            uint32 _queueIndex,
            uint256 _totalAmount,
            uint256 _soldAmount,
            uint256 _claimedAmount,
            uint256 _buyTime,
            uint32 _ssIndex
        )
    {
        if (mapUserSeed[roundNumber][account] > 0) {
            SowNode memory sowNode = queueSeed[mapUserSeed[roundNumber][account]];
            res = true;
            _roundIndex = sowNode.roundIndex;
            _queueIndex = sowNode.queueIndex;
            _totalAmount = sowNode.outAmount;
            _soldAmount = sowNode.soldAmount;
            _claimedAmount = sowNode.claimedAmount;
            _buyTime = sowNode.buyTime;
            _ssIndex = sowNode.ssIndex;
        }
    }

    function checkCollectable(uint32 roundNumber, address account)
        external
        view
        returns (bool res, uint256 amount)
    {
        (res, amount) = _checkCollectable(roundNumber, account, SystemSetting(moduleMgr.getModuleSystemSetting()).getMatureTime(0));
    }

    function _checkCollectable(
        uint32 roundNumber,
        address account,
        uint256 matureTime
    ) internal view returns (bool res, uint256 amount) {
        if(mapUserSeed[roundNumber][account] > 0) {
            SowNode memory sowNode = queueSeed[mapUserSeed[roundNumber][account]];
            if(sowNode.soldAmount > sowNode.claimedAmount && block.timestamp >= sowNode.buyTime + matureTime) {
                res = true;
                amount = sub(sowNode.soldAmount, sowNode.claimedAmount);
            }
        }
    }

    function increaseUserSeedClaimedAmount(
        uint32 roundNumber,
        address account,
        uint256 amount
    ) external onlyCaller {
        require(
            mapUserSeed[roundNumber][account] > 0,
            "user seed not exists"
        );
        SowNode storage sowNode = queueSeed[mapUserSeed[roundNumber][account]];
        require(
            sowNode.soldAmount >= add(sowNode.claimedAmount, amount),
            "insufficient claimable amount to claim"
        );
        sowNode.claimedAmount = add(sowNode.claimedAmount, amount);
        if (sowNode.claimedAmount >= sowNode.outAmount) {
            delete mapUserSeed[roundNumber][account];
        }
    }

    function isRoundExists(uint32 roundNumber)
        external
        view
        returns (bool res)
    {
        res = mapRound[roundNumber].firstIndex > 0;
    }

    function userForgottenSeedAvailable(address account, uint32 roundNumber) external view returns (bool res, uint256 amount) {
        (res, amount) = _userForgottenSeedAvailable(account, roundNumber, SystemSetting(moduleMgr.getModuleSystemSetting()).getFixedTimeForgotten(0));
    }

    function _userForgottenSeedAvailable(
        address account,
        uint32 roundNumber,
        uint256 fixedTimeForgotten
    ) internal view returns (bool res, uint256 amount) {
        if (
            mapRound[roundNumber].firstIndex > 0 &&
            mapUserSeed[roundNumber][account] > 0
        ) {
            SowNode memory sowNode = queueSeed[mapUserSeed[roundNumber][account]];
            if (sowNode.buyTime < sub(block.timestamp, fixedTimeForgotten)) {
                res = true;
                amount = sub(sowNode.soldAmount, sowNode.claimedAmount);
            }
        }
    }

    function getSysFundAmount() external view returns (uint256 res) {
        res = sysFundAmount;
    }

    function decreaseSysFundAmount(uint256 amount) external {
        require(mapCaller[msg.sender], " 23");
        require(sysFundAmount >= amount, "sysfundAmount overflow to decrease");
        sysFundAmount = sub(sysFundAmount, amount);
    }

    function getFomoPoolAmount(uint32 roundNumber)
        external
        view
        returns (uint256 res)
    {
        res = mapFomoPoolAmount[roundNumber];
    }

    function getCharityAmount() external view returns (uint256 res) {
        res = charityAmount;
    }

    function decreaseCharityAmount(uint256 amount) external onlyCaller {
        require(charityAmount >= amount, "charityAmount overflow to decrease");
        charityAmount = sub(charityAmount, amount);
    }

    function isRoundStop(uint32 roundNumber) external view returns (bool res) {
        res = _isRoundStop
        (
            roundNumber, 
            SystemSetting(moduleMgr.getModuleSystemSetting()).getResetCountDownTimeLength(0)
        );
    }

    function _isRoundStop(
        uint32 roundNumber,
        uint256 resetCountDownTimeLength
    ) internal view returns (bool res) {
        if (mapRound[roundNumber].firstIndex > 0) {
            RoundData memory rd = mapRound[roundNumber];
            SowNode memory last_snd = queueSeed[rd.lastIndex];
            res = block.timestamp > add(last_snd.buyTime, resetCountDownTimeLength);
        }
    }

    function isFomoRewardTransfered(address account, uint32 roundNumber) external view returns (bool res) {
        res = mapFomoRewardTransfered[account][roundNumber];
    }

    function transferFomoReward
    (
        uint32 roundNumber
    ) external onlyCaller {
        _transferFomoReward(roundNumber);
    }

    function _transferFomoReward
    (
        uint32 roundNumber
    ) internal {
        (
            bool res1,
            address account1,
            uint256 amount1
        ) = _getLastInRewardAddress(roundNumber, SystemSetting(moduleMgr.getModuleSystemSetting()).getResetCountDownTimeLength(0));
        if (res1) {
            if (!mapFomoRewardTransfered[account1][roundNumber]) {
                if (!mapFomoRewardClaimed[account1].exists) {
                    mapFomoRewardClaimed[account1] = FomoRewardClaimData(
                        amount1,
                        0,
                        true
                    );
                } else {
                    FomoRewardClaimData storage frd = mapFomoRewardClaimed[
                        account1
                    ];
                    frd.totalAmount = add(frd.totalAmount, amount1);
                }
            }
        }

        (
            bool res2,
            address account2,
            uint256 amount2
        ) = _getMostInRewardAddress(roundNumber, SystemSetting(moduleMgr.getModuleSystemSetting()).getResetCountDownTimeLength(0));
        if (res2) {
            if (!mapFomoRewardTransfered[account2][roundNumber]) {
                if (!mapFomoRewardClaimed[account2].exists) {
                    mapFomoRewardClaimed[account2] = FomoRewardClaimData(
                        amount2,
                        0,
                        true
                    );
                } else {
                    FomoRewardClaimData storage frd = mapFomoRewardClaimed[
                        account2
                    ];
                    frd.totalAmount = add(frd.totalAmount, amount2);
                }
            }
        }

        if (res1 && res2) {
            if (account1 == account2) {
                if (!mapFomoRewardTransfered[account1][roundNumber]) {
                    mapFomoRewardTransfered[account1][roundNumber] = true;
                }
            } else {
                mapFomoRewardTransfered[account1][roundNumber] = true;
                mapFomoRewardTransfered[account2][roundNumber] = true;
            }
        }
    }

    function getRoundLastTime(uint32 roundNumber) external view returns (uint res) {
        if(mapRound[roundNumber].firstIndex > 0) {
            res = mapRound[roundNumber].lastTime;
        }
    }

    function getLastInRewardAddress(uint32 roundNumber)
        external
        view
        returns (
            bool res,
            address account,
            uint256 amount
        )
    {
        (res, account, amount) = _getLastInRewardAddress(roundNumber, SystemSetting(moduleMgr.getModuleSystemSetting()).getResetCountDownTimeLength(0));
    }

    function _getLastInRewardAddress
    (
        uint32 roundNumber,
        uint256 resetCountDownTimeLength
    )
        internal
        view
        returns (
            bool res,
            address account,
            uint256 amount
        )
    {
        if (mapRound[roundNumber].firstIndex > 0) {
            if (_isRoundStop(roundNumber, resetCountDownTimeLength)) {
                RoundData memory rd = mapRound[roundNumber];
                res = true;
                account = queueSeed[rd.lastIndex].account;
                amount = mul(queueSeed[rd.lastIndex].outAmount, 10);
                if (amount > div(mapFomoPoolAmount[roundNumber], 2)) {
                    amount = div(mapFomoPoolAmount[roundNumber], 2);
                }
            }
        }
    }

    function getMostInRewardAddress(uint32 roundNumber)
        external
        view
        returns (
            bool res,
            address account,
            uint256 amount
        )
    {
        (res, account, amount) = _getMostInRewardAddress(roundNumber, SystemSetting(moduleMgr.getModuleSystemSetting()).getResetCountDownTimeLength(0));
    }

    function _getMostInRewardAddress
    (
        uint32 roundNumber,
        uint256 resetCountDownTimeLength
    )
        internal
        view
        returns (
            bool res,
            address account,
            uint256 amount
        )
    {
        if (mapRound[roundNumber].firstIndex > 0) {
            if (_isRoundStop(roundNumber, resetCountDownTimeLength)) {
                RoundData memory rd = mapRound[roundNumber];
                res = true;

                uint256 maxAmount = queueSeed[rd.lastIndex].outAmount;
                uint32 dstIndex = rd.firstIndex;
                for (uint32 i = rd.firstIndex; i <= rd.lastIndex; ++i) {
                    if (queueSeed[i].outAmount >= maxAmount) {
                        maxAmount = queueSeed[i].outAmount;
                        dstIndex = i;
                    }
                }
                account = queueSeed[dstIndex].account;

                (bool res_last, , uint256 amount_last) = _getLastInRewardAddress(roundNumber, resetCountDownTimeLength);
                if(res_last) {
                    amount = sub(mapFomoPoolAmount[roundNumber], amount_last);
                }else{
                    amount = mapFomoPoolAmount[roundNumber];
                }
            }
        }
    }

    function checkFomoReward(address account, uint32 roundNumber)
        external
        view
        returns (
            bool isLastIn,
            bool isMostIn,
            uint256 amount
        )
    {
        (isLastIn, isMostIn, amount) = _checkFomoReward(account, roundNumber, SystemSetting(moduleMgr.getModuleSystemSetting()).getResetCountDownTimeLength(0));
    }

    function _checkFomoReward
    (
        address account, 
        uint32 roundNumber,
        uint256 resetCountDownTimeLength
    )
        internal
        view
        returns (
            bool isLastIn,
            bool isMostIn,
            uint256 amount
        )
    {
        if (
            mapRound[roundNumber].firstIndex > 0 &&
            mapUserSeed[roundNumber][account] > 0
        ) {
            if (_isRoundStop(roundNumber, resetCountDownTimeLength)) {
                RoundData memory rd = mapRound[roundNumber];
                if (account == queueSeed[rd.lastIndex].account) {
                    isLastIn = true;
                }

                uint256 maxAmount = queueSeed[rd.lastIndex].outAmount;
                uint32 dstIndex = rd.lastIndex;
                for (uint32 i = rd.lastIndex; i >= rd.firstIndex; --i) {
                    if (queueSeed[i].outAmount > maxAmount) {
                        maxAmount = queueSeed[i].outAmount;
                        dstIndex = i;
                    }
                }

                if (account == queueSeed[dstIndex].account) {
                    isMostIn = true;
                }

                uint256 lastRewardAmount = mul(queueSeed[rd.lastIndex].outAmount, 10);
                if (lastRewardAmount > div(mapFomoPoolAmount[roundNumber], 2)) {
                    lastRewardAmount = div(mapFomoPoolAmount[roundNumber], 2);
                }
                uint256 mostRewardAmount = sub(mapFomoPoolAmount[roundNumber],
                    lastRewardAmount);

                uint256 rewardAmount = 0;
                if (isLastIn) {
                    rewardAmount = add(rewardAmount, lastRewardAmount);
                }

                if (isMostIn) {
                    rewardAmount = add(rewardAmount, mostRewardAmount);
                }

                amount = rewardAmount;
            }
        }
    }

    function fomoRewardClaimable(address account)
        external
        view
        returns (bool res, uint256 amount)
    {
        (res, amount) = _fomoRewardClaimable(account);
    }

    function _fomoRewardClaimable(address account)
        internal
        view
        returns (bool res, uint256 amount)
    {
        if (mapFomoRewardClaimed[account].exists) {
            if (
                mapFomoRewardClaimed[account].totalAmount >
                mapFomoRewardClaimed[account].claimedAmount
            ) {
                res = true;
                amount =
                    sub(mapFomoRewardClaimed[account].totalAmount,
                    mapFomoRewardClaimed[account].claimedAmount);
            }
        }
    }

    function fomoRewardClaimedDataExists(address account) external view returns (bool res) {
        res = mapFomoRewardClaimed[account].exists;
    }

    function increaseFomoRewardClaimedAmount(address account, uint256 amount) external onlyCaller {
        require (mapFomoRewardClaimed[account].exists, "user claimed data not exists");
        FomoRewardClaimData storage frd = mapFomoRewardClaimed[account];
        require(frd.totalAmount >= add(frd.claimedAmount, amount), "claimed data error");
        frd.claimedAmount = add(frd.claimedAmount, amount);
    }

    //get round data
    function getRoundData(uint32 roundNumber)
        external
        view
        returns (
            bool res,
            uint256 inAmount,
            uint256 outAmount,
            uint lastTime,
            uint32 firstIndex,
            uint32 currentIndex,
            uint32 lastIndex
        )
    {
        if (mapRound[roundNumber].firstIndex > 0) {
            res = true;
            inAmount = mapRound[roundNumber].inAmount;
            outAmount = mapRound[roundNumber].outAmount;
            lastTime = mapRound[roundNumber].lastTime;
            firstIndex = mapRound[roundNumber].firstIndex;
            currentIndex = mapRound[roundNumber].currentIndex;
            lastIndex = mapRound[roundNumber].lastIndex;
        }
    }

    function getForgottenClaimable(address account, uint32 roundNumber, uint fixedTimeForgotten, uint resetCountDownTimeLength) external view returns (bool res, uint256 amount) {
        if(mapFomoRewardClaimed[account].exists) {
            FomoRewardClaimData storage frd = mapFomoRewardClaimed[account];
            if (
                frd.totalAmount > frd.claimedAmount &&
                mapRound[roundNumber].lastTime <
                add(sub(block.timestamp, fixedTimeForgotten), resetCountDownTimeLength)
            ) {
                res = true;
                amount = sub(frd.totalAmount, frd.claimedAmount);
            }
        }
    }

    function deleteUserSeedData(address account, uint32 roundNumber) external onlyCaller {
        delete mapUserSeed[roundNumber][account];
    }

    function checkLostSeed(uint32 roundNumber) external view returns (bool res, uint256 amount) {
        if(mapRound[roundNumber].firstIndex > 0 && _isRoundStop(roundNumber, SystemSetting(moduleMgr.getModuleSystemSetting()).getResetCountDownTimeLength(0))) {
            RoundData memory data = mapRound[roundNumber];
            if(data.helpAmount > data.outAmount) {
                res = true;
                amount = data.helpAmount - data.outAmount;
            }
        }
    }

    function _getSowNode(uint32 index) internal view returns (SowNode memory res) {
        res = mapSowNode[index];
    }
}