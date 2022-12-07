/**
 *Submitted for verification at BscScan.com on 2022-12-06
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
contract HelloWorld {

    string public message = "Hello World";

    function getMessage() public view returns(string memory) {
        return message;
    }

    function setMessage(string memory newMessage) public {
        message = newMessage;
    }

}