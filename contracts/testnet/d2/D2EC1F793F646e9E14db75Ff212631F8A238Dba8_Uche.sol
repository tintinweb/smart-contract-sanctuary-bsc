/**
 *Submitted for verification at BscScan.com on 2022-09-15
*/

//SPDX-License-Identifier: Unlicensed
pragma solidity ^ 0.8.17; 
contract Uche {
    string message = "welcome";
    uint256 public result;

    function add(uint256 a, uint256 b) public returns (uint256) { 
       return result = a + b;
}
    function subtract(uint256 a , uint256 b) public returns (uint256) {
        return result = a - b; }
    function multiply(uint256 a , uint b) public returns (uint256) { 
        return result = a * b; }
    function divion(uint256 a , uint256 b) external returns (uint256) { 
        return result = a / b; }
    function modulus(uint256 a , uint256 b) external returns (uint256) { 
        return result = a % b;
     }
}