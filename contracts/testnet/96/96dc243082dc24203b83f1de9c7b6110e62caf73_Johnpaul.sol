/**
 *Submitted for verification at BscScan.com on 2022-09-17
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

contract Johnpaul {

    string message = "Hello, Welcome";

    uint256 result;

    function add(uint256 x, uint256 y) public returns (uint256) {
        return result = x + y;
    }
     function subtract(uint256 x, uint256 y) public returns (uint256) {
        return result = x - y;
    }
     function multiply(uint256 x, uint256 y) public returns (uint256) {
        return result = x * y;
    }
     function divide(uint256 x, uint256 y) external returns (uint256) {
        return result = x / y;
    }
     function mode(uint256 x, uint256 y) external returns (uint256) {
        return result = x % y;
    }
    //  function getResult() public returns (uint256) {
    //     return result;
    // }
}