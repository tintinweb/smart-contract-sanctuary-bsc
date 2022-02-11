/**
 *Submitted for verification at BscScan.com on 2022-02-02
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract test {
    int16 public integer = 200;
    
    int [] public arr;

    function sum (int16 arg) public  view returns(int16){
        return integer + arg;
    }

    function addArr(int arg) public{
        arr.push(arg);
    }

}