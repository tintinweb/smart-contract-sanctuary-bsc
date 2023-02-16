/**
 *Submitted for verification at BscScan.com on 2023-02-16
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract TestERC20 {
    string public name = "RRR";
    string public symbol = "R";
    uint256 public decimal = 5;
    uint256 public totalSupport;

    mapping(address => uint256) public balancesOf;

    constructor(uint256 totalAmount) {
        balancesOf[msg.sender] = totalAmount;
        totalSupport = totalAmount;
    }

    function transfer(address to, uint256 amount)
        public
        returns (bool success)
    {
        balancesOf[msg.sender] -= amount;
        balancesOf[to] += amount;
        return true;
    }
}