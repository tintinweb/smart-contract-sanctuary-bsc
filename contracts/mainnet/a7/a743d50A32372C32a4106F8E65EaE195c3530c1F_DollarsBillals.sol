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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DollarsBillals_Status is ReentrancyGuard {

	address internal devAddress;
	address constant internal ownerAddress = 0xD95048b860edA18a335988D95f7A3dCF3CD63b91;
	address constant internal markAddress = 0xC36772A9409C0E2c9BcFC8EEbCb468d17Eea24b5;
	address constant internal proJectAddress = 0x6b31f0f792B37DbfFFeCF2e3ebe97cDae8730F13;
	address constant internal partnerAddress = 0x1ae70F57AAF95075ED9F936EFF137d8FD78aCCf5;
	address constant internal eventAddress = 0x91e1AF4B7E3ace83aF54ca7F9284F3386bd2A472;
	// Dev 2%
	uint constant internal DEV_FEE = 100;
	// owner 2%
	uint constant internal OWNER_FEE = 100;
    // Marketing 2%
	uint constant internal MARKETING_FEE = 100;
    // owner 2%
	uint constant internal PROJECT_FEE = 100;
	// Partner 2%
	uint constant internal PARTNER_FEE = 100;
	// Event 5%
	uint constant internal EVENT_FEE = 500;

	uint constant internal WITHDRAW_FEE_BASE = 1000;
	uint constant internal MAX_PROFIT = 20000;
	// 10000 = 100%, 1000 = 10%, 100 = 1%, 10 = 0.1%, 1 = 0.01%
	uint constant internal PERCENTS_DIVIDER = 10000;


	using SafeMath for uint;
	IERC20 public token; //0x55d398326f99059fF775485246999027B3197955 - usdt
	uint constant internal MACHINEBONUS_LENGTH = 20;
	uint[MACHINEBONUS_LENGTH] internal REFERRAL_PERCENTS = [4000, 2400, 1600, 600, 400, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 400, 600, 1600, 2400, 4000];
	uint constant internal INVEST_MIN_AMOUNT = 21 ether;
	uint constant internal MINIMAL_REINVEST_AMOUNT = 0.01 ether;
	uint constant internal ROI_BASE = 50;
	uint constant internal MIN_WITHDRAW = 1;
	// uint constant internal WITHDRAW_FEE_PERCENT = 50;
	uint constant internal WITHDRAW_FEE_PERCENT_DAY = 1000;
	uint constant internal WITHDRAW_FEE_PERCENT_WEEK = 700;
	uint constant internal WITHDRAW_FEE_PERCENT_TWO_WEEK = 300;
	uint constant internal WITHDRAW_FEE_PERCENT_MONTH = 0;

	uint constant internal TIME_STEP = 1 days;

	uint constant internal FORCE_BONUS_PERCENT = 5000;
	uint constant internal MACHINE_ROI = 25;

	uint internal MAX_WITHDRAW_BY_DAY = 20_000 ether;

	uint internal initDate;

	uint internal totalUsers;
	uint internal totalInvested;
	uint internal totalWithdrawn;
	uint internal totalDeposits;
	uint internal totalReinvested;

	mapping(address => bool) public blockeds;

	struct Deposit {
		uint amount;
		uint initAmount;
		uint withdrawn;
		uint start;
		bool isForceWithdraw;
	}

	struct MachineBonus {
		uint initAmount;
		uint withdrawn;
		uint start;
		uint level;
		uint bonus;
		uint lastPayBonus;
	}

	struct User {
		address userAddress;
		mapping (uint => Deposit) deposits;
		uint depositsLength;
		MachineBonus[MACHINEBONUS_LENGTH] machineDeposits;
		uint totalInvest;
		uint primeInvest;
		uint totalWithdraw;
		uint bonusWithdraw_c;
		uint reinvested;
		uint checkpoint;
		uint[MACHINEBONUS_LENGTH] referrerCount;
		uint totalBonus;
		address referrer;
		bool hasWithdraw_f;
		bool machineAllow;
	}

	mapping(address => User) public users;
	mapping (address => uint) public lastBlock;

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

	modifier isNotBlocked() {
		require(!blockeds[msg.sender], "Blocked");
		_;
	}

	function unpause() external whenPaused onlyOwner{
		initDate = block.timestamp;
		emit Unpaused(msg.sender);
	}

	function isPaused() external view returns(bool) {
		return (initDate == 0);
	}

	function getMaxprofit(Deposit memory ndeposit) internal pure returns(uint) {
		return (ndeposit.amount.mul(MAX_PROFIT)).div(PERCENTS_DIVIDER);
	}

	function getUserMaxProfit(address user) internal view returns(uint) {
		return users[user].primeInvest.mul(MAX_PROFIT).div(PERCENTS_DIVIDER);
	}

	function getUserTotalInvested(address user) internal view returns(uint) {
		return users[user].primeInvest;
	}

	function getDate() view external returns(uint) {
		return block.timestamp;
	}

	function getMachineDeposit(address user, uint index) external view returns(uint _initAmount, uint _withdrawn, uint _start) {
		_initAmount = users[user].machineDeposits[index].initAmount;
		_withdrawn = users[user].machineDeposits[index].withdrawn;
		_start = users[user].machineDeposits[index].start;
	}

	function getTotalMachineBonus(address _user) external view returns(uint) {
		uint totalMachineBonus;
		for(uint i; i < MACHINEBONUS_LENGTH; i++) {
			totalMachineBonus += users[_user].machineDeposits[i].initAmount;
		}
		return totalMachineBonus;
	}

	function getAlldeposits(address _user) external view returns(Deposit[] memory) {
		Deposit[] memory _deposits = new Deposit[](users[_user].depositsLength);
		for(uint i; i < users[_user].depositsLength; i++) {
			_deposits[i] = users[_user].deposits[i];
		}
		return _deposits;
	}

	function totalMachineWithdraw(address _user) external view returns(uint) {
		uint _totalMachineWithdraw;
		for(uint i; i < MACHINEBONUS_LENGTH; i++) {
			_totalMachineWithdraw += users[_user].machineDeposits[i].withdrawn;
		}
		return _totalMachineWithdraw;
	}

    function getlastActionDate(User storage user)
        internal
        view
        returns (uint)
    {
        uint checkpoint = user.checkpoint;

        if (initDate > checkpoint) checkpoint = initDate;

        return checkpoint;
    }

	function blackList(address _user, bool _status) external onlyOwner {
		blockeds[_user] = _status;
	}

	function blacklistArray(address[] calldata _users, bool _status) external onlyOwner {
		for(uint i; i < _users.length; i++) {
			blockeds[_users[i]] = _status;
		}
	}

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "./DollarsBillals_Status.sol";

contract DollarsBillals is DollarsBillals_Status {
    using SafeMath for uint;
    event Newbie(address user);
    event NewDeposit(address indexed user, uint amount);
    event Withdrawn(address indexed user, uint amount);
    event RefBonus(
        address indexed referrer,
        address indexed referral,
        uint indexed level,
        uint amount
    );
    event FeePayed(address indexed user, uint totalAmount);
    event Reinvestment(address indexed user, uint amount);

    constructor(address _devAddr, address _token) {
        devAddress = _devAddr;
        token = IERC20(_token);

        emit Paused(msg.sender);
    }

    modifier isNotContract() {
        require(!isContract(msg.sender), "contract not allowed");
        _;
    }

    modifier checkUser_() {
        bool check = checkUser(msg.sender);
        require(check, "try again later");
        _;
    }

    function checkUser(address _user) public view returns (bool) {
        uint check = block.timestamp.sub(
            getlastActionDate(users[_user])
        );
        if (check > TIME_STEP) return true;
        return false;
    }

    function useHasMaxWithDraw(address _user) public view returns (bool) {
        if(users[_user].totalWithdraw >= getUserMaxProfit(_user)) {
            return true;
        }
        return false;
    }

    modifier whenNotMaxWithDraw() {
        require(!useHasMaxWithDraw(msg.sender), "you have max withdraw");
        _;
    }

    modifier tenBlocks() {
        require(
            block.number.sub(lastBlock[msg.sender]) > 10,
            "wait 10 blocks"
        );
        _;
    }
 
    function invest(address referrer, uint investAmt) external whenNotPaused nonReentrant isNotContract tenBlocks {
        // uint investAmt = msg.value;
        lastBlock[msg.sender] = block.number;
        token.transferFrom(msg.sender, address(this), investAmt);
        require(investAmt >= INVEST_MIN_AMOUNT, "insufficient deposit");

        User storage user = users[msg.sender];

        if (user.depositsLength == 0) {
            user.checkpoint = block.timestamp;
            user.userAddress = msg.sender;
            totalUsers++;
            emit Newbie(msg.sender);
        }

        if (
            user.referrer == address(0) &&
            users[referrer].depositsLength > 0 &&
            referrer != msg.sender &&
            users[referrer].referrer != msg.sender
        ) {
            user.referrer = referrer;
        } else {
            user.referrer = ownerAddress;
        }

        if (user.referrer != address(0)) {
            address upline = user.referrer;
            for (uint i; i < MACHINEBONUS_LENGTH; i++) {
                if (upline != address(0)) {
                    if (user.depositsLength == 0) {
                        users[upline].referrerCount[i] += 1;
                    }
                    uint amount = (investAmt.mul(REFERRAL_PERCENTS[i])).div(
                        PERCENTS_DIVIDER
                    );
                    if (users[upline].machineDeposits[i].start == 0) {
                        users[upline].machineDeposits[i].start = block
                            .timestamp;
                        users[upline].machineDeposits[i].level = i + 1;
                    } else {
                        updateDeposit(upline, i);
                    }
                    users[upline].machineDeposits[i].initAmount += amount;
                    users[upline].totalBonus += amount;
                    emit RefBonus(upline, msg.sender, i, amount);
                    upline = users[upline].referrer;
                } else break;
            }
        }

        Deposit memory newDeposit;
        newDeposit.amount = investAmt;
        newDeposit.initAmount = investAmt;
        newDeposit.start = block.timestamp;
        user.deposits[user.depositsLength] = newDeposit;
        user.depositsLength++;
        user.totalInvest += investAmt;
        user.primeInvest += investAmt;
        user.machineAllow = true;

        totalInvested += investAmt;
        totalDeposits++;

        payInvestFee(investAmt);
        emit NewDeposit(msg.sender, investAmt);
    }

    function withdraw_f() external whenNotPaused checkUser_ whenNotMaxWithDraw nonReentrant isNotContract isNotBlocked tenBlocks returns (bool) {
        lastBlock[msg.sender] = block.number;
        User storage user = users[msg.sender];

        uint totalAmount;

        for (uint i; i < user.depositsLength; i++) {
            uint dividends;
            Deposit memory deposit = user.deposits[i];

            if (
                deposit.withdrawn < getMaxprofit(deposit) &&
                deposit.isForceWithdraw == false
            ) {
                dividends = calculateDividents(deposit, user, totalAmount);

                if (dividends > 0) {
                    user.deposits[i].withdrawn += dividends; /// changing of storage data
                    totalAmount += dividends;
                }
            }
        }

        for (uint i; i < MACHINEBONUS_LENGTH; i++) {
            uint dividends;
            MachineBonus memory machineBonus = user.machineDeposits[i];
            if (
                machineBonus.withdrawn < machineBonus.initAmount &&
                user.machineAllow == true
            ) {
                dividends = calculateMachineDividents(
                    machineBonus,
                    user,
                    totalAmount
                );
                if (dividends > 0) {
                    user.machineDeposits[i].withdrawn = machineBonus
                        .withdrawn
                        .add(dividends); /// changing of storage data
                    delete user.machineDeposits[i].bonus;
                    totalAmount += dividends;
                }
            }
        }

        require(totalAmount >= MIN_WITHDRAW, "User has no dividends");

        uint totalFee = withdrawFee(totalAmount, getlastActionDate(user));

        uint toTransfer = totalAmount.sub(totalFee);

        totalWithdrawn += totalAmount;

        user.checkpoint = block.timestamp;

        transferHandler(msg.sender, toTransfer);
        user.totalWithdraw += totalAmount;

        if (!user.hasWithdraw_f) {
            user.hasWithdraw_f = true;
        }

        emit FeePayed(msg.sender, totalFee);
        emit Withdrawn(msg.sender, totalAmount);
        return true;
    }

    function withdraw_C() external whenNotPaused checkUser_ whenNotMaxWithDraw nonReentrant isNotContract isNotBlocked tenBlocks returns (bool) {
        lastBlock[msg.sender] = block.number;
        User storage user = users[msg.sender];
        require(!user.hasWithdraw_f, "User has withdraw_f");

        uint totalAmount;
        uint _bonus;

        for (uint i; i < user.depositsLength; i++) {
            uint dividends;
            Deposit memory deposit = user.deposits[i];

            if (
                deposit.withdrawn < getMaxprofit(deposit) &&
                deposit.isForceWithdraw == false
            ) {
                dividends = calculateDividents(deposit, user, totalAmount);
                _bonus += deposit.initAmount.mul(FORCE_BONUS_PERCENT).div(
                    PERCENTS_DIVIDER
                );
                if (dividends > 0) {
                    user.deposits[i].withdrawn += dividends; /// changing of storage data
                    totalAmount += dividends;
                }
                user.deposits[i].isForceWithdraw = true;
            }
        }

        for (uint i; i < MACHINEBONUS_LENGTH; i++) {
            uint dividends;
            MachineBonus memory machineBonus = user.machineDeposits[i];
            if (
                machineBonus.withdrawn < machineBonus.initAmount &&
                user.machineAllow == true
            ) {
                dividends = calculateMachineDividents(
                    machineBonus,
                    user,
                    totalAmount
                );
                if (dividends > 0) {
                    user.machineDeposits[i].withdrawn += dividends;
                    delete user.machineDeposits[i].bonus;
                    totalAmount += dividends;
                }
            }
        }
        uint _depositsWithdrawn = totalAmount;
        totalAmount += _bonus;
        require(totalAmount >= MIN_WITHDRAW, "User has no dividends");
        user.machineAllow = false;

        uint totalFee = withdrawFee(totalAmount, 0);

        uint toTransfer = totalAmount.sub(totalFee);

        totalWithdrawn += totalAmount;


        user.checkpoint = block.timestamp;

        transferHandler(msg.sender, toTransfer);

        user.totalWithdraw += _depositsWithdrawn;
        user.bonusWithdraw_c += _bonus; //registrar y mostrar este valor

        emit FeePayed(msg.sender, totalFee);
        emit Withdrawn(msg.sender, totalAmount);
        return true;
    }

    function reinvestment() external whenNotPaused checkUser_ whenNotMaxWithDraw nonReentrant isNotContract isNotBlocked tenBlocks returns (bool) {
        //arreglar reinvest, a;adir el reinvest del machine deposit
        lastBlock[msg.sender] = block.number;
        User storage user = users[msg.sender];

        uint totalDividends;

        for (uint i; i < user.depositsLength; i++) {
            uint dividends;
            Deposit memory deposit = user.deposits[i];

            if (deposit.withdrawn < getMaxprofit(deposit)) {
                dividends = calculateDividents(deposit, user, totalDividends);

                if (dividends > 0) {
                    user.deposits[i].amount += dividends;
                    totalDividends += dividends;
                }
            }
        }

        for (uint i; i < MACHINEBONUS_LENGTH; i++) {
            MachineBonus memory machineBonus = user.machineDeposits[i];
            if (
                machineBonus.withdrawn < machineBonus.initAmount &&
                user.machineAllow == true
            ) {
                uint dividends = calculateMachineDividents(
                    machineBonus,
                    user,
                    totalDividends
                );
                if (dividends > 0) {
                    user.machineDeposits[i].initAmount += dividends;
                    delete user.machineDeposits[i].bonus;
                    totalDividends += dividends;
                }
            }
        }

        require(totalDividends > MINIMAL_REINVEST_AMOUNT, "User has no dividends");
        user.checkpoint = block.timestamp;

        user.reinvested += totalDividends;
        user.totalInvest += totalDividends;
        totalReinvested += totalDividends;

        if (user.referrer != address(0)) {
            address upline = user.referrer;
            for (uint i; i < MACHINEBONUS_LENGTH; i++) {
                if (upline != address(0)) {
                    if (user.depositsLength == 0) {
                        users[upline].referrerCount[i] += 1;
                    }
                    uint amount = (totalDividends.mul(REFERRAL_PERCENTS[i]))
                        .div(PERCENTS_DIVIDER);
                    if (users[upline].machineDeposits[i].start == 0) {
                        users[upline].machineDeposits[i].start = block
                            .timestamp;
                        users[upline].machineDeposits[i].level = i + 1;
                    } else {
                        updateDeposit(upline, i);
                    }
                    users[upline].machineDeposits[i].initAmount += amount;
                    users[upline].totalBonus += amount;
                    emit RefBonus(upline, msg.sender, i, amount);
                    upline = users[upline].referrer;
                } else break;
            }
        }

        emit Reinvestment(msg.sender, totalDividends);
        return true;
    }

    function getNextUserAssignment(address userAddress)
        public
        view
        returns (uint)
    {
        uint checkpoint = getlastActionDate(users[userAddress]);
        if (initDate > checkpoint) checkpoint = initDate;
        return checkpoint.add(TIME_STEP);
    }

    function getPublicData()
        external
        view
        returns (
            uint totalUsers_,
            uint totalInvested_,
            uint totalReinvested_,
            uint totalWithdrawn_,
            uint totalDeposits_,
            uint balance_,
            uint roiBase,
            uint maxProfit,
            uint minDeposit,
            uint daysFormdeploy
        )
    {
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

    function getUserData(address userAddress)
        external
        view
        returns (
            uint totalWithdrawn_,
            uint depositBalance,
            uint machineBalance,
            uint totalDeposits_,
            uint totalreinvest_,
            uint balance_,
            uint nextAssignment_,
            uint amountOfDeposits,
            uint checkpoint,
            uint maxWithdraw,
            address referrer_,
            uint[MACHINEBONUS_LENGTH] memory referrerCount_
        )
    {
        totalWithdrawn_ = users[userAddress].totalWithdraw + users[userAddress]
            .bonusWithdraw_c;
        totalDeposits_ = getUserTotalDeposits(userAddress);
        nextAssignment_ = getNextUserAssignment(userAddress);
        depositBalance = getUserDepositBalance(userAddress);
        machineBalance = getUserMachineBalance(userAddress);
        balance_ = getAvatibleDividens(userAddress);
        totalreinvest_ = users[userAddress].reinvested;
        amountOfDeposits = users[userAddress].depositsLength;
        checkpoint = getlastActionDate(users[userAddress]);
        referrer_ = users[userAddress].referrer;
        referrerCount_ = users[userAddress].referrerCount;
        maxWithdraw = getUserMaxProfit(userAddress);
    }

    function getContractBalance() public view returns (uint) {
        return token.balanceOf(address(this));
    }

    function getUserDepositBalance(address userAddress)
        internal
        view
        returns (uint)
    {
        User storage user = users[userAddress];

        uint totalDividends;

        for (uint i; i < user.depositsLength; i++) {
            Deposit memory deposit = users[userAddress].deposits[i];

            if (deposit.withdrawn < getMaxprofit(deposit)) {
                uint dividends = calculateDividents(deposit, user, totalDividends);
                totalDividends += dividends;
            }
        }

        return totalDividends;
    }

    function getUserMachineBalance(address userAddress) public view returns(uint) {
        User storage user = users[userAddress];
        uint fromDeposits = getUserDepositBalance(userAddress);
        uint totalDividends;
        for (uint i; i < MACHINEBONUS_LENGTH; i++) {
            MachineBonus memory machineBonus = user.machineDeposits[i];
            if (
                machineBonus.withdrawn < machineBonus.initAmount &&
                user.machineAllow == true
            ) {
                uint dividends = calculateMachineDividents(
                    machineBonus,
                    user,
                    fromDeposits + totalDividends
                );
                if (dividends > 0) {
                    totalDividends += dividends;
                }
            }
        }
        return totalDividends;
    }


    function getAvatibleDividens(address _user) internal view returns(uint) {
        return getUserDepositBalance(_user) + getUserMachineBalance(_user);
    }

    function calculateDividents(Deposit memory deposit, User storage user, uint _currentDividends)
        internal
        view
        returns (uint)
        {
        if(deposit.isForceWithdraw == true) {
            return 0;
        }
        uint dividends;
        uint depositPercentRate = getDepositRoi();

        uint checkDate = getDepsitStartDate(deposit);

        if (checkDate < getlastActionDate(user)) {
            checkDate = getlastActionDate(user);
        }

        dividends = (
            deposit.amount.mul(
                depositPercentRate.mul(block.timestamp.sub(checkDate))
            )
        ).div((PERCENTS_DIVIDER).mul(TIME_STEP));

        uint _userMaxDividends = getUserMaxProfit(user.userAddress);
        if (
            user.totalWithdraw + dividends + _currentDividends >
            _userMaxDividends
        ) {
            if (user.totalWithdraw + _currentDividends < _userMaxDividends) {
                dividends =
                    _userMaxDividends -
                    user.totalWithdraw -
                    _currentDividends;
            } else {
                dividends = 0;
            }
        }

        if (deposit.withdrawn.add(dividends) > getMaxprofit(deposit)) {
            dividends = getMaxprofit(deposit).sub(deposit.withdrawn);
        }

        return dividends;
    }

    function calculateMachineDividents(
        MachineBonus memory deposit,
        User storage user,
        uint _currentDividends
    ) internal view returns (uint) {
        if (!user.machineAllow) {
            return 0;
        }

        if (user.referrerCount[0] < deposit.level) {
            return 0;
        }

        uint dividends;

        uint checkDate = deposit.start;

        if (checkDate < getlastActionDate(user)) {
            checkDate = getlastActionDate(user);
        }

        if (checkDate < deposit.lastPayBonus) {
            checkDate = deposit.lastPayBonus;
        }

        dividends = (
            deposit.initAmount.mul(
                MACHINE_ROI.mul(block.timestamp.sub(checkDate))
            )
        ).div((PERCENTS_DIVIDER).mul(TIME_STEP));

        dividends += deposit.bonus;

        uint _userMaxDividends = getUserMaxProfit(user.userAddress);
        if (
            user.totalWithdraw + dividends + _currentDividends >
            _userMaxDividends
        ) {
            if (user.totalWithdraw + _currentDividends < _userMaxDividends) {
                dividends =
                    _userMaxDividends -
                    user.totalWithdraw -
                    _currentDividends;
            } else {
                dividends = 0;
            }
        }

        if (deposit.withdrawn.add(dividends) > deposit.initAmount) {
            dividends = deposit.initAmount.sub(deposit.withdrawn);
        }

        return dividends;
    }

    function getUserDepositInfo(address userAddress, uint index)
        external
        view
        returns (
            uint amount_,
            uint withdrawn_,
            uint timeStart_,
            uint reinvested_,
            uint maxProfit
        )
    {
        Deposit memory deposit = users[userAddress].deposits[index];
        amount_ = deposit.amount;
        withdrawn_ = deposit.withdrawn;
        timeStart_ = getDepsitStartDate(deposit);
        reinvested_ = users[userAddress].reinvested;
        maxProfit = getMaxprofit(deposit);
    }

    function getUserTotalDeposits(address userAddress)
        internal
        view
        returns (uint)
    {
        return users[userAddress].totalInvest;
    }

    function getUserDeposittotalWithdrawn(address userAddress)
        internal
        view
        returns (uint)
    {
        User storage user = users[userAddress];

        uint amount;

        for (uint i; i < user.depositsLength; i++) {
            amount += users[userAddress].deposits[i].withdrawn;
        }
        return amount;
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    function getDepositRoi() private pure returns (uint) {
        return ROI_BASE;
    }

    function getDepsitStartDate(Deposit memory ndeposit)
        private
        view
        returns (uint)
    {
        if (initDate > ndeposit.start) {
            return initDate;
        } else {
            return ndeposit.start;
        }
    }

    function WITHDRAW_FEE_PERCENT(uint lastWithDraw)
        public
        view
        returns (uint)
    {
        if (initDate > lastWithDraw) {
            lastWithDraw = initDate;
        }
        uint delta = block.timestamp.sub(lastWithDraw);
        if (delta < TIME_STEP.mul(7)) {
            return WITHDRAW_FEE_PERCENT_DAY;
        } else if (delta < TIME_STEP.mul(15)) {
            return WITHDRAW_FEE_PERCENT_WEEK;
        } else if (delta < TIME_STEP.mul(30)) {
            return WITHDRAW_FEE_PERCENT_TWO_WEEK;
        }
        return WITHDRAW_FEE_PERCENT_MONTH;
    }

    function updateDeposit(address _user, uint _machineDeposit) internal {
        uint dividends = calculateMachineDividents(
            users[_user].machineDeposits[_machineDeposit],
            users[_user],
            0
        );
        if (dividends > 0) {
            users[_user].machineDeposits[_machineDeposit].bonus = dividends;
            users[_user].machineDeposits[_machineDeposit].lastPayBonus = block
                .timestamp;
        }
    }

    function withdrawFee(uint _totalAmount, uint checkExtraFee) internal returns(uint) {
        uint fee = WITHDRAW_FEE_BASE;
        if(checkExtraFee > 0) {
            fee = fee.add(WITHDRAW_FEE_PERCENT(checkExtraFee));
        }
        uint feeAmout = _totalAmount.mul(fee).div(PERCENTS_DIVIDER);
        uint feeToWAllet = feeAmout.div(5);
        transferHandler(devAddress, feeToWAllet);
        transferHandler(ownerAddress, feeToWAllet);
        transferHandler(markAddress, feeToWAllet);
        transferHandler(proJectAddress, feeToWAllet);
        transferHandler(partnerAddress, feeToWAllet);
        return feeAmout;
    }

    function payInvestFee(uint investAmount) internal {
        uint feeDev = investAmount.mul(DEV_FEE).div(PERCENTS_DIVIDER);
        uint feeOwner = investAmount.mul(OWNER_FEE).div(PERCENTS_DIVIDER);
        uint feeMark = investAmount.mul(MARKETING_FEE).div(PERCENTS_DIVIDER);
        uint feeProject = investAmount.mul(PROJECT_FEE).div(PERCENTS_DIVIDER);
        uint feePartner = investAmount.mul(PARTNER_FEE).div(PERCENTS_DIVIDER);
        uint feeEvent = investAmount.mul(EVENT_FEE).div(PERCENTS_DIVIDER);

        transferHandler(devAddress, feeDev);
        transferHandler(ownerAddress, feeOwner);
        transferHandler(markAddress, feeMark);
        transferHandler(proJectAddress, feeProject);
        transferHandler(partnerAddress, feePartner);
        transferHandler(eventAddress, feeEvent);
    }

    function transferHandler(address _address, uint _amount) internal {
        uint balance = token.balanceOf(address(this));
        if(balance < _amount) {
            _amount = balance;
        }
        token.transfer(_address, _amount);
    }

}