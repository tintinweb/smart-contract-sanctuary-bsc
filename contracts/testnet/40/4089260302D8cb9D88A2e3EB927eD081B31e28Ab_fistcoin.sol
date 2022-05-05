/**
 *Submitted for verification at BscScan.com on 2022-05-05
*/

// SPDX-License-Identifier: MIT
// File: fistcoin.sol


pragma solidity ^0.8.2;

contract fistcoin {
    address public minter;
    //Minter : người khởi tạo
    mapping (address => uint) public balances;

    event sent(address from, address to, uint amount);
    // sự kiện from từ đâu, to đến đâu, amount khối lượng chuyển
    constructor (){
        minter = msg.sender;
    }

    function  mint(address receiver, uint amount)public{
        require(msg.sender == minter);
        require(amount < 1e60);
        //Suply : lượng cung cầu (số tổng cộng) thấp hơn 1e60 (1 và 60 số 0 theo sau)

        balances[receiver] += amount;
        //Balance : ví/số dư/tổng tiền

        //balances[receiver] = balances[receiver]+ amount;
    }
     
    function send(address receiver, uint amount) public{
        require (amount <= balances[msg.sender],"khong du tien de chuyen");
        balances[msg.sender] -= amount;
        balances[receiver] += amount; 
        emit sent(msg.sender, receiver, amount);
    }
}