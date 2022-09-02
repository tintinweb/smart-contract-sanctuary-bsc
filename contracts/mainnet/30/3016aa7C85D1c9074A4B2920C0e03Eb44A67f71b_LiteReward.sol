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
    struct UserInfo {
        uint256 stakedOf;
        uint256 rewardOf;
        uint256 duration;
        uint256 lastDepositAt;
        uint256 lastRewardAt;
        uint256 userReward;
    }

    struct PoolInfo {
        uint256 totalStaked;
        address lpToken;
        uint256 allocPoint;
        uint256 accPerShare;
    }
}

interface IStaking is StakeInfo {
    function userInfo(address token, address _account)
        external
        view
        returns (UserInfo memory _user);

    function poolInfo(address token)
        external
        view
        returns (PoolInfo memory _pool);
}

interface IUSD {
    function owner() external view returns (address);

    function stakeTo() external view returns (address);

    function rewardTo() external view returns (address);
}

contract LiteReward is StakeInfo {
    address public constant usdAddress =
        0x1F20F26a747916FaB87C1Fe342fa4FA787f2B2BF;
    address public constant liteAddress =
        0x3Ef3f6Cf9f867A33C4109208a6bd043A9Ef0E091;

    uint256 public bounsDay = 20;
    uint256 public constant bounsDuration = 86400;

    bool public isBonus = true;
    uint256 public totalPool = 0;
    address[] public pools;

    mapping(address => mapping(address => BonusUser)) bonusUser;
    mapping(address => BonusPool) private bonusPool;
    struct BonusPool {
        uint256 totalStaked;
        address lpToken;
        bool status;
        uint256 accPerShare;
    }

    struct BonusUser {
        uint256 stakedOf;
        uint256 rewardOf;
        uint256 lastRewardAt;
        uint256 userReward;
    }

    uint256 public totalReward;
    uint256 public totalUsedReward;
    uint256 public totalPendingReward;

    uint256 public lastBounsEpoch;
    uint256 public lastBounsToken;

    event Staked(address indexed from, address token, uint256 amount);

    event Unstaked(address indexed from, address token, uint256 amount);

    event Reward(address indexed to, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner(), "caller is not owner");
        _;
    }

    modifier onlyRewardTo() {
        require(msg.sender == rewardTo(), "caller can not be allowed");
        _;
    }

    function owner() public view returns (address) {
        return IUSD(usdAddress).owner();
    }

    function stakeTo() public view returns (address) {
        return IUSD(usdAddress).stakeTo();
    }

    function rewardTo() public view returns (address) {
        return IUSD(usdAddress).rewardTo();
    }

    function setBounsDay(uint256 day) external onlyOwner {
        bounsDay = day;
    }

    function setIsBonus(bool value) external onlyOwner {
        isBonus = value;
    }

    function poolLength() external view returns (uint256) {
        return pools.length;
    }

    function getPool(uint256 index)
        external
        view
        returns (BonusPool memory _pool)
    {
        return poolInfo(pools[index]);
    }

    function poolInfo(address token)
        public
        view
        returns (BonusPool memory _pool)
    {
        _pool = bonusPool[token];
        if (_pool.totalStaked == 0) {
            PoolInfo memory stakingInfo = IStaking(stakeTo()).poolInfo(token);
            _pool.totalStaked = stakingInfo.totalStaked;
        }
        return _pool;
    }

    function userInfo(address token, address _account)
        public
        view
        returns (BonusUser memory _user)
    {
        _user = bonusUser[token][_account];
        if (_user.stakedOf == 0) {
            UserInfo memory stakingUser = IStaking(stakeTo()).userInfo(
                token,
                _account
            );
            _user.stakedOf = stakingUser.stakedOf;
        }
        return _user;
    }

    function addPool(address token) public onlyOwner {
        require(bonusPool[token].lpToken == address(0), "token is exist");
        totalPool += 1;
        pools.push(token);
        bonusPool[token] = BonusPool({
            totalStaked: 0,
            lpToken: token,
            status: true,
            accPerShare: 0
        });
    }

    function setPool(address token, bool status) public onlyOwner {
        require(bonusPool[token].lpToken != address(0), "token is not exist");
        require(bonusPool[token].status != status, "status is same");
        if (status) {
            totalPool += 1;
        } else {
            totalPool -= 1;
        }
        bonusPool[token].status = status;
    }

    function depositReward(uint256 amount_) external {
        TransferHelper.safeTransferFrom(
            liteAddress,
            msg.sender,
            address(this),
            amount_
        );
        totalReward += amount_;
    }

    function withdrawToken(
        address token_,
        address to_,
        uint256 amount_
    ) external onlyOwner {
        TransferHelper.safeTransfer(token_, to_, amount_);
    }

    function getPendingReward() public view returns (uint256) {
        return (totalReward - totalUsedReward) / bounsDay;
    }

    function bonusReward() external {
        require(isBonus, "isBonus error");
        uint256 _epoch_day = block.timestamp / bounsDuration;
        require(_epoch_day > lastBounsEpoch, "Error: lastBounsEpoch");

        _bonusReward();
    }

    function _bonusReward() private {
        if (isBonus && totalPool > 0) {
            uint256 _epoch_day = block.timestamp / bounsDuration;
            if (_epoch_day > lastBounsEpoch) {
                lastBounsEpoch = _epoch_day;
                lastBounsToken = getPendingReward();

                for (uint256 pid = 0; pid < pools.length; ++pid) {
                    _updatePool(pools[pid]);
                }
            }
        }
    }

    function _updatePool(address token) private {
        BonusPool memory _pool = poolInfo(token);
        if (_pool.status && _pool.totalStaked > 0 && lastBounsToken > 0) {
            uint256 _reward = lastBounsToken / totalPool;

            bonusPool[token].accPerShare +=
                (_reward * 1e12) /
                _pool.totalStaked;

            totalUsedReward += _reward;
            totalPendingReward += _reward;
        }
    }

    function updateStaked(
        address token,
        address account,
        uint256 beforeStaked,
        uint256 afterStaked
    ) external onlyRewardTo {
        _bonusReward();
        if (beforeStaked > 0) {
            // 领取之前的奖励
            uint256 pending = rewardAmount(account, token);
            _takeReward(token, account, pending);
        }

        PoolInfo memory stakingInfo = IStaking(stakeTo()).poolInfo(token);
        bonusPool[token].totalStaked = stakingInfo.totalStaked;
        bonusUser[token][account].stakedOf = afterStaked;
        bonusUser[token][account].rewardOf =
            (afterStaked * bonusPool[token].accPerShare) /
            1e12;
    }

    function takeReward(address token) external {
        _bonusReward();

        BonusUser memory user = userInfo(token, msg.sender);
        require(user.stakedOf > 0, "Staking: out of staked");
        uint256 pending = rewardAmount(msg.sender, token);
        require(pending > 0, "Staking: no pending reward");

        _takeReward(token, msg.sender, pending);
    }

    function rewardAmount(address _account, address _token)
        public
        view
        returns (uint256)
    {
        uint256 pending;
        BonusUser memory _user = userInfo(_token, _account);
        BonusPool memory _pool = poolInfo(_token);
        if (_user.stakedOf > 0) {
            uint256 _accPerShare = _pool.accPerShare;
            uint256 _epoch_day = block.timestamp / bounsDuration;
            if (_epoch_day > lastBounsEpoch && _pool.status) {
                uint256 _reward = getPendingReward() / totalPool;
                _accPerShare += (_reward * 1e12) / _pool.totalStaked;
            }
            pending = ((_user.stakedOf * _accPerShare) / 1e12) - _user.rewardOf;
        }

        return pending;
    }

    function predictReward(address _account, address _token)
        external
        view
        returns (uint256)
    {
        uint256 pending;
        BonusUser memory _user = userInfo(_token, _account);
        BonusPool memory _pool = poolInfo(_token);
        if (_user.stakedOf > 0) {
            uint256 _accPerShare = _pool.accPerShare;
            if (_pool.status) {
                _accPerShare += (getPendingReward() * 1e12) / _pool.totalStaked;
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
            BonusUser memory _user = userInfo(token, _account);
            bonusUser[token][_account].rewardOf =
                (_user.stakedOf * bonusPool[token].accPerShare) /
                1e12;
            safeTransfer(token, _account, pending);
        }
    }

    function safeTransfer(
        address token,
        address _account,
        uint256 _amount
    ) private {
        if (_amount > 0) {
            if (_amount > totalPendingReward) {
                _amount = totalPendingReward;
            }
            BonusUser storage user = bonusUser[token][_account];
            totalPendingReward -= _amount;
            user.userReward += _amount;
            TransferHelper.safeTransfer(liteAddress, _account, _amount);
            emit Reward(_account, _amount);
        }
    }
}