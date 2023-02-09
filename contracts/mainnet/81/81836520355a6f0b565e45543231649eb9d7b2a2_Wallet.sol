/**
 *Submitted for verification at BscScan.com on 2023-02-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

contract Wallet {
    // balances[owner]
    mapping(address => uint256) public balances;

    // allowances[owner][spender]
    mapping(address => mapping(address => uint256)) public allowances;

    function approve(address spender, uint256 amount) external  {
        allowances[msg.sender][spender] = amount;
    }

    function transferFrom(address from, address to, uint256 amount) external {
        assert(allowances[from][msg.sender] >= amount);
        allowances[from][msg.sender] -= amount;
        balances[from] -= amount;
        balances[to] += amount;

    }

    function withdraw(uint256 amount) external  {
        payable(msg.sender).transfer(amount);
    }

    receive() external payable {
        balances[msg.sender] += msg.value;
    }
}