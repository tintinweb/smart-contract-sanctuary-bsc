// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "./interfaces/IRewardMinter.sol";
import "./interfaces/ITreatToken.sol";
import "./SafeOwnable.sol";
import "./VestingManager.sol";

/*
 * @title Pool contract that allows staking tokens for fixed period of time,
 * extend or replenish deposits,
 */
contract FixedPeriodPool is SafeOwnable, ReentrancyGuard {
    struct DepositInfo {
        bool active;            // Is deposit active? true - active, false - withdrawn
        uint64 unlockBlock;     // Unlock block of user deposit
        uint256 stakeShares;    // Amount of stake shares the user has for staking
        uint256 rewardShares;   // Amount of reward shares the user has for staking. Depends on deposit amount and lock duration
        uint256 lastUpdateAccTokenPerShare;     // Last value of accTokenPerShare during last deposit update/creation time
        uint256 pendingRewards; // Pending rewards amount. Initially has 0 value. Updated on deposit replenishing
    }

    // struct for view function
    struct ExtendedDepositInfo {
        uint64 depositId;           // ID index of deposit
        bool active;                // Is deposit active? true - active, false - withdrawn
        uint64 unlockBlock;         // Unlock block of user deposit
        uint64 remainingDuration;   // Remaining blocks number till the end of deposit
        uint256 stakeShares;        // Amount of stake shares the user has for staking
        uint256 stakeTokens;        // Amount of stake tokens the user has deposited
        uint256 rewardShares;       // Amount of reward shares the user has for staking. Depends on deposit amount and lock duration
        uint256 pendingRewards;     // Amount of pending rewards
        uint256 rewardsPerDay;      // Amount of reward tokens user is receiving per day for this deposit
        uint256 lastUpdateAccTokenPerShare;   // Last value of accTokenPerShare during last deposit update/creation time
        uint256 locked;                 // Amount of locked tokens
        uint256 remainingVestingTime;   // Remaining vesting duration
    }

    // struct for ending deposits
    struct DepositPath {
        address account;       // Address of deposit owner
        uint64 depositId;     // ID index of deposit
    }

    IERC20 public immutable burnToken;   // ERC20 token that is burned in order to unlock staking
    IERC20 public immutable stakeToken;
    IERC20 public immutable rewardToken;
    uint256 public immutable defaultStakePPS;
    uint256 public immutable PRECISION_FACTOR;
    bool public immutable allowDepositOnBehalf;         //true - allow deposit/replenish on behalf. false - forbid
    bool public immutable stakeTreatToken;                 //Stake token is Treat token. (Special functions will be used)
    address private constant BURN_WALLET = 0x000000000000000000000000000000000000dEaD;

    uint256 private constant BLOCKS_PER_DAY = 1200 * 24;

    // using uint32 for gas savings (SLOAD). uint32.max (2^32) should be more than enough for any block duration
    uint32 public maxMultiplier;    // maximal multiplier of rewards shares, in basis points
    uint32 public minLockDuration;  // minimal lock time allowed for deposit
    uint32 public maxLockDuration;  // maximal lock time allowed for deposit
    // Time after the end of deposit, when only deposit owner can withdraw it
    uint32 public freeWithdrawalPeriod = 1200 * 24 * 7; // 7 days
    // Time after {freeWithdrawalPeriod} has passed, while which rewards for closing it are growing
    // At the start of this period the one, who closes unlocked (finished) deposit will get ~0% of collected rewards
    // By the end of this period rewards for closing deposit will become 100% of collected rewards
    uint32 public eliminationPeriodDuration = 1200 * 24 * 200; //200 days
    uint32 public startBlock;
    uint32 public lastRewardBlock;
    uint32 public vestingDuration;  // period, during which tokens will be fully vested

    // using uint128 for gas savings (SLOAD).
    // uint128.max (2^128) should be more than enough for `rewardPerBlock` and `maxDepositAmount` values
    uint128 public rewardPerBlock;
    // maximum amount of stake tokens user is allowed to deposit. 0 for no limitations
    uint128 public maxDepositAmount;
    // Amount of tokens to be burned in order to unlock staking
    uint256 public burnAmountToUnlock;

    // Accrued token per share
    uint256 public accTokenPerShare;
    uint256 public stakeTotalShares = 0;    // sum of stake shares of each user
    uint256 public rewardTotalShares = 0;   // sum of rewards shares of each user
    //account => => depositId => VestingData
    mapping(address => mapping(uint256 => VestingManager.VestingData)) public tokenVesting;
    mapping(address => uint256) public totalUserStaked;  // Sum of active users stake shares
    mapping(address => uint256) public unclaimedRewards;  // Sum of unclaimed rewards
    // account address => Array of user deposits
    mapping(address => DepositInfo[]) public deposits;
    // true - user has unlocked staking by burning tokens
    mapping(address => bool) public hasUnlockedStaking;

    event Redeposit(
        address indexed account,
        bool harvestedRewards,
        uint32 depositId, // uint32 for gas saving
        uint32 indexed unlockBlock,
        uint256 earnedRewards,
        uint256 rewardShares
    );

    event NewDeposit(
        address indexed account,
        uint32 depositId, // uint32 for gas saving
        uint32 indexed unlockBlock,
        uint256 amount,
        uint256 stakeShares,
        uint256 rewardShares
    );

    event DepositUpdate (
        address indexed account,
        uint32 depositId,
        uint32 additionalLockDuration,
        uint32 indexed newUnlockBlock,
        uint256 depositedAmount,
        uint256 addedStakeShares,
        uint256 addedRewardShares
    );

    event Withdrawal(
        address indexed account,
        bool harvestedRewards,
        uint32 depositId, // uint32 for gas saving
        uint256 amount,
        uint256 shares,
        uint256 rewards
    );

    event ClosedDeposits (
        address indexed account,
        uint256 rewards,
        DepositPath[] depositPaths
    );

    event EmergencyWithdrawal(
        address indexed account,
        uint32 depositId, // uint32 for gas saving
        uint256 amount,
        uint256 shares
    );
    event RewardsHarvested(address account, uint256 amount);

    event PoolUnlock(address);
    event NewBurnAmountToUnlock(uint256);
    event NewRewardPerBlock(uint128);
    event NewMaxDepositAmount(uint128);
    event NewStartBlock(uint32);
    event NewMaxMultiplier(uint32);
    event NewMinLockDuration(uint32);
    event NewMaxLockDuration(uint32);
    event NewFreeWithdrawalPeriod(uint32);
    event NewEliminationPeriodDuration(uint32);
    event NewVestingDuration(uint32);

    error UserLocked(address account);   // user has not unlocked the pool yet. Need to burn tokens to do it
    error InvalidPath(uint256 index, address account, uint256 depositId);   // no such deposit
    error NotActive(uint256 index, address account, uint256 depositId);     // deposit is not active anymore
    error NotUnlocked(uint256 index, address account, uint256 depositId);   // deposit has not been unlocked yet


    /*
     * @notice Initialize the contract
     * @param _stakeToken Stake token address
     * @param _rewardToken Reward token address
     * @param _values Array of values
     * _values[0] _startBlock Start block number
     * _values[1] _rewardPerBlock Reward per block (in rewardTokens)
     * _values[2] _maxDepositAmount Maximum amount of stake tokens user is allowed to deposit. 0 for no limitations
     * _values[3] _maxMultiplier Maximum lock duration of deposit
     * _values[4] _minLockDuration Minimum number of blocks user can lock deposit
     * _values[5] _maxLockDuration Maximum number of blocks user can lock deposit
     * _values[6] _vestingDuration Vesting duration of staked tokens
     * _values[7] _burnAmountToUnlock Amount of tokens, that must be burned to unlock this pool for user
     * @param _burnToken ERC20 token address, which will be used to unlock staking by burning
     * @param _allowDepositOnBehalf true - allow deposit/replenish on behalf. false - forbid
     * @param _stakeTreatToken true - Stake token is Treat token. (Special functions will be used)
     */
    constructor(
        address _stakeToken,
        address _rewardToken,
        uint256[] memory _values,
        IERC20 _burnToken,
        bool _allowDepositOnBehalf,
        bool _stakeTreatToken
    ) {
        require(uint128(_values[1]) > 0, "Invalid reward per block");
        require(!_stakeTreatToken || uint32(_values[6]) > 0, "Invalid vesting duration");

        stakeToken = IERC20(_stakeToken);
        rewardToken = IERC20(_rewardToken);
        allowDepositOnBehalf = _allowDepositOnBehalf;
        stakeTreatToken = _stakeTreatToken;

        startBlock = uint32(_values[0]);
        lastRewardBlock = uint32(_values[0]);
        rewardPerBlock = uint128(_values[1]);
        maxDepositAmount = uint128(_values[2]);
        maxMultiplier = uint32(_values[3]);
        minLockDuration = uint32(_values[4]);
        maxLockDuration = uint32(_values[5]);
        vestingDuration = uint32(_values[6]);
        burnAmountToUnlock = uint256(_values[7]);

        burnToken = _burnToken;

        uint256 decimalsRewardToken = uint256(
            IERC20Metadata(_rewardToken).decimals()
        );
        uint256 decimalsStakeToken = uint256(
            IERC20Metadata(_stakeToken).decimals()
        );
        require(decimalsRewardToken < 30, "Must be inferior to 30");
        PRECISION_FACTOR = uint256(10**(30 - decimalsRewardToken));
        require(decimalsRewardToken >= 5 && decimalsStakeToken >= 5, "Invalid decimals");

        defaultStakePPS = 10 ** (decimalsStakeToken - decimalsStakeToken / 2);
    }


    /*
     * @notice Unlocks pool for account
     * @param account Account address which needs to unlock this pool
     * @dev In order to allow staking to `account`, burns `burnAmountToUnlock` amount of ERC20 "burnTokens"
     */
    function unlockPool(address account) external {
        require(!hasUnlockedStaking[account], "Already unlocked");
        _unlockPool(account);
    }


    /*
     * @notice Creates deposit on behalf of msg.sender
     * @param amount amount to deposit (in stakedToken)
     * @param lockDuration Number of blocks the deposit should be locked for
     */
    function deposit(uint256 amount, uint32 lockDuration) external {
        _deposit(amount, lockDuration, msg.sender);
    }


    /*
     * @notice Creates deposit on behalf of account address
     * @param amount amount to deposit (in stakedToken)
     * @param lockDuration Number of blocks the deposit should be locked for
     * @param account future owner of deposit
     * @dev Should be used by ZAP and other smart contracts
     */
    function depositOnBehalf(uint256 amount, uint32 lockDuration, address account) external {
        require(allowDepositOnBehalf, "Not allowed");
        _deposit(amount, lockDuration, account);
    }


    /*
     * @notice Replenishes deposit with specific ID, that belongs to msg.sender
     * @param depositId ID index of deposit
     * @param amount amount to add to deposit (in stakedToken)
     * @param additionalLockDuration Number of blocks to add to deposit duration
     * @dev Increasing deposit amount or/and lock duration will result in increasing rewardShares of deposit
     * @dev Increasing rewardShares of deposit will result in increasing APR for this deposit
     */
    function replenishAndExtendDeposit(
        uint256 depositId,
        uint256 amount,
        uint32 additionalLockDuration
    ) external {
        _replenishAndExtendDeposit(
            msg.sender,
            depositId,
            amount,
            additionalLockDuration
        );
    }


    /*
     * @notice Replenishes deposit with specific ID, that belongs to account
     * @param account Account-owner of deposit
     * @param depositId ID index of deposit
     * @param amount amount to add to deposit (in stakedToken)
     * @dev Should be used by ZAP and other smart contracts
     * @dev Can't increase lock time of deposit. Only deposit amount. So no negative effect can be done.
     */
    function replenishDepositOnBehalf(
        address account,
        uint256 depositId,
        uint256 amount
    ) external {
        require(allowDepositOnBehalf, "Not allowed");
        _replenishAndExtendDeposit(
            account,
            depositId,
            amount,
            0
        );
    }


    /*
     * @notice Withdraws deposit and collected rewards
     * @param depositId ID index of the deposit
     * @param shouldHarvestRewards Should user receive owned rewards?
     * true - immediately receive rewards, false - harvest rewards later
     */
    function withdraw(uint256 depositId, bool shouldHarvestRewards) external nonReentrant {
        require(deposits[msg.sender].length > depositId, "Invalid deposit ID");
        DepositInfo memory userDeposit = deposits[msg.sender][depositId];
        require(userDeposit.active, "Already withdrawn");
        deposits[msg.sender][depositId].active = false;
        require(userDeposit.unlockBlock < block.number, "Can't unlock yet");

        _updatePool();

        uint256 stakeAmount = userDeposit.stakeShares * stakePPS();

        uint256 pendingRewards = userDeposit.pendingRewards + userDeposit.rewardShares
            * (accTokenPerShare - userDeposit.lastUpdateAccTokenPerShare) / PRECISION_FACTOR;

        totalUserStaked[msg.sender] -= userDeposit.stakeShares;
        stakeTotalShares -= userDeposit.stakeShares;
        rewardTotalShares -= userDeposit.rewardShares;

        _executeWithdrawal(
            msg.sender,
            depositId,
            stakeAmount,
            vestingDuration
        );

        if (shouldHarvestRewards) {
            IRewardMinter(address(rewardToken)).mint(msg.sender, pendingRewards);
        } else {
            unclaimedRewards[msg.sender] += pendingRewards;
        }

        emit Withdrawal(
            msg.sender,
            shouldHarvestRewards,
            uint32(depositId),
            stakeAmount,
            userDeposit.stakeShares,
            pendingRewards
        );
    }


    /*
     * @notice Withdraws deposit without collecting rewards. For EMERGENCY use only
     * @param depositId ID index of the deposit
     * @dev Should be used only if there is a problem withdrawing deposit with collecting rewards
     */
    function emergencyWithdraw(uint256 depositId) external nonReentrant {
        require(deposits[msg.sender].length > depositId, "Invalid deposit ID");
        DepositInfo memory userDeposit = deposits[msg.sender][depositId];
        require(userDeposit.active, "Already withdrawn");

        deposits[msg.sender][depositId].active = false;
        require(userDeposit.unlockBlock < block.number, "Can't unlock yet");

        uint256 stakeAmount = userDeposit.stakeShares * stakePPS();

        uint256 pendingRewards = userDeposit.pendingRewards + userDeposit.rewardShares
            * (accTokenPerShare - userDeposit.lastUpdateAccTokenPerShare) / PRECISION_FACTOR;

        totalUserStaked[msg.sender] -= userDeposit.stakeShares;
        stakeTotalShares -= userDeposit.stakeShares;
        rewardTotalShares -= userDeposit.rewardShares;

        // distributing lost rewards among other users (just in case)
        if (rewardTotalShares > 0) {
            accTokenPerShare += pendingRewards * PRECISION_FACTOR / rewardTotalShares;
        }

        _executeWithdrawal(
            msg.sender,
            depositId,
            stakeAmount,
            vestingDuration
        );

        emit EmergencyWithdrawal(
            msg.sender,
            uint32(depositId),
            stakeAmount,
            userDeposit.stakeShares
        );
    }


    /*
     * @notice Deposits again unlocked (finished) deposit
     * @param depositId ID index of the deposit
     * @param lockDuration Number of blocks the deposit should be locked for
     * @param shouldHarvestRewards Should user receive owned rewards?
     * true - immediately receive rewards, false - harvest rewards later
     */
    function redeposit(
        uint256 depositId,
        uint32 lockDuration,
        bool shouldHarvestRewards
    ) external nonReentrant {
        require(block.number >= startBlock, "Pool is not active");
        require(rewardPerBlock > 0, "Pool has ended");
        require(deposits[msg.sender].length > depositId, "Invalid deposit ID");
        require(lockDuration >= minLockDuration, "Below minLockDuration");
        require(lockDuration <= maxLockDuration, "Over maxLockDuration");
        DepositInfo memory userDeposit = deposits[msg.sender][depositId];
        require(userDeposit.active, "Already withdrawn");
        require(userDeposit.unlockBlock < block.number, "Can't unlock yet");
        require(
            maxDepositAmount == 0
            || totalUserStaked[msg.sender] * stakePPS() <= maxDepositAmount,
            "Over max stake limit"
        );

        _updatePool();

        uint256 pendingRewards = userDeposit.pendingRewards + userDeposit.rewardShares
            * (accTokenPerShare - userDeposit.lastUpdateAccTokenPerShare) / PRECISION_FACTOR;

        uint256 rewardShares = deposits[msg.sender][depositId].stakeShares
            * _getRewardMultiplier(lockDuration) / 10_000;

        rewardTotalShares = rewardTotalShares + rewardShares - userDeposit.rewardShares;

        deposits[msg.sender][depositId].unlockBlock = uint64(block.number + lockDuration);
        deposits[msg.sender][depositId].rewardShares = rewardShares;
        deposits[msg.sender][depositId].lastUpdateAccTokenPerShare = accTokenPerShare;
        deposits[msg.sender][depositId].pendingRewards = 0;

        if (shouldHarvestRewards) {
            IRewardMinter(address(rewardToken)).mint(msg.sender, pendingRewards);
        } else {
            unclaimedRewards[msg.sender] += pendingRewards;
        }

        emit Redeposit(
            msg.sender,
            shouldHarvestRewards,
            uint32(depositId),
            uint32(block.number + lockDuration),
            pendingRewards,
            rewardShares
        );
    }


    /*
     * @notice Allows to close unlocked (finished) deposits and receive rewards.
     * @param depositPaths Array of deposit paths: Address of deposit owner + ID index of deposit
     */
    function closeDeposits(DepositPath[] calldata depositPaths) external nonReentrant {
        _updatePool();
        // gas savings + stack too deep
        uint256[] memory values = new uint256[](5);
        values[0] = freeWithdrawalPeriod;
        values[1] = accTokenPerShare;
        values[2] = vestingDuration;
        values[3] = eliminationPeriodDuration;
        values[4] = stakePPS();

        uint256 rewards = 0;
        for (uint i = 0; i < depositPaths.length; i++) {
            uint256 rewardForDepositClosing = _closeDeposit(
                values,
                depositPaths[i].account,
                depositPaths[i].depositId,
                i
            );

            rewards += rewardForDepositClosing;
        }

        IRewardMinter(address(rewardToken)).mint(msg.sender, rewards);

        emit ClosedDeposits(msg.sender, rewards, depositPaths);
    }


    /*
     * @notice Mints unclaimed rewards to the user
     * @param account Account address, which owns the rewards
     * @dev Either msg.sender or tx.origin must be account owner. Can't harvest for someone else
     */
    function harvestRewards(address account) external {
        require(account == msg.sender || account == tx.origin, "Invalid account");
        uint256 _unclaimedRewards = unclaimedRewards[account];
        require(_unclaimedRewards > 0, "Nothing to claim");

        IRewardMinter(address(rewardToken)).mint(account, _unclaimedRewards);
        unclaimedRewards[account] = 0;

        emit RewardsHarvested(account, _unclaimedRewards);
    }


    /*
     * @notice Returns collected user info
     * @param account User account address
     * @return totalStakeShares Total stake shares of active deposits
     * @return totalStakeTokens Total stake tokens of active deposits
     * @return totalRewardShares Total reward shares of active deposits
     * @return totalPendingRewards Total amount of pending rewards for all deposits
     * @return totalRewardsPerDay Total rewards per day that user receives for all deposits
     * @return totalTreatTokensLocked Total TreatTokens locked
     * @return unclaimedUserRewards Amount of rewards that can be claimed with `harvestRewards` function
     * @return depositsData Detailed deposit info
     */
    function getUserInfo(address account) external view
    returns (
        uint256 totalStakeShares,
        uint256 totalStakeTokens,
        uint256 totalRewardShares,
        uint256 totalPendingRewards,
        uint256 totalRewardsPerDay,
        uint256 totalTreatTokensLocked,
        uint256 unclaimedRewardsAmount,
        ExtendedDepositInfo[] memory depositsData
    ) {
        totalStakeShares = totalUserStaked[account];
        unclaimedRewardsAmount = unclaimedRewards[account];
        totalRewardShares = 0;
        totalPendingRewards = 0;
        totalRewardsPerDay = 0;
        totalTreatTokensLocked = 0;
        depositsData = new ExtendedDepositInfo[](deposits[account].length);

        uint256 newAccTokenPerShare = _newAccTokenPerShare();
        uint256 _stakePPS = stakePPS();
        uint256 _vestingDuration = vestingDuration;

        for(uint i = 0; i < deposits[account].length; i++) {
            depositsData[i] = _getDepositData(
                account,
                i,
                _stakePPS,
                newAccTokenPerShare,
                _vestingDuration
            );
            if (!depositsData[i].active) continue;

            totalRewardShares += depositsData[i].rewardShares;
            totalPendingRewards += depositsData[i].pendingRewards;
            totalRewardsPerDay += depositsData[i].rewardsPerDay;
            totalTreatTokensLocked += depositsData[i].locked;
        }

        totalStakeTokens = totalStakeShares * _stakePPS;
    }


    /*
     * @notice Collects deposit data
     * @param account User account address
     * @param depositId DepositId
     * @return depositData Deposit data
     */
    function getDepositData(
        address account,
        uint256 depositId
    ) external view returns (ExtendedDepositInfo memory depositData) {
        uint256 _stakePPS = stakePPS();
        uint256 newAccTokenPerShare = _newAccTokenPerShare();
        uint256 _vestingDuration = vestingDuration;
        require(deposits[account].length > depositId, "Invalid deposit ID");

        return _getDepositData(
            account,
            depositId,
            _stakePPS,
            newAccTokenPerShare,
            _vestingDuration
        );
    }


    /*
     * @notice Collects deposit data
     * @param account User account address
     * @param depositId DepositId
     * @param _stakePPS Stake Price per share
     * @param newAccTokenPerShare Updated `accTokenPerShare`
     * @param _vestingDuration Vesting duration
     * @return depositData Extended deposit info
     */
    function _getDepositData(
        address account,
        uint256 depositId,
        uint256 _stakePPS,
        uint256 newAccTokenPerShare,
        uint256 _vestingDuration
    ) internal view returns (ExtendedDepositInfo memory depositData) {
        DepositInfo memory userDeposit = deposits[account][depositId];

        if (!userDeposit.active) {
            return ExtendedDepositInfo({
                depositId: uint64(depositId),
                active: false,
                unlockBlock: userDeposit.unlockBlock,
                remainingDuration: 0,
                stakeShares: 0,
                stakeTokens: 0,
                rewardShares: 0,
                pendingRewards: 0,
                rewardsPerDay: 0,
                lastUpdateAccTokenPerShare: 0,
                locked: 0,
                remainingVestingTime: 0
            });
        }

        uint256 pendingRewards = userDeposit.pendingRewards + userDeposit.rewardShares
            * (newAccTokenPerShare - userDeposit.lastUpdateAccTokenPerShare) / PRECISION_FACTOR;

        uint256 rewardsPerDay = BLOCKS_PER_DAY * uint256(rewardPerBlock)
            * userDeposit.rewardShares / rewardTotalShares;

        (uint256 locked, uint256 remainingVestingTime) = VestingManager.getLockedAndRemaining(
            tokenVesting[account][depositId],
            _vestingDuration
        );

        return ExtendedDepositInfo({
            depositId: uint64(depositId),
            active: userDeposit.active,
            unlockBlock: userDeposit.unlockBlock,
            remainingDuration: userDeposit.unlockBlock > uint64(block.number)
                ? userDeposit.unlockBlock - uint64(block.number)
                : 0,
            stakeShares: userDeposit.active ? userDeposit.stakeShares : 0,
            stakeTokens: userDeposit.active ? userDeposit.stakeShares * _stakePPS : 0,
            rewardShares: userDeposit.active ? userDeposit.rewardShares : 0,
            pendingRewards: userDeposit.active ? pendingRewards : 0,
            rewardsPerDay: userDeposit.active ? rewardsPerDay : 0,
            lastUpdateAccTokenPerShare: userDeposit.lastUpdateAccTokenPerShare,
            locked: locked,
            remainingVestingTime: remainingVestingTime
        });
    }


    /*
     * @notice Returns most of pools variables in a single call
     * @return _stakeToken Stake token address
     * @return _rewardToken Reward token address
     * @return _burnToken ERC20 token address, which is used to unlock staking by burning
     * @return values array:
     * [0]: startBlock Start block of the pool
     * [1]: rewardPerBlock Rewards per block amount
     * [2]: maxDepositAmount Maximum amount of stake tokens user is allowed to deposit. 0 for no limitations
     * [3]: lastRewardBlock Last reward block
     * [4]: stakeTotalShares Total stake shares
     * [5]: rewardTotalShares Total rewards shares
     * [6]: stakeTotalAmount Total amount of deposited tokens
     * [7]: stakePPS Stake price per share
     * [8]: accTokenPerShare Accrued tokens per share
     * [9]: maxMultiplier Maximum rewards multiplier (for locking for long period of time)
     * [10]: minLockDuration Minimum lock duration for locking the deposit
     * [11]: maxLockDuration Maximum lock duration for locking the deposit
     * [12]: freeWithdrawalPeriod Time after the end of deposit, when only deposit owner can withdraw it
     * [13]: eliminationPeriodDuration Time after {freeWithdrawalPeriod} has passed, while which rewards for closing it are growing
     * [14]: burnAmountToUnlock Amount of tokens, that must be burned to unlock this pool for user
     * [15]: vestingDuration Vesting duration
     */
    function getPoolData() external view returns(
        address _stakeToken,
        address _rewardToken,
        address _burnToken,
        uint256[] memory values
    ) {
        values = new uint256[](16);
        values[0] = startBlock;
        values[1] = rewardPerBlock;
        values[2] = maxDepositAmount;
        values[3] = lastRewardBlock;
        values[4] = stakeTotalShares;
        values[5] = rewardTotalShares;
        values[6] = stakeTotalShares * stakePPS();
        values[7] = stakePPS();
        values[8] = accTokenPerShare;
        values[9] = maxMultiplier;
        values[10] = minLockDuration;
        values[11] = maxLockDuration;
        values[12] = freeWithdrawalPeriod;
        values[13] = eliminationPeriodDuration;
        values[14] = burnAmountToUnlock;
        values[15] = vestingDuration;

        return (
            address(stakeToken),
            address(rewardToken),
            address(burnToken),
            values
        );
    }


    /*
     * @notice Unlocks pool for account
     * @param account Account address which needs to unlock this pool
     * @dev In order to allow staking to `account`, burns `burnAmountToUnlock` amount of ERC20 "burnTokens"
     * @dev Internal function
     */
    function _unlockPool(address account) private {
        hasUnlockedStaking[account] = true;
        burnToken.transferFrom(msg.sender, BURN_WALLET, burnAmountToUnlock);

        emit PoolUnlock(account);
    }


    /*
     * @notice Creates a deposit on behalf
     * @param amount Amount to deposit (in stakedToken)
     * @param lockDuration Number of blocks the deposit should be locked for
     * @param account Future owner of deposit
     * @dev Internal function
     */
    function _deposit(
        uint256 amount,
        uint256 lockDuration,
        address account
    ) internal nonReentrant {
        require(block.number >= startBlock, "Pool is not active");
        require(rewardPerBlock > 0, "Pool has ended");
        require(lockDuration >= minLockDuration, "Below minLockDuration");
        require(lockDuration <= maxLockDuration, "Over maxLockDuration");

        if (!hasUnlockedStaking[account] && burnAmountToUnlock > 0) {
            if (
                burnToken.balanceOf(msg.sender) >= burnAmountToUnlock
                && burnToken.allowance(msg.sender, address(this)) >= burnAmountToUnlock
            ) {
                _unlockPool(account);
            } else {
                revert UserLocked(account);
            }
        }

        _updatePool();
        uint256 PPS = stakePPS();

        uint256 depositedAmount = amount;
        if (stakeTreatToken) {
            _executeStaking(
                account,
                deposits[account].length,
                amount
            );
        } else {
            depositedAmount = _transferStakeAndCheck(amount);
        }
        require(depositedAmount >= PPS * 1000, "Below minimum amount");
        require(
            maxDepositAmount == 0
            || totalUserStaked[account] * PPS + depositedAmount <= maxDepositAmount,
            "Over max stake limit"
        );

        // calculate shares
        uint256 stakeShares = depositedAmount / PPS;
        uint256 rewardShares = stakeShares * _getRewardMultiplier(lockDuration) / 10_000;

        deposits[account].push(DepositInfo({
            active: true,
            unlockBlock: uint64(block.number + lockDuration),
            stakeShares: stakeShares,
            rewardShares: rewardShares,
            lastUpdateAccTokenPerShare: accTokenPerShare,
            pendingRewards: 0
        }));

        totalUserStaked[account] += stakeShares;
        stakeTotalShares += stakeShares;
        rewardTotalShares += rewardShares;

        emit NewDeposit(
            account,
            uint32(deposits[account].length - 1),
            uint32(block.number + lockDuration),
            depositedAmount,
            stakeShares,
            rewardShares
        );
    }


    /*
     * @notice Replenishes deposit with specific ID, that belongs to msg.sender
     * @param account Deposit owner address
     * @param depositId ID index of deposit
     * @param amount amount to add to deposit (in stakedToken)
     * @param additionalLockDuration Number of blocks to add to deposit duration
     * @dev Increasing deposit amount or/and lock duration will result in increasing rewardShares of deposit
     * @dev Increasing rewardShares of deposit will result in increasing APR for this deposit
     */
    function _replenishAndExtendDeposit(
        address account,
        uint256 depositId,
        uint256 additionalAmount,
        uint32 additionalLockDuration
    ) internal nonReentrant {
        require(block.number >= startBlock, "Pool is not active");
        require(additionalLockDuration > 0 || additionalAmount > 0, "Zero duration and amount");
        require(deposits[account].length > depositId, "Invalid deposit ID");
        DepositInfo storage userDeposit = deposits[account][depositId];
        require(userDeposit.active, "Deposit is not active");
        require(userDeposit.unlockBlock > block.number, "Deposit has ended");

        _updatePool();

        // store current pending rewards
        userDeposit.pendingRewards = userDeposit.pendingRewards + userDeposit.rewardShares
            * (accTokenPerShare - userDeposit.lastUpdateAccTokenPerShare) / PRECISION_FACTOR;
        userDeposit.lastUpdateAccTokenPerShare = accTokenPerShare;

        uint256 depositedAmount = additionalAmount;
        uint256 initialStakeShares = userDeposit.stakeShares;
        uint256 initialRewardShares = userDeposit.rewardShares;

        if (additionalLockDuration > 0) {
            // Extending duration for locked deposit should always be rewarded
            // So we recalculate reward shares in a way, like if
            uint256 currentDuration = userDeposit.unlockBlock - block.number;
            uint256 _maxLockDuration = maxLockDuration;
            require(currentDuration + additionalLockDuration >= minLockDuration, "Below minLockDuration");
            require(currentDuration + additionalLockDuration <= _maxLockDuration, "Over maxLockDuration");

            uint256 _maxMultiplier = maxMultiplier;
            uint256 extraMultiplier = uint256(additionalLockDuration) * (_maxMultiplier - 10_000) / _maxLockDuration;
            uint256 rewardSharesToAdd = extraMultiplier * userDeposit.stakeShares / 10_000;

            // check if rewardShares are over current limit
            uint256 maxRewardShares = userDeposit.stakeShares * _maxMultiplier / 10_000;
            if (userDeposit.rewardShares + rewardSharesToAdd > maxRewardShares) {
                rewardSharesToAdd = maxRewardShares - userDeposit.rewardShares;
            }

            userDeposit.rewardShares += rewardSharesToAdd;
            rewardTotalShares += rewardSharesToAdd;

            userDeposit.unlockBlock += additionalLockDuration;
        }

        if (additionalAmount > 0) {
            uint256 PPS = stakePPS();
            if (stakeTreatToken) {
                _executeStaking(
                    account,
                    depositId,
                    additionalAmount
                );
            } else {
                depositedAmount = _transferStakeAndCheck(additionalAmount);
            }
            require(depositedAmount > PPS, "Below minimum amount");
            require(
                maxDepositAmount == 0
                || totalUserStaked[account] * PPS + depositedAmount <= maxDepositAmount,
                "Over max stake limit"
            );
            uint256 lockDuration = userDeposit.unlockBlock - block.number;

            // calculate shares
            uint256 stakeSharesToAdd = depositedAmount / PPS;
            uint256 rewardSharesToAdd = stakeSharesToAdd * _getRewardMultiplier(lockDuration) / 10_000;

            totalUserStaked[account] += stakeSharesToAdd;
            userDeposit.stakeShares += stakeSharesToAdd;
            stakeTotalShares += stakeSharesToAdd;
            userDeposit.rewardShares += rewardSharesToAdd;
            rewardTotalShares += rewardSharesToAdd;
        }

        emit DepositUpdate (
            account,
            uint32(depositId),
            uint32(additionalLockDuration),
            uint32(userDeposit.unlockBlock),
            depositedAmount,
            userDeposit.stakeShares - initialStakeShares,
            userDeposit.rewardShares - initialRewardShares
        );
    }


    /*
     * @notice Closes outdated deposit
     * @param values Helper values
     *  values[0] = freeWithdrawalPeriod;
     *  values[1] = accTokenPerShare;
     *  values[2] = vestingDuration;
     *  values[3] = eliminationPeriodDuration;
     *  values[4] = stakePPS;
     * @param account Deposit owner
     * @param depositId Deposit index
     * @param index Index of deposit in depositPaths array. For correct reverts
     */
    function _closeDeposit(
        uint256[] memory values,
        address account,
        uint256 depositId,
        uint256 index
    ) private returns(uint256 rewardForDepositClosing) {
        if (deposits[account].length <= depositId) {
            revert InvalidPath(index, account, depositId);
        }
        DepositInfo memory userDeposit = deposits[account][depositId];
        if (!userDeposit.active) {
            revert NotActive(index, account, depositId);
        }

        deposits[account][depositId].active = false;
        if (userDeposit.unlockBlock + values[0] > block.number) {
            revert NotUnlocked(index, account, depositId);
        }

        uint256 stakeAmount = userDeposit.stakeShares * values[4];

        uint256 pendingRewards = userDeposit.pendingRewards + userDeposit.rewardShares
        * (values[1] - userDeposit.lastUpdateAccTokenPerShare) / PRECISION_FACTOR;

        totalUserStaked[account] -= userDeposit.stakeShares;
        stakeTotalShares -= userDeposit.stakeShares;
        rewardTotalShares -= userDeposit.rewardShares;

        uint256 eliminationPeriodStart = userDeposit.unlockBlock + values[0];
        rewardForDepositClosing = block.number > (eliminationPeriodStart + values[3])
        ? pendingRewards
        : pendingRewards * (block.number - eliminationPeriodStart) / values[3];

        _executeWithdrawal(
            account,
            depositId,
            stakeAmount,
            values[2]
        );

        unclaimedRewards[account] += (pendingRewards - rewardForDepositClosing);

        emit Withdrawal(
            account,
            false,
            uint32(depositId),
            stakeAmount,
            userDeposit.stakeShares,
            pendingRewards - rewardForDepositClosing
        );
    }


    /*
     * @notice Calculates Price Per Share for stake token
     * @return Price per share for stake token
     */
    function stakePPS() public view returns(uint256) {
        if (!stakeTreatToken && stakeTotalShares >= 1000) {
            return stakeToken.balanceOf(address(this)) / stakeTotalShares;
        }
        return defaultStakePPS;
    }

    /*
     * @notice Updates pool variables
     */
    function _updatePool() private {
        if (block.number <= lastRewardBlock) {
            return;
        }

        if (rewardTotalShares == 0 || rewardPerBlock == 0) {
            lastRewardBlock = uint32(block.number);
            return;
        }

        uint256 newRewards = (block.number - uint256(lastRewardBlock)) * uint256(rewardPerBlock);

        accTokenPerShare += newRewards * PRECISION_FACTOR / rewardTotalShares;
        lastRewardBlock = uint32(block.number);
    }


    /*
     * @notice Transfers stake tokens from msg.senders and calculates exact amount of deposited tokens
     * @param amount Amount of tokens to deposit
     * @param PPS Stake price per share
     * @return depositedAmount Amount of tokens there were deposited
     * @dev Check for tokens that have fee on transfer
     */
    function _transferStakeAndCheck(
        uint256 amount
    ) private returns(uint256 depositedAmount) {
        uint256 initialBalance = stakeToken.balanceOf(address(this));
        stakeToken.transferFrom(
            msg.sender,
            address(this),
            amount
        );
        depositedAmount = stakeToken.balanceOf(address(this)) - initialBalance;
    }


    /*
     * @notice Calculates reward multiplier. The bigger this multiplier, the more rewardShares user will get
     * @param duration deposit duration
     * @return Multiplier in basis points
     */
    function _getRewardMultiplier(
        uint256 duration
    ) private view returns (uint256) {
        return duration * (uint256(maxMultiplier) - 10_000) / maxLockDuration + 10_000;
    }


    /*
     * @notice Calculates updated accTokenPerShare value
     * @return newAccTokenPerShare Updated accTokenPerShare value
     * @dev Should be used ONLY for view functions
     */
    function _newAccTokenPerShare() private view returns (uint256 newAccTokenPerShare) {
        newAccTokenPerShare = accTokenPerShare;
        uint256 _lastRewardBlock = lastRewardBlock;
        uint256 _rewardPerBlock = rewardPerBlock;
        if (rewardTotalShares > 0 && _rewardPerBlock > 0 && block.number > _lastRewardBlock) {
            uint256 newRewards = (block.number - _lastRewardBlock) * _rewardPerBlock;
            newAccTokenPerShare += newRewards * PRECISION_FACTOR / rewardTotalShares;
        }
    }


    /*
     * @notice Executes proper Treat token staking. Updates vesting data
     * @param account Deposit owner
     * @param depositId Deposit id
     * @param stakeAmount Stake amount to withdraw
     */
    function _executeStaking(
        address account,
        uint256 depositId,
        uint256 stakeAmount
    ) private {
        (
            uint256 lockedAmount,
            uint256 remainingVestingProgress
        ) = ITreatToken(address(stakeToken)).executeStaking(account, stakeAmount);

        uint256 _vestingDuration = vestingDuration;

        VestingManager.vestingUpdate(
            tokenVesting[account][depositId],
            _vestingDuration
        );

        VestingManager.addVesting(
            tokenVesting[account][depositId],
            _vestingDuration,
            lockedAmount,
            remainingVestingProgress
        );
    }


    /*
     * @notice Executes proper withdrawal. If stake token is Treat token - manage vesting data
     * @param account Deposit owner
     * @param depositId Deposit id
     * @param stakeAmount Stake amount to withdraw
     * @param _vestingDuration Vesting duration for the deposit
     */
    function _executeWithdrawal(
        address account,
        uint256 depositId,
        uint256 stakeAmount,
        uint256 _vestingDuration
    ) private {
        if (stakeTreatToken) {
            (uint256 locked, uint256 remainingVestingTime) = VestingManager.vestingUpdate(
                tokenVesting[account][depositId],
                _vestingDuration
            );

            tokenVesting[account][depositId].lockedAmount = 0;

            ITreatToken(address(stakeToken)).executeWithdrawal(
                account,
                stakeAmount,
                locked,
                remainingVestingTime * 1e9 / _vestingDuration
            );
        } else {
            stakeToken.transfer(account, stakeAmount);
        }
    }

    // SETTERS

    /*
     * @notice Sets pool values
     * @param _rewardPerBlock Amount of rewards per block for the pool
     * @param _maxDepositAmount Maximum amount of stake tokens user is allowed to deposit. 0 for no limitations
     * @param _startBlock Start block. Deposits are not allowed before this block
       Setting start block in far future will allow to forbid depositing while keeping rewards distribution
     * @param _maxMultiplier Maximum reward multiplier
     * @param _minLockDuration Minimum lock duration. Locking deposits for shorter duration will be forbidden
     * @param _maxLockDuration Maximum lock duration. Locking deposits for longer duration will be forbidden
     * @param _freeWithdrawalPeriod Free withdrawal period
       After the end of deposit lock time only deposit owner is allowed to withdraw this deposit during this period
       After the end of this period anyone can close this deposit and get share of pending rewards
     * @param _eliminationPeriodDuration Elimination period
       Time after {freeWithdrawalPeriod} has passed, while which rewards for closing it are growing
       At the start of this period the one, who closes unlocked (finished) deposit will get ~0% of collected rewards
       By the end of this period rewards for closing deposit will become 100% of collected rewards
     * @param _vestingDuration Time during which Treat token is fully vested
     * @param _burnAmountToUnlock Amount of tokens, that must be burned to unlock this pool for user
     * @dev Only Owner
     */
    function setPoolValues(
        uint128 _rewardPerBlock,
        uint128 _maxDepositAmount,
        uint32 _startBlock,
        uint32 _maxMultiplier,
        uint32 _minLockDuration,
        uint32 _maxLockDuration,
        uint32 _freeWithdrawalPeriod,
        uint32 _eliminationPeriodDuration,
        uint32 _vestingDuration,
        uint256 _burnAmountToUnlock
    ) external onlyOwner {
        require(_minLockDuration < _maxLockDuration, "Invalid maxLockDuration");

        if (rewardPerBlock != _rewardPerBlock) {
            setRewardPerBlock(_rewardPerBlock);
        }

        if (maxDepositAmount != _maxDepositAmount) {
            setMaxDepositAmount(_maxDepositAmount);
        }

        if (startBlock != _startBlock) {
            setStartBlock(_startBlock);
        }

        if (maxMultiplier != _maxMultiplier) {
            setMaxMultiplier(_maxMultiplier);
        }

        if (minLockDuration != _minLockDuration) {
            setMinLockDuration(_minLockDuration);
        }

        if (maxLockDuration != _maxLockDuration) {
            setMaxLockDuration(_maxLockDuration);
        }

        if (freeWithdrawalPeriod != _freeWithdrawalPeriod) {
            setFreeWithdrawalPeriod(_freeWithdrawalPeriod);
        }

        if (eliminationPeriodDuration != _eliminationPeriodDuration) {
            setEliminationPeriodDuration(_eliminationPeriodDuration);
        }

        if (burnAmountToUnlock != _burnAmountToUnlock) {
            setBurnAmountToUnlock(_burnAmountToUnlock);
        }

        if (vestingDuration != _vestingDuration) {
            setVestingDuration(_vestingDuration);
        }
    }


    /*
     * @notice Sets amount of rewards per block for the pool
     * @param _rewardPerBlock Amount of rewards per block for the pool
     * @dev Only Owner
     */
    function setRewardPerBlock(uint128 _rewardPerBlock) public onlyOwner {
        require(rewardPerBlock != _rewardPerBlock, "Already set");
        _updatePool();
        rewardPerBlock = _rewardPerBlock;
        emit NewRewardPerBlock(_rewardPerBlock);
    }


    /*
     * @notice Sets maximum amount of stake tokens user is allowed to deposit
     * @param _maxDepositAmount Maximum amount of stake tokens user is allowed to deposit. 0 for no limitations
     * @dev Only Owner
     */
    function setMaxDepositAmount(uint128 _maxDepositAmount) public onlyOwner {
        require(maxDepositAmount != _maxDepositAmount, "Already set");
        maxDepositAmount = _maxDepositAmount;
        emit NewMaxDepositAmount(_maxDepositAmount);
    }


    /*
     * @notice Sets amount of tokens, that must be burned to unlock this pool for user
     * @param _burnAmountToUnlock Amount of tokens, that must be burned to unlock this pool for user
     * @dev Only Owner
     */
    function setBurnAmountToUnlock(uint256 _burnAmountToUnlock) public onlyOwner {
        require(burnAmountToUnlock != _burnAmountToUnlock, "Already set");
        burnAmountToUnlock = _burnAmountToUnlock;
        emit NewBurnAmountToUnlock(_burnAmountToUnlock);
    }


    /*
     * @notice Sets pool start block. Deposits are not allowed before this block
       Setting start block in far future will allow to forbid depositing while keeping rewards distribution
     * @param _startBlock Start block
     * @dev Only Owner
     */
    function setStartBlock(uint32 _startBlock) public onlyOwner {
        require(startBlock != _startBlock, "Already set");
        startBlock = _startBlock;
        emit NewStartBlock(_startBlock);
    }


    /*
     * @notice Sets maximum reward multiplier for staking for a long period
     * @param _maxMultiplier Maximum reward multiplier
     * @dev Only Owner
     */
    function setMaxMultiplier(uint32 _maxMultiplier) public onlyOwner {
        require(maxMultiplier != _maxMultiplier, "Already set");
        require(maxMultiplier >= 10_000, "maxMultiplier < 10000");
        maxMultiplier = _maxMultiplier;
        emit NewMaxMultiplier(_maxMultiplier);
    }


    /*
     * @notice Sets minimum lock duration. Locking deposits for shorter duration will be forbidden
     * @param _minLockDuration Minimum lock duration
     * @dev Only Owner
     */
    function setMinLockDuration(uint32 _minLockDuration) public onlyOwner {
        require(minLockDuration != _minLockDuration, "Already set");
        require(_minLockDuration < maxLockDuration, "Over maxLockDuration");
        minLockDuration = _minLockDuration;
        emit NewMinLockDuration(_minLockDuration);
    }


    /*
     * @notice Sets maximum lock duration. Locking deposits for longer duration will be forbidden
     * @param _maxLockDuration Maximum lock duration
     * @dev Only Owner
     */
    function setMaxLockDuration(uint32 _maxLockDuration) public onlyOwner {
        require(maxLockDuration != _maxLockDuration, "Already set");
        require(_maxLockDuration >= 1200 * 24 * 7, "maxLockDuration < 1 week");
        require(_maxLockDuration > minLockDuration, "Below minLockDuration");
        maxLockDuration = _maxLockDuration;
        emit NewMaxLockDuration(_maxLockDuration);
    }


    /*
     * @notice Sets free withdrawal period.
       After the end of deposit lock time only deposit owner is allowed to withdraw this deposit during this period
       After the end of this period anyone can close this deposit and get share of pending rewards
     * @param _freeWithdrawalPeriod Free withdrawal period
     * @dev Only Owner
     */
    function setFreeWithdrawalPeriod(uint32 _freeWithdrawalPeriod) public onlyOwner {
        require(freeWithdrawalPeriod != _freeWithdrawalPeriod, "Already set");
//        require(_freeWithdrawalPeriod >= 1200 * 24 * 7, "freeWithdrawalPeriod < 1 week");
        freeWithdrawalPeriod = _freeWithdrawalPeriod;
        emit NewFreeWithdrawalPeriod(_freeWithdrawalPeriod);
    }


    /*
     * @notice Sets elimination period.
       Time after {freeWithdrawalPeriod} has passed, while which rewards for closing it are growing
       At the start of this period the one, who closes unlocked (finished) deposit will get ~0% of collected rewards
       By the end of this period rewards for closing deposit will become 100% of collected rewards
     * @param _eliminationPeriodDuration Elimination period
     * @dev Only Owner
     */
    function setEliminationPeriodDuration(uint32 _eliminationPeriodDuration) public onlyOwner {
        require(eliminationPeriodDuration != _eliminationPeriodDuration, "Already set");
        eliminationPeriodDuration = _eliminationPeriodDuration;
        emit NewEliminationPeriodDuration(_eliminationPeriodDuration);
    }


    /*
     * @notice Sets vesting duration for Treat Token.
     * @param _vestingDuration Time during which Treat token is fully vested
     * @dev Only Owner
     */
    function setVestingDuration(uint32 _vestingDuration) public onlyOwner {
        require(vestingDuration != _vestingDuration, "Already set");
        require(_vestingDuration != 0, "Invalid vesting duration");
        vestingDuration = _vestingDuration;
        emit NewVestingDuration(_vestingDuration);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership} and {updateOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract SafeOwnable is Context {
    address private _owner;
    address private _newOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event OwnershipUpdated(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _owner = _msgSender();
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
        _owner = address(0);
    }

    /**
     * @dev Allows newOwner to claim ownership
     * @param newOwner Address that should become a new owner
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to msg.sender
     */
    function updateOwnership() external {
        _updateOwnership();
    }

    /**
     * @dev Allows newOwner to claim ownership
     * @param newOwner Address that should become a new owner
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _newOwner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to msg.sender
     * Internal function without access restriction.
     */
    function _updateOwnership() private {
        address oldOwner = _owner;
        address newOwner = _newOwner;
        require(msg.sender == newOwner, "Not a new owner");
        require(oldOwner != newOwner, "Already updated");
        _owner = newOwner;
        emit OwnershipUpdated(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeCast.sol";

// @title Library for managing vesting storage data.
// Must be used by staking smart contracts with Treat Token as deposit token
library VestingManager {
    struct VestingData {
        uint40 vestingEndTime;  // end of vesting timestamp
        uint40 lastUpdateTime;  // last vesting update timestamp
        uint176 lockedAmount;   // amount of tokens being vested
    }

    /*
     * @notice Updates vesting data: end of vesting, amount of tokens has not been vested yet
     * @param vestingStorage Vesting data storage
     * @param vestingDuration Vesting duration for this vesting data
     * @return locked Amount of locked tokens
     * @return remainingVestingTime Remaining vesting duration
     */
    function vestingUpdate(
        VestingData storage vestingStorage,
        uint256 vestingDuration
    ) internal returns (uint256 locked, uint256 remainingVestingTime){
        VestingData memory vestingMemory = vestingStorage;
        (locked, remainingVestingTime) = getLockedAndRemaining(
            vestingMemory,
            vestingDuration
        );

        // update if needed
        if (vestingMemory.lastUpdateTime != uint40(block.timestamp)) {
            vestingStorage.lastUpdateTime = uint40(block.timestamp);
        }
        if (
            remainingVestingTime != 0
            && vestingMemory.vestingEndTime != SafeCast.toUint40(block.timestamp + remainingVestingTime)
        ) {
            vestingStorage.vestingEndTime = SafeCast.toUint40(block.timestamp + remainingVestingTime);
        }
        if (vestingMemory.lockedAmount != locked) {
            vestingStorage.lockedAmount = SafeCast.toUint176(locked);
        }
    }


    /*
     * @notice Adds new unvested tokens to vesting storage. Calculates remaining vesting time as weighted average.
     * @param vestingStorage Vesting data storage
     * @param vestingDuration Vesting duration for this vesting data
     * @param lockedAmount Amount of locked tokens to be added
     * @param remainingVestingProgress Remaining percentage of vesting duration for arriving tokens, where 1e9 == 100%
     * If tokens are fully unvested `remainingVestingProgress` = 1e9
     * If tokens are half vested `remainingVestingProgress` = 0.5 * 1e9
     * Should be calculated as {remainingVestingTime * 1e9 / vestingDuration}
     * @return locked Amount of locked tokens
     * @return remainingVestingTime Remaining vesting duration
     * @dev Must be used after vestingUpdate()
     */
    function addVesting(
        VestingData storage vestingStorage,
        uint256 vestingDuration,
        uint256 lockedAmount,
        uint256 remainingVestingProgress
    ) internal returns (uint256 locked, uint256 remainingVestingTime) {
        // gas savings
        VestingData memory vestingMemory = vestingStorage;
        require(vestingMemory.lastUpdateTime == uint40(block.timestamp), "vestingUpdate first");
        // calculate remaining time with weighted average
        uint256 storageRemainingTime = block.timestamp < vestingMemory.vestingEndTime
            ? vestingMemory.vestingEndTime - block.timestamp
            : 0;
        if(lockedAmount == 0) {
            return (vestingMemory.lockedAmount, storageRemainingTime);
        }
        uint256 remainingAddedDuration = vestingDuration * remainingVestingProgress / 1e9;
        remainingVestingTime = (lockedAmount * remainingAddedDuration + vestingMemory.lockedAmount * storageRemainingTime)
            / (lockedAmount + vestingMemory.lockedAmount);
        locked = vestingMemory.lockedAmount + lockedAmount;

        // update vesting data
        vestingStorage.vestingEndTime = SafeCast.toUint40(block.timestamp + remainingVestingTime);
        vestingStorage.lockedAmount = SafeCast.toUint176(locked);
    }


    /*
     * @notice Calculates vesting data: end of vesting, amount of tokens has not been vested yet
     * @param vestingData Vesting data
     * @param vestingDuration Vesting duration for this vesting data
     * @return locked Amount of locked tokens
     * @return remainingVestingTime Remaining vesting duration
     */
    function getLockedAndRemaining(
        VestingData memory vestingData,
        uint256 vestingDuration
    ) internal view returns (uint256 locked, uint256 remainingVestingTime) {
        remainingVestingTime = 0;
        locked = 0;

        if (vestingData.lockedAmount == 0) {
            return (0,0);
        } else {
            uint256 maxEndTime = vestingData.lastUpdateTime + vestingDuration;
            if (vestingData.vestingEndTime > maxEndTime) {
                vestingData.vestingEndTime = SafeCast.toUint40(maxEndTime);
            }

            // If vesting time is over
            if (vestingData.vestingEndTime <= block.timestamp) {
                return (0,0);
            }

            remainingVestingTime = vestingData.vestingEndTime - block.timestamp;
            uint256 sinceLastUpdate = block.timestamp - vestingData.lastUpdateTime;
            locked = vestingData.lockedAmount * remainingVestingTime / (sinceLastUpdate + remainingVestingTime);
        }
    }
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IRewardMinter {
    function mint(address to, uint256 amount) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ITreatToken is IERC20, IERC20Metadata {
    function getPastVotes(address account, uint256 blockNumber)
        external
        view
        returns (uint256);

    function executeStaking(
        address account,
        uint256 transferAmount
    ) external returns (
        uint256 lockedAmount,
        uint256 remainingVestingProgress
    );

    function executeWithdrawal(
        address account,
        uint256 transferAmount,
        uint256 lockedAmount,
        uint256 remainingVestingProgress
    ) external;

    function viewNotVestedTokens(address recipient) external view
        returns(uint256 locked, uint256 remainingVestingTime);

    function isExchangeAddress(address pair) external view returns(bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/math/SafeCast.sol)

pragma solidity ^0.8.0;

/**
 * @dev Wrappers over Solidity's uintXX/intXX casting operators with added overflow
 * checks.
 *
 * Downcasting from uint256/int256 in Solidity does not revert on overflow. This can
 * easily result in undesired exploitation or bugs, since developers usually
 * assume that overflows raise errors. `SafeCast` restores this intuition by
 * reverting the transaction when such an operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 *
 * Can be combined with {SafeMath} and {SignedSafeMath} to extend it to smaller types, by performing
 * all math on `uint256` and `int256` and then downcasting.
 */
library SafeCast {
    /**
     * @dev Returns the downcasted uint248 from uint256, reverting on
     * overflow (when the input is greater than largest uint248).
     *
     * Counterpart to Solidity's `uint248` operator.
     *
     * Requirements:
     *
     * - input must fit into 248 bits
     *
     * _Available since v4.7._
     */
    function toUint248(uint256 value) internal pure returns (uint248) {
        require(value <= type(uint248).max, "SafeCast: value doesn't fit in 248 bits");
        return uint248(value);
    }

    /**
     * @dev Returns the downcasted uint240 from uint256, reverting on
     * overflow (when the input is greater than largest uint240).
     *
     * Counterpart to Solidity's `uint240` operator.
     *
     * Requirements:
     *
     * - input must fit into 240 bits
     *
     * _Available since v4.7._
     */
    function toUint240(uint256 value) internal pure returns (uint240) {
        require(value <= type(uint240).max, "SafeCast: value doesn't fit in 240 bits");
        return uint240(value);
    }

    /**
     * @dev Returns the downcasted uint232 from uint256, reverting on
     * overflow (when the input is greater than largest uint232).
     *
     * Counterpart to Solidity's `uint232` operator.
     *
     * Requirements:
     *
     * - input must fit into 232 bits
     *
     * _Available since v4.7._
     */
    function toUint232(uint256 value) internal pure returns (uint232) {
        require(value <= type(uint232).max, "SafeCast: value doesn't fit in 232 bits");
        return uint232(value);
    }

    /**
     * @dev Returns the downcasted uint224 from uint256, reverting on
     * overflow (when the input is greater than largest uint224).
     *
     * Counterpart to Solidity's `uint224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     *
     * _Available since v4.2._
     */
    function toUint224(uint256 value) internal pure returns (uint224) {
        require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
        return uint224(value);
    }

    /**
     * @dev Returns the downcasted uint216 from uint256, reverting on
     * overflow (when the input is greater than largest uint216).
     *
     * Counterpart to Solidity's `uint216` operator.
     *
     * Requirements:
     *
     * - input must fit into 216 bits
     *
     * _Available since v4.7._
     */
    function toUint216(uint256 value) internal pure returns (uint216) {
        require(value <= type(uint216).max, "SafeCast: value doesn't fit in 216 bits");
        return uint216(value);
    }

    /**
     * @dev Returns the downcasted uint208 from uint256, reverting on
     * overflow (when the input is greater than largest uint208).
     *
     * Counterpart to Solidity's `uint208` operator.
     *
     * Requirements:
     *
     * - input must fit into 208 bits
     *
     * _Available since v4.7._
     */
    function toUint208(uint256 value) internal pure returns (uint208) {
        require(value <= type(uint208).max, "SafeCast: value doesn't fit in 208 bits");
        return uint208(value);
    }

    /**
     * @dev Returns the downcasted uint200 from uint256, reverting on
     * overflow (when the input is greater than largest uint200).
     *
     * Counterpart to Solidity's `uint200` operator.
     *
     * Requirements:
     *
     * - input must fit into 200 bits
     *
     * _Available since v4.7._
     */
    function toUint200(uint256 value) internal pure returns (uint200) {
        require(value <= type(uint200).max, "SafeCast: value doesn't fit in 200 bits");
        return uint200(value);
    }

    /**
     * @dev Returns the downcasted uint192 from uint256, reverting on
     * overflow (when the input is greater than largest uint192).
     *
     * Counterpart to Solidity's `uint192` operator.
     *
     * Requirements:
     *
     * - input must fit into 192 bits
     *
     * _Available since v4.7._
     */
    function toUint192(uint256 value) internal pure returns (uint192) {
        require(value <= type(uint192).max, "SafeCast: value doesn't fit in 192 bits");
        return uint192(value);
    }

    /**
     * @dev Returns the downcasted uint184 from uint256, reverting on
     * overflow (when the input is greater than largest uint184).
     *
     * Counterpart to Solidity's `uint184` operator.
     *
     * Requirements:
     *
     * - input must fit into 184 bits
     *
     * _Available since v4.7._
     */
    function toUint184(uint256 value) internal pure returns (uint184) {
        require(value <= type(uint184).max, "SafeCast: value doesn't fit in 184 bits");
        return uint184(value);
    }

    /**
     * @dev Returns the downcasted uint176 from uint256, reverting on
     * overflow (when the input is greater than largest uint176).
     *
     * Counterpart to Solidity's `uint176` operator.
     *
     * Requirements:
     *
     * - input must fit into 176 bits
     *
     * _Available since v4.7._
     */
    function toUint176(uint256 value) internal pure returns (uint176) {
        require(value <= type(uint176).max, "SafeCast: value doesn't fit in 176 bits");
        return uint176(value);
    }

    /**
     * @dev Returns the downcasted uint168 from uint256, reverting on
     * overflow (when the input is greater than largest uint168).
     *
     * Counterpart to Solidity's `uint168` operator.
     *
     * Requirements:
     *
     * - input must fit into 168 bits
     *
     * _Available since v4.7._
     */
    function toUint168(uint256 value) internal pure returns (uint168) {
        require(value <= type(uint168).max, "SafeCast: value doesn't fit in 168 bits");
        return uint168(value);
    }

    /**
     * @dev Returns the downcasted uint160 from uint256, reverting on
     * overflow (when the input is greater than largest uint160).
     *
     * Counterpart to Solidity's `uint160` operator.
     *
     * Requirements:
     *
     * - input must fit into 160 bits
     *
     * _Available since v4.7._
     */
    function toUint160(uint256 value) internal pure returns (uint160) {
        require(value <= type(uint160).max, "SafeCast: value doesn't fit in 160 bits");
        return uint160(value);
    }

    /**
     * @dev Returns the downcasted uint152 from uint256, reverting on
     * overflow (when the input is greater than largest uint152).
     *
     * Counterpart to Solidity's `uint152` operator.
     *
     * Requirements:
     *
     * - input must fit into 152 bits
     *
     * _Available since v4.7._
     */
    function toUint152(uint256 value) internal pure returns (uint152) {
        require(value <= type(uint152).max, "SafeCast: value doesn't fit in 152 bits");
        return uint152(value);
    }

    /**
     * @dev Returns the downcasted uint144 from uint256, reverting on
     * overflow (when the input is greater than largest uint144).
     *
     * Counterpart to Solidity's `uint144` operator.
     *
     * Requirements:
     *
     * - input must fit into 144 bits
     *
     * _Available since v4.7._
     */
    function toUint144(uint256 value) internal pure returns (uint144) {
        require(value <= type(uint144).max, "SafeCast: value doesn't fit in 144 bits");
        return uint144(value);
    }

    /**
     * @dev Returns the downcasted uint136 from uint256, reverting on
     * overflow (when the input is greater than largest uint136).
     *
     * Counterpart to Solidity's `uint136` operator.
     *
     * Requirements:
     *
     * - input must fit into 136 bits
     *
     * _Available since v4.7._
     */
    function toUint136(uint256 value) internal pure returns (uint136) {
        require(value <= type(uint136).max, "SafeCast: value doesn't fit in 136 bits");
        return uint136(value);
    }

    /**
     * @dev Returns the downcasted uint128 from uint256, reverting on
     * overflow (when the input is greater than largest uint128).
     *
     * Counterpart to Solidity's `uint128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     *
     * _Available since v2.5._
     */
    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");
        return uint128(value);
    }

    /**
     * @dev Returns the downcasted uint120 from uint256, reverting on
     * overflow (when the input is greater than largest uint120).
     *
     * Counterpart to Solidity's `uint120` operator.
     *
     * Requirements:
     *
     * - input must fit into 120 bits
     *
     * _Available since v4.7._
     */
    function toUint120(uint256 value) internal pure returns (uint120) {
        require(value <= type(uint120).max, "SafeCast: value doesn't fit in 120 bits");
        return uint120(value);
    }

    /**
     * @dev Returns the downcasted uint112 from uint256, reverting on
     * overflow (when the input is greater than largest uint112).
     *
     * Counterpart to Solidity's `uint112` operator.
     *
     * Requirements:
     *
     * - input must fit into 112 bits
     *
     * _Available since v4.7._
     */
    function toUint112(uint256 value) internal pure returns (uint112) {
        require(value <= type(uint112).max, "SafeCast: value doesn't fit in 112 bits");
        return uint112(value);
    }

    /**
     * @dev Returns the downcasted uint104 from uint256, reverting on
     * overflow (when the input is greater than largest uint104).
     *
     * Counterpart to Solidity's `uint104` operator.
     *
     * Requirements:
     *
     * - input must fit into 104 bits
     *
     * _Available since v4.7._
     */
    function toUint104(uint256 value) internal pure returns (uint104) {
        require(value <= type(uint104).max, "SafeCast: value doesn't fit in 104 bits");
        return uint104(value);
    }

    /**
     * @dev Returns the downcasted uint96 from uint256, reverting on
     * overflow (when the input is greater than largest uint96).
     *
     * Counterpart to Solidity's `uint96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     *
     * _Available since v4.2._
     */
    function toUint96(uint256 value) internal pure returns (uint96) {
        require(value <= type(uint96).max, "SafeCast: value doesn't fit in 96 bits");
        return uint96(value);
    }

    /**
     * @dev Returns the downcasted uint88 from uint256, reverting on
     * overflow (when the input is greater than largest uint88).
     *
     * Counterpart to Solidity's `uint88` operator.
     *
     * Requirements:
     *
     * - input must fit into 88 bits
     *
     * _Available since v4.7._
     */
    function toUint88(uint256 value) internal pure returns (uint88) {
        require(value <= type(uint88).max, "SafeCast: value doesn't fit in 88 bits");
        return uint88(value);
    }

    /**
     * @dev Returns the downcasted uint80 from uint256, reverting on
     * overflow (when the input is greater than largest uint80).
     *
     * Counterpart to Solidity's `uint80` operator.
     *
     * Requirements:
     *
     * - input must fit into 80 bits
     *
     * _Available since v4.7._
     */
    function toUint80(uint256 value) internal pure returns (uint80) {
        require(value <= type(uint80).max, "SafeCast: value doesn't fit in 80 bits");
        return uint80(value);
    }

    /**
     * @dev Returns the downcasted uint72 from uint256, reverting on
     * overflow (when the input is greater than largest uint72).
     *
     * Counterpart to Solidity's `uint72` operator.
     *
     * Requirements:
     *
     * - input must fit into 72 bits
     *
     * _Available since v4.7._
     */
    function toUint72(uint256 value) internal pure returns (uint72) {
        require(value <= type(uint72).max, "SafeCast: value doesn't fit in 72 bits");
        return uint72(value);
    }

    /**
     * @dev Returns the downcasted uint64 from uint256, reverting on
     * overflow (when the input is greater than largest uint64).
     *
     * Counterpart to Solidity's `uint64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     *
     * _Available since v2.5._
     */
    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
        return uint64(value);
    }

    /**
     * @dev Returns the downcasted uint56 from uint256, reverting on
     * overflow (when the input is greater than largest uint56).
     *
     * Counterpart to Solidity's `uint56` operator.
     *
     * Requirements:
     *
     * - input must fit into 56 bits
     *
     * _Available since v4.7._
     */
    function toUint56(uint256 value) internal pure returns (uint56) {
        require(value <= type(uint56).max, "SafeCast: value doesn't fit in 56 bits");
        return uint56(value);
    }

    /**
     * @dev Returns the downcasted uint48 from uint256, reverting on
     * overflow (when the input is greater than largest uint48).
     *
     * Counterpart to Solidity's `uint48` operator.
     *
     * Requirements:
     *
     * - input must fit into 48 bits
     *
     * _Available since v4.7._
     */
    function toUint48(uint256 value) internal pure returns (uint48) {
        require(value <= type(uint48).max, "SafeCast: value doesn't fit in 48 bits");
        return uint48(value);
    }

    /**
     * @dev Returns the downcasted uint40 from uint256, reverting on
     * overflow (when the input is greater than largest uint40).
     *
     * Counterpart to Solidity's `uint40` operator.
     *
     * Requirements:
     *
     * - input must fit into 40 bits
     *
     * _Available since v4.7._
     */
    function toUint40(uint256 value) internal pure returns (uint40) {
        require(value <= type(uint40).max, "SafeCast: value doesn't fit in 40 bits");
        return uint40(value);
    }

    /**
     * @dev Returns the downcasted uint32 from uint256, reverting on
     * overflow (when the input is greater than largest uint32).
     *
     * Counterpart to Solidity's `uint32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     *
     * _Available since v2.5._
     */
    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");
        return uint32(value);
    }

    /**
     * @dev Returns the downcasted uint24 from uint256, reverting on
     * overflow (when the input is greater than largest uint24).
     *
     * Counterpart to Solidity's `uint24` operator.
     *
     * Requirements:
     *
     * - input must fit into 24 bits
     *
     * _Available since v4.7._
     */
    function toUint24(uint256 value) internal pure returns (uint24) {
        require(value <= type(uint24).max, "SafeCast: value doesn't fit in 24 bits");
        return uint24(value);
    }

    /**
     * @dev Returns the downcasted uint16 from uint256, reverting on
     * overflow (when the input is greater than largest uint16).
     *
     * Counterpart to Solidity's `uint16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     *
     * _Available since v2.5._
     */
    function toUint16(uint256 value) internal pure returns (uint16) {
        require(value <= type(uint16).max, "SafeCast: value doesn't fit in 16 bits");
        return uint16(value);
    }

    /**
     * @dev Returns the downcasted uint8 from uint256, reverting on
     * overflow (when the input is greater than largest uint8).
     *
     * Counterpart to Solidity's `uint8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits
     *
     * _Available since v2.5._
     */
    function toUint8(uint256 value) internal pure returns (uint8) {
        require(value <= type(uint8).max, "SafeCast: value doesn't fit in 8 bits");
        return uint8(value);
    }

    /**
     * @dev Converts a signed int256 into an unsigned uint256.
     *
     * Requirements:
     *
     * - input must be greater than or equal to 0.
     *
     * _Available since v3.0._
     */
    function toUint256(int256 value) internal pure returns (uint256) {
        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    /**
     * @dev Returns the downcasted int248 from int256, reverting on
     * overflow (when the input is less than smallest int248 or
     * greater than largest int248).
     *
     * Counterpart to Solidity's `int248` operator.
     *
     * Requirements:
     *
     * - input must fit into 248 bits
     *
     * _Available since v4.7._
     */
    function toInt248(int256 value) internal pure returns (int248) {
        require(value >= type(int248).min && value <= type(int248).max, "SafeCast: value doesn't fit in 248 bits");
        return int248(value);
    }

    /**
     * @dev Returns the downcasted int240 from int256, reverting on
     * overflow (when the input is less than smallest int240 or
     * greater than largest int240).
     *
     * Counterpart to Solidity's `int240` operator.
     *
     * Requirements:
     *
     * - input must fit into 240 bits
     *
     * _Available since v4.7._
     */
    function toInt240(int256 value) internal pure returns (int240) {
        require(value >= type(int240).min && value <= type(int240).max, "SafeCast: value doesn't fit in 240 bits");
        return int240(value);
    }

    /**
     * @dev Returns the downcasted int232 from int256, reverting on
     * overflow (when the input is less than smallest int232 or
     * greater than largest int232).
     *
     * Counterpart to Solidity's `int232` operator.
     *
     * Requirements:
     *
     * - input must fit into 232 bits
     *
     * _Available since v4.7._
     */
    function toInt232(int256 value) internal pure returns (int232) {
        require(value >= type(int232).min && value <= type(int232).max, "SafeCast: value doesn't fit in 232 bits");
        return int232(value);
    }

    /**
     * @dev Returns the downcasted int224 from int256, reverting on
     * overflow (when the input is less than smallest int224 or
     * greater than largest int224).
     *
     * Counterpart to Solidity's `int224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     *
     * _Available since v4.7._
     */
    function toInt224(int256 value) internal pure returns (int224) {
        require(value >= type(int224).min && value <= type(int224).max, "SafeCast: value doesn't fit in 224 bits");
        return int224(value);
    }

    /**
     * @dev Returns the downcasted int216 from int256, reverting on
     * overflow (when the input is less than smallest int216 or
     * greater than largest int216).
     *
     * Counterpart to Solidity's `int216` operator.
     *
     * Requirements:
     *
     * - input must fit into 216 bits
     *
     * _Available since v4.7._
     */
    function toInt216(int256 value) internal pure returns (int216) {
        require(value >= type(int216).min && value <= type(int216).max, "SafeCast: value doesn't fit in 216 bits");
        return int216(value);
    }

    /**
     * @dev Returns the downcasted int208 from int256, reverting on
     * overflow (when the input is less than smallest int208 or
     * greater than largest int208).
     *
     * Counterpart to Solidity's `int208` operator.
     *
     * Requirements:
     *
     * - input must fit into 208 bits
     *
     * _Available since v4.7._
     */
    function toInt208(int256 value) internal pure returns (int208) {
        require(value >= type(int208).min && value <= type(int208).max, "SafeCast: value doesn't fit in 208 bits");
        return int208(value);
    }

    /**
     * @dev Returns the downcasted int200 from int256, reverting on
     * overflow (when the input is less than smallest int200 or
     * greater than largest int200).
     *
     * Counterpart to Solidity's `int200` operator.
     *
     * Requirements:
     *
     * - input must fit into 200 bits
     *
     * _Available since v4.7._
     */
    function toInt200(int256 value) internal pure returns (int200) {
        require(value >= type(int200).min && value <= type(int200).max, "SafeCast: value doesn't fit in 200 bits");
        return int200(value);
    }

    /**
     * @dev Returns the downcasted int192 from int256, reverting on
     * overflow (when the input is less than smallest int192 or
     * greater than largest int192).
     *
     * Counterpart to Solidity's `int192` operator.
     *
     * Requirements:
     *
     * - input must fit into 192 bits
     *
     * _Available since v4.7._
     */
    function toInt192(int256 value) internal pure returns (int192) {
        require(value >= type(int192).min && value <= type(int192).max, "SafeCast: value doesn't fit in 192 bits");
        return int192(value);
    }

    /**
     * @dev Returns the downcasted int184 from int256, reverting on
     * overflow (when the input is less than smallest int184 or
     * greater than largest int184).
     *
     * Counterpart to Solidity's `int184` operator.
     *
     * Requirements:
     *
     * - input must fit into 184 bits
     *
     * _Available since v4.7._
     */
    function toInt184(int256 value) internal pure returns (int184) {
        require(value >= type(int184).min && value <= type(int184).max, "SafeCast: value doesn't fit in 184 bits");
        return int184(value);
    }

    /**
     * @dev Returns the downcasted int176 from int256, reverting on
     * overflow (when the input is less than smallest int176 or
     * greater than largest int176).
     *
     * Counterpart to Solidity's `int176` operator.
     *
     * Requirements:
     *
     * - input must fit into 176 bits
     *
     * _Available since v4.7._
     */
    function toInt176(int256 value) internal pure returns (int176) {
        require(value >= type(int176).min && value <= type(int176).max, "SafeCast: value doesn't fit in 176 bits");
        return int176(value);
    }

    /**
     * @dev Returns the downcasted int168 from int256, reverting on
     * overflow (when the input is less than smallest int168 or
     * greater than largest int168).
     *
     * Counterpart to Solidity's `int168` operator.
     *
     * Requirements:
     *
     * - input must fit into 168 bits
     *
     * _Available since v4.7._
     */
    function toInt168(int256 value) internal pure returns (int168) {
        require(value >= type(int168).min && value <= type(int168).max, "SafeCast: value doesn't fit in 168 bits");
        return int168(value);
    }

    /**
     * @dev Returns the downcasted int160 from int256, reverting on
     * overflow (when the input is less than smallest int160 or
     * greater than largest int160).
     *
     * Counterpart to Solidity's `int160` operator.
     *
     * Requirements:
     *
     * - input must fit into 160 bits
     *
     * _Available since v4.7._
     */
    function toInt160(int256 value) internal pure returns (int160) {
        require(value >= type(int160).min && value <= type(int160).max, "SafeCast: value doesn't fit in 160 bits");
        return int160(value);
    }

    /**
     * @dev Returns the downcasted int152 from int256, reverting on
     * overflow (when the input is less than smallest int152 or
     * greater than largest int152).
     *
     * Counterpart to Solidity's `int152` operator.
     *
     * Requirements:
     *
     * - input must fit into 152 bits
     *
     * _Available since v4.7._
     */
    function toInt152(int256 value) internal pure returns (int152) {
        require(value >= type(int152).min && value <= type(int152).max, "SafeCast: value doesn't fit in 152 bits");
        return int152(value);
    }

    /**
     * @dev Returns the downcasted int144 from int256, reverting on
     * overflow (when the input is less than smallest int144 or
     * greater than largest int144).
     *
     * Counterpart to Solidity's `int144` operator.
     *
     * Requirements:
     *
     * - input must fit into 144 bits
     *
     * _Available since v4.7._
     */
    function toInt144(int256 value) internal pure returns (int144) {
        require(value >= type(int144).min && value <= type(int144).max, "SafeCast: value doesn't fit in 144 bits");
        return int144(value);
    }

    /**
     * @dev Returns the downcasted int136 from int256, reverting on
     * overflow (when the input is less than smallest int136 or
     * greater than largest int136).
     *
     * Counterpart to Solidity's `int136` operator.
     *
     * Requirements:
     *
     * - input must fit into 136 bits
     *
     * _Available since v4.7._
     */
    function toInt136(int256 value) internal pure returns (int136) {
        require(value >= type(int136).min && value <= type(int136).max, "SafeCast: value doesn't fit in 136 bits");
        return int136(value);
    }

    /**
     * @dev Returns the downcasted int128 from int256, reverting on
     * overflow (when the input is less than smallest int128 or
     * greater than largest int128).
     *
     * Counterpart to Solidity's `int128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     *
     * _Available since v3.1._
     */
    function toInt128(int256 value) internal pure returns (int128) {
        require(value >= type(int128).min && value <= type(int128).max, "SafeCast: value doesn't fit in 128 bits");
        return int128(value);
    }

    /**
     * @dev Returns the downcasted int120 from int256, reverting on
     * overflow (when the input is less than smallest int120 or
     * greater than largest int120).
     *
     * Counterpart to Solidity's `int120` operator.
     *
     * Requirements:
     *
     * - input must fit into 120 bits
     *
     * _Available since v4.7._
     */
    function toInt120(int256 value) internal pure returns (int120) {
        require(value >= type(int120).min && value <= type(int120).max, "SafeCast: value doesn't fit in 120 bits");
        return int120(value);
    }

    /**
     * @dev Returns the downcasted int112 from int256, reverting on
     * overflow (when the input is less than smallest int112 or
     * greater than largest int112).
     *
     * Counterpart to Solidity's `int112` operator.
     *
     * Requirements:
     *
     * - input must fit into 112 bits
     *
     * _Available since v4.7._
     */
    function toInt112(int256 value) internal pure returns (int112) {
        require(value >= type(int112).min && value <= type(int112).max, "SafeCast: value doesn't fit in 112 bits");
        return int112(value);
    }

    /**
     * @dev Returns the downcasted int104 from int256, reverting on
     * overflow (when the input is less than smallest int104 or
     * greater than largest int104).
     *
     * Counterpart to Solidity's `int104` operator.
     *
     * Requirements:
     *
     * - input must fit into 104 bits
     *
     * _Available since v4.7._
     */
    function toInt104(int256 value) internal pure returns (int104) {
        require(value >= type(int104).min && value <= type(int104).max, "SafeCast: value doesn't fit in 104 bits");
        return int104(value);
    }

    /**
     * @dev Returns the downcasted int96 from int256, reverting on
     * overflow (when the input is less than smallest int96 or
     * greater than largest int96).
     *
     * Counterpart to Solidity's `int96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     *
     * _Available since v4.7._
     */
    function toInt96(int256 value) internal pure returns (int96) {
        require(value >= type(int96).min && value <= type(int96).max, "SafeCast: value doesn't fit in 96 bits");
        return int96(value);
    }

    /**
     * @dev Returns the downcasted int88 from int256, reverting on
     * overflow (when the input is less than smallest int88 or
     * greater than largest int88).
     *
     * Counterpart to Solidity's `int88` operator.
     *
     * Requirements:
     *
     * - input must fit into 88 bits
     *
     * _Available since v4.7._
     */
    function toInt88(int256 value) internal pure returns (int88) {
        require(value >= type(int88).min && value <= type(int88).max, "SafeCast: value doesn't fit in 88 bits");
        return int88(value);
    }

    /**
     * @dev Returns the downcasted int80 from int256, reverting on
     * overflow (when the input is less than smallest int80 or
     * greater than largest int80).
     *
     * Counterpart to Solidity's `int80` operator.
     *
     * Requirements:
     *
     * - input must fit into 80 bits
     *
     * _Available since v4.7._
     */
    function toInt80(int256 value) internal pure returns (int80) {
        require(value >= type(int80).min && value <= type(int80).max, "SafeCast: value doesn't fit in 80 bits");
        return int80(value);
    }

    /**
     * @dev Returns the downcasted int72 from int256, reverting on
     * overflow (when the input is less than smallest int72 or
     * greater than largest int72).
     *
     * Counterpart to Solidity's `int72` operator.
     *
     * Requirements:
     *
     * - input must fit into 72 bits
     *
     * _Available since v4.7._
     */
    function toInt72(int256 value) internal pure returns (int72) {
        require(value >= type(int72).min && value <= type(int72).max, "SafeCast: value doesn't fit in 72 bits");
        return int72(value);
    }

    /**
     * @dev Returns the downcasted int64 from int256, reverting on
     * overflow (when the input is less than smallest int64 or
     * greater than largest int64).
     *
     * Counterpart to Solidity's `int64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     *
     * _Available since v3.1._
     */
    function toInt64(int256 value) internal pure returns (int64) {
        require(value >= type(int64).min && value <= type(int64).max, "SafeCast: value doesn't fit in 64 bits");
        return int64(value);
    }

    /**
     * @dev Returns the downcasted int56 from int256, reverting on
     * overflow (when the input is less than smallest int56 or
     * greater than largest int56).
     *
     * Counterpart to Solidity's `int56` operator.
     *
     * Requirements:
     *
     * - input must fit into 56 bits
     *
     * _Available since v4.7._
     */
    function toInt56(int256 value) internal pure returns (int56) {
        require(value >= type(int56).min && value <= type(int56).max, "SafeCast: value doesn't fit in 56 bits");
        return int56(value);
    }

    /**
     * @dev Returns the downcasted int48 from int256, reverting on
     * overflow (when the input is less than smallest int48 or
     * greater than largest int48).
     *
     * Counterpart to Solidity's `int48` operator.
     *
     * Requirements:
     *
     * - input must fit into 48 bits
     *
     * _Available since v4.7._
     */
    function toInt48(int256 value) internal pure returns (int48) {
        require(value >= type(int48).min && value <= type(int48).max, "SafeCast: value doesn't fit in 48 bits");
        return int48(value);
    }

    /**
     * @dev Returns the downcasted int40 from int256, reverting on
     * overflow (when the input is less than smallest int40 or
     * greater than largest int40).
     *
     * Counterpart to Solidity's `int40` operator.
     *
     * Requirements:
     *
     * - input must fit into 40 bits
     *
     * _Available since v4.7._
     */
    function toInt40(int256 value) internal pure returns (int40) {
        require(value >= type(int40).min && value <= type(int40).max, "SafeCast: value doesn't fit in 40 bits");
        return int40(value);
    }

    /**
     * @dev Returns the downcasted int32 from int256, reverting on
     * overflow (when the input is less than smallest int32 or
     * greater than largest int32).
     *
     * Counterpart to Solidity's `int32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     *
     * _Available since v3.1._
     */
    function toInt32(int256 value) internal pure returns (int32) {
        require(value >= type(int32).min && value <= type(int32).max, "SafeCast: value doesn't fit in 32 bits");
        return int32(value);
    }

    /**
     * @dev Returns the downcasted int24 from int256, reverting on
     * overflow (when the input is less than smallest int24 or
     * greater than largest int24).
     *
     * Counterpart to Solidity's `int24` operator.
     *
     * Requirements:
     *
     * - input must fit into 24 bits
     *
     * _Available since v4.7._
     */
    function toInt24(int256 value) internal pure returns (int24) {
        require(value >= type(int24).min && value <= type(int24).max, "SafeCast: value doesn't fit in 24 bits");
        return int24(value);
    }

    /**
     * @dev Returns the downcasted int16 from int256, reverting on
     * overflow (when the input is less than smallest int16 or
     * greater than largest int16).
     *
     * Counterpart to Solidity's `int16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     *
     * _Available since v3.1._
     */
    function toInt16(int256 value) internal pure returns (int16) {
        require(value >= type(int16).min && value <= type(int16).max, "SafeCast: value doesn't fit in 16 bits");
        return int16(value);
    }

    /**
     * @dev Returns the downcasted int8 from int256, reverting on
     * overflow (when the input is less than smallest int8 or
     * greater than largest int8).
     *
     * Counterpart to Solidity's `int8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits
     *
     * _Available since v3.1._
     */
    function toInt8(int256 value) internal pure returns (int8) {
        require(value >= type(int8).min && value <= type(int8).max, "SafeCast: value doesn't fit in 8 bits");
        return int8(value);
    }

    /**
     * @dev Converts an unsigned uint256 into a signed int256.
     *
     * Requirements:
     *
     * - input must be less than or equal to maxInt256.
     *
     * _Available since v3.0._
     */
    function toInt256(uint256 value) internal pure returns (int256) {
        // Note: Unsafe cast below is okay because `type(int256).max` is guaranteed to be positive
        require(value <= uint256(type(int256).max), "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}