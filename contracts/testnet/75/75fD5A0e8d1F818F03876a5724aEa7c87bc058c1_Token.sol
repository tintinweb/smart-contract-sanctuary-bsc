/**
 *Submitted for verification at BscScan.com on 2022-03-13
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

contract Token {
    
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    
    uint public totalSupply = 10000 * 10 ** 18;
    string public name = "CursoCompletoFlexBurn";
    string public symbol = "CCFB";
    uint public decimals = 18;

    uint256 public currentTimerStamp;
    uint256 public timeblock = 60; // Um mes de bloqueio    
    uint public burnRate = 10; //Queima x% dos token transferidos de uma carteira para outra

    
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    address public adressMarketing = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
    address public adressFinanc = 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db;
    address public adressBurn = 0x1111111111111111111111111111111111111111;
    
    
    address public contractOwner;
    
    constructor() {
        contractOwner = msg.sender;
        balances[msg.sender] = totalSupply;
        balances[msg.sender] = totalSupply;
        currentTimerStamp = block.timestamp;
    }

    
    
    function balanceOf(address owner) public view returns(uint) {
        return balances[owner];
    }
    
   
     function transfer(address to, uint value) public returns(bool) {
        require(balanceOf(msg.sender) >= value, 'Saldo insuficiente (balance too low)');
        uint valueToBurn = (value * burnRate / 100);
        balances[to] += value - valueToBurn;
        balances[0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2] += valueToBurn/2;
        balances[0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db] += valueToBurn/2;
        balances[0x1111111111111111111111111111111111111111] += valueToBurn/2;
        balances[msg.sender] -= value;
        emit Transfer(msg.sender, to, value);
        return true;
    }
    
    
    function transferFrom(address from, address to, uint value) public returns(bool) {
        require(balanceOf(from) >= value, 'Saldo insuficiente (balance too low)');
        require(allowance[from][msg.sender] >= value, 'Sem permissao (allowance too low)');
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

    function mint(uint value) public returns(bool) {
        if(msg.sender == contractOwner) {
            totalSupply += value;
    	    balances[msg.sender] += value;
    	    return true;
        }
        return false;
    }

    function burn(uint value) public returns(bool) {
        if(msg.sender == contractOwner) {
            require(balanceOf(msg.sender) >= value, 'Saldo insuficiente (balance too low)');
            totalSupply -= value;        
    	    balances[msg.sender] -= value;
            return true;
        }
        return false;
    }
    modifier isOwner() {
        require(msg.sender == contractOwner);
        _;
    }
    
    function transferOwnership(address newOwner) public isOwner {
        require(newOwner != address(0));
        OwnershipTransferred(contractOwner, newOwner);
        contractOwner = newOwner;
    }   
        
}