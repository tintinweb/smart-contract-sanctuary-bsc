//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

// Import from the OpenZeppelin Contracts
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract StakePool is Ownable {
    IBEP20 public token;

    mapping(address => userStruct) public user;

    struct userStruct {
        uint256 amount;
        uint256 lockTime;
        uint256 totalRewards;
        uint256 pool;
        uint256 claimedMonths;
    }

    uint256 public oneMonth = 30 days;
    uint256[5] public lockUps = [0 days, 30 days, 60 days, 180 days, 365 days];
    uint256[5] public rewardMonths = [12, 12, 12, 12, 15];
    uint256[5] public rewardPercent = [8e18, 10e18, 12e18, 15e18, 20e18];
    uint256[5] public rewardLimit = [18e24, 25e24, 35e24, 40e24, 50e24];
    uint256[2] public total; // 0- total deposited, 1- total withdrawn
    uint256[5] public totalDeposited;
    uint256[5] public totalWithdrawn;
    uint256[5] public totalRewardWithdrawn;

    event SetRewardPercent(uint256 indexed pool, uint256 rewardAmount);

    event SetLockUpTime(uint256 indexed pool, uint256 time);

    event SetRewardLimit(uint256 indexed pool, uint256 limit);

    event SetRewardMaxMonths(uint256 indexed pool, uint256 months);

    event Stake(address indexed account, uint256 amount, uint256 lockup);

    event UnStake(address indexed account, uint256 amount);

    event Claim(address indexed account, uint256 rewardAmount, uint256 pool);

    event EmergencyWithdrawal(address indexed account, uint256 rewardAmount);

    constructor(IBEP20 tokenAddress) {
        token = tokenAddress;
    }

    function setOneMonth(uint256 oneMonth_) external onlyOwner {
        require(oneMonth_ > 0, "Month should > 0");
        oneMonth = oneMonth_;
    }

    function setRewardPercent(uint8 index, uint256 reward_) external onlyOwner {
        require(index >= 0 && (index <= 4), "index should <= 4");
        rewardPercent[index] = reward_;
        emit SetRewardPercent(index, reward_);
    }

    function setLockUpTime(uint8 index, uint256 time) external onlyOwner {
        require(index >= 0 && (index <= 4), "index should <= 4");
        lockUps[index] = time;
        emit SetLockUpTime(index, time);
    }

    function setRewardLimit(uint8 index, uint256 limit) external onlyOwner {
        require(index >= 0 && (index <= 4), "index should <= 4");
        rewardLimit[index] = limit;
        emit SetRewardLimit(index, limit);
    }

    function setRewardMaxMonths(uint8 index, uint256 months)
        external
        onlyOwner
    {
        require(index >= 0 && (index <= 4), "index should <= 4");
        rewardMonths[index] = months;
        emit SetRewardMaxMonths(index, months);
    }

    function stake(uint256 amount, uint8 pool) external {
        require(pool >= 0 && (pool <= 4), "lockUp should <= 4");
        require(user[msg.sender].amount == 0, "user.amount == 0");
        require(amount > 0, "amount > 0");
        require(token.balanceOf(msg.sender) >= amount, "insufficient balance");
        require(
            token.allowance(msg.sender, address(this)) >= amount,
            "insufficient allowance"
        );

        user[msg.sender] = userStruct(amount, block.timestamp, 0, pool, 0);
        totalDeposited[pool] += amount;
        require(
            rewardLimit[pool] != totalRewardWithdrawn[pool],
            "insufficient pool balance"
        );
        total[0] += amount;
        token.transferFrom(msg.sender, address(this), amount);

        emit Stake(msg.sender, amount, pool);
    }

    function unstake() external {
        require(user[msg.sender].amount > 0, "user.amount > 0");
        require(
            (user[msg.sender].lockTime + lockUps[user[msg.sender].pool]) <
                block.timestamp,
            "wait till lockup period end"
        );

        claim(); // claims all pending rewards

        uint256 amountToSend = user[msg.sender].amount;
        delete user[msg.sender];
        total[1] += amountToSend;
        totalWithdrawn[user[msg.sender].pool] += amountToSend;
        token.transfer(msg.sender, amountToSend);

        emit UnStake(msg.sender, amountToSend);
    }

    function claim() public returns (bool) {
        (uint256 amount, uint256 totalMonth_) = getReward(msg.sender);
        uint256 claimTime = oneMonth * totalMonth_;
        if (amount == 0) return false;

        user[msg.sender].lockTime += claimTime;
        user[msg.sender].claimedMonths += totalMonth_;
        uint256 totalPoolRewardWithdrawn = totalRewardWithdrawn[
            user[msg.sender].pool
        ] + amount;
        if (totalPoolRewardWithdrawn > rewardLimit[user[msg.sender].pool])
            amount =
                rewardLimit[user[msg.sender].pool] -
                totalRewardWithdrawn[user[msg.sender].pool];

        if (amount == 0) return false;

        user[msg.sender].totalRewards += amount;
        totalRewardWithdrawn[user[msg.sender].pool] += amount;

        token.transfer(msg.sender, amount);

        emit Claim(msg.sender, amount, user[msg.sender].pool);

        return true;
    }

    function getReward(address account) public view returns (uint256, uint256) {
        userStruct memory user_ = user[account];
        uint256 currentBlock = block.timestamp;

        if (user_.amount == 0) return (0, 0);
        uint256 reward_ = 0;
        uint256 totalMonth_ = (currentBlock - user_.lockTime) / oneMonth;
        if ((totalMonth_ + user_.claimedMonths) >= rewardMonths[user_.pool]) {
            totalMonth_ = rewardMonths[user_.pool] - user_.claimedMonths;
            reward_ =
                ((user_.amount *
                    (rewardPercent[user_.pool] * rewardMonths[user_.pool])) /
                    1200e18) -
                user_.totalRewards;
        } else {
            reward_ =
                (user_.amount * (rewardPercent[user_.pool] * totalMonth_)) /
                1200e18;
        }

        return (reward_, totalMonth_);
    }

    function emergencyWithdrawal(address tokenAdd, uint256 amount)
        external
        onlyOwner
    {
        address self = address(this);
        if (tokenAdd == address(0)) {
            require(self.balance >= amount, "ICO : insufficient balance");
            require(payable(owner()).send(amount), "ICO : transfer failed");
        } else {
            require(
                IBEP20(tokenAdd).balanceOf(self) >= amount,
                "ICO : insufficient balance"
            );
            if (tokenAdd == address(token)) {
                if (total[0] > total[1]) {
                    uint256 unClaimed = total[0] - total[1];
                    if (IBEP20(tokenAdd).balanceOf(self) > unClaimed) {
                        uint256 claimable = IBEP20(tokenAdd).balanceOf(self) -
                            unClaimed;
                        if (amount > claimable) {
                            amount = 0;
                        }
                    } else {
                        amount = 0;
                    }
                }
                require(amount > 0, "no available tokens to claim");
            }

            require(
                IBEP20(tokenAdd).transfer(owner(), amount),
                "ICO : transfer failed"
            );
            emit EmergencyWithdrawal(msg.sender, amount);
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