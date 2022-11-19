/**
 *Submitted for verification at BscScan.com on 2022-11-18
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
contract Hello{
    string public hellostr;
    constructor() {
        hellostr="Hello world";
    }
    function setHello(string memory newvalue) public {
        hellostr = newvalue; 

    }
    function getHello() public view returns(string memory) {
        return hellostr; 
    }
    function getHello2() public view returns(string memory output) {
        output= hellostr;
    }
}