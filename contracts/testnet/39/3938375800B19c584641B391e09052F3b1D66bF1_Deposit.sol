// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Deposit {

  mapping (address => uint256) public amountOf;

  function deposit() external payable {
    require(msg.value != 0, "Not zero");
    amountOf[msg.sender] = msg.value;
  }

  function withdraw() external {
    require(amountOf[msg.sender] != 0, "No call");
    require(msg.sender != address(0), "No zero address");
    (bool success, ) = payable(msg.sender).call{ value: amountOf[msg.sender] }("");
    require(success, "No success to withdraw ");
  }

  function getBalance() public view returns (uint256) {
    return address(this).balance;
  }
}