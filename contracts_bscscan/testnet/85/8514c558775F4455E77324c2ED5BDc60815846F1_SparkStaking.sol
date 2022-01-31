/**
 *Submitted for verification at BscScan.com on 2022-01-31
*/

// SPDX-License-Identifier: MIT

// File: contracts/sparklab.sol

pragma solidity ^0.8.4;

contract SparkStaking {
    IBEP20 public rewardsToken;// Contract address of reward token
    IBEP20 public stakingToken;// Contract address of staking token 

    //declaring total staked
    uint256 public totalStaked;

    //users staking balance
    mapping(address => uint256) public stakingBalance;

    //mapping list of users who ever staked
    mapping(address => bool) public hasStaked;

    //mapping list of users who are staking at the moment
    mapping(address => bool) public isStakingAtm;
    

    //array of all stakers
    address[] public stakers;

    uint public rewardRate = 5; // Percentage for rewards
    address payable ownersAddress;

    mapping(address=>uint) public lastTimeUserStaked;


    constructor(address _stakingToken, address _rewardsToken, address administratorAddress) {
        stakingToken = IBEP20(_stakingToken);
        rewardsToken = IBEP20(_rewardsToken);
        ownersAddress = payable(administratorAddress);
    }

    //     //function to stake the token
    function stake(uint _amount) public {
    totalStaked = totalStaked + _amount;
     stakingBalance[msg.sender] = stakingBalance[msg.sender] + _amount;
        stakingToken.transferFrom(msg.sender, address(this), _amount *(10**18));
         //checking if user staked before or not, if NOT staked adding to array of stakers
        if (hasStaked[msg.sender] == false) {
            stakers.push(msg.sender);
            hasStaked[msg.sender] = true;
        }

        if(isStakingAtm[msg.sender] == false){
            lastTimeUserStaked[msg.sender] = block.timestamp;
        }
        //updating staking status
        isStakingAtm[msg.sender] = true;
    }

    function calculateUserRewards (address userAddress) public view returns(uint){
            if(isStakingAtm[userAddress] == true){
                uint lastTimeStaked = lastTimeUserStaked[userAddress];
                uint periodSpentStaking = block.timestamp - lastTimeStaked;
                uint numberOfDaysStaked = periodSpentStaking / 60 ;
                uint numberOfMonthsStaked = numberOfDaysStaked;
                uint userReward = numberOfMonthsStaked * rewardRate * stakingBalance[userAddress] / 100 * (10**18)  ;
                return userReward;
            }else{
                return 0;
            }
    }
  
  function calculateNumberOfMonthsStaked(address userAddress) public view returns(uint){
      if(isStakingAtm[userAddress] == true ){
          uint lastTimeStaked = lastTimeUserStaked[userAddress];
          uint remainingTime = block.timestamp  - lastTimeStaked;
          uint remainingDays  = remainingTime / 60;
          uint remainingMonths = remainingDays;
          return remainingMonths;
      }else{
          return 0;
      }
  }
        // Function to claim reward
    function claimReward() external {
        uint reward = calculateUserRewards(msg.sender);
        uint numberOfMonthsStaked = calculateNumberOfMonthsStaked(msg.sender);
        require(numberOfMonthsStaked > 0 , "You Can't Claim Rewards In Less than a Month");
        require(reward > 0, "Rewards is too small to be claimed");
        rewardsToken.transfer(msg.sender, reward * (10**18));
        stakingToken.transfer(msg.sender, stakingBalance[msg.sender] * (10**18));
        totalStaked = totalStaked  - stakingBalance[msg.sender];
        stakingBalance[msg.sender]  = 0;
        isStakingAtm[msg.sender] =  false;
    }

    function changeAdminAddress(address payable newAdminAddress) public payable{
     require(msg.sender == ownersAddress, "UnAuthorized to take this action");
        ownersAddress = newAdminAddress;
    }

    function ChangeRewards(uint newRewardRate) public {
    require(ownersAddress == msg.sender, "User Not Authorized");
    rewardRate =  newRewardRate;

}

}




interface IBEP20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}