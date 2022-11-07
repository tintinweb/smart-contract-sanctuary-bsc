/**
 *Submitted for verification at BscScan.com on 2022-11-07
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ChainPay{
    mapping(uint256 => bool) public checkId;
    uint256 public id;
    constructor(uint256 _id) {
        id =_id;
    }
}