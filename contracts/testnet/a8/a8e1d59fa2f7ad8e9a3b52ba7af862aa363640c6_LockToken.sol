/**
 *Submitted for verification at BscScan.com on 2023-03-01
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LockToken {
    string public name = "Lock Token";
    string public symbol = "LTK";
    uint256 public totalSupply = 100000000 * 10**18; // 100 million tokens with 18 decimals
    uint256 public lockedTokens = 90000000 * 10**18; // 90 million locked tokens with 18 decimals
    uint256 public lockedUntil = block.timestamp + 50 * 30 days; // locked until 50 months have passed
    
    mapping(address => uint256) public balanceOf;

    constructor() {
        balanceOf[msg.sender] = totalSupply - lockedTokens;
        balanceOf[address(this)] = lockedTokens;
    }
    
    function transfer(address to, uint256 amount) public returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Not enough balance");
        require(block.timestamp >= lockedUntil || balanceOf[msg.sender] - amount >= totalSupply - lockedTokens, "Tokens are locked");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        return true;
    }
}