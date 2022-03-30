/**
 *Submitted for verification at BscScan.com on 2022-03-30
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.7;

interface poolContract {
    function startBlock() external view returns (uint256 startBlock);
    function bonusEndBlock() external view returns (uint256 bonusEndBlock);
    function rewardPerBlock() external view returns (uint256 rewardPerBlock);
    function totalStaked() external view returns (uint256 totalStaked);
    function rewardToken() external view returns (address rewardToken);

    function userInfo(address _user) external view returns (uint256 amount, uint256 rewardDebt);
    function pendingReward(address _user) external view returns (uint256 pendingReward);
}
interface token{
     function balanceOf(address account) external view returns (uint256);
}



contract PoolCollection  {
    
    function getTotalStaked(address Pool) public view returns (uint256 TS) {
        address _token = poolContract(Pool).rewardToken();
        try poolContract(Pool).totalStaked(){TS = poolContract(Pool).totalStaked();}catch{TS = token(_token).balanceOf(Pool);}
    }

    function poolInfo(address Pool) public view returns (uint256 start, uint256 end, uint256 rwpb, uint256 ts) {
        start = poolContract(Pool).startBlock();
        end = poolContract(Pool).bonusEndBlock();
        rwpb = poolContract(Pool).rewardPerBlock();
        ts = getTotalStaked(Pool);
    }

    function userInfo(address Pool, address User) public view returns (uint256 amount, uint256 pendingReward) {
        (amount,) = poolContract(Pool).userInfo(User);
        pendingReward = poolContract(Pool).pendingReward(User);
    }

    function getManyPoolInfo(address[] memory Pool) external view returns (uint256[] memory start, uint256[] memory end, uint256[] memory rwpb, uint256[] memory ts) {
        for (uint i = 0; i < Pool.length; i++) {
            (start[i], end[i], rwpb[i], ts[i]) = poolInfo(Pool[i]);
        }
    }

    function getManyUserInfo(address[] memory Pool, address User) public view returns (uint256[] memory amount, uint256[] memory pendingReward) {
        for (uint i = 0; i < Pool.length; i++) {
            (amount[i], pendingReward[i]) = userInfo(Pool[i], User);
        }
    }
}