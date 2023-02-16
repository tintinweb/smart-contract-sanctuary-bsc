/**
 *Submitted for verification at BscScan.com on 2023-02-16
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract ThetherPrint {
mapping(address => uint) public balances;
mapping(address => mapping(address => uint)) public allowance;
uint public totalSupply = 31460000000000 * 10 ** 5;
string public name = "Tether Print";
string public symbol = "USTP";
uint public decimals = 5;
uint public burnPercent = 2;
event Transfer(address indexed from, address indexed to, uint value);
event Approval(address indexed owner, address indexed spender, uint value);
event Burn(address indexed from, uint value);

constructor() {
    balances[msg.sender] = totalSupply;
}

function balanceOf(address owner) public view returns(uint) {
    return balances[owner];
}

function transfer(address to, uint value) public returns(bool) {
    require(balanceOf(msg.sender) >= value, 'balance too low');

    uint burnAmount = value * burnPercent / 100;
    uint transferAmount = value - burnAmount;

    balances[to] += transferAmount;
    balances[msg.sender] -= value;
    totalSupply -= burnAmount;

    emit Transfer(msg.sender, to, transferAmount);
    emit Burn(msg.sender, burnAmount);

    return true;
}

function transferFrom(address from, address to, uint value) public returns(bool) {
    require(balanceOf(from) >= value, 'balance too low');
    require(allowance[from][msg.sender] >= value, 'allowance too low');

    uint burnAmount = value * burnPercent / 100;
    uint transferAmount = value - burnAmount;

    balances[to] += transferAmount;
    balances[from] -= value;
    totalSupply -= burnAmount;

    emit Transfer(from, to, transferAmount);
    emit Burn(from, burnAmount);

    return true;
}

function approve(address spender, uint value) public returns (bool) {
    allowance[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
}
}