/**
 *Submitted for verification at BscScan.com on 2022-05-20
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

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