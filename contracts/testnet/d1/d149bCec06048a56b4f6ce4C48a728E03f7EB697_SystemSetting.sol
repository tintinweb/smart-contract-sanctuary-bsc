// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./SystemAuth.sol";

contract SystemSetting {
    uint256 constant default_mature_time = 60480; //60480seconds = 7 days
    uint256 constant default_backlog_time = 86400; //  1 day
    uint256 constant default_min_amount_buy = 10 * 10**18;
    uint256 constant default_max_amount_buy = 10000 * 10**18;
    uint256 constant default_min_dev_custom_amount = 10;
    uint256 constant default_cycle_yields = 50; // 5%
    uint256 constant default_shared_profit = 95; // 9.5%
    uint256 constant default_fomo_pool = 45; // 4.5%
    uint256 constant default_sys_fund = 10; // 1%
    uint256 constant default_charity = 5; // 0.5%
    //------------sum-------------------= 300    // 30%

    uint256 constant max_sys_fund_percent = 50; // 5%
    uint256 constant default_reset_countdown_time_length = 7200; //seconds
    //when the backlog percent is lower than 1%, It is counting down to reset the queue
    uint256 constant default_backlog_percent_to_countdown = 10;
    uint256 constant fixed_time_length_forgotten = 2592000;
    //default land price
    //Player should own a land before sowing seeds
    uint256 constant default_land_price = 100 * 10**18; //100 MUT

    SystemAuth ssAuth;
    //mapping of system settings
    uint32 settingIndex;
    mapping(uint32 => SysSetting) mapSysSetting;

    struct SysSetting {
        uint matureTime;
        uint backlogTime;
        uint256 cycleYieldsPercent;
        uint256 minDevelopCustomAmount;
        uint256 fomoPoolPercent;
        uint256 sysFundPercent;
        uint256 resetCountDownTimeLength;
        uint256 backlogToCountdown;
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

    constructor(address systemAuthAddress) {
        ssAuth = SystemAuth(systemAuthAddress);

        settingIndex = 1;
        uint256[] memory _defaulSharedPercent = new uint256[](4);
        _defaulSharedPercent[0] = 40;
        _defaulSharedPercent[1] = 30;
        _defaulSharedPercent[2] = 10;
        _defaulSharedPercent[3] = 5;
        mapSysSetting[settingIndex] = SysSetting(
            default_mature_time,
            default_backlog_time,
            default_cycle_yields,
            default_min_dev_custom_amount,
            default_fomo_pool,
            default_sys_fund,
            default_reset_countdown_time_length,
            default_backlog_percent_to_countdown,
            default_land_price,
            default_min_amount_buy,
            default_max_amount_buy,
            default_charity,
            50,
            2592000,
            _defaulSharedPercent,
            _defaulSharedPercent.length,
            true
        );
    }

    function _newSysSetting(SysSetting memory ss) internal {
        mapSysSetting[++settingIndex] = SysSetting(
            ss.matureTime,
            ss.backlogTime,
            ss.cycleYieldsPercent,
            ss.minDevelopCustomAmount,
            ss.fomoPoolPercent,
            ss.sysFundPercent,
            ss.resetCountDownTimeLength,
            ss.backlogToCountdown,
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

    function getSysSetting(uint32 index)
        external
        view
        returns (
            uint _matureTime,
            uint _backlogTime,
            uint256 _cycleYieldsPercent,
            uint256 _minDevelopCustomAmount,
            uint256 _fomoPoolPercent,
            uint256 _sysFundPercent,
            uint256 _resetCountDownTimeLength,
            uint256 _backlogToCountdown,
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
            _backlogTime = mapSysSetting[index].backlogTime;
            _cycleYieldsPercent = mapSysSetting[index].cycleYieldsPercent;
            _minDevelopCustomAmount = mapSysSetting[index]
                .minDevelopCustomAmount;
            _fomoPoolPercent = mapSysSetting[index].fomoPoolPercent;
            _sysFundPercent = mapSysSetting[index].sysFundPercent;
            _resetCountDownTimeLength = mapSysSetting[index]
                .resetCountDownTimeLength;
            _backlogToCountdown = mapSysSetting[index].backlogToCountdown;
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

    function getBacklogTime(uint32 index) external view returns (uint256 time) {
        if (index == 0) {
            index = settingIndex;
        }
        if (mapSysSetting[index].exists) {
            time = mapSysSetting[index].backlogTime;
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

    function getBacklogToCountdown(uint32 index)
        external
        view
        returns (uint256 res)
    {
        if (index == 0) {
            index = settingIndex;
        }
        if (mapSysSetting[index].exists) {
            res = mapSysSetting[index].backlogToCountdown;
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
    function setMatureTime(uint256 time) external {
        require(
            msg.sender == ssAuth.getOwner(),
            "Only owner of this contract can set mature time"
        );

        SysSetting memory ss = mapSysSetting[settingIndex];
        ss.matureTime = time;
        _newSysSetting(ss);
    }

    //set backlog time
    function setBacklogTime(uint256 time) external {
        require(
            msg.sender == ssAuth.getOwner(),
            "Only owner of this contract can set mature time"
        );

        SysSetting memory ss = mapSysSetting[settingIndex];
        ss.backlogTime = time;
        _newSysSetting(ss);
    }

    //setCycleYieldsPercent
    function setCycleYieldsPercent(uint256 cyp) external {
        require(
            msg.sender == ssAuth.getOwner(),
            "Only owner of this contract can set CycleYieldsPercent"
        );

        SysSetting memory ss = mapSysSetting[settingIndex];
        ss.cycleYieldsPercent = cyp;
        _newSysSetting(ss);
    }

    //setFomoPoolPercent
    function setFomoPoolPercent(uint256 fpp) external {
        require(
            msg.sender == ssAuth.getOwner(),
            "Only owner of this contract can set FomoPoolPercent"
        );

        SysSetting memory ss = mapSysSetting[settingIndex];
        ss.fomoPoolPercent = fpp;
        _newSysSetting(ss);
    }

    //setSysFundPercent
    function setSysFundPercent(uint256 sfp) external {
        require(
            msg.sender == ssAuth.getOwner(),
            "Only owner of this contract can set SysFundPercent"
        );
        require(sfp <= max_sys_fund_percent, "exceeds max 5%");

        SysSetting memory ss = mapSysSetting[settingIndex];
        ss.sysFundPercent = sfp;
        _newSysSetting(ss);
    }

    function setCharityPercent(uint256 cp) external {
        require(
            msg.sender == ssAuth.getOwner(),
            "Only owner of this contract can set charityPercent"
        );

        SysSetting memory ss = mapSysSetting[settingIndex];
        ss.charityPercent = cp;
        _newSysSetting(ss);
    }

    //set min amount buy
    function setMinAmountBuy(uint256 amount) external {
        require(
            msg.sender == ssAuth.getOwner(),
            "Only owner of this contract can set min amount buy"
        );

        SysSetting memory ss = mapSysSetting[settingIndex];
        ss.minAmountBuy = amount;
        _newSysSetting(ss);
    }

    //set max amount buy
    function setMaxAmountBuy(uint256 amount) external {
        require(
            msg.sender == ssAuth.getOwner(),
            "Only owner of this contract can set max amount buy"
        );

        SysSetting memory ss = mapSysSetting[settingIndex];
        ss.maxAmountBuy = amount;
        _newSysSetting(ss);
    }

    //set sharedLayer percents
    function setSharedPercent(uint256[] memory percents) external {
        require(
            msg.sender == ssAuth.getOwner(),
            "Only owner of this contract set the shared percents"
        );

        SysSetting memory ss = mapSysSetting[settingIndex];
        ss.sharedPercent = percents;
        ss.sharedLayer = percents.length;
        _newSysSetting(ss);
    }

    //set resetCountDownTimeLength
    function setResetCountDownTimeLength(uint256 s) external {
        require(msg.sender == ssAuth.getOwner(), "not owner error");

        SysSetting memory ss = mapSysSetting[settingIndex];
        ss.resetCountDownTimeLength = s;
        _newSysSetting(ss);
    }

    //set minDevelopCustomAmount
    function setMinDevelopCustomAmount(uint256 amount) external {
        require(
            msg.sender == ssAuth.getOwner(),
            "Only owner of this contract set minDevelopCustomAmount"
        );

        SysSetting memory ss = mapSysSetting[settingIndex];
        ss.minDevelopCustomAmount = amount;
        _newSysSetting(ss);
    }

    //set land price
    function setLandPrice(uint256 amount) external {
        require(
            msg.sender == ssAuth.getOwner(),
            "Only owner of this contract set setLandPrice"
        );

        SysSetting memory ss = mapSysSetting[settingIndex];
        ss.landPrice = amount;
        _newSysSetting(ss);
    }
}