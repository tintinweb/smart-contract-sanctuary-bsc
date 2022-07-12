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

interface IDepositUSD {
    function withdrawToken(
        address token_,
        address to_,
        uint256 amount_
    ) external;

    function stakeUsd(address account_, uint256 amount_) external;

    function unstakeUsd(address account_, uint256 amount_) external;

    function depositFee(uint256 amount_) external;

    function takeFee(address account_, uint256 amount_) external;

    function getFee() external view returns (uint256);

    function bonusFee(uint256 amount_) external;
}

interface IUSDReward {
    function inviteReward(address account, uint256 amount) external;
}

interface IUSD {
    function owner() external view returns (address);

    function stakeTo() external view returns (address);

    function rewardTo() external view returns (address);
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

interface IStaking is StakeInfo {
    function userInfo(address _account)
        external
        view
        returns (UserInfo memory _user);

    function totalStaked() external view returns (uint256);

    function totalReward() external view returns (uint256);

    function lastBounsEpoch() external view returns (uint256);

    function lastBounsToken() external view returns (uint256);

    function accRewardPerShare() external view returns (uint256);
}

contract UsdLpStaking is StakeInfo {
    address public immutable usdAddress; // USD合约地址
    address public immutable depositAddress; // 存款合约地址
    address public upgradeAddress; // 升级合约地址
    bool public isUpgrade = false; // 开启升级

    mapping(address => mapping(address => UserInfo)) _userInfo; // 用户信息 token=>user
    mapping(address => bool) public userUpgrade; // 用户升级状态
    uint256 public bounsRate = 50; // 奖励比例 50/ 1000 //每次发放当前手续费余额的20分之一
    uint256 public constant bounsDuration = 300; // 奖励周期 86400
    uint256 public constant unstakeDuration = 900; // 解压周期 86400

    bool public isBonus = false;
    uint256 public totalAllocPoint = 0; // 总分配点数。 必须是所有池中所有分配点的总和。
    address[] public pools; //所有池
    mapping(address => PoolInfo) public poolInfo; //质押池详情

    uint256 public totalReward; //总奖励
    uint256 public lastBounsEpoch; //上一次分红时间
    uint256 public lastBounsToken; //待分红的USD

    uint256 public constant DEPOSIT_DURATION_1 = 2592000; //30d 2592000
    uint256 public constant DEPOSIT_DURATION_2 = 5184000; //60d 5184000
    uint256 public constant DEPOSIT_DURATION_3 = 7776000; //90d 7776000

    constructor(
        address usd_,
        address deposit_,
        bool isUpgrade_
    ) {
        usdAddress = usd_;
        depositAddress = deposit_;
        isUpgrade = isUpgrade_; // 开启升级 ture 在合约初始化前不可操作
        _addPool(usdAddress, 100);
    }

    // 质押事件
    event Staked(address indexed from, address token, uint256 amount);
    // 取消质押事件
    event Unstaked(address indexed from, address token, uint256 amount);
    // 领取奖励事件
    event Reward(address indexed to, uint256 amount);

    modifier onlyOwner() {
        require(
            msg.sender == IUSD(usdAddress).owner(),
            "caller is not the owner"
        );
        _;
    }

    // 设置升级合约
    function setUpgradeAddress(address addr) external onlyOwner {
        require(addr != address(0), "address is zero");
        upgradeAddress = addr;
        isUpgrade = true;
    }

    // 升级合约初始化 继承数据-需在升级合约地址生效后调用此方法
    function initUpgrade() external onlyOwner {
        require(isUpgrade, "not upgrade");
        require(upgradeAddress != address(0), "address is zero");
        require(IUSD(usdAddress).stakeTo() == address(this), "upgrade not end");
        poolInfo[usdAddress].totalStaked = IStaking(upgradeAddress)
            .totalStaked();
        totalReward = IStaking(upgradeAddress).totalReward();
        lastBounsEpoch = IStaking(upgradeAddress).lastBounsEpoch();
        lastBounsToken = IStaking(upgradeAddress).lastBounsToken();
        poolInfo[usdAddress].accPerShare = IStaking(upgradeAddress)
            .accRewardPerShare();
        isUpgrade = false;
    }

    function setBounsRate(uint256 rate) external onlyOwner {
        bounsRate = rate;
    }

    function setIsBonus(bool value) external onlyOwner {
        isBonus = value;
    }

    function userInfo(address token, address _account)
        public
        view
        returns (UserInfo memory _user)
    {
        _user = _userInfo[token][_account];
        if (token == usdAddress) {
            if (!userUpgrade[_account] && upgradeAddress != address(0)) {
                _user = IStaking(upgradeAddress).userInfo(_account);
            }
        }

        return _user;
    }

    // 更新用户信息
    function _upgradeUser(address _account) private {
        if (!userUpgrade[_account] && upgradeAddress != address(0)) {
            UserInfo memory _user = IStaking(upgradeAddress).userInfo(_account);
            _userInfo[usdAddress][_account] = UserInfo({
                stakedOf: _user.stakedOf,
                rewardOf: _user.rewardOf,
                duration: _user.duration,
                lastDepositAt: _user.lastDepositAt,
                lastRewardAt: _user.lastRewardAt,
                userReward: _user.userReward
            });
        }
        userUpgrade[_account] = true;
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

    // 将新的 lp 添加到池中 _allocPoint 分配点
    function addPool(address token, uint256 _allocPoint) public onlyOwner {
        _addPool(token, _allocPoint);
    }

    function _addPool(address token, uint256 _allocPoint) private {
        require(poolInfo[token].lpToken == address(0), "token is exist"); //避免重复添加池
        totalAllocPoint += _allocPoint;
        pools.push(token);
        poolInfo[token] = PoolInfo({
            totalStaked: 0,
            lpToken: token,
            allocPoint: _allocPoint,
            accPerShare: 0
        });
    }

    // 更新给定池的 token 分配点。 只能由所有者调用。
    function setPool(address token, uint256 _allocPoint) public onlyOwner {
        require(poolInfo[token].lpToken != address(0), "token is not exist");
        totalAllocPoint =
            totalAllocPoint -
            poolInfo[token].allocPoint +
            _allocPoint;
        poolInfo[token].allocPoint = _allocPoint;
    }

    // 获取待分红的奖励
    function getPendingReward() public view returns (uint256) {
        //将待分红奖励划入分红余额，分红池按n天分红，分红更线性
        uint256 totalFee = IDepositUSD(depositAddress).getFee();

        return (totalFee * bounsRate) / 1000;
    }

    // 更新分红奖励
    function bonusReward() external {
        require(!isUpgrade, "upgrade status error");
        require(isBonus, "isBonus status error");
        require(totalAllocPoint > 0, "No pool");
        uint256 _epoch_day = block.timestamp / bounsDuration;
        require(_epoch_day > lastBounsEpoch, "Error: lastBounsEpoch");

        _bonusReward();
    }

    function _bonusReward() private {
        if (!isUpgrade && isBonus && totalAllocPoint > 0) {
            uint256 _epoch_day = block.timestamp / bounsDuration;
            if (_epoch_day > lastBounsEpoch) {
                lastBounsEpoch = _epoch_day;
                lastBounsToken = getPendingReward(); //本次可分红数量

                uint256 allReward; //实际分红数量(排除0质押)
                for (uint256 pid = 0; pid < pools.length; ++pid) {
                    allReward += updatePool(pools[pid]);
                }
                IDepositUSD(depositAddress).bonusFee(allReward); //累计总分红,扣减分红奖池
            }
        }
    }

    function updatePool(address token) private returns (uint256) {
        if (poolInfo[token].accPerShare > 0) {
            if (poolInfo[token].totalStaked > 0 && lastBounsToken > 0) {
                uint256 _reward = (lastBounsToken *
                    poolInfo[token].allocPoint) / totalAllocPoint;

                poolInfo[token].accPerShare +=
                    (_reward * 1e12) /
                    poolInfo[token].totalStaked;
                totalReward += _reward; //记录总分红
                return _reward;
            }
        }
        return 0;
    }

    function getDuration(uint256 _duration) private pure returns (uint256) {
        if (_duration >= DEPOSIT_DURATION_3) {
            return DEPOSIT_DURATION_3;
        } else if (_duration >= DEPOSIT_DURATION_2) {
            return DEPOSIT_DURATION_2;
        } else if (_duration >= DEPOSIT_DURATION_1) {
            return DEPOSIT_DURATION_1;
        } else {
            return 0;
        }
    }

    // 质押
    function stake(
        address token,
        uint256 amount,
        uint256 _duration
    ) external returns (bool) {
        require(!isUpgrade, "upgrade status error");
        require(amount > 0, "stake must be integer multiple of 1 USD.");
        require(poolInfo[token].allocPoint > 0, "token is not exist");

        _upgradeUser(msg.sender); //更新用户信息
        _bonusReward(); //更新分红奖励
        UserInfo storage user = _userInfo[token][msg.sender];
        if (user.stakedOf > 0) {
            require(_duration == user.duration, "Error: User Duration");
            // 领取之前的奖励
            uint256 pending = rewardAmount(msg.sender, token);
            _takeReward(token, msg.sender, pending);
        }

        //转入质押
        TransferHelper.safeTransferFrom(
            token,
            msg.sender,
            depositAddress,
            amount
        );

        if (token == usdAddress) {
            //记录质押数量
            IDepositUSD(depositAddress).stakeUsd(msg.sender, amount);
        }

        user.duration = getDuration(_duration);
        user.lastDepositAt = block.timestamp;
        // 更新用户质押的数量
        user.stakedOf += amount;
        // 更新已经领取的奖励
        user.rewardOf = (user.stakedOf * poolInfo[token].accPerShare) / 1e12;
        // 更新池子总票数
        poolInfo[token].totalStaked += amount;
        // emit event
        emit Staked(msg.sender, token, amount);

        return true;
    }

    /**
     * 提取质押物
     */
    function unstake(address token, uint256 _amount)
        external
        virtual
        returns (bool)
    {
        require(!isUpgrade, "upgrade status error");
        _upgradeUser(msg.sender); //更新用户信息
        _bonusReward(); //更新分红奖励

        UserInfo storage user = _userInfo[token][msg.sender];
        require(user.stakedOf >= _amount, "Staking: out of staked");
        require(_amount > 0, "votes must be gt 0.");
        require(
            block.timestamp - user.lastDepositAt >= user.duration,
            "Error: User Duration"
        ); // 定期
        require(
            block.timestamp - user.lastDepositAt >= unstakeDuration,
            "Error: User Unstake Duration"
        ); //活期

        // 领取之前的奖励
        uint256 pending = rewardAmount(msg.sender, token);
        _takeReward(token, msg.sender, pending);

        _unstake(token, _amount);
        return true;
    }

    function _unstake(address token, uint256 _amount) private {
        if (_amount > 0) {
            UserInfo storage user = _userInfo[token][msg.sender];
            if (_amount > user.stakedOf) {
                _amount = user.stakedOf;
            }

            poolInfo[token].totalStaked -= _amount;
            // 更新用户质押的数量
            user.stakedOf -= _amount;
            // 更新已经领取的奖励
            user.rewardOf =
                (user.stakedOf * poolInfo[token].accPerShare) /
                1e12;

            if (token == usdAddress) {
                //记录质押数量
                IDepositUSD(depositAddress).unstakeUsd(msg.sender, _amount);
            } else {
                IDepositUSD(depositAddress).withdrawToken(
                    token,
                    msg.sender,
                    _amount
                );
            }

            emit Unstaked(msg.sender, token, _amount);
        }
    }

    function rewardAmount(address _account, address _token)
        public
        view
        returns (uint256)
    {
        uint256 pending;
        UserInfo memory _user = userInfo(_token, _account);
        if (_user.stakedOf > 0 && poolInfo[_token].allocPoint > 0) {
            uint256 _accPerShare = poolInfo[_token].accPerShare;
            uint256 _epoch_day = block.timestamp / bounsDuration;
            if (_epoch_day > lastBounsEpoch) {
                uint256 _reward = (getPendingReward() *
                    poolInfo[_token].allocPoint) / totalAllocPoint;
                _accPerShare += (_reward * 1e12) / poolInfo[_token].totalStaked;
            }
            pending = ((_user.stakedOf * _accPerShare) / 1e12) - _user.rewardOf;
        }
        return pending;
    }

    function _takeReward(
        address token,
        address _account,
        uint256 pending
    ) private {
        if (pending > 0) {
            UserInfo storage user = _userInfo[token][_account];
            user.rewardOf =
                (user.stakedOf * poolInfo[token].accPerShare) /
                1e12;
            safeTransfer(token, _account, pending);
        }
    }

    // 直接领取收益
    function takeReward(address token) external {
        require(!isUpgrade, "upgrade status error");
        _upgradeUser(msg.sender); //更新用户信息
        _bonusReward(); //更新分红奖励

        UserInfo storage user = _userInfo[token][msg.sender];
        require(user.stakedOf > 0, "Staking: out of staked");
        uint256 pending = rewardAmount(msg.sender, token);
        require(pending > 0, "Staking: no pending reward");

        _takeReward(token, msg.sender, pending);
        if (
            user.duration > 0 &&
            (block.timestamp - user.lastDepositAt >= user.duration)
        ) {
            _unstake(token, user.stakedOf);
        }
    }

    // 安全的转账功能，以防万一如果舍入错误导致池没有足够的奖励。
    function safeTransfer(
        address token,
        address _account,
        uint256 _amount
    ) internal {
        if (_amount > 0) {
            address _rewardAddr = IUSD(usdAddress).rewardTo();
            if (_rewardAddr != address(0)) {
                IUSDReward(_rewardAddr).inviteReward(_account, _amount);
            }

            UserInfo storage user = _userInfo[token][_account];
            user.userReward += _amount;
            IDepositUSD(depositAddress).takeFee(_account, _amount);
            emit Reward(_account, _amount);
        }
    }
}