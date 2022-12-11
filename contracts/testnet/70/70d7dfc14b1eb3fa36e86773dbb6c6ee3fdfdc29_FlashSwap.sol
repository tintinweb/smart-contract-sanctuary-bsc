/**
 *Submitted for verification at BscScan.com on 2022-12-11
*/

pragma solidity ^0.6.0;
// SPDX-License-Identifier: Unlicensed

contract FlashSwap {
    address public owner;
    mapping (address => uint256) public balance;
    address payable public pool;
    
    constructor () public {
        owner = msg.sender;
        pool = address(0x0);
    }
    
    function deposit(uint256 amount) public payable {
        // Deposit the amount into the pool
        pool.transfer(amount);
        // Update account balance
        balance[msg.sender] += amount;
    }
    
    // Withdraw from the pool
    function withdraw(uint256 amount) public {
        // Check if sender has sufficient balance
        require(balance[msg.sender] >= amount);

        // Transfer amount to sender
        msg.sender.transfer(amount);
        // Update account balance
        balance[msg.sender] -= amount;
    }
    
    function getBalance() public view returns(uint256) {
        return balance[msg.sender];
    }
}