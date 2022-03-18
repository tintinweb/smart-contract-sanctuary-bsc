/**
 *Submitted for verification at BscScan.com on 2022-03-18
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Test3 {
    uint storageData;
    string name;
    function setX(uint x) public {
        storageData = x;
    }

    function setY(string memory x) public {
        name = x;
    }
    constructor(uint x_,string memory y_){
        storageData = x_;
        name = y_;
    }
}