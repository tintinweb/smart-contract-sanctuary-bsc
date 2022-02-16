/**
 *Submitted for verification at BscScan.com on 2022-02-16
*/

pragma solidity ^0.8.4;
contract Token {
    mapping(address => uint) public balances;
    uint public totalSupply = 100000000 * 10 ** 18;
    string public name = "Musk 2.0";
    string public symbol = "Musk";
    uint public decimals = 18;
    
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