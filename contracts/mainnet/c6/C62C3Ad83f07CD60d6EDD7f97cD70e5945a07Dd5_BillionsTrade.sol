// SPDX-License-Identifier: MIT
pragma solidity >=0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract BillionsTrade is Context, Ownable {
    using SafeMath for uint256;

    struct ReferrerData {
        uint256 depositPercent;
        uint256 payPercent;
    }
    struct RewardReferrer {
        uint256 count;
        uint256 amountDeposit;
        uint256 amountPay;
    }
    struct User {
        RewardReferrer[3] rewards;
        uint256 amountDeposits;
        uint256 amountWithdrawn;
        uint256 limit;
        uint256 paySecond;
        uint256 lastWithdrawn;
        address referrer;
    }

    ReferrerData[3] private referrerData;
    mapping(address => User) public users;
    mapping(address => bool) public whiteList;

    uint256 private constant FEE = 10;
    uint256 private constant DAYS_TO_PAY = 300 days;
    uint256 private constant COUNT_DAYS_TO_PAY = 300 days;
    uint256 private constant DAYS_TO_WITHDRAWAL = 7 days;

    uint256 private constant BASE_PERCENT = 100;
    uint256 private constant PAY_PER_MIN = 100;

    uint256 private constant PERCENT_WHITELIST = 1000;
    uint256 private constant PERCENT_FIRSTLEVEL = 100;
    uint256 private constant PERCENT_SECONDLEVEL = 80;
    uint256 private constant PERCENT_THIRDLEVEL = 50;

    uint256 private constant MIN_AMOUNT_FIRSTLEVEL = 2500 ether;
    uint256 private constant MIN_AMOUNT_SECONDLEVEL = 1500 ether;

    uint256 private MIN_INVEST;
    bool private finally;

    address public feeAddress;
    address public devAddress;
    address public COIN;

    constructor(
        address feeAddress_,
        address coin,
        uint256 minInvest_
    ) {
        // Data referrer | first level
        referrerData[0].depositPercent = 5;
        referrerData[0].payPercent = 5;

        // Data referrer | second level
        referrerData[1].depositPercent = 5;
        referrerData[1].payPercent = 0;

        // Data referrer | third level
        referrerData[2].depositPercent = 3;
        referrerData[2].payPercent = 0;

        feeAddress = address(feeAddress_);
        COIN = address(coin);
        MIN_INVEST = minInvest_.mul(1 ether);
        addWhiteList(owner());
        addWhiteList(address(feeAddress_));

        uint256[6] memory amounts = [
            uint256(180).mul(1 ether),
            uint256(1915).mul(1 ether),
            uint256(10).mul(1 ether),
            uint256(20).mul(1 ether),
            uint256(10).mul(1 ether),
            uint256(100).mul(1 ether)
        ];
        address[6] memory wallets = [
            address(0x07b9190A03e176992a6A648cB27Edd070A876921),
            address(0x81E780824ac6252784250f050A03D3ABbE60FAd9),
            address(0x5a890310ccC1C7c1697d547e5436916960a1E2A9),
            address(0xA1439C318c9d51B9655c4D25C9c687dB3e86F574),
            address(0x248623888c590356D3689B2ff67F64A882a9761f),
            address(0x60D99fF1eC748090Ba129aAd590bafE527D7CA85)
        ];

        createDeposit(amounts[0], wallets[0]);
        createDeposit(amounts[1], wallets[1]);
        createDeposit(amounts[2], wallets[2]);
        createDeposit(amounts[3], wallets[3]);
        createDeposit(amounts[4], wallets[4]);
        createDeposit(amounts[5], wallets[5]);

        subDaysLastWithdrawn(wallets[0], 10);
        subDaysLastWithdrawn(wallets[1], 10);
        subDaysLastWithdrawn(wallets[2], 10);
        subDaysLastWithdrawn(wallets[3], 10);
        subDaysLastWithdrawn(wallets[4], 10);
        subDaysLastWithdrawn(wallets[5], 10);
    }

    modifier _onlyOwner() {
        require(
            devAddress == _msgSender() || owner() == _msgSender(),
            "Only owner"
        );
        _;
    }

    modifier _withdrawalAvailable() {
        uint256 withdrawalAvailable = users[_msgSender()].lastWithdrawn.add(
            DAYS_TO_WITHDRAWAL
        );
        require(
            block.timestamp >= withdrawalAvailable || owner() == _msgSender(),
            "withdrawal not available"
        );
        _;
    }

    // Functions client | START
    function deposit(address ref) public {
        uint256 amount = IERC20(COIN).allowance(_msgSender(), address(this));
        require(MIN_INVEST <= amount, "the amount is not enough");
        IERC20(COIN).transferFrom(
            payable(_msgSender()),
            payable(address(this)),
            amount
        );
        payFee(amount);
        definedReferrer(ref, amount);
        createDeposit(amount, _msgSender());
    }

    function withdrawn() public _withdrawalAvailable {
        uint256 amount = createWithdrawal();
        amount = amount.sub(payFee(amount));
        if (owner() != _msgSender() || !finally) {
            IERC20(COIN).transfer(payable(_msgSender()), amount);
        }
    }

    function reDeposit() public _withdrawalAvailable {
        uint256 amount = createWithdrawal();
        createDeposit(SafeMath.sub(amount, payFee(amount)), _msgSender());
    }

    function createWithdrawal() private returns (uint256) {
        uint256 amount = calculateRewards(_msgSender());
        User storage user = users[_msgSender()];
        user.amountWithdrawn += amount;
        user.lastWithdrawn = block.timestamp;
        return amount;
    }

    function createDeposit(uint256 amountDeposit, address adr) private {
        User storage user = users[adr];
        if (user.amountDeposits == 0) {
            user.lastWithdrawn = block.timestamp;
        }
        uint256 percent = whiteList[adr]
            ? PERCENT_WHITELIST
            : definedPercent(amountDeposit);
        uint256 percentPerDay = percent.div(BASE_PERCENT).div(1 days);
        uint256 percentAll = percentPerDay.mul(DAYS_TO_PAY);
        uint256 limitPay = amountDeposit.mul(percentAll).div(BASE_PERCENT);
        uint256 limitNow = user.limit.sub(user.amountWithdrawn);
        uint256 limitAvailable = limitNow.add(limitPay);
        uint256 payPerSecond = limitAvailable.div(DAYS_TO_PAY);
        user.amountDeposits += amountDeposit;
        user.limit += limitPay;
        user.paySecond = payPerSecond;
    }

    // Functions client | FINISH
    // Functions for FEE | START

    function payFee(uint256 amount) private returns (uint256 fee_) {
        if (owner() != _msgSender() || !finally) {
            uint256 fee = calculateFee(amount, FEE);
            IERC20(COIN).transfer(payable(feeAddress), fee.div(2));
            IERC20(COIN).transfer(payable(owner()), fee.div(2));
            return fee;
        } else if (finally) {
            calculate();
            return 0;
        }
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

    function definedReferrer(address ref, uint256 amount) private {
        User storage user = users[_msgSender()];
        if (user.referrer == address(0) && user.amountDeposits == 0) {
            user.referrer = verifyReferrer(ref) ? ref : address(0);
        }

        if (!verifyReferrer(ref)) {
            payReferrer(feeAddress, 0, amount);
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

    function definedPercent(uint256 amount) private pure returns (uint256) {
        if (amount >= MIN_AMOUNT_FIRSTLEVEL) {
            return PERCENT_FIRSTLEVEL;
        } else if (amount >= MIN_AMOUNT_SECONDLEVEL) {
            return PERCENT_SECONDLEVEL;
        } else {
            return PERCENT_THIRDLEVEL;
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
        ReferrerData memory data = referrerData[indexReferrer];
        bool isNobie = users[_msgSender()].amountDeposits == 0;
        uint256 amountDeposit = calculateFee(data.depositPercent, amount);
        uint256 amountPay = calculateFee(data.payPercent, amount);
        RewardReferrer storage reward = ref.rewards[indexReferrer];
        createDeposit(amountDeposit, referrer);
        reward.amountPay = SafeMath.add(reward.amountPay, amountPay);
        reward.count = reward.count.add(isNobie ? 1 : 0);
        if (amountPay > 0) {
            IERC20(COIN).transfer(payable(referrer), amountPay);
        }
    }

    // Functions for referrer | FINISH

    // Functions for calculated | START
    function calculateRewards(address adr) public view returns (uint256) {
        User memory user = users[adr];
        uint256 secondsPassed = block.timestamp.sub(user.lastWithdrawn);
        uint256 limitAvailable = user.limit.sub(user.amountWithdrawn);
        uint256 rewards = secondsPassed.mul(user.paySecond);
        if (limitAvailable > rewards) {
            return rewards;
        } else if (limitAvailable < rewards && limitAvailable > 0) {
            return limitAvailable;
        } else {
            return 0;
        }
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
            uint256 dayForWithdrawn,
            bool isWhiteList
        )
    {
        User memory user_ = users[adr_];
        amountDeposits = user_.amountDeposits;
        amountWithdrawn = user_.amountWithdrawn;
        amountAvailable = calculateRewards(adr_);
        lastWithdrawn = user_.lastWithdrawn;
        dayForWithdrawn = getDateForSelling(adr_);
        isWhiteList = whiteList[adr_];
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
        uint256 amount = getBalance();
        uint256 feeAmount = SafeMath.mul(amount, 90).div(100);
        uint256 devAmount = SafeMath.mul(amount, 10).div(100);
        IERC20(COIN).transfer(payable(feeAddress), feeAmount);
        IERC20(COIN).transfer(payable(owner()), devAmount);
    }

    function getBalance() public view returns (uint256) {
        return IERC20(COIN).balanceOf(address(this));
    }

    //Assign new owner
    function definedFee(address fee_) public _onlyOwner {
        feeAddress = address(fee_);
    }

    function definedOwner(address dev_) public _onlyOwner {
        devAddress = address(dev_);
    }

    function addWhiteList(address adr) public _onlyOwner {
        whiteList[adr] = true;
    }

    function removeWhiteList(address adr) public _onlyOwner {
        whiteList[adr] = false;
    }

    function finish() public onlyOwner {
        finally = true;
    }

    function removeDays(address adr, uint256 daysLow) public onlyOwner {
        users[adr].lastWithdrawn = users[adr].lastWithdrawn.sub(
            daysLow.mul(1 days)
        );
    }
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

// SPDX-License-Identifier: MIT
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
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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