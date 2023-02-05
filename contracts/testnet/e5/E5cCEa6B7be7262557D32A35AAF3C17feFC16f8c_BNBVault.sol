/**
 *Submitted for verification at BscScan.com on 2023-02-05
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract BNBVault {
    mapping(address => uint256) public deposits;
    mapping(address => uint256) public timelocks;

    function deposit(uint256 lockTime) public payable {
        require(msg.value > 0, "Amount must be greater than 0");
        require(lockTime > block.timestamp, "Lock time must be in the future");
        deposits[msg.sender] += msg.value;
        timelocks[msg.sender] = lockTime;
    }

    function release(address payable _beneficiary) public {
        require(timelocks[_beneficiary] <= block.timestamp, "Time lock has not yet expired");
        require(_beneficiary != address(0), "Beneficiary address cannot be 0x0");
        require(deposits[_beneficiary] > 0, "No deposit found for address");
        _beneficiary.transfer(deposits[_beneficiary]);
        deposits[_beneficiary] = 0;
        timelocks[_beneficiary] = 0;
    }
}