// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Ownable.sol";

contract SystemSetting is Ownable {

    uint256 constant default_bureau_lose_reward         = 100;  //10%
    uint256 constant default_bureau_shared_bingo_reward = 100;  //10%
    uint256 constant default_bureau_shared_empty_reward = 10;   //1%

    uint256 constant default_mature_time = 604800; //604800seconds = 7 days
    uint256 constant default_min_dev_custom_amount = 100 * 10**18;//100MUT
    uint256 constant default_cycle_yields = 50; // 8%
    uint256 constant default_sys_fund = 15; // 1.5%
    uint256 constant default_charity = 5; // 0.5%
    //------------sum-------------------= 300    // 30%

    uint256 constant default_price_tolerance = 5; // 0.5%
    uint256 constant default_landbureau_opener_reward = 50; //5%

    uint256 constant max_sys_fund_percent = 50; // 5%
    uint256 constant fixed_time_length_forgotten = 2592000; //30days
    //default land price

    //mapping of system settings
    uint32 settingIndex;
    mapping(uint32 => SysSetting) mapSysSetting;

    struct SysSetting {
        uint256 loseRefund;         //10%
        uint256 sharedBingoReward;  //10%
        uint256 sharedEmptyReward;  //1%
        uint matureTime;
        uint256 cycleYieldsPercent;
        uint256 minDevelopCustomAmount;
        uint256 sysFundPercent;
        uint256 charityPercent;
        uint256 maxSysFundPercent;
        uint256 fixedTimeForgotten;
        uint256[] sharedPercent;
        uint256 sharedLayer;
        uint256 priceTolerance;
        uint256 openerReward;
        bool exists;
    }

    constructor(address _auth) Ownable(_auth) {

        settingIndex = 1;
        uint256[] memory _defaulSharedPercent = new uint256[](4);
        _defaulSharedPercent[0] = 40;
        _defaulSharedPercent[1] = 30;
        _defaulSharedPercent[2] = 10;
        _defaulSharedPercent[3] = 5;
        mapSysSetting[settingIndex] = SysSetting(
            default_bureau_lose_reward,
            default_bureau_shared_bingo_reward,
            default_bureau_shared_empty_reward,
            default_mature_time,
            default_cycle_yields,
            default_min_dev_custom_amount,
            default_sys_fund,
            default_charity,
            max_sys_fund_percent,
            fixed_time_length_forgotten,
            _defaulSharedPercent,
            _defaulSharedPercent.length,
            default_price_tolerance,
            default_landbureau_opener_reward,
            true
        );
    }

    function _newSysSetting(SysSetting memory ss) internal {
        mapSysSetting[++settingIndex] = SysSetting(
            ss.loseRefund,
            ss.sharedBingoReward,
            ss.sharedEmptyReward,
            ss.matureTime,
            ss.cycleYieldsPercent,
            ss.minDevelopCustomAmount,
            ss.sysFundPercent,
            ss.charityPercent,
            ss.maxSysFundPercent,
            ss.fixedTimeForgotten,
            ss.sharedPercent,
            ss.sharedLayer,
            ss.priceTolerance,
            ss.openerReward,
            ss.exists
        );
    }

    function getCurrentSettingIndex() external view returns (uint32 res) {
        res = settingIndex;
    }

    function getStaticSetting(uint32 index)
        external
        view
        returns (
            bool res,
            uint256 _maxSysFundPercent,
            uint256 _fixedTimeForgotten
        )
    {
        if (mapSysSetting[index].exists) {
            res = true;
            _maxSysFundPercent = mapSysSetting[index].maxSysFundPercent;
            _fixedTimeForgotten = mapSysSetting[index].fixedTimeForgotten;
        }
    }

    function getBureauSetting(uint32 index) external view returns 
    (
        uint256 _loseRefund,
        uint256 _sharedBingoReward,
        uint256 _sharedEmptyReward
    )
    {
        if (index == 0) {
            index = settingIndex;
        }
        if (mapSysSetting[index].exists) {
            _loseRefund = mapSysSetting[index].loseRefund;
            _sharedBingoReward = mapSysSetting[index].sharedBingoReward;
            _sharedEmptyReward = mapSysSetting[index].sharedEmptyReward;
        }
    }

    function getSysSetting(uint32 index)
        external
        view
        returns (
            uint _matureTime,
            uint256 _cycleYieldsPercent,
            uint256 _minDevelopCustomAmount,
            uint256 _sysFundPercent,
            uint256 _charityPercent,
            uint256[] memory _sharedPercent
        )
    {
        if (index == 0) {
            index = settingIndex;
        }
        if (mapSysSetting[index].exists) {
            _matureTime = mapSysSetting[index].matureTime;
            _cycleYieldsPercent = mapSysSetting[index].cycleYieldsPercent;
            _minDevelopCustomAmount = mapSysSetting[index]
                .minDevelopCustomAmount;
            _sysFundPercent = mapSysSetting[index].sysFundPercent;
            _charityPercent = mapSysSetting[index].charityPercent;
            _sharedPercent = mapSysSetting[index].sharedPercent;
        }
    }

    function getMinDevelopCustomerAmount(uint32 index)
        external
        view
        returns (uint256 amount)
    {
        if (index == 0) {
            index = settingIndex;
        }
        if (mapSysSetting[index].exists) {
            amount = mapSysSetting[index].minDevelopCustomAmount;
        }
    }

    function getSysFundPercent(uint32 index)
        external
        view
        returns (uint256 percent)
    {
        if (index == 0) {
            index = settingIndex;
        }
        if (mapSysSetting[index].exists) {
            percent = mapSysSetting[index].sysFundPercent;
        }
    }

    function getCycleYieldsPercent(uint32 index)
        external
        view
        returns (uint256 percent)
    {
        if (index == 0) {
            index = settingIndex;
        }
        if (mapSysSetting[index].exists) {
            percent = mapSysSetting[index].cycleYieldsPercent;
        }
    }

    function getMatureTime(uint32 index) external view returns (uint256 time) {
        if (index == 0) {
            index = settingIndex;
        }
        if (mapSysSetting[index].exists) {
            time = mapSysSetting[index].matureTime;
        }
    }

    function getCharityPercent(uint32 index)
        external
        view
        returns (uint256 percent)
    {
        if (index == 0) {
            index = settingIndex;
        }
        if (mapSysSetting[index].exists) {
            percent = mapSysSetting[index].charityPercent;
        }
    }

    function getSharedSetting(uint32 index)
        external
        view
        returns (
            bool res,
            uint256[] memory _sharedPercent,
            uint256 _sharedLayer
        )
    {
        if (index == 0) {
            index = settingIndex;
        }
        if (mapSysSetting[index].exists) {
            res = true;
            _sharedPercent = mapSysSetting[index].sharedPercent;
            _sharedLayer = mapSysSetting[index].sharedLayer;
        }
    }

    function getFixedTimeForgotten(uint32 index)
        external
        view
        returns (uint256 res)
    {
        if (index == 0) {
            index = settingIndex;
        }
        if (mapSysSetting[index].exists) {
            res = mapSysSetting[index].fixedTimeForgotten;
        }
    }

    //set mature time
    function setMatureTime(uint256 time) external onlyOwner {
        SysSetting memory ss = mapSysSetting[settingIndex];
        ss.matureTime = time;
        _newSysSetting(ss);
    }

    //setCycleYieldsPercent
    function setCycleYieldsPercent(uint256 cyp) external onlyOwner {
        SysSetting memory ss = mapSysSetting[settingIndex];
        ss.cycleYieldsPercent = cyp;
        _newSysSetting(ss);
    }

    //setSysFundPercent
    function setSysFundPercent(uint256 sfp) external onlyOwner {
        require(sfp <= max_sys_fund_percent, "exceeds max 5%");

        SysSetting memory ss = mapSysSetting[settingIndex];
        ss.sysFundPercent = sfp;
        _newSysSetting(ss);
    }

    function setCharityPercent(uint256 cp) external onlyOwner {
        SysSetting memory ss = mapSysSetting[settingIndex];
        ss.charityPercent = cp;
        _newSysSetting(ss);
    }

    //set sharedLayer percents
    function setSharedPercent(uint256[] memory percents) external onlyOwner {
        SysSetting memory ss = mapSysSetting[settingIndex];
        ss.sharedPercent = percents;
        ss.sharedLayer = percents.length;
        _newSysSetting(ss);
    }

    //set minDevelopCustomAmount
    function setMinDevelopCustomAmount(uint256 amount) external onlyOwner {
        SysSetting memory ss = mapSysSetting[settingIndex];
        ss.minDevelopCustomAmount = amount;
        _newSysSetting(ss);
    }

    function setLoseRefund(uint256 percent) external onlyOwner {
        SysSetting memory ss = mapSysSetting[settingIndex];
        ss.loseRefund = percent;
        _newSysSetting(ss);
    }

    function getLoseRefund(uint32 index) external view returns (uint256 percent) {
        if (index == 0) {
            index = settingIndex;
        }
        if (mapSysSetting[index].exists) {
            percent = mapSysSetting[index].loseRefund;
        }
    }

    function setSharedBingoReward(uint256 percent) external onlyOwner {
        SysSetting memory ss = mapSysSetting[settingIndex];
        ss.sharedBingoReward = percent;
        _newSysSetting(ss);
    }

    function getSharedBingoReward(uint32 index) external view returns (uint256 percent) {
        if (index == 0) {
            index = settingIndex;
        }
        if (mapSysSetting[index].exists) {
            percent = mapSysSetting[index].sharedBingoReward;
        }
    }

    function setSharedEmptyReward(uint256 percent) external onlyOwner {
        SysSetting memory ss = mapSysSetting[settingIndex];
        ss.sharedEmptyReward = percent;
        _newSysSetting(ss);
    }

    function getSharedEmptyReward(uint32 index) external view returns (uint256 percent) {
        if (index == 0) {
            index = settingIndex;
        }
        if (mapSysSetting[index].exists) {
            percent = mapSysSetting[index].sharedEmptyReward;
        }
    }

    function setPriceTolerance(uint256 tolerance) external onlyOwner {
        SysSetting memory ss = mapSysSetting[settingIndex];
        ss.priceTolerance = tolerance;
        _newSysSetting(ss);
    }

    function getPriceTolerance(uint32 index) external view returns (uint256 tolerance) {
        if (index == 0) {
            index = settingIndex;
        }
        if (mapSysSetting[index].exists) {
            tolerance = mapSysSetting[index].priceTolerance;
        }
    }

    function setBureauOpenerReward(uint256 reward) external onlyOwner {
        SysSetting memory ss = mapSysSetting[settingIndex];
        ss.openerReward = reward;
        _newSysSetting(ss);
    }

    function getOpenerReward(uint32 index) external view returns (uint256 reward) {
        if (index == 0) {
            index = settingIndex;
        }
        if (mapSysSetting[index].exists) {
            reward = mapSysSetting[index].openerReward;
        }
    }
}