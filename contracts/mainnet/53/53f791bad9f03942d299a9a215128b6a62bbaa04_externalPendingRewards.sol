/**
 *Submitted for verification at BscScan.com on 2023-01-29
*/

// Contract to read pending rewards from MasterChef and ReflectorChef contracts
// 
//
// @MikeMurpher

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IExternalMasterChef{
    function poolLength() external view returns (uint256);
    function pendingPrint(uint256 _pid, address _user) external view returns (uint256);
}

interface IExternalReflectorChef{
    function poolLength() external view returns (uint256);
    function pendingRCollector(uint256 _pid, address _user) external view returns (uint256);
}

contract externalPendingRewards {

    function pendingRewardsMasterChef(address _externalChefAddress, address _userAddress) public view returns (uint256) {
        require(_externalChefAddress != address(0) && _userAddress != address(0), "Address cannot be null");
        IExternalMasterChef externalMasterChef = IExternalMasterChef(_externalChefAddress);
        uint256 poolLengthFromMasterChef = externalMasterChef.poolLength();
        uint256[] memory userPools = new uint256[](poolLengthFromMasterChef);
        uint256[] memory userPendingRewards = new uint256[](poolLengthFromMasterChef);
        uint256 total = 0;

        for (uint i = 0; i < poolLengthFromMasterChef; i++) {
            uint256 pendingRewards = externalMasterChef.pendingPrint(i, _userAddress);

            if (pendingRewards>0){
                userPools[i] = i;
                userPendingRewards[i]= pendingRewards;
                total += userPendingRewards[i];
            }
        }

        return total;
    }

        function pendingRewardsReflectorChef(address _externalChefAddress, address _userAddress) public view returns (uint256) {
        require(_externalChefAddress != address(0) && _userAddress != address(0), "Address cannot be null");
        IExternalReflectorChef externalReflectorChef = IExternalReflectorChef(_externalChefAddress);
        uint256 poolLengthFromReflectorChef = externalReflectorChef.poolLength();
        uint256[] memory userPools = new uint256[](poolLengthFromReflectorChef);
        uint256[] memory userPendingRewards = new uint256[](poolLengthFromReflectorChef);
        uint256 total = 0;

        for (uint i = 0; i < poolLengthFromReflectorChef; i++) {
            uint256 pendingRewards = externalReflectorChef.pendingRCollector(i, _userAddress);

            if (pendingRewards>0){
                userPools[i] = i;
                userPendingRewards[i]= pendingRewards;
                total += userPendingRewards[i];
            }
        }

        return total;
    }
}