/**
 *Submitted for verification at BscScan.com on 2023-03-02
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}


contract TokenStaking {
    address public owner;
    IERC20 public token;
    uint256 public stakingPeriod;
    uint256 public rewardRate;
    uint256 public totalStaked;
    mapping(address => uint256) public stakedBalances;
    mapping(address => uint256) public lastStakedTime;
    mapping(address => uint256) public rewards;

    event Staked(address indexed staker, uint256 amount);
    event Unstaked(address indexed staker, uint256 amount);
    event RewardClaimed(address indexed staker, uint256 amount);

    constructor(address tokenAddress, uint256 _stakingPeriod, uint256 _rewardRate) {
        token = IERC20(tokenAddress);
        stakingPeriod = _stakingPeriod;
        rewardRate = _rewardRate;
        owner = msg.sender;
    }

    function stake(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        require(token.balanceOf(msg.sender) >= amount, "Insufficient balance");
        if (stakedBalances[msg.sender] > 0) {
            uint256 reward = calculateReward(msg.sender);
            rewards[msg.sender] += reward;
            emit RewardClaimed(msg.sender, reward);
        }
        require(token.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        stakedBalances[msg.sender] += amount;
        lastStakedTime[msg.sender] = block.timestamp;
        totalStaked += amount;
        emit Staked(msg.sender, amount);
    }

    function unstake() external {
        require(stakedBalances[msg.sender] > 0, "No staked tokens");
        uint256 reward = calculateReward(msg.sender);
        rewards[msg.sender] += reward;
        emit RewardClaimed(msg.sender, reward);
        uint256 amount = stakedBalances[msg.sender];
        stakedBalances[msg.sender] = 0;
        totalStaked -= amount;
        require(token.transfer(msg.sender, amount), "Transfer failed");
        emit Unstaked(msg.sender, amount);
    }

    function claimReward() external {
        require(rewards[msg.sender] > 0, "No rewards to claim");
        uint256 reward = rewards[msg.sender];
        rewards[msg.sender] = 0;
        require(token.transfer(msg.sender, reward), "Transfer failed");
        emit RewardClaimed(msg.sender, reward);
    }

    function calculateReward(address staker) public view returns (uint256) {
        uint256 reward = (block.timestamp - lastStakedTime[staker]) * rewardRate * stakedBalances[staker] / stakingPeriod / 1e18;
        return reward;
    }
}