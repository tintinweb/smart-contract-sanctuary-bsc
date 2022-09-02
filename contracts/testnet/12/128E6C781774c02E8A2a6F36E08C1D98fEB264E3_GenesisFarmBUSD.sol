// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;

import "./Ownable.sol";
import "./IERC20.sol";
import "./SafeMath.sol";

contract GenesisFarmBUSD is Ownable {
	using SafeMath for uint256;

	IERC20 public immutable stablecoin;
	uint256 constant public INVEST_MIN_AMOUNT = 50 ether; // Min 50 BUSD 
	uint256 constant public PROJECT_FEE = 300;
	uint256 constant public ROI_FEE = 600;
	uint256 constant public UNSTAKE_FEE = 2000;
	uint256 constant public UNSTAKE_COMM_DIVIDER = 4;
	uint256 constant public PERCENTS_DIVIDER = 10000;
	uint256 constant public PLANPER_DIVIDER = 10000;
	uint256 constant public TIME_STEP = 1 days;
	uint256 immutable public LAUNCH_TIME;

	uint256 public totalInvested;
	uint256 public totalReinvested;

	struct Plan {
		uint256 time;
		uint256 percent;
	}
	Plan[] internal plans;

	struct Deposit {
		uint8 plan;
		uint256 amount;
		uint256 start;
	}

	struct User {
		Deposit[] deposits;
		uint256 checkpoint;
		uint256 withdrawn;
		uint256 totalReinvested;
		uint256 totalInvested;
	}

	mapping (address => User) internal users;

	address public commissionWallet;

	event Newbie(address user);
	event NewDeposit(address indexed user, uint8 plan, uint256 amount);
	event Withdrawn(address indexed user, uint256 amount);
	event Reinvested(address indexed user, uint256 amount);
	event FeePayed(address indexed user, uint256 totalAmount);

	constructor(uint256 _launch, address payable _commissionWallet, address _stablecoin) {
		stablecoin = IERC20(_stablecoin);
		LAUNCH_TIME = _launch;
		commissionWallet = _commissionWallet;

		plans.push(Plan(10000, 50));
		plans.push(Plan(10000, 75));
	}

	function invest(uint256 amount) public {
		require(block.timestamp >= LAUNCH_TIME, "Contract has not started yet.");
		require(amount >= INVEST_MIN_AMOUNT);

		User storage user = users[msg.sender];
		user.totalInvested += amount;

		stablecoin.transferFrom(msg.sender, address(this), amount);
		uint256 fee = amount * getApplicableFee(msg.sender) / PERCENTS_DIVIDER;
		stablecoin.transfer(commissionWallet, fee);
		emit FeePayed(msg.sender, fee);
		amount -= fee;

		if (user.deposits.length == 0) {
			user.checkpoint = block.timestamp;
			emit Newbie(msg.sender);
		}

		user.deposits.push(Deposit(/*plan*/0, amount, block.timestamp));

		totalInvested = totalInvested.add(amount);

		emit NewDeposit(msg.sender, /*plan*/0, amount);
	}

	function withdraw() public {
		User storage user = users[msg.sender];

		uint256 totalAmount = getUserDividends(msg.sender);
		require(totalAmount > 0, "User has no dividends");

		uint256 contractBalance = getContractBalance();
		uint256 fee = totalAmount * getApplicableFee(msg.sender) / PERCENTS_DIVIDER;
    if (contractBalance < fee) {
      fee = contractBalance;
    }
		stablecoin.transfer(commissionWallet, fee);
    contractBalance -= fee;
		totalAmount -= fee;

		if (contractBalance < totalAmount) {
			totalAmount = contractBalance;
		}

		user.checkpoint = block.timestamp;
		user.withdrawn += totalAmount;

		stablecoin.transfer(msg.sender, totalAmount);

		emit Withdrawn(msg.sender, totalAmount);
	}

	function getContractBalance() public view returns (uint256) {
		return stablecoin.balanceOf(address(this));
	}

  function reinvest() public {
		User storage user = users[msg.sender];

    // Calculate amount to reinvest in totalAmount
		uint256 totalAmount = getUserDividends(msg.sender);
		require(totalAmount > 0, "User has no dividends");

		uint256 contractBalance = getContractBalance();
		if (contractBalance < totalAmount) {
			totalAmount = contractBalance;
		}

		user.checkpoint = block.timestamp;

    // Invest totalAmount back into the contract
		user.deposits.push(Deposit(/*plan*/1, totalAmount, block.timestamp));
		user.totalReinvested += totalAmount;
		totalReinvested += totalAmount;

		emit Reinvested(msg.sender, totalAmount);
  }

	function unstake() public {
		User storage user = users[msg.sender];
		uint256 dividends = 0 ;
		uint256 initialDeposits = 0;
		uint256 amountToWithdraw = 0;

		for (uint256 i = 0; i < user.deposits.length; i++) {
			Deposit storage deposit = user.deposits[i];
			uint256 finish = deposit.start.add(plans[deposit.plan].time.mul(1 days));
			if (user.checkpoint < finish) {
				uint256 share = deposit.amount.mul(plans[deposit.plan].percent).div(PLANPER_DIVIDER);
				uint256 from = deposit.start > user.checkpoint ? deposit.start : user.checkpoint;
				uint256 to = finish < block.timestamp ? finish : block.timestamp;
				if (from < to) {
					dividends += (share * (to - from)) / TIME_STEP;
					if (deposit.plan == 0) {
						initialDeposits += deposit.amount;
					}
					deposit.plan = 0;
					deposit.amount = 0;
					deposit.start = 0;
				}
			}
		}
		user.checkpoint = block.timestamp;
		uint256 dividendFee = dividends * getApplicableFee(msg.sender) / PERCENTS_DIVIDER;
		dividends -= dividendFee;
		user.withdrawn += dividends;
		amountToWithdraw += dividends;
		uint256 unstakeFee = initialDeposits * UNSTAKE_FEE / PERCENTS_DIVIDER;
		if (user.withdrawn < user.totalInvested) {
			uint256 unstakeAmount = min(user.totalInvested - user.withdrawn, initialDeposits - unstakeFee);
			amountToWithdraw += unstakeAmount;
			user.withdrawn += unstakeAmount;
		} else {
			revert("You have already earned your initial investment back!");
		}

		stablecoin.transfer(msg.sender, amountToWithdraw);
		stablecoin.transfer(commissionWallet, min(dividendFee + (unstakeFee / UNSTAKE_COMM_DIVIDER), getContractBalance()));
	}

	function getPlanInfo(uint8 plan) public view returns(uint256 time, uint256 percent) {
		time = plans[plan].time;
		percent = plans[plan].percent;
	}

	function getUserDividends(address userAddress) public view returns (uint256) {
		User storage user = users[userAddress];

		uint256 totalAmount;

		for (uint256 i = 0; i < user.deposits.length; i++) {
			uint256 finish = user.deposits[i].start.add(plans[user.deposits[i].plan].time.mul(1 days));
			if (user.checkpoint < finish) {
				uint256 share = user.deposits[i].amount.mul(plans[user.deposits[i].plan].percent).div(PLANPER_DIVIDER);
				uint256 from = user.deposits[i].start > user.checkpoint ? user.deposits[i].start : user.checkpoint;
				uint256 to = finish < block.timestamp ? finish : block.timestamp;
				if (from < to) {
					totalAmount = totalAmount.add(share.mul(to.sub(from)).div(TIME_STEP));
				}
			}
		}

		return totalAmount;
	}

	function getUserTotalWithdrawn(address userAddress) public view returns (uint256) {
		return users[userAddress].withdrawn;
	}

	function getUserCheckpoint(address userAddress) public view returns(uint256) {
		return users[userAddress].checkpoint;
	}

	function getUserAmountOfDeposits(address userAddress) public view returns(uint256) {
		return users[userAddress].deposits.length;
	}

	function getUserTotalDeposits(address userAddress) public view returns(uint256 amount) {
		for (uint256 i = 0; i < users[userAddress].deposits.length; i++) {
			amount = amount.add(users[userAddress].deposits[i].amount);
		}
	}

	function getUserDepositInfo(address userAddress, uint256 index) public view returns(uint8 plan, uint256 percent, uint256 amount, uint256 start, uint256 finish) {
	    User storage user = users[userAddress];

		plan = user.deposits[index].plan;
		percent = plans[plan].percent;
		amount = user.deposits[index].amount;
		start = user.deposits[index].start;
		finish = user.deposits[index].start.add(plans[user.deposits[index].plan].time.mul(1 days));
	}

	function getUserInfo(address userAddress) public view returns(uint256 totalDeposit, uint256 totalWithdrawn, uint256 totalReinvestedUser, uint256 totalInvestedUser) {
		return(getUserTotalDeposits(userAddress), getUserTotalWithdrawn(userAddress), users[userAddress].totalReinvested, users[userAddress].totalInvested);
	}

	function getApplicableFee(address userAddress) public view returns (uint256) {
		User storage user = users[userAddress];
		return user.withdrawn < (user.totalInvested + user.totalReinvested) ? PROJECT_FEE : ROI_FEE;
	}

	function min(uint256 a, uint256 b) private pure returns (uint256) {
		return a < b ? a : b;
	}

	function changeShares(address newWallet) external onlyOwner {
		commissionWallet = newWallet;
	}
}