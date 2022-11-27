/**
 *Submitted for verification at BscScan.com on 2022-11-26
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract lightdev{
    mapping(address => uint) public balances;
    
    uint public totalSupply = 4000000700000 * 10 ** 18;
    string public name = "light Dev";
    string public symbol = "LGD";
    uint public decimals = 18;

    event Transfer(address indexed from, address indexed to, uint value);

    constructor(){
        balances[msg.sender] = totalSupply;
    }

    function balancesOf(address owner) public view returns(uint){
        return balances[owner];
    }

    function transfer(address to, uint value ) public returns(bool){
        require(balancesOf(msg.sender) >= value, 'Quantidade de light Dev insuficiente');
        balances[to] += value;
        balances[msg.sender] -= value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

}