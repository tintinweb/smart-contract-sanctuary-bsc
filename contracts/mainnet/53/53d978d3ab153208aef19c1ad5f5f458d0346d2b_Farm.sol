// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./Ownable.sol";
import "./ReentrancyGuard.sol";
import "./SafeMath.sol";
import "./SafeERC20.sol";

contract Farm is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // Info of each user.
    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
    }

    // Info of each pool.
    struct PoolInfo {
        IERC20 lpToken; // Address of LP token contract.
        uint256 allocPoint; // How many allocation points assigned to this pool. Roselle to distribute per block.
        uint256 lastRewardBlock; // Last block number that Roselle distribution occurs.
        uint256 accRosellePerShare; // Accumulated Roselle per share, times 1e12. See below.
    }

    // The Roselle TOKEN!
    IERC20 public roselle;
    // DAO address
    address public daoaddr;
    // FON tokens created per block.
    uint256 public rosellePerBlock = 1e11;
    // Bonus muliplier for early roselle makers.
    uint256 public BONUS_MULTIPLIER = 4050925;

    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    // Duplicate pool check
    mapping(address => bool) public poolAdded;

    mapping(address => mapping(uint256 => uint256)) userTokens;
    // Total allocation poitns. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;
    // The block number when Roselle mining starts.
    uint256 public startBlock;
    uint256 public endBlock;
    bool public opened;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event UpdateMultiplier(uint256 multiplier);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );

    constructor(IERC20 _roselle, uint256 _startBlock) {
        roselle = _roselle;
        daoaddr = _msgSender();
        startBlock = _startBlock;
        endBlock = _startBlock + 5184000; // 86400 / 3 * 180
    }

    modifier validatePoolByPid(uint256 _pid) {
        require(_pid < poolInfo.length, "Pool does not exist");
        _;
    }

    function updateMultiplier(uint256 multiplierNumber) public onlyOwner {
        massUpdatePools();
        BONUS_MULTIPLIER = multiplierNumber;
        emit UpdateMultiplier(multiplierNumber);
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
    ) public onlyOwner {
        require(!poolAdded[address(_lpToken)], "duplicate poll");
        poolAdded[address(_lpToken)] = true;
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock
            ? block.number
            : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(
            PoolInfo({
                lpToken: _lpToken,
                allocPoint: _allocPoint,
                lastRewardBlock: lastRewardBlock,
                accRosellePerShare: 0
            })
        );
    }

    // Update the given pool's Roselle allocation point. Can only be called by the owner.
    function set(
        uint256 _pid,
        uint256 _allocPoint,
        bool _withUpdate
    ) public validatePoolByPid(_pid) {
        require(
            owner() == _msgSender() || daoaddr == _msgSender(),
            "Ownable: caller is not the owner"
        );
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
        if (_to > endBlock) _to = endBlock;
        if (_from > _to) return 0;
        return _to.sub(_from).mul(BONUS_MULTIPLIER);
    }

    // View function to see pending Roselle on frontend.
    function pendingRoselle(uint256 _pid, address _user)
        external
        view
        validatePoolByPid(_pid)
        returns (uint256)
    {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accRosellePerShare = pool.accRosellePerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(
                pool.lastRewardBlock,
                block.number
            );
            uint256 roselleReward = multiplier
                .mul(rosellePerBlock)
                .mul(pool.allocPoint)
                .div(totalAllocPoint)
                .mul(85)
                .div(100);
            accRosellePerShare = accRosellePerShare.add(
                roselleReward.mul(1e12).div(lpSupply)
            );
        }
        return
            user.amount.mul(accRosellePerShare).div(1e12).sub(user.rewardDebt);
    }

    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) public validatePoolByPid(_pid) {
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
        uint256 roselleReward = multiplier
            .mul(rosellePerBlock)
            .mul(pool.allocPoint)
            .div(totalAllocPoint);
        pool.accRosellePerShare = pool.accRosellePerShare.add(
            roselleReward.mul(1e12).div(lpSupply)
        );
        pool.lastRewardBlock = block.number;
    }

    // Deposit LP tokens to Farm for Roselle allocation.
    function deposit(uint256 _pid, uint256 _amount)
        public
        validatePoolByPid(_pid)
        nonReentrant
    {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user
                .amount
                .mul(pool.accRosellePerShare)
                .div(1e12)
                .sub(user.rewardDebt);
            if (pending > 0) {
                userTokens[msg.sender][_pid] += pending;
            }
        }
        if (_amount > 0) {
            pool.lpToken.safeTransferFrom(
                address(msg.sender),
                address(this),
                _amount
            );
            user.amount = user.amount.add(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.accRosellePerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount);
    }

    // Withdraw LP tokens from Farm.
    function withdraw(uint256 _pid, uint256 _amount)
        public
        validatePoolByPid(_pid)
        nonReentrant
    {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        uint256 pending = user
            .amount
            .mul(pool.accRosellePerShare)
            .div(1e12)
            .sub(user.rewardDebt);
        if (pending > 0) {
            userTokens[msg.sender][_pid] += pending;
        }
        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
        }
        user.rewardDebt = user.amount.mul(pool.accRosellePerShare).div(1e12);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid)
        public
        validatePoolByPid(_pid)
        nonReentrant
    {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        pool.lpToken.safeTransfer(address(msg.sender), user.amount);
        emit EmergencyWithdraw(msg.sender, _pid, user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
    }

    // Safe roselle transfer function, just in case if rounding error causes pool to not have enough Roselle.
    function safeRoselleTransfer(address _to, uint256 _amount) internal {
        roselle.safeTransfer(_to, _amount);
    }

    // Update dao address by the previous dao.
    function dao(address _daoaddr) public {
        require(msg.sender == daoaddr, "dao: wut?");
        daoaddr = _daoaddr;
    }

    function open() external onlyOwner {
        require(!opened, "opened");
        opened = true;
    }

    function takeToken(uint256 _pid) external validatePoolByPid(_pid) {
        require(opened, "closed");
        safeRoselleTransfer(msg.sender, userTokens[msg.sender][_pid]);
        userTokens[msg.sender][_pid] = 0;
    }
}