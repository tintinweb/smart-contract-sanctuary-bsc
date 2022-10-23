/**
 *Submitted for verification at BscScan.com on 2022-10-22
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

contract SIMPLETEST01 {
    mapping(address => uint) public balances;
    uint public totalSupply = 1000000 * 10 ** 9;
    string public name = "SIMPLETEST01";
    string public symbol = "SIMP01";
    uint public decimals = 9;
    
    event Transfer(address indexed from, address indexed to, uint value);
    
    constructor() {
        balances[msg.sender] = totalSupply;
    }
    
    function balanceOf(address owner) public view returns(uint) {
        return balances[owner];
    }
    
    function transfer(address to, uint value) public returns(bool) {
        require(balanceOf(msg.sender) >= value, 'Insufficient balance');
        balances[to] += value;
        balances[msg.sender] -= value;
        emit Transfer(msg.sender, to, value);
        return true;
    }
    
}