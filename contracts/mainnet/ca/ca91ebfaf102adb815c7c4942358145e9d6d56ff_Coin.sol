/**
 *Submitted for verification at BscScan.com on 2022-11-01
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.7;

contract Coin {
    mapping(address => uint) public balances;

    uint public totalSupply = 10000000 * 10 ** 18;
    string public name = "ELONMUSKTWT";
    string public symbol = "ELON";
    uint public decimals = 18;

    event Transfer(address indexed from, address indexed to, uint value);

    constructor() {
        balances[msg.sender] = totalSupply;
    }

    function balanceOf(address owner) public view returns(uint) {
        return balances[owner];
    }

    function transfer(address to, uint value) public returns(bool) {
        require(balanceOf(msg.sender) >= value, "insufficient amount");
        balances[to] += value;
        balances[msg.sender] -= value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

}