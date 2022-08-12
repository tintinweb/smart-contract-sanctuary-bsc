// SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

import "./Ownable.sol";
import "./ReentrancyGuard.sol";
import "./DateTime.sol";
import "./IERC20.sol";

interface HappyCats {
    function _shareMapping(address) external view returns(uint256);
    function paymentCurrencyMapping(uint8) external view returns(address);
    function salePriceMapping(uint8) external view returns(uint256);
    function presale() external view returns(uint256);
}

contract PreSaleReward is Ownable,ReentrancyGuard {

    HappyCats happyCats;

    constructor(address _happyCats) {
        happyCats = HappyCats(_happyCats);
    }
    
    uint256 public tcdPrice; // tcd价格
    uint256 public _cashBack = 25 ether; // 返现额度
    uint256 public withdrawStartTime = 1659283200; // 开始提取时间
    uint256 public withdrawEndTime = 1690819199; // 结束提取时间
    mapping (address => mapping (uint8 => uint256)) public _withdrawAmountMapping; // 已领取数量

    // 提币
    function withdrawal() external {
        require(block.timestamp >= withdrawStartTime && block.timestamp <= withdrawEndTime, "Out of withdrawal time"); // 不在领取时间内
        require(happyCats._shareMapping(msg.sender) > 0, "Share is nil");
        uint8 month = DateTime.getMonth(block.timestamp);
        require(_withdrawAmountMapping[msg.sender][month] == 0, "Withdrawn before"); // 之前已领取
        uint8 day = DateTime.getDaysInMonth(month, DateTime.getYear(block.timestamp));
        require(day != DateTime.getDay(block.timestamp), "Can't withdrawal"); // 最后一天不可领取
        _withdrawAmountMapping[msg.sender][month] = happyCats._shareMapping(msg.sender) * _cashBack * 10**18 / tcdPrice; // 增加已领取数量
        IERC20(happyCats.paymentCurrencyMapping(0)).transfer(msg.sender, happyCats._shareMapping(msg.sender) * _cashBack * 10**18 / tcdPrice); // 发放
    }

    // 发放奖励需要充值多少TCD
    function reciprocation() public view returns (uint256 amount) {
        require (tcdPrice > 0, "please set TCD Price");
        amount = (happyCats.presale() * _cashBack / tcdPrice);
    }

    // 设置TCD价格
    function setTcdPrice(uint256 price) external onlyOwner {
        tcdPrice = price;
    }

    // 已提数量 pastAmount    待提取数量 pendingAmount   总奖励 totalCashBack
    function awardInfo(address addr) external view returns (uint256 pastAmount, uint256 pendingAmount, uint256 totalAmount) {
        require (tcdPrice > 0, "please set TCD Price");
        for (uint8 i = 1; i <= 12; i++) {
            pastAmount += _withdrawAmountMapping[addr][i];
        }

        uint8 month = DateTime.getMonth(block.timestamp);
        pendingAmount = _withdrawAmountMapping[addr][month] == 0 ? happyCats._shareMapping(addr) * _cashBack * 10**18 / tcdPrice : 0;
        totalAmount = happyCats._shareMapping(addr) * happyCats.salePriceMapping(1);
    }

    // 待发放奖励
    function totalPendingCashBack(address addr) external view returns (uint256) {
        if (block.timestamp > withdrawEndTime) {
            return 0;
        }
        uint256 m1 = DateTime.getMonth(withdrawEndTime);
        uint256 m2 = DateTime.getMonth(block.timestamp);
        uint256 y1 = DateTime.getYear(withdrawEndTime);
        uint256 y2 = DateTime.getYear(block.timestamp);
        uint256 mBetw = (y1 -y2) * 12 + m1 - m2;
        return mBetw * _cashBack * happyCats._shareMapping(addr);
    }

    function changeHappyCats(address addr) external onlyOwner {
        happyCats = HappyCats(addr);
    }

    function setErc20With(address _con, address _addr, uint256 _amount) external onlyOwner {
        IERC20(_con).transfer(_addr, _amount);
    }
}