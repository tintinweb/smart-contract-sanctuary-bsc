/**
 *Submitted for verification at BscScan.com on 2022-03-11
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.7;

contract Handshake {
    mapping(address => uint) public balances;
    mapping(address => uint) public lockTimes;
    
    address private owner;
    uint private decimals = 18;
    uint private totalSupply = 12 * (10**12) * 10 ** 18;
    string public name = "Handshake";
    string public symbol = "SHAKE";
    
    event Transfer(address indexed from, address indexed to, uint value);
    
    constructor(){
        balances[msg.sender] = totalSupply;
        owner = msg.sender;
    }
    
    function balanceOf(address tokenOwner) public view returns(uint){
        return balances[tokenOwner];
    }

    function lockTimeOf(address tokenOwner) public view returns(uint){
        return lockTimes[tokenOwner];
    }
    
    function transfer(address to, uint value) public returns(bool){
        if(msg.sender!=owner){
            uint lockTime = lockTimes[msg.sender];
            if(lockTime > 0){
                require(lockTime < block.timestamp, 'tokens in a lock period');
            }
        }
        require(balanceOf(msg.sender) >= value, 'balance too low');
        balances[to] += value;
        balances[msg.sender] -= value;
        emit Transfer(msg.sender, to, value);
        return true;
    }
    function transferLock(address to, uint value, uint duration) public returns(bool){
        require(msg.sender != to, 'cant lock self');        
        require(msg.sender == owner, 'only owner can lock');
        require(owner != to, 'cant lock owner');

        require(balanceOf(msg.sender) >= value, 'balance too low');

        uint lockTime = lockTimes[to];
        if(lockTime > 0){
            require(lockTime >= block.timestamp, 'already unlocked');
        }
        
        balances[to] += value;
        balances[msg.sender] -= value;
        lockTimes[to] = block.timestamp + duration;
        emit Transfer(msg.sender, to, value);
        return true;
    }
    
}