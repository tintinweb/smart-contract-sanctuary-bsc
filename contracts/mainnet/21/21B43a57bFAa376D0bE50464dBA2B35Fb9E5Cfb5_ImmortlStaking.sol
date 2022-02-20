// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import "./Ownable.sol";
import "./SafeERC20.sol";
import "./EnumerableSet.sol";

contract ImmortlStaking is Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
        uint256 vestingStartTime;
    }

    struct PoolInfo {
        IERC20 stakingToken;        // Address of deposit token contract.
        uint256 allocPoint;         // How many allocation points assigned to this pool.
        uint256 lastRewardBlock;    // Last block number that reward distribution occurred.
        uint256 accTokenPerShare;   // Accumulated token per share, times 1e12.
        uint256 totalStakedAmount;  // Total token in pool.
        uint256 vestingPeriod;      // Vesting period for staked tokens.
    }

    PoolInfo[] public poolInfo;
    mapping(uint256 => EnumerableSet.AddressSet) poolUsers;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    mapping(uint256 => mapping(address => uint256)) public failedRewardsCache;
    IERC20 public constant IMRTL = IERC20(0x170DC35C5B58AEdEdC81960691eb4b389Eba9E95);

    uint256 public bonusMultiplier = 1;
    uint256 public tokenPerBlock;
    uint256 public totalAllocPoint;
    uint256 public startBlock;
    uint256 public totalTokensInPools;
    bool isIgnoringVesting;

    event StartStaking(uint256 timestamp);
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyRewardWithdraw(uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event UpdatePoolAlloc(uint256 indexed pid, uint256 previous, uint256 newValue);
    event UpdateRewardRate(uint256 previous, uint256 newValue);
    event AddPool(address token, uint256 allocPoint, uint256 vesting);
    event UpdateMultiplier(uint256 previous, uint256 newValue);

    modifier ignoreVesting() {
        isIgnoringVesting = true;
        _;
        isIgnoringVesting = false;
    }

    constructor() {
        // Set value in the future because start will be triggered manually by calling startStaking().
        startBlock = block.number + 28800 * 365;
        tokenPerBlock = 1 * 10**18;
    }

    // Public

    function remainingRewards() external view returns (uint256) {
        return IMRTL.balanceOf(address(this)) - totalTokensInPools;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    function userCountAtPool(uint256 _pid) external view returns (uint256) {
        return poolUsers[_pid].length();
    }

    function userAddress(uint256 _pid, uint256 _index) external view returns (address) {
        return poolUsers[_pid].at(_index);
    }

    function getMultiplier(uint256 _from, uint256 _to) public view returns (uint256) {
        return (_to - _from) * bonusMultiplier;
    }

    function pendingRewards(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];

        uint256 accTokenPerShare = pool.accTokenPerShare;
        uint256 tokenSupply = pool.totalStakedAmount;
        uint256 lastRewardBlock = pool.lastRewardBlock;

        if (block.number > lastRewardBlock && tokenSupply != 0) {
            uint256 multiplier = getMultiplier(lastRewardBlock, block.number);
            uint256 reward = multiplier * tokenPerBlock * pool.allocPoint / totalAllocPoint;
            accTokenPerShare += reward * 1e12 / tokenSupply;
        }

        return user.amount * accTokenPerShare / 1e12 - user.rewardDebt + failedRewardsCache[_pid][_user];
    }

    function massUpdatePools() public {
        uint256 length = poolInfo.length;

        for (uint256 pid = 0; pid < length; ++pid) {
            PoolInfo storage pool = poolInfo[pid];
            if (block.number <= pool.lastRewardBlock) {
                continue;
            }

            if (pool.totalStakedAmount == 0 || pool.allocPoint == 0) {
                pool.lastRewardBlock = block.number;
                continue;
            }

            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 reward = multiplier * tokenPerBlock * pool.allocPoint / totalAllocPoint;

            pool.accTokenPerShare += reward * 1e12 / pool.totalStakedAmount;
            pool.lastRewardBlock = block.number;
        }
    }

    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }

        if (pool.totalStakedAmount == 0 || pool.allocPoint == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }

        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 reward = multiplier * tokenPerBlock * pool.allocPoint / totalAllocPoint;

        pool.accTokenPerShare += reward * 1e12 / pool.totalStakedAmount;
        pool.lastRewardBlock = block.number;
    }

    function compound(uint256 _pid) external ignoreVesting {
        PoolInfo storage pool = poolInfo[_pid];
        require(pool.stakingToken == IMRTL, "Can compound only IMRTL");

        uint256 userBalanceBefore = pool.stakingToken.balanceOf(msg.sender);
        withdraw(_pid, 0);
        uint256 claimed = pool.stakingToken.balanceOf(msg.sender) - userBalanceBefore;
        deposit(_pid, claimed);
    }

    function deposit(uint256 _pid, uint256 _amount) public {
        require(block.number >= startBlock, "Can not deposit before farm start");

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        updatePool(_pid);

        if (user.amount > 0) {
            uint256 failedRewards = failedRewardsCache[_pid][msg.sender];
            uint256 pending = user.amount * pool.accTokenPerShare / 1e12 - user.rewardDebt + failedRewards;
            if(pending > 0) {
                safeTokenTransfer(_pid, msg.sender, pending);
            }
        } else if (_amount > 0) {
            poolUsers[_pid].add(msg.sender);
        }

        if (_amount > 0) {
            user.amount += _amount;
            pool.totalStakedAmount += _amount;

            if (!isIgnoringVesting) {
                user.vestingStartTime = block.timestamp;
            }
            if (address(pool.stakingToken) == address(IMRTL)) {
                totalTokensInPools += _amount;
            }

            pool.stakingToken.safeTransferFrom(msg.sender, address(this), _amount);
        }

        user.rewardDebt = user.amount * pool.accTokenPerShare / 1e12;
        emit Deposit(msg.sender, _pid, _amount);
    }

    function withdraw(uint256 _pid, uint256 _amount) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "User amount not enough");

        updatePool(_pid);

        uint256 failedRewards = failedRewardsCache[_pid][msg.sender];
        uint256 pending = user.amount * pool.accTokenPerShare / 1e12 - user.rewardDebt + failedRewards;
        if(pending > 0) {
            safeTokenTransfer(_pid, msg.sender, pending);
        }

        if (_amount > 0) {
            require(block.timestamp - user.vestingStartTime >= pool.vestingPeriod, "Tokens are vested");

            user.amount -= _amount;
            pool.totalStakedAmount -= _amount;

            if (address(pool.stakingToken) == address(IMRTL)) {
                totalTokensInPools -= _amount;
            }
            if (user.amount == 0) {
                poolUsers[_pid].remove(msg.sender);
            }

            pool.stakingToken.safeTransfer(msg.sender, _amount);
        }

        user.rewardDebt = user.amount * pool.accTokenPerShare / 1e12;
        emit Withdraw(msg.sender, _pid, _amount);
    }

    function emergencyWithdraw(uint256 _pid) external {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        uint256 amount = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;
        pool.totalStakedAmount -= amount;

        if (address(pool.stakingToken) == address(IMRTL)) {
            totalTokensInPools -= amount;
        }
        if (block.timestamp - user.vestingStartTime < pool.vestingPeriod && pool.allocPoint > 0) {
            amount = amount * 85 / 100;
        }

        pool.stakingToken.safeTransfer(msg.sender, amount);

        emit EmergencyWithdraw(msg.sender, _pid, amount);
    }

    // Private

    function safeTokenTransfer(uint256 _pid, address _to, uint256 _amount) private {
        uint256 balance = IMRTL.balanceOf(address(this));
        if (balance > totalTokensInPools) {
            uint256 rewardBalance = balance - totalTokensInPools;
            if (_amount >= rewardBalance) {
                failedRewardsCache[_pid][_to] = _amount - rewardBalance;
                IMRTL.transfer(_to, rewardBalance);
            } else if (_amount > 0) {
                failedRewardsCache[_pid][_to] = 0;
                IMRTL.transfer(_to, _amount);
            }
        } else {
            failedRewardsCache[_pid][_to] = _amount;
        }
    }

    // Maintenance

    function emergencyRewardWithdraw() external onlyOwner {
        uint256 rewardAmount = IMRTL.balanceOf(address(this)) - totalTokensInPools;
        IMRTL.transfer(msg.sender, rewardAmount);
        emit EmergencyRewardWithdraw(rewardAmount);
    }

    function startStaking() external onlyOwner {
        require(block.number < startBlock, "Farm started already");

        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            PoolInfo storage pool = poolInfo[pid];
            pool.lastRewardBlock = block.number;
        }

        startBlock = block.number;
        emit StartStaking(startBlock);
    }

    function addPool(
        IERC20 _stakingToken,
        uint256 _allocPoint,
        uint256 _vestingPeriod,
        bool _withUpdate
    ) external onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint += _allocPoint;
        poolInfo.push(
            PoolInfo({
                stakingToken: _stakingToken,
                allocPoint: _allocPoint,
                lastRewardBlock: lastRewardBlock,
                accTokenPerShare: 0,
                totalStakedAmount: 0,
                vestingPeriod: _vestingPeriod
            })
        );

        emit AddPool(address(_stakingToken), _allocPoint, _vestingPeriod);
    }

    function updatePool(uint256 _pid, uint256 _allocPoint, bool _withUpdate) external onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint - poolInfo[_pid].allocPoint + _allocPoint;
        emit UpdatePoolAlloc(_pid, poolInfo[_pid].allocPoint, _allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;
    }

    function setMultiplier(uint256 _multiplier) external onlyOwner {
        emit UpdateMultiplier(bonusMultiplier, _multiplier);
        bonusMultiplier = _multiplier;
    }

    function updateRewardRate(uint256 _tokenPerBlock) external onlyOwner {
        massUpdatePools();
        emit UpdateRewardRate(tokenPerBlock, _tokenPerBlock);
        tokenPerBlock = _tokenPerBlock;
    }
}