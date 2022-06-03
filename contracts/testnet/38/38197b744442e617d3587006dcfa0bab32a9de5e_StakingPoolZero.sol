/**
 *Submitted for verification at BscScan.com on 2022-06-02
*/

// SPDX-License-Identifier: MIT

// File: contracts/staking pool 0.sol


pragma solidity ^0.8.4;

contract StakingPoolZero {
    IBEP20 public rewardsToken;// Contract address of reward token
    IBEP20 public stakingToken;// Contract address of staking token 

    //declaring total staked
    uint256 public totalStaked;

    //users staking balance
    mapping(address => uint256) public stakingBalance;

    //mapping list of users who ever staked
    mapping(address => bool) public hasStaked;

    //mapping list of users who are staking at the moment
    mapping(address => bool) public isStakingAtm;
    

    //array of all stakers
    address[] public stakers;

    uint public percentageYield = 5; // Percentage for rewards
    uint public lastUpdateTime;
    uint256 public stakePeriod = 0 days;
    uint256 public stakeTime;
    uint public rewardPerTokenStored;
    address ownersAddress;

    mapping(address => uint) public userRewardPerTokenPaid;
    mapping(address => uint) public rewards;

    uint private _totalSupply;
    mapping(address => uint) private _balances;

    constructor(address _stakingToken, address _rewardsToken, address administratorAddress) {
        stakingToken = IBEP20(_stakingToken);
        rewardsToken = IBEP20(_rewardsToken);
        administratorAddress = payable(ownersAddress);
    }

    //Function to change Percentage Yield
    function changePY(uint newPY) public{
        percentageYield = newPY;
    }

    //Function to calculate reward per token staked
    function rewardPerToken() public view returns (uint) {
        if (_totalSupply == 0) {
            return 0;
        }
        return
            rewardPerTokenStored +
            (((block.timestamp - stakeTime) * percentageYield) / 100);
    }
    
        //function to calculate reward
    function earned(address account) public view returns (uint) {
        if (block.timestamp - stakeTime < stakePeriod){
            return 0;
        }
        return
            ((stakingBalance[account] *
                (rewardPerToken() - userRewardPerTokenPaid[account]))) +
            rewards[account];
        
    }
        //function to update reward
    modifier updateReward(address account) {
        
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = block.timestamp;

        rewards[account] = earned(account);
        userRewardPerTokenPaid[account] = rewardPerTokenStored;
        _;
    }
        //function to stake the token
    function stake(uint _amount) public {
    totalStaked = totalStaked + _amount;
     stakingBalance[msg.sender] = stakingBalance[msg.sender] + _amount;
        stakeTime = block.timestamp;
        stakingToken.transferFrom(msg.sender, address(this), _amount);
         //checking if user staked before or not, if NOT staked adding to array of stakers
        if (!hasStaked[msg.sender]) {
            stakers.push(msg.sender);
        }

        //updating staking status
        hasStaked[msg.sender] = true;
        isStakingAtm[msg.sender] = true;
    }

    function unstake() public {
        //get staking balance for user

        uint256 balance = stakingBalance[msg.sender];

        //amount should be more than 0
        require(balance > 0, "amount has to be more than 0");

        //transfer staked tokens back to user
        stakingToken.transfer(msg.sender, balance);
        totalStaked = totalStaked - balance;

        //reseting users staking balance
        stakingBalance[msg.sender] = 0;

        //updating staking status
        isStakingAtm[msg.sender] = false;
    }
  
        // Function to claim reward
    function claimReward() external updateReward(msg.sender) {
        uint reward = rewards[msg.sender];
        rewards[msg.sender] = 0;
        rewardsToken.transfer(msg.sender, reward);
    }
    
    function changeAdminAddress(address payable newAdminAddress) public payable{
     require(msg.sender == ownersAddress, "UnAuthorized to take this action");
    ownersAddress = newAdminAddress;
    }

}

interface IBEP20 {
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