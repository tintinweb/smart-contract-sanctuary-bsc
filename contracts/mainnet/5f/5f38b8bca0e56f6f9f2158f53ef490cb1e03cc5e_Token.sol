/**
 *Submitted for verification at BscScan.com on 2022-07-10
*/

// SPDX-License-Identifier: MIT
// Dev: Rambod Taati
pragma solidity ^0.8.2;
contract Token{
    mapping(address => uint) public balances;    
    mapping(address => mapping(address => uint)) public allowance;

    uint public totalSupply = 9630000000000 * 10 ** 18;
    string public name = 'Our Infinily Love';
    string public symbol = 'GML';
    uint public decimals=18;

    event Tranfer(address indexed from,address indexed to, uint value);
    event Approval(address indexed owner,address indexed spender, uint value);

    constructor(){
        balances[msg.sender] = totalSupply;        
    }

    function balanceOf(address owner) public view returns(uint){
        return balances[owner];
    }

    function transfer(address to,uint value) public returns(bool){
        require(balanceOf(msg.sender)>= value, 'balance too low');
        balances[msg.sender]-=value;
        balances[to] +=value;
        emit Tranfer(msg.sender,to,value);
        return true;
    }

    function transferFrom(address from,address to,uint value) public returns(bool){
        require(balanceOf(from) >= value, 'balance too low');
        require(allowance[from][msg.sender]>= value, 'allowance too low');
        balances[from]-=value;
        balances[to]+=value;
        emit Tranfer(from,to,value);
        return true;
    }

    function approve(address spender, uint value) public returns(bool){
        allowance[msg.sender][spender]= value;
        emit Approval(msg.sender,spender,value);
        return true;
    }
}