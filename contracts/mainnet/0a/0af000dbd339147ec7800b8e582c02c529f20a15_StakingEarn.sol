// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./SafeERC20.sol";
import "./IERC20.sol";

contract StakingEarn {
  struct UserInfo{
    uint256 share;
    uint256 totalEnterStaking;
    uint256 totalLeaveStaking;
    uint256 lastStakingTime;
  }
  IERC20 public token;
  address private owner;
  uint256 public totalStaking;
  uint256 public totalShare;
  uint256 public PERCENT_SHARE = 1e6;
  uint256 public beforRelease;
  uint256 public lastRelease;
  uint256 public totalRelease;
  uint256 public lastReleaseTime;
  mapping(address => UserInfo) public users;

  event Release(uint256 time, uint256 amount);

  constructor(address token_, uint256 lastReleaseTime_){
    token = IERC20(token_);
    owner = msg.sender;
    lastReleaseTime = lastReleaseTime_;
  }
  function back(address token_, uint256 amount) external{
    require(msg.sender == owner, "only owner");
    require(token_ != address(token));
    if(token_ == address(0))
      payable(owner).transfer(amount);
    else
      IERC20(token_).transfer(owner, amount);
  }
  function enterStaking(uint256 amount_) external {
    require(amount_ > 0, "the amount can not be zero");
    UserInfo storage user = users[msg.sender];
    SafeERC20.safeTransferFrom(token, msg.sender, address(this), amount_);
    uint256 share;
    if(totalStaking == 0){
      share = amount_ * PERCENT_SHARE;
    }else{
      share = amount_ * totalShare / totalStaking;
    }
    totalStaking += amount_;
    totalShare += share;
    user.share += share;
    user.totalEnterStaking += amount_;
    user.lastStakingTime = block.timestamp;
  }
  function leaveStaking(uint256 share) external {
    UserInfo storage user = users[msg.sender];
    require(user.share >= share, "not enough share");
    uint256 amount = (share * totalStaking) / totalShare;
    totalStaking -= amount;
    user.share -= share;
    totalShare -= share;
    if(block.timestamp - user.lastStakingTime < 3 days)
      amount = amount - (amount / 1000);
    user.totalLeaveStaking += amount;
    SafeERC20.safeTransfer(token, msg.sender, amount);
  }
  function release() external {
    require(block.timestamp - lastReleaseTime > 1 days, "time has not come");
    uint256 balance = getReleaseToken();
    beforRelease = totalStaking;
    totalStaking += balance;
    lastRelease = balance;
    totalRelease += balance;
    lastReleaseTime += 1 days;
    emit Release(block.timestamp, balance);
  }
  function getReleaseToken() public view returns(uint256){
    uint256 balance = token.balanceOf(address(this));
    if(balance < totalStaking)
      return 0;
    return (balance - totalStaking) / 20;
  }
  function userToken(address account) external view returns(
    uint256 enter, uint256 leave, uint256 last, uint256 share,
    uint256 amount, uint256 nextReleaseAmount){
    UserInfo memory user = users[account];
    enter = user.totalEnterStaking;
    leave = user.totalLeaveStaking;
    last = user.lastStakingTime;
    share = user.share;
    amount = (user.share * totalStaking) / totalShare;
    nextReleaseAmount = (user.share * (totalStaking + getReleaseToken())) / totalShare;
  }
}