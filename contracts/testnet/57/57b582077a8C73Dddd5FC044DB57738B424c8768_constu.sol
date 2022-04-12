// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;



contract constu {

    uint public num;
    constructor(uint _num){
        num=_num;
    }
    function getBalance() public view returns(uint){

        return address(this).balance;

    }
    
}