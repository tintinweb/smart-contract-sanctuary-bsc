// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "./Ownable.sol";
import "./IERC20.sol";
import "./SafeERC20.sol";

import "./WayaToken.sol";
import "./GayaToken.sol";


// TaskMaster is the master of Waya. He can make Waya and only he can do this.
//
// Note that it's ownable and the owner wields tremendous power. The ownership
// will be transferred to a governance smart contract once WAYA is sufficiently
// distributed and the community can show to govern itself.
//
// Have fun reading it. Hopefully it's bug-free. God bless.

contract TaskMaster is Ownable {
    using SafeERC20 for IERC20;

    // Info of each user.
    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        //
        // We do some fancy math here. Basically, any point in time, the amount of WAYAs
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * pool.accWayaPerShare) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
        //   1. The pool's `accWayaPerShare` (and `lastRewardBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }

    // Info of each pool.
    struct PoolInfo {
        IERC20  lpToken; // Address of LP token contract.
        uint256 allocPoint; // How many allocation points assigned to this pool. WAYAs to distribute per block.
        uint256 lastRewardBlock; // Last block number that WAYAs distribution occurs.
        uint256 accWayaPerShare; // Accumulated WAYAs per share, times 1e12. See below.
    }

    // The WAYA TOKEN!
    WayaToken public waya;
    // The GAYA TOKEN!
    GayaToken public gaya;
    // Dev address.
    address public devaddr;
    // WAYA tokens created per block.
    uint256 public wayaPerBlock;
    // Bonus muliplier for early waya makers.
    uint256 public BONUS_MULTIPLIER = 1;

    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;
    // The block number when WAYA mining starts.
    uint256 public startBlock;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event WayaPerBlockUpdated (uint256 oldWayaPerBlock, uint256 newWayaPerBlock);
    event BonusMultiplierUpdate (uint256 oldMultiplierNumber, uint256 newMultiplierNumber);

    constructor(
        WayaToken _waya,
        GayaToken _gaya,
        address _devaddr,
        uint256 _wayaPerBlock,
        uint256 _startBlock
    ) {
        waya = _waya;
        gaya = _gaya;
        devaddr = _devaddr;
        wayaPerBlock = _wayaPerBlock * (1e18);
        startBlock = _startBlock;

        // staking pool
        poolInfo.push(PoolInfo({lpToken: _waya, allocPoint: 1000, lastRewardBlock: startBlock, accWayaPerShare: 0}));

        totalAllocPoint = 1000;
    }

    function updateWayaPerBlock(uint256 _newWayaPerBlock) public onlyOwner {
        uint256 _oldWayaPerBlock = wayaPerBlock;
        wayaPerBlock = _newWayaPerBlock * (1e18);
        emit WayaPerBlockUpdated(_oldWayaPerBlock, _newWayaPerBlock);
    }

    function updateMultiplier(uint256 _newMultiplierNumber) public onlyOwner {
        uint256 _oldMultiplierNumber = BONUS_MULTIPLIER;
        BONUS_MULTIPLIER = _newMultiplierNumber;
        emit BonusMultiplierUpdate(_oldMultiplierNumber, _newMultiplierNumber);
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    // Add a new lp to the pool. Can only be called by the owner.
    // IMPORTANT: DO NOT add the same LP token more than once. Rewards will be messed up if you do.
    function addPool(
        uint256 _allocPoint,
        IERC20 _lpToken,
        bool _withUpdate
    ) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint + _allocPoint;
        poolInfo.push(
            PoolInfo({lpToken: _lpToken, allocPoint: _allocPoint, lastRewardBlock: lastRewardBlock, accWayaPerShare: 0})
        );
        updateStakingPool();
    }

    // Update the given pool's WAYA allocation point. Can only be called by the owner.
    function updateAllocPoint(
        uint256 _pid,
        uint256 _allocPoint,
        bool _withUpdate
    ) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 prevAllocPoint = poolInfo[_pid].allocPoint;
        poolInfo[_pid].allocPoint = _allocPoint;
        if (prevAllocPoint != _allocPoint) {
            totalAllocPoint = totalAllocPoint - prevAllocPoint + _allocPoint;
            updateStakingPool();
        }
    }

    function updateStakingPool() internal {
        uint256 length = poolInfo.length;
        uint256 points = 0;
        for (uint256 pid = 1; pid < length; ++pid) {
            points = points + poolInfo[pid].allocPoint;
        }
        if (points != 0) {
            points = points / 3;
            totalAllocPoint = totalAllocPoint - poolInfo[0].allocPoint + points;
            poolInfo[0].allocPoint = points;
        }
    }


    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to) public view returns (uint256) {
        return (_to - _from) * BONUS_MULTIPLIER;
    }

    // View function to see pending WAYAs on frontend.
    function pendingWaya(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accWayaPerShare = pool.accWayaPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 wayaReward = (multiplier * wayaPerBlock * pool.allocPoint) / totalAllocPoint;
            accWayaPerShare = accWayaPerShare + ( (wayaReward *(1e12)) / lpSupply);
        }
        return ( (user.amount * accWayaPerShare) / (1e12) ) - user.rewardDebt;
    }

    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 wayaReward = (multiplier * wayaPerBlock * pool.allocPoint) / totalAllocPoint;
        waya.mint(devaddr, wayaReward / 10);
        waya.mint(address(gaya), wayaReward);
        pool.accWayaPerShare = pool.accWayaPerShare + ((wayaReward * (1e12)) / lpSupply);
        pool.lastRewardBlock = block.number;
    }

    // Deposit LP tokens to TaskMaster for WAYA allocation.
    function deposit(uint256 _pid, uint256 _amount) public {
        require(_pid != 0, "deposit WAYA by staking");

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = ((user.amount * pool.accWayaPerShare) / (1e12) ) - user.rewardDebt;
            if (pending > 0) {
                safeWayaTransfer(msg.sender, pending);
            }
        }
        if (_amount > 0) {
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            user.amount = user.amount + _amount;
        }
        user.rewardDebt = (user.amount * pool.accWayaPerShare) / (1e12);
        emit Deposit(msg.sender, _pid, _amount);
    }

    // Withdraw LP tokens from TaskMaster.
    function withdraw(uint256 _pid, uint256 _amount) public {
        require(_pid != 0, "withdraw WAYA by unstaking");
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");

        updatePool(_pid);
        uint256 pending = (user.amount * pool.accWayaPerShare / (1e12)) - user.rewardDebt;
        if (pending > 0) {
            safeWayaTransfer(msg.sender, pending);
        }
        if (_amount > 0) {
            user.amount = user.amount - _amount;
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
        }
        user.rewardDebt = (user.amount * pool.accWayaPerShare) / (1e12);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    // Stake WAYA tokens to TaskMaster
    function enterStaking(uint256 _amount) public {
        PoolInfo storage pool = poolInfo[0];
        UserInfo storage user = userInfo[0][msg.sender];
        updatePool(0);
        if (user.amount > 0) {
            uint256 pending = (user.amount * pool.accWayaPerShare / (1e12)) - user.rewardDebt;
            if (pending > 0) {
                safeWayaTransfer(msg.sender, pending);
            }
        }
        if (_amount > 0) {
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            user.amount = user.amount + _amount;
        }
        user.rewardDebt = (user.amount * pool.accWayaPerShare) / (1e12);

        gaya.mint(msg.sender, _amount);
        emit Deposit(msg.sender, 0, _amount);
    }

    // Withdraw WAYA tokens from STAKING.
    function leaveStaking(uint256 _amount) public {
        PoolInfo storage pool = poolInfo[0];
        UserInfo storage user = userInfo[0][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(0);
        uint256 pending = ( (user.amount * pool.accWayaPerShare) / (1e12) ) - user.rewardDebt;
        if (pending > 0) {
            safeWayaTransfer(msg.sender, pending);
        }
        if (_amount > 0) {
            user.amount = user.amount - _amount;
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
        }
        user.rewardDebt = (user.amount * pool.accWayaPerShare) / (1e12);

        gaya.burn(msg.sender, _amount);
        emit Withdraw(msg.sender, 0, _amount);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        pool.lpToken.safeTransfer(address(msg.sender), user.amount);
        emit EmergencyWithdraw(msg.sender, _pid, user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
    }

    // Safe waya transfer function, just in case if rounding error causes pool to not have enough WAYAs.
    function safeWayaTransfer(address _to, uint256 _amount) internal {
        gaya.safeWayaTransfer(_to, _amount);
    }

    // Update dev address by the previous dev.
    function dev(address _devaddr) public {
        require(msg.sender == devaddr, "dev: wut?");
        devaddr = _devaddr;
    }
}