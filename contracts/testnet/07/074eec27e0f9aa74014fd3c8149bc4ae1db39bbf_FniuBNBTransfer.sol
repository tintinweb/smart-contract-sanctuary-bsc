/**
 *Submitted for verification at BscScan.com on 2022-05-27
*/

// SPDX-License-Identifier: MIT
 pragma solidity ^0.8.14;
 
 contract FniuBNBTransfer {
     address public owner;
 
     constructor() {
         owner = msg.sender;
     }
 
     modifier onlyOwner () {
       require(msg.sender == owner, "This can only be called by the contract owner!");
       _;
     }
 
     function deposit() payable public {
     }
 
     function depositAmount(uint256 amount) payable public {
         require(msg.value == amount);
     }
 
     function withdraw() payable onlyOwner public {
         payable(msg.sender).transfer(address(this).balance);
     }
 
     function withdrawAmount(uint256 amount) onlyOwner payable public {
         require(msg.value == amount);
         require(amount <= getBalance());
         payable(msg.sender).transfer(amount); //this not work
         //msg.sender.transfer(getBalance()); // this ok
     }
 
     function getBalance() public view returns (uint256) {
         return address(this).balance;
     }
}