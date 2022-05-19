/**
 *Submitted for verification at BscScan.com on 2022-05-19
*/

// File: contracts/cfd.sol


pragma solidity 0.8.13;

contract cfd2{
    using SafeMath for uint256;

    /** base parameters **/
    uint256 public EGGS_TO_HIRE_1MINERS = 1440000;
    uint256 public REFERRAL = 50;
    uint256 public PERCENTS_DIVIDER = 1000;
    uint256 public TAX = 30;
    uint256 public MKT = 10;
    uint256 public INS = 10;
    uint256 public MARKET_EGGS_DIVISOR = 2;

    uint256 public PRELAUNCH_BONUS = 25;
    uint256 public MIN_INVEST_LIMIT = 0; 
    uint256 public WALLET_DEPOSIT_LIMIT = 50 * 1e18; 

	uint256 public COMPOUND_BONUS = 20;
	uint256 public COMPOUND_BONUS_MAX_TIMES = 5;
    uint256 public COMPOUND_STEP = 24 * 60 * 60;

    uint256 public WITHDRAWAL_TAX = 800;
    uint256 public COMPOUND_FOR_NO_TAX_WITHDRAWAL = 10;

    uint256 public totalStaked;
    uint256 public totalDeposits;
    uint256 public totalCompound;
    uint256 public totalRefBonus;
    uint256 public totalWithdrawn;

    uint256 public marketEggs;
    uint256 PSN = 10000;
    uint256 PSNH = 5000;
    bool public contractStarted = false;
    bool public prelaunchStarted = false; 
    bool public prelaunchEnded = false;

	uint256 public CUTOFF_STEP = 48 * 60 * 60;
	uint256 public WITHDRAW_COOLDOWN = 4 * 60 * 60; 

    /* addresses */
    address public owner;
    address payable public dev;
    address payable public ins;
    address payable public mkt;

    struct User {
        uint256 initialDeposit;
        uint256 userDeposit;
        uint256 miners;
        uint256 claimedEggs;
        uint256 lastHatch;
        uint256 totalWithdrawn;
        uint256 dailyCompoundBonus;
        uint256 CoffeeHolicCompoundCount; 
        uint256 lastWithdrawTime;
        address referrer;
        uint256 referralsCount;
        uint256 referralEggRewards;
        address cafeFavourite;
        uint256 cafeTipsContribution;
    }

    mapping(address => User) public users;

    struct Cafe{
        bytes32 cafeName;
        uint256 tipsRate;
        uint256 totalTips;
        uint256 tips;
        uint256 membersNo;
        uint256 availableCafeReward;
        uint256 totalCafeReward;
        uint256 lastDistributed;
    }
    mapping (address => Cafe) public cafes;
    uint256 public CAFE_OWNER_DEPOSIT_LIMIT = 1 * 1e16; 
    uint256 public CAFE_TIPS_CONTRIBUTION = 10;

    
    mapping(address => uint256) internal cafeRewardsCollected;

    function prelaunch(address ref) public payable{
        require(prelaunchStarted, "Prelaunch has not started.");
        require(!prelaunchEnded, "Prelaunch ended.");
        require(!contractStarted, "Contract has Started.");
        User storage user = users[msg.sender];
        require(msg.value >= MIN_INVEST_LIMIT, "Mininum investment not met.");
        require(user.initialDeposit.add(msg.value) <= WALLET_DEPOSIT_LIMIT, "Max deposit limit reached.");
        uint256 eggsBought = calculateEggBuy(msg.value, address(this).balance.sub(msg.value).mul(PRELAUNCH_BONUS.div(PERCENTS_DIVIDER)));
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

        if (user.cafeFavourite != address(0)) {
            address cafeId = user.cafeFavourite;
            if (cafeId != address(0)) {
                uint256 cafeRefRewards = eggsBought.mul(cafes[cafeId].tipsRate).div(PERCENTS_DIVIDER);
                cafes[cafeId].tips += cafeRefRewards;
                cafes[cafeId].totalTips += cafeRefRewards;
                user.cafeTipsContribution += cafeRefRewards;
            }
        }

        uint256 eggsPayout = payFees(msg.value);
        totalStaked = totalStaked.add(msg.value.sub(eggsPayout));
        totalDeposits = totalDeposits.add(1);
        buyMoreBeans(false);

    }


    constructor(address payable _dev, address payable _ins, address payable _mkt) {
		require(!isContract(_dev)  && !isContract(_ins) && !isContract(_mkt));
        owner = msg.sender;
        dev = _dev;
        ins = _ins;
        mkt = _mkt;
    }

	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function startBazaar(address addr) public payable{
        if (!contractStarted) {
    		if (msg.sender == owner) {
    			contractStarted = true;
                prelaunchStarted = true;
                prelaunchEnded = true;
                buyBeans(addr);
    		} else revert("Contract not yet started.");
    	}
    }

    function startBazaarPreLaunch(address addr) public payable{
        if (!prelaunchStarted && !prelaunchEnded) {
    		if (msg.sender == owner) {
    		    require(marketEggs == 0);
    			prelaunchStarted = true;
                marketEggs = 144000000000;
                prelaunch(addr);
    		} else revert("prelaunch not yet started.");
    	}
    }


    function fundContract() external payable {}

    function buyMoreBeans(bool isCompound) public {
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
            
            user.CoffeeHolicCompoundCount = user.CoffeeHolicCompoundCount .add(1);
        }

        if (user.cafeFavourite != address(0)) {
            address cafeId = user.cafeFavourite;
            if (cafeId != address(0)) {
                uint256 cafeRefRewards = eggsForCompound.mul(cafes[cafeId].tipsRate).div(PERCENTS_DIVIDER);
                cafes[cafeId].tips += cafeRefRewards;
                cafes[cafeId].totalTips += cafeRefRewards;
                user.cafeTipsContribution += cafeRefRewards;
            }
        }
        
        user.miners = user.miners.add(eggsForCompound.div(EGGS_TO_HIRE_1MINERS));
        user.claimedEggs = 0;
        user.lastHatch = block.timestamp;

        marketEggs = marketEggs.add(eggsUsed.div(MARKET_EGGS_DIVISOR));
    }

    function sellShots() public{
        require(contractStarted, "Contract not yet Started.");

        User storage user = users[msg.sender];
        uint256 hasEggs = getMyEggs();
        uint256 eggValue = calculateEggSell(hasEggs);
      
        if(user.dailyCompoundBonus < COMPOUND_FOR_NO_TAX_WITHDRAWAL){
           
            eggValue = eggValue.sub(eggValue.mul(WITHDRAWAL_TAX).div(PERCENTS_DIVIDER));
        }else{
          
             user.dailyCompoundBonus = 0;   
             user.CoffeeHolicCompoundCount = 0;  
        }
        
        user.lastWithdrawTime = block.timestamp;
        user.claimedEggs = 0;  
        user.lastHatch = block.timestamp;
        marketEggs = marketEggs.add(hasEggs.div(MARKET_EGGS_DIVISOR));
        
        if(getBalance() < eggValue) {
            eggValue = getBalance();
        }

        uint256 eggsPayout = eggValue.sub(payFees(eggValue));
        payable(address(msg.sender)).transfer(eggsPayout);
        user.totalWithdrawn = user.totalWithdrawn.add(eggsPayout);
        totalWithdrawn = totalWithdrawn.add(eggsPayout);
    }
     
    function buyBeans(address ref) public payable{
        require(contractStarted, "Contract not yet Started.");
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

        if (user.cafeFavourite != address(0)) {
            address cafeId = user.cafeFavourite;
            if (cafeId != address(0)) {
                uint256 cafeRefRewards = eggsBought.mul(cafes[cafeId].tipsRate).div(PERCENTS_DIVIDER);
                cafes[cafeId].tips += cafeRefRewards;
                cafes[cafeId].totalTips += cafeRefRewards;
                user.cafeTipsContribution += cafeRefRewards;
            }
        }

        uint256 eggsPayout = payFees(msg.value);
        totalStaked = totalStaked.add(msg.value.sub(eggsPayout));
        totalDeposits = totalDeposits.add(1);
        buyMoreBeans(false);
    }

   //cafejig
    function setUpCafe(bytes32 newCafeName, uint256 cafeTipsRate) public {
        require(contractStarted, "Contract not yet Started.");
        require(users[msg.sender].initialDeposit >= CAFE_OWNER_DEPOSIT_LIMIT, "Limit not reached");
        require(cafeTipsRate >10, "high tips rate"); 

        require(users[msg.sender].initialDeposit >= CAFE_OWNER_DEPOSIT_LIMIT, "Limit not reached");
        require(cafeTipsRate >10, "High tips rate");  

        Cafe storage cafe = cafes[msg.sender];
        cafe.cafeName = newCafeName;
        cafe.tipsRate = cafeTipsRate.mul(10);
        users[msg.sender].cafeFavourite = msg.sender;
        cafe.membersNo +=1;
    
    }

    function joinCafe(address refCafe) public {
        require(contractStarted, "Contract not yet Started.");
        
         if (users[msg.sender].cafeFavourite != address(0)) {
             address cafeId = users[msg.sender].cafeFavourite;
             cafes[cafeId].membersNo -=1;
             users[msg.sender].cafeFavourite == address(0);
         }

        users[msg.sender].cafeFavourite = refCafe;
        users[msg.sender].cafeTipsContribution = 0;
        cafes[refCafe].membersNo +=1;
        
    }
    
    function cafeAdminshareTips() public {
        require(contractStarted, "Contract not yet Started.");
    
        Cafe storage cafe = cafes[msg.sender];
        require((block.timestamp.sub(cafe.lastDistributed)/ 60 / 60 / 24) <= 30 days , "Coffee tips not full."); 
        uint256 cafeEggs = cafe.tips;
        uint256 adminshare = cafeEggs.mul(cafe.tipsRate).div(PERCENTS_DIVIDER);
        uint256 eggsadminPayout = adminshare.sub(payFees(adminshare));
        cafe.availableCafeReward = (cafeEggs.sub(adminshare)).div(cafe.membersNo);

        payable(address(msg.sender)).transfer(eggsadminPayout);

    }
    function cafeCollectTips() public {
        require(contractStarted, "Contract not yet Started.");
        require((block.timestamp.sub(cafeRewardsCollected[msg.sender])/ 60 / 60 / 24) <= 30 days , "No reward to collect."); 

        User storage user = users[msg.sender];
        uint256 cafeTipsEggs = cafes[user.cafeFavourite].availableCafeReward;
        uint256 eggsuserPayout = cafeTipsEggs.sub(payFees(cafeTipsEggs ));
        cafeRewardsCollected[msg.sender]=block.timestamp;
        payable(address(msg.sender)).transfer(eggsuserPayout);
    }  

    function getUserCafeInfo(address _adr) public view returns(uint256 _cafeTipsContribution, bytes32 _cafeFavourite, uint256 _tipsRate, uint256 _totalTips,
    uint256 _tips,uint256 _membersNo,uint256 _availableCafeReward, uint256 _totalCafeReward, uint256 _lastDistributed){
        
         _cafeTipsContribution = users[_adr].cafeTipsContribution;
          address caferef= users[_adr].cafeFavourite;
         _cafeFavourite= cafes[caferef].cafeName;
         _tipsRate= cafes[caferef].tipsRate;
         _totalTips= cafes[caferef].totalTips;
         _tips= cafes[caferef].tips;
         _membersNo= cafes[caferef].membersNo;
         _availableCafeReward= cafes[caferef].availableCafeReward;
         _totalCafeReward= cafes[caferef].totalCafeReward;
         _lastDistributed= cafes[caferef].lastDistributed;

	}

    function payFees(uint256 eggValue) internal returns(uint256){
        uint256 tax = eggValue.mul(TAX).div(PERCENTS_DIVIDER);
        uint256 mktng = eggValue.mul(MKT).div(PERCENTS_DIVIDER);
         uint256 insu = eggValue.mul(INS).div(PERCENTS_DIVIDER);
        dev.transfer(tax);
        ins.transfer(insu);
        mkt.transfer(mktng);
        return mktng.add(insu).add(tax);
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
         _farmerCompoundCount = users[_adr].CoffeeHolicCompoundCount;
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

    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) public view returns(uint256){
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

    
    function PRC_EGGS_TO_HIRE_1MINERS(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value >= 479520 && value <= 720000); /** min 3% max 12%**/
        EGGS_TO_HIRE_1MINERS = value;
    }

    function PRC_TAX(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value <= 15);
        TAX = value;
    }

    function PRC_MKT(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value <= 20);
        MKT = value;
    }

    function PRC_REFERRAL(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value >= 10 && value <= 100);
        REFERRAL = value;
    }

    function PRC_MARKET_EGGS_DIVISOR(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value <= 50);
        MARKET_EGGS_DIVISOR = value;
    }

    function SET_WITHDRAWAL_TAX(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value <= 900);
        WITHDRAWAL_TAX = value;
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
        require(value <= 24);
        COMPOUND_STEP = value * 60 * 60;
    }

    function SET_INVEST_MIN(uint256 value) external {
        require(msg.sender == owner, "Admin use only");
        MIN_INVEST_LIMIT = value * 1e17;
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
        require(value >= 10);
        WALLET_DEPOSIT_LIMIT = value * 1 ether;
    }
    
    function SET_COMPOUND_FOR_NO_TAX_WITHDRAWAL(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value <= 12);
        COMPOUND_FOR_NO_TAX_WITHDRAWAL = value;
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