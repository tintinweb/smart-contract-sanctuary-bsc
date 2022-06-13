/**
 *Submitted for verification at BscScan.com on 2022-06-13
*/

// SPDX-License-Identifier: MIT
 pragma solidity 0.8.7;


 contract mytoken{
     string name;
     string symbol;
     uint256 totalSupply;
     uint256 decimal;

mapping (address=>uint256) public balanceOf;
mapping(address=> mapping(address =>uint256)) public allowed;
address public _owner;

 constructor(string memory _name,string memory _symbol,uint256 _totalSupply,uint256 _decimal){
     name=_name;
     symbol=_symbol;
     totalSupply=_totalSupply;
     decimal=_decimal;
     balanceOf[msg.sender]=totalSupply;
     _owner = msg.sender;
    
 }
 function getname() public view  returns (string memory){
     return name;
 }
 function getsymbol() public view returns(string memory){
     return symbol;
 }
 function gettotalSupply() public view returns(uint256){
     return totalSupply;
 }
 function getdecimal()public view returns(uint256){
     return decimal;
 }
 function transfer(address to, uint256 _amount) public returns(bool){
     require(balanceOf[msg.sender]>=_amount);
      (balanceOf[msg.sender]-=_amount);
     balanceOf[to]+=_amount;
     return true;
 }
 function approve(address to, uint256 amount) public returns (bool){
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