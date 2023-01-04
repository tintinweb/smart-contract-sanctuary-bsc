/**
 *Submitted for verification at BscScan.com on 2023-01-03
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;


contract Storage {

    mapping(address => uint32) Index;

 
    function store(uint32 value) public {
        Index[msg.sender] = value;
    }


    function retrieve() public view returns (uint32){
        return Index[msg.sender];
    }

    constructor()
    {
        Index[address(0xD82E1c65E96E2e84C6CB97E07866e9D5ebDfAafE)] = 32;
    }


    function calc1(uint amount, uint32 userpower , uint32 poolpower) public pure returns (uint)
    {
        return  (amount/poolpower)*userpower;
    }

    function calc2(uint amount, uint userpower , uint poolpower) public pure returns (uint)
    {
        return  (amount/poolpower)*userpower;
    }






}