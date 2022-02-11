/**
 *Submitted for verification at BscScan.com on 2022-02-05
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Bank {
    mapping(address => uint) _balance;

    function deposit() public payable {
        _balance[msg.sender] += msg.value; //เช็ค balance ของคน sender มาเท่านั้น
    }

    function withdraw(uint amount) public {
        require(amount <= _balance[msg.sender], "amount exceed balance");

        _balance[msg.sender] -= amount;

        payable(msg.sender).transfer(amount);
    }

    function balance() public view returns(uint){
        return _balance[msg.sender];
    }

    function totalSupply() public view returns(uint) {
        return address(this).balance;
    }
}