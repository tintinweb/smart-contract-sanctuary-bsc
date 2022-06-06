/**
 * @title Reward Pool
 * @dev RewardPool contract
 *
 * @author - <USDFI TRUST>
 * for the USDFI Trust
 *
 * SPDX-License-Identifier: Business Source License 1.1
 *
 **/

import "./Manager.sol";
import "./ReentrancyGuard.sol";

pragma solidity 0.6.12;

contract RewardPool is Manager, ReentrancyGuard {
    constructor(
        address _stakingCoinAddress,
        address _rewardCoinAddress,
        address _vaultAddress
    ) public {
        stakingCoinAddress = _stakingCoinAddress;
        rewardCoinAddress = _rewardCoinAddress;
        vaultAddress = _vaultAddress;
    }

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 _amount);
    event Withdrawn(address indexed user, uint256 _amount);
    event RewardPaid(address indexed user, uint256 _reward);

    modifier updateReward(address _account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (_account != address(0)) {
            rewards[_account] = earned(_account);
            userRewardPerTokenPaid[_account] = rewardPerTokenStored;
        }
        _;
    }

    // last time reward applicable
    function lastTimeRewardApplicable() public view returns (uint256) {
        return SafeMath.min(block.timestamp, periodFinish);
    }

    // reward per staked token
    function rewardPerToken() public view returns (uint256) {
        if (totalSupply() == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored.add(
                lastTimeRewardApplicable()
                    .sub(lastUpdateTime)
                    .mul(rewardRate)
                    .mul(1e18)
                    .div(totalSupply())
            );
    }

    // reward per staked token without ref fees
    function rewardPerTokenWithoutRef() public view returns (uint256) {
        if (totalSupply() == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored.add(
                lastTimeRewardApplicable()
                    .sub(lastUpdateTime)
                    .mul(rewardRate)
                    .mul(1e18)
                    .div(totalSupply())
                    .div(100000)
                    .mul(normalPercent)
            );
    }

    // how much reward earned this address
    function earned(address _account) public view returns (uint256) {
        return
            balanceOf(_account)
                .mul(rewardPerToken().sub(userRewardPerTokenPaid[_account]))
                .div(1e18)
                .add(rewards[_account]);
    }

    // how much reward earned this address without ref fees
    function earnedWithoutRef(address _account) public view returns (uint256) {
        return
            balanceOf(_account)
                .mul(rewardPerToken().sub(userRewardPerTokenPaid[_account]))
                .div(1e18)
                .add(rewards[_account])
                .div(100000)
                .mul(normalPercent);
    }

    // stake visibility is public as overriding LPTokenWrapper's stake() function
    function stake(uint256 _amount, address _sponsor)
        public
        override
        updateReward(msg.sender)
        nonReentrant
    {
        require(_amount > 0, "Cannot stake 0");
        super.stake(_amount, _sponsor);
        emit Staked(msg.sender, _amount);
    }

    // withdraw "staking coin" from the pool (when the address is in the withdraw time or accept the penalty fee)
    function withdraw(uint256 _amount)
        public
        override
        updateReward(msg.sender)
        nonReentrant
    {
        require(_amount > 0, "Cannot withdraw 0");
        super.withdraw(_amount);
        emit Withdrawn(msg.sender, _amount);
        notifyRewardAmount();
    }

    // emergency withdraw "staking coin" from the pool #SAFU
    function emergencyWithdraw(uint256 _amount)
        public
        override
        updateReward(msg.sender)
        nonReentrant
    {
        require(_amount > 0, "Cannot withdraw 0");
        super.emergencyWithdraw(_amount);
        emit Withdrawn(msg.sender, _amount);
    }

    // withdraw "staking coin" from the pool and claim rewards
    function exit() external {
        withdraw(balanceOf(msg.sender));
        getReward();
    }

    // claim rewards
    function getReward() public updateReward(msg.sender) nonReentrant {
        notifyRewardAmount();

        if (ProxyTrigger == true) {
            Proxy.triggerProxy(); // this should later contribute to the decentralization of the project
        }

        uint256 reward = earned(msg.sender);
        if (reward > 0) {
            rewards[msg.sender] = 0;
            uint256 refReward = reward.div(100000).mul(refRewardFee);
            reward = reward.sub(refReward);
            IERC20(rewardCoinAddress).safeTransfer(msg.sender, reward);
            address sponsor = referrals.getSponsor(msg.sender);
            emit RewardPaid(msg.sender, reward.add(refReward));

            uint256 i = 0;
            while (i < refLevelReward.length) {
                IERC20(rewardCoinAddress).safeTransfer(
                    sponsor,
                    refReward.div(100000).mul(refLevelReward[i])
                );
                sponsor = referrals.getSponsor(sponsor);
                i++;
            }
        }
    }

    // add new rewards
    function notifyRewardAmount() internal updateReward(address(0)) {
        if (block.timestamp >= nextRewardTime) {
            nextRewardTime = block.timestamp.add(87000);

            uint256 reward = IERC20(rewardCoinAddress).balanceOf(vaultAddress);
            if (reward > 0) {
                IERC20(rewardCoinAddress).safeTransferFrom(
                    vaultAddress,
                    address(this),
                    reward
                );

                reward = reward.div(100000).mul(rewardCoinFee);
                ReceivedRewardCoins = ReceivedRewardCoins.add(reward);

                if (block.timestamp >= periodFinish) {
                    rewardRate = reward.div(DURATION);
                } else {
                    uint256 remaining = periodFinish.sub(block.timestamp);
                    uint256 leftover = remaining.mul(rewardRate);
                    rewardRate = reward.add(leftover).div(DURATION);
                }
                lastUpdateTime = block.timestamp;
                periodFinish = block.timestamp.add(DURATION);
                emit RewardAdded(reward);
            }
        }
    }

    // request a withdraw and activate the lock time
    function requestWithdraw() public {
        requestedWithdrawTime[msg.sender] = block.timestamp;
    }

    // time remaining until a withdraw can be executed
    function remainingTimeToWithdraw(address _account)
        public
        view
        returns (uint256)
    {
        uint256 endTime = requestedWithdrawTime[_account].add(lockTime);
        if (block.timestamp < endTime) {
            return endTime.sub(block.timestamp);
        } else {
            return 0;
        }
    }

    // remaining time until a withdraw can no longer be executed
    function remainingTimeToLock(address _account)
        public
        view
        returns (uint256)
    {
        uint256 endTime = requestedWithdrawTime[_account].add(lockTime).add(
            freeTime
        );
        if (block.timestamp < endTime) {
            return endTime.sub(block.timestamp);
        } else {
            return 0;
        }
    }

    function canWithdraw(address _account) public view returns (bool) {
        if (
            block.timestamp > requestedWithdrawTime[_account].add(lockTime) &&
            block.timestamp <
            requestedWithdrawTime[_account].add(lockTime).add(freeTime)
        ) {
            return true;
        } else {
            return false;
        }
    }
}