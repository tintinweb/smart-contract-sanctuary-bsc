/**
 *Submitted for verification at BscScan.com on 2022-09-16
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.17;

contract David{
string public welcome = "Hello";
uint256 result;

function add(uint256 a, uint256 b) public returns (uint256) {
    return result = a + b;
}
function sub(uint256 a, uint256 b) public returns (uint256) {
    return result = a - b;
}

function multiply(uint256 a, uint256 b) public returns (uint256) {
    return result = a * b;

}
function division(uint256 a, uint256 b) public returns (uint256) {
    return result = a / b;
}

function mode(uint256 a, uint256 b) public returns (uint256) {
    return result = a % b;
}
function getresult() public view returns (uint256) {
    return result;
}

}