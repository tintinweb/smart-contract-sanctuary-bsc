/**
 *Submitted for verification at BscScan.com on 2023-03-10
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract Staking {
    IERC20 public token;
    uint256 public minimumStake = 100 * 10**18; 
    uint256 public maximumStake = 100000 * 10**18;
    uint256 public dailyInterestRate = 100; // 1%
    uint256 public referralLevel1Percentage = 50;
    uint256 public referralLevel2Percentage = 30;
    uint256 public referralLevel3Percentage = 20;
    mapping(address => uint256) public stakedAmounts;
    mapping(address => uint256) public lastClaimedTimes;
    mapping(address => address) public referrers;
    mapping(address => uint256) public referralEarnings;

    event Staked(address indexed user, uint256 amount);
    event Claimed(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);

    constructor(IERC20 _token) {
        token = _token;
    }

    function stake(uint256 amount, address referrer) external  {
        require(amount >= minimumStake && amount <= maximumStake, "Invalid amount");
        require(token.transferFrom(msg.sender, address(this), amount), "Token transfer failed");

        if (referrers[msg.sender] == address(0) && referrer != address(0) && referrer != msg.sender) {
            referrers[msg.sender] = referrer;
        }

        stakedAmounts[msg.sender] += amount;
        lastClaimedTimes[msg.sender] = block.timestamp;

        emit Staked(msg.sender, amount);
    }

    function claim() external  {
        uint256 amount = calculateEarnings(msg.sender);
        require(amount > 0, "No earnings");

        lastClaimedTimes[msg.sender] = block.timestamp;
        require(token.transfer(msg.sender, amount), "Token transfer failed");

        emit Claimed(msg.sender, amount);
    }

    function withdraw(uint256 amount) external {
        require(amount > 0 && amount <= stakedAmounts[msg.sender], "Invalid amount");
        uint256 earnings = calculateEarnings(msg.sender);

        if (earnings > 0) {
            lastClaimedTimes[msg.sender] = block.timestamp;
            require(token.transfer(msg.sender, earnings), "Token transfer failed");
            emit Claimed(msg.sender, earnings);
        }

        stakedAmounts[msg.sender] -= amount;
        require(token.transfer(msg.sender, amount), "Token transfer failed");
        
        emit Withdrawn(msg.sender, amount);
    }

    function calculateEarnings(address account) internal returns (uint256) {
        uint256 stakedAmount = stakedAmounts[account];
        require(stakedAmount >= minimumStake && stakedAmount <= maximumStake, "Invalid staked amount");
    
        uint256 timeDiff = block.timestamp - lastClaimedTimes[account];
        uint256 earningsPercentage = timeDiff * dailyInterestRate / 86400;
        uint256 earnings = stakedAmount * earningsPercentage / 100;
    
        uint256 referrer1Earnings = earnings * referralLevel1Percentage / 100;
        referralEarnings[referrers[account]] += referrer1Earnings;
    
        address referrer2 = referrers[referrers[account]];
        if (referrer2 != address(0)) {
            uint256 referrer2Earnings = earnings * referralLevel2Percentage / 100;
            referralEarnings[referrer2] += referrer2Earnings;
            address referrer3 = referrers[referrer2];
            if (referrer3 != address(0)) {
                uint256 referrer3Earnings = earnings * referralLevel3Percentage / 100;
                referralEarnings[referrer3] += referrer3Earnings;
            }
        }
        lastClaimedTimes[account] = block.timestamp;
        return earnings;
    }

    function getReferralEarnings() external view returns (uint256) {
        return referralEarnings[msg.sender];
    }

    function withdrawReferralEarnings() external {
        uint256 amount = referralEarnings[msg.sender];
        require(amount > 0, "No earnings");
        referralEarnings[msg.sender] = 0;
        require(token.transfer(msg.sender, amount), "Token transfer failed");
    }
}