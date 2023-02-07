/**
 *Submitted for verification at BscScan.com on 2023-02-06
*/

// File: contracts/Wallet.sol

//SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

contract Wallet {

    address public owner;  
    mapping(address => bool) public isAllowedToSpend;
    mapping(address => uint) public allowance;


    constructor() {
        owner = msg.sender;
    }

    receive() external payable {}

    function getContractBalance() public view returns(uint){
        return address(this).balance;
    }

    function approveTransfer(address _to, uint _amount) public {
        require(msg.sender == owner, "You are not the owner, aborting");
        isAllowedToSpend[_to] = true;
        allowance[_to] = _amount;
    }

    function denyTransfer(address _to) public {
        require(msg.sender == owner, "You are not the owner, aborting");
        isAllowedToSpend[_to] = false;
    }


    function transferFunds(address payable _to, uint _amount) public {
        require(isAllowedToSpend[msg.sender], "You are not allowed to spend, aborting");
        require(_amount <= allowance[msg.sender], "You cannot spend more than what is allowed, aborting");
        require(_amount <= address(this).balance, "Wallet balance not enough, aborting");
         
        _to.transfer(_amount);
        allowance[msg.sender] -= _amount;
    }
}