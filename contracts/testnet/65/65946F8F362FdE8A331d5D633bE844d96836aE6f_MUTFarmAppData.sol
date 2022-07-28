// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./SystemAuth.sol";

contract MUTFarmAppData {
    address caller;

    SystemAuth ssAuth;

    struct RoundData {
        uint256 inAmount;
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

    constructor(address ssAuthAddress) {
        ssAuth = SystemAuth(ssAuthAddress);
    }

    function setCaller(address _caller) external {
        require(msg.sender == ssAuth.getOwner(), "Owner only");
        caller = _caller;
    }

    function getCaller() external view returns (address res) {
        res = caller;
    }

    function enqueue(
        address account,
        uint256 amount,
        uint256 withSharedProfit,
        uint256 withFomoReward,
        uint32 ssIndex
    ) external {
        require(msg.sender == caller, "caller only");
        SeedNodeData memory data = SeedNodeData(
            account,
            amount,
            withSharedProfit,
            withFomoReward,
            block.timestamp,
            ssIndex,
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
        require(msg.sender == caller, "caller only");
        FomoRewardClaimData storage frd = mapFomoRewardClaimed[account];
        require(
            frd.totalAmount >= frd.claimedAmount + amount,
            "amount overflow to claim"
        );
        frd.claimedAmount += amount;
    }

    function increaseQueueFirstIndex(uint32 add) external {
        require(msg.sender == caller, "caller only");
        queueFirstIndex += add;
    }

    function increaseQueueLastIndex(uint32 add) external {
        require(msg.sender == caller, "caller only");
        queueLastIndex += add;
    }

    function createNewRound(uint256 inAmount) external {
        require(msg.sender == caller, "caller only");
        ++queueLastIndex;
        queueFirstIndex = queueLastIndex;
        ++roundIndex;
        totalQueueAmount = 0;
        mapRound[roundIndex] = RoundData(
            inAmount,
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
        uint256 newAmount,
        uint32 ssIndex
    ) external {
        require(msg.sender == caller, "caller only");
        mapUserSeed[roundIndex][account] = SeedUserData(
            roundIndex,
            queueLastIndex,
            newAmount,
            0,
            0,
            block.timestamp,
            ssIndex,
            true
        );
    }

    function updateRoundDataInAmount(uint256 addInAmount) external {
        require(msg.sender == caller, "caller only");
        RoundData storage rd = mapRound[roundIndex];
        rd.inAmount += addInAmount;
        rd.lastTime = block.timestamp;
        rd.lastIndex = ++queueLastIndex;
    }

    function increaseRoundDataOutAmount(uint256 amount) external {
        require(msg.sender == caller, "caller only");
        RoundData storage rd = mapRound[roundIndex];
        rd.outAmount += amount;
    }

    function increaseCharityAmount(uint256 amount) external {
        require(msg.sender == caller, "caller only");
        charityAmount += amount;
    }

    function increaseSysFundAmount(uint256 amount) external {
        require(msg.sender == caller, "caller only");
        sysFundAmount += amount;
    }

    function increaseFomoPoolAmount(uint256 amount) external {
        require(msg.sender == caller, "caller only");
        mapFomoPoolAmount[roundIndex] += amount;
    }

    function isFirstSeedDataExists() external view returns (bool res) {
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
        SeedNodeData memory firstSeedData = queueSeed[queueFirstIndex];
        address firstNodeSeedAccount = firstSeedData.account;
        SeedUserData memory firstSeedUserData = mapUserSeed[roundIndex][
            firstNodeSeedAccount
        ];
        res = firstSeedUserData.totalAmount - firstSeedUserData.soldAmount;
    }

    function getFirstNodeSeedAccount() external view returns (address addr) {
        SeedNodeData memory firstSeedData = queueSeed[queueFirstIndex];
        addr = firstSeedData.account;
    }

    function increaseTotalQueueAmount(uint256 amount) external {
        require(msg.sender == caller, "caller only");
        totalQueueAmount += amount;
    }

    function decreaseTotalQueueAmount(uint256 amount) external {
        require(msg.sender == caller, "caller only");
        require(
            totalQueueAmount >= amount,
            "amount overflow to decrease total queue amount"
        );
        totalQueueAmount -= amount;
    }

    function sellUserSeed(address account, uint256 amount) external {
        require(msg.sender == caller, "caller only");
        SeedUserData storage sud = mapUserSeed[roundIndex][account];
        require(sud.totalAmount >= sud.soldAmount + amount, "Seed sold out");
        sud.soldAmount += amount;
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
            uint256 amount,
            uint256 withSharedProfit,
            uint256 withFomoReward,
            uint256 buyTime,
            uint32 ssIndex
        )
    {
        if (index >= 1 && index <= queueLastIndex) {
            account = queueSeed[index].account;
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

    //check if seed is collectable
    function checkCollectable(
        uint256 roundNumber,
        address account,
        uint256 matureTime
    ) external view returns (bool res, uint256 amount) {
        (res, amount) = _checkCollectable(roundNumber, account, matureTime);
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
                amount = sud.soldAmount - sud.claimedAmount;
            }
        }
    }

    function increaseUserSeedClaimedAmount(
        uint256 roundNumber,
        address account,
        uint256 amount
    ) external {
        require(msg.sender == caller, "caller only");
        require(
            mapUserSeed[roundNumber][account].exists,
            "user seed not exists"
        );
        SeedUserData storage sud = mapUserSeed[roundNumber][account];
        require(
            sud.soldAmount >= sud.claimedAmount + amount,
            "insufficient claimable amount to claim"
        );
        sud.claimedAmount += amount;
        if (sud.claimedAmount >= sud.totalAmount) {
            delete mapUserSeed[roundNumber][msg.sender];
        }
    }

    function isRoundExists(uint256 roundNumber)
        external
        view
        returns (bool res)
    {
        res = mapRound[roundNumber].exists;
    }

    function userForgottenSeedAvailable(
        address account,
        uint256 roundNumber,
        uint256 fixedTimeForgotten
    ) external view returns (bool res, uint256 amount) {
        (res, amount) = _userForgottenSeedAvailable(
            account,
            roundNumber,
            fixedTimeForgotten
        );
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
                block.timestamp - fixedTimeForgotten
            ) {
                res = true;
                amount =
                    mapUserSeed[roundNumber][account].soldAmount -
                    mapUserSeed[roundNumber][account].claimedAmount;
            }
        }
    }

    function getSysFundAmount() external view returns (uint256 res) {
        res = sysFundAmount;
    }

    function decreaseSysFundAmount(uint256 amount) external {
        require(msg.sender == caller, "caller only");
        require(sysFundAmount >= amount, "sysfundAmount overflow to decrease");
        sysFundAmount -= amount;
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
        require(msg.sender == caller, "caller only");
        require(charityAmount >= amount, "charityAmount overflow to decrease");
        charityAmount -= amount;
    }

    //check if the round is dead
    function isRoundStop(
        uint256 roundNumber,
        uint256 resetCountDownTimeLength,
        uint256 backlogToCountdown,
        uint256 backlogTime
    ) external view returns (bool res) {
        res = _isRoundStop(
            roundNumber,
            resetCountDownTimeLength,
            backlogToCountdown,
            backlogTime
        );
    }

    function _isRoundStop(
        uint256 roundNumber,
        uint256 resetCountDownTimeLength,
        uint256 backlogToCountdown,
        uint256 backlogTime
    ) internal view returns (bool res) {
        if (mapRound[roundNumber].exists) {
            RoundData memory rd = mapRound[roundNumber];
            SeedNodeData memory last_snd = queueSeed[rd.lastIndex];
            (bool backlogRes, uint256 percent, , ) = _getBacklog(
                roundNumber,
                backlogTime
            );
            if (
                block.timestamp > last_snd.buyTime + resetCountDownTimeLength &&
                backlogRes &&
                percent < backlogToCountdown
            ) {
                res = true;
            }
        }
    }

    function getBacklog(uint256 roundNumber, uint256 backlogTime)
        external
        view
        returns (bool res, uint256 percent, bool hasOnePercent, uint onePercentTime)
    {
        (res, percent, hasOnePercent, onePercentTime) = _getBacklog(roundNumber, backlogTime);
    }

    function _getBacklog(uint256 roundNumber, uint256 backlogTime)
        internal
        view
        returns (bool res, uint256 percent, bool hasOnePercent, uint onePercentTime)
    {
        if (mapRound[roundNumber].exists) {
            uint256 amount24 = 0;
            uint32 i = 0;

            uint256 amount_1 = 0;
            uint256 percent_1 = 0;
            uint time_1 = 0;

            for (i = mapRound[roundNumber].lastIndex; i >= mapRound[roundNumber].currentIndex; i--) {
                if(queueSeed[i].exists) {
                    SeedUserData memory sud = mapUserSeed[roundNumber][queueSeed[i].account];
                    if(sud.exists && queueSeed[i].buyTime > block.timestamp - backlogTime) {
                        amount24 += (sud.totalAmount-sud.soldAmount);
                    }

                    amount_1 += (sud.totalAmount-sud.soldAmount);
                    if(percent_1 < 10 && (1000 * amount_1) / totalQueueAmount >= 10) {
                        hasOnePercent = true;
                        onePercentTime = time_1;
                    }
                    percent_1 = (1000 * amount_1) / totalQueueAmount;
                    time_1 = queueSeed[i].buyTime;
                }
            }
            
            if(mapRound[roundNumber].lastIndex == mapRound[roundNumber].currentIndex) {
                hasOnePercent = true;
                onePercentTime = queueSeed[mapRound[roundNumber].lastIndex].buyTime;
            }

            res = true;
            percent = (1000 * amount24) / totalQueueAmount;
        }
    }

    function transferFomoReward
    (
        uint256 roundNumber,
        uint256 resetCountDownTimeLength,
        uint256 backlogToCountdown,
        uint256 backlogTime
    ) external {
        require(msg.sender == caller, "caller only");
        (
            bool res1,
            address account1,
            uint256 amount1
        ) = _getLastInRewardAddress(roundNumber, resetCountDownTimeLength, backlogToCountdown, backlogTime);
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
                    frd.totalAmount += amount1;
                }
            }
        }

        (
            bool res2,
            address account2,
            uint256 amount2
        ) = _getMostInRewardAddress(roundNumber, resetCountDownTimeLength, backlogToCountdown, backlogTime);
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
                    frd.totalAmount += amount2;
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

    function getLastInRewardAddress
    (
        uint256 roundNumber,
        uint256 resetCountDownTimeLength,
        uint256 backlogToCountdown,
        uint256 backlogTime
    )
        external
        view
        returns (
            bool res,
            address account,
            uint256 amount
        )
    {
        (res, account, amount) = _getLastInRewardAddress(roundNumber, resetCountDownTimeLength, backlogToCountdown, backlogTime);
    }

    function _getLastInRewardAddress
    (
        uint256 roundNumber,
        uint256 resetCountDownTimeLength,
        uint256 backlogToCountdown,
        uint256 backlogTime
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
            if (_isRoundStop(roundNumber, resetCountDownTimeLength, backlogToCountdown, backlogTime)) {
                RoundData memory rd = mapRound[roundNumber];
                res = true;
                account = queueSeed[rd.lastIndex].account;
                amount = queueSeed[rd.lastIndex].amount * 10;
                if (amount > mapFomoPoolAmount[roundNumber] / 2) {
                    amount = mapFomoPoolAmount[roundNumber] / 2;
                }
            }
        }
    }

    function getMostInRewardAddress
    (
        uint256 roundNumber,
         uint256 resetCountDownTimeLength,
        uint256 backlogToCountdown,
        uint256 backlogTime
    )
        external
        view
        returns (
            bool res,
            address account,
            uint256 amount
        )
    {
        (res, account, amount) = _getMostInRewardAddress(roundNumber, resetCountDownTimeLength, backlogToCountdown, backlogTime);
    }

    function _getMostInRewardAddress
    (
        uint256 roundNumber,
        uint256 resetCountDownTimeLength,
        uint256 backlogToCountdown,
        uint256 backlogTime
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
            if (_isRoundStop(roundNumber, resetCountDownTimeLength, backlogToCountdown, backlogTime)) {
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

                (bool res_last, , uint256 amount_last) = _getLastInRewardAddress(roundNumber, resetCountDownTimeLength, backlogToCountdown, backlogTime);
                if(res_last) {
                    amount = mapFomoPoolAmount[roundNumber] - amount_last;
                }else{
                    amount = mapFomoPoolAmount[roundNumber];
                }
            }
        }
    }

    function checkFomoReward
    (
        address account, 
        uint256 roundNumber,
        uint256 resetCountDownTimeLength,
        uint256 backlogToCountdown,
        uint256 backlogTime
    )
        external
        view
        returns (
            bool isLastIn,
            bool isMostIn,
            uint256 amount
        )
    {
        (isLastIn, isMostIn, amount) = _checkFomoReward(account, roundNumber, resetCountDownTimeLength, backlogToCountdown, backlogTime);
    }

    function _checkFomoReward
    (
        address account, 
        uint256 roundNumber,
        uint256 resetCountDownTimeLength,
        uint256 backlogToCountdown,
        uint256 backlogTime
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
            if (_isRoundStop(roundNumber, resetCountDownTimeLength, backlogToCountdown, backlogTime)) {
                RoundData memory rd = mapRound[roundNumber];
                if (account == queueSeed[rd.lastIndex].account) {
                    isLastIn = true;
                }

                uint256 maxAmount = queueSeed[rd.lastIndex].amount;
                uint32 dstIndex = rd.lastIndex;
                for (uint32 i = rd.lastIndex; i >= rd.firstIndex; i--) {
                    if (queueSeed[i].amount > maxAmount) {
                        maxAmount = queueSeed[i].amount;
                        dstIndex = i;
                    }
                }

                if (account == queueSeed[dstIndex].account) {
                    isMostIn = true;
                }

                uint256 lastRewardAmount = queueSeed[rd.lastIndex].amount * 10;
                if (lastRewardAmount > mapFomoPoolAmount[roundNumber] / 2) {
                    lastRewardAmount = mapFomoPoolAmount[roundNumber] / 2;
                }
                uint256 mostRewardAmount = mapFomoPoolAmount[roundNumber] -
                    lastRewardAmount;

                uint256 rewardAmount = 0;
                if (isLastIn) {
                    rewardAmount += lastRewardAmount;
                }

                if (isMostIn) {
                    rewardAmount += mostRewardAmount;
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
                    mapFomoRewardClaimed[account].totalAmount -
                    mapFomoRewardClaimed[account].claimedAmount;
            }
        }
    }

    function fomoRewardClaimedDataExists(address account) external view returns (bool res) {
        res = mapFomoRewardClaimed[account].exists;
    }

    function increaseFomoRewardClaimedAmount(address account, uint256 amount) external {
        require(msg.sender == caller, "caller only");
        require (mapFomoRewardClaimed[account].exists, "user claimed data not exists");
        FomoRewardClaimData storage frd = mapFomoRewardClaimed[account];
        require(frd.totalAmount >= frd.claimedAmount + amount, "claimed data error");
        frd.claimedAmount += amount;
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
                block.timestamp -
                    fixedTimeForgotten +
                    resetCountDownTimeLength
            ) {
                res = true;
                amount = frd.totalAmount - frd.claimedAmount;
            }
        }
    }

    function deleteUserSeedData(address account, uint256 roundNumber) external {
        require(msg.sender == caller, "caller only");
        delete mapUserSeed[roundNumber][account];
    }
}