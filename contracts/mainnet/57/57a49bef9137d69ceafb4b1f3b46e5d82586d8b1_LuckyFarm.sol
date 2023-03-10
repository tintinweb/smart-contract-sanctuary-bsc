/**
 *Submitted for verification at BscScan.com on 2023-03-10
*/

// SPDX-License-Identifier: MIT

// redeployment to address/remove bug regarding updated staking starttime when user partially unstakes or claims yield thus reapplying early unstaking fee (line 256 and 299 of old staking contract respectively)

pragma solidity ^0.7.4;



library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}


/**
 * Allows for contract ownership along with multi-address authorization
 */
abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }


    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    /**
     * Authorize address. Owner only
     */
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}


//Interface name is not important, however functions in it are important
interface LuckyInterface{
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function getTotalShares(address account) external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

//Interface name is not important, however functions in it are important
interface validBoostInterface{
    function balanceOf(address user) external view returns (uint256);
}

//Interface name is not important, however functions in it are important
interface DiviesInterface{
    function setShare(address shareholder, uint256 amount) external; 
}


contract LuckyFarm is Auth {

    using SafeMath for uint256;

    mapping(address => uint256) public stakingBalance;
    mapping(address => bool) public isStaking;
    mapping(address => uint256) public startTime;

    bool internal locked = false; //locked logic to prevent reentrancy vunerables (decrement balance before sending also prevents this but be safe)

    address[] boostableContracts;
    mapping(address => uint256) boostRequiredAmount;

    mapping (address => uint256) contractBoost;

    string public name = "LuckyFarm";

    address DEAD = 0x000000000000000000000000000000000000dEaD; //dead address for burn

    uint256 performanceFee = 2;
    uint256 earlyUnstakeInterval = 259200; //72 hrs in seconds
    uint256 earlyUnstakeFee = 1;
    uint256 feeDenominator = 100;

    // Duration of rewards to be paid out (in seconds)
    uint256 public duration;
    // Timestamp of when the rewards finish
    uint256 public finishAt;
    // Minimum of last updated time and reward finish time
    uint256 public updatedAt;
    // Reward to be paid out per second
    uint256 public rewardRate;
    // Sum of (reward rate * dt * 1e18 / total supply)
    uint256 public rewardPerTokenStored;

    uint256 public totalBurnt;

    // User address => rewardPerTokenStored
    mapping(address => uint256) public userRewardPerTokenPaid;
    // User address => rewards to be claimed
    mapping(address => uint256) public rewards;

    // Total staked
    uint256 public totalStaked;

    LuckyInterface public luckyToken;
    DiviesInterface public Divies;

    event Stake(address indexed from, uint256 amount);
    event Unstake(address indexed from, uint256 amount,uint256 burnt);
    event YieldWithdraw(address indexed to, uint256 amount, uint256 burnt);

    constructor(address _luckyToken, address _diviesAddy) Auth(msg.sender)  {
            luckyToken = LuckyInterface(_luckyToken);
            Divies = DiviesInterface(_diviesAddy);
    }

    modifier updateReward(address _account) {
        rewardPerTokenStored = rewardPerToken();
        updatedAt = lastTimeRewardApplicable();

        if (_account != address(0)) {
            rewards[_account] = earned(_account);
            userRewardPerTokenPaid[_account] = rewardPerTokenStored;
        }

        _;
    }

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }

    function stake(uint256 amount) noReentrant() external updateReward(msg.sender) {
        require(
            amount > 0 &&
            luckyToken.balanceOf(msg.sender) >= amount, 
            "You cannot stake zero tokens");
            
        luckyToken.transferFrom(msg.sender, address(this), amount);
        stakingBalance[msg.sender] = stakingBalance[msg.sender].add(amount);
        totalStaked = totalStaked.add(amount);
        startTime[msg.sender] = block.timestamp;
        isStaking[msg.sender] = true;
        Divies.setShare(msg.sender, luckyToken.getTotalShares(msg.sender));
        emit Stake(msg.sender, amount);
    }

    function unstake(uint256 amount) noReentrant() external updateReward(msg.sender) {
        require(
            isStaking[msg.sender] = true &&
            stakingBalance[msg.sender] >= amount, 
            "Attempting To Unstake More Than Staked"
        );
        uint256 oldStartTime  = startTime[msg.sender];
        uint256 burn;
        if(block.timestamp < oldStartTime + earlyUnstakeInterval) {
            burn = amount.mul(earlyUnstakeFee).div(feeDenominator);
            luckyToken.transfer(DEAD, burn);
            totalBurnt = totalBurnt.add(burn);
        }
        uint256 balTransfer = amount.sub(burn);
        stakingBalance[msg.sender] = stakingBalance[msg.sender].sub(amount);
        totalStaked = totalStaked.sub(amount); 
        luckyToken.transfer(msg.sender, balTransfer);
        if(stakingBalance[msg.sender] == 0){
            isStaking[msg.sender] = false;
        }
        emit Unstake(msg.sender, balTransfer,burn);
    }


    function calculateYieldBoost(address user) public view returns(uint256){
        uint256 boostableContractCount = boostableContracts.length;
        uint256 totalBoostPerc = 0;
        for (uint256 i = 0; i < boostableContractCount; i++) {  //loop through all contracts that offer boosts
            validBoostInterface contractInstance = validBoostInterface(boostableContracts[i]);
            uint256 boostReq = boostRequiredAmount[boostableContracts[i]];
            if(contractInstance.balanceOf(user) >= boostReq ){
                totalBoostPerc = totalBoostPerc.add(contractBoost[boostableContracts[i]]);
            }   
        } 

        return totalBoostPerc; 
    } 
    

    function getRewardsRemaining(uint256 toTransfer) public view returns(bool){
        uint256 remaining = luckyToken.balanceOf(address(this)).sub(totalStaked);
        if (toTransfer > remaining) {
            return false;
        } else {
            return true;
        }
    }

    function withdrawYield() noReentrant() external updateReward(msg.sender) {
        uint256 toTransfer = rewards[msg.sender];

        require(
            toTransfer > 0,
            "Nothing to withdraw"
            );
        require(getRewardsRemaining(toTransfer), "No More Rewards Available"); //failsafe to stop people claiming others stake as yield
            
        uint256 burn = toTransfer.mul(performanceFee).div(feeDenominator);
        uint256 balTransfer = toTransfer.sub(burn);

        totalBurnt = totalBurnt.add(burn);
        rewards[msg.sender] = 0;
        
        luckyToken.transfer(DEAD, burn);
        luckyToken.transfer(msg.sender, balTransfer);
        emit YieldWithdraw(msg.sender, balTransfer,burn);
    } 


    function addBoostableContractAddress(address contractAddy, uint256 reqAmount, uint256 boostPerc) external authorized {
        boostableContracts.push(contractAddy);
        boostRequiredAmount[contractAddy] = reqAmount;
        contractBoost[contractAddy] = boostPerc;
    }


    function updateBoostableContractAddress(address contractAddy, uint256 boostPerc) external authorized {
        contractBoost[contractAddy] = boostPerc;
    }

    function removeBoostableContractAddress(uint256 index) external authorized {
        boostableContracts[index] = boostableContracts[boostableContracts.length - 1];
        boostableContracts.pop();
    }

    function getBoostableContractAddress() public view returns (address[] memory) {
        return boostableContracts;
    } 
    
    function pendingBoostedEarned(address _account) public view returns (uint256){
        uint256 boostRate = calculateYieldBoost(_account);
        return
            ((((stakingBalance[_account] * (rewardPerToken() - userRewardPerTokenPaid[_account])) / 1e18) + rewards[_account]).mul(boostRate).div(feeDenominator));
    }

    function earned(address _account) public view returns (uint256) {
        uint256 boostedEarned = pendingBoostedEarned(_account);
        return
            ((((stakingBalance[_account] * (rewardPerToken() - userRewardPerTokenPaid[_account])) / 1e18) + rewards[_account]).add(boostedEarned));
    }


    function setRewardsDuration(uint256 _duration) external onlyOwner {
        require(finishAt < block.timestamp, "reward duration not finished");
        duration = _duration;
    }

    function notifyRewardAmount(
        uint256 _amount
    ) external onlyOwner updateReward(address(0)) {
        if (block.timestamp >= finishAt) {
            rewardRate = _amount / duration;
        } else {
            uint256 remainingRewards = (finishAt - block.timestamp) * rewardRate;
            rewardRate = (_amount + remainingRewards) / duration;
        }

        require(rewardRate > 0, "reward rate = 0");
        require(
            rewardRate * duration <= luckyToken.balanceOf(address(this)),
            "reward amount > balance"
        );

        finishAt = block.timestamp + duration;
        updatedAt = block.timestamp;
    }

    function _min(uint256 x, uint256 y) private pure returns (uint256) {
        return x <= y ? x : y;
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return _min(finishAt, block.timestamp);
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalStaked == 0) {
            return rewardPerTokenStored;
        }

        return
            rewardPerTokenStored +
            (rewardRate * (lastTimeRewardApplicable() - updatedAt) * 1e18) /
            totalStaked;
    }

    function getAPR() public view returns (uint256){
        if (totalStaked == 0) {
            return 0;
        }

        return ((rewardRate.mul(60).mul(60).mul(24).mul(365)).mul(100).div(totalStaked));
    }

}