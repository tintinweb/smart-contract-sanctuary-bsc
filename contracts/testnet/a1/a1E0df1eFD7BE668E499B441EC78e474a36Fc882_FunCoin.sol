/**
 *Submitted for verification at BscScan.com on 2022-06-13
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.2;

contract FunCoin {
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowances;
    uint public totalSupply = 10000 * 10 ** 18;
    string public name      = "Fun Coin";
    string public symbol    = "FCT";

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    constructor() {
        balances[msg.sender] = totalSupply;
    }

    function balanceOf(address owner) public view returns(uint) {
        return balances[owner];
    }

    function transfer(address to, uint value) public returns(bool) {
        require(balanceOf(msg.sender) >= value, "Insufficient Balances");
        balances[to] += value;
        balances[msg.sender] -= value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint value) public returns(bool) {
        require(balanceOf(from) >= value, "Insufficient balances");
        require(allowances[from][msg.sender] >= value, "Insufficient allowance");
        balances[from] -= value;
        balances[to] += value;
        emit Transfer(from, to, value);
        return true;
    }

    function approved(address spender, uint value) public returns(bool) {
        allowances[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
}