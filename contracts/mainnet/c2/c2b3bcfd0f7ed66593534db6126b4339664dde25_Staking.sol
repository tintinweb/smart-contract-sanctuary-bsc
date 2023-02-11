/**
 *Submitted for verification at BscScan.com on 2023-02-11
*/

// SPDX-License-Identifier: MIT
// DEV: SUB_ZERO
// TELEGRAM: https://t.me/Lucky_Portal

pragma solidity ^0.8.0;

contract Staking {
    uint256 public totalStaked;
    uint256 public poolBalance;
    mapping(address => uint256) public stakes;
    mapping(address => bool) public addressStaked;
    mapping(address => StakeInfo) public stakeInfos;
    uint256 public interestRate;
    address public owner;

    struct StakeInfo {
        uint256 amount;
        uint256 endTS;
        uint256 claimed;
    }

    // Constructor to set the interest rate and the owner
    constructor(uint256 _interestRate) {
        interestRate = _interestRate;
        owner = msg.sender;
    }

    // Function to deposit tokens into the staking contract
function deposit(uint256 _amount) public payable {
    require(msg.value == _amount, "Invalid deposit amount");
    require(_amount > 0, "Deposit amount must be greater than 0");
    require(msg.sender == address(0xE278911C4275d89C8F1824f2c3300AaE56668aB5), "Wrong token type");
    totalStaked += _amount;
    stakes[msg.sender] += _amount;
    addressStaked[msg.sender] = true;
    stakeInfos[msg.sender] = StakeInfo(_amount, block.timestamp + 30 days, 0);
}

    // Function to add ether to the pool balance
    function addToPool() external payable {
        require(msg.value > 0, "Value must be greater than 0");
        poolBalance += msg.value;
    }

    // Function to allow holders to claim their rewards
    function claimReward() external returns (bool){
        require(addressStaked[msg.sender] == true, "You are not participated");
        require(stakeInfos[msg.sender].endTS < block.timestamp, "Stake time is not over yet");
        require(stakeInfos[msg.sender].claimed == 0, "Already claimed");

        uint256 stakeAmount = stakeInfos[msg.sender].amount;
        uint256 totalTokens = stakeAmount + (stakeAmount * interestRate / 100);
        stakeInfos[msg.sender].claimed = totalTokens;
        poolBalance += totalTokens;

        emit Claimed(msg.sender, totalTokens);

        return true;
    }

    event Claimed(address indexed holder, uint256 amount);
}