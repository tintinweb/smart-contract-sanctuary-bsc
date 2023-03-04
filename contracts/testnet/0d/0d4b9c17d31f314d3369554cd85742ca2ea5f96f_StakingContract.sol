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
// File: dex1.sol



pragma solidity ^0.8.0;


contract StakingContract {
    IERC20 public stakingToken;
    IERC20 public rewardToken;
    
    uint256 public totalStaked;
    uint256 public rewardRate;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;

    mapping(address => uint256) public stakedBalances;
    mapping(address => uint256) public earnedRewards;

    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardRateChanged(uint256 newRate);
    event Unstaked(address indexed user, uint256 amount);
    event Compounded(address indexed user, uint256 amount);
    event RewardsDistributed(uint256 amount);
    event RewardClaimed(address indexed user, uint256 amount);

    constructor(address _stakingToken, address _rewardToken) {
        stakingToken = IERC20(_stakingToken);
        rewardToken = IERC20(_rewardToken);
        rewardRate = 1; // Default reward rate of 1 reward token per staked token per day
        lastUpdateTime = block.timestamp;
    }

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            earnedRewards[account] = earnedReward(account);
        }
        _;
    }

    function stakedBalanceOf(address account) public view returns (uint256) {
        return stakedBalances[account];
    }

    function earnedReward(address account) public view returns (uint256) {
        uint256 stakedBalance = stakedBalances[account];
        return stakedBalance * (rewardPerToken() - rewardPerTokenStored) / 1e18 + earnedRewards[account];
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalStaked == 0) {
            return rewardPerTokenStored;
        }
        return rewardPerTokenStored + (lastTimeRewardApplicable() - lastUpdateTime) * rewardRate * 1e18 / totalStaked;
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return block.timestamp;
    }

    function stake(uint256 amount) public updateReward(msg.sender) {
        require(amount > 0, "Cannot stake 0 tokens");
        totalStaked += amount;
        stakedBalances[msg.sender] += amount;
        stakingToken.transferFrom(msg.sender, address(this), amount);
        emit Staked(msg.sender, amount);
    }

    function withdraw(uint256 amount) public updateReward(msg.sender) {
        require(amount > 0, "Cannot withdraw 0 tokens");
        require(stakedBalances[msg.sender] >= amount, "Insufficient staked balance");
        totalStaked -= amount;
        stakedBalances[msg.sender] -= amount;
        stakingToken.transfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount);
    }

    function changeRewardRate(uint256 newRate) public {
        require(msg.sender == address(this), "Only contract itself can change reward rate");
        rewardRate = newRate;
        lastUpdateTime = block.timestamp;
        emit RewardRateChanged(newRate);
    }

    function unstake() public updateReward(msg.sender) {
        uint256 stakedBalance = stakedBalances[msg.sender];
        require(stakedBalance > 0, "Cannot unstake 0 tokens");
        totalStaked -= stakedBalance;
            stakedBalances[msg.sender] = 0;
    stakingToken.transfer(msg.sender, stakedBalance);
    emit Unstaked(msg.sender, stakedBalance);
}

function compound() public updateReward(msg.sender) {
    uint256 earned = earnedRewards[msg.sender];
    require(earned > 0, "Cannot compound 0 rewards");
    earnedRewards[msg.sender] = 0;
    stakedBalances[msg.sender] += earned;
    totalStaked += earned;
    emit Compounded(msg.sender, earned);
}

function distributeRewards(uint256 amount) public {
    require(msg.sender == address(this), "Only contract itself can distribute rewards");
    rewardToken.transferFrom(msg.sender, address(this), amount);
    rewardPerTokenStored += amount * 1e18 / totalStaked;
    emit RewardsDistributed(amount);
}

function claimReward() public updateReward(msg.sender) {
    uint256 earned = earnedRewards[msg.sender];
    require(earned > 0, "No rewards to claim");
    earnedRewards[msg.sender] = 0;
    rewardToken.transfer(msg.sender, earned);
    emit RewardClaimed(msg.sender, earned);
}
}