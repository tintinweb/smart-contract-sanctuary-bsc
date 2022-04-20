/**
 *Submitted for verification at BscScan.com on 2022-04-20
*/

// SPDX-License-Identifier: MIT


pragma solidity ^0.8.4;

    contract EverForkCoinStaking {
    IBEP20 public rewardsToken;
    IBEP20 public stakingToken;


    uint256 public totalStaked;

    mapping(address => uint256) public stakingBalance;

    mapping(address => bool) public hasStaked;

    mapping(address => bool) public isStakingNow;

    uint public interestRate = 784 ;

    uint public stakingPeriod = 365;
    

    address[] public stakers;

    address payable adminAddress;

    uint public taxPercentage = 5;

    mapping(address=>uint) public lastTimeUserStaked;


    constructor(address _stakingToken, address _rewardsToken, address administratorAddress) {
        stakingToken = IBEP20(_stakingToken);
        rewardsToken = IBEP20(_rewardsToken);
        adminAddress = payable(administratorAddress);
    }

    function stake(uint _amount) public {
    totalStaked = totalStaked + _amount;
     stakingBalance[msg.sender] = stakingBalance[msg.sender] + _amount;
        stakingToken.transferFrom(msg.sender, address(this), _amount * (10**9));
        if (hasStaked[msg.sender] == false) {
            stakers.push(msg.sender);
            hasStaked[msg.sender] = true;
        }

        if(isStakingNow[msg.sender] == false){
            lastTimeUserStaked[msg.sender] = block.timestamp;
        }
        isStakingNow[msg.sender] = true;
    }

    function calculateUserReturns (address userAddress) public view returns(uint){
            if(isStakingNow[userAddress] == true){
                uint numberOfDaysStaked = calculateNumberOfDaysStaked(userAddress);
            // uint userReturns = stakingBalance[userAddress];
            uint userBalance = stakingBalance[userAddress] * (10 **9 );


            for(uint i =0; i< numberOfDaysStaked; i++){
                userBalance  = userBalance + userBalance * interestRate / 100 / stakingPeriod;
            }

            return userBalance - (stakingBalance[msg.sender] * (10**9)) ;


            }else{
                return 0;
            }
    }

    function calculateExitFee (uint daysStaked)public pure returns(uint){
        uint exitFee;
        if (daysStaked >= 30 ){
            exitFee = 10;
        }
        else if (daysStaked < 30 && daysStaked > 7 ){
            exitFee = 15;
        }
        else if (daysStaked <= 7){
            exitFee = 30;
        }

        return exitFee;
    }


  
  function calculateNumberOfDaysStaked(address userAddress) public view returns(uint){
      if(isStakingNow[userAddress] == true ){
          uint lastTimeStaked = lastTimeUserStaked[userAddress];
          uint remainingTime = block.timestamp  - lastTimeStaked;
          uint remainingDays  = remainingTime / 86400 ;
          return remainingDays;
      }else{
          return 0;
      }
  }
    function claimReturns() external {
        uint reward = calculateUserReturns(msg.sender);
        uint numberOfDaysStaked = calculateNumberOfDaysStaked(msg.sender);
        require(numberOfDaysStaked > 0 , "Can't unstake in less than a day");
        require(reward > 0, "Rewards is too small to be claimed");
        uint totalToBePayed = stakingBalance[msg.sender]  + (reward / (10**9));
        require(rewardsToken.balanceOf(address(this)) / (10**9)  - totalToBePayed   >= totalStaked, "Can't collect rewards, when contract has low balance");
        uint rewardTax = (reward * calculateExitFee(numberOfDaysStaked)) / 100;
        uint stakingTax = (stakingBalance[msg.sender] * taxPercentage) / 100;
        rewardsToken.transfer(msg.sender, reward - rewardTax );
        stakingToken.transfer(msg.sender, (stakingBalance[msg.sender] - stakingTax) * (10**9));
        totalStaked = totalStaked  - stakingBalance[msg.sender];
        stakingBalance[msg.sender]  = 0;
        isStakingNow[msg.sender] =  false;
    }

    function replaceAdminAddress(address payable newAddress) public payable{
     require(msg.sender == adminAddress, "You need to be the admin to change admin Address");
        adminAddress = newAddress;
    }

    function EditInterestRate(uint newRewardRate) public {
    require(adminAddress == msg.sender, "Not Authorized for this action");
    interestRate =  newRewardRate;

}

function UnstakeTokenUrgently() public {
    require(isStakingNow[msg.sender] == true, "You currently don't have any tokens staked");
    stakingToken.transfer(msg.sender, stakingBalance[msg.sender] * (10**9));
    stakingBalance[msg.sender]  = 0;
    isStakingNow[msg.sender] =  false;
    totalStaked = totalStaked - stakingBalance[msg.sender];
}



    function getTotalStaked() public view returns(uint256){
                return totalStaked;
        }

    function getUserStakingBalance(address userAddress) public view returns (uint){
            return stakingBalance[userAddress];
        }

    function getInterestRate() public view returns (uint){
        return interestRate;

        }

 
 function changeTaxPercentage(uint newTaxPercentage) public {
     require(msg.sender == adminAddress, "Not an Admin");
     taxPercentage = newTaxPercentage;
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