/**
 *Submitted for verification at BscScan.com on 2022-09-04
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

contract Token{
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    
    uint public totalSupply = 1000000000 * 10 ** 18; // the total supply
    string public name = "Planet Coin"; // the name of the token
    string public symbol = "PLNTC"; // the 3 character symbol of our token
    uint public decimals = 18; // fractions of the token that can be transfered

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    constructor() {
        balances[msg.sender] = totalSupply; // the address that sends the transaction 
        
    }

    function balanceOf(address owner) public view returns(uint){
        return balances[owner];
    }

    function transfer(address to, uint value) public returns(bool){
        require(balanceOf(msg.sender) >= value, 'balance not enough');
        balances[to] += value;
        balances[msg.sender] -= value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint value) public returns(bool){
        require(balanceOf(from) >= value, 'balance not enough');
        require(allowance[from][msg.sender] >= value, 'allowance not enough');
        balances[to] += value;
        balances[from] -= value;
        emit Transfer(from, to, value);
        return true;

    }

    function approve(address spender, uint value)public returns(bool){
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
}