/**
 *Submitted for verification at BscScan.com on 2022-10-21
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract calculator {

   uint256 public result;

     function add (uint256 x, uint256 y)
     public{
         result = x + y;
     } 

    function subtract (uint256 x, uint256 y) public{
        require (x > y, "second number should be less than the first number");
        result = x - y;
    }
    function multiplication (uint256 x, uint256 y) public{
         result = x * y;
    }

    function division (uint256 x, uint256 y) public{
        require (y > 0);
        result = x / y;
    }

}