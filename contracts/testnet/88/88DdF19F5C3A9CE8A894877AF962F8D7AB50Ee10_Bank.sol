// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// Template used to initialize state variables 
contract Bank {

  uint256 public bank_funds;
  address public owner;
  address public deployer;

  constructor(address _owner, uint256 _funds) {
    bank_funds = _funds;
    owner = _owner;
    deployer = msg.sender;
  }
}