// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract HelloWorldV2 {
    string private message;

    function getMessage() public view returns (string memory) {
        return message;
    }

    function getHelloMessage() public view returns (string memory) {
        return string.concat("Hello", message);
    }

    function setMessage(string memory newMessage) public {
        message = newMessage;
    }
}