/**
 *Submitted for verification at BscScan.com on 2022-06-17
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >= 0.8.0;

contract inheritance {

    mapping (string => uint) public receiveValue;

    function writeValue (string memory name, uint newValue) public {
        receiveValue[name] = newValue;
    }

    function readValue (string memory name) public view returns(uint) {
        return receiveValue[name];
    }
    
}