/**
 *Submitted for verification at BscScan.com on 2022-09-03
*/

/**
 *Submitted for verification at BscScan.com on 2022-09-01
*/

// SPDX-License-Identifier: None

pragma solidity 0.6.12;

contract sfeferferfer {
    IBEP20 token;
    using SafeMath for uint256;
    address bst = 0x136561788492C78D143cF77e2B912ab29B6Ec949;
    uint256 public constant INVEST_MIN_AMOUNT = 1 wei;
    uint256[] public REFERRAL_PERCENTS = [100];//10% referal reward
    uint256 public constant PERCENTS_DIVIDER = 1000;
    uint256 public constant TIME_STEP = 1 days;
    uint256 public totalInvested;
    uint256 public totalRefBonus;
    uint256 public startUNIX;
    address payable public OwnerAddress;
    uint256 public totalDeposits;
    uint256 public PercentPlan_1 = 10 wei;
    uint256 public PercentPlan_2 = 15 wei;
    uint256 public PercentPlan_3 = 20 wei;

    struct Plan {
        uint256 time;
        uint256 percent ;
        uint256 withdrawl;
    }

    Plan[] internal plans;

    struct Deposit {
        uint8 plan;
		uint256 percent;
		uint256 amount;
		uint256 profit;
		uint256 start;
		uint256 finish;
        uint256 cooldown;
    }

    struct User {
        Deposit[] deposits;
        uint256 checkpoint;
        address referrer;
        uint256[1] levels;
        uint256 bonus;
        uint256 totalBonus;
        uint256 withdrawn;
        uint256 invest;
    }

    mapping(address => User) internal users;
    event Newbie(address user);
	event NewDeposit(address indexed user, uint8 plan, uint256 percent, uint256 amount, uint256 profit, uint256 start, uint256 finish);

    event Withdrawn(address indexed user, uint256 amount);
    event RefBonus(
        address indexed referrer,
        address indexed referral,
        uint256 indexed level,
        uint256 amount
    );
    event FeePayed(address indexed user, uint256 totalAmount);

    constructor(address payable wallet) public {
        token = IBEP20(bst);
        startUNIX = 1661555726;  
        OwnerAddress = wallet;
      //  plans.push(Plan(1, 10 wei, 63072000));
      //  plans.push(Plan(1, 15 wei, 94608000));
      //  plans.push(Plan(1, 20 wei, 157680000));
  }

function Reward_Staki () private {
      //  require(msg.sender == OwnerAddress, "Admin use only.");
        plans.push(Plan(1, PercentPlan_1, 63072000));
        plans.push(Plan(1, PercentPlan_2, 94608000));
        plans.push(Plan(1, PercentPlan_3, 157680000));
return;
     }



function Percent_staking_1 (uint256 values  ) external {
        require(msg.sender == OwnerAddress, "Admin use only.");
          require(values >= 3 wei && values <= 10 wei);
         PercentPlan_1 = values; 
     }

     function Percent_staking_2 (uint256 values  ) external {
        require(msg.sender == OwnerAddress, "Admin use only.");
          require(values >= 4 wei && values <= 15 wei);
         PercentPlan_2 = values; 
     }

     function Percent_staking_3 (uint256 values  ) external {
        require(msg.sender == OwnerAddress, "Admin use only.");
          require(values >= 6 wei && values <= 20 wei);
         PercentPlan_3 = values; 
     }



    function invest(address referrer, uint8 plan,  uint256 value) public {

        require(value >= INVEST_MIN_AMOUNT);
        require(plan <= 2, "Invalid plan");
        token.transferFrom(msg.sender, address(this), value);
        User storage user = users[msg.sender];

if (user.referrer == address(0)) {
            if (users[referrer].deposits.length > 0 && referrer != msg.sender) {
                user.referrer = referrer;
            }

            address upline = user.referrer;
            for (uint256 i = 0; i < 1; i++) {
                if (upline != address(0)) {
                    users[upline].levels[i] = users[upline].levels[i].add(1);
                    upline = users[upline].referrer;
                } else break;
            }
        }
        if (user.referrer != address(0)) {
            address upline = user.referrer;
            for (uint256 i = 0; i < 1; i++) {
                if (upline != address(0)) {
                    uint256 amount = value.mul(REFERRAL_PERCENTS[i]).div(
                        PERCENTS_DIVIDER
                    );
                    users[upline].bonus = users[upline].bonus.add(amount);
                    users[upline].totalBonus = users[upline].totalBonus.add(
                        amount
                    );
                    emit RefBonus(upline, msg.sender, i, amount);
                    upline = users[upline].referrer;
                } else break;
            }
        }


        if (user.deposits.length == 0) {
            user.checkpoint = block.timestamp;
            emit Newbie(msg.sender);
        }
		(uint256 percent, uint256 profit, uint256 finish) = getResult(plan, value);
		user.deposits.push(Deposit(plan, percent, value, profit, block.timestamp, finish, ( block.timestamp+(plans[plan].withdrawl ))));
        totalInvested = totalInvested.add(value);
        emit NewDeposit(msg.sender, plan, percent, value, profit, block.timestamp, finish);
        totalDeposits = totalDeposits.add(1);
    }

    function withdraw() public {
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
			totalAmount = contractBalance;
		}
		user.checkpoint = block.timestamp;
        for (uint256 x = 0; x < user.deposits.length; x++) {
			 if(block.timestamp > user.deposits[x].cooldown) {
                user.deposits[x].cooldown = block.timestamp+(plans[user.deposits[x].plan].withdrawl );
             }
		}        
		user.withdrawn = user.withdrawn.add(totalAmount);
        token.transfer(msg.sender, totalAmount);

		emit Withdrawn(msg.sender, totalAmount);
	}

    function blockinfo() public view returns (uint256)
    {
        return block.timestamp;
    }


    function getContractBalance() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function getPlanInfo(uint8 plan)
        public
        view
        returns (uint256 time, uint256 percent, uint256 withdrawl)
    {
        time = plans[plan].time;
        percent = plans[plan].percent;
        withdrawl = plans[plan].withdrawl;

    }

	function getResult(uint8 plan, uint256 deposit) public view returns (uint256 percent, uint256 profit, uint256 finish) {
		percent = getPercent(plan);
		profit = deposit.mul(percent).div(PERCENTS_DIVIDER).mul(plans[plan].time);
		finish = block.timestamp.add(plans[plan].time.mul(TIME_STEP));
	}

	function getPercent(uint8 plan) public view returns (uint256) {
	   return plans[plan].percent;
    }

  function getUserDividendsinfo(address userAddress)
        public
        view
        returns (uint256)
    {
        User storage user = users[userAddress];

        uint256 totalAmount;
        for (uint256 i = 0; i < user.deposits.length; i++) {
		if (user.checkpoint < user.deposits[i].finish) {
        uint256 share = user.deposits[i].amount.mul(user.deposits[i].percent).div(PERCENTS_DIVIDER);
        uint256 from = user.deposits[i].start > user.checkpoint ? user.deposits[i].start : user.checkpoint;
        uint256 to = user.deposits[i].finish < block.timestamp ? user.deposits[i].finish : block.timestamp;
         if (from < to) {
		totalAmount = totalAmount.add(share.mul(to.sub(from)).div(TIME_STEP));
               }
            }
        }
       return totalAmount;
    }

    function getUserDividends(address userAddress)
        public
        view
        returns (uint256)
    {
        User storage user = users[userAddress];

        uint256 totalAmount;

        for (uint256 i = 0; i < user.deposits.length; i++) {
		if (user.checkpoint < user.deposits[i].finish) {
        if(block.timestamp > user.deposits[i].cooldown) {
        uint256 share = user.deposits[i].amount.mul(user.deposits[i].percent).div(PERCENTS_DIVIDER);
        uint256 from = user.deposits[i].start > user.checkpoint ? user.deposits[i].start : user.checkpoint;
         uint256 to = user.deposits[i].finish < block.timestamp ? user.deposits[i].finish : block.timestamp;
        if (from < to) {
		totalAmount = totalAmount.add(share.mul(to.sub(from)).div(TIME_STEP));

                }
                }
            }
        }
       return totalAmount;
    }

    function getUserTotalWithdrawn(address userAddress)
        public
        view
        returns (uint256)
    {
        return users[userAddress].withdrawn;
    }

    function getUserCheckpoint(address userAddress)
        public
        view
        returns (uint256)
    {
        return users[userAddress].checkpoint;
    }

    function getUserReferrer(address userAddress)
        public
        view
        returns (address)
    {
        return users[userAddress].referrer;
    }

    function getUserDownlineCount(address userAddress)
        public
        view
        returns (uint256[1] memory referrals)
    {
        return (users[userAddress].levels);
    }

    function getUserTotalReferrals(address userAddress)
        public
        view
        returns (uint256)
    {
        return
            users[userAddress].levels[0];
    }

    function getUserReferralBonus(address userAddress)
        public
        view
        returns (uint256)
    {
        return users[userAddress].bonus;
    }

    function getUserReferralTotalBonus(address userAddress)
        public
        view
        returns (uint256)
    {
        return users[userAddress].totalBonus;
    }

    function getUserReferralWithdrawn(address userAddress)
        public
        view
        returns (uint256)
    {
        return users[userAddress].totalBonus.sub(users[userAddress].bonus);
    }

    function getUserAvailable(address userAddress)
        public
        view
        returns (uint256)
    {
        return getUserReferralBonus(userAddress).add(getUserDividendsinfo(userAddress));

    }

    function getUserAmountOfDeposits(address userAddress)
        public
        view
        returns (uint256)
    {
        return users[userAddress].deposits.length;
    }

    function getUserTotalDeposits(address userAddress)
        public
        view
        returns (uint256 amount)
    {
        for (uint256 i = 0; i < users[userAddress].deposits.length; i++) {
            amount = amount.add(users[userAddress].deposits[i].amount);
        }
    }

	function getUserDepositInfo(address userAddress, uint256 index) public view returns(uint8 plan, uint256 percent, uint256 amount, uint256 profit, uint256 start, uint256 finish, uint256 cooldown) {
	    User storage user = users[userAddress];

		plan = user.deposits[index].plan;
		percent = user.deposits[index].percent;
		amount = user.deposits[index].amount;
		profit = user.deposits[index].profit;
		start = user.deposits[index].start;
		finish = user.deposits[index].finish;
        cooldown = user.deposits[index].cooldown;
	}

	function getUserLastDepositInfo(address userAddress, uint8 plan) public view returns( uint256 percent, uint256 amount, uint256 start, uint256 finish, uint256 profit, uint256 cooldown) {
	    User storage user = users[userAddress];
		if(user.deposits.length > 0){
			plan = user.deposits[users[userAddress].deposits.length - 1].plan;
			percent = user.deposits[users[userAddress].deposits.length - 1].percent;
			amount = user.deposits[users[userAddress].deposits.length - 1].amount;
			start = user.deposits[users[userAddress].deposits.length - 1].start;
			finish = user.deposits[users[userAddress].deposits.length - 1].finish;
			profit = user.deposits[users[userAddress].deposits.length - 1].profit;
            cooldown = user.deposits[users[userAddress].deposits.length - 1].cooldown;
		}	
	}

    function getSiteInfo()
        public
        view
        returns (uint256 _totalInvested, uint256 _totalBonus, uint256 _totalDeposits)
    {
        return (totalInvested, totalRefBonus, totalDeposits);
    }

    function getUserInfo(address userAddress)
        public
        view
        returns (
            uint256 totalDeposit,
            uint256 totalWithdrawn,
            uint256 totalReferrals
        )
    {
        return (
            getUserTotalDeposits(userAddress),
            getUserTotalWithdrawn(userAddress),
            getUserTotalReferrals(userAddress)
        );
    }

    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
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

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}