/**
 *Submitted for verification at BscScan.com on 2023-01-07
*/

// SPDX-License-Identifier: Unlicensed

//Website: https://cryptounity.org/ 
//Whitepaper: https://cryptounity.org/docs/V4_WHITE_PAPER_ENG.pdf
//Audit: https://www.certik.com/projects/cryptounity
//Team: https://cryptounity.org/our-team/

pragma solidity ^0.8.4;

// Main coin information
contract CryptoUnity {
    // Initialize addresses mapping
    mapping(address => uint) public balances;
    // Total supply 
    uint public totalSupply = 1000000000 * 10 ** 9;
    // Tokens Name
    string public name = "CryptoUnity";
    // Tokens Symbol
    string public symbol = "CUT";
    // Total Decimals 
    uint public decimals = 9;
    
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