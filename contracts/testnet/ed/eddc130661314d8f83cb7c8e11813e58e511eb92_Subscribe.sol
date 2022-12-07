/**
 *Submitted for verification at BscScan.com on 2022-12-07
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// Sources flattened with hardhat v2.12.2 https://hardhat.org

// File common/ISubscribers.sol

// License-Identifier: MIT
pragma solidity ^0.8.17;

interface ISubscribers {
    function isSubscribed(address addr) external view returns (bool);
}


// File @openzeppelin/contracts/token/ERC20/[email protected]

// License-Identifier: MIT
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


// File @openzeppelin/contracts/interfaces/[email protected]

// License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;


// File @openzeppelin/contracts/utils/[email protected]

// License-Identifier: MIT
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


// File @openzeppelin/contracts/access/[email protected]

// License-Identifier: MIT
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


// File @openzeppelin/contracts/utils/math/[email protected]

// License-Identifier: MIT
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


// File common/ACBase.sol

// License-Identifier: MIT
pragma solidity ^0.8.17;
abstract contract Base is Ownable {
    address public treasury;

    function set_treasury(address _treasury) external onlyOwner {
        treasury = _treasury;
    }
}


// File contracts/subscription.sol

// License-Identifier: MIT
pragma solidity ^0.8.17;
/**
 * @title Subscriptions
 * @notice Accounting for subscriptions for users who want to bill
 * @dev Using on Invoices contract
 */
contract Subscribe is Base, ISubscribers {
    using SafeMath for uint256;
    struct User {
        uint256 untilTime;
        bool isPaused;
    }

    mapping(address => User) public users;

    uint256 public subscriptionPrice;
    uint256 public subscriptionDuration;
    uint256 public paymentDelta;
    uint256 public trialDuration;

    IERC20 immutable usdt;

    /**
     * @notice Emitted when one of the subscriber properties (isPaused or untilTime) changes
     * @dev If untilTime = 0 subscription is turned off.
     * @param user Address of subscriber. Indexed
     * @param isPaused True if subcriber turn off auto-renewal. Indexed
     * @param untilTime Timestamp of subscription is end (millisecons count)
     */
    event subscriber(
        address indexed user,
        bool indexed isPaused,
        uint256 untilTime
    );
    /**
     * @notice Emitted when a subscriber is charged
     * @param user Address of subscriber. Indexed
     * @param amount Number of USDT written off
     * @param untilTime New timestamp of subscription is end (millisecons count)
     */
    event wroteOff(address indexed user, uint256 amount, uint256 untilTime);

    modifier onlyForUser(address _addr) {
        require(users[_addr].untilTime > 0, "User not exists");
        _;
    }

    constructor(
        address _usdt,
        uint256 _subscriptionPrice,
        uint256 _subscriptionDuration,
        uint256 _paymentDelta,
        uint256 _trialDuration,
        address _treasury
    ) {
        usdt = IERC20(_usdt);
        subscriptionPrice = _subscriptionPrice;
        subscriptionDuration = _subscriptionDuration;
        paymentDelta = _paymentDelta;
        trialDuration = _trialDuration;
        treasury = _treasury;
    }

    /**
     * @notice Set true to isPaused property of subscriber with address _addr.
     * It will not be possible to call Write off function for this subscriber.
     * @dev Send subscriber event.
     * Only for owner
     * @param _addr Address of subscriber
     */
    function cancelSubscription(address _addr)
        external
        onlyForUser(_addr)
        onlyOwner
    {
        User memory _user = users[_addr];
        require(!_user.isPaused, "Subscriber: auto-renewal already stop");
        users[_addr].isPaused = true;
        emit subscriber(_addr, true, _user.untilTime);
    }

    /**
     * @notice Set true to isPaused property of subscriber with sender's address.
     * It will not be possible to call Write off function for this subscriber.
     * @dev Send subscriber event
     */
    function cancelSubscription() external onlyForUser(msg.sender) {
        User memory _user = users[msg.sender];
        require(!_user.isPaused, "Subscriber: auto-renewal already stop");
        users[msg.sender].isPaused = true;
        emit subscriber(msg.sender, true, _user.untilTime);
    }

    /**
     * @notice Write off USDT from _addr if subscriber is exists and not paused
     * Transfer tokens to treasury.
     * @dev Send subscriber and wroteOff events
     * @param _addr Address of subscriber
     */
    function writeOff(address _addr) external onlyForUser(_addr) {
        User memory _user = users[_addr];
        require(!_user.isPaused, "User is paused");
        require(
            _user.untilTime <= block.timestamp,
            "Subscription is still active"
        );
        uint256 allowance = usdt.allowance(_addr, address(this));
        require(subscriptionPrice <= allowance, "Not enough USDT");
        usdt.transferFrom(_addr, address(this), subscriptionPrice);
        usdt.transfer(treasury, subscriptionPrice);
        _user.untilTime = block.timestamp.add(subscriptionDuration);
        users[_addr].untilTime = _user.untilTime;
        emit wroteOff(_addr, subscriptionPrice, _user.untilTime);
        emit subscriber(_addr, true, _user.untilTime);
    }

    function writeOffAfterRenew(address _addr) internal {
        User memory _user = users[_addr];
        require(!_user.isPaused, "Subscriber: auto-renewal is stop");
        if (_user.untilTime <= block.timestamp) {
            uint256 allowance = usdt.allowance(_addr, address(this));
            require(subscriptionPrice <= allowance, "Not enough USDT");
            usdt.transferFrom(_addr, address(this), subscriptionPrice);
            usdt.transfer(treasury, subscriptionPrice);
            _user.untilTime = block.timestamp.add(subscriptionDuration);
            users[_addr].untilTime = _user.untilTime;
            emit wroteOff(_addr, subscriptionPrice, _user.untilTime);
        }
        emit subscriber(_addr, true, _user.untilTime);
    }

    /**
     * @notice Set false to isPaused property of subscriber with sender's address and
     * try to write off tokens from the subscriber.
     * @dev Send subscriber and wroteOff events
     */
    function renewSubscription() external onlyForUser(msg.sender) {
        require(
            users[msg.sender].isPaused,
            "Subscriber: auto-renewal already active"
        );
        users[msg.sender].isPaused = false;
        writeOffAfterRenew(msg.sender);
    }

    /**
     * @notice Set false to isPaused property of subscriber with address _addr and
     * try to write off tokens from the subscriber.
     * @dev Send subscriber and wroteOff events.
     * Only for owner
     * @param _addr Address of subscriber
     */
    function renewSubscription(address _addr)
        external
        onlyForUser(_addr)
        onlyOwner
    {
        require(users[_addr].isPaused, "User not stop");
        users[_addr].isPaused = false;
        writeOffAfterRenew(_addr);
    }

    /**
     * @notice Check subscription status
     * @dev from interface ISubscribers
     * @param _addr Address of subscriber
     * @return User with _addr subscription status
     */
    function isSubscribed(address _addr) external view returns (bool) {
        if (users[_addr].untilTime.add(paymentDelta) >= block.timestamp) {
            return true;
        }
        return false;
    }

    /**
     * @notice Add new subscriber with trial period
     * @dev Send subscriber event
     */
    function newSubscription() external {
        User memory _user = users[msg.sender];
        require(_user.untilTime == 0, "Subcsriber already exists");
        _user = User(block.timestamp.add(trialDuration), false);
        users[msg.sender] = _user;
        emit subscriber(msg.sender, true, _user.untilTime);
    }

    /**
     * @notice Set trial duration
     * @dev Only for owner
     * @param _trialDuration Count of milliseconds
     */
    function set_trial(uint256 _trialDuration) external onlyOwner {
        trialDuration = _trialDuration;
    }

    /**
     * @notice Set price for subscription
     * @dev Only for owner
     * @param _subscriptionPrice USDT format
     */
    function set_subscriptionPrice(uint256 _subscriptionPrice)
        external
        onlyOwner
    {
        subscriptionPrice = _subscriptionPrice;
    }

    /**
     * @notice Set subscription duration
     * @dev Only for owner
     * @param _subscriptionDuration Count of milliseconds
     */
    function set_subscriptionDuration(uint256 _subscriptionDuration)
        external
        onlyOwner
    {
        subscriptionDuration = _subscriptionDuration;
    }

    /**
     * @notice Set period for runner duration
     * @dev Only for owner
     * @param _paymentDelta Count of milliseconds
     */
    function set_paymentDelta(uint256 _paymentDelta) external onlyOwner {
        paymentDelta = _paymentDelta;
    }

    /**
     * @notice Set new values for 4 proprties of the contract
     * @dev Only for owner
     * @param _subscriptionPrice USDT format
     * @param _subscriptionDuration Count of milliseconds
     * @param _paymentDelta Count of milliseconds
     * @param _trialDuration Count of milliseconds
     */
    function set_subscriptionOptions(
        uint256 _subscriptionPrice,
        uint256 _subscriptionDuration,
        uint256 _paymentDelta,
        uint256 _trialDuration
    ) external onlyOwner {
        subscriptionPrice = _subscriptionPrice;
        subscriptionDuration = _subscriptionDuration;
        paymentDelta = _paymentDelta;
        trialDuration = _trialDuration;
    }

    /**
     * @notice Add new subscriber with custom period. isPaused - true.
     * @dev Only for owner. Send subscriber event
     * @param _addr Address of subscriber
     * @param duration Count of milliseconds. Added to current timestamp
     */
    function addFreeSubs(address _addr, uint256 duration) external onlyOwner {
        require(users[_addr].untilTime == 0, "Subscriber already exists");
        users[_addr] = User(block.timestamp.add(duration), true);
        emit subscriber(_addr, true, users[_addr].untilTime);
    }

    /**
     * @notice Add custom period to exists subscriber and untilTime increases to duration.
     * Or create new subscriber with untilTime  - curremt time plus duration. isPaused - true.
     * @dev Only for owner. Send subscriber event
     * @param _addr Address of subscriber
     * @param duration Count of milliseconds.
     */
    function extendSubscribe(address _addr, uint256 duration)
        external
        onlyOwner
    {
        uint256 _untilTime = users[_addr].untilTime;
        if (_untilTime == 0) {
            _untilTime = block.timestamp.add(duration);
        } else {
            _untilTime = _untilTime.add(duration);
        }
        users[_addr] = User(_untilTime, true);
        emit subscriber(_addr, true, _untilTime);
    }
}