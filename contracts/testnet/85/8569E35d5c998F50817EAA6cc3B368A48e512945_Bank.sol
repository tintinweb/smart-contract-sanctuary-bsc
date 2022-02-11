/**
 *Submitted for verification at BscScan.com on 2022-02-05
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Bank {
    // uint x;
    // string y;
    // address public account;
    // address private account;
    // address internal account;
    // uint balance
    // uint[] balances
    // address _account;
    // mapping(address => uint) _balances;
    // mapping(address => mapping(address => bool))

    // uint private _balance;
    mapping(address => uint) _balances;

    function deposit() public payable {
        // _balance = _balances + amount;
        _balances[msg.sender] += msg.value;
    }

    function withdraw(uint amount) public {
        require(amount <= _balances[msg.sender], "Amount exceed balance");
        // _balance = _balances - amount;
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