/**
 *Submitted for verification at BscScan.com on 2022-10-23
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract HelloWorld {
    string public greet = "Hello World!";

    function setGreet(string memory newMessage) public {
        greet = newMessage;
    } 
}