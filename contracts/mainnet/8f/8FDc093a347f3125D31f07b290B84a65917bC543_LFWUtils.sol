// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface IPancakeInterface {
    function pendingReward(address _user) external view returns (uint256);
    function bonusEndBlock() external view returns (uint256);
    function lastRewardBlock() external view returns (uint256);
    function stakedToken() external view returns (address);
    function rewardToken() external view returns (address);
    struct UserInfo {
        uint256 amount; // How many staked tokens the user has provided
        uint256 rewardDebt; // Reward debt
    }
    function getUserAmountByAddress(address _user) external view returns (UserInfo memory user);
}

contract LFWUtils {
    uint256 public numParameters = 3;
    function getPancakeStakingInfo(
        address _scAddress, 
        address _userAddress
    ) public view returns(uint256[] memory pancakeStakingInfo) {
        pancakeStakingInfo = new uint256[](numParameters);
        IPancakeInterface.UserInfo memory userInfo;
        pancakeStakingInfo[0] = IPancakeInterface(_scAddress).pendingReward(_userAddress);
        pancakeStakingInfo[1] = IPancakeInterface(_scAddress).bonusEndBlock() - IPancakeInterface(_scAddress).lastRewardBlock();
        userInfo = IPancakeInterface(_scAddress).getUserAmountByAddress(_userAddress);
        pancakeStakingInfo[2] = userInfo.amount;
    }
}