/**
 *Submitted for verification at BscScan.com on 2022-05-05
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract testContract{
    uint256 public totalStakeLockedValue = 100 * 10 ** 18;
    uint256 public rewardPoolBalance = 100 * 10 ** 18;
    uint256 public magnitude = 1000000000000000000;
    
    uint256 public minAPR = 18;
    uint256 public rewardsTimeBlock = 5760; //considering 15 seconds block
    uint256 totalBlocksPerYear = rewardsTimeBlock * 365;

    mapping (address => uint256) public userStakes;
    mapping (address => uint256) public lastReawardClaimedTime;
    
    constructor() {
        userStakes[msg.sender] = 30 * 10 ** 18;
        lastReawardClaimedTime[msg.sender] = 1648922458;
    }

    function getShare(uint256 _stakeBalance) public view returns(uint256){
        return ((_stakeBalance * 100)/totalStakeLockedValue);
    }

    //uint256 totalStakeLockedValue = 100;

    function setVals(uint256 _rewardPoolBalance, uint256 _totalStakeLockedValue) public {
        rewardPoolBalance = _rewardPoolBalance * 10 ** 18;
        totalStakeLockedValue = _totalStakeLockedValue * 10 ** 18;
    }

    function setUserStake(uint256 _amount) public {
        userStakes[msg.sender] = _amount * 10 ** 18;
        //totalStakeLockedValue = _totalStakeLockedValue * 10 ** 18;
    }

    function setRewardPoolBalance(uint256 _rewardPoolBalance) public {
        rewardPoolBalance = _rewardPoolBalance * 10 ** 18;
    }

    function setTotalStakeLockedValue(uint256 _totalStakeLockedValue) public {
        totalStakeLockedValue = _totalStakeLockedValue * 10 ** 18;
    }

    function getAPR() public view returns(uint256){
        uint256 actualAPR = (((rewardPoolBalance * magnitude) / totalStakeLockedValue)*100)/magnitude;
       /*
        uint256 actualAPR;
        if(rewardPoolBalance > totalStakeLockedValue){
            actualAPR  = (((rewardPoolBalance * magnitude) / totalStakeLockedValue)*100)/magnitude;
        }else{
            actualAPR = (((rewardPoolBalance * magnitude) / totalStakeLockedValue)*100)/(magnitude * 10);
        }
        */
        //uint256 actualAPR = (((rewardPoolBalance) / totalStakeLockedValue)*100);
        //return actualAPR;
        
        if(rewardPoolBalance >= totalStakeLockedValue){
            return actualAPR;
        }else{
            return minAPR;
        }
        /*
        if(rewardPoolBalance < totalStakeLockedValue) {
            return minAPR;
        }else if(rewardPoolBalance <= ((totalStakeLockedValue * minAPR)/100)) {
            return minAPR;
        }else if((((rewardPoolBalance * magnitude / totalStakeLockedValue)*100)/magnitude) >= minAPR){
            return ((rewardPoolBalance * magnitude /totalStakeLockedValue)*100)/magnitude;
        }else{
            return minAPR;
        }
        */

        //uint256 APR = (rewardPoolBalance / totalStakeLockedValue)*100;
        //return APR;
    }

    function setRewardsClaimTime(uint _timestamp) public {
        lastReawardClaimedTime[msg.sender] = _timestamp;
    }

    function getElapsedTime() public view returns(uint256){
        uint256 reawardClaimedTime = lastReawardClaimedTime[msg.sender];
        return (block.timestamp - reawardClaimedTime) / 1 days;
    }

    function getRewardsPerYear() public view returns(uint256){
        return (userStakes[msg.sender] * getAPR())/100;
    }

    function getUnclaimedRewards() public view returns(uint256){
        uint256 rewardsPerYear = (userStakes[msg.sender] * getAPR())/100;
        //uint256 reawardClaimedTime = lastReawardClaimedTime[msg.sender];
        uint256 lapsedTime = (block.timestamp - lastReawardClaimedTime[msg.sender]) / 1 days;
        uint256 lapsedBlocksDuration = lapsedTime * 5760; // considering each block of 15 seconds
        

        uint256 unclaimedRewards = (rewardsPerYear * ((lapsedBlocksDuration * magnitude) / totalBlocksPerYear))/magnitude;
        //return (rewardsPerYear,lapsedTime,lapsedBlocksDuration,totalBlocksPerYear,unclaimedRewards);
        return (unclaimedRewards);
    }
}