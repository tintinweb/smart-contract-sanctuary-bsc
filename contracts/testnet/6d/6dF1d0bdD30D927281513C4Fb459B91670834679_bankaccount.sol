/**
 *Submitted for verification at BscScan.com on 2022-06-11
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;
interface ERC20{


  function balanceOf(address _Owner) view external returns(uint256 balance);
  function transfer(address _to, uint256 _value) view external returns(bool success);
  function Approval(address _spender, uint256 _value) view external returns(bool success);
  function transferFrom(address _from, address _to, uint256 _value) view external returns(bool success);
  function allowance(address _Owner, address _spender) view external returns(uint256 remaining);
  
  event Transfer(address _from, address _to, uint256 _value );
  event approve(address _Owner, address _spender, uint _value);
}
contract bankaccount{
  address Owner;
  uint256 public account;
  uint256 public Investers;
  uint256 public Withdraw;
  uint256 public TranferAmount;

  ERC20 public token;

  struct Bank{
  string accountName;
  uint256 accountNumber;
  uint256 balanceOf;
  bool userExists;

}
  mapping(address=>Bank)public users;
  mapping(uint=>address)public UserAddress;
 
constructor(address _token){
  token=ERC20(_token);
  Owner=msg.sender;
}
function createAccount(string memory _accountName, uint256 _accountNumber)public returns(string memory){
  require(users[msg.sender].userExists==false);
  users[msg.sender].accountName=_accountName;
  users[msg.sender].accountNumber=_accountNumber;
  UserAddress[account]=msg.sender;
  account+=1;
  users[msg.sender].userExists=true;
  return "CrateAccount";
}
function deposit(uint256 _tokenamount)public returns(string memory){
  require(users[msg.sender].userExists==true);
  require(_tokenamount>0);
  users[msg.sender].balanceOf=users[msg.sender].balanceOf+_tokenamount;
  token.transferFrom(msg.sender,address(this),_tokenamount);
  Investers+=users[msg.sender].balanceOf;
  return "Deposit Success";
}
function withdraw(uint256 _balanceOf)public payable returns(string memory){
  require(users[msg.sender].userExists==true);
  require(_balanceOf>0);
  users[msg.sender].balanceOf=users[msg.sender].balanceOf-_balanceOf;
  Withdraw+=_balanceOf;
  token.transfer(msg.sender,_balanceOf);
  return "Withdraw Success"; 
}
function TransferAmount(address _to, uint256 _amount)public  returns(string memory){
  require(users[msg.sender].userExists==true);
  require(_amount>0);
  users[msg.sender].balanceOf=users[msg.sender].balanceOf-_amount;
  users[_to].balanceOf=users[_to].balanceOf+_amount;
  TranferAmount+=_amount;
  // payable(_to).transfer(_amount);
  return "TranferAmount Success"; 
}
 function Balance()view public returns(uint){
    return token.balanceOf(address(this));
}
}