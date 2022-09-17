/**
 *Submitted for verification at BscScan.com on 2022-09-16
*/

// SPDX-License-Identifier: mit

pragma solidity 0.8.17;
contract Samuel {


  
  uint256 result;

  function add (uint256 a, uint256 b) public {
    result = a + b;
  }

  function subtract(uint256 a, uint256 b) public {
    result = a - b;
  }

  function multiply(uint256 a, uint256 b) public {
    result = a * b;
  }

  function divide(uint256 a, uint256 b) external {
    result = a / b;
  }

  
  function modulusByNumber(uint256 a, uint256 b) external {
    result = a % b;
  }

}