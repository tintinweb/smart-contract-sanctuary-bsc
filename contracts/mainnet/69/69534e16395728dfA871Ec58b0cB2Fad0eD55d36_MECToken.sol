// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.12;

import "./SafeMath.sol";

/// @title Meta Energy Coin 
/// @author Meta Gobi Energy LLC
contract MECToken {
  using SafeMath for uint256;

  uint256 public totalSupply;
  uint8 public decimals;
  string public symbol;
  string public name;
  
  address public creator;
  bool public isActive;

  mapping (address => uint256) private balances;
  mapping (address => mapping (address => uint256)) private allowances;

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);

  modifier onlyCreator {
    require(msg.sender == creator, "Only creator can do this action!");
    _;
  }

  modifier whenActive {
    require(isActive, "Contract is inactive!");
    _;
  }

  constructor() {
    creator = msg.sender;
    name = "Meta Energy Coin";
    symbol = "MEC";
    decimals = 18;
    totalSupply = 100_000_000_000 ether;
    balances[creator] = totalSupply;    
    isActive = true;
    emit Transfer(address(0), creator, totalSupply);
  }

  function revertActiveness() external onlyCreator returns (bool) {
    isActive  = !isActive;
    return true;
  }

  function balanceOf(address account) external view returns (uint256) {
    return balances[account];
  }

  function transfer(address recipient, uint256 amount) external whenActive returns (bool) {
    _transfer(msg.sender, recipient, amount);
    return true;
  }

  function allowance(address owner, address spender) external view returns (uint256) {
    return allowances[owner][spender];
  }

  function approve(address spender, uint256 amount) external whenActive returns (bool) {
    _approve(msg.sender, spender, amount);
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 amount) external whenActive returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, msg.sender, allowances[sender][msg.sender].sub(amount, "Transfer amount exceeds allowance"));
    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue) public whenActive returns (bool) {
    _approve(msg.sender, spender, allowances[msg.sender][spender].add(addedValue));
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public whenActive returns (bool) {
    _approve(msg.sender, spender, allowances[msg.sender][spender].sub(subtractedValue, "Decreased allowance below zero"));
    return true;
  }

  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "Transfer from the zero address");
    require(recipient != address(0), "Transfer to the zero address");
    balances[sender] = balances[sender].sub(amount, "Transfer amount exceeds balance");
    balances[recipient] = balances[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
  }

  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "Approve from the zero address");
    require(spender != address(0), "Approve to the zero address");
    allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  function emergencyExtractToCreator() external onlyCreator {
    (bool success,) = payable(creator).call{value: address(this).balance}("");
    require(success, "Transfer failed.");    
  }

}