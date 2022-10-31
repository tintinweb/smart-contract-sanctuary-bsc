// SPDX-License-Identifier: MIT


pragma solidity 0.6.9;

import "./IERC20.sol";
import "./SafeMath.sol";
import "./Ownable.sol";

contract PancakeStaking is Ownable {
    using SafeMath for uint256;

    // Info of each user.
    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        //
        // We do some fancy math here. Basically, any point in time, the amount of IMOs
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * pool.accIMOPerShare) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
        //   1. The pool's `accIMOPerShare` (and `lastRewardBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }
    // Info of each pool.
    struct PoolInfo {
        IERC20 lpToken; // Address of LP token contract.
        uint256 allocPoint; // How many allocation points assigned to this pool. IMOs to distribute per block.
        uint256 lastRewardBlock; // Last block number that IMOs distribution occurs.
        uint256 accIMOPerShare; // Accumulated IMOs per share, times 1e12. See below.
    }
    // The IMO token
    IERC20 public imo;
    // IMO tokens distributed per block.
    uint256 public imoPerBlock;
    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    // Total allocation poitns. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;
    // The block number when IMO staking starts.
    uint256 public startBlock;
    // The block number when IMO staking ends.
    uint256 public endBlock;
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );

    constructor(
        IERC20 _imo,
        uint256 _imoPerBlock,
        uint256 _startBlock,
        uint256 _endBlock
    ) public {
        setOwnerInternal(msg.sender);
        imo = _imo;
        imoPerBlock = _imoPerBlock;
        startBlock = _startBlock;
        endBlock = _endBlock;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    // Add a new lp to the pool. Can only be called by the owner.
    // XXX DO NOT add the same LP token more than once. Rewards will be messed up if you do.
    function add(
        uint256 _allocPoint,
        IERC20 _lpToken,
        bool _withUpdate
    ) external onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock =
            block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(
            PoolInfo({
                lpToken: _lpToken,
                allocPoint: _allocPoint,
                lastRewardBlock: lastRewardBlock,
                accIMOPerShare: 0
            })
        );
    }

    // Update the given pool's IMO allocation point. Can only be called by the owner.
    function set(
        uint256 _pid,
        uint256 _allocPoint,
        bool _withUpdate
    ) external onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(
            _allocPoint
        );
        poolInfo[_pid].allocPoint = _allocPoint;
    }

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to)
        public
        view
        returns (uint256)
    {
        uint256 to = _to;
        if(to > endBlock) {
            to = endBlock;
        }

        if(_from >= to) {
            return 0;
        }

        return to.sub(_from);
    }

    // View function to see pending IMOs on frontend.
    function pendingIMO(uint256 _pid, address _user)
        external
        view
        returns (uint256)
    {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accIMOPerShare = pool.accIMOPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier =
                getMultiplier(pool.lastRewardBlock, block.number);
            uint256 imoReward =
                multiplier.mul(imoPerBlock).mul(pool.allocPoint).div(
                    totalAllocPoint
                );
            accIMOPerShare = accIMOPerShare.add(
                imoReward.mul(1e12).div(lpSupply)
            );
        }
        return user.amount.mul(accIMOPerShare).div(1e12).sub(user.rewardDebt);
    }

    // Update reward vairables for all pools. Be careful of gas spending!
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
        uint256 imoReward =
            multiplier.mul(imoPerBlock).mul(pool.allocPoint).div(
                totalAllocPoint
            );
        pool.accIMOPerShare = pool.accIMOPerShare.add(
            imoReward.mul(1e12).div(lpSupply)
        );
        pool.lastRewardBlock = block.number;
    }

    // Deposit LP tokens for IMO allocation.
    function deposit(uint256 _pid, uint256 _amount) external {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending =
                user.amount.mul(pool.accIMOPerShare).div(1e12).sub(
                    user.rewardDebt
                );
            safeIMOTransfer(msg.sender, pending);
        }
        require(pool.lpToken.transferFrom(msg.sender, address(this), _amount), "lp transfer");
        user.amount = user.amount.add(_amount);
        user.rewardDebt = user.amount.mul(pool.accIMOPerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount);
    }

    // Withdraw LP tokens.
    function withdraw(uint256 _pid, uint256 _amount) external {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        uint256 pending =
            user.amount.mul(pool.accIMOPerShare).div(1e12).sub(
                user.rewardDebt
            );
        safeIMOTransfer(msg.sender, pending);
        user.amount = user.amount.sub(_amount);
        user.rewardDebt = user.amount.mul(pool.accIMOPerShare).div(1e12);
        require(pool.lpToken.transfer(msg.sender, _amount), "lp-transfer");
        emit Withdraw(msg.sender, _pid, _amount);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) external {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(pool.lpToken.transfer(msg.sender, user.amount), "lp-transfer");
        emit EmergencyWithdraw(msg.sender, _pid, user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
    }

    function emergencyWithdrawIMO() external onlyOwner {
        require(imo.transfer(msg.sender, imo.balanceOf(address(this))), "imo-transfer");
    }

    function safeIMOTransfer(address _to, uint256 _amount) internal {
        uint256 imoBal = imo.balanceOf(address(this));
        if (_amount > imoBal) {
            require(imo.transfer(_to, imoBal), "imo-transfer");
        } else {
            require(imo.transfer(_to, _amount), "imo-transfer");
        }
    }
}