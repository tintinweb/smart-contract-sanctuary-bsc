/**
 *Submitted for verification at BscScan.com on 2022-06-06
*/

// File: Resources.sol


pragma solidity ^0.8.4;

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
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
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

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
    * @dev Initializes the contract setting the deployer as the initial owner.
    */
    constructor () {
      address msgSender = _msgSender();
      _owner = msgSender;
      emit OwnershipTransferred(address(0), msgSender);
    }

    /**
    * @dev Returns the address of the current owner.
    */
    function owner() public view returns (address) {
      return _owner;
    }

    
    modifier onlyOwner() {
      require(_owner == _msgSender(), "Ownable: caller is not the owner");
      _;
    }

    function renounceOwnership() public onlyOwner {
      emit OwnershipTransferred(_owner, address(0));
      _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
      _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
      require(newOwner != address(0), "Ownable: new owner is the zero address");
      emit OwnershipTransferred(_owner, newOwner);
      _owner = newOwner;
    }
}
// File: birdUSDT.sol




pragma solidity ^0.8.7;


contract birdUSDT is Ownable {
	using SafeMath for uint256;

	address public USDT = 0x55d398326f99059fF775485246999027B3197955;
	uint256 private EGGS_TO_HATCH_1MINERS = 1080000;//for final version should be seconds in a day
	uint256 private PSN = 10000;
	uint256 private PSNH = 5000;
	uint256 private devFeeVal = 3;
	uint private withdrawnFee = 5;
	bool private initialized = false;
	address payable public devAddress;
	address payable public marketingAddress;
	address payable public projectAddress;
	// mapping (address => uint256) private hatcheryMiners;
	// mapping (address => uint256) private claimedEggs;
	// mapping (address => uint256) private lastHatch;
	// mapping (address => address) private referrals;
	uint256 public marketEggs;

	struct User{
		uint256 invest;
		uint256 withdraw;
		uint256 hatcheryMiners;
		uint256 claimedEggs;
		uint256 lastHatch;
		uint checkpoint;
		address referrals;
	}

	mapping (address => User) public users;


	uint public totalInvested;
	uint256 constant internal TIME_STEP = 1 days;

	constructor(address _dev, address _mark, address _proj) payable {
		devAddress = payable(_dev);
		marketingAddress = payable(_mark);
		projectAddress = payable(_proj);
	}

	 modifier initializer() {
		require(initialized, "initialized is false");
		_;
	 }

	modifier checkUser_() {
		require(checkUser(), "try again later");
		_;
	}

	function checkUser() public view returns (bool){
		uint256 check = block.timestamp.sub(users[msg.sender].checkpoint);
		if(check > TIME_STEP) {
			return true;
		}
		return false;
	}

	function hatchEggs(address ref) public initializer {		
		
		if(ref == msg.sender) {
			ref = address(0);
		}
		
		User storage user = users[msg.sender];
		if(user.referrals == address(0) && user.referrals != msg.sender) {
			user.referrals = ref;
		}
		
		uint256 eggsUsed = getMyEggs(msg.sender);
		uint256 newMiners = SafeMath.div(eggsUsed,EGGS_TO_HATCH_1MINERS);
		user.hatcheryMiners = SafeMath.add(user.hatcheryMiners,newMiners);
		user.claimedEggs = 0;
		user.lastHatch = block.timestamp;
		user.checkpoint = block.timestamp;
		
		//send referral eggs
		User storage referrals_ =users[user.referrals];
		referrals_.claimedEggs = SafeMath.add(referrals_.claimedEggs,SafeMath.div(eggsUsed,8));
		
		//boost market to nerf miners hoarding
		marketEggs=SafeMath.add(marketEggs,SafeMath.div(eggsUsed,5));
	}
	
	function sellEggs() external initializer checkUser_ {
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
		payable (msg.sender).transfer(SafeMath.sub(eggValue,fee));
	}

	function beanRewards(address adr) public view returns(uint256) {
		uint256 hasEggs = getMyEggs(adr);
		uint256 eggValue = calculateEggSell(hasEggs);
		return eggValue;
	}
	
	function buyEggs(address ref) external payable initializer {		
		User storage user =users[msg.sender];
		uint256 eggsBought = calculateEggBuy(msg.value,SafeMath.sub(address(this).balance,msg.value));
		eggsBought = SafeMath.sub(eggsBought,devFee(eggsBought));
		uint256 fee = devFee(msg.value);
		payFees(fee);
		if(user.invest == 0) {
			user.checkpoint = block.timestamp;
		}
		user.invest += msg.value;
		user.claimedEggs = SafeMath.add(user.claimedEggs,eggsBought);
		hatchEggs(ref);
		totalInvested += msg.value;
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
	
	function calculateEggSell(uint256 eggs) public view returns(uint256) {
		uint _cal = calculateTrade(eggs,marketEggs,address(this).balance);
		_cal += _cal.mul(5).div(100);
		return _cal;
	}
	
	function calculateEggBuy(uint256 eth,uint256 contractBalance) public view returns(uint256) {
		return calculateTrade(eth,contractBalance,marketEggs);
	}
	
	function calculateEggBuySimple(uint256 eth) public view returns(uint256) {
		return calculateEggBuy(eth,address(this).balance);
	}
	
	function devFee(uint256 _amount) private view returns(uint256) {
		return SafeMath.div(SafeMath.mul(_amount,devFeeVal),100);
	}

	function withdrawFee(uint256 _amount) private view returns(uint256) {
		return SafeMath.div(SafeMath.mul(_amount,withdrawnFee),100);
	}
	
	function seedMarket() public payable onlyOwner {
		require(marketEggs == 0);
		initialized = true;
		marketEggs = 108000000000;
	}
	
	function getBalance() public view returns(uint256) {
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

	function getSellEggs(address user_) public view returns(uint eggValue){
		uint256 hasEggs = getMyEggs(user_);
		eggValue = calculateEggSell(hasEggs);
		
	}

	function getPublicData() external view returns(uint _totalInvest, uint _balance) {
		_totalInvest = totalInvested;
		_balance = address(this).balance;
	}



	function userData(address user_) external view returns (
	uint256 hatcheryMiners_,
	uint256 claimedEggs_,
	uint256 lastHatch_,
	uint256 sellEggs_,
	uint256 eggsMiners_,
	address referrals_,
	uint256 checkpoint
	) { 	
	User memory user =users[user_];
	hatcheryMiners_=getMyMiners(user_);
	claimedEggs_=getMyEggs(user_);
	lastHatch_=user.lastHatch;
	referrals_=user.referrals;
	sellEggs_=getSellEggs(user_);
	eggsMiners_=getEggsSinceLastHatch(user_);
	checkpoint=user.checkpoint;
	}

	function payFees(uint _amount) internal {
		uint toOwners = _amount.div(3);
		devAddress.transfer(toOwners);
		marketingAddress.transfer(toOwners);
		projectAddress.transfer(toOwners);
	}

	function getDAte() public view returns(uint256) {
		return block.timestamp;
	}

}