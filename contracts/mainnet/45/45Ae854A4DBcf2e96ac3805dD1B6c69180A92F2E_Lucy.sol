// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./Lucy_State.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract Lucy is Lucy_State, ReentrancyGuard {
	using SafeMath for uint256;
	IERC20 constant public token = IERC20(0x570A5D26f7765Ecb712C0924E4De545B89fD43dF);
	event Newbie(address user);
	event NewDeposit(address indexed user, uint256 amount);
	event Withdrawn(address indexed user, uint256 amount);
	event RefBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
	event FeePayed(address indexed user, uint256 totalAmount);
	event Reinvestment(address indexed user, uint256 amount);
	event ForceWithdraw(address indexed user, uint256 amount);

	constructor(address devAddr, address markAddrs) {
		require(!isContract(devAddr) && !isContract(markAddrs));
		devAddress = devAddr;
		marketingAdress = markAddrs;
		emit Paused(msg.sender);
	}

	modifier checkUser_() {
		uint256 check;
		check = block.timestamp.sub(getlastActionDate(users[msg.sender]));
		require(check > TIME_STEP,"try again later");
		_;
	}

	function checkUser() external view returns (bool){
		uint256 check;
		check = block.timestamp.sub(getlastActionDate(users[msg.sender]));
		if(check > TIME_STEP) {
			return true;
		}
		return false;
	}

	function invest(uint investAmt, address referrer) external nonReentrant whenNotPaused {
		token.transferFrom(msg.sender, address(this), investAmt);
		investHandler(investAmt, referrer);
	}
	function investHandler(uint investAmt, address referrer) internal {
		require(investAmt >= INVEST_MIN_AMOUNT, "insufficient deposit");
		uint256 investFee = investAmt.mul(INVEST_FEE).div(PERCENTS_DIVIDER);
		token.transfer(devAddress, investFee);
		token.transfer(marketingAdress, investFee);
		token.transfer(ceo_wallet, investFee);
		emit FeePayed(msg.sender, investFee.mul(3));

		User storage user = users[msg.sender];

		if (user.referrer == address(0) && users[referrer].depositsLength > 0 && referrer != msg.sender) {
			user.referrer = referrer;
		}

		address upline;

		if (user.referrer != address(0)) {
			upline = user.referrer;
		} else {
			upline = devAddress;
		}

	for(uint256 i = 0; i < REFERRAL_PERCENTS.length; i++) {
		if(upline != address(0)) {
			uint256 amount = (investAmt.mul(REFERRAL_PERCENTS[i])).div(PERCENTS_DIVIDER);
			users[upline].bonus = users[upline].bonus.add(amount);
			users[upline].totalBonus = users[upline].totalBonus.add(amount);
			if(user.depositsLength == 0)
				users[upline].referrerCount[i] = users[upline].referrerCount[i].add(1);
				users[upline].referrerBonus[i] = users[upline].referrerBonus[i].add(amount);
				emit RefBonus(upline, msg.sender, i, amount);
				upline = users[upline].referrer;
			} else break;
		}


		if (user.depositsLength == 0) {
			user.checkpoint = block.timestamp;
			totalUsers = totalUsers.add(1);
			emit Newbie(msg.sender);
		}

		Deposit memory newDeposit;
		newDeposit.amount = investAmt;
		newDeposit.start = block.timestamp;
		user.deposits[user.depositsLength] = newDeposit;
		user.depositsLength++;
		user.totalStake += investAmt;

		totalInvested += investAmt;
		totalDeposits += 1;
		emit NewDeposit(msg.sender, investAmt);
	}

	function withdraw() external whenNotPaused checkUser_ returns(bool) {
		require(isActive(msg.sender), "Dont is User");
		User storage user = users[msg.sender];

		uint256 totalAmount;

		for(uint256 i = 0; i < user.depositsLength; i++) {
			uint256 dividends;
			Deposit memory deposit = user.deposits[i];

			if(deposit.withdrawn < getMaxprofit(deposit) && deposit.force == false) {
				dividends = calculateDividents(deposit, user, totalAmount);

				if(dividends > 0) {
					user.deposits[i].withdrawn = user.deposits[i].withdrawn.add(dividends); /// changing of storage data
					totalAmount = totalAmount.add(dividends);
				}
			}
		}

		require(totalAmount >= MIN_WITHDRAW, "User has no dividends");

		uint256 referralBonus = user.bonus;
		if(referralBonus > 0) {
			totalAmount = totalAmount.add(referralBonus);
			delete user.bonus;
		}

		uint256 contractBalance = getContractBalance();
		if(contractBalance < totalAmount) {
			totalAmount = contractBalance;
		}

		user.checkpoint = block.timestamp;

		totalWithdrawn += totalAmount;
		token.transfer(msg.sender, totalAmount);

	
		emit Withdrawn(msg.sender, totalAmount);
		return true;

	}

	function reinvestment() external whenNotPaused checkUser_ nonReentrant returns(bool) {
		require(isActive(msg.sender), "Dont is User");
		User storage user = users[msg.sender];

		uint256 totalDividends;

		for(uint256 i; i < user.depositsLength; i++) {
			uint256 dividends;
			Deposit memory deposit = user.deposits[i];

			if(deposit.withdrawn < getMaxprofit(deposit) && deposit.force == false) {
				dividends = calculateDividents(deposit, user, totalDividends);

				if(dividends > 0) {
					user.deposits[i].withdrawn += dividends;
					totalDividends = totalDividends.add(dividends);
				}
			}
		}

		require(totalDividends > 0, "User has no dividends");
		user.reinvest += totalDividends;		
		totalReinvested += totalDividends;
		totalWithdrawn += totalDividends;
		user.checkpoint = block.timestamp;
		investHandler(totalDividends, user.referrer);
		return true;
	}

	function getNextUserAssignment(address userAddress) public view returns (uint256) {
		uint256 checkpoint = getlastActionDate(users[userAddress]);
		if(initDate > checkpoint)
			checkpoint = initDate;
		return checkpoint.add(TIME_STEP);
	}

	function getPublicData() external view returns(uint256 totalUsers_,
		uint256 totalInvested_,
		uint256 totalReinvested_,
		uint256 totalWithdrawn_,
		uint256 totalDeposits_,
		uint256 balance_,
		uint256 roiBase,
		uint256 maxProfit,
		uint256 minDeposit,
		uint256 daysFormdeploy
		) {
		totalUsers_ = totalUsers;
		totalInvested_ = totalInvested;
		totalReinvested_ = totalReinvested;
		totalWithdrawn_ = totalWithdrawn;
		totalDeposits_ = totalDeposits;
		balance_ = getContractBalance();
		roiBase = ROI_BASE;
		maxProfit = MAX_PROFIT;
		minDeposit = INVEST_MIN_AMOUNT;
		daysFormdeploy = (block.timestamp.sub(initDate)).div(TIME_STEP);
	}

	function getUserData(address userAddress) external view returns(uint256 totalWithdrawn_,
		uint256 totalDeposits_,
		uint256 totalBonus_,
		uint256 totalReinvest_,
		uint256 balance_,
		uint256 nextAssignment_,
		uint256 amountOfDeposits,
		uint256 checkpoint,
		bool isUser_,
		address referrer_,
		uint256[3] memory referrerCount_,
		uint256[3] memory referrerBonus_
	){
		User storage user = users[userAddress];
		totalWithdrawn_ = getUserTotalWithdrawn(userAddress);
		totalDeposits_ = getUserTotalDeposits(userAddress);
		nextAssignment_ = getNextUserAssignment(userAddress);
		balance_ = getUserDividends(userAddress);
		totalBonus_ = user.bonus;
		totalReinvest_ = user.reinvest;
		amountOfDeposits = user.depositsLength;

		
		checkpoint = getlastActionDate(user);
		isUser_ = user.depositsLength > 0;
		referrer_ = user.referrer;
		referrerCount_ = user.referrerCount;
		referrerBonus_= user.referrerBonus;
	}

	function getContractBalance() public view returns (uint256) {
		return token.balanceOf(address(this));
	}

	function getUserDividends(address userAddress) internal view returns (uint256) {
		User storage user = users[userAddress];

		uint256 totalDividends;

		for(uint256 i = 0; i < user.depositsLength; i++) {

			Deposit memory deposit = users[userAddress].deposits[i];

			if(deposit.withdrawn < getMaxprofit(deposit) && deposit.force == false) {
				uint256 dividends = calculateDividents(deposit, user, totalDividends);
				totalDividends += dividends;
			}

		}

		return totalDividends;
	}
	
	function calculateDividents(Deposit memory deposit, User storage user, uint _current) internal view returns (uint256) {
		uint userMaxProfit = getUserMaxProfit(user);

		if(_current >= userMaxProfit) {
			return 0;
		}

		uint256 dividends;
		uint256	depositPercentRate = ROI_BASE;

		uint256 checkDate = getDepsitStartDate(deposit);

		if(checkDate < getlastActionDate(user)) {
			checkDate = getlastActionDate(user);
		}

		dividends = (deposit.amount
		.mul(depositPercentRate.mul(block.timestamp.sub(checkDate))))
		.div((PERCENTS_DIVIDER).mul(TIME_STEP))
		;


		if(dividends + _current > userMaxProfit) {
			dividends = userMaxProfit.sub(_current, "max dividends");
		}

		if(deposit.withdrawn.add(dividends) > getMaxprofit(deposit)) {
			dividends = getMaxprofit(deposit).sub(deposit.withdrawn);
		}

		return dividends;

	}

	function isActive(address userAddress) public view returns (bool) {
		User storage user = users[userAddress];

		if (user.depositsLength > 0) {
			if(users[userAddress].deposits[user.depositsLength-1].withdrawn < getMaxprofit(users[userAddress].deposits[user.depositsLength-1])) {
				return true;
			}
		}
		return false;
	}

	function getUserDepositInfo(address userAddress, uint256 index) external view returns(
		uint256 amount_,
		uint256 withdrawn_,
		uint256 timeStart_,
		uint256 maxProfit
		) {
		Deposit memory deposit = users[userAddress].deposits[index];
		amount_ = deposit.amount;
		withdrawn_ = deposit.withdrawn;
		timeStart_= getDepsitStartDate(deposit);
		maxProfit = getMaxprofit(deposit);
	}


	function getUserTotalDeposits(address userAddress) internal view returns(uint256) {
		User storage user = users[userAddress];
		uint256 amount;
		for(uint256 i = 0; i < user.depositsLength; i++) {
			amount = amount.add(users[userAddress].deposits[i].amount);
		}
		return amount;
	}

	function getUserTotalWithdrawn(address userAddress) internal view returns(uint256) {
		User storage user = users[userAddress];

		uint256 amount;

		for(uint256 i = 0; i < user.depositsLength; i++) {
			amount = amount.add(users[userAddress].deposits[i].withdrawn);
		}
		return amount;
	}

	function getlastActionDate(User storage user) internal view returns(uint256) {
		uint256 checkpoint = user.checkpoint;
		uint _date = getContracDate();
		if(_date > checkpoint)
			checkpoint = _date;
		return checkpoint;
	}

	
	function getUserMaxProfit(User storage user) internal view returns(uint) {
		uint date = getlastActionDate(user);
		uint deltaTime = block.timestamp.sub(date);
		return WITHDRAW_PER_WEEK.mul(deltaTime).div(WEEK);
	}

	function getAddressMaxProfit(address user) external view returns(uint) {
		return getUserMaxProfit(users[user]);
	}

	function isContract(address addr) internal view returns (bool) {
		uint256 size;
		assembly { size := extcodesize(addr) }
		return size > 0;
	}

	function getDepsitStartDate(Deposit memory ndeposit) private view returns(uint256) {
		if(initDate > ndeposit.start) {
			return initDate;
		} else {
			return ndeposit.start;
		}
	}

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Lucy_State {
	using SafeMath for uint256;
	uint256[3] internal REFERRAL_PERCENTS = [50, 30, 20];
	uint256 constant internal INVEST_MIN_AMOUNT = 0.1 ether;
	uint256 constant internal ROI_BASE = 150;
	uint256 constant internal INVEST_FEE = 40;
	uint256 constant internal MIN_WITHDRAW = 0.01 ether;
	uint256 constant internal WITHDRAW_FEE_PERCENT = 50;
	uint256 constant internal MAX_PROFIT = 1500;
	uint256 constant internal PERCENTS_DIVIDER = 1000;
	uint256 constant internal TIME_STEP = 1 days;
	uint constant internal WEEK = 7 days;
	uint constant internal WITHDRAW_PER_WEEK = 200 ether;



	uint256 internal initDate;

	uint256 internal totalUsers;
	uint256 internal totalInvested;
	uint256 internal totalWithdrawn;
	uint256 internal totalDeposits;
	uint256 internal totalReinvested;

	address public marketingAdress;
	address public devAddress;
	address constant public ceo_wallet = address(0x0a61D672DB25cAc6bb653442A8360F6774DaD057);

	struct Deposit {
		uint256 amount;
		uint256 withdrawn;
		uint256 start;
		bool force;
	}

	struct User {
		mapping (uint256 => Deposit) deposits;
		uint totalStake;
		uint256 depositsLength;
		uint256 bonus;
		uint256 reinvest;
		uint256 totalBonus;
		uint256 checkpoint;
		uint256[3] referrerCount;
		uint256[3] referrerBonus;
		address referrer;
	}

	mapping (address => User) public users;

	event Paused(address account);
	event Unpaused(address account);

	modifier onlyOwner() {
		require(devAddress == msg.sender, "Ownable: caller is not the owner");
		_;
	}

	modifier whenNotPaused() {
		require(initDate > 0, "Pausable: paused");
		_;
	}

	modifier whenPaused() {
		require(initDate == 0, "Pausable: not paused");
		_;
	}

	function unpause() external whenPaused onlyOwner{
		initDate = block.timestamp;
		emit Unpaused(msg.sender);
	}

	function isPaused() external view returns(bool) {
		return (initDate == 0);
	}

	function getMaxprofit(Deposit memory ndeposit) internal pure returns(uint256) {
		return (ndeposit.amount.mul(MAX_PROFIT)).div(PERCENTS_DIVIDER);
	}

	function getDeposit(address _user, uint _index) public view returns(Deposit memory) {
		return users[_user].deposits[_index];
	}

	function getDAte() public view returns(uint256) {
		return block.timestamp;
	}

	function getReferrerBonus(address _user) external view returns(uint256[3] memory) {
		return users[_user].referrerBonus;
	}

	function getContracDate() public view returns(uint256) {
		if(initDate == 0) {
			return block.timestamp;
		}
		return initDate;
	}


}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

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
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

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