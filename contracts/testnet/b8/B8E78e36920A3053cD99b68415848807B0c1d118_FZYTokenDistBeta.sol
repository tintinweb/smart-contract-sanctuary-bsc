/**
 *Submitted for verification at BscScan.com on 2023-01-03
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IBEP20 
{
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

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract FZYTokenDistBeta  {
    using SafeMath for uint256; 
    IBEP20 public fzy;
    
    uint256 private constant baseDivider = 10000;
    uint256 private constant minDeposit = 1e18;
    uint256 private constant timeStep = 1 minutes;
    uint256 private constant dayPerCycle = 3 minutes; 
    uint256 private constant dayRewardPercents = 5;
    
    uint256 public startTime;
    uint256 public totalTokenDistribute;
    mapping(uint256=>address[]) public tokenDepositUsers;

    struct TokenInfo {
        uint256 stakeToken; 
        uint256 amount; 
        uint256 start;
        uint256 unfreeze;
        uint256 lastClaim;
        uint256 rewardClaimed;
        bool isUnfreezed;
    }

    mapping(address => TokenInfo[]) public tokenInfos;

    address[] public depositors;

    struct UserInfo {
        uint256 start;
        uint256 totalTokenDeposit;
        uint256 totalFreezed;
        uint256 totalRevenue;
    }

    mapping(address=>UserInfo) public userInfo;
    
    bool public isFreezeReward;

    event StakingToken(address user, uint256 amount);
    event Withdraw(address user, uint256 withdrawable);

    constructor() public {
        fzy = IBEP20(0x0F6EB6BEbe238a7958bf26685032b16E1F851d2e);
        startTime = block.timestamp;
    }

    function stakingToken(uint256 _amount) external {
        require(_amount >= minDeposit, "less than min");
		require(_amount.mod(minDeposit) == 0 && _amount >= minDeposit, "mod err");
		
		UserInfo storage user = userInfo[msg.sender];
		if(user.totalTokenDeposit == 0){
            uint256 dayNow = getCurDay();
            tokenDepositUsers[dayNow].push(msg.sender);
        }
		
		user.totalTokenDeposit = user.totalTokenDeposit.add(_amount);
        user.totalFreezed = user.totalFreezed.add(_amount);
		user.start = block.timestamp;
		uint256 unfreezeTime = block.timestamp.add(dayPerCycle);
		uint256 rewardClaimed = 0;
		depositors.push(msg.sender);

		tokenInfos[msg.sender].push(TokenInfo(
            _amount,
            _amount, 
            block.timestamp, 
            unfreezeTime,
            block.timestamp,
            rewardClaimed,
            false
        ));
        emit StakingToken(msg.sender, _amount);
    }
	
    function withdraw() external {
		UserInfo storage user = userInfo[msg.sender];
		uint256 withdrawable = 0;
		for(uint256 i = 0; i < tokenInfos[msg.sender].length; i++)
		{
			TokenInfo storage order = tokenInfos[msg.sender][i];            
            if(order.isUnfreezed == false && order.rewardClaimed < order.amount && block.timestamp > order.unfreeze)
            {
                uint256 orderDays = (block.timestamp.sub(order.lastClaim)).div(timeStep);
                uint256 monthCycle = orderDays.div(3);
                uint256 nextCycleStart = monthCycle.mul(dayPerCycle);

                uint256 staticReward = order.amount.mul(dayRewardPercents).mul(dayPerCycle).div(timeStep).div(baseDivider);
                uint256 claimReward = staticReward.mul(monthCycle);
                order.lastClaim = order.lastClaim.add(nextCycleStart);
                order.unfreeze = order.lastClaim.add(dayPerCycle);
                if(order.amount > order.rewardClaimed.add(claimReward))
                {
                    withdrawable = withdrawable.add(claimReward);
                    order.rewardClaimed = order.rewardClaimed.add(claimReward);
                    user.totalRevenue = user.totalRevenue.add(claimReward);
                }
                if(order.amount < order.rewardClaimed)
                {
                    uint256 remainReward = order.amount.sub(order.rewardClaimed);
                    withdrawable = withdrawable.add(remainReward);
                    order.rewardClaimed = order.rewardClaimed.add(remainReward);
                    user.totalRevenue = user.totalRevenue.add(remainReward);                    
                    order.isUnfreezed = true;
                }
                if(order.amount == order.rewardClaimed)
                {
                    order.isUnfreezed = true;
                }
            }
		}
        totalTokenDistribute = totalTokenDistribute.add(withdrawable);
		fzy.transfer(msg.sender, withdrawable);
		withdrawable = 0;
        emit Withdraw(msg.sender, withdrawable);
    }

    function getCurDay() public view returns(uint256) {
        return (block.timestamp.sub(startTime)).div(timeStep);
    }

    function getOrderLength(address _user) external view returns(uint256) {
        return tokenInfos[_user].length;
    }

    function getDepositorsLength() external view returns(uint256) {
        return depositors.length;
    }
}