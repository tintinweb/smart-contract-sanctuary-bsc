/**
 *Submitted for verification at BscScan.com on 2022-06-07
*/

// SPDX-License-Identifier: MIT
// File: trainContract.sol

pragma solidity ^0.8.2;

contract TokenUK {
    
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;

    uint public totalSupply = 100 * 10;
    string public name = "PhucCoin";
    string public symbol = "PhucCoin";
    uint public decimal = 18;

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    constructor() {
        balances[msg.sender] = totalSupply;
    }

    function balanceOf(address owner) public view returns(uint) {
        return balances[owner];
    }

    function transfer(address to, uint value) public returns(bool){
        require(balanceOf(msg.sender) >= value, 'Insufficient funds');
        balances[to] += value;
        balances[msg.sender] -= value;

        emit Transfer(msg.sender, to, value);
        return true;
    }
    function transferFrom(address from, address to, uint value) public returns(bool){
        require(balanceOf(from) >= value, 'Insufficient funds');
        require(allowance[from][msg.sender] >= value, 'Insufficient funds');
        balances[to] += value;
        balances[from] -= value;

        emit Transfer(from, to, value);
        return true;
    }
    function approve(address spender, uint value) public returns(bool){
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
}