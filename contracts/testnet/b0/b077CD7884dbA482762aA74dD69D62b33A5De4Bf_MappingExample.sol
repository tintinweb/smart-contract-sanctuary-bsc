/**
 *Submitted for verification at BscScan.com on 2022-03-19
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.6;
     
contract MappingExample{
     
    mapping(address=>uint) public x;

    function setBalance (address i, uint y) public returns(uint){
        x[i] = y;
        return y;
    }
}