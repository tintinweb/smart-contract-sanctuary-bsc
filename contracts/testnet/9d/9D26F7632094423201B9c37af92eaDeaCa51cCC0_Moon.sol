/**
 *Submitted for verification at BscScan.com on 2022-07-14
*/

// SPDX-License-Identifier: MIT
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

contract Moon {
    using SafeMath for uint256;

    IToken public token_BUSD;
	address erctoken = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7; /** BUSD Testnet **/
    //address erctoken = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; /** BUSD Mainnet **/
    
    uint256 public MOON_TO_HIRE_1MINERS = 1080000;
    uint256 public PERCENTS_DIVIDER = 1000;
    uint256 public REFERRAL = 80;
    uint256 public TAX = 80;
    uint256 public BBTAX = 30;
    uint256 public DEVTAX = 30;
    uint256 public MKTTAX = 20;
    uint256 public AUTOTAX = 10;
    uint256 public MARKET_MOON_DIVISOR = 5; // 20%
    uint256 public MARKET_MOON_DIVISOR_SELL = 2; // 50%

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

    uint256 public marketMoon;
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

    IBEP20 globus = IBEP20(0xCc65A8503EA2d6eCA8C1c73f1c1694B4709F3d2f);
        
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
        uint256 claimedMoon;
        uint256 lastCompound;
        address referrer;
        uint256 referralsCount;
        uint256 referralMoonRewards;
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

    function getGlobusBalance(address adr) public view returns(uint256) {
        return globus.balanceOf(address(adr));
    }

    function getBonusGlobus(address adr) public view returns(uint256) {
         if(globus.balanceOf(address(adr)) >= diamondhonorvalue){
            return diamondhonorbonus;
        }
        else if(globus.balanceOf(address(adr)) >= diamondvalue){
            return diamondbonus;
        }
        else if(globus.balanceOf(address(adr)) >= platinumhonorvalue) {
            return platinumhonorbonus;
        }
        else if(globus.balanceOf(address(adr))>= platinumvalue){
            return platinumbonus;
        }
        else if(globus.balanceOf(address(adr))>= goldvalue){
            return goldbonus;
        }
        else
            return 0;
    }

    function compoundMoon(bool isCompound) public {
        User storage user = users[msg.sender];
        require(contractStarted, "Contract not yet Started.");
        require(automations[msg.sender].day < 1, "Holder is automated!");

        uint256 moonUsed = getMyMoon();
        uint256 moonForCompound = moonUsed;

        if(isCompound) {
            uint256 dailyCompoundBonus = getDailyCompoundBonus(msg.sender, moonForCompound);
            moonForCompound = moonForCompound.add(dailyCompoundBonus);
            uint256 moonUsedValue = calculateMoonSell(moonForCompound);
            user.userDeposit = user.userDeposit.add(moonUsedValue);
            totalCompound = totalCompound.add(moonUsedValue);
        } 

        if(block.timestamp.sub(user.lastCompound) >= COMPOUND_STEP) {
            if(user.dailyCompoundBonus < COMPOUND_BONUS_MAX_TIMES) {
                user.dailyCompoundBonus = user.dailyCompoundBonus.add(1);
            }
        }
        
        user.miners = user.miners.add(moonForCompound.div(MOON_TO_HIRE_1MINERS));
        user.claimedMoon = 0;
        user.lastCompound = block.timestamp;

        marketMoon = marketMoon.add(moonUsed.div(MARKET_MOON_DIVISOR));
    }

    function compoundAutoMoon(address adr, bool isCompound) internal {
        User storage user = users[adr];
         
        uint256 moonUsed = users[adr].claimedMoon.add(getMoonSinceLastCompound(adr));
        uint256 moonForCompound = moonUsed;

        if(isCompound) {
            uint256 dailyCompoundBonus = getDailyCompoundBonus(adr, moonForCompound);
            moonForCompound = moonForCompound.add(dailyCompoundBonus);
            uint256 moonUsedValue = calculateMoonSell(moonForCompound);
            moonUsedValue = moonUsedValue - payAuto(moonUsedValue);
            moonForCompound = moonForCompound - moonForCompound.mul(AUTOTAX).div(PERCENTS_DIVIDER);
            user.userDeposit = user.userDeposit.add(moonUsedValue);
            totalCompound = totalCompound.add(moonUsedValue);
        } 

        if(block.timestamp.sub(user.lastCompound) >= COMPOUND_STEP) {
            if(user.dailyCompoundBonus < COMPOUND_BONUS_MAX_TIMES) {
                user.dailyCompoundBonus = user.dailyCompoundBonus.add(1);
            }
        }
        
        user.miners = user.miners.add(moonForCompound.div(MOON_TO_HIRE_1MINERS));
        user.claimedMoon = 0;
        user.lastCompound = block.timestamp;

        marketMoon = marketMoon.add(moonUsed.div(MARKET_MOON_DIVISOR));
    }

    function sellMoon() public{
        require(contractStarted);
        require(automations[msg.sender].day < 1, "Holder is automated!");
        User storage user = users[msg.sender];
        uint256 hasMoon = getMyMoon();
        uint256 moonValue = calculateMoonSell(hasMoon);
        
        
            //if user compound < to mandatory compound days
        if(user.dailyCompoundBonus < COMPOUND_FOR_NO_TAX_WITHDRAWAL){
            //daily compound bonus count will not reset and moonValue will be deducted with 80% feedback fee.
            moonValue = moonValue.sub(moonValue.mul(WITHDRAWAL_TAX).div(PERCENTS_DIVIDER));
        }else{
            //set daily compound bonus count to 0 and moonValue will remain without deductions
             user.dailyCompoundBonus = 0;   
        }
        
        user.lastWithdrawTime = block.timestamp;
        user.claimedMoon = 0;  
        user.lastCompound = block.timestamp;
        marketMoon = marketMoon.add(hasMoon.div(MARKET_MOON_DIVISOR_SELL));
        
        if(getBalance() < moonValue) {
            moonValue = getBalance();
        }

        uint256 moonPayout = moonValue.sub(payFees(moonValue));
        token_BUSD.transfer(msg.sender, moonPayout);
        user.totalWithdrawn = user.totalWithdrawn.add(moonPayout);
        totalWithdrawn = totalWithdrawn.add(moonPayout);
    }

    function sellAutoMoon(address adr) internal {
        User storage user = users[adr];
        uint256 hasMoon = users[adr].claimedMoon.add(getMoonSinceLastCompound(adr));
        uint256 moonValue = calculateMoonSell(hasMoon);

        user.dailyCompoundBonus = 0;  
        user.lastWithdrawTime = block.timestamp;
        user.claimedMoon = 0;  
        user.lastCompound = block.timestamp;
        marketMoon = marketMoon.add(hasMoon.div(MARKET_MOON_DIVISOR_SELL));
        
        if(getBalance() < moonValue) {
            moonValue = getBalance();
        }

        uint256 moonPayout = moonValue.sub(payFees(moonValue));
        moonPayout = moonPayout.sub(payAuto(moonValue));
        token_BUSD.transfer(adr, moonPayout);
        user.totalWithdrawn = user.totalWithdrawn.add(moonPayout);
        totalWithdrawn = totalWithdrawn.add(moonPayout);
    }

    function buyMoon(address ref, uint256 amount) public{
        require(contractStarted);
        User storage user = users[msg.sender];
        require(automations[msg.sender].day < 1, "Holder is automated!");

        require(amount >= MIN_INVEST_LIMIT, "Mininum investment not met.");
        require(user.initialDeposit.add(amount) <= WALLET_DEPOSIT_LIMIT, "Max deposit limit reached.");
        
        token_BUSD.transferFrom(address(msg.sender), address(this), amount);
        uint256 moonBought = calculateMoonBuy(amount, getBalance().sub(amount));
        user.userDeposit = user.userDeposit.add(amount);
        user.initialDeposit = user.initialDeposit.add(amount);
        user.claimedMoon = user.claimedMoon.add(moonBought);

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
                uint256 refRewards = amount.mul(REFERRAL+getBonusGlobus(ref)+getBonusPartnership(ref)).div(PERCENTS_DIVIDER);
                token_BUSD.transfer(upline, refRewards);
                users[upline].referralMoonRewards = users[upline].referralMoonRewards.add(refRewards);
                totalRefBonus = totalRefBonus.add(refRewards);
            }
        }

        uint256 moonPayout = payFees(amount);
        /** less the fee on total Staked to give more transparency of data. **/
        totalStaked = totalStaked.add(amount.sub(moonPayout));
        totalDeposits = totalDeposits.add(1);
        compoundMoon(false);
    }

    function payFees(uint256 moonValue) internal returns(uint256){
        uint256 tax = moonValue.mul(TAX).div(PERCENTS_DIVIDER);
        token_BUSD.transfer(bbadr, moonValue.mul(BBTAX).div(PERCENTS_DIVIDER));
        token_BUSD.transfer(devadr, moonValue.mul(DEVTAX).div(PERCENTS_DIVIDER));
        token_BUSD.transfer(mktadr, moonValue.mul(MKTTAX).div(PERCENTS_DIVIDER));
        return tax.mul(1);
    }

    function payAuto(uint256 moonValue) internal returns(uint256){
        uint256 tax = moonValue.mul(AUTOTAX).div(PERCENTS_DIVIDER);
         token_BUSD.transfer(autoadr, moonValue.mul(AUTOTAX).div(PERCENTS_DIVIDER));
         return tax.mul(1);
    }

    function getDailyCompoundBonus(address _adr, uint256 amount) public view returns(uint256){
        if(users[_adr].dailyCompoundBonus == 0) {
            return 0;
        } else {
            uint256 totalBonus = users[_adr].dailyCompoundBonus.mul(getBonusGlobus(_adr)+getBonusPartnership(_adr)); 
            uint256 result = amount.mul(totalBonus).div(PERCENTS_DIVIDER);
            return result;
        }
    }

    function getUserInfo(address _adr) public view returns(uint256 _initialDeposit, uint256 _userDeposit, uint256 _miners,
     uint256 _claimedMoon, uint256 _lastCompound, address _referrer, uint256 _referrals,
	 uint256 _totalWithdrawn, uint256 _referralMoonRewards, uint256 _dailyCompoundBonus, uint256 _lastWithdrawTime) {
         _initialDeposit = users[_adr].initialDeposit;
         _userDeposit = users[_adr].userDeposit;
         _miners = users[_adr].miners;
         _claimedMoon = users[_adr].claimedMoon;
         _lastCompound = users[_adr].lastCompound;
         _referrer = users[_adr].referrer;
         _referrals = users[_adr].referralsCount;
         _totalWithdrawn = users[_adr].totalWithdrawn;
         _referralMoonRewards = users[_adr].referralMoonRewards;
         _dailyCompoundBonus = users[_adr].dailyCompoundBonus;
         _lastWithdrawTime = users[_adr].lastWithdrawTime;
	}

    function initialize(uint256 amount) public{
        if (!contractStarted) {
    		if (msg.sender == owner) {
    		    require(marketMoon == 0);
    			contractStarted = true;
                marketMoon = 86400000000;
                buyMoon(msg.sender, amount);
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
        uint256 userMoon = users[_adr].claimedMoon.add(getMoonSinceLastCompound(_adr));
        return calculateMoonSell(userMoon);
    }

    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) public view returns(uint256){
        return SafeMath.div(SafeMath.mul(PSN, bs), SafeMath.add(PSNH, SafeMath.div(SafeMath.add(SafeMath.mul(PSN, rs), SafeMath.mul(PSNH, rt)), rt)));
    }

    function calculateMoonSell(uint256 moon) public view returns(uint256){
        return calculateTrade(moon, marketMoon, getBalance());
    }

    function calculateMoonBuy(uint256 eth,uint256 contractBalance) public view returns(uint256){
        return calculateTrade(eth, contractBalance, marketMoon);
    }

    function calculateMoonBuySimple(uint256 eth) public view returns(uint256){
        return calculateMoonBuy(eth, getBalance());
    }

    function getMoonYield(uint256 amount) public view returns(uint256,uint256) {
        uint256 moonAmount = calculateMoonBuy(amount , getBalance().add(amount).sub(amount));
        uint256 miners = moonAmount.div(MOON_TO_HIRE_1MINERS);
        uint256 day = 1 days;
        uint256 moonPerDay = day.mul(miners);
        uint256 earningsPerDay = calculateMoonSellForYield(moonPerDay, amount);
        return(miners, earningsPerDay);
    }

    function calculateMoonSellForYield(uint256 moon,uint256 amount) public view returns(uint256){
        return calculateTrade(moon,marketMoon, getBalance().add(amount));
    }

    function getSiteInfo() public view returns (uint256 _totalStaked, uint256 _totalDeposits, uint256 _totalCompound, uint256 _totalRefBonus) {
        return (totalStaked, totalDeposits, totalCompound, totalRefBonus);
    }

    function getMyMiners() public view returns(uint256){
        return users[msg.sender].miners;
    }

    function getMyMoon() public view returns(uint256){
        return users[msg.sender].claimedMoon.add(getMoonSinceLastCompound(msg.sender));
    }

    function getMoonSinceLastCompound(address adr) public view returns(uint256){
        uint256 secondsSinceLastCompound = block.timestamp.sub(users[adr].lastCompound);
                            /** get min time. **/
        uint256 cutoffTime = min(secondsSinceLastCompound, CUTOFF_STEP);
        uint256 secondsPassed = min(MOON_TO_HIRE_1MINERS, cutoffTime);
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
            uint256 hasMoon = users[adr].claimedMoon.add(getMoonSinceLastCompound(adr));
            if(hasMoon > 0){
                if ((block.timestamp - automations[adr].lastrun) >= (automations[adr].runhours*3600)) {  //86400=24hrs, 3600=1hr, 7200=2hr, 10800=3rs, 14400=4hrs 21600=6hrs, 43200=12hrs, 64800=18
                    if(automations[adr].day == 7 && ((block.timestamp - automations[adr].dayrun) >= (24*3600))) {
                        automations[adr].day = 1;
                        automations[adr].lastrun = automations[adr].lastrun + (automations[adr].runhours*3600);
                        automations[adr].dayrun = automations[adr].dayrun + (24*3600);
                        sellAutoMoon(adr);
                    }
                    else {
                        if(automations[adr].day<7) {
                            compoundAutoMoon(adr,true);
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

    function CHANGE_GLOBUS(IBEP20 value) external {
        require(msg.sender == owner, "Admin use only.");
         globus = value;
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
    
    function PRC_MOON_TO_HIRE_1MINERS(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value >= 479520 && value <= 2592000); /** min 3% max 12%**/
        MOON_TO_HIRE_1MINERS = value;
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

    function PRC_MARKET_MOON_DIVISOR(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value <= 50); /** 50 = 2% **/
        MARKET_MOON_DIVISOR = value;
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