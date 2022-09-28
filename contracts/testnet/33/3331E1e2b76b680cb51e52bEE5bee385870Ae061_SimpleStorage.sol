/**
 *Submitted for verification at BscScan.com on 2022-09-28
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

contract SimpleStorage {

   string message = "Hellow Word";
   
   function getMessage() public view returns(string memory) {
      return message;
   }

   function setMessage(string memory newMessage) public {
      message = newMessage;
   }

}