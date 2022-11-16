/**
 *Submitted for verification at BscScan.com on 2022-11-15
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract Hello {

    string public helloStr = "Initial Value!";

    constructor() {
        helloStr = "Hello World!";
    }

    function setHello(string memory newValue) public {
        helloStr = newValue;
    }

    function getHello() public view returns(string memory) {
        return helloStr;
    }
}