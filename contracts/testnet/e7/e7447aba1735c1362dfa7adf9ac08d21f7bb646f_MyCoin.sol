//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;

contract MyCoin{
    address public minter;
    mapping(address => uint) public balances;
    event Transfer(address from, address to, uint amount);
    constructor(){
        minter = msg.sender;
    }
    function mint(address receiver,uint amount) public{
        require(msg.sender == minter);
        balances[receiver] += amount;
    }
    function transfer(address to,uint amount) public{
        require(amount <= balances[msg.sender]);
        balances[msg.sender] -= amount;
        balances[to] += amount;
        emit Transfer(msg.sender,to,amount);
    }
}