/**
 *Submitted for verification at BscScan.com on 2022-12-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Tem{
    uint public a;
    constructor(uint _a){
        a = _a;
    }
    function aa() public view returns(uint){
        return a*3;
    }
}

contract Cs{
    Tem public tem;
    constructor(){
        tem = new Tem(12);
    }
}