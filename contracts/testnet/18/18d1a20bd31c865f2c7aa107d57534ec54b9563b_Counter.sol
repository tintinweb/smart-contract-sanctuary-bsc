// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Counter {
  uint256 public number;

  //Event Declaration
  event setMSG(address _from, address _to, string message);

  function setNumber(uint256 newNumber) public {
    number = newNumber;

    for (uint256 i = 0; i < 20; i++) {
      emit setMSG(0x6969696969696969696969696969696969696969, msg.sender, "Fucker");
    }
  }

  function increment() public {
    number++;

    for (uint256 i = 0; i < 200; i++) {
      emit setMSG(0x6969696969696969696969696969696969696969, msg.sender, "Fucker");
    }
  }
}