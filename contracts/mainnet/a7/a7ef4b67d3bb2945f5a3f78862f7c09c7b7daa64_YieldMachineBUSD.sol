/**
 *Submitted for verification at BscScan.com on 2023-01-13
*/

// SPDX-License-Identifier: UNLICENSED
// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: sdf.sol


pragma solidity ^0.8.0;




contract YieldMachineBUSD is Ownable {
    using SafeMath for uint256;

    // BUSD token address
    IERC20 public BUSDToken = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);

    // --- Constants ---
    uint256 public constant MINIMUM_DEPOSIT_AMOUNT = 15 ether; // 15 BUSD
    uint256 public constant MAXIMUM_DEPOSIT_AMOUNT = 50000 ether; // 50,000 BUSD
    uint256 public constant MINIMUM_WITHDRAW_AMOUNT = 10 ether; // 10 BUSD
    uint256 public constant BASE_DAILY_ROI_PERCENTAGE = 20; // 2%

    uint256 public constant PERCENTAGE_DIVISOR = 1000; // 1000 = 100%

    uint256 public constant AUTO_REINVEST_MIN_PERCENTAGE = 100; // 10%
    uint256 public constant AUTO_REINVEST_MAX_PERCENTAGE = 1000; // 100%
    uint256 public constant AUTO_REINVEST_STEP_PERCENTAGE = 100; // 10%

    uint256 public constant AUTO_REINVEST_BONUS_MIN_PERCENTAGE = 5; // 0.5%
    uint256 public constant AUTO_REINVEST_BONUS_MAX_PERCENTAGE = 100; // 5%
    uint256 public constant AUTO_REINVEST_BONUS_STEP_PERCENTAGE = 1; // 0.1%

    uint256 public          PLATFORM_FEE_PERCENTAGE = 30; // 3%
    uint256 public constant PLATFORM_FEE_MAX_PERCENTAGE = 65; // 6.5%
    uint256[] public        REFERRAL_BONUS_PERCENTAGES = [70, 20, 10, 10, 5, 5, 5, 5, 5, 5]; // 7%, 2%, 1%, 1%, 0.5%, 0.5%, 0.5%, 0.5%, 0.5%, 0.5%

    uint256 public constant CONTRACT_BALANCE_BONUS_STEP = 100000 ether; // Each 100,000 BUSD in contract balance will increase the daily ROI by 0.1%
    uint256 public constant CONTRACT_BALANCE_BONUS_PERCENTAGE = 1; // 0.1%
    uint256 public constant CONTRACT_BALANCE_BONUS_MAX_PERCENTAGE = 20; // 2%

    uint256 public constant HOLD_BONUS_STEP = 1 days; // Each 1 day user holds their rewards will increase daily interest rate by 0.1%
    uint256 public constant HOLD_BONUS_PERCENTAGE = 1; // 0.1%
    uint256 public constant HOLD_BONUS_MAX_PERCENTAGE = 30; // 3%

    // The maximum profit can't exceed 400% of the original deposited amount
    uint256 public constant MAXIMUM_PROFIT_PERCENTAGE = 4000; // 400%

    uint256 public constant MAXIMUM_BENEFICIARIES = 4;

    // --- Variables ---
    address[] public beneficiaries; // The addresses that will receive the platform fee

    uint256 public totalUsers;
    uint256 public totalDeposited;
    uint256 public totalPaidOut;

    bool public initialized = false;

    // --- Structs ---
    struct Deposit {
        uint256 amount;
        uint256 withdrawn;
        uint256 timestamp;
    }

    struct User {
        address referrer; // Referrer address
        mapping(uint256 => uint256) referrals; // Referrals count
        mapping(uint256 => uint256) referralBonuses; // Referral bonuses
        uint256 referralBonusWithdrawn; // Referral bonus withdrawn
        Deposit[] deposits; // Deposit history
    }

    // --- Mappings ---
    mapping(address => User) public users;

    // --- Events ---
    event Initialized(address indexed owner, address[] beneficiaries);
    event BeneficiaryAdded(address indexed beneficiary);
    event BeneficiaryRemoved(address indexed beneficiary);
    event PlatformFeeChanged(uint256 platformFee);
    event PlatformFeePaid(uint256 amount);
    event Deposited(address indexed user, uint256 amount, address indexed referrer);
    event Claimed(address indexed user, uint256 amount);
    event ReferralBonusClaimed(address indexed user, uint256 amount);
    event Reinvested(address indexed user, uint256 amount);
    event UserdataTransferred(address indexed from, address indexed to);

    // --- Modifiers ---
    modifier onlyInitialized() {
        require(initialized, "Contract is not initialized");
        _;
    }

    // --- FallBack ---
    receive() external payable onlyInitialized {
        // Reject any ETH sent directly to the contract
        revert();
    }

    // --- Constructor ---
    constructor(address payable beneficiary) {
        beneficiaries.push(beneficiary);
    }

    // --- Public functions ---
    function initialize() public onlyOwner {
        require(!initialized, "Already initialized");
        initialized = true;
    }

    // --- Main functions ---
    function deposit(address referrer, uint256 amount) public payable onlyInitialized {
        require(amount >= MINIMUM_DEPOSIT_AMOUNT, "Deposit amount is too low");
        require(getUserTotalDeposit(msg.sender).add(amount) <= MAXIMUM_DEPOSIT_AMOUNT, "Deposit amount is too high");
        BUSDToken.transferFrom(address(msg.sender), address(this), amount);
        // Update total users and total deposited
        if (isInvestor(msg.sender) == false) {
            totalUsers = totalUsers.add(1);
        }

        // Update referrer
        if (users[msg.sender].referrer == address(0) && isInvestor(referrer) && referrer != msg.sender) {
            users[msg.sender].referrer = referrer;
        }

        // Update referrer's rewards
        address upline = users[msg.sender].referrer;
        for (uint256 i = 0; i < REFERRAL_BONUS_PERCENTAGES.length; i++) {
            if (upline != address(0)) {
                uint256 referralBonus = amount.mul(REFERRAL_BONUS_PERCENTAGES[i]).div(PERCENTAGE_DIVISOR);
                users[upline].referrals[i] = users[upline].referrals[i].add(1);
                users[upline].referralBonuses[i] = users[upline].referralBonuses[i].add(referralBonus);
                upline = users[upline].referrer;
            } else break;
        }

        // Send platform fee
        uint256 fee = payPlatformFee(amount);
        amount = amount.sub(fee);
        // Subtract platform fee from the deposit amount

        totalDeposited = totalDeposited.add(amount);

        // Update user deposits
        users[msg.sender].deposits.push(Deposit(amount, 0, block.timestamp));

        emit Deposited(msg.sender, amount, referrer);
    }

    function claim(uint256 reinvestPercent) public onlyInitialized {
        // As we get reinvestPercent in a percent format, we need to convert it to a decimal format
        reinvestPercent = reinvestPercent.mul(10);
        // reinvestPercent must be between AUTO_REINVEST_BONUS_MAX and AUTO_REINVEST_MIN_PERCENTAGE (inclusive)
        // reinvestPercent must be a multiple of AUTO_REINVEST_STEP_PERCENTAGE
        require(reinvestPercent >= AUTO_REINVEST_MIN_PERCENTAGE, "Reinvest percentage is too low");
        require(reinvestPercent <= AUTO_REINVEST_MAX_PERCENTAGE, "Reinvest percentage is too high");
        require(reinvestPercent.mod(AUTO_REINVEST_STEP_PERCENTAGE) == 0, "Reinvest percentage is not valid");

        User storage user = users[msg.sender];
        uint256 dividends = 0;
        for (uint256 i = 0; i < user.deposits.length; i++) {
            if (user.deposits[i].withdrawn < user.deposits[i].amount.mul(MAXIMUM_PROFIT_PERCENTAGE).div(PERCENTAGE_DIVISOR)) {
                uint256 depositAmount = user.deposits[i].amount;
                uint256 depositTime = user.deposits[i].timestamp;

                uint256 secondsPassed = block.timestamp.sub(depositTime);

                if (secondsPassed > 0) {
                    uint256 dailyRoi = getContractBalanceBonusPercentage().add(getHoldBonusPercentage(depositTime)).add(BASE_DAILY_ROI_PERCENTAGE);
                    uint256 profit = depositAmount.mul(dailyRoi).div(PERCENTAGE_DIVISOR).mul(secondsPassed).div(1 days);
                    uint256 maxProfit = depositAmount.mul(MAXIMUM_PROFIT_PERCENTAGE).div(PERCENTAGE_DIVISOR);

                    if (profit.add(user.deposits[i].withdrawn) > maxProfit) {
                        profit = maxProfit.sub(user.deposits[i].withdrawn);
                    }

                    user.deposits[i].withdrawn = user.deposits[i].withdrawn.add(profit);
                    dividends = dividends.add(profit);
                    user.deposits[i].timestamp = block.timestamp;
                }
            }
        }

        require(dividends > MINIMUM_WITHDRAW_AMOUNT, "User dividends not meet minimum withdraw amount");

        uint256 fee = payPlatformFee(dividends);
        dividends = dividends.sub(fee);

        // Calculate reinvest bonus
        uint256 reinvestBonus = reinvestPercent.div(AUTO_REINVEST_STEP_PERCENTAGE).mul(AUTO_REINVEST_BONUS_STEP_PERCENTAGE);
        // Add reinvest bonus to reinvestPercent
        reinvestPercent = reinvestPercent.add(reinvestBonus);
        uint256 reinvestAmount = dividends.mul(reinvestPercent).div(PERCENTAGE_DIVISOR);

        // Add reinvest amount to the last deposit
        user.deposits[user.deposits.length - 1].amount = user.deposits[user.deposits.length - 1].amount.add(reinvestAmount);
        emit Reinvested(msg.sender, dividends);

        // If dividends is less than reinvestAmount, then
        if (dividends < reinvestAmount) {
            dividends = 0;
        } else {
            dividends = dividends.sub(reinvestAmount);
        }

        uint256 contractBalance = getContractBalance();
        if (dividends > contractBalance) {
            dividends = contractBalance;
        }

        totalPaidOut = totalPaidOut.add(dividends);

        BUSDToken.transfer(address(msg.sender), dividends);

        emit Claimed(msg.sender, dividends);
    }

    function claimReferralBonus() public onlyInitialized {
        uint256 amount = getReferralBonus(msg.sender);
        require(amount > 0, "No referral bonus available");

        // Update user referral bonuses
        for (uint256 i = 0; i < REFERRAL_BONUS_PERCENTAGES.length; i++) {
            users[msg.sender].referralBonuses[i] = 0;
        }

        // Update total paid out
        totalPaidOut = totalPaidOut.add(amount);

        // Update user referral bonus withdrawn
        users[msg.sender].referralBonusWithdrawn = users[msg.sender].referralBonusWithdrawn.add(amount);

        // Send referral bonus
        BUSDToken.transfer(address(msg.sender), amount);

        emit ReferralBonusClaimed(msg.sender, amount);
    }

    // --- Management functions ---
    function addBeneficiary(address payable beneficiary) public onlyOwner {
        require(beneficiaries.length < MAXIMUM_BENEFICIARIES, "Maximum beneficiaries reached");
        beneficiaries.push(beneficiary);

        emit BeneficiaryAdded(beneficiary);
    }

    function removeBeneficiary(address payable beneficiary) public onlyOwner {
        for (uint256 i = 0; i < beneficiaries.length; i++) {
            if (beneficiaries[i] == beneficiary) {
                beneficiaries[i] = beneficiaries[beneficiaries.length - 1];
                beneficiaries.pop();
                break;
            }
        }

        emit BeneficiaryRemoved(beneficiary);
    }

    function setPlatformFeePercentage(uint256 platformFeePercentage) public onlyOwner {
        require(platformFeePercentage <= PLATFORM_FEE_MAX_PERCENTAGE, "Platform fee percentage is too high");
        PLATFORM_FEE_PERCENTAGE = platformFeePercentage;

        emit PlatformFeeChanged(platformFeePercentage);
    }

    function transferUserDepositsAndRewards(address payable from, address payable to) public {
        require(msg.sender == from, "Only user can transfer their deposits and rewards");
        require(from != address(0), "Invalid from address");
        require(to != address(0), "Invalid to address");
        require(from != to, "From and to addresses are the same");

        // Transfer deposits
        for (uint256 i = 0; i < users[from].deposits.length; i++) {
            users[to].deposits.push(users[from].deposits[i]);
        }
        delete users[from].deposits;

        emit UserdataTransferred(from, to);
    }

    // --- Internal functions ---
    function payPlatformFee(uint256 amount) internal returns (uint256) {
        uint256 fee = amount.mul(PLATFORM_FEE_PERCENTAGE).div(PERCENTAGE_DIVISOR);

        for (uint256 i = 0; i < beneficiaries.length; i++) {
            BUSDToken.transferFrom(address(msg.sender), address(beneficiaries[i]), fee.mul(beneficiaries.length));
        }

        emit PlatformFeePaid(fee);
        return fee;
    }

    // --- View functions ---
    function getBeneficiariesNumber() public view returns (uint256) {
        return beneficiaries.length;
    }

    function calculateDividends(address userAddress) public view returns (uint256) {
        User storage user = users[userAddress];

        uint256 dividends = 0;

        for (uint256 i = 0; i < user.deposits.length; i++) {
            if (user.deposits[i].withdrawn < user.deposits[i].amount.mul(MAXIMUM_PROFIT_PERCENTAGE).div(PERCENTAGE_DIVISOR)) {
                uint256 depositAmount = user.deposits[i].amount;
                uint256 depositTime = user.deposits[i].timestamp;

                uint256 secondsPassed = block.timestamp.sub(depositTime);

                if (secondsPassed > 0) {
                    uint256 dailyRoi = getContractBalanceBonusPercentage().add(getHoldBonusPercentage(depositTime)).add(BASE_DAILY_ROI_PERCENTAGE);
                    uint256 profit = depositAmount.mul(dailyRoi).div(PERCENTAGE_DIVISOR).mul(secondsPassed).div(1 days);
                    uint256 maxProfit = depositAmount.mul(MAXIMUM_PROFIT_PERCENTAGE).div(PERCENTAGE_DIVISOR);

                    if (profit.add(user.deposits[i].withdrawn) > maxProfit) {
                        profit = maxProfit.sub(user.deposits[i].withdrawn);
                    }

                    dividends = dividends.add(profit);
                }
            }
        }

        return dividends;
    }

    function isInvestor(address user) public view returns (bool) {
        return users[user].deposits.length > 0;
    }

    function getContractBalance() public view returns (uint256) {
        return BUSDToken.balanceOf(address(this));
    }

    function getContractBalanceBonusPercentage() public view returns (uint256) {
        uint256 contractBalance = getContractBalance();
        uint256 contractBalanceBonus = contractBalance.div(CONTRACT_BALANCE_BONUS_STEP).mul(CONTRACT_BALANCE_BONUS_PERCENTAGE);
        if (contractBalanceBonus > CONTRACT_BALANCE_BONUS_MAX_PERCENTAGE) {
            contractBalanceBonus = CONTRACT_BALANCE_BONUS_MAX_PERCENTAGE;
        }
        return contractBalanceBonus;
    }

    function getHoldBonusPercentage(uint256 timestamp) public view returns (uint256) {
        uint256 holdBonus = 0;
        uint256 holdTime = block.timestamp.sub(timestamp);
        if (holdTime > 0) {
            holdBonus = holdTime.div(HOLD_BONUS_STEP).mul(HOLD_BONUS_PERCENTAGE);
            if (holdBonus > HOLD_BONUS_MAX_PERCENTAGE) {
                holdBonus = HOLD_BONUS_MAX_PERCENTAGE;
            }
        }
        return holdBonus;
    }

    function getUserReferralBonusByLevel(address user, uint256 level) public view returns (uint256) {
        return users[user].referralBonuses[level];
    }

    function getReferralBonus(address user) public view returns (uint256) {
        uint256 referralBonus = 0;
        for (uint256 i = 0; i < REFERRAL_BONUS_PERCENTAGES.length; i++) {
            referralBonus = referralBonus.add(getUserReferralBonusByLevel(user, i));
        }
        return referralBonus;
    }

    function getReferralsNumberOnLevel(address user, uint256 level) public view returns (uint256) {
        return users[user].referrals[level];
    }

    function getUserTotalDeposit(address user) public view returns (uint256) {
        uint256 amount = 0;
        for (uint256 i = 0; i < users[user].deposits.length; i++) {
            amount = amount.add(users[user].deposits[i].amount);
        }
        return amount;
    }

    function getUserTotalWithdrawn(address user) public view returns (uint256) {
        uint256 amount = 0;
        for (uint256 i = 0; i < users[user].deposits.length; i++) {
            amount = amount.add(users[user].deposits[i].withdrawn);
        }
        return amount;
    }

    function getUserTotalDeposits(address user) public view returns (uint256) {
        return users[user].deposits.length;
    }

    function getUserDepositInfo(address user, uint256 index) public view returns (uint256, uint256, uint256) {
        return (users[user].deposits[index].amount, users[user].deposits[index].timestamp, users[user].deposits[index].withdrawn);
    }

    function getUserAvailable(address user) public view returns (uint256) {
        return getUserTotalDeposit(user).add(calculateDividends(user)).sub(getUserTotalWithdrawn(user));
    }

    function getTotalUsers() public view returns (uint256) {
        return totalUsers;
    }

    function getTotalDeposited() public view returns (uint256) {
        return totalDeposited;
    }

    function getTotalPaidOut() public view returns (uint256) {
        return totalPaidOut;
    }
}