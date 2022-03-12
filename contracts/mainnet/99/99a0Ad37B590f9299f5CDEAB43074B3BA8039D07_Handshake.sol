/**
 *Submitted for verification at BscScan.com on 2022-03-12
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.7;

contract Handshake {
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowence;
    
    address public owner;
    uint public decimals = 18;
    uint public totalSupply = 12 * (10**12) * 10 ** 18;
    string public name = "Handshake";
    string public symbol = "SHAKE";
    
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    
    constructor(){
        balances[msg.sender] = totalSupply;
        owner = msg.sender;
    }
    
    function balanceOf(address tokenOwner) public view returns(uint){
        return balances[tokenOwner];
    }
    function getOwner() external view returns (address) {
        return owner;
    }
    
    function transfer(address to, uint value) public returns(bool){
        require(balanceOf(msg.sender) >= value, 'balance too low');

        balances[to] += value;
        balances[msg.sender] -= value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function tranferFrom(address from, address to, uint value) public returns(bool){
        require(balanceOf(from) >= value, 'balance too low');
        require(allowence[from][msg.sender] >= value, 'allowance too low');
        balances[to] += value;
        balances[from] -= value;
        emit Transfer(from, to, value);
        return true;
    }
    
    function approve(address sender, uint value) public returns(bool){
        allowence[msg.sender][sender] = value;
        emit Approval(msg.sender, sender, value);
        return true;
        
    }
    
}