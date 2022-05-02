/**
 *Submitted for verification at BscScan.com on 2022-05-02
*/

//SPDX-Licence-Identifier: MIT

pragma solidity ^0.8.0;

contract Token {

    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    uint public totalSupply = 1000 * 10 ** 18;
    uint public decimals = 18;
    string public name = "tokentest1";
    string public symbol = "TT1";

    constructor() {
        balances[msg.sender] = totalSupply;
    }

    function balancesOf(address owner) public view returns(uint) {
        return balances[owner];
    }

    function transfer(address to, uint value) public returns(bool) {
        require(balancesOf(msg.sender) >= value, 'balance too low');
        balances[to] += value;
        balances[msg.sender] -value;
        emit Transfer(msg.sender, to, value);
        return true;

    }

    function transferFrom(address from, address to, uint value) public returns(bool) {
        require(balancesOf(from) >= value, 'balance too low');
        require(allowance[msg.sender][from] >= value, 'allowance too low');
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