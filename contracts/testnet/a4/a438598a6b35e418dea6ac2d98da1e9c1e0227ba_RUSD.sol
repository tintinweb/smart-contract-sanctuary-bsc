/**
 *Submitted for verification at BscScan.com on 2022-12-09
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.5.0;

// RUSD is a stable coin that is pegged to the US dollar
contract RUSD {
  // Interest rate is set at 2%
  uint256 public interestRate = 2;
  
  // This is the address of the contract owner (the developer)
  address public devWallet;
  
  // This is the maximum amount of RUSD that can be borrowed as a percentage of the collateral
  uint256 public maxLoanPercentage = 75;
  
  // This mapping stores the current balance of each user's RUSD and ETH collateral
  struct UserBalances {
  uint256 rusdBalance;
  uint256 ethBalance;
}
mapping (address => UserBalances) public userBalances;

  
  // This event is emitted when a user borrows RUSD
  event LoanTaken(
    address indexed borrower,
    uint256 rusdBorrowed,
    uint256 ethCollateral
  );
  
  // This event is emitted when a user repays a loan
  event LoanRepaid(
    address indexed borrower,
    uint256 rusdRepaid,
    uint256 ethCollateral
  );
  
  // This function is called when the contract is deployed
  constructor() public {
    devWallet = msg.sender;
  }
  
  // This function allows a user to borrow RUSD
  function borrow(uint256 _rusdBorrowed) public {
    // Calculate the amount of ETH required as collateral
    uint256 ethCollateral = _rusdBorrowed * 100 / (100 - maxLoanPercentage);
    
    // Check that the user has sufficient ETH balance
    require(userBalances[msg.sender].ethBalance >= ethCollateral, "Insufficient ETH balance");
    
    // Deduct the required ETH collateral from the user's balance
    userBalances[msg.sender].ethBalance -= ethCollateral;
    
    // Add the borrowed RUSD to the user's balance
    userBalances[msg.sender].rusdBalance += _rusdBorrowed;
    
    // Emit the LoanTaken event
    emit LoanTaken(msg.sender, _rusdBorrowed, ethCollateral);
  }
  
  // This function allows a user to repay a loan
  function repay(uint256 _rusdRepaid) public {
    // Check that the user has sufficient RUSD balance
    require(userBalances[msg.sender].rusdBalance >= _rusdRepaid, "Insufficient RUSD balance");
    
    // Calculate the amount of ETH collateral that the user will receive
    uint256 ethCollateral = _rusdRepaid * 100 / (100 + interestRate);
    
    // Add the ETH collateral to the user's balance
    userBalances[msg.sender].ethBalance += ethCollateral;
    
    // Deduct the repaid RUSD from the user's balance
    userBalances[msg.sender].rusdBalance -= _rusdRepaid;
    
    // Emit the LoanRepaid event
    emit LoanRepaid(msg.sender, _rusdRepaid, ethCollateral);
  }
}