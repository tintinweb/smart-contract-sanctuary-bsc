/**
 *Submitted for verification at BscScan.com on 2022-08-18
*/

pragma solidity 0.8.11;

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
library SafeMaths {
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
contract LevMiner {
    using SafeMaths for uint256;
    IToken public token_BUSD;
    // address erctoken = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7; /** BUSD Testnet **/
    address insContract = 0xAf58b358aBEC8539D8Df17F06Ab89D9421e6237A; // insurance contract
    address erctoken = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; /** BUSD Mainnet **/
    
    uint256 public LEVS_TO_HIRE_1MINER = 1728000; // 5% roi
    uint256 public PERCENTS_DIVIDER = 1000;
    uint256 public REFERRAL = 50; // 5% referral fee
    uint256 public LEFTOVER = 950; 
    uint256 public TAX = 50; // 5% tax
    uint256 public MARKET_MINERS_DIVISION = 2; // 50%
    uint256 public MARKET_LEVS_DIVISOR_SELL = 1; // 100%
    uint256 public MIN_INVEST_LIMIT = 10 * 1e18; /** 10 BUSD  **/
    uint256 public WALLET_DEPOSIT_LIMIT = 50000 * 1e18; /** 50000 BUSD  **/
    uint256 public THRESHOLD1 = 1000 * 1e18;
    uint256 public THRESHOLD2 = 5000 * 1e18;
    uint256 public THRESHOLD3 = 10000 * 1e18;
    uint256 public MAX_SELL_LIMIT = 30000 * 1e18; /** 30000 BUSD  **/
    uint256 public COMPOUND_BONUS = 30; /** 3% **/
    uint256 public COMPOUND_BONUS_MAX_TIMES = 10; /** 10 times  **/
    uint256 public COMPOUND_STEP = 10 * 60 * 60; /** every 10 hours. **/
    uint256 public WITHDRAWAL_TAX = 500; // 50% tax if you choose to withdraw before 5 days of compounding
    uint256 public COMPOUND_FOR_NO_TAX_WITHDRAWAL = 5; // compound days, for no tax withdrawal.
    uint256 public totalStaked;
    uint256 public totalDeposits;
    uint256 public totalCompound;
    uint256 public totalRefBonus;
    uint256 public totalWithdrawn;
    uint256 public marketLevs;
    uint256 PSN = 10000;
    uint256 PSNH = 5000;
    bool public contractStarted;
    uint256 public CUTOFF_STEP = 36 * 60 * 60; /** 36 hours  **/
    uint256 public WITHDRAW_COOLDOWN = 6 * 60 * 60; /** 6 hours  **/ 
    uint256 public insurancePool;
    address public owner;
    address public levLockerContract;
    address public projectContract;
    address public contestWinner;
    struct User {
        uint256 initialDeposit;
        uint256 userDeposit;
        uint256 miners;
        uint256 claimedLevs;
        uint256 lastCompound;
        address referrer;
        uint256 referralsCount;
        uint256 referralMinerRewards;
        uint256 totalWithdrawn;
        uint256 dailyCompoundBonus;
        uint256 lastWithdrawTime;
        uint256 winnerTrack;
    }
    mapping(address => User) public users;
    
    constructor(address _levLockerContract, address _projectContract) {
        // require(!isContract(_levLockerContract) && !isContract(projectContract));
        owner = msg.sender;
        levLockerContract = _levLockerContract;
        projectContract = _projectContract;
        token_BUSD = IToken(erctoken);
    }
    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function setWinner(address winner) external  {
        require(msg.sender == owner, "Admin use only.");
        contestWinner = winner; 
    }

    function wdWinnings() external  {
        User storage user = users[msg.sender];
        require (msg.sender == contestWinner, "You are not the contest winner");
        require(user.winnerTrack != 2, "You already won once!");
        uint256 theAmt = 100;
        token_BUSD.transfer(msg.sender, theAmt);
        user.winnerTrack = 2;
    }

    function setLevMiners(bool isCompound) public {
        User storage user = users[msg.sender];
        require(contractStarted, "Contract not yet Started.");
        uint256 levMinersUsed = getMyLevMiners();
        uint256 levMinersForCompound = levMinersUsed;
        if(isCompound) {
            uint256 dailyCompoundBonus = getDailyCompoundBonus(msg.sender, levMinersForCompound);
            levMinersForCompound = levMinersForCompound.add(dailyCompoundBonus);
            uint256 levMinersUsedValue = calculateMinerSell(levMinersForCompound);
            user.userDeposit = user.userDeposit.add(levMinersUsedValue);
            totalCompound = totalCompound.add(levMinersUsedValue);
        }
        if(block.timestamp.sub(user.lastCompound) >= COMPOUND_STEP) {
            if(user.dailyCompoundBonus < COMPOUND_BONUS_MAX_TIMES) {
                user.dailyCompoundBonus = user.dailyCompoundBonus.add(1);
            }
        }
        
        user.miners = user.miners.add(levMinersForCompound.div(LEVS_TO_HIRE_1MINER));
        user.claimedLevs = 0;
        user.lastCompound = block.timestamp;
        marketLevs = marketLevs.add(levMinersUsed.div(MARKET_MINERS_DIVISION));
    }
    function sellLevMinings() public{
        require(contractStarted);
        User storage user = users[msg.sender];
        uint256 hasLevMiners = getMyLevMiners();
        uint256 levMinerValue = calculateMinerSell(hasLevMiners);
        
        /** 
            if user compound < to mandatory compound days**/
        if(user.dailyCompoundBonus < COMPOUND_FOR_NO_TAX_WITHDRAWAL){
            //daily compound bonus count will not reset and levMinerValue will be deducted with 60% feedback tax.
            levMinerValue = levMinerValue.sub(levMinerValue.mul(WITHDRAWAL_TAX).div(PERCENTS_DIVIDER));
        }else{
            //set daily compound bonus count to 0 and levMinerValue will remain without deductions
             user.dailyCompoundBonus = user.dailyCompoundBonus - 3; // each time a user decides to withdraw, we reduce their compounds by 3   
        }
        
        user.lastWithdrawTime = block.timestamp;
        user.claimedLevs = 0;  
        user.lastCompound = block.timestamp;
        marketLevs = marketLevs.add(hasLevMiners.div(MARKET_LEVS_DIVISOR_SELL));
        
        if(getBalance() < levMinerValue) {
            levMinerValue = getBalance();
        }
        uint256 levMiningPayout = levMinerValue.sub(payFees(levMinerValue));
        require(levMiningPayout <= MAX_SELL_LIMIT, "Withdrawal amount too high, compound and try again.");
        token_BUSD.transfer(msg.sender, levMiningPayout);
        user.totalWithdrawn = user.totalWithdrawn.add(levMiningPayout);
        totalWithdrawn = totalWithdrawn.add(levMiningPayout);
    }
    function buyLevMiners(address ref, uint256 amount) public{
        require(contractStarted, "Contract hasn't started yet.");
        User storage user = users[msg.sender];
        require(amount >= MIN_INVEST_LIMIT, "Mininum investment not met.");
        
        token_BUSD.transferFrom(address(msg.sender), address(this), amount);
        
        uint256 newAmt = amount.mul(LEFTOVER).div(PERCENTS_DIVIDER);
        uint256 insFee = amount.mul(TAX).div(PERCENTS_DIVIDER);
        insurancePool += insFee;
        
       
        uint256 levMinersBought = calculateLevMinerBuy(newAmt, getBalance().sub(newAmt));
        user.userDeposit = user.userDeposit.add(newAmt);
        user.initialDeposit = user.initialDeposit.add(newAmt);
        user.claimedLevs = user.claimedLevs.add(levMinersBought);
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
                uint256 refRewards = newAmt.mul(REFERRAL).div(PERCENTS_DIVIDER);
                token_BUSD.transfer(upline, refRewards);
                users[upline].referralMinerRewards = users[upline].referralMinerRewards.add(refRewards);
                totalRefBonus = totalRefBonus.add(refRewards);
            }
        }
        uint256 levMiningPayout = payFees(amount);
        token_BUSD.transfer(insContract, insFee);
        /** less the fee on total Staked to give more transparency of data. **/
        totalStaked += newAmt.sub(levMiningPayout);
        totalDeposits += 1;
        setLevMiners(false);
    }
    function payFees(uint256 levMinerValue) internal returns(uint256){
        uint256 tax = levMinerValue.mul(TAX).div(PERCENTS_DIVIDER);
        token_BUSD.transfer(levLockerContract, tax);
        token_BUSD.transfer(projectContract, tax);
        return tax.mul(3);
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
     uint256 _claimedLevs, uint256 _lastCompound, address _referrer, uint256 _referrals,
     uint256 _totalWithdrawn, uint256 _referralMinerRewards, uint256 _dailyCompoundBonus, uint256 _lastWithdrawTime) {
         _initialDeposit = users[_adr].initialDeposit;
         _userDeposit = users[_adr].userDeposit;
         _miners = users[_adr].miners;
         _claimedLevs = users[_adr].claimedLevs;
         _lastCompound = users[_adr].lastCompound;
         _referrer = users[_adr].referrer;
         _referrals = users[_adr].referralsCount;
         _totalWithdrawn = users[_adr].totalWithdrawn;
         _referralMinerRewards = users[_adr].referralMinerRewards;
         _dailyCompoundBonus = users[_adr].dailyCompoundBonus;
         _lastWithdrawTime = users[_adr].lastWithdrawTime;
    }
    function startContract(uint256 amount) public{ // requires a purchase amount
        if (!contractStarted) {
            if (msg.sender == owner) {
                require(marketLevs == 0);
                contractStarted = true;
                marketLevs = 86400000000;
                buyLevMiners(msg.sender, amount);
            } else revert("Contract not yet started.");
        } else revert("Contract has already started.");
    }
    function getBalance() public view returns (uint256) {
        return token_BUSD.balanceOf(address(this));
    }
    function getTimeStamp() public view returns (uint256) {
        return block.timestamp;
    }
    function getAvailableEarnings(address _adr) public view returns(uint256) {
        uint256 userMiners = users[_adr].claimedLevs.add(getLevsSinceLastCompound(_adr));
        return calculateMinerSell(userMiners);
    }
    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) public view returns(uint256){
        return SafeMaths.div(SafeMaths.mul(PSN, bs), SafeMaths.add(PSNH, SafeMaths.div(SafeMaths.add(SafeMaths.mul(PSN, rs), SafeMaths.mul(PSNH, rt)), rt)));
    }
    function calculateMinerSell(uint256 levs) public view returns(uint256){
        return calculateTrade(levs, marketLevs, getBalance());
    }
    function calculateLevMinerBuy(uint256 eth,uint256 contractBalance) public view returns(uint256){
        return calculateTrade(eth, contractBalance, marketLevs);
    }
    function calculateLevMinerBuySimple(uint256 eth) public view returns(uint256){
        return calculateLevMinerBuy(eth, getBalance());
    }
    function getMinersYield(uint256 amount) public view returns(uint256,uint256) {
        uint256 levsAmount = calculateLevMinerBuy(amount , getBalance().add(amount).sub(amount));
        uint256 miners = levsAmount.div(LEVS_TO_HIRE_1MINER);
        uint256 day = 1 days;
        uint256 levsPerDay = day.mul(miners);
        uint256 earningsPerDay = calculateLevMiningForYield(levsPerDay, amount);
        return(miners, earningsPerDay);
    }
    function calculateLevMiningForYield(uint256 levs,uint256 amount) public view returns(uint256){
        return calculateTrade(levs,marketLevs, getBalance().add(amount));
    }
    function getSiteInfo() public view returns (uint256 _totalStaked, uint256 _totalDeposits, uint256 _totalCompound, uint256 _totalRefBonus) {
        return (totalStaked, totalDeposits, totalCompound, totalRefBonus);
    }
    function getMyMiners() public view returns(uint256){
        return users[msg.sender].miners;
    }
    function getMyLevMiners() public view returns(uint256){
        return users[msg.sender].claimedLevs.add(getLevsSinceLastCompound(msg.sender));
    }
    function getLevsSinceLastCompound(address adr) public view returns(uint256){
        uint256 secondsSinceLastCompound = block.timestamp.sub(users[adr].lastCompound);
                            /** get min time. **/
        uint256 cutoffTime = min(secondsSinceLastCompound, CUTOFF_STEP);
        uint256 secondsPassed = min(LEVS_TO_HIRE_1MINER, cutoffTime);
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
    function CHANGE_CONTRACT(address value) external {
        require(msg.sender == levLockerContract, "Admin use only.");
        levLockerContract = value;
    }
    function CHANGE_INS(address value) external {
        require(msg.sender == projectContract, "Admin use only.");
        projectContract = value;
    }
    /** percentage setters **/
    // 2592000 - 3%, 2160000 - 4%, 1728000 - 5%, 1440000 - 6%, 1200000 - 7%, 1080000 - 8%
    // 959000 - 9%, 864000 - 10%, 720000 - 12%, 575424 - 15%, 540000 - 16%, 479520 - 18%
    
    function PRC_LEVS_TO_HIRE_1MINERS(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value >= 479520 && value <= 2592000); /** min 3% max 12%**/
        LEVS_TO_HIRE_1MINER = value;
    }
    function PRC_TAX(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value <= 100); /** 10% max **/
        TAX = value;
    }    
    function PRC_REFERRAL(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value >= 10 && value <= 100); /** 10% max **/
        REFERRAL = value;
    }
    function PRC_MARKET_MINERS_DIVISOR(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value <= 50); /** 50 = 2% **/
        MARKET_MINERS_DIVISION = value;
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
        require(value <= 30);
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
        require(value <= 24);
        WITHDRAW_COOLDOWN = value * 60 * 60;
    }
    function recoverERC20(uint256 tokenAmount) public {
        require(msg.sender == owner);
        token_BUSD.transfer(owner, tokenAmount);
     }
    function SET_WALLET_DEPOSIT_LIMIT(uint256 value) external {
        require(msg.sender == owner, "Admin use only");
        require(value >= 20);
        WALLET_DEPOSIT_LIMIT = value * 1e18;
    }
}