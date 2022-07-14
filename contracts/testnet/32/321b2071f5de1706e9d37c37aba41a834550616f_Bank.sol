/**
 *Submitted for verification at BscScan.com on 2022-07-14
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


contract Bank{
    // is can use only owner    
    address owner;
    uint totalBalance;
    mapping(address => uint) balances; // get of address with balance in this address
    mapping(address => uint) lockTime; // set time can withdraw

    // event can show data in terminal when use 
    event Deposit(address from, address to, uint amount);
    event SendTo(address from, address receiver, uint amount);
    event ReceiveEther(address from, address receiver, uint amount);

    constructor(){
        owner = msg.sender;
    }

    receive() external payable{
        emit ReceiveEther(msg.sender, address(this), msg.value);
    }

    // get ether to this function in uint mapping
    function deposit() external payable {
        emit Deposit(msg.sender, address(this), msg.value);
    }

    // get back after deposit
    // only owner
    function withdraw(uint _amount) public payable{
        require(owner == msg.sender, "Unauthorized, only owner");
        payable(msg.sender).transfer(_amount * 1 ether);
    }

    // send to address receive
    // only owner
    function sendToReceive(address payable _receive, uint _amount) external payable{
        require(owner == msg.sender, "Unauthorized, only owner");
        _receive.transfer(_amount * 1 ether);
        emit SendTo(address(this), _receive, totalBalance);
    }

    // get balance when deposit
    function getBalance() public view returns(uint){
        return address(this).balance;
    }
}