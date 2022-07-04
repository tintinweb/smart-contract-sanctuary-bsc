/**
 *Submitted for verification at BscScan.com on 2022-07-03
*/

/**

 BUSD Miner Yield Farm
 
 investment platform based on Binance network (BSC) blockchain smart-contract technology.

 © The Busd Miner(busdminers.org). All rights reserved.
     
    ┌───────────────────────────────────────────────────────────────────────┐
    │                                                                       │
    │       Website : https://busdminers.org                                │
    │                                                                       |
    |                                                                       |
    └───────────────────────────────────────────────────────────────────────┘

~ PLANS:
  plan 1 1.50%  200 days 300% ROI (2% daily, 400%)
  plan 2 1.39%   90 days 125% ROI (2.5% daily, 225%)
  plan 3 1.33%   60 days  80% ROI (3% daily, 180%)
  plan 4 1.00%   40 days  40% ROI (3.5% daily, 140%)
  * rates shown are the actual APR per day.

  Withdrawals are subject to 10% Sustainability tax.
  *sustainability tax stays in the contract.
  
~ PLAN REQUIREMENTS: 
  plan 1 - min. 30 BUSD, max. of 6,000 BUSD
  plan 2 - min. 40 BUSD, max. of 8,000 BUSD
  plan 3 - min. 50 BUSD, max. of 10,000 BUSD
  plan 4 - min. 60 BUSD, max. of 12,000 BUSD
 
~ REFERRAL SYSTEM:
  1 level referral bonus of 5%.

~ ANTI-WHALE CONTROL FEATURES:
  32 hours cut off time 
  24 hours withdraw cooldown.
  12 hours compound cooldown.
  Max active deposit limit of 36000 BUSD.
  Max withdraw amount of 1000 BUSD per day.

~ CONTRACT FEATURES:
  Compound function and with 5% compound bonus(non-stacking).
  Plan rewards.
  Special event pools.
  Project Statistics.

~ Fund Distribution
  85% Platform main balance, participants payouts
  5% Affiliate program bonuses
  2.5% Advertising and promotion expenses
  7.5% Support work, technical functioning, administration fee 
 

**/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

interface IERC20 {
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

contract BUSDYieldMiner {
	using SafeMath for uint256;


	IERC20 public erctoken;
    address token = 0x8301F2213c0eeD49a7E28Ae4c3e91722919B8B47; //TESTNET 2 BUSD
	// address token = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7; /** Testnet 1  BUSD **/
	// address token = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; /** BUSD **/

	/** default percentages **/
	uint256 public PROJECT_FEE = 10; //15; // 1.5% * 5 feee
	uint256 public MKT_BUYBACK_FEE = 10; // 25; // 2.5% marketing fee
	uint256 public REFERRAL_PERCENT = 50;
	uint256 public SUSTAINABILITY_TAX = 50; //5% stay in smart contract after withdraw
	uint256 constant public TIME_STEP = 1 days;
	uint256 constant private PERCENTS_DIVIDER = 1000;

	/* whale control features. **/
	uint256 public CUTOFF_STEP = 32 * 60 * 60;
	uint256 public WITHDRAW_COOLDOWN = 7 * 60 * 60;
	uint256 public COMPOUND_COOLDOWN = 12 * 60 * 60;
    uint256 public REINVEST_BONUS = 50;
	uint256 public MAX_WITHDRAW = 1000 ether;
	uint256 public WALLET_LIMIT = 40000 ether;

    /** deposits after this timestamp gets additional percentages **/
    uint256 public PERCENTAGE_BONUS_STARTTIME = 0;
	uint256 public PERCENTAGE_BONUS_PLAN_1 = 0;
    uint256 public PERCENTAGE_BONUS_PLAN_2 = 0;
    uint256 public PERCENTAGE_BONUS_PLAN_3 = 0;
    uint256 public PERCENTAGE_BONUS_PLAN_4 = 0;

    /* project statistics **/
	uint256 public totalInvested;
	uint256 public totalReInvested;
	uint256 public totalRefBonus;
	uint256 public totalInvestorCount;

    struct Plan {
        uint256 time;
        uint256 percent;
        uint256 mininvest;
        uint256 maxinvest;

        /** plan statistics **/
        uint256 planTotalInvestorCount;
        uint256 planTotalInvestments;
        uint256 planTotalReInvestorCount;
        uint256 planTotalReInvestments;
        
        bool planActivated;
    }
    
	struct Deposit {
        uint8 plan;
		uint256 amount;
		uint256 start;
		bool reinvested;
	}
    
    Plan[] internal plans;

	struct User {
		Deposit[] deposits;
		mapping (uint8 => uint256) checkpoints; /** a checkpoint for each plan **/
		uint256 cutoff;
		uint256 totalInvested;
		address referrer;
		uint256 referralsCount;
		uint256 bonus;
		uint256 totalBonus;
		uint256 withdrawn;
		uint256 reinvested;
		uint256 totalDepositAmount;
	}

	mapping (address => User) internal users;

    address private dev1;
    address private dev2;
    address private dev3;
    address private prtnr1;
    address private prtnr2;
    address private mktAndBuyBack;
	address private contractOwner;
    uint public startTime = 1653746400; // Fri May 27 2022 14:00:00 GMT+0000 https://www.unixtimestamp.com/
	event Newbie(address user);
	event NewDeposit(address indexed user, uint8 plan, uint256 amount);
	event ReinvestedDeposit(address indexed user, uint8 plan, uint256 amount);
	event Withdrawn(address indexed user, uint256 amount);
	event RefBonus(address indexed referrer, address indexed referral, uint256 amount);
	event FeePayed(address indexed user, uint256 totalAmount);

	constructor(address _dev1, address _dev2, address _dev3, address _prtnr1, address _prtnr2, address _mkt) {
		require(!isContract(_dev1) && !isContract(_dev2) && !isContract(_dev3) && !isContract(_prtnr1) && !isContract(_prtnr2) && !isContract(_mkt));
        contractOwner = msg.sender;
        dev1 = _dev1;
        dev2 = _dev2;
        dev3 = _dev3;
        prtnr1 = _prtnr1;
        prtnr2 = _prtnr2;
        mktAndBuyBack = _mkt;
        erctoken = IERC20(token);

        plans.push(Plan(200, 20, 30 ether, 6000 ether, 0, 0, 0, 0, true));
        plans.push(Plan(90,  25, 40 ether, 8000 ether, 0, 0, 0, 0, true));
        plans.push(Plan(60,  30, 50 ether, 10000 ether, 0, 0, 0, 0, true));
        plans.push(Plan(40,  35, 60 ether, 12000 ether, 0, 0, 0, 0, true));
	}

	function invest(address referrer, uint8 plan, uint256 amounterc) public {
        require(block.timestamp > startTime);
        require(plan < plans.length, "Invalid Plan.");
        require(amounterc >= plans[plan].mininvest, "Less than minimum amount required for the selected Plan.");
        require(amounterc <= plans[plan].maxinvest, "More than maximum amount required for the selected Plan.");
		require(plans[plan].planActivated, "Plan selected is disabled");
        require(getUserActiveProjectInvestments(msg.sender).add(amounterc) <= WALLET_LIMIT, "Max wallet deposit limit reached.");

		/** fees **/
		erctoken.transferFrom(address(msg.sender), address(this), amounterc);
        emit FeePayed(msg.sender, payFees(amounterc));

		User storage user = users[msg.sender];

        if (user.referrer == address(0)) {
            if (users[referrer].deposits.length > 0 && referrer != msg.sender) {
                user.referrer = referrer;
            }

            address upline1 = user.referrer;
            if (upline1 != address(0)) {
                users[upline1].referralsCount = users[upline1].referralsCount.add(1);
            }
        }
        if (user.referrer != address(0)) {
            address upline = user.referrer;
            if (upline != address(0)) {
                uint256 amount = amounterc.mul(REFERRAL_PERCENT).div(PERCENTS_DIVIDER);
                users[upline].bonus = users[upline].bonus.add(amount);
                users[upline].totalBonus = users[upline].totalBonus.add(amount);
                totalRefBonus = totalRefBonus.add(amount);
                emit RefBonus(upline, msg.sender, amount);
            }
        }

        /** new user gets current time + CUTOFF_STEP for initial time window **/
		if (user.deposits.length == 0) {
			user.checkpoints[plan] = block.timestamp;
			user.cutoff = block.timestamp.add(CUTOFF_STEP);
			emit Newbie(msg.sender);
		}

        /** deposit from new invest **/
		user.deposits.push(Deposit(plan, amounterc, block.timestamp, false));

		user.totalInvested = user.totalInvested.add(amounterc);
		totalInvested = totalInvested.add(amounterc);

		/** statistics **/
		totalInvestorCount = totalInvestorCount.add(1);
		plans[plan].planTotalInvestorCount = plans[plan].planTotalInvestorCount.add(1);
		plans[plan].planTotalInvestments = plans[plan].planTotalInvestments.add(amounterc);

		emit NewDeposit(msg.sender, plan, amounterc);
	}

	function reinvest(uint8 plan) public {
		require(block.timestamp > startTime);
        require(plan < plans.length, "Invalid plan");
        require(plans[plan].planActivated, "Plan selected is disabled.");

        User storage user = users[msg.sender];

        if(user.checkpoints[plan].add(COMPOUND_COOLDOWN) > block.timestamp){
            revert("Compounding/Reinvesting can only be made after compound cooldown.");
        }

        uint256 totalAmount = getUserDividends(msg.sender, int8(plan));

        uint256 finalAmount = totalAmount.add(totalAmount.mul(REINVEST_BONUS).div(PERCENTS_DIVIDER));
		user.deposits.push(Deposit(plan, finalAmount, block.timestamp, true));

        user.reinvested = user.reinvested.add(finalAmount);
        user.checkpoints[plan] = block.timestamp;
        user.cutoff = block.timestamp.add(CUTOFF_STEP);

        /** statistics **/
		totalReInvested = totalReInvested.add(finalAmount);
		plans[plan].planTotalReInvestments = plans[plan].planTotalReInvestments.add(finalAmount);
		plans[plan].planTotalReInvestorCount = plans[plan].planTotalReInvestorCount.add(1);

		emit ReinvestedDeposit(msg.sender, plan, finalAmount);
	}

	function withdraw() public {
		require(block.timestamp > startTime);
		User storage user = users[msg.sender];

		uint256 totalAmount = getUserDividends(msg.sender);

		uint256 referralBonus = getUserReferralBonus(msg.sender);
		if (referralBonus > 0) {
			user.bonus = 0;
			totalAmount = totalAmount.add(referralBonus);
		}

		require(totalAmount > 0, "User has no dividends");

		uint256 contractBalance = erctoken.balanceOf(address(this));

		if (contractBalance < totalAmount) {
			user.bonus = totalAmount.sub(contractBalance);
			user.totalBonus = user.totalBonus.add(user.bonus);
			totalAmount = contractBalance;
		}

        for(uint8 i = 0; i < plans.length; i++){

            if(user.checkpoints[i].add(WITHDRAW_COOLDOWN) > block.timestamp){
               revert("Withdrawals can only be made after withdraw cooldown.");
            }

		    user.checkpoints[i] = block.timestamp; /** global withdraw will reset checkpoints on all plans **/
        }

        /** Excess dividends are sent back to the user's account available for the next withdrawal. **/
        if(totalAmount > MAX_WITHDRAW) {
            user.bonus = totalAmount.sub(MAX_WITHDRAW);
            totalAmount = MAX_WITHDRAW;
        }

        totalAmount = totalAmount.sub(totalAmount.mul(SUSTAINABILITY_TAX).div(PERCENTS_DIVIDER)); /* 10% of withdrawable amount goes back to the contract. */
        user.cutoff = block.timestamp.add(CUTOFF_STEP); /** global withdraw will also reset CUTOFF **/
		user.withdrawn = user.withdrawn.add(totalAmount);

        erctoken.transfer(msg.sender, totalAmount);
		emit Withdrawn(msg.sender, totalAmount);
	}
	
	function payFees(uint256 amounterc) internal returns(uint256) {
		uint256 fee = amounterc.mul(PROJECT_FEE).div(PERCENTS_DIVIDER);
		uint256 marketing = amounterc.mul(MKT_BUYBACK_FEE).div(PERCENTS_DIVIDER);
		erctoken.transfer(dev1, fee);
        erctoken.transfer(dev2, fee);
        erctoken.transfer(dev3, fee);
        erctoken.transfer(prtnr1, fee);
        erctoken.transfer(prtnr2, fee);
        erctoken.transfer(mktAndBuyBack, marketing);
        uint256 totalFee = fee.mul(5);
        return totalFee.add(marketing);
    }

	function getUserDividends(address userAddress, int8 plan) public view returns (uint256) {
		User storage user = users[userAddress];

		uint256 totalAmount;

		uint256 endPoint = block.timestamp < user.cutoff ? block.timestamp : user.cutoff;

		for (uint256 i = 0; i < user.deposits.length; i++) {
		    if(plan > -1){
		        if(user.deposits[i].plan != uint8(plan)){
		            continue;
		        }
		    }
			uint256 finish = user.deposits[i].start.add(plans[user.deposits[i].plan].time.mul(1 days));
			/** check if plan is not yet finished. **/
			if (user.checkpoints[user.deposits[i].plan] < finish) {

			    uint256 percent = plans[user.deposits[i].plan].percent;
			    if(user.deposits[i].start >= PERCENTAGE_BONUS_STARTTIME){
                    if(user.deposits[i].plan == 0){
                        percent = percent.add(PERCENTAGE_BONUS_PLAN_1);
                    }else if(user.deposits[i].plan == 1){
                        percent = percent.add(PERCENTAGE_BONUS_PLAN_2);
                    }else if(user.deposits[i].plan == 2){
                        percent = percent.add(PERCENTAGE_BONUS_PLAN_3);
                    }else if(user.deposits[i].plan == 3){
                        percent = percent.add(PERCENTAGE_BONUS_PLAN_4);
                    }
			    }

				uint256 share = user.deposits[i].amount.mul(percent).div(PERCENTS_DIVIDER);

				uint256 from = user.deposits[i].start > user.checkpoints[user.deposits[i].plan] ? user.deposits[i].start : user.checkpoints[user.deposits[i].plan];
				/** uint256 to = finish < block.timestamp ? finish : block.timestamp; **/
				uint256 to = finish < endPoint ? finish : endPoint;
				if (from < to) {
					totalAmount = totalAmount.add(share.mul(to.sub(from)).div(TIME_STEP));
				}
			}
		}

		return totalAmount;
	}
    
	function getUserActiveProjectInvestments(address userAddress) public view returns (uint256){
	    uint256 totalAmount;

		/** get total active investments in all plans. **/
        for(uint8 i = 0; i < plans.length; i++){
              totalAmount = totalAmount.add(getUserActiveInvestments(userAddress, i));  
        }
        
	    return totalAmount;
	}

	function getUserActiveInvestments(address userAddress, uint8 plan) public view returns (uint256){
	    User storage user = users[userAddress];
	    uint256 totalAmount;

		for (uint256 i = 0; i < user.deposits.length; i++) {

	        if(user.deposits[i].plan != uint8(plan)){
	            continue;
	        }

			uint256 finish = user.deposits[i].start.add(plans[user.deposits[i].plan].time.mul(1 days));
			if (user.checkpoints[uint8(plan)] < finish) {
			    /** sum of all unfinished deposits from plan **/
				totalAmount = totalAmount.add(user.deposits[i].amount);
			}
		}
	    return totalAmount;
	}


	function getPlanInfo(uint8 plan) public view returns(uint256 time, uint256 percent, uint256 minimumInvestment, uint256 maximumInvestment,
	  uint256 planTotalInvestorCount, uint256 planTotalInvestments , uint256 planTotalReInvestorCount, uint256 planTotalReInvestments, bool planActivated) {
		time = plans[plan].time;
		percent = plans[plan].percent;
		minimumInvestment = plans[plan].mininvest;
		maximumInvestment = plans[plan].maxinvest;
		planTotalInvestorCount = plans[plan].planTotalInvestorCount;
		planTotalInvestments = plans[plan].planTotalInvestments;
		planTotalReInvestorCount = plans[plan].planTotalReInvestorCount;
		planTotalReInvestments = plans[plan].planTotalReInvestments;
		planActivated = plans[plan].planActivated;
	}

	function getContractBalance() public view returns (uint256) {
		return erctoken.balanceOf(address(this));
	}

	function getUserDividends(address userAddress) public view returns (uint256) {
	    return getUserDividends(userAddress, -1);
	}

	function getUserCutoff(address userAddress) public view returns (uint256) {
      return users[userAddress].cutoff;
    }

	function getUserTotalWithdrawn(address userAddress) public view returns (uint256) {
		return users[userAddress].withdrawn;
	}

	function getUserCheckpoint(address userAddress, uint8 plan) public view returns(uint256) {
		return users[userAddress].checkpoints[plan];
	}

	function getUserReferrer(address userAddress) public view returns(address) {
		return users[userAddress].referrer;
	}

    function getUserTotalReferrals(address userAddress) public view returns (uint256){
        return users[userAddress].referralsCount;
    }

	function getUserReferralBonus(address userAddress) public view returns(uint256) {
	    return users[userAddress].bonus;
	}

	function getUserReferralTotalBonus(address userAddress) public view returns(uint256) {
		return users[userAddress].totalBonus;
	}

	function getUserReferralWithdrawn(address userAddress) public view returns(uint256) {
		return users[userAddress].totalBonus.sub(users[userAddress].bonus);
	}

	function getUserAvailable(address userAddress) public view returns(uint256) {
		return getUserReferralBonus(userAddress).add(getUserDividends(userAddress));
	}

	function getUserAmountOfDeposits(address userAddress) public view returns(uint256) {
		return users[userAddress].deposits.length;
	}

	function getUserTotalDeposits(address userAddress) public view returns(uint256 amount) {
		for (uint256 i = 0; i < users[userAddress].deposits.length; i++) {
			amount = amount.add(users[userAddress].deposits[i].amount);
		}
	}

	function getUserDepositInfo(address userAddress, uint256 index) public view returns(uint8 plan, uint256 percent, uint256 amount, uint256 start, uint256 finish, bool reinvested) {
	    User storage user = users[userAddress];
		plan = user.deposits[index].plan;
		percent = plans[plan].percent;
		amount = user.deposits[index].amount;
		start = user.deposits[index].start;
		finish = user.deposits[index].start.add(plans[user.deposits[index].plan].time.mul(1 days));
		reinvested = user.deposits[index].reinvested;
	}

    function getSiteInfo() public view returns (uint256 _totalInvested, uint256 _totalBonus) {
        return (totalInvested, totalRefBonus);
    }

	function getUserInfo(address userAddress) public view returns(uint256 totalDeposit, uint256 totalWithdrawn, uint256 totalReferrals) {
		return(getUserTotalDeposits(userAddress), getUserTotalWithdrawn(userAddress), getUserTotalReferrals(userAddress));
	}

	/** Get Block Timestamp **/
	function getBlockTimeStamp() public view returns (uint256) {
	    return block.timestamp;
	}

	/** Get Plans Length **/
	function getPlansLength() public view returns (uint256) {
	    return plans.length;
	}

	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    /** Add additional plans in the Plan structure. **/
    function ADD_NEW_PLAN(uint256 time, uint256 percent, uint256 mininvest, uint256 maxinvest, bool planActivated) external {
        require(msg.sender == contractOwner, "Admin use only");
        plans.push(Plan(time, percent, mininvest, maxinvest, 0, 0, 0, 0, planActivated));
    }

    function ADD_PERCENT_STARTTIME(uint256 value) external {
        require(msg.sender == contractOwner, "Admin use only");
        PERCENTAGE_BONUS_STARTTIME = value;
    }

    function ADD_PLAN1_BONUS(uint256 value) external {
        require(msg.sender == contractOwner, "Admin use only");
        require(value <= 100);
        PERCENTAGE_BONUS_PLAN_1 = value;
    }

    function ADD_PLAN2_BONUS(uint256 value) external {
        require(msg.sender == contractOwner, "Admin use only");
        require(value <= 100);
        PERCENTAGE_BONUS_PLAN_2 = value;
    }

    function ADD_PLAN3_BONUS(uint256 value) external {
        require(msg.sender == contractOwner, "Admin use only");
        require(value <= 100);
        PERCENTAGE_BONUS_PLAN_3 = value;
    }

    function ADD_PLAN4_BONUS(uint256 value) external {
        require(msg.sender == contractOwner, "Admin use only");
        require(value <= 100);
        PERCENTAGE_BONUS_PLAN_4 = value;
    }

    function CHANGE_OWNERSHIP(address value) external {
        require(msg.sender == contractOwner, "Admin use only");
        contractOwner = value;
    }

    function CHANGE_PROJECT_FEE(uint256 value) external {
        require(msg.sender == contractOwner, "Admin use only");
        require(value <= 20);
        PROJECT_FEE = value;
    }

    function CHANGE_MKT_BUYBACK_FEE(uint256 value) external {
        require(msg.sender == contractOwner, "Admin use only");
        require(value <= 100);
        MKT_BUYBACK_FEE = value;
    }

    function SET_REFERRAL_PERCENT(uint256 value) external {
        require(msg.sender == contractOwner, "Admin use only");
        require(value <= 80);
        REFERRAL_PERCENT = value;
    }

    function SET_REINVEST_BONUS(uint256 value) external {
        require(msg.sender == contractOwner, "Admin use only");
        require(value <= 50);
        REINVEST_BONUS = value;
    }

    function SET_SUSTAINABILITY_TAX(uint256 value) external {
        require(msg.sender == contractOwner, "Admin use only");
        require(value <= 100);
        SUSTAINABILITY_TAX = value;
    }

    function SET_PLAN_PERCENT(uint8 plan, uint256 value) external {
        require(msg.sender == contractOwner, "Admin use only");
        plans[plan].percent = value;
    }

    function SET_PLAN_TIME(uint8 plan, uint256 value) external {
        require(msg.sender == contractOwner, "Admin use only");
        plans[plan].time = value;
    }

    function SET_PLAN_MIN(uint8 plan, uint256 value) external {
        require(msg.sender == contractOwner, "Admin use only");
        plans[plan].mininvest = value * 1e15;
    }

    function SET_PLAN_MAX(uint8 plan, uint256 value) external {
        require(msg.sender == contractOwner, "Admin use only");
        plans[plan].maxinvest = value * 1 ether;
    }

    function SET_PLAN_ACTIVE(uint8 plan, bool value) external {
        require(msg.sender == contractOwner, "Admin use only");
        plans[plan].planActivated = value;
    }

    function SET_CUTOFF_STEP(uint256 value) external {
        require(msg.sender == contractOwner, "Admin use only");
        require(value <= 48);
        CUTOFF_STEP = value * 60 * 60;
    }

    function SET_WITHDRAW_COOLDOWN(uint256 value) external {
        require(msg.sender == contractOwner, "Admin use only");
        require(value <= 24);
        WITHDRAW_COOLDOWN = value * 60 * 60;
    }

    function SET_COMPOUND_COOLDOWN(uint256 value) external {
        require(msg.sender == contractOwner, "Admin use only");
        require(value <= 24);
        COMPOUND_COOLDOWN = value * 60 * 60;
    }

    function SET_MAX_WITHDRAW(uint256 value) external {
        require(msg.sender == contractOwner, "Admin use only");
        MAX_WITHDRAW = value * 1 ether;
    }

    function SET_WALLET_LIMIT(uint256 value) external {
        require(msg.sender == contractOwner, "Admin use only");
        WALLET_LIMIT = value * 1 ether;
    } 
        
    function SET_START_TIME(uint256 value) external {
        require(msg.sender == contractOwner, "Admin use only");
        startTime = value;
    } 
    
    function CHANGE_DEV1(address value) external {
        require(msg.sender == contractOwner, "Admin use only.");
        dev1 = value;
    }

    function CHANGE_DEV2(address value) external {
        require(msg.sender == contractOwner, "Admin use only.");
        dev2 = value;
    }

    function CHANGE_DEV3(address value) external {
        require(msg.sender == contractOwner, "Admin use only.");
        dev3 = value;
    }

    function CHANGE_PRTNR1(address value) external {
        require(msg.sender == contractOwner, "Admin use only.");
        prtnr1 = value;
    }

    function CHANGE_PRTNR2(address value) external {
        require(msg.sender == contractOwner, "Admin use only.");
        prtnr2 = value;
    }

    function CHANGE_MKT_WALLET(address value) external {
        require(msg.sender == contractOwner, "Admin use only.");
        mktAndBuyBack = value;
    }

//  modifier onlyOwner() {
//         require(contractOwner  == msg.sender, "Ownable: caller is not the owner");

//         _;
//     }
//      function owner() public view returns (address) {
//         return contractOwner;
//     }

//        function withdrawBUSD(uint256 amount) public payable owner 
//     {
//         token.transfer(msg.sender,  amount);
//     }




function withdrawToken(uint256 amount) external
    {
        require(msg.sender == contractOwner, "Admin use only.");
        erctoken.transfer(msg.sender,  amount);
    }


}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}