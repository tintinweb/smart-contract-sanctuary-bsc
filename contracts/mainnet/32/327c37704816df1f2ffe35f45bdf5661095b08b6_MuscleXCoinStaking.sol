// SPDX-License-Identifier: MIT

import "./Ownable.sol";

pragma solidity ^0.8.4;

contract   MuscleXCoinStaking is Ownable {
    IBEP20 public rewardsToken;
    IBEP20 public stakingToken;

    uint256 public totalStaked;

    mapping(address => uint256) public stakingBalance;

    mapping(address => bool) public hasStaked;

    mapping(address => bool) public isStakingAtm;

    mapping(address=>uint) public numberOfDaysContract;

    uint stakingPeriod = 365;

    address[] public stakers;

    uint public rewardRateForXtier = 800; 

    uint public rewardRateForGold  =  700;

    uint public rewardRateForSilver = 600;

    uint public rewardRateForBronze = 500;

    uint public taxForGold = 8;

    uint public taxForSilver = 15;

    uint public taxForBronze = 30;

    address payable ownersAddress;

    mapping(address=>uint) public lastTimeUserStaked;

    mapping(address=>uint) public accumulatedRewards;


    constructor(address _stakingToken, address _rewardsToken, address administratorAddress) {
        stakingToken = IBEP20(_stakingToken);
        rewardsToken = IBEP20(_rewardsToken);
        ownersAddress = payable(administratorAddress);
    }


    function stake(uint _amount, uint numberOfDaysToStake) public {
    totalStaked = totalStaked + _amount;

    bool isStakingPeriodValid = false;

    if(numberOfDaysToStake == 30 ){
        isStakingPeriodValid = true;
    }
    else if (numberOfDaysToStake == 21 ){
        isStakingPeriodValid = true;
    }

    else if (numberOfDaysToStake == 14 ){
        isStakingPeriodValid = true;
    }

    else if (numberOfDaysToStake == 7 ){
        isStakingPeriodValid = true;
    }

    require(isStakingPeriodValid == true, "Staking Time not supported");

        stakingToken.transferFrom(msg.sender, address(this), _amount *(10**18));
        if (hasStaked[msg.sender] == false) {
            stakers.push(msg.sender);
            hasStaked[msg.sender] = true;
        }

        if (isStakingAtm[msg.sender] == true ){
            require(numberOfDaysContract[msg.sender] == numberOfDaysToStake, "Sorry You need to be on the same APY as before to stake more tokens " );
                    uint userRewards = calculateUserRewards(msg.sender);
                    accumulatedRewards[msg.sender]  = userRewards;
        }else{
            accumulatedRewards[msg.sender] = 0;
        }
        
             stakingBalance[msg.sender] = stakingBalance[msg.sender] + _amount;
             numberOfDaysContract[msg.sender] = numberOfDaysToStake;
            lastTimeUserStaked[msg.sender] = block.timestamp;

            isStakingAtm[msg.sender] = true;
    }

    function calculateUserRewards (address userAddress) public view returns(uint){
            if(isStakingAtm[userAddress] == true){
                uint numberOfDaysStaked = calculateNumberOfDaysStaked(userAddress);
            uint userBalance = stakingBalance[userAddress] * (10 **18 );

            uint rewardRate;

            if(numberOfDaysContract[userAddress] == 30){
                rewardRate = rewardRateForXtier;
            }
            else if (numberOfDaysContract[userAddress] == 21 ){
                rewardRate = rewardRateForGold;
            }

            else if (numberOfDaysContract[userAddress] == 14  ){
                rewardRate = rewardRateForSilver;
            }
            else if (numberOfDaysContract[userAddress] == 7 ){
                rewardRate = rewardRateForBronze;
            }

            for(uint i = 0; i< numberOfDaysStaked; i++){
                userBalance  = userBalance + userBalance * rewardRate / 100 / stakingPeriod;
            }

            return accumulatedRewards[userAddress] +  userBalance - (stakingBalance[userAddress] * (10**18)) ;
            }else{
                return 0;
            }
    }

    function calculateExitFee (uint daysStaked, address userAddress)public view returns(uint){

        uint exitFee = 0; 

        uint numbersOfDaysStaked  = daysStaked;

        if(numberOfDaysContract[userAddress] == 21 && numbersOfDaysStaked < 21  ){
          exitFee = taxForGold;  
        }
        else if (numberOfDaysContract[userAddress] == 14 && numbersOfDaysStaked < 14  ){
            exitFee = taxForSilver;
        }
        else if (numberOfDaysContract[msg.sender] == 7 &&  numbersOfDaysStaked < 7 ){
            exitFee = taxForBronze;
        }

        return exitFee;
    }
  
  function calculateNumberOfDaysStaked(address userAddress) public view returns(uint){
      if(isStakingAtm[userAddress] == true ){
          uint lastTimeStaked = lastTimeUserStaked[userAddress];
          uint remainingTime = block.timestamp  - lastTimeStaked;
          uint remainingDays  = remainingTime / 86400;
          return remainingDays;
      }else{
          return 0;
      }
  }
    function claimReward(uint amount) external {
        uint reward = calculateUserRewards(msg.sender);

        uint numberOfDaysStaked = calculateNumberOfDaysStaked(msg.sender);

        require(amount <= stakingBalance[msg.sender], "Can't unstake more than your balance");

        bool canUserUnStake = false;

        if(numberOfDaysContract[msg.sender] == 30 ){
            if (numberOfDaysStaked >  29 ){
                canUserUnStake = true;
            }else {
                canUserUnStake = false;
            }
        }else{
            canUserUnStake = true;
        }

        require(canUserUnStake == true, "Can't unstake as an X Tier Staker under 30 days ");

        require(numberOfDaysStaked > 0 , "Can't unstake in less than a day");

        require(reward > 0, "Rewards is too small to be claimed");

        uint percentageOfRewardsToSend = amount * 100 / stakingBalance[msg.sender] ;

        uint rewardsToPay = reward * percentageOfRewardsToSend / 100;

        uint totalToBePayed = amount  + (rewardsToPay / (10**18));

        uint percentageOfTaxToPay = calculateExitFee(numberOfDaysStaked, msg.sender);

        require(rewardsToken.balanceOf(address(this)) / (10**18)  - totalToBePayed   >= totalStaked, "Contract Balance too Low");

        uint taxToPay = (rewardsToPay * percentageOfTaxToPay ) / 100; 
        
        rewardsToken.transfer(msg.sender, rewardsToPay - taxToPay );

        stakingToken.transfer(msg.sender, amount * (10**18));

        totalStaked = totalStaked  - amount;

        if (rewardsToPay >= accumulatedRewards[msg.sender]){
            accumulatedRewards[msg.sender] = 0;
        }else{
            accumulatedRewards[msg.sender] -=  rewardsToPay;
        }

        if(amount >= stakingBalance[msg.sender]){
        stakingBalance[msg.sender]  = 0;
        isStakingAtm[msg.sender] =  false;
        }else{
            stakingBalance[msg.sender] -= amount;
        }
       
    }

    function changeAdminAddress(address payable newAdminAddress) public payable{
     require(msg.sender == ownersAddress, "UnAuthorized to take this action");
        ownersAddress = newAdminAddress;
    }

    function ChangeRewardsForXTier(uint newRewardRate) public {
    require(ownersAddress == msg.sender, "User Not Authorized");
    rewardRateForXtier =  newRewardRate;

    }

    function ChangeRewardsForGold(uint newRewardRate) public {
    require(ownersAddress == msg.sender, "User Not Authorized");
    rewardRateForGold =  newRewardRate;

    }

    function ChangeRewardsForSilver(uint newRewardRate) public {
    require(ownersAddress == msg.sender, "User Not Authorized");
    rewardRateForSilver =  newRewardRate;

    }

    function ChangeRewardsForBronze(uint newRewardRate) public {
    require(ownersAddress == msg.sender, "User Not Authorized");
    rewardRateForBronze =  newRewardRate;

    }


    function ChangeTaxForGold(uint newTaxRate) public {
            require(ownersAddress == msg.sender, "User Not Authorized");
            taxForGold = newTaxRate;
    }

    function ChangeTaxForSilver(uint newTaxRate) public {
            require(ownersAddress == msg.sender, "User Not Authorized");
            taxForSilver = newTaxRate;
    }

    function ChangeTaxForBronze(uint newTaxRate) public {
            require(ownersAddress == msg.sender, "User Not Authorized");
            taxForBronze = newTaxRate;
    }

function EmergencyUnstake() public {
    require(isStakingAtm[msg.sender] == true, "You currently don't have any tokens staked");
    stakingToken.transfer(msg.sender, stakingBalance[msg.sender] * (10**18));
    stakingBalance[msg.sender]  = 0;
    isStakingAtm[msg.sender] =  false;
    accumulatedRewards[msg.sender] = 0;
}



    function getTotalStaked() public view returns(uint){
                return totalStaked;
        }

    function getUserStakingBalance(address userAddress) public view returns (uint){
            return stakingBalance[userAddress];
        }

    function getRewardRateXTier() public view returns (uint){
        return rewardRateForXtier;
        }

        function getRewardRateGold() public view returns (uint){
        return rewardRateForGold;
        }

        function getRewardRateSilver() public view returns (uint){
        return rewardRateForSilver;
        }

        function getRewardRateBronze() public view returns (uint){
        return rewardRateForBronze;
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