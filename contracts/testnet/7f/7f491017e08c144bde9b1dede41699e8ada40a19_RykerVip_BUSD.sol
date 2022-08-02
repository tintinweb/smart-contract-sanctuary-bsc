/**
 *Submitted for verification at BscScan.com on 2022-08-02
*/

/** 

    Ryker.Vip 7 in 1 Mining - BUSD Coin Edition. 

    🖌 7 ways to earn in 1 investment
      🖊  4% Miner Daily Yield
      🖊  1% Fixed Income Yield.
      🖊  6% Referral Rewards, 3% Referrer/3% Referee.
      🖊  Lottery Every 12 hours.
      🖊  Daily Top Referrer Rewards.
      🖊  Last Deposit Jackpot Rewards.
      🖊  Late Investor Income.

    🖌 Unique Features:
      🖊  Automated Compound Feature.
      🖊  Automated Anti-Bot Feature.
      🖊  Over-Income Tax Deduction.
      🖊  Flip Coin - Miner Betting Feature.
      🖊  Horse Race - Miner Betting Feature. 

    🖌 Upcoming Feature:
      🖊  Hold Ryker Tokens for increase in rewards.  

**/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract RykerVip_BUSD {

    IERC20 public tokenERC20;
    bool private contractStarted;
    uint256 public FIXED_YIELD_INCOME_PRCT = 10;
    uint256 public MAX_INCENTIVE_BALANCE = 5000 ether;

    uint256[] private horseRaceOddsArr = [160, 300, 850, 1800, 9000];
    uint8[] private TOP_REFERRER_BONUSES = [30, 25, 20, 15, 10];
    uint256 private topReferrerRound;
    uint256 private TOP_REFERRER_BALANCE;

    uint256 private currentTossCoinPot = 0;
    uint256 private currentHeadsBetAmt = 0;
    uint256 private currentTailsBetAmt = 0;
    uint256 private currentHeadsBetCount = 0; 
    uint256 private currenttailsBetCount = 0;
    
    uint256 private currentPot = 0;
    uint256 private participants = 0;
    uint256 private totalTickets = 0;

    uint256 private totalStaked;
    uint256 private totalDeposits;
    uint256 private totalCompound;
    uint256 private totalRefBonus;
    uint256 private totalWithdrawn;
    uint256 private totalLotteryMinerBonus;
    uint256 private totalTopPoolReferrerMinerBonus;
    uint256 public  totalLastDepositJackpot;
    
    // event timestamps
    uint256 public LOTTERY_START_TIME;
    uint256 public TOSS_COIN_START_TIME;
    uint256 public TOP_REFERRER_START_TIME;
    uint256 public LAST_DEPOSIT_START_TIME;
    uint256 public HORSE_RACE_START_TIME;
    
    // event enablers
	bool private LOTTERY_ACTIVATED;
    bool private TOSS_COIN_ACTIVATED;
	bool private TOP_REFERRER_ACTIVATED;
    bool private LAST_DEPOSIT_ACTIVATED;
    bool private HORSE_BETTING_ACTIVATED;
    bool private AUTO_COMPOUND_ACTIVATED;

    bool private blacklistActive = true;
    bool private LOCKED;

    address private owner;
    address private development;
    address private marketing;
    address private lateInvFund;
    address private autoCompoundExecutor;
    address public potentialLastDepositWinner;
    address[] public currentUserBettors;
    address[] public currentUserHorseBettors;

    uint256 public currentLastBuyRound = 1; 
    uint256 private currentLotteryRound = 1;
    uint256 private currentTossCoinRound = 1;      
    uint256 private currentHorseRaceRound = 1;
    uint256 private marketEggs;

    using SafeMath for uint256;
    using SafeMath for uint8;

    struct potentialBotUsers {
        bool isBlacklisted;
        uint256 hireAttemptCount;
        uint256 hireAttemptTotVal;
    }

    struct UserDeposit {
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

    struct UserBet {
        bool won;
        bool isfinished;
        address wallet;
        uint256 betNumber;
        uint256 betAmountMiner;
        uint256 roundNum;
        uint256 odds;
        uint256 rewards; 
        uint256 tossTimeStamp;
    }

    UserDeposit[] public userDeposits;

    mapping(uint8   => address) public pool_top;
    mapping(address => User) public users;
    mapping(address => UserBet) public userBetHistory;
    mapping(address => UserBet) private userHorseRaceHistory;
    mapping(address => bool) private isEarlyProjectSupporter;
    mapping(address => potentialBotUsers) private potentialBlacklisted;
    mapping(address => uint256) public userLotteryMinerRewards;
    mapping(address => uint256) public userTopPoolReferrerMinerRewards;
    mapping(uint256 => mapping(uint256 => address)) public participantAdresses;
    mapping(uint256 => mapping(address => uint256)) public totalDepositPool;
    mapping(uint256 => mapping(address => uint256)) public ticketOwners;

    event AutoCompoundEvent(address indexed _addr, uint256 drawTime);
    event PoolPayoutEvent(address indexed addr, uint256 amount, uint256 drawTime);
    event LastBuyEvent(uint256 indexed round, address indexed winner, uint256 amountRewards, uint256 minerRewards, uint256 drawTime);
    event HorceRaceEvent(uint256 indexed round, uint256 winningHorse, uint256 winnningOdds, uint256 TotalNumberOfWinners, uint256 drawTime);
    event TossCoinEvent(uint256 indexed round, uint256 winner, uint256 totalMinerPot, uint256 oddsWon, uint256 winnersCount, uint256 drawTime);
    event LotteryEvent(uint256 indexed round, address indexed investorWinner, uint256 pot, uint256 totalLotteryParticipants, uint256 totalLotteryTickets, uint256 drawTime);
    
    //0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56 BUSD Main, 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7 BUSD Test
    constructor(address _development, address _lateInvFund, address _marketing, address _autoCompoundExecutor) {
		require(!isContract(_development) && !isContract(_lateInvFund) && !isContract(_marketing) && !isContract(_autoCompoundExecutor), "Not a user address.");
        tokenERC20           = IERC20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7);
        owner                = msg.sender;
        development          = _development;
        lateInvFund          = _lateInvFund;
        marketing            = _marketing;
        autoCompoundExecutor = _autoCompoundExecutor;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier contractActivated {
        require(contractStarted, "Contract not yet Started.");
        _;
    }

    modifier nonReentrant {
        require(!LOCKED, "No re-entrancy");
        LOCKED = true;
        _;
        LOCKED = false;
    }

	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

	function updateAutoCompoundExecutor(address value) external onlyOwner {
        require(!isContract(value));
        autoCompoundExecutor = value;
    }

    function executeAutoCompound(address _addr) external {
        require(msg.sender == autoCompoundExecutor, "Not Executor Address.");
        require(AUTO_COMPOUND_ACTIVATED, "Auto Compound not Activated.");
        compoundAddress(true, _addr); // will skip validations because checks are already done before this calling this function
        emit AutoCompoundEvent(_addr, block.timestamp);
    }

    function startRykerContract(address addr, uint256 amount) public onlyOwner {
        if (!contractStarted) {
            require(marketEggs == 0);
            contractStarted = true;
            marketEggs = 216000000000; 
            LOTTERY_ACTIVATED = true;
            TOSS_COIN_ACTIVATED = true;
            TOP_REFERRER_ACTIVATED = true;
            LAST_DEPOSIT_ACTIVATED = true;
            AUTO_COMPOUND_ACTIVATED = true;
            HORSE_BETTING_ACTIVATED = true;
            LOTTERY_START_TIME = block.timestamp;
            TOSS_COIN_START_TIME = block.timestamp;
            TOP_REFERRER_START_TIME = block.timestamp;
            LAST_DEPOSIT_START_TIME = block.timestamp;
            HORSE_RACE_START_TIME = block.timestamp;
            invest(addr, amount);
    	} else revert("Contract already started.");
    }

    function blackListWallet(address Wallet, bool isBlacklisted) internal {
        potentialBlacklisted[Wallet].isBlacklisted = isBlacklisted;
    }
   
    function checkIfSpamBot(address Wallet, uint amount) internal {
        
        //if buy attemp exceeds 2 attempts address will be blacklisted and amount will be put in the contract without refund
        if(potentialBlacklisted[Wallet].hireAttemptCount > 2)
        {
            potentialBlacklisted[Wallet].hireAttemptCount = potentialBlacklisted[Wallet].hireAttemptCount.add(1);
            potentialBlacklisted[Wallet].isBlacklisted = true;
            potentialBlacklisted[Wallet].hireAttemptTotVal = potentialBlacklisted[Wallet].hireAttemptTotVal.add(amount);
            tokenERC20.transferFrom(address(Wallet), address(this), amount);
        }
        else
        {   // no need to transfer amount back since we only count the attempt.
            potentialBlacklisted[Wallet].hireAttemptCount = potentialBlacklisted[Wallet].hireAttemptCount.add(1);
        }
    }

    function checkIfBlacklisted(address Wallet) public view returns(bool blacklisted, uint256 hireAttemptCount, uint256 hireAttemptTotVal) {
        blacklisted = potentialBlacklisted[Wallet].isBlacklisted;
        hireAttemptCount = potentialBlacklisted[Wallet].hireAttemptCount;
        hireAttemptTotVal = potentialBlacklisted[Wallet].hireAttemptTotVal;
    }

    function compound(bool isCompound) public contractActivated {
        compoundAddress(isCompound, msg.sender); 
    }

    function compoundAddress(bool isCompound, address _address) internal {
        User storage user = users[_address];

        uint256 eggsUsed = getMyEggsAddress(_address);
        uint256 eggsForCompound = eggsUsed;

        if(isCompound) {
            uint256 dailyCompoundBonus = getDailyCompoundBonus(_address, eggsForCompound);
            eggsForCompound = eggsForCompound.add(dailyCompoundBonus);
            uint256 eggsUsedValue = calculateEggSell(eggsForCompound);
            user.userDeposit = user.userDeposit.add(eggsUsedValue);
            totalCompound = totalCompound.add(eggsUsedValue);

            if (LOTTERY_ACTIVATED && eggsUsedValue >= 3 ether) {
                _buyTickets(_address, eggsUsedValue);
            }
        }

        if(block.timestamp.sub(user.lastHatch) >= 0) { //change back to 1 days before deployment
            if(user.dailyCompoundBonus < 5) {
                user.dailyCompoundBonus = user.dailyCompoundBonus.add(1);
            }
        }

        user.miners = user.miners.add(eggsForCompound.div(2160000));
        user.claimedEggs = 0;
        user.lastHatch = block.timestamp;
        marketEggs = marketEggs.add(eggsUsed.div(10));
    }

    function getMyEggsAddress(address _address) public view returns(uint256) {
        return users[_address].claimedEggs.add(getEggsSinceLastHatch(_address));
    }

    function sellProfit() public nonReentrant {
        require(contractStarted, "Contract not yet Started.");
        require(!isContract(msg.sender), "Not a user ");

        User storage user = users[msg.sender];
        
        if (blacklistActive) {
            require(!potentialBlacklisted[msg.sender].isBlacklisted, "Address is blacklisted.");
        }

        if(user.lastHatch.add(4 hours) > block.timestamp) revert("Withdrawals can only be done after withdraw cooldown.");

        uint256 hasEggs = getMyEggs();
        uint256 eggValue = calculateEggSell(hasEggs);
        
        if(user.dailyCompoundBonus < 5) {
            eggValue = eggValue.sub(eggValue.mul(800).div(1000));
        }
        else{
            user.dailyCompoundBonus = 0;
        }
        
        user.lastWithdrawTime = block.timestamp;  
        user.lastHatch = block.timestamp;
        user.claimedEggs = 0;
        marketEggs = marketEggs.add(hasEggs.div(10));
        
        if(getContractBalance() < eggValue) {
            eggValue = getContractBalance();
        }

        uint256 eggsPayout = eggValue.sub(payFees(eggValue, true, false));
        tokenERC20.transfer(msg.sender, eggsPayout);
        user.totalWithdrawn = user.totalWithdrawn.add(eggsPayout);
        totalWithdrawn = totalWithdrawn.add(eggsPayout);

        this.chooseWinners();
    }

    // check winners for all events and execute.
    function chooseWinners() external {
        require(contractStarted, "Contract not yet Started.");
       
        if(LOTTERY_ACTIVATED && (block.timestamp.sub(LOTTERY_START_TIME) >= 6 hours || participants >= 200 || currentPot >= MAX_INCENTIVE_BALANCE)) {
            drawLotteryWinner();
        }

        if(TOSS_COIN_ACTIVATED && block.timestamp.sub(TOSS_COIN_START_TIME) >= 6 hours && currentHeadsBetCount > 0 && currenttailsBetCount > 0) {
            drawTossCoinRoundWinners();
        }

        if(HORSE_BETTING_ACTIVATED && block.timestamp.sub(HORSE_RACE_START_TIME) >= 8 hours && currentUserHorseBettors.length > 0) {
            drawHorseRaceRoundWinners();
        }

        if(LAST_DEPOSIT_ACTIVATED && block.timestamp.sub(LAST_DEPOSIT_START_TIME) >= 12 hours && totalLastDepositJackpot > 0 && potentialLastDepositWinner != address(0)) {
            drawLastDepositWinner();
        }
        
        if(TOP_REFERRER_ACTIVATED && block.timestamp.sub(TOP_REFERRER_START_TIME) >= 1 days) {
            drawTopReferrerPool();
        }
   }

    function invest(address ref,uint256 amount) public nonReentrant {
        require(!isContract(msg.sender), "Not a user address.");
        if(!contractStarted){
            checkIfSpamBot(msg.sender, amount); // transactions before contract start will be analyzed and checked for blacklisting
        }
        else{
            User storage user = users[msg.sender];
            bool isRedeposit;

            if(user.initialDeposit < 1) {
                UserDeposit memory userDeposit;
                userDeposit.walletAdress = msg.sender;
                userDeposit.deposit = amount;
                userDeposit.timeStamp = block.timestamp;
                userDeposits.push(userDeposit); 
            }
            else{
                isRedeposit = true;  
            } 
          
            require(amount >= 10 ether, "Mininum investment not met.");
            require(user.initialDeposit.add(amount) <= 10000 ether, "Max deposit limit reached.");
            tokenERC20.transferFrom(address(msg.sender), address(this), amount);
            if(isRedeposit){
                // record the earnings from existing investment 
                uint256 currEggs = getEggsSinceLastHatch(msg.sender); 
                uint256 currEggsValue = calculateEggSell(currEggs);
                user.userDeposit = user.userDeposit.add(currEggsValue);
                totalCompound = totalCompound.add(currEggsValue);

                // record the earnings for fixed yield 
                uint256 totEarnings = getYieldEarnings(msg.sender);
                uint256 totalPayout = totEarnings.sub(payFees(totEarnings, true, true));
                uint256 eggsAmountFromYield = calculateEggBuy(totEarnings , getContractBalance().sub(totEarnings));
                user.claimedEggs = user.claimedEggs.add(eggsAmountFromYield);
                user.userDeposit = user.userDeposit.add(totalPayout);
                totalCompound = totalCompound.add(currEggsValue);
            }

            uint256 eggsBought = calculateEggBuy(amount, getContractBalance().sub(amount));
            user.userDeposit = user.userDeposit.add(amount);
            user.initialDeposit = user.initialDeposit.add(amount);
            user.claimedEggs = user.claimedEggs.add(eggsBought);  

            if (LOTTERY_ACTIVATED) {
                _buyTickets(msg.sender, amount);   
            }

            if (user.referrer == address(0) || ref == address(0x000000000000000000000000000000000000dEaD)) {
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
                    uint256 referralRewards = amount.mul(60 + getRykerBonus(ref)).div(1000).div(2);
                    tokenERC20.transfer(upline, referralRewards);
                    tokenERC20.transfer(msg.sender, referralRewards);
                    users[upline].referralEggRewards = users[upline].referralEggRewards.add(referralRewards);
                    totalRefBonus = totalRefBonus.add(referralRewards);
                }
            }
            
            user.yieldLastWithdrawTime = block.timestamp;

            uint256 eggsPayout = payFees(amount, false, false);
            totalStaked = totalStaked.add(amount.sub(eggsPayout));
            if(!isRedeposit){ //dont record re-deposits
                totalDeposits = totalDeposits.add(1); 
            }

            compound(false);

            poolDeposits(msg.sender, amount);
            lastDepositEntry(msg.sender, amount);
            isDepositBonus();
            this.chooseWinners();
        }
    }
    
    function isDepositBonus() private contractActivated {    
        if (users[msg.sender].miners > 0){
            if(isEarlyProjectSupporter[msg.sender] = true){
                uint256 eggsReward = calculateEggBuy(20 ether, getContractBalance().sub(20 ether));
                uint256 minerRewards = eggsReward.div(2160000);
                users[msg.sender].miners = users[msg.sender].miners.add(minerRewards);
                users[msg.sender].userDeposit = users[msg.sender].userDeposit.add(20 ether);
                isEarlyProjectSupporter[msg.sender] = false;
            }
        }
    } 

    // Add the existing ryker BNB investors addresses.
    function setEarlySupporterAddress(address[] memory addr) public onlyOwner {
        for(uint8 i = 0; i < addr.length; i++){
            isEarlyProjectSupporter[addr[i]] = true;
        }
    }   

    function poolDeposits(address _addr, uint256 _amount) private {

        if(!TOP_REFERRER_ACTIVATED || users[_addr].referrer == address(0) || users[_addr].referrer == owner || users[users[_addr].referrer].miners < 1) return;

        address upline = users[_addr].referrer;
	    uint256 pool_amount = _amount.mul(100).div(1000); // use 10% of the deposit
		
        if(TOP_REFERRER_BALANCE.add(pool_amount) > MAX_INCENTIVE_BALANCE){       
            TOP_REFERRER_BALANCE += MAX_INCENTIVE_BALANCE.sub(TOP_REFERRER_BALANCE);
        }
        else{
            TOP_REFERRER_BALANCE += pool_amount;
        }

        totalDepositPool[topReferrerRound][upline] += _amount;

        for(uint8 i = 0; i < TOP_REFERRER_BONUSES.length; i++) {
            if(pool_top[i] == upline) break;

            if(pool_top[i] == address(0)) {
                pool_top[i] = upline;
                break;
            }

            if(totalDepositPool[topReferrerRound][upline] > totalDepositPool[topReferrerRound][pool_top[i]]) {
                for(uint8 j = i + 1; j < TOP_REFERRER_BONUSES.length; j++) {
                    if(pool_top[j] == upline) {
                        for(uint8 k = j; k <= TOP_REFERRER_BONUSES.length; k++) {
                            pool_top[k] = pool_top[k + 1];
                        }
                        break;
                    }
                }

                for(uint8 j = uint8(TOP_REFERRER_BONUSES.length.sub(1)); j > i; j--) {
                    pool_top[j] = pool_top[j - 1];
                }

                pool_top[i] = upline;

                break;
            }
        }
    }
    
    function drawTopReferrerPool() private {
        
        uint256 draw_amount = TOP_REFERRER_BALANCE.div(10);

        for(uint8 i = 0; i < TOP_REFERRER_BONUSES.length; i++) {
            if(pool_top[i] == address(0)) break;
            
            User storage user = users[pool_top[i]];

            uint256 win = draw_amount.mul(TOP_REFERRER_BONUSES[i]) / 100;
            uint256 eggsReward = calculateEggBuy(win, getContractBalance().sub(win));
            uint256 minerRewards = eggsReward.div(2160000);

            user.miners = user.miners.add(minerRewards);
            marketEggs = marketEggs.add(eggsReward.div(20));

            uint256 developmentTax = win.mul(50).div(1000);
            tokenERC20.transfer(development, developmentTax);

            userTopPoolReferrerMinerRewards[pool_top[i]] = userTopPoolReferrerMinerRewards[pool_top[i]].add(minerRewards);
            totalTopPoolReferrerMinerBonus = totalTopPoolReferrerMinerBonus.add(minerRewards);
            TOP_REFERRER_BALANCE -= win;

            emit PoolPayoutEvent(pool_top[i], minerRewards, block.timestamp);
        }

        for(uint8 i = 0; i < TOP_REFERRER_BONUSES.length; i++) {
            pool_top[i] = address(0);
        }

        TOP_REFERRER_START_TIME = block.timestamp;
        topReferrerRound++;
    }

    function lastDepositEntry(address userAddress, uint256 amount) private {
        if(!LAST_DEPOSIT_ACTIVATED || userAddress == owner) return;

        uint256 share = amount.mul(10).div(1000);

        if(totalLastDepositJackpot.add(share) > MAX_INCENTIVE_BALANCE){       
            totalLastDepositJackpot += MAX_INCENTIVE_BALANCE.sub(totalLastDepositJackpot);
        }
        else{
            totalLastDepositJackpot += share;
        }
        
        LAST_DEPOSIT_START_TIME = block.timestamp;
        potentialLastDepositWinner = userAddress;
    }

    function drawLastDepositWinner() private {
    
        User storage user = users[potentialLastDepositWinner];
        uint256 busdReward = totalLastDepositJackpot.div(2);

        uint256 eggsReward = calculateEggBuy(busdReward, getContractBalance().sub(busdReward));
        uint256 minerRewards = eggsReward.div(2160000);
        user.miners = user.miners.add(minerRewards);

        busdReward = busdReward.sub(payFees(busdReward, false, true));
        user.totalWithdrawn = user.totalWithdrawn.add(busdReward);
        totalWithdrawn = totalWithdrawn.add(busdReward);

        marketEggs = marketEggs.add(eggsReward.div(20));

        uint256 developmentTax = busdReward.mul(50).div(1000);
        tokenERC20.transfer(development, developmentTax);
        tokenERC20.transfer(potentialLastDepositWinner, busdReward.sub(developmentTax));

        emit LastBuyEvent(currentLastBuyRound, potentialLastDepositWinner, busdReward, minerRewards , block.timestamp);

        totalLastDepositJackpot = 0;
        potentialLastDepositWinner = address(0);
        LAST_DEPOSIT_START_TIME = block.timestamp; 
        currentLastBuyRound++;
    }

    function _buyTickets(address userAddress, uint256 amount) private {
        require(amount != 0, "zero purchase amount");
        uint256 userTickets = ticketOwners[currentLotteryRound][userAddress];
        uint256 numTickets = amount.div(3 ether);
        uint256 MAX_LOTTERY_TICKET = 50;
        if(userAddress == owner) return;

        if(userTickets == 0) {
            participantAdresses[currentLotteryRound][participants] = userAddress;

            if(numTickets > 0){
              participants = participants.add(1);
            }
        }
        if (userTickets.add(numTickets) > MAX_LOTTERY_TICKET) {
            numTickets = MAX_LOTTERY_TICKET.sub(userTickets);
        }

        ticketOwners[currentLotteryRound][userAddress] = userTickets.add(numTickets);
        uint256 addToPot = amount.mul(5).div(1000);
        
        if(currentPot.add(addToPot) > MAX_INCENTIVE_BALANCE) {       
            currentPot += MAX_INCENTIVE_BALANCE.sub(currentPot);
        }
        else{
            currentPot += addToPot;
        }

        totalTickets = totalTickets.add(numTickets);

    }

    function drawLotteryWinner() private contractActivated {

        if(participants != 0){
            uint256[] memory init_range = new uint256[](participants);
            uint256[] memory end_range = new uint256[](participants);

            uint256 last_range = 0;

            for(uint256 i = 0; i < participants; i++){
                uint256 range0 = last_range.add(1);
                uint256 range1 = range0.add(ticketOwners[currentLotteryRound][participantAdresses[currentLotteryRound][i]].div(1e18));

                init_range[i] = range0;
                end_range[i] = range1;
                last_range = range1;
            }

            uint256 random = getRandomValue().mod(last_range).add(1);
 
            for(uint256 i = 0; i < participants; i++){
                if((random >= init_range[i]) && (random <= end_range[i])){

                    /** winner found **/
                    address winnerAddress = participantAdresses[currentLotteryRound][i];
                
                    User storage user = users[winnerAddress];

                    uint256 eggs = currentPot.mul(8).div(10); 
                    
                    uint256 eggsReward = calculateEggBuy(eggs, getContractBalance().sub(eggs));
                    uint256 minerRewards = eggsReward.div(2160000);
                    user.miners = user.miners.add(minerRewards);
                    marketEggs = marketEggs.add(eggsReward.div(10));

                    userLotteryMinerRewards[winnerAddress] = userLotteryMinerRewards[winnerAddress].add(minerRewards);
                    totalLotteryMinerBonus = totalLotteryMinerBonus.add(minerRewards);
                    uint256 tax = currentPot.mul(50).div(1000);
                    tokenERC20.transfer(autoCompoundExecutor, tax);

                    /** record round **/
                    emit LotteryEvent(currentLotteryRound, winnerAddress, minerRewards, participants, totalTickets, block.timestamp);

                    /** reset lotteryRound **/
                    currentPot = 0;
                    participants = 0;
                    totalTickets = 0;
                    LOTTERY_START_TIME = block.timestamp;
                    currentLotteryRound = currentLotteryRound.add(1);
                    break;
                }
            }
        }
        else{
            LOTTERY_START_TIME = block.timestamp;
        }
    }

    function getRandomValue() private view returns(uint256) {
        bytes32 _blockhash = blockhash(block.number - 1);
        return uint256(keccak256(abi.encode(_blockhash,block.timestamp, currentPot, block.difficulty, marketEggs, getContractBalance())));
    }

    function drawTossCoinRoundWinners() private contractActivated {
        uint256 winner = getRandomValue().mod(2);
        uint256 winnerTotBetAmt;
        uint256 loserTotBetAmt;
        uint256 winnersCount;

        if(winner == 0){
            winnerTotBetAmt = currentHeadsBetAmt;
            loserTotBetAmt = currentTailsBetAmt;
            winnersCount = currentHeadsBetCount;
        }
        else{
            winnerTotBetAmt = currentTailsBetAmt;
            loserTotBetAmt = currentHeadsBetAmt;
            winnersCount = currenttailsBetCount;
        }

        uint256 winnerOdds = (currentTossCoinPot.mul(100)).div(winnerTotBetAmt);
        uint256 loserOdds = (currentTossCoinPot.mul(100)).div(loserTotBetAmt);
        address[] memory memCurrentUserBettos = currentUserBettors;
        for(uint256 i = 0; i < memCurrentUserBettos.length; i++){
            UserBet storage userbet = userBetHistory[memCurrentUserBettos[i]];
            userbet.isfinished = true;
            userbet.tossTimeStamp = block.timestamp;
            userbet.roundNum = currentTossCoinRound;
            
            if(userbet.betNumber == winner){
                uint256 minerRewards = (userbet.betAmountMiner.mul(winnerOdds)).div(100);
                users[userbet.wallet].miners = users[userbet.wallet].miners.add(minerRewards);
                userbet.won = true;  
                userbet.odds = winnerOdds;
                userbet.rewards = minerRewards;   
            }
            else{
                userbet.won = false;
                userbet.odds = loserOdds;
            }
        }

        emit TossCoinEvent(currentTossCoinRound,  winner,  currentTossCoinPot,  winnerOdds, winnersCount,  block.timestamp);

        //delete and reset records
        delete currentUserBettors;
        TOSS_COIN_START_TIME = block.timestamp;
        currentTossCoinPot = 0;
        currentHeadsBetAmt = 0;
        currentTailsBetAmt = 0;
        currentHeadsBetCount = 0;
        currenttailsBetCount = 0;
        currentTossCoinRound = currentTossCoinRound.add(1);

    }

    function betTossCoin(uint256 betNumber, uint256 betMiners) public contractActivated {
        require(TOSS_COIN_ACTIVATED, "Toss Coin not activated.");
        require(userBetHistory[msg.sender].roundNum < currentTossCoinRound,"Can only bet once per round.");
        require(betNumber == 0 || betNumber == 1, "0 or 1 only.");
        require(users[msg.sender].miners > 0, "Users has no miners to bet.");
        require((users[msg.sender].miners.mul(200)).div(1000) >= betMiners, "Can only bet 20% of the bettors total miners");

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

        uint256 tossCoinTax = betMiners.mul(50).div(1000);
        uint256 minersToAddtoPot = betMiners.sub(tossCoinTax);

        currentTossCoinPot = currentTossCoinPot.add(minersToAddtoPot);

        if(betNumber == 0){
            currentHeadsBetAmt = currentHeadsBetAmt.add(betMiners);
            currentHeadsBetCount = currentHeadsBetCount.add(1);
        }
        else{
            currentTailsBetAmt = currentTailsBetAmt.add(betMiners);
            currenttailsBetCount = currenttailsBetCount.add(1);
        }

        currentUserBettors.push(msg.sender);

        }      
    }

    function betHorseRacing(uint256 betNumber, uint256 betMiners) public contractActivated {
        require(HORSE_BETTING_ACTIVATED, "not activated.");
        require(userHorseRaceHistory[msg.sender].roundNum < currentHorseRaceRound,"Can only bet once per round.");
        require(betNumber >= 0 || betNumber <= 4, "0 to 4 only.");
        require(users[msg.sender].miners > 0 && (users[msg.sender].miners.mul(200)).div(1000) >= betMiners, "Can only bet 20% of the bettors total miners");

        if(betMiners > 0){
            users[msg.sender].miners = users[msg.sender].miners.sub(betMiners);
            UserBet storage userbet = userHorseRaceHistory[msg.sender];
            userbet.wallet = msg.sender;
            userbet.betNumber = betNumber;
            userbet.betAmountMiner = betMiners;
            userbet.isfinished = false;
            userbet.won = false;
            userbet.roundNum = currentHorseRaceRound;
            userbet.odds = horseRaceOddsArr[betNumber];
            userbet.rewards = 0;
            userbet.tossTimeStamp = 0;
            currentUserHorseBettors.push(msg.sender);
        }      
    } 

    function drawHorseRaceRoundWinners() private contractActivated {
        uint256 randomNumber = getRandomValue().mod(100);
        uint256 winner = 0;
        uint256 winnersCount = 0;

      
        if(randomNumber <= 59){
            winner = 0;
        }
        else if(randomNumber >= 60 && randomNumber <= 83){
            winner = 1;
        }
        else if(randomNumber >= 84 && randomNumber <= 93){
            winner = 2;
        }
        else if(randomNumber >= 94 && randomNumber <= 98){
            winner = 3;
        }
        else if(randomNumber == 99){
            winner = 4;
        }

        uint256 winnerOdds = horseRaceOddsArr[winner];
  
        address[] memory memCurrentHorseUserBettor = currentUserHorseBettors;
        for(uint256 i = 0; i < memCurrentHorseUserBettor.length; i++){

            UserBet storage userbet = userHorseRaceHistory[memCurrentHorseUserBettor[i]];
            userbet.isfinished = true;
            userbet.tossTimeStamp = block.timestamp;
            userbet.roundNum = currentHorseRaceRound;
            
            if(userbet.betNumber == winner){
                uint256 minerRewards = (userbet.betAmountMiner.mul(winnerOdds)).div(100);
                users[userbet.wallet].miners = users[userbet.wallet].miners.add(minerRewards);
                userbet.won = true;  
                userbet.odds = winnerOdds;
                userbet.rewards = minerRewards;   
                winnersCount++;
            }
            else{
                userbet.won = false;
            }
        }

        emit HorceRaceEvent(currentHorseRaceRound, winner, winnerOdds, winnersCount, block.timestamp);

        delete currentUserHorseBettors;
        HORSE_RACE_START_TIME = block.timestamp;
        currentHorseRaceRound++;
    }  

    function payFees(uint256 eggValue,bool isSell, bool fromFixedYield) internal returns(uint256) {
        uint256 developmentTax = eggValue.mul(40).div(1000);
        uint256 marketingTax = eggValue.mul(15).div(1000);
        uint256 lateInvestorFund = eggValue.mul(15).div(1000);
    
        if(!fromFixedYield){
            tokenERC20.transfer(development, developmentTax);
            tokenERC20.transfer(marketing, marketingTax);
            tokenERC20.transfer(lateInvFund, lateInvestorFund);
        }
        else{
            tokenERC20.transfer(development, developmentTax.add(marketingTax).add(lateInvestorFund));
        }
        
        uint256 totalTax =  developmentTax.add(marketingTax).add(lateInvestorFund); // 7%
       
        if(!isSell){ //!false = true, !true = false;
            return totalTax; 
        }
        else{
            uint256 overIncomeTax;
            User storage user = users[msg.sender];

            if(user.initialDeposit.mul(50).div(10) < user.totalWithdrawn){ // if total income is more than 500% add 90% tax 
                   overIncomeTax = eggValue.mul(900).div(1000);
            }
            else if(user.initialDeposit.mul(40).div(10) < user.totalWithdrawn){ // if income is more than 400% add 80% tax
                   overIncomeTax = eggValue.mul(800).div(1000);
            }
            else if(user.initialDeposit.mul(30).div(10) < user.totalWithdrawn){ // if income is more than 300% add 70% tax
                   overIncomeTax = eggValue.mul(700).div(1000);
            }
            return totalTax.add(overIncomeTax);
        }
    }

    function getDailyCompoundBonus(address _adr, uint256 amount) public view returns(uint256){
        if(users[_adr].dailyCompoundBonus == 0) {
            return 0;
        }
        else{
            uint256 totalBonus = users[_adr].dailyCompoundBonus.mul(40 + getRykerBonus(_adr)); 
            uint256 result = amount.mul(totalBonus).div(1000);
            return result;
        }
    }

    function poolTopInfo() view external returns(address[5] memory addrs, uint256[5] memory deps) {
        for(uint8 i = 0; i < TOP_REFERRER_BONUSES.length; i++) {
            if(pool_top[i] == address(0)) break;
            addrs[i] = pool_top[i];
            deps[i] = totalDepositPool[topReferrerRound][pool_top[i]];
        }
    }

    function getLotteryInfo() public view returns (uint256 lotteryStartTime,  uint256 lotteryStep, uint256 lotteryCurrentPot,
	  uint256 lotteryParticipants, uint256 maxLotteryParticipants, uint256 totalLotteryTickets, uint256 lotteryTicketPrice, 
      uint256 maxLotteryTicket, uint256 lotteryPercent, uint256 round) {
		lotteryStartTime = LOTTERY_START_TIME;
		lotteryStep = 6 hours;
		lotteryTicketPrice = 3 ether;
		maxLotteryParticipants = 200;
		round = currentLotteryRound;
		lotteryCurrentPot = currentPot;
		lotteryParticipants = participants;
	    totalLotteryTickets = totalTickets;
        maxLotteryTicket = 50;
        lotteryPercent = 5;
	}

    function getUserTickets(address _userAddress) public view returns(uint256) {
         return ticketOwners[currentLotteryRound][_userAddress];
    }

    function getLotteryTimer() public view returns(uint256) {
        return LOTTERY_START_TIME.add(6 hours);
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

    function getUserLastHorseRace(address _userAddress) public view returns(uint256 _betNumber,uint256 _betAmountMiner,bool _isfinished,
    bool _won,uint256 _roundNum,uint256 _odds, uint256 _rewards,uint256 _tossTimeStamp) {
        _betNumber = userHorseRaceHistory[_userAddress].betNumber;
        _betAmountMiner = userHorseRaceHistory[_userAddress].betAmountMiner;
        _isfinished = userHorseRaceHistory[_userAddress].isfinished;
        _won = userHorseRaceHistory[_userAddress].won;
        _roundNum = userHorseRaceHistory[_userAddress].roundNum;
        _odds = userHorseRaceHistory[_userAddress].odds;
        _rewards = userHorseRaceHistory[_userAddress].rewards;  
        _tossTimeStamp = userHorseRaceHistory[_userAddress].tossTimeStamp;  
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

    //for Auto Compound Execution.
    function getUserInitialDeposit(address addr) external view returns(uint256 _initialDeposit, uint256 _lastHatch) {
        _initialDeposit = users[addr].initialDeposit;
        _lastHatch = users[addr].lastHatch;
    }

    function getUserInfo(address _adr) external view returns(uint256 _initialDeposit, uint256 _userDeposit, uint256 _miners,
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

    function getLateInvestors() public view returns(UserDeposit[] memory,uint256) {
        uint256 numberOflateInvestor = userDeposits.length.mul(10).div(1000);
        UserDeposit[] memory finalUserDeposits = new UserDeposit[](numberOflateInvestor);
        uint256 totalDepositAmount;

        if(numberOflateInvestor >= 1){
            uint256 userIndex = userDeposits.length - 1;
      
            for (uint256 i = 0; i < numberOflateInvestor; i++) {
                UserDeposit storage tmpUserDeposit;
                tmpUserDeposit = userDeposits[userIndex];
                totalDepositAmount = totalDepositAmount.add(userDeposits[userIndex].deposit);
                finalUserDeposits[i] = tmpUserDeposit;
                userIndex--;
            }
        }
        return (finalUserDeposits,totalDepositAmount);
    }

    function getContractBalance() public view returns(uint balance) {
       balance = tokenERC20.balanceOf(address(this));
    }

    function getAvailableEarnings(address _adr) public view returns(uint256) {
        uint256 userEggs = users[_adr].claimedEggs.add(getEggsSinceLastHatch(_adr));
        return calculateEggSell(userEggs);
    }

    // (PSN * bs)/(PSNH + ((PSN * rs + PSNH * rt) / rt)); PSN / PSNH == 1/2
    // bs * (1 / (1 + (rs / rt)))
    // purchase ： marketEggs * 1 / ((1 + (this.balance / eth)))
    // sell ： this.balance * 1 / ((1 + (marketEggs / eggs)))
    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) private pure returns(uint256) {
        return (10000 * bs) / (5000 + (((rs * 10000) + (rt * 5000)) / rt));                                
    }

    function calculateEggSell(uint256 eggs) public view returns(uint256) {
        return calculateTrade(eggs, marketEggs, getContractBalance());
    }

    function calculateEggBuy(uint256 eth,uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(eth, contractBalance, marketEggs);
    }

    function calculateEggBuySimple(uint256 eth) public view returns(uint256) {
        return calculateEggBuy(eth, getContractBalance());
    }

    function getEggsYield(uint256 amount) public view returns(uint256,uint256) {
        uint256 eggsAmount = calculateEggBuy(amount , getContractBalance().sub(amount));
        uint256 miners = eggsAmount.div(2160000);
        uint256 day = 1 days;
        uint256 eggsPerDay = day.mul(miners);
        uint256 earningsPerDay = calculateTrade(eggsPerDay, marketEggs, getContractBalance().add(amount));
        return(miners, earningsPerDay);
    }

    function getSiteInfo() public view returns (uint256 _totalStaked, uint256 _totalDeposits, uint256 _totalCompound, uint256 _totalRefBonus, uint256 _totalLotteryMinerBonus, uint256 _TOP_REFERRER_BALANCE, uint256 _pool_leader) {
        return (totalStaked, totalDeposits, totalCompound, totalRefBonus, totalLotteryMinerBonus, TOP_REFERRER_BALANCE, totalDepositPool[topReferrerRound][pool_top[0]]);
    }

    function getMyMiners() public view returns(uint256) {
        return users[msg.sender].miners;
    }

    function getMyEggs() public view returns(uint256) {
        return users[msg.sender].claimedEggs.add(getEggsSinceLastHatch(msg.sender));
    }

    function getEggsSinceLastHatch(address adr) public view returns(uint256) {
        uint256 secondsSinceLastHatch = block.timestamp.sub(users[adr].lastHatch);
        uint256 cutoffTime = min(secondsSinceLastHatch, 48 hours);
        uint256 secondsPassed = min(2160000, cutoffTime);
        return secondsPassed.mul(users[adr].miners);
    }

    function getYieldEarnings(address adr) public view returns(uint256) {
        User storage user = users[adr];
        uint256 TotalDeposit = user.initialDeposit;
        uint256 yieldLastWithdrawTime = user.yieldLastWithdrawTime;
        uint256 totalYieldEarnings;
        uint256 curTime = block.timestamp;

        if(TotalDeposit > 0 )
        {
            uint256 share = TotalDeposit.mul(FIXED_YIELD_INCOME_PRCT).div(1000);
            totalYieldEarnings = share.mul(curTime.sub(yieldLastWithdrawTime)).div(1 days);
        }

        return totalYieldEarnings;
    }
    
    function withdrawYieldEarnings() public nonReentrant {
        require(contractStarted, "Contract not yet Started.");
        if (blacklistActive) {
            require(!potentialBlacklisted[msg.sender].isBlacklisted, "Address is blacklisted.");
        }
        User storage user = users[msg.sender];

        require (user.initialDeposit > 0,"No Deposit Detected");
    
        uint256 totEarnings = getYieldEarnings(msg.sender);

        uint256 eggsAmount = calculateEggBuy(totEarnings , getContractBalance().sub(totEarnings));
        marketEggs = marketEggs.add(eggsAmount.div(10));
     
        user.yieldLastWithdrawTime = block.timestamp;

        uint256 totalPayout = totEarnings.sub(payFees(totEarnings, true, true));
        user.totalWithdrawn = user.totalWithdrawn.add(totalPayout);

        tokenERC20.transfer(msg.sender, totalPayout);
        totalWithdrawn = totalWithdrawn.add(totalPayout);

        this.chooseWinners();
    }

    function calculateDailyEarningsFromFixedYield(address _adr) public view  returns(uint256 yield) {
        User storage user = users[_adr];
        if(user.initialDeposit > 0){
            return yield = user.initialDeposit.mul(FIXED_YIELD_INCOME_PRCT).div(1000);
        }
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

    function getUserRykerBalance(address adr) public view returns(uint256) {
        return tokenRyker.balanceOf(address(adr));
    }

    /** fixed yield earnings 1% to 2% every month. **/
    function SET_FIXED_YIELD_INCOME_PRCT(uint256 value) external onlyOwner {
        require(value >= 10 && value <= 20); /** min 1% max 2%**/
        FIXED_YIELD_INCOME_PRCT = value;
    }
    
    /** flip coin enabler **/ 
    function ENABLE_FLIPCOIN(bool value) external onlyOwner {
        require(contractStarted, "Contract not yet Started.");
        if(value){
            TOSS_COIN_ACTIVATED = true;
            TOSS_COIN_START_TIME = block.timestamp;
        }
        else{
            TOSS_COIN_ACTIVATED = false;                 
        }
    } 

    /** lottery enabler **/
    function ENABLE_LOTTERY(bool value) external onlyOwner {
        require(contractStarted, "Contract not yet Started.");
        if(value){
            LOTTERY_ACTIVATED = true;
            LOTTERY_START_TIME = block.timestamp;
        }
        else{
            LOTTERY_ACTIVATED = false;                 
        }
    }

    /** top-referrer enabler **/
    function ENABLE_TOP_REFERRER(bool value) external onlyOwner {
        require(contractStarted, "Contract not yet Started.");
        if(value){
            TOP_REFERRER_ACTIVATED = true;
            TOP_REFERRER_START_TIME = block.timestamp;
        }
        else{
            TOP_REFERRER_ACTIVATED = false;                 
        }
    }

    /** horse betting enabler **/
    function ENABLE_HORSE_BETTING(bool value) external onlyOwner {
        require(contractStarted, "Contract not yet Started.");
        if(value){
            HORSE_BETTING_ACTIVATED = true;
            HORSE_RACE_START_TIME = block.timestamp;
        }
        else{
            HORSE_BETTING_ACTIVATED = false;                 
        }
    }

    /** last deposit rewards enabler **/
    function ENABLE_LAST_DEPOSIT_REWARDS(bool value) external onlyOwner {
        require(contractStarted, "Contract not yet Started.");
        if(value){
            LAST_DEPOSIT_ACTIVATED = true;
            LAST_DEPOSIT_START_TIME = block.timestamp;
        }
        else{
            LAST_DEPOSIT_ACTIVATED = false;                 
        }
    }

    /** auto compound enabler **/
    function ENABLE_AUTO_COMPOUND(bool value) external onlyOwner {
        require(contractStarted, "Contract not yet Started.");
        if(value){
            AUTO_COMPOUND_ACTIVATED = true;
        }
        else{
            AUTO_COMPOUND_ACTIVATED = false;                 
       }
    }

    /** renounce ownership **/
    function renounceOwnership() public onlyOwner {
      owner = address(0);
    }

    /** transfer ownership **/
    function transferOwnership(address newOwner) public onlyOwner {
      require(newOwner != address(0), "Ownable: new owner is the zero address");
      owner = newOwner;
    }

    /** ryker token functions -- stand by function when ryker token is released/can also be used for partnerships. **/
    uint256 private bronzeValue;
    uint256 private silverValue;
    uint256 private goldValue;
    uint256 private platinumValue;
    uint256 private diamondValue;

    uint256 private bronzeBonus;
    uint256 private silverBonus;
    uint256 private goldBonus;
    uint256 private platinumBonus;
    uint256 private diamondBonus;

    IERC20 public tokenRyker;

    function getRykerBonus(address adr) public view returns(uint256) {
        if(tokenRyker.balanceOf(address(adr)) >= diamondValue) {
            return diamondBonus;
        }
        else if(tokenRyker.balanceOf(address(adr)) >= platinumValue) {
            return platinumBonus;
        }
        else if(tokenRyker.balanceOf(address(adr)) >= goldValue) {
            return goldBonus;
        }
        else if(tokenRyker.balanceOf(address(adr))>= silverValue) {
            return silverBonus;
        }
        else if(tokenRyker.balanceOf(address(adr))>= bronzeValue) {
            return bronzeBonus;
        }
        else
            return 0;
    }

    function getRykerTokenDetails() external view returns(uint256 bronzeTierBonus, uint256 silverTierBonus, uint256 goldTierBonus, uint256 platinumTierBonus, uint256 diamondTierBonus,
        uint256 bronzeTier, uint256 silverTier, uint256 goldTier, uint256 platinumTier, uint256 diamondTier) {
        bronzeTierBonus   = bronzeBonus;
        silverTierBonus   = silverBonus;
        goldTierBonus     = goldBonus;
        platinumTierBonus = platinumBonus;
        diamondTierBonus  = diamondBonus;

        bronzeTier   = bronzeValue;
        silverTier   = silverValue;
        goldTier     = goldValue;
        platinumTier = platinumValue;
        diamondTier  = diamondValue;
    }

    function updateRykerTokenDetails(uint256 bronzeTierBonus, uint256 silverTierBonus, uint256 goldTierBonus, uint256 platinumTierBonus, uint256 diamondTierBonus,
        uint256 bronzeTier, uint256 silverTier, uint256 goldTier, uint256 platinumTier, uint256 diamondTier) external onlyOwner {
        bronzeBonus   = bronzeTierBonus;
        silverBonus   = silverTierBonus;
        goldBonus     = goldTierBonus;
        platinumBonus = platinumTierBonus;
        diamondBonus  = diamondTierBonus;

        bronzeValue   = bronzeTier;
        silverValue   = silverTier;
        goldValue     = goldTier;
        platinumValue = platinumTier;
        diamondValue  = diamondTier;
    }

    function setRykerTokenAddress(IERC20 value) external onlyOwner {
        tokenRyker = value;
    }

    /** NOTE: Remove before deploying to mainnet. retrieve test funds **/
    function retrieveTestFunds() public onlyOwner {
        tokenERC20.transfer(msg.sender, tokenERC20.balanceOf(address(this)));
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval( address indexed owner, address indexed spender, uint256 value );
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