/**
 *Submitted for verification at BscScan.com on 2022-03-31
*/

/**

As simple as the name says, CODE ZERO.

Clean code. Classic BSC moonshot.

https://codezerobsc.com
https://t.me/CodeZeroBSC


**/


// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.2;

contract CodeZero {
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
   
    uint public totalSupply = 1000000 * 10 ** 18;
    string public name = "Code Zero";
    string public symbol = "CodeZero";
    uint public decimals = 18;
    
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    
    constructor() {
        balances[msg.sender] = totalSupply;
    }
    
    function balanceOf(address owner) public returns(uint) {
        return balances[owner];
    }
    
    function transfer(address to, uint value) public returns(bool) {
        require(balanceOf(msg.sender) >= value, 'balance too low');
        balances[to] += value;
        balances[msg.sender] -= value;
       emit Transfer(msg.sender, to, value);
        return true;
    }
    
    function transferFrom(address from, address to, uint value) public returns(bool) {
        require(balanceOf(from) >= value, 'balance too low');
        require(allowance[from][msg.sender] >= value, 'allowance too low');
        balances[to] += value;
        balances[from] -= value;
        emit Transfer(from, to, value);
        return true;   
    }
    
    function approve(address spender, uint value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;   
    }
}