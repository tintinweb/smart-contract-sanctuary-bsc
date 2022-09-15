/**
 *Submitted for verification at BscScan.com on 2022-09-15
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

contract LiteStaking {
    address public immutable tokenAddress;
    mapping(address => UserInfo) public userInfo;
    uint256 public constant bounsDuration = 600;
    uint256 public constant unstakeDuration = 600;
    uint256 public bounsDay = 20; //20 d
    uint256 public inviteRate1 = 0; //50/1000 5%
    uint256 public inviteRate2 = 0; //30/1000 3%

    uint256 public constant DEPOSIT_DURATION_1 = 2592000; //30d 2592000
    uint256 public constant DEPOSIT_DURATION_2 = 5184000; //60d 5184000
    uint256 public constant DEPOSIT_DURATION_3 = 7776000; //90d 7776000

    address public owner;
    bool public startBonus = false;

    uint256 public totalReward;
    uint256 public totalUsedReward;
    uint256 public totalStaked;
    uint256 public totalPendingReward;
    uint256 public lastBounsEpoch;
    uint256 public lastBounsToken;
    uint256 public accPerShare;

    mapping(address => address) public inviter;
    mapping(address => uint256) public inviteNum;

    struct UserInfo {
        uint256 stakedOf;
        uint256 rewardOf;
        uint256 lastStakedAt;
        uint256 lastRewardAt;
        uint256 userReward;
        uint256 inviteReward;
        uint256 duration; //质押周期
    }

    event Staked(address indexed from, uint256 amount);
    event Unstaked(address indexed from, uint256 amount);
    event Reward(address indexed to, uint256 amount);
    event InviteReward(
        address indexed from,
        address indexed to,
        uint256 amount
    );
    event BindInviter(address indexed _user, address indexed _inviter);

    constructor(address token_) {
        owner = msg.sender;
        tokenAddress = token_;
    }

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

    function setStartBonus(bool value) external onlyOwner {
        startBonus = value;
    }

    function setInviteRates(uint256 rate1, uint256 rate2) external onlyOwner {
        require(rate1 < 500 && rate2 < 500, "rate range error");
        inviteRate1 = rate1;
        inviteRate2 = rate2;
    }

    function depositReward(uint256 amount_) external {
        TransferHelper.safeTransferFrom(
            tokenAddress,
            msg.sender,
            address(this),
            amount_
        );
        totalReward += amount_;
    }

    function setInviter(address inviter_) external virtual returns (bool) {
        require(inviter[msg.sender] == address(0), "already bind inviter");
        require(msg.sender != inviter_, "can't bind self");
        require(
            inviter_ == owner || inviter[inviter_] != address(0),
            "inviter must be binded"
        );

        inviter[msg.sender] = inviter_;
        inviteNum[inviter_] += 1;
        emit BindInviter(msg.sender, inviter_);
        return true;
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
        require(startBonus, "startBonus error");
        require(totalStaked > 0, "totalStaked error");
        uint256 _epoch_day = block.timestamp / bounsDuration;
        require(_epoch_day > lastBounsEpoch, "Error: lastBounsEpoch");

        _bonusReward();
    }

    function stake(uint256 amount) external returns (bool) {
        return stake(amount, 0);
    }

    function stake(uint256 amount, uint256 _duration) public returns (bool) {
        require(amount > 0, "amount error");
        _bonusReward();

        UserInfo storage user = userInfo[msg.sender];
        if (user.stakedOf > 0) {
            uint256 pending = rewardAmount(msg.sender);
            _takeReward(msg.sender, pending);
        }

        if (user.stakedOf > 0) {
            require(_duration == user.duration, "Error: User Duration");
            // 领取之前的奖励
            uint256 pending = rewardAmount(msg.sender);
            _takeReward(msg.sender, pending);
        }

        TransferHelper.safeTransferFrom(
            tokenAddress,
            msg.sender,
            address(this),
            amount
        );

        user.duration = getDuration(_duration);
        user.lastStakedAt = block.timestamp;
        user.stakedOf += amount;
        user.rewardOf = (user.stakedOf * accPerShare) / 1e12;
        totalStaked += amount;

        emit Staked(msg.sender, amount);

        return true;
    }

    function unstake(uint256 amount) external returns (bool) {
        require(amount > 0, "amount error");
        _bonusReward();

        UserInfo storage user = userInfo[msg.sender];
        require(user.stakedOf >= amount, "Staking: out of staked");
        require(amount > 0, "amount error");
        require(
            block.timestamp - user.lastStakedAt >= user.duration,
            "Error: User Duration"
        );
        require(
            block.timestamp - user.lastStakedAt >= unstakeDuration,
            "Staking: unstakeDuration"
        );

        uint256 pending = rewardAmount(msg.sender);
        _takeReward(msg.sender, pending);

        _unstake(amount);
        return true;
    }

    function rewardAmount(address _account) public view returns (uint256) {
        uint256 pending;
        UserInfo memory _user = userInfo[_account];
        if (_user.stakedOf > 0) {
            uint256 _accPerShare = accPerShare;
            uint256 _epoch_day = block.timestamp / bounsDuration;
            if (_epoch_day > lastBounsEpoch && startBonus) {
                _accPerShare += (getPendingReward() * 1e12) / totalStaked;
            }
            pending = ((_user.stakedOf * _accPerShare) / 1e12) - _user.rewardOf;
        }
        return pending;
    }

    function predictReward(address _account) public view returns (uint256) {
        uint256 pending;
        UserInfo memory _user = userInfo[_account];
        if (_user.stakedOf > 0) {
            uint256 _accPerShare = accPerShare;
            _accPerShare += (getPendingReward() * 1e12) / totalStaked;
            pending = ((_user.stakedOf * _accPerShare) / 1e12) - _user.rewardOf;
        }
        return pending;
    }

    function takeReward() external {
        _bonusReward();

        UserInfo storage user = userInfo[msg.sender];
        require(user.stakedOf > 0, "Staking: out of staked");
        uint256 pending = rewardAmount(msg.sender);
        require(pending > 0, "Staking: no pending reward");

        _takeReward(msg.sender, pending);
        if (
            user.duration > 0 &&
            (block.timestamp - user.lastStakedAt >= user.duration)
        ) {
            _unstake(user.stakedOf);
        }
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

    function _bonusReward() private {
        if (startBonus && totalStaked > 0) {
            uint256 _epoch_day = block.timestamp / bounsDuration;
            if (_epoch_day > lastBounsEpoch) {
                lastBounsEpoch = _epoch_day;
                lastBounsToken = getPendingReward();
                if (lastBounsToken > 0) {
                    totalUsedReward += lastBounsToken;
                    totalPendingReward += lastBounsToken;
                    accPerShare += (lastBounsToken * 1e12) / totalStaked;
                }
            }
        }
    }

    function _unstake(uint256 _amount) private {
        if (_amount > 0) {
            UserInfo storage user = userInfo[msg.sender];
            if (_amount > user.stakedOf) {
                _amount = user.stakedOf;
            }

            totalStaked -= _amount;
            user.stakedOf -= _amount;
            user.rewardOf = (user.stakedOf * accPerShare) / 1e12;
            TransferHelper.safeTransfer(tokenAddress, msg.sender, _amount);
            emit Unstaked(msg.sender, _amount);
        }
    }

    function _takeReward(address _account, uint256 pending) private {
        if (pending > 0) {
            UserInfo storage user = userInfo[_account];
            user.rewardOf = (user.stakedOf * accPerShare) / 1e12;
            safeTransferReward(_account, pending);

            //invite reward
            address _inviter = inviter[_account];
            takeInviteReward(_account, _inviter, pending, inviteRate1);
            takeInviteReward(_account, inviter[_inviter], pending, inviteRate2);
        }
    }

    function takeInviteReward(
        address _account,
        address _inviter,
        uint256 _amount,
        uint256 _rate
    ) private {
        if (_rate > 0 && _inviter != address(0)) {
            UserInfo memory user = userInfo[_account];
            UserInfo storage inviterUser = userInfo[_inviter];

            if (inviterUser.stakedOf > 0) {
                uint256 _reward = (_amount * _rate) / 1000;
                if (user.stakedOf > inviterUser.stakedOf) {
                    _reward = (_reward * inviterUser.stakedOf) / user.stakedOf;
                }

                uint256 _pending = totalReward - totalUsedReward;
                if (_reward > _pending) {
                    _reward = _pending;
                }

                totalUsedReward += _reward;
                inviterUser.inviteReward += _reward;
                TransferHelper.safeTransfer(tokenAddress, _inviter, _reward);
                emit InviteReward(_account, _inviter, _reward);
            }
        }
    }

    function safeTransferReward(address _account, uint256 _amount) private {
        if (_amount > 0) {
            if (_amount > totalPendingReward) {
                _amount = totalPendingReward;
            }
            UserInfo storage user = userInfo[_account];
            totalPendingReward -= _amount;
            user.userReward += _amount;
            TransferHelper.safeTransfer(tokenAddress, _account, _amount);
            emit Reward(_account, _amount);
        }
    }
}