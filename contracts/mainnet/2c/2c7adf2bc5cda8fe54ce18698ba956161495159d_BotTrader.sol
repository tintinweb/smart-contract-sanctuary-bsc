/**
 *Submitted for verification at BscScan.com on 2022-12-22
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-14
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

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


interface ERC20 {
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

// interface BUSDBirdStake{
//     function userInfo(address _addr) view external returns(uint256 for_withdraw, uint256 total_invested, uint256 total_withdrawn, uint256 total_match_bonus, uint256[5] memory structure);
// }

contract BotTrader is Ownable {
	using SafeMath for uint256;

	address public BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
	
	uint256 private EGGS_TO_HATCH_1MINERS = 1080000;
	uint256 private PSN = 20000;
	uint256 private PSNH = 20000;
	uint256 private devFeeVal = 10;
	uint256 private mrkFeeVal = 20;
	uint256 private totalFee  = 60;
	uint256 private monthlyLimit  = 2000 ether;
	// uint256 private balanceLimit  = 10000 ether;
	bool private initialized = false;
	address payable public dev1;
	address payable public dev2;
	address payable public dev3;
	address payable public dev4;
    address payable public mark;
	uint256 public marketEggs;

	struct User{
		uint256 invest;
		uint256 withdraw;
		uint256 hatcheryMiners;
		uint256 claimedEggs;
		uint256 lastHatch;
		uint checkpoint;
		address referrals; // Referrer
        uint256 botLevel;
        address[] yourReferrals;
        uint256 refEarnings;
	}

	mapping (address => User) public users;
	mapping (uint256 => mapping(address => uint256)) public mLimit; // Month limit

	uint public totalDonates;
	uint public totalInvested;
	uint256 constant internal TIME_STEP = 1 days;

    // address public oldContract;

	constructor() {
		dev1 = payable(0x9c9f7C2c185AE2e076faeA8ee821A0f3fafc2950); // s
		dev2 = payable(0xd35762a92cb3A83664FbC87bEFe7930a0a9b1A3C); // o
        dev3 = payable(0xF8Aaf52fb65137428bb02ed71Fa9ceAf572828D7); // a
		dev4 = payable(0x8667d16463F440b7eC170B1eCA4DCe7FF7C05fB0); // k
        
		mark = payable(0x01e2fe78F6507619a6904C0Ef36F3959c3Fca7fA); // f

        // oldContract = address(0x09180Eb78a3cb64Db28d058382428f6553612ee9);
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
            User storage refUser = users[ref];
            refUser.yourReferrals.push(msg.sender);
		}
		
		uint256 eggsUsed = getMyEggs(msg.sender);
		uint256 newMiners = SafeMath.div(eggsUsed,EGGS_TO_HATCH_1MINERS);
		user.hatcheryMiners = SafeMath.add(user.hatcheryMiners,newMiners);
		user.claimedEggs = 0;
		user.lastHatch = block.timestamp;
		user.checkpoint = block.timestamp;
		
		// User storage referrals_ =users[user.referrals]; // Referrer address
		// referrals_.claimedEggs = SafeMath.add(referrals_.claimedEggs, (eggsUsed * 15) / 100); // Send referral eggs
		
		//boost market to nerf miners hoarding
		// marketEggs=SafeMath.add(marketEggs,SafeMath.div(eggsUsed,5));
	}

    function levelUpBot(uint256 amount) external initializer {

        User storage user = users[msg.sender];
        
        require (user.botLevel <= 2 && user.botLevel >= 0, "You already have the max level (Level 3)");

        if (user.botLevel == 0) {
            require(amount >= 10 ether, "Price for Level 2 is $10");
            ERC20(BUSD).transferFrom(address(msg.sender), address(this), amount);
            user.botLevel = 1;

        } else if (user.botLevel == 1) {
            require(amount >= 20 ether, "Price for Level 3 is $20");
            ERC20(BUSD).transferFrom(address(msg.sender), address(this), amount);
            user.botLevel = 2;

        }
         
    }
	
	function sellEggs() external initializer checkUser_ {
		User storage user =users[msg.sender];
		uint256 hasEggs = getMyEggs(msg.sender);
        uint256 eggValue;

        // if(ERC20(BUSD).balanceOf(address(this)) > balanceLimit){
        //     eggValue = calculateEggSell(hasEggs/);
        //     hasEggs -= (hasEggs/30); 
        // }

        if (user.botLevel == 0) {
            eggValue = calculateEggSell(hasEggs/10);
            hasEggs -= (hasEggs/10);
        } else if (user.botLevel == 1) {
            eggValue = calculateEggSell(hasEggs/20);
            hasEggs -= (hasEggs/20);
        } else if (user.botLevel == 2) {
            eggValue = calculateEggSell(hasEggs/30);
            hasEggs -= (hasEggs/30);
        }
        
        require(mLimit[cMonth()][msg.sender] + eggValue <= monthlyLimit, "only 2k every month");
        mLimit[cMonth()][msg.sender] += eggValue;

		uint256 devFee = eggValue * devFeeVal / 1000;
		uint256 mrkFee  = eggValue * mrkFeeVal / 1000;

        ERC20(BUSD).transfer(payable(dev1), devFee);
        ERC20(BUSD).transfer(payable(dev2), devFee);
        ERC20(BUSD).transfer(payable(dev3), devFee);
        ERC20(BUSD).transfer(payable(dev4), devFee);
        ERC20(BUSD).transfer(payable(mark), mrkFee);

        uint256 eggsUsed = hasEggs;
		uint256 newMiners = SafeMath.div(eggsUsed,EGGS_TO_HATCH_1MINERS);
		user.hatcheryMiners = SafeMath.add(user.hatcheryMiners,newMiners);
		user.claimedEggs = 0;
		user.lastHatch = block.timestamp;
		user.checkpoint = block.timestamp;

		marketEggs = SafeMath.add(marketEggs,hasEggs);
		user.withdraw += eggValue;
        ERC20(BUSD).transfer(payable(msg.sender), SafeMath.sub(eggValue,(devFee+devFee+mrkFee))); // Value minus fee
	}

	function beanRewards(address adr) public view returns(uint256) {
		uint256 hasEggs = getMyEggs(adr);
		uint256 eggValue = calculateEggSell(hasEggs);
		return eggValue;
	}
	
	function buyEggs(address ref, uint256 amount) external initializer {		
		User storage user =users[msg.sender];

        ERC20(BUSD).transferFrom(address(msg.sender), address(this), amount);

        // if(oldContract != address(0)){
        //     (,uint256 oldTotalDeposit,,,) = BUSDBirdStake(oldContract).userInfo(msg.sender); 
        //     if(oldTotalDeposit > 0){
        //         amount += amount / 100;
        //     }
        // }

		uint256 eggsBought = calculateEggBuy(amount,SafeMath.sub(ERC20(BUSD).balanceOf(address(this)),amount));
		eggsBought = SafeMath.sub(eggsBought, (eggsBought * totalFee) / 1000 );
        uint256 devFee = amount * devFeeVal / 1000;
		uint256 mrkFee = amount * mrkFeeVal / 1000;

        ERC20(BUSD).transfer(payable(dev1), devFee);
        ERC20(BUSD).transfer(payable(dev2), devFee);
        ERC20(BUSD).transfer(payable(dev3), devFee);
        ERC20(BUSD).transfer(payable(dev4), devFee);
        ERC20(BUSD).transfer(payable(mark), mrkFee);

		if(user.invest == 0) {
			user.checkpoint = block.timestamp;
		}
		user.invest += amount;
		user.claimedEggs = SafeMath.add(user.claimedEggs,eggsBought);
		hatchEggs(ref);
        ERC20(BUSD).transfer(payable(user.referrals), (amount * 15) / 100); // Send 15% referrals

        User storage userRefs = users[ref];

        userRefs.refEarnings += (amount * 15) / 100;

		totalInvested += amount;
	}
	
	function calculateTrade(uint256 rt,uint256 rs, uint256 bs) private view returns(uint256) {
		uint a =PSN.mul(bs);
		uint b =PSNH;
		uint c =PSN.mul(rs);
		uint d =PSNH.mul(rt);
		uint h =c.add(d).div(rt);
		return a.div(b.add(h));
	}
	
	function calculateEggSell(uint256 eggs) public view returns(uint256) {
		uint _cal = calculateTrade(eggs,marketEggs,ERC20(BUSD).balanceOf(address(this)));
		_cal += _cal.mul(5).div(100);
		return _cal;
	}
	
	function calculateEggBuy(uint256 eth,uint256 contractBalance) public view returns(uint256) {
		return calculateTrade(eth,contractBalance,marketEggs);
	}
	
	function calculateEggBuySimple(uint256 eth) public view returns(uint256) {
		return calculateEggBuy(eth,ERC20(BUSD).balanceOf(address(this)));
	}
	
	function seedMarket() public onlyOwner {
		require(marketEggs == 0);
		initialized = true;
		marketEggs = 108000000000;
	}
	
	function getBalance() public view returns(uint256) {
		return ERC20(BUSD).balanceOf(address(this));
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
		_balance = ERC20(BUSD).balanceOf(address(this));
	}

	function cMonth() public view returns(uint256) {
		return (block.timestamp / (30 * TIME_STEP));
	}

	function userData(address user_) external view returns (
	uint256 hatcheryMiners_,
	uint256 claimedEggs_,
	uint256 lastHatch_,
	uint256 sellEggs_,
	uint256 eggsMiners_,
	address referrals_,
	uint256 checkpoint,
	uint256 monLimit,
    uint256 botLvl,
    address[] memory userReferrals,
    uint256 referralEarnings
	) { 	
        User memory user =users[user_];
        hatcheryMiners_=getMyMiners(user_);
        claimedEggs_=getMyEggs(user_);
        lastHatch_=user.lastHatch;
        referrals_=user.referrals;
        sellEggs_=getSellEggs(user_);
        eggsMiners_=getEggsSinceLastHatch(user_);
        checkpoint=user.checkpoint;
        monLimit = mLimit[cMonth()][msg.sender];
        botLvl = user.botLevel;
        userReferrals = user.yourReferrals;
        referralEarnings = user.refEarnings;
	}
	
	function donate(uint256 amount) external {		
        ERC20(BUSD).transferFrom(address(msg.sender), address(this), amount);
        totalDonates += amount;
    }

    function setBotLevel(address _user, uint256 _level) public onlyOwner {
        require(_level >= 2 && _level >= 0, "Wrong value");
        User storage user = users[_user];
        user.botLevel = _level;
    }

}