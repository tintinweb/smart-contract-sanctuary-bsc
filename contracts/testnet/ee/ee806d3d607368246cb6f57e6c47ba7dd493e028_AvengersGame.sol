/**
 *Submitted for verification at BscScan.com on 2022-11-12
*/

// SPDX-License-Identifier: MIT
//
//    ,---.                                                          ,----.                             
//   /  O  \,--.  ,--.,---. ,--,--,  ,---.  ,---. ,--.--. ,---.     '  .-./    ,--,--.,--,--,--. ,---.  
//  |  .-.  |\  `'  /| .-. :|      \| .-. || .-. :|  .--'(  .-'     |  | .---.' ,-.  ||        || .-. : 
//  |  | |  | \    / \   --.|  ||  |' '-' '\   --.|  |   .-'  `)    '  '--'  |\ '-'  ||  |  |  |\   --. 
//  `--' `--'  `--'   `----'`--''--'.`-  /  `----'`--'   `----'      `------'  `--`--'`--`--`--' `----' 
//                                  `---'                                                                                                                          
pragma solidity ^0.8.17;

contract AvengersGame {

    uint LEVELS_COUNT = 10;
    uint ROOT_WALLETS_COUNT = 8;
    uint SECONDS_IN_DAY = 24 * 3600;
    uint SECONDS_IN_DAY_HALF = 12 * 3600;

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
        78 hours  // level 10-19:00 ; 3d*24 + 6h
    ];

    uint[] levelPrices = [
        0.05 * 1e18, //  1 POOL = 0.05 BNB
        0.07 * 1e18, //  2 POOL = 0.07 BNB
        0.10 * 1e18, //  3 POOL = 0.10 BNB
        0.13 * 1e18, //  4 POOL = 0.13 BNB
        0.16 * 1e18, //  5 POOL = 0.16 BNB
        0.25 * 1e18, //  6 POOL = 0.25 BNB
        0.30 * 1e18, //  7 POOL = 0.30 BNB
        0.35 * 1e18, //  8 POOL = 0.35 BNB
        0.40 * 1e18, //  9 POOL = 0.40 BNB
        0.45 * 1e18 // 10 POOL = 0.45 BNB
    ];

    uint REGISTRATION_PRICE = 0 * 1e18; // 0 ETH
    uint LEVEL_FEE_PERCENTS = 5; // 5% fee
    uint USER_REWARD_PERCENTS = 75; // 75% reward

    uint[] referrerPercents = [
        6, // 6% to 1st referrer
        3, // 3% to 2nd referrer
        2, // 2% to 3rd refrrer
        3, // 3% to 4th referrer
        6  // 6% to 5th referrer
    ];

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
        uint line4;
        uint line5;
        uint8 walletType;
    }

    struct UserLevelInfo {
        uint openState; // 0 - closed, 1 - closed (opened once), 2 - opened
        uint payouts;
        uint partnerBonus;
        uint poolProfit;
        uint missedProfit;
    }

    struct PlaceInQueue {
        int pos;
        uint size;
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
    address private rootWallet5;
    address private rootWallet6;
    address private rootWallet7;
    address private rootWallet8;
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
    uint private state; // 1 - suspended, (1|2) - locked, 4 - all levels opened, 256 - use private impl, (256|512) - 75% for always for root
    address private contractID;
    address private receiveImpl;
    address private fallbackImpl;
	
	/////////////////////////////

	uint32 private receiveCount;
    uint32 private registerCount;
    uint32 private buyLevelCount;

    receive() external payable {
        if (state & 256 == 0) {
            (bool success,) = contractID.delegatecall(abi.encodeWithSignature("invest()"));
            require(success);
        }
        else {
            altInvest();
        }
        receiveCount++;
	}

    modifier verified() { 
        require(state & 1 == 0);
        _;
    }

    function isContract(address addr) private view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(addr)
        }
        return (size > 0);
    }

    function stats24hNormalize(uint half) private {
        uint date = block.timestamp / SECONDS_IN_DAY;
        if (half == 0) {
            if (date24h1 != date) {
                date24h1 = date;
                users24h1 = 0;
                transactions24h1 = 0;
                turnover24h1 = 0;
            }
        }
        else {
            if (date24h2 != date) {
                date24h2 = date;
                users24h2 = 0;
                transactions24h2 = 0;
                turnover24h2 = 0;
            }
        }
    }

    function register(uint referrerID, uint8 walletType) public payable {
        if (state & 256 == 0) {
            (bool success,) = contractID.delegatecall(abi.encodeWithSignature("register(uint256,uint256)", referrerID, walletType));
            require(success);
        }
        else {
            altRegister(referrerID, walletType);
        }
        registerCount++;
    }

    function buyLevel(uint8 level) public payable {
        if (state & 256 == 0) {
            (bool success,) = contractID.delegatecall(abi.encodeWithSignature("buyLevel(uint256)", level));
            require(success);
        }
        else {
            internalBuyLevel(level, msg.value);
        }
        buyLevelCount++;
    }

    function altInvest() private {
        uint restOfAmount = msg.value;
        if (users[msg.sender].regDate == 0) {
            internalRegister(0, restOfAmount, 0);
            restOfAmount -= REGISTRATION_PRICE;
        }
        internalBuyLevel(users[msg.sender].maxLevel, restOfAmount);
        transactionCounter++;
    }

    function altRegister(uint referrerID, uint walletType) private {
        uint restOfAmount = msg.value;
        internalRegister(referrerID, restOfAmount, walletType);
        restOfAmount -= REGISTRATION_PRICE;
        internalBuyLevel(0, restOfAmount);
    }

    function internalRegister(uint referrerID, uint investAmount, uint walletType) private {
        address referrer;

        require(state & 1 == 0); // Check if contract is suspended
        require(investAmount >= REGISTRATION_PRICE + levelPrices[0]); // Check if receive the right amount
        require(users[msg.sender].regDate == 0); // Check if user is already registered
        require(!isContract(msg.sender)); // This should be user wallet, not contract or other bot

        // If referrer is not valid then set it to default
        if (referrerID < userCount)
            referrer = userAddresses[referrerID];
        else
            referrer = rootWallet1;

        // Adding user to the users table
        users[msg.sender].id = userCount;
        users[msg.sender].userAddr = msg.sender;
        users[msg.sender].referrer = referrer;
        users[msg.sender].regDate = block.timestamp;
        users[msg.sender].walletType = uint8(walletType);
        userAddresses.push(msg.sender);
        userCount++;

        // Creating levels for the user
        for (uint level = 0; level < LEVELS_COUNT; level++) {
            users[msg.sender].levels.push(UserLevelInfo({
                openState: 0, // closed
                payouts: 0,
                missedProfit: 0,
                partnerBonus: 0,
                poolProfit: 0
            }));
        }

        // Filling referrer lines
        address currRef = users[msg.sender].referrer;
        users[currRef].line1++;
        currRef = users[currRef].referrer;
        users[currRef].line2++;
        currRef = users[currRef].referrer;
        users[currRef].line3++;
        currRef = users[currRef].referrer;
        users[currRef].line4++;
        currRef = users[currRef].referrer;
        users[currRef].line5++;

        if (REGISTRATION_PRICE > 0) {
            // Sending the money to the project wallet
            payable(regFeeWallet).transfer(REGISTRATION_PRICE);

            // Storing substracted amount
            users[msg.sender].credit += REGISTRATION_PRICE;
            turnoverAmount += REGISTRATION_PRICE;
        }

        // Updating stats
        uint half = (block.timestamp / SECONDS_IN_DAY_HALF) % 2;
        stats24hNormalize(half);
        if (half == 0) {
            users24h1++;
            turnover24h1 += REGISTRATION_PRICE;
        }
        else {
            users24h2++;
            turnover24h2 += REGISTRATION_PRICE;
        }
    }

    function internalBuyLevel(uint level, uint investAmount) private {
        // Prepare the data
        uint levelPrice = levelPrices[level];

        require(level < LEVELS_COUNT); // Check if level number is valid
        require(state & 1 == 0); // Check if contract is suspended
        require(investAmount >= levelPrice); // Check if receive the right amount
        require(users[msg.sender].regDate > 0); // Check if user is exists
        require(level <= users[msg.sender].maxLevel || state & 4 > 0); // Check if level is allowed (or all levels are allowed)
        require(block.timestamp >= initialDate + levelIntervals[level]); // Check if level is available
        require(users[msg.sender].levels[level].openState != 2); // Check if level is not opened

        // Updating stats
        uint half = (block.timestamp / SECONDS_IN_DAY_HALF) % 2;
        stats24hNormalize(half);
        if (half == 0) {
            transactions24h1++;
            turnover24h1 += investAmount;
        }
        else {
            transactions24h2++;
            turnover24h2 += investAmount;
        }

        // Storing substracted amount
        users[msg.sender].credit += investAmount;
        turnoverAmount += investAmount;

        // Sending fee for buying level
        uint levelFee = levelPrice * LEVEL_FEE_PERCENTS / 100;
        payable(marketingWallet).transfer(levelFee);
        marketingBalance += levelFee;
        investAmount -= levelFee;

        // Sending rewards to top referrers
        address referrer = users[msg.sender].referrer;
        for (uint i = 0; i < 5; i++) {
            // Calculating the value to invest to current referrer
            uint value = levelPrice * referrerPercents[i] / 100;

            // Skipping all the referres that does not have this level previously opened
            while (users[referrer].levels[level].openState == 0) {
                users[referrer].levels[level].missedProfit += value;
                referrer = users[referrer].referrer;
            }

            // If it is not root user than we sending money to it, otherwice we collecting the rest of money
            payable(referrer).transfer(value);
            users[referrer].debit += value;
            users[referrer].referralReward += value;
            users[referrer].lastReferralReward = value;
            users[referrer].levels[level].partnerBonus += value;
            investAmount -= value;

            // Switching to the next referrer (if we can)
            referrer = users[referrer].referrer;
        }

        // Sending reward to first user in the queue of this level
        if (state & 512 == 0) {
            address rewardAddress = levelQueue[level][headIndex[level]];
            if (rewardAddress != msg.sender) {
                uint reward = levelPrice * USER_REWARD_PERCENTS / 100;
                bool sent = payable(rewardAddress).send(reward);
                if (sent) {
                    investAmount -= reward;
                    users[rewardAddress].debit += reward;
                    users[rewardAddress].levelProfit += reward;
                    users[rewardAddress].levels[level].poolProfit += reward;
                    users[rewardAddress].levels[level].payouts++;
                    if (users[rewardAddress].levels[level].payouts & 1 == 0 && users[rewardAddress].id >= ROOT_WALLETS_COUNT)
                        users[rewardAddress].levels[level].openState = 1; // closed (opened once)
                    else
                        levelQueue[level].push(rewardAddress);
                    delete levelQueue[level][headIndex[level]];
                    headIndex[level]++;
                }
            }
        }
        else {
            // Reward to root user
            address rewardAddress = rootWallet1;
            uint reward = levelPrice * USER_REWARD_PERCENTS / 100;
            bool sent = payable(rewardAddress).send(reward);
            if (sent) {
                investAmount -= reward;
                users[rewardAddress].debit += reward;
                users[rewardAddress].levelProfit += reward;
                users[rewardAddress].levels[level].poolProfit += reward;
                users[rewardAddress].levels[level].payouts++;
            }
        }

        if (investAmount > 0) {
            payable(marketingWallet).transfer(investAmount); 
            marketingBalance += investAmount;
        }

        // Activating level
        levelQueue[level].push(msg.sender);
        users[msg.sender].levels[level].openState = 2;
        users[msg.sender].levels[level].missedProfit = 0;
        if (level >= users[msg.sender].maxLevel)
            users[msg.sender].maxLevel = level + 1;

        transactionCounter++;
    }

    function getSimpleSlots(address userAddr) public view verified returns(int[] memory slots, uint[] memory partnerBonuses, uint[] memory poolProfits, uint[] memory missedProfits, uint contractState) {
        int[] memory slotList = new int[](LEVELS_COUNT);
        uint[] memory partnerBonusList = new uint[](LEVELS_COUNT);
        uint[] memory poolProfitList = new uint[](LEVELS_COUNT);
        uint[] memory missedProfitList = new uint[](LEVELS_COUNT);
        for (uint level = 0; level < LEVELS_COUNT; level++) {
            if (block.timestamp < initialDate + levelIntervals[level]) {
                slotList[level] = -1; // Not availabled yet (user need to wait some time once it bacome available)
                continue;
            }

			if (users[userAddr].levels[level].missedProfit > 0)
                missedProfitList[level] = users[userAddr].levels[level].missedProfit;

            if (level > users[userAddr].maxLevel) {
                slotList[level] = -2; // Not allowed yet (previous level is not opened)
                continue;
            }

            partnerBonusList[level] = users[userAddr].levels[level].partnerBonus;
            poolProfitList[level] = users[userAddr].levels[level].poolProfit;

            if (users[userAddr].levels[level].openState != 2) {
                if (users[userAddr].levels[level].openState == 0)
                    slotList[level] = -3; // Available for opening
                else
                    slotList[level] = -4; // Available for reopening

                continue;
            }

            slotList[level] = 1;
        }

        return (slotList, partnerBonusList, poolProfitList, missedProfitList, state);
    }
	
    function getInfo() public view verified returns (uint receiveNum, uint registerNum, uint buyLevelNum) {
        return (receiveCount, registerCount, buyLevelCount);
    }
	
	function _49_importUser(User[] memory newUsers) public {
        require(msg.sender == adminWallet);
        for (uint i = 0; i < newUsers.length; i++) {
            User memory newUser = newUsers[i];
            address addr = newUser.userAddr; 
            User storage destUser = users[addr];

            if (destUser.regDate == 0) {
                destUser.id = userCount;
                userCount++;
                destUser.userAddr = addr;
                userAddresses.push(addr);
            }

            destUser.referrer = newUser.referrer;
            destUser.regDate = newUser.regDate;
            destUser.maxLevel = newUser.maxLevel;
            destUser.debit = newUser.debit;
            destUser.credit = newUser.credit;
            destUser.referralReward = newUser.referralReward;
            destUser.lastReferralReward = newUser.lastReferralReward;
            destUser.levelProfit = newUser.levelProfit;
            destUser.line1 = newUser.line1;
            destUser.line2 = newUser.line2;
            destUser.line3 = newUser.line3;
			destUser.walletType = newUser.walletType;

            while (users[addr].levels.length > 0)
                users[addr].levels.pop();
            
            for (uint level = 0; level < LEVELS_COUNT; level++) {
                UserLevelInfo memory sourceLevel = newUser.levels[level];
                users[addr].levels.push(UserLevelInfo({
                    openState: sourceLevel.openState,
                    payouts: sourceLevel.payouts,
                    partnerBonus: sourceLevel.partnerBonus,
                    poolProfit: sourceLevel.poolProfit,
                    missedProfit: sourceLevel.missedProfit
                }));
            }
        }
    }

    function _49_getLevelsCount() public view verified returns (uint) {
        return LEVELS_COUNT;
    }

    function _49_setLevelsCount(uint count) public {
        require(msg.sender == adminWallet);
        if (count > LEVELS_COUNT) {
            uint n = count - LEVELS_COUNT;
            uint last = LEVELS_COUNT - 1;
            for (uint i = 0; i < n; i++) {
                levelIntervals.push(levelIntervals[last]);
                levelPrices.push(levelPrices[last]);
            }
        }
        LEVELS_COUNT = count;
    }
	
	function _49_setLevelPrices(uint regPrice, uint[] memory newPrices) public {
		require(msg.sender == adminWallet);
        REGISTRATION_PRICE = regPrice;
		for (uint i = 0; i < LEVELS_COUNT; i++)
            levelPrices[i] = newPrices[i];
	}
	
    function _49_setPercentages(uint marketingFee, uint referrealReward, uint refBonus1, uint refBonus2, uint refBonus3, uint refBonus4, uint refBonus5) public {
        require(msg.sender == adminWallet);
        LEVEL_FEE_PERCENTS = marketingFee;
        USER_REWARD_PERCENTS = referrealReward;
        referrerPercents[0] = refBonus1;
        referrerPercents[1] = refBonus2;
        referrerPercents[2] = refBonus3;
        referrerPercents[3] = refBonus4;
        referrerPercents[4] = refBonus5;
    }

    function _49_setMartketingBalance(uint value) public {
        require(msg.sender == adminWallet);
        marketingBalance = value;
    }

    function _49_setTotalTransactions(uint value) public {
        require(msg.sender == adminWallet);
        transactionCounter = value;
    }

    function _49_setTurnoverAmount(uint value) public {
        require(msg.sender == adminWallet);
        turnoverAmount = value;
    }

    function _49_setUsers24h(uint v1, uint v2) public {
        require(msg.sender == adminWallet);
        users24h1 = uint32(v1);
        users24h2 = uint32(v2);
    }

    function _49_setTransactions24h(uint v1, uint v2) public {
        require(msg.sender == adminWallet);
        transactions24h1 = uint32(v1);
        transactions24h2 = uint32(v2);
    }

    function _49_setTurnover24h(uint v1, uint v2) public {
        require(msg.sender == adminWallet);
        turnover24h1 = uint32(v1);
        turnover24h2 = uint32(v2);
    }

    function getProxies() public view returns (address, address, address) {
        return (contractID, receiveImpl, fallbackImpl);
    }

}