/**
 *Submitted for verification at BscScan.com on 2022-08-07
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

// Main coin information
contract Token {
    // Addresses mapping
    mapping(address => uint) public balances;
    // Total supply (In Palm case its 21.000.000 PALM tokens)
    uint public totalSupply = 21000000 * 10 ** 18;
    // Tokens Name
    string public name = "Palm Pay";
    // Tokens Symbol
    string public symbol = "PALM";
    // Total Decimals (max 18)
    uint public decimals = 18;
    
    // Transfers
    event Transfer(address indexed from, address indexed to, uint value);
    
    // Event executed only ones uppon deploying the contract
    constructor() {
        // send total tokens to admin
        balances[msg.sender] = totalSupply;
    }
    
    // Check balances
    function balanceOf(address owner) public view returns(uint) {
        return balances[owner];
    }
    
    // Transfering coins function
    function transfer(address to, uint value) public returns(bool) {
        require(balanceOf(msg.sender) >= value, 'Insufficient balance');
        balances[to] += value;
        balances[msg.sender] -= value;
        emit Transfer(msg.sender, to, value);
        return true;
    }
    
}