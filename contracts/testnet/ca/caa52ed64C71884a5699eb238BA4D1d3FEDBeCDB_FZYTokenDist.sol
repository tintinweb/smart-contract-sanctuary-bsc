/**
 *Submitted for verification at BscScan.com on 2022-12-21
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

interface IERC20 
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

contract FZYTokenDist  {
    using SafeMath for uint256; 
    IERC20 public fzy;
    
    uint256 private constant baseDivider = 10000;
    uint256 private constant minDeposit = 50e18;
    uint256 private constant timeStep = 1 days;
    uint256 private constant dayPerCycle = 30 days; 
    uint256 private constant dayRewardPercents = 50;
    uint256 private constant maxTokenPercents = 1000;
    
	uint256 private constant refer1Percents = 500;
	uint256 private constant refer2Percents = 300;
	uint256 private constant refer3Percents = 200;
    
    uint256 public startTime;
    mapping(uint256=>address[]) public splitDepositUsers;

    struct SplitInfo {
        uint256 amount; 
        uint256 start;
        uint256 unfreeze; 
        bool isUnfreezed;
    }

    mapping(address => SplitInfo[]) public splitInfos;

    address[] public depositors;

    struct UserInfo {
        uint256 start;
        uint256 totalSplitDeposit;
        uint256 totalReferDeposit;
        uint256 totalFreezed;
        uint256 totalRevenue;
    }

    mapping(address=>UserInfo) public userInfo;
    
    struct RewardInfo{
        uint256 statics;
    }

    mapping(address=>RewardInfo) public rewardInfo;
    
    bool public isFreezeReward;

    event DepositBySplit(address user, address refer1, address refer2, address refer3, uint256 amount);
    event Withdraw(address user, uint256 withdrawable);

    constructor() public {
        fzy = IERC20(0xeD45E8FCA9c0b36fd4F3b35A258b856BA3AB9d70);
        startTime = block.timestamp;
    }

    function depositBySplit(address _refer1, address _refer2, address _refer3, uint256 _amount) external {
        require(_amount >= minDeposit, "less than min");
		require(_amount.mod(minDeposit) == 0 && _amount >= minDeposit, "mod err");
		
		UserInfo storage user = userInfo[msg.sender];
		if(user.totalSplitDeposit == 0){
            uint256 dayNow = getCurDay();
            splitDepositUsers[dayNow].push(msg.sender);
        }	
		
		user.totalSplitDeposit = user.totalSplitDeposit.add(_amount);
		user.start = block.timestamp;
		uint256 tokenAmt = _amount.mul(maxTokenPercents).div(baseDivider);        
		UserInfo storage userRefer1 = userInfo[_refer1];
		uint256 tokenRefer1Amt = tokenAmt.mul(refer1Percents).div(baseDivider); 
		userRefer1.totalReferDeposit = userRefer1.totalReferDeposit.add(tokenRefer1Amt);
        
		UserInfo storage userRefer2 = userInfo[_refer2];
		uint256 tokenRefer2Amt = tokenAmt.mul(refer2Percents).div(baseDivider); 
		userRefer2.totalReferDeposit = userRefer2.totalReferDeposit.add(tokenRefer2Amt);
        
		UserInfo storage userRefer3 = userInfo[_refer3];
		uint256 tokenRefer3Amt = tokenAmt.mul(refer3Percents).div(baseDivider); 
		userRefer3.totalReferDeposit = userRefer3.totalReferDeposit.add(tokenRefer3Amt);
		
		tokenAmt = tokenAmt.add(user.totalReferDeposit);
		
		user.totalFreezed = user.totalFreezed.add(tokenAmt);
		uint256 unfreezeTime = block.timestamp.add(dayPerCycle);
		
		depositors.push(msg.sender);

		splitInfos[msg.sender].push(SplitInfo(
            tokenAmt, 
            block.timestamp, 
            unfreezeTime,
            false
        ));
        emit DepositBySplit(msg.sender, _refer1, _refer2, _refer3, _amount);
    }
	
    function withdraw() external {
		UserInfo storage user = userInfo[msg.sender];
		RewardInfo storage userRewards = rewardInfo[msg.sender];
		uint256 withdrawable = 0;
		for(uint256 i = 0; i < splitInfos[msg.sender].length; i++)
		{
			SplitInfo storage order = splitInfos[msg.sender][i];
			if(block.timestamp > order.unfreeze  && order.isUnfreezed == false && order.amount >= 0)
			{
				uint256 staticReward = order.amount.mul(dayRewardPercents).mul(dayPerCycle).div(timeStep).div(baseDivider);
				uint256 unfreezeTime = block.timestamp.add(dayPerCycle);
				order.unfreeze = unfreezeTime;
				if(user.totalFreezed > user.totalRevenue){
					uint256 leftCapital = user.totalFreezed.sub(user.totalRevenue);
					if(staticReward > leftCapital){
						staticReward = leftCapital;
					}
				}
				else
				{
					staticReward = 0;
				}
				userRewards.statics = userRewards.statics.add(staticReward);
				user.totalRevenue = user.totalRevenue.add(staticReward);
			}
		}
        withdrawable = withdrawable.add(userRewards.statics);
		fzy.transfer(msg.sender, withdrawable);
		userRewards.statics = 0;
        emit Withdraw(msg.sender, withdrawable);
    }

    function getCurDay() public view returns(uint256) {
        return (block.timestamp.sub(startTime)).div(timeStep);
    }

    function getOrderLength(address _user) external view returns(uint256) {
        return splitInfos[_user].length;
    }

    function getDepositorsLength() external view returns(uint256) {
        return depositors.length;
    }
}