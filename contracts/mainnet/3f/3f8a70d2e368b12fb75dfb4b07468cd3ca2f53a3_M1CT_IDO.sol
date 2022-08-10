/**
 *Submitted for verification at BscScan.com on 2022-08-10
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

contract M1CT_IDO{
    
  
  
  struct Investor {
   uint invested;
   uint investedBnb;
    
  }
 
    
  uint public MIN_DEPOSIT_BUSD = 1 ;
  uint START_AT        = 22442985;
  address public buyTokenAddr = 0xd4C82D4C004180739D5eD34C45DeBB75F3E1fcD5; 
  uint public tokenPerBnb         = 200000;
  event OwnershipTransferred(address);
  
  address public owner = msg.sender;
  
  
  uint public totalInvested;
  uint public totalInvestedBnb;
  address public contractAddr = address(this);
  
  mapping (address => Investor) public investors;
  event BuyAt(address user, uint amount);
 
 
  function buy() external payable {
    BEP20 token = BEP20(buyTokenAddr);
    require(msg.value >= 0);
    require((totalInvestedBnb+msg.value) <= 500*(10**18),"Max Bnb Purchase Exceed");
    uint tokenVal = tokenPerBnb*msg.value ;
    
    investors[msg.sender].invested += tokenVal;
    investors[msg.sender].investedBnb += msg.value;
    totalInvested += tokenVal;
    totalInvestedBnb += msg.value;
    
    token.transfer(msg.sender, tokenVal);
    
    emit BuyAt(msg.sender, tokenVal);
  
  } 
  

  
    function tokenInBNB(uint amount) public view returns (uint) {
        uint tokenVal = tokenPerBnb*amount;
        return (tokenVal);
    }

    /*
    like tokenPrice = 0.0000000001
    setBuyPrice = 1 
    tokenPriceDecimal= 10
    */
    // Set buy price  
    function setTokenAmountPerBnb(uint _tokenAmount) public {
      require(msg.sender == owner, "Only owner");
      tokenPerBnb        = _tokenAmount;
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