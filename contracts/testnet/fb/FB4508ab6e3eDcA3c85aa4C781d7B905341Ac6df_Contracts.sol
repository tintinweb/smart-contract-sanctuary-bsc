/**
 *Submitted for verification at BscScan.com on 2022-07-07
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

contract Contracts {
  uint public count = 0; // state variable
  
  struct Bill{
    address customers;
    uint256 amountDeposit;
    uint256 amountWithdraw;
    uint256 timestamp;
  }
  mapping(address => Bill[]) public bills;
  
  mapping(address => uint256) public balances;

  function Deposit() public payable {
    // require(msg.value == amount);
    balances[msg.sender] += msg.value;
    createBill(msg.sender, msg.value, 0, block.timestamp);
  }

  function Withdraw(uint256 amount) public {
    require(amount <= balances[msg.sender]);
    balances[msg.sender] -= amount;
    // (bool sent,) = msg.sender.call{value; amount}("sent");
    // require(sent, "Failed to Complete");
    // payable(msg.sender).transfer(amount);
    createBill(msg.sender, 0, amount, block.timestamp);
  }
  // payable(address(msg.sender)).transfer(amount);

  function getBalance() public view returns(uint256) {
    return balances[msg.sender];
  }
  
  function createBill(address customers, uint256 amountDeposit, uint256 amountWithdraw, uint256 timestamp) public {
    Bill memory bill = Bill(customers, amountDeposit, amountWithdraw, timestamp);
    bills[msg.sender].push(bill);
  }

  function getBill() public view returns(Bill[] memory){
    return bills[msg.sender];
  }
 
}