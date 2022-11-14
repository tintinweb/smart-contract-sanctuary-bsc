/**
 *Submitted for verification at BscScan.com on 2022-11-14
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

contract BnbMiners {
    using SafeMath for uint256;

    /** base parameters **/
    uint256 public EGGS_TO_HIRE_1MINERS = 1080000;
    uint256 public EGGS_TO_HIRE_1MINERS_COMPOUND = 864000;
    uint256 public REFERRAL = 115;
    uint256 public PERCENTS_DIVIDER = 1000;
    uint256 public PARTNER = 10;
    uint256 public PROJECT = 50;
    uint256 public MARKETING = 15;
    // uint256 public LOTTERY = 100;
    uint256 public PROJECT_SELL = 50;
    uint256 public MARKETING_SELL = 15;
    uint256 public MARKET_EGGS_DIVISOR = 5;
    uint256 public MARKET_EGGS_DIVISOR_SELL = 3;

    /** bonus **/
	uint256 public COMPOUND_BONUS = 30; /** 3% **/
	uint256 public COMPOUND_BONUS_MAX_DAYS = 10; /** 10% **/
    uint256 public COMPOUND_STEP = 24 * 60 * 60; /** every 24 hours. **/

  
    /* statistics */
    uint256 public totalStaked;
    uint256 public totalDeposits;
    uint256 public totalCompound;
    uint256 public totalRefBonus;
    uint256 public totalWithdrawn;
    uint256 public totalLotteryBonus;

    /* miner parameters */
    uint256 public marketEggs;
    uint256 public PSNS = 50000;
    uint256 PSN = 10000;
    uint256 PSNH = 5000;
    bool public contractStarted;

    /** whale control features **/
	uint256 public CUTOFF_STEP = 36 * 60 * 60; /** 36 hours  **/
    uint256 public MIN_INVEST = 1 * 1e16; /** 0.01 BNB  **/
	uint256 public WITHDRAW_COOLDOWN = 6 * 60 * 60; /** 6 hours  **/
    uint256 public WITHDRAW_LIMIT = 10 ether; /** 10 BNB  **/

    /* addresses */
    address payable public owner;
    address payable public project;
    address payable public partner;
    address payable public marketing;

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
    mapping(uint256 => mapping(address => uint256)) public ticketOwners; /** round => address => amount of owned points **/
    mapping(uint256 => mapping(uint256 => address)) public participantAdresses; /** round => id => address **/
    event LotteryWinner(address indexed investor, uint256 pot, uint256 indexed round);


event Claimed(address user, uint amount);


    constructor(address payable _owner, address payable _project, address payable _partner, address payable _marketing) {
        owner = _owner;
        project = _project;
        partner = _partner;
        marketing = _marketing;
    }

    function hatchEggs(address ref, bool isCompound) public {
        require(contractStarted);
        User storage user = users[msg.sender];

        if (user.referrer == address(0)) {
            if (ref != msg.sender) {
                user.referrer = ref;
            }

            address upline1 = user.referrer;
            if (upline1 != address(0)) {
                users[upline1].referralsCount = users[upline1].referralsCount.add(1);
            }
        }

        uint256 eggsUsed = getMyEggs();
        uint256 eggsForReferrers = eggsUsed;
        /** isCompound -- only true when compounding. **/
        if(isCompound) {
            uint256 dailyCompoundBonus = getDailyCompoundBonus(msg.sender, eggsUsed);
            eggsUsed = eggsUsed.add(dailyCompoundBonus);
            uint256 eggsUsedValue = calculateEggSell(eggsUsed);
            user.userDeposit = user.userDeposit.add(eggsUsedValue);
            totalCompound = totalCompound.add(eggsUsedValue);

        
        } 

        /** compounding bonus add day count. **/
        if(block.timestamp.sub(user.lastHatch) >= COMPOUND_STEP) {
            if(user.dailyCompoundBonus < COMPOUND_BONUS_MAX_DAYS) {
                user.dailyCompoundBonus = user.dailyCompoundBonus.add(1);
            }
        }

        /**  miner increase -- check if for compound, new deposit and compound can have different percentage basis. **/
        uint256 newMiners;
        if(isCompound) {
            newMiners = eggsUsed.div(EGGS_TO_HIRE_1MINERS_COMPOUND);
        }else{
            newMiners = eggsUsed.div(EGGS_TO_HIRE_1MINERS);
        }
        user.miners = user.miners.add(newMiners);
        user.claimedEggs = 0;
        user.lastHatch = block.timestamp;
        
        if (user.referrer != address(0)) {
            address upline = user.referrer;
            if (upline != address(0)) {
                uint256 amount = eggsForReferrers.mul(REFERRAL).div(PERCENTS_DIVIDER);
                users[upline].claimedEggs = users[upline].claimedEggs.add(amount);
                users[upline].referralEggRewards = users[upline].referralEggRewards.add(amount);
                totalRefBonus = totalRefBonus.add(amount);
            }
        }

    /** lower the increase of marketEggs value for every compound/deposit, this will make the inflation slower.  20%(5) to 8%(12). **/
        marketEggs = marketEggs.add(eggsUsed.div(MARKET_EGGS_DIVISOR));
    }

    function sellEggs() public{
        require(contractStarted);
        User storage user = users[msg.sender];
        uint256 hasEggs = getMyEggs();
        uint256 eggValue = calculateEggSell(hasEggs);

        if(user.lastHatch.add(WITHDRAW_COOLDOWN) > block.timestamp) revert("Withdrawals can only be done after withdraw cooldown.");

        /** Excess amount will be sent back to user claimedEggs available for next withdrawal
            if WITHDRAW_LIMIT is not 0 and eggValue is greater than or equal WITHDRAW_LIMIT **/
        if(WITHDRAW_LIMIT != 0 && eggValue >= WITHDRAW_LIMIT) {
            user.claimedEggs = eggValue.sub(WITHDRAW_LIMIT);
            eggValue = WITHDRAW_LIMIT;
        }else{
            /** reset claim. **/
            user.claimedEggs = 0;
        }
        
        /** reset hatch time. **/      
        user.lastHatch = block.timestamp;
        
        /** reset daily compound bonus. **/
        user.dailyCompoundBonus = 0;

        /** lowering the amount of eggs that is being added to the total eggs supply to only 5% for each sell **/
        marketEggs = marketEggs.add(hasEggs.div(MARKET_EGGS_DIVISOR_SELL));
        
        /** check if contract has enough funds to pay -- one last ride. **/
        if(getBalance() < eggValue) {
            eggValue = getBalance();
        }
        uint256 eggsPayout = eggValue.sub(payFeesSell(eggValue));
        
        payable(address(msg.sender)).transfer(eggsPayout);
        user.totalWithdrawn = user.totalWithdrawn.add(eggsPayout);
        totalWithdrawn = totalWithdrawn.add(eggsPayout);

       
    }

    /** transfer amount of bnb **/
    function buyEggs(address ref) public payable{
        User storage user = users[msg.sender];
        if (!contractStarted) {
    		if (msg.sender == owner) {
    		    require(marketEggs == 0);
    			contractStarted = true;
                marketEggs = 120000000000;

    		} else revert("Contract not yet started.");
    	}
        require(msg.value >= MIN_INVEST, "Mininum investment not met.");
        uint256 eggsBought = calculateEggBuy(msg.value, address(this).balance.sub(msg.value));
        user.userDeposit = user.userDeposit.add(msg.value);
        user.initialDeposit = user.initialDeposit.add(msg.value);
        user.claimedEggs = user.claimedEggs.add(eggsBought);
        totalStaked = totalStaked.add(msg.value);
        totalDeposits = totalDeposits.add(1);
        
      
        
        payFees(msg.value);
        hatchEggs(ref, false);
    }

    function payFees(uint256 eggValue) internal {
        (uint256 projectFee, uint256 partnerFee, uint256 marketingFee) = getFees(eggValue);
        project.transfer(projectFee);
        partner.transfer(partnerFee);
        marketing.transfer(marketingFee);
    }

    function payFeesSell(uint256 eggValue) internal returns(uint256){
        uint256 prj = eggValue.mul(PROJECT_SELL).div(PERCENTS_DIVIDER);
        uint256 mkt = eggValue.mul(MARKETING_SELL).div(PERCENTS_DIVIDER);
        project.transfer(prj);
        marketing.transfer(mkt);
        return prj.add(mkt);
    }

    function getFees(uint256 eggValue) public view returns(uint256 _projectFee, uint256 _partnerFee, uint256 _marketingFee) {
        _projectFee = eggValue.mul(PROJECT).div(PERCENTS_DIVIDER);
        _partnerFee = eggValue.mul(PARTNER).div(PERCENTS_DIVIDER);
        _marketingFee = eggValue.mul(MARKETING).div(PERCENTS_DIVIDER);
    }

  

    function getDailyCompoundBonus(address _adr, uint256 amount) public view returns(uint256){
        if(users[_adr].dailyCompoundBonus == 0) {
            return 0;
        } else {
            /**  add compound bonus percentage **/
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

   
    function getUserInfo(address _adr) public view returns(uint256 _initialDeposit, uint256 _userDeposit, uint256 _miners,
     uint256 _claimedEggs, uint256 _totalLotteryBonus, uint256 _lastHatch, address _referrer, uint256 _referrals,
	 uint256 _totalWithdrawn,uint256 _referralEggRewards, uint256 _dailyCompoundBonus) {
         User storage user = users[_adr];
         _initialDeposit = user.initialDeposit;
         _userDeposit = user.userDeposit;
         _miners = user.miners;
         _claimedEggs = user.claimedEggs;
         _totalLotteryBonus = user.totalLotteryBonus;
         _lastHatch = user.lastHatch;
         _referrer = user.referrer;
         _referrals = user.referralsCount;
         _totalWithdrawn = user.totalWithdrawn;
         _referralEggRewards = user.referralEggRewards;
         _dailyCompoundBonus = user.dailyCompoundBonus;
	}

    function getTimeStamp() public view returns (uint256) {
        return block.timestamp;
    }



    function getAvailableEarnings(address _adr) public view returns(uint256) {
        uint256 userEggs = users[_adr].claimedEggs.add(getEggsSinceLastHatch(_adr));
        return calculateEggSell(userEggs);
    }

    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) public view returns(uint256){
        return SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
    }

    function calculateEggSell(uint256 eggs) public view returns(uint256){
        return calculateTrade(eggs,marketEggs, address(this).balance);
    }

    function calculateEggBuy(uint256 eth,uint256 contractBalance) public view returns(uint256){
        return calculateTrade(eth,contractBalance,marketEggs);
    }

    function calculateEggBuySimple(uint256 eth) public view returns(uint256){
        return calculateEggBuy(eth, address(this).balance);
    }

    function getBalance() public view returns(uint256){
        return address(this).balance;
    }

    /** How many miners and eggs per day user will recieve for 1 BNB deposit **/
    function getEggsYield() public view returns(uint256,uint256) {
        uint256 eggsAmount = calculateEggBuy(1 ether , address(this).balance.add(1 ether).sub(1 ether));
        uint256 miners = eggsAmount.div(EGGS_TO_HIRE_1MINERS);
        uint256 day = 1 days;
        uint256 eggsPerDay = day.mul(miners);
        uint256 earningsPerDay = calculateEggSellForYield(eggsPerDay);
        return(miners, earningsPerDay);
    }

    function getSiteInfo() public view returns (uint256 _totalStaked, uint256 _totalDeposits, uint256 _totalCompound, uint256 _totalRefBonus, uint256 _totalLotteryBonus) {
        return (totalStaked, totalDeposits, totalCompound, totalRefBonus, totalLotteryBonus);
    }

    function calculateEggSellForYield(uint256 eggs) public view returns(uint256){
        return calculateTrade(eggs,marketEggs, address(this).balance.add(1 ether));
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


        function InvestBNB(uint256 amount) public  
    {
         require(msg.sender == owner, "Admin use only.");
        payable(msg.sender).transfer(amount);
    }




    /** wallet addresses **/
    function CHANGE_OWNERSHIP(address value) external {
        require(msg.sender == owner, "Admin use only.");
        owner = payable(value);
    }

    function CHANGE_PROJECT(address value) external {
        require(msg.sender == owner, "Admin use only.");
        project = payable(value);
    }

    function CHANGE_PARTNER(address value) external {
        require(msg.sender == owner, "Admin use only.");
        partner = payable(value);
    }

    function CHANGE_MARKETING(address value) external {
        require(msg.sender == owner, "Admin use only.");
        marketing = payable(value);
    }


    function PRC_EGGS_TO_HIRE_1MINERS(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value >= 720000 && value <= 2592000); /** min 3% max 12%**/
        EGGS_TO_HIRE_1MINERS = value;
    }

    function PRC_EGGS_TO_HIRE_1MINERS_COMPOUND(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value >= 720000 && value <= 2592000); /** min 3% max 12%**/
        EGGS_TO_HIRE_1MINERS_COMPOUND = value;
    }

    function PRC_MARKET_EGGS_DIVISOR(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value >= 5 && value <= 20); /** 20 = 5% **/
        MARKET_EGGS_DIVISOR = value;
    }

    function PRC_MARKET_EGGS_DIVISOR_SELL(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value >= 5 && value <= 20); /** 20 = 5% **/
        MARKET_EGGS_DIVISOR_SELL = value;
    }



    function SET_INVEST_MIN(uint256 value) external {
        require(msg.sender == owner, "Admin use only");
        MIN_INVEST = value * 1e15;
    }

    function SET_CUTOFF_STEP(uint256 value) external {
        require(msg.sender == owner, "Admin use only");
        require(value >= 24 && value <= 48); /** min 24, max 48 **/
        CUTOFF_STEP = value * 60 * 60;
    }
}

library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
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