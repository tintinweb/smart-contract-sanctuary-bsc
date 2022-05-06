// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './Durations.sol';
import './IERC20.sol';

/**
  定期存款合约
  1，固定收益率
  2，到期后可以续存
  3，存款会有时间窗口
  4，

 */
contract FiexdDeposit is Durations{

  address public depositToken;

  address public rewardToken;

  //当前年利率（500/5%）
  uint256 public apr;

  uint256 public tradeFeeRate = 0;

  uint256 public protectionPeriod = 7 days;

  uint256 public startBlock;
  uint256 public endBlock;

  uint256 public yitian = 1 days;


  mapping(address => DepositSlip) depositSlips;

  struct DepositSlip{
    address user;
    uint256 balance;
    uint256 startTime;
    uint256 duration;
    uint256 apr;
    uint256 reward;
  }

  event Deposit(address indexed user,uint256 amount,uint256 duration);
  event Extension(address indexed user,uint256 amount,uint256 duration);
  event Withdraw(address indexed user,uint256 amount,uint256 reward);



  constructor(
    address _depositToken,
    address _rewardToken,
    uint256 _apr,
    uint256 _startBlock,
    uint256 _endBlock,
    uint256[] memory _durations
  ){
    require(_depositToken != address(0) && _rewardToken != address(0),'token params error');
    require(_apr > 0,'interestRate params error');
    require(_startBlock > block.number,'startBlock params error');
    require(_endBlock > _startBlock, 'endBlock params error');
    require(_durations.length > 0,'durations params error');

    depositToken = _depositToken;
    rewardToken =_rewardToken;
    apr = _apr;
    startBlock = _startBlock;
    endBlock = _endBlock;
    _add(_durations);
  }



  function deposit(uint256 amount,uint256 duration) external{
    require(startBlock <= block.number && endBlock >= block.number,'deposit not open');
    require(amount > 0,'amount error');
    require(durationContains(duration),'deadline param is error');
    DepositSlip storage depositSlip =  depositSlips[_msgSender()];
    _update(depositSlip);

    depositSlip.balance += amount;
    depositSlip.user = _msgSender();
    depositSlip.apr = apr;
    depositSlip.duration = duration;
    depositSlip.startTime = block.timestamp;
    
    emit Deposit(depositSlip.user,amount,duration);
  }

  function _update(DepositSlip storage depositSlip) internal {
    if(depositSlip.balance > 0){
      //存在之前的质押，计算奖励
      uint256 rewardByDay = (depositSlip.balance * depositSlip.apr)/10000/365;
      uint256 depositDays = (block.timestamp - depositSlip.startTime)/86400;
      depositDays = depositDays > depositSlip.duration ? depositSlip.duration : depositDays;
      uint256 reward = rewardByDay * depositDays;
      depositSlip.reward += reward;
    }
  }

  function extension(uint256 duration) external {
    require(durationContains(duration),'deadline param is error');
    DepositSlip storage depositSlip = depositSlips[_msgSender()];

    //是否到期
    uint256 deadline = (depositSlip.duration * 86400)+depositSlip.startTime;
    require(deadline < block.timestamp,'deposit not due');
    //是否超过保护期
    require((block.timestamp - deadline) < protectionPeriod,'too late');
    //计算奖励
    _update(depositSlip);
    //deposit

    //把奖励加到本金
    depositSlip.balance += depositSlip.reward;
    depositSlip.reward = 0;
    depositSlip.apr = apr;
    depositSlip.duration = duration;
    depositSlip.startTime = block.timestamp;

    emit Extension(depositSlip.user, depositSlip.balance, depositSlip.duration);
  }



  function withdraw() external {
    DepositSlip storage depositSlip = depositSlips[_msgSender()];

    //是否到期
    uint256 deadline = (depositSlip.duration * 86400)+depositSlip.startTime;
    require(deadline < block.timestamp,'deposit not due');
    //是否有余额
    require(depositSlip.balance > 0,'no balance');
    //计算奖励
    _update(depositSlip);

    //计算手续费
    uint256 balance = depositSlip.balance;
    uint256 reward = depositSlip.reward;
    if(reward > 0){
      uint256 tradeFee = depositSlip.reward * tradeFeeRate / 10000;
      reward -= tradeFee;
    }
    
    //修改存款单
    depositSlip.balance = 0;
    depositSlip.reward = 0;
    //提取奖励和本金
    if(depositToken == rewardToken){
      IERC20(depositToken).transfer(depositSlip.user, balance+reward);
    }else{
      IERC20(depositToken).transfer(depositSlip.user, balance);
      IERC20(rewardToken).transfer(depositSlip.user, reward);
    }

    emit Withdraw(depositSlip.user, balance, reward);
  }


  function viewDepositSlip(address user) external view returns(DepositSlip memory){
    return depositSlips[user];
  }











}