/**
 *Submitted for verification at BscScan.com on 2022-10-15
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.17;

contract calculator {

    uint256 public result;
    
   function addition (uint256 x,uint256 y) public{
       result = x + y;
   }


    function subtract(uint256 x,uint256 y) public{
        result = x - y;
    }
     
    function multiply (uint256 x,uint256 y ) public{
        result = x * y;
    }

    function divide  (uint256 x,uint256 y) public {
        result = x / y;

    }
    function modulus (uint256 x,uint256 y) public{
        result = x % y;
    }  
    
}