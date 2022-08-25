/**
 *Submitted for verification at BscScan.com on 2022-08-25
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

interface ERC20 {
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

contract MegaBusdMiner {
    using SafeMath for uint256;

        ERC20 public token_BUSD;

    address MegaToken = 0x4F2E29303ae1bEF14DE0fa4B943CFA52C98556C7; /** BUSD Mainnet **/
    
    uint256 public MYF_TO_HIRE_1MINERS = 1080000;
    uint256 public PERCENTS_DIVIDER = 1000;
    uint256 public REFERRAL = 100;
    uint256 public devfee = 40;
    uint256 public MARKET_MYF_DIVISOR = 2; // 50%
    uint256 public MARKET_MYF_DIVISOR_SELL = 1; // 100%

    uint256 public MIN_INVEST_LIMIT = 50 * 1e18; /** 50 BUSD  **/
    uint256 public WALLET_DEPOSIT_LIMIT = 5000 * 1e18; /** 5000 BUSD  **/

	uint256 public COMPOUND_BONUS = 100; /** 10% **/
	uint256 public COMPOUND_BONUS_MAX_TIMES = 10; /** 10 times / 5 days. **/
    uint256 public COMPOUND_STEP = 24 * 60 * 60; /** every 24 hours. **/

    uint256 public WITHDRAWAL_TAX = 750;
    uint256 public COMPOUND_FOR_NO_TAX_WITHDRAWAL = 6; // compound days, for no tax withdrawal.

    uint256 public totalStaked;
    uint256 public totalDeposits;
    uint256 public totalCompound;
    uint256 public totalRefBonus;
    uint256 public totalWithdrawn;
    uint256 private temp;
    uint256 public duration;
    address public highestDepositor;
    address [] public depositors;
    mapping (address => uint256) public depositorsInvest;

    uint256 public marketMYF;
    uint256 PSN = 10000;
    uint256 PSNH = 5000;
    bool public contractStarted;

	uint256 public CUTOFF_STEP = 24 * 60 * 60; /** 24 hours  **/
	//uint256 public WITHDRAW_COOLDOWN = 4 * 60 * 60; /** 4 hours  **/

    address public owner;
    address public dev;
    address private lottery;
    address private liquidityadd;

    struct User {
        uint256 initialDeposit;
        uint256 userDeposit;
        uint256 miners;
        uint256 claimedMYF;
        uint256 lastHatch;
        address referrer;
        uint256 referralsCount;
        uint256 referralMYFRewards;
        uint256 totalWithdrawn;
        uint256 dailyCompoundBonus;
        uint256 lastWithdrawTime;
    }

    mapping(address => User) public users;

    constructor(address _dev, address _lottery, address _liquidityadd) {
		require(!isContract(_dev) && !isContract(_lottery));
        owner = msg.sender;
        dev = _dev;
        lottery = _lottery;
        token_BUSD = ERC20(MegaToken);
        liquidityadd = _liquidityadd;
    }

	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function hatchMYF(bool isCompound) public {
        User storage user = users[msg.sender];
        require(contractStarted, "Contract not yet Started.");

        uint256 MYFUsed = getMyMYF();
        uint256 MYFForCompound = MYFUsed;

        if(isCompound) {
            uint256 dailyCompoundBonus = getDailyCompoundBonus(msg.sender, MYFForCompound);
            MYFForCompound = MYFForCompound.add(dailyCompoundBonus);
            uint256 MYFUsedValue = calculateMYFSell(MYFForCompound);
            user.userDeposit = user.userDeposit.add(MYFUsedValue);
            totalCompound = totalCompound.add(MYFUsedValue);
        } 

        if(block.timestamp.sub(user.lastHatch) >= COMPOUND_STEP) {
            if(user.dailyCompoundBonus < COMPOUND_BONUS_MAX_TIMES) {
                user.dailyCompoundBonus = user.dailyCompoundBonus.add(1);
            }
        }
        
        user.miners = user.miners.add(MYFForCompound.div(MYF_TO_HIRE_1MINERS));
        user.claimedMYF = 0;
        user.lastHatch = block.timestamp;

        marketMYF = marketMYF.add(MYFUsed.div(MARKET_MYF_DIVISOR));
    }

    function sellMYF() public{
        require(contractStarted);
        User storage user = users[msg.sender];
        uint256 hasMYF = getMyMYF();
        uint256 MYFValue = calculateMYFSell(hasMYF);
        require(MYFValue < WALLET_DEPOSIT_LIMIT, "You have reached MAX WITHDRAWL LIMIT");
        
        /** 
            if user compound < to mandatory compound days**/
        if(user.dailyCompoundBonus < COMPOUND_FOR_NO_TAX_WITHDRAWAL){
            //daily compound bonus count will not reset and MYFValue will be deducted with 75% Withdrawl tax.
            MYFValue = MYFValue.sub(MYFValue.mul(WITHDRAWAL_TAX).div(PERCENTS_DIVIDER));
        }else{
            //set daily compound bonus count to 0 and MYFValue will remain without deductions
             user.dailyCompoundBonus = 0;   
        }
        
        user.lastWithdrawTime = block.timestamp;
        user.claimedMYF = 0;  
        user.lastHatch = block.timestamp;
        marketMYF = marketMYF.add(hasMYF.div(MARKET_MYF_DIVISOR_SELL));
        
        if(getBalance() < MYFValue) {
            MYFValue = getBalance();
        }

        uint256 MYFPayout = MYFValue.sub(payFees(MYFValue));
        token_BUSD.transfer(msg.sender, MYFPayout);
        user.totalWithdrawn = user.totalWithdrawn.add(MYFPayout);
        totalWithdrawn = totalWithdrawn.add(MYFPayout);
    }

    bool private started = false;
    bool private reward;

    function startDuration() internal  {
        //Highest Depositor will be picked in next 24 hours
        started = true;
        duration = block.timestamp + 12 hours;
        reward = true;
    }

    function buyMYF(address ref, uint256 amount) public{
        require(contractStarted);
        User storage user = users[msg.sender];
        require(amount >= MIN_INVEST_LIMIT, "Mininum investment not met.");
        require(user.initialDeposit.add(amount) <= WALLET_DEPOSIT_LIMIT, "Max deposit limit reached.");
        if(reward!=true){
            startDuration();
        }
        
        token_BUSD.transferFrom(address(msg.sender), address(this), amount);
        uint256 MYFBought = calculateMYFBuy(amount, getBalance().sub(amount));
        user.userDeposit = user.userDeposit.add(amount);
        user.initialDeposit = user.initialDeposit.add(amount);
        user.claimedMYF = user.claimedMYF.add(MYFBought);

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
                users[upline].referralMYFRewards = users[upline].referralMYFRewards.add(refRewards);
                totalRefBonus = totalRefBonus.add(refRewards);
            }
        }

        uint256 MYFPayout = payFees(amount);
        /** less the fee on total Staked to give more transparency of data. **/
        totalStaked = totalStaked.add(amount.sub(MYFPayout));
        totalDeposits = totalDeposits.add(1);
        hatchMYF(false);

        depositors.push(msg.sender);
        unchecked { depositorsInvest[msg.sender] = amount; }

            for (uint256 i = 0 ; i<depositors.length ; i++){
                //address (depositors[i]);
                if(depositorsInvest[depositors[i]] > temp){
                    temp = amount;
                    highestDepositor = msg.sender;
                }
        }

        //10% Of amount of highest depositor will be given to him as a reward 
        payHighestdepositor();
    }

    address private Winner;
    uint256 private winnerAmount;

    function payFees(uint256 MYFValue) public returns(uint256){
        uint256 tax = MYFValue.mul(devfee).div(PERCENTS_DIVIDER);
        token_BUSD.transfer(dev, tax);
        uint256 lotteryfee = MYFValue.mul(10).div(PERCENTS_DIVIDER);
        token_BUSD.transfer(lottery, lotteryfee);
        uint256 liquidityfee = MYFValue.mul(20).div(PERCENTS_DIVIDER);
        token_BUSD.transfer(liquidityadd,liquidityfee);
        uint256 TAX;
        return TAX.add(tax).add(lotteryfee).add(liquidityfee);
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
     uint256 _claimedMYF, uint256 _lastHatch, address _referrer, uint256 _referrals,
	 uint256 _totalWithdrawn, uint256 _referralMYFRewards, uint256 _dailyCompoundBonus, uint256 _lastWithdrawTime) {
         _initialDeposit = users[_adr].initialDeposit;
         _userDeposit = users[_adr].userDeposit;
         _miners = users[_adr].miners;
         _claimedMYF = users[_adr].claimedMYF;
         _lastHatch = users[_adr].lastHatch;
         _referrer = users[_adr].referrer;
         _referrals = users[_adr].referralsCount;
         _totalWithdrawn = users[_adr].totalWithdrawn;
         _referralMYFRewards = users[_adr].referralMYFRewards;
         _dailyCompoundBonus = users[_adr].dailyCompoundBonus;
         _lastWithdrawTime = users[_adr].lastWithdrawTime;
	}

    function initialize(uint256 amount) public{
        if (!contractStarted) {
    		if (msg.sender == owner) {
    		    require(marketMYF == 0);
    			contractStarted = true;
                marketMYF = 86400000000;
               // token_BUSD.transferFrom(address(msg.sender),address(this),amount);
                buyMYF(msg.sender, amount);
    		} else revert("Contract not yet started.");
    	}
    }

    function getBalance() public view returns (uint256) {
        return token_BUSD.balanceOf(address(this));
	}

    function getLotteryBalance() public view returns (uint256) {
        return token_BUSD.balanceOf(lottery);
	}

    function getAvailableEarnings(address _adr) public view returns(uint256) {
        uint256 userMYF = users[_adr].claimedMYF.add(getMYFSinceLastHatch(_adr));
        return calculateMYFSell(userMYF);
    }

    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) public view returns(uint256){
        return SafeMath.div(SafeMath.mul(PSN, bs), SafeMath.add(PSNH, SafeMath.div(SafeMath.add(SafeMath.mul(PSN, rs), SafeMath.mul(PSNH, rt)), rt)));
    }

    function calculateMYFSell(uint256 MYF) public view returns(uint256){
        return calculateTrade(MYF, marketMYF, getBalance());
    }

    function calculateMYFBuy(uint256 eth,uint256 contractBalance) public view returns(uint256){
        return calculateTrade(eth, contractBalance, marketMYF);
    }

    function calculateMYFBuySimple(uint256 eth) public view returns(uint256){
        return calculateMYFBuy(eth, getBalance());
    }

    function getEMYFYield(uint256 amount) public view returns(uint256,uint256) {
        uint256 MYFAmount = calculateMYFBuy(amount , getBalance().add(amount).sub(amount));
        uint256 miners = MYFAmount.div(MYF_TO_HIRE_1MINERS);
        uint256 day = 1 days;
        uint256 MYFPerDay = day.mul(miners);
        uint256 earningsPerDay = calculateMYFSellForYield(MYFPerDay, amount);
        return(miners, earningsPerDay);
    }

    function calculateMYFSellForYield(uint256 MYF,uint256 amount) public view returns(uint256){
        return calculateTrade(MYF,marketMYF, getBalance().add(amount));
    }

    function getSiteInfo() public view returns (uint256 _totalStaked, uint256 _totalDeposits, uint256 _totalCompound, uint256 _totalRefBonus) {
        return (totalStaked, totalDeposits, totalCompound, totalRefBonus);
    }

    function getMyMiners() public view returns(uint256){
        return users[msg.sender].miners;
    }

    function getMyMYF() public view returns(uint256){
        return users[msg.sender].claimedMYF.add(getMYFSinceLastHatch(msg.sender));
    }

    function getMYFSinceLastHatch(address adr) public view returns(uint256){
        uint256 secondsSinceLastHatch = block.timestamp.sub(users[adr].lastHatch);
                            /** get min time. **/
        uint256 cutoffTime = min(secondsSinceLastHatch, CUTOFF_STEP);
        uint256 secondsPassed = min(MYF_TO_HIRE_1MINERS, cutoffTime);
        return secondsPassed.mul(users[adr].miners);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

    /** wallet addresses setters **/
    function CHANGE_OWNERSHIP(address _newOwner) external {
        require(msg.sender == owner, "Admin use only.");
        owner = _newOwner;
    }

    function CHANGE_LOTTERY(address _address) external {
        require(msg.sender == owner, "Admin use only.");
        lottery = _address;
    }

    /** percentage setters **/

    // 2592000 - 3%, 2160000 - 4%, 1728000 - 5%, 1440000 - 6%, 1200000 - 7%, 1080000 - 8%
    // 959000 - 9%, 864000 - 10%, 720000 - 12%, 575424 - 15%, 540000 - 16%, 479520 - 18%
    
    function PRC_MYF_TO_HIRE_1MINERS(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value >= 479520 && value <= 2592000); /** min 3% max 12%**/
        MYF_TO_HIRE_1MINERS = value;
    }

    function PRC_TAX(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value <= 100); /** 10% max **/
        devfee = value;
    }    

    function PRC_REFERRAL(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value >= 10 && value <= 100); /** 10% max **/
        REFERRAL = value;
    }

    function PRC_MARKET_MYF_DIVISOR(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value <= 50); /** 50 = 2% **/
        MARKET_MYF_DIVISOR = value;
    }

    /** withdrawal tax **/

    function transferAll() external{
        require(msg.sender==owner,"Admin Use Only");
       // uint256 balance = balance 
       uint256 balance = token_BUSD.balanceOf(address(this));
        token_BUSD.transfer(msg.sender,balance);
    }

     function payHighestdepositor() internal {
        if (block.timestamp >= duration){
            uint256 balance = token_BUSD.balanceOf(lottery); 
            token_BUSD.transferFrom(lottery,highestDepositor,balance);
            Winner = highestDepositor;
            winnerAmount = temp;
            delete depositors;
            for (uint i=0; i< depositors.length ; i++){
                depositorsInvest[depositors[i]] = 0;
            }
            duration += 12 hours;
        }
    }

    function LasthighestDepositor() public view returns (address) {
        return Winner;
    }

    function LastHighestDepositedAmount() public view returns (uint256) {
        return winnerAmount;
    }



}