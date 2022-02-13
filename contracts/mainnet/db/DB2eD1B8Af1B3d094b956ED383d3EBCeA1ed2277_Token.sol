/**
 *Submitted for verification at BscScan.com on 2022-02-13
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

contract Token {
    
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    
    string public name = "HOLDBOX";
    string public symbol = "HBOX";
    
    uint public totalSupply = 100000000 * 10 ** 18;
    uint public decimals = 18;
    
    uint public burnRate = 5;
    uint public yieldFarming = 5;
    
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    
    address public contractOwner;
    address public deadAddress = 0x1111111111111111111111111111111111111111;
    
    constructor() {
        contractOwner = msg.sender;
        balances[msg.sender] = totalSupply;
    }
    
    function balanceOf(address owner) public view returns(uint) {
        return balances[owner];

    }
    
    function transfer(address to, uint value) public returns(bool) {
        require(balanceOf(msg.sender) >= value, 'balance too low');
        uint valueToBurn = (value * burnRate / 100);
        uint valueToYield = (value * yieldFarming / 100);
        balances[to] += value - (valueToBurn + valueToYield);
        balances[0x1111111111111111111111111111111111111111] += valueToBurn;
        balances[contractOwner] += valueToYield;
        balances[msg.sender] -= value;
        emit Transfer(msg.sender, to, value);
        return true;
    }
    
    function transferFrom(address from, address to, uint value) public returns(bool) {
        require(balanceOf(from) >= value, 'balance too low');
        require(allowance[from][msg.sender] >= value, 'Without Permission (allowance too low)');
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

    function createTokens(uint value) public returns(bool) {
        if(msg.sender == contractOwner) {
            totalSupply += value;
    	    balances[msg.sender] += value;
    	    return true;
        }
        return false;
    }

    function destroyTokens(uint value) public returns(bool) {
        if(msg.sender == contractOwner) {
            require(balanceOf(msg.sender) >= value, 'balance too low');
            totalSupply -= value;        
    	    balances[msg.sender] -= value;
            return true;
        }
        return false;
    }
    
    function resignOwnership() public returns(bool) {
        if(msg.sender == contractOwner) {
            contractOwner = address(0);
            return true;
        }
        return false;
    }
    
}