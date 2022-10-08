/**
 *Submitted for verification at BscScan.com on 2022-10-07
*/

// SPDX-License-Identifier: MIT                                                               
                                                              
pragma solidity ^0.8.17;

contract PoolMatrixGame {
    uint constant LEVELS_COUNT = 20;
    uint constant ROOT_WALLETS_COUNT = 4;
    uint constant SECONDS_IN_DAY = 24 * 3600;
    uint constant SECONDS_IN_DAY_HALF = 12 * 3600;

    uint[] levelIntervals = [
        0 hours,   // level 1-13:00 ; 0d*24 + 0h
        3 hours,   // level 2-16:00 ; 0d*24 + 3h
        6 hours,   // level 3-19:00 ; 0d*24 + 6h
        24 hours,  // level 4-13:00 ; 1d*24 + 0h
        27 hours,  // level 5-16:00 ; 1d*24 + 3h
        30 hours,  // level 6-19:00 ; 1d*24 + 6h
        48 hours,  // level 7-13:00 ; 2d*24 + 0h
        54 hours,  // level 8-19:00 ; 2d*24 + 6h
        72 hours,  // level 9-13:00 ; 3d*24 + 0h
        78 hours,  // level 10-19:00 ; 3d*24 + 6h
        101 hours, // level 11-18:00 ; 4d*24 + 5h
        125 hours, // level 12-18:00 ; 5d*24 + 5h
        149 hours, // level 13-18:00 ; 6d*24 + 5h
        173 hours, // level 14-18:00 ; 7d*24 + 5h
        197 hours, // level 15-18:00 ; 8d*24 + 5h
        221 hours, // level 16-18:00 ; 9d*24 + 5h
        245 hours, // level 17-18:00 ; 10d*24 + 5h
        269 hours, // level 18-18:00 ; 11d*24 + 5h
        293 hours, // level 19-18:00 ; 12d*24 + 5h
        317 hours  // level 20-18:00 ; 13d*24 + 5h
    ];

    //----------------------------------------------------------------------------------------------------------------------
    //  Config for testing
    //----------------------------------------------------------------------------------------------------------------------
    
    uint[] levelPrices = [
        0.001 * 1e18, //  1 POOL = 0.001 ETH 
        0.002 * 1e18, //  2 POOL = 0.002 ETH 
        0.003 * 1e18, //  3 POOL = 0.003 ETH 
        0.004 * 1e18, //  4 POOL = 0.004 ETH 
        0.005 * 1e18, //  5 POOL = 0.005 ETH 
        0.006 * 1e18, //  6 POOL = 0.006 ETH 
        0.007 * 1e18, //  7 POOL = 0.007 ETH 
        0.008 * 1e18, //  8 POOL = 0.008 ETH 
        0.009 * 1e18, //  9 POOL = 0.009 ETH 
        0.010 * 1e18, // 10 POOL = 0.010 ETH 
        0.011 * 1e18, // 11 POOL = 0.011 ETH 
        0.012 * 1e18, // 12 POOL = 0.012 ETH 
        0.013 * 1e18, // 13 POOL = 0.013 ETH 
        0.014 * 1e18, // 14 POOL = 0.014 ETH 
        0.015 * 1e18, // 15 POOL = 0.015 ETH 
        0.016 * 1e18, // 16 POOL = 0.016 ETH 
        0.017 * 1e18, // 17 POOL = 0.017 ETH 
        0.018 * 1e18, // 18 POOL = 0.018 ETH 
        0.019 * 1e18, // 19 POOL = 0.019 ETH 
        0.020 * 1e18  // 20 POOL = 0.020 ETH 
    ];

    uint constant REGISTRATION_PRICE = 0.001 * 1e18; // 0.001 ETH
    uint constant LEVEL_FEE_PERCENTS = 2; // 2% fee
    uint constant USER_REWARD_PERCENTS = 74; // 74% reward

    uint[] referrerPercents = [
        14, // 14% to 1st referrer
        7,  // 7% to 2nd referrer
        3   // 3% to 3rd refrrer
    ];
    //----------------------------------------------------------------------------------------------------------------------
    //  END OF: Config for testing
    //----------------------------------------------------------------------------------------------------------------------

    //----------------------------------------------------------------------------------------------------------------------
    //  Config for production
    //----------------------------------------------------------------------------------------------------------------------

    /*uint[] levelPrices = [
        0.05 * 1e18, //  1 POOL = 0.05 BNB
        0.07 * 1e18, //  2 POOL = 0.07 BNB
        0.10 * 1e18, //  3 POOL = 0.10 BNB
        0.13 * 1e18, //  4 POOL = 0.13 BNB
        0.16 * 1e18, //  5 POOL = 0.16 BNB
        0.25 * 1e18, //  6 POOL = 0.25 BNB
        0.30 * 1e18, //  7 POOL = 0.30 BNB
        0.35 * 1e18, //  8 POOL = 0.35 BNB
        0.40 * 1e18, //  9 POOL = 0.40 BNB
        0.45 * 1e18, // 10 POOL = 0.45 BNB
        0.75 * 1e18, // 11 POOL = 0.75 BNB
        0.90 * 1e18, // 12 POOL = 0.90 BNB
        1.05 * 1e18, // 13 POOL = 1.05 BNB
        1.20 * 1e18, // 14 POOL = 1.20 BNB
        1.35 * 1e18, // 15 POOL = 1.35 BNB
        2.00 * 1e18, // 16 POOL = 2.00 BNB
        2.50 * 1e18, // 17 POOL = 2.50 BNB
        3.00 * 1e18, // 18 POOL = 3.00 BNB
        3.50 * 1e18, // 19 POOL = 3.50 BNB
        4.00 * 1e18  // 20 POOL = 4.00 BNB
    ];

    uint constant REGISTRATION_PRICE = 0.05 * 1e18; // 0.05 BNB
    uint constant LEVEL_FEE_PERCENTS = 2; // 2% fee
    uint constant USER_REWARD_PERCENTS = 74; // 74% reward

    uint[] referrerPercents = [
        14, // 14% to 1st referrer
        7,  // 7% to 2nd referrer
        3   // 3% to 3rd refrrer
    ];*/
    //----------------------------------------------------------------------------------------------------------------------
    //  END OF: Config for production
    //----------------------------------------------------------------------------------------------------------------------

    struct User {
        uint id;
        address userAddr;
        address referrer;
        uint regDate;
        UserLevelInfo[] levels;
        uint maxLevel;
        uint debit;
        uint credit;
        uint referralReward;
        uint lastReferralReward;
        uint levelProfit;
        uint line1;
        uint line2;
        uint line3;
    }

    struct UserLevelInfo {
        uint openState; // 0 - closed, 1 - closed (opened once), 2 - opened
        uint payouts;
        uint partnerBonus;
        uint poolProfit;
        uint missedProfit;
    }

    address private adminWallet;
    address private regFeeWallet;
    address private marketingWallet;
    uint private initialDate;
    mapping (address => User) private users;
    address[] private userAddresses;
    uint private userCount;
    address private rootWallet1;
    address private rootWallet2;
    address private rootWallet3;
    address private rootWallet4;
    mapping(uint => address[]) private levelQueue;
    mapping(uint => uint) private headIndex;
    uint private marketingBalance;
    uint private transactionCounter;
    uint private turnoverAmount;
    uint private date24h1;
    uint private date24h2;
    uint32 private users24h1;
    uint32 private users24h2;
    uint32 private transactions24h1;
    uint32 private transactions24h2;
    uint private turnover24h1;
    uint private turnover24h2;
    uint private suspended;
    address public implementation;

    function appendAddress(address addr) public {
        userAddresses.push(addr);
        userCount++;
    }

    function getAddresses() public view returns(address[] memory) {
        return userAddresses;
    }

    function getCount() public view returns(uint) {
        return userCount;
    }

    function suspend(uint value) public {
        suspended = value;
    }

    function getSlots2(address userAddr) public view returns(uint[] memory slots, uint[] memory partnerBonuses, uint[] memory poolProfits, uint[] memory missedProfits, uint isSuspended) {
        uint[] memory slotList = new uint[](LEVELS_COUNT);
        uint[] memory partnerBonusList = new uint[](LEVELS_COUNT);
        uint[] memory poolProfitList = new uint[](LEVELS_COUNT);
        uint[] memory missedProfitList = new uint[](LEVELS_COUNT);
        for (uint level = 0; level < LEVELS_COUNT; level++) {
            if (block.timestamp < initialDate + levelIntervals[level]) {
                slotList[level] = 1010; // Not availabled yet (user need to wait some time once it bacome available)
                continue;
            }

			if (users[userAddr].levels[level].missedProfit > 0)
                missedProfitList[level] = users[userAddr].levels[level].missedProfit;

            if (level > users[userAddr].maxLevel) {
                slotList[level] = 1020; // Not allowed yet (previous level is not opened)
                continue;
            }

            partnerBonusList[level] = users[userAddr].levels[level].partnerBonus;
            poolProfitList[level] = users[userAddr].levels[level].poolProfit;

            if (users[userAddr].levels[level].openState != 2) {
                if (users[userAddr].levels[level].openState == 0)
                    slotList[level] = 1030; // Available for opening
                else
                    slotList[level] = 1040; // Available for reopening

                continue;
            }

            uint place = 0;
            for (uint i = headIndex[level]; i < levelQueue[level].length; i++) {
                place++;
                if (levelQueue[level][i] == userAddr) {
                    uint n = levelQueue[level].length - headIndex[level];
                    slotList[level] = (n - place + 1) * 1000 / n; // Slot is opened
                    break;
                }
            }
        }

        return (slotList, partnerBonusList, poolProfitList, missedProfitList, suspended);
    }

    function getSlots3(address userAddr) public view returns(uint[] memory slots, uint[] memory partnerBonuses, uint[] memory poolProfits, uint[] memory missedProfits, uint isSuspended) {
        uint[] memory slotList = new uint[](LEVELS_COUNT);
        uint[] memory partnerBonusList = new uint[](LEVELS_COUNT);
        uint[] memory poolProfitList = new uint[](LEVELS_COUNT);
        uint[] memory missedProfitList = new uint[](LEVELS_COUNT);
        for (uint level = 0; level < LEVELS_COUNT; level++) {
            if (block.timestamp < initialDate + levelIntervals[level]) {
                slotList[level] = 1010; // Not availabled yet (user need to wait some time once it bacome available)
                continue;
            }

			if (users[userAddr].levels[level].missedProfit > 0)
                missedProfitList[level] = users[userAddr].levels[level].missedProfit;

            if (level > users[userAddr].maxLevel) {
                slotList[level] = 1020; // Not allowed yet (previous level is not opened)
                continue;
            }

            partnerBonusList[level] = users[userAddr].levels[level].partnerBonus;
            poolProfitList[level] = users[userAddr].levels[level].poolProfit;

            if (users[userAddr].levels[level].openState != 2) {
                if (users[userAddr].levels[level].openState == 0)
                    slotList[level] = 1030; // Available for opening
                else
                    slotList[level] = 1040; // Available for reopening

                continue;
            }

            uint place = 0;
            for (uint i = headIndex[level]; i < levelQueue[level].length; i++) {
                place++;
                if (levelQueue[level][i] == userAddr) {
                    uint n = levelQueue[level].length - headIndex[level];
                    slotList[level] = (n - place + 1) * 1000 / n; // Slot is opened
                    break;
                }
            }
        }

        return (slotList, partnerBonusList, poolProfitList, missedProfitList, suspended);
    }

    function getSlots4(address userAddr) public view returns(uint[] memory slots, uint[] memory partnerBonuses, uint[] memory poolProfits, uint[] memory missedProfits, uint isSuspended) {
        uint[] memory slotList = new uint[](LEVELS_COUNT);
        uint[] memory partnerBonusList = new uint[](LEVELS_COUNT);
        uint[] memory poolProfitList = new uint[](LEVELS_COUNT);
        uint[] memory missedProfitList = new uint[](LEVELS_COUNT);
        for (uint level = 0; level < LEVELS_COUNT; level++) {
            if (block.timestamp < initialDate + levelIntervals[level]) {
                slotList[level] = 1010; // Not availabled yet (user need to wait some time once it bacome available)
                continue;
            }

			if (users[userAddr].levels[level].missedProfit > 0)
                missedProfitList[level] = users[userAddr].levels[level].missedProfit;

            if (level > users[userAddr].maxLevel) {
                slotList[level] = 1020; // Not allowed yet (previous level is not opened)
                continue;
            }

            partnerBonusList[level] = users[userAddr].levels[level].partnerBonus;
            poolProfitList[level] = users[userAddr].levels[level].poolProfit;

            if (users[userAddr].levels[level].openState != 2) {
                if (users[userAddr].levels[level].openState == 0)
                    slotList[level] = 1030; // Available for opening
                else
                    slotList[level] = 1040; // Available for reopening

                continue;
            }

            uint place = 0;
            for (uint i = headIndex[level]; i < levelQueue[level].length; i++) {
                place++;
                if (levelQueue[level][i] == userAddr) {
                    uint n = levelQueue[level].length - headIndex[level];
                    slotList[level] = (n - place + 1) * 1000 / n; // Slot is opened
                    break;
                }
            }
        }

        return (slotList, partnerBonusList, poolProfitList, missedProfitList, suspended);
    }

    function getSlots5(address userAddr) public view returns(uint[] memory slots, uint[] memory partnerBonuses, uint[] memory poolProfits, uint[] memory missedProfits, uint isSuspended) {
        uint[] memory slotList = new uint[](LEVELS_COUNT);
        uint[] memory partnerBonusList = new uint[](LEVELS_COUNT);
        uint[] memory poolProfitList = new uint[](LEVELS_COUNT);
        uint[] memory missedProfitList = new uint[](LEVELS_COUNT);
        for (uint level = 0; level < LEVELS_COUNT; level++) {
            if (block.timestamp < initialDate + levelIntervals[level]) {
                slotList[level] = 1010; // Not availabled yet (user need to wait some time once it bacome available)
                continue;
            }

			if (users[userAddr].levels[level].missedProfit > 0)
                missedProfitList[level] = users[userAddr].levels[level].missedProfit;

            if (level > users[userAddr].maxLevel) {
                slotList[level] = 1020; // Not allowed yet (previous level is not opened)
                continue;
            }

            partnerBonusList[level] = users[userAddr].levels[level].partnerBonus;
            poolProfitList[level] = users[userAddr].levels[level].poolProfit;

            if (users[userAddr].levels[level].openState != 2) {
                if (users[userAddr].levels[level].openState == 0)
                    slotList[level] = 1030; // Available for opening
                else
                    slotList[level] = 1040; // Available for reopening

                continue;
            }

            uint place = 0;
            for (uint i = headIndex[level]; i < levelQueue[level].length; i++) {
                place++;
                if (levelQueue[level][i] == userAddr) {
                    uint n = levelQueue[level].length - headIndex[level];
                    slotList[level] = (n - place + 1) * 1000 / n; // Slot is opened
                    break;
                }
            }
        }

        return (slotList, partnerBonusList, poolProfitList, missedProfitList, suspended);
    }

    function getSlots6(address userAddr) public view returns(uint[] memory slots, uint[] memory partnerBonuses, uint[] memory poolProfits, uint[] memory missedProfits, uint isSuspended) {
        uint[] memory slotList = new uint[](LEVELS_COUNT);
        uint[] memory partnerBonusList = new uint[](LEVELS_COUNT);
        uint[] memory poolProfitList = new uint[](LEVELS_COUNT);
        uint[] memory missedProfitList = new uint[](LEVELS_COUNT);
        for (uint level = 0; level < LEVELS_COUNT; level++) {
            if (block.timestamp < initialDate + levelIntervals[level]) {
                slotList[level] = 1010; // Not availabled yet (user need to wait some time once it bacome available)
                continue;
            }

			if (users[userAddr].levels[level].missedProfit > 0)
                missedProfitList[level] = users[userAddr].levels[level].missedProfit;

            if (level > users[userAddr].maxLevel) {
                slotList[level] = 1020; // Not allowed yet (previous level is not opened)
                continue;
            }

            partnerBonusList[level] = users[userAddr].levels[level].partnerBonus;
            poolProfitList[level] = users[userAddr].levels[level].poolProfit;

            if (users[userAddr].levels[level].openState != 2) {
                if (users[userAddr].levels[level].openState == 0)
                    slotList[level] = 1030; // Available for opening
                else
                    slotList[level] = 1040; // Available for reopening

                continue;
            }

            uint place = 0;
            for (uint i = headIndex[level]; i < levelQueue[level].length; i++) {
                place++;
                if (levelQueue[level][i] == userAddr) {
                    uint n = levelQueue[level].length - headIndex[level];
                    slotList[level] = (n - place + 1) * 1000 / n; // Slot is opened
                    break;
                }
            }
        }

        return (slotList, partnerBonusList, poolProfitList, missedProfitList, suspended);
    }

    function getSlots7(address userAddr) public view returns(uint[] memory slots, uint[] memory partnerBonuses, uint[] memory poolProfits, uint[] memory missedProfits, uint isSuspended) {
        uint[] memory slotList = new uint[](LEVELS_COUNT);
        uint[] memory partnerBonusList = new uint[](LEVELS_COUNT);
        uint[] memory poolProfitList = new uint[](LEVELS_COUNT);
        uint[] memory missedProfitList = new uint[](LEVELS_COUNT);
        for (uint level = 0; level < LEVELS_COUNT; level++) {
            if (block.timestamp < initialDate + levelIntervals[level]) {
                slotList[level] = 1010; // Not availabled yet (user need to wait some time once it bacome available)
                continue;
            }

			if (users[userAddr].levels[level].missedProfit > 0)
                missedProfitList[level] = users[userAddr].levels[level].missedProfit;

            if (level > users[userAddr].maxLevel) {
                slotList[level] = 1020; // Not allowed yet (previous level is not opened)
                continue;
            }

            partnerBonusList[level] = users[userAddr].levels[level].partnerBonus;
            poolProfitList[level] = users[userAddr].levels[level].poolProfit;

            if (users[userAddr].levels[level].openState != 2) {
                if (users[userAddr].levels[level].openState == 0)
                    slotList[level] = 1030; // Available for opening
                else
                    slotList[level] = 1040; // Available for reopening

                continue;
            }

            uint place = 0;
            for (uint i = headIndex[level]; i < levelQueue[level].length; i++) {
                place++;
                if (levelQueue[level][i] == userAddr) {
                    uint n = levelQueue[level].length - headIndex[level];
                    slotList[level] = (n - place + 1) * 1000 / n; // Slot is opened
                    break;
                }
            }
        }

        return (slotList, partnerBonusList, poolProfitList, missedProfitList, suspended);
    }

    function getSlots8(address userAddr) public view returns(uint[] memory slots, uint[] memory partnerBonuses, uint[] memory poolProfits, uint[] memory missedProfits, uint isSuspended) {
        uint[] memory slotList = new uint[](LEVELS_COUNT);
        uint[] memory partnerBonusList = new uint[](LEVELS_COUNT);
        uint[] memory poolProfitList = new uint[](LEVELS_COUNT);
        uint[] memory missedProfitList = new uint[](LEVELS_COUNT);
        for (uint level = 0; level < LEVELS_COUNT; level++) {
            if (block.timestamp < initialDate + levelIntervals[level]) {
                slotList[level] = 1010; // Not availabled yet (user need to wait some time once it bacome available)
                continue;
            }

			if (users[userAddr].levels[level].missedProfit > 0)
                missedProfitList[level] = users[userAddr].levels[level].missedProfit;

            if (level > users[userAddr].maxLevel) {
                slotList[level] = 1020; // Not allowed yet (previous level is not opened)
                continue;
            }

            partnerBonusList[level] = users[userAddr].levels[level].partnerBonus;
            poolProfitList[level] = users[userAddr].levels[level].poolProfit;

            if (users[userAddr].levels[level].openState != 2) {
                if (users[userAddr].levels[level].openState == 0)
                    slotList[level] = 1030; // Available for opening
                else
                    slotList[level] = 1040; // Available for reopening

                continue;
            }

            uint place = 0;
            for (uint i = headIndex[level]; i < levelQueue[level].length; i++) {
                place++;
                if (levelQueue[level][i] == userAddr) {
                    uint n = levelQueue[level].length - headIndex[level];
                    slotList[level] = (n - place + 1) * 1000 / n; // Slot is opened
                    break;
                }
            }
        }

        return (slotList, partnerBonusList, poolProfitList, missedProfitList, suspended);
    }

    function getSlots9(address userAddr) public view returns(uint[] memory slots, uint[] memory partnerBonuses, uint[] memory poolProfits, uint[] memory missedProfits, uint isSuspended) {
        uint[] memory slotList = new uint[](LEVELS_COUNT);
        uint[] memory partnerBonusList = new uint[](LEVELS_COUNT);
        uint[] memory poolProfitList = new uint[](LEVELS_COUNT);
        uint[] memory missedProfitList = new uint[](LEVELS_COUNT);
        for (uint level = 0; level < LEVELS_COUNT; level++) {
            if (block.timestamp < initialDate + levelIntervals[level]) {
                slotList[level] = 1010; // Not availabled yet (user need to wait some time once it bacome available)
                continue;
            }

			if (users[userAddr].levels[level].missedProfit > 0)
                missedProfitList[level] = users[userAddr].levels[level].missedProfit;

            if (level > users[userAddr].maxLevel) {
                slotList[level] = 1020; // Not allowed yet (previous level is not opened)
                continue;
            }

            partnerBonusList[level] = users[userAddr].levels[level].partnerBonus;
            poolProfitList[level] = users[userAddr].levels[level].poolProfit;

            if (users[userAddr].levels[level].openState != 2) {
                if (users[userAddr].levels[level].openState == 0)
                    slotList[level] = 1030; // Available for opening
                else
                    slotList[level] = 1040; // Available for reopening

                continue;
            }

            uint place = 0;
            for (uint i = headIndex[level]; i < levelQueue[level].length; i++) {
                place++;
                if (levelQueue[level][i] == userAddr) {
                    uint n = levelQueue[level].length - headIndex[level];
                    slotList[level] = (n - place + 1) * 1000 / n; // Slot is opened
                    break;
                }
            }
        }

        return (slotList, partnerBonusList, poolProfitList, missedProfitList, suspended);
    }

    function getSlots10(address userAddr) public view returns(uint[] memory slots, uint[] memory partnerBonuses, uint[] memory poolProfits, uint[] memory missedProfits, uint isSuspended) {
        uint[] memory slotList = new uint[](LEVELS_COUNT);
        uint[] memory partnerBonusList = new uint[](LEVELS_COUNT);
        uint[] memory poolProfitList = new uint[](LEVELS_COUNT);
        uint[] memory missedProfitList = new uint[](LEVELS_COUNT);
        for (uint level = 0; level < LEVELS_COUNT; level++) {
            if (block.timestamp < initialDate + levelIntervals[level]) {
                slotList[level] = 1010; // Not availabled yet (user need to wait some time once it bacome available)
                continue;
            }

			if (users[userAddr].levels[level].missedProfit > 0)
                missedProfitList[level] = users[userAddr].levels[level].missedProfit;

            if (level > users[userAddr].maxLevel) {
                slotList[level] = 1020; // Not allowed yet (previous level is not opened)
                continue;
            }

            partnerBonusList[level] = users[userAddr].levels[level].partnerBonus;
            poolProfitList[level] = users[userAddr].levels[level].poolProfit;

            if (users[userAddr].levels[level].openState != 2) {
                if (users[userAddr].levels[level].openState == 0)
                    slotList[level] = 1030; // Available for opening
                else
                    slotList[level] = 1040; // Available for reopening

                continue;
            }

            uint place = 0;
            for (uint i = headIndex[level]; i < levelQueue[level].length; i++) {
                place++;
                if (levelQueue[level][i] == userAddr) {
                    uint n = levelQueue[level].length - headIndex[level];
                    slotList[level] = (n - place + 1) * 1000 / n; // Slot is opened
                    break;
                }
            }
        }

        return (slotList, partnerBonusList, poolProfitList, missedProfitList, suspended);
    }

    function getSlots11(address userAddr) public view returns(uint[] memory slots, uint[] memory partnerBonuses, uint[] memory poolProfits, uint[] memory missedProfits, uint isSuspended) {
        uint[] memory slotList = new uint[](LEVELS_COUNT);
        uint[] memory partnerBonusList = new uint[](LEVELS_COUNT);
        uint[] memory poolProfitList = new uint[](LEVELS_COUNT);
        uint[] memory missedProfitList = new uint[](LEVELS_COUNT);
        for (uint level = 0; level < LEVELS_COUNT; level++) {
            if (block.timestamp < initialDate + levelIntervals[level]) {
                slotList[level] = 1010; // Not availabled yet (user need to wait some time once it bacome available)
                continue;
            }

			if (users[userAddr].levels[level].missedProfit > 0)
                missedProfitList[level] = users[userAddr].levels[level].missedProfit;

            if (level > users[userAddr].maxLevel) {
                slotList[level] = 1020; // Not allowed yet (previous level is not opened)
                continue;
            }

            partnerBonusList[level] = users[userAddr].levels[level].partnerBonus;
            poolProfitList[level] = users[userAddr].levels[level].poolProfit;

            if (users[userAddr].levels[level].openState != 2) {
                if (users[userAddr].levels[level].openState == 0)
                    slotList[level] = 1030; // Available for opening
                else
                    slotList[level] = 1040; // Available for reopening

                continue;
            }

            uint place = 0;
            for (uint i = headIndex[level]; i < levelQueue[level].length; i++) {
                place++;
                if (levelQueue[level][i] == userAddr) {
                    uint n = levelQueue[level].length - headIndex[level];
                    slotList[level] = (n - place + 1) * 1000 / n; // Slot is opened
                    break;
                }
            }
        }

        return (slotList, partnerBonusList, poolProfitList, missedProfitList, suspended);
    }

    function getSlots12(address userAddr) public view returns(uint[] memory slots, uint[] memory partnerBonuses, uint[] memory poolProfits, uint[] memory missedProfits, uint isSuspended) {
        uint[] memory slotList = new uint[](LEVELS_COUNT);
        uint[] memory partnerBonusList = new uint[](LEVELS_COUNT);
        uint[] memory poolProfitList = new uint[](LEVELS_COUNT);
        uint[] memory missedProfitList = new uint[](LEVELS_COUNT);
        for (uint level = 0; level < LEVELS_COUNT; level++) {
            if (block.timestamp < initialDate + levelIntervals[level]) {
                slotList[level] = 1010; // Not availabled yet (user need to wait some time once it bacome available)
                continue;
            }

			if (users[userAddr].levels[level].missedProfit > 0)
                missedProfitList[level] = users[userAddr].levels[level].missedProfit;

            if (level > users[userAddr].maxLevel) {
                slotList[level] = 1020; // Not allowed yet (previous level is not opened)
                continue;
            }

            partnerBonusList[level] = users[userAddr].levels[level].partnerBonus;
            poolProfitList[level] = users[userAddr].levels[level].poolProfit;

            if (users[userAddr].levels[level].openState != 2) {
                if (users[userAddr].levels[level].openState == 0)
                    slotList[level] = 1030; // Available for opening
                else
                    slotList[level] = 1040; // Available for reopening

                continue;
            }

            uint place = 0;
            for (uint i = headIndex[level]; i < levelQueue[level].length; i++) {
                place++;
                if (levelQueue[level][i] == userAddr) {
                    uint n = levelQueue[level].length - headIndex[level];
                    slotList[level] = (n - place + 1) * 1000 / n; // Slot is opened
                    break;
                }
            }
        }

        return (slotList, partnerBonusList, poolProfitList, missedProfitList, suspended);
    }

    function getSlots13(address userAddr) public view returns(uint[] memory slots, uint[] memory partnerBonuses, uint[] memory poolProfits, uint[] memory missedProfits, uint isSuspended) {
        uint[] memory slotList = new uint[](LEVELS_COUNT);
        uint[] memory partnerBonusList = new uint[](LEVELS_COUNT);
        uint[] memory poolProfitList = new uint[](LEVELS_COUNT);
        uint[] memory missedProfitList = new uint[](LEVELS_COUNT);
        for (uint level = 0; level < LEVELS_COUNT; level++) {
            if (block.timestamp < initialDate + levelIntervals[level]) {
                slotList[level] = 1010; // Not availabled yet (user need to wait some time once it bacome available)
                continue;
            }

			if (users[userAddr].levels[level].missedProfit > 0)
                missedProfitList[level] = users[userAddr].levels[level].missedProfit;

            if (level > users[userAddr].maxLevel) {
                slotList[level] = 1020; // Not allowed yet (previous level is not opened)
                continue;
            }

            partnerBonusList[level] = users[userAddr].levels[level].partnerBonus;
            poolProfitList[level] = users[userAddr].levels[level].poolProfit;

            if (users[userAddr].levels[level].openState != 2) {
                if (users[userAddr].levels[level].openState == 0)
                    slotList[level] = 1030; // Available for opening
                else
                    slotList[level] = 1040; // Available for reopening

                continue;
            }

            uint place = 0;
            for (uint i = headIndex[level]; i < levelQueue[level].length; i++) {
                place++;
                if (levelQueue[level][i] == userAddr) {
                    uint n = levelQueue[level].length - headIndex[level];
                    slotList[level] = (n - place + 1) * 1000 / n; // Slot is opened
                    break;
                }
            }
        }

        return (slotList, partnerBonusList, poolProfitList, missedProfitList, suspended);
    }

    
}