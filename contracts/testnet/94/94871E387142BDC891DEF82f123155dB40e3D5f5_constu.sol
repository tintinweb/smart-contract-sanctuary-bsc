// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;



contract constu {

    uint public num= 10;

    function getBalance() public view returns(uint){

        return address(this).balance;

    }
    
}