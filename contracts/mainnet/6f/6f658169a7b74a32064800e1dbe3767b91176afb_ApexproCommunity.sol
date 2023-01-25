/**
 *Submitted for verification at BscScan.com on 2023-01-25
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;


/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
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




// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}





contract ApexproCommunity is Ownable {
	using SafeMath for uint256;

	uint256          public INVEST_MIN_AMOUNT = 0.005 ether; // Min 0.005 bnb 
    uint256          public MAX_WITHDRAW_AMOUNT = 1 ether; // claim 1 BNB max
	uint256[] public REFERRAL_PERCENTS = [500, 0, 0, 0, 0, 0, 0, 0, 0, 0];
	uint256[] public SEED_PERCENTS = [1000, 500, 400, 300, 200, 150, 150, 100, 100, 100];
	uint256          public PROJECTIN_FEE = 200;
    uint256          public PROJECTOUT_FEE = 100;
    uint256          public MARKETIN_FEE = 600;
    uint256          public MARKETOUT_FEE = 0;
	uint256          public DEVIN_FEE = 200;
    uint256          public DEVOUT_FEE = 0;
    uint256          public TAX_FEE = 500; // goes to contract
	uint256 constant public PERCENT_STEP = 10;
	uint256 constant public PERCENTS_DIVIDER = 10000;
	uint256 constant public PLANPER_DIVIDER = 10000;
	uint256          public	WITHDRAW_COOLDOWN = 3 days; // short claim day
    uint256          public	WITHDRAW_COOLDOWN2 = 0 days; // reward claim day
    uint256          public	WITHDRAW_COOLDOWN3 = 100 days; // long claim day
    uint256          public	YIELD_COOLDOWN = 3 days; // yield cooldown
	uint256 constant public TIME_STEP = 1 days;
	uint256 immutable public LAUNCH_TIME;

	uint256 public totalInvested;
	uint256 public totalReinvested;
	uint256 public totalRefBonus;

	bool public refContestEnabled = true;
	struct Contestant {
		address addr;
		uint256 amount;
	}
	// mapping from week number to top-5 leaderboard
	mapping (uint256 => Contestant[10]) public topReferrers;
	// mapping from week number to contestant to amount
	mapping (uint256 => mapping (address => uint256)) public relevantReferrals;
	
	
	address chkLv2;
    address chkLv3;
    address chkLv4;
    address chkLv5;
    address chkLv6;
    address chkLv7;
    address chkLv8;
    address chkLv9;
    address chkLv10;
   
	

    
    struct RefUserDetail {
        address refUserAddress;
        uint256 refLevel;
    }

    mapping(address => mapping (uint => RefUserDetail)) public RefUser;
    mapping(address => uint256) public referralCount_;
    
	
	mapping(address => address) internal referralLevel1Address;
    mapping(address => address) internal referralLevel2Address;
    mapping(address => address) internal referralLevel3Address;
    mapping(address => address) internal referralLevel4Address;
    mapping(address => address) internal referralLevel5Address;
    mapping(address => address) internal referralLevel6Address;
    mapping(address => address) internal referralLevel7Address;
    mapping(address => address) internal referralLevel8Address;
    mapping(address => address) internal referralLevel9Address;
    mapping(address => address) internal referralLevel10Address;
   
	

    
	

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
		uint256 shortcheckpoint;
        uint256 longcheckpoint;
        uint256 rewardcheckpoint;
        uint256 shortyieldcheckpoint;
        uint256 longyieldcheckpoint;
		address referrer;
		uint256[10] levels;
		uint256 bonus;
		uint256 totalBonus;
		uint256 seedincome;
		uint256 withdrawn;
		uint256 withdrawnseed;
		uint256 totalReinvested;
        uint256 totalinvest;
        bool blacklisted;
	}
	
	
	

	mapping (address => User) internal users;

	address payable public commissionWallet;
	address payable public devWallet;
    address payable public ownerWallet;

	event Newbie(address user);
	event NewDeposit(address indexed user, uint8 plan, uint256 amount);
	event Withdrawn(address indexed user, uint256 amount);
	event Reinvested(address indexed user, uint256 amount);
	event RefBonus(address indexed referrer, address referral, uint256 indexed week, uint256 indexed level, uint256 amount);
	event SeedIncome(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
	event DfeePayed(address indexed user, uint256 totalAmount); // deposite fee
    event WfeePayed(address indexed user, uint256 totalAmount); // withdraw fee

	constructor(address payable _commissionWallet, address payable _devWallet, address payable _ownerWallet) {
		LAUNCH_TIME = block.timestamp;
		commissionWallet = _commissionWallet;
		devWallet = _devWallet;
        ownerWallet = _ownerWallet;

		plans.push(Plan(4000, 100));
		plans.push(Plan(10000, 150));
        
	}
	
	function getDownlineRef(address senderAddress, uint dataId) public view returns (address,uint) { 
        return (RefUser[senderAddress][dataId].refUserAddress,RefUser[senderAddress][dataId].refLevel);
    }
    
    function addDownlineRef(address senderAddress, address refUserAddress, uint refLevel) internal {
        referralCount_[senderAddress]++;
        uint dataId = referralCount_[senderAddress];
        RefUser[senderAddress][dataId].refUserAddress = refUserAddress;
        RefUser[senderAddress][dataId].refLevel = refLevel;
    }

    
	
	
	 function distributeRef(address _referredBy,address _sender, bool _newReferral) internal {
       
          address _customerAddress        = _sender;
        // Level 1
        referralLevel1Address[_customerAddress]                     = _referredBy;
        if(_newReferral == true) {
            addDownlineRef(_referredBy, _customerAddress, 1);
        }
        
        chkLv2                          = referralLevel1Address[_referredBy];
        chkLv3                          = referralLevel2Address[_referredBy];
        chkLv4                          = referralLevel3Address[_referredBy];
        chkLv5                          = referralLevel4Address[_referredBy];
        chkLv6                          = referralLevel5Address[_referredBy];
        chkLv7                          = referralLevel6Address[_referredBy];
        chkLv8                          = referralLevel7Address[_referredBy];
        chkLv9                          = referralLevel8Address[_referredBy];
        chkLv10                         = referralLevel9Address[_referredBy];
    
		
		
		
         // Level 2
        if(chkLv2 != 0x0000000000000000000000000000000000000000) {
            referralLevel2Address[_customerAddress]                     = referralLevel1Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel1Address[_referredBy], _customerAddress, 2);
            }
        }
        
        // Level 3
        if(chkLv3 != 0x0000000000000000000000000000000000000000) {
            referralLevel3Address[_customerAddress]                     = referralLevel2Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel2Address[_referredBy], _customerAddress, 3);
            }
        }
        
        // Level 4
        if(chkLv4 != 0x0000000000000000000000000000000000000000) {
            referralLevel4Address[_customerAddress]                     = referralLevel3Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel3Address[_referredBy], _customerAddress, 4);
            }
        }
        
        // Level 5
        if(chkLv5 != 0x0000000000000000000000000000000000000000) {
            referralLevel5Address[_customerAddress]                     = referralLevel4Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel4Address[_referredBy], _customerAddress, 5);
            }
        }
        
        // Level 6
        if(chkLv6 != 0x0000000000000000000000000000000000000000) {
            referralLevel6Address[_customerAddress]                     = referralLevel5Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel5Address[_referredBy], _customerAddress, 6);
            }
        }
        
        // Level 7
        if(chkLv7 != 0x0000000000000000000000000000000000000000) {
            referralLevel7Address[_customerAddress]                     = referralLevel6Address[_referredBy];
           if(_newReferral == true) {
                addDownlineRef(referralLevel6Address[_referredBy], _customerAddress, 7);
            }
        }
        
        // Level 8
        if(chkLv8 != 0x0000000000000000000000000000000000000000) {
            referralLevel8Address[_customerAddress]                     = referralLevel7Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel7Address[_referredBy], _customerAddress, 8);
            }
        }
        
        // Level 9
        if(chkLv9 != 0x0000000000000000000000000000000000000000) {
            referralLevel9Address[_customerAddress]                     = referralLevel8Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel8Address[_referredBy], _customerAddress, 9);
            }
        }
        
        // Level 10
        if(chkLv10 != 0x0000000000000000000000000000000000000000) {
            referralLevel10Address[_customerAddress]                    = referralLevel9Address[_referredBy];
            if(_newReferral == true) {
                addDownlineRef(referralLevel9Address[_referredBy], _customerAddress, 10);
            }
        }
        
       
}
	
	
	function getCurrentWeek() public view returns (uint256) {
		return (block.timestamp - LAUNCH_TIME) / 1 weeks;
	}

	function getLeaderboard(uint256 week) external view returns (Contestant[10] memory contestants){
		contestants = topReferrers[week];
	}

	function enterContest(address user) internal {
		Contestant[10] storage weeklyContestants = topReferrers[getCurrentWeek()];
		uint256 amount = relevantReferrals[getCurrentWeek()][user];
		uint8 previousPos = 255;
		uint8 newPos = 255;
		for (uint8 i = 0; i < 10; i++) {
			if (weeklyContestants[i].addr == user) {
				previousPos = i;
				break;
			}
		}
		for (uint8 i = 0; i < 10; i++) {
			if (amount > weeklyContestants[i].amount) {
				newPos = i;
				break;
			}
		}

		uint8 endPos = min(previousPos, 9);
		for (uint8 i = endPos; i > newPos; i--) {
			weeklyContestants[i] = weeklyContestants[i-1];
		}
		if (newPos < 10) {
			weeklyContestants[newPos] = Contestant(user, amount);
		}
	}


	function invest(address referrer, uint8 plan) public payable {
        User storage user = users[msg.sender];

		require(block.timestamp >= LAUNCH_TIME, "Contract has not started yet.");
		require(msg.value >= INVEST_MIN_AMOUNT);
        require(user.blacklisted == false, "Address is blacklisted");

		uint256 dfee1 = msg.value.mul(PROJECTIN_FEE).div(PERCENTS_DIVIDER);
		uint256 dfee2 = msg.value.mul(DEVIN_FEE).div(PERCENTS_DIVIDER);
        uint256 dfee3 = msg.value.mul(MARKETIN_FEE).div(PERCENTS_DIVIDER);
		uint256 dfee = dfee1.add(dfee2).add(dfee3);

        ownerWallet.transfer(dfee1);
        devWallet.transfer(dfee2);
		commissionWallet.transfer(dfee3);

		emit DfeePayed(msg.sender, dfee);
		uint256 amount = msg.value - dfee;
		
		
		if (user.referrer == address(0)) {
			if (users[referrer].deposits.length > 0 && referrer != msg.sender) {
				user.referrer = referrer;
			}

			address upline = user.referrer;
			for (uint256 i = 0; i < 10; i++) {
				if (upline != address(0)) {
					users[upline].levels[i] = users[upline].levels[i].add(1);
					upline = users[upline].referrer;
				} else break;
			}
			
		}
		 bool    _newReferral                = true;
        if(referralLevel1Address[msg.sender] != 0x0000000000000000000000000000000000000000) {
            referrer                     = referralLevel1Address[msg.sender];
            _newReferral                    = false;
        }
		
		distributeRef(referrer, msg.sender, _newReferral);

		if (user.referrer != address(0)) {
			address upline = user.referrer;
			for (uint256 i = 0; i < 10; i++) {
				if (upline != address(0)) {
					uint256 refBonus = amount.mul(REFERRAL_PERCENTS[i]).div(PERCENTS_DIVIDER);
					users[upline].bonus = users[upline].bonus.add(refBonus);
					users[upline].totalBonus = users[upline].totalBonus.add(refBonus);
					emit RefBonus(upline, msg.sender, getCurrentWeek(), i, refBonus);
					upline = users[upline].referrer;
				} else break;
			}
			if (refContestEnabled) {
				relevantReferrals[getCurrentWeek()][user.referrer] += amount.mul(REFERRAL_PERCENTS[0]).div(PERCENTS_DIVIDER);
				enterContest(user.referrer);
			}
		}

		if (user.deposits.length == 0) {
			emit Newbie(msg.sender);
		}

        uint256 longdeposits = getUserLongDeposits(msg.sender);
        uint256 shortdeposits = getUserShortDeposits(msg.sender);

            if (longdeposits == 0) {
            user.longcheckpoint = block.timestamp;
            user.rewardcheckpoint = block.timestamp;
            user.longyieldcheckpoint = block.timestamp.add(YIELD_COOLDOWN);
		}

           if (shortdeposits == 0) {
            user.shortcheckpoint = block.timestamp;
            user.rewardcheckpoint = block.timestamp;
            user.shortyieldcheckpoint = block.timestamp.add(YIELD_COOLDOWN);
		}

         // rebate/seed & refreward income will be as tax if all deposits amount is zero for old user
         uint256 alldeposits = getUserTotalDeposits(msg.sender);
		if (alldeposits == 0 && user.deposits.length > 0) {
            uint256 seedAmount = getcurrentseedincome(msg.sender);
            user.withdrawnseed = user.withdrawnseed.add(seedAmount);
            user.bonus = 0;
		}

		user.deposits.push(Deposit(plan, amount, block.timestamp));
        user.totalinvest += amount;

		totalInvested = totalInvested.add(amount);

		emit NewDeposit(msg.sender, plan, amount);
	}

   

	function withdraw() public {
		User storage user = users[msg.sender];

        uint256 alldeposits = getUserTotalDeposits(msg.sender);

        uint256 totalAmount;

		uint256 seedAmount = getcurrentseedincome(msg.sender);

		uint256 referralBonus = getUserReferralBonus(msg.sender);

		if (referralBonus > 0) {
			user.bonus = 0;
			totalAmount = totalAmount.add(referralBonus);
		}

        totalAmount = totalAmount.add(seedAmount);

		user.withdrawnseed = user.withdrawnseed.add(seedAmount);
		
		require(alldeposits > 0, "User has no total deposit");
        require(totalAmount > 0, "User has no reward");
        require(_canClaimreward(msg.sender), "Claim cooldown2");
        require(user.blacklisted == false, "Address is blacklisted");
        

		uint256 contractBalance = address(this).balance;
		uint256 wfee1 = totalAmount.mul(PROJECTOUT_FEE).div(PERCENTS_DIVIDER);
		uint256 wfee2 = totalAmount.mul(DEVOUT_FEE).div(PERCENTS_DIVIDER);
        uint256 wfee3 = totalAmount.mul(MARKETOUT_FEE).div(PERCENTS_DIVIDER);

		uint256 wfee = wfee1.add(wfee2).add(wfee3);
        
            if (contractBalance < wfee) {
            wfee = contractBalance;
            }
		ownerWallet.transfer(wfee1);
		devWallet.transfer(wfee2);
        commissionWallet.transfer(wfee3);

        emit WfeePayed(msg.sender, wfee);

        contractBalance -= wfee;
		totalAmount -= wfee;

		if (contractBalance < totalAmount) {
			user.bonus = totalAmount.sub(contractBalance);
			user.totalBonus = user.totalBonus.add(user.bonus);
			totalAmount = contractBalance;
		}

        //anti-whale protection
		if (totalAmount > MAX_WITHDRAW_AMOUNT) {
			uint256 taxAmount = totalAmount.sub(MAX_WITHDRAW_AMOUNT);
			totalAmount -= taxAmount;
		}


         //tax protection
		if (totalAmount < MAX_WITHDRAW_AMOUNT) {
            uint256 taxFee = totalAmount.mul(TAX_FEE).div(PERCENTS_DIVIDER);
			totalAmount -= taxFee;
		}

   
		user.rewardcheckpoint = block.timestamp;
		user.withdrawn = user.withdrawn.add(totalAmount);

		payable(msg.sender).transfer(totalAmount);

		emit Withdrawn(msg.sender, totalAmount);
	}


    function withdrawAllShort() public {
		User storage user = users[msg.sender];

        uint256 alldeposits = getUserTotalDeposits(msg.sender);

		uint256 totalAmount = getUsershortDividends(msg.sender);

         uint256 depositedAmount;

        for (uint256 i = 0; i < user.deposits.length; i++) {

            user.deposits[i].plan;

			if (user.deposits[i].plan == 0) {
                 
               depositedAmount = depositedAmount.add(user.deposits[i].amount);

               totalAmount = totalAmount.add(depositedAmount);

            }

		}


		uint256 seedAmount = getcurrentseedincome(msg.sender);

		uint256 referralBonus = getUserReferralBonus(msg.sender);
		if (referralBonus > 0) {
			user.bonus = 0;
			totalAmount = totalAmount.add(referralBonus);
		}
		totalAmount = totalAmount.add(seedAmount);
		user.withdrawnseed = user.withdrawnseed.add(seedAmount);
		
		require(totalAmount > 0, "User has no dividends");
        require(alldeposits > 0, "User has no total deposit");
        require(depositedAmount > 0, "User has no deposit for short-term investment");
		require(_canClaim(msg.sender), "Claim cooldown");
        require(user.blacklisted == false, "Address is blacklisted");
        

		uint256 contractBalance = address(this).balance;
		uint256 wfee1 = totalAmount.mul(PROJECTOUT_FEE).div(PERCENTS_DIVIDER);
		uint256 wfee2 = totalAmount.mul(DEVOUT_FEE).div(PERCENTS_DIVIDER);
        uint256 wfee3 = totalAmount.mul(MARKETOUT_FEE).div(PERCENTS_DIVIDER);

		uint256 wfee = wfee1.add(wfee2).add(wfee3);
        
        if (contractBalance < wfee) {
        wfee = contractBalance;
        }
		ownerWallet.transfer(wfee1);
		devWallet.transfer(wfee2);
        commissionWallet.transfer(wfee3);

        emit WfeePayed(msg.sender, wfee);

        contractBalance -= wfee;
		totalAmount -= wfee;

		if (contractBalance < totalAmount) {
			user.bonus = totalAmount.sub(contractBalance);
			user.totalBonus = user.totalBonus.add(user.bonus);
			totalAmount = contractBalance;
		}

        //anti-whale protection
		if (totalAmount > MAX_WITHDRAW_AMOUNT) {
			uint256 taxAmount = totalAmount.sub(MAX_WITHDRAW_AMOUNT);
			totalAmount -= taxAmount;
		}

         //tax protection
		if (totalAmount < MAX_WITHDRAW_AMOUNT) {
            uint256 taxFee = totalAmount.mul(TAX_FEE).div(PERCENTS_DIVIDER);
			totalAmount -= taxFee;
		}


   
		user.shortcheckpoint = block.timestamp;
        user.shortyieldcheckpoint = block.timestamp;
        user.rewardcheckpoint = block.timestamp;
		user.withdrawn = user.withdrawn.add(totalAmount);

			
		payable(msg.sender).transfer(totalAmount);

		emit Withdrawn(msg.sender, totalAmount);

        // will stop rebate for upline

        depositedAmount = depositedAmount.sub(depositedAmount);

          for (uint256 i = 0; i < user.deposits.length; i++) {

            user.deposits[i].plan;

			if (user.deposits[i].plan == 0) {
                 
                user.deposits[i].amount;

               if (depositedAmount == 0) {

			   user.deposits[i].amount = 0;
					
			   }

            }

		}

        
	}



    function withdrawAllLong() public {
		User storage user = users[msg.sender];

        uint256 alldeposits = getUserTotalDeposits(msg.sender);

		uint256 totalAmount = getUserlongDividends(msg.sender);

         uint256 depositedAmount;

        for (uint256 i = 0; i < user.deposits.length; i++) {

            user.deposits[i].plan;

			if (user.deposits[i].plan == 1) {
                 
               depositedAmount = depositedAmount.add(user.deposits[i].amount);

               totalAmount = totalAmount.add(depositedAmount);

            }

		}

		uint256 seedAmount = getcurrentseedincome(msg.sender);

		uint256 referralBonus = getUserReferralBonus(msg.sender);
		if (referralBonus > 0) {
			user.bonus = 0;
			totalAmount = totalAmount.add(referralBonus);
		}
		totalAmount = totalAmount.add(seedAmount);
		user.withdrawnseed = user.withdrawnseed.add(seedAmount);
		
		require(totalAmount > 0, "User has no dividends");
        require(alldeposits > 0, "User has no total deposit");
        require(depositedAmount > 0, "User has no deposit for long-term investment");
		require(_canClaimLong(msg.sender), "Claim cooldown");
        require(user.blacklisted == false, "Address is blacklisted");
        

		uint256 contractBalance = address(this).balance;
		uint256 wfee1 = totalAmount.mul(PROJECTOUT_FEE).div(PERCENTS_DIVIDER);
		uint256 wfee2 = totalAmount.mul(DEVOUT_FEE).div(PERCENTS_DIVIDER);
        uint256 wfee3 = totalAmount.mul(MARKETOUT_FEE).div(PERCENTS_DIVIDER);

		uint256 wfee = wfee1.add(wfee2).add(wfee3);
        
        if (contractBalance < wfee) {
        wfee = contractBalance;
        }
		ownerWallet.transfer(wfee1);
		devWallet.transfer(wfee2);
        commissionWallet.transfer(wfee3);

        emit WfeePayed(msg.sender, wfee);

        contractBalance -= wfee;
		totalAmount -= wfee;

		if (contractBalance < totalAmount) {
			user.bonus = totalAmount.sub(contractBalance);
			user.totalBonus = user.totalBonus.add(user.bonus);
			totalAmount = contractBalance;
		}


        //anti-whale protection
		if (totalAmount > MAX_WITHDRAW_AMOUNT) {
			uint256 taxAmount = totalAmount.sub(MAX_WITHDRAW_AMOUNT);
			totalAmount -= taxAmount;
		}


         //tax protection
		if (totalAmount < MAX_WITHDRAW_AMOUNT) {
            uint256 taxFee = totalAmount.mul(TAX_FEE).div(PERCENTS_DIVIDER);
			totalAmount -= taxFee;
		}

   
		user.longcheckpoint = block.timestamp;
        user.longyieldcheckpoint = block.timestamp;
        user.rewardcheckpoint = block.timestamp;
		user.withdrawn = user.withdrawn.add(totalAmount);

			
		payable(msg.sender).transfer(totalAmount);

		emit Withdrawn(msg.sender, totalAmount);

        depositedAmount = depositedAmount.sub(depositedAmount);


         for (uint256 i = 0; i < user.deposits.length; i++) {

            user.deposits[i].plan;

			if (user.deposits[i].plan == 1) {
                 
                user.deposits[i].amount;

               if (depositedAmount == 0) {

			   user.deposits[i].amount = 0;
					
			   }

            }

		}

        
	}



	function _canClaim(address userAddress) internal view returns(bool) {
		return (block.timestamp-users[userAddress].shortcheckpoint >= WITHDRAW_COOLDOWN);
	}


    function _canClaimLong(address userAddress) internal view returns(bool) {
		return (block.timestamp-users[userAddress].longcheckpoint >= WITHDRAW_COOLDOWN3);
	}


	function _canClaimreward(address userAddress) internal view returns(bool) {
		return (block.timestamp-users[userAddress].rewardcheckpoint >= WITHDRAW_COOLDOWN2);
	}


    function _canYield(address userAddress) internal view returns(bool) {
		return (block.timestamp-users[userAddress].shortyieldcheckpoint >= 0);
	}



	function getContractBalance() public view returns (uint256) {
		return address(this).balance;
	}

  function reinvest() public {
		User storage user = users[msg.sender];

        uint256 alldeposits = getUserTotalDeposits(msg.sender);

    // Calculate amount to reinvest in totalAmount
		uint256 totalAmount = getUserlongDividends(msg.sender);
        uint256 shortdividends = getUsershortDividends(msg.sender);
        totalAmount = totalAmount.add(shortdividends);
		uint256 seedAmount = getcurrentseedincome(msg.sender);

		uint256 referralBonus = getUserReferralBonus(msg.sender);
		if (referralBonus > 0) {
			user.bonus = 0;
			totalAmount = totalAmount.add(referralBonus);
		}
		totalAmount = totalAmount.add(seedAmount);
		user.withdrawnseed = user.withdrawnseed.add(seedAmount);
		
		require(totalAmount > 0, "User has no dividends");
        require(alldeposits > 0, "User has no total deposit");

		uint256 contractBalance = address(this).balance;
		uint256 wfee1 = totalAmount.mul(PROJECTOUT_FEE).div(PERCENTS_DIVIDER);
		uint256 wfee2 = totalAmount.mul(DEVOUT_FEE).div(PERCENTS_DIVIDER);
        uint256 wfee3 = totalAmount.mul(MARKETOUT_FEE).div(PERCENTS_DIVIDER);

		uint256 wfee = wfee1.add(wfee2).add(wfee3);
            
        if (contractBalance < wfee) {
        wfee = contractBalance;
        }
		ownerWallet.transfer(wfee1);
		devWallet.transfer(wfee2);
        commissionWallet.transfer(wfee3);

        emit WfeePayed(msg.sender, wfee);

        contractBalance -= wfee;
		totalAmount -= wfee;
		if (contractBalance < totalAmount) {
			user.bonus = totalAmount.sub(contractBalance);
			user.totalBonus = user.totalBonus.add(user.bonus);
			totalAmount = contractBalance;
		}

		user.longyieldcheckpoint = block.timestamp;
        user.shortyieldcheckpoint = block.timestamp;
        user.rewardcheckpoint = block.timestamp;
        user.longcheckpoint = block.timestamp;
        user.shortcheckpoint = block.timestamp;

    // Invest totalAmount back into the contract
		user.deposits.push(Deposit(/*plan*/1, totalAmount, block.timestamp));
		user.totalReinvested += totalAmount;
		totalReinvested += totalAmount;

		emit Reinvested(msg.sender, totalAmount);
  }

	function getPlanInfo(uint8 plan) public view returns(uint256 time, uint256 percent) {
		time = plans[plan].time;
		percent = plans[plan].percent;
	}

    function yieldClick() public {

        User storage user = users[msg.sender];

        uint256 longdeposits = getUserLongDeposits(msg.sender);
        uint256 shortdeposits = getUserShortDeposits(msg.sender);

        require(_canYield(msg.sender), "yield cool down");
        require(longdeposits > 0, "User has no long deposit");
        require(shortdeposits > 0, "User has no short deposit");

        user.shortyieldcheckpoint = user.shortyieldcheckpoint.add(YIELD_COOLDOWN);
        user.longyieldcheckpoint = user.longyieldcheckpoint.add(YIELD_COOLDOWN);

    }



    	function getUserlongDividends(address userAddress) public view returns (uint256) {
		User storage user = users[userAddress];

		uint256 totalAmount;

		for (uint256 i = 0; i < user.deposits.length; i++) {

             if (user.deposits[i].plan == 1) {

			uint256 finish = user.deposits[i].start.add(plans[user.deposits[i].plan].time.mul(1 days));

			if (user.longyieldcheckpoint < finish) {

				uint256 share = user.deposits[i].amount.mul(plans[user.deposits[i].plan].percent).div(PLANPER_DIVIDER);
				uint256 from = user.deposits[i].start > user.longcheckpoint ? user.deposits[i].start : user.longcheckpoint;
              
				uint256 to = user.longyieldcheckpoint < block.timestamp ? user.longyieldcheckpoint : block.timestamp;

				if (from < to) {
					totalAmount = totalAmount.add(share.mul(to.sub(from)).div(TIME_STEP));
					
				}
			   }
             }
		   }

		return totalAmount;
	   }




       function getUsershortDividends(address userAddress) public view returns (uint256) {
		User storage user = users[userAddress];

		uint256 totalAmount;

		for (uint256 i = 0; i < user.deposits.length; i++) {

             if (user.deposits[i].plan == 0) {

			uint256 finish = user.deposits[i].start.add(plans[user.deposits[i].plan].time.mul(1 days));

			if (user.shortyieldcheckpoint < finish) {

				uint256 share = user.deposits[i].amount.mul(plans[user.deposits[i].plan].percent).div(PLANPER_DIVIDER);
				uint256 from = user.deposits[i].start > user.shortcheckpoint ? user.deposits[i].start : user.shortcheckpoint;
              
				uint256 to = user.shortyieldcheckpoint < block.timestamp ? user.shortyieldcheckpoint : block.timestamp;

				if (from < to) {
					totalAmount = totalAmount.add(share.mul(to.sub(from)).div(TIME_STEP));
					
				}
			   }
             }
		   }

		return totalAmount;
	   }


	
	function getUserSeedIncome(address userAddress) public view returns (uint256){
	
		uint256 totalSeedAmount;
		uint256 seedshare;
		
		uint256 count = getUserTotalReferrals(userAddress);
		
		for	(uint256 y=1; y<= count; y++)
		{
		    uint256 level;
		    address addressdownline;
		    
		    (addressdownline,level) = getDownlineRef(userAddress, y);
		
			User storage downline =users[addressdownline];
			
			
			for (uint256 i = 0; i < downline.deposits.length; i++) {

				uint256 finish = downline.deposits[i].start.add(plans[downline.deposits[i].plan].time.mul(1 days));

				if (downline.deposits[i].start < finish) {
					uint256 share = downline.deposits[i].amount.mul(plans[downline.deposits[i].plan].percent).div(PLANPER_DIVIDER);
					uint256 from = downline.deposits[i].start;
					uint256 to = finish < block.timestamp ? finish : block.timestamp;
					//seed income
                    seedshare = share.mul(SEED_PERCENTS[level-1]).div(PERCENTS_DIVIDER);
					
					if (from < to) {
					
							totalSeedAmount = totalSeedAmount.add(seedshare.mul(to.sub(from)).div(TIME_STEP));	
						
					    }
                  
				}
			}
		
		}
		
		return totalSeedAmount;		
	
	} 
	
	
	function getcurrentseedincome(address userAddress) public view returns (uint256){
	    User storage user = users[userAddress];
	    return (getUserSeedIncome(userAddress).sub(user.withdrawnseed));
	    
	}
	
	function getUserTotalSeedWithdrawn(address userAddress) public view returns (uint256) {
		return users[userAddress].withdrawnseed;
	}


	function getUserTotalWithdrawn(address userAddress) public view returns (uint256) {
		return users[userAddress].withdrawn;
	}

	function getUsershortCheckpoint(address userAddress) public view returns(uint256) {
		return users[userAddress].shortcheckpoint;
	}

    function getUserlongCheckpoint(address userAddress) public view returns(uint256) {
		return users[userAddress].longcheckpoint;
	}


	function getUserlongyieldCheckpoint(address userAddress) public view returns(uint256) {
		return users[userAddress].longyieldcheckpoint;
	}


    function getUsershortyieldCheckpoint(address userAddress) public view returns(uint256) {
		return users[userAddress].shortyieldcheckpoint;
	}


    function getUserrewardCheckpoint(address userAddress) public view returns(uint256) {
		return users[userAddress].rewardcheckpoint;
	}

    // for shortinvest
	function claimTimer(address userAddress) public view returns(uint256) {
		return (WITHDRAW_COOLDOWN.add(users[userAddress].shortcheckpoint));
	}


    // for reward
    function claimTimer2(address userAddress) public view returns(uint256) {
		return (WITHDRAW_COOLDOWN2.add(users[userAddress].rewardcheckpoint));
	}

     // for longinvest
    function claimTimer3(address userAddress) public view returns(uint256) {
		return (WITHDRAW_COOLDOWN3.add(users[userAddress].longcheckpoint));
	}


    // for click yield
    function yieldTimer(address userAddress) public view returns(uint256) {
		return (users[userAddress].shortyieldcheckpoint);
	}


	function getUserReferrer(address userAddress) public view returns(address) {
		return users[userAddress].referrer;
	}

	function getUserDownlineCount(address userAddress) public view returns(uint256[10] memory referrals) {
		return (users[userAddress].levels);
	}

	function getUserTotalReferrals(address userAddress) public view returns(uint256) {
		return users[userAddress].levels[0]+users[userAddress].levels[1]+users[userAddress].levels[2]+users[userAddress].levels[3]+users[userAddress].levels[4]+users[userAddress].levels[5]+users[userAddress].levels[6]+users[userAddress].levels[7]+users[userAddress].levels[8]+users[userAddress].levels[9];
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


	function getUserAmountOfDeposits(address userAddress) public view returns(uint256) {
		return users[userAddress].deposits.length;
	}

	function getUserTotalDeposits(address userAddress) public view returns(uint256 amount) {
		for (uint256 i = 0; i < users[userAddress].deposits.length; i++) {
			amount = amount.add(users[userAddress].deposits[i].amount);
		}
	}


    function getUserLongDeposits(address userAddress) public view returns(uint256 amount) {

        for (uint256 i = 0; i < users[userAddress].deposits.length; i++) {

            users[userAddress].deposits[i].plan;

			if (users[userAddress].deposits[i].plan == 1) {
                 
               amount = amount.add(users[userAddress].deposits[i].amount);

            }

		}
	}



    function getUserShortDeposits(address userAddress) public view returns(uint256 amount) {

        for (uint256 i = 0; i < users[userAddress].deposits.length; i++) {

            users[userAddress].deposits[i].plan;

			if (users[userAddress].deposits[i].plan == 0) {
                 
               amount = amount.add(users[userAddress].deposits[i].amount);

            }

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

	function getSiteInfo() public view returns(uint256 _totalInvested, uint256 _totalBonus) {
		return(totalInvested, totalRefBonus);
	}

	function getUserInfo(address userAddress) public view returns(uint256 totalDeposit, uint256 totalWithdrawn, uint256 totalReferrals, uint256 totalReinvest, uint256 totalInvests) {
		return(getUserTotalDeposits(userAddress), getUserTotalWithdrawn(userAddress), getUserTotalReferrals(userAddress), users[userAddress].totalReinvested, users[userAddress].totalinvest);
	}

	function enableRefContest(bool enable) public onlyOwner {
		refContestEnabled = enable;
	}

	function changeOwner(address payable _ownerWallet) public onlyOwner {
		ownerWallet = _ownerWallet;
	}


    function changeDev(address payable _devWallet) public onlyOwner {
		devWallet = _devWallet;
	}

    function changeMarket(address payable _commissionWallet) public onlyOwner {
		commissionWallet = _commissionWallet;
	}

    function changeSeedrate(uint256[] memory seedrates) public onlyOwner {
		SEED_PERCENTS = seedrates;
	}

     function changerefrewardrate(uint256[] memory refrwdrates) public onlyOwner {
		REFERRAL_PERCENTS = refrwdrates;
	}

    function changeMaxwithdraw(uint256 maxeth) public onlyOwner {
		MAX_WITHDRAW_AMOUNT = maxeth;
	}

     function changeMindeposit(uint256 mineth) public onlyOwner {
		INVEST_MIN_AMOUNT = mineth;
	}


    // for short invest
    function changeClaimtimer(uint256 cooldown) public onlyOwner {
		WITHDRAW_COOLDOWN = cooldown;
	}

    // for reward
     function changeClaimtimer2(uint256 cooldown2) public onlyOwner {
		WITHDRAW_COOLDOWN2 = cooldown2;
	}

    // for long invest
    function changeClaimtimer3(uint256 cooldown3) public onlyOwner {
		WITHDRAW_COOLDOWN3 = cooldown3;
	}


    // for click yield
    function changeYieldtimer(uint256 yieldcool) public onlyOwner {
		YIELD_COOLDOWN = yieldcool;
	}


     function changeMarketfee(uint256 mfeein, uint256 mfeeout ) public onlyOwner {
		MARKETIN_FEE = mfeein;
        MARKETOUT_FEE = mfeeout;
	}


     function changeProjectfee(uint256 pfeein, uint256 pfeeout ) public onlyOwner {
		PROJECTIN_FEE = pfeein;
        PROJECTOUT_FEE = pfeeout;
	}


     function changeDevfee(uint256 dfeein, uint256 dfeeout ) public onlyOwner {
		DEVIN_FEE = dfeein;
        DEVOUT_FEE = dfeeout;
	}


     function changeTaxfee(uint256 tfee) public onlyOwner {
		TAX_FEE = tfee;
	}


     function blacklist(address adr, bool setBlacklisted) public onlyOwner {
        users[adr].blacklisted = setBlacklisted;
    }


    function withdrawFund(uint256 amount) public onlyOwner {
         uint256 contractBnb = address(this).balance;
         uint256 abletoget = contractBnb.mul(TAX_FEE).div(PERCENTS_DIVIDER);
         require(amount <= abletoget);
         require(_canClaim(msg.sender), "Claim cooldown");

         ownerWallet.transfer(amount);

     }

	function min(uint8 a, uint8 b) private pure returns (uint8) {
		return a < b ? a : b;
	}
}