/**
 *Submitted for verification at BscScan.com on 2022-12-30
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

contract SmartContract {
    address public owner;
    mapping(address => uint256) public balances;
    uint256 public totalDeposits;
    uint256 public totalWithdrawals;
    uint256 public totalFees;
    uint256 public lockPeriod = 30 days;
    uint256 public interestRate = 75;

    constructor() {
        owner = msg.sender;
    }

    function deposit(uint256 _amount) public payable {
        require(_amount > 0, "Cannot deposit 0 or negative amount.");
        require(block.timestamp > lockPeriod, "Initial deposit is locked for 30 days.");
        balances[msg.sender] += _amount;
        totalDeposits += _amount;
        totalFees += _amount * 2 / 100; // 2% fee
    }

    function withdraw(uint256 _amount) public {
        require(_amount > 0, "Cannot withdraw 0 or negative amount.");
        require(balances[msg.sender] >= _amount, "Insufficient balance.");
        balances[msg.sender] -= _amount;
        totalWithdrawals += _amount;
        totalFees += _amount * 1 / 100; // 1% fee
        address payable recipient = payable(msg.sender);
        recipient.transfer(_amount);
    }

    function calculateInterest() public view returns (uint256) {
        return ((balances[msg.sender] * 1) * (interestRate)) / 100 * 1 days;
    }

    function ownerWithdraw() public {
        require(msg.sender == owner, "Only contract owner can perform this action.");
        address payable recipient = payable(owner);
        recipient.transfer(totalDeposits);
        totalDeposits = 0;
    }

    function getTotalDeposits() public view returns (uint256) {
        return totalDeposits;
    }

    function getTotalWithdrawals() public view returns (uint256) {
        return totalWithdrawals;
    }

    function getTotalFees() public view returns (uint256) {
        return totalFees;
    }
}