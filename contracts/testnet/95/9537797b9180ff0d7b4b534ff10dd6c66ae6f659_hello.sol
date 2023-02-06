/**
 *Submitted for verification at BscScan.com on 2023-02-05
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13; 

contract hello {
    
    string public HelloStr = "Intial value";

    constructor() {
        HelloStr = "Hello Word" ;
    }

    function SetHello(string memory newValue) public {
        HelloStr = newValue ;
    }

    function getHello() public view returns(string memory) {
        return HelloStr;
    }

}