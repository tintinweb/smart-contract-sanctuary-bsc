/**
 *Submitted for verification at BscScan.com on 2022-05-10
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
// We need a staking plan in which the user will stake a bep20 token and he’ll get a reward in the same token
// Plan:
// 1 day 10% extra
// 3 days 20% extra
// 7 days 30% extra
// 12 days 50% extra
// 15 days 80% extra
// 20 days 100% 
// For testing purposes, we can set
// 1 day=1 second 

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
interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}
contract staking{
    using SafeMath for uint256;
    IERC20 SYAC;
    struct myStruck{
        uint256 amount;
        uint256 initialTime;
        uint256 finalTime;
        uint256 totalReward;
    }

    constructor(IERC20 _SYAC){
        SYAC = _SYAC;
    }
    mapping(address => myStruck) public stakes;
    mapping(address => bool) public isStaked;
    address[] internal stakesHolder;
    uint256 public totalTime = 20 minutes;

    function stake(uint256 _amount) external{
        require(_amount > 0 && !isStaked[msg.sender]);
        isStaked[msg.sender] = true;
        stakesHolder.push(msg.sender);
        SYAC.transferFrom(msg.sender, address(this), _amount);
        stakes[msg.sender].initialTime = block.timestamp;
        stakes[msg.sender].amount = _amount;
        stakes[msg.sender].finalTime = block.timestamp + totalTime;
        stakes[msg.sender].totalReward = stakes[msg.sender].amount.mul(2);
    }
    function calculateReward(address _addr) public view returns(uint256){
        uint256 reward;
        uint256 TimeDiff = block.timestamp - stakes[_addr].initialTime;
        if(TimeDiff >= totalTime){
            reward = stakes[_addr].amount.mul(2);
        }
        else if(TimeDiff < 2 minutes){
            reward = stakes[_addr].amount.div(100).mul(10);
        }
        else if(TimeDiff < 4 minutes){
            reward = stakes[_addr].amount.div(100).mul(20);
        }
        else if(TimeDiff < 8 minutes){
            reward = stakes[_addr].amount.div(100).mul(30);
        }
        else if(TimeDiff < 13 minutes){
            reward = stakes[_addr].amount.div(100).mul(50);
        }    
        else{
            reward = stakes[_addr].amount.div(100).mul(80);
        }
        return reward;
       }
    function withdrawReward(address _addr) public{
        uint256 reward = calculateReward(_addr);
        SYAC.transfer(_addr, reward);
        stakes[_addr].initialTime = 0;
    }
    function unstake(address _addr) external {
        withdrawReward(_addr);
        SYAC.transfer(address(this), stakes[_addr].amount);
        isStaked[_addr] = false;
    }
}