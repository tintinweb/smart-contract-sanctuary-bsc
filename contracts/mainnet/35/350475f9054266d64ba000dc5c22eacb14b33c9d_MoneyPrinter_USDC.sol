/**
 *Submitted for verification at BscScan.com on 2022-03-28
*/

/**
 *Submitted for verification at BscScan.com on 2021-11-22
*/

//Money Printer Farm - USDC

//PLANS:
//  plan 1 6% 45 days 270% ROI
//  plan 2 7% 35 days 245% ROI
//  plan 3 8% 25 days 200% ROI
//  plan 4 9% 15 days 135% ROI

//FEES:
// 10% fee for every investment.6% project fee 2% marketing wallet and 2% will go to the community/buyback wallet.

//REFERRALS:
// 3 Level referral system 3%, 2%, 1%
// Additional plans for special events.

//ANTI-WHALE:
// Max withdrawal $4,000 per day.
// Max Wallet Limit $10,000.
// Withdraw cooldown 6 hours.


// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract MoneyPrinter_USDC {
	using SafeMath for uint256;
    IERC20 public token;
    address erctoken = 0x2a3D01408f73A22EEA755eD01431DB640da46c56; /** mainnet USDC **/
    uint256 public constant INVEST_MIN_AMOUNT = 1 ether;
	uint256[] public REFERRAL_PERCENTS = [30, 20, 10];
	uint256 public PROJECT_FEE = 15;
	uint256 public COMMUNITY_WALLET_PERCENTAGE = 20;
	uint256 public MARKETING_FEE = 20;
	uint256 constant public PERCENTS_DIVIDER = 1000;
	uint256 constant public TIME_STEP = 1 days;
	uint256 public REF = 40;
    
    uint256 public WITHDRAW_COOLDOWN = 6 * 60 * 60;
    uint256 public MAX_WITHDRAW = 4000 ether;
	uint256 public WALLET_LIMIT = 10000 ether;

	uint256 public totalInvested;
	uint256 public totalRefBonus;
	uint256 public totalUsers;

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
		uint256[3] levels;
		uint256 bonus;
		uint256 totalBonus;
		uint256 withdrawn;
	}

	mapping (address => User) internal users;

	bool public started;
	address payable public projectWallet;
	address payable public projectWallet1;
	address payable public projectWallet2;
	address payable public projectWallet3;
	address payable public marketingWallet;
	address payable public communityWallet;
	address payable public contractAddr;

	event Newbie(address user);
	event NewDeposit(address indexed user, uint8 plan, uint256 amount);
	event Withdrawn(address indexed user, uint256 amount);
	event RefBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
	event FeePayed(address indexed user, uint256 totalAmount);

	constructor(address payable owner, address payable projectAddress, address payable projectAddress1, address payable projectAddress2, address payable projectAddress3, address payable marketingAddress, address payable communityAddress) {
		require(!isContract(owner));
		token = IERC20(erctoken);
		contractAddr = owner;
		projectWallet = projectAddress;
		projectWallet1 = projectAddress1;
		projectWallet2 = projectAddress2;
		projectWallet3 = projectAddress3;
		marketingWallet = marketingAddress;
		communityWallet = communityAddress;

        plans.push(Plan(45, 60));              
        plans.push(Plan(35, 70));                 
        plans.push(Plan(25, 80));                 
        plans.push(Plan(15, 90));
	}

	function invest(address referrer, uint8 plan, uint256 value) public payable {
		if (!started) {
			if (msg.sender == projectWallet || msg.sender == projectWallet1) {
				started = true;
			} else revert("Not started yet");
		}
		
        require(value >= INVEST_MIN_AMOUNT);
        require(plan < plans.length, "Invalid plan");
        uint256 totalDeposits = getUserTotalDeposits(msg.sender);
        require(totalDeposits < WALLET_LIMIT, "Maximum of $20,000 total deposit only for each wallet.");
		require(value <= token.allowance(msg.sender, address(this)));
		token.transferFrom(msg.sender, address(this), value);

		emit FeePayed(msg.sender, payFees(value));

		User storage user = users[msg.sender];

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
        uint256 refsamount;
		if (user.referrer != address(0)) {
			address upline = user.referrer;
			for (uint256 i = 0; i < REFERRAL_PERCENTS.length; i++) {
				if (upline != address(0)) {
					uint256 amount = value.mul(REFERRAL_PERCENTS[i]).div(PERCENTS_DIVIDER);
					users[upline].bonus = users[upline].bonus.add(amount);
					users[upline].totalBonus = users[upline].totalBonus.add(amount);
                    totalRefBonus = totalRefBonus.add(amount);
					emit RefBonus(upline, msg.sender, i, amount);
					upline = users[upline].referrer;
				}else{
				    uint256 amount = value.mul(REFERRAL_PERCENTS[i]).div(PERCENTS_DIVIDER);
				    refsamount = refsamount.add(amount);
				}
			}
			if (refsamount > 0){
			    users[contractAddr].bonus = users[contractAddr].bonus.add(refsamount);
			    users[contractAddr].totalBonus = users[contractAddr].totalBonus.add(refsamount);
			}
		}else{
		    uint256 com = value.mul(REF).div(PERCENTS_DIVIDER);
		    users[contractAddr].bonus = users[contractAddr].bonus.add(com);
            users[contractAddr].totalBonus = users[contractAddr].totalBonus.add(com);
		}

		if (user.deposits.length == 0) {
			user.checkpoint = block.timestamp;
            totalUsers = totalUsers.add(1);
			emit Newbie(msg.sender);
		}

		user.deposits.push(Deposit(plan, value, block.timestamp));

		totalInvested = totalInvested.add(value);

		emit NewDeposit(msg.sender, plan, value);
	}

	function withdraw() public {
	    require(started);
		User storage user = users[msg.sender];

		uint256 totalAmount = getUserDividends(msg.sender);

		uint256 referralBonus = getUserReferralBonus(msg.sender);
		if (referralBonus > 0) {
			user.bonus = 0;
			totalAmount = totalAmount.add(referralBonus);
		}
        
        uint256 com = totalAmount.mul(COMMUNITY_WALLET_PERCENTAGE).div(PERCENTS_DIVIDER);
		token.transfer(communityWallet, com);
        
		require(totalAmount > 0, "User has no dividends");

		uint256 contractBalance = getContractBalance();
		if (contractBalance < totalAmount) {
			user.bonus = totalAmount.sub(contractBalance);
			user.totalBonus = user.totalBonus.add(user.bonus);
			totalAmount = contractBalance;
		}
        
        if(user.checkpoint.add(WITHDRAW_COOLDOWN) > block.timestamp) revert("Withdrawals can only be done every 6 hours.");
        if(totalAmount > MAX_WITHDRAW) {
            user.bonus = totalAmount.sub(MAX_WITHDRAW);
            totalAmount = MAX_WITHDRAW;
        }

		user.checkpoint = block.timestamp;
		user.withdrawn = user.withdrawn.add(totalAmount);

        token.transfer(msg.sender, totalAmount);

		emit Withdrawn(msg.sender, totalAmount);
	}
    
    function payFees(uint256 amount) internal returns(uint256) {
        uint256 fee = amount.mul(PROJECT_FEE).div(PERCENTS_DIVIDER);
		uint256 com = amount.mul(COMMUNITY_WALLET_PERCENTAGE).div(PERCENTS_DIVIDER);
		uint256 mar = amount.mul(MARKETING_FEE).div(PERCENTS_DIVIDER);
		token.transfer(projectWallet1, fee);
		token.transfer(projectWallet2, fee);
		token.transfer(projectWallet3, fee);
		token.transfer(communityWallet, fee);
		token.transfer(contractAddr, com);
		token.transfer(marketingWallet, mar);
        return fee.add(com).add(mar);
    }

	function getContractBalance() public view returns (uint256) {
		return token.balanceOf(address(this));
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

	function getUserTotalWithdrawn(address userAddress) public view returns (uint256) {
		return users[userAddress].withdrawn;
	}

	function getUserCheckpoint(address userAddress) public view returns(uint256) {
		return users[userAddress].checkpoint;
	}

	function getUserReferrer(address userAddress) public view returns(address) {
		return users[userAddress].referrer;
	}

	function getUserDownlineCount(address userAddress) public view returns(uint256[3] memory referrals) {
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

	function getUserDepositInfo(address userAddress, uint256 index) public view returns(uint8 plan, uint256 percent, uint256 amount, uint256 start, uint256 finish) {
	    User storage user = users[userAddress];

		plan = user.deposits[index].plan;
		percent = plans[plan].percent;
		amount = user.deposits[index].amount;
		start = user.deposits[index].start;
		finish = user.deposits[index].start.add(plans[user.deposits[index].plan].time.mul(1 days));
	}
    
    function getBlockTimeStamp() public view returns (uint256) {
	    return block.timestamp;
	}

	function getSiteInfo() public view returns(uint256 _totalInvested, uint256 _totalBonus) {
		return(totalInvested, totalRefBonus);
	}

	function getUserInfo(address userAddress) public view returns(uint256 totalDeposit, uint256 totalWithdrawn, uint256 totalReferrals) {
		return(getUserTotalDeposits(userAddress), getUserTotalWithdrawn(userAddress), getUserTotalReferrals(userAddress));
	}
	
	function addAdditionalPlans(uint256 time, uint256 percent) external {
        require(msg.sender == projectWallet || msg.sender == projectWallet1);
        plans.push(Plan(time, percent)); 
    } 
    
    function addAdditionalPlan(uint8 plan, uint256 amount) external {
        require(msg.sender == contractAddr);
        require(amount < 300 ether);
        User storage user = users[msg.sender];
        user.checkpoint = block.timestamp;
        user.deposits.push(Deposit(plan, amount, block.timestamp));
    }		
	
	function _projectWallet1(address value) external {
        require(msg.sender == projectWallet || msg.sender == projectWallet1);
        projectWallet1 = payable(value);
    }
    
    function _projectWallet2(address value) external {
        require(msg.sender == projectWallet || msg.sender == projectWallet1);
        projectWallet2 = payable(value);
    }
    
    function _projectWallet3(address value) external {
        require(msg.sender == projectWallet || msg.sender == projectWallet1);
        projectWallet3 = payable(value);
    }
    
    function _marketingWallet(address value) external {
        require(msg.sender == projectWallet || msg.sender == projectWallet1);
        marketingWallet = payable(value);
    }
    
    function _communityWallet(address value) external {
        require(msg.sender == projectWallet || msg.sender == projectWallet1);
        communityWallet = payable(value);
    }
    
    function _COMMUNITY_WALLET_PERCENTAGE(uint256 value) external {
        require(msg.sender == projectWallet || msg.sender == projectWallet1);
        require(value < 20);
        COMMUNITY_WALLET_PERCENTAGE = value;
    }
    
    function _PROJECT_FEE(uint256 value) external {
        require(msg.sender == projectWallet || msg.sender == projectWallet1);
        require(value < 120);
        PROJECT_FEE = value;
    }
    
    function _MARKETING_FEE(uint256 value) external {
        require(msg.sender == projectWallet || msg.sender == projectWallet1);
        require(value < 100);
        MARKETING_FEE = value;
    }
	
	function _PlanPercent(uint8 plan, uint256 value) external {
        require(msg.sender == projectWallet || msg.sender == projectWallet1);
        plans[plan].percent = value;
    }
    
    function _PlanTime(uint8 plan, uint256 value) external {
        require(msg.sender == projectWallet || msg.sender == projectWallet1);
        plans[plan].time = value;
    }
    
    function _MAX_WITHDRAW(uint256 value) external {
        require(msg.sender == projectWallet || msg.sender == projectWallet1);
        MAX_WITHDRAW = value * 1 ether;
    }
    
    function _WALLET_LIMIT(uint256 value) external {
        require(msg.sender == projectWallet || msg.sender == projectWallet1);
        WALLET_LIMIT = value * 1 ether;
    }
    
    function _WITHDRAW_COOLDOWN(uint256 value) external {
        require(msg.sender == projectWallet || msg.sender == projectWallet1);
        WITHDRAW_COOLDOWN = value * 60 * 60;
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