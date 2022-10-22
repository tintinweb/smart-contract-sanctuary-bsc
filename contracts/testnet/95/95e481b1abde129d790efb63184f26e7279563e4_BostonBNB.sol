/**
 *Submitted for verification at BscScan.com on 2022-10-21
*/

// SPDX-License-Identifier: none
pragma solidity ^0.8.11;
/**     
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }
  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }
  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }
  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a); 
    return c;
  }
}

interface BEP20 {
    function totalSupply() external view returns (uint theTotalSupply);
    function balanceOf(address _owner) external view returns (uint balance);
    function transfer(address _to, uint _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint _value) external returns (bool success);
    function approve(address _spender, uint _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint remaining);
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

contract Ownable {
  address public CEO; 

  
  constructor() {
    CEO = msg.sender;
   
  }
  modifier onlyOwner() {
    require(msg.sender == CEO);
    _;
  }
}
contract BostonBNB is Ownable {   
   
   struct Tariff {
    uint time;
    uint percent;
    uint minInvest;
    uint donatePercent;
  }
  
  struct Deposit {
    uint tariff;
    uint amount;
    uint at;
    uint cashbackAmount;
  }
  
  struct WithdrawStruct {
    address fromAddr;
    uint amount;
    uint at;
  }

  
  struct Investor {
    bool registered;
    address referer;
    Deposit[] deposits;
    Stake[] stakes;
    WithdrawStruct[] withdrawStructs;
    uint invested;
    uint paidAt;
    uint withdrawn;
    uint firstInvestAt;
    uint tariffId;
    uint oneWeekcompoundCount;
    uint oneWeekCompoundSum;
    uint levelBusiness;
    uint bostonToken;
  }

  struct InvestorTime {
    uint paidAt;
    uint firstInvestAt;
    uint latestInvestAt;
    uint nextCompoundAt;
    uint eagleClubAchieveAt;
    uint diamondClubAchieveAt;
    uint ambassadorClubAchieveAt;
    uint kingClubAchieveAt;
  }

  struct InvestorIncome {
    uint cashback;
    uint balanceRef;
    uint compoundBonus;
    uint withdrawBonus;
    uint rankBonus;
    uint eagleRankBonus;
    uint diamondRankBonus;
    uint ambassadorRankBonus;
    uint kingRankBonus;
  }

  struct Stake {
    uint amount;
    uint stakeAt;
    bool withdraw;
    uint withdrawAt;
  }

 
 

 
  Tariff[] public tariffs;
  uint[] public refRewards;
  uint[] public refRewardPercent;

  uint public oneDay = 300; 
  uint public ownerFee = 0;
  uint public marketingFee = 3;
  uint public normalWithdrawalFee = 10;
  uint public stakeFee = 20;
  uint public unstakeFee = 15;
  uint public emergencyWithdrawalFee = 20;
  uint public devFee = 6;
  uint public bostonPrice = 200000; // 200000 Boston per bnb
  uint public totalDonateAmount;
  

  address payable public marketingWalletAddress = payable(msg.sender);  
  address payable public devWalletAddress = payable(msg.sender);
  address public ownerWalletAddress = msg.sender;
  address public contractAddr = address(this);
  mapping (address => Investor) public investors;
  mapping (address => InvestorIncome) public investors_income;
  mapping (address => InvestorTime) public investors_time;
  mapping (address => uint) public investors_donate;
  
 // mapping (address => InvestorReferral) public investorreferrals;
  mapping (address => mapping(uint=>uint)) public userReferralCnt;
  mapping (address => mapping(uint=>uint)) public userReferralBalance;
  mapping (address => mapping(uint=>uint)) public userCompoundBonus;
  
  event investAt(address user,  uint amount, uint tariff);
  event stakedAt(address user,  uint amount);
  event Reinvest(address user, uint amount, uint tariff);
  event Sell(address user, uint amount);
  event Unstake(address user, uint amount, uint withdrawAt, uint index);
  event TransferOwnership(address user);
  

  constructor() {
   

    tariffs.push(Tariff(182 * oneDay, 315, 0.02*(10**18),105));
    tariffs.push(Tariff(182 * oneDay, 378, 3.1*(10**18),120));
    tariffs.push(Tariff(182 * oneDay, 630, 6.1*(10**18),210));

    for (uint i = 1; i <= 15; i++) {
      refRewards.push(i);
    }
    
    refRewardPercent.push(700);
    refRewardPercent.push(300);
    refRewardPercent.push(200);
    refRewardPercent.push(100);
    refRewardPercent.push(100);
    refRewardPercent.push(100);
    refRewardPercent.push(50);
    refRewardPercent.push(50);
    refRewardPercent.push(50);
    refRewardPercent.push(50);
    refRewardPercent.push(50);
    refRewardPercent.push(50);
    refRewardPercent.push(50);
    refRewardPercent.push(25);
    refRewardPercent.push(25);
  
  }
  
  function rewardReferers(uint amount, address referer) internal {
    
      bool newUser = false;
      if(!investors[msg.sender].registered) {
        newUser = true;
        investors[msg.sender].registered = true;
      }  
      
      if (investors[referer].registered && referer != msg.sender) {
        investors[msg.sender].referer = referer;
        
        address rec = referer;
        for (uint i = 0; i < refRewards.length; i++) {
          if (!investors[rec].registered) {
            break;
          }
          if(newUser==true){
            userReferralCnt[rec][i]++;
          }
          uint a = amount * refRewardPercent[i] / (100*100);
          userReferralBalance[rec][i] += a;
          investors_income[rec].balanceRef += a;
          
          rec = investors[rec].referer;
        }
        
      }
    
  }
  
  function updateLevelBusiness(uint amount) internal {
    address rec = investors[msg.sender].referer;
    
    for (uint i = 0; i < refRewards.length; i++) {
      if (!investors[rec].registered) {
        break;
      }
      investors[rec].levelBusiness += amount;
      if(investors[rec].levelBusiness >= 100*(10**18)) { // minimum 100 bnb for rank bonus
        if(investors[rec].levelBusiness >= 1100*(10**18) && userReferralCnt[rec][0]>=20 && investors_income[rec].kingRankBonus == 0){
          uint bonus = (500*(10**18) * 15)/(100*10); //1.5 percent 
          investors_income[rec].rankBonus += bonus;
          investors_income[rec].kingRankBonus = bonus;
          investors_time[rec].kingClubAchieveAt = block.timestamp;
          
        }
        else if(investors[rec].levelBusiness >= 600*(10**18) && userReferralCnt[rec][0]>=15 && investors_income[rec].ambassadorRankBonus == 0){
          uint bonus = (300*(10**18) * 20)/(100*10);//2 percent 
          investors_income[rec].rankBonus += bonus; 
          investors_income[rec].ambassadorRankBonus = bonus;
          investors_time[rec].ambassadorClubAchieveAt = block.timestamp;
          
        }
        else if(investors[rec].levelBusiness >= 300*(10**18) && userReferralCnt[rec][0]>=10  && investors_income[rec].diamondRankBonus == 0){
          uint bonus = (200*(10**18) * 30)/(100*10); //3 percent 
          investors_income[rec].rankBonus += bonus;
          investors_income[rec].diamondRankBonus = bonus;
          investors_time[rec].diamondClubAchieveAt = block.timestamp;
        }
        else if(investors[rec].levelBusiness >= 100*(10**18)  && userReferralCnt[rec][0]>=5 && investors_income[rec].eagleRankBonus == 0){
          uint bonus = (100*(10**18) * 35)/(100*10); //3.5 percent
          investors_income[rec].rankBonus += bonus;
          investors_income[rec].eagleRankBonus = bonus; 
          investors_time[rec].eagleClubAchieveAt = block.timestamp;
        }
      }
      rec = investors[rec].referer;
    }
  }
  

  function cashback() public view returns (uint amount) {
     amount = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, block.number))) % 6;
     amount = amount + 10;
     return amount;
  } 
  
  function invest(uint tariff, address referer, uint bnbAmount) external  {
      require(tariff<=2,"Invalid Plan");
      //uint bnbAmount = msg.value;
      require(bnbAmount >= tariffs[tariff].minInvest,"Minimum Investment");
       
      if (investors[msg.sender].registered) {
        require(investors[msg.sender].tariffId==tariff,"Can't Invest in different plan");
        
      }
      

      if(investors[msg.sender].invested==0){
        investors[msg.sender].firstInvestAt = block.timestamp;
      } 

      // marketing Fee
      uint marketingFeeAmount = bnbAmount*marketingFee/100; 
      //marketingWalletAddress.transfer(marketingFeeAmount);

      // dev Fee
      uint DevFeeAmount = bnbAmount*devFee/100; 
      //marketingWalletAddress.transfer(DevFeeAmount);

      investors[msg.sender].invested += bnbAmount;
      investors_time[msg.sender].latestInvestAt = block.timestamp;
      investors_time[msg.sender].nextCompoundAt = block.timestamp+oneDay;
      
      investors[msg.sender].deposits.push(Deposit(tariff, bnbAmount, block.timestamp,0));
      
      rewardReferers(bnbAmount,referer);

      uint bostonToken = bnbAmount * bostonPrice;
      investors[msg.sender].bostonToken +=  bostonToken;
      updateLevelBusiness(bnbAmount);
      emit investAt(msg.sender,  bnbAmount , tariff);
	}


  function upgradePackage(uint bnbAmount) external {
      require(investors[msg.sender].registered,"Invalid User");
      //uint bnbAmount = msg.value;
      uint tariff = investors[msg.sender].tariffId;
      require(bnbAmount >= 5 *(10**17),"Minimum Investment");
      

      // marketing Fee
      uint marketingFeeAmount = bnbAmount*marketingFee/100; 
      //marketingWalletAddress.transfer(marketingFeeAmount);

      // dev Fee
      uint DevFeeAmount = bnbAmount*devFee/100; 
      //marketingWalletAddress.transfer(DevFeeAmount);
     
      investors[msg.sender].invested += bnbAmount;

      uint cashbackAmt = bnbAmount*cashback()/100;
      
      investors[msg.sender].deposits.push(Deposit(tariff, bnbAmount, block.timestamp, cashbackAmt));
      investors_income[msg.sender].cashback += cashbackAmt;
      investors_time[msg.sender].latestInvestAt = block.timestamp;

      uint bostonToken = bnbAmount * bostonPrice;
      investors[msg.sender].bostonToken +=  bostonToken;
      uint directBonus = bnbAmount*7/100;
      userReferralBalance[investors[msg.sender].referer][0] +=directBonus;
      investors_income[investors[msg.sender].referer].balanceRef +=  directBonus;

      
      updateLevelBusiness(bnbAmount);
      emit investAt(msg.sender, bnbAmount, tariff);
	}


  function compound() external  {
    
	  (uint amount, uint donateAmount) = roi(msg.sender);
    require(amount > 0);

    rewardReferers(amount, investors[msg.sender].referer);
    uint bostonToken = amount * bostonPrice;
    investors[msg.sender].invested += amount;
    investors[msg.sender].bostonToken +=  bostonToken;
	  uint tariff = investors[msg.sender].tariffId;
	
    investors[msg.sender].deposits.push(Deposit(tariff, amount, block.timestamp, 0));
    investors[msg.sender].paidAt = block.timestamp;
    
   
    if((investors_time[msg.sender].nextCompoundAt > block.timestamp) && ((investors_time[msg.sender].nextCompoundAt - block.timestamp) <= oneDay) ){
       investors[msg.sender].oneWeekcompoundCount += 1;
       investors[msg.sender].oneWeekCompoundSum += amount; 
       investors_time[msg.sender].nextCompoundAt += oneDay;
    }
    else if(block.timestamp > investors_time[msg.sender].nextCompoundAt){
      investors[msg.sender].oneWeekcompoundCount = 1;
      investors[msg.sender].oneWeekCompoundSum = amount; 
      investors_time[msg.sender].nextCompoundAt = block.timestamp+oneDay;
    }

    if(investors[msg.sender].oneWeekcompoundCount>=7){
      compoundReward(investors[msg.sender].oneWeekCompoundSum);
      investors[msg.sender].oneWeekcompoundCount = 0;
      investors[msg.sender].oneWeekCompoundSum = 0; 
    }
   
    
    emit Reinvest(msg.sender,tariff, amount);
  } 

  function compoundReward(uint amount) internal {
      investors_income[msg.sender].compoundBonus += amount*5/100;
      
      address rec = investors[msg.sender].referer;
      uint compoundPercent;
      for (uint i = 0; i < 6; i++) {
        if (!investors[rec].registered) {
          break;
        }
        if(i==0){
          compoundPercent = 30;
        }
        else if(i==1){
          compoundPercent = 20;
        }
        else if(i==2){
          compoundPercent = 10;
        }
        else{
          compoundPercent = 5;
        }
        uint bonus = amount*compoundPercent/(100*10);
        investors_income[rec].compoundBonus += bonus;
        userCompoundBonus[rec][i] += bonus;
        rec = investors[rec].referer;
      }
  }

  function stakeBnb(uint bnbAmount) external {
      //uint bnbAmount = msg.value;
      require(bnbAmount >= 1*(10**15),"Minimum Stake");
      investors[msg.sender].firstInvestAt = block.timestamp;
      
  
      // dev Fee
      uint feeAmount = bnbAmount*stakeFee/100; 
      //marketingWalletAddress.transfer(feeAmount);

      investors[msg.sender].invested += bnbAmount;
      investors[msg.sender].stakes.push(Stake(bnbAmount, block.timestamp, false, 0));
      updateLevelBusiness(bnbAmount);
      emit stakedAt(msg.sender,  bnbAmount);
	}


  function donateBnb(uint bnbAmount) external {
      //uint bnbAmount = msg.value;
     investors_donate[msg.sender] += bnbAmount; 
     totalDonateAmount += bnbAmount;
	}

 
   // View details
  function stakeDetails(address addr) public view returns (uint[] memory amount, uint[] memory stakeAt, bool[] memory withdraw, uint[] memory withdrawAt,uint[] memory profit) {
      uint len = investors[addr].stakes.length;
      amount = new uint[](len);
      stakeAt = new uint[](len);
      withdraw = new bool[](len);
      withdrawAt = new uint[](len);
      profit = new uint[](len);
      for(uint i = 0; i < len; i++){
          amount[i] = investors[addr].stakes[i].amount;
          stakeAt[i] = investors[addr].stakes[i].stakeAt;
          withdraw[i] = investors[addr].stakes[i].withdraw;
          withdrawAt[i] = investors[addr].stakes[i].withdrawAt;
          profit[i] = stakeRoi(addr,i);
      }
      return (amount, stakeAt, withdraw, withdrawAt, profit);
  }


   // View details
  function widthdrawalRewards(address addr) public view returns (address[] memory fromAddr, uint[] memory amount, uint[] memory at) {
      uint len = investors[addr].withdrawStructs.length;
      fromAddr = new address[](len);
      amount = new uint[](len);
      at = new uint[](len);
      for(uint i = 0; i < len; i++){
          fromAddr[i] = investors[addr].withdrawStructs[i].fromAddr;
          amount[i] = investors[addr].withdrawStructs[i].amount;
          at[i] = investors[addr].withdrawStructs[i].at;
      }
      return (fromAddr, amount, at);
  }


     // View details
  function depositDetails(address addr) public view returns (uint[] memory tariff, uint[] memory amount, uint[] memory depositAt, uint[] memory cashbackAmt) {
      uint len = investors[addr].deposits.length;
      tariff = new uint[](len);
      amount = new uint[](len);
      depositAt = new uint[](len);
      cashbackAmt = new uint[](len);
      for(uint i = 0; i < len; i++){
          tariff[i] = investors[addr].deposits[i].tariff;
          amount[i] = investors[addr].deposits[i].amount;
          depositAt[i] = investors[addr].deposits[i].at;
          cashbackAmt[i] = investors[addr].deposits[i].cashbackAmount;
      }
      return (tariff,amount, depositAt, cashbackAmt);
  }


  function roi(address user) public view returns (uint amount,uint donateAmount) {
    Investor storage investor = investors[user];

    for (uint i = 0; i < investor.deposits.length; i++) {
      Deposit storage dep = investor.deposits[i];
      Tariff storage tariff = tariffs[dep.tariff];
      
      uint finish = dep.at + tariff.time;
      uint since = investor.paidAt > dep.at ? investor.paidAt : dep.at;
      uint till = block.timestamp > finish ? finish : block.timestamp;

      if (since < till) {
        amount += dep.amount * (till - since) * tariff.percent / tariff.time / 100;
        donateAmount += dep.amount * (till - since) * tariff.donatePercent / tariff.time / 100;
        
      }
    }
  }


   function showRoi(address user) public view returns (uint amount) {
    Investor storage investor = investors[user];

    for (uint i = 0; i < investor.deposits.length; i++) {
      Deposit storage dep = investor.deposits[i];
      Tariff storage tariff = tariffs[dep.tariff];
      
      uint finish = dep.at + tariff.time;
      uint since = investor.paidAt > dep.at ? investor.paidAt : dep.at;
      uint till = block.timestamp > finish ? finish : block.timestamp;

      if (since < till) {
        amount += dep.amount * (till - since) * tariff.percent / tariff.time / 100;
        
      }
    }
    amount = amount*bostonPrice;
  }
 





   function stakeRoi(address user,uint index) public view returns (uint amount) {
    Investor storage investor = investors[user];

      Stake storage dep = investor.stakes[index];
   
      
      uint finish = dep.stakeAt + (365*oneDay);
      uint since = dep.stakeAt;
      uint till = block.timestamp > finish ? finish : block.timestamp;

      if (since < till && dep.withdraw==false) {
        amount = dep.amount * (till - since) * (6*100) / (365*oneDay) / 100;
        
      }
    
  }

  
  function unstake(uint index) external {
    
    Investor storage investor = investors[msg.sender];
    Stake storage dep = investor.stakes[index];

    address payable addressAt = payable(msg.sender);
    uint amount = 0;
    //if((block.timestamp - dep.stakeAt) > (365*oneDay)){
    if((block.timestamp - dep.stakeAt) > (12*oneDay)){
      amount = stakeRoi(addressAt,index);
    }
    else {
      amount =  dep.stakeAt*85/100;
      // dev Fee
      uint DevFeeAmount = dep.stakeAt*unstakeFee/100; 
      //devWalletAddress.transfer(DevFeeAmount);

      
    }
    
    //addressAt.transfer(amount);

    investor.stakes[index].withdrawAt = block.timestamp;
    investor.stakes[index].withdraw = true;
    
    emit Unstake(msg.sender, amount, block.timestamp, index);
  }

  
  function myData() public view returns (uint,bool,bool){
       
      (uint withdrawableAmount, uint donateAmount) = roi(msg.sender);
      uint withdrawnAt  = investors[msg.sender].paidAt == 0  ? investors[msg.sender].firstInvestAt :  investors[msg.sender].paidAt;
      bool withdrawBtn  = (block.timestamp - withdrawnAt) > (7*oneDay) ? true : false;
      bool compoundBonusWillCount  = (investors_time[msg.sender].nextCompoundAt > block.timestamp) && ((investors_time[msg.sender].nextCompoundAt - block.timestamp) <= oneDay) ? true : false;
     
      return (withdrawableAmount,withdrawBtn,compoundBonusWillCount);
  }
  

  
  function withdrawal() external {
   
    address payable addressAt = payable(msg.sender);
   
    uint withdrawnAt  = investors[addressAt].paidAt == 0  ? investors[addressAt].firstInvestAt :  investors[addressAt].paidAt;
    require((block.timestamp - withdrawnAt) > (1*oneDay),"7 days gap Required") ;
    
    (uint amount, uint donateAmount) = roi(addressAt);
    
    amount +=  investors_income[addressAt].balanceRef;
    amount +=  investors_income[addressAt].compoundBonus;
    amount +=  investors_income[addressAt].cashback;
    amount +=  investors_income[addressAt].withdrawBonus;
    amount +=  investors_income[addressAt].rankBonus;
    totalDonateAmount += donateAmount;
    investors_donate[msg.sender] += donateAmount;

    require(amount>0,"No amount found");
    
    
    uint feeAmount = amount*normalWithdrawalFee/100; 
    //marketingWalletAddress.transfer(feeAmount);

    //referralFee
    uint referralFeePer;
    if(investors[msg.sender].tariffId == 0){
      referralFeePer = 5;
    } 
    else if(investors[msg.sender].tariffId == 1){
      referralFeePer = 15;
    } 
    else {
      referralFeePer = 35;
    } 
    uint referralFeeAmt = amount*referralFeePer/(100*10); 
    investors_income[investors[msg.sender].referer].withdrawBonus += referralFeeAmt;

    investors[investors[msg.sender].referer].withdrawStructs.push(WithdrawStruct(msg.sender, referralFeeAmt, block.timestamp));
    

    uint remainingAmt = amount - feeAmount - referralFeeAmt - donateAmount;
    //addressAt.transfer(remainingAmt);

    investors[addressAt].withdrawn += amount;
    investors_income[addressAt].balanceRef = 0;
    investors_income[addressAt].compoundBonus = 0;
    investors_income[addressAt].cashback = 0;
    investors_income[addressAt].withdrawBonus = 0;
    investors_income[addressAt].rankBonus = 0;
    investors_time[addressAt].paidAt = block.timestamp;
    investors[addressAt].paidAt = block.timestamp;

    uint bostonToken = amount * bostonPrice;
    investors[msg.sender].bostonToken -=  bostonToken;

    emit Sell(msg.sender, amount);
  }



  
  function emergencyWithdrawal() external {
   
    address payable addressAt = payable(msg.sender);
   
    
    (uint amount, uint donateAmount) = roi(addressAt);
    
    amount +=  investors_income[addressAt].balanceRef;
    amount +=  investors_income[addressAt].compoundBonus;
    amount +=  investors_income[addressAt].cashback;
    amount +=  investors_income[addressAt].withdrawBonus;
    amount +=  investors_income[addressAt].rankBonus;

    totalDonateAmount += donateAmount;
    investors_donate[msg.sender] += donateAmount;

    require(amount>0,"No amount found");
    
    // dev Fee
    uint DevFeeAmount = amount*emergencyWithdrawalFee/100; 
    //marketingWalletAddress.transfer(DevFeeAmount);
    
     //referralFee
    uint referralFeePer;
    if(investors[msg.sender].tariffId == 0){
      referralFeePer = 5;
    } 
    else if(investors[msg.sender].tariffId == 1){
      referralFeePer = 15;
    } 
    else {
      referralFeePer = 35;
    } 
    uint referralFeeAmt = amount*referralFeePer/(100*10); 
    investors_income[investors[msg.sender].referer].withdrawBonus += referralFeeAmt;
    investors[investors[msg.sender].referer].withdrawStructs.push(WithdrawStruct(msg.sender, referralFeeAmt, block.timestamp));

    uint remainingAmt = amount - DevFeeAmount - referralFeeAmt - donateAmount;
    //addressAt.transfer(remainingAmt);

    investors[addressAt].withdrawn += amount;
    investors_income[addressAt].balanceRef = 0;
    investors_income[addressAt].compoundBonus = 0;
    investors_income[addressAt].cashback = 0;
    investors_income[addressAt].withdrawBonus = 0;
    investors_income[addressAt].rankBonus = 0;
    investors_time[addressAt].paidAt = block.timestamp;
    investors[addressAt].paidAt = block.timestamp;
    
    uint bostonToken = amount * bostonPrice;
    investors[msg.sender].bostonToken -=  bostonToken;

    emit Sell(msg.sender, amount);
  }


 
}