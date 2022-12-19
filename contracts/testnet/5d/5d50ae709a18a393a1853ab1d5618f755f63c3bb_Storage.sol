/**
 *Submitted for verification at BscScan.com on 2022-12-18
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.17;


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
}