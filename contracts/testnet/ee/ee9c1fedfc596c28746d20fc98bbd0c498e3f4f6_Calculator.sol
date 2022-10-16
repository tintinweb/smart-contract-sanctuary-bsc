/**
 *Submitted for verification at BscScan.com on 2022-10-15
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

contract Calculator {
       uint256 public result;

       function add(uint256 num1, uint256 num2) public {
              result = num1 + num2;
       }

       function subtract(uint256 x, uint256 y) public {
              require(x >= y, "y is greater than x");
              result = x - y;
       }

       function divide(uint256 x, uint256 y) public {
              result = x / y;
       }

       function multiply(uint256 x, uint256 y) public {
              result = x * y;
       }
}