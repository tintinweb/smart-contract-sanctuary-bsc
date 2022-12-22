// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./SafeERC20.sol";
import "./Ownable.sol";

contract TokenLockForPrivate is Ownable {
    using SafeERC20 for IERC20;

    // ERC20 basic token contract being held
    IERC20 public immutable token;

    // 锁仓支付地址
    address public payer;

    // 解锁收款地址
    address public recipient;

    // 首次释放时间
    uint256 public startDate;

    // 首次释放百分比
    uint256 public startPercent = 30;

    // 线性释放时间
    uint256 public releaseDate;

    // 首次解锁期限
    uint256 public immutable firstTerm = 10 * 24 * 3600;

    // 释放间隔 90天
    uint256 public immutable releaseInterval = 90 * 24 * 3600;

    // 释放千分比 100, 174, 174, 174, 174, 174
    uint256[] public releasePercents = [130, 304, 478, 652, 826, 1000];

    // 锁仓数量
    uint256 public lockedAmount;

    // 释放数量
    uint256 public releasedAmount;

    constructor(address _token) {
        token = IERC20(_token);
    }

    function activate(address _payer, address _recipient, uint256 _openDate) external onlyOwner {
        require(0 == startDate, "activate already");
        payer = _payer;
        recipient = _recipient;
        startDate = _openDate + firstTerm;
        releaseDate = startDate + releaseInterval;
    }

    function lock(uint amount) external onlyOwner {
        require(0 == startDate || block.timestamp <= startDate, "Lock time exceed");
        require(token.balanceOf(payer) >= amount, "Insufficient balance for lock");
        lockedAmount += amount;
        token.transferFrom(payer, address(this), amount);
    }

    function claim() external {
        uint availableForClaim = this.available();
        require(availableForClaim > 0, "No available token to release");
        require(token.balanceOf(address(this)) >= availableForClaim, "Insufficient balance for claim");
        token.transfer(recipient, availableForClaim);
        releasedAmount += availableForClaim;
    }

    function available() external view returns (uint256) {
        // 没到释放时间
        if (block.timestamp < startDate) {
            return 0;
        }

        // 首次释放时间
        uint firstAmount = lockedAmount * startPercent / 1000;
        if (block.timestamp < releaseDate) {
            return firstAmount - releasedAmount;
        }

        // 释放次数
        uint releasedTimes = ((block.timestamp - releaseDate) / releaseInterval) + 1;
        releasedTimes = releasedTimes >= releasePercents.length ? releasePercents.length : releasedTimes;
        uint releasePercent = releasePercents[releasedTimes - 1];

        return ((lockedAmount * releasePercent) / 1000) - releasedAmount;
    }
}