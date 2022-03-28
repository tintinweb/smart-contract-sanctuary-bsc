/**
 *Submitted for verification at BscScan.com on 2022-03-27
*/

//SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

contract Greeto{
    string greeting;//23

    constructor(string memory _greeting){
        greeting = _greeting;
    }

    function getGreeting() public view returns (string memory) {
    return greeting;
  }

  function setGreeting(string memory _greeting) public {
    greeting = _greeting;
  }

}