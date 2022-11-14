/**
 *Submitted for verification at BscScan.com on 2022-11-13
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

contract FomoSnapshot {
    address private _owner;
    address public oToken;

    mapping(address => bool) public exclude;

    mapping(uint256 => address) public snapshots;
    mapping(uint256 => bool) public claimeds;
    uint256 [] public rewards;
    uint256 [] public rewardIds;

    uint256 public startTime; // 00:00:00
    uint256 public endTime;
    uint256 public dailyStartTime;
    uint256 public dailyEndTime;
    uint256 public reverseDays = 30;
    uint256 public amountThreshold;

    constructor(address creator) {
        _owner = creator;
        oToken = msg.sender;
    }

    function blockHeight() public view returns (uint256) {
        if (startTime == 0 || startTime > block.timestamp) return 0;
        uint256 currentHeight = (block.timestamp - startTime) / 1 days;
        return currentHeight;
    }

    function lastSnapshot(address account, uint256 amount) external onlyPerformer  {
        if (exclude[account]) return;
        if (amount < amountThreshold) return;
        if (checkEffectiveTime()) snapshots[blockHeight()] = account;
    }

    function checkEffectiveTime() public returns (bool) {
        if (block.timestamp < startTime || block.timestamp > endTime)
            return false; 
        uint256 todayZeroTime = startTime + blockHeight() * (1 days);
        uint256 todayStartTime = todayZeroTime + dailyStartTime;
        uint256 todayEndTime = todayZeroTime + dailyEndTime;
        if (block.timestamp >= todayStartTime && block.timestamp <= todayEndTime) 
            return true;
        return false;
    }

    function removeToken() external onlyOwner {
        uint256 balance = IERC20(oToken).balanceOf(address(this));
        IERC20(oToken).transfer(address(msg.sender), balance);
    }

    function setExclude(address account, bool value) external onlyOwner {
        exclude[account] = value;
    }

    function queryReward() public view returns (uint256) {
        if (rewards.length == 0) return 0;
        uint256 height = blockHeight();
        uint256 totalReward = 0;
        uint256 j = 0;
        for (uint i=height; i>0; i--) {
            if (snapshots[i] == msg.sender && claimeds[i] == false && checkEndStatus(i)) {
                totalReward = totalReward + findReward(i);
            }
            if (++j > reverseDays) break;
        }
        if (snapshots[0] == msg.sender && claimeds[0] == false && checkEndStatus(0)) {
            totalReward = totalReward + findReward(0);
        }
        return totalReward;
    }

    function checkEndStatus(uint256 height) public view returns (bool) {
        uint256 zeroTimeForHeight = startTime + height * (1 days);
        uint256 endTimeForHeight = zeroTimeForHeight + dailyEndTime;
        if (block.timestamp >= endTimeForHeight)
            return true;
        return false;
    }

    function findReward(uint256 index) private view returns (uint256) {
        for (uint i=rewardIds.length; i>0; i--) {
            if (index >= rewardIds[i-1]) {
                return rewards[i-1];
            }
        }
        return 0;
    }

    function claimReward() external {
        uint256 reward = queryReward();
        require(reward > 0, "No rewards");
        IERC20(oToken).transfer(address(msg.sender), reward);
        uint256 height = blockHeight();
        uint256 j = 0;
        for (uint i=height; i>0; i--) {
            if (snapshots[i] == msg.sender && claimeds[i] == false && checkEndStatus(i)) {
                claimeds[i] = true;
            }
            if (++j > reverseDays) break;
        }
        if (snapshots[0] == msg.sender && claimeds[0] == false && checkEndStatus(0)) {
            claimeds[0] = true;
        }
    }

    function setTimeParam(uint256 startValue, uint256 endValue, uint256 dailyStart, uint256 dailyEnd) external onlyOwner {
        if (startValue > 0 && startTime == 0) startTime = startValue;
        if (endValue > 0) endTime = endValue;
        if (dailyStart > 0) dailyStartTime = dailyStart;
        if (dailyEnd > 0) dailyEndTime = dailyEnd;
    }

    function setRewardParam(uint256 reward) external onlyOwner {
        uint256 size = rewardIds.length;
        if (size > 0 && rewardIds[size-1] == blockHeight()) {
            rewards[size-1] = reward;
            return;
        }
        rewardIds.push(blockHeight());
        rewards.push(reward);
    }

    function setReverseDays(uint256 value) external onlyOwner {
        reverseDays = value;
    }

    function setAmountThreshold(uint256 amount) external onlyOwner {
        amountThreshold = amount;
    }

    modifier onlyPerformer() {
        require(oToken == msg.sender, "caller is not the token contract");
        _;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function performer() public view returns (address) {
        return oToken;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
}