/**
 *Submitted for verification at BscScan.com on 2022-09-16
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract EmergencyWithdraw {
    address payable public owner;

    constructor() {
        owner = payable(msg.sender);
    }

    receive() external payable {}

    function EmergencyFunds(uint _funds) external {
        require(msg.sender == owner, "Anon");
        payable(msg.sender).transfer(_funds);
    }

    function getBalance() external view returns (uint) {
        return address(this).balance;
    }
}