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

interface iPresale {
  function getPresaleTokensToRedeem(address wallet) external view returns (uint256);

  function getPresaleTokensSold() external view returns (uint256);
}

contract ClaimXMF is iBEP20 {
  uint256 public totalTokenSupply;
  uint256 public hardcodedBalance;
  
  iPresale presale;

  constructor(uint256 _totalTokenSupply, uint256 _hardcodedBalance, address _presaleAddress) {
    totalTokenSupply = _totalTokenSupply;
    hardcodedBalance = _hardcodedBalance;

    presale = iPresale(_presaleAddress);
  }

  function totalSupply() public view override returns (uint256) {
    return presale.getPresaleTokensSold();
  }

  function decimals() public pure override returns (uint8) {
    return 18;
  }

  function symbol() public pure override returns (string memory) {
    return "CLXMF";
  }

  function name() public pure override returns (string memory) {
    return "CLAIMXMF";
  }

  function getOwner() public pure override returns (address) {
    return address(0x0);
  }

  function balanceOf(address account) public view override returns (uint256) {
    return presale.getPresaleTokensToRedeem(account);
  }

  function transfer(address recipient, uint256 amount) public pure override returns (bool) {
    require(false, "CLAIMXMF cannot be transfered.");
    return false;
  }

  function allowance(address _owner, address spender) public pure override returns (uint256) {
    require(false, "CLAIMXMF doesn't have allowance.");
    return 0;
  }

  function approve(address spender, uint256 amount) public pure override returns (bool) {
    require(false, "CLAIMXMF can't be approved.");
    return false;
  }

  function transferFrom(address sender, address recipient, uint256 amount) public pure override returns (bool) {
    require(false, "CLAIMXMF cannot be transfered.");
    return false;
  }
}