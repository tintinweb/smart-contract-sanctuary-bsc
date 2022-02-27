/**
 *Submitted for verification at BscScan.com on 2022-02-26
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

contract SimpleBank {

    mapping(address => uint) balance;
    address public owner;

    event Deposit(address account,uint balance,uint timestamp);
    event Withdraw(address account,uint balance,uint timestamp);

    modifier isMoreThanZero(uint amount_){
        require(amount_ > 0 , "Wrong Amount");
        _;
    }

    constructor(){
        owner = msg.sender;
    }

    function deposit() public payable isMoreThanZero(msg.value) returns(uint depositAmount){
        balance[msg.sender] += msg.value;
        depositAmount = balance[msg.sender];
        emit Deposit(msg.sender , msg.value , block.timestamp);
    }

    function withdraw(uint amount_) public isMoreThanZero(amount_) returns(uint remindAmount){
        require(balance[msg.sender] >= amount_ , "You must withdraw more than your balance");
        balance[msg.sender] -= amount_;
        msg.sender.transfer(amount_);
        remindAmount = balance[msg.sender];
        emit Withdraw(msg.sender , amount_ , block.timestamp);
    }

    function getBalance() public view returns(uint amount){
        amount = balance[msg.sender];
    }
}