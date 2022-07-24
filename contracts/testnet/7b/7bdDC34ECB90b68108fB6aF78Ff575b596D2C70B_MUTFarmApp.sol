// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./SystemAuth.sol";
import "./SystemSetting.sol";
import "./FarmLand.sol";
import "./Relationship.sol";
import "./History.sol";

contract MUTFarmApp is Strings {
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

    //events
    //seed bought event
    event seedBoughtEvent(address account, uint256 amount, uint256 time);

    //seed sold event
    event seedSoldEvent(address account, uint256 amount, uint256 time);

    //seed claimed event
    event seedClaimedEvent(address account, uint256 amount);

    //fomo reward claimed event
    event fomoRewardClaimedEvent(address account, uint256 amount);

    //claim shared profit event
    event sharedProfitClaimedEvent(address account, uint256 amount);

    SystemSetting ssSetting;
    SystemAuth ssAuth;
    FarmLand farmLand;
    Relationship relationship;
    History history;

    constructor(
        address systemSettingAddress,
        address systemAuthAddress,
        address farmLandAddress,
        address relationshipAddress,
        address historyAddress
    ) {
        ssSetting = SystemSetting(systemSettingAddress);
        ssAuth = SystemAuth(systemAuthAddress);

        farmLand = FarmLand(farmLandAddress);
        relationship = Relationship(relationshipAddress);
        history = History(historyAddress);

        roundIndex = 0;
        queueFirstIndex = 0;
        queueLastIndex = 0;
    }

    //-----------------------------------------------------queue implementation begin----------------------------
    function _enqueue(SeedNodeData memory data) internal {
        queueSeed[queueLastIndex] = data;
    }

    //buy seeds and sow them to the ground, using coin as payment
    //with withPaymentAmount, such as usdt
    //with shared profit if available
    //with fomo reward if available
    function sowSeed(
        uint256 withPaymentAmount,
        uint256 withSharedProfit,
        uint256 withFomoReward
    ) external {
        _sowSeed(
            msg.sender,
            ssAuth.getRoot(),
            withPaymentAmount,
            withSharedProfit,
            withFomoReward
        );
    }

    //buy seeds and sow them to the ground, using coin as payment
    //with parent address
    //with withPaymentAmount
    //with shared profit if available
    //with fomo reward if available
    function sowSeedWithParent(
        address parent,
        uint256 withPaymentAmount,
        uint256 withSharedProfit,
        uint256 withFomoReward
    ) external {
        _sowSeed(
            msg.sender,
            parent,
            withPaymentAmount,
            withSharedProfit,
            withFomoReward
        );
    }

    function _sowSeed(
        address account,
        address parent,
        uint256 withPaymentAmount,
        uint256 withSharedProfit,
        uint256 withFomoReward
    ) internal {
        require(account != address(0), "ZERO address not allowed to buy seed");
        require(
            farmLand.haveLand(account),
            "You need to buy a land to active your farming"
        );
        require(
            !mapUserSeed[roundIndex][account].exists,
            "All your Seeds are not Mature yet"
        );

        _transferFomoReward(roundIndex);

        uint256 consumeAmount = 0;
        bool useSharedProfit = false;
        if (withSharedProfit > 0) {
            (
                bool resShared,
                uint256 sharedProfitTotal,
                uint256 sharedProfitClaimed
            ) = relationship.getSharedProfit(account);
            require(
                resShared &&
                    withSharedProfit <=
                    (sharedProfitTotal - sharedProfitClaimed),
                "Insufficient available shared profit to spend"
            );
            consumeAmount += withSharedProfit;
            useSharedProfit = true;
        }

        bool useFomoReward = false;
        if (withFomoReward > 0) {
            (
                bool available,
                uint256 availableFomoReward
            ) = _fomoRewardClaimable(account);
            require(
                available && withFomoReward <= availableFomoReward,
                "Insufficient available fomo reward to spend"
            );
            consumeAmount += withFomoReward;
            useFomoReward = true;
        }

        if (withPaymentAmount > 0) {
            require(
                ERC20(ssAuth.getPayment()).balanceOf(account) >=
                    withPaymentAmount,
                "insufficient payment balance"
            );
            require(
                ERC20(ssAuth.getPayment()).allowance(account, address(this)) >=
                    withPaymentAmount,
                "not allowed to spend payment amount"
            );
            consumeAmount += withPaymentAmount;
        }

        require(
            consumeAmount >= ssSetting.getMinAmountBuy(0),
            "too small amount to buy seed"
        );
        require(
            consumeAmount <= ssSetting.getMaxAmountBuy(0),
            "too much amount to buy seed"
        );

        //transfer payment to contract
        require(
            ERC20(ssAuth.getPayment()).transferFrom(
                account,
                address(this),
                withPaymentAmount
            ),
            "sow seed error while transfer payment ot contract"
        );

        if (parent == address(parent) && parent != address(0)) {
            relationship.makeRelationship(parent, account);
        } else {
            relationship.makeRelationship(ssAuth.getRoot(), account);
        }

        require(
            _distributeMony(
                account,
                consumeAmount,
                withSharedProfit,
                withFomoReward
            ),
            "Buy seed error 407"
        );

        if (useSharedProfit) {
            relationship.useSharedProfit(account, withSharedProfit);
        }

        if (useFomoReward) {
            FomoRewardClaimData storage frd = mapFomoRewardClaimed[account];
            frd.claimedAmount += withFomoReward;
        }

        emit seedBoughtEvent(account, consumeAmount, block.timestamp);
    }

    //distribute money
    function _distributeMony(
        address account,
        uint256 amount,
        uint256 withSharedProfit,
        uint256 withFomoReward
    ) internal returns (bool res) {
        if (_isRoundStop(roundIndex) || roundIndex == 0) {
            //reset round
            //create a new round and left the old round data as there was.
            ++queueLastIndex;
            queueFirstIndex = queueLastIndex;
            ++roundIndex;
            totalQueueAmount = 0;
            mapRound[roundIndex] = RoundData(
                amount,
                0,
                block.timestamp,
                block.timestamp,
                block.timestamp,
                queueFirstIndex,
                queueFirstIndex,
                queueLastIndex,
                true
            );
        } else {
            RoundData storage rd = mapRound[roundIndex];
            rd.inAmount += amount;
            rd.lastTime = block.timestamp;
            rd.lastIndex = ++queueLastIndex;
        }

        //share profit upstream
        uint256 sharedAmount = relationship.sharedProfit(account, amount);

        //deposit charity
        uint256 charity = (amount * ssSetting.getCharityPercent(0)) / 1000;
        charityAmount += charity;

        //deposit sysFund
        uint256 forSysFund = (amount * ssSetting.getSysFundPercent(0)) / 1000;
        sysFundAmount += forSysFund;
        //deposit fomoPool
        uint256 forFomoPool = (amount * ssSetting.getFomoPoolPercent(0)) / 1000;
        // fomoPoolAmount += forFomoPool;
        mapFomoPoolAmount[roundIndex] += forFomoPool;

        uint256 paddingAmount = amount -
            (sharedAmount + forSysFund + forFomoPool + charityAmount);

        while (true) {
            if (paddingAmount == 0) {
                break;
            }

            SeedNodeData memory firstSeedData = queueSeed[queueFirstIndex];
            if (!firstSeedData.exists) {
                break;
            }

            address firstNodeSeedAccount = firstSeedData.account;

            if (!mapUserSeed[roundIndex][firstNodeSeedAccount].exists) {
                break;
            }

            SeedUserData memory firstSeedUserData = mapUserSeed[roundIndex][
                firstNodeSeedAccount
            ];

            uint256 firstNodeSeedAmount = firstSeedUserData.totalAmount -
                firstSeedUserData.soldAmount;
            if (firstNodeSeedAmount == 0) {
                ++queueFirstIndex;
                continue;
            }

            uint256 userSellAmount = 0;
            if (paddingAmount >= firstNodeSeedAmount) {
                userSellAmount = firstNodeSeedAmount;
            } else {
                userSellAmount = paddingAmount;
            }
            bool sold = _sellUserSeed(firstNodeSeedAccount, userSellAmount);
            if (sold) {
                paddingAmount -= userSellAmount;
                totalQueueAmount -= userSellAmount;
                RoundData storage rd = mapRound[roundIndex];
                rd.outAmount += userSellAmount;
            } else {
                revert("Error while buying seed");
            }
        }

        uint256 newAmount = amount +
            (amount * ssSetting.getCycleYieldsPercent(0)) /
            1000;
        SeedNodeData memory newData = SeedNodeData(
            account,
            newAmount,
            withSharedProfit,
            withFomoReward,
            block.timestamp,
            ssSetting.getCurrentSettingIndex(),
            true
        );
        _enqueue(newData);
        mapUserSeed[roundIndex][account] = SeedUserData(
            roundIndex,
            queueLastIndex,
            newAmount,
            0,
            0,
            block.timestamp,
            ssSetting.getCurrentSettingIndex(),
            true
        );
        totalQueueAmount += newAmount;
        res = true;
    }

    function _sellUserSeed(address account, uint256 amount)
        internal
        returns (bool res)
    {
        require(mapUserSeed[roundIndex][account].exists, "You seed not exists");
        SeedUserData storage sud = mapUserSeed[roundIndex][account];
        require(sud.totalAmount >= sud.soldAmount + amount, "Seed sold out");
        sud.soldAmount += amount;
        if (sud.totalAmount <= sud.soldAmount) {
            ++queueFirstIndex;
            RoundData storage rd = mapRound[roundIndex];
            rd.currentIndex = queueFirstIndex;
            rd.currentTime = block.timestamp;
        }

        history.addMatureRecord(account, amount);

        emit seedSoldEvent(account, amount, block.timestamp);
        res = true;
    }

    function getSeedNodeData(uint32 index)
        external
        view
        returns (
            bool res,
            string memory account,
            uint256 amount,
            uint256 withSharedProfit,
            uint256 withFomoReward,
            uint256 buyTime,
            uint32 ssIndex
        )
    {
        if (index >= 1 && index <= queueLastIndex) {
            account = toHexString(queueSeed[index].account);
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
    function checkCollectable(uint256 roundNumber, address account)
        external
        view
        returns (bool res, uint256 amount)
    {
        (res, amount) = _checkCollectable(roundNumber, account);
    }

    function _checkCollectable(uint256 roundNumber, address account)
        internal
        view
        returns (bool res, uint256 amount)
    {
        if (
            mapUserSeed[roundNumber][account].exists &&
            mapUserSeed[roundNumber][account].soldAmount >
            mapUserSeed[roundNumber][account].claimedAmount
        ) {
            SeedUserData memory sud = mapUserSeed[roundNumber][account];
            if (block.timestamp >= sud.buyTime + ssSetting.getMatureTime(0)) {
                res = true;
                amount = sud.soldAmount - sud.claimedAmount;
            }
        }
    }

    //claim collectable seed
    //if you miss or just forget to claim your collectable seed, the money will be transfered to an account by system after a while(fixed set to 1 month)
    function claimSeed(uint256 roundNumber) external {
        require(
            msg.sender != address(0),
            "ZERO address not allowed to claim seed"
        );
        require(
            mapUserSeed[roundNumber][msg.sender].exists,
            "You seeds not exists"
        );
        SeedUserData storage sud = mapUserSeed[roundNumber][msg.sender];
        (bool collectable, uint256 amount) = _checkCollectable(
            roundNumber,
            msg.sender
        );
        require(collectable, "Seeds uncollectable");
        require(
            ERC20(ssAuth.getPayment()).balanceOf(address(this)) >= amount,
            "Insufficient balance of Coin"
        );

        bool transfered = ERC20(ssAuth.getPayment()).transfer(
            msg.sender,
            amount
        );
        require(transfered, "Failed to claim seed");
        sud.claimedAmount += amount;

        if (sud.claimedAmount >= sud.totalAmount) {
            delete mapUserSeed[roundNumber][msg.sender];
        }

        history.addClaimRecord(msg.sender, amount);

        emit seedClaimedEvent(msg.sender, amount);
    }

    //collect user's forgotten money of seed
    function collectForgottenSeed(
        address account,
        uint256 roundNumber,
        address to
    ) external {
        require(
            msg.sender == ssAuth.getOwner(),
            "Only owner can collect user's forgotten money to `to` address"
        );

        require(mapRound[roundNumber].exists, "Round not exists");
        require(
            mapUserSeed[roundNumber][account].exists,
            "user's forgotten money not available"
        );

        (bool avaible, uint256 amount) = _userForgottenSeedAvailable(
            account,
            roundNumber
        );
        require(avaible && amount > 0, "have not forgotten seed to collect");

        require(
            ERC20(ssAuth.getPayment()).balanceOf(address(this)) >= amount,
            "insufficient balance in contract"
        );
        bool transfered = ERC20(ssAuth.getPayment()).transfer(to, amount);
        require(transfered, "collect forgotten seed error");

        delete mapUserSeed[roundNumber][account];
    }

    function userForgottenSeedAvailable(address account, uint256 roundNumber)
        external
        view
        returns (bool res, uint256 amount)
    {
        (res, amount) = _userForgottenSeedAvailable(account, roundNumber);
    }

    function _userForgottenSeedAvailable(address account, uint256 roundNumber)
        internal
        view
        returns (bool res, uint256 amount)
    {
        if (
            mapRound[roundNumber].exists &&
            mapUserSeed[roundNumber][account].exists
        ) {
            if (
                mapUserSeed[roundNumber][account].buyTime <
                block.timestamp - ssSetting.getFixedTimeForgotten(0)
            ) {
                res = true;
                amount =
                    mapUserSeed[roundNumber][account].soldAmount -
                    mapUserSeed[roundNumber][account].claimedAmount;
            }
        }
    }

    //get amount of system fund
    function getSysFundAmount() external view returns (uint256 res) {
        res = sysFundAmount;
    }

    //get amount of fomo pool
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

    //withdraw system fund
    function withdrawSysFund(uint256 amount, address to) external {
        require(msg.sender == ssAuth.getOwner(), "!!!###");
        require(
            ERC20(ssAuth.getPayment()).balanceOf(address(this)) >= amount,
            "$$$%%%"
        );
        require(sysFundAmount >= amount, "&&&***");
        bool t = ERC20(ssAuth.getPayment()).transfer(to, amount);
        require(t, "Failed to withdraw system fund");
        sysFundAmount -= amount;
    }

    function withdrawCharity(uint256 amount, address to) external {
        require(msg.sender == ssAuth.getOwner(), "!!!###");
        require(
            ERC20(ssAuth.getPayment()).balanceOf(address(this)) >= amount,
            "$$$%%%"
        );
        require(charityAmount >= amount, "&&&***");
        bool t = ERC20(ssAuth.getPayment()).transfer(to, amount);
        require(t, "Failed to withdraw charity");
        charityAmount -= amount;
    }

    //check if the round is dead
    function isRoundStop(uint256 roundNumber) external view returns (bool res) {
        res = _isRoundStop(roundNumber);
    }

    function _isRoundStop(uint256 roundNumber)
        internal
        view
        returns (bool res)
    {
        if (mapRound[roundNumber].exists) {
            RoundData memory rd = mapRound[roundNumber];
            SeedNodeData memory last_snd = queueSeed[rd.lastIndex];
            (bool backlogRes, uint256 percent) = _getBacklog(roundNumber);
            if (
                block.timestamp >
                last_snd.buyTime + ssSetting.getResetCountDownTimeLength(0) &&
                backlogRes &&
                percent < ssSetting.getBacklogToCountdown(0)
            ) {
                res = true;
            }
        }
    }

    //calculate the backlog of keep long value
    //returns percent 0 ~ 1000
    function getBacklog(uint256 roundNumber)
        external
        view
        returns (bool res, uint256 percent)
    {
        (res, percent) = _getBacklog(roundNumber);
    }

    function _getBacklog(uint256 roundNumber)
        internal
        view
        returns (bool res, uint256 percent)
    {
        if (mapRound[roundNumber].exists) {
            RoundData memory rd = mapRound[roundNumber];
            uint256 nowTime = block.timestamp;
            uint256 amount24 = 0;
            for (uint32 i = rd.lastIndex; i >= rd.currentIndex; i--) {
                SeedNodeData memory snd = queueSeed[i];
                if (
                    snd.exists &&
                    snd.buyTime > nowTime - ssSetting.getBacklogTime(0)
                ) {
                    SeedUserData memory sud = mapUserSeed[roundNumber][snd.account];
                    if(sud.exists) {
                        amount24 += (sud.totalAmount-sud.soldAmount);
                    }
                    
                } else {
                    break;
                }
            }
            res = true;
            percent = (1000 * amount24) / totalQueueAmount;
        }
    }

    //fomo reward

    //transfer rewards from pool
    function _transferFomoReward(uint256 roundNumber) internal {
        if (_isRoundStop(roundIndex)) {
            (
                bool res1,
                address account1,
                ,
                uint256 amount1
            ) = _getLastInRewardAddress(roundNumber);
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
                ,
                uint256 amount2
            ) = _getMostInRewardAddress(roundNumber);
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
    }

    //check if an account is rewarded the fomo prize
    function checkFomoReward(address account, uint256 roundNumber)
        external
        view
        returns (
            bool isLastIn,
            bool isMostIn,
            uint256 amount
        )
    {
        (isLastIn, isMostIn, amount) = _checkFomoReward(account, roundNumber);
    }

    function _checkFomoReward(address account, uint256 roundNumber)
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
            if (_isRoundStop(roundNumber)) {
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

    //get claimable of fomo reward
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

    //get the account who got the last in rewards
    function getLastInRewardAddress(uint256 roundNumber)
        external
        view
        returns (
            bool res,
            string memory account,
            uint256 amount
        )
    {
        (res, , account, amount) = _getLastInRewardAddress(roundNumber);
    }

    function _getLastInRewardAddress(uint256 roundNumber)
        internal
        view
        returns (
            bool res,
            address accountAddr,
            string memory account,
            uint256 amount
        )
    {
        if (mapRound[roundNumber].exists) {
            if (_isRoundStop(roundNumber)) {
                RoundData memory rd = mapRound[roundNumber];
                res = true;
                accountAddr = queueSeed[rd.lastIndex].account;
                account = toHexString(accountAddr);
                amount = queueSeed[rd.lastIndex].amount * 10;
                if (amount > mapFomoPoolAmount[roundNumber] / 2) {
                    amount = mapFomoPoolAmount[roundNumber] / 2;
                }
            }
        }
    }

    //get the account who got the most in rewards, the first one in reverse travel
    function getMostInRewardAddress(uint256 roundNumber)
        external
        view
        returns (
            bool res,
            string memory account,
            uint256 amount
        )
    {
        (res, , account, amount) = _getMostInRewardAddress(roundNumber);
    }

    function _getMostInRewardAddress(uint256 roundNumber)
        internal
        view
        returns (
            bool res,
            address accountAddr,
            string memory account,
            uint256 amount
        )
    {
        if (mapRound[roundNumber].exists) {
            if (_isRoundStop(roundNumber)) {
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
                accountAddr = queueSeed[dstIndex].account;
                account = toHexString(accountAddr);
                amount = maxAmount;
            }
        }
    }

    //claim my reward
    //if you miss or just forget to claim your reward, the money will be transfered to an account by system after a while(fixed set to 1 month)
    function claimFomoReward(uint256 amount) external {
        require(address(0) != msg.sender, "ZERO address forbidden");
        require(
            msg.sender != ssAuth.getOwner(),
            "owner can not claim fomo rewards"
        );

        uint256 roundNumber = roundIndex > 0 ? roundIndex - 1 : 0;
        _transferFomoReward(roundNumber);

        require(
            mapFomoRewardClaimed[msg.sender].exists,
            "fomo rewards unavailable for you"
        );
        FomoRewardClaimData storage frd = mapFomoRewardClaimed[msg.sender];
        require(
            frd.totalAmount > frd.claimedAmount,
            "no fomo rewards for claiming"
        );
        require(
            amount > frd.totalAmount - frd.claimedAmount,
            "insufficient claimable amount to be claimed"
        );

        uint256 claimableAmount = frd.totalAmount - frd.claimedAmount;

        require(
            ERC20(ssAuth.getPayment()).balanceOf(address(this)) >=
                claimableAmount,
            "Insufficient balance in this contract for reward claiming"
        );
        bool transfered = ERC20(ssAuth.getPayment()).transfer(
            msg.sender,
            claimableAmount
        );
        require(transfered, "Claiming reward error");

        frd.claimedAmount += claimableAmount;

        emit fomoRewardClaimedEvent(msg.sender, claimableAmount);
    }

    //claim shared profit
    function claimSharedProfit(uint256 amount) external {
        require(msg.sender != ssAuth.getOwner(), "can not be owner");
        require(msg.sender != address(0), "can not be ZERO address");
        (bool res, uint256 totalAmount, uint256 claimedAmount) = relationship
            .getSharedProfit(msg.sender);
        require(res, "shared profit not exists");
        require(
            totalAmount >= amount + claimedAmount,
            "insufficient amount to be claimed"
        );
        require(
            ERC20(ssAuth.getPayment()).balanceOf(address(this)) >= amount,
            "Insufficient balance in contract"
        );
        bool transfered = ERC20(ssAuth.getPayment()).transfer(
            msg.sender,
            amount
        );
        require(transfered, "claim shared profit error");

        relationship.increaseClaimedSharedProfit(msg.sender, amount);

        emit sharedProfitClaimedEvent(msg.sender, amount);
    }

    //send forgotten reward to an account
    function sendFomoRewardByOwner(address account, address to) external {
        require(
            msg.sender == ssAuth.getOwner(),
            "Only owner can send rewards to an account"
        );

        uint256 roundNumber = roundIndex > 0 ? roundIndex - 1 : 0;
        _transferFomoReward(roundNumber);

        require(mapFomoRewardClaimed[account].exists, "reward not exists");
        FomoRewardClaimData storage frd = mapFomoRewardClaimed[account];

        if (
            frd.totalAmount > frd.claimedAmount &&
            mapRound[roundNumber].lastTime <
            block.timestamp -
                ssSetting.getFixedTimeForgotten(0) +
                ssSetting.getResetCountDownTimeLength(0)
        ) {
            uint256 claimable = frd.totalAmount - frd.claimedAmount;
            require(
                ERC20(ssAuth.getPayment()).balanceOf(address(this)) >=
                    claimable,
                "insufficient balance in contract"
            );
            bool transfered = ERC20(ssAuth.getPayment()).transfer(
                to,
                claimable
            );
            if (transfered) {
                frd.claimedAmount += claimable;
            }
        }
    }

    //get round data
    function getRoundData(uint256 roundNumber)
        external
        view
        returns (
            bool res,
            uint256 inAmount,
            uint256 outAmount,
            uint256 firstTime,
            uint256 currentTime,
            uint256 lastTime,
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
}