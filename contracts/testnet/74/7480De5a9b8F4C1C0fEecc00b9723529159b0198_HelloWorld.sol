/**
 *Submitted for verification at BscScan.com on 2022-05-22
*/

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;


contract HelloWorld {
  string public message;
  
  constructor(string memory _message){
    message = _message;
  }

  function printHelloWorld() public view returns (string memory) {
    return message;
  }

  function updateMessage(string memory _message) public {
    message = _message;
  }

}