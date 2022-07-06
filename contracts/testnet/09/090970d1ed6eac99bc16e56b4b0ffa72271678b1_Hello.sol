/**
 *Submitted for verification at BscScan.com on 2022-07-05
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;
contract Hello {
    string public helloStr;
    constructor (){
        helloStr = "hello world!";
    }
    function setHello (string memory newValue) public {
        helloStr = newValue ;
    }
    function getHello() public view returns (string memory){
        return helloStr ;
    }

}