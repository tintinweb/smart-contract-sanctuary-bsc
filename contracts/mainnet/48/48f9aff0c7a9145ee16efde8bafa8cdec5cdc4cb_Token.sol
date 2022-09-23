/**
 *Submitted for verification at BscScan.com on 2022-09-23
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.2; 
contract Token {
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowed;
    uint public totalSupply;
    string public name;
    string public symbol;
    uint public decimals;
    
    address payable public owner;
    
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed _owner, address indexed spender, uint value);     
    
    constructor() { 
        name = "GAMEZLAND";
        symbol = "GAME";
        decimals = 18;
        totalSupply = (10 ** 12) * 10 ** decimals; 
        owner = payable(msg.sender);
        balances[owner] = totalSupply;  
        emit Transfer(address(0), msg.sender, totalSupply);
    }
    
    function balanceOf(address _owner) public view returns(uint) {
        return balances[_owner];
    }
    
    function transfer(address to, uint value) public returns(bool) {
        require(balances[msg.sender] >= value, 'balance too low');
        balances[to] += value;
        balances[msg.sender] -= value;
        emit Transfer(msg.sender, to, value);
        return true;
    }
    
    function transferFrom(address from, address to, uint value) public returns(bool) {
        require(balances[from] >= value, 'balance too low');
        require(allowed[from][msg.sender] >= value, 'allowance too low');
        balances[to] += value;
        balances[from] -= value;
        allowed[from][msg.sender] -=value;
        emit Transfer(from, to, value);
        return true;   
    }
    
    function approve(address spender, uint value) public returns (bool) {
        allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;   
    }
    
    function allowance(address _owner, address spender) public view returns (uint) {
        return allowed[_owner][spender];
    }
    

    function burn(uint amount) public {
        require(amount <= balances[msg.sender]);

        totalSupply -= amount;
        balances[msg.sender] -= amount;
        
        emit Transfer(msg.sender, address(0), amount);
    }


}