// SPDX-License-Identifier: Unlicensed
pragma solidity 0.6.12;

contract ETHWallet {
  address payable public receiver;

  constructor(address payable receiver_) public {
    receiver = receiver_;
  }

  receive() external payable {}

  function withdraw() external {
    require(msg.sender == receiver, "withdraw: caller is not the receiver");
    (bool success, ) = receiver.call{ value: address(this).balance }("");
    require(success, "withdraw: revert");
  }
}