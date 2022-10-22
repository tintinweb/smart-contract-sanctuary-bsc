// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SignedSafeMathUpgradeable.sol";
import "./Bicento.sol";

contract Staking is Initializable, OwnableUpgradeable {
    using SafeMathUpgradeable for uint256;
    using SignedSafeMathUpgradeable for int256;
    using SafeERC20Upgradeable for IERC20Upgradeable;
    // Info of each user.
    struct UserInfo {
        uint256 amount; // Amount of LP tokens the user has provided for each period (14/30/60/90...days).
        uint256 fixedReward; // The reward entitled to the user from a fixed interest rate for each period (i.e. 5% for 14 days, 12% for 30 days...)   
         int256 dynamicRewardDebt; // The dynamic amount of Bicento entitled to the user for each period..
        uint256 lockedTime; // The locked timestamp for each period before releasing the LP tokens; User only receive earlyWithdrawalRate percentage of LP tokens if withdraw before locked time. When register a IDO project, the new locked time will be reviewed and updated 
        uint256 lastTimeAmountChanged; // The last time to stake/unstake LP tokens, used for fixed reward calculation
  
        // We do some fancy math here. Basically, any point in time, the amount of Bicentos
        // entitled to a user but is pending to be distributed is: 
        //   reward = fixed reward + dynamic reward 
        // 
        //   fixed reward = user.amount * timeToStakeInSecond * interestRatePerSecond 
        //  
        //   dynamic reward = (user.amount * pool.accBicentoPerShare) - user.dynamicRewardDebt  
        //   (pool.accBicentoPerShare is only updated if dynamicRewardRemaining > 0 and dynamicRewardStartTime <= updating time <= dynamicRewardEndTime)
        //     
        // For dynamic reward, whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
        //   1. The pool's `accBicentoPerShare` (and `lastRewardTime`) gets updated.
        //   2. User's `amount` gets updated.
        //   3. User's `rewardDebt` gets updated.
    }
    // Info of each pool.
    struct PoolInfo {
        IERC20Upgradeable lpToken; // Address of LP token contract.
        uint256 allocPoint; // How many allocation points assigned to this pool. Bicentos to distribute per second.
        uint256 creatingTime; //The creating time of the pool
        uint256 lastRewardTime; // Last timestamp that dynamic Bicentos reward distribution occurs.
        uint256 accBicentoPerShare; // Accumulated dynamic Bicentos per share, times ACC_BICENTO_PRECISION (1e12). See below.
        uint256 fixedRewardRemaining; // Fixed reward left in the pool 
        uint256 dynamicRewardStartTime; // The start time of dynamic reward
        uint256 dynamicRewardEndTime; // The end time of dynamic reward
        uint256 dynamicRewardRemaining; // The dynamic reward left in the pool
    }
    // The Bicento token!
    IERC20Upgradeable public bicento;
    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => mapping(uint256 => UserInfo))) public userInfo; //userInfo[poolId][userAddress][periodId]  
    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint;
    // Bicento tokens created per second.
    uint256 public bicentoPerSecond;
    // Precision. Trick for small numbers 
    uint256 private constant ACC_BICENTO_PRECISION = 1e12;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event Harvest(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event LogBicentoPerSecond(uint256 bicentoPerSecond);

    uint256 private constant SECONDS_PER_DAY = 86400;
    uint256 private constant SECONDS_PER_YEAR = 31556952; // 1 year ~ 365.2425 days (refer to sushiswap/sushiswap-interface/src/functions/convert/apyApr.ts)

    // Amount and allocation for each staking Level (i.e level 1: 400 1x, level 2: 800 2x...)
    uint256[] private userStakedAmountLevel;
    uint256[] private userAllocationLevel;      
    // Percentage of withdrawl amount if user unstakes early before locked time of each period
    uint256 private earlyWithdrawalRate; // percentage
    // Staking period and their fixed interest rates (i.e 14 days 5%, 30 days 12%...s) 
    uint256[] private stakingPeriod; // per second
    uint256[] private fixedInterestRate;  // percentage 

    uint256 private constant DECIMAL_PRECISION = 1e18;

    /// @notice Initialize data
    function initialize(IERC20Upgradeable _bicento) public initializer {
        __Ownable_init();

        //bicento = IERC20Upgradeable(bicentoAddress);        
        bicento = _bicento;
        totalAllocPoint = 0;

        initStakingPeriods();        
        initUserStakedAmountLevel();
        initUserAllocationLevel();
    }

    /// @notice Returns the number of pools.
    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    /// @notice Add a new LP to the pool. Can only be called by the owner.
    /// DO NOT add the same LP token more than once. Rewards will be messed up if you do.
    /// @param _allocPoint AP of the new pool.
    /// @param _lpToken Address of the LP ERC-20 token.
    /// @param _fixedRewardRemaining Fixed reward amount
    /// @param _dynamicRewardStartTime The start time of dynamic reward
    /// @param _dynamicRewardEndTime The end time of dynamic reward
    /// @param _dynamicRewardRemaining Dynamic reward amount
    /// @param _withUpdate True if want to update all pools.
    function add(uint256 _allocPoint, IERC20Upgradeable _lpToken, uint256 _fixedRewardRemaining, uint256 _dynamicRewardStartTime, uint256 _dynamicRewardEndTime, uint256 _dynamicRewardRemaining, bool _withUpdate) public onlyOwner {
        require(_dynamicRewardStartTime >= block.timestamp, "add: Start time for dynamic reward is less than the creating pool time");
        require(_dynamicRewardEndTime > _dynamicRewardStartTime, "add: End time for dynamic reward must be greater than start time");
        uint256 creatorBicentoBalance = bicento.balanceOf(msg.sender);  
        uint256 totalReward = _fixedRewardRemaining + _dynamicRewardRemaining;
        require(creatorBicentoBalance >= totalReward, "add: Not enough rewards to add a new pool");
    
        if (_withUpdate) {
            massUpdatePools();
        }
        
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
    
        poolInfo.push(
            PoolInfo({
                lpToken: _lpToken,
                allocPoint: _allocPoint,
                creatingTime: block.timestamp,
                lastRewardTime: _dynamicRewardStartTime,
                accBicentoPerShare: 0,
                fixedRewardRemaining: _fixedRewardRemaining,
                dynamicRewardStartTime: _dynamicRewardStartTime,
                dynamicRewardEndTime: _dynamicRewardEndTime,
                dynamicRewardRemaining: _dynamicRewardRemaining
            })
        );

        //bicento.safeTransferFrom(address(msg.sender), address(this), totalReward);
        //bicento.transferFrom(address(msg.sender), address(this), totalReward);
    }

    /// @notice Add more fixed reward amount to a pool
    /// @param pid Pool id 
    /// @param fixedRewardAmount Amount added to fixed reward
    function addFixedReward(uint256 pid, uint256 fixedRewardAmount) public onlyOwner {
        uint256 creatorBicentoBalance = bicento.balanceOf(msg.sender);
        require(creatorBicentoBalance >= fixedRewardAmount, "addFixedReward: Not enough token to add for fixed reward.");

        PoolInfo storage pool = poolInfo[pid];
        pool.fixedRewardRemaining = pool.fixedRewardRemaining.add(fixedRewardAmount);

        bicento.safeTransferFrom(address(msg.sender), address(this), fixedRewardAmount);
    }
    
    /// @notice Add more dynamic reward amount to a pool
    /// @param pid Pool id 
    /// @param dynamicRewardAmount Amount added to dynamic reward
    function addDynamicReward(uint256 pid, uint256 dynamicRewardAmount) public onlyOwner {
        uint256 creatorBicentoBalance = bicento.balanceOf(msg.sender);
        require(creatorBicentoBalance >= dynamicRewardAmount, "addDynamicReward: Not enough token to add for dynamic reward");

        PoolInfo storage pool = poolInfo[pid];
        pool.dynamicRewardRemaining = pool.dynamicRewardRemaining.add(dynamicRewardAmount); 

        bicento.safeTransferFrom(address(msg.sender), address(this), dynamicRewardAmount);
    }

    /// @notice Adjust last reward time
    /// @param pid Pool id 
    /// @param _lastRewardTime New last reward time
    function setLastRewardTime(uint256 pid, uint256 _lastRewardTime) public onlyOwner {
        PoolInfo storage pool = poolInfo[pid];
        pool.lastRewardTime = _lastRewardTime;
    }

    /// @notice Adjust dynamic reward period
    /// @param pid Pool id 
    /// @param newDynamicRewardStartTime New start time
    /// @param newDynamicRewardEndTime New end time
    function setDynamicRewardPeriod(uint256 pid, uint256 newDynamicRewardStartTime, uint256 newDynamicRewardEndTime) public onlyOwner {
        require(newDynamicRewardStartTime >= block.timestamp, "setDynamicRewardTime: Start time for new dynamic reward is less than current time");
        require(newDynamicRewardEndTime > newDynamicRewardStartTime, "setDynamicRewardTime: End time for dynamic reward must be greater than start time");
        PoolInfo storage pool = poolInfo[pid];
        pool.dynamicRewardStartTime = newDynamicRewardStartTime;
        pool.dynamicRewardEndTime = newDynamicRewardEndTime;
    }

    /// @notice Update the given pool's Bicento allocation point. Can only be called by the owner.
    /// @param _pid The index of the pool. See `poolInfo`.
    /// @param _allocPoint New AP of the pool.
    /// @param _withUpdate True if want to update all pools.
    function setAllocationPoint(uint256 _pid, uint256 _allocPoint, bool _withUpdate) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;
    }

    /// @notice Sets the Bicento per second to be distributed. Can only be called by the owner.
    /// @param _bicentoPerSecond The amount of Bicento to be distributed per second.
    function setBicentoPerSecond(uint256 _bicentoPerSecond) public onlyOwner {
        bicentoPerSecond = _bicentoPerSecond;
        emit LogBicentoPerSecond(_bicentoPerSecond);
    }

    /// @notice View function to see pending Bicento on frontend.
    /// @param _pid The index of the pool. See `poolInfo`.
    /// @param _user Address of user.
    /// @param _periodid The index of the staking period (i.e 0 for 14 days, 1 for 30 days...).
    /// @return pending Bicento reward for a given user.
    function pendingBicento(uint256 _pid, address _user, uint256 _periodid) external view returns (uint256) {
        UserInfo storage user = userInfo[_pid][_user][_periodid];
        PoolInfo storage pool = poolInfo[_pid];        
        uint256 currentTime = block.timestamp;

        // Fixed reward
        uint256 lastTimeAmountChanged = (user.lastTimeAmountChanged == 0) ? pool.creatingTime : user.lastTimeAmountChanged;
        uint256 fixedReward = user.fixedReward.add(user.amount.mul(currentTime-lastTimeAmountChanged).mul(fixedInterestRate[_periodid])/(SECONDS_PER_YEAR * 100));
        if (fixedReward > pool.fixedRewardRemaining) fixedReward = pool.fixedRewardRemaining;

        // Dynamic reward
        uint256 accBicentoPerShare = pool.accBicentoPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));

        if (currentTime > pool.lastRewardTime && lpSupply != 0) {
            uint256 time = currentTime.sub(pool.lastRewardTime);
            uint256 bicentoReward = time.mul(bicentoPerSecond).mul(pool.allocPoint) / totalAllocPoint;
            accBicentoPerShare = accBicentoPerShare.add(bicentoReward.mul(ACC_BICENTO_PRECISION) / lpSupply);
        }
        
        int256 accumulatedBicento = int256(user.amount.mul(accBicentoPerShare) / ACC_BICENTO_PRECISION); 
        uint256 dynamicReward = accumulatedBicento > user.dynamicRewardDebt ? uint256(accumulatedBicento.sub(user.dynamicRewardDebt)) : 0; 
        if (dynamicReward > pool.dynamicRewardRemaining) dynamicReward = pool.dynamicRewardRemaining;

        return fixedReward + dynamicReward;
    }

    /// @notice Update dynamic reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    /// @notice Update dynamic reward variables of the given pool.
    /// @param _pid The index of the pool. See `poolInfo`.
    function updatePool(uint256 _pid) public {
        uint256 currentTime = block.timestamp;
        PoolInfo storage pool = poolInfo[_pid];

        // Only update dynamic reward if is in its period (start, end time) 
        if ( (currentTime <= pool.dynamicRewardEndTime) && (currentTime >= pool.dynamicRewardStartTime) && (pool.dynamicRewardRemaining > 0) ) {
            if (currentTime > pool.lastRewardTime) {
                uint256 lpSupply = pool.lpToken.balanceOf(address(this));
                if (lpSupply > 0) {
                    uint256 time = currentTime.sub(pool.lastRewardTime);
                    uint256 bicentoReward = time.mul(bicentoPerSecond).mul(pool.allocPoint) / totalAllocPoint;
                    pool.accBicentoPerShare = pool.accBicentoPerShare.add(bicentoReward.mul(ACC_BICENTO_PRECISION) / lpSupply);
                }
                pool.lastRewardTime = currentTime;
            }
        } else {
            if (currentTime > pool.lastRewardTime)
                pool.lastRewardTime = currentTime;
        }
    }

    /// @notice Deposit LP tokens for Bicento allocation.
    /// @param _pid The index of the pool. See `poolInfo`.
    /// @param _periodid The index of the staking period (i.e 0 for 14 days, 1 for 30 days...).
    /// @param _amount LP token amount to deposit.
    function deposit(uint256 _pid, uint256 _periodid, uint256 _amount) public {
        require(_amount > 0, "deposit: Deposit must be > 0");

        UserInfo storage user = userInfo[_pid][msg.sender][_periodid];
        PoolInfo storage pool = poolInfo[_pid];        
        updatePool(_pid);

        uint256 currentTime = block.timestamp;

        // Update fixedReward
        if (user.lastTimeAmountChanged == 0) user.lastTimeAmountChanged = pool.creatingTime;
        user.fixedReward = user.fixedReward.add(user.amount.mul(currentTime-user.lastTimeAmountChanged).mul(fixedInterestRate[_periodid])/(SECONDS_PER_YEAR * 100));
        user.lastTimeAmountChanged = currentTime;
        
        // Update dynamicRewardDebt
        user.dynamicRewardDebt = user.dynamicRewardDebt.add(int256(_amount.mul(pool.accBicentoPerShare) / ACC_BICENTO_PRECISION));
       
        if (currentTime + stakingPeriod[_periodid] > user.lockedTime) user.lockedTime = currentTime + stakingPeriod[_periodid];
        
        user.amount = user.amount.add(_amount);
        pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);

        emit Deposit(msg.sender, _pid, _amount);
    }

    /// @notice Withdraw LP tokens.
    /// @param _pid The index of the pool. See `poolInfo`.
    /// @param _periodid The index of the staking period (i.e 0 for 14 days, 1 for 30 days...).
    /// @param _amount LP token amount to withdraw.
    function withdraw(uint256 _pid, uint256 _periodid, uint256 _amount) public {
        UserInfo storage user = userInfo[_pid][msg.sender][_periodid];
        uint256 currentTime = block.timestamp;

        // If early withdraw, user only receive earlyWithdrawalRate percentage of _amount
        uint256 withdrawableAmount = (currentTime > user.lockedTime) ? _amount : _amount.mul(earlyWithdrawalRate).div(100); 
        require(user.amount >= withdrawableAmount, "withdraw: Withdrawing exceeds the remaining");
                
        PoolInfo storage pool = poolInfo[_pid];
        updatePool(_pid);

        // Update fixedReward
        if (user.lastTimeAmountChanged == 0) user.lastTimeAmountChanged = pool.creatingTime;
        user.fixedReward = user.fixedReward.add(user.amount.mul(currentTime-user.lastTimeAmountChanged).mul(fixedInterestRate[_periodid])/(SECONDS_PER_YEAR * 100));
        user.lastTimeAmountChanged = currentTime;
        
        // Update dynamicRewardDebt         
        user.dynamicRewardDebt = user.dynamicRewardDebt.sub(int256(withdrawableAmount.mul(pool.accBicentoPerShare) / ACC_BICENTO_PRECISION));
        
        user.amount = user.amount.sub(withdrawableAmount);
        pool.lpToken.safeTransfer(address(msg.sender), withdrawableAmount);

        emit Withdraw(msg.sender, _pid, withdrawableAmount);
    }

    /// @notice Harvest processing
    /// @param _pid The index of the pool. See `poolInfo`.
    /// @param _periodid The index of the staking period (i.e 0 for 14 days, 1 for 30 days...).
    function harvest(uint256 _pid, uint256 _periodid) public {
        UserInfo storage user = userInfo[_pid][msg.sender][_periodid];
        PoolInfo storage pool = poolInfo[_pid];
        updatePool(_pid);

        uint256 currentTime = block.timestamp;

        // Fixed reward
        if (user.lastTimeAmountChanged == 0) user.lastTimeAmountChanged = pool.creatingTime;
        user.fixedReward = user.fixedReward.add(user.amount.mul(currentTime-user.lastTimeAmountChanged).mul(fixedInterestRate[_periodid])/(SECONDS_PER_YEAR * 100));
        user.lastTimeAmountChanged = currentTime;
        
        uint256 fixedReward = (user.fixedReward > pool.fixedRewardRemaining) ? pool.fixedRewardRemaining : user.fixedReward;
        pool.fixedRewardRemaining -= fixedReward;

        // Dynamic reward
        int256 accumulatedBicento = int256(user.amount.mul(pool.accBicentoPerShare) / ACC_BICENTO_PRECISION);
        uint256 dynamicReward = accumulatedBicento > user.dynamicRewardDebt ? uint256(accumulatedBicento.sub(user.dynamicRewardDebt)) : 0; 
        if (dynamicReward > pool.dynamicRewardRemaining) dynamicReward = pool.dynamicRewardRemaining;
        pool.dynamicRewardRemaining -= dynamicReward;

        // Update user dynamicRewardDebt 
        user.dynamicRewardDebt = accumulatedBicento;
        
        uint256 harvestedReward = fixedReward + dynamicReward;   
        safeBicentoTransfer(address(msg.sender), harvestedReward);
        emit Harvest(msg.sender, _pid, harvestedReward);
    }
    
    /// @notice Withdraw LP tokens and harvest processing.
    /// @param _pid The index of the pool. See `poolInfo`.
    /// @param _periodid The index of the staking period (i.e 0 for 14 days, 1 for 30 days...).
    /// @param _amount LP token amount to withdraw.
    function withdrawAndHarvest(uint256 _pid, uint256 _periodid, uint256 _amount) public {
        UserInfo storage user = userInfo[_pid][msg.sender][_periodid];
        uint256 currentTime = block.timestamp;

        // If early withdraw, user only receive earlyWithdrawalRate percentage of _amount
        uint256 withdrawableAmount = (currentTime > user.lockedTime) ? _amount : _amount.mul(earlyWithdrawalRate).div(100);
        require(user.amount >= withdrawableAmount, "withdrawAndHarvest: Withdrawing exceeds the remaining");

        PoolInfo storage pool = poolInfo[_pid];
        updatePool(_pid);

        // Fixed reward
        if (user.lastTimeAmountChanged == 0) user.lastTimeAmountChanged = pool.creatingTime;
        user.fixedReward = user.fixedReward.add(user.amount.mul(currentTime-user.lastTimeAmountChanged).mul(fixedInterestRate[_periodid])/(SECONDS_PER_YEAR * 100));
        user.lastTimeAmountChanged = currentTime;
        
        uint256 fixedReward = (user.fixedReward > pool.fixedRewardRemaining) ? pool.fixedRewardRemaining : user.fixedReward;
        pool.fixedRewardRemaining -= fixedReward;

        // Dynamic reward
        int256 accumulatedBicento = int256(user.amount.mul(pool.accBicentoPerShare) / ACC_BICENTO_PRECISION);
        uint256 dynamicReward = accumulatedBicento > user.dynamicRewardDebt ? uint256(accumulatedBicento.sub(user.dynamicRewardDebt)) : 0; 
        if (dynamicReward > pool.dynamicRewardRemaining) dynamicReward = pool.dynamicRewardRemaining;
        pool.dynamicRewardRemaining -= dynamicReward;

        // Update user dynamicRewardDebt and amount 
        user.dynamicRewardDebt = accumulatedBicento.sub(int256(withdrawableAmount.mul(pool.accBicentoPerShare) / ACC_BICENTO_PRECISION)); 

        uint256 harvestedReward = fixedReward + dynamicReward;       
        user.amount = user.amount.sub(withdrawableAmount);

        safeBicentoTransfer(address(msg.sender), harvestedReward);
        pool.lpToken.safeTransfer(address(msg.sender), withdrawableAmount);

        emit Harvest(msg.sender, _pid, harvestedReward);
        emit Withdraw(msg.sender, _pid, withdrawableAmount);
    }

    /// @notice Withdraw without caring about rewards. EMERGENCY ONLY.
    /// @param _pid The index of the pool. See `poolInfo`.
    /// @param _periodid The index of the staking period (i.e 0 for 14 days, 1 for 30 days...).
    function emergencyWithdraw(uint256 _pid, uint256 _periodid) public {
        UserInfo storage user = userInfo[_pid][msg.sender][_periodid];
        PoolInfo storage pool = poolInfo[_pid];

        uint256 amount = user.amount;
        user.amount = 0;
        user.dynamicRewardDebt = 0;
        user.fixedReward = 0;
        user.lockedTime = pool.creatingTime;

        pool.lpToken.safeTransfer(address(msg.sender), amount);
        emit EmergencyWithdraw(msg.sender, _pid, amount);
    }

    /// @notice Safe Bicento transfer function, just in case if rounding error causes pool to not have enough Bicentos.
    /// @param _to Address to transfer Bicento
    /// @param _amount Amount transferred
    function safeBicentoTransfer(address _to, uint256 _amount) internal {
        uint256 bicentoBal = bicento.balanceOf(address(this));
        if (_amount > bicentoBal) {
            bicento.transfer(_to, bicentoBal);
        } else {
            bicento.transfer(_to, _amount);
        }
    }

    /// @notice Init staking period and their fixed interest rates
    function initStakingPeriods() private {
        earlyWithdrawalRate = 80; // 80%

        // 14, 30, 60, 90 days
        stakingPeriod.push(14 * SECONDS_PER_DAY); // 14 days * seconds per day
        stakingPeriod.push(30 * SECONDS_PER_DAY);
        stakingPeriod.push(60 * SECONDS_PER_DAY);
        stakingPeriod.push(90 * SECONDS_PER_DAY);

        fixedInterestRate.push(5); // 5%
        fixedInterestRate.push(12);
        fixedInterestRate.push(25);
        fixedInterestRate.push(40);
    }

    /// @notice Init amounts for staking levels
    function initUserStakedAmountLevel() private {
        userStakedAmountLevel.push(0);
        userStakedAmountLevel.push(400 * DECIMAL_PRECISION); // Level 1 : 400 Bicento
        userStakedAmountLevel.push(800 * DECIMAL_PRECISION);
        userStakedAmountLevel.push(2000 * DECIMAL_PRECISION);
        userStakedAmountLevel.push(4000 * DECIMAL_PRECISION);
        userStakedAmountLevel.push(8000 * DECIMAL_PRECISION);
        userStakedAmountLevel.push(20000 * DECIMAL_PRECISION);
        userStakedAmountLevel.push(40000 * DECIMAL_PRECISION);
        userStakedAmountLevel.push(80000 * DECIMAL_PRECISION);
        userStakedAmountLevel.push(160000 * DECIMAL_PRECISION);      
    } 

    /// @notice Init allocations for staking levels
    function initUserAllocationLevel() private {
        userAllocationLevel.push(0);
        userAllocationLevel.push(1); // Level 1 : 1x
        userAllocationLevel.push(2);
        userAllocationLevel.push(2);
        userAllocationLevel.push(5); // Level 4 : 5x
        userAllocationLevel.push(11);
        userAllocationLevel.push(28);
        userAllocationLevel.push(57);
        userAllocationLevel.push(115);
        userAllocationLevel.push(288);
    } 

    /// @notice Get staking level length 
    /// @return Staking level length  
    function getStakingLevelSize() external view returns (uint256) {
        return userStakedAmountLevel.length;
    }

    /// @notice Get total amounts of all staking periods of a user 
    /// @param pid The index of the pool. See `poolInfo`.
    /// @param userAddress Address of a user
    /// @return The total staking amount of all periods for a user 
    function getUserStakedAmount(uint256 pid, address userAddress) external view returns (uint256) {
        // If need to check that the userAddress exists ???
        uint256 stakedAmount = 0;
        for (uint256 i = 0; i < stakingPeriod.length; i++) {
           stakedAmount += userInfo[pid][userAddress][i].amount; 
        }
        return stakedAmount; 
    }

    /// @notice Get a staking level/tier based on the total amount 
    /// @param amount The total amounts of all staking periods of a user 
    /// @return Staking level/tier of a user
    function getUserStakeLevel(uint256 amount) external view returns (uint256) {
        uint256 length = userStakedAmountLevel.length;
        
        if (length < 2) {
            return 0; 
        } else {
            for (uint256 i = 0; i < length-1; i++) {
                if ( (amount < userStakedAmountLevel[i+1]) && (userStakedAmountLevel[i] <= amount) ) {
                    return i;
                }
            }
            return length-1;
        }
    }

    /// @notice Get an allocation for a staking level/tier
    /// @param userStakeLevel The staking level/tier
    /// @return Allocation for a staking level/tier
    function getUserAllocationLevel(uint256 userStakeLevel) external view returns (uint256) {
        if (userStakeLevel >= userAllocationLevel.length) 
            return 0; 
        else 
            return userAllocationLevel[userStakeLevel];    
    }

    /// @notice Set amount for a staking level
    /// @param userStakeLevel The staking level
    /// @param stakedAmount Amount for the level
    function setUserStakedAmountLevel(uint256 userStakeLevel, uint256 stakedAmount) public onlyOwner {
        require(userStakeLevel < userStakedAmountLevel.length,"setUserStakedAmountLevel: userStakeLevel is out of bound");
        userStakedAmountLevel[userStakeLevel] = stakedAmount;
    }

    /// @notice Set allocation for a staking level
    /// @param userStakeLevel The staking level
    /// @param allocation Allocation for the level
    function setUserAllocationLevel(uint256 userStakeLevel, uint256 allocation) public onlyOwner {
        require(userStakeLevel < userAllocationLevel.length,"setUserAllocationLevel: userAllocLevel is out of bound");
        userAllocationLevel[userStakeLevel] = allocation;
    }

    /// @notice Set rate for early withdrawal
    /// @param _earlyWithdrawalRate The rate for early withdrawal
    function setEarlyWithdrawalRate(uint256 _earlyWithdrawalRate) public onlyOwner {
        require(_earlyWithdrawalRate >= 0, "setEarlyWithdrawalRate: rate needs > 0");
        require(_earlyWithdrawalRate <= 100, "setEarlyWithdrawalRate: rate exceeds 100%");
        earlyWithdrawalRate = _earlyWithdrawalRate;
    }

    /// @notice Set staking period for a period
    /// @param periodid The index of the staking period (i.e 0 for 14 days, 1 for 30 days...).
    /// @param periodInSecond Amount of second for the period
    function setStakingPeriod(uint256 periodid, uint256 periodInSecond) public onlyOwner {
        require(periodid < stakingPeriod.length, "setStakingPeriod: periodid is out of bound");
        stakingPeriod[periodid] = periodInSecond;
    }

    /// @notice Set fixed interest rate for a period
    /// @param periodid The index of the staking period (i.e 0 for 14 days, 1 for 30 days...).
    /// @param interestRate The interest rate is set
    function setFixedInterestRate(uint256 periodid, uint256 interestRate) public onlyOwner {
        require(periodid < fixedInterestRate.length, "setFixedInterestRate: periodid is out of bound");
        fixedInterestRate[periodid] = interestRate;
    }

    /// @notice Update new locked time for every period if it is longer than the current one (Normally for extension of the locked time when registration)
    /// @param _pid The index of the pool. See `poolInfo`.
    /// @param userAddress User address 
    /// @param _newlockedTime The new locked time 
    function updateLockedTime(uint256 _pid, address userAddress, uint256 _newlockedTime) external {
        uint256 count = stakingPeriod.length;

        for (uint256 i = 0; i < count; i++) { 
            UserInfo storage user = userInfo[_pid][userAddress][i]; 
            if ( (user.amount > 0) && (_newlockedTime > user.lockedTime) ) user.lockedTime = _newlockedTime;
        }
    }

    function bicentoTransfer(
        address to,
        uint256 amount
    ) external payable{
        bicento.approve(address(msg.sender), amount);
        bicento.transfer(to, amount);
    }

    function bicentoTransferFrom(
        address from,
        address to,
        uint256 amount
    ) external payable{
        bicento.safeApprove(address(this), amount);
        //bicento.safeApprove(payable(to), amount);
        bicento.safeTransferFrom(from, address(this), amount);
        //require(sent, "Token transfer failed");
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMathUpgradeable {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
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
        return a + b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
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
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
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
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SignedSafeMath.sol)

pragma solidity ^0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SignedSafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */
library SignedSafeMathUpgradeable {
    /**
     * @dev Returns the multiplication of two signed integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(int256 a, int256 b) internal pure returns (int256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two signed integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(int256 a, int256 b) internal pure returns (int256) {
        return a / b;
    }

    /**
     * @dev Returns the subtraction of two signed integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(int256 a, int256 b) internal pure returns (int256) {
        return a - b;
    }

    /**
     * @dev Returns the addition of two signed integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(int256 a, int256 b) internal pure returns (int256) {
        return a + b;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract Bicento is Initializable, ERC20Upgradeable, ERC20BurnableUpgradeable {    
    uint256 private constant _PRE_MINE_SUPPLY = 20000000 * 1e18; // Pre-mint to msg.sender of this token contract 
    uint256 private constant _MAX_SUPPLY = 500000000 * 1e18; // Max supply of Bicento token
  
    /// @notice initializer for constructor. Do not remove the below comment, it is cumstomized for compiler to allow unsafe upgradeable constructore
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    /// @notice Initialize and mint _PRE_MINE_SUPPLY token
    function initialize() public initializer {
        __ERC20_init("Bicento", "BCEN");
        __ERC20Burnable_init();
        
        _mint(msg.sender, _PRE_MINE_SUPPLY);
    }

    /// @notice Override _mint function capped with max supply
    /// @param account The address to receive minted token.
    /// @param amount The amount of token
    function _mint(address account, uint256 amount) internal virtual override {
        require(totalSupply() + amount <= _MAX_SUPPLY, "Bicento: Exceeded max supply");
        super._mint(account, amount);
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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20Upgradeable.sol";
import "./extensions/IERC20MetadataUpgradeable.sol";
import "../../utils/ContextUpgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable, IERC20MetadataUpgradeable {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    function __ERC20_init(string memory name_, string memory symbol_) internal onlyInitializing {
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[45] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/extensions/ERC20Burnable.sol)

pragma solidity ^0.8.0;

import "../ERC20Upgradeable.sol";
import "../../../utils/ContextUpgradeable.sol";
import "../../../proxy/utils/Initializable.sol";

/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
abstract contract ERC20BurnableUpgradeable is Initializable, ContextUpgradeable, ERC20Upgradeable {
    function __ERC20Burnable_init() internal onlyInitializing {
    }

    function __ERC20Burnable_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `amount`.
     */
    function burnFrom(address account, uint256 amount) public virtual {
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20MetadataUpgradeable is IERC20Upgradeable {
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