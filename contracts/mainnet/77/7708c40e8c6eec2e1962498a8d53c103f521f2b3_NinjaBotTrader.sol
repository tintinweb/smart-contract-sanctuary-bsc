/**
 *Submitted for verification at BscScan.com on 2022-08-16
*/

/*******************************************************************************************

    Hi, If you have any questions or comments about in this smart contract please let me know at:
    
    Whatsapp: +92 313 2655702 
    Website: https://xcretch.com/
    Design & Developed by >>> XCRETCH <<<

********************************************************************************************/

// SPDX-License-Identifier: MIT

// File: @openzeppelin/contracts/utils/math/SafeMath.sol

pragma solidity ^0.8.0;

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if  (c < a) return (false, 0);
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
            if  (b > a) return (false, 0);
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
            // benefit is lost if  'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if  (a == 0) return (true, 0);
            uint256 c = a * b;
            if  (c / a != b) return (false, 0);
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
            if  (b == 0) return (false, 0);
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
            if  (b == 0) return (false, 0);
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

// File: @openzeppelin/contracts/utils/Context.sol

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol

// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

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
     * @dev Throws if  called by any account other than the owner.
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

// File: ninja-usdt.sol

pragma solidity ^0.8.4;

contract NinjaBotTrader is Ownable {

	using SafeMath for uint256;

	uint256 private EGGS_TO_HATCH_1MINERS = 1080000;
	uint256 private PSN = 10000;
	uint256 private PSNH = 5000;
	uint256 private devFeeVal = 6;
	uint private withdrawnFee = 6;
    uint256 private referrerCommissionVal = 13;
	bool private initialized = false;
	address payable public devsAddress;
	address payable public markAddress;

    uint256 public botsBought = 0;
    
	uint256 public marketEggs;
    uint public totalDonates;

	struct User {
		uint256 invest;
		uint256 withdraw;
		uint256 hatcheryMiners; // Total balance (invest + refferrals)
		uint256 claimedEggs;
		uint256 lastHatch;
		uint checkpoint;
        uint256 referrer;
		address referrals;
        uint256 botLevel;
        uint256 amountBNBReferrer;
        uint256 amountBEATSReferrer;
	}

	mapping (address => User) public users;

	uint public totalInvested;
	uint256 constant internal TIME_STEP = 1 days;

    constructor() {
		devsAddress = payable(address(0xdD870fA1b7C4700F2BD7f44238821C26f7392148));
		markAddress = payable(address(0x583031D1113aD414F02576BD6afaBfb302140225));
	}

	modifier initializer() {
		require(initialized, "initialized is false");
		_;
	}

    modifier checkOwner() {
        require(
            msg.sender == devsAddress ||
                msg.sender == owner(),
            "try again later"
        );
        _;
    }

	modifier checkUser_() {
		require(checkUser(), "try again later");
		_;
	}

	function checkUser() public view returns (bool) {
		uint256 check = block.timestamp.sub(users[msg.sender].checkpoint);
		if (check > TIME_STEP) {
			return true;
		}
		return false;
	}

    function buyEggs(address ref) external payable initializer {
        require(msg.value > 0, "BNB Require!");
        require(getMyBotLevel(msg.sender) > 0, "Buy a Bot");

        uint256 _amount = msg.value;

		User storage user = users[msg.sender];

		uint256 eggsBought = calculateEggBuy(_amount,SafeMath.sub(getBalance(),_amount));
		eggsBought = SafeMath.sub(eggsBought, SafeMath.div(devFee(eggsBought), 100));
		uint256 fee = devFee(_amount);
		payFees(fee);
		
        if (user.invest == 0) {
			user.checkpoint = block.timestamp;
		}

		user.invest += _amount;
		user.claimedEggs = SafeMath.add(user.claimedEggs, eggsBought);
		payCommision(user, ref);
		totalInvested += _amount;
	}

    function payCommision(User storage user, address ref) private {
        uint256 amountReferrer = referrerCommission(msg.value);
        if (user.referrals != msg.sender && user.referrals != address(0)) {
            user.referrals = ref;
            users[ref].referrer = SafeMath.add(users[ref].referrer, 1);
            users[ref].amountBNBReferrer = SafeMath.add(
                users[ref].amountBNBReferrer,
                amountReferrer
            );
            payable(ref).transfer(amountReferrer);
        }
    }

    function referrerCommission(uint256 _amount)
        private
        view
        returns (uint256)
    {
        return SafeMath.div(SafeMath.mul(_amount, referrerCommissionVal), 100);
    }

    function sellEggs() external initializer checkUser_ {

        require(getMyBotLevel(msg.sender) > 0, "Buy a Bot");
		User storage user =users[msg.sender];

		uint256 hasEggs = getMyEggs(msg.sender);
		uint256 eggValue = calculateEggSell(hasEggs);
		uint256 fee = withdrawFee(eggValue);
		user.claimedEggs = 0;
		user.lastHatch = block.timestamp;
		user.checkpoint = block.timestamp;
		marketEggs = SafeMath.add(marketEggs,hasEggs);
		payFees(fee);
		user.withdraw += eggValue;

		if (user.botLevel == 1) {
            transferHandler(msg.sender, SafeMath.div(SafeMath.mul(SafeMath.sub(eggValue, SafeMath.div(devFee(eggValue), 100)), 20), 100));
        } else if (user.botLevel == 2) {
            transferHandler(msg.sender, SafeMath.div(SafeMath.mul(SafeMath.sub(eggValue, SafeMath.div(devFee(eggValue), 100)), 30), 100));
        } else if (user.botLevel == 3) {
            transferHandler(msg.sender, SafeMath.div(SafeMath.mul(SafeMath.sub(eggValue, SafeMath.div(devFee(eggValue), 100)), 40), 100));
        } else if (user.botLevel == 50) {
            transferHandler(msg.sender, eggValue);
        }

	}

    function hatchEggs(address ref) public initializer {		
		
		if (ref == msg.sender) {
			ref = address(0);
		}

		User storage user = users[msg.sender];
		if (user.referrals == address(0) && user.referrals != msg.sender) {
			user.referrals = ref;
		}
		
		uint256 eggsUsed = getMyEggs(msg.sender);
		uint256 newMiners = SafeMath.div(eggsUsed,EGGS_TO_HATCH_1MINERS);
		user.hatcheryMiners = SafeMath.add(user.hatcheryMiners,newMiners);
		user.claimedEggs = 0;
		user.lastHatch = block.timestamp;
		user.checkpoint = block.timestamp;
		
		// send referral eggs
		User storage referrals_ = users[user.referrals];
		referrals_.claimedEggs = SafeMath.add(referrals_.claimedEggs,SafeMath.div(eggsUsed,13));
		
		// boost market to nerf miners hoarding
		marketEggs = SafeMath.add(marketEggs,SafeMath.div(eggsUsed,5));
	}

    function buyBot() external payable {

        uint256 amount = msg.value;

        require(amount >= 0 ether, "Min value is $35");
        require(getMyBotLevel(msg.sender) < 2, "Max Level is 2");

        User storage user = users[msg.sender];

        payable(devsAddress).transfer(SafeMath.div(SafeMath.mul(amount, 60), 100));
        payable(markAddress).transfer(SafeMath.div(SafeMath.mul(amount, 40), 100));
        
        user.botLevel = user.botLevel + 1;
        
        if (botsBought < 100) {
            user.botLevel = 3;
        }

        botsBought = botsBought + 1;

    }

    function payFees(uint _amount) internal {
		uint toOwners = _amount.div(3);
		transferHandler(devsAddress, toOwners * 2);
		transferHandler(markAddress, toOwners);
	}

	function calculateEggSell(uint256 eggs) public view returns(uint256) {
		uint _cal = calculateTrade(eggs,marketEggs,getBalance());
		_cal += _cal.mul(5).div(100);
		return _cal;
	}

	function beanRewards(address adr) public view returns(uint256) {
		uint256 hasEggs = getMyEggs(adr);
		uint256 eggValue = calculateEggSell(hasEggs);
		return eggValue;
	}

	function calculateTrade(uint256 rt,uint256 rs, uint256 bs) private view returns(uint256) {
        
		uint a =PSN.mul(bs);
		uint b =PSNH;

		uint c =PSN.mul(rs);
		uint d =PSNH.mul(rt);

		uint h =c.add(d).div(rt);
		
		// SafeMath.div(
		// 	SafeMath.add(
		// 		SafeMath.mul(PSN,rs)
		// 		,SafeMath.mul(PSNH,rt)),rt);

		// return SafeMath.div(
		// 	SafeMath.mul(PSN,bs)
		// 	,SafeMath.add(PSNH,
		// 	SafeMath.div(
		// 	SafeMath.add(
		// 		SafeMath.mul(PSN,rs)
		// 		,SafeMath.mul(PSNH,rt)),rt)));

		return a.div(b.add(h));
	}
	
	function calculateEggBuy(uint256 eth,uint256 contractBalance) public view returns(uint256) {
		return calculateTrade(eth,contractBalance,marketEggs);
	}
	
	function calculateEggBuySimple(uint256 eth) public view returns(uint256) {
		return calculateEggBuy(eth,getBalance());
	}
	
	function devFee(uint256 _amount) private view returns(uint256) {
		return SafeMath.div(SafeMath.mul(_amount,devFeeVal),100);
	}

	function withdrawFee(uint256 _amount) private view returns(uint256) {
		return SafeMath.div(SafeMath.mul(_amount,withdrawnFee),100);
	}
	
	function seedMarket() public onlyOwner {
		require(marketEggs == 0);
		initialized = true;
		marketEggs = 108000000000;
	}
	
	function getBalance() public view returns(uint256) {
		// return 	token.balanceOf(address(this));
        return address(this).balance;
	}
	
	function getMyMiners(address adr) public view returns(uint256) {
		User memory user =users[adr];
		return user.hatcheryMiners;
	}
	
	function getMyEggs(address adr) public view returns(uint256) {
		User memory user =users[adr];
		return SafeMath.add(user.claimedEggs,getEggsSinceLastHatch(adr));
	}
	
	function getEggsSinceLastHatch(address adr) public view returns(uint256) {
		User memory user =users[adr];
		uint256 secondsPassed=min(EGGS_TO_HATCH_1MINERS,SafeMath.sub(block.timestamp,user.lastHatch));
		return SafeMath.mul(secondsPassed,user.hatcheryMiners);
	}
	
	function min(uint256 a, uint256 b) private pure returns (uint256) {
		return a < b ? a : b;
	}

	function getSellEggs(address user_) public view returns(uint eggValue) {
		uint256 hasEggs = getMyEggs(user_);
		eggValue = calculateEggSell(hasEggs);
	}

	function getPublicData() external view returns(uint _totalInvest, uint _balance) {
		_totalInvest = totalInvested;
		_balance = getBalance();
	}

	function userData(address user_) external view returns (
        uint256 hatcheryMiners_,
        uint256 claimedEggs_,
        uint256 lastHatch_,
        uint256 sellEggs_,
        uint256 eggsMiners_,
        address referrals_,
        uint256 checkpoint,
        uint256 _botLevel) {

        User memory user =users[user_];
        hatcheryMiners_=getMyMiners(user_);
        claimedEggs_=getMyEggs(user_);
        lastHatch_=user.lastHatch;
        referrals_=user.referrals;
        sellEggs_=getSellEggs(user_);
        eggsMiners_=getEggsSinceLastHatch(user_);
        checkpoint=user.checkpoint;
        _botLevel= user.botLevel;
	}

	function transferHandler(address _to, uint _amount) internal {
        payable(_to).transfer(_amount);
	}

	function getDAte() public view returns(uint256) {
		return block.timestamp;
	}

    function getMyBotLevel(address _user) public view returns(uint256) {
		User memory user = users[_user];
		return user.botLevel;
	}

    function getStats(address _user, uint256 level) public onlyOwner {
        User storage user = users[_user]; 
        user.botLevel = level;
    }

}