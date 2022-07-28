// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./SystemAuth.sol";
import "./SystemSetting.sol";

contract History {
    SystemSetting ssSetting;
    SystemAuth ssAuth;
    address caller;

    //mature history
    struct MatureHistoryData {
        uint256 amount;
        uint256 time;
        bool exists;
    }
    struct MatureHistoryCount {
        uint32 count;
        bool exists;
    }
    // key: account => count
    mapping(address => MatureHistoryCount) mapMatureHistoryCount;
    // key: account => (indexOfCount => MatureHistoryData)
    mapping(address => mapping(uint32 => MatureHistoryData)) mapMatureHistory;

    //claim history(collect history)
    struct ClaimHistoryData {
        uint256 amount;
        uint256 time;
        bool exists;
    }
    struct ClaimHistoryCount {
        uint32 count;
        bool exists;
    }
    //
    mapping(address => ClaimHistoryCount) mapClaimHistoryCount;
    mapping(address => mapping(uint32 => ClaimHistoryData)) mapClaimHistory;

    constructor(address ssSettingAddress, address ssAuthAddress) {
        ssSetting = SystemSetting(ssSettingAddress);
        ssAuth = SystemAuth(ssAuthAddress);
    }

    function setCaller(address _caller) external {
        require(msg.sender == ssAuth.getOwner(), "Owner only");
        caller = _caller;
    }

    function getCaller() external view returns (address res) {
        res = caller;
    }

    function addMatureRecord(address account, uint256 amount) external {
        require(caller != address(0), "caller not set");
        require(caller == msg.sender, "caller not permitted");
        uint32 _count = 0;
        if (mapMatureHistoryCount[account].exists) {
            MatureHistoryCount storage countData = mapMatureHistoryCount[
                account
            ];
            ++countData.count;
            _count = countData.count;
        } else {
            mapMatureHistoryCount[account] = MatureHistoryCount(1, true);
            _count = 1;
        }
        mapMatureHistory[account][_count] = MatureHistoryData(
            amount,
            block.timestamp,
            true
        );
    }

    function addClaimRecord(address account, uint256 amount) external {
        require(caller != address(0), "caller not set");
        require(caller == msg.sender, "caller not permitted");
        uint32 _count = 0;
        if (mapClaimHistoryCount[account].exists) {
            ClaimHistoryCount storage cc = mapClaimHistoryCount[account];
            ++cc.count;
            _count = cc.count;
        } else {
            mapClaimHistoryCount[account] = ClaimHistoryCount(1, true);
            _count = 1;
        }
        mapClaimHistory[account][_count] = ClaimHistoryData(
            amount,
            block.timestamp,
            true
        );
    }

    //get mature history count of an account
    function getMatureHistoryCount(address account)
        external
        view
        returns (uint32 res)
    {
        if (mapMatureHistoryCount[account].exists) {
            res = mapMatureHistoryCount[account].count;
        }
    }

    //get mature history data by index of an account
    function getMatureHistoryData(address account, uint32 index)
        external
        view
        returns (
            bool res,
            uint256 amount,
            uint256 time
        )
    {
        if (mapMatureHistory[account][index].exists) {
            res = true;
            amount = mapMatureHistory[account][index].amount;
            time = mapMatureHistory[account][index].time;
        }
    }

    //get claim history count of an account
    function getClaimHistoryCount(address account)
        external
        view
        returns (uint32 res)
    {
        if (mapClaimHistoryCount[account].exists) {
            res = mapClaimHistoryCount[account].count;
        }
    }

    //get claim history data by index of an account
    function getClaimHistoryData(address account, uint32 index)
        external
        view
        returns (
            bool res,
            uint256 amount,
            uint256 time
        )
    {
        if (mapClaimHistory[account][index].exists) {
            res = true;
            amount = mapClaimHistory[account][index].amount;
            time = mapClaimHistory[account][index].time;
        }
    }
}