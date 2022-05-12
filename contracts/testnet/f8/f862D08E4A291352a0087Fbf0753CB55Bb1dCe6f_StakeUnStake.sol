/**
 *Submitted for verification at BscScan.com on 2022-05-12
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IERC20{
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

library SafeMath {
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

contract StakeUnStake{
    
    using SafeMath for uint256;
    address public Owner;
    address team = 0xE569166c7A16195c18C697D4c10416dfBB9c99Bc;
    IERC20 tokenA;
    IERC20 tokenB;

    uint256 private finaltime = 60 seconds;
    uint256 private rewardTime =5 seconds;
    uint private rewardPercentage = 30;

    constructor(IERC20 _stake, IERC20 _reward){
        Owner = msg.sender;
        tokenA = _stake;
        tokenB = _reward;
    }

    struct Staker{
        uint256 amount;
        uint256 time;
        uint256 Reward;
        uint256 withdraw;
        uint256 totalreward;
    }

    mapping (address => Staker) public userStake;
      
   function deposit(uint256 _amount) public {
       tokenA.transferFrom(msg.sender, address(this), _amount);
       userStake[msg.sender].amount = _amount;
       userStake[msg.sender].time = block.timestamp;
       userStake[msg.sender].totalreward = (_amount).mul(360).div(100);
   }
   function calculateReward(address _user) public view returns(uint reward){

        require(block.timestamp > userStake[msg.sender].time, "Too Early");
        if(block.timestamp >= userStake[_user].time + finaltime){
            reward = (userStake[_user].amount).mul(360).div(100);
        }else{

            reward = (block.timestamp).sub(userStake[_user].time).div(rewardTime).mul(userStake[_user].amount).mul(rewardPercentage).div(100);  
        }
        reward -=userStake[msg.sender].withdraw;
        return reward;

    }

    function withdrawReward() public {
        uint256 rewardAmount = calculateReward(msg.sender);
        require(rewardAmount >0, "No Reward");
        uint comission;
        comission =(rewardAmount)*5/100;
        rewardAmount -=comission;
        tokenB.transfer(team, comission);
        tokenB.transfer(msg.sender, rewardAmount);

        
        userStake[msg.sender].Reward = rewardAmount;
        userStake[msg.sender].totalreward -= rewardAmount;
        userStake[msg.sender].withdraw +=rewardAmount;
    }

    function UNSTAKE() external {
        uint256 a = userStake[msg.sender].amount;
        tokenA.transfer(msg.sender, a);
        userStake[msg.sender].amount = 0;
        userStake[msg.sender].time = 0;
        userStake[msg.sender].Reward = 0;
    }






}