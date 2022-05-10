/**
 *Submitted for verification at BscScan.com on 2022-05-09
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

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

contract Ukramine {
    using SafeMath for uint256;

    IToken public token_BUSD;
    
    uint256 public MINERALS_TO_BUILD_1EXTRACTOR = 1080000;
    uint256 public PERCENTS_DIVIDER = 1000;
    uint256 public REFERRAL = 100; // 10%
    uint256 public TAX = 50;
    uint256 public MARKET_MINERALS_DIVISOR = 2; // 50%
    uint256 public MARKET_MINERALS_DIVISOR_SELL = 1; // 100%

    uint256 public MIN_INVEST_LIMIT = 10 * 1e18; /** 10 BUSD  **/
    uint256 public WALLET_DEPOSIT_LIMIT = 10000 * 1e18; /** 10000 BUSD  **/

    uint256 public REBUILD_BONUS = 30; /** 3% **/
    uint256 public REBUILD_BONUS_MAX_TIMES = 10; /** 10 times / 5 days. **/
    uint256 public REBUILD_STEP = 12 * 60 * 60; /** every 12 hours. **/

    uint256 public COLLECTION_TAX = 750; // 75%
    uint256 public REBUILD_FOR_NO_TAX_COLLECTION = 10; // rebuild periods, for no tax collection.

    uint256 public totalStaked;
    uint256 public totalDeposits;
    uint256 public totalRebuild;
    uint256 public totalRefBonus;
    uint256 public totalCollected;

    uint256 public marketMinerals;
    uint256 PSN = 10000;
    uint256 PSNH = 5000;
    bool public contractStarted;

    uint256 public CUTOFF_STEP = 48 * 60 * 60; /** 48 hours  **/

    address public owner;
    address public mkt;
    address public shop;

    struct User {
        uint256 initialDeposit;
        uint256 userDeposit;
        uint256 extractors;
        uint256 claimedMinerals;
        uint256 lastRebuild;
        address referrer;
        uint256 referralsCount;
        uint256 referralMineralRewards;
        uint256 totalCollected;
        uint256 dailyRebuildBonus;
        uint256 lastWithdrawTime;
    }

    mapping(address => User) public users;

    mapping(address => uint256) public customMineralsPerExtractor;
    mapping(address => uint256) public customCutoffStep;
    mapping(address => uint256) public customCollectionTax;
    mapping(address => uint256) public customRebuildBonus;
    mapping(address => uint256) public customRebuildBonusMaxTimes;
    mapping(address => uint256) public customRebuildStep;
    mapping(address => uint256) public customRebuildForNoTaxCollection;
    mapping(address => uint256) public customReferral;

    constructor(address _erctoken, address _mkt, address _shop) {
        require(!isContract(_mkt));
        owner = msg.sender;
        mkt = _mkt;
        shop = _shop;
        token_BUSD = IToken(_erctoken);
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function getMineralsPerExtractor(address addr) public view returns (uint256) {
        uint256 minerals;

        if (customMineralsPerExtractor[addr] > 0) {
            minerals = customMineralsPerExtractor[addr];
        } else {
            minerals = MINERALS_TO_BUILD_1EXTRACTOR;
        }

        return minerals;
    }

    function getCutoffStep(address addr) public view returns (uint256) {
        uint256 cutoff;

        if (customCutoffStep[addr] > 0) {
            cutoff = customCutoffStep[addr];
        } else {
            cutoff = CUTOFF_STEP;
        }

        return cutoff;
    }

    function getCollectionTax(address addr) public view returns (uint256) {
        uint256 tax;

        if (customCollectionTax[addr] > 0) {
            tax = customCollectionTax[addr];
        } else {
            tax = COLLECTION_TAX;
        }

        return tax;
    }

    function getRebuildBonus(address addr) public view returns (uint256) {
        uint256 bonus;

        if (customRebuildBonus[addr] > 0) {
            bonus = customRebuildBonus[addr];
        } else {
            bonus = REBUILD_BONUS;
        }

        return bonus;
    }

    function getRebuildBonusMaxTimes(address addr) public view returns (uint256) {
        uint256 times;

        if (customRebuildBonusMaxTimes[addr] > 0) {
            times = customRebuildBonusMaxTimes[addr];
        } else {
            times = REBUILD_BONUS_MAX_TIMES;
        }

        return times;
    }

    function getRebuildStep(address addr) public view returns (uint256) {
        uint256 step;

        if (customRebuildStep[addr] > 0) {
            step = customRebuildStep[addr];
        } else {
            step = REBUILD_STEP;
        }

        return step;
    }

    function getRebuildForNoTaxCollection(address addr) public view returns (uint256) {
        uint256 rebuild;

        if (customRebuildForNoTaxCollection[addr] > 0) {
            rebuild = customRebuildForNoTaxCollection[addr];
        } else {
            rebuild = REBUILD_FOR_NO_TAX_COLLECTION;
        }

        return rebuild;
    }

    function getReferral(address addr) public view returns (uint256) {
        uint256 referral;

        if (customReferral[addr] > 0) {
            referral = customReferral[addr];
        } else {
            referral = REFERRAL;
        }

        return referral;
    }

    function rebuildExtractors(bool isRebuild) public {
        User storage user = users[msg.sender];
        require(contractStarted, "Contract not yet Started.");

        uint256 mineralsUsed = getMyMinerals();
        uint256 mineralsForRebuild = mineralsUsed;

        if(isRebuild) {
            uint256 dailyRebuildBonus = getDailyRebuildBonus(msg.sender, mineralsForRebuild);
            mineralsForRebuild = mineralsForRebuild.add(dailyRebuildBonus);
            uint256 mineralsUsedValue = calculateMineralSell(mineralsForRebuild);
            user.userDeposit = user.userDeposit.add(mineralsUsedValue);
            totalRebuild = totalRebuild.add(mineralsUsedValue);
        } 

        if(block.timestamp.sub(user.lastRebuild) >= getRebuildStep(msg.sender)) {
            if(user.dailyRebuildBonus < getRebuildBonusMaxTimes(msg.sender)) {
                user.dailyRebuildBonus = user.dailyRebuildBonus.add(1);
            }
        }
        
        user.extractors = user.extractors.add(mineralsForRebuild.div(getMineralsPerExtractor(msg.sender)));
        user.claimedMinerals = 0;
        user.lastRebuild = block.timestamp;

        marketMinerals = marketMinerals.add(mineralsUsed.div(MARKET_MINERALS_DIVISOR));
    }

    function collectMinerals() public{
        require(contractStarted);
        User storage user = users[msg.sender];
        uint256 hasMinerals = getMyMinerals();
        uint256 mineralValue = calculateMineralSell(hasMinerals);
        
        /** 
            if user rebuild < to mandatory rebuild periods**/
        if(user.dailyRebuildBonus < getRebuildForNoTaxCollection(msg.sender)){
            //daily rebuild bonus count will not reset and mineralValue will be deducted with collection tax.
            mineralValue = mineralValue.sub(mineralValue.mul(getCollectionTax(msg.sender)).div(PERCENTS_DIVIDER));
        }else{
            //set daily rebuild bonus count to 0 and mineralValue will remain without deductions
             user.dailyRebuildBonus = 0;   
        }
        
        user.lastWithdrawTime = block.timestamp;
        user.claimedMinerals = 0;  
        user.lastRebuild = block.timestamp;
        marketMinerals = marketMinerals.add(hasMinerals.div(MARKET_MINERALS_DIVISOR_SELL));
        
        if(getBalance() < mineralValue) {
            mineralValue = getBalance();
        }

        uint256 mineralsPayout = mineralValue.sub(payFees(mineralValue));
        token_BUSD.transfer(msg.sender, mineralsPayout);
        user.totalCollected = user.totalCollected.add(mineralsPayout);
        totalCollected = totalCollected.add(mineralsPayout);
    }

    function buildExtractors(address ref, uint256 amount) public{
        require(contractStarted);
        User storage user = users[msg.sender];
        require(amount >= MIN_INVEST_LIMIT, "Mininum investment not met.");
        require(user.initialDeposit.add(amount) <= WALLET_DEPOSIT_LIMIT, "Max deposit limit reached.");
        
        token_BUSD.transferFrom(address(msg.sender), address(this), amount);
        uint256 mineralsBought = calculateMineralBuy(amount, getBalance().sub(amount));
        user.userDeposit = user.userDeposit.add(amount);
        user.initialDeposit = user.initialDeposit.add(amount);
        user.claimedMinerals = user.claimedMinerals.add(mineralsBought);

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
                uint256 refRewards = amount.mul(getReferral(ref)).div(PERCENTS_DIVIDER);
                token_BUSD.transfer(upline, refRewards);
                users[upline].referralMineralRewards = users[upline].referralMineralRewards.add(refRewards);
                totalRefBonus = totalRefBonus.add(refRewards);
            }
        }

        uint256 mineralsPayout = payFees(amount);
        /** less the fee on total Staked to give more transparency of data. **/
        totalStaked = totalStaked.add(amount.sub(mineralsPayout));
        totalDeposits = totalDeposits.add(1);
        rebuildExtractors(false);
    }

    function payFees(uint256 mineralValue) internal returns(uint256){
        uint256 tax = mineralValue.mul(TAX).div(PERCENTS_DIVIDER);
        token_BUSD.transfer(mkt, tax);
        return tax;
    }

    function getDailyRebuildBonus(address _adr, uint256 amount) public view returns(uint256){
        if(users[_adr].dailyRebuildBonus == 0) {
            return 0;
        } else {
            uint256 totalBonus = users[_adr].dailyRebuildBonus.mul(getRebuildBonus(_adr)); 
            uint256 result = amount.mul(totalBonus).div(PERCENTS_DIVIDER);
            return result;
        }
    }

    function getUserInfo(address _adr) public view returns(uint256 _initialDeposit, uint256 _userDeposit, uint256 _extractors,
     uint256 _claimedMinerals, uint256 _lastRebuild, address _referrer, uint256 _referrals,
     uint256 _totalCollected, uint256 _referralMineralRewards, uint256 _dailyRebuildBonus, uint256 _lastWithdrawTime) {
         _initialDeposit = users[_adr].initialDeposit;
         _userDeposit = users[_adr].userDeposit;
         _extractors = users[_adr].extractors;
         _claimedMinerals = users[_adr].claimedMinerals;
         _lastRebuild = users[_adr].lastRebuild;
         _referrer = users[_adr].referrer;
         _referrals = users[_adr].referralsCount;
         _totalCollected = users[_adr].totalCollected;
         _referralMineralRewards = users[_adr].referralMineralRewards;
         _dailyRebuildBonus = users[_adr].dailyRebuildBonus;
         _lastWithdrawTime = users[_adr].lastWithdrawTime;
    }

    function initialize(uint256 amount) public{
        if (!contractStarted) {
            if (msg.sender == owner) {
                require(marketMinerals == 0);
                contractStarted = true;
                marketMinerals = 86400000000;
                buildExtractors(msg.sender, amount);
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
        uint256 userMinerals = users[_adr].claimedMinerals.add(getMineralsSinceLastRebuild(_adr));
        return calculateMineralSell(userMinerals);
    }

    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) public view returns(uint256){
        return SafeMath.div(SafeMath.mul(PSN, bs), SafeMath.add(PSNH, SafeMath.div(SafeMath.add(SafeMath.mul(PSN, rs), SafeMath.mul(PSNH, rt)), rt)));
    }

    function calculateMineralSell(uint256 minerals) public view returns(uint256){
        return calculateTrade(minerals, marketMinerals, getBalance());
    }

    function calculateMineralBuy(uint256 eth,uint256 contractBalance) public view returns(uint256){
        return calculateTrade(eth, contractBalance, marketMinerals);
    }

    function calculateMineralBuySimple(uint256 eth) public view returns(uint256){
        return calculateMineralBuy(eth, getBalance());
    }

    function getMineralsYield(address adr, uint256 amount) public view returns(uint256,uint256) {
        uint256 mineralsAmount = calculateMineralBuy(amount , getBalance().add(amount).sub(amount));
        uint256 extractors = mineralsAmount.div(getMineralsPerExtractor(adr));
        uint256 day = 1 days;
        uint256 mineralsPerDay = day.mul(extractors);
        uint256 earningsPerDay = calculateMineralSellForYield(mineralsPerDay, amount);
        return(extractors, earningsPerDay);
    }

    function calculateMineralSellForYield(uint256 minerals,uint256 amount) public view returns(uint256){
        return calculateTrade(minerals,marketMinerals, getBalance().add(amount));
    }

    function getSiteInfo() public view returns (uint256 _totalStaked, uint256 _totalDeposits, uint256 _totalRebuild, uint256 _totalRefBonus) {
        return (totalStaked, totalDeposits, totalRebuild, totalRefBonus);
    }

    function getMyExtractors() public view returns(uint256){
        return users[msg.sender].extractors;
    }

    function getMyMinerals() public view returns(uint256){
        return users[msg.sender].claimedMinerals.add(getMineralsSinceLastRebuild(msg.sender));
    }

    function getMineralsSinceLastRebuild(address adr) public view returns(uint256){
        uint256 secondsSinceLastRebuild = block.timestamp.sub(users[adr].lastRebuild);
                            /** get min time. **/
        uint256 cutoffTime = min(secondsSinceLastRebuild, getCutoffStep(adr));
        uint256 secondsPassed = min(getMineralsPerExtractor(adr), cutoffTime);
        return secondsPassed.mul(users[adr].extractors);
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
        require(msg.sender == owner, "Admin use only.");
        mkt = value;
    }

    function CHANGE_SHOP_CONTRACT(address value) external {
        require(msg.sender == owner, "Admin use only.");
        shop = value;
    }

    /** percentage setters **/

    // 2592000 - 3%, 2160000 - 4%, 1728000 - 5%, 1440000 - 6%, 1200000 - 7%, 1080000 - 8%
    // 959000 - 9%, 864000 - 10%, 720000 - 12%, 575424 - 15%, 540000 - 16%, 479520 - 18%
    
    function PRC_MINERALS_TO_BUILD_1EXTRACTOR(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value >= 479520 && value <= 2592000); /** min 3% max 12%**/
        MINERALS_TO_BUILD_1EXTRACTOR = value;
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

    function PRC_MARKET_MINERALS_DIVISOR(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value <= 50); /** 50 = 2% **/
        MARKET_MINERALS_DIVISOR = value;
    }

    /** Collection tax **/
    function SET_COLLECTION_TAX(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value <= 800); /** Max Tax is 80% or lower **/
        COLLECTION_TAX = value;
    }
    
    function SET_REBUILD_FOR_NO_TAX_COLLECTION(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        REBUILD_FOR_NO_TAX_COLLECTION = value;
    }

    function BONUS_DAILY_REBUILD(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value >= 10 && value <= 900);
        REBUILD_BONUS = value;
    }

    function BONUS_DAILY_REBUILD_BONUS_MAX_TIMES(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value <= 30);
        REBUILD_BONUS_MAX_TIMES = value;
    }

    function BONUS_REBUILD_STEP(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        REBUILD_STEP = value * 60 * 60;
    }

    function SET_MIN_INVEST_LIMIT(uint256 value) external {
        require(msg.sender == owner, "Admin use only");
        MIN_INVEST_LIMIT = value * 1e18;
    }

    function SET_CUTOFF_STEP(uint256 value) external {
        require(msg.sender == owner, "Admin use only");
        CUTOFF_STEP = value * 60 * 60;
    }

    function SET_WALLET_DEPOSIT_LIMIT(uint256 value) external {
        require(msg.sender == owner, "Admin use only");
        require(value >= 20);
        WALLET_DEPOSIT_LIMIT = value * 1e18;
    }

    /** Shop functionalities for perks **/

    function SET_CUSTOM_MINERALS_PER_EXTRACTOR(address adr, uint256 minerals) external {
        require(msg.sender == shop, "Shop use only");
        customMineralsPerExtractor[adr] = minerals;
    }

    function SET_CUSTOM_CUTOFF_STEP(address adr, uint256 cutoff) external {
        require(msg.sender == shop, "Shop use only");
        customCutoffStep[adr] = cutoff;
    }

    function SET_CUSTOM_COLLECTION_TAX(address adr, uint256 tax) external {
        require(msg.sender == shop, "Shop use only");
        customCollectionTax[adr] = tax;
    }

    function SET_CUSTOM_REBUILD_BONUS(address adr, uint256 bonus) external {
        require(msg.sender == shop, "Shop use only");
        customRebuildBonus[adr] = bonus;
    }

    function SET_CUSTOM_REBUILD_BONUS_MAX_TIMES(address adr, uint256 times) external {
        require(msg.sender == shop, "Shop use only");
        customRebuildBonusMaxTimes[adr] = times;
    }

    function SET_CUSTOM_REBUILD_STEP(address adr, uint256 step) external {
        require(msg.sender == shop, "Shop use only");
        customRebuildStep[adr] = step;
    }

    function SET_CUSTOM_REBUILD_FOR_NO_TAX_COLLECTION(address adr, uint256 rebuild) external {
        require(msg.sender == shop, "Shop use only");
        customRebuildForNoTaxCollection[adr] = rebuild;
    }
}