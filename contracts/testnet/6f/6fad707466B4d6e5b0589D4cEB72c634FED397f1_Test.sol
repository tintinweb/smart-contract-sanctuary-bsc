/**
 *Submitted for verification at BscScan.com on 2023-02-05
*/

// SPDX-License-Identifier: MIT


pragma solidity ^0.7.0;

contract Test {
    mapping (address => uint) public deposits;

    function receive() external payable {
        deposits[msg.sender] += msg.value;
    }

    function withdraw() public {
        uint amount = deposits[msg.sender];
        require(amount > 0, "You have not made any deposits");
        msg.sender.transfer(amount);
        deposits[msg.sender] = 0;
    }
}