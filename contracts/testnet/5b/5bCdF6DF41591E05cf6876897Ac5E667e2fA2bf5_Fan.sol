/**
 *Submitted for verification at BscScan.com on 2022-11-10
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Fan {
    address public minter;
    mapping (address => uint) public balances;

    event Sent(address from, address to, uint amount);
    
    constructor() {
        minter = msg.sender;
    }

    function mint(address receiver, uint amount) public {
        require(msg.sender==minter);
        balances[receiver] +=amount;
    }

    function send(address receiver, uint amount) public {
        //require(amount <= balances [msg.sender], "Insufficient balance");
        balances[msg.sender] -= amount;
        balances[receiver] += amount;
        emit Sent(msg.sender, receiver, amount);
    }
}