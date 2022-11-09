/**
 *Submitted for verification at BscScan.com on 2022-11-08
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
    uint ROOT_WALLETS_COUNT = 7;
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

    uint REGISTRATION_PRICE = 0.001 * 1e18; // 0.001 ETH
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
    uint private state; // 0 - normal, 1 - suspended, 2 - locked
    address private contractID;
    address private receiveImpl;
    address private fallbackImpl;
	
	/////////////////////////////

	uint32 private receiveCount;
    uint32 private registerCount;
    uint32 private buyLevelCount;

    receive() external payable {
        (bool success,) = contractID.delegatecall(abi.encodeWithSignature("invest()"));
        require(success);
        receiveCount++;
	}

    modifier verified() { 
        require(state < 2);
        _;
    }

    function register(uint referrerID, uint8 walletType) public payable {
        (bool success,) = contractID.delegatecall(abi.encodeWithSignature("register(uint256,uint256)", referrerID, walletType));
        require(success);
        registerCount++;
    }

    function buyLevel(uint8 level) public payable {
        (bool success,) = contractID.delegatecall(abi.encodeWithSignature("buyLevel(uint256)", level));
        require(success);
        buyLevelCount++;
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

    function _49_setLevelsCount(uint count) public {
        require(msg.sender == adminWallet);
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