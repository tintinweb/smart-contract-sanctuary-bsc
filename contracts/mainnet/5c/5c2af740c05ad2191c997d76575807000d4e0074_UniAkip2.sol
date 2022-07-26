/**
 *Submitted for verification at BscScan.com on 2022-07-25
*/

// SPDX-License-Identifier: Unlicensed

/**

UNIAKIP

What happens with the tax?

*/

pragma solidity ^0.8.3;

contract UniAkip2{
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    uint public constant decimals = 0;
    uint public constant totalSupply = 1000000;
    uint256 public constant _MAX_TX_SIZE = 200000; // 2 %
    string public constant name = "UNIAKIP 2.0";
    string public constant symbol = "AKIP2";
    
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    
    constructor() {
        balances[msg.sender] = totalSupply;
    }
    
    function balanceOf(address owner) public view returns(uint) {
        return balances[owner];
    }
    
    function transfer(address to, uint value) public returns(bool) {
        require(balanceOf(msg.sender) >= value, 'balance too low');
        require(value <= _MAX_TX_SIZE, "Transfer amount exceeds the maxTxAmount.");
        require(balanceOf(to)+value <= _MAX_TX_SIZE, "Transaction would exceed wallet max");
        balances[to] += value * 9/10; // What happens here? 1/10 is not catered for.
        balances[msg.sender] -= value;
        emit Transfer(msg.sender, to, value);
        return true;
    }
    
    function transferFrom(address from, address to, uint value) public returns(bool) {
        require(balanceOf(from) >= value, 'balance too low');
        require(allowance[from][msg.sender] >= value, 'allowance too low');
        require(balanceOf(to)+value <= _MAX_TX_SIZE, "Transaction would exceed wallet max");
        balances[to] += value;
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