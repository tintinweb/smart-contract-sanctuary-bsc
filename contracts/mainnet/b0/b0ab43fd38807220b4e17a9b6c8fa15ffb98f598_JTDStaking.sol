/**
 *Submitted for verification at BscScan.com on 2022-06-30
*/

// JTD Staking

// Code written by MrGreenCrypto
// SPDX-License-Identifier: None

pragma solidity 0.8.15;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract JTDStaking{

    mapping(address => uint256) private shareholderIndexes;
    mapping(address => uint256) private lastClaim;
    mapping(address => Share) private shares;
    address[] private shareholders;
    struct Share {uint256 amount;uint256 totalExcluded;uint256 totalRealised;}

    uint256 private totalShares;
    uint256 private totalRewards;
    uint256 private totalDistributed;
    uint256 private rewardsPerShare;
    uint256 private veryLargeNumber = 10**36;
    uint256 private busdBalanceBefore;
    uint256 private minDistribution = 1 ether;
    uint256 private lastRewardsTime;
    uint256 private timeBetweenRewards;
    uint256 private currentIndex;
    IBEP20 private constant BUSD = IBEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    IBEP20 private constant JTD = IBEP20(0x5F314f6E9CF3956Fe13CA4BCFDd0a14e5AFE6969);

    function stake(uint256 amount) external {
        uint256 newBalanceOfBUSD = BUSD.balanceOf(address(this));
        uint256 busdSinceLastStake = newBalanceOfBUSD - busdBalanceBefore;
        totalRewards += busdSinceLastStake;
        rewardsPerShare = rewardsPerShare + veryLargeNumber * busdSinceLastStake / totalShares;
        
        if (shares[msg.sender].amount >= 0) distributeRewards(msg.sender);
        
        if (shares[msg.sender].amount == 0 && amount > 0) addShareholder(msg.sender);

        if (amount >= 0) {
            JTD.transferFrom(msg.sender, address(this), amount);
            totalShares += amount;
            shares[msg.sender].amount = amount;
            shares[msg.sender].totalExcluded = getTotalRewardsOf(shares[msg.sender].amount);
        }

    }

    function unstake() external {
        uint256 newBalanceOfBUSD = BUSD.balanceOf(address(this));
        uint256 busdSinceLastStake = newBalanceOfBUSD - busdBalanceBefore;
        totalRewards += busdSinceLastStake;
        rewardsPerShare = rewardsPerShare + veryLargeNumber * busdSinceLastStake / totalShares;

        if (shares[msg.sender].amount >= 0) {
            distributeRewards(msg.sender);
            totalShares = totalShares - shares[msg.sender].amount;
            JTD.transfer(msg.sender, shares[msg.sender].amount);
            shares[msg.sender].amount = 0;
            removeShareholder(msg.sender);
        }
    }

    function process(uint256 rewardsToSendPerTx) external {
        uint256 shareholderCount = shareholders.length;
        if (shareholderCount <= rewardsToSendPerTx) return;
        if(currentIndex == 0) lastRewardsTime = block.timestamp;
        if(lastRewardsTime + timeBetweenRewards > block.timestamp) return;

        for (uint256 rewardsSent = 0; rewardsSent < rewardsToSendPerTx; rewardsSent++) {
            if (currentIndex >= shareholderCount) currentIndex = 0;
            distributeRewards(shareholders[currentIndex]);
            currentIndex++;
        }
    }

    function distributeRewards(address shareholder) internal {
        uint256 amount = getUnpaidEarnings(shareholder);
        if (amount < minDistribution) return;

        BUSD.transfer(shareholder, amount);
        totalDistributed = totalDistributed + amount;
        shares[shareholder].totalRealised =
            shares[shareholder].totalRealised +
            amount;
        shares[shareholder].totalExcluded = getTotalRewardsOf(
            shares[shareholder].amount
        );
    }

    function getUnpaidEarnings(address shareholder) internal view returns (uint256) {
        uint256 shareholderTotalRewards = getTotalRewardsOf(shares[shareholder].amount);
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;
        if (shareholderTotalRewards <= shareholderTotalExcluded) return 0;
        return shareholderTotalRewards - shareholderTotalExcluded;
    }

    function getTotalRewardsOf(uint256 share) internal view returns (uint256) {
        return (share * rewardsPerShare) / veryLargeNumber;
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length - 1];
        shareholderIndexes[shareholders[shareholders.length - 1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }
}