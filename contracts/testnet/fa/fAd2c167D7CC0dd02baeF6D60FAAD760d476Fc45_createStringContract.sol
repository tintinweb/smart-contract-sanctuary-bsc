/**
 *Submitted for verification at BscScan.com on 2022-04-15
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

contract changeString {
    string public nam;
    constructor(string memory _name){
        nam = _name;
    }
    function setName(string memory _name) public returns(bool) {
        nam = _name;
        return true;
    }
}

contract createStringContract {
    changeString[] public allChangeString;
    function create(string memory _name) public {
        changeString csc = new changeString(_name);
        allChangeString.push(csc);
    }
}