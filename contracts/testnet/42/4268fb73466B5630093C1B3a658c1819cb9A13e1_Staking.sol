/**
 *Submitted for verification at BscScan.com on 2022-10-10
*/

/**
 *Submitted for verification at Etherscan.io on 2022-09-22
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract Staking{
    IERC20 public governanceToken;
    IERC20 public milEth;
    uint256 constant MIN_DEPOSIT = 45001*10**18;
    address public feeReceiver = address(0x00);

    struct User{
         uint256 stakedTokens;
         uint256 stakedTime;
         uint256 rewardTokens;
    }

    uint256 public totalStaked;
    mapping(address=>uint256) public prevReward;
    mapping(address=>User) public users;
    
    constructor( IERC20 _milEth,IERC20 _governanceToken, address _feeReceiver) {
        governanceToken = _governanceToken;
        milEth = _milEth;
        feeReceiver = _feeReceiver;
    }
    
    function rewardCalculation(address _user) public view returns(uint256){
        uint256 point = ((block.timestamp - users[_user].stakedTime)/60 seconds)*10**18;
        uint256 totalReward= ((7*point)/10000)*users[_user].stakedTokens;
        return (totalReward/10**18)-users[_user].rewardTokens;
    }

    function stake(uint256 _numberOfTokens) public {
        require(users[msg.sender].stakedTokens <= 0, "You need to unstake first!");
        require(_numberOfTokens >= MIN_DEPOSIT, "You must have at least 45001 $MilEth!");
        require(milEth.balanceOf(msg.sender) >= _numberOfTokens,"You don't have enough tokens to stake");
        uint256 untaxedAmount = _numberOfTokens - 10**18;
        uint256 taxedAmount = (untaxedAmount*5)/1000;
        uint256 amountToDeposit = untaxedAmount-taxedAmount;
        require(governanceToken.balanceOf(address(this)) >= amountToDeposit, "System is out of goverenance tokens!");
        governanceToken.transfer(msg.sender, amountToDeposit);
        milEth.transferFrom(msg.sender, address(this), _numberOfTokens);
        milEth.transfer(feeReceiver, taxedAmount+1);
        users[msg.sender].stakedTime = block.timestamp;
        users[msg.sender].stakedTokens += amountToDeposit;
        totalStaked += _numberOfTokens-10**18;
    }
    
    function withdraw() public{
        uint256 rewardOfUser=rewardCalculation(msg.sender);
        users[msg.sender].rewardTokens += rewardOfUser+prevReward[msg.sender];
        require(users[msg.sender].rewardTokens > 0, "You don't have tokens to withdraw!");
        milEth.transfer(msg.sender, users[msg.sender].rewardTokens);
        prevReward[msg.sender]=0;
    }
    
    function unstake()public{
        require(users[msg.sender].stakedTokens > 0,"You don't have tokens to unstake!");
        require(governanceToken.transferFrom(msg.sender, address(this), users[msg.sender].stakedTokens), "You need to refund governance tokens!");
        uint256 taxedAmount = (users[msg.sender].stakedTokens*15)/1000;
        milEth.transfer(feeReceiver,taxedAmount);
        milEth.transfer(msg.sender,users[msg.sender].stakedTokens-taxedAmount);
        prevReward[msg.sender]+=rewardCalculation(msg.sender);
        users[msg.sender].stakedTokens = 0;
    }
}