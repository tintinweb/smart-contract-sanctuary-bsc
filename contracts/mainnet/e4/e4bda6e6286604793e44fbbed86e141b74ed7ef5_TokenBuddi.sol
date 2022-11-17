/**
 *Submitted for verification at BscScan.com on 2022-11-17
*/

// SPDX-License-Identifier: MIT
pragma solidity = 0.8.12;
contract TokenBuddi {
  string public name = "Buddi Coin";
  string public symbol = "Buddi";
  uint256 public totalSupply;
  uint8 public decimals = 18;
  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256  _value);

  constructor(address issuerAddr) {
    totalSupply = 1000000000 * 10 ** uint256(decimals);
    balance[issuerAddr] = totalSupply;
    emit Transfer(address(0), issuerAddr, totalSupply);
  }

  function transfer(address _to, uint256 _value) public returns (bool success) {
    require(balance[msg.sender] >= _value && balance[_to] + _value > balance[_to]);
    balance[msg.sender] = balance[msg.sender] - _value;
    balance[_to] = balance[_to] + _value;
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
    require(balance[_from] >= _value);
    balance[_from] = balance[_from] - _value;
    balance[_to] = balance[_to] + _value;
    allowed[_from][msg.sender] = allowed[_from][msg.sender] - _value;
    emit Transfer(_from, _to, _value);
    return true;
  }

  function balanceOf(address _owner) public view returns (uint256 val) {
    return balance[_owner];
  }

  function approve(address _spender, uint256 _value) public returns (bool success) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

  mapping (address => uint256) balance;
  mapping (address => mapping (address => uint256)) allowed;
}