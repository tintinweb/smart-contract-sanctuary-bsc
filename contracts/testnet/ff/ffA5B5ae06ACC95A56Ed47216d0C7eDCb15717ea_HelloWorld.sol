/**
 *Submitted for verification at BscScan.com on 2022-12-17
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.5.10;

contract HelloWorld {

   string public message;

   constructor(string memory initMessage) public {
      message = initMessage;
   }

   function update(string memory newMessage) public {
      message = newMessage;
      }
}