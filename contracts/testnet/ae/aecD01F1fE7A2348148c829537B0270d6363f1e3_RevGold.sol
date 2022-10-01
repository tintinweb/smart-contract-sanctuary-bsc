// SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

contract RevGold {
  address public owner;

  constructor() {
    owner = msg.sender;
  }

  function deposit() external payable {
    require(msg.value == 2 ether, "please send two ether");
  }

  function withdraw() external {
    require(msg.sender == owner, "No");
    // msg.sender.transfer(address(this).balance);
  }

  // this is observable without help from the contract, could be left out or included as a courtesy

  function balance() external view returns (uint256 balanceEth) {
    balanceEth = address(this).balance;
  }
}