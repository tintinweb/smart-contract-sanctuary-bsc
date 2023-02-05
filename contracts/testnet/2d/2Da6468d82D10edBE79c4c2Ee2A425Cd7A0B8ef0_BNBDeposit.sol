/**
 *Submitted for verification at BscScan.com on 2023-02-05
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract BNBDeposit {
    mapping(address => uint256) public deposits;

    function deposit() public payable {
        require(msg.value > 0, "Amount must be greater than 0");
        deposits[msg.sender] += msg.value;
    }
}