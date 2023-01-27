// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import './SafeMath.sol';
import './IERC20.sol';
import './SafeERC20.sol';
import './Ownable.sol';

interface IMigratorChef {
    function migrate(IERC20 token) external returns (IERC20);
}

// Craftsman is the master of VVS. He can make VVS and he is a fair guy.
//
// Note that it's ownable and the owner wields tremendous power. The ownership
// will be transferred to a governance smart contract once VVS is sufficiently
// distributed and the community can show to govern itself.
//
// Have fun reading it. Hopefully it's bug-free. God bless.
contract GwinkFarm is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // Info of each user.
    struct UserInfo {
        uint256 amount;     // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        //
        // We do some fancy math here. Basically, any point in time, the amount of VVSs
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * pool.accVVSPerShare) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
        //   1. The pool's `accVVSPerShare` (and `lastRewardBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }

    // Info of each pool.
    struct PoolInfo {
        IERC20 lpToken;           // Address of LP token contract.
        uint256 allocPoint;       // How many allocation points assigned to this pool. VVSs to distribute per block.
        uint256 lastRewardBlock;  // Last block number that VVSs distribution occurs.
        uint256 accVVSPerShare; // Accumulated VVSs per share, times 1e12. See below.
    }

    // The VVS TOKEN!
    IERC20 public vvs;
    // Dev address.
    address public devaddr;
    // VVS tokens created per block.
    uint256 public vvsPerBlock;
    // Bonus multiplier for early vvs makers.
    uint256 public BONUS_MULTIPLIER = 1;
    // The migrator contract. It has a lot of power. Can only be set through governance (owner).
    IMigratorChef public migrator;

    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;
    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;
    // The block number when VVS mining starts.
    uint256 public startBlock;
    // The ratio of single-sided VVS pool against totalAllocPoint
    uint256 public vvsStakingRatio = 25;    //MAY BE USELESS

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event UpdatedVVSStakingRatio(uint256 newRatio);
    event UpdatedVVSPerBlock(uint256 newVssPerBlock);

    constructor(
        IERC20 _farmLockToken,
        IERC20 _vvs,
        address _devaddr,
        uint256 _vvsPerBlock//,
        //uint256 _startBlock
    ) {
        vvs = _vvs;
        devaddr = _devaddr;
        vvsPerBlock = _vvsPerBlock;   //SET WITH FUNCTION
        startBlock = block.number;

        // staking pool
        poolInfo.push(PoolInfo({
            lpToken: _farmLockToken,
            allocPoint: 1000,
            lastRewardBlock: startBlock,
            accVVSPerShare: 0
        }));

        totalAllocPoint = 1000;

    }

    function updateVVSPerBlock(uint256 _vvsPerBlock) public onlyOwner {
        massUpdatePools();
        vvsPerBlock = _vvsPerBlock;
        massUpdatePools();

        emit UpdatedVVSPerBlock(_vvsPerBlock);
    }

    function updateMultiplier(uint256 multiplierNumber) public onlyOwner {
        BONUS_MULTIPLIER = multiplierNumber;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    // Add a new lp to the pool. Can only be called by the owner.
    // XXX DO NOT add the same LP token more than once. Rewards will be messed up if you do.
    function add(uint256 _allocPoint, IERC20 _lpToken, bool _withUpdate) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(PoolInfo({
            lpToken: _lpToken,
            allocPoint: _allocPoint,
            lastRewardBlock: lastRewardBlock,
            accVVSPerShare: 0
        }));
        updateStakingPool();
    }

    // Update the given pool's VVS allocation point. Can only be called by the owner.
    function set(uint256 _pid, uint256 _allocPoint, bool _withUpdate) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 prevAllocPoint = poolInfo[_pid].allocPoint;
        poolInfo[_pid].allocPoint = _allocPoint;
        if (prevAllocPoint != _allocPoint) {
            totalAllocPoint = totalAllocPoint.sub(prevAllocPoint).add(_allocPoint);
            updateStakingPool();
        }
    }

    function updateStakingPool() internal {
        uint256 length = poolInfo.length;
        uint256 points = 0;
        for (uint256 pid = 1; pid < length; ++pid) {
            points = points.add(poolInfo[pid].allocPoint);
        }
        if (points != 0) {
            points = points.mul(vvsStakingRatio).div(100 - vvsStakingRatio);
            totalAllocPoint = totalAllocPoint.sub(poolInfo[0].allocPoint).add(points);
            poolInfo[0].allocPoint = points;
        }
    }

    // Set the migrator contract. Can only be called by the owner.
    function setMigrator(IMigratorChef _migrator) public onlyOwner {
        migrator = _migrator;
    }

    // Migrate lp token to another lp contract. Can be called by anyone. We trust that migrator contract is good.
    function migrate(uint256 _pid) public {
        require(address(migrator) != address(0), "migrate: no migrator");
        PoolInfo storage pool = poolInfo[_pid];
        IERC20 lpToken = pool.lpToken;
        uint256 bal = lpToken.balanceOf(address(this));
        lpToken.safeApprove(address(migrator), bal);
        IERC20 newLpToken = migrator.migrate(lpToken);
        require(bal == newLpToken.balanceOf(address(this)), "migrate: bad");
        pool.lpToken = newLpToken;
    }

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to) public view returns (uint256) {
        return _to.sub(_from).mul(BONUS_MULTIPLIER);
    }

    // View function to see pending VVSs on frontend.
    function pendingVVS(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accVVSPerShare = pool.accVVSPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 vvsReward = multiplier.mul(vvsPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
            accVVSPerShare = accVVSPerShare.add(vvsReward.mul(1e12).div(lpSupply));
        }
        return user.amount.mul(accVVSPerShare).div(1e12).sub(user.rewardDebt);
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
        uint256 vvsReward = multiplier.mul(vvsPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
        // vvs.mint(devaddr, vvsReward.div(10));
        //vvs.mint(address(bench), vvsReward);
        pool.accVVSPerShare = pool.accVVSPerShare.add(vvsReward.mul(1e12).div(lpSupply));
        pool.lastRewardBlock = block.number;
    }

    // Deposit LP tokens to Craftsman for VVS allocation.
    function deposit(uint256 _pid, uint256 _amount) public {

        //require (_pid != 0, 'deposit VVS by staking');

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accVVSPerShare).div(1e12).sub(user.rewardDebt);
            if(pending > 0) {
                safeVVSTransfer(msg.sender, pending);
            }
        }
        if (_amount > 0) {
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            user.amount = user.amount.add(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.accVVSPerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount);
    }

    // Withdraw LP tokens from Craftsman.
    function withdraw(uint256 _pid, uint256 _amount) public {

        //require (_pid != 0, 'withdraw VVS by unstaking');
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");

        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accVVSPerShare).div(1e12).sub(user.rewardDebt);
        if(pending > 0) {
            safeVVSTransfer(msg.sender, pending);
        }
        if(_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
        }
        user.rewardDebt = user.amount.mul(pool.accVVSPerShare).div(1e12);
        emit Withdraw(msg.sender, _pid, _amount);
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

    // Safe vvs transfer function, just in case if rounding error causes pool to not have enough VVSs.
    /*function safeVVSTransfer(address _to, uint256 _amount) internal {
        bench.safeVVSTransfer(_to, _amount);
    }*/

    //ADDED
    function safeVVSTransfer(address _to, uint256 _amount) internal {
        uint256 vvsBal = vvs.balanceOf(address(this));
        if (_amount > vvsBal) {
            vvs.transfer(_to, vvsBal);
        } else {
            vvs.transfer(_to, _amount);
        }
    }

    // Update dev address by the previous dev.
    function dev(address _devaddr) public {
        require(msg.sender == devaddr, "dev: wut?");
        devaddr = _devaddr;
    }

    /*function distributeSupply(
        address[] memory _teamAddresses,
        uint256[] memory _teamAmounts
    ) public onlyOwner {
        massUpdatePools();
        vvs.distributeSupply(_teamAddresses, _teamAmounts);
        vvsPerBlock = vvs.SUPPLY_PER_BLOCK();
    }*/

    function updateStakingRatio(
        uint256 _ratio
    ) public onlyOwner {
        require(_ratio <= 50, "updateStakingRatio: must be lte 50%");

        massUpdatePools();
        vvsStakingRatio = _ratio;
        updateStakingPool();

        emit UpdatedVVSStakingRatio(_ratio);
    }
}