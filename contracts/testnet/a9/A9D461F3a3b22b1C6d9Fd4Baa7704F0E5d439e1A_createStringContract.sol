/**
 *Submitted for verification at BscScan.com on 2022-04-15
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

contract changeString {
    string public name;
    constructor(string memory _name){
        name = _name;
    }
    function setName(string memory _name) public returns(bool) {
        name = _name;
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