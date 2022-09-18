/**
 *Submitted for verification at BscScan.com on 2022-09-18
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract WonderSea_Vault {
    using SafeMath for uint256;

    IERC20 public WSF_Token;
    address erctoken = 0x71F9033EcbaD23737c298e654303F76FEe57AFfF; /** WSF **/

    /** Base parameters **/
    uint256 public EGGS_TO_HIRE_1MINERS = 1728000; /** 5% **/
    uint256 public EGGS_TO_HIRE_1MINERS_COMPOUND = 1080000;
    uint256 public REFERRAL = 80; /** 8% Referral Rewards **/
    uint256 public PERCENTS_DIVIDER = 1000;
    uint256 public OWNER = 25; /** 2.5% for dev **/
    uint256 public TREASURY = 25; /** 2.5% for Tresury **/
    uint256 public JACKPOT = 10; /** 1% for Jackpot **/
    uint256 public MARKET_EGGS_DIVISOR = 8;
    uint256 public MARKET_EGGS_DIVISOR_SELL = 2;
    uint256 FREE_STAFFS_BONUS = 1000 ether; /** for Newbie **/
    uint256 public totalDeals = 0; 
    uint256 public totalVolume = 0; 

    /** Bonus **/
	uint256 public COMPOUND_BONUS = 40; /** 4% **/
	uint256 public COMPOUND_BONUS_MAX_TIMES = 14; /** 14 times / 7 days **/
    uint256 public COMPOUND_STEP = 12 * 60 * 60; /** every 12 hours **/

    /** Withdrawal tax **/
    uint256 public WITHDRAWAL_TAX = 600; /** 60% **/
    uint256 public COMPOUND_FOR_NO_TAX_WITHDRAWAL = 6; /** 6 times **/

    /* LuckyDraw */
	bool public LOTTERY_ACTIVATED;
    uint256 public LOTTERY_START_TIME;
    uint256 public LOTTERY_PERCENT = 10; /** 1% of deposit/compound amount will be put into the Pot **/
    uint256 public LOTTERY_STEP = 20 * 60 * 60; /** every 20 hours **/
    uint256 public LOTTERY_TICKET_PRICE = 1000 ether; /** every 1,000 $WSF deposit/compound **/
    uint256 public MAX_LOTTERY_TICKET = 100; /** Max 100 tickets/user **/
    uint256 public MAX_LOTTERY_PARTICIPANTS = 1000; /** Max 1000 participants **/
    uint256 public lotteryRound = 0;
    uint256 public currentPot = 0;
    uint256 public participants = 0;
    uint256 public totalTickets = 0;

    /* Tournament */
    uint256 public TOURNAMENT_INTERVAL = 7 days; /** 7 days **/
    bool public tournamentStarted = false;
    uint256 public TOURNAMENT_START_TIME;
    uint8 public TOURNAMENT_ROUND;
    uint8 public WINNER_TOUR_COUNT = 20; /** Top 20 Leaderboard **/
    mapping(uint8 => mapping(uint8 => address)) public WINNER_TOUR_ADDRESS;
    mapping(uint8 => mapping(uint8 => uint256)) public WINNER_TOUR_AMOUNTS;

    /* Vault parameters */
    uint256 public marketEggs;
    uint256 PSN = 10000;
    uint256 PSNH = 5000;
    bool public contractStarted;

    /** Whale control features **/
	uint256 public CUTOFF_STEP = 48 * 60 * 60; /** 48 hours  **/
    uint256 public MIN_INVEST = 5000 ether; /** Min 5000 $WSF/deposit  **/
	uint256 public WITHDRAW_COOLDOWN = 4 * 60 * 60; /** 4 hours  **/
    uint256 public WALLET_DEPOSIT_LIMIT = 50000000 ether; /** Max 5,000,000 $WSF/wallet  **/

    /* Statistics */
    uint256 public totalStaked;
    uint256 public totalDeposits;
    uint256 public totalCompound;
    uint256 public totalRefBonus;
    uint256 public totalWithdrawn;
    uint256 public totalLotteryBonus;
    uint256 public numUsers;
    mapping (uint256 => address) public totalUsers;
    mapping (address => bool) public enteredUsers;

    /* Addresses */
    address payable public owner;
    address payable public treasury;

    struct User {
        uint256 initialDeposit;
        uint256 userDeposit;
        uint256 miners;
        uint256 claimedEggs;
        uint256 totalLotteryBonus;
        uint256 lastHatch;
        uint256 lastCompound;
        address referrer;
        uint256 referralsCount;
        uint256 referralEggRewards;
        uint256 totalWithdrawn;
        uint256 dailyCompoundBonus;
        uint256 lastWithdrawTime;
        mapping(uint8 => uint256) TournamentDeposit; 
    }

    mapping(address => bool) public OneGetFree;

    struct LotteryHistory {
        uint256 round;
        address winnerAddress;
        uint256 pot;
        uint256 totalLotteryParticipants;
        uint256 totalLotteryTickets;
    }

    // Ref Leaderboard
    mapping (uint256 => ReferralData) public referralsData;
    mapping (address=>uint256) public refIndex;
    mapping (address => uint256) public refferalsAmountData;
    uint256 public totalRefferalCount;
    struct ReferralData{
            address refAddress;
            uint256 amount;
            uint256 refCount;
        }

    LotteryHistory[] internal lotteryHistory;
    mapping(address => User) public users;
    mapping(uint256 => mapping(address => uint256)) public ticketOwners;
    mapping(uint256 => mapping(uint256 => address)) public participantAdresses;
    event LotteryWinner(address indexed investor, uint256 pot, uint256 indexed round);

    ITimerPool timer;

    constructor(address payable _owner, address payable _treasury, ITimerPool _timer) {
		require(!isContract(_owner) && !isContract(_treasury));
        WSF_Token = IERC20(erctoken);
        owner = _owner;
        treasury = _treasury;
        timer = _timer;
    }

	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function hireMoreStaffs(bool isCompound, uint256 newMiners) public {
        User storage user = users[msg.sender];
        require(contractStarted, "Contract not yet Started.");

        uint256 eggsUsed = getMyEggs();
        uint256 eggsForCompound = eggsUsed;

        if(isCompound) {
            uint256 dailyCompoundBonus = getDailyCompoundBonus(msg.sender, eggsForCompound);
            eggsForCompound = eggsForCompound.add(dailyCompoundBonus);
            uint256 eggsUsedValue = calculateEggSell(eggsForCompound);

            user.userDeposit = user.userDeposit.add(eggsUsedValue);
            totalCompound = totalCompound.add(eggsUsedValue);

            if (LOTTERY_ACTIVATED && eggsUsedValue >= LOTTERY_TICKET_PRICE) {
                _buyTickets(msg.sender, eggsUsedValue);
            }

            totalDeals +=1;
            totalVolume += eggsUsedValue;

        } else {
            uint256 eggsUsedValue = getEggsSinceLastHatch(msg.sender);
            user.userDeposit = user.userDeposit.add(eggsUsedValue);
            
            if ( user.lastWithdrawTime == 0) {
            user.lastWithdrawTime = block.timestamp;
        }
        }
        
        if(block.timestamp.sub(user.lastCompound) >= COMPOUND_STEP) {
            if(user.dailyCompoundBonus < COMPOUND_BONUS_MAX_TIMES) {
                user.dailyCompoundBonus = user.dailyCompoundBonus.add(1);
                user.lastCompound = block.timestamp;
            }
        }

        if (isCompound) {
            newMiners = eggsForCompound.div(EGGS_TO_HIRE_1MINERS_COMPOUND);
        } else {
            newMiners = eggsForCompound.div(EGGS_TO_HIRE_1MINERS);

        }
        user.miners = user.miners.add(newMiners);
        
        user.claimedEggs = 0;
        user.lastHatch = block.timestamp;
        
        marketEggs = marketEggs.add(eggsUsed.div(MARKET_EGGS_DIVISOR));
    }

    function sellFish() public {
        require(contractStarted);
        User storage user = users[msg.sender];
        uint256 hasEggs = getMyEggs();
        uint256 eggValue = calculateEggSell(hasEggs);

        if(user.lastWithdrawTime.add(WITHDRAW_COOLDOWN) > block.timestamp) revert("Withdrawals can only be done after withdraw cooldown.");
        
        user.claimedEggs = 0;
        user.lastHatch = block.timestamp;
        
        if(user.dailyCompoundBonus < COMPOUND_FOR_NO_TAX_WITHDRAWAL){
            eggValue = eggValue.sub(eggValue.mul(WITHDRAWAL_TAX).div(PERCENTS_DIVIDER));
        }else{
             user.dailyCompoundBonus = 1; 
        }
        
        user.lastWithdrawTime = block.timestamp;

        marketEggs = marketEggs.add(hasEggs.div(MARKET_EGGS_DIVISOR_SELL));
        
        if(getBalance() < eggValue) {
            eggValue = getBalance();
        }

        uint256 eggsPayout = eggValue.sub(payFees(eggValue));
        
        WSF_Token.transfer(msg.sender, eggsPayout);
        user.totalWithdrawn = user.totalWithdrawn.add(eggsPayout);
        totalWithdrawn = totalWithdrawn.add(eggsPayout);

        if(block.timestamp.sub(LOTTERY_START_TIME) >= LOTTERY_STEP || participants >= MAX_LOTTERY_PARTICIPANTS){
            chooseWinner();
        }

        totalDeals +=1;
        totalVolume += totalWithdrawn;
    }

    /** transfer amount of WSF **/
    function hireStaffs(address ref, uint256 amount) public payable {
        User storage user = users[msg.sender];
        if (!contractStarted) {
    		if (msg.sender == owner) {
    		    require(marketEggs == 0);
    			contractStarted = true;
                marketEggs = 172800000000;
                LOTTERY_ACTIVATED = true;
                LOTTERY_START_TIME = block.timestamp;
    		} else revert("Contract not yet started.");
    	}
        require(amount >= MIN_INVEST, "Mininum investment not met.");
        require(user.initialDeposit.add(amount) <= WALLET_DEPOSIT_LIMIT, "Max deposit limit reached.");

        if (tournamentStarted && TOURNAMENT_START_TIME + TOURNAMENT_INTERVAL < block.timestamp) {
            TOURNAMENT_START_TIME = TOURNAMENT_START_TIME.add(TOURNAMENT_INTERVAL);
            TOURNAMENT_ROUND = TOURNAMENT_ROUND + 1;
        }

        if (tournamentStarted) {
            user.TournamentDeposit[TOURNAMENT_ROUND] = user.TournamentDeposit[TOURNAMENT_ROUND].add(amount);
            // console.log("space->tournamentAmount: ", user.TournamentDeposit[TOURNAMENT_ROUND]);
            for (uint8 i = 1; i <= WINNER_TOUR_COUNT; i++) {
                if (user.TournamentDeposit[TOURNAMENT_ROUND] > WINNER_TOUR_AMOUNTS[TOURNAMENT_ROUND][i]) {
                    if (WINNER_TOUR_ADDRESS[TOURNAMENT_ROUND][i] != msg.sender) {
                        address c;
                        uint256 m;
                        for (uint8 j = i+1; j <= WINNER_TOUR_COUNT; j++) {
                            
                            c = WINNER_TOUR_ADDRESS[TOURNAMENT_ROUND][j];
                            m = WINNER_TOUR_AMOUNTS[TOURNAMENT_ROUND][j];

                            WINNER_TOUR_ADDRESS[TOURNAMENT_ROUND][j] = WINNER_TOUR_ADDRESS[TOURNAMENT_ROUND][i];
                            WINNER_TOUR_AMOUNTS[TOURNAMENT_ROUND][j] = WINNER_TOUR_AMOUNTS[TOURNAMENT_ROUND][i];

                            WINNER_TOUR_ADDRESS[TOURNAMENT_ROUND][i] = c;
                            WINNER_TOUR_AMOUNTS[TOURNAMENT_ROUND][i] = m;

                            if (c == msg.sender) break;
                        }
                    }

                    WINNER_TOUR_ADDRESS[TOURNAMENT_ROUND][i] = msg.sender;
                    WINNER_TOUR_AMOUNTS[TOURNAMENT_ROUND][i] = user.TournamentDeposit[TOURNAMENT_ROUND];
                    // console.log("space->action: ", i);
                    // console.log("space->TOURNAMENT_ROUND: ", TOURNAMENT_ROUND);

                    break;
                }
            }
        }
        
        WSF_Token.transferFrom(address(msg.sender), address(this), amount);
        uint256 eggsBought = calculateEggBuy(amount, getBalance().sub(amount));
        user.userDeposit = user.userDeposit.add(amount);
        user.initialDeposit = user.initialDeposit.add(amount);
        user.claimedEggs = user.claimedEggs.add(eggsBought);

        if (!enteredUsers[msg.sender]) {
            enteredUsers[msg.sender] = true;
            totalUsers[numUsers] = msg.sender;
            numUsers = SafeMath.add(numUsers, 1);
        }

        if (LOTTERY_ACTIVATED) {
			_buyTickets(msg.sender, amount);
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
                
        // Ref leaderboard
        if(user.referrer != address(0) && refferalsAmountData[user.referrer]==0){
                totalRefferalCount = totalRefferalCount.add(1);
                refIndex[user.referrer] = totalRefferalCount;
            }
                
        if (user.referrer != address(0)) {
            address upline = user.referrer;
            uint256 currentIndex = refIndex[user.referrer];
            if (upline != address(0)) {
                uint256 refRewards = amount.mul(REFERRAL).div(PERCENTS_DIVIDER);
                WSF_Token.transfer(upline, refRewards);
                
                users[upline].referralEggRewards = users[upline].referralEggRewards.add(refRewards);
                totalRefBonus = totalRefBonus.add(refRewards);
                refferalsAmountData[upline] = refferalsAmountData[upline].add(user.claimedEggs);
                referralsData[currentIndex] = ReferralData({
                refAddress:user.referrer,
                amount:referralsData[currentIndex].amount.add(refRewards),
                refCount:referralsData[currentIndex].refCount.add(1)
                });
            }
        }

        uint256 eggsPayout = payFees(amount);
        timer.update(amount.mul(JACKPOT).div(PERCENTS_DIVIDER), block.timestamp, msg.sender);

        totalStaked = totalStaked.add(amount.sub(eggsPayout));
        totalDeposits = totalDeposits.add(1);
        hireMoreStaffs(false, 0);

        totalDeals += 1;
        totalVolume += amount;
    }

    function getFreeStaffs() public {   
        User storage user = users[msg.sender]; 
        require (contractStarted); 
        require (OneGetFree[msg.sender] == false);
        user.lastHatch = block.timestamp;
        if (user.lastCompound == 0) {
            user.lastCompound = block.timestamp;
        }
        if (user.lastWithdrawTime == 0) {
            user.lastWithdrawTime = block.timestamp;
        }
        
        user.miners = SafeMath.add(SafeMath.div(calculateEggBuySimple(FREE_STAFFS_BONUS),EGGS_TO_HIRE_1MINERS),user.miners);
        OneGetFree[msg.sender] = true;

        if (!enteredUsers[msg.sender]) {
            enteredUsers[msg.sender] = true;
            totalUsers[numUsers] = msg.sender;
            numUsers = SafeMath.add(numUsers, 1);
        }

        totalDeals += 1;
        totalVolume += FREE_STAFFS_BONUS;
    } 

    function payFees(uint256 eggValue) internal returns(uint256){
        (uint256 treasuryFee, uint256 ownerFee) = getFees(eggValue);
        WSF_Token.transfer(treasury, treasuryFee);
		WSF_Token.transfer(owner, ownerFee);
        WSF_Token.transfer(address(timer), eggValue.mul(JACKPOT).div(PERCENTS_DIVIDER));
        return treasuryFee.add(ownerFee);
    }

    function getFees(uint256 eggValue) public view returns(uint256 _treasuryFee, uint256 _ownerFee) {
        _treasuryFee = eggValue.mul(TREASURY).div(PERCENTS_DIVIDER);
        _ownerFee = eggValue.mul(OWNER).div(PERCENTS_DIVIDER);
    }

    /** lottery section! **/
    function _buyTickets(address userAddress, uint256 amount) private {
        require(amount != 0, "zero purchase amount");
        uint256 userTickets = ticketOwners[lotteryRound][userAddress];
        uint256 numTickets = amount.div(LOTTERY_TICKET_PRICE);

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
        currentPot = currentPot.add(amount.mul(LOTTERY_PERCENT).div(PERCENTS_DIVIDER));
        totalTickets = totalTickets.add(numTickets);

        if(block.timestamp.sub(LOTTERY_START_TIME) >= LOTTERY_STEP || participants >= MAX_LOTTERY_PARTICIPANTS){
            chooseWinner();
        }
    }

   /** will auto execute, when condition is met **/
    function chooseWinner() public {
       require(((block.timestamp.sub(LOTTERY_START_TIME) >= LOTTERY_STEP) || participants >= MAX_LOTTERY_PARTICIPANTS),
        "Lottery must run for LOTTERY_STEP or there must be MAX_LOTTERY_PARTICIPANTS particpants");
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

            uint256 random = _getRandom().mod(last_range).add(1);

            for(uint256 i = 0; i < participants; i++){
                if((random >= init_range[i]) && (random <= end_range[i])){

                    address winnerAddress = participantAdresses[lotteryRound][i];
                    User storage user = users[winnerAddress];

                    uint256 eggs = currentPot.mul(9).div(10);
                    
                    uint256 eggsReward = calculateEggBuy(eggs, getBalance().sub(eggs));
                    user.miners = user.miners.add(eggsReward.div(EGGS_TO_HIRE_1MINERS_COMPOUND));

                    user.totalLotteryBonus = user.totalLotteryBonus.add(eggsReward);
                    totalLotteryBonus = totalLotteryBonus.add(eggsReward);
                    payFees(currentPot);

                    lotteryHistory.push(LotteryHistory(lotteryRound, winnerAddress, eggsReward, participants, totalTickets));
                    emit LotteryWinner(winnerAddress, eggsReward, lotteryRound);

                    currentPot = 0;
                    participants = 0;
                    totalTickets = 0;
                    LOTTERY_START_TIME = block.timestamp;
                    lotteryRound = lotteryRound.add(1);
                    break;
                }
            }
        }else{
            LOTTERY_START_TIME = block.timestamp;
        } 
    }

    function _getRandom() private view returns(uint256){
        bytes32 _blockhash = blockhash(block.number-1);
        return uint256(keccak256(abi.encode(_blockhash,block.timestamp,currentPot,block.difficulty, marketEggs, getBalance())));
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

    function getLotteryHistory(uint256 index) public view returns(uint256 round, address winnerAddress, uint256 pot,
	  uint256 totalLotteryParticipants, uint256 totalLotteryTickets) {
		round = lotteryHistory[index].round;
		winnerAddress = lotteryHistory[index].winnerAddress;
		pot = lotteryHistory[index].pot;
		totalLotteryParticipants = lotteryHistory[index].totalLotteryParticipants;
		totalLotteryTickets = lotteryHistory[index].totalLotteryTickets;
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

    function getUserInfo(address _adr) public view returns(uint256 _initialDeposit, uint256 _userDeposit, uint256 _miners,
     uint256 _claimedEggs, uint256 _totalLotteryBonus, uint256 _lastHatch, uint256 _lastCompound, address _referrer, uint256 _referrals,
	 uint256 _totalWithdrawn, uint256 _referralEggRewards, uint256 _dailyCompoundBonus, uint256 _lastWithdrawTime) {
         _initialDeposit = users[_adr].initialDeposit;
         _userDeposit = users[_adr].userDeposit;
         _miners = users[_adr].miners;
         _claimedEggs = users[_adr].claimedEggs;
         _totalLotteryBonus = users[_adr].totalLotteryBonus;
         _lastHatch = users[_adr].lastHatch;
         _lastCompound = users[_adr].lastCompound;
         _referrer = users[_adr].referrer;
         _referrals = users[_adr].referralsCount;
         _totalWithdrawn = users[_adr].totalWithdrawn;
         _referralEggRewards = users[_adr].referralEggRewards;
         _dailyCompoundBonus = users[_adr].dailyCompoundBonus;
         _lastWithdrawTime = users[_adr].lastWithdrawTime;
	}

    function getBalance() public view returns (uint256) {
        return WSF_Token.balanceOf(address(this));
	}

    function getTimeStamp() public view returns (uint256) {
        return block.timestamp;
    }

    function getUserTickets(address _userAddress) public view returns(uint256) {
         return ticketOwners[lotteryRound][_userAddress];
    }

    function getLotteryTimer() public view returns(uint256) {
        return LOTTERY_START_TIME.add(LOTTERY_STEP);
    }

    function getAvailableEarnings(address _adr) public view returns(uint256) {
        uint256 userEggs = users[_adr].claimedEggs.add(getEggsSinceLastHatch(_adr));
        return calculateEggSell(userEggs);
    }

    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) public view returns(uint256){
        return SafeMath.div(SafeMath.mul(PSN, bs), SafeMath.add(PSNH, SafeMath.div(SafeMath.add(SafeMath.mul(PSN, rs), SafeMath.mul(PSNH, rt)), rt)));
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
        return calculateTrade(eggs,marketEggs, getBalance().add(amount));
    }

    function getSiteInfo() public view returns (uint256 _totalStaked, uint256 _totalDeposits, uint256 _totalCompound, uint256 _totalRefBonus, uint256 _totalLotteryBonus, uint256 _numUsers, uint256 _totalDeals, uint256 _totalVolume) {
        return (totalStaked, totalDeposits, totalCompound, totalRefBonus, totalLotteryBonus, numUsers, totalDeals, totalVolume);
    }

    function getMyMiners() public view returns(uint256){
        return users[msg.sender].miners;
    }

    function getMyEggs() public view returns(uint256){
        return users[msg.sender].claimedEggs.add(getEggsSinceLastHatch(msg.sender));
    }

    function getEggsSinceLastHatch(address adr) public view returns(uint256){
        uint256 secondsSinceLastHatch = block.timestamp.sub(users[adr].lastHatch);

        uint256 cutoffTime = min(secondsSinceLastHatch, CUTOFF_STEP);
        uint256 secondsPassed = min(EGGS_TO_HIRE_1MINERS, cutoffTime);
        return secondsPassed.mul(users[adr].miners);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

    function ENABLE_LOTTERY() public {
        require(msg.sender == owner, "Admin use only.");
        require(contractStarted);
        LOTTERY_ACTIVATED = true;
        LOTTERY_START_TIME = block.timestamp;
    }

    function DISABLE_LOTTERY() public {
        require(msg.sender == owner, "Admin use only.");
        require(contractStarted);
        LOTTERY_ACTIVATED = false;
    }

    /** wallet addresses **/
    function CHANGE_OWNERSHIP(address value) external {
        require(msg.sender == owner, "Admin use only.");
        owner = payable(value);
    }

    function PRC_EGGS_TO_HIRE_1MINERS(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value >= 479520 && value <= 2592000); /** min 3% max 12% **/
        EGGS_TO_HIRE_1MINERS = value;
    }

    function PRC_EGGS_TO_HIRE_1MINERS_COMPOUND(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value >= 479520 && value <= 2592000); /** min 3% max 12% **/
        EGGS_TO_HIRE_1MINERS_COMPOUND = value;
    }

    function PRC_REFERRAL(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value >= 10 && value <= 100); /**  max 10% **/
        REFERRAL = value;
    }

    function PRC_MARKET_EGGS_DIVISOR_SELL(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value <= 50); /** max 50 = 2% **/
        MARKET_EGGS_DIVISOR_SELL = value;
    }

    function SET_WITHDRAWAL_TAX(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value <= 150); /** max 15% or lower **/
        WITHDRAWAL_TAX = value;
    }

    function BONUS_DAILY_COMPOUND(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value >= 10 && value <= 100); /** max 10%/compound **/
        COMPOUND_BONUS = value;
    }

    function BONUS_DAILY_COMPOUND_BONUS_MAX_TIMES(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value <= 20); /** max 20 times **/
        COMPOUND_BONUS_MAX_TIMES = value;
    }

    function BONUS_COMPOUND_STEP(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        COMPOUND_STEP = value * 60 * 60; /** max 24 hours/bonus **/
    }

    function SET_LOTTERY_STEP(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        LOTTERY_STEP = value * 60 * 60; /** max 7 days/time **/
    }

    function SET_LOTTERY_PERCENT(uint256 value) external {
        require(msg.sender == owner, "Admin use only");
        require(value >= 10 && value <= 50); /** max 5% **/
        LOTTERY_PERCENT = value;
    }

    function SET_LOTTERY_TICKET_PRICE(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        LOTTERY_TICKET_PRICE = value * 1 ether; /** max 100,000 $WSF/ticket **/
    }

    function SET_MAX_LOTTERY_TICKET(uint256 value) external {
        require(msg.sender == owner, "Admin use only");
        require(value >= 1 && value <= 1000); /** max 1000 ticket/user **/
        MAX_LOTTERY_TICKET = value;
    }

    function SET_MAX_LOTTERY_PARTICIPANTS(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value >= 10 && value <= 10000); /** max 10,000 users **/
        MAX_LOTTERY_PARTICIPANTS = value;
    }

    function SET_TOURNAMENT_INTERVAL(uint256 value) external {
        require(msg.sender == owner, "Admin use only");
        require(value <= 1_209_600, "available between 0 and 14 days");
        TOURNAMENT_INTERVAL = value;
    }

    function startTOURNAMENT() external {
        require(msg.sender == owner, "Admin use only");
        tournamentStarted = true;
        TOURNAMENT_START_TIME = block.timestamp;
        TOURNAMENT_ROUND = TOURNAMENT_ROUND + 1;
    }

    function finishTOURNAMENT() external {
        require(msg.sender == owner, "Admin use only");
        tournamentStarted = false;
    }

    function SET_WINNER_TOUR_COUNT(uint8 value) external {
        require(msg.sender == owner, "Admin use only");
        require(value < 10); /** max 10 winners **/
        WINNER_TOUR_COUNT = value;
    }

    function getTournamentWinners(uint8 _round, uint8 _index) view external returns (address, uint256) {
        return (WINNER_TOUR_ADDRESS[_round][_index], WINNER_TOUR_AMOUNTS[_round][_index]);
    }

    function SET_INVEST_MIN(uint256 value) external {
        require(msg.sender == owner, "Admin use only");
        require(value >= 200 && value <= 10000); /** max 10,000 $WSF **/
        MIN_INVEST = value * 1 ether;
    }

    function SET_CUTOFF_STEP(uint256 value) external {
        require(msg.sender == owner, "Admin use only");
        require(value >= 12 && value <= 48); /** max 48 hours **/
        CUTOFF_STEP = value * 60 * 60;
    }

    function SET_WITHDRAW_COOLDOWN(uint256 value) external {
        require(msg.sender == owner, "Admin use only");
        require(value <= 12); /** max 12 hours **/
        WITHDRAW_COOLDOWN = value * 60 * 60;
    }

    function SET_WALLET_DEPOSIT_LIMIT(uint256 value) external {
        require(msg.sender == owner, "Admin use only");
        require(value >= 100000 && value <= 10000000); /** max 10,000,000 $WSF **/
        WALLET_DEPOSIT_LIMIT = value * 1 ether;
    }
}

interface ITimerPool {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function update(
        uint256 _amount,
        uint256 _time,
        address _user
    ) external;
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
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