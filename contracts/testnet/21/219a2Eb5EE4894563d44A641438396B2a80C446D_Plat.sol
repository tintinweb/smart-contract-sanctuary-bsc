/**
 *Submitted for verification at BscScan.com on 2022-07-09
*/

// File: contracts/Platins.sol

/**

Plat is set up to passively reward holders in the stablecoin BUSD. When you deposit your BUSD using the dApp you will receive:
- Up to 8% Daily in BUSD rewards
- 8% Base Referral Bonus
- 8% Tax on Deposits and Claims only
- 48 Hours Rewards Accumulation Cut-Off to help sustain project longevity.
- 5 Day Auto Compound Feature, another way to help sustain the project for the long term
- 80% Fee For Early Withdrawals.
 
Benefits for Platinum Holders:
- Extra stacking compound bonus when compounding every 12hrs+ for all holders of Platinum token based on a tiered system.
- Extra Referral Bonuses for all holders of Platinum token based on a tiered system.
- 3% of the total tax will be used to buy-back Platinum tokens.
- 5 Tier system that gives you more % bonuses depending on how many tokens you have.
 
Partnership Bonuses for Projects:
- Extra stacking compound bonus when compounding every 12hrs+ for all holders of the Partnership token
- Extra Referral Bonuses for all holders of the Partnership token
- Partnership token can specify minimum amount of tokens to hold to get bonuses.
- 100% of Initial Partnership Agreement Cost will go into the contract and will remain inaccessible.
- Partnership Token can use referral bonuses to buyback and market their token 
 
Automation:
- Investors can enable/disable automation at any time
- Investors can choose compound intervals between 4 and 24 hours (suggest to choose 13-24 hours to receive stacking Platinum/Partnership bonuses)
- Automation will follow the 6+1 Strategy. Compound for 6 days and then claim on the 7th day. ALL Automatic.
- Automation fee of 1% per compound/claim

*/

pragma solidity 0.8.14;

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

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Plat {
    using SafeMath for uint256;

    IToken public token_BUSD;
	address erctoken = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7; /** BUSD Testnet **/
    // address erctoken = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; /** BUSD Mainnet **/
    
    uint256 public PLATIN_TO_HIRE_1MINERS = 1080000;
    uint256 public PERCENTS_DIVIDER = 1000;
    uint256 public REFERRAL = 80;
    uint256 public TAX = 80;
    uint256 public BBTAX = 30;
    uint256 public DEVTAX = 30;
    uint256 public MKTTAX = 20;
    uint256 public AUTOTAX = 10;
    uint256 public MARKET_PLATIN_DIVISOR = 5; // 20%
    uint256 public MARKET_PLATIN_DIVISOR_SELL = 2; // 50%

    uint256 public MIN_INVEST_LIMIT = 10 * 1e18; /** 10 BUSD  **/
    uint256 public WALLET_DEPOSIT_LIMIT = 20000 * 1e18; /** 20000 BUSD  **/

	uint256 public COMPOUND_BONUS = 5; /** 0.5% **/
	uint256 public COMPOUND_BONUS_MAX_TIMES = 10; /** 10 times / 5 days. **/
    uint256 public COMPOUND_STEP = 12 * 60 * 60; /** every 12 hours. **/

    uint256 public WITHDRAWAL_TAX = 800; //800 = 80%, 600 = 60%, 400 = 40%
    uint256 public COMPOUND_FOR_NO_TAX_WITHDRAWAL = 10; // compound for no tax withdrawal.

    uint256 public totalStaked;
    uint256 public totalDeposits;
    uint256 public totalCompound;
    uint256 public totalRefBonus;
    uint256 public totalWithdrawn;

    uint256 public marketPlatin;
    uint256 PSN = 10000;
    uint256 PSNH = 5000;
    bool public contractStarted;

	uint256 public CUTOFF_STEP = 48 * 60 * 60; /** 48 hours  **/
	uint256 public WITHDRAW_COOLDOWN = 4 * 60 * 60; /** 4 hours  **/

    address public owner;
    address public bbadr;
    address public devadr;
    address public mktadr;
    address public autoadr;

    uint256 goldvalue = 100000 * 10**18;
    uint256 platinumvalue = 400000 * 10**18;
    uint256 platinumhonorvalue = 1500000 * 10**18;
    uint256 diamondvalue = 3000000 * 10**18;
    uint256 diamondhonorvalue = 6000000 * 10**18;

    uint256 goldbonus = 2;
    uint256 platinumbonus = 5;
    uint256 platinumhonorbonus = 10;
    uint256 diamondbonus = 15;
    uint256 diamondhonorbonus = 20;

    // IBEP20 platinum = IBEP20(0x7700Edc3DBb30cBB7603212E061c804220c3cA54);
    IBEP20 platinum = IBEP20(0x7700Edc3DBb30cBB7603212E061c804220c3cA54);// testnet address
        
    address[] partnerships;
    mapping (address => uint256) partnershipIndexes;

    struct Partner {
        uint256 min_amount;
        uint256 bonus;
    }

    mapping(address => Partner) public partners;

    struct User {
        uint256 initialDeposit;
        uint256 userDeposit;
        uint256 miners;
        uint256 claimedPlatin;
        uint256 lastCompound;
        address referrer;
        uint256 referralsCount;
        uint256 referralPlatinRewards;
        uint256 totalWithdrawn;
        uint256 dailyCompoundBonus;
        uint256 lastWithdrawTime;
    }

    mapping(address => User) public users;

    address[] automate;
    mapping (address => uint256) automateIndexes;

    struct Automation {
        uint256 day;
        uint256 runhours;
        uint256 dayrun;
        uint256 lastrun;
    }

    mapping(address => Automation) public automations;


    constructor(address _bbadr, address _devadr, address _mktadr, address _autoadr) {
		require(!isContract(_bbadr) && !isContract(_devadr) && !isContract(_mktadr) && !isContract(_autoadr));
        owner = msg.sender;
        bbadr = _bbadr;
        devadr = _devadr;
        mktadr = _mktadr;
        autoadr = _autoadr;
        token_BUSD = IToken(erctoken);
    }

	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function getPlatinumBalance(address adr) public view returns(uint256) {
        return platinum.balanceOf(address(adr));
    }

    function getBonusPlatinum(address adr) public view returns(uint256) {
         if(platinum.balanceOf(address(adr)) >= diamondhonorvalue){
            return diamondhonorbonus;
        }
        else if(platinum.balanceOf(address(adr)) >= diamondvalue){
            return diamondbonus;
        }
        else if(platinum.balanceOf(address(adr)) >= platinumhonorvalue) {
            return platinumhonorbonus;
        }
        else if(platinum.balanceOf(address(adr))>= platinumvalue){
            return platinumbonus;
        }
        else if(platinum.balanceOf(address(adr))>= goldvalue){
            return goldbonus;
        }
        else
            return 0;
    }

    function compoundPlatin(bool isCompound) public {
        User storage user = users[msg.sender];
        require(contractStarted, "Contract not yet Started.");
        require(automations[msg.sender].day < 1, "Holder is automated!");

        uint256 platinUsed = getMyPlatin();
        uint256 platinForCompound = platinUsed;

        if(isCompound) {
            uint256 dailyCompoundBonus = getDailyCompoundBonus(msg.sender, platinForCompound);
            platinForCompound = platinForCompound.add(dailyCompoundBonus);
            uint256 platinUsedValue = calculatePlatinSell(platinForCompound);
            user.userDeposit = user.userDeposit.add(platinUsedValue);
            totalCompound = totalCompound.add(platinUsedValue);
        } 

        if(block.timestamp.sub(user.lastCompound) >= COMPOUND_STEP) {
            if(user.dailyCompoundBonus < COMPOUND_BONUS_MAX_TIMES) {
                user.dailyCompoundBonus = user.dailyCompoundBonus.add(1);
            }
        }
        
        user.miners = user.miners.add(platinForCompound.div(PLATIN_TO_HIRE_1MINERS));
        user.claimedPlatin = 0;
        user.lastCompound = block.timestamp;

        marketPlatin = marketPlatin.add(platinUsed.div(MARKET_PLATIN_DIVISOR));
    }

    function compoundAutoPlatin(address adr, bool isCompound) internal {
        User storage user = users[adr];
         
        uint256 platinUsed = users[adr].claimedPlatin.add(getPlatinSinceLastCompound(adr));
        uint256 platinForCompound = platinUsed;

        if(isCompound) {
            uint256 dailyCompoundBonus = getDailyCompoundBonus(adr, platinForCompound);
            platinForCompound = platinForCompound.add(dailyCompoundBonus);
            uint256 platinUsedValue = calculatePlatinSell(platinForCompound);
            platinUsedValue = platinUsedValue - payAuto(platinUsedValue);
            platinForCompound = platinForCompound - platinForCompound.mul(AUTOTAX).div(PERCENTS_DIVIDER);
            user.userDeposit = user.userDeposit.add(platinUsedValue);
            totalCompound = totalCompound.add(platinUsedValue);
        } 

        if(block.timestamp.sub(user.lastCompound) >= COMPOUND_STEP) {
            if(user.dailyCompoundBonus < COMPOUND_BONUS_MAX_TIMES) {
                user.dailyCompoundBonus = user.dailyCompoundBonus.add(1);
            }
        }
        
        user.miners = user.miners.add(platinForCompound.div(PLATIN_TO_HIRE_1MINERS));
        user.claimedPlatin = 0;
        user.lastCompound = block.timestamp;

        marketPlatin = marketPlatin.add(platinUsed.div(MARKET_PLATIN_DIVISOR));
    }

    function sellPlatin() public{
        require(contractStarted);
        require(automations[msg.sender].day < 1, "Holder is automated!");
        User storage user = users[msg.sender];
        uint256 hasPlatin = getMyPlatin();
        uint256 platinValue = calculatePlatinSell(hasPlatin);
        
        
            //if user compound < to mandatory compound days
        if(user.dailyCompoundBonus < COMPOUND_FOR_NO_TAX_WITHDRAWAL){
            //daily compound bonus count will not reset and platinValue will be deducted with 80% feedback fee.
            platinValue = platinValue.sub(platinValue.mul(WITHDRAWAL_TAX).div(PERCENTS_DIVIDER));
        }else{
            //set daily compound bonus count to 0 and platinValue will remain without deductions
             user.dailyCompoundBonus = 0;   
        }
        
        user.lastWithdrawTime = block.timestamp;
        user.claimedPlatin = 0;  
        user.lastCompound = block.timestamp;
        marketPlatin = marketPlatin.add(hasPlatin.div(MARKET_PLATIN_DIVISOR_SELL));
        
        if(getBalance() < platinValue) {
            platinValue = getBalance();
        }

        uint256 platinPayout = platinValue.sub(payFees(platinValue));
        token_BUSD.transfer(msg.sender, platinPayout);
        user.totalWithdrawn = user.totalWithdrawn.add(platinPayout);
        totalWithdrawn = totalWithdrawn.add(platinPayout);
    }

    function sellAutoPlatin(address adr) internal {
        User storage user = users[adr];
        uint256 hasPlatin = users[adr].claimedPlatin.add(getPlatinSinceLastCompound(adr));
        uint256 platinValue = calculatePlatinSell(hasPlatin);

        user.dailyCompoundBonus = 0;  
        user.lastWithdrawTime = block.timestamp;
        user.claimedPlatin = 0;  
        user.lastCompound = block.timestamp;
        marketPlatin = marketPlatin.add(hasPlatin.div(MARKET_PLATIN_DIVISOR_SELL));
        
        if(getBalance() < platinValue) {
            platinValue = getBalance();
        }

        uint256 platinPayout = platinValue.sub(payFees(platinValue));
        platinPayout = platinPayout.sub(payAuto(platinValue));
        token_BUSD.transfer(adr, platinPayout);
        user.totalWithdrawn = user.totalWithdrawn.add(platinPayout);
        totalWithdrawn = totalWithdrawn.add(platinPayout);
    }

    function buyPlatin(address ref, uint256 amount) public{
        require(contractStarted);
        User storage user = users[msg.sender];
        require(automations[msg.sender].day < 1, "Holder is automated!");

        require(amount >= MIN_INVEST_LIMIT, "Mininum investment not met.");
        require(user.initialDeposit.add(amount) <= WALLET_DEPOSIT_LIMIT, "Max deposit limit reached.");
        
        token_BUSD.transferFrom(address(msg.sender), address(this), amount);
        uint256 platinBought = calculatePlatinBuy(amount, getBalance().sub(amount));
        user.userDeposit = user.userDeposit.add(amount);
        user.initialDeposit = user.initialDeposit.add(amount);
        user.claimedPlatin = user.claimedPlatin.add(platinBought);

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
                uint256 refRewards = amount.mul(REFERRAL+getBonusPlatinum(ref)+getBonusPartnership(ref)).div(PERCENTS_DIVIDER);
                token_BUSD.transfer(upline, refRewards);
                users[upline].referralPlatinRewards = users[upline].referralPlatinRewards.add(refRewards);
                totalRefBonus = totalRefBonus.add(refRewards);
            }
        }

        uint256 platinPayout = payFees(amount);
        /** less the fee on total Staked to give more transparency of data. **/
        totalStaked = totalStaked.add(amount.sub(platinPayout));
        totalDeposits = totalDeposits.add(1);
        compoundPlatin(false);
    }

    function payFees(uint256 platinValue) internal returns(uint256){
        uint256 tax = platinValue.mul(TAX).div(PERCENTS_DIVIDER);
        token_BUSD.transfer(bbadr, platinValue.mul(BBTAX).div(PERCENTS_DIVIDER));
        token_BUSD.transfer(devadr, platinValue.mul(DEVTAX).div(PERCENTS_DIVIDER));
        token_BUSD.transfer(mktadr, platinValue.mul(MKTTAX).div(PERCENTS_DIVIDER));
        return tax.mul(1);
    }

    function payAuto(uint256 platinValue) internal returns(uint256){
        uint256 tax = platinValue.mul(AUTOTAX).div(PERCENTS_DIVIDER);
         token_BUSD.transfer(autoadr, platinValue.mul(AUTOTAX).div(PERCENTS_DIVIDER));
         return tax.mul(1);
    }

    function getDailyCompoundBonus(address _adr, uint256 amount) public view returns(uint256){
        if(users[_adr].dailyCompoundBonus == 0) {
            return 0;
        } else {
            uint256 totalBonus = users[_adr].dailyCompoundBonus.mul(getBonusPlatinum(_adr)+getBonusPartnership(_adr)); 
            uint256 result = amount.mul(totalBonus).div(PERCENTS_DIVIDER);
            return result;
        }
    }

    function getUserInfo(address _adr) public view returns(uint256 _initialDeposit, uint256 _userDeposit, uint256 _miners,
     uint256 _claimedPlatin, uint256 _lastCompound, address _referrer, uint256 _referrals,
	 uint256 _totalWithdrawn, uint256 _referralPlatinRewards, uint256 _dailyCompoundBonus, uint256 _lastWithdrawTime) {
         _initialDeposit = users[_adr].initialDeposit;
         _userDeposit = users[_adr].userDeposit;
         _miners = users[_adr].miners;
         _claimedPlatin = users[_adr].claimedPlatin;
         _lastCompound = users[_adr].lastCompound;
         _referrer = users[_adr].referrer;
         _referrals = users[_adr].referralsCount;
         _totalWithdrawn = users[_adr].totalWithdrawn;
         _referralPlatinRewards = users[_adr].referralPlatinRewards;
         _dailyCompoundBonus = users[_adr].dailyCompoundBonus;
         _lastWithdrawTime = users[_adr].lastWithdrawTime;
	}

    function initialize(uint256 amount) public{
        if (!contractStarted) {
    		if (msg.sender == owner) {
    		    require(marketPlatin == 0);
    			contractStarted = true;
                marketPlatin = 86400000000;
                buyPlatin(msg.sender, amount);
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
        uint256 userPlatin = users[_adr].claimedPlatin.add(getPlatinSinceLastCompound(_adr));
        return calculatePlatinSell(userPlatin);
    }

    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) public view returns(uint256){
        return SafeMath.div(SafeMath.mul(PSN, bs), SafeMath.add(PSNH, SafeMath.div(SafeMath.add(SafeMath.mul(PSN, rs), SafeMath.mul(PSNH, rt)), rt)));
    }

    function calculatePlatinSell(uint256 platin) public view returns(uint256){
        return calculateTrade(platin, marketPlatin, getBalance());
    }

    function calculatePlatinBuy(uint256 eth,uint256 contractBalance) public view returns(uint256){
        return calculateTrade(eth, contractBalance, marketPlatin);
    }

    function calculatePlatinBuySimple(uint256 eth) public view returns(uint256){
        return calculatePlatinBuy(eth, getBalance());
    }

    function getPlatinYield(uint256 amount) public view returns(uint256,uint256) {
        uint256 platinAmount = calculatePlatinBuy(amount , getBalance().add(amount).sub(amount));
        uint256 miners = platinAmount.div(PLATIN_TO_HIRE_1MINERS);
        uint256 day = 1 days;
        uint256 platinPerDay = day.mul(miners);
        uint256 earningsPerDay = calculatePlatinSellForYield(platinPerDay, amount);
        return(miners, earningsPerDay);
    }

    function calculatePlatinSellForYield(uint256 platin,uint256 amount) public view returns(uint256){
        return calculateTrade(platin,marketPlatin, getBalance().add(amount));
    }

    function getSiteInfo() public view returns (uint256 _totalStaked, uint256 _totalDeposits, uint256 _totalCompound, uint256 _totalRefBonus) {
        return (totalStaked, totalDeposits, totalCompound, totalRefBonus);
    }

    function getMyMiners() public view returns(uint256){
        return users[msg.sender].miners;
    }

    function getMyPlatin() public view returns(uint256){
        return users[msg.sender].claimedPlatin.add(getPlatinSinceLastCompound(msg.sender));
    }

    function getPlatinSinceLastCompound(address adr) public view returns(uint256){
        uint256 secondsSinceLastCompound = block.timestamp.sub(users[adr].lastCompound);
                            /** get min time. **/
        uint256 cutoffTime = min(secondsSinceLastCompound, CUTOFF_STEP);
        uint256 secondsPassed = min(PLATIN_TO_HIRE_1MINERS, cutoffTime);
        return secondsPassed.mul(users[adr].miners);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

    function REMOVE_PARTNERSHIP(address partnership) external {
        require(msg.sender == owner, "Admin use only.");
        partnerships[partnershipIndexes[partnership]] = partnerships[partnerships.length-1];
        partnershipIndexes[partnerships[partnerships.length-1]] = partnershipIndexes[partnership];
        partnerships.pop();
        delete partners[partnership];

    }
   
    function ADD_PARTNERSHIP(address partnership, uint256 minamount, uint256 bonus) external {
        require(msg.sender == owner, "Admin use only.");
        partnershipIndexes[partnership] = partnerships.length;
        partnerships.push(partnership);

        partners[partnership].bonus = bonus;
        partners[partnership].min_amount = minamount;
    }

    function CHANGE_PARTNERSHIP(address partnership, uint256 minamount, uint256 bonus) external {
        require(msg.sender == owner, "Admin use only.");

        partners[partnership].bonus = bonus;
        partners[partnership].min_amount = minamount;
    }


    function getBonusPartnership(address adr) public view returns(uint256) {
        uint256 partnershipCount = partnerships.length;
        if(partnershipCount == 0) { return 0; }

        uint256 iterations = 0;
        uint256 bonus = 0;

        while(iterations < partnershipCount) {
            IBEP20 partner = IBEP20(partnerships[iterations]);
            if(partner.balanceOf(address(adr)) >= partners[partnerships[iterations]].min_amount ) {
                if(partners[partnerships[iterations]].bonus > bonus) {
                    bonus = partners[partnerships[iterations]].bonus;
                }
            }
            iterations++;
        }
        return bonus;
    }

    function getPartnershipCount() public view returns(uint256) {
        return partnerships.length;
    }

    function verifyPartnership(address token) public view returns(uint256) {
        uint256 partnershipCount = partnerships.length;
        if(partnershipCount == 0) { return 0; }

        uint256 iterations = 0;

        while(iterations < partnershipCount) {
            address partner = partnerships[iterations];
            if(partner == token) {return 1;}
            iterations++;
        }
        return 0;
    }

    function ADD_AUTOMATE(uint256 hrs) external {
        require(contractStarted);
        require(automations[msg.sender].day == 0, "Address already exists!");
        require(hrs >= 4 && hrs <= 24, "Hours are not correct!");

        automateIndexes[msg.sender] = automate.length;
        automate.push(msg.sender);

        automations[msg.sender].day = 1;
        automations[msg.sender].runhours = hrs;
        automations[msg.sender].lastrun = block.timestamp;
        automations[msg.sender].dayrun = block.timestamp;
    }

    function REMOVE_AUTOMATE() external {
        require(contractStarted);
        require(automations[msg.sender].day >= 1, "Address doesn't exists!");
        automate[automateIndexes[msg.sender]] = automate[automate.length-1];
        automateIndexes[automate[automate.length-1]] = automateIndexes[msg.sender];
        automate.pop();
        delete automations[msg.sender];
    }

    function getAutomateCounts() public view returns(uint256) {
        return automate.length;
    }

    function runAutomate() external {
        require(msg.sender == owner, "Admin use only.");
        require(contractStarted);
        uint256 automateCount = automate.length;

        uint256 iterations = 0;
        while(iterations < automateCount) {
            address adr = automate[iterations];
            uint256 hasPlatin = users[adr].claimedPlatin.add(getPlatinSinceLastCompound(adr));
            if(hasPlatin > 0){
                if ((block.timestamp - automations[adr].lastrun) >= (automations[adr].runhours*3600)) {  //86400=24hrs, 3600=1hr, 7200=2hr, 10800=3rs, 14400=4hrs 21600=6hrs, 43200=12hrs, 64800=18
                    if(automations[adr].day == 7 && ((block.timestamp - automations[adr].dayrun) >= (24*3600))) {
                        automations[adr].day = 1;
                        automations[adr].lastrun = automations[adr].lastrun + (automations[adr].runhours*3600);
                        automations[adr].dayrun = automations[adr].dayrun + (24*3600);
                        sellAutoPlatin(adr);
                    }
                    else {
                        if(automations[adr].day<7) {
                            compoundAutoPlatin(adr,true);
                        }
                        if((block.timestamp - automations[adr].dayrun) >= (24*3600)) {
                            automations[adr].day++;
                            automations[adr].dayrun = automations[adr].dayrun + (24*3600);
                        }
                        automations[adr].lastrun = automations[adr].lastrun + (automations[adr].runhours*3600);
                    }
                }
            }
            iterations++;
        }
    }    

    function CHANGE_TIERBONUS(uint256 dh, uint256 d,uint256 ph, uint256 p,uint256 g) external {
        require(msg.sender == owner, "Admin use only.");
        diamondhonorbonus = dh;
        diamondbonus = d;
        platinumhonorbonus = ph;
        platinumbonus = p;
        goldbonus = g;
    }

    function CHANGE_TIERS(uint256 dh, uint256 d,uint256 ph, uint256 p,uint256 g) external {
        require(msg.sender == owner, "Admin use only.");
        diamondhonorvalue = dh * 10**18;
        diamondvalue = d * 10**18;
        platinumhonorvalue = ph * 10**18;
        platinumvalue = p * 10**18;
        goldvalue = g * 10**18;
    }

    function CHANGE_PLATINUM(IBEP20 value) external {
        require(msg.sender == owner, "Admin use only.");
         platinum = value;
    }

    /** wallet addresses setters **/
    function CHANGE_OWNERSHIP(address value) external {
        require(msg.sender == owner, "Admin use only.");
        owner = value;
    }

    function CHANGE_BB_WALLET(address value) external {
        require(msg.sender == owner, "Admin use only.");
        bbadr = value;
    }

    function CHANGE_DEV_WALLET(address value) external {
        require(msg.sender == owner, "Admin use only.");
        devadr = value;
    }

    function CHANGE_MKT_WALLET(address value) external {
        require(msg.sender == owner, "Admin use only.");
        mktadr = value;
    }

    function CHANGE_AUTO_WALLET(address value) external {
        require(msg.sender == owner, "Admin use only.");
        autoadr = value;
    }

    /** percentage setters **/

    // 2592000 - 3%, 2160000 - 4%, 1728000 - 5%, 1440000 - 6%, 1200000 - 7%, 1080000 - 8%
    // 959000 - 9%, 864000 - 10%, 720000 - 12%, 575424 - 15%, 540000 - 16%, 479520 - 18%
    
    function PRC_PLATIN_TO_HIRE_1MINERS(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value >= 479520 && value <= 2592000); /** min 3% max 12%**/
        PLATIN_TO_HIRE_1MINERS = value;
    }

    function PRC_TAX(uint256 t, uint256 b, uint256 d, uint256 m) external {
        require(msg.sender == owner, "Admin use only.");
        require(b+d+m <= 100); /** 10% max **/
        TAX = t;
        BBTAX = b;
        DEVTAX = d;
        MKTTAX = m;
    }    

    function PRC_REFERRAL(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value >= 10 && value <= 100); /** 10% max **/
        REFERRAL = value;
    }

    function PRC_MARKET_PLATIN_DIVISOR(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value <= 50); /** 50 = 2% **/
        MARKET_PLATIN_DIVISOR = value;
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

    function SET_WALLET_DEPOSIT_LIMIT(uint256 value) external {
        require(msg.sender == owner, "Admin use only");
        require(value >= 20);
        WALLET_DEPOSIT_LIMIT = value * 1e18;
    }

}