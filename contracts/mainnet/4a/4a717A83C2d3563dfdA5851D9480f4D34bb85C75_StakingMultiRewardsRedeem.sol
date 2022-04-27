pragma solidity ^0.8.7;

import * as stakingInterface from "./../../reward-distribution/interface/IStaking.sol";
import * as rewardsInterface from "./../../reward-distribution/interface/IPendingRewardProvider.sol";

contract StakingMultiRewardsRedeem {
    address stakingAddress;
    address token;

    constructor(address stakingContract, address _token) {
        stakingAddress = stakingContract;
        token = _token;
    }

    function withdrawMulti(address[] memory list) external {
        stakingInterface.IStaking staking = stakingInterface.IStaking(stakingAddress);
        rewardsInterface.IPendingRewardProvider rewards = rewardsInterface.IPendingRewardProvider(stakingAddress);
        uint256 lastRound = staking.currentRound();
        for (uint256 i = 0; i <= list.length; i++) {
            address current = list[i];
            uint256 lastAddressRound = staking.getLastClaimedRound(current);
            if (lastAddressRound >= lastRound)
                continue;
            uint256 tokenRewards = staking.pendingReflections(token, current);
            if (tokenRewards > 0) {
                staking.claimPendingReflectionsFor(current);
            }
            uint256 pendingToken = rewards.getPendingRewards(token, current);
            uint256 pendingNative = rewards.getPendingRewards(address(0), current);
            if (pendingToken > 0)
                rewards.withdrawTokenRewardForReceiver(token, current);
            if (pendingNative > 0)
                rewards.withdrawTokenRewardForReceiver(address(0), current);
        }
    }

    function currentRoundTest(address[] memory list) public view returns(uint256) {
        return stakingInterface.IStaking(stakingAddress).currentRound();
    }

    function getLastClaimedRoundTest(address[] memory list) public view returns(uint256) {
        for (uint256 i = 0; i <= list.length; i++) {
            address current = list[i];
            stakingInterface.IStaking(stakingAddress).getLastClaimedRound(current);
        }
        return 0;
    }

    function claimPendingReflectionsFor(address[] memory list) public view returns(uint256) {
        for (uint256 i = 0; i <= list.length; i++) {
            address current = list[i];
            stakingInterface.IStaking(stakingAddress).pendingReflections(token, current);
        }
        return 0;
    }

     function pendingReflectionsTest(address[] memory list) public view returns(uint256) {
        for (uint256 i = 0; i <= list.length; i++) {
            address current = list[i];
            stakingInterface.IStaking(stakingAddress).pendingReflections(token, current);
        }
        return 0;
    }

    function claimPendingReflectionsForTest(address[] memory list) public {
        for (uint256 i = 0; i <= list.length; i++) {
            address current = list[i];
            stakingInterface.IStaking(stakingAddress).claimPendingReflectionsFor(current);
        }
    }

    function withdrawTokenRewardForReceiverTokenTest(address[] memory list) public {
        for (uint256 i = 0; i <= list.length; i++) {
            address current = list[i];
            rewardsInterface.IPendingRewardProvider(stakingAddress).withdrawTokenRewardForReceiver(token, current);
        }
    }

    function withdrawTokenRewardForReceiverNativeTest(address[] memory list) public {
        for (uint256 i = 0; i <= list.length; i++) {
            address current = list[i];
            rewardsInterface.IPendingRewardProvider(stakingAddress).withdrawTokenRewardForReceiver(address(0), current);
        }
    }
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

interface IStaking {
    function roundCanBeIncremented() external view returns (bool); 
    function incrementRound() external;
    function currentRound() external view returns (uint256);

    function getLastClaimedRound(address token) external view returns (uint256);
    function pendingReflections(address token, address account) external view returns (uint256);
    function claimPendingReflectionsFor(address account) external;
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

interface IPendingRewardProvider {
    function getRewardTokens() external view returns(address[] memory);
    function getPendingRewards(address rewardToken, address receiver) external view returns(uint256);
    function withdrawTokenRewards(address rewardToken) external;
    function withdrawTokenRewardForReceiver(address rewardToken, address receiver) external;
}