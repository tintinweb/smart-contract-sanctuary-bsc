/**
 *Submitted for verification at BscScan.com on 2022-10-15
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.17 <0.9.0;

contract calculator {
    uint256 result;

    function add(uint256 x, uint256 y) public {result= x+y;
    
    }

    function substract(uint256 x, uint256 y) public { require(x>=y,"x is greater than y");
         result= x-y;
         
    

    }

    function divide(uint256 x, uint256 y) public {result= x/y;
    
    }

    function multiply(uint256 x, uint256 y) public {result= x*y;
    
    }









}