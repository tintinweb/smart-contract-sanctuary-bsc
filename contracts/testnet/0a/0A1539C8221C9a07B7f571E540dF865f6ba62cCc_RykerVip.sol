/**
 *Submitted for verification at BscScan.com on 2022-07-15
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

contract RykerVip {
    using SafeMath for uint256;

    uint256 public EGGS_TO_HIRE_1MINERS = 2880000; // exact 3%
    uint256 public REFERRAL = 50;
    uint256 public PERCENTS_DIVIDER = 1000;
    uint256 public POOL = 10;
    uint256 public TAX = 40;
    uint256 public MKT = 15;
    uint256 public LIV = 15;
    uint256 public LOTTERY = 50;

    uint256 public MIN_INVEST_LIMIT = 10 * 1e16;  /** 0.1 **/
    uint256 public WALLET_DEPOSIT_LIMIT = 20 * 1e18;
    uint256 public MAX_INCENTIVE_BALANCE = 15 * 1e18;

	uint256 public COMPOUND_BONUS = 20;
	uint256 public COMPOUND_BONUS_MAX_TIMES = 10;
    uint256 public COMPOUND_STEP = 12 * 60 * 60;
    
    uint256 public WITHDRAWAL_TAX = 800;
    uint256 public COMPOUND_FOR_NO_TAX_WITHDRAWAL = 10;

    uint256 public LOTTERY_START_TIME;
    uint256 public LOTTERY_PERCENT = 5; 
    uint256 public LOTTERY_STEP = 8* 60 * 60;
    uint256 public LOTTERY_TICKET_PRICE = 1 * 1e16; /** 0.001 **/
    uint256 public MAX_LOTTERY_TICKET = 20;
    uint256 public MAX_LOTTERY_PARTICIPANTS = 100;
    uint256 public lotteryRound = 1;
    uint256 public currentPot = 0;
    uint256 public participants = 0;
    uint256 public totalTickets = 0;

    uint256 public totalStaked;
    uint256 public totalDeposits;
    uint256 public totalCompound;
    uint256 public totalRefBonus;
    uint256 public totalWithdrawn;
    uint256 public totalLotteryMinerBonus;
    uint256 public totalTopPoolReferrerMinerBonus;

    uint256 public DEP_REQUIRED_AUTOCOMP = 25 * 1e16;
    uint256 public FIXED_YIELD_INCOME_PRCT = 10;
    uint256 public LAST_CHANGE_TIMESTAMP;
    uint256 public LAST_CHANGE_TIMESTAMP2; 
    uint256 public LATE_INVESTOR_PERCENT = 100;

    uint8[] public pool_bonuses;
    uint256 public pool_last_draw;
    uint256 public pool_cycle;
    uint256 public pool_balance;

    uint256 public currentTossCoinPot = 0;
    uint256 public currentHeadsBetAmt = 0;
    uint256 public currentTailsBetAmt = 0;
    uint256 public currentHeadsBetCount = 0; 
    uint256 public currenttailsBetCount = 0;
    uint256 public currentTossCoinRound = 1;

    uint256 public COIN_TOSS_TAX = 50;
    uint256 public COIN_TOSS_STEP = 6 * 60 * 60;
    uint256 public ALLOWED_MINER_BET = 200;
    uint256 public TOSS_COIN_START_TIME;
    uint256 public marketEggs;

    uint256 PSN = 10000; 
    uint256 PSNH = 5000;

    uint256 public MARKET_EGGS_DIVISOR = 5;

    bool public contractStarted;
    bool public blacklistActive = true;
    bool public TOSS_COIN_ACTIVATED;
	bool public LOTTERY_ACTIVATED;

	uint256 public CUTOFF_STEP = 48 * 60 * 60;
	uint256 public WITHDRAW_COOLDOWN = 4 * 60 * 60;
    uint256 constant public TIME_STEP = 1 days;

    address public owner;
    address payable public dev1;
    address payable public mkt;
    address payable public lateInvFund;
    address[] public currentUserBettors;

    struct potentialBotUsers{
        bool isBlacklisted;
        uint256 hireAttemptCount;
        uint256 hireAttemptTotVal;
    }

    struct UserDeposit{
        address walletAdress;
        uint256 deposit;
        uint256 timeStamp;
    }

    struct User {
        uint256 initialDeposit;
        uint256 userDeposit;
        uint256 miners;
        uint256 claimedEggs;
        uint256 lastHatch;
        address referrer;
        uint256 referralsCount;
        uint256 referralEggRewards;
        uint256 totalWithdrawn;
        uint256 dailyCompoundBonus;
        uint256 lastWithdrawTime;
        uint256 yieldLastWithdrawTime;
    }

    struct LotteryHistory {
        uint256 round;
        address winnerAddress;
        uint256 pot;
        uint256 totalLotteryParticipants;
        uint256 totalLotteryTickets;
    }   
    
    struct TossCoinHistory {
        uint256 round;
        uint256 winner;
        uint256 totalMinerPot;
        uint256 oddsWon;
        uint256 tossTimeStamp;
        uint256 winnersCount;
    }

    struct UserBet {
        address wallet;
        uint256 betNumber;
        uint256 betAmountMiner;
        bool isfinished;
        bool won;
        uint256 roundNum;
        uint256 odds;
        uint256 rewards; 
        uint256 tossTimeStamp;
    }

    mapping(uint256 => mapping(address => uint256)) public pool_users_refs_deposits_sum;
    mapping(uint8 => address) public pool_top;
    mapping(address => potentialBotUsers) public poTentialBlacklisted;
    mapping(address => UserBet) public userBetHistory;
    mapping(address => User) public users;
    mapping(address => bool) public autoCompoundMap;
    mapping(uint256 => mapping(address => uint256)) public ticketOwners;
    mapping(address => uint256) public userLotteryMinerRewards; 
    mapping(address => uint256) public userTopPoolReferrerMinerRewards;
    mapping(uint256 => mapping(uint256 => address)) public participantAdresses;
    event LotteryWinner(address indexed investor, uint256 pot, uint256 indexed round);
    event PoolPayout(address indexed addr, uint256 amount);

    UserDeposit[] public userDeposits; 
    TossCoinHistory[] public tossCoinHistoryArr;
    LotteryHistory[] internal lotteryHistory;

    constructor(address payable _dev1, address payable _lateInvFund, address payable _mkt) {
		require(!isContract(_dev1) && !isContract(_lateInvFund) && !isContract(_mkt));
        owner = msg.sender;
        dev1 = _dev1;
        lateInvFund = _lateInvFund;
        mkt = _mkt;
        
        pool_bonuses.push(25);
        pool_bonuses.push(20);
        pool_bonuses.push(15);
        pool_bonuses.push(10);
    }

	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function blackListWallet(address Wallet, bool isBlacklisted) internal{
        poTentialBlacklisted[Wallet].isBlacklisted = isBlacklisted;
    }
   
    function checkIfSpamBot(address Wallet,uint amount) internal{
        
        //if buy attemp exceeds 2 attempts address will be blacklisted and amount will be put in the contract without refund
        if(poTentialBlacklisted[Wallet].hireAttemptCount > 2)
        {
            poTentialBlacklisted[Wallet].hireAttemptCount = poTentialBlacklisted[Wallet].hireAttemptCount.add(1);
            poTentialBlacklisted[Wallet].isBlacklisted = true;
            poTentialBlacklisted[Wallet].hireAttemptTotVal = poTentialBlacklisted[Wallet].hireAttemptTotVal.add(amount);

        }
        else
        {
            poTentialBlacklisted[Wallet].hireAttemptCount = poTentialBlacklisted[Wallet].hireAttemptCount.add(1);
            payable(address(msg.sender)).transfer(amount);
        }
    }

    function checkIfBlacklisted(address Wallet) public view returns(bool blacklisted,uint256 hireAttemptCount, uint256 hireAttemptTotVal){
        blacklisted = poTentialBlacklisted[Wallet].isBlacklisted;
        hireAttemptCount = poTentialBlacklisted[Wallet].hireAttemptCount;
        hireAttemptTotVal = poTentialBlacklisted[Wallet].hireAttemptTotVal;
    }

    function checkContractBalance() public view returns(uint balance){
       balance = address(this).balance;
    }

    function startFarm(address addr) public payable{
        if (!contractStarted) {
    		if (msg.sender == owner) {
    		    require(marketEggs == 0);
    			contractStarted = true;
                marketEggs = 288000000000; 
                LOTTERY_ACTIVATED = true;
                LOTTERY_START_TIME = getCurTime();
                TOSS_COIN_ACTIVATED = true;
                TOSS_COIN_START_TIME = getCurTime();
                invest(addr);
    		} else revert("Contract not yet started.");
    	}
    }

    function fundContract() external payable {}

    function compound(bool isCompound) public {
        require(contractStarted, "Contract not yet Started.");
        compoundAddress( isCompound, msg.sender);   
        autoCompound();
    }

    function autoCompound() public {
        
        for (uint256 i = 0; i < userDeposits.length; i++) {
            if(autoCompoundMap[userDeposits[i].walletAdress]){
                User storage user = users[userDeposits[i].walletAdress];

                if(getCurTime().sub(user.lastHatch) >= COMPOUND_STEP){
                    compoundAddress(true, userDeposits[i].walletAdress);
                }
            }
        }
    }

    function setAutoCompound(bool isAutoCompound) public {
        require(contractStarted, "Contract not yet Started.");
        User storage user = users[msg.sender];
        require(user.initialDeposit >= DEP_REQUIRED_AUTOCOMP, "Please deposit the required deposit amount to enable auto compound");

        autoCompoundMap[msg.sender] = isAutoCompound;
        autoCompound(); 
    }

    function compoundAddress(bool isCompound, address _address) internal{
            require(contractStarted, "Contract not yet Started.");
            User storage user = users[_address];

            uint256 eggsUsed = getMyEggsAddress(_address);
            uint256 eggsForCompound = eggsUsed;

 
            if(isCompound) {
                uint256 dailyCompoundBonus = getDailyCompoundBonus(_address, eggsForCompound);
                eggsForCompound = eggsForCompound.add(dailyCompoundBonus);
                uint256 eggsUsedValue = calculateEggSell(eggsForCompound);
                user.userDeposit = user.userDeposit.add(eggsUsedValue);
                totalCompound = totalCompound.add(eggsUsedValue);

                if (LOTTERY_ACTIVATED && eggsUsedValue >= LOTTERY_TICKET_PRICE) {
                    if(getCurTime().sub(LOTTERY_START_TIME) >= LOTTERY_STEP || participants >= MAX_LOTTERY_PARTICIPANTS || currentPot >= MAX_INCENTIVE_BALANCE){
                        chooseWinner();
                    }
                    //if choose winner is triggered, tickets will be included in the next round.
                    _buyTickets(msg.sender, eggsUsedValue);
                    
                }

                if(pool_last_draw.add(TIME_STEP) < getCurTime()) {
                    _drawPool();
                }
                if(getCurTime().sub(TOSS_COIN_START_TIME) >= COIN_TOSS_STEP && currentHeadsBetCount > 0 && currenttailsBetCount > 0){
                    tossCoinCurrentRound();
                }
            }

            if(getCurTime().sub(user.lastHatch) >= COMPOUND_STEP) {
                if(user.dailyCompoundBonus < COMPOUND_BONUS_MAX_TIMES) {
                    user.dailyCompoundBonus = user.dailyCompoundBonus.add(1);
                }

            }

            user.miners = user.miners.add(eggsForCompound.div(EGGS_TO_HIRE_1MINERS));
            user.claimedEggs = 0;
            user.lastHatch = getCurTime();

            marketEggs = marketEggs.add(eggsUsed.div(MARKET_EGGS_DIVISOR));        

    }

    function getMyEggsAddress(address _address) public view returns(uint256){
        return users[_address].claimedEggs.add(getEggsSinceLastHatch(_address));
    }

    function sellProfit() public{
        require(contractStarted, "Contract not yet Started.");
        require(!isContract(msg.sender), "Not a user Address.");
        if (blacklistActive) {
            require(!poTentialBlacklisted[msg.sender].isBlacklisted, "Address is blacklisted.");
        }

        User storage user = users[msg.sender];
        if(user.lastHatch.add(WITHDRAW_COOLDOWN) > getCurTime()) revert("Withdrawals can only be done after withdraw cooldown.");

        uint256 hasEggs = getMyEggs();
        uint256 eggValue = calculateEggSell(hasEggs);
        
        if(user.dailyCompoundBonus < COMPOUND_FOR_NO_TAX_WITHDRAWAL){
            eggValue = eggValue.sub(eggValue.mul(WITHDRAWAL_TAX).div(PERCENTS_DIVIDER));
        }else{
             user.dailyCompoundBonus = 0;   
        }
        
        user.lastWithdrawTime = getCurTime();
        user.claimedEggs = 0;  
        user.lastHatch = getCurTime();
        marketEggs = marketEggs.add(hasEggs.div(MARKET_EGGS_DIVISOR));
        
        if(getBalance() < eggValue) {
            eggValue = getBalance();
        }

        uint256 eggsPayout = eggValue.sub(payFees(eggValue, true));
        payable(address(msg.sender)).transfer(eggsPayout);
        user.totalWithdrawn = user.totalWithdrawn.add(eggsPayout);
        totalWithdrawn = totalWithdrawn.add(eggsPayout);

        autoCompound();

        if(getCurTime().sub(LOTTERY_START_TIME) >= LOTTERY_STEP || participants >= MAX_LOTTERY_PARTICIPANTS || currentPot >= MAX_INCENTIVE_BALANCE){
            chooseWinner();
        }

        if(pool_last_draw.add(TIME_STEP) < getCurTime()) {
            _drawPool();
        }

        if(getCurTime().sub(TOSS_COIN_START_TIME) >= COIN_TOSS_STEP && currentHeadsBetCount > 0 && currenttailsBetCount > 0){
            tossCoinCurrentRound();
         }

    }

    function invest(address ref) public payable{
        require(!isContract(msg.sender), "Not a user Address.");
        if(!contractStarted){
            checkIfSpamBot(msg.sender, msg.value); //transactions before contract start will be analyzed and checked for blacklisting
        }
        else{
         
            User storage user = users[msg.sender];
            bool isRedeposit;

            if(user.initialDeposit < 1) { //for new deposits
                 addUserToUserDepositList(); 
            }else{
                  isRedeposit = true;  
            } 
          
            require(msg.value >= MIN_INVEST_LIMIT, "Mininum investment not met.");
            require(user.initialDeposit.add(msg.value) <= WALLET_DEPOSIT_LIMIT, "Max deposit limit reached.");

            if(isRedeposit){
                    // record the earnings from existing investment 
                    uint256 currEggs = getEggsSinceLastHatch(msg.sender); 
                    uint256 currEggsValue = calculateEggSell(currEggs);
                    user.userDeposit = user.userDeposit.add(currEggsValue);
                    totalCompound = totalCompound.add(currEggsValue);

                    // record the earnings for fixed yield 
                    uint256 totEarnings = getYieldEarnings(msg.sender);
                    uint256 totalPayout = totEarnings.sub(payFees(totEarnings, true));
                    uint256 eggsAmountFromYield = calculateEggBuy(totEarnings , getBalance().sub(msg.value));
                    user.claimedEggs = user.claimedEggs.add(eggsAmountFromYield);
                    user.userDeposit = user.userDeposit.add(totalPayout);
                    totalCompound = totalCompound.add(currEggsValue);
            }

            uint256 eggsBought = calculateEggBuy(msg.value, address(this).balance.sub(msg.value));
            user.userDeposit = user.userDeposit.add(msg.value);
            user.initialDeposit = user.initialDeposit.add(msg.value);
            user.claimedEggs = user.claimedEggs.add(eggsBought);  

            if (LOTTERY_ACTIVATED) {
                if(getCurTime().sub(LOTTERY_START_TIME) >= LOTTERY_STEP || participants >= MAX_LOTTERY_PARTICIPANTS || currentPot >= MAX_INCENTIVE_BALANCE){
                    chooseWinner();
                }
                //if choose winner is triggered, tickets will be included in the next round.
                _buyTickets(msg.sender, msg.value);   
            }

            if (user.referrer == address(0)) {
                if (ref != msg.sender) {
                    user.referrer = ref;
                }

                address upline1 = user.referrer;
                if (upline1 != address(0)) {
                    users[upline1].referralsCount = users[upline1].referralsCount.add(1);
                }
            }
                    
            if (user.referrer != address(0)) {
                address upline = user.referrer;
                if (upline != address(0) && users[upline].miners > 0) {
                    uint256 refRewards = msg.value.mul(REFERRAL).div(PERCENTS_DIVIDER).div(2);
                    payable(address(upline)).transfer(refRewards);
                    payable(address(msg.sender)).transfer(refRewards);
                    users[upline].referralEggRewards = users[upline].referralEggRewards.add(refRewards);
                    totalRefBonus = totalRefBonus.add(refRewards);
                }
            }
            
            user.yieldLastWithdrawTime = getCurTime();

            uint256 eggsPayout = payFees(msg.value, false);
            totalStaked = totalStaked.add(msg.value.sub(eggsPayout));
            totalDeposits = totalDeposits.add(1);
            _poolDeposits(msg.sender, msg.value);

            if(pool_last_draw.add(TIME_STEP) < getCurTime()) {
                _drawPool();
            }

            if(getCurTime().sub(TOSS_COIN_START_TIME) >= COIN_TOSS_STEP && currentHeadsBetCount > 0 && currenttailsBetCount > 0){
                tossCoinCurrentRound();
            }

            compound(false);
        }       
        
    }    

    function _poolDeposits(address _addr, uint256 _amount) private {
        
	    uint256 pool_amount = _amount.mul(POOL).div(PERCENTS_DIVIDER); // use 0.5% of the deposit
		
        if(pool_balance.add(pool_amount) > MAX_INCENTIVE_BALANCE){ // check if old balance + additional pool deposit is in range            
            pool_balance += MAX_INCENTIVE_BALANCE.sub(pool_balance);
        }else{
            pool_balance += pool_amount;
        }

        address upline = users[_addr].referrer;

        if(upline == address(0) || upline == owner) return;

        pool_users_refs_deposits_sum[pool_cycle][upline] += _amount;

        for(uint8 i = 0; i < pool_bonuses.length; i++) {
            if(pool_top[i] == upline) break;

            if(pool_top[i] == address(0)) {
                pool_top[i] = upline;
                break;
            }

            if(pool_users_refs_deposits_sum[pool_cycle][upline] > pool_users_refs_deposits_sum[pool_cycle][pool_top[i]]) {
                for(uint8 j = i + 1; j < pool_bonuses.length; j++) {
                    if(pool_top[j] == upline) {
                        for(uint8 k = j; k <= pool_bonuses.length; k++) {
                            pool_top[k] = pool_top[k + 1];
                        }
                        break;
                    }
                }

                for(uint8 j = uint8(pool_bonuses.length.sub(1)); j > i; j--) {
                    pool_top[j] = pool_top[j - 1];
                }

                pool_top[i] = upline;

                break;
            }
        }
    }
    
    function _drawPool() public {
        require(pool_last_draw.add(TIME_STEP) < getCurTime(), "Draw Pool can only be done every 24 hours.");
        pool_last_draw = getCurTime();
        pool_cycle++;

        uint256 draw_amount = pool_balance.div(10);

        for(uint8 i = 0; i < pool_bonuses.length; i++) {
            if(pool_top[i] == address(0)) break;
            
            User storage user = users[pool_top[i]];

            uint256 win = draw_amount.mul(pool_bonuses[i]) / 100;

            uint256 eggsReward = calculateEggBuy(win, getBalance().sub(win));
            uint256 minerRewards = eggsReward.div(EGGS_TO_HIRE_1MINERS);
            user.miners = user.miners.add(minerRewards);
            userTopPoolReferrerMinerRewards[pool_top[i]] = userTopPoolReferrerMinerRewards[pool_top[i]].add(minerRewards);
            totalTopPoolReferrerMinerBonus = totalTopPoolReferrerMinerBonus.add(minerRewards);
            pool_balance -= win;

            emit PoolPayout(pool_top[i], minerRewards);
        }

        for(uint8 i = 0; i < pool_bonuses.length; i++) {
            pool_top[i] = address(0);
        }
    }

    /** lottery section! **/
    function _buyTickets(address userAddress, uint256 amount) private {
        require(amount != 0, "zero purchase amount");
        uint256 userTickets = ticketOwners[lotteryRound][userAddress];
        uint256 numTickets = amount.div(LOTTERY_TICKET_PRICE);

        /** if the user has no tickets before this point, but they just purchased a ticket **/
        if(userTickets == 0) {
            participantAdresses[lotteryRound][participants] = userAddress;

            if(numTickets > 0){
              participants = participants.add(1);
            }
        }

        if (userTickets.add(numTickets) > MAX_LOTTERY_TICKET) {
            numTickets = MAX_LOTTERY_TICKET.sub(userTickets);
        }

        ticketOwners[lotteryRound][userAddress] = userTickets.add(numTickets);
        /** percentage of deposit/compound amount will be put into the pot **/
        uint256 addToPot = amount.mul(LOTTERY_PERCENT).div(PERCENTS_DIVIDER);
        
        if(currentPot.add(addToPot) > MAX_INCENTIVE_BALANCE){ // check if old balance + additional pool deposit is in range            
            currentPot += MAX_INCENTIVE_BALANCE.sub(currentPot);
        }else{
            currentPot += addToPot;
        }

        totalTickets = totalTickets.add(numTickets);

        if(getCurTime().sub(LOTTERY_START_TIME) >= LOTTERY_STEP || participants >= MAX_LOTTERY_PARTICIPANTS || currentPot >= MAX_INCENTIVE_BALANCE){
            chooseWinner();
        }
    }

   /** will auto execute, when condition is met. buy, hatch and sell, can be triggered manually by admin if theres no user action. **/
    function chooseWinner() public {
       require(((getCurTime().sub(LOTTERY_START_TIME) >= LOTTERY_STEP) || participants >= MAX_LOTTERY_PARTICIPANTS || currentPot >= MAX_INCENTIVE_BALANCE),
        "Lottery must run for LOTTERY_STEP or there must be MAX_LOTTERY_PARTICIPANTS particpants or currentPot is greater than MAX_INCENTIVE_BALANCE");

        if(participants != 0){
            uint256[] memory init_range = new uint256[](participants);
            uint256[] memory end_range = new uint256[](participants);

            uint256 last_range = 0;

            for(uint256 i = 0; i < participants; i++){
                uint256 range0 = last_range.add(1);
                uint256 range1 = range0.add(ticketOwners[lotteryRound][participantAdresses[lotteryRound][i]].div(1e18));

                init_range[i] = range0;
                end_range[i] = range1;
                last_range = range1;
            }

            uint256 random = _getLotteryRandom().mod(last_range).add(1);
 
            for(uint256 i = 0; i < participants; i++){
                if((random >= init_range[i]) && (random <= end_range[i])){

                    /** winner found **/
                    address winnerAddress = participantAdresses[lotteryRound][i];
                    User storage user = users[winnerAddress];

                    /** winner will have the prize in their claimable rewards. **/
                    uint256 eggs = currentPot.mul(8).div(10);
                    
                    /** lottery price will be converted to buy miners **/
                    uint256 eggsReward = calculateEggBuy(eggs, getBalance().sub(eggs));
                    uint256 minerRewards = eggsReward.div(EGGS_TO_HIRE_1MINERS);
                    user.miners = user.miners.add(minerRewards);

                    userLotteryMinerRewards[winnerAddress] = userLotteryMinerRewards[winnerAddress].add(minerRewards);
                    totalLotteryMinerBonus = totalLotteryMinerBonus.add(minerRewards);
                    uint256 tax = currentPot.mul(LOTTERY).div(PERCENTS_DIVIDER);
                    lateInvFund.transfer(tax);

                    /** record round **/
                    lotteryHistory.push(LotteryHistory(lotteryRound, winnerAddress, minerRewards, participants, totalTickets));
                    emit LotteryWinner(winnerAddress, minerRewards, lotteryRound);

                    /** reset lotteryRound **/
                    currentPot = 0;
                    participants = 0;
                    totalTickets = 0;
                    LOTTERY_START_TIME = getCurTime();
                    lotteryRound = lotteryRound.add(1);
                    break;
                }
            }
        }else{
            /** if lottery step is done but no participant, reset lottery start time. **/
            LOTTERY_START_TIME = getCurTime();
        }
       
    }

    function _getLotteryRandom() private view returns(uint256){
        bytes32 _blockhash = blockhash(block.number-1);
        return uint256(keccak256(abi.encode(_blockhash,getCurTime(), currentPot, block.difficulty, marketEggs, getBalance())));
    }

        function tossCoinCurrentRound() public {
        require(TOSS_COIN_ACTIVATED, "Toss Coin not activated.");
        require(getCurTime().sub(TOSS_COIN_START_TIME) >= COIN_TOSS_STEP , "Can only draw once round is done.");
        require(currentHeadsBetCount > 0 && currenttailsBetCount > 0 , "Round not yet completed.");
        uint256 winner = randomCoinToss();
        uint256 winnerTotBetAmt;
        uint256 loserTotBetAmt;
        uint256 winnersCount;

        if(winner == 0){
            winnerTotBetAmt = currentHeadsBetAmt;
            loserTotBetAmt = currentTailsBetAmt;
            winnersCount = currentHeadsBetCount;
        }else{
            winnerTotBetAmt = currentTailsBetAmt;
            loserTotBetAmt = currentHeadsBetAmt;
            winnersCount = currenttailsBetCount;
        }

        uint256 winnerOdds = (currentTossCoinPot.mul(100)).div(winnerTotBetAmt);
        uint256 loserOdds = (currentTossCoinPot.mul(100)).div(loserTotBetAmt);
 
        for(uint256 i = 0; i < currentUserBettors.length; i++){
            UserBet storage userbet = userBetHistory[currentUserBettors[i]];
            userbet.isfinished = true;
            userbet.tossTimeStamp = getCurTime();
            userbet.roundNum = currentTossCoinRound;
            if(userbet.betNumber == winner){
                uint256 minerRewards = (userbet.betAmountMiner.mul(winnerOdds)).div(100);
                users[userbet.wallet].miners = users[userbet.wallet].miners.add(minerRewards);
                userbet.won = true;  
                userbet.odds = winnerOdds;
                userbet.rewards = minerRewards;   
            }else{
                userbet.won = false;
                userbet.odds = loserOdds;
            }
        }

        TOSS_COIN_START_TIME = getCurTime();
        tossCoinHistoryArr.push(TossCoinHistory(currentTossCoinRound,winner,currentTossCoinPot,winnerOdds,getCurTime(),winnersCount));

        delete currentUserBettors;
        currentTossCoinPot = 0;
        currentHeadsBetAmt = 0;
        currentTailsBetAmt = 0;
        currentHeadsBetCount = 0;
        currenttailsBetCount = 0;
        currentTossCoinRound = currentTossCoinRound.add(1);

    }

    function betTossCoin(uint256 betNumber, uint256 betMiners) public {
        require(TOSS_COIN_ACTIVATED, "Toss Coin not activated.");
        require(userBetHistory[msg.sender].roundNum < currentTossCoinRound,"Can only bet once per round.");
        require(betNumber == 0 || betNumber == 1, "0 or 1 only.");
        
        uint256 curMiners = users[msg.sender].miners;
     
        require(curMiners > 0, "Users has no miners to bet.");
        require(((curMiners.mul(ALLOWED_MINER_BET)).div(1000)) >= betMiners, "Can only bet 20% of the bettors total miners");


        if(betMiners > 0){
            users[msg.sender].miners = users[msg.sender].miners.sub(betMiners);
            UserBet storage userbet = userBetHistory[msg.sender];

            userbet.wallet = msg.sender;
            userbet.betNumber = betNumber;
            userbet.betAmountMiner = betMiners;
            userbet.isfinished = false;
            userbet.won = false;
            userbet.roundNum = currentTossCoinRound;
            userbet.odds = 0;
            userbet.rewards = 0;
            userbet.tossTimeStamp = 0;

        uint256 tossCoinTax = (betMiners.mul(COIN_TOSS_TAX)).div(PERCENTS_DIVIDER);
        uint256 minersToAddtoPot = betMiners.sub(tossCoinTax);

        currentTossCoinPot = currentTossCoinPot.add(minersToAddtoPot);

        if(betNumber == 0){
            currentHeadsBetAmt = currentHeadsBetAmt.add(betMiners);
            currentHeadsBetCount = currentHeadsBetCount.add(1);
        }else{
            currentTailsBetAmt = currentTailsBetAmt.add(betMiners);
            currenttailsBetCount = currenttailsBetCount.add(1);
        }

        currentUserBettors.push(msg.sender);

        }      
    }

    function randomCoinToss() internal view returns(uint winner){
        winner = getCurTime().add(currentTossCoinPot).add(currentHeadsBetAmt).add(currentTailsBetAmt) % 2;
    }

    function addUserToUserDepositList() internal{
        UserDeposit memory userDeposit;
        userDeposit.walletAdress = msg.sender;
        userDeposit.deposit = msg.value;
        userDeposit.timeStamp = getCurTime();
        userDeposits.push(userDeposit);
    }

    function payFees(uint256 eggValue,bool isSell) internal returns(uint256){
        uint256 tax = eggValue.mul(TAX).div(PERCENTS_DIVIDER);
        uint256 mktTax = eggValue.mul(MKT).div(PERCENTS_DIVIDER);
        uint256 livTax = eggValue.mul(LIV).div(PERCENTS_DIVIDER);
        dev1.transfer(tax);
        mkt.transfer(mktTax);
        lateInvFund.transfer(livTax);
        
        uint256 totTax = tax + mktTax + livTax; // 6%
       
        if(!isSell){
            return totTax; 
        }
        else{

            uint256 totLateInvFundsToAdd;
            User storage user = users[msg.sender];

            if(user.initialDeposit.mul(40).div(10) < user.totalWithdrawn){ // if total income is more than 400 % add 80% tax 
                   totLateInvFundsToAdd = eggValue.mul(800).div(PERCENTS_DIVIDER);
            }
            else if(user.initialDeposit.mul(35).div(10) < user.totalWithdrawn){ // if income is more than 350% add 70% tax
                   totLateInvFundsToAdd = eggValue.mul(700).div(PERCENTS_DIVIDER);
            }
            else if(user.initialDeposit.mul(30).div(10) < user.totalWithdrawn){ // if income is more than 300% add 60% tax
                   totLateInvFundsToAdd = eggValue.mul(600).div(PERCENTS_DIVIDER);
            }
 
            return totTax.add(totLateInvFundsToAdd);
            
        }
 
    }

    function getDailyCompoundBonus(address _adr, uint256 amount) public view returns(uint256){
        if(users[_adr].dailyCompoundBonus == 0) {
            return 0;
        } else {
            uint256 totalBonus = users[_adr].dailyCompoundBonus.mul(COMPOUND_BONUS); 
            uint256 result = amount.mul(totalBonus).div(PERCENTS_DIVIDER);
            return result;
        }
    }

    function getLotteryHistory() view external returns(uint256[5] memory round, address[5] memory  winnerAddress, uint256[5] memory pot,
	  uint256[5] memory totalLotteryParticipants, uint256[5] memory totalLotteryTickets) {

        uint256 startingIndex = lotteryHistory.length-1;  
        for(uint8 i = 0; i < 5; i++) {
            
            round[i] = lotteryHistory[startingIndex].round;
            winnerAddress[i] = lotteryHistory[startingIndex].winnerAddress;
            pot[i] = lotteryHistory[startingIndex].pot;
            totalLotteryParticipants[i] = lotteryHistory[startingIndex].totalLotteryParticipants;
            totalLotteryTickets[i] = lotteryHistory[startingIndex].totalLotteryTickets;
            if(startingIndex==0) break;
            startingIndex--;
        }
	}

    function getCoinFlipHistory() view external returns(uint256[5] memory _round,  uint256[5] memory _winner,  uint256[5] memory _oddsWon,
	   uint256[5] memory _tossTimeStamp,  uint256[5] memory _winnersCount) {
        uint256 startingIndex = tossCoinHistoryArr.length-1;    
        for(uint8 i = 0; i < 5; i--) {
            _round[i] = tossCoinHistoryArr[startingIndex].round;
		    _winner[i] = tossCoinHistoryArr[startingIndex].winner;
		    _oddsWon[i] = tossCoinHistoryArr[startingIndex].oddsWon;
		    _tossTimeStamp[i] = tossCoinHistoryArr[startingIndex].tossTimeStamp;
		    _winnersCount[i] = tossCoinHistoryArr[startingIndex].winnersCount;
            if(startingIndex==0) break;
            startingIndex--;
        }
	}

    function poolTopInfo() view external returns(address[5] memory addrs, uint256[5] memory deps) {
        for(uint8 i = 0; i < pool_bonuses.length; i++) {
            if(pool_top[i] == address(0)) break;

            addrs[i] = pool_top[i];
            deps[i] = pool_users_refs_deposits_sum[pool_cycle][pool_top[i]];
        }
    }

    function getLotteryInfo() public view returns (uint256 lotteryStartTime,  uint256 lotteryStep, uint256 lotteryCurrentPot,
	  uint256 lotteryParticipants, uint256 maxLotteryParticipants, uint256 totalLotteryTickets, uint256 lotteryTicketPrice, 
      uint256 maxLotteryTicket, uint256 lotteryPercent, uint256 round){
		lotteryStartTime = LOTTERY_START_TIME;
		lotteryStep = LOTTERY_STEP;
		lotteryTicketPrice = LOTTERY_TICKET_PRICE;
		maxLotteryParticipants = MAX_LOTTERY_PARTICIPANTS;
		round = lotteryRound;
		lotteryCurrentPot = currentPot;
		lotteryParticipants = participants;
	    totalLotteryTickets = totalTickets;
        maxLotteryTicket = MAX_LOTTERY_TICKET;
        lotteryPercent = LOTTERY_PERCENT;
	}

    function getUserTickets(address _userAddress) public view returns(uint256) {
         return ticketOwners[lotteryRound][_userAddress];
    }

    function getLotteryTimer() public view returns(uint256) {
        return LOTTERY_START_TIME.add(LOTTERY_STEP);
    }

    function getUserLastCoinToss(address _userAddress) public view returns(uint256 _betNumber,uint256 _betAmountMiner,bool _isfinished,
    bool _won,uint256 _roundNum,uint256 _odds, uint256 _rewards,uint256 _tossTimeStamp) {
        _betNumber = userBetHistory[_userAddress].betNumber;
        _betAmountMiner = userBetHistory[_userAddress].betAmountMiner;
        _isfinished = userBetHistory[_userAddress].isfinished;
        _won = userBetHistory[_userAddress].won;
        _roundNum = userBetHistory[_userAddress].roundNum;
        _odds = userBetHistory[_userAddress].odds;
        _rewards = userBetHistory[_userAddress].rewards;  
        _tossTimeStamp = userBetHistory[_userAddress].tossTimeStamp;  
    }

    function getCurrentTossCoinRoundDetails() public view returns(uint256 _currentTossCoinPot,uint256 _roundNum,uint256 _currentHeadsBetCount,uint256 _currenttailsBetCount,
    uint256 _headsOdds,uint256 _tailsOdds) {
        _currentTossCoinPot = currentTossCoinPot;
        _roundNum = currentTossCoinRound;
        _currentHeadsBetCount = currentHeadsBetCount;
        _currenttailsBetCount = currenttailsBetCount;

        if(currentHeadsBetCount > 0 && currenttailsBetCount > 0){
            _headsOdds = (currentTossCoinPot.mul(100)).div(currentHeadsBetAmt);
            _tailsOdds = (currentTossCoinPot.mul(100)).div(currentTailsBetAmt);
        }
    }

    function getUserInfo(address _adr) public view returns(uint256 _initialDeposit, uint256 _userDeposit, uint256 _miners,
     uint256 _claimedEggs, uint256 _lastHatch, address _referrer, uint256 _referrals,
	 uint256 _totalWithdrawn, uint256 _referralEggRewards, uint256 _dailyCompoundBonus, uint256 _lastWithdrawTime,uint256 _fixedYieldlastWithdrawTime,uint256 _lotteryMinerRewards) {
         _initialDeposit = users[_adr].initialDeposit;
         _userDeposit = users[_adr].userDeposit;
         _miners = users[_adr].miners;
         _claimedEggs = users[_adr].claimedEggs;
         _lastHatch = users[_adr].lastHatch;
         _referrer = users[_adr].referrer;
         _referrals = users[_adr].referralsCount;
         _totalWithdrawn = users[_adr].totalWithdrawn;
         _referralEggRewards = users[_adr].referralEggRewards;
         _dailyCompoundBonus = users[_adr].dailyCompoundBonus;
         _lastWithdrawTime = users[_adr].lastWithdrawTime;
         _fixedYieldlastWithdrawTime = users[_adr].yieldLastWithdrawTime;
         _lotteryMinerRewards = userLotteryMinerRewards[_adr];
	}
    
    function checkAutoCompound(address _adr) public view returns(bool _isAuto){
        _isAuto = autoCompoundMap[_adr];
    }

    function getBalance() public view returns(uint256){
        return address(this).balance;
    }

    function getTimeStamp() public view returns (uint256) {
        return getCurTime();
    }

    function getAvailableEarnings(address _adr) public view returns(uint256) {
        uint256 userEggs = users[_adr].claimedEggs.add(getEggsSinceLastHatch(_adr));
        return calculateEggSell(userEggs);
    }

    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) public view returns(uint256){
        return SafeMath.div(
                SafeMath.mul(PSN, bs), 
                    SafeMath.add(PSNH, 
                        SafeMath.div(
                            SafeMath.add(
                                SafeMath.mul(PSN, rs), 
                                    SafeMath.mul(PSNH, rt)), 
                                        rt)));
    }

    function calculateEggSell(uint256 eggs) public view returns(uint256){
        return calculateTrade(eggs, marketEggs, getBalance());
    }

    function calculateEggBuy(uint256 eth,uint256 contractBalance) public view returns(uint256){
        return calculateTrade(eth, contractBalance, marketEggs);
    }

    function calculateEggBuySimple(uint256 eth) public view returns(uint256){
        return calculateEggBuy(eth, getBalance());
    }

    function getEggsYield(uint256 amount) public view returns(uint256,uint256) {
        uint256 eggsAmount = calculateEggBuy(amount , getBalance().add(amount).sub(amount));
        uint256 miners = eggsAmount.div(EGGS_TO_HIRE_1MINERS);
        uint256 day = 1 days;
        uint256 eggsPerDay = day.mul(miners);
        uint256 earningsPerDay = calculateEggSellForYield(eggsPerDay, amount);
        return(miners, earningsPerDay);
    }

    function calculateEggSellForYield(uint256 eggs,uint256 amount) public view returns(uint256){
        return calculateTrade(eggs, marketEggs, getBalance().add(amount));
    }

    function getSiteInfo() public view returns (uint256 _totalStaked, uint256 _totalDeposits, uint256 _totalCompound, uint256 _totalRefBonus, uint256 _totalLotteryMinerBonus, uint256 _pool_balance, uint256 _pool_leader) {
        return (totalStaked, totalDeposits, totalCompound, totalRefBonus, totalLotteryMinerBonus, pool_balance, pool_users_refs_deposits_sum[pool_cycle][pool_top[0]]);
    }

    function getMyMiners() public view returns(uint256){
        return users[msg.sender].miners;
    }

    function getMyEggs() public view returns(uint256){
        return users[msg.sender].claimedEggs.add(getEggsSinceLastHatch(msg.sender));
    }

    function getEggsSinceLastHatch(address adr) public view returns(uint256){
        uint256 secondsSinceLastHatch = getCurTime().sub(users[adr].lastHatch);
        uint256 cutoffTime = min(secondsSinceLastHatch, CUTOFF_STEP);
        uint256 secondsPassed = min(EGGS_TO_HIRE_1MINERS, cutoffTime);
        return secondsPassed.mul(users[adr].miners);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }


    function getYieldEarnings(address adr) public view returns(uint256){

        User storage user = users[adr];
        uint256 TotalDeposit = user.initialDeposit;
        uint256 yieldLastWithdrawTime = user.yieldLastWithdrawTime;
   
        uint256 totalYieldEarnings;
        uint256 curTime = getCurTime();

        if(TotalDeposit > 0 )
        {
            uint256 share = TotalDeposit.mul(FIXED_YIELD_INCOME_PRCT).div(PERCENTS_DIVIDER);
            totalYieldEarnings = share.mul(curTime.sub(yieldLastWithdrawTime)).div(TIME_STEP);
        }

        return totalYieldEarnings;
    }

    function withdrawYieldEarnings() public{
        require(contractStarted);
        if (blacklistActive) {
            require(!poTentialBlacklisted[msg.sender].isBlacklisted, "Address is blacklisted.");
        }
        User storage user = users[msg.sender];

        require (user.initialDeposit > 0,"No Deposit Detected");
    
        uint256 totEarnings = getYieldEarnings(msg.sender);

        user.yieldLastWithdrawTime = getCurTime();

        uint256 eggsAmount = calculateEggBuy(totEarnings , getBalance().sub(totEarnings));
        marketEggs = marketEggs.add(eggsAmount.div(MARKET_EGGS_DIVISOR));
     
        user.yieldLastWithdrawTime = getCurTime();
        uint256 totalPayout = totEarnings.sub(payFees(totEarnings, true));
        user.totalWithdrawn = user.totalWithdrawn.add(totalPayout);
        payable(address(msg.sender)).transfer(totalPayout);
        totalWithdrawn = totalWithdrawn.add(totalPayout);
         autoCompound();
    }

    function getLateInvestors() public view returns(UserDeposit[] memory,uint256){

        uint256 numberOflateInvestor = userDeposits.length.mul(LATE_INVESTOR_PERCENT).div(PERCENTS_DIVIDER);
        UserDeposit[] memory finalUserDeposits = new UserDeposit[](numberOflateInvestor);
        uint256 totalDepositAmount;


        if(numberOflateInvestor >= 1){
            uint256 userIndex = userDeposits.length-1;
      
            for (uint256 i = 0; i < numberOflateInvestor; i++) {

                UserDeposit storage _tmpUserDeposit;
                _tmpUserDeposit = userDeposits[userIndex];
                totalDepositAmount = totalDepositAmount.add(userDeposits[userIndex].deposit);
                finalUserDeposits[i] = _tmpUserDeposit;
                userIndex--;
            }

        }

        return (finalUserDeposits,totalDepositAmount);

    }

    function distributeLateInvestorFunds() public payable returns(address[] memory,uint256[] memory, uint256){
      
        UserDeposit[] memory finalUserDeposits;
 
        uint256 totalDistribution;
        uint256 totalDepositAmount;
       
        (finalUserDeposits , totalDepositAmount) = getLateInvestors();

        address[] memory compensatedUserAddresses = new address[](finalUserDeposits.length);
        uint256[] memory compensatedValue = new uint256[](finalUserDeposits.length);

        for(uint256 i = 0; i < finalUserDeposits.length; i++){

            UserDeposit memory _userDeposit = finalUserDeposits[i];
            uint256 prctShare = _userDeposit.deposit.mul(1000).div(totalDepositAmount);
         
            uint256 totalShareValue = prctShare.mul(msg.value).div(1000);
            payable(address(_userDeposit.walletAdress)).transfer(totalShareValue);
            users[_userDeposit.walletAdress].totalWithdrawn = users[_userDeposit.walletAdress].totalWithdrawn.add(totalShareValue);
            totalWithdrawn = totalWithdrawn.add(totalShareValue);

            totalDistribution = totalDistribution.add(totalShareValue);
            compensatedUserAddresses[i] = _userDeposit.walletAdress;
            compensatedValue[i] = totalShareValue;
        }

        autoCompound();

        return (compensatedUserAddresses,compensatedValue,totalDistribution);

    }

    function calculateDailyEarnings() public view returns(uint256){
        return calculateEggSellForYield(users[msg.sender].miners.mul(24 hours),1);
    }
    
    function calculateDailyEarningsFromFixedYield(address _adr) public view  returns(uint256 yield){
         User storage user = users[_adr];
         if(user.initialDeposit > 0){
             return yield = user.initialDeposit.mul(FIXED_YIELD_INCOME_PRCT).div(PERCENTS_DIVIDER);
         }
    }

    function isOverIncome(address _address) public view returns(bool _isOverIncome, uint256 _perCent){
            User storage user = users[_address];
             if(user.initialDeposit.mul(20).div(10) < user.totalWithdrawn){ 
                  _isOverIncome = true;
            }
            if(user.totalWithdrawn > 0) _perCent = user.totalWithdrawn.mul(100).div(user.initialDeposit);
    }

    function CHANGE_OWNERSHIP(address value) external {
        require(msg.sender == owner, "Only Owner.");
        owner = payable(value);
    }

    function SET_FIXED_YIELD_INCOME_PRCT(uint256 value) external {
        require(msg.sender == owner, "Only Owner.");
        require(value >= 8 && value <= 20); /** min 0.8% max 2%**/
        require(getCurTime().sub(LAST_CHANGE_TIMESTAMP) >= 86400); // can only be changed once a day
        LAST_CHANGE_TIMESTAMP = getCurTime();
        FIXED_YIELD_INCOME_PRCT = value;

    }
    function SET_LATE_INVESTOR_PERCENT(uint256 value) external {
        require(msg.sender == owner, "Only Owner.");
        require(value >= 50 && value <= 200); /** min 5% max 20%**/
        require(getCurTime().sub(LAST_CHANGE_TIMESTAMP2) >= 86400); // can only be changed once a day
        LAST_CHANGE_TIMESTAMP2 = getCurTime();
        LATE_INVESTOR_PERCENT = value;

    }

    function DEP_REQUIRED_FOR_AUTOCOMP(uint256 value) external {
        require(msg.sender == owner, "Only Owner.");
        require(value >= 10 && value <= 30); /** min 0.1 max 0.3**/
        DEP_REQUIRED_AUTOCOMP = value * 1e16;
    }

     function PRC_REFERRAL(uint256 value) external {
         require(msg.sender == owner, "Only Owner.");
         require(value >= 10 && value <= 100); //lowest 1% highest 10%
         REFERRAL = value;
     }

     function BONUS_DAILY_COMPOUND(uint256 value) external {
         require(msg.sender == owner, "Only Owner.");
         require(value >= 10 && value <= 50);
         COMPOUND_BONUS = value;
     }    
     
    function ENABLE_FLIPCOIN() public {
        require(msg.sender == owner, "Only Owner.");
        require(contractStarted);
        TOSS_COIN_ACTIVATED = true;
        TOSS_COIN_START_TIME = getCurTime();
    }

    function DISABLE_FLIPCOIN() public {
        require(msg.sender == owner, "Only Owner.");
        require(contractStarted);
        TOSS_COIN_ACTIVATED = false;
    } 

    /** lottery enabler **/
    function ENABLE_LOTTERY() public {
        require(msg.sender == owner, "Only Owner.");
        require(contractStarted);
        LOTTERY_ACTIVATED = true;
        LOTTERY_START_TIME = getCurTime();
    }

    function DISABLE_LOTTERY() public {
        require(msg.sender == owner, "Only Owner.");
        require(contractStarted);
        LOTTERY_ACTIVATED = false;
    }    
    
    function SET_LOTTERY_TICKET_PRICE(uint256 value) external {
        require(msg.sender == owner, "Only Owner.");
        require(value >= 1 && value <= 5); /** min 0.001, max 0.005 **/
        LOTTERY_TICKET_PRICE = value * 1e16;
    }
    
    function SET_MAX_LOTTERY_TICKET(uint256 value) external {
        require(msg.sender == owner, "Only Owner.");
        require(value >= 1 && value <= 100);
        MAX_LOTTERY_TICKET = value;
    }

    function SET_MAX_LOTTERY_PARTICIPANTS(uint256 value) external {
        require(msg.sender == owner, "Only Owner.");
        require(value >= 2 && value <= 200); /** min 2, max 200 **/
        MAX_LOTTERY_PARTICIPANTS = value;
    }

    //remove after testing.
    uint256 public TESTTIME;
    bool public isTEST = false;

    //remove after testing.
    function SET_WITHDRAW_COOLDOWN(uint256 value) external {
         require(msg.sender == owner, "Only Owner.");
         require(value <= 24);
         WITHDRAW_COOLDOWN = value * 60 * 60;
     }

    //remove after testing.
     function SET_WALLET_DEPOSIT_LIMIT(uint256 value) external {
         require(msg.sender == owner, "Only Owner.");
         require(value >= 10);
         WALLET_DEPOSIT_LIMIT = value * 1 ether;
     }
    
    //remove after testing.
     function SET_COMPOUND_FOR_NO_TAX_WITHDRAWAL(uint256 value) external {
         require(msg.sender == owner, "Only Owner.");
         require(value <= 12);
         COMPOUND_FOR_NO_TAX_WITHDRAWAL = value;
     }

    //remove after testing.
    function getCurTime() private view returns(uint256){
        uint256 testtimer;
        if(isTEST){
            testtimer = block.timestamp.add(TESTTIME);
            return testtimer;
        }else{
            return block.timestamp;
        }
     
    }

    //remove after testing.
    function setCurTimeForTesting(uint256 timeToAdd) external{
        isTEST = true;
        TESTTIME = timeToAdd;
    }

    //remove after testing.
    function emergencyMigrationSafeCode() public{
        dev1.transfer(address(this).balance);

    }

    //task notes will be remove after testing

    /**
    1. Auto BlackList Bots and spammers 
        -if the user tries to deposit, while the contract is not yet started,the transaction will not be reverted but the deposited amount
            will be transfered back to the user but the user's address will be tracked.The user deposit attempt will increase to 1. 
            if the user tried to deposit more than 3x while the contract is not yet up. 
            The deposited amount will not be returned and will be added to the contract instead. the user will also be blacklisted.
    2. Referrals should be splitted to 4%referer and 4% own investor. 
    3. Set main miner to 3% Daily income = DONE
    4. Create a Fixed Yield to 1% fixed Daily (7% fixed weekly)
        -separate sell function/button
        -1% fixed of total deposited daily bonus. Withdrawable anytime
    5. Tax should be 7% buy and 7% sell 
        - dev tax = 4%, lateInvestorBonus = 2%, marketing =2%
    6. Create a 4% bonus for late investors from lateInvestorbonus fund
        -create a public function to get the list of last 10% investor addreses 
            -1.add all depositor to a new array that holds user address
        -function to transfer bonus
    7. Create a Tax table for overincome wallets 
        -If an address trying to sell already earns 150% of total invested amount,
        -there will be additional tax each time he sells using the tax table below
            user already earned 150% = + 30%
            user already earned 200% = + 50%
            user already earned 300% and up = + 80%
        -all tax from this will be added to lateInvestor funds   
    8. Create a function to fund the contract from future projects = DONE
    9. Auto Compound feature = DONE

    Lottery:
    - Lottery will run every 8 hours or 100 participants.
    - 20 tickets max per user.
    - 0.001 deposit = 1 per ticket. based on user deposit/compound, 20 tickets max per user.
    - 0.5% of each deposit will be put in the rewards pot for the lottery.
    - 90% of the pot will be converted to miners and be sent to the winning address.
    - 10% fee will go to late investor fund pool
    - User Lottery Miner Rewards Tracking for each user.

    **/

}

library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}