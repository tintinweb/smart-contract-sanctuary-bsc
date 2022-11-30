/**
 *Submitted for verification at BscScan.com on 2022-11-30
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract GeekCodes {

    mapping(address => string) public codes;

    constructor() {
        
    }

    function setCode(string memory code) public {
        codes[msg.sender] = code;
    }
   
    function getCode() public view returns (string memory) {
        return codes[msg.sender];
    }
}