/**
 *Submitted for verification at BscScan.com on 2022-09-19
*/

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


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

// File: contracts/Poolsmine.sol


pragma solidity ^0.8.3;





contract TestPools  is ReentrancyGuard {
    using SafeMath for uint256;

    enum PlanType {
        ANYTIME,
        ENDTIME
    }

    event Newbie(address user);
    event NewDeposit(
        address indexed user,
        uint8 plan,
        uint256 percent,
        uint256 amount,
        uint256 start
    );
    event Withdrawn(address indexed user, uint256 amount);
    event RefBonus(
        address indexed referrer,
        address indexed referral,
        uint256 amount
    );
    event FeePayed(address indexed user, uint256 amount);
    event WalletCreated(address indexed wallet, uint percent);
    event WalletRemoved(address indexed wallet);

    uint256 public constant INVEST_MIN_AMOUNT = 0.001 ether;
    uint256 public constant PERCENT_REFERRAL = 10 * 1E18;
    uint256 public constant PERCENT_COMMISSION_FEE = 1 * 1E18;
    uint256 public constant PERCENT_STEP = 5 * 1E17;
    uint256 public constant TIME_STEP = 1 days;
    uint256 public constant PERCENT_LIMIT = 100 * 1E18;
    address public owner;
    address public commissionWallet;
    uint256 public totalInvestors;

    struct Deposit {
        uint8 plan;
        uint256 percent;
        uint256 amount;
        uint256 start;
    }

    struct User {
        Deposit[] deposits;
        uint256 checkpoint;
        address referrer;
        uint256 bonus;
    }

    struct Plan {
        uint256 time;
        uint256 percent;
        PlanType planType;
    }

    struct Wallet {
        bool allowed;
        uint256 percent;
    }

    mapping(address => User) public users;

    mapping(uint256 => Plan) public plans;
    uint256 public planIndex;

    mapping(address => Wallet) internal whitelist;
    address[] public whitelisted;

    constructor(address _commissionWallet) {
        owner = msg.sender;
        commissionWallet = _commissionWallet;

        plans[planIndex++] = Plan(14, 5 * 1E17, PlanType.ENDTIME);
        plans[planIndex++] = Plan(21, 1 * 1E18, PlanType.ENDTIME);
        plans[planIndex++] = Plan(28, 125 * 1E16, PlanType.ENDTIME);
        plans[planIndex++] = Plan(0, 1 * 1E18, PlanType.ANYTIME);
    }

    function invest(address _referrer, uint8 _planId) public payable {
        require(msg.value >= INVEST_MIN_AMOUNT, "Minimum required");
        require(plans[_planId].percent != 0, "Invalid plan");
        uint256 total = msg.value;
        uint256 amount = 0;

        uint256 fee = getValuePercentageFromWei(total, PERCENT_COMMISSION_FEE);
        payable(commissionWallet).transfer(fee);
        total = total.sub(fee);
        emit FeePayed(msg.sender, fee);

        User storage user = users[msg.sender];

        if (user.deposits.length == 0) {
            totalInvestors.add(1);
            user.checkpoint = block.timestamp;
            emit Newbie(msg.sender);
        }

        if (
            user.referrer == address(0) &&
            users[_referrer].deposits.length > 0 &&
            _referrer != msg.sender
        ) {
            user.referrer = _referrer;
        }

        if (user.referrer != address(0)) {
            uint256 referrerPercent = PERCENT_REFERRAL;
            if (isWhitelisted(user.referrer)) {
                referrerPercent = whitelist[user.referrer].percent;
            }

            amount = getValuePercentageFromWei(msg.value, referrerPercent);

            users[user.referrer].bonus = users[user.referrer].bonus.add(amount);
            emit RefBonus(user.referrer, msg.sender, amount);
        } else {
            amount = getValuePercentageFromWei(msg.value, PERCENT_REFERRAL);

            users[owner].bonus = users[owner].bonus.add(amount);
            emit RefBonus(owner, msg.sender, amount);
        }

        total = total.sub(amount);

        user.deposits.push(
            Deposit(_planId, plans[_planId].percent, total, block.timestamp)
        );

        emit NewDeposit(
            msg.sender,
            _planId,
            plans[_planId].percent,
            msg.value,
            block.timestamp
        );
    }

    // Withdraw user investiments
    // @param _includeDeposits include deposit, if is true user will remove investment deposit otherwise only profit will be withdrawn
    function withdraw(bool _includeDeposits) public payable nonReentrant {
        User storage user = users[msg.sender];
        require(user.deposits.length > 0, "User does not exists");

        uint totalAmount = getUserProfit(
            msg.sender,
            block.timestamp,
            _includeDeposits
        );

        if (user.bonus > 0) {
            totalAmount = totalAmount.add(user.bonus);
        }

        require(
            totalAmount > 0 && totalAmount < address(this).balance,
            "Insuficient funds"
        );

        if (_includeDeposits) {
            removeDeposits(msg.sender, block.timestamp);
        }

        user.checkpoint = block.timestamp;
        user.bonus = 0;

        payable(msg.sender).transfer(totalAmount);

        emit Withdrawn(msg.sender, totalAmount);
    }

    // Remove User Deposits
    // @param _userAddress User address
    // @param _endTime Limit period time in seconds
    function removeDeposits(address _userAddress, uint256 _endTime) internal {
        User storage user = users[_userAddress];
        uint256 startIndex = 0;
        bool hasNext = false;
        do {
            hasNext = false;
            for (uint i = startIndex; i < user.deposits.length; i++) {
                Deposit memory deposit = user.deposits[i];
                Plan memory plan = plans[deposit.plan];

                uint256 startTime = user.checkpoint > deposit.start
                    ? user.checkpoint
                    : deposit.start;
                uint256 time = _endTime.sub(startTime).div(TIME_STEP);

                if (
                    (plan.planType == PlanType.ANYTIME ||
                        (plan.planType == PlanType.ENDTIME &&
                            time >= plan.time))
                ) {
                    user.deposits[i] = user.deposits[user.deposits.length - 1];
                    user.deposits.pop();
                    startIndex = i;
                    hasNext = true;
                    break;
                }
            }
        } while (hasNext == true);
    }

    // Get User Profit
    // @param _userAddress User address
    // @param _endTime Limit time in seconds
    // @param _includeDeposits include deposit amounts to be calculated
    function getUserProfit(
        address _userAddress,
        uint256 _endTime,
        bool _includeDeposits
    ) public view returns (uint256) {
        User memory user = users[_userAddress];
        uint256 profit = 0;
        for (uint i = 0; i < user.deposits.length; i++) {
            Deposit memory deposit = user.deposits[i];
            Plan memory plan = plans[deposit.plan];

            uint256 startTime = user.checkpoint > deposit.start
                ? user.checkpoint
                : deposit.start;
            uint256 time = _endTime.sub(startTime).div(TIME_STEP);
            uint256 totalPercent = deposit.percent.mul(time);

            if (plan.planType == PlanType.ANYTIME) {
                profit = profit.add(
                    getValuePercentageFromWei(deposit.amount, totalPercent)
                );
                if (_includeDeposits) {
                    profit = profit.add(deposit.amount);
                }
            } else if (plan.planType == PlanType.ENDTIME && time >= plan.time) {
                profit = profit.add(
                    getValuePercentageFromWei(deposit.amount, totalPercent)
                );
                if (_includeDeposits) {
                    profit = profit.add(deposit.amount);
                }
            }
        }
        return profit;
    }

    // Add an address to the whitelist
    // @param _wallet  address from the wallet, should not be a contract
    // @param _percent the percentual should not be bigger than 100 and not smaller than 0
    function addWallet(address _wallet, uint256 _percent) public onlyOwner {
        require(_percent < PERCENT_LIMIT, "The percentage is out of range");
        require(
            whitelist[_wallet].allowed == false,
            "Wallet is already in the list"
        );

        Wallet storage wallet = whitelist[_wallet];
        wallet.allowed = true;
        wallet.percent = _percent;

        whitelisted.push(_wallet);
        emit WalletCreated(_wallet, _percent);
    }

    // Remove from the whitelist
    // @param _wallet address to remove from whitelist
    function removeWallet(address _wallet) public onlyOwner {
        whitelist[_wallet].allowed = false;
        whitelist[_wallet].percent = 0;
        for (uint i = 0; i < whitelisted.length; i++) {
            if (whitelisted[i] == _wallet) {
                whitelisted[i] = whitelisted[whitelisted.length - 1];
                whitelisted.pop();
                break;
            }
        }
        emit WalletRemoved(_wallet);
    }

    // Check if user is whitelisted
    // @param _wallet address to check if is whitelisted
    function isWhitelisted(address _wallet) public view returns (bool) {
        return whitelist[_wallet].allowed;
    }

    function getUserDeposits(address _userAddress)
        public
        view
        returns (uint256 total)
    {
        total = users[_userAddress].deposits.length;
    }

    function getUserAmountDeposits(address _userAddress)
        public
        view
        returns (uint256 amount)
    {
        for (uint256 i = 0; i < users[_userAddress].deposits.length; i++) {
            amount = amount.add(users[_userAddress].deposits[i].amount);
        }
    }

    function getUserDepositInfo(address _userAddress, uint256 _index)
        public
        view
        returns (
            uint8 plan,
            uint256 percent,
            uint256 amount,
            uint256 start
        )
    {
        User memory user = users[_userAddress];

        plan = user.deposits[_index].plan;
        percent = user.deposits[_index].percent;
        amount = user.deposits[_index].amount;
        start = user.deposits[_index].start;
    }

    function getPercentageSumByTime(
        uint8 _planId,
        uint256 _startDate,
        uint256 _endDate
    ) public view returns (uint256) {
        if (_endDate > _startDate) {
            uint256 totalDaysInvested = _endDate.sub(_startDate).div(TIME_STEP);
            return
                plans[_planId].percent.add(PERCENT_STEP.mul(totalDaysInvested));
        }
        return 0;
    }

    function getValuePercentageFromWei(uint256 _value, uint256 _percentage)
        public
        pure
        returns (uint256 percent)
    {
        percent = _value.mul(_percentage).div(100 * 1E18);
        return percent;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
}