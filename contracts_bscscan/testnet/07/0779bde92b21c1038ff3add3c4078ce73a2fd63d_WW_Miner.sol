/**
 *Submitted for verification at BscScan.com on 2022-02-05
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-03
*/

/**

Walts World DAO - Miner Game

    4% Daily Interest Rate.
    10% Referral Bonus, going straight to the wallet.
    5% Stacking compound bonus every 12 hours, max of 14 times.

    Sustainability:
    36 hours cut off time. Earnings will stop if there is no action on or before timer is off.
    12 hours withdrawal cooldown.
    5,000 WALT max deposit per wallet.
    30% Feedback Tax on 2 consecutive withdrawals.
      * to prevent consecutive withdrawals and give longevity and sustainability to the project.

*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

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

contract WW_Miner {

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
        uint256 withdrawCount;
        uint256 lastWithdrawTime;
    }

    mapping(address => User) public users;

     function initialize(address _waltAddress, address payable _owner, address payable _project) public{
        require(!isContract(_owner) && !isContract(_project));
        erctoken = _waltAddress;
        owner = _owner;
        project = _project;
        walt = IERC20(erctoken);

        EGGS_TO_HIRE_1MINERS = 2160000;
        EGGS_TO_HIRE_1MINERS_COMPOUND = 1080000;
        REFERRAL = 100;
        PERCENTS_DIVIDER = 1000;
        PROJECT = 20;
        OWNER = 20;
        MARKETING = 20;
        MARKET_EGGS_DIVISOR = 8;
        MARKET_EGGS_DIVISOR_SELL = 2;

        CUTOFF_STEP = 36 * 60 * 60;
        WITHDRAW_COOLDOWN = 12 * 60 * 60;
        WALLET_DEPOSIT_LIMIT = 10000 ether;

        WITHDRAWAL_TAX = 300;
        WITHDRAWAL_TAX_DAYS = 2;

	    COMPOUND_BONUS = 50;
	    COMPOUND_BONUS_MAX_TIMES = 14;
        COMPOUND_STEP = 12 * 60 * 60;

        if (!contractStarted) {
            if (msg.sender == owner || msg.sender == project) {
                require(marketEggs == 0);
                contractStarted = true;
                marketEggs = 216000000000;             
            } else revert("Contract not yet started.");
        }
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

        if(isCompound) {
            uint256 dailyCompoundBonus = getDailyCompoundBonus(msg.sender, eggsForCompound);
            eggsForCompound = eggsForCompound.add(dailyCompoundBonus);
            uint256 eggsUsedValue = calculateEggSell(eggsForCompound);
            user.userDeposit = user.userDeposit.add(eggsUsedValue);
            totalCompound = totalCompound.add(eggsUsedValue);
        } 

        if(block.timestamp.sub(user.lastHatch) >= COMPOUND_STEP) {
            if(user.dailyCompoundBonus < COMPOUND_BONUS_MAX_TIMES) {
                user.dailyCompoundBonus = user.dailyCompoundBonus.add(1);
            }
        }

        uint256 newMiners;
        if(isCompound) {
            newMiners = eggsForCompound.div(EGGS_TO_HIRE_1MINERS_COMPOUND);
        }else{
            newMiners = eggsForCompound.div(EGGS_TO_HIRE_1MINERS);
        }
        user.miners = user.miners.add(newMiners);
        
        user.claimedEggs = 0;
        user.lastHatch = block.timestamp;

        if(block.timestamp.sub(user.lastWithdrawTime) >= COMPOUND_STEP){
            user.withdrawCount = 0;
        }

        marketEggs = marketEggs.add(eggsUsed.div(MARKET_EGGS_DIVISOR));
    }

    function sellEggs() public{
        require(contractStarted);
        User storage user = users[msg.sender];
        uint256 hasEggs = getMyEggs();
        uint256 eggValue = calculateEggSell(hasEggs);

        if(user.lastHatch.add(WITHDRAW_COOLDOWN) > block.timestamp) revert("Withdrawals can only be done after withdraw cooldown.");
        
        user.claimedEggs = 0;
        user.lastHatch = block.timestamp;
        user.dailyCompoundBonus = 0;

        /** if user withdraw count added 1 is >= 2, implement = 30% tax. **/
        if(user.withdrawCount.add(1) >= WITHDRAWAL_TAX_DAYS){
          eggValue = eggValue.sub(eggValue.mul(WITHDRAWAL_TAX).div(PERCENTS_DIVIDER));
        }

        user.withdrawCount = user.withdrawCount.add(1); 
        user.lastWithdrawTime = block.timestamp;

        marketEggs = marketEggs.add(hasEggs.div(MARKET_EGGS_DIVISOR_SELL));
        
        if(getBalance() < eggValue) {
            eggValue = getBalance();
        }

        uint256 eggsPayout = eggValue.sub(payFees(eggValue));
        
        walt.transfer(msg.sender, eggsPayout);
        user.totalWithdrawn = user.totalWithdrawn.add(eggsPayout);
        totalWithdrawn = totalWithdrawn.add(eggsPayout);
    }

    /** transfer amount of WALT **/
    function buyEggs(address ref, uint256 amount) public payable{
        User storage user = users[msg.sender];
        require(user.initialDeposit.add(amount) <= WALLET_DEPOSIT_LIMIT, "Max deposit limit reached.");
        
        walt.transferFrom(address(msg.sender), address(this), amount);
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
                /** referral rewards will be in Walt **/
                uint256 refRewards = amount.mul(REFERRAL).div(PERCENTS_DIVIDER);
                walt.transfer(upline, refRewards);
                /** referral rewards will be in Walt value **/
                users[upline].referralEggRewards = users[upline].referralEggRewards.add(refRewards);
                totalRefBonus = totalRefBonus.add(refRewards);
            }
        }

        uint256 eggsPayout = payFees(amount);
        totalStaked = totalStaked.add(amount.sub(eggsPayout));
        totalDeposits = totalDeposits.add(1);
        hatchEggs(false);
    }

    function payFees(uint256 eggValue) internal returns(uint256){
        (uint256 projectFee, uint256 ownerFee) = getFees(eggValue);
        uint256 marketingFee = eggValue.mul(MARKETING).div(PERCENTS_DIVIDER);
        walt.transfer(project, projectFee);
		walt.transfer(owner, ownerFee);
        walt.transfer(marketing, marketingFee);
        return projectFee.add(ownerFee).add(marketingFee);
    }

    function getFees(uint256 eggValue) public view returns(uint256 _projectFee, uint256 _ownerFee) {
        _projectFee = eggValue.mul(PROJECT).div(PERCENTS_DIVIDER);
        _ownerFee = eggValue.mul(OWNER).div(PERCENTS_DIVIDER);
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
	 uint256 _totalWithdrawn, uint256 _referralEggRewards, uint256 _dailyCompoundBonus, uint256 _lastWithdrawTime, uint256 _withdrawCount) {
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
         _withdrawCount = users[_adr].withdrawCount;
	}

    function getBalance() public view returns (uint256) {
        return walt.balanceOf(address(this));
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

    /** How many miners and eggs per day user will recieve based on WALT deposit **/
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
        uint256 cutoffTime = min(secondsSinceLastHatch, CUTOFF_STEP);
        uint256 secondsPassed = min(EGGS_TO_HIRE_1MINERS, cutoffTime);
        return secondsPassed.mul(users[adr].miners);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

    /** wallet addresses **/
    function CHANGE_OWNERSHIP(address value) external {
        require(msg.sender == owner || msg.sender == project, "Admin use only.");
        owner = payable(value);
    }

    function CHANGE_PROJECT(address value) external {
        require(msg.sender == owner || msg.sender == project, "Admin use only.");
        project = payable(value);
    }

    function CHANGE_MARKETING(address value) external {
        require(msg.sender == owner || msg.sender == project, "Admin use only.");
        marketing = payable(value);
    }

    /**
        2592000 - 3%
        2160000 - 4%
        1728000 - 5%
        1440000 - 6%
        1200000 - 7%
        1080000 - 8%
         959000 - 9%
         864000 - 10%
         720000 - 12%
         575424 - 15%
         540000 - 16%
         479520 - 18%
    **/

    function PRC_EGGS_TO_HIRE_1MINERS(uint256 value) external {
        require(msg.sender == owner || msg.sender == project, "Admin use only.");
        require(value >= 479520 && value <= 2592000); /** min 3% max 12%**/
        EGGS_TO_HIRE_1MINERS = value;
    }

    function PRC_EGGS_TO_HIRE_1MINERS_COMPOUND(uint256 value) external {
        require(msg.sender == owner || msg.sender == project, "Admin use only.");
        require(value >= 479520 && value <= 2592000); /** min 3% max 12%**/
        EGGS_TO_HIRE_1MINERS_COMPOUND = value;
    }

    function PRC_PROJECT(uint256 value) external {
        require(msg.sender == owner || msg.sender == project, "Admin use only.");
        require(value >= 10 && value <= 100); /** 10% max **/
        PROJECT = value;
    }

    function PRC_REFERRAL(uint256 value) external {
        require(msg.sender == owner || msg.sender == project, "Admin use only.");
        require(value >= 10 && value <= 100); /** 10% max **/
        REFERRAL = value;
    }

    function PRC_MARKET_EGGS_DIVISOR(uint256 value) external {
        require(msg.sender == owner || msg.sender == project, "Admin use only.");
        require(value <= 50); /** 50 = 2% **/
        MARKET_EGGS_DIVISOR = value;
    }

    function PRC_MARKET_EGGS_DIVISOR_SELL(uint256 value) external {
        require(msg.sender == owner || msg.sender == project, "Admin use only.");
        require(value <= 50); /** 50 = 2% **/
        MARKET_EGGS_DIVISOR_SELL = value;
    }

    /** withdrawal tax **/
    function SET_WITHDRAWAL_TAX(uint256 value) external {
        require(msg.sender == owner || msg.sender == project, "Admin use only.");
        require(value <= 500); /** Max Tax is 50% or lower **/
        WITHDRAWAL_TAX = value;
    }

    function SET_WITHDRAW_DAYS_TAX(uint256 value) external {
        require(msg.sender == owner || msg.sender == project, "Admin use only.");
        require(value >= 2); /** Minimum 2 days **/
        WITHDRAWAL_TAX_DAYS = value;
    }

    /** bonus **/
    function BONUS_DAILY_COMPOUND(uint256 value) external {
        require(msg.sender == owner || msg.sender == project, "Admin use only.");
        require(value >= 10 && value <= 900); /** 90% max **/
        COMPOUND_BONUS = value;
    }

    function BONUS_DAILY_COMPOUND_BONUS_MAX_TIMES(uint256 value) external {
        require(msg.sender == owner || msg.sender == project, "Admin use only.");
        require(value <= 30); /** 30 max **/
        COMPOUND_BONUS_MAX_TIMES = value;
    }

    function BONUS_COMPOUND_STEP(uint256 value) external {
        require(msg.sender == owner || msg.sender == project, "Admin use only.");
         /** hour conversion **/
        COMPOUND_STEP = value * 60 * 60;
    }

    function SET_CUTOFF_STEP(uint256 value) external {
        require(msg.sender == owner || msg.sender == project, "Admin use only");
        CUTOFF_STEP = value * 60 * 60;
    }

    function SET_WITHDRAW_COOLDOWN(uint256 value) external {
        require(msg.sender == owner || msg.sender == project, "Admin use only");
        require(value <= 24);
        WITHDRAW_COOLDOWN = value * 60 * 60;
    }

    function SET_WALLET_DEPOSIT_LIMIT(uint256 value) external {
        require(msg.sender == owner || msg.sender == project, "Admin use only");
        require(value >= 20);
        WALLET_DEPOSIT_LIMIT = value * 1 ether;
    }

        using SafeMath for uint256;
    uint256 public EGGS_TO_HIRE_1MINERS;
    uint256 public EGGS_TO_HIRE_1MINERS_COMPOUND;
    uint256 public MARKET_EGGS_DIVISOR;
    uint256 public MARKET_EGGS_DIVISOR_SELL;
    uint256 public REFERRAL;
    uint256 public PERCENTS_DIVIDER;
    uint256 public PROJECT;
    uint256 public OWNER;
    uint256 public MARKETING;
	uint256 public COMPOUND_BONUS;
	uint256 public COMPOUND_BONUS_MAX_TIMES;
    uint256 public COMPOUND_STEP;
    uint256 public WITHDRAWAL_TAX;
    uint256 public WITHDRAWAL_TAX_DAYS;
    uint256 public totalStaked;
    uint256 public totalDeposits;
    uint256 public totalCompound;
    uint256 public totalRefBonus;
    uint256 public totalWithdrawn;
    uint256 public marketEggs;
	uint256 public CUTOFF_STEP;
	uint256 public WITHDRAW_COOLDOWN;
    uint256 public WALLET_DEPOSIT_LIMIT;
    uint256 PSN = 10000;
    uint256 PSNH = 5000;
    address payable public owner;
    address payable public project;
    address payable public marketing;
	address erctoken;
    bool public contractStarted;
    IERC20 public walt;
	    
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