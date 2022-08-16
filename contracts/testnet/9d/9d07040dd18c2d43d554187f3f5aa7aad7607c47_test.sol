/**
 *Submitted for verification at BscScan.com on 2022-08-15
*/

// SPDX-License-Identifier: UNLIVENSED
pragma solidity ^0.8.0;


contract test {
    uint public num;


    function incNum() public {
        num++;
    }

    function decNum() public {
        num--;
    }

    function getNum() public view  returns(uint) {
        return num;
    }
}