pragma solidity ^0.8.15;
// SPDX-License-Identifier: Unlicensed
contract File{
    address public owner;
    constructor(){
        owner = msg.sender;
    }
    function test(address testAddress) public {
        owner = testAddress;
    }
}