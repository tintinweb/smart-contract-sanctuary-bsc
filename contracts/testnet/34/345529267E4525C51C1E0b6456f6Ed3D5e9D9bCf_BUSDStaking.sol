// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;



interface IERC20{
//Functions
function totalSupply() external  view returns (uint256);
function balanceOf(address tokenOwner) external view returns (uint);
function allowance(address tokenOwner, address spender)external view returns (uint);
function transfer(address to, uint tokens) external returns (bool);
function approve(address spender, uint tokens)  external returns (bool);
function transferFrom(address from, address to, uint tokens) external returns (bool);

//Events
event Approval(address indexed tokenOwner, address indexed spender,uint tokens);
event Transfer(address indexed from, address indexed to,uint tokens);

}


contract BUSDStaking{
  
  IERC20 token;
  uint rewardPercentage = 180_00;
  uint[3] referralPercentages = [8_00 , 3_00 , 2_00];
  uint devWalletFee = 5_00;
  uint projectWalletFee = 2_00;
  uint percentDivider = 100_00;
  uint stakingTime = 6 minutes;
  uint withdrawLimitTime = 1 minutes;
  uint aprPercent = 30_00;
  address owner;

  address devWallet = 0xf638B71a52f8e2edFDdb8824F1e09AAb0b6cD695;
  address projectWallet = 0xf638B71a52f8e2edFDdb8824F1e09AAb0b6cD695;


  struct userStakeData{
    uint amount;
    uint totalAmount;
    uint remainingAmount;
    uint startTime;
    uint endTime;
    uint lastWithdrawTime;
    bool isActive;
  }

 struct User {
        bool isExists;
        address direct;
        userStakeData[] stakes;
        uint256 totalStaked;
        uint256 totalWithdrawan;
    }

  mapping(address => User) public users;

  constructor(IERC20 _token) {
    token  = _token;
    owner = msg.sender;
  }
   
    function Stake(uint _amount , address _referal) external  returns(bool) {
         User storage user = users[msg.sender];
        require(msg.sender!=_referal,"You cannot reffer yourself!");

        if(msg.sender==owner ){
            user.direct = address(0);
        }
        if(_referal==address(0)){
            user.direct = owner;
        }
        if(!users[_referal].isExists && msg.sender!=owner)
        {
          user.direct = owner;
        }
        if(user.direct==address(0) && msg.sender!=owner && users[_referal].isExists){
            user.direct = _referal;
        }
        token.transferFrom(msg.sender,address(this), _amount);
        uint rewardAmount = (_amount*rewardPercentage)/percentDivider;
        user.isExists = true;


        user.stakes.push(
           userStakeData(
           _amount,
           rewardAmount,
           rewardAmount,
           block.timestamp,
           block.timestamp+stakingTime,
           block.timestamp,
           true
           )
        );

        user.totalStaked += _amount; 
        distributeStakingRewards(_amount);
        return true;

    }

    function withdraw(uint _index) external returns(bool){

        User storage user = users[msg.sender];

        require(_index <user.stakes.length, "Invalid Index");
        require(user.stakes[_index].isActive, "Stake is not Active");
        require(block.timestamp-user.stakes[_index].lastWithdrawTime>=withdrawLimitTime,"You cannot withdaw right now. wait for turn!");
        uint slots = (block.timestamp-user.stakes[_index].lastWithdrawTime)/withdrawLimitTime;
        uint currentDivident = ((user.stakes[_index].amount*aprPercent)/percentDivider)*slots;
        if(currentDivident>= user.stakes[_index].remainingAmount){
          currentDivident =  user.stakes[_index].remainingAmount;
        }
        uint devWalletAmount = (currentDivident*devWalletFee)/percentDivider;
        uint projectWalletAmount = (currentDivident*projectWalletFee)/percentDivider;

        uint amountToSend = currentDivident-devWalletAmount;

        token.transfer(msg.sender , amountToSend);
        token.transfer(devWallet , devWalletAmount);
        token.transfer(projectWallet , projectWalletAmount);

        if(block.timestamp>= user.stakes[_index].endTime){
        user.stakes[_index].lastWithdrawTime =  user.stakes[_index].endTime;

        }
        else{
        user.stakes[_index].lastWithdrawTime += (slots*withdrawLimitTime);
        }
        user.stakes[_index].remainingAmount -=currentDivident ;

        if(user.stakes[_index].remainingAmount==0)
        {
          user.stakes[_index].isActive = false;  
        }
          return true;
    }

    function distributeStakingRewards(uint _amount) internal returns(bool)
    {
        token.transfer(devWallet , (_amount*devWalletFee)/percentDivider);

        address referal = users[msg.sender].direct;

        for(uint i ; i<referralPercentages.length ; i++){
           if(referal==address(0)){
               break;
           }
           token.transfer(referal, (_amount*referralPercentages[i])/percentDivider);
           referal = users[referal].direct;
        }

        return true;

    }


    function viewStaking(uint _index , address _user) public view returns(
         uint amount,
         uint totalAmount,
         uint remainingAmount,
         uint startTime,
         uint endTime,
         uint lastWithdrawTime,
         bool isActive
    )
    {


     User storage user = users[_user];
     amount = user.stakes[_index].amount;
     totalAmount = user.stakes[_index].totalAmount;
     remainingAmount = user.stakes[_index].remainingAmount;
     startTime =  user.stakes[_index].startTime;
     endTime =  user.stakes[_index].endTime;
     lastWithdrawTime =  user.stakes[_index].lastWithdrawTime;
     isActive =  user.stakes[_index].isActive;
        
    }

   
}