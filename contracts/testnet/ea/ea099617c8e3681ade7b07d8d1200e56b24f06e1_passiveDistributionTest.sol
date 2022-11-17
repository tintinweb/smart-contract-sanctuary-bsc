/**
 *Submitted for verification at BscScan.com on 2022-11-17
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

contract passiveDistributionTest {

    mapping(address => bool) public validator;
    mapping(address => uint) public totalStakedForValidator;
    mapping(address => uint) public totalValidatorReward;

    // staker => validator => lastRewardTime
    mapping(address => mapping(address => uint)) public stakeTime;
    // staker => validator => lastRewardTime
    mapping(address => mapping(address => uint)) public stakedAmount;    
    //validator => LastRewardtime
    mapping( address => uint) public lastRewardTime;
    //validator => lastRewardTime => reflectionPerent
    mapping(address => mapping( uint => uint )) public reflectionPercentSum;




    function stake(address _validator) public payable returns(bool) {
        require(validator[_validator], "not a validator");
        totalStakedForValidator[_validator] += msg.value;
        if(stakedAmount[msg.sender][_validator] > 0 ) withdrawStakeReward(_validator);
        else stakeTime[msg.sender][_validator] = lastRewardTime[_validator];
        stakedAmount[msg.sender][_validator] += msg.value;
        return true;
    }

     function unstake(address _validator) public returns(bool) {
        require(validator[_validator], "not a validator");
        uint sA = stakedAmount[msg.sender][_validator];
        require( sA > 0, "nothing staked");
        withdrawStakeReward(_validator);
        stakedAmount[msg.sender][_validator] = 0;
        stakeTime[msg.sender][_validator] = 0;
        payable(msg.sender).transfer(sA);        
        return true;
    }


    function newValidator(address _validator) public returns (bool){
        require(!validator[_validator], "already a validator");
        validator[_validator] = true;
        lastRewardTime[_validator] = block.timestamp;
        return true;
    }

    function calculateReflectionPercent(uint _totalAmount, uint _rewardAmount) private pure returns(uint){
        return (_rewardAmount * 100000000000000000000 / _totalAmount) / 1000000000000;
    }

    function distributeReward(address _validator) public payable returns (bool){
        require(validator[_validator], "not a validator");
        require(msg.value > 0 , "invalid reward");
        totalValidatorReward[_validator] += msg.value/2;

        uint lastRewardHold = reflectionPercentSum[_validator][lastRewardTime[_validator]];
        lastRewardTime[_validator] = block.timestamp;
        reflectionPercentSum[_validator][lastRewardTime[_validator]] = lastRewardHold + calculateReflectionPercent(totalStakedForValidator[_validator], msg.value/2);


        return true;
    }

    function withdrawStakeReward(address _validator) public returns (bool){
        require(stakeTime[msg.sender][_validator] > 0 , "nothing staked");
        require(stakeTime[msg.sender][_validator] < lastRewardTime[_validator], "no reward yet");

        uint validPercent = reflectionPercentSum[_validator][lastRewardTime[_validator]] - reflectionPercentSum[_validator][stakeTime[msg.sender][_validator]];
        require(validPercent > 0, "still no reward");
        stakeTime[msg.sender][_validator] = lastRewardTime[_validator];
        uint reward = stakedAmount[msg.sender][_validator] * validPercent / 100000000  ;
        payable(msg.sender).transfer(reward);    
        return true;
    }

    function withdrawValidatorReward() public returns (bool){
        require(validator[msg.sender], "not a validator");
        uint amount = totalValidatorReward[msg.sender];
        require(amount > 0, "no reward yet");
        payable(msg.sender).transfer(amount);
        return true;
    }

    function viewStakeReward(address _staker, address _validator) public view returns(uint){
        
        uint validPercent = reflectionPercentSum[_validator][lastRewardTime[_validator]] - reflectionPercentSum[_validator][stakeTime[_staker][_validator]];

        uint reward = stakedAmount[_staker][_validator] * validPercent / 100000000  ;   
        return reward;
    }

}