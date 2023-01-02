/**
 *Submitted for verification at BscScan.com on 2023-01-02
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

contract TheWithdraw {
    address payable public owner;
    uint public minDeposit = 10000000000000000000; // 0.1 BNB
    uint public maxDeposit = 500000000000000000000; // 50 BNB
    uint public coolDownPeriod = 10 seconds; // 10 seconds
    uint public weeklyWithdrawalLimit = 7 days; // 1 week
    uint public rewardPercentage = 1000000000000000000; // 10%
    uint public feePercentage = 3; // 3%
    mapping (address => uint) public deposits;
    mapping (address => uint) public lastDepositTime;
    mapping (address => uint) public rewards;

    constructor() public {
        owner = msg.sender;
    }

function deposit(uint _value) public payable {
    require(_value >= minDeposit, "Minimum deposit is 0.1 BNB");
    require(_value <= maxDeposit, "Maximum deposit is 50 BNB");
    require(now - lastDepositTime[msg.sender] >= coolDownPeriod, "Please wait 10 seconds before making another deposit");
    require(humanVerification(), "Failed human verification");

    deposits[msg.sender] += _value;
    lastDepositTime[msg.sender] = now;
    rewards[msg.sender] += _value * rewardPercentage / 100;
}

    function humanVerification() private pure returns (bool) {
        // Add code for human verification test here
        return true;
    }

    function compound() public {
        require(rewards[msg.sender] > 0, "No rewards to compound");
        uint compoundedAmount = rewards[msg.sender];
        deposits[msg.sender] += compoundedAmount;
        rewards[msg.sender] = 0;
    }

    function withdraw() public {
        require(now - lastDepositTime[msg.sender] >= weeklyWithdrawalLimit, "You can only withdraw once a week");
        require(rewards[msg.sender] > 0, "No rewards to withdraw");
        msg.sender.transfer(rewards[msg.sender]);
        rewards[msg.sender] = 0;
    }

    receive() external payable {
        owner.transfer(feePercentage / 100 * msg.value);
    }
}