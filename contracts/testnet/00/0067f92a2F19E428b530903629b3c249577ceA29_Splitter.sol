/**
 *Submitted for verification at BscScan.com on 2023-01-13
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

contract Splitter {
  function sendDifferentAmounts(uint[] calldata amounts, address[] calldata recipients) public payable {
    require(recipients.length >= amounts.length, "recipients specified less than the amounts");
    require(recipients.length <= amounts.length, "amounts specified less than the recipients");
    uint amount;
    for (uint i = 0; i < amounts.length; i++) {
      amount = amounts[i];
      if(amount > 0) payable(recipients[i]).transfer(amount);
    }
  }

  function sendSameAmount(uint amount, address[] calldata recipients) public payable {
    require(amount > 0, "zero amount");
    for (uint i = 0; i < recipients.length; i++) {
      payable(recipients[i]).transfer(amount);
    }
  }
}