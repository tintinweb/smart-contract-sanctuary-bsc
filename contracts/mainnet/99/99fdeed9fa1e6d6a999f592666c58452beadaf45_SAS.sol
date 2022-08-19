//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SafeMath.sol";
import "./IERC20.sol";
import "./SafeERC20.sol";
import "./ReentrancyGuard.sol";
import "./Pausable.sol";
import "./Ownable.sol";
import "./IPancakeRouter02.sol";

// https://docs.synthetix.io/contracts/source/contracts/stakingrewards
contract SAS is ReentrancyGuard, Pausable, Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    /* ========== STATE VARIABLES ========== */

    IERC20 public rewardsToken;
    IERC20 public stakingToken;
    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public rewardsDuration = 365 days;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;

    address public treasury;
    address public secondaryPool;

    struct LockedBalance {
        uint256 balance;
        uint256 duration;
        uint256 unlockTime;
        uint256 score;
        uint256 rewardPerTokenPaid;
        uint256 reward;
    }

    uint256 private _totalSupply;
    uint256 private _totalScore;
    mapping(address => LockedBalance[]) private locks;

    // Duration of lock period in seconds
    uint256 public constant minDuration = 1 days;
    uint256 public constant maxDuration = 365 days;

    IPancakeRouter02 router;

    /* ========== CONSTRUCTOR ========== */

    constructor(
        address _rewardsToken,
        address _stakingToken,
        address _router,
        address _treasury,
        address _secondaryPool
    ) {
        rewardsToken = IERC20(_rewardsToken);
        stakingToken = IERC20(_stakingToken);
        router = IPancakeRouter02(_router);
        treasury = _treasury;
        secondaryPool = _secondaryPool;

        rewardsToken.approve(address(router), 2**256 - 1);
    }

    /* ========== VIEWS ========== */

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function totalScore() external view returns (uint256) {
        return _totalScore;
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return block.timestamp < periodFinish ? block.timestamp : periodFinish;
    }

    function remainContractTime() public view returns (uint256) {
        uint256 _remainTime = periodFinish.sub(block.timestamp);
        return _remainTime;
    }

    function rewardPerToken() public view returns (uint256) {
        if (_totalScore == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored.add(
                lastTimeRewardApplicable()
                    .sub(lastUpdateTime)
                    .mul(rewardRate)
                    .mul(1e18)
                    .div(_totalScore)
            );
    }

    function locksCount(address user) external view returns (uint256) {
        return locks[user].length;
    }

    function lockInfo(address user, uint256 lockIdx)
        external
        view
        returns (
            uint256 balance,
            uint256 duration,
            uint256 unlockTime,
            uint256 score,
            uint256 rewardPerTokenPaid,
            uint256 reward
        )
    {
        require(lockIdx < locks[user].length, "Lock index does not exist");
        LockedBalance memory lock = locks[user][lockIdx];
        return (
            lock.balance,
            lock.duration,
            lock.unlockTime,
            lock.score,
            lock.rewardPerTokenPaid,
            lock.reward
        );
    }

    function remainLockerTime(address user, uint256 lockIdx)
        public
        view
        returns (uint256)
    {
        uint256 _remainTime = locks[user][lockIdx].unlockTime.sub(
            block.timestamp
        );
        return _remainTime;
    }

    function isUnlocked(address user, uint256 lockIdx)
        public
        view
        returns (bool)
    {
        return block.timestamp >= locks[user][lockIdx].unlockTime;
    }

    function earned(address user, uint256 lockIdx)
        public
        view
        returns (uint256)
    {
        require(lockIdx < locks[user].length, "Lock index does not exist");
        LockedBalance memory lock = locks[user][lockIdx];
        return
            lock
                .score
                .mul(rewardPerToken().sub(lock.rewardPerTokenPaid))
                .div(1e18)
                .add(lock.reward);
    }

    function totalEarned(address user) public view returns (uint256) {
        uint256 total;
        for (uint256 i = 0; i < locks[user].length; i++) {
            total += earned(user, i);
        }
        return total;
    }

    function totalFullyClaimable(address user) public view returns (uint256) {
        uint256 total;
        uint256 len = locks[user].length;
        for (uint256 i = 0; i < len; i++) {
            if (isUnlocked(user, i)) total += earned(user, i);
        }
        return total;
    }

    function getRewardForDuration() external view returns (uint256) {
        return rewardRate.mul(rewardsDuration);
    }

    /* ========== PURE FUNCTIONS ========== */

    function calculateScore(uint256 amount, uint256 duration)
        public
        pure
        returns (uint256)
    {
        return amount.mul(duration);
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function stakeOnNewLock(
        address user,
        uint256 amount,
        uint256 duration
    ) external nonReentrant whenNotPaused {
        require(user != address(0), "User cannot be 0 address");
        require(amount > 0, "Cannot stake 0");
        require(
            duration >= minDuration && duration <= maxDuration,
            "Lock duration not in range"
        );

        uint256 unlockTime = block.timestamp.add(duration);
        require(
            unlockTime <= periodFinish,
            "Lock must end before pool finish time"
        );

        locks[user].push(
            LockedBalance({
                balance: 0,
                duration: duration,
                unlockTime: unlockTime,
                score: 0,
                rewardPerTokenPaid: 0,
                reward: 0
            })
        );

        uint256 lastIdx = locks[user].length - 1;
        updateReward(user, lastIdx);

        uint256 score = calculateScore(amount, duration);
        locks[user][lastIdx].score = score;
        locks[user][lastIdx].balance = amount;
        _totalScore = _totalScore.add(score);
        _totalSupply = _totalSupply.add(amount);

        stakingToken.safeTransferFrom(user, address(this), amount);
        emit Staked(user, amount, duration);
    }

    function stakeOnExistingLock(
        address user,
        uint256 lockIdx,
        uint256 amount
    ) external nonReentrant whenNotPaused {
        require(user != address(0), "User cannot be 0 address");
        require(amount > 0, "Cannot stake 0");
        require(lockIdx < locks[user].length, "Lock index does not exist");
        updateReward(user, lockIdx);

        LockedBalance storage lock = locks[user][lockIdx];
        uint256 scoreDelta = calculateScore(amount, lock.duration);

        lock.balance = lock.balance.add(amount);
        lock.score = lock.score.add(scoreDelta);
        _totalSupply = _totalSupply.add(amount);
        _totalScore = _totalScore.add(scoreDelta);

        stakingToken.safeTransferFrom(user, address(this), amount);
        emit Staked(user, amount, lock.duration);
    }

    function withdraw(uint256 lockIdx) external nonReentrant {
        uint256 len = locks[msg.sender].length;
        require(lockIdx < len, "Lock index does not exist");
        require(
            isUnlocked(msg.sender, lockIdx),
            "Cant withdraw before unlock time"
        );

        updateReward(msg.sender, lockIdx);

        LockedBalance[] storage userLocks = locks[msg.sender];
        LockedBalance memory lock = userLocks[lockIdx];

        require(lock.balance > 0, "Lock position is empty");

        if (len > 1) userLocks[lockIdx] = userLocks[len - 1];
        userLocks.pop();

        _totalScore = _totalScore.sub(lock.score);
        _totalSupply = _totalSupply.sub(lock.balance);

        stakingToken.safeTransfer(msg.sender, lock.balance);
        emit Withdrawn(msg.sender, lock.balance);

        getFullReward(lock.reward);
    }

    function withdrawEarly(uint256 lockIdx) external nonReentrant {
        uint256 len = locks[msg.sender].length;
        require(lockIdx < len, "Lock index does not exist");
        require(
            !isUnlocked(msg.sender, lockIdx),
            "Unlock time has passed, use standard withdraw instead"
        );

        updateReward(msg.sender, lockIdx);

        LockedBalance[] storage userLocks = locks[msg.sender];
        LockedBalance memory lock = userLocks[lockIdx];

        require(lock.balance > 0, "Lock position is empty");

        if (len > 1) userLocks[lockIdx] = userLocks[len - 1];
        userLocks.pop();

        _totalScore = _totalScore.sub(lock.score);
        _totalSupply = _totalSupply.sub(lock.balance);

        stakingToken.safeTransfer(msg.sender, lock.balance);
        emit Withdrawn(msg.sender, lock.balance);

        getPenalizedReward(lock.reward, lock.duration, lock.unlockTime);
    }

    function getFullReward(uint256 reward) internal {
        if (reward > 0) {
            rewardsToken.safeTransfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
    }

    function getPenalizedReward(
        uint256 reward,
        uint256 duration,
        uint256 unlockTime
    ) internal {
        if (reward > 0) {
            // send completion% * 25% to user
            uint256 userAmount = reward
                .mul(block.timestamp.sub(unlockTime.sub(duration)))
                .div(duration);
            userAmount = userAmount.mul(25).div(100);

            if (userAmount > 0)
                rewardsToken.safeTransfer(msg.sender, userAmount);

            // apply penalty to remaining amount
            uint256 penaltyAmount = reward.sub(userAmount);
            applyPenalty(penaltyAmount);

            emit RewardPaid(msg.sender, userAmount);
        }
    }

    function applyPenalty(uint256 penaltyAmount) internal {
        uint256 secondaryPoolAmount = penaltyAmount.div(2);
        if (secondaryPoolAmount > 0)
            rewardsToken.safeTransfer(secondaryPool, secondaryPoolAmount);

        uint256 remainingAmount = penaltyAmount.sub(secondaryPoolAmount);
        uint256 treasuryAmount = remainingAmount.div(2);
        if (treasuryAmount > 0)
            rewardsToken.safeTransfer(treasury, treasuryAmount);

        uint256 swapToTreasuryAmount = remainingAmount.sub(treasuryAmount);
        if (swapToTreasuryAmount > 0) {
            // setup swap parameters
            uint256 amountOutMin = 1;
            address[] memory path = new address[](2);
            path[0] = address(rewardsToken);
            path[1] = router.WETH();
            uint256 deadline = block.timestamp + 300;

            // approve token transfer and execute swap
            router.swapExactTokensForETH(
                swapToTreasuryAmount,
                amountOutMin,
                path,
                treasury,
                deadline
            );
        }
    }

    function updateReward(address user, uint256 lockIdx) internal {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (user != address(0)) {
            locks[user][lockIdx].reward = earned(user, lockIdx);
            locks[user][lockIdx].rewardPerTokenPaid = rewardPerTokenStored;
        }
    }

    /* ========== RESTRICTED FUNCTIONS ========== */

    function notifyRewardAmount(uint256 reward) external onlyOwner {
        updateReward(address(0), 0);
        if (block.timestamp >= periodFinish) {
            rewardRate = reward.div(rewardsDuration);
        } else {
            uint256 remaining = periodFinish.sub(block.timestamp);
            uint256 leftover = remaining.mul(rewardRate);
            rewardRate = reward.add(leftover).div(rewardsDuration);
        }

        // Ensure the provided reward amount is not more than the balance in the contract.
        // This keeps the reward rate in the right range, preventing overflows due to
        // very high values of rewardRate in the earned and rewardsPerToken functions;
        // Reward + leftover must be less than 2^256 / 10^18 to avoid overflow.
        uint256 balance = rewardsToken.balanceOf(address(this));
        require(
            rewardRate <= balance.div(rewardsDuration),
            "Provided reward too high"
        );

        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp.add(rewardsDuration);
        emit RewardAdded(reward);
    }

    // Added to support recovering LP Rewards from other systems such as BAL to be distributed to holders
    function recoverERC20(address tokenAddress, uint256 tokenAmount)
        external
        onlyOwner
    {
        require(
            tokenAddress != address(stakingToken),
            "Cannot withdraw the staking token"
        );
        IERC20(tokenAddress).safeTransfer(msg.sender, tokenAmount);
        emit Recovered(tokenAddress, tokenAmount);
    }

    function setRewardsDuration(uint256 _rewardsDuration) external onlyOwner {
        require(
            block.timestamp > periodFinish,
            "Previous rewards period must be complete before changing the duration for the new period"
        );
        rewardsDuration = _rewardsDuration;
        emit RewardsDurationUpdated(rewardsDuration);
    }

    function setTreasury(address _treasury) public onlyOwner {
        treasury = _treasury;
        emit SetTreasury(_treasury);
    }

    function setSecondaryPool(address _secondaryPool) public onlyOwner {
        secondaryPool = _secondaryPool;
        emit SetSecondaryPool(_secondaryPool);
    }

    // pause should be called before any critical action or bug detection
    // this will cause the contract main activities to cease
    function pause() external whenNotPaused onlyOwner {
        _pause();
    }

    function unpause() external whenPaused onlyOwner {
        _unpause();
    }

    /* ========== EVENTS ========== */

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount, uint256 duration);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event RewardsDurationUpdated(uint256 newDuration);
    event Recovered(address token, uint256 amount);
    event SetRewardsDistribution(address distributor);
    event SetTreasury(address treasury);
    event SetSecondaryPool(address secondaryPool);
}