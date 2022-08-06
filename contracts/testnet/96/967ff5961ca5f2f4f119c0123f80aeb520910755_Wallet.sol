/**
 *Submitted for verification at BscScan.com on 2022-08-05
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;


contract Wallet {

    address  public owner;

    event Withdraw(uint amount);

    receive() external payable{}

    constructor(){
        owner = msg.sender;
    }

    function withdraw() external {
        require(msg.sender == owner, "Unauthorized");
        payable(msg.sender).transfer(getWalletBalance());
        emit Withdraw(getWalletBalance());
    }

    function getWalletBalance() public view returns (uint){
        return address(this).balance;
    }
}