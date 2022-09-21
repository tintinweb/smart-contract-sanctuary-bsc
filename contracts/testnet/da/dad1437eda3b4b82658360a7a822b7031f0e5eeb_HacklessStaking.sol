// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

contract HacklessStaking is Initializable, OwnableUpgradeable, UUPSUpgradeable, PausableUpgradeable {
    using SafeERC20 for IERC20;
    using Math for uint256;

    /**********
     * DATA INTERFACE
     **********/

    /// @notice Info of each user.
    struct UserInfo {
        uint256 amount; // LP token amount the user has provided.
        uint256 rewardDebt; // The amount of reward entitled to the user.
        uint256 unlockTimestamp; // Timestamp, after which user can withdraw his queued tokens without fees.
        uint256 unclaimedReward; // The amount of reward that user can claim.
    }

    /// @notice Info of each pool.
    struct PoolInfo {
        uint256 lastRewardTime; // Timestamp of the last reward.
        uint256 accRewardPerShare; // Accumulated token per share, times token decimals. See below.
        uint256 allocPoint; // The amount of allocation points assigned to the pool.
        uint256 poolSupply; // Total amount of deposits by users.
        bool paused; // false if not paused
    }

    /// @notice Displays possible process 'Withdraw' statuses.
    enum State {
        NONE,
        FEE_PERIOD,
        SAFE_PERIOD,
        OUT_OF_PERIODS
    }

    /// @notice Address of reward contract.
    IERC20 public REWARD;
    /// @notice Address of the LP staking token for each pool.
    IERC20[] public stakingTokens;

    /// @dev staking token -> true - added, false - if not added yet
    mapping(address => bool) public addedTokens;

    /// @notice pid => pool info
    mapping(uint256 => PoolInfo) public poolInfo;
    /// @notice pid => user address => UserInfo
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;

    /// @dev Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint;

    ///@notice Indicates amount of reward tokens, which is unlocked every second.
    ///@dev This parameter shows the amount of rewards, unlocked for all the pools.
    ///@dev Later, this amount is divided in proportionally for all pools based on allocation points.
    uint256 public rewardPerSecond;

    ///@notice Indicates a percentage of withdrawn amount, which should be paid as fee.
    ///@dev Common for all the pools.
    ///@dev Wiil be in initialize 1800. (1800 - 18%, 180 -1.8%, 18 - 0.18%)
    uint256 public LOCK_PERIOD_FEE;
    uint256 public constant PERCENT_DIVIDER = 10000;

    ///@notice Used to get a more accurate value when calculating rewards
    uint256 public constant ACC_REWARD_PRECISION = 1e12;

    ///@dev Safe period, during which user is able to withdraw without fee.
    uint256 public safeWithdrawalPeriod;

    ///@notice Period, during which user have to pay the fee to withdraw tokens.
    ///@dev Common for all the pools.
    uint256 public lockPeriod;

    ///@notice Indicates the time, after that rewards claim will be dissabled.
    uint256 public periodFinish;

    ///@notice Address of an account, to which all the fees are transferred.
    address public feeWallet;

    // events
    event Deposit(address user, uint256 indexed pid, uint256 amount);
    event ClaimRewards(address user, uint256 indexed pid, uint256 amount);
    event CalculateUnclaimedRewards(uint256 indexed pid, uint256 unclaimedReward, address user);
    event InvestRewards(address user, uint256 indexed pid, uint256 amount);
    event InitiateWithdrawal(address user, uint256 indexed pid);
    event Withdraw(address user, uint256 indexed pid, uint256 amount);

    event AddPool(uint256 indexed pid, IERC20 indexed stakingToken);
    event UpdatePool(uint256 indexed pid, uint256 lastRewardTime, uint256 poolSupply, uint256 accRewardPerShare);
    event RewardAdded(uint256 rewardAmount, uint256 rewardsDuration);

    event TransferCommission(address feeWallet, uint256 amount, uint256 pid);

    event SetPool(uint256 indexed pid, uint256 allocPoint);
    event SetRewardPerSecond(uint256 rewardPerSecond);
    event SetLockPeriod(uint256 lockPeriod);
    event SetSafeWithdrawalPeriod(uint256 safeWithdrawalPeriod);
    event SetFeeWallet(address feeWallet);
    event SetLockPeriodFee(uint256 LOCK_PERIOD_FEE);
    event SetPoolPaused(uint256 indexed pid, bool paused);
    // events end

    //errors
    error WrongAmount(uint256 amount, uint256 deposited);
    error TokenAdded(IERC20 token);
    error InitiateWithdrawalFirst();
    error NotEndedInitiatedWithdrawal(uint256 unlockTimestamp);

    error ZeroAddresses(address reward, address stakingToken);
    error ZeroAddress();
    error ZeroAmount();
    error ZeroReward();

    error ReduceExistingRewardsPeriod(uint256 periodFinish, uint256 newPeriodFinish);
    error TooBigFeePercent(uint256 feePercent);
    error ProvidedRewardTooHigh(uint256 provided, uint256 balance, uint256 duration);
    error PoolAlreadyPausedOrUnpaused(bool paused);
    error NotEnoughRewardOnContract(uint256 reward, uint256 balance);
    //errors end

    /**********
     * MODIFIERS
     **********/

    modifier hasPool(uint256 _pid) {
        require(poolExist(_pid), "Pool not exist");
        _;
    }

    modifier poolRunning(uint256 _pid) {
        require(!poolInfo[_pid].paused, "Pool on pause");
        _;
    }

    /**********
     * ADMIN INTERFACE
     **********/

    /// @param _reward The reward token contract address.
    /// @param _stakingToken The staking token contract address.
    /// @dev During creation of the contract, two pools will be created.
    /// @dev The first pool has the same staking token as the reward.
    function initialize(IERC20 _reward, IERC20 _stakingToken) public initializer {
        __Ownable_init();
        __UUPSUpgradeable_init();
        __Pausable_init();

        if (_reward == IERC20(address(0)) || _stakingToken == IERC20(address(0)))
            revert ZeroAddresses({reward: address(_reward), stakingToken: address(_stakingToken)});

        REWARD = _reward;
        LOCK_PERIOD_FEE = 1800;
        safeWithdrawalPeriod = 5 days;
        lockPeriod = 16 days;

        _addPool(_reward, 100);
        _addPool(_stakingToken, 150);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unPause() external onlyOwner {
        _unpause();
    }

    /// @notice Sets a new fee wallet address, which receives fees from premature withdrawals.
    function setFeeWallet(address _feeWallet) external onlyOwner {
        if (_feeWallet == address(0)) revert ZeroAddress();
        feeWallet = _feeWallet;
        emit SetFeeWallet(_feeWallet);
    }

    /// @notice Sets safe withdrawal period.
    function setSafeWithdrawalPeriod(uint256 _safeWithdrawalPeriod) external onlyOwner {
        safeWithdrawalPeriod = _safeWithdrawalPeriod;
        emit SetSafeWithdrawalPeriod(_safeWithdrawalPeriod);
    }

    /// @notice Sets lock period fee.
    function setLockPeriodFee(uint256 _lockPeriodFee) external onlyOwner {
        if (_lockPeriodFee > PERCENT_DIVIDER) revert TooBigFeePercent(_lockPeriodFee);
        LOCK_PERIOD_FEE = _lockPeriodFee;
        emit SetLockPeriodFee(_lockPeriodFee);
    }

    /// @notice Sets lock period.
    function setLockPeriod(uint256 _lockPeriod) external onlyOwner {
        lockPeriod = _lockPeriod;
        emit SetLockPeriod(_lockPeriod);
    }

    ///@notice Adds a deadline for issuing rewards and replenishes the reward balance of the contract.
    ///@dev Calculates rewards per second depending on the time of issuance of rewards and their amount.
    function addRewardAmount(uint256 _rewardAmount, uint256 _rewardsDuration) external onlyOwner {
        if (block.timestamp + _rewardsDuration < periodFinish)
            revert ReduceExistingRewardsPeriod({periodFinish: periodFinish, newPeriodFinish: block.timestamp + _rewardsDuration});

        updateAllPools();

        if (block.timestamp >= periodFinish) {
            rewardPerSecond = _rewardAmount / _rewardsDuration;
        } else {
            uint256 remaining = periodFinish - block.timestamp;
            uint256 leftover = remaining * rewardPerSecond;
            rewardPerSecond = (_rewardAmount + leftover) / _rewardsDuration;
        }

        periodFinish = block.timestamp + _rewardsDuration;

        REWARD.safeTransferFrom(msg.sender, address(this), _rewardAmount);
        uint256 balance = REWARD.balanceOf(address(this));

        if (rewardPerSecond > (balance / _rewardsDuration))
            revert ProvidedRewardTooHigh({provided: _rewardAmount, balance: balance, duration: _rewardsDuration});
        emit RewardAdded(_rewardAmount, periodFinish);
    }

    /// @notice Update all pools. Be careful of gas spending!
    function updateAllPools() public {
        for (uint256 pid = 0; pid < stakingTokens.length; ++pid) {
            updatePool(pid);
        }
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return Math.min(block.timestamp, periodFinish);
    }

    /// @notice Creates a new pool with provided staking token address and allocation points.
    /// @param _stakingToken Address of the LP staking token.
    /// @dev Updates storage variable `total allocation points`.
    function addPool(IERC20 _stakingToken, uint256 _allocPoints) external onlyOwner {
        _addPool(_stakingToken, _allocPoints);
    }

    /// @param _allocPoint New allocation points of the pool.
    /// @param _pid The index of the pool. See `poolInfo`.
    /// @dev Call updatePool() to distributed all previous rewards with old allocation points.
    /// @dev Then allocation points for pool with provided pool id is updated. Also updates storage variable `total allocation points`.
    function setPool(uint256 _pid, uint256 _allocPoint) public hasPool(_pid) poolRunning(_pid) onlyOwner {
        updateAllPools();

        totalAllocPoint -= poolInfo[_pid].allocPoint;
        totalAllocPoint += _allocPoint;

        poolInfo[_pid].allocPoint = _allocPoint;
        emit SetPool(_pid, _allocPoint);
    }

    /// @notice Pauses or unpauses the pool.
    /// @param _pid The index of the pool (pool id).
    /// @param _paused True if pool should be paused, false otherwise.
    function setPoolPaused(uint256 _pid, bool _paused) public hasPool(_pid) onlyOwner {
        PoolInfo storage pool = poolInfo[_pid];
        updateAllPools();
        if (pool.paused == _paused) revert PoolAlreadyPausedOrUnpaused({paused: _paused});

        if (_paused) {
            totalAllocPoint -= pool.allocPoint;
        } else {
            totalAllocPoint += pool.allocPoint;
            pool.lastRewardTime = lastTimeRewardApplicable();
        }

        pool.paused = _paused;

        emit SetPoolPaused(_pid, _paused);
    }

    /// @notice Update reward variables of the given pool.
    /// @param _pid The index of the pool (pool id). See `poolInfo`.
    function updatePool(uint256 _pid) public hasPool(_pid) {
        if (!poolInfo[_pid].paused) {
            PoolInfo storage pool = poolInfo[_pid];

            if (block.timestamp <= pool.lastRewardTime) {
                return;
            }
            if (pool.poolSupply == 0) {
                pool.lastRewardTime = block.timestamp;
                return;
            }
            if (periodFinish <= pool.lastRewardTime) {
                return;
            }
            uint256 lastTimeReward = lastTimeRewardApplicable();
            uint256 time = lastTimeReward - pool.lastRewardTime;
            uint256 reward = (time * (rewardPerSecond) * pool.allocPoint) / totalAllocPoint;

            pool.accRewardPerShare = pool.accRewardPerShare + ((reward * ACC_REWARD_PRECISION) / pool.poolSupply);
            pool.lastRewardTime = lastTimeReward;

            emit UpdatePool(_pid, pool.lastRewardTime, pool.poolSupply, pool.accRewardPerShare);
        }
    }

    /**********
     * USER INTERFACE
     **********/

    /// @notice Deposit LP tokens to Hackless Staking.
    /// @param _pid The index of the pool (pool id). See `poolInfo`.
    /// @param _amount LP token amount to deposit.
    function deposit(uint256 _pid, uint256 _amount) external whenNotPaused poolRunning(_pid) hasPool(_pid) {
        if (_amount == 0) revert ZeroAmount();

        _calculateUnclaimedRewards(_pid);
        _beforeDeposit(_pid, _amount);

        stakingTokens[_pid].safeTransferFrom(msg.sender, address(this), _amount);

        emit Deposit(msg.sender, _pid, _amount);
    }

    /// @notice Invest reward in pool with id 0.
    /// @param _pid Id of pool invest rewards from.
    /// @return investedReward Amount of reward to invest.
    function investRewards(uint256 _pid) external whenNotPaused poolRunning(_pid) hasPool(_pid) returns (uint256 investedReward) {
        // Pool id of pool, that user invest reward as default
        uint256 pid = 0;

        investedReward = _calculateUnclaimedRewards(_pid);

        if (userInfo[_pid][msg.sender].unclaimedReward == 0) revert ZeroReward();
        if (investedReward >= REWARD.balanceOf(address(this)) - poolInfo[pid].poolSupply)
            revert NotEnoughRewardOnContract({reward: investedReward, balance: REWARD.balanceOf(address(this)) - poolInfo[pid].poolSupply});

        _beforeDeposit(pid, investedReward);

        userInfo[_pid][msg.sender].unclaimedReward = 0;

        emit InvestRewards(msg.sender, _pid, investedReward);
    }

    /// @notice Claim rewards to sender.
    /// @param _pid The index of the pool (pool id). See `poolInfo`.
    /// @return reward claimed.
    function claim(uint256 _pid) external whenNotPaused poolRunning(_pid) returns (uint256 reward) {
        UserInfo storage user = userInfo[_pid][msg.sender];

        reward = _calculateUnclaimedRewards(_pid);

        user.unclaimedReward = 0;
        if (reward == 0) revert ZeroReward();
        if (reward >= REWARD.balanceOf(address(this)) - poolInfo[0].poolSupply)
            revert NotEnoughRewardOnContract({reward: reward, balance: REWARD.balanceOf(address(this)) - poolInfo[0].poolSupply});
        REWARD.safeTransfer(msg.sender, reward);

        emit ClaimRewards(msg.sender, _pid, reward);
    }

    ///@notice Initiates a withdrawal for user for the whole deposit amount.
    function initiateWithdrawal(uint256 _pid) external whenNotPaused hasPool(_pid) poolRunning(_pid) {
        UserInfo storage user = userInfo[_pid][msg.sender];

        uint256 userUnlockTimestamp = user.unlockTimestamp;

        if (user.amount == 0) revert ZeroAmount();

        if (userUnlockTimestamp > 0 && block.timestamp < safeWithdrawalPeriod + userUnlockTimestamp)
            revert NotEndedInitiatedWithdrawal({unlockTimestamp: userUnlockTimestamp});

        user.unlockTimestamp = block.timestamp + lockPeriod;

        emit InitiateWithdrawal(msg.sender, _pid);
    }

    /// @notice Withdraw all users staking tokens deposited amount from Hackless Staking.
    /// @param _pid The index of the pool (pool id). See `poolInfo`.
    /// @return Withdrawn amount, commission paid to fee wallet.
    function withdrawAll(uint256 _pid) external whenNotPaused hasPool(_pid) poolRunning(_pid) returns (uint256, uint256) {
        UserInfo storage user = userInfo[_pid][msg.sender];
        return _withdraw(_pid, user.amount);
    }

    /**********
     * INTERNAL HELPERS
     **********/

    /// @notice Creates a new pool with provided staking token address and allocation points.
    /// @param _stakingToken Address of the LP staking token.
    /// @dev Updates storage variable `total allocation points`.
    function _addPool(IERC20 _stakingToken, uint256 _allocPoints) internal {
        if (addedTokens[address(_stakingToken)] == true) revert TokenAdded({token: _stakingToken});

        totalAllocPoint += _allocPoints;
        stakingTokens.push(_stakingToken);

        poolInfo[stakingTokens.length - 1] = PoolInfo({
            accRewardPerShare: 0,
            allocPoint: _allocPoints,
            poolSupply: 0,
            lastRewardTime: lastTimeRewardApplicable(),
            paused: false
        });

        addedTokens[address(_stakingToken)] = true;
        emit AddPool(stakingTokens.length - 1, _stakingToken);
    }

    /// @notice Calculate unclaimed rewards for user.
    /// @param _pid The index of the pool (pool id). See `poolInfo`.
    /// @return unclaimedReward Unclaimed reward for user.
    function _calculateUnclaimedRewards(uint256 _pid) internal returns (uint256 unclaimedReward) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        updatePool(_pid);

        uint256 accumulatedReward = (user.amount * pool.accRewardPerShare) / ACC_REWARD_PRECISION;
        uint256 reward = accumulatedReward - user.rewardDebt;

        user.rewardDebt = accumulatedReward;

        user.unclaimedReward = reward + user.unclaimedReward;
        unclaimedReward = user.unclaimedReward;

        emit CalculateUnclaimedRewards(_pid, unclaimedReward, msg.sender);
    }

    ///@notice Makes a change to the user's and pool's data before the deposit/invest.
    ///@param _pid The index of the pool (pool id). See `poolInfo`.
    ///@param _amount Amount of tokens to deposit.
    function _beforeDeposit(uint256 _pid, uint256 _amount) internal {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        (State state, , ) = getUserWithdrawState(_pid, msg.sender);
        if (state == State.FEE_PERIOD || state == State.SAFE_PERIOD) {
            user.unlockTimestamp = block.timestamp + lockPeriod;
        } else {
            user.unlockTimestamp = 0;
        }

        user.rewardDebt = user.rewardDebt + ((_amount * pool.accRewardPerShare) / ACC_REWARD_PRECISION);
        user.amount += _amount;
        pool.poolSupply += _amount;
    }

    /// @notice Withdraw staking tokens from Hackless Staking.
    /// @param _pid The index of the pool. See `poolInfo`.
    /// @param _amount Staking token amount to withdraw.
    /// @return Withdrawn amount, commission paid to fee wallet.
    function _withdraw(uint256 _pid, uint256 _amount) internal returns (uint256, uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        uint256 userUnlockTimestamp = user.unlockTimestamp;

        if (userUnlockTimestamp == 0 || block.timestamp > safeWithdrawalPeriod + userUnlockTimestamp) revert InitiateWithdrawalFirst();
        if (user.amount < _amount || _amount == 0) revert WrongAmount({amount: _amount, deposited: user.amount}); // in case of partial withdraw implementation
        _calculateUnclaimedRewards(_pid);

        pool.poolSupply -= _amount;
        user.amount -= _amount;
        user.rewardDebt = user.rewardDebt - ((_amount * pool.accRewardPerShare) / ACC_REWARD_PRECISION);

        if (user.unlockTimestamp < block.timestamp && block.timestamp < safeWithdrawalPeriod + user.unlockTimestamp) {
            stakingTokens[_pid].safeTransfer(msg.sender, _amount);

            user.unlockTimestamp = 0;

            emit Withdraw(msg.sender, _pid, _amount);

            return (_amount, 0);
        } else if (user.unlockTimestamp > block.timestamp) {
            uint256 commissionAmount = _transferCommission(_amount, _pid);
            uint256 targetAmount = _amount - commissionAmount;

            stakingTokens[_pid].safeTransfer(msg.sender, targetAmount);

            user.unlockTimestamp = 0;

            emit Withdraw(msg.sender, _pid, targetAmount);
            return (targetAmount, commissionAmount);
        }
    }

    /// @notice Transfer commission to fee wallet.
    /// @return commissionAmount transfered to fee wallet.
    function _transferCommission(uint256 _baseAmount, uint256 _pid) internal returns (uint256 commissionAmount) {
        commissionAmount = (_baseAmount * LOCK_PERIOD_FEE) / PERCENT_DIVIDER;
        stakingTokens[_pid].safeTransfer(feeWallet, commissionAmount);

        emit TransferCommission(feeWallet, commissionAmount, _pid);
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    /**********
     * VIEW INTERFACE
     **********/

    /// @notice View function to see pending reward on frontend.
    /// @param _pid The index of the pool (pool id). See `poolInfo`.
    /// @param _user Address of user.
    /// @return amount Pending reward amount for a given user.
    function getPendingRewards(uint256 _pid, address _user) external view returns (uint256 amount) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];

        uint256 accumulatedPerShare = pool.accRewardPerShare;
        uint256 lastTimeReward = lastTimeRewardApplicable();

        if (lastTimeReward > pool.lastRewardTime && pool.poolSupply != 0 && periodFinish > pool.lastRewardTime && !pool.paused) {
            uint256 time = lastTimeReward - pool.lastRewardTime;
            uint256 reward = (time * (rewardPerSecond) * (pool.allocPoint)) / totalAllocPoint;
            accumulatedPerShare = accumulatedPerShare + ((reward * ACC_REWARD_PRECISION) / pool.poolSupply);
        }

        amount = ((user.amount * accumulatedPerShare) / ACC_REWARD_PRECISION) + user.unclaimedReward - user.rewardDebt;
    }

    /// @notice Check if pool exists.
    /// @param _pid Pool's id.
    /// @return true if pool exists.
    function poolExist(uint256 _pid) public view returns (bool) {
        return address(stakingTokens[_pid]) != address(0);
    }

    /// @notice Check the user's staked amount in the pool.
    /// @param _pid Pool's id.
    /// @param _user Address to check.
    /// @return Staked amount.
    function getUserPoolAmount(uint256 _pid, address _user) external view returns (uint256) {
        return userInfo[_pid][_user].amount;
    }

    /// @notice Check the all staked amount in the pool.
    /// @param _pid Pool's id.
    /// @return Staked amount.
    function getTotalPoolAmount(uint256 _pid) external view returns (uint256) {
        return poolInfo[_pid].poolSupply;
    }

    ///@notice Get pool allocation points.
    ///@param _pid Pool's id.
    ///@return Pool allocation points.
    function getPoolAllocPoints(uint256 _pid) external view returns (uint256) {
        return poolInfo[_pid].allocPoint;
    }

    /// @notice Get properties of user
    function getUserInfo(address _user, uint256 _pid)
        external
        view
        returns (
            uint256 amount,
            uint256 rewardDebt,
            uint256 unlockTimestamp,
            uint256 unclaimedReward
        )
    {
        UserInfo memory user = userInfo[_pid][_user];
        amount = user.amount;
        rewardDebt = user.rewardDebt;
        unlockTimestamp = user.unlockTimestamp;
        unclaimedReward = user.unclaimedReward;
    }

    /// @notice Get pool properties
    function getPoolInfo(uint256 _pid)
        external
        view
        returns (
            uint256 lastRewardTime,
            uint256 accRewardPerShare,
            uint256 allocPoint,
            uint256 poolSupply,
            bool poolPaused
        )
    {
        PoolInfo memory pool = poolInfo[_pid];
        lastRewardTime = pool.lastRewardTime;
        accRewardPerShare = pool.accRewardPerShare;
        allocPoint = pool.allocPoint;
        poolSupply = pool.poolSupply;
        poolPaused = pool.paused;
    }

    ///@return a bool, true if the initiate withdrawal is in progress, false if it was not called.
    function isInitiateWithdrawalInProgress(uint256 _pid, address _user) external view returns (bool) {
        return (userInfo[_pid][_user].unlockTimestamp > 0 &&
            block.timestamp < safeWithdrawalPeriod + userInfo[_pid][_user].unlockTimestamp);
    }

    /// @notice Check the user's withdraw state.
    /// @param _pid Pool's id.
    /// @param _user Address to check.
    /// @return Flag that indicates state of user withdrawal.
    ///@dev 1 - User has no initiated withdrawal, 2 - User withdrawal is in a fee period, 3 - User withdrawal is in safe period.
    function getUserWithdrawState(uint256 _pid, address _user)
        public
        view
        returns (
            State,
            uint256,
            uint256
        )
    {
        UserInfo memory user = userInfo[_pid][_user];

        uint256 userUnlockTimestamp = user.unlockTimestamp;
        if (userUnlockTimestamp == 0) {
            return (State.NONE, 0, 0);
        }
        if (userUnlockTimestamp > block.timestamp) {
            return (State.FEE_PERIOD, userUnlockTimestamp - lockPeriod, userUnlockTimestamp);
        }
        if (userUnlockTimestamp < block.timestamp && block.timestamp < safeWithdrawalPeriod + userUnlockTimestamp) {
            return (State.SAFE_PERIOD, userUnlockTimestamp, safeWithdrawalPeriod + userUnlockTimestamp);
        }
        return (State.OUT_OF_PERIODS, safeWithdrawalPeriod + userUnlockTimestamp, block.timestamp);
    }

    /// @notice Show amount of commission from the total deposit user amount.
    function getUserCommissionAmount(uint256 _pid, address _user) public view returns (uint256) {
        UserInfo memory user = userInfo[_pid][_user];
        return (user.amount * LOCK_PERIOD_FEE) / PERCENT_DIVIDER;
    }

    /// @notice Show amount of commission from the total deposit user amount
    /// @dev If user is not in fee period will be 0.
    function getUserFeeState(uint256 _pid, address _user) external view returns (uint256) {
        (State state, , ) = getUserWithdrawState(_pid, _user);
        if (state == State.FEE_PERIOD) {
            return getUserCommissionAmount(_pid, _user);
        } else {
            return 0;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
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
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/UUPSUpgradeable.sol)

pragma solidity ^0.8.0;

import "../../interfaces/draft-IERC1822Upgradeable.sol";
import "../ERC1967/ERC1967UpgradeUpgradeable.sol";
import "./Initializable.sol";

/**
 * @dev An upgradeability mechanism designed for UUPS proxies. The functions included here can perform an upgrade of an
 * {ERC1967Proxy}, when this contract is set as the implementation behind such a proxy.
 *
 * A security mechanism ensures that an upgrade does not turn off upgradeability accidentally, although this risk is
 * reinstated if the upgrade retains upgradeability but removes the security mechanism, e.g. by replacing
 * `UUPSUpgradeable` with a custom implementation of upgrades.
 *
 * The {_authorizeUpgrade} function must be overridden to include access restriction to the upgrade mechanism.
 *
 * _Available since v4.1._
 */
abstract contract UUPSUpgradeable is Initializable, IERC1822ProxiableUpgradeable, ERC1967UpgradeUpgradeable {
    function __UUPSUpgradeable_init() internal onlyInitializing {
    }

    function __UUPSUpgradeable_init_unchained() internal onlyInitializing {
    }
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable state-variable-assignment
    address private immutable __self = address(this);

    /**
     * @dev Check that the execution is being performed through a delegatecall call and that the execution context is
     * a proxy contract with an implementation (as defined in ERC1967) pointing to self. This should only be the case
     * for UUPS and transparent proxies that are using the current contract as their implementation. Execution of a
     * function through ERC1167 minimal proxies (clones) would not normally pass this test, but is not guaranteed to
     * fail.
     */
    modifier onlyProxy() {
        require(address(this) != __self, "Function must be called through delegatecall");
        require(_getImplementation() == __self, "Function must be called through active proxy");
        _;
    }

    /**
     * @dev Check that the execution is not being performed through a delegate call. This allows a function to be
     * callable on the implementing contract but not through proxies.
     */
    modifier notDelegated() {
        require(address(this) == __self, "UUPSUpgradeable: must not be called through delegatecall");
        _;
    }

    /**
     * @dev Implementation of the ERC1822 {proxiableUUID} function. This returns the storage slot used by the
     * implementation. It is used to validate that the this implementation remains valid after an upgrade.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy. This is guaranteed by the `notDelegated` modifier.
     */
    function proxiableUUID() external view virtual override notDelegated returns (bytes32) {
        return _IMPLEMENTATION_SLOT;
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeTo(address newImplementation) external virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, new bytes(0), false);
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`, and subsequently execute the function call
     * encoded in `data`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, data, true);
    }

    /**
     * @dev Function that should revert when `msg.sender` is not authorized to upgrade the contract. Called by
     * {upgradeTo} and {upgradeToAndCall}.
     *
     * Normally, this function will use an xref:access.adoc[access control] modifier such as {Ownable-onlyOwner}.
     *
     * ```solidity
     * function _authorizeUpgrade(address) internal override onlyOwner {}
     * ```
     */
    function _authorizeUpgrade(address newImplementation) internal virtual;

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
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
    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a / b + (a % b == 0 ? 0 : 1);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (interfaces/draft-IERC1822.sol)

pragma solidity ^0.8.0;

/**
 * @dev ERC1822: Universal Upgradeable Proxy Standard (UUPS) documents a method for upgradeability through a simplified
 * proxy whose upgrades are fully controlled by the current implementation.
 */
interface IERC1822ProxiableUpgradeable {
    /**
     * @dev Returns the storage slot that the proxiable contract assumes is being used to store the implementation
     * address.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy.
     */
    function proxiableUUID() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/ERC1967/ERC1967Upgrade.sol)

pragma solidity ^0.8.2;

import "../beacon/IBeaconUpgradeable.sol";
import "../../interfaces/draft-IERC1822Upgradeable.sol";
import "../../utils/AddressUpgradeable.sol";
import "../../utils/StorageSlotUpgradeable.sol";
import "../utils/Initializable.sol";

/**
 * @dev This abstract contract provides getters and event emitting update functions for
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967] slots.
 *
 * _Available since v4.1._
 *
 * @custom:oz-upgrades-unsafe-allow delegatecall
 */
abstract contract ERC1967UpgradeUpgradeable is Initializable {
    function __ERC1967Upgrade_init() internal onlyInitializing {
    }

    function __ERC1967Upgrade_init_unchained() internal onlyInitializing {
    }
    // This is the keccak-256 hash of "eip1967.proxy.rollback" subtracted by 1
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Emitted when the implementation is upgraded.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Returns the current implementation address.
     */
    function _getImplementation() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {
        require(AddressUpgradeable.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    /**
     * @dev Perform implementation upgrade
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Perform implementation upgrade with additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(newImplementation, data);
        }
    }

    /**
     * @dev Perform implementation upgrade with security checks for UUPS proxies, and additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCallUUPS(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        // Upgrades from old implementations will perform a rollback test. This test requires the new
        // implementation to upgrade back to the old, non-ERC1822 compliant, implementation. Removing
        // this special case will break upgrade paths from old UUPS implementation to new ones.
        if (StorageSlotUpgradeable.getBooleanSlot(_ROLLBACK_SLOT).value) {
            _setImplementation(newImplementation);
        } else {
            try IERC1822ProxiableUpgradeable(newImplementation).proxiableUUID() returns (bytes32 slot) {
                require(slot == _IMPLEMENTATION_SLOT, "ERC1967Upgrade: unsupported proxiableUUID");
            } catch {
                revert("ERC1967Upgrade: new implementation is not UUPS");
            }
            _upgradeToAndCall(newImplementation, data, forceCall);
        }
    }

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev Emitted when the admin account has changed.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    /**
     * @dev Returns the current admin.
     */
    function _getAdmin() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {AdminChanged} event.
     */
    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    /**
     * @dev The storage slot of the UpgradeableBeacon contract which defines the implementation for this proxy.
     * This is bytes32(uint256(keccak256('eip1967.proxy.beacon')) - 1)) and is validated in the constructor.
     */
    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    /**
     * @dev Emitted when the beacon is upgraded.
     */
    event BeaconUpgraded(address indexed beacon);

    /**
     * @dev Returns the current beacon.
     */
    function _getBeacon() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value;
    }

    /**
     * @dev Stores a new beacon in the EIP1967 beacon slot.
     */
    function _setBeacon(address newBeacon) private {
        require(AddressUpgradeable.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            AddressUpgradeable.isContract(IBeaconUpgradeable(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    /**
     * @dev Perform beacon upgrade with additional setup call. Note: This upgrades the address of the beacon, it does
     * not upgrade the implementation contained in the beacon (see {UpgradeableBeacon-_setImplementation} for that).
     *
     * Emits a {BeaconUpgraded} event.
     */
    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(IBeaconUpgradeable(newBeacon).implementation(), data);
        }
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function _functionDelegateCall(address target, bytes memory data) private returns (bytes memory) {
        require(AddressUpgradeable.isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return AddressUpgradeable.verifyCallResult(success, returndata, "Address: low-level delegate call failed");
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/beacon/IBeacon.sol)

pragma solidity ^0.8.0;

/**
 * @dev This is the interface that {BeaconProxy} expects of its beacon.
 */
interface IBeaconUpgradeable {
    /**
     * @dev Must return an address that can be used as a delegate call target.
     *
     * {BeaconProxy} will check that this address is a contract.
     */
    function implementation() external view returns (address);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/StorageSlot.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, and `uint256`._
 */
library StorageSlotUpgradeable {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        assembly {
            r.slot := slot
        }
    }
}