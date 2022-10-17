/**
 *Submitted for verification at BscScan.com on 2022-10-16
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
 contract Calculator{
     uint256 public result;

    function add(uint256 x, uint256 y) public{
         result = x + y;
     }

    function sub(uint256 x, uint256 y) public{
        require(x > y, "the second parameter should be lesse than x");
         result = x - y;
     }

    function mul(uint256 x, uint256 y) public{
         result = x * y;
     }

    function div(uint256 x, uint256 y) public{
         require(x > y, "The second parameter should be larger than 0");

         result = x / y;
     }
 }