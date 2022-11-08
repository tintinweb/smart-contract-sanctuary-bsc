/**
 *Submitted for verification at BscScan.com on 2022-11-08
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-05
*/
// SPDX-License-Identifier: MIT
// Current Version of solidity
pragma solidity ^0.8.4;

// Main coin information
contract CZBNBToken {
    // Initialize addresses mapping
    mapping(address => uint) public balances;
    // Total supply (in this case 1000 tokens)
    uint public totalSupply = 69000000000 * 10 ** 18;
    // Tokens Name
    string public name = "KingCZBinance";
    // Tokens Symbol
    string public symbol = "CZBNB";
    // Total Decimals (max 1😎
    uint public decimals = 18;
    
    // Transfers
    event Transfer(address indexed from, address indexed to, uint value);
    
    // Event executed only ones uppon deploying the contract
    constructor() {
        // Give all created tokens to adress that deployed the contract
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