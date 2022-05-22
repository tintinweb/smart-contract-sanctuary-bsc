/**
 *Submitted for verification at BscScan.com on 2022-05-22
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

contract TheBoxFinance {
    
    mapping(address => uint) public balances;
    mapping(address => uint) public total_bought;
    mapping(address => uint) public total_sold;
    mapping(address => uint) public whitelist;
    mapping(address => mapping(address => uint)) public allowance;
    string public name = "The Box Finance";
    string public symbol = "TBF";
    uint public decimals = 18;
    uint private supplyPotency = 10 ** decimals;
    uint public totalSupply = 1000000000000 * supplyPotency;
    address public the_owner; 
    bool public allow_sell = false;
    uint public max_sell_percent = 100; //percent, between 0 to 1000    
    
    
    event Transfer(address indexed from, address indexed to, uint amount);
    event Approval(address indexed owner, address indexed spender, uint amount);
    
    constructor() {
        balances[msg.sender] = totalSupply;
    }
    
    function balanceOf(address owner) public view returns(uint) {
        return balances[owner];
    }
    
    function transfer(address to, uint value) public returns(bool) {
        require(balanceOf(msg.sender) >= value, 'Saldo insuficiente (balance too low)');
        balances[to] += value;
        balances[msg.sender] -= value;
        emit Transfer(msg.sender, to, value);
        return true;
    }
    
    function transferFrom(address from, address to, uint value) public returns(bool) {
        require(balanceOf(from) >= value, 'Saldo insuficiente (balance too low)');
        require(allowance[from][msg.sender] >= value, 'Sem permissao (allowance too low)');
        balances[to] += value;
        balances[from] -= value;
        emit Transfer(from, to, value);
        return true;
    }
    
    function approve(address spender, uint value) public returns(bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
    
}