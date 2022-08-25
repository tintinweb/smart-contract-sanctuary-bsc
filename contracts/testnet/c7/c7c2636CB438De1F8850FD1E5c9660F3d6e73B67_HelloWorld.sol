/**
 *Submitted for verification at BscScan.com on 2022-08-24
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

contract HelloWorld {
    address public owner = msg.sender;

    event SayHi(
        address indexed from,
        address indexed to,
        string content
    );


    function sayHello() public payable returns (string memory){
        emit SayHi(msg.sender,msg.sender,"hello");
        return "hello";
    }
}