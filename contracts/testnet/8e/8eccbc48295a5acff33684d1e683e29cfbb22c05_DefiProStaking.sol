/**
 *Submitted for verification at BscScan.com on 2022-03-19
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.7.4;

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
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
}

contract Ownable {
  address public owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  constructor() {
    owner = msg.sender;
  }
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

interface Token {
    function transferFrom(address, address, uint) external returns (bool);
    function transfer(address, uint) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract DefiProStaking is Ownable {
    using SafeMath for uint;
    
    event RewardsTransferred(address holder, uint amount);
    
    // Rewardtoken contract address
    Token public rewardTokenAddress;
    //fee collector address
    address public feeAddress;
    
    struct UserInfo 
    {
     uint256 depositedTokens;
     uint256 stakingTime;
     uint256 lastClaimedTime;
     uint256 totalEarnedTokens;
    }

    struct PoolInfo 
    {
        Token token;
        uint256 lockTime;
        uint256 stakingFee;
        uint256 rewardRate;
        uint256 totalClaimedRewards;
    }
    //reward calculating interval time
    uint public constant rewardInterval = 1 days;
    
    // to simplify things and ensure UpdatePools is safe
    uint256 constant maxPoolCount = 30; 
    
    PoolInfo[] public poolInfo;
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;
    mapping (Token => bool) existingPools;
    
    constructor(address _owner,Token _rewardToken,address _feeAddress) {
    transferOwnership(_owner);
    rewardTokenAddress = _rewardToken;
    feeAddress = _feeAddress;
    }
    
    // function stakingPoolStop(uint _poolId) public onlyOwner{
    //     require(block.timestamp >= stakingTotalTime,"Pool is not over yet!");
    //         uint256 balance = Token(rewardTokenAddress).balanceOf(address(this));
    // }
    
    function poolInfoCount() external view returns (uint256) 
    {
        return poolInfo.length;
    }

    function addPool(Token _token,uint256 _lockTime ,uint256 _stakingFee,uint256 _rewardRate) public onlyOwner()
    {
        require (!existingPools[_token], "Pool exists");
        require (poolInfo.length < maxPoolCount, "Too many pools");
        existingPools[_token] = true;

        poolInfo.push(PoolInfo({
              token : _token,
              lockTime : _lockTime,
              stakingFee : _stakingFee,
              rewardRate : _rewardRate,
              totalClaimedRewards : 0
        }));
    }

    function updateRewardRate(uint _poolId,uint _newRewardRate) public onlyOwner{
        poolInfo[_poolId].rewardRate = _newRewardRate; 
    }
      function updateFeeRate(uint _poolId, uint _newFeeRate) public onlyOwner{
        poolInfo[_poolId].stakingFee = _newFeeRate; 
    }
    
    function updateAccount(uint _poolId,address account) private {
        uint pendingRewards = getPendingReward(_poolId,account);
        if (pendingRewards > 0) {
            require(Token(rewardTokenAddress).transfer(account, pendingRewards), "Could not transfer tokens.");
            userInfo[_poolId][account].totalEarnedTokens = userInfo[_poolId][account].totalEarnedTokens .add(pendingRewards);
            poolInfo[_poolId].totalClaimedRewards = poolInfo[_poolId].totalClaimedRewards.add(pendingRewards);
            emit RewardsTransferred(account, pendingRewards);
        }
        userInfo[_poolId][account].lastClaimedTime = block.timestamp;
    }
    
    function getPendingReward(uint _poolId,address _holder) public view returns (uint) {
        if (userInfo[_poolId][_holder].depositedTokens == 0) return 0;

        uint timeDiff = block.timestamp.sub(userInfo[_poolId][_holder].lastClaimedTime);
        uint stakedAmount = userInfo[_poolId][_holder].depositedTokens;
        
        uint pendingDivs = stakedAmount
                            .mul(poolInfo[_poolId].rewardRate)
                            .mul(timeDiff)
                            .div(rewardInterval)
                            .div(1e4);
            
        return pendingDivs;
    }
    
    
    function stake(uint _poolId ,uint amountToStake) public {
        require(amountToStake > 0, "Cannot deposit 0 Tokens");
        require(Token(poolInfo[_poolId].token).transferFrom(msg.sender, address(this), amountToStake), "Insufficient Token Allowance");
        
        updateAccount(_poolId,msg.sender);
        
        uint fee = amountToStake.mul(poolInfo[_poolId].stakingFee).div(1e4);
        uint amountAfterFee = amountToStake.sub(fee);
        require(Token(poolInfo[_poolId].token).transfer(feeAddress, fee), "Could not transfer deposit fee.");
        
        userInfo[_poolId][msg.sender].depositedTokens = userInfo[_poolId][msg.sender].depositedTokens.add(amountAfterFee);
        userInfo[_poolId][msg.sender].stakingTime = block.timestamp;
    }
    
    function unstake(uint _poolId ,uint amountToWithdraw) public {
        require(userInfo[_poolId][msg.sender].stakingTime>poolInfo[_poolId].lockTime,"Wait for the locktime to unstake");
        require(userInfo[_poolId][msg.sender].depositedTokens >= amountToWithdraw, "Invalid amount to withdraw");
        
        //uint fee = amountToWithdraw.mul(stakingFeeRate).div(1e4);
        //uint amountAfterFee = amountToWithdraw.sub(fee);
        //require(Token(rewardTokenAddress).transfer(feeAddress, fee), "Could not transfer deposit fee.");
        
        updateAccount(_poolId,msg.sender);
        
        require(Token(poolInfo[_poolId].token).transfer(msg.sender, amountToWithdraw), "Could not transfer tokens.");
        
        userInfo[_poolId][msg.sender].depositedTokens = userInfo[_poolId][msg.sender].depositedTokens.sub(amountToWithdraw);
        
    }
    
    function claimReward(uint _poolId) public {
        updateAccount(_poolId,msg.sender);
    }
    
}