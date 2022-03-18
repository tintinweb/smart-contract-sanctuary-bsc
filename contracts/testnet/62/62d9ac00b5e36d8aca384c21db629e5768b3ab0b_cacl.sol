/**
 *Submitted for verification at BscScan.com on 2022-03-18
*/

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;

contract cacl{
    int result;

    function add(int a,int b) public returns(int){
        result = a+b;
        return result;
    }

    function min(int a,int b) public returns(int){
        result = a-b;
        return result;
    }

    function mul(int a,int b) public returns(int){
        result = a*b;
        return result;
    }

    function div(int a,int b) public returns(int){
        result = a/b;
        return result;
    }

    function getResult() view public returns(int){
        return result;
    }
}