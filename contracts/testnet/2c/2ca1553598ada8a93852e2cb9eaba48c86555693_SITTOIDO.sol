/**
 *Submitted for verification at BscScan.com on 2023-03-31
*/

// SPDX-License-Identifier: none
pragma solidity ^0.8.12;

interface ERC20 {
    function totalSupply() external view returns (uint theTotalSupply);
    function balanceOf(address _owner) external view returns (uint balance);
    function transfer(address _to, uint _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint _value) external returns (bool success);
    function approve(address _spender, uint _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint remaining);
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

contract SITTOIDO{
  
    
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
 
    
  uint public MIN_DEPOSIT_USDT  ;
  
  address public buyTokenAddr = 0x55a7f2DE1e9FE58bA6493132160b8fF1F1388741; // TESTNET
  
  uint public tokenPrice;
  uint public tokenPriceDecimal;
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

 function buyTokenWithUSDT(uint UsdtAmount) external  {
        require( UsdtAmount >= MIN_DEPOSIT_USDT);
        UsdtAmount = UsdtAmount ;
        ERC20 sendtoken    = ERC20(buyTokenAddr);
        ERC20 receiveToken = ERC20(0x7e32FA53123E1953305b2e995D71EAf9fF4dE415);///Testnet
        
        uint tokenVal = (UsdtAmount* 10**tokenPriceDecimal) / tokenPrice ; 
        
        require(sendtoken.balanceOf(address(this)) >= tokenVal, "Insufficient contract balance");
        require(receiveToken.balanceOf(msg.sender) >= UsdtAmount, "Insufficient user balance");
      
        receiveToken.transferFrom(msg.sender, contractAddr, UsdtAmount);
        investors[msg.sender].invested += tokenVal;
        totalInvested += tokenVal;
       
        sendtoken.transfer(msg.sender, tokenVal);
        emit DepositAt(msg.sender, 0, tokenVal);
  
  } 
  function buyTokenWithBUSD(uint BusdAmount) external  {
        BusdAmount = BusdAmount ;
        ERC20 sendtoken    = ERC20(buyTokenAddr);
        ERC20 receiveToken = ERC20(0xd37675DaD087285e94a6317710F4FD7243895F99);///Testnet
        
        uint tokenVal = (BusdAmount* 10**tokenPriceDecimal) / tokenPrice ; 
        
        require(sendtoken.balanceOf(address(this)) >= tokenVal, "Insufficient contract balance");
        require(receiveToken.balanceOf(msg.sender) >= BusdAmount, "Insufficient user balance");
      
        receiveToken.transferFrom(msg.sender, contractAddr, BusdAmount);
        investors[msg.sender].invested += tokenVal;
        totalInvested += tokenVal;
       
        sendtoken.transfer(msg.sender, tokenVal);
        emit DepositAt(msg.sender, 0, tokenVal);
  
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

    // Owner Token Withdraw    
    // Only owner can withdraw token 
    function withdrawToken(address tokenAddress, address to, uint amount) public returns(bool) {
        require(msg.sender == owner, "Only owner");
        require(to != address(0), "Cannot send to zero address");
        ERC20 _token = ERC20(tokenAddress);
        _token.transfer(to, amount);
        return true;
    }

       // // Owner USDT Withdraw
    // // Only owner can withdraw USDT from contract
      function withdrawUSDT(address tokenAddress, address to, uint amount) public returns(bool) {
        require(msg.sender == msg.sender, "Only owner");
        require(to != address(0), "Cannot send to zero address");
        ERC20 _token = ERC20(tokenAddress);
        _token.transfer(to,amount);
        return true;
    }
       // // Owner BUSD Withdraw
    // // Only owner can withdraw BUSD from contract

    function withdrawBUSD(address tokenAddress, address to, uint amount) public returns(bool) {
        require(msg.sender == msg.sender, "Only owner");
        require(to != address(0), "Cannot send to zero address");
        ERC20 _token = ERC20(tokenAddress);
        _token.transfer(to,amount);
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