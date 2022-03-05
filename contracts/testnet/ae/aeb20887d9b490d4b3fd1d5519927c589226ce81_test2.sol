/**
 *Submitted for verification at BscScan.com on 2022-03-04
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


contract test2{
    uint public a = 0;
    uint public b;
    uint public sum;
    uint public sub;
    function sandS(uint val1, uint val2) public{
        a = val1;
        b = val2;
    }

    function sum1( uint val1, uint val2) public returns(uint s, uint sb){
        sum = val1 + val2;
        sub = val1 - val2;
        s = sum;
        sb = sub;
    }
}