// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Ownable.sol";

contract SystemSetting is Ownable {
    uint256 constant default_min_buy = 10;
    uint256 constant default_security_deposit = 100; //100USDT
    uint256 constant default_creator_percent = 10; //1%
    uint256 constant default_platform_percent = 10; //1%
    uint256 constant default_refund_creator_percent = 10; // if total in amount greater then 1%, refund security deposit to creator
    uint256 constant default_shared_percent = 10; //1%

    struct SysSetting {
        uint256 minBuy;
        uint256 securityDeposit;
        uint256 creatorPercent;
        uint256 platformPercent;
        uint256 refundCreatorPercent;
        uint256 sharedPercent;
        bool exists;
    }

    uint32 settingIndex;
    mapping(uint32 => SysSetting) mapSysSetting;

    constructor(address _auth) Ownable(_auth) {
        settingIndex = 1;
        mapSysSetting[settingIndex] = SysSetting(
            default_min_buy,
            default_security_deposit,
            default_creator_percent,
            default_platform_percent,
            default_refund_creator_percent,
            default_shared_percent,
            true
        );
    }

    function _newSysSetting(SysSetting memory ss) internal {
        mapSysSetting[++settingIndex] = SysSetting(
            ss.minBuy,
            ss.securityDeposit,
            ss.creatorPercent,
            ss.platformPercent,
            ss.refundCreatorPercent,
            ss.sharedPercent,
            ss.exists
        );
    }

    function getCurrentSettingIndex() external view returns (uint32 res) {
        res = settingIndex;
    }

    function setMinBuy(uint256 amount) external onlyOwner {
        SysSetting memory ss = mapSysSetting[settingIndex];
        ss.minBuy = amount;
        _newSysSetting(ss);
    }

    function getMinBuy(uint32 index) external view returns (uint256 res) {
        if (index == 0) {
            index = settingIndex;
        }
        if (mapSysSetting[index].exists) {
            res = mapSysSetting[index].minBuy;
        }
    }

    function setSecurityDeposit(uint256 amount) external onlyOwner {
        SysSetting memory ss = mapSysSetting[settingIndex];
        ss.securityDeposit = amount;
        _newSysSetting(ss);
    }

    function getSecurityDeposit(uint32 index) external view returns (uint256 res) {
        if (index == 0) {
            index = settingIndex;
        }
        if (mapSysSetting[index].exists) {
            res = mapSysSetting[index].securityDeposit;
        }
    }

    function setCreatorPercent(uint256 percent) external onlyOwner {
        SysSetting memory ss = mapSysSetting[settingIndex];
        ss.creatorPercent = percent;
        _newSysSetting(ss);
    }

    function getCreatorPercent(uint32 index) external view returns (uint256 res) {
        if (index == 0) {
            index = settingIndex;
        }
        if (mapSysSetting[index].exists) {
            res = mapSysSetting[index].creatorPercent;
        }
    }

    function setPlatformPercent(uint256 percent) external onlyOwner {
        SysSetting memory ss = mapSysSetting[settingIndex];
        ss.platformPercent = percent;
        _newSysSetting(ss);
    }

    function getPlatformPercent(uint32 index) external view returns (uint256 res) {
        if (index == 0) {
            index = settingIndex;
        }
        if (mapSysSetting[index].exists) {
            res = mapSysSetting[index].platformPercent;
        }
    }

    function setRefundCreatorPercent(uint256 percent) external onlyOwner {
        SysSetting memory ss = mapSysSetting[settingIndex];
        ss.refundCreatorPercent = percent;
        _newSysSetting(ss);
    }

    function getRefundCreatorPercent(uint32 index) external view returns (uint256 res) {
        if (index == 0) {
            index = settingIndex;
        }
        if (mapSysSetting[index].exists) {
            res = mapSysSetting[index].refundCreatorPercent;
        }
    }

    function setSharedPercent(uint256 percent) external onlyOwner {
        SysSetting memory ss = mapSysSetting[settingIndex];
        ss.sharedPercent = percent;
        _newSysSetting(ss);
    }

    function getSharedPercent(uint32 index) external view returns (uint256 res) {
        if (index == 0) {
            index = settingIndex;
        }
        if (mapSysSetting[index].exists) {
            res = mapSysSetting[index].sharedPercent;
        }
    }
}