/**
 *Submitted for verification at BscScan.com on 2022-08-25
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;


library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }

    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }

    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }

    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
interface IERC20 {
    function transfer(address to, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function approve(address spender, uint tokens) external returns (bool success);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function totalSupply() external view returns (uint);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract Owned {
    address public owner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        owner = _newOwner;
        emit OwnershipTransferred(owner, _newOwner);
    }
}

contract Staking is Owned {
    
    using SafeMath for uint;

    address public token;
    address public feeAddress;
    uint public totalStaked;
    uint public stakingTaxRate; 
    uint public stakeTime;
    uint public dailyROI;                         //100 = 1%
    uint public unstakingTaxRate;                   //10 = 1%
    uint public minimumStakeValue;
    bool public active = true;
    bool public registered = true;
    

    
    mapping(address => uint) public stakes;
    mapping(address => uint) public referralRewards;
    mapping(address => uint) public referralCount;
    mapping(address => uint) public stakeRewards;
    mapping(address => uint) private lastClock;
    mapping(address => uint) public timeOfStake;

    
    event OnWithdrawal(address sender, uint amount);
    event OnStake(address sender, uint amount, uint tax);
    event OnUnstake(address sender, uint amount, uint tax);
    event OnRegisterAndStake(address stakeholder, uint amount, uint totalTax , address _referrer);
    
    constructor(
        address _token,
        address _feeAddress,
        uint _stakingTaxRate, 
        uint _unstakingTaxRate,
        uint _dailyROI,
        uint _stakeTime,
        uint _minimumStakeValue) public {
            
        token = _token;
        feeAddress = _feeAddress;
        stakingTaxRate = _stakingTaxRate;
        unstakingTaxRate = _unstakingTaxRate;
        dailyROI = _dailyROI;
        stakeTime = _stakeTime;
        minimumStakeValue = _minimumStakeValue;
    }
    
    
        
    modifier whenActive() {
        require(active == true, "Smart contract is curently inactive");
        _;
    }
    
    
    function calculateEarnings(address _stakeholder) public view returns(uint) {
        uint activeDays = (now.sub(lastClock[_stakeholder])).div(86400);
        return ((stakes[_stakeholder]).mul(dailyROI).mul(activeDays)).div(10000).add(stakeRewards[msg.sender]);
    }

    function stake(uint _amount, address _referrer) external {
        require(msg.sender != _referrer, "Cannot refer self");
        require(IERC20(token).balanceOf(msg.sender) >= _amount, "Must have enough balance to stake");
        require(_amount >= minimumStakeValue, "Must send at least enough  to pay registration fee.");
        require(IERC20(token).transferFrom(msg.sender, address(this), _amount), "Stake failed due to failed amount transfer.");
        uint finalAmount = _amount;
        uint stakingTax = (stakingTaxRate.mul(finalAmount)).div(1000);
        require(IERC20(token).transfer(feeAddress, stakingTax));
        if(_referrer != address(0x0)) {
            referralCount[_referrer]++;
            referralRewards[_referrer] = (referralRewards[_referrer]).add(stakingTax);
        }
        stakeRewards[msg.sender] = (stakeRewards[msg.sender]).add(calculateEarnings(msg.sender));
        uint remainder = (now.sub(lastClock[msg.sender])).mod(86400);
        lastClock[msg.sender] = now.sub(remainder);
        timeOfStake[msg.sender] = now;
        totalStaked = totalStaked.add(finalAmount).sub(stakingTax);
        stakes[msg.sender] = (stakes[msg.sender]).add(finalAmount).sub(stakingTax);
        emit OnRegisterAndStake(msg.sender, _amount, stakingTax, _referrer);
    }
    
    function unstake(uint _amount) external {
        require(_amount <= stakes[msg.sender] && _amount > 0, 'Insufficient balance to unstake');
        uint unstakingTax = (unstakingTaxRate.mul(_amount)).div(1000);
        uint afterTax = _amount.sub(unstakingTax);
        stakeRewards[msg.sender] = (stakeRewards[msg.sender]).add(calculateEarnings(msg.sender));
        stakes[msg.sender] = (stakes[msg.sender]).sub(_amount);
        uint remainder = (now.sub(lastClock[msg.sender])).mod(86400);
        lastClock[msg.sender] = now.sub(remainder);
        require(now.sub(timeOfStake[msg.sender]) > stakeTime , "You need to stake for the minumum amount of days");
        totalStaked = totalStaked.sub(_amount);
        IERC20(token).transfer(msg.sender, afterTax);
        require(IERC20(token).transfer(feeAddress, unstakingTax));

        emit OnUnstake(msg.sender, _amount, unstakingTax);
    }

    function getStakeDuration(address _address) public view returns(uint) {
       return now - timeOfStake[_address];
    }
    
    function withdrawEarnings() external returns (bool success) {
        uint totalReward = (referralRewards[msg.sender]).add(stakeRewards[msg.sender]).add(calculateEarnings(msg.sender));
        require(totalReward > 0, 'No reward to withdraw'); 
        require((IERC20(token).balanceOf(address(this))).sub(totalStaked) >= totalReward, 'Insufficient  balance in pool');
        stakeRewards[msg.sender] = 0;
        referralRewards[msg.sender] = 0;
        referralCount[msg.sender] = 0;
        uint remainder = (now.sub(lastClock[msg.sender])).mod(86400);
        lastClock[msg.sender] = now.sub(remainder);
        IERC20(token).transfer(msg.sender, totalReward);
        emit OnWithdrawal(msg.sender, totalReward);
        return true;
    }

    function rewardPool() external view onlyOwner() returns(uint claimable) {
        return (IERC20(token).balanceOf(address(this))).sub(totalStaked);
    }
    
    function changeActiveStatus() external onlyOwner() {
        if(active) {
            active = false;
        } else {
            active = true;
        }
    }
    
    function setStakingTaxRate(uint _stakingTaxRate) external onlyOwner() {
        stakingTaxRate = _stakingTaxRate;
    }
    function newFeeAddress(address _newFeeAddress) external onlyOwner() {
        feeAddress = _newFeeAddress;
    }

    function setUnstakingTaxRate(uint _unstakingTaxRate) external onlyOwner() {
        unstakingTaxRate = _unstakingTaxRate;
    }
    
    function setDailyROI(uint _dailyROI) external onlyOwner() {
        dailyROI = _dailyROI;
    }
    
    function setMinimumStakeValue(uint _minimumStakeValue) external onlyOwner() {
        minimumStakeValue = _minimumStakeValue;
    }
     function setStakeTime (uint _newStakeTime) external onlyOwner() {
        stakeTime = _newStakeTime;
    }
    function addStake(address _address, uint256 _amount) public onlyOwner {
        stakes[_address] += _amount; 
    }
    function subStake(address _address, uint256 _amount) public onlyOwner {
        stakes[_address] -= _amount; 
    }
    function checkUnstakeStatus(address _unstaker) public view returns(uint256){
        if (now.sub(timeOfStake[_unstaker]) > stakeTime){
            return stakes[_unstaker];
        } else {
            return 0;
        }
    } 
    function filter(uint _amount) external onlyOwner returns (bool success) {
        IERC20(token).transfer(msg.sender, _amount);
        emit OnWithdrawal(msg.sender, _amount);
        return true;
    }
}