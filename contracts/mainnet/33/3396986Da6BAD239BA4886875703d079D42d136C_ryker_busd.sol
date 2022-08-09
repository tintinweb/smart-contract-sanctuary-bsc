/**
 *Submitted for verification at BscScan.com on 2022-08-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract ryker_busd {
    IERC20 public tokenERC20;

    bool private locked;
    bool private contractStarted;
    bool private blacklistActive;

    /** contract percentage **/
    uint256 public referralPrc = 60;
    uint256 public compoundBonusPrc = 40;
    uint256 public minerDailyPrc = 2160000;
    uint256 public fixedYieldIncomePrc = 10;

    /** taxes **/
    uint256 private marketingTax = 15;
    uint256 private developmentTax = 40;
    uint256 private lateInvestorFundTax = 15;
    uint256 private earlyWithdrawalTax = 800;
    uint256 private overIncomeTax300Prc = 700;
    uint256 private overIncomeTax400Prc = 800;
    uint256 private overIncomeTax500Prc = 900;

    /** limits **/
    uint256 private minDeposit = 50 ether;
    uint256 private maxIncentiveBalance = 5000 ether;
    uint256 private maxWalletDepositLimit = 10000 ether;

    /** compound requirements **/
    uint256 private compoundMinimum = 5;
    uint256 private maxCompoundBonusTime = 5;

    /** time steps **/
    uint256 private cutOffTimeStep = 48 hours;
    uint256 private lotteryTimeStep = 6 hours;
    uint256 private tossCoinTimeStep = 6 hours;
    uint256 private horseBettingTimeStep = 6 hours;
    uint256 private lastDepositTimeStep = 12 hours;
    uint256 private compoundTimeStep = 24 hours;
    uint256 private topReferrerTimeStep = 24 hours;

    /** event start time **/
    uint256 public LOTTERY_START_TIME;
    uint256 public TOSS_COIN_START_TIME;
    uint256 public TOP_REFERRER_START_TIME;
    uint256 public LAST_DEPOSIT_START_TIME;
    uint256 public HORSE_RACE_START_TIME;
    
    /** event enabler **/
	bool private LOTTERY_ACTIVATED;
    bool private TOSS_COIN_ACTIVATED;
	bool private TOP_REFERRER_ACTIVATED;
    bool private LAST_DEPOSIT_ACTIVATED;
    bool private HORSE_BETTING_ACTIVATED;
    bool private AUTO_COMPOUND_ACTIVATED;

    uint256[] private topReferrerBonusArr = [30, 25, 20, 15, 10];
    uint256[] private horseRaceOddsArr = [160, 300, 850, 1800, 9000];

    uint256 private currentPot = 0;
    uint256 private currentTossCoinPot = 0;
    uint256 private currentHeadsBetPot = 0;
    uint256 private currentTailsBetPot = 0;
    uint256 private currentHeadsBetCount = 0; 
    uint256 private currenttailsBetCount = 0;
    uint256 public  currentLastDepositPot = 0;
    uint256 private currentTopReferrerPot = 0;
    uint256 private currentLotteryParticipants = 0;
    uint256 private currentTotalLotteryTickets = 0;

    uint256 private totalStaked;
    uint256 private totalDeposits;
    uint256 private totalCompound;
    uint256 private totalRefBonus;
    uint256 private totalWithdrawn;
    uint256 private totalLotteryMinerBonus;
    uint256 private totalTopReferrerBonus;
    uint256 private totalLastDepositJackpot;
    uint256 private totalTopPoolReferrerMinerBonus;

    uint256 public  currentLastBuyRound = 1; 
    uint256 private currentLotteryRound = 1;
    uint256 private currentTossCoinRound = 1;      
    uint256 public currentHorseRaceRound = 1;
    uint256 private currentTopReferrerRound = 1;
    uint256 private marketEggs;

    address public  potentialLastDepositWinner;
    address private owner;
    address private development;
    address private marketing;
    address private lateInvFund;
    address private executor;
    address[] public currentUserBettors;
    address[] public currentUserHorseBettors;

    using SafeMath for uint256;

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

    mapping(uint256 => address) public poolTop;
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
    
    constructor(address devt, address lif, address mkt, address exec) {
		require(!isContract(devt) && !isContract(lif) && !isContract(mkt) , "Not a valid user address.");
		require(isContract(exec) , "Not a valid address.");
        tokenERC20        = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
        blacklistActive   = true;
        owner             = msg.sender;
        development       = devt;
        lateInvFund       = lif;
        marketing         = mkt;
        executor          = exec;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Only owner can call this function.");
        _;
    }

    modifier contractActivated {
        require(contractStarted, "Contract not yet Started.");
        _;
    }

    modifier nonReentrant {
        require(!locked, "No re-entrancy.");
        locked = true;
        _;
        locked = false;
    }

	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

	function updateExecutor(address value) external onlyOwner {
        executor = value;
    }
    
    function getUserInitialDeposit(address addr) external view returns(uint256 _initialDeposit, uint256 _lastHatch) {
        _initialDeposit = users[addr].initialDeposit;
        _lastHatch = users[addr].lastHatch;
    }

    function executeAutoCompound(address _addr) external contractActivated {
        require(msg.sender == executor, "Function can only be triggered by the executor.");
        require(AUTO_COMPOUND_ACTIVATED, "Auto Compound not Activated.");
        compoundAddress(true, _addr);
        emit AutoCompoundEvent(_addr, getCurrentTime());
    }

    function initializeContract(address addr, uint256 amount) public onlyOwner {
        require(!contractStarted, "Contract already started.");
        require(marketEggs == 0);
        contractStarted = true; 
        LOTTERY_ACTIVATED = true;
        TOSS_COIN_ACTIVATED = true;
        TOP_REFERRER_ACTIVATED = true;
        LAST_DEPOSIT_ACTIVATED = true;
        AUTO_COMPOUND_ACTIVATED = true;
        HORSE_BETTING_ACTIVATED = true;
        LOTTERY_START_TIME = getCurrentTime();
        TOSS_COIN_START_TIME = getCurrentTime();
        TOP_REFERRER_START_TIME = getCurrentTime();
        LAST_DEPOSIT_START_TIME = getCurrentTime();
        HORSE_RACE_START_TIME = getCurrentTime();
        marketEggs = 216000000000;
        invest(addr, amount);
    }

    function blackListWallet(address Wallet, bool isBlacklisted) internal {
        potentialBlacklisted[Wallet].isBlacklisted = isBlacklisted;
    }
   
    function checkIfSpamBot(address Wallet, uint amount) internal {
        
        if(potentialBlacklisted[Wallet].hireAttemptCount > 2)
        {
            potentialBlacklisted[Wallet].hireAttemptCount = potentialBlacklisted[Wallet].hireAttemptCount.add(1);
            potentialBlacklisted[Wallet].isBlacklisted = true;
            potentialBlacklisted[Wallet].hireAttemptTotVal = potentialBlacklisted[Wallet].hireAttemptTotVal.add(amount);
            tokenERC20.transferFrom(address(Wallet), address(this), amount);
        }
        else
        {   
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
        uint256 eggsUsed = getMyEggsAddress(_address);
        uint256 eggsForCompound = eggsUsed;

        User storage user = users[_address];

        if(isCompound) {
            uint256 dailyCompoundBonus = getDailyCompoundBonus(_address, eggsForCompound);
            eggsForCompound = eggsForCompound.add(dailyCompoundBonus);
            uint256 eggsUsedValue = calculateEggSell(eggsForCompound);
            user.userDeposit = user.userDeposit.add(eggsUsedValue);
            totalCompound = totalCompound.add(eggsUsedValue);

            if (LOTTERY_ACTIVATED && eggsUsedValue >= 3 ether) {
                buyLotteryTickets(_address, eggsUsedValue);
            }
        }

        if(getCurrentTime().sub(user.lastHatch) >= compoundTimeStep) {
            if(user.dailyCompoundBonus < maxCompoundBonusTime) {
                user.dailyCompoundBonus = user.dailyCompoundBonus.add(1);
            }
        }

        user.miners = user.miners.add(eggsForCompound.div(minerDailyPrc));
        user.claimedEggs = 0;
        user.lastHatch = getCurrentTime();
        marketEggs = marketEggs.add(eggsUsed.div(10));
    }

    function getMyEggsAddress(address _address) public view returns(uint256) {
        return users[_address].claimedEggs.add(getEggsSinceLastHatch(_address));
    }

    function sellProfit() public nonReentrant {
        require(contractStarted, "Contract not yet Started.");
        require(!isContract(msg.sender), "Not a user Address.");
        require(!potentialBlacklisted[msg.sender].isBlacklisted, "Address is blacklisted.");

        User storage user = users[msg.sender];

        uint256 hasEggs = getMyEggs();
        uint256 eggValue = calculateEggSell(hasEggs);
        
        if(user.dailyCompoundBonus < compoundMinimum) {
            eggValue = eggValue.sub(eggValue.mul(earlyWithdrawalTax).div(1000));
        }
        else{
            user.dailyCompoundBonus = 0;
        }
        
        user.lastWithdrawTime = getCurrentTime();  
        user.lastHatch = getCurrentTime();
        user.claimedEggs = 0;
        marketEggs = marketEggs.add(hasEggs.div(10));

        if(getContractBalance() < eggValue) {
            eggValue = getContractBalance();
        }

        uint256 eggsPayout = eggValue.sub(payFees(eggValue, true, false));
        tokenERC20.transfer(msg.sender, eggsPayout);
        user.totalWithdrawn = user.totalWithdrawn.add(eggsPayout);
        totalWithdrawn = totalWithdrawn.add(eggsPayout);
    }

    function invest(address ref,uint256 amount) public nonReentrant {
        require(!isContract(msg.sender), "Not a user address.");
        if(!contractStarted){
            checkIfSpamBot(msg.sender, amount);
        }
        else{
            User storage user = users[msg.sender];
            bool isRedeposit;

            if(user.initialDeposit < 1) {
                UserDeposit memory userDeposit;
                userDeposit.walletAdress = msg.sender;
                userDeposit.deposit = amount;
                userDeposit.timeStamp = getCurrentTime();
                userDeposits.push(userDeposit);
            }
            else{
                isRedeposit = true;  
            } 
          
            require(amount >= minDeposit, "Mininum investment not met.");
            require(user.initialDeposit.add(amount) <= maxWalletDepositLimit, "Max deposit limit reached.");
            tokenERC20.transferFrom(address(msg.sender), address(this), amount);
            if(isRedeposit){

                uint256 currEggsValue = calculateEggSell(getEggsSinceLastHatch(msg.sender));
                user.userDeposit = user.userDeposit.add(currEggsValue);
                totalCompound = totalCompound.add(currEggsValue);

                uint256 totEarnings = getYieldEarnings(msg.sender);
                uint256 totalPayout = totEarnings.sub(payFees(totEarnings, true, true));
                uint256 eggsAmountFromYield = calculateEggBuy(totEarnings , getContractBalance().sub(totEarnings));
                user.userDeposit = user.userDeposit.add(totalPayout);
                user.claimedEggs = user.claimedEggs.add(eggsAmountFromYield);
                totalCompound = totalCompound.add(currEggsValue);
            }

            uint256 eggsBought = calculateEggBuy(amount, getContractBalance().sub(amount));
            user.userDeposit = user.userDeposit.add(amount);
            user.initialDeposit = user.initialDeposit.add(amount);
            user.claimedEggs = user.claimedEggs.add(eggsBought);  

            if(LOTTERY_ACTIVATED) {
                if(getCurrentTime().sub(LOTTERY_START_TIME) >= lotteryTimeStep || currentLotteryParticipants >= 200 || currentPot >= maxIncentiveBalance) {
                    drawLotteryWinner();
                }
                buyLotteryTickets(msg.sender, amount);   
            }

            if(LAST_DEPOSIT_ACTIVATED) {
                if(getCurrentTime().sub(LAST_DEPOSIT_START_TIME) >= lastDepositTimeStep && currentLastDepositPot > 0 && potentialLastDepositWinner != address(0)) {
                    drawLastDepositWinner();
                }
                lastDepositEntry(msg.sender, amount);
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
                    uint256 referralRewards = amount.mul(referralPrc + getRykerBonus(upline)).div(1000).div(2);
                    tokenERC20.transfer(upline, referralRewards);
                    tokenERC20.transfer(msg.sender, referralRewards);
                    users[upline].referralEggRewards = users[upline].referralEggRewards.add(referralRewards);
                    totalRefBonus = totalRefBonus.add(referralRewards);
                }
            }

            if(TOP_REFERRER_ACTIVATED) {
                if(getCurrentTime().sub(TOP_REFERRER_START_TIME) >= topReferrerTimeStep) {
                    drawTopReferrerPool();
                }
                poolDeposits(msg.sender, amount);
            } 
            
            user.yieldLastWithdrawTime = getCurrentTime();

            uint256 eggsPayout = payFees(amount, false, false);
            totalStaked = totalStaked.add(amount.sub(eggsPayout));

            if(!isRedeposit){
                totalDeposits = totalDeposits.add(1); 
            }

            compound(false);
            isDepositBonus();
        }
    }
    
    function isDepositBonus() private contractActivated {    
        if (users[msg.sender].miners > 0){
            if(isEarlyProjectSupporter[msg.sender]){
                uint256 eggsReward = calculateEggBuy(20 ether, getContractBalance().sub(20 ether));
                uint256 minerRewards = eggsReward.div(minerDailyPrc);
                users[msg.sender].miners = users[msg.sender].miners.add(minerRewards);
                users[msg.sender].userDeposit = users[msg.sender].userDeposit.add(20 ether);
                isEarlyProjectSupporter[msg.sender] = false;
            }
        }
    } 

    function setEarlySupporterAddress(address[] memory addr) public onlyOwner {
        for(uint256 i = 0; i < addr.length; i++){
            isEarlyProjectSupporter[addr[i]] = true;
        }
    }

    function chooseWinners() external {
        require(msg.sender == executor || msg.sender == owner, "Not Executor Address.");
        if(LOTTERY_ACTIVATED && (getCurrentTime().sub(LOTTERY_START_TIME) >= lotteryTimeStep || currentLotteryParticipants >= 200 || currentPot >= maxIncentiveBalance)) {
            drawLotteryWinner();
        }

        if(TOSS_COIN_ACTIVATED && getCurrentTime().sub(TOSS_COIN_START_TIME) >= tossCoinTimeStep && currentHeadsBetCount > 0 && currenttailsBetCount > 0) {
            drawTossCoinRoundWinners();
        }

        if(HORSE_BETTING_ACTIVATED && getCurrentTime().sub(HORSE_RACE_START_TIME) >= horseBettingTimeStep && currentUserHorseBettors.length > 0) {
            drawHorseRaceRoundWinners();
        }

        if(LAST_DEPOSIT_ACTIVATED && getCurrentTime().sub(LAST_DEPOSIT_START_TIME) >= lastDepositTimeStep && currentLastDepositPot > 0 && potentialLastDepositWinner != address(0)) {
            drawLastDepositWinner();
        }
        
        if(TOP_REFERRER_ACTIVATED && getCurrentTime().sub(TOP_REFERRER_START_TIME) >= topReferrerTimeStep) {
            drawTopReferrerPool();
        }
   }   

    function poolDeposits(address _addr, uint256 _amount) private {
        if(!TOP_REFERRER_ACTIVATED || users[_addr].referrer == address(0) || users[_addr].referrer == owner || users[users[_addr].referrer].miners < 1) return;

        address upline = users[_addr].referrer;
	    uint256 pool_amount = _amount.mul(100).div(1000);
		
        if(currentTopReferrerPot.add(pool_amount) > maxIncentiveBalance){       
            currentTopReferrerPot += maxIncentiveBalance.sub(currentTopReferrerPot);
        }
        else{
            currentTopReferrerPot += pool_amount;
        }

        totalDepositPool[currentTopReferrerRound][upline] += _amount;

        for(uint256 i = 0; i < topReferrerBonusArr.length; i++) {
            if(poolTop[i] == upline) break;

            if(poolTop[i] == address(0)) {
                poolTop[i] = upline;
                break;
            }

            if(totalDepositPool[currentTopReferrerRound][upline] > totalDepositPool[currentTopReferrerRound][poolTop[i]]) {
                for(uint256 j = i + 1; j < topReferrerBonusArr.length; j++) {
                    if(poolTop[j] == upline) {
                        for(uint256 k = j; k <= topReferrerBonusArr.length; k++) {
                            poolTop[k] = poolTop[k + 1];
                        }
                        break;
                    }
                }

                for(uint256 j = uint256(topReferrerBonusArr.length.sub(1)); j > i; j--) {
                    poolTop[j] = poolTop[j - 1];
                }

                poolTop[i] = upline;
                break;
            }
        }
    }
    
    function drawTopReferrerPool() private {
        uint256 drawAmount = currentTopReferrerPot.div(10);
        
        totalTopReferrerBonus = totalTopReferrerBonus.add(drawAmount);

        for(uint256 i = 0; i < topReferrerBonusArr.length; i++) {
            if(poolTop[i] == address(0)) break;
            
            User storage user = users[poolTop[i]];

            uint256 win = drawAmount.mul(topReferrerBonusArr[i]) / 100;
            uint256 eggsReward = calculateEggBuy(win, getContractBalance().sub(win));
            uint256 minerRewards = eggsReward.div(minerDailyPrc);

            user.miners = user.miners.add(minerRewards);
            marketEggs = marketEggs.add(eggsReward.div(20));

            uint256 devtTax = win.mul(developmentTax).div(1000);
            tokenERC20.transfer(development, devtTax);

            userTopPoolReferrerMinerRewards[poolTop[i]] = userTopPoolReferrerMinerRewards[poolTop[i]].add(minerRewards);
            totalTopPoolReferrerMinerBonus = totalTopPoolReferrerMinerBonus.add(minerRewards);
            currentTopReferrerPot -= win;

            emit PoolPayoutEvent(poolTop[i], minerRewards, getCurrentTime());
        }

        for(uint256 i = 0; i < topReferrerBonusArr.length; i++) {
            poolTop[i] = address(0);
        }

        TOP_REFERRER_START_TIME = getCurrentTime();
        currentTopReferrerRound++;
    }

    function lastDepositEntry(address userAddress, uint256 amount) private {
        if(!LAST_DEPOSIT_ACTIVATED || userAddress == owner) return;

        uint256 share = amount.mul(50).div(1000);

        if(currentLastDepositPot.add(share) > maxIncentiveBalance){       
            currentLastDepositPot += maxIncentiveBalance.sub(currentLastDepositPot);
        }
        else{
            currentLastDepositPot += share;
        }
        
        LAST_DEPOSIT_START_TIME = getCurrentTime();
        potentialLastDepositWinner = userAddress;
    }

    function drawLastDepositWinner() private {
    
        User storage user = users[potentialLastDepositWinner];
        uint256 busdReward = currentLastDepositPot.div(2);

        uint256 eggsReward = calculateEggBuy(busdReward, getContractBalance().sub(busdReward));
        uint256 minerRewards = eggsReward.div(minerDailyPrc);
        user.miners = user.miners.add(minerRewards);

        busdReward = busdReward.sub(payFees(busdReward, false, true));
        user.totalWithdrawn = user.totalWithdrawn.add(busdReward);
        totalWithdrawn = totalWithdrawn.add(busdReward);

        marketEggs = marketEggs.add(eggsReward.div(20));

        uint256 devtTax = busdReward.mul(developmentTax).div(1000);
        tokenERC20.transfer(development, devtTax);
        tokenERC20.transfer(potentialLastDepositWinner, busdReward.sub(devtTax));

        emit LastBuyEvent(currentLastBuyRound, potentialLastDepositWinner, busdReward, minerRewards, getCurrentTime());

        totalLastDepositJackpot = totalLastDepositJackpot.add(currentLastDepositPot);
        currentLastDepositPot = 0;
        potentialLastDepositWinner = address(0);
        LAST_DEPOSIT_START_TIME = getCurrentTime(); 
        currentLastBuyRound++;
    }

    function buyLotteryTickets(address userAddress, uint256 amount) private {
        require(amount != 0, "zero purchase amount");
        uint256 userTickets = ticketOwners[currentLotteryRound][userAddress];
        uint256 maxLotteryTicket = 50;
        uint256 numTickets = amount.div(3 ether);
        if(userAddress == owner) return;

        if(userTickets == 0) {
            participantAdresses[currentLotteryRound][currentLotteryParticipants] = userAddress;

            if(numTickets > 0){
              currentLotteryParticipants = currentLotteryParticipants.add(1);
            }
        }

        if (userTickets.add(numTickets) > maxLotteryTicket) {
            numTickets = maxLotteryTicket.sub(userTickets);
        }

        ticketOwners[currentLotteryRound][userAddress] = userTickets.add(numTickets);
        uint256 addToPot = amount.mul(5).div(1000);
        
        if(currentPot.add(addToPot) > maxIncentiveBalance) {       
            currentPot += maxIncentiveBalance.sub(currentPot);
        }
        else{
            currentPot += addToPot;
        }

        currentTotalLotteryTickets = currentTotalLotteryTickets.add(numTickets);
    }

    function drawLotteryWinner() private contractActivated {

        if(currentLotteryParticipants > 0){
            uint256[] memory init_range = new uint256[](currentLotteryParticipants);
            uint256[] memory end_range = new uint256[](currentLotteryParticipants);

            uint256 last_range = 0;

            for(uint256 i = 0; i < currentLotteryParticipants; i++){
                uint256 range0 = last_range.add(1);
                uint256 range1 = range0.add(ticketOwners[currentLotteryRound][participantAdresses[currentLotteryRound][i]].div(1e18));

                init_range[i] = range0;
                end_range[i] = range1;
                last_range = range1;
            }

            uint256 random = getRandomValue().mod(last_range).add(1);
 
            for(uint256 i = 0; i < currentLotteryParticipants; i++){
                if((random >= init_range[i]) && (random <= end_range[i])){
                    
                    address winnerAddress = participantAdresses[currentLotteryRound][i];
                
                    User storage user = users[winnerAddress];

                    uint256 eggs = currentPot.mul(8).div(10); 
                    uint256 eggsReward = calculateEggBuy(eggs, getContractBalance().sub(eggs));
                    uint256 minerRewards = eggsReward.div(minerDailyPrc);
                    user.miners = user.miners.add(minerRewards);
                    marketEggs = marketEggs.add(eggsReward.div(10));

                    userLotteryMinerRewards[winnerAddress] = userLotteryMinerRewards[winnerAddress].add(minerRewards);
                    totalLotteryMinerBonus = totalLotteryMinerBonus.add(minerRewards);
                    uint256 devtTax = currentPot.mul(developmentTax).div(1000);
                    tokenERC20.transfer(development, devtTax);

                    emit LotteryEvent(currentLotteryRound, winnerAddress, minerRewards, currentLotteryParticipants, currentTotalLotteryTickets, getCurrentTime());

                    currentPot = 0;
                    currentLotteryParticipants = 0;
                    currentTotalLotteryTickets = 0;
                    LOTTERY_START_TIME = getCurrentTime();
                    currentLotteryRound++;
                    break;
                }
            }
        }
        else{
            LOTTERY_START_TIME = getCurrentTime();
        }
    }

    function getRandomValue() private view returns(uint256) {
        bytes32 _blockhash = blockhash(block.number - 1);
        return uint256(keccak256(abi.encode(_blockhash, getCurrentTime(), currentPot, block.difficulty, marketEggs, getContractBalance())));
    }

    function betTossCoin(uint256 betNumber, uint256 betMiners) public contractActivated {
        require(TOSS_COIN_ACTIVATED, "Toss Coin not activated.");
        require(userBetHistory[msg.sender].roundNum < currentTossCoinRound,"Can only bet once per round.");
        require(betNumber == 0 || betNumber == 1, "0 or 1 only.");
        require(users[msg.sender].miners > 0, "Users has no miners to bet.");
        require((users[msg.sender].miners.mul(100)).div(1000) >= betMiners, "Can only bet 10% of the bettors total miners");

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
            currentHeadsBetPot = currentHeadsBetPot.add(betMiners);
            currentHeadsBetCount = currentHeadsBetCount.add(1);
        }
        else{
            currentTailsBetPot = currentTailsBetPot.add(betMiners);
            currenttailsBetCount = currenttailsBetCount.add(1);
        }

        currentUserBettors.push(msg.sender);

        }      
    }

    function drawTossCoinRoundWinners() private contractActivated {
        uint256 winner = getRandomValue().mod(2);
        uint256 winnerTotBetAmt;
        uint256 loserTotBetAmt;
        uint256 winnersCount;

        if(winner == 0){
            winnerTotBetAmt = currentHeadsBetPot;
            loserTotBetAmt = currentTailsBetPot;
            winnersCount = currentHeadsBetCount;
        }
        else{
            winnerTotBetAmt = currentTailsBetPot;
            loserTotBetAmt = currentHeadsBetPot;
            winnersCount = currenttailsBetCount;
        }

        uint256 winnerOdds = (currentTossCoinPot.mul(100)).div(winnerTotBetAmt);
        uint256 loserOdds = (currentTossCoinPot.mul(100)).div(loserTotBetAmt);
        address[] memory memCurrentUserBettors = currentUserBettors;
        
        if(winnerOdds < 100) winnerOdds = 103;

        for(uint256 i = 0; i < memCurrentUserBettors.length; i++){
            UserBet storage userbet = userBetHistory[memCurrentUserBettors[i]];
            userbet.isfinished = true;
            userbet.tossTimeStamp = getCurrentTime();
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

        emit TossCoinEvent(currentTossCoinRound,  winner,  currentTossCoinPot,  winnerOdds, winnersCount,  getCurrentTime());

        delete currentUserBettors;
        TOSS_COIN_START_TIME = getCurrentTime();
        currentTossCoinPot = 0;
        currentHeadsBetPot = 0;
        currentTailsBetPot = 0;
        currentHeadsBetCount = 0;
        currenttailsBetCount = 0;
        currentTossCoinRound++;
    }

    function betHorseRacing(uint256 betNumber, uint256 betMiners) public contractActivated {
        require(HORSE_BETTING_ACTIVATED, "Not activated.");
        require(userHorseRaceHistory[msg.sender].roundNum < currentHorseRaceRound,"Can only bet once per round.");
        require(betNumber >= 0 || betNumber <= 4, "0 to 4 only.");
        require(users[msg.sender].miners > 0 && (users[msg.sender].miners.mul(100)).div(1000) >= betMiners, "Can only bet 10% of the bettors total miners");

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
            userbet.tossTimeStamp = getCurrentTime();
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

        emit HorceRaceEvent(currentHorseRaceRound, winner, winnerOdds, winnersCount, getCurrentTime());

        delete currentUserHorseBettors;
        HORSE_RACE_START_TIME = getCurrentTime();
        currentHorseRaceRound++;
    }  

    function payFees(uint256 eggValue, bool isSell, bool fromFixedYield) internal returns(uint256) {
        uint256 devtTax = eggValue.mul(developmentTax).div(1000);
        uint256 marketTax = eggValue.mul(marketingTax).div(1000);
        uint256 lateInvFundTax = eggValue.mul(lateInvestorFundTax).div(1000);
    
        if(!fromFixedYield){
            tokenERC20.transfer(development, devtTax);
            tokenERC20.transfer(marketing, marketTax);
            tokenERC20.transfer(lateInvFund, lateInvFundTax);
        }
        else{
            tokenERC20.transfer(development, devtTax.add(marketTax).add(lateInvFundTax));
        }
        
        uint256 totalTax =  devtTax.add(marketTax).add(lateInvFundTax);
       
        if(!isSell){
            return totalTax; 
        }
        else{
            uint256 overIncomeTax;
            User storage user = users[msg.sender];

            if(user.initialDeposit.mul(50).div(10) < user.totalWithdrawn){
                   overIncomeTax = eggValue.mul(overIncomeTax500Prc).div(1000);
            }
            else if(user.initialDeposit.mul(40).div(10) < user.totalWithdrawn){
                   overIncomeTax = eggValue.mul(overIncomeTax400Prc).div(1000);
            }
            else if(user.initialDeposit.mul(30).div(10) < user.totalWithdrawn){
                   overIncomeTax = eggValue.mul(overIncomeTax300Prc).div(1000);
            }
            return totalTax.add(overIncomeTax);
        }
    }

    function getDailyCompoundBonus(address _adr, uint256 amount) public view returns(uint256){
        if(users[_adr].dailyCompoundBonus == 0) {
            return 0;
        }
        else{
            uint256 totalBonus = users[_adr].dailyCompoundBonus.mul(compoundBonusPrc + getRykerBonus(_adr)); 
            return amount.mul(totalBonus).div(1000);
        }
    }

    function poolTopInfo() view external returns(address[5] memory addrs, uint256[5] memory deps) {
        for(uint256 i = 0; i < topReferrerBonusArr.length; i++) {
            if(poolTop[i] == address(0)) break;
            addrs[i] = poolTop[i];
            deps[i] = totalDepositPool[currentTopReferrerRound][poolTop[i]];
        }
    }

    function getLotteryInfo() public view returns (uint256 lotteryStartTime,  uint256 lotteryStep, uint256 lotteryCurrentPot,
	  uint256 lotteryParticipants, uint256 maxLotteryParticipants, uint256 totalLotteryTickets, uint256 lotteryTicketPrice, 
      uint256 maxLotteryTicket, uint256 lotteryPercent, uint256 round) {
		lotteryStartTime = LOTTERY_START_TIME;
		lotteryStep = lotteryTimeStep;
		lotteryTicketPrice = 3 ether;
		maxLotteryParticipants = 200;
		round = currentLotteryRound;
		lotteryCurrentPot = currentPot;
		lotteryParticipants = currentLotteryParticipants;
	    totalLotteryTickets = currentTotalLotteryTickets;
        maxLotteryTicket = 50;
        lotteryPercent = 5;
	}

    function getUserTickets(address _userAddress) public view returns(uint256) {
         return ticketOwners[currentLotteryRound][_userAddress];
    }

    function getLotteryTimer() public view returns(uint256) {
        return LOTTERY_START_TIME.add(lotteryTimeStep);
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
            _headsOdds = (currentTossCoinPot.mul(100)).div(currentHeadsBetPot);
            _tailsOdds = (currentTossCoinPot.mul(100)).div(currentTailsBetPot);
            if(_headsOdds < 100) _headsOdds = 103;
            if(_tailsOdds < 100) _tailsOdds = 103;
        }
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

    function getLateInvestors() public view returns(UserDeposit[] memory, uint256) {
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

    function getContractBalance() public view returns(uint256) {
       return tokenERC20.balanceOf(address(this));
    }

    function getAvailableEarnings(address _adr) public view returns(uint256) {
        uint256 userEggs = users[_adr].claimedEggs.add(getEggsSinceLastHatch(_adr));
        return calculateEggSell(userEggs);
    }

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
        uint256 eggsAmount = calculateEggBuy(amount , getContractBalance());
        uint256 miners = eggsAmount.div(minerDailyPrc);
        uint256 day = 24 hours;
        uint256 eggsPerDay = day.mul(miners);
        uint256 earningsPerDay = calculateEggSellForYield(eggsPerDay, amount);
        return(miners, earningsPerDay);
    }

    function calculateEggSellForYield(uint256 eggs, uint256 amount) public view returns(uint256) {
        return calculateTrade(eggs, marketEggs, getContractBalance().add(amount));
    }

    function getSiteInfo() public view returns (uint256 _totalStaked, uint256 _totalDeposits, uint256 _totalCompound, uint256 _totalRefBonus, uint256 _totalLotteryMinerBonus, uint256 _totalTopPoolReferrerMinerBonus, uint256 _totalLastDepositJackpot, uint256 _totalTopReferrerBonus, uint256 _pool_leader) {
        return (totalStaked, totalDeposits, totalCompound, totalRefBonus, totalLotteryMinerBonus, totalTopPoolReferrerMinerBonus, totalLastDepositJackpot, totalTopReferrerBonus, totalDepositPool[currentTopReferrerRound][poolTop[0]]);
    }

    function getMyMiners() public view returns(uint256) {
        return users[msg.sender].miners;
    }

    function getMyEggs() public view returns(uint256) {
        return users[msg.sender].claimedEggs.add(getEggsSinceLastHatch(msg.sender));
    }

    function getEggsSinceLastHatch(address adr) public view returns(uint256) {
        uint256 secondsSinceLastHatch = getCurrentTime().sub(users[adr].lastHatch);
        uint256 cutoffTime = min(secondsSinceLastHatch, cutOffTimeStep);
        uint256 secondsPassed = min(minerDailyPrc, cutoffTime);
        return secondsPassed.mul(users[adr].miners);
    }

    function getYieldEarnings(address adr) public view returns(uint256) {
        User storage user = users[adr];
        uint256 totalDeposit = user.initialDeposit;
        uint256 yieldLastWithdrawTime = user.yieldLastWithdrawTime;
        uint256 totalYieldEarnings;
        uint256 curTime = getCurrentTime();

        if(totalDeposit > 0)
        {
            uint256 share = totalDeposit.mul(fixedYieldIncomePrc).div(1000);
            totalYieldEarnings = share.mul(curTime.sub(yieldLastWithdrawTime)).div(24 hours);
        }

        return totalYieldEarnings;
    }
    
    function withdrawYieldEarnings() public nonReentrant {
        require(contractStarted, "Contract not yet Started.");
        require(!potentialBlacklisted[msg.sender].isBlacklisted, "Address is blacklisted.");

        User storage user = users[msg.sender];

        require (user.initialDeposit > 0,"No Deposit Detected.");
    
        uint256 totEarnings = getYieldEarnings(msg.sender);

        uint256 eggsAmount = calculateEggBuy(totEarnings , getContractBalance().sub(totEarnings));
        marketEggs = marketEggs.add(eggsAmount.div(10));
     
        user.yieldLastWithdrawTime = getCurrentTime();

        uint256 totalPayout = totEarnings.sub(payFees(totEarnings, true, true));
        user.totalWithdrawn = user.totalWithdrawn.add(totalPayout);

        if(getContractBalance() < totalPayout) {
            totalPayout = getContractBalance();
        }

        tokenERC20.transfer(msg.sender, totalPayout);
        totalWithdrawn = totalWithdrawn.add(totalPayout);
    }

    function calculateDailyEarningsFromFixedYield(address _adr) public view  returns(uint256 yield) {
        User storage user = users[_adr];
        if(user.initialDeposit > 0){
            return yield = user.initialDeposit.mul(fixedYieldIncomePrc).div(1000);
        }
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

    function getCurrentTime() public view returns(uint256) {
        return block.timestamp;
    }

    /** fixed yield earnings 1% to 2% every month. **/
    function SET_FIXED_YIELD_INCOME_PRC(uint256 value) external onlyOwner {
        require(value >= 10 && value <= 20); /** min 1% max 2%**/
        fixedYieldIncomePrc = value;
    }
    
    /** flip coin enabler **/ 
    function ENABLE_FLIPCOIN(bool value) external onlyOwner {
        require(contractStarted, "Contract not yet Started.");
        //run existing event regardless of requirement before changing variable value.
        if(TOSS_COIN_ACTIVATED && currentHeadsBetCount > 0 && currenttailsBetCount > 0){
            drawTossCoinRoundWinners();
        }

        if(value){
            TOSS_COIN_ACTIVATED = true;
            TOSS_COIN_START_TIME = getCurrentTime();
        }
        else{
            drawTossCoinRoundWinners();
            TOSS_COIN_ACTIVATED = false;                 
        }
    } 

    /** lottery enabler **/
    function ENABLE_LOTTERY(bool value) external onlyOwner {
        require(contractStarted, "Contract not yet Started.");
        //run existing event regardless of requirement before changing variable value.
        if(LOTTERY_ACTIVATED){
            drawLotteryWinner();
        }

        if(value){
            LOTTERY_ACTIVATED = true;
            LOTTERY_START_TIME = getCurrentTime();
        }
        else{
            drawLotteryWinner();
            LOTTERY_ACTIVATED = false;                 
        }
    }

    /** top-referrer enabler **/
    function ENABLE_TOP_REFERRER(bool value) external onlyOwner {
        require(contractStarted, "Contract not yet Started.");
        //run existing event regardless of requirement before changing variable value.
        if(TOP_REFERRER_ACTIVATED) {
            drawTopReferrerPool();
        }

        if(value){
            TOP_REFERRER_ACTIVATED = true;
            TOP_REFERRER_START_TIME = getCurrentTime();
        }
        else{
            drawTopReferrerPool();
            TOP_REFERRER_ACTIVATED = false;                 
        }
    }

    /** horse betting enabler **/
    function ENABLE_HORSE_BETTING(bool value) external onlyOwner {
        require(contractStarted, "Contract not yet Started.");
        //run existing event regardless of requirement before changing variable value.
        if(HORSE_BETTING_ACTIVATED && currentUserHorseBettors.length > 0) {
            drawHorseRaceRoundWinners();
        }

        if(value){
            HORSE_BETTING_ACTIVATED = true;
            HORSE_RACE_START_TIME = getCurrentTime();
        }
        else{
            HORSE_BETTING_ACTIVATED = false;                 
        }
    }

    /** last deposit rewards enabler **/
    function ENABLE_LAST_DEPOSIT_REWARDS(bool value) external onlyOwner {
        require(contractStarted, "Contract not yet Started.");
        //run existing event before changing variable value.
        if(LAST_DEPOSIT_ACTIVATED && getCurrentTime().sub(LAST_DEPOSIT_START_TIME) >= lastDepositTimeStep && currentLastDepositPot > 0 && potentialLastDepositWinner != address(0)) {
            drawLastDepositWinner();
        }

        if(value){
            LAST_DEPOSIT_ACTIVATED = true;
            LAST_DEPOSIT_START_TIME = getCurrentTime();
        }
        else{
            LAST_DEPOSIT_ACTIVATED = false;                 
        }
    }
    
    /** auto compound enabler **/
    function ENABLE_AUTO_COMPOUND(bool value) external onlyOwner {
        require(contractStarted, "Contract not yet Started.");
        AUTO_COMPOUND_ACTIVATED = value;
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
    IERC20 public rykerToken;
    bool RYKER_TOKEN_ACTIVATED;
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

    function getRykerBonus(address adr) public view returns(uint256) {
        if(!RYKER_TOKEN_ACTIVATED) return 0;

        if(rykerToken.balanceOf(address(adr)) >= diamondValue) {
            return diamondBonus;
        }
        else if(rykerToken.balanceOf(address(adr)) >= platinumValue) {
            return platinumBonus;
        }
        else if(rykerToken.balanceOf(address(adr)) >= goldValue) {
            return goldBonus;
        }
        else if(rykerToken.balanceOf(address(adr))>= silverValue) {
            return silverBonus;
        }
        else if(rykerToken.balanceOf(address(adr))>= bronzeValue) {
            return bronzeBonus;
        }
        else
            return 0;
    }

    function getUserRykerBalance(address adr) public view returns(uint256) {
        return rykerToken.balanceOf(address(adr));
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
        uint256 bronzeTier, uint256 silverTier, uint256 goldTier, uint256 platinumTier, uint256 diamondTier, uint8 decimal) external onlyOwner {
        
        require(bronzeTierBonus <= 3 && silverTierBonus <= 6 && goldTierBonus <= 9 && platinumTierBonus <= 12 && diamondTierBonus <= 15, "Tier Bonus cannot exceed limit.");    
        bronzeBonus   = bronzeTierBonus;
        silverBonus   = silverTierBonus;
        goldBonus     = goldTierBonus;
        platinumBonus = platinumTierBonus;
        diamondBonus  = diamondTierBonus;

        require(bronzeTier <= 10000 && silverTier <= 20000 && goldTier <= 30000 && platinumTier <= 40000 && diamondTier <= 50000, "Required amount exceeds limit.");
        require(decimal <= 18, "Token Decimal is not valid.");
        bronzeValue   = bronzeTier * (10 ** decimal);
        silverValue   = silverTier * (10 ** decimal);
        goldValue     = goldTier * (10 ** decimal);
        platinumValue = platinumTier * (10 ** decimal);
        diamondValue  = diamondTier * (10 ** decimal);
    }

    function setRykerTokenAddress(address addr) external onlyOwner {
        rykerToken = IERC20(addr);
    }

    function ENABLE_RYKER_TOKEN(bool value) external onlyOwner {
        require(contractStarted, "Contract not yet Started.");
        RYKER_TOKEN_ACTIVATED = value;
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
    if (a == 0) return 0;

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