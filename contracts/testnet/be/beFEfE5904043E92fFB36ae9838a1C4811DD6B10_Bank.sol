/**
 *Submitted for verification at BscScan.com on 2022-02-05
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//pascal case ie. BankAccount
//camel case ie. bankAccount
contract Bank {
    // uint private _balance;
    mapping(address => uint) _balances;
    // address private _account;
    // public , private , internal , external
    // uint[] balances;
    // mapping(address => uint) _balances;
    // mapping(address => mapping(address => bool))
    // string name;

    function deposite() public payable {
        // _balance = _balance + amount;
        _balances[msg.sender] += msg.value;
    }

    function withdraw(uint amount) public {
        require(amount <= _balances[msg.sender], "amount exceed balance");

        _balances[msg.sender] -= amount;

        payable(msg.sender).transfer(amount);
    }
    
    function balance() public view returns(uint) {
        return _balances[msg.sender];
    }

    function totalSupply() public view returns(uint) {
        return address(this).balance;
    }
}