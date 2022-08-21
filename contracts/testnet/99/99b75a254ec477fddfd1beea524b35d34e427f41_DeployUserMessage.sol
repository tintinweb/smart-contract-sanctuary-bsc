/**
 *Submitted for verification at BscScan.com on 2022-08-20
*/

pragma solidity ^0.8.11;

contract UserMessage {
  string message;
  constructor(string memory _message){
     message = _message;
  }
}

contract DeployUserMessage {
  mapping(address => address) userToContract;
   constructor(){
  }
  function Deploy(string memory message) public {
    new UserMessage(message);
  }
}