/**
 *Submitted for verification at BscScan.com on 2022-06-22
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Jowirx {

    address owner;
    uint bal;

    constructor() {
        owner = msg.sender;
    }

    receive() external payable {}

    function getBalance() view public returns(uint) {
        return bal;
    }

    function deposit() payable public {
        bal += msg.value;
    }

    //function to get the useraddress
    function getOwner() public view returns (address) {    
        return owner;
    }
    
    //Function to return current balance of user
    function getUserBalance() public view returns(uint256){
        return owner.balance;
    }

    function withdraw(uint withdrawAmount) public {
        require(msg.sender == owner, "Only owner can withdraw!");
        payable(msg.sender).transfer(withdrawAmount);
    }
}