/**
 *Submitted for verification at BscScan.com on 2022-02-03
*/

pragma solidity ^0.8.5;

// SPDX-License-Identifier: Unlicensed

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
 
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

contract StakeContract {
    
    using SafeMath for uint256;
    IBEP20 public token;

    uint256 public buyFee;
    uint256 public sellFee;

    // Info of each user.
    struct UserInfo {
        uint256 amount;           // How many tokens the user has provided.
        uint256 firstStakedBlock; // first stake time
        uint256 lastCalcBlock;
        uint256 reward;
    }

    mapping (address => UserInfo) public userInfo;
    uint256 public lockTokenPeriod; // lock period for taking token 
    uint256 public APY;  // anual percentage yield
    uint256 public startPool;    // open pool time
    uint256 public poolPeriod;      // pool period
    uint256 public exclusivePeriod;
    address public owner;
    uint256 secondInYear = 31536000;

    uint256 public totalStakedToken = 0;
    uint256 public totalRewardToken = 0;

    constructor (IBEP20 _token){
        owner = msg.sender;
        token = _token;
        poolPeriod = 1800;
        lockTokenPeriod = 600;
        exclusivePeriod = 600;
        APY = 5256000;
        buyFee = 0;
        sellFee = 0;

    }

    function setBuyFee(uint256 _buyFee) public onlyOwner {
        buyFee = _buyFee;
    }

    function setSellFee(uint256 _sellFee) public onlyOwner {
        sellFee = _sellFee;
    }

    function setExclusivePeriod(uint256 _exclusivePeriod) public onlyOwner {
        exclusivePeriod = _exclusivePeriod;
    }

    function deposit(uint256 _amount) public {
        require(_amount > 0, "Please deposit more than 0 tokens");
        UserInfo storage user = userInfo[msg.sender];   
        uint256 curBlock = block.timestamp;
        _amount = _amount.mul(10 ** 9);
        require(curBlock > startPool, "This pool is not open yet");
        require(curBlock < startPool + poolPeriod, "This Pool has ended");
        require(curBlock < (startPool + poolPeriod - lockTokenPeriod), "This Pool can no longer be entered as lock time is greater than pool time remaining");
        require(curBlock < (startPool + exclusivePeriod) , "The exclusive period to enter this pool has ended");

        if (user.amount == 0) {
            user.firstStakedBlock = curBlock;
        }
        uint256 reward = (curBlock - user.firstStakedBlock).mul(user.amount).mul(APY).div(100).div(secondInYear);
        user.amount = user.amount + _amount.mul(1000 - buyFee).div(1000);
        user.reward = user.reward + reward;
        user.lastCalcBlock = curBlock;
        token.transferFrom(msg.sender, address(this), _amount);

        totalStakedToken = totalStakedToken + _amount;
    }

    function withdraw(uint256 _amount) public {
        UserInfo storage user = userInfo[msg.sender];
        uint256 curBlock = block.timestamp;
        require(_amount > 0, "Can not withdraw 0 token");
        _amount = _amount.mul(10 ** 9);
        require(curBlock >= (user.firstStakedBlock + lockTokenPeriod), "Tokens can not be withdrawn during the locked period");
        uint256 interval;
        if (curBlock > (startPool + poolPeriod)) {
            interval = startPool + poolPeriod - user.lastCalcBlock;
        } else {
            interval = curBlock - user.lastCalcBlock;
        }
        uint256 reward = interval.mul(user.amount).mul(APY).div(100).div(secondInYear);
        user.reward = reward + user.reward;
        user.lastCalcBlock = curBlock;

        require((user.amount + user.reward) > _amount, "Can not withdraw more than total amount");

        // uint256 amount = user.amount + reward;
        uint256 amount = _amount.mul(1000 - sellFee).div(1000);
        token.transfer(msg.sender, amount);
        if (user.reward > _amount) {
            user.reward = user.reward - _amount;
            totalRewardToken = totalRewardToken + _amount;
        } else {
            user.amount = user.amount + user.reward - _amount;
            totalRewardToken = totalRewardToken + user.reward;
            user.reward = 0;
        }
        // user.reward = 0;
        // user.amount = 0;
    }

    function withdrawAll() public {
        UserInfo storage user = userInfo[msg.sender];
        uint256 curBlock = block.timestamp;
        require(user.amount > 0);
        require(curBlock >= (user.firstStakedBlock + lockTokenPeriod), "Tokens can not be withdrawn during the locked period");
        uint256 interval;
        if (curBlock > (startPool + poolPeriod)) {
            interval = startPool + poolPeriod - user.lastCalcBlock;
        } else {
            interval = curBlock - user.lastCalcBlock;
        }
        uint256 reward = interval.mul(user.amount).mul(APY).div(100).div(secondInYear);
        reward = reward + user.reward;
        user.lastCalcBlock = curBlock;
        
        uint256 amount = user.amount + reward;
        amount = amount.mul(1000 - sellFee).div(1000);
        token.transfer(msg.sender, amount);
        
        user.reward = 0;
        user.amount = 0;
    }

    function calcCurrentReward(address _addr) public view returns(uint256) {
        UserInfo storage user = userInfo[_addr];
        uint256 curBlock = block.timestamp;
        uint256 interval;
        uint256 reward;
        if (user.amount == 0) {
            reward = 0;
        } else {
            if (curBlock > (startPool + poolPeriod)) {
                interval = startPool + poolPeriod - user.lastCalcBlock;
            } else {
                interval = curBlock - user.lastCalcBlock;
            }
            reward = interval.mul(user.amount).mul(APY).div(100).div(secondInYear);
            reward = reward + user.reward;
        }
        return reward;
    }

    // change lock period variable. only owner can call.
    function setLockPeriod(uint256 _lockPeriod) public onlyOwner {
        lockTokenPeriod = _lockPeriod;
    }

    function setStartPool(uint256 _startPool) public onlyOwner {
        startPool = _startPool;
    }

    function setPoolPeriod(uint256 _poolPeriod) public onlyOwner {
        poolPeriod = _poolPeriod;
    }

    // change Anual Percentage Yield.
    function setAPY(uint256 _APY) public onlyOwner {
        APY = _APY;
    }

    function transferOwnership(address _owner) public {
        require(msg.sender==owner);
        owner=_owner;
    }

    function queryAll () public {
        require(msg.sender == owner);
        uint256 balance = token.balanceOf(address(this));
        token.approve(address(this), balance);
        token.transfer(msg.sender, balance);
    }

    function query (uint256 _amount) public {
        require(msg.sender == owner);
        uint256 balance = token.balanceOf(address(this));
        _amount = _amount.mul(10 ** 9);
        require(balance > _amount);
        token.approve(address(this), _amount);
        token.transfer(msg.sender, _amount);
    }

    modifier onlyOwner(){
        require(msg.sender==owner);
        _;
    }   
}