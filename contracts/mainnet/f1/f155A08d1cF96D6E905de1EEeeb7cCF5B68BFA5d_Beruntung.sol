/**
 *Submitted for verification at BscScan.com on 2022-05-18
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Beruntung {
    constructor() payable {}

        function getBalance() external view returns (uint) {
        return address(this).balance;
    }

    function attack() external payable {
        // You can simply break the game by sending ether so that
        // the game balance >= 7 ether

        // cast address to payable
        selfdestruct(payable(msg.sender));
    }   
}