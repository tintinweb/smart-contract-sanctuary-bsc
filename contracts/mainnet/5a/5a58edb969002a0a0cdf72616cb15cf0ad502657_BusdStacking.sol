/**
 *Submitted for verification at BscScan.com on 2022-11-29
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

interface BUSDToken {
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

contract BusdStacking {
    using SafeMath for uint256;

    BUSDToken public token_BUSD;

    address erctoken = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; /** BUSD token **/
    
    uint256 public MINER_TO_HIRE_1FARM = 2880000; 
    uint256 public PERCENTS_DIVIDER = 1000;
    uint256 public REFERRAL = 80;
    uint256 public TAX = 10;
    uint256 public MARKET_MINER_DIVISOR = 20; // 50%
    uint256 public MARKET_MINER_DIVISOR_SELL = 1; // 100%

    uint256 public MIN_INVEST_LIMIT = 10 * 1e18; /** 10 BUSD  **/
    uint256 public WALLET_DEPOSIT_LIMIT = 50000 * 1e18; /** 50000 BUSD  **/

	uint256 public COMPOUND_BONUS = 25; /** 2.5% **/
	uint256 public COMPOUND_BONUS_MAX_TIMES = 10; /** 10 times / 5 days. **/
    uint256 public COMPOUND_STEP = 12 * 60 * 60; /** every 12 hours. **/

    uint256 public WITHDRAWAL_TAX = 300; 
    uint256 public COMPOUND_FOR_NO_TAX_WITHDRAWAL = 2; // compound days, for no tax withdrawal.

    uint256 public totalStaked;
    uint256 public totalDeposits;
    uint256 public totalCompound;
    uint256 public totalRefBonus;
    uint256 public totalWithdrawn;

    uint256 public marketMiners;
    uint256 PSN = 10000;
    uint256 PSNH = 5000;
    bool public contractStarted;

	uint256 public CUTOFF_STEP = 12 * 60 * 60; /** .5 days cut interest **/
	uint256 public WITHDRAW_COOLDOWN = 4 * 60 * 60; /** 4 hours  **/

    address public owner;
    address public dev1;
    address public dev2;
    address public dev3;
    address public dev4;
    address public mkt;

    struct User {
        uint256 initialDeposit;
        uint256 userDeposit;
        uint256 miners;
        uint256 claimedMiners;
        uint256 lastHatch;
        address referrer;
        uint256 referralsCount;
        uint256 referralMinerRewards;
        uint256 totalWithdrawn;
        uint256 dailyCompoundBonus;
        uint256 lastWithdrawTime;
    }

    mapping(address => User) public users;

    constructor(address _dev1, address _dev2, address _dev3, address _dev4, address _mkt) {
		require(!isContract(_dev1) && !isContract(_dev2) && !isContract(_dev3) && !isContract(_dev4) && !isContract(_mkt));
        owner = msg.sender;
        dev1 = _dev1;
        dev2 = _dev2;
        dev3 = _dev3;
        dev4 = _dev4;   
        mkt = _mkt;     /** Marketing */
        token_BUSD = BUSDToken(erctoken);
    }

	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function Compounding(bool isCompound) public {
        User storage user = users[msg.sender];
        require(contractStarted, "Contract not yet Started.");

        uint256 minersUsed = getMyMiners();
        uint256 minersForCompound = minersUsed;

        if(isCompound) {
            uint256 dailyCompoundBonus = getDailyCompoundBonus(msg.sender, minersForCompound);
            minersForCompound = minersForCompound.add(dailyCompoundBonus);
            uint256 minersUsedValue = calculateMinersSell(minersForCompound);
            user.userDeposit = user.userDeposit.add(minersUsedValue);
            totalCompound = totalCompound.add(minersUsedValue);
        } 

        if(block.timestamp.sub(user.lastHatch) >= COMPOUND_STEP) {
            if(user.dailyCompoundBonus < COMPOUND_BONUS_MAX_TIMES) {
                user.dailyCompoundBonus = user.dailyCompoundBonus.add(1);
            }
        }
        
        user.miners = user.miners.add(minersForCompound.div(MINER_TO_HIRE_1FARM));
        user.claimedMiners = 0;
        user.lastHatch = block.timestamp;

        marketMiners = marketMiners.add(minersUsed.div(MARKET_MINER_DIVISOR));
    }

    function Withdraw() public{
        require(contractStarted);
        User storage user = users[msg.sender];
        uint256 hasMiners = getMyMiners();
        uint256 minerValue = calculateMinersSell(hasMiners);
        
        /** 
            if user compound < to mandatory compound days**/
        if(user.dailyCompoundBonus < COMPOUND_FOR_NO_TAX_WITHDRAWAL){
            //daily compound bonus count will not reset and minerValue will be deducted with feedback tax.
            minerValue = minerValue.sub(minerValue.mul(WITHDRAWAL_TAX).div(PERCENTS_DIVIDER));
        }else{
            //set daily compound bonus count to 0 and minerValue will remain without deductions
             user.dailyCompoundBonus = 0;   
        }
        
        user.lastWithdrawTime = block.timestamp;
        user.claimedMiners = 0;  
        user.lastHatch = block.timestamp;
        marketMiners = marketMiners.add(hasMiners.div(MARKET_MINER_DIVISOR_SELL));
        
        if(getBalance() < minerValue) {
            minerValue = getBalance();
        }

        uint256 minersPayout = minerValue.sub(payFees(minerValue));
        token_BUSD.transfer(msg.sender, minersPayout);
        user.totalWithdrawn = user.totalWithdrawn.add(minersPayout);
        totalWithdrawn = totalWithdrawn.add(minersPayout);
    }

    function Deposit(address ref, uint256 amount) public{
        require(contractStarted);
        User storage user = users[msg.sender];
        require(amount >= MIN_INVEST_LIMIT, "Mininum investment not met.");
        require(user.initialDeposit.add(amount) <= WALLET_DEPOSIT_LIMIT, "Max deposit limit reached.");
        
        token_BUSD.transferFrom(address(msg.sender), address(this), amount);
        uint256 minerBought = calculateMinerBuy(amount, getBalance().sub(amount));
        user.userDeposit = user.userDeposit.add(amount);
        user.initialDeposit = user.initialDeposit.add(amount);
        user.claimedMiners = user.claimedMiners.add(minerBought);

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
                users[upline].referralMinerRewards = users[upline].referralMinerRewards.add(refRewards);
                totalRefBonus = totalRefBonus.add(refRewards);
            }
        }

        uint256 minersPayout = payFees(amount);
        /** less the fee on total Staked to give more transparency of data. **/
        totalStaked = totalStaked.add(amount.sub(minersPayout));
        totalDeposits = totalDeposits.add(1);
        Compounding(false);
    }

    function payFees(uint256 minerValue) internal returns(uint256){
        uint256 tax = minerValue.mul(TAX).div(PERCENTS_DIVIDER);
        token_BUSD.transfer(dev1, tax);
        token_BUSD.transfer(dev2, tax);
        token_BUSD.transfer(dev3, tax);
        token_BUSD.transfer(dev4, tax);
        token_BUSD.transfer(mkt, tax);
        return tax.mul(5);
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
     uint256 _claimedMiners, uint256 _lastHatch, address _referrer, uint256 _referrals,
	 uint256 _totalWithdrawn, uint256 _referralMinerRewards, uint256 _dailyCompoundBonus, uint256 _lastWithdrawTime) {
         _initialDeposit = users[_adr].initialDeposit;
         _userDeposit = users[_adr].userDeposit;
         _miners = users[_adr].miners;
         _claimedMiners = users[_adr].claimedMiners;
         _lastHatch = users[_adr].lastHatch;
         _referrer = users[_adr].referrer;
         _referrals = users[_adr].referralsCount;
         _totalWithdrawn = users[_adr].totalWithdrawn;
         _referralMinerRewards = users[_adr].referralMinerRewards;
         _dailyCompoundBonus = users[_adr].dailyCompoundBonus;
         _lastWithdrawTime = users[_adr].lastWithdrawTime;
	}

    function initialize(uint256 amount) public{
        if (!contractStarted) {
    		if (msg.sender == owner) {
    		    require(marketMiners == 0);
    			contractStarted = true;
                marketMiners = 86400000000;
                Deposit(msg.sender, amount);
    		} else revert("Contract not yet started.");
    	}
    }

    function getBalance() public view returns (uint256) {
        return token_BUSD.balanceOf(address(this));
	}

    function getTimeStamp() public view returns (uint256) {
        return block.timestamp;
    }

    function getAvailableEarnings(address _adr) public view returns(uint256) {
        uint256 userminers = users[_adr].claimedMiners.add(getMinersSinceLastHatch(_adr));
        return calculateMinersSell(userminers);
    }

    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) public view returns(uint256){
        return SafeMath.div(SafeMath.mul(PSN, bs), SafeMath.add(PSNH, SafeMath.div(SafeMath.add(SafeMath.mul(PSN, rs), SafeMath.mul(PSNH, rt)), rt)));
    }

    function calculateMinersSell(uint256 miners) public view returns(uint256){
        return calculateTrade(miners, marketMiners, getBalance());
    }

    function calculateMinerBuy(uint256 eth,uint256 contractBalance) public view returns(uint256){
        return calculateTrade(eth, contractBalance, marketMiners);
    }

    function calculateMinerBuySimple(uint256 eth) public view returns(uint256){
        return calculateMinerBuy(eth, getBalance());
    }

    function getMinersYield(uint256 amount) public view returns(uint256,uint256) {
        uint256 minersAmount = calculateMinerBuy(amount , getBalance().add(amount).sub(amount));
        uint256 miners = minersAmount.div(MINER_TO_HIRE_1FARM);
        uint256 day = 1 days;
        uint256 minersPerDay = day.mul(miners);
        uint256 earningsPerDay = calculateMinersSellForYield(minersPerDay, amount);
        return(miners, earningsPerDay);
    }

    function calculateMinersSellForYield(uint256 miners,uint256 amount) public view returns(uint256){
        return calculateTrade(miners,marketMiners, getBalance().add(amount));
    }

    function getSiteInfo() public view returns (uint256 _totalStaked, uint256 _totalDeposits, uint256 _totalCompound, uint256 _totalRefBonus) {
        return (totalStaked, totalDeposits, totalCompound, totalRefBonus);
    }

    function getMyFarms() public view returns(uint256){
        return users[msg.sender].miners;
    }

    function getMyMiners() public view returns(uint256){
        return users[msg.sender].claimedMiners.add(getMinersSinceLastHatch(msg.sender));
    }

    function getMinersSinceLastHatch(address adr) public view returns(uint256){
        uint256 secondsSinceLastHatch = block.timestamp.sub(users[adr].lastHatch);
                            /** get min time. **/
        uint256 cutoffTime = min(secondsSinceLastHatch, CUTOFF_STEP);
        uint256 secondsPassed = min(MINER_TO_HIRE_1FARM, cutoffTime);
        return secondsPassed.mul(users[adr].miners);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

    /** percentage setters **/
    // 2880000 - 3%, 2160000 - 4%, 1728000 - 5%, 1440000 - 6%, 1200000 - 7%, 1080000 - 8%
    // 959000 - 9%, 864000 - 10%, 720000 - 12%, 575424 - 15%, 540000 - 16%, 479520 - 18%
    
    function PRC_MINER_TO_HIRE_1FARM(uint256 value) external {
        require(msg.sender == owner, "Team use only.");
        require(value >= 479520 && value <= 2880000); /** min 3% max 12%**/
        MINER_TO_HIRE_1FARM = value;
    }

    function PRC_REFERRAL(uint256 value) external {
        require(msg.sender == owner, "Team use only.");
        require(value >= 10 && value <= 100); /** 10% max **/
        REFERRAL = value;
    }

    /** withdrawal tax **/
    function SET_WITHDRAWAL_TAX(uint256 value) external {
        require(msg.sender == owner, "Team use only.");
        require(value <= 800); /** Max Tax is 80% or lower **/
        WITHDRAWAL_TAX = value;
    }
    
    function SET_WITHDRAW_COOLDOWN(uint256 value) external {
        require(msg.sender == owner, "Team use only");
        require(value <= 24);
        WITHDRAW_COOLDOWN = value * 60 * 60;
    }


}