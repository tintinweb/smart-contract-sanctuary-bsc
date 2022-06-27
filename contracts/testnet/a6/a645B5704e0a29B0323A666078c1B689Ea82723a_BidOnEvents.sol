// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/utils/Counters.sol';

contract BidOnEvents is Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private eventCounter;
    Counters.Counter private pullCounter;

    uint256 private fee_; // 1000000 is 100%
    uint32 private constant PRECISION = 1000000;

    mapping(uint256 => mapping(address => User)) private poolToUsers; // poolId, userAddress
    mapping(uint256 => Event) private events;
    mapping(uint256 => Pool) private pools;

    enum Outcome {
        WIN,
        DRAW,
        LOSS
    }

    struct User {
        Outcome outcome;
        uint256 balance;
    }
    struct Pool {
        uint256 id;
        Outcome outcome;
        uint256 balance;
    }
    struct Event {
        uint256 id;
        string name;
        IERC20 token;
        uint256 startTime;
        uint8 outcome;
        bool isEnded;
        uint256[3] poolsIds;
    }

    event BidPlaced(
        address indexed userAddress,
        uint256 indexed eventId,
        uint256 indexed poolId,
        Outcome outcome,
        uint256 amount
    );
    event EventCreated(
        uint256 indexed id,
        string indexed name,
        IERC20 indexed token,
        uint256 startTime,
        uint8 outcome,
        bool isEnded,
        uint256[3] poolsIds
    );
    event PoolCreated(uint256 indexed id, Outcome indexed outcome, uint256 balance);
    event RewardGeted(uint256 indexed eventId, uint256 indexed poolId, address indexed userAddress, uint256 reward);
    event EventEnded(uint256 indexed eventId, uint8 indexed outcome);

    constructor() {}

    function getEvent(uint256 eventId) public view returns (Event memory) {
        return events[eventId];
    }

    function getPool(uint256 poolId) public view returns (Pool memory) {
        return pools[poolId];
    }

    function getUserInPull(uint256 poolId, address userAddress) public view returns (User memory) {
        return poolToUsers[poolId][msg.sender];
    }

    function getFee() public view returns (uint256) {
        return fee_;
    }

    function getEventCounter() public view returns (uint256) {
        return pullCounter.current();
    }

    function getPoolCounter() public view returns (uint256) {
        return eventCounter.current();
    }

    function createPool(Outcome outcome) internal returns (bool) {
        uint256 pullId = pullCounter.current();
        pools[pullId] = Pool(pullId, outcome, 0);
        pullCounter.increment();
        emit PoolCreated(pullId, outcome, 0);
        return true;
    }

    function createEvent(
        string memory eventName,
        IERC20 token,
        uint256 startTime
    ) public onlyOwner returns (bool) {
        uint256 pullWinId = pullCounter.current();
        createPool(Outcome.WIN);
        uint256 pullDrawId = pullCounter.current();
        createPool(Outcome.DRAW);
        uint256 pullLossId = pullCounter.current();
        createPool(Outcome.LOSS);

        uint256 eventId = eventCounter.current();
        events[eventId] = Event(eventId, eventName, token, startTime, 3, false, [pullWinId, pullDrawId, pullLossId]);
        eventCounter.increment();
        emit EventCreated(eventId, eventName, token, startTime, 3, false, [pullWinId, pullDrawId, pullLossId]);
        return true;
    }

    function bid(
        uint256 eventId,
        Outcome outcome,
        uint256 amount
    ) public returns (bool) {
        Event memory currentEvent = events[eventId];
        require(!currentEvent.isEnded, 'BidOnEvents: event is ended');
        require(currentEvent.startTime > block.timestamp, 'BidOnEvents: event is started');
        currentEvent.token.transferFrom(msg.sender, address(this), amount);
        uint256 poolId = currentEvent.poolsIds[uint256(outcome)];
        pools[poolId].balance = pools[poolId].balance + amount;
        poolToUsers[poolId][msg.sender].outcome = outcome;
        poolToUsers[poolId][msg.sender].balance = poolToUsers[poolId][msg.sender].balance + amount;
        emit BidPlaced(msg.sender, eventId, poolId, outcome, amount);
        return true;
    }

    function getLosersPools(uint8 outcome) internal view returns (uint8[2] memory) {
        require(outcome <= 2, 'BidOnEvents: wrong outcome');
        if (outcome == 0) {
            return [1, 2];
        } else if (outcome == 1) {
            return [0, 2];
        } else {
            return [0, 1];
        }
    }

    function culculateReward(uint256 eventId, address userAddress) internal view returns (uint256 reward) {
        Event memory currentEvent = events[eventId];
        require(currentEvent.isEnded, 'BidOnEvents: event is not ended');
        uint256 winnerPoolId = currentEvent.poolsIds[uint8(currentEvent.outcome)];
        uint256 allTokensOfWiners = pools[winnerPoolId].balance;
        uint8[2] memory losersPolls = getLosersPools(currentEvent.outcome);
        uint256 allTokensOfLosers = pools[currentEvent.poolsIds[losersPolls[0]]].balance +
            pools[currentEvent.poolsIds[losersPolls[1]]].balance;
        reward = ((((allTokensOfLosers * PRECISION) / allTokensOfWiners) *
            poolToUsers[winnerPoolId][userAddress].balance) / PRECISION);
    }

    function predictRewards(uint256 eventId, address userAddress) public view returns (uint256[3] memory rewards) {
        Event memory currentEvent = events[eventId];
        if (currentEvent.isEnded) {
            uint8[2] memory losersPolls = getLosersPools(currentEvent.outcome);
            rewards[losersPolls[0]] = 0;
            rewards[losersPolls[1]] = 0;
            rewards[currentEvent.outcome] = culculateReward(eventId, msg.sender);
        }
    }

    function getReward(uint256 eventId) public returns (bool) {
        Event memory currentEvent = events[eventId];
        require(currentEvent.isEnded, 'BidOnEvents: event is not ended');
        uint256 reward = culculateReward(eventId, msg.sender);
        require(reward > 0, 'BidOnEvents: you dont have reward');
        uint256 poolId = currentEvent.poolsIds[currentEvent.outcome];
        pools[poolId].balance = pools[poolId].balance - poolToUsers[poolId][msg.sender].balance;
        poolToUsers[poolId][msg.sender].balance = 0;
        currentEvent.token.transfer(msg.sender, reward);
        emit RewardGeted(eventId, poolId, msg.sender, reward);
        return true;
    }

    function endEvent(uint256 eventId, Outcome outcome) public onlyOwner returns (bool) {
        require(events[eventId].startTime < block.timestamp, 'BidOnEvents: event is not started');
        uint8 newOutcome = uint8(outcome);
        require(newOutcome <= 2, 'BidOnEvents: wrong outcome');
        require(!events[eventId].isEnded, 'BidOnEvents: event is already ended');
        events[eventId].isEnded = true;
        events[eventId].outcome = newOutcome;
        emit EventEnded(eventId, newOutcome);
        return true;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
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