// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

import "./Escrow.sol";

contract GlaxPaymentGateway{
  Escrow immutable private escrow;

  constructor(){
    escrow = new Escrow();
  }

  //Receives payment on sale
  function sendPayment(address dest) public payable {
    require(msg.value > 0, "PaymentGateway: Cannot send a value of zero");
    escrow.deposit{value: msg.value}(dest);
  }

  //to withdrawl funds
  function withdraw() public {
    escrow.withdraw(payable(msg.sender));
  }

  // checks balance available to withdraw of msg.sender
  // @return the balance
  function balance() public view returns (uint256) {
    return escrow.depositsOf(msg.sender);
  }
}