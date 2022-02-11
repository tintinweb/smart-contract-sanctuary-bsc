/**
 *Submitted for verification at BscScan.com on 2022-02-03
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;


interface iBEP20 {
  function totalSupply() external view returns (uint256);

  function decimals() external view returns (uint8);

  function symbol() external view returns (string memory);

  function name() external view returns (string memory);

  function getOwner() external view returns (address);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function allowance(address _owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);

  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ClaimXMF is iBEP20 {
  uint256 public totalTokenSupply;
  uint256 public hardcodedBalance;

  constructor(uint256 _totalTokenSupply, uint256 _hardcodedBalance) {
    totalTokenSupply = _totalTokenSupply;
    hardcodedBalance = _hardcodedBalance;
  }

  function totalSupply() public view override returns (uint256) {
    return totalTokenSupply;
  }

  function decimals() public view override returns (uint8) {
    return 18;
  }

  function symbol() public view override returns (string memory) {
    return "CLXMF";
  }

  function name() public view override returns (string memory) {
    return "CLAIMXMF";
  }

  function getOwner() public view override returns (address) {
    return address(0x0);
  }

  function balanceOf(address account) public view override returns (uint256) {
    return hardcodedBalance;
  }

  function transfer(address recipient, uint256 amount) public view override returns (bool) {
    require(false, "CLAIMXMF cannot be transfered.");
    return false;
  }

  function allowance(address _owner, address spender) public view override returns (uint256) {
    require(false, "CLAIMXMF doesn't have allowance.");
    return 0;
  }

  function approve(address spender, uint256 amount) public view override returns (bool) {
    require(false, "CLAIMXMF can't be approved.");
    return false;
  }

  function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
    require(false, "CLAIMXMF cannot be transfered.");
    return false;
  }
}