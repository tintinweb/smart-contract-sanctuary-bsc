/**
 *Submitted for verification at BscScan.com on 2022-03-12
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-07
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;

contract BNBRain {
	uint256 constant public INVEST_MIN_AMOUNT = 0.05 ether;
	uint256[] public REFERRAL_PERCENTS = [50];
	uint256 constant public PROJECT_FEE = 100;
	uint256 constant public MARKETING_FEE = 50;
	uint256 constant public INSURANCE_FEE = 100;
	uint256 constant public HOLD_BONUS = 700;
	uint256 constant public PERCENTS_DIVIDER = 1000;
	uint256 constant public TIME_STEP = 1 days;

	uint256 public totalStaked;
	uint256 public totalReinvested;
	uint256 public totalRefBonus;

    struct Plan {
        uint256 time;
        uint256 percent;
    }

    Plan[] internal plans;

	struct Deposit {
        uint8 plan;
		uint256 percent;
		uint256 amount;
		uint256 profit;
		uint256 start;
		uint256 finish;
	}

	struct User {
		Deposit[] deposits;
		uint256 checkpoint;
		address referrer;
		uint256[1] levels;
		uint256 bonus;
		uint256 totalBonus;
	}

	mapping (address => User) internal users;

	uint256 public startUNIX;
	address payable public projectWallet;
	address payable public marketingWallet;
	address payable public insuranceWallet;

	event Newbie(address user);
	event NewDeposit(address indexed user, uint8 plan, uint256 percent, uint256 amount, uint256 profit, uint256 start, uint256 finish);
	event Reinvest(address indexed user, uint256 amount);
	event Withdrawn(address indexed user, uint256 amount);
	event RefBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
	event FeePayed(address indexed user, uint256 totalAmount);

	constructor() {
		projectWallet   = payable(0x9f304cD3D1db06d6898Cc1999D0Ded08cEEFa29c);
		marketingWallet = payable(0x5EA05346Cc109B6A238d5a5b05d2dBDE2F259779);
		insuranceWallet = payable(0x269140Dcd4679189e10046aA2D5d8F81750fF202);
		startUNIX = block.timestamp;
        plans.push(Plan(10, 222));
	}

	function invest(address referrer) public payable {
		require(msg.value >= INVEST_MIN_AMOUNT,"min deposit is 0.05 BNB");
        uint8 plan = 0;

		uint256 pro = msg.value * PROJECT_FEE / PERCENTS_DIVIDER;
		projectWallet.transfer(pro);
		uint256 mar = msg.value * MARKETING_FEE / PERCENTS_DIVIDER;
		marketingWallet.transfer(mar);
		uint256 ins = msg.value * INSURANCE_FEE / PERCENTS_DIVIDER;
		insuranceWallet.transfer(ins);
		emit FeePayed(msg.sender, pro + mar + ins);

		User storage user = users[msg.sender];

		if (user.referrer == address(0)) {
			if (users[referrer].deposits.length > 0 && referrer != msg.sender) {
				user.referrer = referrer;
			}

			address upline = user.referrer;
			for (uint256 i = 0; i < 1; i++) {
				if (upline != address(0)) {
					users[upline].levels[i] = users[upline].levels[i] + 1;
					upline = users[upline].referrer;
				} else break;
			}
		}

		if (user.referrer != address(0)) {

			address upline = user.referrer;
			for (uint256 i = 0; i < 1; i++) {
				if (upline != address(0)) {
					uint256 amount = msg.value * REFERRAL_PERCENTS[i] / PERCENTS_DIVIDER;
					users[upline].bonus = users[upline].bonus + amount;
					users[upline].totalBonus = users[upline].totalBonus + amount;
					emit RefBonus(upline, msg.sender, i, amount);
					upline = users[upline].referrer;
				} else break;
			}

		}

		if (user.deposits.length == 0) {
			user.checkpoint = block.timestamp;
			emit Newbie(msg.sender);
		}

		(uint256 percent, uint256 profit, uint256 finish) = getResult(plan, msg.value);
		user.deposits.push(Deposit(plan, percent, msg.value, profit, block.timestamp, finish));

		totalStaked = totalStaked + msg.value;
		emit NewDeposit(msg.sender, plan, percent, msg.value, profit, block.timestamp, finish);
	}

	function withdraw() public {
		User storage user = users[msg.sender];
		require(user.checkpoint + TIME_STEP < block.timestamp, "only once a day");
		uint256 totalAmount = getUserDividends(msg.sender);

		uint256 referralBonus = getUserReferralBonus(msg.sender);
		if (referralBonus > 0) {
			user.bonus = 0;
			totalAmount = totalAmount + referralBonus;
		}

		require(totalAmount > 0, "User has no dividends");
		uint256 contractBalance = address(this).balance;
		if (contractBalance < totalAmount) {
			totalAmount = contractBalance;
		}
		user.checkpoint = block.timestamp;
		payable(msg.sender).transfer(totalAmount);
		emit Withdrawn(msg.sender, totalAmount);
	}

	function reinvest() public {
		User storage user = users[msg.sender];
		require(user.checkpoint + TIME_STEP < block.timestamp, "only once a day");
		uint256 totalAmount = getUserDividends(msg.sender);

		uint256 referralBonus = getUserReferralBonus(msg.sender);
		if (referralBonus > 0) {
			user.bonus = 0;
			totalAmount = totalAmount + referralBonus;
		}

		require(totalAmount > INVEST_MIN_AMOUNT, "User has no dividends");
		user.checkpoint = block.timestamp;

		(uint256 percent, uint256 profit, uint256 finish) = getResult(0, totalAmount);
		user.deposits.push(Deposit(0, percent, totalAmount, profit, block.timestamp, finish));

		totalReinvested = totalReinvested + totalAmount;
		emit Reinvest(msg.sender, totalAmount);
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

	function getResult(uint8 plan, uint256 deposit) public view returns (uint256 percent, uint256 profit, uint256 finish) {
		percent = getPercent(plan);
		profit = deposit * percent / PERCENTS_DIVIDER * plans[plan].time;
		finish = block.timestamp + (plans[plan].time * TIME_STEP);
	}

	function getUserDividends(address userAddress) public view returns (uint256) {
		User storage user = users[userAddress];

		uint256 totalAmount;
		for (uint256 i = 0; i < user.deposits.length; i++) {
			if (user.checkpoint < user.deposits[i].finish) {
				uint256 share = user.deposits[i].amount * user.deposits[i].percent / PERCENTS_DIVIDER;
				uint256 from = user.deposits[i].start > user.checkpoint ? user.deposits[i].start : user.checkpoint;
				uint256 to = user.deposits[i].finish < block.timestamp ? user.deposits[i].finish : block.timestamp;
				if (from < to) {
					totalAmount = totalAmount + (share * (to - from) / TIME_STEP);
				}

				if(user.checkpoint <= user.deposits[i].start && user.deposits[i].finish < block.timestamp){
					totalAmount = totalAmount + (user.deposits[i].amount * HOLD_BONUS / PERCENTS_DIVIDER);
				}

			}
		}

		return totalAmount;
	}

	function getUserCheckpoint(address userAddress) public view returns(uint256) {
		return users[userAddress].checkpoint;
	}

	function getUserReferrer(address userAddress) public view returns(address) {
		return users[userAddress].referrer;
	}

	function getUserDownlineCount(address userAddress) public view returns(uint256) {
		return (users[userAddress].levels[0]);
	}

	function getUserReferralBonus(address userAddress) public view returns(uint256) {
		return users[userAddress].bonus;
	}

	function getUserReferralTotalBonus(address userAddress) public view returns(uint256) {
		return users[userAddress].totalBonus;
	}

	function getUserReferralWithdrawn(address userAddress) public view returns(uint256) {
		return users[userAddress].totalBonus - users[userAddress].bonus;
	}

	function getUserAvailable(address userAddress) public view returns(uint256) {
		return getUserReferralBonus(userAddress) + getUserDividends(userAddress);
	}

	function getUserAmountOfDeposits(address userAddress) public view returns(uint256) {
		return users[userAddress].deposits.length;
	}

	function getUserTotalDeposits(address userAddress) public view returns(uint256 amount) {
		for (uint256 i = 0; i < users[userAddress].deposits.length; i++) {
			amount = amount + users[userAddress].deposits[i].amount;
		}
	}

	function getUserDepositInfo(address userAddress, uint256 index) public view returns(uint8 plan, uint256 percent, uint256 amount, uint256 profit, uint256 start, uint256 finish) {
	    User storage user = users[userAddress];

		plan = user.deposits[index].plan;
		percent = user.deposits[index].percent;
		amount = user.deposits[index].amount;
		profit = user.deposits[index].profit;
		start = user.deposits[index].start;
		finish = user.deposits[index].finish;
	}

	function setPlan(uint256 amount) public{
		require(msg.sender == projectWallet, "only owner");
		require(amount >= 1 && amount <= 20, "amount should be in range of 1 to 20");
		plans[0].percent = amount * 10;
	}
}