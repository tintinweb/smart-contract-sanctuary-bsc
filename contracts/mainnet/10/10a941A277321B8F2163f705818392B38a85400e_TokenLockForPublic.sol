// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./SafeERC20.sol";
import "./Ownable.sol";

contract TokenLockForPublic is Ownable {
    using SafeERC20 for IERC20;

    // ERC20 basic token contract being held
    IERC20 public immutable token;

    // 锁仓支付地址
    address public payer;

    // 首次释放时间
    uint256 public startDate;

    // 首次释放百分比 2%
    uint256 public immutable startPercent = 20;

    // 线性释放时间
    uint256 public releaseDate;

    // 首次解锁期限
    uint256 public immutable firstTerm = 15 * 24 * 3600;

    // 释放间隔 30天
    uint256 public immutable releaseInterval = 30 * 24 * 3600;

    // 可释放千分比 60,60,60,100,100,100,42,42,42,42,42,42,42,42,42,36
    uint256[] public releasePercents = [80, 140, 200, 300, 400, 500, 542, 584, 626, 668, 710, 752, 794, 836, 878, 920, 964, 1000];

    // 用户列表
    address[] public allUsers;

    // 锁仓数量
    mapping (address => uint256) public lockedAmounts;

    // 释放数量
    mapping (address => uint256) public releasedAmount;

    constructor(address _token) {
        token = IERC20(_token);
    }

    function activate(address _payer, uint256 _openDate) external onlyOwner {
        require(0 == startDate || block.timestamp <= _openDate, "Lock time exceed");
        payer = _payer;
        startDate = _openDate + firstTerm;
        releaseDate = startDate + releaseInterval;
    }

    function lock(address user, uint amount) external onlyOwner {
        require(0 == startDate || block.timestamp <= startDate, "Lock time exceed");
        if (lockedAmounts[user] == 0) {
            allUsers.push(user);
        }

        lockedAmounts[user] += amount;
        require(token.balanceOf(payer) >= amount, "Insufficient balance for lock");
        token.transferFrom(payer, address(this), amount);
    }

    function lockBatch(address[] memory addresses, uint[] memory amounts) external onlyOwner {
        require(0 == startDate || block.timestamp <= startDate, "Lock time exceed");
        require(addresses.length > 0 && addresses.length == amounts.length, "Mismatch array length");
        uint amountTotal = 0;
        for (uint i=0; i<addresses.length; i++) {
            amountTotal += amounts[i];
            if (lockedAmounts[addresses[i]] == 0) {
                allUsers.push(addresses[i]);
            }
            lockedAmounts[addresses[i]] += amounts[i];
        }

        require(token.balanceOf(payer) >= amountTotal, "Insufficient balance for lock");
        token.transferFrom(payer, address(this), amountTotal);
    }

    function claim() external {
        this.claimFor(msg.sender);
    }

    function claimFor(address user) external {
        uint availableForClaim = this.available(user);
        require(availableForClaim > 0, "No available token to release");
        require(token.balanceOf(address(this)) >= availableForClaim, "Insufficient balance for claim");
        token.transfer(user, availableForClaim);
        releasedAmount[user] += availableForClaim;
    }

    function timestamp() external view returns (uint256) {
        return block.timestamp;
    }

    function available(address user) external view returns (uint256) {
        // 没到释放时间
        if (block.timestamp < startDate) {
            return 0;
        }

        // 初次释放数量
        uint lockedAmount = lockedAmounts[user];
        uint firstAmount = lockedAmount * startPercent / 1000;
        if (block.timestamp < releaseDate) {
            return firstAmount - releasedAmount[user];
        }

        // 线性释放数量
        uint releasedTimes = ((block.timestamp - releaseDate) / releaseInterval) + 1;
        releasedTimes = releasedTimes >= releasePercents.length ? releasePercents.length : releasedTimes;
        uint releasePercent = releasePercents[releasedTimes - 1];

        return ((lockedAmount * releasePercent) / 1000) - releasedAmount[user];
    }
}