// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Ownable.sol";

contract SystemSetting is Ownable {

    uint256 constant default_bureau_lose_reward         = 100;  //10%
    uint256 constant default_bureau_shared_bingo_reward = 100;  //10%
    uint256 constant default_bureau_shared_empty_reward = 10;   //1%

    uint256 constant default_mature_time = 604800; //604800seconds = 7 days
    uint256 constant default_min_amount_buy = 100 * 10**18;
    uint256 constant default_max_amount_buy = 5000 * 10**18;
    uint256 constant default_min_dev_custom_amount = 100 * 10**18;//100MUT
    uint256 constant default_cycle_yields = 80; // 8%
    uint256 constant default_fomo_pool = 45; // 4.5%
    uint256 constant default_sys_fund = 15; // 1.5%
    uint256 constant default_charity = 5; // 0.5%
    //------------sum-------------------= 300    // 30%

    uint256 constant max_sys_fund_percent = 50; // 5%
    uint256 constant default_reset_countdown_time_length = 43200; //12 Hours
    uint256 constant fixed_time_length_forgotten = 2592000; //30days
    //default land price
    //Player should own a land before sowing seeds
    uint256 constant default_land_price = 100 * 10**18; //100 MUT

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
        uint256 fomoPoolPercent;
        uint256 sysFundPercent;
        uint256 resetCountDownTimeLength;
        uint256 landPrice;
        uint256 minAmountBuy;
        uint256 maxAmountBuy;
        uint256 charityPercent;
        uint256 maxSysFundPercent;
        uint256 fixedTimeForgotten;
        uint256[] sharedPercent;
        uint256 sharedLayer;
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
            default_fomo_pool,
            default_sys_fund,
            default_reset_countdown_time_length,
            default_land_price,
            default_min_amount_buy,
            default_max_amount_buy,
            default_charity,
            max_sys_fund_percent,
            fixed_time_length_forgotten,
            _defaulSharedPercent,
            _defaulSharedPercent.length,
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
            ss.fomoPoolPercent,
            ss.sysFundPercent,
            ss.resetCountDownTimeLength,
            ss.landPrice,
            ss.minAmountBuy,
            ss.maxAmountBuy,
            ss.charityPercent,
            ss.maxSysFundPercent,
            ss.fixedTimeForgotten,
            ss.sharedPercent,
            ss.sharedLayer,
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
            uint256 _fomoPoolPercent,
            uint256 _sysFundPercent,
            uint256 _resetCountDownTimeLength,
            uint256 _landPrice,
            uint256 _minAmountBuy,
            uint256 _maxAmountBuy,
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
            _fomoPoolPercent = mapSysSetting[index].fomoPoolPercent;
            _sysFundPercent = mapSysSetting[index].sysFundPercent;
            _resetCountDownTimeLength = mapSysSetting[index].resetCountDownTimeLength;
            _landPrice = mapSysSetting[index].landPrice;
            _minAmountBuy = mapSysSetting[index].minAmountBuy;
            _maxAmountBuy = mapSysSetting[index].maxAmountBuy;
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

    function getLandPrice(uint32 index) external view returns (uint256 price) {
        if (index == 0) {
            index = settingIndex;
        }
        if (mapSysSetting[index].exists) {
            price = mapSysSetting[index].landPrice;
        }
    }

    function getMinAmountBuy(uint32 index)
        external
        view
        returns (uint256 amount)
    {
        if (index == 0) {
            index = settingIndex;
        }
        if (mapSysSetting[index].exists) {
            amount = mapSysSetting[index].minAmountBuy;
        }
    }

    function getMaxAmountBuy(uint32 index)
        external
        view
        returns (uint256 amount)
    {
        if (index == 0) {
            index = settingIndex;
        }
        if (mapSysSetting[index].exists) {
            amount = mapSysSetting[index].maxAmountBuy;
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

    function getFomoPoolPercent(uint32 index)
        external
        view
        returns (uint256 percent)
    {
        if (index == 0) {
            index = settingIndex;
        }
        if (mapSysSetting[index].exists) {
            percent = mapSysSetting[index].fomoPoolPercent;
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

    function getResetCountDownTimeLength(uint32 index)
        external
        view
        returns (uint256 res)
    {
        if (index == 0) {
            index = settingIndex;
        }
        if (mapSysSetting[index].exists) {
            res = mapSysSetting[index].resetCountDownTimeLength;
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

    //setFomoPoolPercent
    function setFomoPoolPercent(uint256 fpp) external onlyOwner {
        SysSetting memory ss = mapSysSetting[settingIndex];
        ss.fomoPoolPercent = fpp;
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

    //set min amount buy
    function setMinAmountBuy(uint256 amount) external onlyOwner {
        SysSetting memory ss = mapSysSetting[settingIndex];
        ss.minAmountBuy = amount;
        _newSysSetting(ss);
    }

    //set max amount buy
    function setMaxAmountBuy(uint256 amount) external onlyOwner {
        SysSetting memory ss = mapSysSetting[settingIndex];
        ss.maxAmountBuy = amount;
        _newSysSetting(ss);
    }

    //set sharedLayer percents
    function setSharedPercent(uint256[] memory percents) external onlyOwner {
        SysSetting memory ss = mapSysSetting[settingIndex];
        ss.sharedPercent = percents;
        ss.sharedLayer = percents.length;
        _newSysSetting(ss);
    }

    //set resetCountDownTimeLength
    function setResetCountDownTimeLength(uint256 s) external onlyOwner {
        SysSetting memory ss = mapSysSetting[settingIndex];
        ss.resetCountDownTimeLength = s;
        _newSysSetting(ss);
    }

    //set minDevelopCustomAmount
    function setMinDevelopCustomAmount(uint256 amount) external onlyOwner {
        SysSetting memory ss = mapSysSetting[settingIndex];
        ss.minDevelopCustomAmount = amount;
        _newSysSetting(ss);
    }

    //set land price
    function setLandPrice(uint256 amount) external onlyOwner {
        SysSetting memory ss = mapSysSetting[settingIndex];
        ss.landPrice = amount;
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
}