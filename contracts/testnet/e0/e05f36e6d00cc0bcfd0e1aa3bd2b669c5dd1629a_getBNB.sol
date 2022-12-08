/**
 *Submitted for verification at BscScan.com on 2022-12-08
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;


contract getBNB {
    address public _sender;
    uint public _amount;

    mapping (address => uint) public sender_amount;

    // constructor() payable {
    //     _sender = msg.sender;
    //     _amount = msg.value;
    // }
    function pay() public payable {
        sender_amount[_sender] += _amount;
    }
    function withdraw() public {
        uint amount = sender_amount[msg.sender];
        // 记住，在发送资金之前将待发金额清零
        // 来防止重入（re-entrancy）攻击
        sender_amount[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }
}