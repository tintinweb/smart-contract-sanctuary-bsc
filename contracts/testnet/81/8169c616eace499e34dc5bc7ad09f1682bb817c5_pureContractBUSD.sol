/**
 *Submitted for verification at BscScan.com on 2022-10-17
*/

// SPDX-License-Identifier: none
pragma solidity ^0.8.11;

interface BEP20 {
    function approve(address _spender, uint _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint remaining);
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
  }

  Tariff[] public tariffs;
  uint[] public refRewards;
  uint public oneDay = 86400; 
  uint public totalInvestors;
  uint public totalInvested;
  uint public berryPricePerBusd = 100;
  uint public ownerFee = 3;
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
        
        if (!investors[msg.sender].registered) {
            investors[msg.sender].registered = true;
            investors[msg.sender].referer = referer;
         }
       
    }

    function calculateBerry(uint amt) public view returns (uint berrryAmt) {
        berrryAmt = (amt*berryPricePerBusd)/(10**18);
    }
}