/**
 *Submitted for verification at BscScan.com on 2022-08-02
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract XXXXX {
	using SafeMath for uint256;

	uint256 constant public INVEST_MIN_AMOUNT = 1 ether;
	uint256[] public REFERRAL_PERCENTS = [50, 20, 15, 10, 5];
	uint256 constant public PROJECT_FEE = 100;
	uint256 constant public PERCENT_STEP = 5;
	uint256 constant public PLAN_LENGTH = 30;
	uint256 constant public PERCENTS_DIVIDER = 1000;
	//uint256 constant public TIME_STEP = 1 days;        //mainnet
	uint256 constant public TIME_STEP = 600;             //testnet

	uint256 public totalStaked;
	uint256 public depositCount;
	uint256 public totalRefBonus;
	uint256 public totalUsers;
	uint256 public totalWithdrawn;

    struct Plan {
        uint8 openDay;
        uint256 baseProfit;
        uint256 min;
        uint256 max;
    }

    Plan[] internal plans;

	struct Deposit {
        uint8 plan;
		uint256 amount;
		uint256 profit;
		uint256 start;
		uint256 finish;
		bool isWithdrawn;
	}

	struct User {
		Deposit[] deposits;
		uint256 checkpoint;
		uint256 planCheckpoint;
		address payable referrer;
		uint256[5] levels;
		uint256 bonus;
		uint256 totalBonus;
		uint256 withdrawn;
	}

	mapping (address => User) internal users;

	uint256 public startUNIX;
	address payable public commissionWallet;

	event Newbie(address user);
	event NewDeposit(address indexed user, uint8 plan, uint256 amount, uint256 profit, uint256 start, uint256 finish);
	event Withdrawn(address indexed user, uint256 amount);
	event RefBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
	event FeePayed(address indexed user, uint256 totalAmount);

	constructor() {
		commissionWallet = payable(0x554472D18830641fF7256B60b4f4E14b0E88D1Ba); //       testnet
		//commissionWallet = payable(); //mainnet
		startUNIX = block.timestamp;

        plans.push(Plan(0, 1080, 0.04 ether, 0.08 ether));
        plans.push(Plan(1, 1100, 0.08 ether, 0.12 ether));
        plans.push(Plan(2, 1120, 0.12 ether, 0.20 ether));
        plans.push(Plan(3, 1140, 0.16 ether, 0.39 ether));
        plans.push(Plan(4, 1160, 0.20 ether, 0.58 ether));
        plans.push(Plan(5, 1180, 0.24 ether, 0.77 ether));
		plans.push(Plan(6, 1200, 0.27 ether, 0.97 ether));
		plans.push(Plan(7, 1220, 0.31 ether, 1.16 ether));
		plans.push(Plan(8, 1240, 0.35 ether, 1.35 ether));
		plans.push(Plan(9, 1260, 0.39 ether, 1.54 ether));
		plans.push(Plan(10, 1280, 0.49 ether, 1.74 ether));
		plans.push(Plan(11, 1300, 0.58 ether, 1.93 ether));
		plans.push(Plan(12, 1320, 0.77 ether, 2.12 ether));
		plans.push(Plan(13, 1340, 0.97 ether, 2.31 ether));
		plans.push(Plan(14, 1360, 1.16 ether, 2.50 ether));
		plans.push(Plan(15, 1380, 1.35 ether, 2.70 ether));
		plans.push(Plan(16, 1400, 1.54 ether, 2.89 ether));
		plans.push(Plan(17, 1420, 1.74 ether, 3.08 ether));
		plans.push(Plan(18, 1440, 1.93 ether, 3.27 ether));
		plans.push(Plan(19, 1460, 2.12 ether, 3.47 ether));
		plans.push(Plan(20, 1480, 2.31 ether, 3.85 ether));
		plans.push(Plan(21, 1500, 2.50 ether, 4.24 ether));
		plans.push(Plan(22, 1520, 2.70 ether, 5 ether));
		plans.push(Plan(23, 1540, 3.08 ether, 5.77 ether));
		plans.push(Plan(24, 1560, 3.47 ether, 6.54 ether));
		plans.push(Plan(25, 1580, 3.85 ether, 7.70 ether));
		plans.push(Plan(26, 1600, 4.24 ether, 9.62 ether));
		plans.push(Plan(27, 1620, 5 ether, 11.54 ether));
		plans.push(Plan(28, 1640, 6.16 ether, 15.39 ether));
		plans.push(Plan(29, 1660, 7.70 ether, 19.24 ether));
	}

	function invest(address payable referrer, uint8 plan) public payable {
		require(block.timestamp > startUNIX, "Not launched yet");
		require(plan >= 0 && plan <= 29, "Invalid plan");
		User storage user = users[msg.sender];
		if(user.deposits.length > 0){
        	require(user.deposits[user.deposits.length - 1].finish < block.timestamp, "Previous deposit not yet finished");
		}

		uint256 userActivePlan = getUserLastActivePlan(msg.sender);
		require(plan <= userActivePlan, "Plan not yet activate");
		require(msg.value >= plans[plan].min && msg.value <= plans[plan].max, "Invalid amount");

		for (uint256 i = 0; i < user.deposits.length; i++) {
			if (user.deposits[i].plan == plan) {
				if (!user.deposits[i].isWithdrawn) {
                    revert("Same active deposit");
				}
			}
		}

		uint256 fee = msg.value.mul(PROJECT_FEE).div(PERCENTS_DIVIDER);
		commissionWallet.transfer(fee);
		emit FeePayed(msg.sender, fee);

		if (user.referrer == address(0)) {
			if (users[referrer].deposits.length > 0 && referrer != msg.sender) {
				user.referrer = referrer;
			}
			address upline = user.referrer;
			for (uint256 i = 0; i < 5; i++) {
				if (upline != address(0)) {
					users[upline].levels[i] = users[upline].levels[i].add(1);
					upline = users[upline].referrer;
				} else break;
			}
		}

		if (user.referrer != address(0)) {
			address payable upline = user.referrer;
			for (uint256 i = 0; i < 5; i++) {
				if (upline != address(0)) {
					uint256 amount = msg.value.mul(REFERRAL_PERCENTS[i]).div(PERCENTS_DIVIDER);
					users[upline].totalBonus = users[upline].totalBonus.add(amount);
					totalRefBonus = totalRefBonus.add(amount);
					upline.transfer(amount);	
					emit RefBonus(upline, msg.sender, i, amount);
					upline = users[upline].referrer;
				} else break;
			}
		}

		if (user.deposits.length == 0) {
			user.checkpoint = block.timestamp;
			user.planCheckpoint = block.timestamp;
			totalUsers = totalUsers.add(1);
			emit Newbie(msg.sender);
		}	

		uint256 randPercent = getPercent(plans[plan].baseProfit);
		user.deposits.push(Deposit(plan, msg.value, randPercent, block.timestamp, block.timestamp + TIME_STEP, false));
		totalStaked = totalStaked.add(msg.value);
		depositCount++;
		emit NewDeposit(msg.sender, plan, msg.value, randPercent, block.timestamp, block.timestamp + TIME_STEP);
	}

	function withdraw(uint8 plan) public {
		require(block.timestamp > startUNIX, "Not launched yet");
		User storage user = users[msg.sender];

		require(user.deposits.length > 0, "Not deposit");

		uint256 totalAmount = _getUserDividends(msg.sender, plan);
		require(totalAmount > 0, "User has no dividends");

		uint256 contractBalance = address(this).balance;
		if (contractBalance < totalAmount) {
			totalAmount = contractBalance;
		}

		user.checkpoint = block.timestamp;
		user.withdrawn  = user.withdrawn.add(totalAmount);
		totalWithdrawn = totalWithdrawn.add(totalAmount);

		payable(msg.sender).transfer(totalAmount);
		emit Withdrawn(msg.sender, totalAmount);
	}

	function getContractBalance() public view returns (uint256) {
		return address(this).balance;
	}

	function getPlanInfo(uint8 plan) public view returns(uint8 openDay,uint256 baseProfit, uint256 minAmount, uint256 maxAmount) {
		openDay = plans[plan].openDay;
		baseProfit = plans[plan].baseProfit;
        minAmount = plans[plan].min;
        maxAmount = plans[plan].max;
	}

	function getUserLastActivePlan(address userAddress) public view returns(uint256) {
		uint256 PlanId;
		if(users[userAddress].planCheckpoint > 0) {
			PlanId = block.timestamp.sub(users[userAddress].planCheckpoint).div(TIME_STEP);
			if(PlanId >= PLAN_LENGTH){
				PlanId = PLAN_LENGTH.sub(1);
			}
		}
		return PlanId;
	}

	function getPercent(uint256 _baseProfit) internal view returns(uint256) {
		uint256 finalPercent;
		 uint256 randomnumber = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, block.difficulty))) % 5;
		 finalPercent = _baseProfit.add(randomnumber.mul(10));
		return finalPercent;
	}

	function _getUserDividends(address _userAddress, uint8 _plan) internal returns (uint256) {
		User storage user = users[_userAddress];

		uint256 totalAmount;
		for (uint256 i = 0; i < user.deposits.length; i++) {
			if (user.deposits[i].plan == _plan) {
				if (!user.deposits[i].isWithdrawn && block.timestamp > user.deposits[i].finish) {
                    totalAmount = totalAmount.add(user.deposits[i].amount.mul(user.deposits[i].profit).div(PERCENTS_DIVIDER));
					user.deposits[i].isWithdrawn = true;
				}
			}
		}

		return totalAmount;
	}

	function getUserDividends(address _userAddress, uint8 _plan) public view returns (uint256) {
		User storage user = users[_userAddress];

		uint256 totalAmount;
		for (uint256 i = 0; i < user.deposits.length; i++) {
			if (user.deposits[i].plan == _plan) {
				if (!user.deposits[i].isWithdrawn && block.timestamp > user.deposits[i].finish) {
                    totalAmount = totalAmount.add(user.deposits[i].amount.mul(user.deposits[i].profit).div(PERCENTS_DIVIDER));
				}
			}
		}

		return totalAmount;
	}

	function getUserCheckpoint(address userAddress) public view returns(uint256) {
		return users[userAddress].checkpoint;
	}

	function getUserPlanCheckpoint(address userAddress) public view returns(uint256) {
		return users[userAddress].planCheckpoint;
	}

	function getUserReferrer(address userAddress) public view returns(address) {
		return users[userAddress].referrer;
	}

	function getUserDownlineCount(address userAddress) public view returns(uint256, uint256, uint256, uint256, uint256) {
		return (users[userAddress].levels[0], users[userAddress].levels[1], users[userAddress].levels[2], users[userAddress].levels[3], users[userAddress].levels[4]);
	}

	function getUserReferralTotalBonus(address userAddress) public view returns(uint256) {
		return users[userAddress].totalBonus;
	}

	function getUserReferralWithdrawn(address userAddress) public view returns(uint256) {
		return users[userAddress].totalBonus;
	}

	function getUserAvailable(address userAddress) public view returns(uint256 amount) {
		User storage user = users[userAddress];
		for (uint256 i = 0; i < user.deposits.length; i++) {
			if (!user.deposits[i].isWithdrawn && block.timestamp > user.deposits[i].finish) {
                amount = amount.add(user.deposits[i].amount.mul(user.deposits[i].profit).div(PERCENTS_DIVIDER));
			}
		}
	}

	function getUserAvailablePlan(address userAddress) public view returns(uint256[] memory, uint256[] memory) {
		User storage user = users[userAddress];
		uint256[] memory planIndex = new uint256[](PLAN_LENGTH);
		uint256[] memory depositIndex = new uint256[](PLAN_LENGTH);
		for (uint256 i = 0; i < user.deposits.length; i++) {
			if (!user.deposits[i].isWithdrawn && block.timestamp > user.deposits[i].finish) {
                planIndex[user.deposits[i].plan] = 1;
				depositIndex[user.deposits[i].plan] = i;
			}
		}
		return (planIndex, depositIndex);
	}

	function getUserAmountOfDeposits(address userAddress) public view returns(uint256) {
		return users[userAddress].deposits.length;
	}

	function getUserTotalDeposits(address userAddress) public view returns(uint256 amount) {
		for (uint256 i = 0; i < users[userAddress].deposits.length; i++) {
			amount = amount.add(users[userAddress].deposits[i].amount);
		}
	}

	function getUserDepositInfo(address userAddress, uint256 index) public view returns(uint8 plan, uint256 amount, uint256 start, uint256 finish, uint256 profit, bool isWithdrawn) {
	    User storage user = users[userAddress];
		if(user.deposits.length > 0){
			if(index < user.deposits.length){
				plan = user.deposits[index].plan;
				amount = user.deposits[index].amount;
				profit = user.deposits[index].profit;
				isWithdrawn = user.deposits[index].isWithdrawn;
				start = user.deposits[index].start;
				finish = user.deposits[index].finish;
			}
			
		}

	}

	function getUserLastDepositInfo(address userAddress) public view returns(uint8 plan, uint256 amount, uint256 start, uint256 finish) {
	    User storage user = users[userAddress];

		plan = user.deposits[users[userAddress].deposits.length - 1].plan;
		amount = user.deposits[users[userAddress].deposits.length - 1].amount;
		start = user.deposits[users[userAddress].deposits.length - 1].start;
		finish = user.deposits[users[userAddress].deposits.length - 1].finish;
	}

	function getSiteInfo() public view returns(uint256 _totalStaked, uint256 _totalRefBonus, uint256 _totalUsers, uint256 _totalWithdrawn, uint256 _depositCount) {
		return(totalStaked, totalRefBonus, totalUsers, totalWithdrawn, depositCount);
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
}