// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;
pragma experimental ABIEncoderV2;

import {IRebatePool} from '../governances/RebatePool.sol';
import {IVotingEscrowCallback} from '../governances/VotingEscrow.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

contract VotingEscrowHelper is IVotingEscrowCallback, Ownable {
    mapping(IERC20 => address) public tokenAtPool;
    IVotingEscrowCallback[] public rebatePools;
    IVotingEscrowCallback public votingEmission;

    modifier isContract(address _address) {
        uint32 size;
        assembly {
            size := extcodesize(_address)
        }
        require(size > 0, 'Not a contract!');
        _;
    }

    constructor(address rebatePool_, address votingEmission_) public {
        votingEmission = IVotingEscrowCallback(votingEmission_);
        rebatePools.push(IVotingEscrowCallback(rebatePool_));
        tokenAtPool[IRebatePool(rebatePool_).getToken()] = rebatePool_;
    }

    function syncWithVotingEscrow(address account_) external override {
        votingEmission.syncWithVotingEscrow(account_);
        for (uint256 i = 0; i < rebatePools.length; i++) {
            rebatePools[i].syncWithVotingEscrow(account_);
        }
    }

    function setEmission(address votingEmission_) public onlyOwner isContract(votingEmission_) {
        votingEmission = IVotingEscrowCallback(votingEmission_);
    }

    function getAllRebatePools() public view returns (IVotingEscrowCallback[] memory) {
        return rebatePools;
    }

    function addRebatePool(address rebatePool_) public onlyOwner isContract(rebatePool_) {
        require(!_isPoolExisted(rebatePool_), 'Pool is already added');
        rebatePools.push(IVotingEscrowCallback(rebatePool_));
        tokenAtPool[IRebatePool(rebatePool_).getToken()] = rebatePool_;
    }

    function replacePoolAtWith(uint256 index_, address rebatePool_) public onlyOwner isContract(rebatePool_) {
        require(index_ >= 0 || index_ < rebatePools.length, 'Wrong argument');
        require(!_isPoolExisted(rebatePool_), 'Pool is already added');
        address oldRebatePool_ = address(IVotingEscrowCallback(rebatePools[index_]));
        tokenAtPool[IRebatePool(oldRebatePool_).getToken()] = address(0);
        rebatePools[index_] = IVotingEscrowCallback(rebatePool_);
        tokenAtPool[IRebatePool(rebatePool_).getToken()] = rebatePool_;
    }


    function _isPoolExisted(address rebatePool_) private view returns (bool) {
        for (uint256 i = 0; i < rebatePools.length; i++) {
            if (rebatePools[i] == IVotingEscrowCallback(rebatePool_)) {
                return true;
            }
        }
        return false;
    }

}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;
pragma experimental ABIEncoderV2;

import '@openzeppelin/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

import '../library/SafeDecimalMath.sol';
import '../library/CoreUtility.sol';
import '../library/System.sol';
import '../interfaces/IVotingEscrow.sol';
import '../interfaces/IWrappedERC20.sol';

interface IRebatePool {

    function getToken() external view returns (IERC20);
}

contract RebatePool is CoreUtility, Ownable, IRebatePool {
    using SafeMath for uint256;
    using SafeDecimalMath for uint256;
    using SafeERC20 for IERC20;

    /// @notice 60% as the max admin fee rate
    uint256 public constant MAX_ADMIN_FEE_RATE = 5e17;

    uint256 public immutable maxTime;
    IERC20 public immutable rewardToken;
    IVotingEscrow public immutable votingEscrow;

    /// @notice Receiver for admin fee
    address public admin;

    /// @notice Admin fee rate
    uint256 public adminFeeRate;

    /// @notice Timestamp of the last checkpoint
    uint256 public checkpointTimestamp;

    /// @notice Mapping of unlockTime => total amount that will be unlocked at unlockTime
    mapping(uint256 => uint256) public scheduledUnlock;

    /// @notice Amount of Goen locked at the end of the last checkpoint's week
    uint256 public nextWeekLocked;

    /// @notice Total veGoen at the end of the last checkpoint's week
    uint256 public nextWeekSupply;

    /// @notice Cumulative rewards received until the last checkpoint minus cumulative rewards
    ///         claimed until now
    uint256 public lastRewardBalance;

    /// @notice Mapping of week => total rewards accumulated
    ///
    ///         Key is the start timestamp of a week on each Thursday. Value is
    ///         the rewards collected from the corresponding fund in rewardToken's unit
    mapping(uint256 => uint256) public rewardsPerWeek;

    /// @notice Mapping of week => vote-locked Goen total supplies
    ///
    //          Key is the start timestamp of a week on each Thursday. Value is
    ///         vote-locked Goen total supplies captured at the start of each week
    mapping(uint256 => uint256) public veSupplyPerWeek;

    /// @notice Locked balance of an account, which is synchronized with `VotingEscrow` when
    ///         `syncWithVotingEscrow()` is called
    mapping(address => IVotingEscrow.LockedBalance) public userLockedBalances;

    /// @notice Start timestamp of the week of a user's last checkpoint
    mapping(address => uint256) public userWeekCursors;

    /// @notice An account's veGoen amount at the beginning of the week of this user's
    ///         last checkpoint
    mapping(address => uint256) public userLastBalances;

    /// @notice Mapping of account => amount of claimable Goen
    mapping(address => uint256) public claimableRewards;

    event Synchronized(
        address indexed account,
        uint256 oldAmount,
        uint256 oldUnlockTime,
        uint256 newAmount,
        uint256 newUnlockTime
    );

    constructor(
        address rewardToken_,
        address votingEscrow_,
        address admin_,
        uint256 adminFeeRate_
    ) public {
        require(adminFeeRate_ <= MAX_ADMIN_FEE_RATE, 'Cannot exceed max admin fee rate');
        rewardToken = IERC20(rewardToken_);
        votingEscrow = IVotingEscrow(votingEscrow_);
        maxTime = IVotingEscrow(votingEscrow_).maxTime();
        admin = admin_;
        adminFeeRate = adminFeeRate_;
        checkpointTimestamp = block.timestamp;
    }

    function getToken() public view override returns (IERC20) {
        return rewardToken;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balanceAtTimestamp(userLockedBalances[account], block.timestamp);
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupplyAtTimestamp(block.timestamp);
    }

    function balanceOfAtTimestamp(address account, uint256 timestamp) external view returns (uint256) {
        require(timestamp >= checkpointTimestamp, 'Must be current or future time');
        return _balanceAtTimestamp(userLockedBalances[account], timestamp);
    }

    function totalSupplyAtTimestamp(uint256 timestamp) external view returns (uint256) {
        require(timestamp >= checkpointTimestamp, 'Must be current or future time');
        return _totalSupplyAtTimestamp(timestamp);
    }

    /// @dev Calculate the amount of veGoen of a `LockedBalance` at a given timestamp
    function _balanceAtTimestamp(IVotingEscrow.LockedBalance memory lockedBalance, uint256 timestamp)
        public
        view
        returns (uint256)
    {
        if (timestamp >= lockedBalance.unlockTime) {
            return 0;
        }
        return lockedBalance.amount.mul(lockedBalance.unlockTime - timestamp) / maxTime;
    }

    function _totalSupplyAtTimestamp(uint256 timestamp) public view returns (uint256) {
        uint256 total = 0;
        for (
            uint256 weekCursor = _endOfWeek(timestamp);
            weekCursor <= timestamp + maxTime;
            weekCursor += System.SYSTEM_INTERVAL
        ) {
            total = total.add((scheduledUnlock[weekCursor].mul(weekCursor - timestamp)) / maxTime);
        }
        return total;
    }

    /// @notice Synchronize an account's locked Goen with `VotingEscrow`.
    /// @param account Address of the synchronized account
    function syncWithVotingEscrow(address account) external {
        userCheckpoint(account);

        uint256 nextWeek = _endOfWeek(block.timestamp);
        IVotingEscrow.LockedBalance memory newLockedBalance = votingEscrow.getLockedBalance(account);
        if (newLockedBalance.amount == 0 || newLockedBalance.unlockTime <= nextWeek) {
            return;
        }
        IVotingEscrow.LockedBalance memory oldLockedBalance = userLockedBalances[account];
        uint256 newNextWeekLocked = nextWeekLocked;
        uint256 newNextWeekSupply = nextWeekSupply;

        // Remove the old schedule if there is one
        if (oldLockedBalance.amount > 0 && oldLockedBalance.unlockTime > nextWeek) {
            scheduledUnlock[oldLockedBalance.unlockTime] = scheduledUnlock[oldLockedBalance.unlockTime].sub(
                oldLockedBalance.amount
            );
            newNextWeekLocked = newNextWeekLocked.sub(oldLockedBalance.amount);
            newNextWeekSupply = newNextWeekSupply.sub(
                oldLockedBalance.amount.mul(oldLockedBalance.unlockTime - nextWeek) / maxTime
            );
        }

        scheduledUnlock[newLockedBalance.unlockTime] = scheduledUnlock[newLockedBalance.unlockTime].add(
            newLockedBalance.amount
        );
        nextWeekLocked = newNextWeekLocked.add(newLockedBalance.amount);
        // Round up on division when added to the total supply, so that the total supply is never
        // smaller than the sum of all accounts' veGoen balance.
        nextWeekSupply = newNextWeekSupply.add(
            newLockedBalance.amount.mul(newLockedBalance.unlockTime - nextWeek).add(maxTime - 1) / maxTime
        );
        userLockedBalances[account] = newLockedBalance;

        emit Synchronized(
            account,
            oldLockedBalance.amount,
            oldLockedBalance.unlockTime,
            newLockedBalance.amount,
            newLockedBalance.unlockTime
        );
    }

    function userCheckpoint(address account) public returns (uint256 rewards) {
        checkpoint();
        rewards = claimableRewards[account].add(_rewardCheckpoint(account));
        claimableRewards[account] = rewards;
    }

    function claimRewards(address account) external returns (uint256 rewards) {
        rewards = _claimRewards(account);
        rewardToken.safeTransfer(account, rewards);
    }

    function claimRewardsAndUnwrap(address account) external returns (uint256 rewards) {
        rewards = _claimRewards(account);
        IWrappedERC20(address(rewardToken)).withdraw(rewards);
        (bool success, ) = account.call{value: rewards}('');
        require(success, 'Transfer failed');
    }

    /// @notice Receive unwrapped transfer from the wrapped token.
    receive() external payable {}

    function _claimRewards(address account) public returns (uint256 rewards) {
        checkpoint();
        rewards = claimableRewards[account].add(_rewardCheckpoint(account));
        claimableRewards[account] = 0;
        lastRewardBalance = lastRewardBalance.sub(rewards);
    }

    /// @notice Make a global checkpoint. If the period since the last checkpoint spans over
    ///         multiple weeks, rewards received in this period are split into these weeks
    ///         proportional to the time in each week.
    /// @dev Post-conditions:
    ///
    ///      - `checkpointTimestamp == block.timestamp`
    ///      - `lastRewardBalance == rewardToken.balanceOf(address(this))`
    ///      - All `rewardsPerWeek[t]` are updated, where `t <= checkpointTimestamp`
    ///      - All `veSupplyPerWeek[t]` are set, where `t <= checkpointTimestamp`
    ///      - `nextWeekSupply` is the total veGoen at the end of this week
    ///      - `nextWeekLocked` is the total locked Goen at the end of this week
    function checkpoint() public {
        uint256 tokenBalance = rewardToken.balanceOf(address(this));
        uint256 tokensToDistribute = tokenBalance.sub(lastRewardBalance);
        lastRewardBalance = tokenBalance;

        uint256 adminFee = tokensToDistribute.multiplyDecimal(adminFeeRate);
        if (adminFee > 0) {
            claimableRewards[admin] = claimableRewards[admin].add(adminFee);
            tokensToDistribute = tokensToDistribute.sub(adminFee);
        }
        uint256 rewardTime = checkpointTimestamp;
        uint256 weekCursor = _endOfWeek(rewardTime) - System.SYSTEM_INTERVAL;
        uint256 currentWeek = _endOfWeek(block.timestamp) - System.SYSTEM_INTERVAL;

        // Update veGoen supply at the beginning of each week since the last checkpoint.
        if (weekCursor < currentWeek) {
            uint256 newLocked = nextWeekLocked;
            uint256 newSupply = nextWeekSupply;
            for (uint256 w = weekCursor + System.SYSTEM_INTERVAL; w <= currentWeek; w += System.SYSTEM_INTERVAL) {
                veSupplyPerWeek[w] = newSupply;
                // Calculate supply at the end of the next week.
                newSupply = newSupply.sub(newLocked.mul(System.SYSTEM_INTERVAL) / maxTime);
                // Remove Goen unlocked at the end of the next week from total locked amount.
                newLocked = newLocked.sub(scheduledUnlock[w + System.SYSTEM_INTERVAL]);
            }
            nextWeekLocked = newLocked;
            nextWeekSupply = newSupply;
        }

        // Distribute rewards received since the last checkpoint.
        if (tokensToDistribute > 0) {
            if (weekCursor >= currentWeek) {
                rewardsPerWeek[weekCursor] = rewardsPerWeek[weekCursor].add(tokensToDistribute);
            } else {
                uint256 sinceLast = block.timestamp - rewardTime;
                // Calculate the fraction of rewards proportional to the time from
                // the last checkpoint to the end of that week.
                rewardsPerWeek[weekCursor] = rewardsPerWeek[weekCursor].add(
                    tokensToDistribute.mul(weekCursor + System.SYSTEM_INTERVAL - rewardTime) / sinceLast
                );
                weekCursor += System.SYSTEM_INTERVAL;
                // Calculate the fraction of rewards for intermediate whole weeks.
                while (weekCursor < currentWeek) {
                    rewardsPerWeek[weekCursor] = tokensToDistribute.mul(System.SYSTEM_INTERVAL) / sinceLast;
                    weekCursor += System.SYSTEM_INTERVAL;
                }
                // Calculate the fraction of rewards proportional to the time from
                // the beginning of the current week to the current block timestamp.
                rewardsPerWeek[weekCursor] = tokensToDistribute.mul(block.timestamp - weekCursor) / sinceLast;
            }
        }

        checkpointTimestamp = block.timestamp;
    }

    function updateAdmin(address newAdmin) external onlyOwner {
        admin = newAdmin;
    }

    function updateAdminFeeRate(uint256 newAdminFeeRate) external onlyOwner {
        require(newAdminFeeRate <= MAX_ADMIN_FEE_RATE, 'Cannot exceed max admin fee rate');
        adminFeeRate = newAdminFeeRate;
    }

    /// @dev Calculate rewards since a user's last checkpoint and make a new checkpoint.
    ///
    ///      Post-conditions:
    ///
    ///      - `userWeekCursor[account]` is the start timestamp of the current week
    ///      - `userLastBalances[account]` is amount of veGoen at the beginning of the current week
    /// @param account Address of the account
    /// @return Rewards since the last checkpoint
    function _rewardCheckpoint(address account) public returns (uint256) {
        uint256 currentWeek = _endOfWeek(block.timestamp) - System.SYSTEM_INTERVAL;
        uint256 weekCursor = userWeekCursors[account];
        if (weekCursor >= currentWeek) {
            return 0;
        }
        if (weekCursor == 0) {
            userWeekCursors[account] = currentWeek;
            return 0;
        }

        // The week of the last user checkpoint has ended.
        uint256 lastBalance = userLastBalances[account];
        uint256 rewards = lastBalance > 0
            ? lastBalance.mul(rewardsPerWeek[weekCursor]) / veSupplyPerWeek[weekCursor]
            : 0;
        weekCursor += System.SYSTEM_INTERVAL;

        // Iterate over succeeding weeks and calculate rewards.
        IVotingEscrow.LockedBalance memory lockedBalance = userLockedBalances[account];
        while (weekCursor < currentWeek) {
            uint256 veGoenBalance = _balanceAtTimestamp(lockedBalance, weekCursor);
            if (veGoenBalance == 0) {
                break;
            }
            // A positive veGoenBalance guarentees that veSupply of that week is also positive
            rewards = rewards.add(veGoenBalance.mul(rewardsPerWeek[weekCursor]) / veSupplyPerWeek[weekCursor]);
            weekCursor += System.SYSTEM_INTERVAL;
        }

        userWeekCursors[account] = currentWeek;
        userLastBalances[account] = _balanceAtTimestamp(lockedBalance, currentWeek);
        return rewards;
    }

    /// @notice Recalculate `nextWeekSupply` from scratch. This function eliminates accumulated
    ///         rounding errors in `nextWeekSupply`, which is incrementally updated in
    ///         `syncWithVotingEscrow()` and `checkpoint()`. It is almost never required.
    /// @dev See related test cases for details about the rounding errors.
    function calibrateSupply() external {
        uint256 nextWeek = _endOfWeek(checkpointTimestamp);
        nextWeekSupply = _totalSupplyAtTimestamp(nextWeek);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;
pragma experimental ABIEncoderV2;

import '@openzeppelin/contracts/utils/Address.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
import '@openzeppelin/contracts/utils/ReentrancyGuard.sol';
import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';

import '../library/CoreUtility.sol';
import '../library/ManagedPausable.sol';
import '../interfaces/IVotingEscrow.sol';
import '../library/ProxyUtility.sol';

interface IAddressWhitelist {
    function check(address account) external view returns (bool);
}

interface IVotingEscrowCallback {
    function syncWithVotingEscrow(address account) external;
}

contract VotingEscrow is
    IVotingEscrow,
    OwnableUpgradeable,
    ReentrancyGuard,
    CoreUtility,
    ManagedPausable,
    ProxyUtility
{
    /// @dev Reserved storage slots for future base contract upgrades
    uint256[29] public _reservedSlots;

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event LockCreated(address indexed account, uint256 amount, uint256 unlockTime);

    event AmountIncreased(address indexed account, uint256 increasedAmount);

    event UnlockTimeIncreased(address indexed account, uint256 newUnlockTime);

    event Withdrawn(address indexed account, uint256 amount);

    uint8 public constant decimals = 18;

    uint256 public immutable override maxTime;

    address public immutable override token;

    string public name;
    string public symbol;

    address public addressWhitelist;

    mapping(address => LockedBalance) public locked;

    /// @notice Mapping of unlockTime => total amount that will be unlocked at unlockTime
    mapping(uint256 => uint256) public scheduledUnlock;

    /// @notice max lock time allowed at the moment
    uint256 public maxTimeAllowed;

    /// @notice Contract to be call when an account's locked Goen is updated
    address public callback;

    /// @notice Amount of Goen locked now. Expired locks are not included.
    uint256 public totalLocked;

    /// @notice Total veGoen at the end of the last checkpoint's week
    uint256 public nextWeekSupply;

    /// @notice Mapping of week => vote-locked Goen total supplies
    ///
    ///         Key is the start timestamp of a week on each Thursday. Value is
    ///         vote-locked Goen total supplies captured at the start of each week
    mapping(uint256 => uint256) public veSupplyPerWeek;

    /// @notice Start timestamp of the trading week in which the last checkpoint is made
    uint256 public checkpointWeek;

    constructor(address token_, uint256 maxTime_) public {
        token = token_;
        maxTime = maxTime_;
    }

    /// @dev Initialize the contract. The contract is designed to be used with OpenZeppelin's
    ///      `TransparentUpgradeableProxy`. This function should be called by the proxy's
    ///      constructor (via the `_data` argument).
    function initialize(
        string memory name_,
        string memory symbol_,
        uint256 maxTimeAllowed_
    ) external initializer {
        __Ownable_init();
        require(maxTimeAllowed_ <= maxTime, 'Cannot exceed max time');
        maxTimeAllowed = maxTimeAllowed_;
        _initializeV2(msg.sender, name_, symbol_);
    }

    /// @dev Initialize the part added in V2. If this contract is upgraded from the previous
    ///      version, call `upgradeToAndCall` of the proxy and put a call to this function
    ///      in the `data` argument.
    ///
    ///      In the previous version, name and symbol were not correctly initialized via proxy.

    function initializeV2(
        address pauser_,
        string memory name_,
        string memory symbol_
    ) external onlyProxyAdmin {
        _initializeV2(pauser_, name_, symbol_);
    }

    function _initializeV2(
        address pauser_,
        string memory name_,
        string memory symbol_
    ) public {
        _initializeManagedPausable(pauser_);
        require(bytes(name).length == 0 && bytes(symbol).length == 0);
        name = name_;
        symbol = symbol_;

        // Initialize totalLocked, nextWeekSupply and checkpointWeek
        uint256 nextWeek = _endOfWeek(block.timestamp);
        uint256 totalLocked_ = 0;
        uint256 nextWeekSupply_ = 0;
        for (uint256 weekCursor = nextWeek; weekCursor <= nextWeek + maxTime; weekCursor += System.SYSTEM_INTERVAL) {
            totalLocked_ = totalLocked_.add(scheduledUnlock[weekCursor]);
            nextWeekSupply_ = nextWeekSupply_.add((scheduledUnlock[weekCursor].mul(weekCursor - nextWeek)) / maxTime);
        }
        totalLocked = totalLocked_;
        nextWeekSupply = nextWeekSupply_;
        checkpointWeek = nextWeek - System.SYSTEM_INTERVAL;
    }

    function getTimestampDropBelow(address account, uint256 threshold) external view override returns (uint256) {
        LockedBalance memory lockedBalance = locked[account];
        if (lockedBalance.amount == 0 || lockedBalance.amount < threshold) {
            return 0;
        }
        return lockedBalance.unlockTime.sub(threshold.mul(maxTime).div(lockedBalance.amount));
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _balanceOfAtTimestamp(account, block.timestamp);
    }

    // calculate total veGoen every week , su
    function totalSupply() external view override returns (uint256) {
        uint256 weekCursor = checkpointWeek;
        uint256 nextWeek = _endOfWeek(block.timestamp);
        uint256 currentWeek = nextWeek - System.SYSTEM_INTERVAL;
        uint256 newNextWeekSupply = nextWeekSupply;
        uint256 newTotalLocked = totalLocked;
        if (weekCursor < currentWeek) {
            weekCursor += System.SYSTEM_INTERVAL;
            for (; weekCursor < currentWeek; weekCursor += System.SYSTEM_INTERVAL) {
                // Remove Goen unlocked at the beginning of the next week from total locked amount.
                newTotalLocked = newTotalLocked.sub(scheduledUnlock[weekCursor]);
                // Calculate supply at the end of the next week.
                newNextWeekSupply = newNextWeekSupply.sub(newTotalLocked.mul(System.SYSTEM_INTERVAL) / maxTime);
            }
            newTotalLocked = newTotalLocked.sub(scheduledUnlock[weekCursor]);
            newNextWeekSupply = newNextWeekSupply.sub(newTotalLocked.mul(block.timestamp - currentWeek) / maxTime);
        } else {
            newNextWeekSupply = newNextWeekSupply.add(newTotalLocked.mul(nextWeek - block.timestamp) / maxTime);
        }

        return newNextWeekSupply;
    }

    function getLockedBalance(address account) external view override returns (LockedBalance memory) {
        return locked[account];
    }

    function balanceOfAtTimestamp(address account, uint256 timestamp) external view override returns (uint256) {
        return _balanceOfAtTimestamp(account, timestamp);
    }

    function totalSupplyAtTimestamp(uint256 timestamp) external view returns (uint256) {
        return _totalSupplyAtTimestamp(timestamp);
    }

    function createLock(uint256 amount, uint256 unlockTime) external nonReentrant whenNotPaused {
        _assertNotContract();
        require(unlockTime + System.SYSTEM_INTERVAL == _endOfWeek(unlockTime), 'Unlock time must be end of a week');

        LockedBalance memory lockedBalance = locked[msg.sender];

        require(amount > 0, 'Zero value');
        require(lockedBalance.amount == 0, 'Withdraw old tokens first');
        require(unlockTime > block.timestamp, 'Can only lock until time in the future');
        require(unlockTime <= block.timestamp + maxTimeAllowed, 'Voting lock cannot exceed max lock time');
        // checkpoint of total
        _checkpoint(lockedBalance.amount, lockedBalance.unlockTime, amount, unlockTime);
        scheduledUnlock[unlockTime] = scheduledUnlock[unlockTime].add(amount);
        locked[msg.sender].unlockTime = unlockTime;
        locked[msg.sender].amount = amount;

        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);

        if (callback != address(0)) {
            IVotingEscrowCallback(callback).syncWithVotingEscrow(msg.sender);
        }

        emit LockCreated(msg.sender, amount, unlockTime);
    }

    function increaseAmount(address account, uint256 amount) external nonReentrant whenNotPaused {
        LockedBalance memory lockedBalance = locked[account];

        require(amount > 0, 'Zero value');
        require(lockedBalance.unlockTime > block.timestamp, 'Cannot add to expired lock');

        uint256 newAmount = lockedBalance.amount.add(amount);
        _checkpoint(lockedBalance.amount, lockedBalance.unlockTime, newAmount, lockedBalance.unlockTime);
        scheduledUnlock[lockedBalance.unlockTime] = scheduledUnlock[lockedBalance.unlockTime].add(amount);
        locked[account].amount = newAmount;

        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);

        if (callback != address(0)) {
            IVotingEscrowCallback(callback).syncWithVotingEscrow(msg.sender);
        }

        emit AmountIncreased(account, amount);
    }

    function increaseUnlockTime(uint256 unlockTime) external nonReentrant whenNotPaused {
        require(unlockTime + System.SYSTEM_INTERVAL == _endOfWeek(unlockTime), 'Unlock time must be end of a week');
        LockedBalance memory lockedBalance = locked[msg.sender];

        require(lockedBalance.unlockTime > block.timestamp, 'Lock expired');
        require(unlockTime > lockedBalance.unlockTime, 'Can only increase lock duration');
        require(unlockTime <= block.timestamp + maxTimeAllowed, 'Voting lock cannot exceed max lock time');

        _checkpoint(lockedBalance.amount, lockedBalance.unlockTime, lockedBalance.amount, unlockTime);
        scheduledUnlock[lockedBalance.unlockTime] = scheduledUnlock[lockedBalance.unlockTime].sub(lockedBalance.amount);
        scheduledUnlock[unlockTime] = scheduledUnlock[unlockTime].add(lockedBalance.amount);
        locked[msg.sender].unlockTime = unlockTime;

        if (callback != address(0)) {
            IVotingEscrowCallback(callback).syncWithVotingEscrow(msg.sender);
        }

        emit UnlockTimeIncreased(msg.sender, unlockTime);
    }

    function withdraw() external nonReentrant {
        LockedBalance memory lockedBalance = locked[msg.sender];
        require(block.timestamp >= lockedBalance.unlockTime, 'The lock is not expired');
        uint256 amount = uint256(lockedBalance.amount);

        lockedBalance.unlockTime = 0;
        lockedBalance.amount = 0;
        locked[msg.sender] = lockedBalance;

        IERC20(token).safeTransfer(msg.sender, amount);

        emit Withdrawn(msg.sender, amount);
    }

    function updateAddressWhitelist(address newWhitelist) external onlyOwner {
        require(newWhitelist == address(0) || Address.isContract(newWhitelist), 'Must be null or a contract');
        addressWhitelist = newWhitelist;
    }

    function updateCallback(address newCallback) external onlyOwner {
        require(newCallback == address(0) || Address.isContract(newCallback), 'Must be null or a contract');
        callback = newCallback;
    }

    function _assertNotContract() private view {
        if (msg.sender != tx.origin) {
            if (addressWhitelist != address(0) && IAddressWhitelist(addressWhitelist).check(msg.sender)) {
                return;
            }
            revert('Smart contract depositors not allowed');
        }
    }

    function _balanceOfAtTimestamp(address account, uint256 timestamp) public view returns (uint256) {
        require(timestamp >= block.timestamp, 'Must be current or future time');
        LockedBalance memory lockedBalance = locked[account];
        if (timestamp > lockedBalance.unlockTime) {
            return 0;
        }
        return (lockedBalance.amount.mul(lockedBalance.unlockTime - timestamp)) / maxTime;
    }

    function _totalSupplyAtTimestamp(uint256 timestamp) public view returns (uint256) {
        uint256 weekCursor = _endOfWeek(timestamp);
        uint256 total = 0;
        for (; weekCursor <= timestamp + maxTime; weekCursor += System.SYSTEM_INTERVAL) {
            total = total.add((scheduledUnlock[weekCursor].mul(weekCursor - timestamp)) / maxTime);
        }
        return total;
    }

    /// @dev Pre-conditions:
    ///
    ///      - `newAmount > 0`
    ///      - `newUnlockTime > block.timestamp`
    ///      - `newUnlockTime +System.SYSTEM_INTERVAL == _endOfWeek(newUnlockTime)`, i.e. aligned to a trading week
    ///
    ///      The latter two conditions gaurantee that `newUnlockTime` is no smaller than the local
    ///      variable `nextWeek` in the function.
    function _checkpoint(
        uint256 oldAmount,
        uint256 oldUnlockTime,
        uint256 newAmount,
        uint256 newUnlockTime
    ) public {
        // Update veGoen supply at the beginning of each week since the last checkpoint.
        uint256 weekCursor = checkpointWeek;
        uint256 nextWeek = _endOfWeek(block.timestamp);
        uint256 currentWeek = nextWeek - System.SYSTEM_INTERVAL;
        uint256 newTotalLocked = totalLocked;
        uint256 newNextWeekSupply = nextWeekSupply;
        if (weekCursor < currentWeek) {
            for (uint256 w = weekCursor + System.SYSTEM_INTERVAL; w <= currentWeek; w += System.SYSTEM_INTERVAL) {
                veSupplyPerWeek[w] = newNextWeekSupply;
                // Remove Goen unlocked at the beginning of this week from total locked amount.
                newTotalLocked = newTotalLocked.sub(scheduledUnlock[w]);
                // Calculate supply at the end of the next week.
                newNextWeekSupply = newNextWeekSupply.sub(newTotalLocked.mul(System.SYSTEM_INTERVAL) / maxTime);
            }
            checkpointWeek = currentWeek;
        }

        // Remove the old schedule if there is one
        if (oldAmount > 0 && oldUnlockTime >= nextWeek) {
            newTotalLocked = newTotalLocked.sub(oldAmount);
            newNextWeekSupply = newNextWeekSupply.sub(oldAmount.mul(oldUnlockTime - nextWeek) / maxTime);
        }

        totalLocked = newTotalLocked.add(newAmount);
        // Round up on division when added to the total supply, so that the total supply is never
        // smaller than the sum of all accounts' veGoen balance.
        nextWeekSupply = newNextWeekSupply.add(newAmount.mul(newUnlockTime - nextWeek).add(maxTime - 1) / maxTime);
    }

    function updateMaxTimeAllowed(uint256 newMaxTimeAllowed) external onlyOwner {
        require(newMaxTimeAllowed <= maxTime, 'Cannot exceed max time');
        require(newMaxTimeAllowed > maxTimeAllowed, 'Cannot shorten max time allowed');
        maxTimeAllowed = newMaxTimeAllowed;
    }

    /// @notice Recalculate `nextWeekSupply` from scratch. This function eliminates accumulated
    ///         rounding errors in `nextWeekSupply`, which is incrementally updated in
    ///         `createLock`, `increaseAmount` and `increaseUnlockTime`. It is almost
    ///         never required.
    /// @dev Search "rounding error" in test cases for details about the rounding errors.
    function calibrateSupply() external {
        uint256 nextWeek = checkpointWeek + System.SYSTEM_INTERVAL;
        nextWeekSupply = _totalSupplyAtTimestamp(nextWeek);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
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
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
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
        require(b <= a, "SafeMath: subtraction overflow");
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
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
        require(b > 0, "SafeMath: modulo by zero");
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./IERC20.sol";
import "../../math/SafeMath.sol";
import "../../utils/Address.sol";

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
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
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
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

import "@openzeppelin/contracts/math/SafeMath.sol";

library SafeDecimalMath {
    using SafeMath for uint256;

    /* Number of decimal places in the representations. */
    uint256 private constant decimals = 18;
    uint256 private constant highPrecisionDecimals = 27;

    /* The number representing 1.0. */
    uint256 private constant UNIT = 10**uint256(decimals);

    /* The number representing 1.0 for higher fidelity numbers. */
    uint256 private constant PRECISE_UNIT = 10**uint256(highPrecisionDecimals);
    uint256 private constant UNIT_TO_HIGH_PRECISION_CONVERSION_FACTOR =
        10**uint256(highPrecisionDecimals - decimals);

    /**
     * @return The result of multiplying x and y, interpreting the operands as fixed-point
     * decimals.
     *
     * @dev A unit factor is divided out after the product of x and y is evaluated,
     * so that product must be less than 2**256. As this is an integer division,
     * the internal division always rounds down. This helps save on gas. Rounding
     * is more expensive on gas.
     */
    function multiplyDecimal(uint256 x, uint256 y) internal pure returns (uint256) {
        /* Divide by UNIT to remove the extra factor introduced by the product. */
        return x.mul(y).div(UNIT);
    }

    function multiplyDecimalPrecise(uint256 x, uint256 y) internal pure returns (uint256) {
        /* Divide by UNIT to remove the extra factor introduced by the product. */
        return x.mul(y).div(PRECISE_UNIT);
    }

    /**
     * @return The result of safely dividing x and y. The return value is a high
     * precision decimal.
     *
     * @dev y is divided after the product of x and the standard precision unit
     * is evaluated, so the product of x and UNIT must be less than 2**256. As
     * this is an integer division, the result is always rounded down.
     * This helps save on gas. Rounding is more expensive on gas.
     */
    function divideDecimal(uint256 x, uint256 y) internal pure returns (uint256) {
        /* Reintroduce the UNIT factor that will be divided out by y. */
        return x.mul(UNIT).div(y);
    }

    function divideDecimalPrecise(uint256 x, uint256 y) internal pure returns (uint256) {
        /* Reintroduce the UNIT factor that will be divided out by y. */
        return x.mul(PRECISE_UNIT).div(y);
    }

    /**
     * @dev Convert a standard decimal representation to a high precision one.
     */
    function decimalToPreciseDecimal(uint256 i) internal pure returns (uint256) {
        return i.mul(UNIT_TO_HIGH_PRECISION_CONVERSION_FACTOR);
    }

    /**
     * @dev Convert a high precision decimal to a standard decimal representation.
     */
    function preciseDecimalToDecimal(uint256 i) internal pure returns (uint256) {
        uint256 quotientTimesTen = i.mul(10).div(UNIT_TO_HIGH_PRECISION_CONVERSION_FACTOR);

        if (quotientTimesTen % 10 >= 5) {
            quotientTimesTen = quotientTimesTen.add(10);
        }

        return quotientTimesTen.div(10);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, and the max value of
     * uint256 on overflow.
     */
    function saturatingMul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        return c / a != b ? type(uint256).max : c;
    }

    function saturatingMultiplyDecimal(uint256 x, uint256 y) internal pure returns (uint256) {
        /* Divide by UNIT to remove the extra factor introduced by the product. */
        return saturatingMul(x, y).div(UNIT);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

import '@openzeppelin/contracts/math/SafeMath.sol';
import './System.sol';

abstract contract CoreUtility {
    using SafeMath for uint256;

    /// @dev UTC time of a day when the fund settles.
    uint256 internal constant SETTLEMENT_TIME = 14 hours;

    /// @dev Return end timestamp of the trading week containing a given timestamp.
    ///
    ///      A trading week starts at UTC time `SETTLEMENT_TIME` on a Thursday (inclusive)
    ///      and ends at the same time of the next Thursday (exclusive).
    /// @param timestamp The given timestamp
    /// @return End timestamp of the trading week.
    function _endOfWeek(uint256 timestamp) internal pure returns (uint256) {
        return
            ((timestamp.add(System.SYSTEM_INTERVAL) - SETTLEMENT_TIME) / System.SYSTEM_INTERVAL) * System.SYSTEM_INTERVAL + SETTLEMENT_TIME;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

library System {
    address constant SWAP_ROUTER = address(0);
    address constant VENUS_UNICONTROLLER = 0x94d1820b2D1c7c7452A163983Dc888CEC546b77D;
    address constant GOEN = address(0);
    address constant WBNB = 0x97c012Ef10eDc79510A17272CEE3ecBE1443177F;
    address constant XVS = 0xB9e0E753630434d7863528cc73CB7AC638a7c8ff;
    address constant BUSD = 0x8301F2213c0eeD49a7E28Ae4c3e91722919B8B47;
    uint256 constant SYSTEM_INTERVAL = 1 days;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;
pragma experimental ABIEncoderV2;

interface IVotingEscrow {
    struct LockedBalance {
        uint256 amount;
        uint256 unlockTime;
    }

    function token() external view returns (address);

    function maxTime() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function balanceOfAtTimestamp(address account, uint256 timestamp) external view returns (uint256);

    function getTimestampDropBelow(address account, uint256 threshold) external view returns (uint256);

    function getLockedBalance(address account) external view returns (LockedBalance memory);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IWrappedERC20 is IERC20 {
    function deposit() external payable;

    function withdraw(uint256 wad) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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

pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
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

pragma solidity >=0.6.0 <0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/Initializable.sol";
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
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Contract of an emergency stop mechanism that can be triggered by an authorized account.
 *
 * This module is modified based on Pausable in OpenZeppelin v3.3.0, adding public functions to
 * pause, unpause and manage the pauser role. It is also designed to be used by upgradable
 * contracts, like PausableUpgradable but with compact storage slots and no dependencies.
 */
abstract contract ManagedPausable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**AC
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    event PauserRoleTransferred(address indexed previousPauser, address indexed newPauser);

    uint256 private constant FALSE = 0;
    uint256 private constant TRUE = 1;

    uint256 private _initialized;

    uint256 private _paused;

    address private _pauser;

    function _initializeManagedPausable(address pauser_) internal {
        require(_initialized == FALSE);
        _initialized = TRUE;
        _paused = FALSE;
        _pauser = pauser_;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused != FALSE;
    }

    function pauser() public view returns (address) {
        return _pauser;
    }

    function renouncePauserRole() external onlyPauser {
        emit PauserRoleTransferred(_pauser, address(0));
        _pauser = address(0);
    }

    function transferPauserRole(address newPauser) external onlyPauser {
        require(newPauser != address(0));
        emit PauserRoleTransferred(_pauser, newPauser);
        _pauser = newPauser;
    }

    modifier onlyPauser() {
        require(_pauser == msg.sender, "Pausable: only pauser");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(_paused == FALSE, "Pausable: paused");
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
        require(_paused != FALSE, "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function pause() external onlyPauser whenNotPaused {
        _paused = TRUE;
        emit Paused(msg.sender);
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function unpause() external onlyPauser whenPaused {
        _paused = FALSE;
        emit Unpaused(msg.sender);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

abstract contract ProxyUtility {
    /// @dev Storage slot with the admin of the contract.
    bytes32 private constant _ADMIN_SLOT = bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1);

    /// @dev Revert if the proxy admin is not the caller
    modifier onlyProxyAdmin() {
        bytes32 slot = _ADMIN_SLOT;
        address proxyAdmin;
        assembly {
            proxyAdmin := sload(slot)
        }
        require(msg.sender == proxyAdmin, "Only proxy admin");
        _;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;
import "../proxy/Initializable.sol";

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

// solhint-disable-next-line compiler-version
pragma solidity >=0.4.24 <0.8.0;

import "../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {UpgradeableProxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
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
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

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

    /// @dev Returns true if and only if the function is running in the constructor
    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

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
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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