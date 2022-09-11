// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "./Ownable.sol";
import "./IERC20.sol";
import "./SafeMath.sol";

contract TCDLock is Ownable {
    using SafeMath for uint256;
    IERC20 tcd = IERC20(address(0xF916Df050C140086BC6B8de0803A0BD45F0e136F));
    uint256[] depositTime;                          // 存入时间
    mapping (uint256 => uint256) depositMapping;    // key 存入时间    value 存入数量
    mapping (uint256 => uint256) withdrawMapping;   // key 存入时间    value 已提取天数
    uint256 depositQuantity;                        // 存入总量
    uint256 withdrawQuantity;                       // 提取总量

    function deposit (uint256 amount) external onlyOwner {
        uint256 today = block.timestamp.div(86400);
        depositTime.push(today);
        depositMapping[today] += amount;
        tcd.transferFrom(msg.sender, address(this), amount);
    }

    function withdraw () external onlyOwner {
        uint256 todayWithdraw;
        uint256[] memory _depositTime = depositTime;
        uint256 today = block.timestamp.div(86400);
        for (uint256 i = 0; i < _depositTime.length; i++) {
            uint256 withdrawNum = today - _depositTime[i];
            if (withdrawMapping[_depositTime[i]] >= 100) {
                depositTime[i] = depositTime[depositTime.length - 1];
                depositTime.pop();
                continue;
            }

            withdrawMapping[_depositTime[i]] += withdrawNum;
            todayWithdraw += withdrawNum * (depositMapping[_depositTime[i]] / 100);
        }
        tcd.transfer(msg.sender, todayWithdraw);
    }

    uint256 public tcdLockAmount;       // 锁仓余额
    mapping (uint256 => uint256) todayWithdrawMapping;    // 当日提取 

    function sycnAmount () external onlyOwner {
        tcdLockAmount = tcd.balanceOf(address(this));
    }

    function withdraw1 () external onlyOwner {
        uint256 today = block.timestamp.div(86400);
        require(todayWithdrawMapping[today] == 0);
        uint256 withdrawAmount = tcdLockAmount / 100;
        require(tcd.balanceOf(address(this)) > withdrawAmount);
        tcd.transfer(msg.sender, withdrawAmount);
        todayWithdrawMapping[today] = withdrawAmount;
    }

    function setToken (address addr) external onlyOwner {
        tcd = IERC20(addr);
    }
}