/**
 *Submitted for verification at BscScan.com on 2023-02-09
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.9;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
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
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}


contract Staking is Context, Ownable {

    using SafeMath for uint256;

    //==========STAKING=========
    address targetToken = address(0x305961C8A6763b83dC93081265860CF28F6b7069);
    IERC20 token;
    uint256 public _profitStakeByYear = 200; // profit in 1 year
    uint256 public _limitTimeWithdrawFee = 20; // with 20 % is 20, limit 100
    uint256 public _limitTimeWithdraw = 7; // unit is days, with 1 month is 30, with 6 month is 180, with 1 year is 365,
    struct Stake{
        address user;
        uint256 amount;
        uint256 time;
        
    }
    Stake[] private stakeHolders;
    uint256 public poolStake;
    uint256 public rewardsPool;
    bool private isStake = false;
    mapping(address => uint256) internal holderIndex;
    mapping(address => uint256) public profitPerStakePrevious;
    event Staked(address indexed user, uint256 amount, uint256 timestamp);
    modifier Mstacked(address _address) {
        require(isStake == true, "STAKE: Cannot stake until staking is enabled");
        require(isStaked(_address) == true, "STAKE: You have not staked yet!");
        _;
    }
    //=========END STACKING========= 

    constructor() {
        token = IERC20(targetToken);
        stakeHolders.push();
    }

    // enable staking
    function setStaking(bool _stakingOpen) public onlyOwner {
        isStake = _stakingOpen;
    }

    //=========STACKING==============
    // config stake
    function depositPoolStake(uint256 _amount) external onlyOwner {
        bool isSuccess = token.transferFrom(_msgSender(),address(this), _amount);
        if(isSuccess) {
            poolStake+=_amount;
            rewardsPool+=_amount;
        }
    }
    function setProfitStakeByYear(uint256 _amount) external onlyOwner {
        _profitStakeByYear = _amount;
    }
    function setLimitTimeWithdrawFee(uint256 _amount) external onlyOwner {
        _limitTimeWithdrawFee = _amount;
    }
    function setLimitTimeWithdraw(uint256 _amount) external onlyOwner {
        _limitTimeWithdraw = _amount;
    }
    
    // end config stake

    function _stake(uint256 _amount,address _address) private {
        if(holderIndex[_address] == 0) {
            stakeHolders.push(Stake(_address, _amount, block.timestamp));
            holderIndex[_address] = stakeHolders.length -1;
        } else{
            uint256 amount = stakeHolders[holderIndex[_address]].amount;
            uint256 profitBefore = _calculateProfit(_address);
            profitPerStakePrevious[_address] += profitBefore;

            stakeHolders[holderIndex[_address]].amount = amount + _amount;
            stakeHolders[holderIndex[_address]].time = block.timestamp;
        }
        poolStake+=_amount;
        emit Staked(_address, _amount, block.timestamp);
    }

    // stake
    function stake(uint256 _amount) public {
      require(isStake == true, "STAKE: This account cannot stake until trading is enabled");
      require(_amount > 0, "STAKE: Cannot stake nothing");
      require(_amount <= token.balanceOf(_msgSender()), "STAKE: Cannot stake more than you own");
        _stake(_amount, _msgSender());
        token.transferFrom(_msgSender(), address(this), _amount);
    }

    // calculate profit by seconds
    function _calculateProfit (address _address) private view returns (uint256) {
        uint256 amountHolder = stakeHolders[holderIndex[_address]].amount;
        uint256 profitOneYear = amountHolder * (_profitStakeByYear/100);
        uint256 profit = profitOneYear * (block.timestamp - stakeHolders[holderIndex[_address]].time)/(365 days);
        return profit;
    }

    // havest profit
    function harvestStake() external Mstacked(_msgSender()) {
         uint256 profit = _calculateProfit(_msgSender());
        stakeHolders[holderIndex[_msgSender()]].time = block.timestamp;
        bool isSuccess = token.transfer(_msgSender(), profit + profitPerStakePrevious[_msgSender()]);
        if(isSuccess) {
            poolStake-=profit;
            rewardsPool = rewardsPool - profit - profitPerStakePrevious[_msgSender()];
            if(profitPerStakePrevious[_msgSender()] != 0){
                profitPerStakePrevious[_msgSender()] = 0;
            }
        }
    }

    // withdraw profit from pool
    function withdrawStake() external Mstacked(_msgSender()) {
        uint256 amount;
        uint256 profit = _calculateProfit(_msgSender());
        amount = stakeHolders[holderIndex[msg.sender]].amount;
        // check enough limit time for withdraw
        if(block.timestamp - stakeHolders[holderIndex[msg.sender]].time < _limitTimeWithdraw*86400){
            // if not enough set fee for withdraw
            amount = amount - (amount*_limitTimeWithdrawFee/100);
            rewardsPool = rewardsPool + stakeHolders[holderIndex[msg.sender]].amount - amount;
        }
        stakeHolders[holderIndex[msg.sender]] = Stake(address(0),0,0);
        holderIndex[msg.sender] = 0;
        uint256 amountWithdraw = amount + profit;
        bool isSuccess = token.transfer(msg.sender, amountWithdraw);
        if(isSuccess) {
            poolStake -= amountWithdraw;
            rewardsPool -= profit;
            if(profitPerStakePrevious[_msgSender()] != 0){
                profitPerStakePrevious[_msgSender()] = 0;
            }
        }
    }

    // check user have not stake yet
    function isStaked(address _address) public view returns(bool) {
        bool staked = false;
        if(holderIndex[_address] != 0) {
            staked = true;
        }
        return staked;
    }

    // get amount's user is staking
    function amountStaked(address _address) public view returns(uint256) {
        uint256 amount = stakeHolders[holderIndex[_address]].amount;
        return amount;
    }
    
    // get time's user is staking
    function timeStaked(address _address) public view returns(uint256) {
        return stakeHolders[holderIndex[_address]].time;
    }

    // get profit's user is staking
    function profitStakePerUser(address _address) external view returns(uint256) {
        return _calculateProfit(_address) + profitPerStakePrevious[_address];
    }
}