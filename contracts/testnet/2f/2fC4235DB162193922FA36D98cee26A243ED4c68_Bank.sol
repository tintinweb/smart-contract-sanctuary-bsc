/**
 *Submitted for verification at BscScan.com on 2022-02-05
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Bank {
    mapping(address => uint) _balances;

    // msg.sender is the owner who call this method
    // payable is the keyword that make your method can access owner wallet
    function deposit() public payable {
        _balances[msg.sender] += msg.value;
    }

    function withdraw(uint amount) public {
        // this is the guard pattern
        // just like if (amount < _balance) return
        // first arg is a condition
        // second arg is message that you want to tell user
        require(amount <= _balances[msg.sender], "amount exceed balance");
        _balances[msg.sender] -= amount;

        // this line of code will transfer money from smart contract to owner
        payable(msg.sender).transfer(amount);
    }

    // returns is tuple type
    // uint inside returns is return type
    // view is the keyword that make the method is view method (user does not spend gas fee for use this method)
    function balance() public view returns(uint) {
        return _balances[msg.sender];
    }

    function totalSupplies() public view returns(uint){
        return address(this).balance;
    }
}