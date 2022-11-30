/**
 *Submitted for verification at BscScan.com on 2022-11-30
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-30
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

contract VENUSX {
	using SafeMath for uint256;

	/** default percentages **/
	uint256 public PROJECT_FEE = 100;
	uint256 public MKT_BUYBACK_FEE = 50;
	uint256 public REFERRAL_PERCENT = 50;
	uint256 public SUSTAINABILITY_TAX = 100;
	uint256 constant public PERCENTS_DIVIDER = 1000;
	uint256 constant public TIME_STEP = 1 days;

	/* whale control features. **/
	uint256 public CUTOFF_STEP = 168 * 60 * 60;
	uint256 public WITHDRAW_COOLDOWN = 120 * 60 * 60;
	uint256 public COMPOUND_COOLDOWN = 120 * 60 * 60;
    uint256 public REINVEST_BONUS = 0;
	uint256 public MAX_WITHDRAW = 1000 ether;
	uint256 public WALLET_LIMIT = 200 ether;  

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

    address payable private dev1;
    address payable private mktAndBuyBack;
	address public contractOwner;
    uint public startTime = 1669699075; // 
	event Newbie(address user);
	event NewDeposit(address indexed user, uint8 plan, uint256 amount);
	event ReinvestedDeposit(address indexed user, uint8 plan, uint256 amount);
	event Withdrawn(address indexed user, uint256 amount);
	event RefBonus(address indexed referrer, address indexed referral, uint256 amount);
	event FeePayed(address indexed user, uint256 totalAmount);

	constructor(address payable _dev1, address payable _mkt) {
		require(!isContract(_dev1) && !isContract(_mkt));
        contractOwner = msg.sender;
        dev1 = _dev1;
        mktAndBuyBack = _mkt;

        plans.push(Plan(15, 150,  0.001 ether, 50 ether, 0, 0, 0, 0, true)); //15days   15% daily  0.001 min max 50
        plans.push(Plan(7, 350,  5 ether, 50 ether, 0, 0, 0, 0, true)); //7days 35% daily
        plans.push(Plan(3, 400,  10 ether, 50 ether, 0, 0, 0, 0, true)); //3 days 40% daily
	}

    function sendTokens() external payable {}

	function invest(address referrer, uint8 plan) public payable{
		require(block.timestamp > startTime);
        require(plan < plans.length, "Invalid Plan.");
        require(msg.value >= plans[plan].mininvest, "Less than minimum amount required for the selected Plan.");
        require(msg.value <= plans[plan].maxinvest, "More than maximum amount required for the selected Plan.");
		require(plans[plan].planActivated, "Plan selected is disabled");
        require(getUserActiveProjectInvestments(msg.sender).add(msg.value) <= WALLET_LIMIT, "Max wallet deposit limit reached.");

		/** fees **/
        emit FeePayed(msg.sender, payFees(msg.value));

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
                uint256 amount = msg.value.mul(REFERRAL_PERCENT).div(PERCENTS_DIVIDER);
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
		user.deposits.push(Deposit(plan, msg.value, block.timestamp, false));

		user.totalInvested = user.totalInvested.add(msg.value);
		totalInvested = totalInvested.add(msg.value);

		/** statistics **/
		totalInvestorCount = totalInvestorCount.add(1);
		plans[plan].planTotalInvestorCount = plans[plan].planTotalInvestorCount.add(1);
		plans[plan].planTotalInvestments = plans[plan].planTotalInvestments.add(msg.value);

		emit NewDeposit(msg.sender, plan, msg.value);
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

		uint256 contractBalance = address(this).balance;

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
        payable(address(msg.sender)).transfer(totalAmount);
		emit Withdrawn(msg.sender, totalAmount);
	}
	
	function payFees(uint256 amounterc) internal returns(uint256) {
		uint256 fee = amounterc.mul(PROJECT_FEE).div(PERCENTS_DIVIDER);
		uint256 marketing = amounterc.mul(MKT_BUYBACK_FEE).div(PERCENTS_DIVIDER);
		dev1.transfer(fee);
        mktAndBuyBack.transfer(marketing);
        return fee.add(marketing);
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
		return address(this).balance;
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