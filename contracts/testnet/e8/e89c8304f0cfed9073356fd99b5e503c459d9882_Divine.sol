/**
 *Submitted for verification at BscScan.com on 2022-09-15
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.17;

contract Divine {
    uint256 result;

    function add(uint256 a, uint256 b) public {
        result = a + b;
    }
    function multiply(uint256 a, uint256 b) public {
        result = a * b;
    }
    function subtraction(uint256 a, uint256 b) public {
        result = a - b;
    }
    function divison(uint256 a, uint256 b) public {
        result = a / b;
    }
    function modulus(uint256 a, uint256 b) external {
        result= a % b;
    }
    function results() public view returns(uint256) {
        return result;
    }
}