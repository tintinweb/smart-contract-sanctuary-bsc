/**
 *Submitted for verification at BscScan.com on 2022-09-14
*/

// SPDX-License-Identifier: unlicensed
pragma solidity = 0.8.17;

contract Fonkem {
    uint256 public result;
    string public message = "welcome to my world";

function add (uint256 a, uint256 b) public {result = a + b;}

function subtract (uint256 a, uint256 b) public {result = a - b;}

function multiply (uint256 a, uint256 b) public {result = a * b;}

function divide (uint256 a, uint256 b) public {result = a / b;}

function modulo (uint256 a, uint256 b)  public {result = a % b;}

}