/**
 *Submitted for verification at BscScan.com on 2022-09-23
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

library TransferHelper {
    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0xa9059cbb, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FAILED"
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x23b872dd, from, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FROM_FAILED"
        );
    }
}

interface StakeInfo {
    // 每个用户的信息。
    struct UserInfo {
        uint256 stakedOf; // 用户提供了多少 LP 代币。
        uint256 rewardOf; // 用户已经获取的奖励
        uint256 duration; //质押周期
        uint256 lastDepositAt; //最后质押时间
        uint256 lastRewardAt; //最后领奖时间
        uint256 userReward; //用户奖励
    }

    // 每个池的信息。
    struct PoolInfo {
        uint256 totalStaked; // 总股份
        address lpToken; // LP 代币合约地址。
        uint256 allocPoint; // 分配给此池的分配点数。
        uint256 accPerShare; // 质押一个LPToken的全局收益
    }
}

contract LiteStaking is StakeInfo {
    address public immutable tokenAddress; // token合约地址
    address public owner; // 合约所有者

    uint256 public bounsDay = 20; //20 d
    uint256 public constant bounsDuration = 86400; // 奖励周期 86400
    uint256 public constant unstakeDuration = 86400; // 解压周期 86400
    uint256 public autoDelay = 3 * bounsDuration; // 过期3个分红周期(3d),自动延期

    bool public isStaking = true; // 是否开启质押
    bool public isBonus = false; // 是否开启奖励
    uint256 public totalAllocPoint = 0; // 总分配点数。 必须是所有池中所有分配点的总和。
    uint256[] public pools; //所有池
    mapping(uint256 => PoolInfo) public poolInfo; //质押池详情
    mapping(uint256 => mapping(address => UserInfo)) public userInfo; // 用户信息 deposit_duration=>user=>user

    uint256 public totalStaked; //总质押量
    uint256 public totalReward; //总奖励
    uint256 public totalUsedReward; //总分红奖励
    uint256 public totalPendingReward; //总分红待领奖励
    uint256 public lastBounsEpoch; //上一次分红时间
    uint256 public lastBounsToken; //待分红的USD

    constructor(address token_) {
        tokenAddress = token_;
        owner = msg.sender;

        _addPool(604800, 10); //7d 604800
        _addPool(2592000, 20); //30d 2592000
        _addPool(5184000, 40); //60d 5184000
        _addPool(7776000, 80); //90d 7776000
    }

    // 质押事件
    event Staked(address indexed from, uint256 _duration, uint256 amount);
    // 取消质押事件
    event Unstaked(address indexed to, uint256 _duration, uint256 amount);
    // 领取奖励事件
    event Reward(address indexed to, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "caller is not the owner");
        _;
    }

    function setOwner(address newOwner) external onlyOwner {
        owner = newOwner;
    }

    function setBounsDay(uint256 day) external onlyOwner {
        bounsDay = day;
    }

    function setStaking(bool _isStaking) external onlyOwner {
        isStaking = _isStaking;
    }

    function setIsBonus(bool value) external onlyOwner {
        isBonus = value;
    }

    function setAutoDelay(uint256 value) external onlyOwner {
        autoDelay = value;
    }

    function poolLength() external view returns (uint256) {
        return pools.length;
    }

    function getPool(uint256 index)
        external
        view
        returns (PoolInfo memory _pool)
    {
        return poolInfo[pools[index]];
    }

    function withdrawToken(
        address token_,
        address to_,
        uint256 amount_
    ) external onlyOwner {
        TransferHelper.safeTransfer(token_, to_, amount_);
    }

    // 添加新的周期池
    function addPool(uint256 _duration, uint256 _allocPoint) public onlyOwner {
        _addPool(_duration, _allocPoint);
    }

    function _addPool(uint256 _duration, uint256 _allocPoint) private {
        require(poolInfo[_duration].lpToken == address(0), "duration is exist"); //避免重复添加池
        totalAllocPoint += _allocPoint;
        pools.push(_duration);
        poolInfo[_duration] = PoolInfo({
            totalStaked: 0,
            lpToken: tokenAddress,
            allocPoint: _allocPoint,
            accPerShare: 0
        });
    }

    // 更新周期分红权重
    function setPool(uint256 _duration, uint256 _allocPoint) public onlyOwner {
        require(
            poolInfo[_duration].lpToken != address(0),
            "duration is not exist"
        );
        totalAllocPoint =
            totalAllocPoint -
            poolInfo[_duration].allocPoint +
            _allocPoint;
        poolInfo[_duration].allocPoint = _allocPoint;
    }

    //存入奖励
    function depositReward(uint256 amount_) external {
        TransferHelper.safeTransferFrom(
            tokenAddress,
            msg.sender,
            address(this),
            amount_
        );
        totalReward += amount_;
    }

    // 获取下一次待分红的奖励
    function getPendingReward() public view returns (uint256) {
        return (totalReward - totalUsedReward) / bounsDay;
    }

    // 更新分红奖励
    function bonusReward() external {
        require(isBonus, "isBonus status error");
        require(totalAllocPoint > 0, "No pool");
        uint256 _epoch_day = block.timestamp / bounsDuration;
        require(_epoch_day > lastBounsEpoch, "Error: lastBounsEpoch");

        _bonusReward();
    }

    function _bonusReward() private {
        if (isBonus && totalAllocPoint > 0) {
            uint256 _epoch_day = block.timestamp / bounsDuration;
            if (_epoch_day > lastBounsEpoch) {
                lastBounsEpoch = _epoch_day;
                lastBounsToken = getPendingReward(); //本次可分红数量

                for (uint256 pid = 0; pid < pools.length; ++pid) {
                    _updatePool(pools[pid]);
                }
            }
        }
    }

    function _updatePool(uint256 _duration) private {
        if (
            poolInfo[_duration].allocPoint > 0 &&
            poolInfo[_duration].totalStaked > 0 &&
            lastBounsToken > 0
        ) {
            uint256 _reward = (lastBounsToken *
                poolInfo[_duration].allocPoint) / totalAllocPoint;

            poolInfo[_duration].accPerShare +=
                (_reward * 1e12) /
                poolInfo[_duration].totalStaked;

            //记录总分红
            totalUsedReward += _reward;
            totalPendingReward += _reward;
        }
    }

    // 质押
    function stake(uint256 _duration, uint256 amount) external returns (bool) {
        require(isStaking, "isStaking status error");
        require(amount > 0, "stake must be integer multiple of 1 USD.");
        require(poolInfo[_duration].allocPoint > 0, "duration is not exist");

        _bonusReward(); //更新分红奖励
        UserInfo storage user = userInfo[_duration][msg.sender];
        if (user.stakedOf > 0) {
            // 领取之前的奖励
            uint256 pending = rewardAmount(msg.sender, _duration);
            _takeReward(_duration, msg.sender, pending);
        }

        //转入质押
        TransferHelper.safeTransferFrom(
            tokenAddress,
            msg.sender,
            address(this),
            amount
        );

        user.duration = _duration;
        user.lastDepositAt = block.timestamp;
        // 更新用户质押的数量
        user.stakedOf += amount;
        // 更新已经领取的奖励
        user.rewardOf =
            (user.stakedOf * poolInfo[_duration].accPerShare) /
            1e12;
        // 更新池子总票数
        poolInfo[_duration].totalStaked += amount;
        totalStaked += amount;

        // emit event
        emit Staked(msg.sender, _duration, amount);

        return true;
    }

    /**
     * 提取质押物
     */
    function unstake(uint256 _duration, uint256 _amount)
        external
        virtual
        returns (bool)
    {
        _bonusReward(); //更新分红奖励

        UserInfo storage user = userInfo[_duration][msg.sender];
        require(user.stakedOf >= _amount, "Staking: out of staked");
        require(_amount > 0, "votes must be gt 0.");

        // 领取之前的奖励
        uint256 pending = rewardAmount(msg.sender, _duration);
        _takeReward(_duration, msg.sender, pending);

        require(
            block.timestamp - user.lastDepositAt >= user.duration,
            "Error: User Duration"
        ); // 定期
        require(
            block.timestamp - user.lastDepositAt >= unstakeDuration,
            "Error: User Unstake Duration"
        ); //活期

        _unstake(_duration, _amount);
        return true;
    }

    function _unstake(uint256 _duration, uint256 _amount) private {
        if (_amount > 0) {
            UserInfo storage user = userInfo[_duration][msg.sender];
            if (_amount > user.stakedOf) {
                _amount = user.stakedOf;
            }

            totalStaked -= _amount;
            poolInfo[_duration].totalStaked -= _amount;
            // 更新用户质押的数量
            user.stakedOf -= _amount;
            // 更新已经领取的奖励
            user.rewardOf =
                (user.stakedOf * poolInfo[_duration].accPerShare) /
                1e12;

            TransferHelper.safeTransfer(tokenAddress, msg.sender, _amount);

            emit Unstaked(msg.sender, _duration, _amount);
        }
    }

    function rewardAmount(address _account, uint256 _duration)
        public
        view
        returns (uint256)
    {
        uint256 pending;
        UserInfo memory _user = userInfo[_duration][_account];
        if (_user.stakedOf > 0) {
            uint256 _accPerShare = poolInfo[_duration].accPerShare;
            uint256 _epoch_day = block.timestamp / bounsDuration;
            if (
                _epoch_day > lastBounsEpoch &&
                poolInfo[_duration].allocPoint > 0
            ) {
                uint256 _reward = (getPendingReward() *
                    poolInfo[_duration].allocPoint) / totalAllocPoint;
                _accPerShare +=
                    (_reward * 1e12) /
                    poolInfo[_duration].totalStaked;
            }
            pending = ((_user.stakedOf * _accPerShare) / 1e12) - _user.rewardOf;
        }

        return pending;
    }

    function predictReward(address _account, uint256 _duration)
        external
        view
        returns (uint256)
    {
        uint256 pending;
        UserInfo memory _user = userInfo[_duration][_account];
        if (_user.stakedOf > 0) {
            uint256 _accPerShare = poolInfo[_duration].accPerShare;
            if (poolInfo[_duration].allocPoint > 0) {
                _accPerShare +=
                    (getPendingReward() * 1e12) /
                    poolInfo[_duration].totalStaked;
            }
            pending = ((_user.stakedOf * _accPerShare) / 1e12) - _user.rewardOf;
        }
        return pending;
    }

    function _takeReward(
        uint256 _duration,
        address _account,
        uint256 pending
    ) private {
        if (pending > 0) {
            UserInfo storage user = userInfo[_duration][_account];

            uint256 userDepositDuration = user.lastDepositAt + user.duration;
            // 超期了
            if (block.timestamp > userDepositDuration) {
                //自动延期
                if (block.timestamp - userDepositDuration > autoDelay) {
                    user.lastDepositAt = block.timestamp;
                }
            }

            user.rewardOf =
                (user.stakedOf * poolInfo[_duration].accPerShare) /
                1e12;
            safeTransfer(_duration, _account, pending);
        }
    }

    // 直接领取收益
    function takeReward(uint256 _duration) external {
        _bonusReward(); //更新分红奖励

        UserInfo storage user = userInfo[_duration][msg.sender];
        require(user.stakedOf > 0, "Staking: out of staked");
        uint256 pending = rewardAmount(msg.sender, _duration);
        require(pending > 0, "Staking: no pending reward");

        _takeReward(_duration, msg.sender, pending);
        if (
            user.duration > 0 &&
            (block.timestamp - user.lastDepositAt >= user.duration)
        ) {
            _unstake(_duration, user.stakedOf);
        }
    }

    // 安全的转账功能，以防万一如果舍入错误导致池没有足够的奖励。
    function safeTransfer(
        uint256 _duration,
        address _account,
        uint256 _amount
    ) private {
        if (_amount > 0) {
            if (_amount > totalPendingReward) {
                _amount = totalPendingReward;
            }

            UserInfo storage user = userInfo[_duration][_account];
            totalPendingReward -= _amount;
            user.userReward += _amount;
            TransferHelper.safeTransfer(tokenAddress, _account, _amount);
            emit Reward(_account, _amount);
        }
    }
}