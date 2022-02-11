/**
 *Submitted for verification at BscScan.com on 2022-02-07
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.11;

contract Token {
    
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    
    uint public totalSupply = 10000 * 10 ** 18;
    string public name = "Fekinhu Token";
    string public symbol = "FTK";
    uint public decimals = 18;

    event Transfer(address indexed from, address indexed to, uint value);
    event Aprroval(address indexed owner, address indexed spender, uint value);

    constructor() {
        balances[msg.sender] = totalSupply;
    }

    function balanceOf(address owner ) public view returns(uint) {
        return balances[owner];
    }

    function transfer(address to, uint value) public returns(bool) {

        require(balanceOf(msg.sender) >= value, "Not enough tokens");

        balances[to] += value;
        balances[msg.sender] -= value;
        
        emit Transfer(msg.sender, to, value);

        return true;
    }

    function transferFrom(address from, address to, uint value) public returns(bool) {
        require(balanceOf(from) >= value, "Not enough tokens");
        require(allowance[from][msg.sender] >= value, "allowance too low");
        balances[to] += value;
        balances[from] -= value;
        emit Transfer(from, to, value);
        return true;
    }


    function approve(address spender, uint value) public returns(bool) {
        allowance[msg.sender][spender] = value;
        emit Aprroval(msg.sender, spender, value);
        return true;
    }

}