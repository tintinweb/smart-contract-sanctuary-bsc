/**
 *Submitted for verification at BscScan.com on 2022-03-10
*/

// SPDX-License-Identifier:MIT
pragma solidity ^0.8.4;


contract TokyoNFTs {

    mapping(address => uint) public balances;

    uint public totalSupply = 15000000 * 10 ** 18;

    string public name = "TokyoNFTs";

    string public symbol = "TOKYO";

    uint public decimals = 18;
    

    event Transfer(address indexed from, address indexed to, uint value);
    

    constructor() {
        balances[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
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