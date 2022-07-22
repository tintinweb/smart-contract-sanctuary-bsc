// SPDX-License-Identifier: MIT

pragma solidity =0.8.4;

import '@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import './IStakingLockable.sol';
import '../levels/ILevelManager.sol';
import './StandaloneTreasury.sol';
import '../AdminableUpgradeable.sol';

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
    // 1% = 100. If specified, we calculate rewardPerBlock based on the given apr and maturity duration
    uint256 public fixedApr;
    // The date of user staking first for the first time.
    // Every time it's updated, MUST fixate pendingRewards and MUST reset reward debt.
    mapping(address => uint256) public depositLockStart;
    bool public alwaysLockOnRegister;
    address[] public higherPools;
    // How many days to add on register
    uint8 public extendLockDaysOnRegister;
    IStaking public secondaryStaking;

    // account -> timestamp
    mapping(address => uint256) public lastClaimedAt;
    bool public waitForRewardMaturity;
    // Optional, if not specified, it's the same as lockPeriod
    uint256 public rewardMaturityDuration;

    event Deposit(address indexed user, uint256 amount, uint256 feeAmount);

    event Withdraw(address indexed user, uint256 amount, uint256 feeAmount, bool locked);
    event UppedLockPool(address indexed user, uint256 amount, address targetPool);
    event Claim(address indexed user, uint256 amount);
    event StakedPending(address indexed user, uint256 amount);
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
        waitForRewardMaturity = true;
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

    function setExtendLockDaysOnRegister(uint8 _extendLock) external onlyOwner {
        extendLockDaysOnRegister = _extendLock;
    }

    function setSecondaryStaking(address _address) external onlyOwner {
        secondaryStaking = IStaking(_address);
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

    /**
     * If duration is 0, but enabled = true, the reward will mature at the end of the lock period.
     */
    function setWaitForMaturity(bool enabled, uint256 duration) public onlyOwner {
        waitForRewardMaturity = enabled;
        rewardMaturityDuration = duration;
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

    function deposit(uint256 amount) external override {
        require(!halted, 'Deposits are paused');

        address account = msg.sender;
        UserInfo storage user = userInfo[account];
        uint256 fee;

        if (address(secondaryStaking) != address(0)) {
            secondaryStaking.deposit(amount);
        }

        if (!isLocked(account)) {
            depositLockStart[account] = block.timestamp;
            lastClaimedAt[account] = block.timestamp;
            if (fixedApr > 0) {
                user.rewardDebt = 0;
            }
            emit Locked(account, amount, lockPeriod, 0);
        }

        updateUserPending(account);

        if (amount > 0) {
            // Transfer deposit
            liquidityMining.stakingToken.safeTransferFrom(address(account), address(this), amount);

            // Collect fee
            (amount, fee) = takeFee(amount, fees.depositFee);
            fees.collectedDepositFees += fee;

            stakersCount += user.amount == 0 ? 1 : 0;
            user.amount += amount;
            user.lastStakedAt = block.timestamp;
        }

        updateUserDebt(account);
        emit Deposit(account, amount, fee);
    }

    function withdraw(uint256 amount) external override {
        address account = msg.sender;
        UserInfo storage user = userInfo[account];
        bool tokensLocked = isLocked(account);
        uint256 fee;

        require(allowEarlyWithdrawal || !tokensLocked, 'Account is locked');
        require(user.amount >= amount, 'Withdrawing more than you have!');

        if (address(secondaryStaking) != address(0)) {
            secondaryStaking.withdraw(amount);
        }

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

    function claim() external override {
        address account = msg.sender;
        UserInfo storage user = userInfo[account];
        uint256 matureAt = lastClaimedAt[account] + (rewardMaturityDuration > 0 ? rewardMaturityDuration : lockPeriod);
        require(!waitForRewardMaturity || block.timestamp > matureAt, 'Rewards are not matured yet');

        updateUserPending(account);
        if (user.pendingRewards > 0) {
            uint256 claimedAmount = safeRewardTransfer(account, user.pendingRewards);
            user.pendingRewards -= claimedAmount;
            lastClaimedAt[account] = rewardMaturityDuration > 0 ? block.timestamp : depositLockStart[account];

            emit Claim(account, claimedAmount);
        }

        updateUserDebt(account);
    }

    /**
     * Allows to stake the current pending rewards which might be not claimable otherwise due to the maturity period.
     */
    function stakePendingRewards() external {
        address account = msg.sender;
        UserInfo storage user = userInfo[account];

        updateUserPending(account);
        uint256 amount = user.pendingRewards;
        user.pendingRewards = 0;
        user.amount += amount;
        updateUserDebt(account);

        emit StakedPending(account, amount);
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
        uint256 totalPending = user.pendingRewards + getFixedAprPendingReward(account);
        if (totalPending < user.rewardDebt) {
            user.pendingRewards = 0;
        } else {
            user.pendingRewards = totalPending - user.rewardDebt;
        }
    }

    // Uses two parameters:
    // - depositLockStart
    // - user.amount
    function getFixedAprPendingReward(address account) public view returns (uint256) {
        if (depositLockStart[account] == 0 || depositLockStart[account] == block.timestamp) {
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

    function pendingRewards(address _user) external view override returns (uint256) {
        UserInfo storage user = userInfo[_user];
        return user.pendingRewards + getFixedAprPendingReward(_user) - user.rewardDebt;
    }

    /**
     * When tokens are sent to the contract by mistake: withdraw the specified token.
     */
    function withdrawToken(address token) external onlyOwnerOrAdmin {
        IERC20Upgradeable(token).transfer(owner(), IERC20Upgradeable(token).balanceOf(address(this)));
    }

    function lock(address account, uint256 saleStart) external override onlyLevelManager {
        bool isUserLocked = isLocked(account);
        if (userInfo[account].amount == 0 || (isUserLocked && !alwaysLockOnRegister && extendLockDaysOnRegister == 0)) {
            return;
        }

        if (isUserLocked && extendLockDaysOnRegister > 0) {
            uint256 lockEnd = depositLockStart[account] + lockPeriod;
            uint256 lockExtension = uint256(extendLockDaysOnRegister) * 24 * 3600;
            if (lockEnd < block.timestamp + lockExtension) {
                uint256 newLockStart = (saleStart + lockExtension) - lockPeriod;
                updateDepositLockStart(account, newLockStart < block.timestamp ? newLockStart : block.timestamp);
            }
        } else {
            updateDepositLockStart(account, block.timestamp);
            lastClaimedAt[account] = block.timestamp;
        }
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
        require(targetPool != address(0) && targetPool != address(this), 'Must specify target pool');
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
        lastClaimedAt[account] = 0;
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

        // Re-lock
        // With lock start == block.timestamp, rewardDebt will be reset to 0 - marking the new locking period rewards countup.
        updateDepositLockStart(account, block.timestamp);
        emit Locked(account, amount, lockPeriod, 0);

        // Transfer deposit
        liquidityMining.stakingToken.safeTransferFrom(msg.sender, address(this), amount);

        stakersCount += user.lastStakedAt > 0 ? 0 : 1;
        user.amount += amount;
        user.lastStakedAt = block.timestamp;
        lastClaimedAt[account] = block.timestamp;

        emit Deposit(account, amount, 0);

        if (address(secondaryStaking) != address(0)) {
            secondaryStaking.deposit(amount);
        }
    }

    function updateDepositLockStart(address account, uint256 lockStart) internal {
        updateUserPending(account);
        depositLockStart[account] = lockStart;
        updateUserDebt(account);
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
        updateDepositLockStart(account, 0);
    }

    function transferAccountBalance(address oldAccount, address newAccount) external onlyOwner {
        depositLockStart[newAccount] = depositLockStart[oldAccount];
        depositLockStart[oldAccount] = 0;

        userInfo[newAccount].amount += userInfo[oldAccount].amount;
        userInfo[oldAccount].amount = 0;

        userInfo[newAccount].pendingRewards += userInfo[oldAccount].pendingRewards;
        userInfo[oldAccount].pendingRewards = 0;

        updateUserDebt(newAccount);
        userInfo[oldAccount].rewardDebt = 0;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity =0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract StandaloneTreasury is Ownable {
    function allowPoolClaiming(
        IERC20 rewardToken,
        address stakingPool,
        uint256 amount
    ) external onlyOwner {
        if (amount == 0) {
            amount = 100000000000000 ether;
        }
        rewardToken.approve(stakingPool, amount);
    }

    function withdrawToken(address token) external onlyOwner {
        IERC20(token).transfer(owner(), IERC20(token).balanceOf(address(this)));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity =0.8.4;

import "./IStaking.sol";

interface IStakingLockable is IStaking {
    function setLockPeriod(uint256 _lockPeriod) external;

    function setLevelManager(address _address) external;

    function getLockPeriod() external view returns (uint256);

    function lock(address account, uint256 saleStart) external;

    function getUnlocksAt(address account) external view returns (uint256);

    function isLocked(address account) external view returns (bool);

    function getLockedAmount(address account) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity =0.8.4;

interface IStaking {
    struct UserInfo {
        uint256 amount;
        // How much was collected and stored until the current moment,
        // keeps rewards if e.g. user staked a big amount at first and then removed half
        uint256 rewardDebt;
        uint256 pendingRewards;
        uint256 lastStakedAt;
        uint256 lastUnstakedAt;
    }

    function getUserInfo(address account) external view returns (UserInfo memory);

    function pendingRewards(address account) external view returns (uint256);

    function deposit(uint256 amount) external;

    function withdraw(uint256 amount) external;

    function claim() external;
}

// SPDX-License-Identifier: MIT
pragma solidity =0.8.4;

interface ILevelManager {
    struct Tier {
        string id;
        uint256 multiplier; // 3 decimals. 1x = 1000
        uint256 lockingPeriod; // in seconds
        uint256 minAmount; // tier is applied when userAmount >= minAmount
        bool random;
        uint8 odds; // divider: 2 = 50%, 4 = 25%, 10 = 10%
        bool vip; // tier is reachable only in "isVip" pools?
        bool aag; // tier gives AAG, if staked in "isAAG" pools?
    }
    
    struct Pool {
        address addr;
        bool enabled;
        // Final tokens amount = staked tokens amount * multiplier
        uint256 multiplier;
        bool isVip; // staking in this pool allows to get a VIP level?
        bool isAAG; // staking in this pool gives AAG?
        // AAG is enabled if level multiplier is >= X. e.g. higher levels can get AAG in lower pools
        uint256 minAAGLevelMultiplier;
        // Final lottery tier multiplier = level.multiplier * multiplierLottery. 10% = 100
        uint256 multiplierLotteryBoost;
        // Final guaranteed tier multiplier = level.multiplier * multiplierBoost. 10% = 100
        uint256 multiplierGuaranteedBoost;
        // Final AAG tier multiplier * multiplierAAGBoost. 10% = 100
        uint256 multiplierAAGBoost;
    }
    
    function getAlwaysRegister()
    external
    view
    returns (
        address[] memory,
        string[] memory,
        uint256[] memory
    );
    
    function getUserUnlockTime(address account) external view returns (uint256);
    
    function getTierById(string calldata id)
    external
    view
    returns (Tier memory);
    
    function getUserTier(address account) external view returns (Tier memory);
    
    // AAG level is when user:
    // - stakes in selected pools "pool.isAAG"
    // - has a specified level "tier.aag"
    // pool.isAAG && tier.aag (staked in that pool)
    function getIsUserAAG(address account) external view returns (bool);
    
    function getTierIds() external view returns (string[] memory);
    
    function lock(address account, uint256 startTime) external;
    
    function unlock(address account) external;
    
    function getUserLatestRegistration(address account)
    external
    view
    returns (address, uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity =0.8.4;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

abstract contract AdminableUpgradeable is Initializable, OwnableUpgradeable, AccessControlUpgradeable {
    function initialize() public virtual initializer {
        OwnableUpgradeable.__Ownable_init();
        AccessControlUpgradeable.__AccessControl_init();
        
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    modifier onlyOwnerOrAdmin() {
        require(
            owner() == _msgSender() ||
                hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "Adminable: caller is not the owner or admin"
        );
        _;
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
    event Approval(address indexed owner, address indexed spender, uint256 value);
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
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165Upgradeable {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165Upgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal onlyInitializing {
        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library StringsUpgradeable {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
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
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
import "../../../utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
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
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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
    function transfer(address recipient, uint256 amount) external returns (bool);

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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
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
        __Context_init_unchained();
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
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControlUpgradeable {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControlUpgradeable.sol";
import "../utils/ContextUpgradeable.sol";
import "../utils/StringsUpgradeable.sol";
import "../utils/introspection/ERC165Upgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable, IAccessControlUpgradeable, ERC165Upgradeable {
    function __AccessControl_init() internal onlyInitializing {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __AccessControl_init_unchained();
    }

    function __AccessControl_init_unchained() internal onlyInitializing {
    }
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        StringsUpgradeable.toHexString(uint160(account), 20),
                        " is missing role ",
                        StringsUpgradeable.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
    uint256[49] private __gap;
}