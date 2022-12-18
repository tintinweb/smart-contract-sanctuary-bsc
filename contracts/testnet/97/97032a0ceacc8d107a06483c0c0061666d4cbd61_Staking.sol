/**
 *Submitted for verification at BscScan.com on 2022-12-17
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
contract Owned {
    address payable public owner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() {
        owner = payable(msg.sender);
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address payable _newOwner) public onlyOwner {
        owner = _newOwner;
        emit OwnershipTransferred(msg.sender, _newOwner);
    }
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 *
*/
 
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
  
  function ceil(uint a, uint m) internal pure returns (uint r) {
    return (a + m - 1) / m * m;
  }
}


// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// ----------------------------------------------------------------------------
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address tokenOwner) external view returns (uint256 balance);
    function allowance(address tokenOwner, address spender) external view returns (uint256 remaining);
    function transfer(address to, uint256 tokens) external returns (bool success);
    function approve(address spender, uint256 tokens) external returns (bool success);
    function transferFrom(address from, address to, uint256 tokens) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);
}

contract Staking is Owned{
    
    using SafeMath for uint256;

    uint256 public totalRewards;
    uint256 public stakingRate = 100; // 100%
    uint256 public totalStakes;

    address public ATG = 0xA91DCDD458Ed100C18949B653E27250aBE93F2EA;
    struct DepositedToken{
        uint256 activeDeposit;
        uint256 totalDeposits;
        uint256 startTime;
        uint256 pendingGains;
        uint256 lastClaimedDate;
        uint256 totalGained;
    }
    
    mapping(address => mapping(address => DepositedToken)) users;
    
    event StakeStarted(uint256 indexed _amount);
    event RewardsCollected(uint256 indexed _rewards);
    event AddedToExistingStake(uint256 indexed tokens);
    event StakingStopped(uint256 indexed _refunded);
 
    function Stake(address ATG_LP, uint256 _amount) external{
        
        // add to stake
        _newDeposit(ATG_LP, _amount); 
        emit StakeStarted(_amount);
    }
    
    
    function AddToStake(address _ATG_LP,uint256 _amount) internal{
        
        _addToExisting(_ATG_LP,_amount);  
        emit AddedToExistingStake(_amount);
    }
  
     function ClaimReward(address _ATG_LP) external {
        require(PendingReward(_ATG_LP, msg.sender) > 0, "No pending rewards");
    
        uint256 _pendingReward = PendingReward(_ATG_LP, msg.sender);
        
        // Global stats update
        totalRewards = totalRewards.add(_pendingReward);
        
        // update the record
        users[msg.sender][ATG].totalGained = users[msg.sender][ATG].totalGained.add(_pendingReward);
        users[msg.sender][ATG].lastClaimedDate = block.timestamp;
        users[msg.sender][ATG].pendingGains = 0;
        
        // mint more tokens inside token contract equivalent to _pendingReward
        require(IERC20(ATG).transfer(msg.sender, _pendingReward));
        
        emit RewardsCollected(_pendingReward);
    }
   function StopStaking(address _ATG_LP) external {
        require(users[msg.sender][_ATG_LP].activeDeposit >= 0, "No active stake");
        uint256 _activeDeposit = users[msg.sender][_ATG_LP].activeDeposit;
        
        // update staking stats
            // check if we have any pending rewards, add it to previousGains var
            users[msg.sender][ATG].pendingGains = PendingReward(_ATG_LP, msg.sender);
            // update amount 
            users[msg.sender][_ATG_LP].activeDeposit = 0;
            // reset last claimed figure as well
            users[msg.sender][ATG].lastClaimedDate = block.timestamp;
        
        // withdraw the tokens and move from contract to the caller
        require(IERC20(_ATG_LP).transfer(msg.sender, _activeDeposit));
        
        emit StakingStopped(_activeDeposit);
    }
    
   
    function PendingReward(address _ATG_LP, address _caller) public view returns(uint256 _pendingRewardWeis){
        uint256 _totalStakingTime = block.timestamp.sub(users[_caller][ATG].lastClaimedDate);
        
        uint256 _reward_token_second = ((stakingRate).mul(10 ** 12)).div(365 days); // added extra 10^12
        
        uint256 reward = ((users[_caller][_ATG_LP].activeDeposit).mul(_totalStakingTime.mul(_reward_token_second))).div(10 ** 14); // remove extra 10^12 // 10^2 are for 100 (%)
        
        return reward.add(users[_caller][ATG].pendingGains);
    }
    
  
    function ActiveStakeDeposit(address _ATG_LP,address _user) external view returns(uint256 _activeDeposit){
        return users[_user][_ATG_LP].activeDeposit;
    }
 
    // ------------------------------------------------------------------------
    function YourTotalStakingTillToday(address _ATG_LP,address _user) external view returns(uint256 _totalStaking){
        return users[_user][_ATG_LP].totalDeposits;
    }
    
  
    function LastStakedOn(address _ATG_LP,address _user) external view returns(uint256 _unixLastStakedTime){
        return users[_user][_ATG_LP].startTime;
    }
    
   
    function TotalStakingRewards(address _ATG_LP, address _user) external view returns(uint256 _totalEarned){
        return users[_user][_ATG_LP].totalGained;
    }
    
       
    function _newDeposit(address _ATG_LP, uint256 _amount) internal{
        if(users[msg.sender][_ATG_LP].activeDeposit >  0){
            AddToStake(_ATG_LP, _amount);
        }
        else{
        // add that token into the contract balance
        // check if we have any pending reward, add it to pendingGains variable
        users[msg.sender][ATG].pendingGains = PendingReward(_ATG_LP, msg.sender);
            
        users[msg.sender][_ATG_LP].activeDeposit = _amount;
        users[msg.sender][_ATG_LP].totalDeposits = users[msg.sender][_ATG_LP].totalDeposits.add(_amount);
        users[msg.sender][_ATG_LP].startTime = block.timestamp;
        users[msg.sender][ATG].lastClaimedDate = block.timestamp;
        
        // update global stats
        totalStakes = totalStakes.add(_amount);
          // transfer tokens from user to the contract balance
        require(IERC20(_ATG_LP).transferFrom(msg.sender, address(this), _amount));
        }
    }
 
    function _addToExisting(address _ATG_LP,uint256 _amount) internal{
        
        // update staking stats
            // check if we have any pending reward, add it to pendingGains variable
            users[msg.sender][ATG].pendingGains = PendingReward(_ATG_LP, msg.sender);
            
            // update current deposited amount 
            users[msg.sender][_ATG_LP].activeDeposit = users[msg.sender][_ATG_LP].activeDeposit.add(_amount);
            // update total deposits till today
            users[msg.sender][_ATG_LP].totalDeposits = users[msg.sender][_ATG_LP].totalDeposits.add(_amount);
            // update new deposit start time -- new stake will begin from this time onwards
            users[msg.sender][_ATG_LP].startTime = block.timestamp;
            // reset last claimed figure as well -- new stake will begin from this time onwards
            users[msg.sender][ATG].lastClaimedDate = block.timestamp;
            // move the tokens from the caller to the contract address
            require(IERC20(_ATG_LP).transferFrom(msg.sender,address(this), _amount));
        // update global stats
        totalStakes = totalStakes.add(_amount);
    }
}