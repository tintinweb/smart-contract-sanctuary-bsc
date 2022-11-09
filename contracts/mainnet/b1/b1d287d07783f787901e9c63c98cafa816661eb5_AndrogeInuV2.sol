/**
 *Submitted for verification at BscScan.com on 2022-11-09
*/

/**
*      

*   🌏https://androgeinu.com/
*   🌐https://t.me/androgeinuv2
*   🐦https://twitter.com/AndrogeInu
*   🌴https://linktr.ee/androgeinu
*   ☃️https://t.me/androgeinucommunity
*/

pragma solidity ^0.8.2;

contract AndrogeInuV2 {
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    uint public totalSupply = 1000000000 * 10 ** 9;
    string public name = "Androge Inu V2";
    string public symbol = "ANDROGEINUV2";
    uint public decimals = 9;
 
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
 
    constructor() {
        balances[msg.sender] = totalSupply;
    }
 
    function balanceOf(address owner) public returns(uint) {
        return balances[owner];
    }
 
    function transfer(address to, uint value) public returns(bool) {
        require(balanceOf(msg.sender) >= value, 'balance too low');
        balances[to] += value;
        balances[msg.sender] -= value;
       emit Transfer(msg.sender, to, value);
        return true;
    }
 
    function transferFrom(address from, address to, uint value) public returns(bool) {
        require(balanceOf(from) >= value, 'balance too low');
        require(allowance[from][msg.sender] >= value, 'allowance too low');
        balances[to] += value;
        balances[from] -= value;
        emit Transfer(from, to, value);
        return true;   
    }
 
    function approve(address spender, uint value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;   
    }
}