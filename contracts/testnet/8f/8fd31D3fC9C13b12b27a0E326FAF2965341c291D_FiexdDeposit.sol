// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './Durations.sol';
import './IERC20.sol';
import './INeptune.sol';

/**
  定期存款合约
  1，固定收益率
  2，到期后可以续存
  3，存款会有时间窗口
  4，提取收益将收取一定的手续费

 */
contract FiexdDeposit is Durations{

  address public depositToken;

  //当前年利率（50000/500%）
  uint256 public apr;

  uint256 public tradeFeeRate = 0;

  uint256 public protectionPeriod = 7 days;

  uint256 public startBlock;
  uint256 public endBlock;

  uint256 public yitian = 1 days;

  uint256 public totalDeposit;


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
    uint256 _apr,
    uint256 _startBlock,
    uint256 _endBlock,
    uint256[] memory _durations
  ){
    require(_depositToken != address(0),'token params error');
    require(_apr > 0,'interestRate params error');
    require(_startBlock > block.number,'startBlock params error');
    require(_endBlock > _startBlock, 'endBlock params error');
    require(_durations.length > 0,'durations params error');

    depositToken = _depositToken;
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

    IERC20(depositToken).transferFrom(_msgSender(), address(this), amount);

    depositSlip.balance += amount;
    depositSlip.user = _msgSender();
    depositSlip.apr = apr;
    depositSlip.duration = duration;
    depositSlip.startTime = block.timestamp;
    totalDeposit += amount;
    
    emit Deposit(depositSlip.user,amount,duration);
  }

  function _update(DepositSlip storage depositSlip) internal {
    if(depositSlip.balance > 0){
      depositSlip.reward += _getReward(depositSlip);
    }
  }

  function _getReward(DepositSlip memory depositSlip) internal view returns (uint256 reward) {
    reward = 0;
    if(depositSlip.balance > 0){
      //存在之前的质押，计算奖励
      uint256 rewardByDay = (depositSlip.balance * depositSlip.apr)/10000/365;
      uint256 depositDays = (block.timestamp - depositSlip.startTime)/yitian;
      depositDays = depositDays > depositSlip.duration ? depositSlip.duration : depositDays;
      reward = rewardByDay * depositDays;
    }
  }

  function extension(uint256 duration) external {
    require(durationContains(duration),'deadline param is error');
    DepositSlip storage depositSlip = depositSlips[_msgSender()];

    //是否到期
    uint256 deadline = (depositSlip.duration * yitian)+depositSlip.startTime;
    require(deadline < block.timestamp,'deposit not due');
    //是否超过保护期
    require((block.timestamp - deadline) < protectionPeriod,'too late');
    //计算奖励
    _update(depositSlip);
    //deposit

    //把奖励加到本金
    INeptune(depositToken).mint(address(this), depositSlip.reward);
    totalDeposit +=depositSlip.reward;
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
    uint256 deadline = (depositSlip.duration * yitian)+depositSlip.startTime;
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
    totalDeposit -= balance;
    //提取奖励和本金
    INeptune(depositToken).mint(depositSlip.user, reward);
    IERC20(depositToken).transfer(depositSlip.user, balance);
    emit Withdraw(depositSlip.user, balance, reward);
  }


  function viewDepositSlip(address user) external view returns(DepositSlip memory){
    DepositSlip memory depositSlip = depositSlips[user];
    depositSlip.reward += _getReward(depositSlip);

    return depositSlip;
  }


  function updateApr(uint256 _apr) external onlyOwner{
    require(_apr != apr,'no change');
    apr = _apr;
  }

  function updateTradeFeeRate(uint256 _tradeFeeRate) external onlyOwner{
    require(_tradeFeeRate != tradeFeeRate,'no change');
    tradeFeeRate = _tradeFeeRate;
  }

  function updateProtectionPeriod(uint256 _protectionPeriod)external onlyOwner{
    require(_protectionPeriod != protectionPeriod,'no change');
    protectionPeriod = _protectionPeriod;
  }

  function updateDepositDate(uint256 _startBlock,uint256 _endBlock)external onlyOwner{
    require(_startBlock > block.number && _endBlock > _startBlock,'date is error');
    startBlock = _startBlock;
    endBlock = _endBlock;
  }

  function updateYiTian(uint256 _yitian) external onlyOwner{
    require(_yitian != yitian,'no change');
    yitian = _yitian;
  }












}