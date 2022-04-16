// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.7.4;

contract GotFinance {

  string public _name = "GotFinance";
  string public _symbol = "GOF";
  uint8 public _decimals = 5;
  constructor() {

  }

  function balanceOf() external pure returns (uint256) {
    return 1;
  }

  // function greet() public view returns (string memory) {
  //   return greeting;
  // }

}