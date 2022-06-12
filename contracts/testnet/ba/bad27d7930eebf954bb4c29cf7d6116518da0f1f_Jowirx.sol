/**
 *Submitted for verification at BscScan.com on 2022-06-11
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Jowirx {

    address owner;
    uint public bal;

    constructor(){
        owner = msg.sender;
    }

    receive() external payable {}

    function getBalance() view public returns(uint) {
        return bal;
    }

    function deposit() external payable {
        bal += msg.value;
    }

    function withdraw(uint withdrawAmount) external {
        require(msg.sender == owner, "Only owner can withdraw!");
        payable(msg.sender).transfer(withdrawAmount);
    }
}