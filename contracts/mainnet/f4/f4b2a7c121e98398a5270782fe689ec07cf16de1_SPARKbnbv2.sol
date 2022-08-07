/**
 *Submitted for verification at BscScan.com on 2022-08-07
*/

pragma solidity 0.5.10;

contract SPARKbnbv2 {
	using SafeMath for uint256;

	uint256 constant public INVEST_MIN_AMOUNT = 0.05 ether; 
    uint256 constant public HOUR_LIMIT = 1 ether; // only 1 BNB per Hour
	uint256 constant public MAX_INVESTS = 300; 
	uint256 constant public CEO_FEE = 10;
	uint256 constant public DEV_FEE = 10;
	uint256 constant public PERCENTS_DIVIDER = 1000;
	uint constant public	TIME_STEP = 3600;

	uint256 public totalInvested;
	uint256 public totalReferral;
	uint256 public totalSeed;

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
		address referrer;
		uint256[1] levels;
		uint256 bonus;
		uint256 totalBonus;
		uint256 seed;
		uint256 totalSeed;
		uint256 withdrawn;
	}

	mapping (address => User) internal users;
    mapping (uint => mapping(address => uint)) public dLimit;

	uint256 public startDate;

	address payable public ceoWallet;
	address payable public devWallet;

	event Newbie(address user);
	event NewDeposit(address indexed user, uint8 plan, uint256 amount, uint256 time);
	event Withdrawn(address indexed user, uint256 amount, uint256 time);
	event RefBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
	event FeePaid(address indexed user, uint256 totalAmount);
	event SeedPaid(address indexed user, address indexed referral, uint256 totalAmount, uint256 time);

	constructor(address payable ceoAddr, address payable devAddr, uint256 start) public {
		require(!isContract(ceoAddr) && !isContract(devAddr));
		ceoWallet = ceoAddr;
		devWallet = devAddr;

		if(start>0){
			startDate = start;
		}
		else{
			startDate = block.timestamp;
		}

        plans.push(Plan(1,  1010));
        
	}

	function invest(address referrer, uint8 plan) public payable {
		require(block.timestamp > startDate, "contract does not launch yet");
		require(msg.value >= INVEST_MIN_AMOUNT, "min amount is 0.05 BNB");
         
        require(plan < 1, "Invalid plan");

		uint256 ceo = msg.value.mul(CEO_FEE).div(PERCENTS_DIVIDER);
		uint256 dFee = msg.value.mul(DEV_FEE).div(PERCENTS_DIVIDER);
		ceoWallet.transfer(ceo);
		devWallet.transfer(dFee);
		emit FeePaid(msg.sender, ceo.add(dFee));

		User storage user = users[msg.sender];
		user.referrer = referrer;

		require(user.deposits.length < MAX_INVESTS, " max 300 depsoits");

		if (user.deposits.length == 0) {
			user.checkpoint = block.timestamp;
			emit Newbie(msg.sender);
		}
		user.deposits.push(Deposit(plan, msg.value, block.timestamp));
		totalInvested = totalInvested.add(msg.value);
		emit NewDeposit(msg.sender, plan, msg.value, block.timestamp);
	}

	function withdraw() public {
        User storage user = users[msg.sender];
        require(user.checkpoint.add(TIME_STEP) < block.timestamp, "only once a hour");
		uint256 totalAmount = getUserDividends(msg.sender);
		if (user.bonus > 0) {
            totalAmount = totalAmount.add(user.bonus);
			user.bonus = 0;
		}

        if(dLimit[cDay()][msg.sender] + totalAmount > HOUR_LIMIT){
            user.bonus = dLimit[cDay()][msg.sender].add(totalAmount).sub(HOUR_LIMIT);
            totalAmount = HOUR_LIMIT.sub(dLimit[cDay()][msg.sender]);
        }
        require(totalAmount > 0, "User has no dividends");
        dLimit[cDay()][msg.sender] = dLimit[cDay()][msg.sender].add(totalAmount);

		uint256 contractBalance = address(this).balance;
		if (contractBalance < totalAmount) {
            user.bonus = user.bonus.add(totalAmount.sub(contractBalance));
			totalAmount = contractBalance;
		}
		user.checkpoint = block.timestamp;
		user.withdrawn = user.withdrawn.add(totalAmount);
		msg.sender.transfer(totalAmount);
		emit Withdrawn(msg.sender, totalAmount, block.timestamp);
	}

	function reinvest(uint8 plan) public {
		User storage user = users[msg.sender];
		require(user.deposits.length < MAX_INVESTS, " max 300 depsoits");
		
		(uint256 totalAmount1,) = getUserDividendsOnReinvest(msg.sender);
		uint256 totalAmount = totalAmount1;
		if (user.bonus > 0) {
            totalAmount = totalAmount.add(user.bonus);
			user.bonus = 0;
		}
		require(block.timestamp > startDate, "contract does not launch yet");
		require(totalAmount >= INVEST_MIN_AMOUNT);
        require(plan < 1, "Invalid plan");
		user.deposits.push(Deposit(plan, totalAmount, block.timestamp));
		totalInvested = totalInvested.add(totalAmount);
		user.checkpoint = block.timestamp;
		user.withdrawn = user.withdrawn.add(totalAmount);
		emit NewDeposit(msg.sender, plan, totalAmount, block.timestamp);
	}

	function getContractBalance() public view returns (uint256) {
		return address(this).balance;
	}

	function getPlanInfo(uint8 plan) public view returns(uint256 time, uint256 percent) {
		time = plans[plan].time;
		percent = plans[plan].percent;
	}

	function getUserDividends(address userAddress) public view returns (uint256) {
		User storage user = users[userAddress];
		uint256 totalAmount;
		for (uint256 i = 0; i < user.deposits.length; i++) {
			uint256 finish = user.deposits[i].start.add(plans[user.deposits[i].plan].time.mul(TIME_STEP));
			if (user.checkpoint < finish) {
				uint256 share = user.deposits[i].amount.mul(plans[user.deposits[i].plan].percent).div(PERCENTS_DIVIDER);
				uint256 from = user.deposits[i].start > user.checkpoint ? user.deposits[i].start : user.checkpoint;
				uint256 to = finish < block.timestamp ? finish : block.timestamp;
				if (from < to) {
					totalAmount = totalAmount.add(share.mul(to.sub(from)).div(TIME_STEP));
				}
			}
		}
		return totalAmount;
	}

	function getUserDividendsOnReinvest(address userAddress) public view returns (uint256,uint256) {
		User storage user = users[userAddress];
		uint256 totalAmountPlan1;
		uint256 totalAmountPlan2;
		for (uint256 i = 0; i < user.deposits.length; i++) {
			uint256 finish = user.deposits[i].start.add(plans[user.deposits[i].plan].time.mul(TIME_STEP));
			if (user.checkpoint < finish) {
				uint256 share = user.deposits[i].amount.mul(plans[user.deposits[i].plan].percent).div(PERCENTS_DIVIDER);
				uint256 from = user.deposits[i].start > user.checkpoint ? user.deposits[i].start : user.checkpoint;
				uint256 to = finish < block.timestamp ? finish : block.timestamp;
				if (from < to) {
					totalAmountPlan1 = totalAmountPlan1.add(share.mul(to.sub(from)).div(TIME_STEP));
				}
			}
		}
		return (totalAmountPlan1, totalAmountPlan2);
	}

    function cDay() public view returns(uint) {
		return (block.timestamp.div(TIME_STEP));
	}

    function getUserHOURLimit(address _user) public view returns(uint) {
		return dLimit[cDay()][_user];
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

	function getUserDownlineCount(address userAddress) public view returns(uint256[1] memory referrals) {
		return (users[userAddress].levels);
	}

	function getUserTotalReferrals(address userAddress) public view returns(uint256) {
		return users[userAddress].levels[0];
	}

	function getUserReferralBonus(address userAddress) public view returns(uint256) {
		return users[userAddress].bonus;
	}

	function getUserTotalSeed(address userAddress) public view returns(uint256) {
		return users[userAddress].totalSeed;
	}

	function getUserSeedBonus(address userAddress) public view returns(uint256) {
		return users[userAddress].seed;
	}

	function getUserReferralTotalBonus(address userAddress) public view returns(uint256) {
		return users[userAddress].totalBonus;
	}

	function getUserReferralWithdrawn(address userAddress) public view returns(uint256) {
		return users[userAddress].totalBonus.sub(users[userAddress].bonus);
	}

	function getUserAvailable(address userAddress) public view returns(uint256) {
		return getUserReferralBonus(userAddress).add(getUserDividends(userAddress)).add(getUserSeedBonus(userAddress));
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
		finish = user.deposits[index].start.add(plans[user.deposits[index].plan].time.mul(TIME_STEP));
	}

	function getSiteInfo() public view returns(uint256 _totalInvested, uint256 _totalBonus, uint256 _totalSeed, uint256 _contractBalance) {
		return(totalInvested, totalReferral, totalSeed, getContractBalance());
	}

	function getUserInfo(address userAddress) public view returns(uint256 checkpoint, uint256 totalDeposit, uint256 totalWithdrawn, uint256 totalReferrals, uint256 totalSeeds) {
		return(getUserCheckpoint(userAddress), getUserTotalDeposits(userAddress), getUserTotalWithdrawn(userAddress), getUserTotalReferrals(userAddress), getUserTotalSeed(userAddress));
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