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

    // 每个用户的信息。
    struct UserInfo {
        uint256 amount; // 用户提供了多少 LP 代币。
        uint256 rewardDebt; // 用户已经获取的奖励
        uint256 rewardUsdtDebt; // 用户已经获取的奖励
        uint256 duration; //质押周期
        uint256 lastDepositAt; //最后质押时间
        uint256 lastRewardAt; //最后领奖时间
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

    address public token; //token address
    uint256 public baseToken; //token amount
    address public usdtAddress = 0x47A01F129b9c95E63a50a6aa6cBaFDD96bEb4C6F; //usdtAddress
    uint256 public BASE_BONUS_REWARD = 240000 * baseToken; //基础每期产出
    uint256 public BONUS_DURATION = 600; //1d 86400
    uint256 public DEPOSIT_DURATION = 1800; //120d 10368000

    uint256 public totalUsdt; //usdt总量
    uint256 public totalUsedUsdt; //已经使用的usdt
    uint256 public allBonusUsdt; //已经分红待领取的usdt奖励

    uint256 public startBonusAt;
    uint256 public lastBonusAt;
    uint256 public pendingToken; //每期产出
    uint256 public pendingUsdt; //每期产出

    // 每个池的信息。
    address[] public pools;
    mapping(address => PoolInfo) public poolInfo; //节点详情

    // 每个持有 LP 代币的用户的信息。
    mapping(address => mapping(address => UserInfo)) public userInfo;
    mapping(address => uint256) public userReward;

    // 总分配点数。 必须是所有池中所有分配点的总和。
    uint256 public totalAllocPoint = 0;

    event Deposit(
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

    function initToken(address _token, uint8 _decmails) public onlyOwner {
        require(token == address(0), "Token has been initialized");
        token = _token;
        startBonusAt = block.timestamp;
        baseToken = 10**_decmails;
    }

    function setOwner(address owner_) public onlyOwner {
        owner = owner_;
    }

    function setTokenAddr(address _token) public onlyOwner {
        token = _token;
    }

    function setBonusReward(uint256 _start, uint256 _reward) public onlyOwner {
        startBonusAt = _start;
        BASE_BONUS_REWARD = _reward;
    }

    function setBonusOption(uint256 _bonus, uint256 deposit1) public onlyOwner {
        BONUS_DURATION = _bonus; //1d
        DEPOSIT_DURATION = deposit1; //120d
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

    function bonusUsdt() private {
        uint256 balanceBefore = IERC20(usdtAddress).balanceOf(address(this)); //兼容有手续费的代币
        IATH(token).swapTokensForStaking();
        uint256 balanceAdd = IERC20(usdtAddress).balanceOf(address(this)) -
            balanceBefore; //兼容有手续费的代币

        totalUsdt += balanceAdd;
    }

    // 更新所有池的奖励变量。 小心汽油消费！
    function bonusReward() public {
        require(
            block.timestamp - lastBonusAt > BONUS_DURATION,
            "Error: BONUS_DURATION"
        );

        require(totalAllocPoint > 0, "Error: totalAllocPoint");
        bonusUsdt();
        pendingUsdt = totalUsdt - totalUsedUsdt;
        totalUsedUsdt += pendingUsdt;

        uint256 _balance = IERC20(token).balanceOf(address(this));
        if (BASE_BONUS_REWARD > _balance) {
            pendingToken = _balance;
        } else {
            pendingToken = BASE_BONUS_REWARD;
        }

        uint256 length = pools.length;
        lastBonusAt = block.timestamp;

        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pools[pid]);
        }
    }

    function updatePool(address _lpToken) private {
        PoolInfo storage pool = poolInfo[_lpToken];
        if (pool.allocPoint > 0 && pool.supply > 0 && pendingToken > 0) {
            uint256 _reward = (pendingToken * pool.allocPoint) /
                totalAllocPoint;

            pool.accPerShare += (_reward * 1e12) / pool.supply;
        }

        if (pool.allocPoint > 0 && pendingUsdt > 0) {
            uint256 _reward = (pendingUsdt * pool.allocPoint) / totalAllocPoint;
            if (pool.extendedSupply > 0) {
                pool.accPerShareUsdt += (_reward * 1e12) / pool.extendedSupply;
                allBonusUsdt += _reward;
            } else {
                totalUsdt += _reward;
            }
        }
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

        emit Deposit(msg.sender, _lpToken, balanceAdd);
    }

    // 从 MasterChef 中提现 LP 代币。
    function withdraw(address _lpToken, uint256 _amount) public {
        PoolInfo storage pool = poolInfo[_lpToken];
        UserInfo storage user = userInfo[_lpToken][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        require(
            block.timestamp - user.lastDepositAt >= user.duration,
            "Error: User Duration"
        );

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

        TransferHelper.safeTransfer(pool.lpToken, msg.sender, _amount);

        emit Withdraw(msg.sender, _lpToken, _amount);
    }

    // 提现而不关心奖励。 仅限紧急情况。
    function emergencyWithdraw(address _lpToken) public {
        PoolInfo storage pool = poolInfo[_lpToken];
        UserInfo storage user = userInfo[_lpToken][msg.sender];
        require(
            block.timestamp - user.lastDepositAt >= user.duration,
            "Error: User Duration"
        );
        TransferHelper.safeTransfer(pool.lpToken, msg.sender, user.amount);

        pool.supply -= user.amount;
        user.amount = 0;
        user.duration = 0;
        user.rewardDebt = 0;
        user.rewardUsdtDebt = 0;
        if (user.duration == DEPOSIT_DURATION) {
            pool.extendedSupply -= user.amount;
        }
        emit Withdraw(msg.sender, _lpToken, user.amount);
    }

    function rewardAmount(address _account, address _lpToken)
        public
        view
        returns (uint256, uint256)
    {
        PoolInfo storage pool = poolInfo[_lpToken];
        UserInfo storage user = userInfo[_lpToken][_account];
        if (
            user.amount > 0 &&
            pool.supply > 0 &&
            pool.allocPoint > 0 &&
            pool.accPerShare > 0
        ) {
            uint256 pending = (user.amount * pool.accPerShare) /
                1e12 -
                user.rewardDebt;
            uint256 usdt;
            if (user.duration == DEPOSIT_DURATION) {
                usdt =
                    (user.amount * pool.accPerShareUsdt) /
                    1e12 -
                    user.rewardUsdtDebt;
            }

            return (pending, usdt);
        }
        return (0, 0);
    }

    // 直接领取收益
    function takeReward(address _lpToken) public {
        PoolInfo storage pool = poolInfo[_lpToken];
        UserInfo storage user = userInfo[_lpToken][msg.sender];
        require(lastBonusAt > user.lastRewardAt, "Error: lastRewardAt");

        // 质押到期时间
        uint256 bonusTimes;
        uint256 userDepositDuration = user.lastDepositAt + user.duration;
        // 超期了
        if (block.timestamp > userDepositDuration) {
            //超过时间
            uint256 overflowTime = block.timestamp - userDepositDuration;
            //超期的时间内分红次数
            bonusTimes = overflowTime / BONUS_DURATION;
        }

        if (
            user.duration > 0 &&
            (block.timestamp - user.lastDepositAt >= user.duration)
        ) {
            withdraw(_lpToken, user.amount);
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

            userReward[_account] += _amount;
            address inviter = getInviter(_account);
            uint256 inviteReward = (_amount * 10) / 100;
            TransferHelper.safeTransfer(
                token,
                _account,
                _amount - inviteReward
            );
            TransferHelper.safeTransfer(token, inviter, inviteReward);
        }

        if (_usdt > 0 && allBonusUsdt > 0) {
            uint256 _reward = allBonusUsdt;
            if (_usdt > _reward) {
                _usdt = _reward;
            }
            allBonusUsdt -= _usdt;
            TransferHelper.safeTransfer(usdtAddress, _account, _usdt);
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