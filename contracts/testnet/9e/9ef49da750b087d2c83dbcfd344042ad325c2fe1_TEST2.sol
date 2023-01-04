/**
 *Submitted for verification at BscScan.com on 2023-01-04
*/

// SPDX-License-Identifier: none
pragma solidity ^0.8.8;

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

contract TEST2{
  
    
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
   Deposit[] deposits;
    uint invested;
    uint paidAt;
    uint withdrawn;
  }
 
    
  uint public MIN_DEPOSIT_BUSD ;
  
  address public buyTokenAddr = 0x332a9F32FC26511Da5CcF7CE604906328b7323a5; // TESTNET
  
  uint public tokenPrice         = 10;
  uint public tokenPriceDecimal  = 2;
  event OwnershipTransferred(address);
  
  address public owner = msg.sender;
  
  
  uint public totalInvestors;
  uint public totalInvested;
  uint public totalWithdrawal;
  address public contractAddr = address(this);
  
  mapping (address => Investor) public investors;
  event DepositAt(address user, uint tariff, uint amount);
  event Reinvest(address user, uint tariff, uint amount);
  event Withdraw(address user, uint amount);
  


  
  
  constructor() {
    
  }

 function buyToken(uint busdAmount) external {
        require( busdAmount >= MIN_DEPOSIT_BUSD);
        busdAmount = busdAmount ;
        BEP20 sendtoken    = BEP20(buyTokenAddr);
        BEP20 receiveToken = BEP20(0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee);///Testnet
        
        uint tokenVal = (busdAmount* 10**tokenPriceDecimal) / tokenPrice ; 
        
        require(sendtoken.balanceOf(address(this)) >= tokenVal, "Insufficient contract balance");
        //require(receiveToken.balanceOf(msg.sender) >= busdAmount, "Insufficient user balance");
      
        receiveToken.transferFrom(msg.sender, contractAddr, busdAmount);
        investors[msg.sender].invested += tokenVal;
        totalInvested += tokenVal;
       
        sendtoken.transfer(msg.sender, tokenVal);
        emit DepositAt(msg.sender, 0, tokenVal);
  
  } 
  
  function myTariff() public view returns (uint) {
      
      uint tariff = investors[msg.sender].deposits[0].tariff;
      return tariff;
    
    }
  
    function myTotalInvestment() public view returns (uint) {
        Investor storage investor = investors[msg.sender];
        uint amount = investor.invested;
        return amount;
    }
  
  
  
    function tokenInBUSD(uint amount) public view returns (uint) {
        uint tokenVal = (amount * 10**tokenPriceDecimal ) /(tokenPrice*1000000000000000000) ;
        return (tokenVal);
    }
    /*
    like tokenPrice = 0.0000000001
    setBuyPrice = 1 
    tokenPriceDecimal= 10
    */
    // Set buy price  
    function setBuyPrice(uint _price, uint _decimal) public {
      require(msg.sender == owner, "Only owner");
      tokenPrice        = _price;
      tokenPriceDecimal = _decimal;
    }
    
    
    // Set buy price decimal i.e. 
    function setMinBusd(uint _busdAmt) public {
      require(msg.sender == owner, "Only owner");
      MIN_DEPOSIT_BUSD = _busdAmt;
    }


   
    // Owner Token Withdraw    
    // Only owner can withdraw token 
    function withdrawToken(address tokenAddress, address to, uint amount) public returns(bool) {
        require(msg.sender == owner, "Only owner");
        require(to != address(0), "Cannot send to zero address");
        BEP20 _token = BEP20(tokenAddress);
        _token.transfer(to, amount);
        return true;
    }
    
    // Owner BNB Withdraw
    // Only owner can withdraw BNB from contract
    function withdrawBNB(address payable to, uint amount) public returns(bool) {
        require(msg.sender == owner, "Only owner");
        require(to != address(0), "Cannot send to zero address");
        to.transfer(amount);
        return true;
    }
    
    // Ownership Transfer
    // Only owner can call this function
    function transferOwnership(address to) public returns(bool) {
        require(msg.sender == owner, "Only owner");
        require(to != address(0), "Cannot transfer ownership to zero address");
        owner = to;
        emit OwnershipTransferred(to);
        return true;
    }

}