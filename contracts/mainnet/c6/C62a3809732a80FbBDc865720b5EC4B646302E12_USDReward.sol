// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

interface IUSD {
    function owner() external view returns (address);

    function stakeTo() external view returns (address);

    function inviter(address account_) external view returns (address);
}

interface IDepositUSD {
    function takeReward(
        address token_,
        string memory usefor,
        address account_,
        uint256 amount_
    ) external;

    function getReward(address token_, string memory usefor)
        external
        view
        returns (uint256);
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
}

interface IStaking is StakeInfo {
    function userInfo(address token, address _account)
        external
        view
        returns (UserInfo memory _user);
}

interface ILiteReward {
    function updateStaked(
        address token,
        address account,
        uint256 beforeStaked,
        uint256 afterStaked
    ) external;
}

contract USDReward is StakeInfo {
    address public constant usdAddress =
        0x1F20F26a747916FaB87C1Fe342fa4FA787f2B2BF;
    address public constant depositAddress =
        0xc336FCe58F75eEF3E2ca130Ee79851cD1A8Da5De;

    address public liteRewardAddress;
    uint256 public rewardRate1 = 100; // 奖励比例1 100/1000
    uint256 public rewardRate2 = 50; // 奖励比例2 50/1000

    modifier onlyStakeTo() {
        require(msg.sender == stakeTo(), "caller can not be allowed");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner(), "caller is not owner");
        _;
    }

    function setRewardRate(uint256 _rewardRate1, uint256 _rewardRate2)
        external
        onlyOwner
    {
        rewardRate1 = _rewardRate1;
        rewardRate2 = _rewardRate2;
    }

    function setLiteRewardAddress(address _liteRewardAddress)
        external
        onlyOwner
    {
        liteRewardAddress = _liteRewardAddress;
    }

    function updateStaked(
        address token,
        address account,
        uint256 beforeStaked,
        uint256 afterStaked
    ) external onlyStakeTo {
        if (liteRewardAddress != address(0)) {
            ILiteReward(liteRewardAddress).updateStaked(
                token,
                account,
                beforeStaked,
                afterStaked
            );
        }
    }

    function takeReward(
        address token,
        address account,
        uint256 amount
    ) external onlyStakeTo {
        address _invite = IUSD(usdAddress).inviter(account);
        if (_invite != address(0) && rewardRate1 > 0) {
            UserInfo memory _user = IStaking(stakeTo()).userInfo(
                token,
                account
            );
            uint256 _stakedOf = _user.stakedOf;
            if (_stakedOf > 0) {
                _inviteReward(token, _invite, _stakedOf, amount, rewardRate1);

                address _invite2 = IUSD(usdAddress).inviter(_invite);
                if (_invite2 != address(0) && rewardRate2 > 0) {
                    _inviteReward(
                        token,
                        _invite2,
                        _stakedOf,
                        amount,
                        rewardRate2
                    );
                }
            }
        }
    }

    function _inviteReward(
        address token,
        address _invite,
        uint256 _stakedOf,
        uint256 amount,
        uint256 rate
    ) private {
        uint256 _allReward = IDepositUSD(depositAddress).getReward(
            usdAddress,
            "invite"
        );
        if (_allReward > 0) {
            UserInfo memory _user = IStaking(stakeTo()).userInfo(
                token,
                _invite
            );
            uint256 _inviteStakedOf = _user.stakedOf;
            if (_inviteStakedOf > 0) {
                uint256 _reward = (amount * rate) / 1000;
                if (_inviteStakedOf < _stakedOf) {
                    _reward = (_reward * _inviteStakedOf) / _stakedOf;
                }

                if (_reward > _allReward) {
                    _reward = _allReward;
                }

                IDepositUSD(depositAddress).takeReward(
                    usdAddress,
                    "invite",
                    _invite,
                    _reward
                );
            }
        }
    }

    function owner() public view returns (address) {
        return IUSD(usdAddress).owner();
    }

    function stakeTo() public view returns (address) {
        return IUSD(usdAddress).stakeTo();
    }
}