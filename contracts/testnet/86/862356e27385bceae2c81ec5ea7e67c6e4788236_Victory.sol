/**
 *Submitted for verification at BscScan.com on 2022-09-22
*/

// SPDX-License-Identifier: Unlicensed 

pragma solidity 0.8.17;
contract Victory {
    uint256 public result;
      function add (uint256 a, uint256 b) public {
      result = a + b;
      }
      function sub (uint256 a, uint256 b) public {
      result = a - b;
      }
      function mul (uint256 a, uint256 b) public {
      result = a * b;
      }
      function div (uint256 a, uint256 b) public {
      result = a / b;
      }
      function mod (uint256 a, uint256 b) public {
      result = a % b;
      }
}