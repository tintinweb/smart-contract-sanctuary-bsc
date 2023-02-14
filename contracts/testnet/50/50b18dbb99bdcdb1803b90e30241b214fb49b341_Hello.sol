/**
 *Submitted for verification at BscScan.com on 2023-02-13
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;


contract Hello{
    
    string public helloStr = "Initial Value";

    constructor() {

        helloStr = "Hello World!";

    }

    function setHello(string memory newValue) public  {
        helloStr = newValue;
         
    }
     //call by value
     function getHello() public view returns(string memory){
         return helloStr;

     }

}