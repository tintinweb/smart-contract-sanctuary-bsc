/**
 *Submitted for verification at BscScan.com on 2022-10-19
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

contract Ownable {
    address public owner;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() {
        owner = msg.sender;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval( address indexed owner, address indexed spender, uint256 value );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom( address from, address to, uint256 amount ) external returns (bool);

    function TotalRewards() external view returns(uint256); 
}


contract SaltYard is Ownable {

    IERC20 public  SALTS;

    uint256 public totalStaked; // total SALTS staked on this contract
    
    uint256 public stake_duration; // 30 days / 90 days 
    
    // charges for early unstake before 7 days (early unstake tax)
    uint public interestRate ;

    constructor(address _tokenAddress)  {
        SALTS = IERC20(_tokenAddress);        
    } 


    struct  StakeInfo {   
        uint256 amount; // total staked amount
        uint[] stakes; // tracks every stake
        uint[] min_lockin; // minimum lockin period  
        uint256 claimed; // tracks interest withdrawn
        bool staked; // default false, true for stakers
    }

    // mapping(address => uint256) rewards;
    mapping (address => StakeInfo) public stakeInfos;

    address[] public stakedAddresses ;

    event Staked(address indexed user, uint256 thisStake, uint256 totalStaked, uint256 timestamp );
    event UnStaked(address indexed user, uint256 unstakedAmount, uint256 remainingStake, uint256 timestamp);


    function Stake(uint256 _amount) external {
        require(SALTS.transferFrom(msg.sender, address(this), _amount));
        StakeInfo storage _stakeInfo = stakeInfos[msg.sender];
        _stakeInfo.stakes.push(_amount);
        _stakeInfo.min_lockin.push(block.timestamp + 7 days);

        if(!_stakeInfo.staked){
            stakedAddresses.push(msg.sender);
        }
        _stakeInfo.staked = true;
        _stakeInfo.amount += _amount;
        totalStaked += _amount; 

        emit Staked(msg.sender, _amount, stakeInfos[msg.sender].amount, block.timestamp);

    }


    // helps in calculating early unstake tax
    struct Unstake_stats {
        uint unstakable; // passed 7 days
        uint taxable; // behind 7 days
    }

    mapping (address => Unstake_stats) stats;

    function UnStake(uint256 _amount) external {
        require(_amount <= stakeInfos[msg.sender].amount, "invalid amount");
        StakeInfo storage _stake = stakeInfos[msg.sender];
       
        for (uint i = 0; i < _stake.stakes.length; i ++) {
            if(_stake.min_lockin[i] <= block.timestamp) {
                stats[msg.sender].unstakable += _stake.stakes[i];
            } else {
                stats[msg.sender].taxable += _stake.stakes[i];
            }
        }

        uint totalTokens;
        if (_amount <= stats[msg.sender].unstakable) {
            totalTokens = _amount ;
        } else {
            uint remaining = _amount - stats[msg.sender].unstakable;
            uint amt_with_tax = remaining - (remaining * interestRate / 100);
            totalTokens = stats[msg.sender].unstakable + amt_with_tax ;
        }
        SALTS.transfer(msg.sender, totalTokens);

        totalStaked -= totalTokens ;
        _stake.amount -= totalTokens;

        emit UnStaked(msg.sender, _amount, stakeInfos[msg.sender].amount, block.timestamp);
    }


    //  Update all the staker's rewards in this method.

    // function UpdateRewards() public onlyOwner {
    //     for (uint i = 0 ; i <= stakedAddresses.length ; i ++) {
    //         address account = stakedAddresses[i];
    //         uint256 amount = stakeInfos[account].amount;
    //         uint256 reward_per_token = totalRewards() / totalStaked * (stake_duration * 24 * 60);
    //         uint256 _rewards = amount * reward_per_token;
    //         stakeInfos[account].rewards += _rewards;
    //     }
    // }


    // function claimRewards() public {
    //     uint amount = stakeInfos[msg.sender].rewards;
    //     SALTS.transfer(msg.sender, amount);
    //     stakeInfos[msg.sender].rewards -= amount ;
    //     stakeInfos[msg.sender].claimed += amount ;
    // }

    function claimRewards(uint amount) public {
        SALTS.transfer(msg.sender, amount);
        stakeInfos[msg.sender].claimed += amount;
    }

    // function calculateRewards(address user) internal view returns(uint256) {
    //     uint256 amount = stakeInfos[user].amount;
    //     uint256 reward_per_token = totalRewards() / totalStaked * (stake_duration * 24 * 60);
    //     uint256 rewards = amount * reward_per_token;
    //     return rewards;
    // }
    
    function set_stake_duration(uint _days) public onlyOwner {
        stake_duration = _days;
    }

    // Note: If interest rate is 0.1% then a = 1 & b = 10 ; interest rate is 0.1%
    // If interst rate is 1% then a = 1, b = 1 ; interestRate 1%
    function set_interest_rate(uint a, uint b) public onlyOwner {
        interestRate = a/b;
    }
    
    //////////////// View Functions ///////////////
    
    function lockinperiod(uint i) external view returns (uint256) {
        StakeInfo storage myStake = stakeInfos[msg.sender];
        return myStake.min_lockin[i];
    }
    
    // tracks total rewards sent to pool from marketplace 
    function totalRewards() internal view returns(uint256) {
        return SALTS.TotalRewards();
    }

    // returns the total amount of salts being staked 
    function stakedSalts() public view returns(uint256) {
        return totalStaked;
    }

    // returns the total number of stakers
    function totalStakers() public view returns(uint256) {
        return stakedAddresses.length;
    }

    // user stats

    // returns total rewards earned by a user 
    // function myTotalRewards() public view {
    //     calculateRewards(msg.sender);
    // }

    // returns total amount of saltz staked by a user
    function myStakedSaltz() public view returns(uint256) {
        return stakeInfos[msg.sender].amount;
    }

    // returns rewards of a user by index of address array
    // function rewardsPerAddress(uint i) internal view {
    //     address user = stakedAddresses[i];
    //     calculateRewards(user);
    // }

    // function updateRewards() public view {
    //     for (uint i = 0; i <= stakedAddresses.length; i++){
    //         rewardsPerAddress(i);
    //     }
    // }

}