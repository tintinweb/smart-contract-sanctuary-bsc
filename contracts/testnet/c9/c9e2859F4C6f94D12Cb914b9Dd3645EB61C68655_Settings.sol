// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Ownable.sol";

contract Settings is Ownable {
    uint256 constant default_min_buy = 100;
    uint256 constant default_security_deposit = 10;
    uint256 constant default_creator_percent = 5; //5%
    uint256 constant default_platform_percent = 2; //2%
    uint256 constant default_refund_creator_percent = 50;//50%

    uint256 private minBuy;
    uint256 private securityDeposit;
    uint256 private creatorPercent;
    uint256 private platformPercent;
    uint256 private refundCreatorPercent;

    constructor() {
        owner = msg.sender;
        minBuy = default_min_buy;
        securityDeposit = default_security_deposit;
        creatorPercent = default_creator_percent;
        platformPercent = default_platform_percent;
        refundCreatorPercent = default_refund_creator_percent;
    }

    function setMinBuy(uint256 amount) external onlyOwner {
        minBuy = amount;
    }

    function getMinBuy() external view returns (uint256 res) {
        res = minBuy;
    }

    function setSecurityDeposit(uint256 amount) external onlyOwner {
        securityDeposit = amount;
    }

    function getSecurityDeposit() external view returns (uint256 res) {
        res = securityDeposit;
    }

    function setCreatorPercent(uint256 amount) external onlyOwner {
        creatorPercent = amount;
    }

    function getCreatorPercent() external view returns (uint256 res) {
        res = creatorPercent;
    }

    function setPlatformPercent(uint256 amount) external onlyOwner {
        platformPercent = amount;
    }

    function getPlatformPercent() external view returns (uint256 res) {
        res = platformPercent;
    }

    function setRefundCreatorPercent(uint256 amount) external onlyOwner {
        refundCreatorPercent = amount;
    }

     function getRefundCreatorPercent() external view returns (uint256 res) {
         res = refundCreatorPercent;
     }
}