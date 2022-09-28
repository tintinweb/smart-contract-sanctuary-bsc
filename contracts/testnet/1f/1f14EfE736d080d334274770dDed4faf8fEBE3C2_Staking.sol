// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract Staking{
    IERC20 public token;
    address private owner;

//user staking info
   struct StakeInfo{
       uint package;
       uint startsAt;
       uint _monthlyPackage;
       uint _stakingIncome;
       bool staked;
       uint lastStakingIncome;
       uint teamTurnOver;
       uint holdingTime;
       address referredBy;
       address[] direct;
      mapping (uint8 => uint256) referrals_per_level;
}
//collective staking packages
struct User{
   uint[] silverPackages;
   uint[] goldPackages;
   uint[] diamondPackages;
   uint[] queenPackages;
   uint[] kingPackages;
   bool superMember;
   bool supremeMember;
   bool goImmortalMember;
   bool silverMember;
   bool goldMember;
   bool diamondMember;
   bool crownMember;
}
 //packages
 uint[6] public stakePackages = [200, 500, 1000, 2000, 5000, 10000];

 //monthly percantages plans
 uint[5] public monthlyPackages = [5, 7, 10, 12, 15]; //monthly percantages

 //levels distribution according to the plans
 uint[10] public percantages = [10, 10 ,5, 5, 4, 4, 3, 3, 2, 2];

//staking level incomes
uint[10] public  stakingLevelIncomes = [5, 5, 3, 3, 2, 2, 2, 1, 1, 1];

//super leadership income
address[] public superLeaders;
uint private superIncomes;
uint private lastPoolWithdraw1 = block.timestamp;
//supreme leadership income
address [] public  supremeLeaders;
uint private supremeIncomes;
uint private lastPoolWithdraw2 = block.timestamp;

//Go immortal income
address[] public goImmortal;
uint private goImmortalIncomes;
uint private lastPoolWithdraw3 = block.timestamp;
//direct referral income
uint directReferralIncome = 10; // 10 % of the deposit

//monthly reward income pools
uint private lastPoolwithdraw4 = block.timestamp;
uint private silver;
address [] private silverMembers;
uint private gold;
address [] private goldMembers;
uint private diamond;
address [] private diamondMembers;
uint private crown;
address [] private crownMembers;

    mapping (address => User)public  _user; 
    mapping (address => StakeInfo)public  _stakeInfo;
    event Deposit(address indexed _depositor, uint indexed _amount);
    event ReferralPayout(address indexed addr, uint256 amount, uint8 level);

 constructor(address tokenAddress){
    token = IERC20(tokenAddress);
    owner = msg.sender;
}


//deposit function

function deposit(address _referredBy, uint stakePackagesIndex, uint monthlyPackageIndex)public{
   //  require(_packages[_referredBy].staked == true);
    StakeInfo storage stakeInfo = _stakeInfo[msg.sender];
    stakeInfo.package = stakePackages[stakePackagesIndex];
    stakeInfo.startsAt = block.timestamp;
    stakeInfo.holdingTime = block.timestamp;
    stakeInfo.lastStakingIncome = block.timestamp;
    stakeInfo._monthlyPackage = monthlyPackages[monthlyPackageIndex];
    token.transferFrom(msg.sender, address(this), stakeInfo.package);
    if(msg.sender == owner){
        _referredBy = address(0);
    }
    //Packages
    User storage user = _user[msg.sender];
    for(uint8 i = 0; i < stakePackages.length; i++){
    if(_stakeInfo[msg.sender].package == stakePackages[0]){
       user.silverPackages.push(_stakeInfo[msg.sender].package);
       break;
    }
    else if(_stakeInfo[msg.sender].package == stakePackages[1] && _user[msg.sender].silverPackages.length >= 0){
       user.goldPackages.push(_stakeInfo[msg.sender].package);
       break;

    }
     else if(_stakeInfo[msg.sender].package == stakePackages[2] && _user[msg.sender].goldPackages.length >= 0){
       user.diamondPackages.push(_stakeInfo[msg.sender].package);
       break;
    }
     else if(_stakeInfo[msg.sender].package == stakePackages[3] && _user[msg.sender].diamondPackages.length >= 0){
       user.queenPackages.push(_stakeInfo[msg.sender].package);
       break;     
    }
     else if(_stakeInfo[msg.sender].package == stakePackages[4] && _user[msg.sender].queenPackages.length >= 0){
        user.kingPackages.push(_stakeInfo[msg.sender].package);
    }
    }
    //direct referral income 10%

    uint _directReferralIncome = (_stakeInfo[msg.sender].package * directReferralIncome) /100;
    _stakeInfo[msg.sender].referredBy = _referredBy;
    token.transfer(_referredBy, _directReferralIncome);
    _stakeInfo[_referredBy].teamTurnOver += _stakeInfo[msg.sender].package;
    _stakeInfo[_referredBy].direct.push(msg.sender); 
   
    //distribution according to the levels

       for(uint8 i = 0; i < percantages.length; i++){
          address ref = _stakeInfo[msg.sender].referredBy;
          uint256 bonuses = (_stakeInfo[msg.sender].package * percantages[i])/ 100;
           token.transfer(ref, bonuses); 
          _stakeInfo[_referredBy].referrals_per_level[i]++;
          _referredBy = _stakeInfo[_referredBy].referredBy;
          ref = _stakeInfo[ref].referredBy; 
          emit ReferralPayout(ref, bonuses, (i+1));
        if(_referredBy == address(0)) break;

      else if (_stakeInfo[msg.sender].package == stakePackages[0]){
         _stakeInfo[_referredBy]. referrals_per_level[1];
         break ;
      }
      else if(_stakeInfo[msg.sender].package == stakePackages[1]){
         _stakeInfo[_referredBy]. referrals_per_level[3];
         break ;
      }
      else if(_stakeInfo[msg.sender].package == stakePackages[2]){
         _stakeInfo[_referredBy]. referrals_per_level[5];
         break ;
      }
      else if(_stakeInfo[msg.sender].package == stakePackages[3]){
         _stakeInfo[_referredBy]. referrals_per_level[7];
         break ;
      }
      else if(_stakeInfo[msg.sender].package == stakePackages[4]){
         _stakeInfo[_referredBy]. referrals_per_level[8];
         break ;
      }
      else if(_stakeInfo[msg.sender].package == stakePackages[5]){
         _stakeInfo[_referredBy]. referrals_per_level[9];
      }
      }
//staking levels income distribution
   
      for (uint8 i = 0; i < stakingLevelIncomes.length; i++){
         if( _stakeInfo[_referredBy].holdingTime >= 360 days){
     address ref = _stakeInfo[msg.sender].referredBy;
     uint256 _incomes = (_stakeInfo[msg.sender].package * stakingLevelIncomes[i])/ 100;
     _stakeInfo[_referredBy].referrals_per_level[i]++;
     _referredBy = _stakeInfo[_referredBy].referredBy;
      token.transfer(ref, _incomes); 
     ref = _stakeInfo[ref].referredBy; 
     emit ReferralPayout(ref, _incomes, (i+1));
    }
    }

    //super members
    
    superIncomes += (_stakeInfo[msg.sender].package * 1 ) / 100;
 if(_stakeInfo[msg.sender].direct.length >= 20){
   superLeaders.push(msg.sender);
   _user[msg.sender].superMember = true;
   
 }
  //supreme members
   
    supremeIncomes +=(_stakeInfo[msg.sender].package * 1 ) / 100;
 if(_stakeInfo[msg.sender].holdingTime >= 360 days && _stakeInfo[msg.sender].package >= 7000){
    supremeLeaders.push(msg.sender);
    _user[msg.sender].supremeMember = true;
    }
    //goImmortal members

    goImmortalIncomes +=  (_stakeInfo[msg.sender].package * 1 ) / 100;
 if(_stakeInfo[msg.sender].holdingTime >= 360 days && _stakeInfo[msg.sender].package >= 10000){
    goImmortal.push(msg.sender);
    _user[msg.sender].goImmortalMember = true;
 }
 //monthly reward income pools distribution
 silver += (_stakeInfo[msg.sender].package * 1 ) / 100;
 if(_stakeInfo[msg.sender].direct.length >= 10 && _stakeInfo[msg.sender].teamTurnOver >= 1e4){
   silverMembers.push(msg.sender);
   _user[msg.sender].silverMember = true;
}
 gold += (_stakeInfo[msg.sender].package * 1 ) / 100;
 if(_stakeInfo[msg.sender].direct.length >= 20 && _stakeInfo[msg.sender].teamTurnOver >= 1e5){
   goldMembers.push(msg.sender);
    _user[msg.sender].goldMember = true;

}
 diamond += (_stakeInfo[msg.sender].package * 1 ) / 100;
 if(_stakeInfo[msg.sender].direct.length >= 30 && _stakeInfo[msg.sender].teamTurnOver >= 1e6){
   diamondMembers.push(msg.sender);
    _user[msg.sender].diamondMember = true;

}
 crown += (_stakeInfo[msg.sender].package * 1 ) / 100;
 if(_stakeInfo[msg.sender].direct.length >= 50 && _stakeInfo[msg.sender].teamTurnOver >= 1e7){
   crownMembers.push(msg.sender);
    _user[msg.sender].crownMember = true;
}
    _stakeInfo[msg.sender].staked = true;
   emit Deposit(msg.sender, _stakeInfo[msg.sender].package);
}
   



//withdraw function

  function withdraw() public{
   require(_stakeInfo[msg.sender].package > 0, "You don't have staking");
   require(block.timestamp >= _stakeInfo[msg.sender].lastStakingIncome + 30 days,  "No withdraw before one month");
      if(_stakeInfo[msg.sender]._monthlyPackage == monthlyPackages[0]) {
         uint sum = 0;
        if(_user[msg.sender].silverPackages.length >= 0){
         for (uint8 i = 0; i < _user[msg.sender].silverPackages.length; i++){
            sum += _user[msg.sender].silverPackages[i];
         }
     uint stakingIncomePerMonth = (sum * 5 ) /100;
      token.transfer(msg.sender, stakingIncomePerMonth);
      }
    //  _stakeInfo[msg.sender]._stakingIncome += stakingIncomePerMonth;
      if(_user[msg.sender].goldPackages.length >= 0){
        for (uint8 i = 0; i < _user[msg.sender].goldPackages.length; i++){
            sum += _user[msg.sender].goldPackages[i];
         }
     uint stakingIncomePerMonth = (sum * 5 ) /100;
      token.transfer(msg.sender, stakingIncomePerMonth);
      }
          if(_user[msg.sender].diamondPackages.length >= 0){
        for (uint8 i = 0; i < _user[msg.sender].diamondPackages.length; i++){
            sum += _user[msg.sender].diamondPackages[i];
         }
     uint stakingIncomePerMonth = (sum * 5 ) /100;
      token.transfer(msg.sender, stakingIncomePerMonth);
      }
         if(_user[msg.sender].queenPackages.length >= 0){
        for (uint8 i = 0; i < _user[msg.sender].queenPackages.length; i++){
            sum += _user[msg.sender].queenPackages[i];
         }
     uint stakingIncomePerMonth = (sum * 5 ) /100;
      token.transfer(msg.sender, stakingIncomePerMonth);
      }
          if(_user[msg.sender].kingPackages.length >= 0){
        for (uint8 i = 0; i < _user[msg.sender].kingPackages.length; i++){
            sum += _user[msg.sender].kingPackages[i];
         }
     uint stakingIncomePerMonth = (sum * 5 ) /100;
      token.transfer(msg.sender, stakingIncomePerMonth);
      }
    }
     else if(_stakeInfo[msg.sender]._monthlyPackage == monthlyPackages[1]) {
         uint sum = 0;
        if(_user[msg.sender].silverPackages.length >= 0){
         for (uint8 i = 0; i < _user[msg.sender].silverPackages.length; i++){
            sum += _user[msg.sender].silverPackages[i];
         }
     uint stakingIncomePerMonth = (sum * 7 ) /100;
      token.transfer(msg.sender, stakingIncomePerMonth);
      }
    //  _stakeInfo[msg.sender]._stakingIncome += stakingIncomePerMonth;
       if(_user[msg.sender].goldPackages.length >= 0){
        for (uint8 i = 0; i < _user[msg.sender].goldPackages.length; i++){
            sum += _user[msg.sender].goldPackages[i];
         }
     uint stakingIncomePerMonth = (sum * 7 ) /100;
      token.transfer(msg.sender, stakingIncomePerMonth);
      }
         if(_user[msg.sender].diamondPackages.length >= 0){
        for (uint8 i = 0; i < _user[msg.sender].diamondPackages.length; i++){
            sum += _user[msg.sender].diamondPackages[i];
         }
     uint stakingIncomePerMonth = (sum * 7 ) /100;
      token.transfer(msg.sender, stakingIncomePerMonth);
      }
        if(_user[msg.sender].queenPackages.length >= 0){
        for (uint8 i = 0; i < _user[msg.sender].queenPackages.length; i++){
            sum += _user[msg.sender].queenPackages[i];
         }
     uint stakingIncomePerMonth = (sum * 7 ) /100;
      token.transfer(msg.sender, stakingIncomePerMonth);
      }
         if(_user[msg.sender].kingPackages.length >= 0){
        for (uint8 i = 0; i < _user[msg.sender].kingPackages.length; i++){
            sum += _user[msg.sender].kingPackages[i];
         }
     uint stakingIncomePerMonth = (sum * 7 ) /100;
      token.transfer(msg.sender, stakingIncomePerMonth);
      }
    }
    else if(_stakeInfo[msg.sender]._monthlyPackage == monthlyPackages[2]) {
         uint sum = 0;
        if(_user[msg.sender].silverPackages.length >= 0){
         for (uint8 i = 0; i < _user[msg.sender].silverPackages.length; i++){
            sum += _user[msg.sender].silverPackages[i];
         }
     uint stakingIncomePerMonth = (sum * 10 ) /100;
      token.transfer(msg.sender, stakingIncomePerMonth);
      }
    //  _stakeInfo[msg.sender]._stakingIncome += stakingIncomePerMonth;
      if(_user[msg.sender].goldPackages.length >= 0){
        for (uint8 i = 0; i < _user[msg.sender].goldPackages.length; i++){
            sum += _user[msg.sender].goldPackages[i];
         }
     uint stakingIncomePerMonth = (sum * 10 ) /100;
      token.transfer(msg.sender, stakingIncomePerMonth);
      }
          if(_user[msg.sender].diamondPackages.length >= 0){
        for (uint8 i = 0; i < _user[msg.sender].diamondPackages.length; i++){
            sum += _user[msg.sender].diamondPackages[i];
         }
     uint stakingIncomePerMonth = (sum * 10 ) /100;
      token.transfer(msg.sender, stakingIncomePerMonth);
      }
         if(_user[msg.sender].queenPackages.length >= 0){
        for (uint8 i = 0; i < _user[msg.sender].queenPackages.length; i++){
            sum += _user[msg.sender].queenPackages[i];
         }
     uint stakingIncomePerMonth = (sum * 10 ) /100;
      token.transfer(msg.sender, stakingIncomePerMonth);
      }
         if(_user[msg.sender].kingPackages.length >= 0){
        for (uint8 i = 0; i < _user[msg.sender].kingPackages.length; i++){
            sum += _user[msg.sender].kingPackages[i];
         }
     uint stakingIncomePerMonth = (sum * 10 ) /100;
      token.transfer(msg.sender, stakingIncomePerMonth);
      }
    }
     else if(_stakeInfo[msg.sender]._monthlyPackage == monthlyPackages[3]) {
         uint sum = 0;
        if(_user[msg.sender].silverPackages.length >= 0){
         for (uint8 i = 0; i < _user[msg.sender].silverPackages.length; i++){
            sum += _user[msg.sender].silverPackages[i];
         }
     uint stakingIncomePerMonth = (sum * 12 ) /100;
      token.transfer(msg.sender, stakingIncomePerMonth);
      }
    //  _stakeInfo[msg.sender]._stakingIncome += stakingIncomePerMonth;
     if(_user[msg.sender].goldPackages.length >= 0){
        for (uint8 i = 0; i < _user[msg.sender].goldPackages.length; i++){
            sum += _user[msg.sender].goldPackages[i];
         }
     uint stakingIncomePerMonth = (sum * 12 ) /100;
      token.transfer(msg.sender, stakingIncomePerMonth);
      }
          if(_user[msg.sender].diamondPackages.length >= 0){
        for (uint8 i = 0; i < _user[msg.sender].diamondPackages.length; i++){
            sum += _user[msg.sender].diamondPackages[i];
         }
     uint stakingIncomePerMonth = (sum * 12 ) /100;
      token.transfer(msg.sender, stakingIncomePerMonth);
      }
        if(_user[msg.sender].queenPackages.length >= 0){
        for (uint8 i = 0; i < _user[msg.sender].queenPackages.length; i++){
            sum += _user[msg.sender].queenPackages[i];
         }
     uint stakingIncomePerMonth = (sum * 12 ) /100;
      token.transfer(msg.sender, stakingIncomePerMonth);
      }
         if(_user[msg.sender].kingPackages.length >= 0){
        for (uint8 i = 0; i < _user[msg.sender].kingPackages.length; i++){
            sum += _user[msg.sender].kingPackages[i];
         }
     uint stakingIncomePerMonth = (sum * 12 ) /100;
      token.transfer(msg.sender, stakingIncomePerMonth);
      }
    }
     else if(_stakeInfo[msg.sender]._monthlyPackage == monthlyPackages[4]) {
         uint sum = 0;
        if(_user[msg.sender].silverPackages.length >= 0){
         for (uint8 i = 0; i < _user[msg.sender].silverPackages.length; i++){
            sum += _user[msg.sender].silverPackages[i];
         }
     uint stakingIncomePerMonth = (sum * 15 ) /100;
      token.transfer(msg.sender, stakingIncomePerMonth);
      }
    //  _stakeInfo[msg.sender]._stakingIncome += stakingIncomePerMonth;
      if(_user[msg.sender].goldPackages.length >= 0){
        for (uint8 i = 0; i < _user[msg.sender].goldPackages.length; i++){
            sum += _user[msg.sender].goldPackages[i];
         }
     uint stakingIncomePerMonth = (sum * 15 ) /100;
      token.transfer(msg.sender, stakingIncomePerMonth);
      }
          if(_user[msg.sender].diamondPackages.length >= 0){
        for (uint8 i = 0; i < _user[msg.sender].diamondPackages.length; i++){
            sum += _user[msg.sender].diamondPackages[i];
         }
     uint stakingIncomePerMonth = (sum * 15 ) /100;
      token.transfer(msg.sender, stakingIncomePerMonth);
      }
         if(_user[msg.sender].queenPackages.length >= 0){
        for (uint8 i = 0; i < _user[msg.sender].queenPackages.length; i++){
            sum += _user[msg.sender].queenPackages[i];
         }
     uint stakingIncomePerMonth = (sum * 15 ) /100;
      token.transfer(msg.sender, stakingIncomePerMonth);
      }
         if(_user[msg.sender].kingPackages.length >= 0){
        for (uint8 i = 0; i < _user[msg.sender].kingPackages.length; i++){
            sum += _user[msg.sender].kingPackages[i];
         }
     uint stakingIncomePerMonth = (sum * 15 ) /100;
      token.transfer(msg.sender, stakingIncomePerMonth);
      }
    } 
       _stakeInfo[msg.sender].lastStakingIncome = block.timestamp;
  }
//withdraw monthly reward income
function _monthlyRewardWithdraw()public {
require(block.timestamp >= lastPoolwithdraw4 + 30 days, " No withdraw before one month");
if (_user[msg.sender].silverMember == true){
 uint incomes = silver / silverMembers.length;
for (uint i = 0; i < silverMembers.length; i++){
   token.transfer(silverMembers[i], incomes);
}
}
if (_user[msg.sender].goldMember == true){
 uint incomes = gold / goldMembers.length;
for (uint i = 0; i < goldMembers.length; i++){
   token.transfer(goldMembers[i], incomes);
}
}
if (_user[msg.sender].diamondMember == true){
 uint incomes = diamond / diamondMembers.length;
for (uint i = 0; i < diamondMembers.length; i++){
   token.transfer(diamondMembers[i], incomes);
}
}
if (_user[msg.sender].crownMember == true){
 uint incomes = crown / crownMembers.length;
for (uint i = 0; i < crownMembers.length; i++){
   token.transfer(crownMembers[i], incomes);
}
}
lastPoolwithdraw4 = block.timestamp;
}

 
// superLeadership income distribution
function _superLeaders() public {
 require(_user[msg.sender].superMember == true);
//  require(superIncomes > 0, "Nothing for withdrawl");
 require(block.timestamp >= lastPoolWithdraw1 + 30 days, " No withdraw before one month");
 uint incomes = superIncomes / superLeaders.length;
 for (uint i = 0; i < superLeaders.length; i++){
    token.transfer(superLeaders[i], incomes);
 }
lastPoolWithdraw1 = block.timestamp;
}
// supremeLeadership income distribution
function _supremeLeaders() public {
 require(_user[msg.sender].supremeMember == true);
//  require(supremeIncomes > 0, "Nothing for withdrawl");
require(block.timestamp >= lastPoolWithdraw2 + 30 days, " No withdraw before one month");
 uint incomes = supremeIncomes / supremeLeaders.length;
 for (uint i = 0; i < supremeLeaders.length; i++){
    token.transfer(supremeLeaders[i], incomes);
 }
lastPoolWithdraw2 = block.timestamp;

}
//goImmortal incomes distribution
function _goImmortal() public {
 require(_user[msg.sender].goImmortalMember == true, "You are not a member");
//  require(goImmortalIncomes > 0, "Nothing for withdrawl");
require(block.timestamp >= lastPoolWithdraw3 + 30 days, " No withdraw before one month");
 uint incomes = goImmortalIncomes / goImmortal.length;
 for (uint i = 0; i < goImmortal.length; i++){
    token.transfer(goImmortal[i], incomes);
 }
lastPoolWithdraw3 = block.timestamp;

}
// get the contract balance
function getContractBalance() public view returns(uint){
    return address(this).balance;
}

}