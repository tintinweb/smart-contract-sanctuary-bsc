/**
 *Submitted for verification at BscScan.com on 2022-05-31
*/

// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract Greeter {
  string private greeting;

  constructor(string memory _greeting) {
    greeting = _greeting;
  }

  function sayHi() public view returns (string memory) {
    return greeting;
  }

  function setGreeting(string memory _greeting) public {
    greeting = _greeting;
  }
}