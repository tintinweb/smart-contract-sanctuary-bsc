/**
 *Submitted for verification at BscScan.com on 2022-02-28
*/

// SPDX-License-Identifier: MIT

pragma solidity =0.8.11;


contract bnbSurge{

  uint256 public totalInvestors;
  uint256 public totalInvested;
  uint256 public totalRefRewards;
  uint8 public constant COMMISSION_FEE=10; //10%
  uint8 public constant REF_FEE=5; //5%
  uint8 public constant MAX_DEPOSIT=100;//Each wallet can have a maximum of 100 deposits 
  address public commissionWallet;
  
  mapping (address=>Investor) public investors;
  Tariff[] public tariffs;
  
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
    //address referrer; --> fot gas saving not store referrer address but referrer fee pay to him/her
    uint referral_counter; 
    uint totalRef; 
    Deposit[] deposits; 
    uint invested; 
    uint lastPaidAt; 
    uint withdrawn; 
  }


  constructor(){
    commissionWallet=msg.sender;

    tariffs.push(Tariff(8 * block.timestamp,112));
    tariffs.push(Tariff(12 * block.timestamp,188));
    tariffs.push(Tariff(26 * block.timestamp,242));
    
    investors[commissionWallet].registered=true;
  }
    
  function invest(uint8 _tariff, address _referrer) public minimumInvest(msg.value) checkCorrectPlan(_tariff) checkMaxDeposit payable {
      
    if(!investors[msg.sender].registered){ 
        totalInvestors++;
        investors[msg.sender].registered=true;
      if(investors[_referrer].registered && _referrer!=msg.sender){
        //investors[msg.sender].referrer=referrer;
        investors[_referrer].referral_counter++;
        investors[_referrer].totalRef+=msg.value * REF_FEE / 100;
        totalRefRewards+=msg.value * REF_FEE / 100;
      }
    }
    
    investors[msg.sender].invested+=msg.value;
    totalInvested+=msg.value;
    investors[msg.sender].deposits.push(Deposit(_tariff,msg.value,block.timestamp));
    payable(commissionWallet).transfer((msg.value * COMMISSION_FEE) /100);
  }

  function withdrawable(address _user) public view returns(uint amount){
    
    for (uint index = 0; index < investors[_user].deposits.length; index++) {
      Deposit memory dep=investors[_user].deposits[index];
      Tariff memory tariff=tariffs[dep.tariff];

      uint finishDate=dep.at + tariff.time;
      uint fromDate=investors[_user].lastPaidAt > dep.at ? investors[_user].lastPaidAt : dep.at;
      uint toDAte= block.timestamp > finishDate ? finishDate: block.timestamp;
      
      if(fromDate < toDAte){
        amount += dep.amount * (toDAte - fromDate) * tariff.percent / tariff.time / 100;
      }
    }
  }
  
  function contractBalance() public view returns(uint){
      
      return address(this).balance;
  }
  
  function withdraw() public {
      
        // withdraw profit + ref balance
        Investor storage investor=investors[msg.sender];
        uint amount=withdrawable(msg.sender);
        
        // ref balance added to withdraw amount
        amount+=investor.totalRef;  
        investor.lastPaidAt=block.timestamp;
        bool isSuccess = payable(msg.sender).send(amount);
        if (isSuccess){
            investor.withdrawn+=amount;
            investor.totalRef=0;
        }
  }
  
  modifier minimumInvest(uint val){
    require(val>=0.05 ether,"Minimum invest is 0.05 BNB");
    _;
  }
   modifier checkCorrectPlan(uint8 tariff) {
    require(tariff<3,'incorrect plan');
    _;
  }
  modifier checkMaxDeposit(){
    require(investors[msg.sender].deposits.length <= 100,'reached 100 deposits');
    _;
    }
}