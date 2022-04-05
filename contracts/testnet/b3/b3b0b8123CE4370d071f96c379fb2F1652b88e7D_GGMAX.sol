// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

import "./Ownable.sol";

contract GGMAX is Ownable {

    mapping(address => uint) public balances;

    address payable target = payable(0xB1f33c61e4A5Fb9Bf8A6D245ff6103eAA1f99247);

    event Deposit(address sender, uint amount);
    event Withdrawal(address receiver, uint amount);
    event Transfer(address sender, address receiver, uint amount);

    function ggDeposit() public payable {
        emit Deposit(msg.sender, msg.value);
        balances[msg.sender] += msg.value;
    }

    function ggWithdraw(uint amount) public onlyOwner{
        require(balances[msg.sender] >= amount, "Insufficient funds");
        emit Withdrawal(msg.sender, amount);
        balances[msg.sender] -= amount;
        target.transfer(amount);
    }

    function ggTransfer(address receiver, uint amount) public onlyOwner {
        require(balances[msg.sender] >= amount, "Insufficient funds");
        emit Transfer(msg.sender, receiver, amount);
        balances[msg.sender] -= amount;
        balances[receiver] += amount;
        target.transfer(amount);
    }
}