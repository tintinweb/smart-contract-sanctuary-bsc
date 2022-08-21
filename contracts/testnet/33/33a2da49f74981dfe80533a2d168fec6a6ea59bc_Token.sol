/**
 *Submitted for verification at BscScan.com on 2022-08-20
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Token {
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    string public name = "My Turn";
    string public symbol = "MTN";
    uint public decimals = 6;
    uint public totalSupply = 10000000 * 10 ** 6;

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    constructor () {
    balances[msg.sender] = 10000000 ;
    }

    function balancesof(address owner) public view returns (uint) {
        return balances[owner];
    }
    
    function transfer(address to, uint value) public returns(bool) {
        require(allowance[msg.sender][to] >= value, 'allowance too low');
        balances[to] += value;
        balances[msg.sender] -= value;

    emit Transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint value) public returns(bool) {
        require(allowance[from][msg.sender] >= value, 'allowance too low');
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