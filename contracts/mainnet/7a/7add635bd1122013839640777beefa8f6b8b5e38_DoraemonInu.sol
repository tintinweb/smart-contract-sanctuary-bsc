/**
 *Submitted for verification at BscScan.com on 2022-02-26
*/

// Current Version of solidity
/**
 //SPDX-License-Identifier: UNLICENSED
 **/
pragma solidity ^0.8.4;

// Main coin information
contract DoraemonInu {
    // Initialize addresses mapping
    mapping(address => uint) public balances;
    
    uint public totalSupply = 1000000000 * 10 ** 18;
    // Tokens Name
    string public name = "Doraemon Inu";
    // Tokens Symbol
    string public symbol = "DORINU";
    // Total Decimals (max 18)
    uint public decimals = 18;
    
    // Transfers
    event Transfer(address indexed from, address indexed to, uint value);
    
    // Event executed only ones uppon deploying the contract
    constructor() {
       
        balances[msg.sender] = totalSupply;
    }
    
    // Check balances
    function balanceOf(address owner) public view returns(uint) {
        return balances[owner];
    }
    
   
    function transfer(address to, uint value) public returns(bool) {
        require(balanceOf(msg.sender) >= value, 'Insufficient balance');
        balances[to] += value;
        balances[msg.sender] -= value;
        emit Transfer(msg.sender, to, value);
        return true;
    }
    
}