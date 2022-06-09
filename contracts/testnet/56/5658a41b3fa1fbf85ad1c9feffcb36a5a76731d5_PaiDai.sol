/**
 *Submitted for verification at BscScan.com on 2022-06-09
*/

//PLANS:
//  plan 2.5% Forever


//FEES:
// 13% to the treasury
// 2%  to Dev

//ANTI-WHALE:
// Max withdrawal $1500 per day. You have 2.5 Days to pull or you will be maxxed. no more earning until next withdraw.
// Max Wallet Limit $25,000.
// Withdraw cooldown 4 hours.


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

contract PaiDai {
	using SafeMath for uint256;
    IERC20 public token;
    address erctoken = 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee; /** mainnet USDC **/
    uint256 public constant INVEST_MIN_AMOUNT = 1 ether;
	uint256 public PROJECT_FEE = 20;
	uint256 public treasury_WALLET_PERCENTAGE = 130;
	uint256 constant public PERCENTS_DIVIDER = 1000;
	uint256 constant public TIME_STEP = 1 days;
    
    
    uint256 public WITHDRAW_COOLDOWN = 4 * 60 * 60;
    uint256 public MAX_WITHDRAW = 1500 ether;
	uint256 public WALLET_LIMIT = 25000 ether;

	uint256 public totalInvested;
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
		uint256 withdrawn;
	}

	mapping (address => User) internal users;

	bool public started;
	address payable public projectWallet;
	address payable public treasury;
	address payable public contractAddr;

	event Newbie(address user);
	event NewDeposit(address indexed user, uint8 plan, uint256 amount);
	event Withdrawn(address indexed user, uint256 amount);
	event FeePayed(address indexed user, uint256 totalAmount);

	constructor(address payable owner, address payable projectAddress) {
		require(!isContract(owner));
		token = IERC20(erctoken);
		contractAddr = owner;
		projectWallet = projectAddress;

        plans.push(Plan(25, 10000));              
	}

	function invest(uint8 plan, uint256 value) public payable {
		if (!started) {
			if (msg.sender == projectWallet) {
				started = true;
			} else revert("Not started yet");
		}
		
        require(value >= INVEST_MIN_AMOUNT);
        require(plan < plans.length, "Invalid plan");
        uint256 totalDeposits = getUserTotalDeposits(msg.sender);
        require(totalDeposits < WALLET_LIMIT, "Maximum of $25,000 total deposit only for each wallet.");
		require(value <= token.allowance(msg.sender, address(this)));
		token.transferFrom(msg.sender, address(this), value);

		emit FeePayed(msg.sender, payFees(value));

		User storage user = users[msg.sender];

		
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
        
        uint256 com = totalAmount.mul(treasury_WALLET_PERCENTAGE).div(PERCENTS_DIVIDER);
		token.transfer(treasury, com);
        
		require(totalAmount > 0, "User has no dividends");

		uint256 contractBalance = getContractBalance();
		if (contractBalance < totalAmount) {
			totalAmount = contractBalance;
		}
        
        if(user.checkpoint.add(WITHDRAW_COOLDOWN) > block.timestamp) revert("Withdrawals can only be done every 6 hours.");
        if(totalAmount > MAX_WITHDRAW) {
            totalAmount = MAX_WITHDRAW;
        }

		user.checkpoint = block.timestamp;
		user.withdrawn = user.withdrawn.add(totalAmount);

        token.transfer(msg.sender, totalAmount);

		emit Withdrawn(msg.sender, totalAmount);
	}
    
    function payFees(uint256 amount) internal returns(uint256) {
        uint256 fee = amount.mul(PROJECT_FEE).div(PERCENTS_DIVIDER);
		uint256 com = amount.mul(treasury_WALLET_PERCENTAGE).div(PERCENTS_DIVIDER);
		token.transfer(treasury, fee);
		token.transfer(contractAddr, com);
        return fee.add(com);
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

	function getSiteInfo() public view returns(uint256 _totalInvested) {
		return(totalInvested);
	}

	function getUserInfo(address userAddress) public view returns(uint256 totalDeposit, uint256 totalWithdrawn) {
		return(getUserTotalDeposits(userAddress), getUserTotalWithdrawn(userAddress));
	}

	function _projectWallet(address value) external {
        require(msg.sender == projectWallet);
        projectWallet = payable(value);
    }
    
    
    function _treasury(address value) external {
        require(msg.sender == projectWallet);
        treasury = payable(value);
    }
    
    function _treasury_WALLET_PERCENTAGE(uint256 value) external {
        require(msg.sender == projectWallet);
        require(value < 20);
        treasury_WALLET_PERCENTAGE = value;
    }
    
    function _PROJECT_FEE(uint256 value) external {
        require(msg.sender == projectWallet);
        require(value < 130);
        PROJECT_FEE = value;
    }
    
	
	function _PlanPercent(uint8 plan, uint256 value) external {
        require(msg.sender == projectWallet);
        plans[plan].percent = value;
    }
    
    function _PlanTime(uint8 plan, uint256 value) external {
        require(msg.sender == projectWallet);
        plans[plan].time = value;
    }
    
    function _MAX_WITHDRAW(uint256 value) external {
        require(msg.sender == projectWallet);
        MAX_WITHDRAW = value * 1 ether;
    }
    
    function _WALLET_LIMIT(uint256 value) external {
        require(msg.sender == projectWallet);
        WALLET_LIMIT = value * 1 ether;
    }
    
    function _WITHDRAW_COOLDOWN(uint256 value) external {
        require(msg.sender == projectWallet);
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