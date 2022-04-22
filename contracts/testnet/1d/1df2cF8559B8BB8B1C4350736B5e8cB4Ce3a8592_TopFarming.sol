// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TopFarming is Pausable, Ownable {
    using Counters for Counters.Counter;
    address public feeRecipient;
    uint256 public feeDecimal;
    uint256 public feeRate;

    mapping(address => bool) private _whitelist;

    event Stake(address indexed user, uint256 indexed pid, uint256 amount);
    event Unstake(address indexed user, uint256 indexed pid, uint256 amount);
    event Harvest(address indexed user, uint256 indexed pid, uint256 amount);

    Counters.Counter private _poolIdCount;
    struct PoolInfo {
        IERC20 stakingToken;
        IERC20 rewardToken;
        uint256 totalAmount;
        uint256 rewardPerSecond;
        uint256 startTime;
        uint256 endTime;
        uint256 lastUpdateTime;
        uint256 rewardPerTokenStake;
        bool isPaused;
    }

    struct UserInfo {
        uint256 amount;
        uint256 userRewardPerStake;
        uint256 unclaimedReward;
        uint256 lastDeposit;
    }

    // PoolInfo[] public poolInfo;
    mapping(uint256 => PoolInfo) public poolInfo;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;

    constructor(
        address _feeRecipient,
        uint256 _feeDecimal,
        uint256 _feeRate
    ) {
        require(_feeRecipient != address(0), "Fee recipient is zero address");
        _updateFeeRecipient(_feeRecipient);
        feeDecimal = _feeDecimal;
        feeRate = _feeRate;
        _poolIdCount.increment();
    }

    function stake(uint256 _pid, uint256 _amount) external whenNotPaused {
        require(_amount > 0, "Amount must be greater than 0");

        PoolInfo storage pool = poolInfo[_pid];
        require(!pool.isPaused, "Pool is paused or not exists");
        require(block.timestamp >= pool.startTime, "Can not participate");
        require(block.timestamp < pool.endTime, "Can not participate");

        UserInfo storage user = userInfo[_pid][msg.sender];

        _updateRewardOfPool(_pid, msg.sender);

        pool.stakingToken.transferFrom(
            address(msg.sender),
            address(this),
            _amount
        );
        pool.totalAmount = pool.totalAmount + _amount;
        user.amount = user.amount + _amount;

        emit Stake(msg.sender, _pid, _amount);
    }

    function unstake(uint256 _pid) external {
        PoolInfo storage pool = poolInfo[_pid];
        require(pool.totalAmount > 0, "Pool is empty");
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount > 0, "Amount exceeded");

        _harvest(_pid);
        _updateRewardOfPool(_pid, msg.sender);

        uint256 _amount = user.amount;
        user.amount = 0;
        pool.totalAmount = pool.totalAmount - _amount;
        pool.stakingToken.transfer(address(msg.sender), _amount);

        if (user.amount == 0) {
            delete userInfo[_pid][msg.sender];
        }

        emit Unstake(msg.sender, _pid, _amount);
    }

    function harvest(uint256 _pid) external {
        _harvest(_pid);
    }

    function _harvest(uint256 _pid) internal {
        PoolInfo storage pool = poolInfo[_pid];
        require(pool.totalAmount > 0, "Pool is empty");
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount > 0, "Amount exceeded");

        _updateRewardOfPool(_pid, msg.sender);
        uint256 totalReward = user.unclaimedReward;

        //tính phí harvest
        uint256 _fee = _calculateFee(totalReward, feeRate, feeDecimal);
        uint256 netAmount = totalReward - _fee;
        require(netAmount > 0, "Reward must be greater than 0");
        require(
            pool.rewardToken.balanceOf(address(this)) >= totalReward,
            "Pool is not enough to distribute reward"
        );
        user.unclaimedReward = 0;
        pool.rewardToken.transfer(msg.sender, netAmount);

        if (_fee > 0) {
            pool.rewardToken.transfer(feeRecipient, _fee);
        }

        emit Harvest(msg.sender, _pid, totalReward);
    }

    function rewardPerToken(uint256 _pid) private view returns (uint256) {
        PoolInfo memory pool = poolInfo[_pid];
        if (pool.totalAmount == 0) {
            return pool.rewardPerTokenStake;
        }
        uint256 endTime = block.timestamp <= pool.endTime
            ? block.timestamp
            : pool.endTime;
        return
            pool.rewardPerTokenStake +
            ((((endTime - pool.lastUpdateTime) *
                (pool.rewardPerSecond)) * 1e18) / pool.totalAmount);
    }

    function calculateUserReward(uint256 _pid, address _account)
        internal
        view
        returns (uint256)
    {
        UserInfo memory user = userInfo[_pid][_account];
        if (user.amount == 0) {
            return 0;
        }
        return
            ((user.amount * (rewardPerToken(_pid) - user.userRewardPerStake)) /
                1e18) + user.unclaimedReward;
    }

    function _updateRewardOfPool(uint256 _pid, address _account) private {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_account];
        uint256 endTime = block.timestamp <= pool.endTime ? block.timestamp : pool.endTime;
        
        pool.rewardPerTokenStake = rewardPerToken(_pid);
        pool.lastUpdateTime = endTime;
        user.unclaimedReward = calculateUserReward(_pid, _account);
        user.userRewardPerStake = pool.rewardPerTokenStake;
    }

    function addPool(
        IERC20 _stakingToken,
        IERC20 _rewardToken,
        uint256 _rewardPerSecond,
        uint256 _startTime,
        uint256 _endTime
    ) external onlyWhitelister {
        require(_startTime >= block.timestamp, "_startTime invalid");
        require(_endTime > _startTime, "_startTime invalid");
        require(_rewardPerSecond > 0, "_rewardPerSecond invalid");
        uint256 _poolId = _poolIdCount.current();
        poolInfo[_poolId] = PoolInfo({
                stakingToken: _stakingToken,
                rewardToken: _rewardToken,
                totalAmount: 0,
                rewardPerSecond: _rewardPerSecond,
                startTime: _startTime,
                endTime: _endTime,
                lastUpdateTime: 0,
                rewardPerTokenStake: 0,
                isPaused: false
            });
        _poolIdCount.increment();
    }

    function updateRewardPerSecond(uint256 _pid, uint256 _rewardPerSecond)
        external
        onlyWhitelister
    {
        PoolInfo storage pool = poolInfo[_pid];
        require(!pool.isPaused, "pool is paused");
        require(_rewardPerSecond > 0, "rewardPerSecond must be greater than 0");
        pool.rewardPerSecond = _rewardPerSecond;
        _updateRewardOfPool(_pid, msg.sender);
    }

    function updatePoolsStatus(uint256[] calldata _pids, bool isPaused)
        external
        onlyWhitelister
    {
        for (uint256 i = 0; i < _pids.length; i++) {
            poolInfo[_pids[i]].isPaused = isPaused;
        }
    }

    function getUserInfo(uint256 _pid) public view returns (uint256, uint256) {
        UserInfo memory user = userInfo[_pid][msg.sender];
        uint256 totalReward = calculateUserReward(_pid, msg.sender);
        return (user.amount, totalReward);
    }

    function getPoolInfo(uint256 _pid) public view returns (PoolInfo memory) {
        PoolInfo memory pool = poolInfo[_pid];
        return pool;
    }

    function _updateFeeRecipient(address _feeRecipient) internal {
        require(
            _feeRecipient != address(0),
            "TopFarming: _feeRecipient is zero address"
        );
        feeRecipient = _feeRecipient;
    }

    function updateFeeRecipient(address _feeRecipient)
        external
        onlyWhitelister
    {
        _updateFeeRecipient(_feeRecipient);
    }

    function _calculateFee(
        uint256 amount_,
        uint256 feeRate_,
        uint256 feeDecimal_
    ) private pure returns (uint256) {
        if (feeRate_ == 0) {
            return 0;
        }
        return (feeRate_ * amount_) / 10**(feeDecimal_ + 2);
    }

    function setFee(uint256 _feeRate, uint256 _feeDecimal)
        external
        onlyWhitelister
    {
        require(_feeRate >= 0, "Invalid input");
        require(_feeDecimal >= 0, "Invalid input");
        feeRate = _feeRate;
        feeDecimal = _feeDecimal;
    }

    function setWhitelisters(address[] calldata users, bool remove)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < users.length; i++) {
            _whitelist[users[i]] = !remove;
        }
    }

    modifier onlyWhitelister() {
        require(_whitelist[_msgSender()], "Not in the whitelist");
        _;
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
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