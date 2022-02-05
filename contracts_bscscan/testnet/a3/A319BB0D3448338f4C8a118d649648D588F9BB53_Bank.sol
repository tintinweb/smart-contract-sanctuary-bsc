/**
 *Submitted for verification at BscScan.com on 2022-02-05
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Bank {
    address  account;

    uint x; //when value change that must away paid gas
    string y;  // Gas to expensive more int. Pls Beware
    //uint private _balances; 
    mapping(address => uint) _balances; //Gas to chep than int oy array

    // function deposit(uint amount) public {
    //     _balances[msg.sender] +=  amount;
    // }

    function deposit() public payable {
        _balances[msg.sender] +=  msg.value;
    }

    // function withdraw(uint amount) public {
    //     require(amount <= _balances[msg.sender], "amount exceed balance");
    //     _balances[msg.sender] -= amount;
    // }

    function withdraw(uint amount) public {
        require(amount <= _balances[msg.sender], "amount exceed balance");
        _balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
    }   


    function balance() public view returns(uint){
        return _balances[msg.sender];
    }

    function totalSuppply() public view returns(uint){
        return  address(this).balance;
    }
}

contract MyBank is Bank{

}