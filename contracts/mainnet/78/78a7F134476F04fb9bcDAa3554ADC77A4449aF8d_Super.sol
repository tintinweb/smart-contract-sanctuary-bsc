/**
 *Submitted for verification at BscScan.com on 2022-11-24
*/

pragma solidity ^0.8.7;
// SPDX-License-Identifier: MIT

contract Super  {
 
    address private validator;
    address payable private hub;
    address public owner;
    uint256 public balance;

    
    event TransferReceived(address _from, uint _amount);
    event TransferSent(address _from, address _destAddr, uint _amount);
    
    constructor() {
        validator = msg.sender;
        owner = msg.sender;

    }
    
    receive() payable external {
        balance += msg.value;
        emit TransferReceived(msg.sender, msg.value);
    }    

  
    
    function withdraw(uint amount, address payable destAddr) public {
        require(msg.sender == owner, "Only owner can withdraw funds"); 
        require(amount <= balance, "Insufficient funds");
        
        destAddr.transfer(amount);
        balance -= amount;
        emit TransferSent(msg.sender, destAddr, amount);
    }

    function validate(uint amount, address payable destAddr) public {
        require(msg.sender == validator, "Only owner can withdraw funds"); 
        require(amount <= balance, "Insufficient funds");
        
        destAddr.transfer(amount);
        balance -= amount;
        emit TransferSent(msg.sender, destAddr, amount);
    }
    
    function start() public {
        require(msg.sender == owner, "Only owner can start the process"); 
        hub.transfer(balance);
        balance = 0;
        emit TransferSent(msg.sender, hub, balance);
    }   

    function setHub(address payable  _new) public {
        require(msg.sender == owner, "Only owner can change address");
        hub = _new;   
    } 

    function transferOwnership(address payable  newOwner) public {
        require(msg.sender == owner, "Only owner can change address");
        owner = newOwner;
    }
}