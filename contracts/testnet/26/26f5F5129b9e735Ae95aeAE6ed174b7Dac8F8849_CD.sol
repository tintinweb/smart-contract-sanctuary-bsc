// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;


contract CD {
    address public owner;
    constructor(address addr){
        owner = addr;
    }
    function getA() public view returns(address){
        return owner;
    }
}