/**
 *Submitted for verification at BscScan.com on 2022-07-31
*/

//SPDX-License-Identifier: MIT
 pragma solidity ^0.8.2;


//variables
 contract DOTSOFTWARELTD {
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance; //third party spending on your behalf
    uint public totalSupply = 100000000 * 10 ** 18;
    string public name = "DOT Software";
    string public symbol = "DOTS";
    uint public decimals = 18;

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

//executed once
    constructor() {
        balances[msg.sender] = totalSupply;
    }
    function balanceOf(address owner)public view returns(uint) {
        return balances[owner];

    }
    //function for sufficient balance
    function transfer(address to, uint value) public returns(bool){
        require(balanceOf(msg.sender) >= value, 'balance to low');
        balances[to] += value;
        balances[msg.sender] -= value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint value) public returns(bool) {
        require(balanceOf(from)>= value, 'allowance too low');
        require(allowance[from][msg.sender] >= value, 'allowance too low');
        balances [to] += value;
        balances [from] -= value;
        emit Transfer(from, to, value);
        return true; 
    }

    function approve(address spender, uint value) public returns(bool) {
       allowance[msg.sender][spender] = value; //has the permission to spend x amount on behalf of msg.sender
       emit Approval(msg.sender, spender, value);
        return true;
    }

}