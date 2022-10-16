/**
 *Submitted for verification at BscScan.com on 2022-10-15
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
contract Calculator {
    uint256 public result;

    function add (uint256 x,uint256 y) public {
       result=x+y;
    }
    function subtract (uint256 x, uint256 y) public {
        require (x >=y,"x is less than y");
        result=x-y;
    }
    function division (uint256 x, uint256 y) public {
        result=x*y;
    }
    function modulus (uint256 x, uint256 y) public {
        result=x%y;
    }
}