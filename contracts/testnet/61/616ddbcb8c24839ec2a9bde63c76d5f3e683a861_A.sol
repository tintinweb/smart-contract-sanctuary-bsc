/**
 *Submitted for verification at BscScan.com on 2022-06-09
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;


contract B {
    uint public i;

    function setI(uint) public view returns  (uint) {
        return i + 3;
    }
}

contract A {
    function callb(address x) view public {
        B b = B(x);
        b.setI(5);
    }
}