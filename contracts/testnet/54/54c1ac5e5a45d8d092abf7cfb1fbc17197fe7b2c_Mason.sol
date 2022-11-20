/**
 *Submitted for verification at BscScan.com on 2022-11-19
*/

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

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

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

// File: Mason.sol



pragma solidity 0.8.12;




contract Mason is Ownable{

	event Investment(
		address indexed user,
		uint256 amount
	);

	event Withdrawal(
		address indexed user,
		uint256 amount
	);

	// event Cashback(
	// 	address user,
	// 	uint256 amount
	// );

	event Registration(
		address indexed user,
		address indexed referal
	);

	event RefBonus(
		address indexed user,
		uint256 amount,
		address referal,
		uint256 indexed lvl
	);

	using SafeMath for uint256;

	// CONSTANTS
	uint256 public RATIO_MULTIPLIER = 10000;
    uint256 public MAX_DEPOSIT_STEP = 10;
    uint256 private MARKETING_FEE = 1500;
	uint256 private DIVIDENDS_PERCENT = 201;
	uint256 private GIFT_PERCENT = 200;
	uint256 constant private SEC_IN_24H = 1 days;
	uint256 constant private SEC_IN_WEEK = 7 days;
	uint256 constant private MIN_INVESTMENT = 0.2 ether;
	uint256[] private REFER_LEVELS = [0 ether, 5 ether, 20 ether];
	uint256[] private REFER_BONUS_PERCENT = [1000, 500, 300, 200, 100];

	// STATE
	uint256 public initializedAt;
	uint256 public giftAmount = 0;
	address payable public lastPayAddress;
	uint256 public lastPayTime;

	uint256 public allInvestCount = 0;
	uint256 public allInvest = 0;
	uint256 public allPaymentsCount = 0;
	uint256 public allPayments = 0;
	uint256 public allMarketingPayments = 0;
	uint256 public usersCount = 0;
	uint256[] public adminRefSysPayment = [0,0,0,0,0];
	uint256[] public adminRefSysPaymentCount = [0,0,0,0,0];
	uint256[] public allReferBonus = [0,0,0,0,0];
	uint256[] public allReferBonusCount = [0,0,0,0,0];

    struct User {
        // uint256 id;
        uint256 invested;
        uint256 investedCount;
        uint256 payments;
        uint256 paymentsCount;
        uint256[5] referBonus;
        uint256[5] referBonusCount;
        // uint256 cashback;
        address payable refer;
        address[] referals;
        uint256 referalsCount;
        uint256 lastPayment;
        // uint256 claimedAmount;
        uint256 registeredAt;
	}

	mapping (address => User) public users;

	constructor() {
		createUserIfNotExist(msg.sender, msg.sender);
        initializedAt = block.timestamp;
    }

	function getMaxDeposit(address _address) public view returns (uint256) {
        User memory user = users[_address];
        uint256 weeksPast = 1 + block.timestamp.sub(initializedAt).mul(10).div(SEC_IN_WEEK).div(10);
        uint256 maxDepositSinceInitialisation = MAX_DEPOSIT_STEP.mul(weeksPast);

        uint256 maxDeposit = min(maxDepositSinceInitialisation, 500 ether);

        if (maxDeposit == 0) maxDeposit = MAX_DEPOSIT_STEP;

        return maxDeposit.sub(user.invested);
    }

    function createUserIfNotExist(address _address, address refer) private {
        
    	User memory user = users[_address];
        if (user.registeredAt == 0) {
            require(refer != address(0), "INVITER MUST EXIST");
            if (initializedAt > 0) {
                require(users[refer].registeredAt > 0, "REFER NOT REGISTERED");
            }
			

            user.invested = 0;
            user.investedCount = 0;
            user.payments = 0;
            user.paymentsCount = 0;
            // user.cashback = 0;
            user.referBonus = [uint256(0), uint256(0), uint256(0), uint256(0), uint256(0)];
            user.referBonusCount = [uint256(0), uint256(0), uint256(0), uint256(0), uint256(0)];
            user.registeredAt = block.timestamp;
            user.lastPayment = block.timestamp;
            // user.claimedAmount = 0;
            usersCount++;
            user.refer = payable (refer);
			users[refer].referals.push(_address);
			users[refer].referalsCount++;

			users[_address] = user;

            emit Registration(refer, _address);
        }
        
    }

    function lastPayGift() public payable {
		if (lastPayTime > 0 && block.timestamp.sub(1 hours) > lastPayTime) {
			lastPayAddress.transfer(giftAmount);
			lastPayTime = 0;
		}
	}

	// function lastPayGift() external payable {
	// 	if (lastPayTime > 0 && block.timestamp.sub(1 hours) > lastPayTime) {
	// 		lastPayAddress.transfer(giftAmount);
	// 		lastPayTime = 0;
	// 	}
	// }

	function withdraw() public payable {
		
		User storage user = users[msg.sender];

		//payment
		if(user.invested > 0){
			uint256 amount = 0;
			amount = user.invested.mul(DIVIDENDS_PERCENT).div(RATIO_MULTIPLIER).mul(block.timestamp.sub(user.lastPayment)).div(SEC_IN_24H);
			if(amount > 0){

				user.lastPayment = block.timestamp;

				if (amount > address(this).balance) {
					amount = address(this).balance;
				}

				//payment user statistics
				user.paymentsCount++;
				user.payments += amount;

				//payment global statistics
				allPaymentsCount++;
				allPayments += amount;

				//payment operation
				emit Withdrawal(msg.sender, amount);
				payable (msg.sender).transfer(amount);
			}
		}

	}

	function deposit(address payable refer) external payable {
		require(msg.value >= MIN_INVESTMENT, "value to invest must be >= 0.01 bnb");

        createUserIfNotExist(msg.sender, refer);

        lastPayGift();
        withdraw();

        User storage user = users[msg.sender];

		user.investedCount++;
		user.invested += msg.value;

		

		giftAmount +=  msg.value.mul(GIFT_PERCENT).div(RATIO_MULTIPLIER);
		lastPayAddress = payable(msg.sender);

		lastPayTime = block.timestamp;

		//investment global statistics
		allInvestCount++;
		allInvest += msg.value;

		//investment operation
		emit Investment(msg.sender,msg.value);

		//refer bonus

		User storage user_refer = user;
		uint256 sum = 0;
		for(uint256 lvl = 0; lvl < REFER_BONUS_PERCENT.length; lvl++){
			sum = msg.value.mul(REFER_BONUS_PERCENT[lvl]).div(RATIO_MULTIPLIER);
			if (user_refer.refer != address(0)) {
				if (getUserStatus(user_refer.refer) > lvl) {
					//refer bonus user statistics
					users[user_refer.refer].referBonusCount[lvl]++;
					users[user_refer.refer].referBonus[lvl] += sum;
					//refer bonus global statistics
					allReferBonus[lvl] += sum;
					allReferBonusCount[lvl]++;
					//refer bonus operation
					emit RefBonus(user_refer.refer, sum, msg.sender, lvl.add(1));
					payable (address(user_refer.refer)).transfer(sum);

					sum = 0;
				}
				user_refer = users[user_refer.refer];
			}

			if (sum > 0) {
				adminRefSysPayment[lvl] += sum;
				adminRefSysPaymentCount[lvl]++;
				payable (owner()).transfer(sum);
			}
		}
		//marketing fee
	    uint256 fee = msg.value.mul(MARKETING_FEE).div(RATIO_MULTIPLIER);
	    allMarketingPayments += fee;
		payable (owner()).transfer(fee);


	}

	function getReferals(address _address) public view returns (address[] memory) {
		return users[_address].referals;
	}

	function getRefersBonus(address _address) public view returns (uint256[5] memory) {
		return users[_address].referBonus;
	}

	function getRefersBonusCount(address _address) public view returns (uint256[5] memory) {
		return users[_address].referBonusCount;
	}

	function getUserStatus(address user) public view returns (uint256){
		uint256 sum = 0;
		if (users[user].invested <= 0) {
			return 0;
		}
		for(uint256 lvl = REFER_LEVELS.length-1; lvl >= 0; lvl--) {
			sum += users[user].referBonus[lvl].mul(RATIO_MULTIPLIER).div(REFER_BONUS_PERCENT[lvl]);
		}
		if (sum > 300 ether) {
			return REFER_LEVELS.length;
		}
		return REFER_LEVELS.length - 2;
		// require(sum > 0);
		// for(uint256 i = REFER_LEVELS.length-1; i >= 0; i--){
		// 	if(sum >= REFER_LEVELS[i])
		// 		return i+1;
		// }
		// return 0;
	}

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}