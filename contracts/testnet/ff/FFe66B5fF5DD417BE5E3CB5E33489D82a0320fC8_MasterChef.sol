// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IERC20 {
    function symbol() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

interface IPancakePair {
    function balanceOf(address owner) external view returns (uint);
    function token0() external view returns (address);
    function token1() external view returns (address);
}

/// @title Farming contract for minted Narfex Token
/// @author Danil Sakhinov
/// @notice Distributes a reward from the balance instead of minting it
contract MasterChef is Ownable {

    // User share of a pool
    struct UserInfo {
        uint amount; // Amount of LP-tokens deposit
        uint withdrawnReward; // Reward already withdrawn
        uint depositTimestamp; // Last deposit time
        uint harvestTimestamp; // Last harvest time
        uint storedReward; // Reward tokens accumulated in contract
    }

    struct PoolInfo {
        IERC20 pairToken; // Address of LP token contract
        uint256 allocPoint; // How many allocation points assigned to this pool
        uint256 lastRewardBlock;  // Last block number that NRFX distribution occurs.
        uint256 accRewardPerShare; // Accumulated NRFX per share, times 1e12
    }

    // Reward to harvest
    IERC20 public rewardToken;
    // The interval from the deposit in which the commission for the reward will be taken.
    uint public commissionInterval = 14 days;
    // Interval since last harvest when next harvest is not possible
    uint public harvestInterval = 8 hours;
    // Commission for to early harvests with 2 digits of presition (10000 = 100%)
    uint public earlyHarvestCommission = 1000;
    // Referral percent for reward with 2 digits of precision (10000 = 100%)
    uint public referralPercent = 60;
    // Amount of NRFX per block for all pools
    uint256 public rewardPerBlock;
    uint constant HUNDRED_PERCENTS = 10000;

    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;
    // Mapping of pools IDs for pair addresses
    mapping (address => uint256) public poolId;
    // Mapping of users referrals
    mapping (address => address) private referrals;
    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;
    // The block number when farming starts
    uint256 public startBlock;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event Harvest(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);

    constructor(
        address _rewardToken,
        uint256 _rewardPerBlock
    ) {
        rewardToken = IERC20(_rewardToken);
        rewardPerBlock = _rewardPerBlock;
        startBlock = block.number;
    }

    /// @notice Count of created pools
    /// @return poolInfo length
    function getPoolsCount() external view returns (uint256) {
        return poolInfo.length;
    }

    /// @notice Returns the soil fertility
    /// @return Reward left in the common pool
    function getNarfexLeft() public view returns (uint) {
        return rewardToken.balanceOf(address(this));
    }

    /// @notice Withdraw amount of reward token to the owner
    /// @param _amount Amount of reward tokens. Can be set to 0 to withdraw all reward tokens
    function withdrawNarfex(uint _amount) public onlyOwner {
        uint amount = _amount > 0
            ? _amount
            : getNarfexLeft();
        rewardToken.transfer(address(msg.sender), amount);
    }

    /// @notice Add a new pool
    /// @param _allocPoint Allocation point for this pool
    /// @param _pairToken Address of LP token contract
    /// @param _withUpdate Force update all pools
    function add(uint256 _allocPoint, address _pairToken, bool _withUpdate) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint + _allocPoint;
        poolInfo.push(PoolInfo({
            pairToken: IERC20(_pairToken),
            allocPoint: _allocPoint,
            lastRewardBlock: lastRewardBlock,
            accRewardPerShare: 0
        }));
        poolId[_pairToken] = poolInfo.length - 1;
    }

    /// @notice Update allocation points for a pool
    /// @param _pid Pool index
    /// @param _allocPoint Allocation points
    /// @param _withUpdate Force update all pools
    function set(uint256 _pid, uint256 _allocPoint, bool _withUpdate) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint - poolInfo[_pid].allocPoint + _allocPoint;
        poolInfo[_pid].allocPoint = _allocPoint;
    }

    /// @notice Set a new reward per block amount
    /// @param _amount Amount of reward tokens per block
    /// @param _withUpdate Force update pools to fix previous rewards
    function setRewardPerBlock(uint256 _amount, bool _withUpdate) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        rewardPerBlock = _amount;
    }

    /// @notice Calculates the user's reward based on a blocks range
    /// @param _pairAddress The address of LP token
    /// @param _user The user address
    /// @return reward size
    /// @dev Only for frontend view
    function getUserReward(address _pairAddress, address _user) public view returns (uint256) {
        uint256 _pid = poolId[_pairAddress];
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accRewardPerShare = pool.accRewardPerShare;
        uint256 lpSupply = pool.pairToken.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 blocks = block.number - pool.lastRewardBlock;
            uint256 cakeReward = blocks * rewardPerBlock * pool.allocPoint / totalAllocPoint;
            accRewardPerShare += cakeReward * 1e12 / lpSupply;
        }
        return user.amount * accRewardPerShare / 1e12 - user.withdrawnReward + user.storedReward;
    }

    /// @notice If enough time has passed since the last harvest
    /// @param _pairAddress The address of LP token
    /// @param _user The user address
    /// @return true if user can harvest
    function getIsUserCanHarvest(address _pairAddress, address _user) internal view returns (bool) {
        uint256 _pid = poolId[_pairAddress];
        UserInfo storage user = userInfo[_pid][_user];
        bool isEarlyHarvest = block.timestamp - user.harvestTimestamp < harvestInterval;
        return !isEarlyHarvest;
    }

    /// @notice If enough time has passed since the last deposit
    /// @param _pairAddress The address of LP token
    /// @param _user The user address
    /// @return true if user can withdraw without loosing some reward
    function getIsEarlyWithdraw(address _pairAddress, address _user) internal view returns (bool) {
        uint256 _pid = poolId[_pairAddress];
        UserInfo storage user = userInfo[_pid][_user];
        bool isEarlyWithdraw = block.timestamp - user.depositTimestamp < commissionInterval;
        return !isEarlyWithdraw;
    }

    /// @notice Returns user's amount of LP tokens
    /// @param _pairAddress The address of LP token
    /// @param _user The user address
    /// @return user's pool size
    function getUserPoolSize(address _pairAddress, address _user) public view returns (uint) {
        uint256 _pid = poolId[_pairAddress];
        return userInfo[_pid][_user].amount;
    }

    /// @notice Returns contract settings by one request
    /// @return uintRewardPerBlock
    /// @return uintCommissionInterval
    /// @return uintHarvestInterval
    /// @return uintEarlyHarvestCommission
    /// @return uintReferralPercent
    function getSettings() public view returns (
        uint uintRewardPerBlock,
        uint uintCommissionInterval,
        uint uintHarvestInterval,
        uint uintEarlyHarvestCommission,
        uint uintReferralPercent
        ) {
        return (
        rewardPerBlock,
        commissionInterval,
        harvestInterval,
        earlyHarvestCommission,
        referralPercent
        );
    }

    /// @notice Returns pool data in one request
    /// @param _pairAddress The address of LP token
    /// @return token0 First token address
    /// @return token1 Second token address
    /// @return token0symbol First token symbol
    /// @return token1symbol Second token symbol
    /// @return amount Liquidity pool size
    /// @return poolShare Share of the pool based on allocation points
    function getPoolData(address _pairAddress) public view returns (
        address token0,
        address token1,
        string memory token0symbol,
        string memory token1symbol,
        uint amount,
        uint poolShare
    ) {
        uint256 _pid = poolId[_pairAddress];
        IPancakePair pairToken = IPancakePair(_pairAddress);
        IERC20 _token0 = IERC20(pairToken.token0());
        IERC20 _token1 = IERC20(pairToken.token1());

        return (
            pairToken.token0(),
            pairToken.token1(),
            _token0.symbol(),
            _token1.symbol(),
            pairToken.balanceOf(address(this)),
            poolInfo[_pid].allocPoint * HUNDRED_PERCENTS / totalAllocPoint
        );
    }

    /// @notice Returns pool data in one request
    /// @param _pairAddress The ID of liquidity pool
    /// @param _user The user address
    /// @return balance User balance of LP token
    /// @return userPool User liquidity pool size in the current pool
    /// @return reward Current user reward in the current pool
    /// @return isCanHarvest Is it time to harvest the reward
    function getPoolUserData(address _pairAddress, address _user) public view returns (
        uint balance,
        uint userPool,
        uint256 reward,
        bool isCanHarvest
    ) {
        return (
            IPancakePair(_pairAddress).balanceOf(_user),
            userInfo[poolId[_pairAddress]][_user].amount,
            getUserReward(_pairAddress, _user),
            getIsUserCanHarvest(_pairAddress, _user)
        );
    }

    /// @notice Sets the commission interval
    /// @param interval Interval size in seconds
    function setCommissionInterval(uint interval) public onlyOwner {
        commissionInterval = interval;
    }

    /// @notice Sets the harvest interval
    /// @param interval Interval size in seconds
    function setHarvestInterval(uint interval) public onlyOwner {
        harvestInterval = interval;
    }

    /// @notice Sets the harvest interval
    /// @param percents Commission in percents (10 for default 10%)
    function setEarlyHarvestCommission(uint percents) public onlyOwner {
        earlyHarvestCommission = percents;
    }

    /// @notice Owner can set the referral percent
    /// @param percent Referral percent
    function setReferralPercent(uint percent) public onlyOwner {
        referralPercent = percent;
    }

    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    /// @notice Update reward variables of the given pool to be up-to-date
    /// @param _pid Pool index
    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.pairToken.balanceOf(address(this));
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 blocks = block.number - pool.lastRewardBlock;
        uint256 cakeReward = blocks * rewardPerBlock * pool.allocPoint / totalAllocPoint;
        pool.accRewardPerShare += cakeReward * 1e12 / lpSupply;
        pool.lastRewardBlock = block.number;
    }

    /// @notice Deposit LP tokens to the farm. It will try to harvest first
    /// @param _pairAddress The address of LP token
    /// @param _amount Amount of LP tokens to deposit
    /// @param _referral Address of the agent who invited the user
    function deposit(address _pairAddress, uint256 _amount, address _referral) public {
        uint256 _pid = poolId[_pairAddress];
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user.amount * pool.accRewardPerShare / 1e12 - user.withdrawnReward + user.storedReward;
            if (pending > 0) {
                rewardTransfer(user, pending, false, _pid);
            }
        }
        if (_amount > 0) {
            pool.pairToken.transferFrom(address(msg.sender), address(this), _amount);
            user.amount += _amount;
        }
        user.withdrawnReward = user.amount * pool.accRewardPerShare / 1e12;
        user.depositTimestamp = block.timestamp;
        emit Deposit(msg.sender, _pid, _amount);
        if (_referral != address(0) && _referral != msg.sender && referrals[msg.sender] != _referral) {
            referrals[msg.sender] = _referral;
        }
    }

    /// @notice Short version of deposit without refer
    function deposit(address _pairAddress, uint256 _amount) public {
        deposit(_pairAddress, _amount, address(0));
    }

    /// @notice Withdraw LP tokens from the farm. It will try to harvest first
    /// @param _pairAddress The address of LP token
    /// @param _amount Amount of LP tokens to withdraw
    function withdraw(address _pairAddress, uint256 _amount) public {
        uint256 _pid = poolId[_pairAddress];
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "Too big amount");
        updatePool(_pid);
        uint256 pending = user.amount * pool.accRewardPerShare / 1e12 - user.withdrawnReward + user.storedReward;
        if (pending > 0) {
            rewardTransfer(user, pending, true, _pid);
        }
        if (_amount > 0) {
            user.amount -= _amount;
            pool.pairToken.transfer(address(msg.sender), _amount);
        }
        user.withdrawnReward = user.amount * pool.accRewardPerShare / 1e12;
        emit Withdraw(msg.sender, _pid, _amount);
    }

    /// @notice Returns LP tokens to the user with the entire reward reset to zero
    function emergencyWithdraw(address _pairAddress) public {
        uint256 _pid = poolId[_pairAddress];
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        pool.pairToken.transfer(address(msg.sender), user.amount);
        emit EmergencyWithdraw(msg.sender, _pid, user.amount);
        user.amount = 0;
        user.withdrawnReward = 0;
        user.storedReward = 0;
    }

    /// @notice Try to harvest reward from the pool.
    /// @notice Will send a reward to the user if enough time has passed since the last harvest
    /// @param _pairAddress The address of LP token
    function harvest(address _pairAddress) public {
        uint256 _pid = poolId[_pairAddress];
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        uint256 pending = user.amount * pool.accRewardPerShare / 1e12 - user.withdrawnReward + user.storedReward;
        if (pending > 0) {
            rewardTransfer(user, pending, true, _pid);
        }
        user.withdrawnReward = user.amount * pool.accRewardPerShare / 1e12;
    }

    /// @notice Transfer reward with all checks
    /// @param user UserInfo storage pointer
    /// @param _amount Amount of reward to transfer
    /// @param isWithdraw Set to false if it called by deposit function
    /// @param _pid Pool index
    function rewardTransfer(UserInfo storage user, uint256 _amount, bool isWithdraw, uint256 _pid) internal {
        bool isCommissioning = block.timestamp - user.depositTimestamp < commissionInterval;
        bool isEarlyHarvest = block.timestamp - user.harvestTimestamp < harvestInterval;
        
        if (isEarlyHarvest) {
            user.storedReward = _amount;
        } else {
            uint amount = isWithdraw && isCommissioning
                ? _amount * (HUNDRED_PERCENTS - earlyHarvestCommission) / HUNDRED_PERCENTS
                : _amount;
            uint narfexLeft = getNarfexLeft();
            if (narfexLeft < amount) {
                amount = narfexLeft;
            }
            if (amount > 0) {
                rewardToken.transfer(msg.sender, amount);
                emit Harvest(msg.sender, _pid, amount);
                /// Send referral reward
                address referral = referrals[msg.sender];
                if (referral != address(0)) {
                    amount = amount * referralPercent / HUNDRED_PERCENTS;
                    narfexLeft = getNarfexLeft();
                    if (narfexLeft < amount) {
                        amount = narfexLeft;
                    }
                    if (amount > 0) {
                        rewardToken.transfer(referral, amount);
                    }
                }
            }
            user.storedReward = 0;
            user.harvestTimestamp = block.timestamp;
        }
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