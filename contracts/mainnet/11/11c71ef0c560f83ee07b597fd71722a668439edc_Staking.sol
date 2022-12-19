/**
 *Submitted for verification at BscScan.com on 2022-12-19
*/

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

// File: @openzeppelin/[email protected]/access/Ownable.sol


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

// File: @openzeppelin/[email protected]/token/ERC20/IERC20.sol


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

// File: contracts/Staking.sol

//SPDX-License-Identifier: MIT

pragma solidity 0.8.16;



contract Staking is Ownable {
    IERC20 public rewardToken;
    IERC20 public stakingToken;

    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    uint256 public rewardPerSecond;
    uint256 public distributionFinish;
    uint256 public rewardsDuration;

    mapping(address => uint256) public rewards;
    mapping(address => uint256) public balances;
    mapping(address => uint256) public userRewardPerTokenPaid;

    uint256 public totalBalance;

    event RewardAdded(uint256 amount);
    event RewardsDurationUpdated(uint256 duration);
    event Stake(address indexed user, uint256 amount);
    event Unstake(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 amount);

    constructor(
        address _stakingToken,
        address _rewardToken,
        uint256 _rewardsDuration
    ) {
        stakingToken = IERC20(_stakingToken);
        rewardToken = IERC20(_rewardToken);
        setRewardsDuration(_rewardsDuration);
    }

    modifier updateReward(address user) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeDistributionActive();
        if (user != address(0)) {
            rewards[user] = earned(user);
            userRewardPerTokenPaid[user] = rewardPerTokenStored;
        }
        _;
    }

    modifier nonNullAmount(uint256 amount) {
        require(amount != 0, "Invalid amount");
        _;
    }

    function stake(uint256 amount) external updateReward(msg.sender) {
        address user = msg.sender;

        _stake(user, amount);
        stakingToken.transferFrom(user, address(this), amount);
    }

    function unstake(uint256 amount) external updateReward(msg.sender) {
        address user = msg.sender;

        _unstake(user, amount);
        stakingToken.transfer(user, amount);
    }

    function getReward() external updateReward(msg.sender) {
        address user = msg.sender;

        uint256 reward = _getReward(user);
        rewardToken.transfer(user, reward);
    }

    function reinvest() external updateReward(msg.sender) {
        require(stakingToken == rewardToken, "Reinvest unavailable");
        address user = msg.sender;

        uint256 reward = _getReward(user);
        _stake(user, reward);
    }

    function exit() external updateReward(msg.sender) {
        address user = msg.sender;

        uint256 userBalance = balances[user];
        _unstake(user, userBalance);
        stakingToken.transfer(user, userBalance);

        uint256 reward = _getReward(user);
        rewardToken.transfer(user, reward);
    }

    function addReward(uint256 amount) external onlyOwner updateReward(address(0)) {
        if (block.timestamp >= distributionFinish) {
            rewardPerSecond = amount / rewardsDuration;
        } else {
            uint256 remaining = distributionFinish - block.timestamp;
            uint256 leftover = remaining * rewardPerSecond;
            rewardPerSecond = (leftover + amount) / rewardsDuration;
        }

        // Ensure the provided reward amount is not more than the balance in the contract.
        // This keeps the reward rate in the right range, preventing overflows due to
        // very high values of rewardRate in the earned and rewardsPerToken functions;
        // Reward + leftover must be less than 2^256 / 10^18 to avoid overflow.
        uint256 balance;
        if (rewardToken == stakingToken) {
            balance = rewardToken.balanceOf(address(this)) - totalBalance;
        } else {
            balance = rewardToken.balanceOf(address(this));
        }

        require(rewardPerSecond <= balance / rewardsDuration, "Provided reward too high");

        lastUpdateTime = block.timestamp;
        distributionFinish = block.timestamp + rewardsDuration;

        emit RewardAdded(amount);
    }

    function setRewardsDuration(uint256 _rewardsDuration) public onlyOwner {
        require(block.timestamp > distributionFinish, "Previous distribution period NOT finished");
        require(_rewardsDuration != 0, "Invalid duration");
        rewardsDuration = _rewardsDuration;

        emit RewardsDurationUpdated(_rewardsDuration);
    }

    function lastTimeDistributionActive() public view returns (uint256) {
        return block.timestamp < distributionFinish ? block.timestamp : distributionFinish;
    }

    /**
     * In case all stakers are gone, reward per token is 0
     * Otherwise we add:
     * last (can be current) period of distribution * reward per second -> reward generated in the last between updates period
     * divided by total staked balance
     * to the current value of reward per token stored
     */
    function rewardPerToken() public view returns (uint256) {
        if (totalBalance == 0) {
            return rewardPerTokenStored;
        }

        return
            rewardPerTokenStored +
            (((lastTimeDistributionActive() - lastUpdateTime) * rewardPerSecond * 1e18) / totalBalance);
    }

    /**
     * User stake balance is multiplied by
     * reward per token minus the paid reward per token.
     * Total reward is added to the value described above.
     *
     * This way we can calculate the reward earned by the user from his wast interaction until now.
     */
    function earned(address user) public view returns (uint256) {
        return ((balances[user] * (rewardPerToken() - userRewardPerTokenPaid[user])) / 1e18) + rewards[user];
    }

    function _stake(address user, uint256 amount) private nonNullAmount(amount) {
        totalBalance = totalBalance + amount;
        balances[user] = balances[user] + amount;

        emit Stake(user, amount);
    }

    function _unstake(address user, uint256 amount) private nonNullAmount(amount) {
        uint256 userBalance = balances[user];
        require(userBalance >= amount, "Insufficient balance");

        totalBalance = totalBalance - amount;
        balances[user] = userBalance - amount;

        emit Unstake(user, amount);
    }

    function _getReward(address user) private returns (uint256) {
        uint256 reward = rewards[user];
        require(reward != 0, "No reward");

        rewards[user] = 0;

        emit RewardPaid(user, reward);

        return reward;
    }
}