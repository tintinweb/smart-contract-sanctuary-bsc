/**
 *Submitted for verification at BscScan.com on 2023-03-02
*/

// SPDX-License-Identifier: UNLICENSED 
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);
    function balanceOf(address who) external view returns (uint256);
}

contract StakingContract {
    mapping (address => uint256) public stakedAmounts;
    mapping (address => uint256) public lastStakeTimes;
    mapping (address => uint256) public rewards;
    mapping (address => bool) public approvedAddresses;
    address public stakedToken;
    address public rewardToken;
    address public governanceAddress;
    uint256 public totalStakedAmount;
    uint256 public totalRewards;

    uint256 public constant REWARD_RATE = 1;
    uint256 public constant REWARD_INTERVAL = 1 days;

    constructor(address _stakedToken, address _rewardToken, address _governanceAddress) {
        stakedToken = _stakedToken;
        rewardToken = _rewardToken;
        governanceAddress = _governanceAddress;
    }

    function stake(uint256 _amount) public {
        require(_amount > 0, "Amount must be greater than 0");
        require(IERC20(stakedToken).balanceOf(msg.sender) >= _amount, "Insufficient balance");

        distributeRewards(msg.sender);

        IERC20(stakedToken).transferFrom(msg.sender, address(this), _amount);

        stakedAmounts[msg.sender] += _amount;
        lastStakeTimes[msg.sender] = block.timestamp;
        totalStakedAmount += _amount;
    }

    function unstake(uint256 _amount) public {
        require(_amount > 0, "Amount must be greater than 0");
        require(stakedAmounts[msg.sender] >= _amount, "Insufficient staked amount");

        distributeRewards(msg.sender);

        IERC20(stakedToken).transfer(msg.sender, _amount);

        stakedAmounts[msg.sender] -= _amount;
        totalStakedAmount -= _amount;
    }

    function withdraw() public {
        uint256 reward = rewards[msg.sender];
        require(reward > 0, "No rewards to withdraw");

        distributeRewards(msg.sender);

        IERC20(rewardToken).transfer(msg.sender, reward);

        rewards[msg.sender] = 0;
        totalRewards -= reward;
    }

    function distributeRewards(address _account) private {
        uint256 timeSinceLastDistribution = block.timestamp - lastStakeTimes[_account];
        uint256 reward = stakedAmounts[_account] * timeSinceLastDistribution * REWARD_RATE / REWARD_INTERVAL;

        if (reward > 0) {
            rewards[_account] += reward;
            totalRewards += reward;
        }

        lastStakeTimes[_account] = block.timestamp;
    }

    function compoundRewards() public {
        distributeRewards(msg.sender);

        uint256 reward = rewards[msg.sender];
        require(reward > 0, "No rewards to compound");

        IERC20(rewardToken).transferFrom(msg.sender, address(this), reward);

        stakedAmounts[msg.sender] += reward;
        totalStakedAmount += reward;
        rewards[msg.sender] = 0;
    }

    function approveAddress(address _address) public {
        require(msg.sender == governanceAddress, "Only governance can approve addresses");
        approvedAddresses[_address] = true;
    }

    function revokeApproval(address _address) public {
        require(msg.sender == governanceAddress, "Only governance can revoke approvals");
        approvedAddresses[_address] = false;
    }

    function spend(address _recipient, uint256 _amount) public {
        require(approvedAddresses[msg.sender], "Sender not approved to spend");
        IERC20(rewardToken).transfer(_recipient, _amount);
    }

}