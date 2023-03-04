/**
 *Submitted for verification at BscScan.com on 2023-03-03
*/

// File: IERC20.sol


pragma solidity ^0.8.0;
interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}
// File: ggf.sol


pragma solidity ^0.8.0;


contract Staking {
    
    address public stakedTokenAddress;   // address of the token being staked
address public rewardTokenAddress;   // address of the token being earned as a reward
address public owner;                // owner of the contract

uint256 public rewardRate;   // amount of reward token earned per staked token per second
uint256 public totalStaked;  // total amount of staked tokens in the contract

mapping(address => uint256) public stakedBalances;   // staked balance of each user
mapping(address => uint256) public lastUpdateTimes;  // timestamp of the last update for each user

constructor(address _stakedTokenAddress, address _rewardTokenAddress, uint256 _rewardRate) {
    stakedTokenAddress = _stakedTokenAddress;
    rewardTokenAddress = _rewardTokenAddress;
    owner = msg.sender;
    rewardRate = _rewardRate;
}


  function compound() external {
        uint256 reward = getReward(msg.sender);
        require(reward > 0, "No rewards to compound.");
        
        require(IERC20(rewardTokenAddress).transferFrom(msg.sender, address(this), reward), "Token transfer failed.");
        stakedBalances[msg.sender] += reward;
        totalStaked += reward;
        lastUpdateTimes[msg.sender] = block.timestamp;
    }

function stake(uint256 amount) external {
    require(amount > 0, "Amount must be greater than zero.");
    require(IERC20(stakedTokenAddress).transferFrom(msg.sender, address(this), amount), "Token transfer failed.");
    
    uint256 updatedBalance = stakedBalances[msg.sender] + amount;
    stakedBalances[msg.sender] = updatedBalance;
    totalStaked += amount;
    lastUpdateTimes[msg.sender] = block.timestamp;
}

function withdraw(uint256 amount) external {
    require(amount > 0, "Amount must be greater than zero.");
    require(stakedBalances[msg.sender] >= amount, "Insufficient staked balance.");
    
    uint256 updatedBalance = stakedBalances[msg.sender] - amount;
    stakedBalances[msg.sender] = updatedBalance;
    totalStaked -= amount;
    lastUpdateTimes[msg.sender] = block.timestamp;
    
    require(IERC20(stakedTokenAddress).transfer(msg.sender, amount), "Token transfer failed.");
}

function unstake() external {
    uint256 stakedAmount = stakedBalances[msg.sender];
    require(stakedAmount > 0, "No staked tokens to withdraw.");
    
    uint256 reward = getReward(msg.sender);
    
    stakedBalances[msg.sender] = 0;
    totalStaked -= stakedAmount;
    lastUpdateTimes[msg.sender] = block.timestamp;
    
    require(IERC20(stakedTokenAddress).transfer(msg.sender, stakedAmount), "Token transfer failed.");
    if (reward > 0) {
        require(IERC20(rewardTokenAddress).transfer(msg.sender, reward), "Token transfer failed.");
    }
}

function changeRewardRate(uint256 newRate) external {
    require(msg.sender == owner, "Only the owner can change the reward rate.");
    rewardRate = newRate;
}

function getReward(address user) public view returns (uint256) {
    uint256 elapsedTime = block.timestamp - lastUpdateTimes[user];
    return stakedBalances[user] * rewardRate * elapsedTime;
}

function claimRewards() external {
    uint256 rewards = getReward(msg.sender);
    require(rewards > 0, "No rewards to claim.");
    
    require(IERC20(rewardTokenAddress).transfer(msg.sender, rewards), "Token transfer failed.");
    lastUpdateTimes[msg.sender] = block.timestamp;
}
    
}