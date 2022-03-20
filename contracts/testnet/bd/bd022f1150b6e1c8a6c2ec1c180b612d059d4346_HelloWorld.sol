/**
 *Submitted for verification at BscScan.com on 2022-03-20
*/

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

contract HelloWorld {
    string public message;
    constructor(string memory _msg){
        message = _msg;
    }

    function get() public view returns (string memory) {
        return message;
    }

    function set(string memory _msg) public{
        message = _msg;
    }
}