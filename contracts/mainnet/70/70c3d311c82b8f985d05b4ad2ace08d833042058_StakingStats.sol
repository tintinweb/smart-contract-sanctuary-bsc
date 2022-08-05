/**
 *Submitted for verification at BscScan.com on 2022-08-05
*/

// Code written by MrGreenCrypto
// SPDX-License-Identifier: None
pragma solidity 0.8.15;

interface StakingContract{
    function getStake(address account) external view returns (uint256);
    function getTotalClaimsOfStaker(address staker) external view returns (uint256);
    function claimableRewards(address staker) external view returns (uint256);
}

contract StakingStats {
    StakingContract staking = StakingContract(0x48599344769427b0B25845d9D1719049B5F83F9b);

	constructor(){}

    function getStats(address staker) public view returns (uint256, uint256, uint256) {
        uint256 staked = staking.getStake(staker);
        uint256 claimed = staking.getTotalClaimsOfStaker(staker);
        uint256 claimable = staking.claimableRewards(staker);
        return (staked, claimed, claimable);
    }
}