/**
 *Submitted for verification at BscScan.com on 2022-07-26
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.15;

contract EtherWallet {
    address payable public owner;
     
    constructor() {
        owner = payable(msg.sender);
    }

    receive() external payable {}

    function withdraw(uint _amount)  external
    {
        require(msg.sender == owner, "Only the owner can call this function");
        payable (msg.sender).transfer(_amount);
        
    }

    function getBalance() external view returns(uint){
        return address(this).balance;
    }





}