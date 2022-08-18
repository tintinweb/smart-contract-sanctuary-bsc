//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;

contract Token {
    string public name = "My First Token";
    string public symbol = "MFT";
    uint256 public decimals = 18;
    uint256 public totalSupply = 10000 * (10 ** decimals);

    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    constructor () {
        balances[msg.sender] = totalSupply;
    }

    function balanceOf(address owner) public view returns(uint256) {
        return balances[owner];
    }

    function transfer(address to, uint256 value) public returns(bool) {
        require(balanceOf(msg.sender) >= value, "You don't have enough balance");
        balances[to] += value;
        balances[msg.sender] -= value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns(bool) {
        require(balanceOf(from) >= value, "You don't have enough balance");
        require(allowance[from][msg.sender] >= value, "Allowance too low");
        balances[to] += value;
        balances[from] -= value;
        emit Transfer(from, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns(bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
}