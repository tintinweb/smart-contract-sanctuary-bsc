/**
 *Submitted for verification at BscScan.com on 2023-02-08
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract HelloWeb3 {
    // 类型 可见性 变量名
    string public public_str = "Hello World!";
    uint256 private private_uint = 1;
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier OnlyOwner() {
        // msg 是evm 注入的全局信息
        // msg.sender 是交易发起人
        require(owner == msg.sender, "only owner can do!");
        _;
    }

    event Transfer(address from, address to, uint256 value);

    // 存储 key value
    mapping(address => uint256) public balances;

    function setBalance(address user, uint256 value) public OnlyOwner {
        balances[user] = value;
    }

    function transfer(address to, uint256 value) public {
        require(balances[msg.sender] >= value, "sender balance not enough!");
        balances[msg.sender] -= value;
        balances[to] += value;
        emit Transfer(msg.sender,to,value);
    }
}