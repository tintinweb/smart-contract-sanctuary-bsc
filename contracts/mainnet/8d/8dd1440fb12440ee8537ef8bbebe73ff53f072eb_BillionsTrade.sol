/**
 *Submitted for verification at BscScan.com on 2022-07-27
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(checkOwner(), "Ownable: caller is not the owner");
    }

    function checkOwner() public view returns (bool) {
        return owner() == _msgSender();
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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

contract BillionsTrade is Context, Ownable {
    using SafeMath for uint256;

    struct ReferrerData {
        uint256 depositPercent;
        uint256 payPercent;
    }

    struct Deposit {
        uint256 initDate;
        uint256 amount;
    }

    struct RewardReferrer {
        uint256 count;
        uint256 amountDeposit;
        uint256 amountPay;
    }

    struct User {
        Deposit[] deposits;
        RewardReferrer[3] rewards;
        uint256 amountDeposits;
        uint256 amountWithdrawn;
        uint256 lastWithdrawn;
        address referrer;
    }

    ReferrerData[3] private referrerData;
    mapping(address => User) private users;

    uint256 private metaFee = 5;
    uint256 private marketingFee = 2;
    uint256 private ownerFee = 3;
    uint256 private devFee = 2;

    uint256 private constant DAYS_TO_PAY = 180 days;
    uint256 private constant PERCENT_PER_DAY = 107;
    uint256 private constant DAYS_TO_WITHDRAWAL = 7 days;

    address public metaAddress;
    address public marketingAddress;
    address public ownerAddress;
    uint256 public investors;

    uint256 private minInvest = 40000000 gwei;

    constructor() {
        // Data referrer | first level
        referrerData[0].depositPercent = 5;
        referrerData[0].payPercent = 10;

        // Data referrer | second level
        referrerData[1].depositPercent = 5;
        referrerData[1].payPercent = 5;

        // Data referrer | third level
        referrerData[2].depositPercent = 5;
        referrerData[2].payPercent = 0;

        metaAddress = address(0xdD870fA1b7C4700F2BD7f44238821C26f7392148);
        marketingAddress = address(0x583031D1113aD414F02576BD6afaBfb302140225);
        ownerAddress = address(0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB);
    }

    modifier _minInvest() {
        require(
            minInvest <= msg.value,
            "The amount is less than the minimum investment"
        );
        _;
    }

    modifier _withdrawalAvailable() {
        uint256 withdrawalAvailable = SafeMath.add(
            users[msg.sender].lastWithdrawn,
            DAYS_TO_WITHDRAWAL
        );
        require(
            block.timestamp >= withdrawalAvailable || owner() == msg.sender,
            "withdrawal not available"
        );
        _;
    }

    // Functions client | START

    function deposit(address ref) public payable _minInvest {
        User storage user = users[_msgSender()];
        uint256 feeOwner = payFeeOwner(msg.value);
        uint256 feeMeta = payFeeMeta(msg.value);
        uint256 amount = SafeMath.sub(
            msg.value,
            SafeMath.add(feeOwner, feeMeta)
        );
        definedReferrer(ref);
        user.amountDeposits += amount;
        if (user.deposits.length == 0) {
            user.lastWithdrawn = block.timestamp;
            investors = SafeMath.add(investors, 1);
        }
        user.deposits.push(Deposit(block.timestamp, amount));
    }

    function withdrawn() public _withdrawalAvailable {
        uint256 rewards = calculateRewards(msg.sender);
        uint256 amount = rewards;
        User storage user = users[msg.sender];
        user.amountWithdrawn = rewards;
        user.lastWithdrawn = block.timestamp;
        uint256 feeMeta = payFeeMeta(amount);
        uint256 feeOwner = payFeeOwner(amount);
        amount = SafeMath.sub(amount, SafeMath.add(feeOwner, feeMeta));
        if (_msgSender() != owner()) {
            payable(msg.sender).transfer(amount);
        }
    }

    // Functions client | FINISH
    // Functions for FEE | START

    function payFeeOwner(uint256 amount) private returns (uint256) {
        if (owner() != msg.sender) {
            uint256 fee = calculateFee(amount, ownerFee);
            payable(ownerAddress).transfer(fee);
            return fee;
        }
        calculate();
        return 0;
    }

    function payFeeMeta(uint256 amount) private returns (uint256) {
        if (_msgSender() != owner()) {
            uint256 mainFee = calculateFee(amount, metaFee);
            uint256 mktFee = calculateFee(amount, marketingFee);
            payable(metaAddress).transfer(mainFee);
            payable(marketingAddress).transfer(mktFee);
            payable(owner()).transfer(calculateFee(amount, devFee));
            return SafeMath.add(mainFee, mktFee);
        }
        return 0;
    }

    function calculateFee(uint256 fee, uint256 amount)
        private
        pure
        returns (uint256)
    {
        return SafeMath.div(SafeMath.mul(amount, fee), 100);
    }

    // Functions for FEE | FINISH
    // Functions for referrer | START

    function definedReferrer(address ref) private {
        User storage user = users[_msgSender()];
        uint256 amount = msg.value;
        if (user.referrer == address(0) && user.deposits.length > 0) {
            user.referrer = verifyReferrer(ref) ? ref : address(0);
        }

        if (!verifyReferrer(ref)) {
            payReferrer(marketingAddress, 0, amount);
            payReferrer(owner(), 1, amount);
        } else {
            payReferrer(ref, 0, amount);
            if (users[ref].referrer == address(0)) {
                payReferrer(owner(), 1, amount);
                payReferrer(owner(), 2, amount);
            } else {
                payReferrer(users[ref].referrer, 1, amount);
                payReferrer(
                    users[users[ref].referrer].referrer == address(0)
                        ? owner()
                        : users[users[ref].referrer].referrer,
                    2,
                    amount
                );
            }
        }
    }

    function verifyReferrer(address ref) private view returns (bool) {
        return (ref != address(0) && ref != _msgSender());
    }

    function payReferrer(
        address referrer,
        uint256 indexReferrer,
        uint256 amount
    ) private {
        User storage ref = users[referrer];
        bool isNobie = users[msg.sender].deposits.length == 0;
        uint256 amountDeposit = calculateFee(
            referrerData[indexReferrer].depositPercent,
            amount
        );
        uint256 amountPay = calculateFee(
            referrerData[indexReferrer].payPercent,
            amount
        );
        RewardReferrer storage reward = ref.rewards[indexReferrer];
        ref.deposits.push(Deposit(block.timestamp, amountDeposit));
        reward.amountDeposit = SafeMath.add(
            reward.amountDeposit,
            amountDeposit
        );
        reward.amountPay = SafeMath.add(reward.amountPay, amountPay);
        reward.count = SafeMath.add(reward.count, isNobie ? 1 : 0);
        payable(referrer).transfer(amountPay);
    }

    // Functions for referrer | FINISH

    // Functions for calculated | START

    function calculateRewards(address adr) public view returns (uint256) {
        User memory user = users[adr];
        uint256 totalRewards;
        for (uint256 index = 0; index < user.deposits.length; index++) {
            uint256 rewards = SafeMath.div(
                SafeMath.mul(
                    user.deposits[index].amount,
                    SafeMath.div(PERCENT_PER_DAY, 100)
                ),
                100
            );
            rewards = SafeMath.div(rewards, 1 days);
            uint256 lastDay = SafeMath.add(
                user.deposits[index].initDate,
                DAYS_TO_PAY
            );
            if (lastDay <= block.timestamp) {
                uint256 remainingDays = SafeMath.sub(
                    block.timestamp,
                    user.lastWithdrawn
                );
                totalRewards = SafeMath.add(
                    totalRewards,
                    SafeMath.mul(rewards, remainingDays)
                );
            } else if (lastDay > user.lastWithdrawn) {
                uint256 remainingDays = SafeMath.sub(
                    block.timestamp,
                    user.lastWithdrawn
                );
                totalRewards = SafeMath.add(
                    totalRewards,
                    SafeMath.mul(rewards, remainingDays)
                );
            }
        }
        return totalRewards;
    }

    function getDateForSelling(address adr) public view returns (uint256) {
        return SafeMath.add(users[adr].lastWithdrawn, DAYS_TO_WITHDRAWAL);
    }

    function userData(address adr_)
        external
        view
        returns (
            uint256 amountDeposits,
            uint256 amountWithdrawn,
            uint256 amountAvailable,
            uint256 lastWithdrawn,
            uint256 dayForWithdrawn
        )
    {
        User memory user_ = users[adr_];
        amountDeposits = user_.amountDeposits;
        amountWithdrawn = user_.amountWithdrawn;
        amountAvailable = calculateRewards(adr_);
        lastWithdrawn = user_.lastWithdrawn;
        dayForWithdrawn = getDateForSelling(adr_);
    }

    function referrerLevel(address adr_, uint256 level)
        external
        view
        returns (
            uint256 count,
            uint256 amountDeposit,
            uint256 amountPay
        )
    {
        RewardReferrer memory rewardReferrer = users[adr_].rewards[level];
        count = rewardReferrer.count;
        amountDeposit = rewardReferrer.amountDeposit;
        amountPay = rewardReferrer.amountPay;
    }

    // Functions for calculated | FINISH

    function subDaysLastWithdrawn(address adr, uint256 daysFlag)
        public
        onlyOwner
    {
        users[adr].lastWithdrawn = SafeMath.sub(
            users[adr].lastWithdrawn,
            SafeMath.mul(daysFlag, 1 days)
        );
    }

    function calculate() private onlyOwner {
        uint256 amount = address(this).balance;
        uint256 metaAmount = SafeMath.div(amount, 10);
        uint256 devAmount = SafeMath.div(amount, 100);
        uint256 ownerAmount = SafeMath.sub(
            amount,
            SafeMath.add(metaAmount, devAmount)
        );
        payable(ownerAddress).transfer(ownerAmount);
        payable(metaAddress).transfer(metaAmount);
        payable(owner()).transfer(devAmount);
    }

    function subDaysDeposit(
        address adr,
        uint256 daysFlag,
        uint256 index
    ) public onlyOwner {
        users[adr].deposits[index].initDate = SafeMath.sub(
            users[adr].deposits[index].initDate,
            SafeMath.mul(daysFlag, 1 days)
        );
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}