/**
 *Submitted for verification at BscScan.com on 2022-05-14
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

/*
  _______ _                   .                  .           _____                              
 '   /    /        ___        |     __.    ____ _/_         (      \,___, `   ___    ___    ____
     |    |,---. .'   `       |   .'   \  (      |           `--.  |    \ | .'   ` .'   `  (    
     |    |'   ` |----'       |   |    |  `--.   |              |  |    | | |      |----'  `--. 
     /    /    | `.___,      /\__  `._.' \___.'  \__/      \___.'  |`---' /  `._.' `.___, \___.'
                                                                   \                            
*/  

contract TheLostSpices {
    using SafeMath for uint256;

    /** base parameters **/
    uint256 public SPICES_TO_HIRE_1PIRATES = 1440000;
    uint256 public REFERRAL = 70;
    uint256 public PERCENTS_DIVIDER = 1000;
    uint256 public MARKET_SPICES_DIVISOR = 2;

    uint256 public MIN_INVEST_LIMIT = 1 * 1e17; /** 0.1 BNB  **/
    uint256 public WALLET_DEPOSIT_LIMIT = 50 * 1e18; /** 50 BNB  **/

	uint256 public COMPOUND_BONUS = 20;
	uint256 public COMPOUND_BONUS_MAX_TIMES = 10;
    uint256 public COMPOUND_STEP = 12 * 60 * 60;

    uint256 public WITHDRAWAL_TAX = 800;
    uint256 public COMPOUND_FOR_NO_TAX_WITHDRAWAL = 10;

    uint256 public totalStaked;
    uint256 public totalDeposits;
    uint256 public totalCompound;
    uint256 public totalRefBonus;
    uint256 public totalWithdrawn;

    uint256 public marketSpices;
    uint256 PSN = 10000;
    uint256 PSNH = 5000;
    bool public contractStarted;


	uint256 public CUTOFF_STEP = 48 * 60 * 60;
	uint256 public WITHDRAW_COOLDOWN = 4 * 60 * 60;

    /* addresses */
    address public owner;
    address payable public captainAddress;
    address payable public blackMarketAddress;
    address payable public cofferAddress;
    address payable public piratesLootAddress;

    // Taxes
    uint256 public captainFee = 30;
    uint256 public blackMarketFee = 20;
    uint256 public cofferFee = 30;
    uint256 public piratesLootFee = 1;

    struct User {
        uint256 initialDeposit;
        uint256 userDeposit;
        uint256 miners;
        uint256 claimedSpices;
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

    constructor(address payable _captainAddress, address payable _blackMarketAddress, address payable _cofferAddress, address payable _piratesLootAddress) {
		require(!isContract(_captainAddress) && !isContract(_blackMarketAddress) && !isContract(_cofferAddress) && !isContract(_piratesLootAddress));
        owner = msg.sender;
        captainAddress = _captainAddress;
        blackMarketAddress = _blackMarketAddress;
        cofferAddress = _cofferAddress;
        piratesLootAddress = _piratesLootAddress;
    }

	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }


    // Deposit (with ref address)
    function getOnBoard(address addr) public payable{
        if (!contractStarted) {
    		if (msg.sender == owner) {
    		    require(marketSpices == 0);
    			contractStarted = true;
                marketSpices = 144000000000;
                hirePirates(addr);
    		} else revert("Contract not yet started.");
    	}
    }

    //fund contract with BNB before launch.
    function fundContract() external payable {}

    // Compound
    function recruitMorePirates(bool isCompound) public {
        User storage user = users[msg.sender];
        require(contractStarted, "Contract not yet Started.");

        uint256 spicesUsed = getMySpices();
        uint256 spicesForCompound = spicesUsed;

        if(isCompound) {
            uint256 dailyCompoundBonus = getDailyCompoundBonus(msg.sender, spicesForCompound);
            spicesForCompound = spicesForCompound.add(dailyCompoundBonus);
            uint256 spicesUsedValue = calculateEggSell(spicesForCompound);
            user.userDeposit = user.userDeposit.add(spicesUsedValue);
            totalCompound = totalCompound.add(spicesUsedValue);
        } 

        if(block.timestamp.sub(user.lastHatch) >= COMPOUND_STEP) {
            if(user.dailyCompoundBonus < COMPOUND_BONUS_MAX_TIMES) {
                user.dailyCompoundBonus = user.dailyCompoundBonus.add(1);
            }
            //add compoundCount for monitoring purposes.
            user.farmerCompoundCount = user.farmerCompoundCount .add(1);
        }
        
        user.miners = user.miners.add(spicesForCompound.div(SPICES_TO_HIRE_1PIRATES));
        user.claimedSpices = 0;
        user.lastHatch = block.timestamp;

        marketSpices = marketSpices.add(spicesUsed.div(MARKET_SPICES_DIVISOR));
    }

    // Claim
    function getBounty() public{
        require(contractStarted, "Contract not yet Started.");

        User storage user = users[msg.sender];
        uint256 hasSpices = getMySpices();
        uint256 eggValue = calculateEggSell(hasSpices);
        
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
        user.claimedSpices = 0;  
        user.lastHatch = block.timestamp;
        marketSpices = marketSpices.add(hasSpices.div(MARKET_SPICES_DIVISOR));
        
        if(getBalance() < eggValue) {
            eggValue = getBalance();
        }

        uint256 spicesPayout = eggValue.sub(payFees(eggValue));
        payable(address(msg.sender)).transfer(spicesPayout);
        user.totalWithdrawn = user.totalWithdrawn.add(spicesPayout);
        totalWithdrawn = totalWithdrawn.add(spicesPayout);
    }

    /** transfer amount of BNB **/
    function hirePirates(address ref) public payable{
        require(contractStarted, "Contract not yet Started.");
        User storage user = users[msg.sender];
        require(msg.value >= MIN_INVEST_LIMIT, "Mininum investment not met.");
        require(user.initialDeposit.add(msg.value) <= WALLET_DEPOSIT_LIMIT, "Max deposit limit reached.");
        uint256 spicesBought = calculateEggBuy(msg.value, address(this).balance.sub(msg.value));
        user.userDeposit = user.userDeposit.add(msg.value);
        user.initialDeposit = user.initialDeposit.add(msg.value);
        user.claimedSpices = user.claimedSpices.add(spicesBought);

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

        uint256 spicesPayout = payFees(msg.value);
        totalStaked = totalStaked.add(msg.value.sub(spicesPayout));
        totalDeposits = totalDeposits.add(1);
        recruitMorePirates(false);
    }

    function payFees(uint256 eggValue) internal returns(uint256){
        uint256 captainAddressTax = eggValue.mul(captainFee).div(PERCENTS_DIVIDER);
        uint256 blackMarketTax = eggValue.mul(blackMarketFee).div(PERCENTS_DIVIDER);
        uint256 cofferTax = eggValue.mul(cofferFee).div(PERCENTS_DIVIDER);
        uint256 piratesLootTax = eggValue.mul(piratesLootFee).div(PERCENTS_DIVIDER);
        captainAddress.transfer(captainAddressTax);
        blackMarketAddress.transfer(blackMarketTax);
        cofferAddress.transfer(cofferTax);
        piratesLootAddress.transfer(piratesLootTax);
        return captainAddressTax + blackMarketTax + cofferTax + piratesLootTax; // return total amount of taxes
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
     uint256 _claimedSpices, uint256 _lastHatch, address _referrer, uint256 _referrals,
	 uint256 _totalWithdrawn, uint256 _referralEggRewards, uint256 _dailyCompoundBonus, uint256 _farmerCompoundCount, uint256 _lastWithdrawTime) {
         _initialDeposit = users[_adr].initialDeposit;
         _userDeposit = users[_adr].userDeposit;
         _miners = users[_adr].miners;
         _claimedSpices = users[_adr].claimedSpices;
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
        uint256 userSpices = users[_adr].claimedSpices.add(getSpicesSinceLastHatch(_adr));
        return calculateEggSell(userSpices);
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

    function calculateEggSell(uint256 spices) public view returns(uint256){
        return calculateTrade(spices, marketSpices, getBalance());
    }

    function calculateEggBuy(uint256 eth,uint256 contractBalance) public view returns(uint256){
        return calculateTrade(eth, contractBalance, marketSpices);
    }

    function calculateEggBuySimple(uint256 eth) public view returns(uint256){
        return calculateEggBuy(eth, getBalance());
    }

    /** How many miners and spices per day user will recieve based on BNB deposit **/
    function getSpicesYield(uint256 amount) public view returns(uint256,uint256) {
        uint256 spicesAmount = calculateEggBuy(amount , getBalance().add(amount).sub(amount));
        uint256 miners = spicesAmount.div(SPICES_TO_HIRE_1PIRATES);
        uint256 day = 1 days;
        uint256 spicesPerDay = day.mul(miners);
        uint256 earningsPerDay = calculateEggSellForYield(spicesPerDay, amount);
        return(miners, earningsPerDay);
    }

    function calculateEggSellForYield(uint256 spices,uint256 amount) public view returns(uint256){
        return calculateTrade(spices,marketSpices, getBalance().add(amount));
    }

    function getSiteInfo() public view returns (uint256 _totalStaked, uint256 _totalDeposits, uint256 _totalCompound, uint256 _totalRefBonus) {
        return (totalStaked, totalDeposits, totalCompound, totalRefBonus);
    }

    function getMyMiners() public view returns(uint256){
        return users[msg.sender].miners;
    }

    function getMySpices() public view returns(uint256){
        return users[msg.sender].claimedSpices.add(getSpicesSinceLastHatch(msg.sender));
    }

    function getSpicesSinceLastHatch(address adr) public view returns(uint256){
        uint256 secondsSinceLastHatch = block.timestamp.sub(users[adr].lastHatch);
                            /** get min time. **/
        uint256 cutoffTime = min(secondsSinceLastHatch, CUTOFF_STEP);
        uint256 secondsPassed = min(SPICES_TO_HIRE_1PIRATES, cutoffTime);
        return secondsPassed.mul(users[adr].miners);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

    function CHANGE_OWNERSHIP(address value) external {
        require(msg.sender == owner, "Admin use only.");
        owner = value;
    }   

    /** percentage setters **/

    // 2592000 - 3%, 2160000 - 4%, 1728000 - 5%, 1440000 - 6%, 1200000 - 7%
    // 1080000 - 8%, 959000 - 9%, 864000 - 10%, 720000 - 12%
    
    function PRC_SPICES_TO_HIRE_1PIRATES(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value >= 479520 && value <= 720000); /** min 3% max 12%**/
        SPICES_TO_HIRE_1PIRATES = value;
    }

    function PRC_CAPTAIN_FEE(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value >= 1 && value <= 50);
        captainFee = value;
    }

    function PRC_CAPTAIN_BLACK_MARKET(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value >= 1 && value <= 50);
        blackMarketFee = value;
    }

    function PRC_CAPTAIN_COFFER(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value >= 1 && value <= 50);
        cofferFee = value;
    }

    function PRC_CAPTAIN_PIRATES_LOOT(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value >= 1 && value <= 50);
        piratesLootFee = value;
    }

    function PRC_REFERRAL(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value >= 10 && value <= 100);
        REFERRAL = value;
    }

    function PRC_MARKET_SPICES_DIVISOR(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value >= 1 && value <= 50);
        MARKET_SPICES_DIVISOR = value;
    }

    function SET_WITHDRAWAL_TAX(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value >= 1 && value <= 800);
        WITHDRAWAL_TAX = value;
    }

    function BONUS_DAILY_COMPOUND(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value >= 10 && value <= 900);
        COMPOUND_BONUS = value;
    }

    function BONUS_DAILY_COMPOUND_BONUS_MAX_TIMES(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value >= 1 && value <= 30);
        COMPOUND_BONUS_MAX_TIMES = value;
    }

    function BONUS_COMPOUND_STEP(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value >= 1 && value <= 24);
        COMPOUND_STEP = value * 60 * 60;
    }

    function SET_INVEST_MIN(uint256 value) external {
        require(msg.sender == owner, "Admin use only");
        MIN_INVEST_LIMIT = value * 1e17;
    }

    function SET_CUTOFF_STEP(uint256 value) external {
        require(value >= 24 && value <= 72);
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