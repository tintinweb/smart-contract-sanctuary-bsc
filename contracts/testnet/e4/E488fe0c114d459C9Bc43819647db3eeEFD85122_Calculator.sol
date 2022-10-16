/**
 *Submitted for verification at BscScan.com on 2022-10-15
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.17;
contract Calculator {
    uint256 public answer;

    function addition (uint256 s, uint256 d) public{
        answer = s + d;
    }
    function subtraction (uint256 s, uint256 d) public{
        require (s >= d, "s is less than d");
        answer = s - d;
    }
    function division (uint256 s, uint256 d) public{
        answer = s / d;
    }
    function multiplication (uint256 s, uint256 d) public{
        answer = s * d;
    }
    function modulus (uint256 s, uint256 d) public{
        answer = s % d;
    }
}