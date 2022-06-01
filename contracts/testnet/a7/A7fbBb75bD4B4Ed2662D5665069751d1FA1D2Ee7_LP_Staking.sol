// SPDX-License-Identifier: MIT

pragma solidity >=0.8.6;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);
}

interface IATH {
    function inviter(address account_) external view returns (address);

    function swapTokensForStaking() external;
}

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

contract LP_Staking {
    address public owner;
    address public token; //token address
    address public usdtAddress = 0x47A01F129b9c95E63a50a6aa6cBaFDD96bEb4C6F; //usdtAddress
    uint256 public BASE_BONUS_REWARD = 462962963000000000; //每个区块产出
    uint256 public BONUS_DURATION = 5; //5s一个区块
    uint256 public DEPOSIT_DURATION = 1800; //120d 10368000
    uint256 public WITHDRAW_DURATION = 1200; //86400

    uint256 public totalBonus; //累计产出
    uint256 public totalUsdt; //usdt总量
    uint256 public totalUsedUsdt; //已经使用的usdt
    uint256 public allBonusUsdt; //已经分红待领取的usdt奖励
    uint256 public BASE_BONUS_USDT = 100 * 1e18; //基础每期产出 1000

    uint256 public lastBonusAt;
    uint256 private _pendingToken; //每期产出
    uint256 private _pendingUsdt; //每期产出

    // 每个池的信息。
    address[] public pools;
    mapping(address => PoolInfo) public poolInfo; //节点详情

    // 每个持有 LP 代币的用户的信息。
    mapping(address => mapping(address => UserInfo)) public userInfo;
    mapping(address => uint256) public userReward;
    mapping(address => uint256) public inviteReward;

    // 总分配点数。 必须是所有池中所有分配点的总和。
    uint256 public totalAllocPoint = 0;

    // 每个用户的信息。
    struct UserInfo {
        uint256 amount; // 用户提供了多少 LP 代币。
        uint256 rewardDebt; // 用户已经获取的奖励
        uint256 rewardUsdtDebt; // 用户已经获取的奖励
        uint256 duration; //质押周期
        uint256 lastDepositAt; //最后质押时间
        uint256 lastRewardAt; //最后领奖时间
        uint256 userReward; // 用户奖励
        uint256 userUsdtReward; // 用户奖励
        uint256 withdraw; // 提取 LP 代币的数量。
        uint256 lastWithdrawAt; // 最后提取 LP 代币的时间。
    }

    // 每个池的信息。
    struct PoolInfo {
        uint256 extendedSupply; // 已经延长了抵押期的总数量。
        uint256 supply; // 总股份
        address lpToken; // LP 代币合约地址。
        uint256 allocPoint; // 分配给此池的分配点数。
        uint256 accPerShare; // 质押一个LPToken的全局收益
        uint256 accPerShareUsdt; // 质押一个LPToken的全局收益
    }

    event Deposit(
        address indexed user,
        address indexed lpToken,
        uint256 amount,
        uint256 duration
    );
    event Unstake(
        address indexed user,
        address indexed lpToken,
        uint256 amount
    );
    event Reward(address indexed user, address indexed lpToken, uint256 amount);
    event RewardUsdt(
        address indexed user,
        address indexed lpToken,
        uint256 amount
    );

    event Withdraw(
        address indexed user,
        address indexed lpToken,
        uint256 amount
    );

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function getInviter(address _account) private view returns (address) {
        return IATH(token).inviter(_account);
    }

    function initToken(address _token) public onlyOwner {
        require(token == address(0), "Token has been initialized");
        token = _token;
    }

    function setOwner(address owner_) public onlyOwner {
        owner = owner_;
    }

    function setTokenAddr(address _token) public onlyOwner {
        token = _token;
    }

    function setBonusOption(
        uint256 _bonus_duration,
        uint256 deposit1_duration,
        uint256 _reward
    ) public onlyOwner {
        BONUS_DURATION = _bonus_duration; //1d
        DEPOSIT_DURATION = deposit1_duration; //120d
        BASE_BONUS_REWARD = _reward;
    }

    function setUsdtAddr(address _usdt) public onlyOwner {
        usdtAddress = _usdt;
    }

    function setBonusUsdt(uint256 _bonus_usdt) public onlyOwner {
        BASE_BONUS_USDT = _bonus_usdt;
    }

    function setWithdrawOption(uint256 _withdraw_duration) public onlyOwner {
        WITHDRAW_DURATION = _withdraw_duration;
    }

    function poolLength() external view returns (uint256) {
        return pools.length;
    }

    function getPool(uint256 pid) public view returns (PoolInfo memory) {
        return poolInfo[pools[pid]];
    }

    function getUserPools(uint256 pid, address _account)
        public
        view
        returns (PoolInfo memory, UserInfo memory)
    {
        address _lpToken = pools[pid];
        return (poolInfo[_lpToken], userInfo[_lpToken][_account]);
    }

    // 将新的 lp 添加到池中。 只能由所有者调用。
    // _allocPoint 分配点
    function addPool(uint256 _allocPoint, address _lpToken) public onlyOwner {
        require(poolInfo[_lpToken].lpToken == address(0)); //防呆，避免重复添加池
        totalAllocPoint += _allocPoint;
        pools.push(_lpToken);
        poolInfo[_lpToken] = PoolInfo({
            extendedSupply: 0,
            supply: 0,
            lpToken: _lpToken,
            allocPoint: _allocPoint,
            accPerShare: 0,
            accPerShareUsdt: 0
        });
    }

    // 更新给定池的 token 分配点。 只能由所有者调用。
    function setPool(address _lpToken, uint256 _allocPoint) public onlyOwner {
        totalAllocPoint =
            totalAllocPoint -
            poolInfo[_lpToken].allocPoint +
            _allocPoint;
        poolInfo[_lpToken].allocPoint = _allocPoint;
    }

    function bonusUsdt(uint256 _bonus) external {
        require(msg.sender == token, "Only token can call this function");
        totalUsdt += _bonus;
    }

    function pendingToken() public view returns (uint256) {
        uint256 diff = block.timestamp - lastBonusAt;
        uint256 num = diff / BONUS_DURATION;

        uint256 _balance = IERC20(token).balanceOf(address(this));
        uint256 pendingAmount = num * BASE_BONUS_REWARD;
        if (pendingAmount > _balance) {
            pendingAmount = _balance;
        }

        return pendingAmount;
    }

    function pendingUsdt() public view returns (uint256) {
        uint256 usdtReward = totalUsdt - totalUsedUsdt;
        uint256 pendingAmount;
        if (usdtReward >= BASE_BONUS_USDT) {
            pendingAmount = BASE_BONUS_USDT;
        }

        return pendingAmount;
    }

    // 更新所有池的奖励变量。 小心汽油消费！
    function bonusReward() public {
        if (totalAllocPoint > 0) {
            _pendingToken = pendingToken();
            _pendingUsdt = pendingUsdt();
            uint256 length = pools.length;
            lastBonusAt = block.timestamp;

            for (uint256 pid = 0; pid < length; ++pid) {
                updatePool(pools[pid]);
            }
        }
    }

    function updatePool(address _lpToken) private {
        PoolInfo storage pool = poolInfo[_lpToken];
        if (pool.allocPoint > 0) {
            if (pool.supply > 0 && _pendingToken > 0) {
                uint256 _reward = (_pendingToken * pool.allocPoint) /
                    totalAllocPoint;
                pool.accPerShare += (_reward * 1e12) / pool.supply;
                totalBonus += _reward;
            }

            if (pool.extendedSupply > 0 && _pendingUsdt > 0) {
                uint256 _reward = (_pendingUsdt * pool.allocPoint) /
                    totalAllocPoint;
                pool.accPerShareUsdt += (_reward * 1e12) / pool.extendedSupply;
                allBonusUsdt += _reward;
                totalUsedUsdt += _reward;
            }
        }
    }

    function rewardAmount(address _account, address _lpToken)
        public
        view
        returns (uint256, uint256)
    {
        PoolInfo storage pool = poolInfo[_lpToken];
        UserInfo storage user = userInfo[_lpToken][_account];
        if (user.amount > 0 && pool.supply > 0 && pool.allocPoint > 0) {
            uint256 _accPerShare = pool.accPerShare;
            uint256 rewardToken;
            uint256 rewardUsdt;
            uint256 _reward;

            _reward = (pendingToken() * pool.allocPoint) / totalAllocPoint;
            _accPerShare += (_reward * 1e12) / pool.supply;
            rewardToken = (user.amount * _accPerShare) / 1e12 - user.rewardDebt;

            if (user.duration == DEPOSIT_DURATION) {
                uint256 _accPerShareUsdt = pool.accPerShareUsdt;
                _reward = (pendingUsdt() * pool.allocPoint) / totalAllocPoint;
                _accPerShareUsdt += (_reward * 1e12) / pool.extendedSupply;

                rewardUsdt =
                    (user.amount * _accPerShareUsdt) /
                    1e12 -
                    user.rewardUsdtDebt;
            }

            return (rewardToken, rewardUsdt);
        }
        return (0, 0);
    }

    // 将 LP 代币存入
    function deposit(
        address _lpToken,
        uint256 _duration,
        uint256 _amount
    ) public {
        require(getInviter(msg.sender) != address(0), "must bind inviter");
        require(
            _duration == 0 || _duration == DEPOSIT_DURATION,
            "Error: _duration"
        );
        PoolInfo storage pool = poolInfo[_lpToken];
        UserInfo storage user = userInfo[_lpToken][msg.sender];
        bonusReward();
        if (user.amount > 0) {
            require(_duration == user.duration, "Error: User Duration");
            _takeReward(msg.sender, _lpToken);
        }

        uint256 balanceBefore = IERC20(pool.lpToken).balanceOf(address(this)); //兼容有手续费的代币
        TransferHelper.safeTransferFrom(
            pool.lpToken,
            msg.sender,
            address(this),
            _amount
        );
        uint256 balanceAdd = IERC20(pool.lpToken).balanceOf(address(this)) -
            balanceBefore; //兼容有手续费的代币

        user.duration = _duration;
        user.amount += balanceAdd;
        user.lastDepositAt = block.timestamp;
        pool.supply += balanceAdd;
        user.rewardDebt = (user.amount * pool.accPerShare) / 1e12;
        user.rewardUsdtDebt = (user.amount * pool.accPerShareUsdt) / 1e12;

        if (_duration == DEPOSIT_DURATION) {
            pool.extendedSupply += balanceAdd;
        }

        emit Deposit(msg.sender, _lpToken, balanceAdd, _duration);
    }

    // 解压 LP 代币
    function unstake(address _lpToken, uint256 _amount) public {
        PoolInfo storage pool = poolInfo[_lpToken];
        UserInfo storage user = userInfo[_lpToken][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        require(
            block.timestamp - user.lastDepositAt >= user.duration,
            "Error: User Duration"
        );
        bonusReward();
        _takeReward(msg.sender, _lpToken);

        user.amount -= _amount;
        pool.supply -= _amount;
        if (user.duration == DEPOSIT_DURATION) {
            pool.extendedSupply -= _amount;
        }

        if (user.amount == 0) {
            user.duration = 0;
            user.rewardDebt = 0;
            user.rewardUsdtDebt = 0;
        } else {
            user.rewardDebt = (user.amount * pool.accPerShare) / 1e12;
            user.rewardUsdtDebt = (user.amount * pool.accPerShareUsdt) / 1e12;
        }

        user.withdraw += _amount;
        user.lastWithdrawAt = block.timestamp;

        emit Unstake(msg.sender, _lpToken, _amount);
    }

    // 提现而不关心奖励。 仅限紧急情况。
    function emergencyUnstake(address _lpToken) public {
        PoolInfo storage pool = poolInfo[_lpToken];
        UserInfo storage user = userInfo[_lpToken][msg.sender];
        require(
            block.timestamp - user.lastDepositAt >= user.duration,
            "Error: User Duration"
        );

        uint256 _amount = user.amount;
        user.amount = 0;
        pool.supply -= _amount;
        user.duration = 0;
        user.rewardDebt = 0;
        user.rewardUsdtDebt = 0;
        if (user.duration == DEPOSIT_DURATION) {
            pool.extendedSupply -= user.amount;
        }
        user.withdraw += _amount;
        user.lastWithdrawAt = block.timestamp;
        emit Unstake(msg.sender, _lpToken, user.amount);
    }

    // 提现 LP 代币
    function withdraw(address _lpToken) public {
        UserInfo storage user = userInfo[_lpToken][msg.sender];
        require(
            block.timestamp - user.lastWithdrawAt >= WITHDRAW_DURATION,
            "Error: User Duration"
        );

        require(user.withdraw > 0, "Error: User Withdraw");
        PoolInfo storage pool = poolInfo[_lpToken];
        uint256 _amount = user.withdraw;
        user.withdraw = 0;
        TransferHelper.safeTransfer(pool.lpToken, msg.sender, _amount);

        emit Withdraw(msg.sender, _lpToken, user.amount);
    }

    // 直接领取收益
    function takeReward(address _lpToken) public {
        PoolInfo storage pool = poolInfo[_lpToken];
        UserInfo storage user = userInfo[_lpToken][msg.sender];
        require(lastBonusAt > user.lastRewardAt, "Error: lastRewardAt");
        bonusReward();
        if (
            user.duration > 0 &&
            (block.timestamp - user.lastDepositAt >= user.duration)
        ) {
            unstake(_lpToken, user.amount);
        } else {
            _takeReward(msg.sender, _lpToken);
            user.rewardDebt = (user.amount * pool.accPerShare) / 1e12;
            user.rewardUsdtDebt = (user.amount * pool.accPerShareUsdt) / 1e12;
        }
    }

    function _takeReward(address _account, address _lpToken) private {
        (uint256 _amount, uint256 _usdt) = rewardAmount(_account, _lpToken);
        UserInfo storage user = userInfo[_lpToken][_account];
        user.lastRewardAt = block.timestamp;

        if (_amount > 0) {
            uint256 _reward = IERC20(token).balanceOf(address(this));
            if (_amount > _reward) {
                _amount = _reward;
            }

            address inviter = getInviter(_account);
            uint256 _inviteReward = (_amount * 10) / 100;
            uint256 _rewardAmount = _amount - _inviteReward;

            user.userReward += _rewardAmount;
            userReward[_account] += _rewardAmount;
            inviteReward[inviter] += _inviteReward;

            TransferHelper.safeTransfer(token, _account, _rewardAmount);
            TransferHelper.safeTransfer(token, inviter, _inviteReward);
            emit Reward(_account, _lpToken, _rewardAmount);
        }

        if (_usdt > 0 && allBonusUsdt > 0) {
            uint256 _reward = allBonusUsdt;
            if (_usdt > _reward) {
                _usdt = _reward;
            }
            allBonusUsdt -= _usdt;
            user.userUsdtReward += _usdt;
            TransferHelper.safeTransfer(usdtAddress, _account, _usdt);
            emit RewardUsdt(_account, _lpToken, _usdt);
        }
    }

    function withdrawToken(
        address token_,
        address to_,
        uint256 amount_
    ) public onlyOwner {
        TransferHelper.safeTransfer(token_, to_, amount_);
    }
}