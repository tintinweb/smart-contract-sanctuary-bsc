/**
 *Submitted for verification at BscScan.com on 2022-09-04
*/

pragma solidity 0.5.10;

contract XXXXX {
	using SafeMath for uint256;

	//uint256 constant public INVEST_MIN_AMOUNT = 0.1 ether; mainnet
	uint256 constant public INVEST_MIN_AMOUNT = 0.01 ether;  //testnet
	uint256[] public REFERRAL_PERCENTS = [250, 150, 50, 50];
	uint256[] public PLAN_CHECKPOINTS = [1, 1, 0, 7];
	uint256 constant public OWNER_FEE = 500;
	uint256 constant public PERCENTS_DIVIDER = 10000;
	//uint256 constant public TIME_STEP = 1 days;   mainnet
	uint256 constant public TIME_STEP = 60;  //testnet
	uint256 public constant MAXIMUM_NUMBER_DEPOSITS = 200;

	uint256 public totalInvested;
	uint256 public totalReferral;

    struct Plan {
        uint256 time;
        uint256 percent;
    }

    Plan[] internal plans;

	struct Deposit {
        uint8 plan;
		uint256 amount;
		uint256 start;
		uint256 checkpoint;
	}


	struct User {
		Deposit[] deposits;
		uint256 checkpoint;
		address referrer;
		uint256[4] levels;
		uint256 bonus;
		uint256 totalBonus;
		uint256 withdrawn;
	}

	mapping (address => User) internal users;

	uint256 public startDate;

	address payable public ceoWallet;

	event Newbie(address user);
	event NewDeposit(address indexed user, uint8 plan, uint256 amount, uint256 time);
	event Withdrawn(address indexed user, uint256 amount, uint256 time);
	event RefBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
	event FeePayed(address indexed user, uint256 totalAmount);
	event WithdrawnRef(address indexed user, uint256 amount);

	constructor(uint256 start) public {
		//ceoWallet = payable(0x65A3f0eFe2e40Bd676484563aE96B85D35E180BD);   mainnet
		ceoWallet = 0xeD08994C435946Ac8De71A5c75cAe91F5175D569;   //testnet

		if(start>0){
			startDate = start;
		}
		else{
			startDate = block.timestamp;
		}

        plans.push(Plan(10000, 500));
        plans.push(Plan(15, 700));
        plans.push(Plan(15, 800));
		plans.push(Plan(21, 680));
	}

	function invest(address referrer, uint8 plan) public payable {
		require(block.timestamp > startDate, "contract does not launch yet");
		require(msg.value >= INVEST_MIN_AMOUNT, "invalid amount");
        require(plan < 4, "Invalid plan");

		uint256 fee = msg.value.mul(OWNER_FEE).div(PERCENTS_DIVIDER);
		ceoWallet.transfer(fee);
		emit FeePayed(msg.sender, fee);

		User storage user = users[msg.sender];

		if (user.referrer == address(0)) {
			if (users[referrer].deposits.length > 0 && referrer != msg.sender) {
				user.referrer = referrer;
			}

			address upline = user.referrer;
			for (uint256 i = 0; i < 4; i++) {
				if (upline != address(0)) {
					users[upline].levels[i] = users[upline].levels[i].add(1);
					upline = users[upline].referrer;
				} else break;
			}
		}

		if (user.referrer != address(0)) {
			address upline = user.referrer;
			for (uint256 i = 0; i < 4; i++) {
				if (upline != address(0)) {
					uint256 amount = msg.value.mul(REFERRAL_PERCENTS[i]).div(PERCENTS_DIVIDER);
					users[upline].bonus = users[upline].bonus.add(amount);
					users[upline].totalBonus = users[upline].totalBonus.add(amount);
					totalReferral = totalReferral.add(amount);
					emit RefBonus(upline, msg.sender, i, amount);
					upline = users[upline].referrer;
				} else break;
			}
		}

		if (user.deposits.length == 0) {
			user.checkpoint = block.timestamp;
			emit Newbie(msg.sender);
		}

		user.deposits.push(Deposit(plan, msg.value, block.timestamp, block.timestamp));

		totalInvested = totalInvested.add(msg.value);

		emit NewDeposit(msg.sender, plan, msg.value, block.timestamp);
	}

	function withdraw(uint256 depositId) public {
		User storage user = users[msg.sender];
		require(user.deposits[depositId].checkpoint.add(PLAN_CHECKPOINTS[user.deposits[depositId].plan].mul(TIME_STEP)) < block.timestamp , "not yet");

		uint256 totalAmount = getUserDividends(msg.sender, depositId);

		require(totalAmount > 0, "User has no dividends");
		require(totalAmount <= address(this).balance, "not enough BNB in contract");

		uint256 fee = totalAmount.mul(OWNER_FEE).div(PERCENTS_DIVIDER);
		ceoWallet.transfer(fee);
		emit FeePayed(msg.sender, fee);

		totalAmount = totalAmount.sub(fee);
		user.deposits[depositId].checkpoint = block.timestamp;
		user.checkpoint = block.timestamp;
		user.withdrawn = user.withdrawn.add(totalAmount);

		msg.sender.transfer(totalAmount);

		emit Withdrawn(msg.sender, totalAmount, block.timestamp);
	}
	
	function withdrawRef() public {
		require(block.timestamp > startDate, "contract does not launch yet");
		User storage user = users[msg.sender];
		uint256 totalAmount = 0;
		uint256 referralBonus = getUserReferralBonus(msg.sender);
		if (referralBonus > 0) {
			user.bonus = 0;
			totalAmount = totalAmount.add(referralBonus);
		}
		require(totalAmount > 0, "User has no dividends");
		require(totalAmount <= address(this).balance, "not enough BNB in contract");

		msg.sender.transfer(totalAmount);
		emit WithdrawnRef(msg.sender, totalAmount);
	}

	function getContractBalance() public view returns (uint256) {
		return address(this).balance;
	}

	function getPlanInfo(uint8 plan) public view returns(uint256 time, uint256 percent) {
		time = plans[plan].time;
		percent = plans[plan].percent;
	}

	function getUserDividends(address _userAddress, uint256 _depositID) public view returns (uint256) {
		User storage user = users[_userAddress];

		uint256 totalAmount;
		uint256 finish = user.deposits[_depositID].start.add(plans[user.deposits[_depositID].plan].time.mul(TIME_STEP));
			if(user.deposits[_depositID].plan == 2){
				if (block.timestamp > finish) {
					totalAmount = totalAmount.add(user.deposits[_depositID].amount.mul(plans[user.deposits[_depositID].plan].percent.mul(plans[user.deposits[_depositID].plan].time)).div(PERCENTS_DIVIDER));
				}
			}else{
				if (user.deposits[_depositID].checkpoint < finish) {
					uint256 share = user.deposits[_depositID].amount.mul(plans[user.deposits[_depositID].plan].percent).div(PERCENTS_DIVIDER);
					if(user.deposits[_depositID].plan == 3){
						share = share.add(getExtraRate(_userAddress, _depositID));
					}
					uint256 from = user.deposits[_depositID].start > user.deposits[_depositID].checkpoint ? user.deposits[_depositID].start : user.deposits[_depositID].checkpoint;
					uint256 to = finish < block.timestamp ? finish : block.timestamp;
					if (from < to) {
						totalAmount = totalAmount.add(share.mul(to.sub(from)).div(TIME_STEP));
					}	
				}
			}
			
		return totalAmount;
	}

	function getExtraRate(address _userAddress, uint256 _depositID) public view returns (uint256) {
        User storage user = users[_userAddress];
		uint256 finish = user.deposits[_depositID].start.add(plans[user.deposits[_depositID].plan].time.mul(TIME_STEP));
		uint to = finish < block.timestamp ? finish : block.timestamp;
		uint256 from = user.deposits[_depositID].start > user.deposits[_depositID].checkpoint ? user.deposits[_depositID].start : user.deposits[_depositID].checkpoint;
		uint timeMultiplier = (to.sub(from)).div(TIME_STEP).mul(5);
		return timeMultiplier;
    }

	function getUserTotalWithdrawn(address userAddress) public view returns (uint256) {
		return users[userAddress].withdrawn;
	}

	function getUserCheckpoint(address userAddress) public view returns(uint256) {
		return users[userAddress].checkpoint;
	}

	function getUserReferrer(address userAddress) public view returns(address) {
		return users[userAddress].referrer;
	}

	function getUserDownlineCount(address userAddress) public view returns(uint256[4] memory referrals) {
		return (users[userAddress].levels);
	}
	
	function getUserTotalReferrals(address userAddress) public view returns(uint256) {
		return users[userAddress].levels[0]+users[userAddress].levels[1]+users[userAddress].levels[2]+users[userAddress].levels[3];
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

	function getUserAvailable(address userAddress, uint256 deposiId) public view returns(uint256) {
		return getUserDividends(userAddress, deposiId);
	}

	function getUserRefAvailable(address userAddress) public view returns(uint256) {
		return getUserReferralBonus(userAddress);
	}
	
	function getUserAmountOfDeposits(address userAddress) public view returns(uint256) {
		return users[userAddress].deposits.length;
	}

	function getUserTotalDeposits(address userAddress) public view returns(uint256 amount) {
		for (uint256 i = 0; i < users[userAddress].deposits.length; i++) {
			amount = amount.add(users[userAddress].deposits[i].amount);
		}
	}

	function getUserDepositInfo(address userAddress, uint256 index) public view returns(uint8 plan, uint256 percent, uint256 amount, uint256 start, uint256 finish, uint256 checkpoint) {
	    User storage user = users[userAddress];

		plan = user.deposits[index].plan;
		percent = plans[plan].percent;
		amount = user.deposits[index].amount;
		start = user.deposits[index].start;
		finish = user.deposits[index].start.add(plans[user.deposits[index].plan].time.mul(TIME_STEP));
		checkpoint = user.deposits[index].checkpoint;
	}

	function getSiteInfo() public view returns(uint256 _totalInvested, uint256 _totalBonus) {
		return(totalInvested, totalReferral);
	}

	function getUserInfo(address userAddress) public view returns(uint256 checkpoint, uint256 totalDeposit, uint256 totalWithdrawn, uint256 totalReferrals) {
		return(getUserCheckpoint(userAddress), getUserTotalDeposits(userAddress), getUserTotalWithdrawn(userAddress), getUserTotalReferrals(userAddress));
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