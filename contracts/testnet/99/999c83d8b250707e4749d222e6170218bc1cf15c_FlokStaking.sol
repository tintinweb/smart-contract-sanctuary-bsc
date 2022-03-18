/**
 *Submitted for verification at BscScan.com on 2022-03-18
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

contract FlokStaking {
    IBEP20 public rewardsToken;
    IBEP20 public stakingToken;

    uint256 public totalStaked;

    mapping(address => uint256) public stakingBalance;

    mapping(address => bool) public hasStaked;

    mapping(address => bool) public isStakingAtm;

    uint stakingPeriod = 2;
    

    address[] public stakers;

    uint public rewardRate = 10; 
    address payable ownersAddress;

    mapping(address=>uint) public lastTimeUserStaked;


    constructor(address _stakingToken, address _rewardsToken, address administratorAddress) {
        stakingToken = IBEP20(_stakingToken);
        rewardsToken = IBEP20(_rewardsToken);
        ownersAddress = payable(administratorAddress);
    }

    function stake(uint _amount) public {
    totalStaked = totalStaked + _amount;
     stakingBalance[msg.sender] = stakingBalance[msg.sender] + _amount;
        stakingToken.transferFrom(msg.sender, address(this), _amount *(10**18));
        if (hasStaked[msg.sender] == false) {
            stakers.push(msg.sender);
            hasStaked[msg.sender] = true;
        }

        if(isStakingAtm[msg.sender] == false){
            lastTimeUserStaked[msg.sender] = block.timestamp;
        }
        isStakingAtm[msg.sender] = true;
    }

    function calculateUserRewards (address userAddress) public view returns(uint){
            if(isStakingAtm[userAddress] == true){
                uint numberOfDaysStaked = calculateNumberOfDaysStaked(userAddress);
                uint userReward =   (10**18) * rewardRate * stakingBalance[userAddress] * numberOfDaysStaked / stakingPeriod / 100 ;
                return userReward;
            }else{
                return 0;
            }
    }
  
  function calculateNumberOfDaysStaked(address userAddress) public view returns(uint){
      if(isStakingAtm[userAddress] == true ){
          uint lastTimeStaked = lastTimeUserStaked[userAddress];
          uint remainingTime = block.timestamp  - lastTimeStaked;
          uint remainingDays  = remainingTime / 60;
          return remainingDays;
      }else{
          return 0;
      }
  }
    function claimReward() external {
        uint reward = calculateUserRewards(msg.sender);
        uint numberOfDaysStaked = calculateNumberOfDaysStaked(msg.sender);
        require(numberOfDaysStaked > 0 , "Can't unstake in less than a day");
        require(reward > 0, "Rewards is too small to be claimed");
        rewardsToken.transfer(msg.sender, reward);
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

    function getTotalStaked() public view returns(uint){
                return totalStaked;
        }

    function getUserStakingBalance(address userAddress) public view returns (uint){
            return stakingBalance[userAddress];
        }

    function getRewardRate() public view returns (uint){
        return rewardRate;
        }

    function changeStakingDays(uint newStakingDays) public {
        require(msg.sender == ownersAddress, "Not Authorized");
            stakingPeriod = newStakingDays;
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