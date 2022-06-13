/**
 *Submitted for verification at BscScan.com on 2022-06-13
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
   contract numtoken{
       string name;
       string symbol;
       uint256 decimal;
       uint256 totalSupply;
      address public _owner;
       mapping(address =>uint256) public balanceOf;
      mapping(address=>mapping(address => uint256 )) public allowed;
   
constructor(string memory _name,string  memory _symbol, uint256 _decimal, uint256 _totalSupply){
    name =_name;
    symbol=_symbol;
    decimal= _decimal;
    totalSupply=_totalSupply;
    balanceOf[msg.sender] =totalSupply;

   }
   function getname()public view returns(string memory){
       return name;
   }
   function getsymbol()public view returns(string memory){
       return symbol;
   }
   function getdecimal()public view returns(uint256){
       return decimal;
   }
   function gettotalSupply()public view returns(uint256){
       return totalSupply;
   }
   function transfer(address to, uint256 amount)public returns(bool) {
       require(balanceOf[msg.sender]>=amount);
       balanceOf[msg.sender]-=amount;
       balanceOf[to]+=amount;
       return true;
   } 
   function approve(address to, uint256 amount) public returns(bool){
       require(balanceOf[msg.sender]>=amount);
       allowed[msg.sender][to]=amount;
       return true;
   }
   
  function transferFrom(address from,address to, uint256 amount) public returns(bool){
      require(balanceOf[from]>=amount);
      require(allowed[from][msg.sender]>=amount);
      balanceOf[from]-=amount;
      balanceOf [to]+=amount;
      allowed[from][msg.sender]-=amount;
      return true;
  }
   }