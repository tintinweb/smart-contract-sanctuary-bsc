/**
 *Submitted for verification at BscScan.com on 2022-03-27
*/

pragma solidity 0.6.12;

contract testBNB {
	using SafeMath for uint256;
    using SafeMath for uint8;

	uint256 constant public INVEST_MIN_AMOUNT = 25e15; // 5 BNB
	uint256[] public REFERRAL_PERCENTS = [30, 20, 10];
	uint256 constant public PROJECT_FEE = 80;
	uint256 constant public DEVELOPER_FEE = 20;
	uint256 constant public PERCENT_STEP = 5;
	uint256 constant public PERCENTS_DIVIDER= 1000;
	uint256 constant public TIME_STEP = 1 hours;
	
	uint256 constant public MAX_HOLD_PERCENT = 15;
	
	uint256 WITHDRAW_FEE_1 = 100; //10%
	uint256 WITHDRAW_FEE_2 = 150; //15%

    
	
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
		uint256 holdBonusCheckpoint;
		address payable referrer;
		uint256 referrals;
		uint256 totalBonus;
		uint256 withdrawn;
	}

	mapping (address => User) internal users;

	mapping (uint8 => mapping(address => uint256)) internal noDeposit;

	uint256 public startUNIX;
	address payable private commissionWallet;
	address payable private developerWallet;
	
	

	event Newbie(address user);
	event NewDeposit(address indexed user, uint8 plan, uint256 percent, uint256 amount, uint256 profit, uint256 start, uint256 finish);
	event Withdrawn(address indexed user, uint256 amount);
	event RefBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);

	constructor(address payable wallet, address payable _developer) public {
		require(!isContract(wallet));
		commissionWallet = wallet;
		developerWallet = _developer;
        startUNIX = block.timestamp.add(365 days);

        plans.push(Plan(7, 60)); // 6% per day for 7 days
        plans.push(Plan(14, 80)); // 8% per day for 14 days
        plans.push(Plan(28, 100)); // 10% per day for 28 days
	}

    function launch() public {
        require(msg.sender == developerWallet);
		startUNIX = block.timestamp;
		
        
    } 


    function invest(address payable referrer,uint8 plan) public payable {
        _invest(referrer, plan, msg.sender, msg.value);
           
    }


	function _invest(address payable referrer, uint8 plan, address payable sender, uint256 value) private {

		require(value >= INVEST_MIN_AMOUNT);
        require(plan < 3, "Invalid plan");
        require(startUNIX < block.timestamp, "contract hasn`t started yet");
		

		uint256 fee = value.mul(PROJECT_FEE).div(PERCENTS_DIVIDER);
		commissionWallet.transfer(fee);
		uint256 developerFee = value.mul(DEVELOPER_FEE).div(PERCENTS_DIVIDER);
		developerWallet.transfer(developerFee);
		
		User storage user = users[sender];

		if (user.referrer == address(0)) {
			if (users[referrer].deposits.length > 0 && referrer != sender) {
				user.referrer = referrer;
			}

			address upline = user.referrer;
			for (uint256 i = 0; i < 3; i++) {
				if (upline != address(0)) {
					users[upline].referrals = users[upline].referrals.add(1);
					upline = users[upline].referrer;
				} else break;
			}
		}

				if (user.referrer != address(0)) {
					uint256 _refBonus = 0;
					address payable upline = user.referrer;
					for (uint256 i = 0; i < 3; i++) {
						if (upline != address(0)) {
							uint256 amount = value.mul(REFERRAL_PERCENTS[i]).div(PERCENTS_DIVIDER);
							
							users[upline].totalBonus = users[upline].totalBonus.add(amount);
                            upline.transfer(amount);
							_refBonus = _refBonus.add(amount);
						
							emit RefBonus(upline, sender, i, amount);
							upline = users[upline].referrer;
						} else break;
					}

					totalRefBonus = totalRefBonus.add(_refBonus);

				}
		
		noDeposit[plan][msg.sender] = noDeposit[plan][msg.sender] + 1;

		if (user.deposits.length == 0) {
			user.checkpoint = block.timestamp;
			user.holdBonusCheckpoint = block.timestamp;
			emit Newbie(sender);
		}

		

		(uint256 percent, uint256 profit, uint256 finish) = getResult(plan, value);
		
		user.deposits.push(Deposit(plan, percent, value, profit, block.timestamp, finish));

		totalStaked = totalStaked.add(value);
        totalUsers = totalUsers.add(1);
		
		emit NewDeposit(sender, plan, percent, value, profit, block.timestamp, finish);
	}

	function withdraw() public {
		
		User storage user = users[msg.sender];

		uint256 totalAmount = getUserDividends(msg.sender);

		require(totalAmount > 0, "User has no dividends");

		uint256 contractBalance = address(this).balance;
		if (contractBalance < totalAmount) {
			totalAmount = contractBalance;
		}

		user.checkpoint = block.timestamp;
		user.holdBonusCheckpoint = block.timestamp;

		user.withdrawn = user.withdrawn.add(totalAmount);
		msg.sender.transfer(totalAmount);

		emit Withdrawn(msg.sender, totalAmount);

	}

	
    

	function getContractBalance() public view returns (uint256) {
		return address(this).balance;
	}

	function getPlanInfo(uint8 plan) public view returns(uint256 time, uint256 percent) {
		time = plans[plan].time;
		percent = plans[plan].percent;
	}

	function getPercent(uint8 plan) public view returns (uint256) {
	    
			return plans[plan].percent.add(PERCENT_STEP.mul(block.timestamp.sub(startUNIX)).div(TIME_STEP));
		
    }
    

	function getResult(uint8 plan, uint256 deposit) public view returns (uint256 percent, uint256 profit, uint256 finish) {
		percent = getPercent(plan);

	
		if (plan < 3) {
			profit = deposit.mul(percent).div(PERCENTS_DIVIDER).mul(plans[plan].time);
		}

		finish = block.timestamp.add(plans[plan].time.mul(TIME_STEP));
	}
	
	 function getUserPercentRate(address userAddress) public view returns (uint) {
        User storage user = users[userAddress];

        uint256 timeMultiplier = block.timestamp.sub(user.holdBonusCheckpoint).div(TIME_STEP); // +0.1% per day
            if (timeMultiplier > MAX_HOLD_PERCENT) {
                timeMultiplier = MAX_HOLD_PERCENT;
            }

         return timeMultiplier;
    }
    

	function getUserDividends(address userAddress) public returns (uint256) {
		User storage user = users[userAddress];

		uint256 totalAmount;
		
		for (uint256 i = 0; i < user.deposits.length; i++) {

			if (user.checkpoint < user.deposits[i].finish) {
					if(block.timestamp > user.deposits[i].finish) {
						require(noDeposit[user.deposits[i].plan][msg.sender] > 1, "KingBNB: must have more than 1 active plan");
						uint256 _profit = user.deposits[i].profit;
						uint256 _profitWithFee = _profit.sub(_profit.mul(WITHDRAW_FEE_2).div(PERCENTS_DIVIDER));
						totalAmount = totalAmount.add(_profitWithFee);
						noDeposit[user.deposits[i].plan][msg.sender] = noDeposit[user.deposits[i].plan][msg.sender] - 1;
					}
			}
		}
  
		return totalAmount;
	}

	function getUserAvailable(address userAddress) public view returns (uint256) {
		User storage user = users[userAddress];

		uint256 totalAmount;

		for (uint256 i = 0; i < user.deposits.length; i++) {


			if (user.checkpoint < user.deposits[i].finish) {
					if(block.timestamp > user.deposits[i].finish) {
						totalAmount = totalAmount.add(user.deposits[i].profit);
					}
				}
			}

       
		return totalAmount;
	}

    function getContractInfo() public view returns(uint256, uint256, uint256) {
        return(totalStaked, totalRefBonus, totalUsers);
    }

	function getUserWithdrawn(address userAddress) public view returns(uint256) {
		return users[userAddress].withdrawn;
	}

	function getUserCheckpoint(address userAddress) public view returns(uint256) {
		return users[userAddress].checkpoint;
	}
    
	function getUserReferrer(address userAddress) public view returns(address) {
		return users[userAddress].referrer;
	} 

	function getUserDownlineCount(address userAddress) public view returns(uint256) {
		return (users[userAddress].referrals);
	}

	function getUserReferralTotalBonus(address userAddress) public view returns(uint256) {
		return users[userAddress].totalBonus;
	}


	function getUserAmountOfDeposits(address userAddress) public view returns(uint256) {
		return users[userAddress].deposits.length;
	}

	function getUserTotalDeposits(address userAddress) public view returns(uint256 amount) {
		for (uint256 i = 0; i < users[userAddress].deposits.length; i++) {
			amount = amount.add(users[userAddress].deposits[i].amount);
		}
	}

	function getUserTotalWithdrawn(address userAddress) public view returns(uint256 amount) {
		
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