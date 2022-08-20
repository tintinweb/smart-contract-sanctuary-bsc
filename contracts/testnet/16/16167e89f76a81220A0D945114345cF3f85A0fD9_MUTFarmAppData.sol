// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./SafeMath.sol";
import "./SystemAuth.sol";
import "./SystemSetting.sol";
import "./ModuleMgr.sol";
import "./Relationship.sol";
import "./History.sol";

contract MUTFarmAppData is SafeMath {

    struct CallerData{
        address caller;
        bool isCaller;
    }
    uint32 callerCount;
    mapping(address => bool) mapCaller;
    mapping(uint32 => CallerData) mapCallerList;

    SystemAuth ssAuth;
    ModuleMgr moduleMgr;

    struct RoundData {
        uint256 inAmount;
        uint256 helpAmount;
        uint256 outAmount;
        uint256 firstTime;
        uint256 currentTime;
        uint256 lastTime;
        uint32 firstIndex;
        uint32 currentIndex;
        uint32 lastIndex;
        bool exists;
    }

    struct SeedNodeData {
        address account;
        uint256 sowAmount;
        uint256 amount;
        uint256 withSharedProfit;
        uint256 withFomoReward;
        uint256 buyTime;
        uint32 ssIndex; //system setting index
        bool exists;
    }

    struct SeedUserData {
        uint256 roundIndex;
        uint32 queueIndex;
        uint256 totalAmount;
        uint256 soldAmount; //amounts have been sold
        uint256 claimedAmount; //amounts have beed claimed;
        uint256 buyTime;
        uint32 ssIndex; //system setting index
        bool exists;
    }

    uint256 roundIndex;

    uint256 charityAmount;
    uint256 sysFundAmount;

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
    mapping(uint32 => SeedNodeData) queueSeed;
    uint32 queueFirstIndex;
    uint32 queueLastIndex;

    //mapping for user seed
    //keys： roundIndex=>(account=>data))
    mapping(uint256 => mapping(address => SeedUserData)) mapUserSeed;

    mapping(uint256 => RoundData) mapRound;

    event seedSoldEvent(address account, uint256 amount, uint timestamp);

    constructor(address ssAuthAddress, address moduleMgrAddress) {
        ssAuth = SystemAuth(ssAuthAddress);
        moduleMgr = ModuleMgr(moduleMgrAddress);
    }

    function addCaller(address _caller) external {
        require(msg.sender == ssAuth.getOwner(), "Owner only");
        require(!mapCaller[_caller], "caller exists");
        mapCaller[_caller] = true;
        mapCallerList[++callerCount] = CallerData(_caller, true);
    }

    function isCaller(address addr) external view returns (bool res) {
        res = _isCaller(addr);
    }

    function _isCaller(address addr) internal view returns (bool res) {
        res = mapCaller[addr];
    }

    function getCallerCount() external view returns (uint32 res) {
        res = callerCount;
    }

    function removeCaller(address addr) external {
        require(msg.sender == ssAuth.getOwner(), "Owner only");
        if(mapCaller[addr]) {
            delete mapCaller[addr];
            for(uint32 i = 1; i <= callerCount; ++i) {
                if(mapCallerList[i].caller == addr) {
                    CallerData storage cd = mapCallerList[i];
                    cd.isCaller = false;
                    break;
                }
            }
        }
    }

    function getCaller(uint32 index) external view returns (bool res, address addr) {
        addr = mapCallerList[index].caller;
        res = mapCaller[addr];
    }

    function enqueue(
        address account,
        uint256 sowAmount,
        uint256 amount,
        uint256 withSharedProfit,
        uint256 withFomoReward
    ) external {
        require(mapCaller[msg.sender], "caller only 5");
        _enqueue(account, sowAmount, amount, withSharedProfit, withFomoReward);
    }

    function _enqueue(
        address account,
        uint256 sowAmount,
        uint256 amount,
        uint256 withSharedProfit,
        uint256 withFomoReward
    ) internal {
        SeedNodeData memory data = SeedNodeData(
            account,
            sowAmount,
            amount,
            withSharedProfit,
            withFomoReward,
            block.timestamp,
            SystemSetting(moduleMgr.getModuleSystemSetting()).getCurrentSettingIndex(),
            true
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

    function getCurrentRoundIndex() external view returns (uint256 res) {
        res = roundIndex;
    }

    function isUserSeedExists(uint256 roundNumber, address account)
        external
        view
        returns (bool res)
    {
        res = mapUserSeed[roundNumber][account].exists;
    }

    function increaseUserFomoRewardClaimed(address account, uint256 amount)
        external
    {
        require(mapCaller[msg.sender], "caller only 6");
        FomoRewardClaimData storage frd = mapFomoRewardClaimed[account];
        require(
            frd.totalAmount >= add(frd.claimedAmount, amount),
            "amount overflow to claim"
        );
        frd.claimedAmount = add(frd.claimedAmount, amount);
    }

    function increaseQueueFirstIndex(uint32 num) external {
        require(mapCaller[msg.sender], "caller only 7");
        queueFirstIndex += num;
    }

    function increaseQueueLastIndex(uint32 num) external {
        require(mapCaller[msg.sender], "caller only 8");
        queueLastIndex += num;
    }

    function createNewRound(uint256 inAmount) external {
        require(mapCaller[msg.sender], "caller only 9");
        ++queueLastIndex;
        queueFirstIndex = queueLastIndex;
        ++roundIndex;
        totalQueueAmount = 0;
        mapRound[roundIndex] = RoundData(
            inAmount,
            0,
            0,
            block.timestamp,
            block.timestamp,
            block.timestamp,
            queueFirstIndex,
            queueFirstIndex,
            queueLastIndex,
            true
        );
    }

    function createNewUserSeedData(
        address account,
        uint256 newAmount
    ) external {
        require(mapCaller[msg.sender], "caller only 10");
        _createNewUserSeedData(account, newAmount);
    }

    function _createNewUserSeedData(
        address account,
        uint256 newAmount
    ) internal {
        mapUserSeed[roundIndex][account] = SeedUserData(
            roundIndex,
            queueLastIndex,
            newAmount,
            0,
            0,
            block.timestamp,
            SystemSetting(moduleMgr.getModuleSystemSetting()).getCurrentSettingIndex(),
            true
        );
    }

    function resowSeed(address account, uint256 roundNumber) external returns(bool res, uint256 sowAmount, uint256 withdrawAmount) {
        require(mapCaller[msg.sender], "caller only 11");
        require(mapUserSeed[roundNumber][account].exists,
         "have no seeds");
         
        require(block.timestamp > 
        mapUserSeed[roundNumber][account].buyTime +
        SystemSetting(moduleMgr.getModuleSystemSetting()).getMatureTime(0), 
        "matured time not reached");

        SeedUserData storage sud = mapUserSeed[roundNumber][account];
        require(sud.soldAmount >= sud.totalAmount, 
        "no all seeds matured");
        uint256 resowbleAmount = sud.soldAmount - sud.claimedAmount;
        require(resowbleAmount >= SystemSetting(moduleMgr.getModuleSystemSetting()).getMinAmountBuy(0), 
        "too small amount to resow");
        if(resowbleAmount > SystemSetting(moduleMgr.getModuleSystemSetting()).getMaxAmountBuy(0)) {
            sowAmount = SystemSetting(moduleMgr.getModuleSystemSetting()).getMaxAmountBuy(0);
            withdrawAmount = resowbleAmount - sowAmount;
        } else {
            sowAmount = resowbleAmount;
        }
        delete mapUserSeed[roundNumber][account];
        require(_distributeMony(account, sowAmount, 0, 0), "resow seed error");
        res = true;
    }

    function distributeMony(address account, uint256 amount, uint256 withSharedProfit, uint256 withFomoReward)
        external
        returns (bool res) 
    {
        require(mapCaller[msg.sender], "caller only 12");
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
        _createNewUserSeedData(account, newAmount);
        _increaseTotalQueueAmount(newAmount);
        _updateRoundDataHelpAmount(helpAmount);
        res = true;
    }

    function _sellUserSeedInBuy(address account, uint256 amount)
        internal
        returns (bool res)
    {
        _sellUserSeed(account, amount);
        History(moduleMgr.getModuleHistory()).addMatureRecord(account, amount);
        emit seedSoldEvent(account, amount, block.timestamp);
        res = true;
    }

    function updateRoundDataInAmount(uint256 addInAmount) external {
        require(mapCaller[msg.sender], "caller only 13");
        RoundData storage rd = mapRound[roundIndex];
        rd.inAmount = add(rd.inAmount, addInAmount);
        rd.lastTime = block.timestamp;
        rd.lastIndex = ++queueLastIndex;
    }

    function updateRoundDataHelpAmount(uint256 addInAmount) external {
        require(mapCaller[msg.sender], "caller only 14");
        _updateRoundDataHelpAmount(addInAmount);
    }

    function _updateRoundDataHelpAmount(uint256 addInAmount) internal {
        RoundData storage rd = mapRound[roundIndex];
        rd.helpAmount = add(rd.helpAmount, addInAmount);
    }

    function increaseRoundDataOutAmount(uint256 amount) external {
        require(mapCaller[msg.sender], "caller only 15");
        _increaseRoundDataOutAmount(amount);
    }

    function _increaseRoundDataOutAmount(uint256 amount) internal {
        RoundData storage rd = mapRound[roundIndex];
        rd.outAmount = add(rd.outAmount, amount);
    }

    function increaseCharityAmount(uint256 amount) external {
        require(mapCaller[msg.sender], "caller only 16");
        charityAmount = add(charityAmount, amount);
    }

    function increaseSysFundAmount(uint256 amount) external {
        require(mapCaller[msg.sender], "caller only 17");
        sysFundAmount = add(sysFundAmount, amount);
    }

    function increaseFomoPoolAmount(uint256 amount) external {
        require(mapCaller[msg.sender], "caller only 18");
        mapFomoPoolAmount[roundIndex] = add(mapFomoPoolAmount[roundIndex], amount);
    }

    function isFirstSeedDataExists() external view returns (bool res) {
        res = _isFirstSeedDataExists();
    }

    function _isFirstSeedDataExists() internal view returns (bool res) {
        SeedNodeData memory firstSeedData = queueSeed[queueFirstIndex];
        if (!firstSeedData.exists) {
            res = false;
        } else {
            address firstNodeSeedAccount = firstSeedData.account;
            if (!mapUserSeed[roundIndex][firstNodeSeedAccount].exists) {
                res = false;
            } else {
                res = true;
            }
        }
    }

    function getFirstNodeSeedAmount() external view returns (uint256 res) {
        res = _getFirstNodeSeedAmount();
    }

    function _getFirstNodeSeedAmount() internal view returns (uint256 res) {
        SeedNodeData memory firstSeedData = queueSeed[queueFirstIndex];
        address firstNodeSeedAccount = firstSeedData.account;
        SeedUserData memory firstSeedUserData = mapUserSeed[roundIndex][
            firstNodeSeedAccount
        ];
        res = sub(firstSeedUserData.totalAmount, firstSeedUserData.soldAmount);
    }

    function getFirstNodeSeedAccount() external view returns (address addr) {
        addr = _getFirstNodeSeedAccount();
    }

    function _getFirstNodeSeedAccount() internal view returns (address addr) {
        SeedNodeData memory firstSeedData = queueSeed[queueFirstIndex];
        addr = firstSeedData.account;
    }

    function increaseTotalQueueAmount(uint256 amount) external {
        require(mapCaller[msg.sender], "caller only 19");
        _increaseTotalQueueAmount(amount);
    }

    function _increaseTotalQueueAmount(uint256 amount) internal {
        totalQueueAmount = add(totalQueueAmount, amount);
    }

    function decreaseTotalQueueAmount(uint256 amount) external {
        require(mapCaller[msg.sender], "caller only 20");
        _decreaseTotalQueueAmount(amount);
    }

    function _decreaseTotalQueueAmount(uint256 amount) internal {
        require(
            totalQueueAmount >= amount,
            "amount overflow to decrease total queue amount"
        );
        totalQueueAmount = sub(totalQueueAmount, amount);
    }

    function sellUserSeed(address account, uint256 amount) external {
        require(mapCaller[msg.sender], "caller only 21");
        _sellUserSeed(account, amount);
    }

    function _sellUserSeed(address account, uint256 amount) internal {
        SeedUserData storage sud = mapUserSeed[roundIndex][account];
        require(sud.totalAmount >= add(sud.soldAmount, amount), "Seed sold out");
        sud.soldAmount = add(sud.soldAmount, amount);
        if (sud.totalAmount <= sud.soldAmount) {
            ++queueFirstIndex;
            RoundData storage rd = mapRound[roundIndex];
            rd.currentIndex = queueFirstIndex;
            rd.currentTime = block.timestamp;
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
            amount = queueSeed[index].amount;
            withSharedProfit = queueSeed[index].withSharedProfit;
            withFomoReward = queueSeed[index].withFomoReward;
            ssIndex = queueSeed[index].ssIndex;
            buyTime = queueSeed[index].buyTime;
            res = true;
        }
    }

    function getSeedUserData(uint256 roundNumber, address account)
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
        if (mapUserSeed[roundNumber][account].exists) {
            res = true;
            _roundIndex = mapUserSeed[roundNumber][account].roundIndex;
            _queueIndex = mapUserSeed[roundNumber][account].queueIndex;
            _totalAmount = mapUserSeed[roundNumber][account].totalAmount;
            _soldAmount = mapUserSeed[roundNumber][account].soldAmount;
            _claimedAmount = mapUserSeed[roundNumber][account].claimedAmount;
            _buyTime = mapUserSeed[roundNumber][account].buyTime;
            _ssIndex = mapUserSeed[roundNumber][account].ssIndex;
        }
    }

    function checkCollectable(uint256 roundNumber, address account)
        external
        view
        returns (bool res, uint256 amount)
    {
        (res, amount) = _checkCollectable(roundNumber, account, SystemSetting(moduleMgr.getModuleSystemSetting()).getMatureTime(0));
    }

    function _checkCollectable(
        uint256 roundNumber,
        address account,
        uint256 matureTime
    ) internal view returns (bool res, uint256 amount) {
        if (
            mapUserSeed[roundNumber][account].exists &&
            mapUserSeed[roundNumber][account].soldAmount >
            mapUserSeed[roundNumber][account].claimedAmount
        ) {
            SeedUserData memory sud = mapUserSeed[roundNumber][account];
            if (block.timestamp >= sud.buyTime + matureTime) {
                res = true;
                amount = sub(sud.soldAmount, sud.claimedAmount);
            }
        }
    }

    function increaseUserSeedClaimedAmount(
        uint256 roundNumber,
        address account,
        uint256 amount
    ) external {
        require(mapCaller[msg.sender], "caller only 22");
        require(
            mapUserSeed[roundNumber][account].exists,
            "user seed not exists"
        );
        SeedUserData storage sud = mapUserSeed[roundNumber][account];
        require(
            sud.soldAmount >= add(sud.claimedAmount, amount),
            "insufficient claimable amount to claim"
        );
        sud.claimedAmount = add(sud.claimedAmount, amount);
        if (sud.claimedAmount >= sud.totalAmount) {
            delete mapUserSeed[roundNumber][account];
        }
    }

    function isRoundExists(uint256 roundNumber)
        external
        view
        returns (bool res)
    {
        res = mapRound[roundNumber].exists;
    }

    function userForgottenSeedAvailable(address account, uint256 roundNumber) external view returns (bool res, uint256 amount) {
        (res, amount) = _userForgottenSeedAvailable(account, roundNumber, SystemSetting(moduleMgr.getModuleSystemSetting()).getFixedTimeForgotten(0));
    }

    function _userForgottenSeedAvailable(
        address account,
        uint256 roundNumber,
        uint256 fixedTimeForgotten
    ) internal view returns (bool res, uint256 amount) {
        if (
            mapRound[roundNumber].exists &&
            mapUserSeed[roundNumber][account].exists
        ) {
            if (
                mapUserSeed[roundNumber][account].buyTime <
                sub(block.timestamp, fixedTimeForgotten)
            ) {
                res = true;
                amount =
                    sub(mapUserSeed[roundNumber][account].soldAmount,
                    mapUserSeed[roundNumber][account].claimedAmount);
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

    function getFomoPoolAmount(uint256 roundNumber)
        external
        view
        returns (uint256 res)
    {
        res = mapFomoPoolAmount[roundNumber];
    }

    function getCharityAmount() external view returns (uint256 res) {
        res = charityAmount;
    }

    function decreaseCharityAmount(uint256 amount) external {
        require(mapCaller[msg.sender], "caller only 23");
        require(charityAmount >= amount, "charityAmount overflow to decrease");
        charityAmount = sub(charityAmount, amount);
    }

    function isRoundStop(uint256 roundNumber) external view returns (bool res) {
        res = _isRoundStop
        (
            roundNumber, 
            SystemSetting(moduleMgr.getModuleSystemSetting()).getResetCountDownTimeLength(0)
        );
    }

    function _isRoundStop(
        uint256 roundNumber,
        uint256 resetCountDownTimeLength
    ) internal view returns (bool res) {
        if (mapRound[roundNumber].exists) {
            RoundData memory rd = mapRound[roundNumber];
            SeedNodeData memory last_snd = queueSeed[rd.lastIndex];
            res = block.timestamp > add(last_snd.buyTime, resetCountDownTimeLength);
        }
    }

    function isFomoRewardTransfered(address account, uint256 roundNumber) external view returns (bool res) {
        res = mapFomoRewardTransfered[account][roundNumber];
    }

    function transferFomoReward
    (
        uint256 roundNumber
    ) external {
        require(mapCaller[msg.sender], "caller only 24");
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

    function getRoundLastTime(uint256 roundNumber) external view returns (uint res) {
        if(mapRound[roundNumber].exists) {
            res = mapRound[roundNumber].lastTime;
        }
    }

    function getLastInRewardAddress(uint256 roundNumber)
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
        uint256 roundNumber,
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
        if (mapRound[roundNumber].exists) {
            if (_isRoundStop(roundNumber, resetCountDownTimeLength)) {
                RoundData memory rd = mapRound[roundNumber];
                res = true;
                account = queueSeed[rd.lastIndex].account;
                amount = mul(queueSeed[rd.lastIndex].amount, 10);
                if (amount > div(mapFomoPoolAmount[roundNumber], 2)) {
                    amount = div(mapFomoPoolAmount[roundNumber], 2);
                }
            }
        }
    }

    function getMostInRewardAddress(uint256 roundNumber)
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
        uint256 roundNumber,
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
        if (mapRound[roundNumber].exists) {
            if (_isRoundStop(roundNumber, resetCountDownTimeLength)) {
                RoundData memory rd = mapRound[roundNumber];
                res = true;

                uint256 maxAmount = queueSeed[rd.lastIndex].amount;
                uint32 dstIndex = rd.firstIndex;
                for (uint32 i = rd.firstIndex; i <= rd.lastIndex; ++i) {
                    if (queueSeed[i].amount >= maxAmount) {
                        maxAmount = queueSeed[i].amount;
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

    function checkFomoReward(address account, uint256 roundNumber)
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
        uint256 roundNumber,
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
            mapRound[roundNumber].exists &&
            mapUserSeed[roundNumber][account].exists
        ) {
            if (_isRoundStop(roundNumber, resetCountDownTimeLength)) {
                RoundData memory rd = mapRound[roundNumber];
                if (account == queueSeed[rd.lastIndex].account) {
                    isLastIn = true;
                }

                uint256 maxAmount = queueSeed[rd.lastIndex].amount;
                uint32 dstIndex = rd.lastIndex;
                for (uint32 i = rd.lastIndex; i >= rd.firstIndex; --i) {
                    if (queueSeed[i].amount > maxAmount) {
                        maxAmount = queueSeed[i].amount;
                        dstIndex = i;
                    }
                }

                if (account == queueSeed[dstIndex].account) {
                    isMostIn = true;
                }

                uint256 lastRewardAmount = mul(queueSeed[rd.lastIndex].amount, 10);
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

    function increaseFomoRewardClaimedAmount(address account, uint256 amount) external {
        require(mapCaller[msg.sender], "caller only 25");
        require (mapFomoRewardClaimed[account].exists, "user claimed data not exists");
        FomoRewardClaimData storage frd = mapFomoRewardClaimed[account];
        require(frd.totalAmount >= add(frd.claimedAmount, amount), "claimed data error");
        frd.claimedAmount = add(frd.claimedAmount, amount);
    }

    //get round data
    function getRoundData(uint256 roundNumber)
        external
        view
        returns (
            bool res,
            uint256 inAmount,
            uint256 outAmount,
            uint firstTime,
            uint currentTime,
            uint lastTime,
            uint32 firstIndex,
            uint32 currentIndex,
            uint32 lastIndex
        )
    {
        if (mapRound[roundNumber].exists) {
            res = true;
            inAmount = mapRound[roundNumber].inAmount;
            outAmount = mapRound[roundNumber].outAmount;
            firstTime = mapRound[roundNumber].firstTime;
            currentTime = mapRound[roundNumber].currentTime;
            lastTime = mapRound[roundNumber].lastTime;
            firstIndex = mapRound[roundNumber].firstIndex;
            currentIndex = mapRound[roundNumber].currentIndex;
            lastIndex = mapRound[roundNumber].lastIndex;
        }
    }

    function getForgottenClaimable(address account, uint256 roundNumber, uint fixedTimeForgotten, uint resetCountDownTimeLength) external view returns (bool res, uint256 amount) {
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

    function deleteUserSeedData(address account, uint256 roundNumber) external {
        require(mapCaller[msg.sender], "caller only 26");
        delete mapUserSeed[roundNumber][account];
    }

    function checkLostSeed(uint256 roundNumber) external view returns (bool res, uint256 amount) {
        if(mapRound[roundNumber].exists && _isRoundStop(roundNumber, SystemSetting(moduleMgr.getModuleSystemSetting()).getResetCountDownTimeLength(0))) {
            RoundData memory data = mapRound[roundNumber];
            if(data.helpAmount > data.outAmount) {
                res = true;
                amount = data.helpAmount - data.outAmount;
            }
        }
    }
}