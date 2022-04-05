/**
 *Submitted for verification at BscScan.com on 2022-04-05
*/

pragma solidity >=0.4.22 <0.9.0;

contract MonkeyMoney {
	using SafeMath for uint256;

    string public name = "MonkeyMoney";

	uint256 constant public INVEST_MIN_AMOUNT = 100000000000000000 wei;
	uint256[] public REFERRAL_PERCENTS = [50, 25, 5];
	uint256 constant public PROJECT_FEE = 100;
	uint256 constant public PERCENTS_DIVIDER = 1000;
	uint256 constant public TIME_STEP = 1 days;
	uint256 constant public MAXIMUM_NUMBER_DEPOSITS = 100;

	uint256 public totalStaked;
	uint256 public totalUsers;

    struct Plan {
        uint256 time;
        uint256 percent;
		uint256 tax;
    }

    Plan[] internal plans;

	struct Deposit {
        uint8 plan;
		uint256 percent;
		uint256 amount;
		uint256 profit;
		uint256 start;
		uint256 finish;
		uint256 tax;
	}

	struct User {
		Deposit[] deposits;
		uint256 checkpoint;
		address referrer;
		uint256[3] levels;
		uint256 bonus;
		uint256 totalBonus;
	}

	mapping (address => User) internal users;

	address payable public devWallet;
	address payable public operationalAccount;

	event Newbie(address user);
	event NewDeposit(address indexed user, uint8 plan, uint256 percent, uint256 amount, uint256 profit, uint256 start, uint256 finish);
	event Withdrawn(address indexed user, uint256 amount);
	event RefBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
	event FeePayed(address indexed user, uint256 totalAmount);

	constructor(address _devWallet, address _operationalAccount) {
		devWallet          = payable(_devWallet);
		operationalAccount = payable(_operationalAccount);

        plans.push(Plan(14, 70, 100));
        plans.push(Plan(21, 77, 150));
        plans.push(Plan(28, 87, 200));
	}

	function invest(address referrer, uint8 plan) public payable {
		require(msg.value >= INVEST_MIN_AMOUNT);
        require(plan < 3, "Invalid plan");

		User storage user = users[msg.sender];
		require(user.deposits.length < MAXIMUM_NUMBER_DEPOSITS, "Maximum number of deposits reached.");

		uint256 fees = msg.value.mul(PROJECT_FEE).div(PERCENTS_DIVIDER);
		(uint256 devFee, uint256 operatingFee) = getFeeAllocation(fees);
		devWallet.transfer(devFee);
		operationalAccount.transfer(operatingFee);
		emit FeePayed(msg.sender, fees);

		if (user.referrer == address(0)) {
			if (users[referrer].deposits.length > 0 && referrer != msg.sender) {
				user.referrer = referrer;
			}

			address upline = user.referrer;
			for (uint256 i = 0; i < 3; i++) {
				if (upline != address(0)) {
					users[upline].levels[i] = users[upline].levels[i].add(1);
					upline = users[upline].referrer;
				} else break;
			}
		}

		if (user.referrer != address(0)) {
			address upline = user.referrer;
			for (uint256 i = 0; i < 3; i++) {
				if (upline != address(0)) {
					uint256 amount = msg.value.mul(REFERRAL_PERCENTS[i]).div(PERCENTS_DIVIDER);
					users[upline].bonus = users[upline].bonus.add(amount);
					users[upline].totalBonus = users[upline].totalBonus.add(amount);
					emit RefBonus(upline, msg.sender, i, amount);
					upline = users[upline].referrer;
				} else break;
			}
		}

		if (user.deposits.length == 0) {
			user.checkpoint = block.timestamp;
            totalUsers = totalUsers.add(1);
			emit Newbie(msg.sender);
		}

		(uint256 percent, uint256 profit, uint256 finish, uint256 tax) = getResult(plan, msg.value);
		user.deposits.push(Deposit(plan, percent, msg.value, profit, block.timestamp, finish, tax));

		totalStaked = totalStaked.add(msg.value);
		emit NewDeposit(msg.sender, plan, percent, msg.value, profit, block.timestamp, finish);
	}

	function getFeeAllocation(uint256 fees) public view returns (uint256 devFee, uint256 operatingFee) {
		if(totalStaked < 400000 ether) {
			devFee       = fees.mul(300).div(PERCENTS_DIVIDER);
			operatingFee = fees.mul(700).div(PERCENTS_DIVIDER);
		}
		else {
			devFee       = fees.mul(500).div(PERCENTS_DIVIDER);
			operatingFee = fees.mul(500).div(PERCENTS_DIVIDER);
		}
	}

	function withdraw() public {
		User storage user = users[msg.sender];

		uint256 totalAmount = getUserDividends(msg.sender);
		uint256 tax;

		for (uint256 i = 0; i < capped(user.deposits.length); i++) {
			if (user.checkpoint < user.deposits[i].finish) {
				if (block.timestamp > user.deposits[i].finish) {
					tax = tax.add(user.deposits[i].profit.mul(user.deposits[i].tax).div(PERCENTS_DIVIDER));
				}
			}
		}

		totalAmount = totalAmount.sub(tax);

		uint256 referralBonus = getUserReferralBonus(msg.sender);
		if (referralBonus > 0) {
			user.bonus = 0;
			totalAmount = totalAmount.add(referralBonus);
		}

		require(totalAmount > 0, "User has no dividends");

		uint256 contractBalance = address(this).balance;
		if (contractBalance < totalAmount) {
			totalAmount = contractBalance;
		}

		user.checkpoint = block.timestamp;
		
        address payable sender = payable(msg.sender);
		sender.transfer(totalAmount);

		emit Withdrawn(msg.sender, totalAmount);
	}

    function snoozeAll(uint256 _days) public {
		require(_days > 0, "Invalid argument _days (min 1).");
        require(_days < 8, "Invalid argument _days (max 7).");

		User storage user = users[msg.sender];

		uint256 count;

		for (uint256 i = 0; i < capped(user.deposits.length); i++) {
			if (user.checkpoint < user.deposits[i].finish) {
				if (block.timestamp > user.deposits[i].finish) {
					count = count.add(1);
					snooze(msg.sender, i, _days);
				}
			}
		}

		require(count > 0, "No plans are currently eligible");
    }

	function snoozeAt(uint256 index, uint256 _days) public {
		require(_days > 0, "Invalid argument _days (min 1).");
        require(_days < 8, "invalid argument _days (max 7).");

		snooze(msg.sender, index, _days);
	}

    function snooze(address sender, uint256 index, uint256 _days) private {
		User storage user = users[sender];
		require(index < user.deposits.length, "Deposit at index does not exist");
		require(user.checkpoint < user.deposits[index].finish, "Deposit term already paid out.");
        require(block.timestamp > user.deposits[index].finish, "Deposit term is not completed.");

		uint8   plan    = user.deposits[index].plan;
        uint256 percent = getPercent(plan);
        uint256 basis   = user.deposits[index].profit;
        uint256 profit;

		for (uint256 i = 0; i < _days; i++) {
			profit = profit.add((basis.add(profit)).mul(percent).div(PERCENTS_DIVIDER));
		}

        user.deposits[index].profit = user.deposits[index].profit.add(profit);
        user.deposits[index].finish = user.deposits[index].finish.add(_days.mul(TIME_STEP));
    }

	function getUserDividends(address userAddress) public view returns (uint256) {
		User storage user = users[userAddress];

		uint256 totalAmount;

		for (uint256 i = 0; i < capped(user.deposits.length); i++) {
			if (user.checkpoint < user.deposits[i].finish) {
				if (block.timestamp > user.deposits[i].finish) {
					totalAmount = totalAmount.add(user.deposits[i].profit);
				}
			}
		}

		return totalAmount;
	}

	function capped(uint256 length) public pure returns (uint256 cap) {
		if(length < MAXIMUM_NUMBER_DEPOSITS) {
			cap = length;
		} else {
			cap = MAXIMUM_NUMBER_DEPOSITS;
		}
	}

	function getResult(uint8 plan, uint256 deposit) public view returns (uint256 percent, uint256 profit, uint256 finish, uint256 tax) {
		percent = getPercent(plan);
		tax     = getTax(plan);

		for (uint256 i = 0; i < plans[plan].time; i++) {
			profit = profit.add((deposit.add(profit)).mul(percent).div(PERCENTS_DIVIDER));
		}

		finish = block.timestamp.add(plans[plan].time.mul(TIME_STEP));
	}

	function getContractBalance() public view returns (uint256) {
		return address(this).balance;
	}

	function getPlanInfo(uint8 plan) public view returns(uint256 time, uint256 percent) {
		time = plans[plan].time;
		percent = plans[plan].percent;
	}

	function getPercent(uint8 plan) public view returns (uint256) {
		return plans[plan].percent;
    }

	function getTax(uint8 plan) public view returns (uint256) {
		return plans[plan].tax;
	}

	function getUserCheckpoint(address userAddress) public view returns(uint256) {
		return users[userAddress].checkpoint;
	}

	function getUserReferrer(address userAddress) public view returns(address) {
		return users[userAddress].referrer;
	}

	function getUserDownlineCount(address userAddress) public view returns(uint256, uint256, uint256) {
		return (users[userAddress].levels[0], users[userAddress].levels[1], users[userAddress].levels[2]);
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

	function getUserDepositInfo(address userAddress, uint256 index) public view returns(uint8 plan, uint256 percent, uint256 amount, uint256 profit, uint256 start, uint256 finish, uint256 tax) {
	    User storage user = users[userAddress];

		plan = user.deposits[index].plan;
		percent = user.deposits[index].percent;
		amount = user.deposits[index].amount;
		profit = user.deposits[index].profit;
		start = user.deposits[index].start;
		finish = user.deposits[index].finish;
		tax = user.deposits[index].tax;
	}

	function getUserDeposits(address userAddress) public view returns(Deposit[] memory deposits) {
		return users[userAddress].deposits;
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