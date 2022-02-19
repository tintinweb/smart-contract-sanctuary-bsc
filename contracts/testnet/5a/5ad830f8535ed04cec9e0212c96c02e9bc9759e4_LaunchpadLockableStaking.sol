// SPDX-License-Identifier: MIT

pragma solidity =0.8.4;

import './SafeERC20Upgradeable.sol';
import './Initializable.sol';
import './IStakingLockable.sol';
import './ILevelManager.sol';
import './StandaloneTreasury.sol';
import './AdminableUpgradeable.sol';

contract LaunchpadLockableStaking is Initializable, AdminableUpgradeable, IStakingLockable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    ILevelManager public levelManager;
    // Keeps reward tokens
    StandaloneTreasury public treasury;

    struct PoolInfo {
        IERC20Upgradeable stakingToken;
        uint256 lastRewardBlock;
        uint256 accRewardPerShare;
    }

    struct Fees {
        address collectorAddress;
        // base 1000, 20% = 200
        uint256 depositFee;
        uint256 withdrawFee;
        uint256 collectedDepositFees;
        uint256 collectedWithdrawFees;
    }

    bool public halted;

    PoolInfo public liquidityMining;
    IERC20Upgradeable public rewardToken;
    // Should be with the same decimals number as the token decimals.
    uint256 public rewardPerBlock;
    uint256 private divider;

    mapping(address => UserInfo) public userInfo;
    Fees public fees;
    // If true, locked tokens cannot be withdrawn at all when locked
    bool public allowEarlyWithdrawal;
    uint256 public stakersCount;

    // For how long users token are locked after triggering the lock (first deposit or expired stake)
    uint256 public lockPeriod;
    // If specified, we calculate rewardPerBlock based on the given apr and maturity duration
    uint256 public fixedApr;
    // The date of user staking first for the first time
    mapping(address => uint256) public depositLockStart;
    bool public alwaysLockOnRegister;
    address[] public higherPools;

    event Deposit(address indexed user, uint256 amount, uint256 feeAmount);

    event Withdraw(address indexed user, uint256 amount, uint256 feeAmount, bool locked);
    event UppedLockPool(address indexed user, uint256 amount, address targetPool);
    event Claim(address indexed user, uint256 amount);
    event Halted(bool status);
    event FeesUpdated(uint256 depositFee, uint256 withdrawFee);
    event EarlyWithdrawalUpdated(bool allowEarlyWithdrawal);
    event RewardPerBlockUpdated(uint256 rewardPerBlock);

    event Locked(address indexed user, uint256 amount, uint256 lockPeriod, uint256 rewardPerBlock);

    modifier onlyLevelManager() {
        require(msg.sender == address(levelManager), 'Only LevelManager can lock');
        _;
    }

    function initialize(
        address _levelManager,
        address _treasury,
        address _feeAddress,
        uint256 _depositFee,
        uint256 _withdrawFee,
        uint256 _lockPeriod,
        uint256 _fixedApr
    ) public initializer {
        AdminableUpgradeable.initialize();

        levelManager = ILevelManager(_levelManager);
        setTreasury(_treasury);

        setFees(_feeAddress, _depositFee, _withdrawFee);
        divider = 1e12;
        allowEarlyWithdrawal = false;
        lockPeriod = _lockPeriod;
        fixedApr = _fixedApr;
    }

    function startMining() external onlyOwner {
        require(liquidityMining.lastRewardBlock == 0, 'Mining already started');
        liquidityMining.lastRewardBlock = block.number;
    }

    function isLocked(address account) public view override returns (bool) {
        return block.timestamp < depositLockStart[account] + lockPeriod;
    }

    function getLockPeriod() external view override returns (uint256) {
        return lockPeriod;
    }

    function getUnlocksAt(address account) external view override returns (uint256) {
        return depositLockStart[account] + lockPeriod;
    }

    function getLockedAmount(address account) external view override returns (uint256) {
        return userInfo[account].amount;
    }

    function getUserInfo(address account) external view override returns (UserInfo memory) {
        return userInfo[account];
    }

    // Reward per block calculates separately for each user based on the amount and lock period
    function getRewardPerBlock(address account) public view returns (uint256) {
        if (fixedApr == 0) {
            return 0;
        }
        if (userInfo[account].amount == 0 || !isLocked(account)) {
            return 0;
        }
        return getRewardPerSecond(account) * 3;
    }

    function getRewardPerSecond(address account) public view returns (uint256) {
        return (userInfo[account].amount * fixedApr) / 100 / 100 / (365 * 24 * 3600);
    }

    function setLevelManager(address _address) external override onlyOwner {
        levelManager = ILevelManager(_address);
    }

    function setTreasury(address _address) public onlyOwner {
        treasury = StandaloneTreasury(_address);
    }

    function setFixedApr(uint256 _apr) public onlyOwner {
        fixedApr = _apr;
        rewardPerBlock = 0;
    }

    function setLockPeriod(uint256 _lockPeriod) external override onlyOwner {
        lockPeriod = _lockPeriod;
    }

    function setFees(
        address _feeAddress,
        uint256 _depositFee,
        uint256 _withdrawFee
    ) public onlyOwner {
        require(_feeAddress != address(0), 'Fees collector address is not specified');
        require(_depositFee < 700, 'Max deposit fee: 70%');
        require(_withdrawFee < 700, 'Max withdraw fee: 70%');

        fees.collectorAddress = _feeAddress;
        fees.depositFee = _depositFee;
        fees.withdrawFee = _withdrawFee;
        emit FeesUpdated(_depositFee, _withdrawFee);
    }

    function setWithdrawFee(uint256 _withdrawFee) external onlyOwner {
        fees.withdrawFee = _withdrawFee;
        emit FeesUpdated(fees.depositFee, fees.withdrawFee);
    }

    function setAllowEarlyWithdrawal(bool status) public onlyOwner {
        allowEarlyWithdrawal = status;
        emit EarlyWithdrawalUpdated(status);
    }

    function halt(bool status) external onlyOwnerOrAdmin {
        halted = status;
        emit Halted(status);
    }

    function setRewardPerBlock(uint256 _rewardPerBlock) external onlyOwnerOrAdmin {
        rewardPerBlock = _rewardPerBlock;
        fixedApr = 0;
        emit RewardPerBlockUpdated(rewardPerBlock);
    }

    function setAlwaysLockOnRegister(bool status) external onlyOwnerOrAdmin {
        alwaysLockOnRegister = status;
    }

    function deposit(uint256 amount) external {
        require(!halted, 'Deposits are paused');

        address account = msg.sender;
        UserInfo storage user = userInfo[account];
        uint256 fee;

        if (!isLocked(account)) {
            depositLockStart[account] = block.timestamp;
            if (fixedApr > 0) {
                user.rewardDebt = 0;
            }
            emit Locked(account, amount, lockPeriod, 0);
        }

        updatePool();
        updateUserPending(account);

        if (amount > 0) {
            // Transfer deposit
            liquidityMining.stakingToken.safeTransferFrom(address(account), address(this), amount);

            // Collect fee
            (amount, fee) = takeFee(amount, fees.depositFee);
            fees.collectedDepositFees += fee;

            stakersCount += user.lastStakedAt > 0 ? 0 : 1;
            user.amount += amount;
            user.lastStakedAt = block.timestamp;
        }

        updateUserDebt(account);
        emit Deposit(account, amount, fee);
    }

    function withdraw(uint256 amount) external {
        address account = msg.sender;
        UserInfo storage user = userInfo[account];
        bool tokensLocked = isLocked(account);
        uint256 fee;

        require(allowEarlyWithdrawal || !tokensLocked, 'Account is locked');
        require(user.amount >= amount, 'Withdrawing more than you have!');

        updatePool();
        updateUserPending(account);

        if (amount > 0) {
            user.amount -= amount;
            user.lastUnstakedAt = block.timestamp;
            stakersCount -= user.amount == 0 && stakersCount > 0 ? 1 : 0;

            // Collect fee if tokens are locked and we allow early withdrawal
            if (allowEarlyWithdrawal && tokensLocked) {
                (amount, fee) = takeFee(amount, fees.withdrawFee);
                fees.collectedWithdrawFees += fee;
            }

            // Transfer withdrawal
            liquidityMining.stakingToken.safeTransfer(address(account), amount);
        }

        updateUserDebt(account);
        emit Withdraw(account, amount, fee, tokensLocked);
    }

    function restake() external {
        address account = msg.sender;
        UserInfo storage user = userInfo[account];
        require(!isLocked(account), 'Account is locked');

        updateUserPending(account);

        user.lastStakedAt = block.timestamp;
        user.rewardDebt = 0;
        depositLockStart[account] = block.timestamp;
        emit Locked(account, user.amount, lockPeriod, getRewardPerBlock(account));

        updateUserDebt(account);
    }

    function claim() external {
        address account = msg.sender;
        UserInfo storage user = userInfo[account];
        updatePool();
        updateUserPending(account);

        if (user.pendingRewards > 0) {
            uint256 claimedAmount = safeRewardTransfer(account, user.pendingRewards);
            user.pendingRewards -= claimedAmount;

            emit Claim(account, claimedAmount);
        }

        updateUserDebt(account);
    }

    function takeFee(uint256 amount, uint256 feePercent) internal returns (uint256, uint256) {
        if (feePercent == 0) {
            return (amount, 0);
        }

        uint256 feeAmount = (amount * feePercent) / 1000;
        liquidityMining.stakingToken.safeTransfer(fees.collectorAddress, feeAmount);

        return (amount - feeAmount, feeAmount);
    }

    function updateUserPending(address account) internal {
        UserInfo storage user = userInfo[account];
        if (user.amount == 0) {
            return;
        }

        uint256 aprPending = getFixedAprPendingReward(account);
        user.pendingRewards += aprPending - user.rewardDebt;
    }

    function getFixedAprPendingReward(address account) public view returns (uint256) {
        if (depositLockStart[account] == 0) {
            return 0;
        }

        // Pending tokens with fixed APR is limited to the APR matching the lock period,
        // e.g. 15% APR for 7 days = 15 / 365 * 7 = 0,28767123%
        uint256 passedTime = block.timestamp >= depositLockStart[account] + lockPeriod
            ? lockPeriod
            : block.timestamp - depositLockStart[account];

        // When lock reached maturity, it unlocks and stops generating rewards
        return passedTime * getRewardPerSecond(account);
    }

    function updateUserDebt(address account) internal {
        UserInfo storage user = userInfo[account];
        user.rewardDebt = getFixedAprPendingReward(account);
    }

    function setPoolInfo(IERC20Upgradeable _rewardToken, IERC20Upgradeable _stakingToken) external onlyOwner {
        require(
            address(rewardToken) == address(0) && address(liquidityMining.stakingToken) == address(0),
            'Token is already set'
        );
        rewardToken = _rewardToken;
        liquidityMining = PoolInfo({stakingToken: _stakingToken, lastRewardBlock: 0, accRewardPerShare: 0});
    }

    function updatePool() internal {
        require(
            liquidityMining.lastRewardBlock > 0 && block.number >= liquidityMining.lastRewardBlock,
            'Mining not yet started'
        );

        // Calculate from rewardPerBlock shared across all stakers
        uint256 stakingTokenSupply = liquidityMining.stakingToken.balanceOf(address(this));
        if (stakingTokenSupply == 0) {
            liquidityMining.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = block.number - liquidityMining.lastRewardBlock;
        uint256 tokensReward = multiplier * rewardPerBlock;
        liquidityMining.accRewardPerShare += ((tokensReward * divider) / stakingTokenSupply);
        liquidityMining.lastRewardBlock = block.number;
    }

    function safeRewardTransfer(address to, uint256 amount) internal returns (uint256) {
        uint256 balance = rewardToken.balanceOf(address(treasury));
        require(amount > 0, 'Reward amount must be more than zero');
        require(balance > 0, 'Not enough reward tokens for transfer');
        if (amount > balance) {
            rewardToken.safeTransferFrom(address(treasury), to, balance);
            return balance;
        }

        rewardToken.safeTransferFrom(address(treasury), to, amount);
        return amount;
    }

    function pendingRewards(address _user) external view returns (uint256) {
        if (liquidityMining.lastRewardBlock == 0 || block.number < liquidityMining.lastRewardBlock) {
            return 0;
        }

        UserInfo storage user = userInfo[_user];
        return getFixedAprPendingReward(_user) - user.rewardDebt + user.pendingRewards;
    }

    /**
     * When tokens are sent to the contract by mistake: withdraw the specified token.
     */
    function withdrawToken(address token) external onlyOwnerOrAdmin {
        IERC20Upgradeable(token).transfer(owner(), IERC20Upgradeable(token).balanceOf(address(this)));
    }

    function lock(address account, uint256 saleStart) external override onlyLevelManager {
        if ((isLocked(account) && !alwaysLockOnRegister) || userInfo[account].amount == 0) {
            return;
        }

        updateUserPending(account);
        depositLockStart[account] = block.timestamp;
        userInfo[account].rewardDebt = 0;
        emit Locked(account, userInfo[account].amount, lockPeriod, 0);
    }

    /**
     * Moves all user staked tokens to the next (or any higher?) pool higher:
     * - only one of the configured pools is allowed
     * - moves all the tokens to the selected pool, adding to already staked
     * - re-locks, the new lock starts from now
     * - leaves rewards in the old pool
     */
    function upPool(address targetPool) external {
        // Only allow to one of the configured pools (one of higher pools)
        require(targetPool != address(0), 'Must specify target pool');
        require(targetPool != address(this), 'Must specify target pool');
        require(higherPools.length > 0, 'Must have higherPools configured');
        bool poolAllowed = false;
        for (uint256 i = 0; i < higherPools.length; i++) {
            if (higherPools[i] == targetPool) {
                poolAllowed = true;
            }
        }
        require(poolAllowed, 'Pool not allowed');

        address account = msg.sender;
        UserInfo storage user = userInfo[account];
        require(user.amount > 0, 'No tokens locked');

        // Persists latest rewards
        updateUserPending(account);

        // Move tokens to the higher pool and lock it
        liquidityMining.stakingToken.approve(targetPool, user.amount);
        LaunchpadLockableStaking(targetPool).receiveUpPool(account, user.amount);

        emit UppedLockPool(account, user.amount, targetPool);

        // Unlock
        user.amount = 0;
        depositLockStart[account] = 0;
        updateUserDebt(account);
    }

    /**
     * Accepts the "up pool" request from another pool:
     * - moves the specified amount of tokens from user
     * - re-locks, the new lock starts from now
     */
    function receiveUpPool(address account, uint256 amount) external {
        require(account != address(0), 'Must specify valid account');
        require(amount > 0, 'Must specify non-zero amount');

        UserInfo storage user = userInfo[account];
        updateUserPending(account);

        // Re-lock
        depositLockStart[account] = block.timestamp;
        emit Locked(account, amount, lockPeriod, 0);

        // Transfer deposit
        liquidityMining.stakingToken.safeTransferFrom(msg.sender, address(this), amount);

        stakersCount += user.lastStakedAt > 0 ? 0 : 1;
        user.amount += amount;
        user.lastStakedAt = block.timestamp;
        user.rewardDebt = 0;

        emit Deposit(account, amount, 0);
    }

    function setHigherPools(address[] calldata pools) external onlyOwnerOrAdmin {
        higherPools = pools;
    }

    function batchSyncLockStatus(address[] calldata addresses) external onlyOwnerOrAdmin {
        for (uint256 i = 0; i < addresses.length; i++) {
            address addr = addresses[i];
            if (!isLocked(addr)) {
                updateUserPending(addr);
                (, uint256 time) = levelManager.getUserLatestRegistration(addr);
                if (time > block.timestamp) {
                    depositLockStart[addr] = block.timestamp;
                    userInfo[addr].rewardDebt = 0;
                }
            }
        }
    }

    function batchFixateRewardsBefore(address[] calldata addresses) external onlyOwnerOrAdmin {
        for (uint256 i = 0; i < addresses.length; i++) {
            address addr = addresses[i];
            if (userInfo[addr].amount > 0) {
                updateUserPending(addr);
                updateUserDebt(addr);
            }
        }
    }

    function batchFixateDebtAfter(address[] calldata addresses) external onlyOwnerOrAdmin {
        for (uint256 i = 0; i < addresses.length; i++) {
            address addr = addresses[i];
            if (userInfo[addr].amount > 0) {
                updateUserDebt(addr);
            }
        }
    }

    function unlock(address account) external onlyOwnerOrAdmin {
        updateUserPending(account);
        depositLockStart[account] = 0;
        updateUserDebt(account);
    }
}