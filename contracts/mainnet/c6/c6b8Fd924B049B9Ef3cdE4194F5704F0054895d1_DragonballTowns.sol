/**
 *Submitted for verification at BscScan.com on 2022-12-14
*/

/**
 *DragonballTowns.. - a ROI Blockchain Game
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

contract DragonballTowns {
    struct Building {
        uint256 tools;
        uint256 emerald;
        uint256 emerald2;
        uint256 yield;
        uint256 timestamp;
        uint256 hrs;
        address ref;
        uint256 refs;
        uint256 refEmerald;
        uint256 refTools;
        uint8 market;
        uint8[7] workers;
    }

    mapping(address => Building) public buildings;

    bool public init;

    uint256 public totalWorkers;
    uint256 public totalTrainers;
    uint256 public totalInvested;
    address public manager;
    address public partner;
    address public marketwallet;

    modifier initialized() {
        require(init, "Game has not started yet");
        _;
    }

    constructor() {
        manager = msg.sender;
        partner = address(0x2EDB0Ad6D06fCefD57F34fD060171859ED056830);
        marketwallet = address(0xF99F6f5880B3E8efCf7ef08cd1835662A2407536);
    }

    function initialize() external {
        require(manager == msg.sender);
        require(!init);
        init = true;
    }

    function addDragonballcash(address ref) external payable initialized {
        uint256 tools = msg.value / 4e14;
        require(tools > 0, "Zero DragonballCash");
        address user = msg.sender;
        totalInvested += msg.value;
        if (buildings[user].timestamp == 0) {
            totalTrainers++;
            buildings[user].timestamp = block.timestamp;
            buildings[user].market = 0;
            if (ref != address(0) && buildings[ref].timestamp != 0) {
                buildings[user].ref = ref;
                buildings[ref].refs++;  
            }
        }

        if (buildings[user].ref != address(0)) {
            referralReward(buildings[user].ref, tools, 5, 5);
        }

        buildings[user].tools += tools;
        payable(manager).transfer((msg.value * 6) / 100);
        payable(partner).transfer((msg.value * 2) / 100);
        payable(marketwallet).transfer((msg.value * 2) / 100);
    }

    function referralReward(
        address ref,
        uint256 amount,
        uint8 tProcent,
        uint8 gProcent
    ) internal {
        uint256 tools = (amount * tProcent) / 100;
        uint256 emerald = (amount * 100 * gProcent) / 100;

        buildings[ref].tools += tools;
        buildings[ref].emerald += emerald;

        buildings[ref].refEmerald += emerald;
        buildings[ref].refTools += tools;
    }

    function compound(uint256 emerald) external initialized {
        address user = msg.sender;
        require(emerald <= buildings[user].emerald && emerald > 0);
        buildings[user].emerald -= emerald;
        uint256 amount = (emerald * 125) / 10000;
        buildings[user].tools += amount;
    }

    function withdrawDragonballcoins(uint256 emerald) external initialized {
        address user = msg.sender;
        require(emerald <= buildings[user].emerald && emerald > 0);
        buildings[user].emerald -= emerald;
        
        uint256 amount = emerald * 4e12;
        amount = address(this).balance < amount
            ? address(this).balance
            : amount;
        uint256 fee = (amount * 2) / 100;
        uint256 fee2 = (amount * 2) / 100;
        payable(manager).transfer(fee);
        payable(partner).transfer(fee2);
        payable(user).transfer(amount - fee - fee2);
    }

    function collectDragonballcoins() public initialized {
        address user = msg.sender;
        syncBuildings(user);
        buildings[user].hrs = 0;
        buildings[user].emerald += buildings[user].emerald2;
        buildings[user].emerald2 = 0;
    }

    function upgradeBuilding(uint256 buildingId) external initialized {
        require(buildingId < 7, "Max 7 buildings");
        address user = msg.sender;
        syncBuildings(user);
        buildings[user].workers[buildingId]++;
        totalWorkers++;
        uint256 workers = buildings[user].workers[buildingId];
        buildings[user].tools -= getUpgradePrice(buildingId, workers);
        buildings[user].yield += getYield(buildingId, workers);
    }

    function upgradeHome() external initialized {
        address user = msg.sender;
        syncBuildings(user);
        uint8 marketId = buildings[user].market + 1;
        (uint256 price, ) = getMarket(marketId);
        buildings[user].tools -= price;
        buildings[user].market = marketId;
    }

    function getWorkers(address addr) external view returns (uint8[7] memory) {
        return buildings[addr].workers;
    }

    function syncBuildings(address user) internal {
        require(buildings[user].timestamp > 0, "User is not registered");
        if (buildings[user].yield > 0) {
            (, uint256 market) = getMarket(buildings[user].market);
            uint256 hrs = block.timestamp /
                3600 -
                buildings[user].timestamp /
                3600;
            if (hrs + buildings[user].hrs > market) {
                hrs = market - buildings[user].hrs;
            }
            buildings[user].emerald2 += hrs * buildings[user].yield;
            buildings[user].hrs += hrs;
        }
        buildings[user].timestamp = block.timestamp;
    }

    function getUpgradePrice(uint256 buildingId, uint256 workerId)
        internal
        pure
        returns (uint256)
    {
        if (workerId == 1)
            return [175, 525, 1575, 3150, 6300, 12600, 18900][buildingId];
        if (workerId == 2)
            return [200, 600, 1800, 3600, 7200, 14400, 21600][buildingId];
        if (workerId == 3)
            return [238, 713, 2138, 4275, 8550, 17100, 25650][buildingId];
        if (workerId == 4)
            return [300, 900, 2700, 5400, 10800, 21600, 32400][buildingId];
        if (workerId == 5)
            return [338, 1013, 3038, 6075, 12150, 24300, 36450][buildingId];
        revert("Incorrect workerId");
    }

    function getYield(uint256 buildingId, uint256 workerId)
        internal
        pure
        returns (uint256)
    {
        if (workerId == 1)
            return [20, 63, 203, 433, 924, 1979, 3166][buildingId];
        if (workerId == 2)
            return [23, 74, 236, 501, 1071, 2292, 3663][buildingId];
        if (workerId == 3)
            return [28, 88, 283, 602, 1290, 2757, 4403][buildingId];
        if (workerId == 4)
            return [35, 113, 362, 770, 1652, 3528, 5630][buildingId];
        if (workerId == 5)
            return [40, 129, 413, 878, 1883, 4020, 6424][buildingId];
        revert("Incorrect workerId");
    }

    function getMarket(uint256 marketId)
        internal
        pure
        returns (uint256, uint256)
    {
        if (marketId == 0) return (0, 24); // price | value
        if (marketId == 1) return (1250, 28);
        if (marketId == 2) return (1250, 32);
        if (marketId == 3) return (1250, 36);
        revert("Incorrect marketId");
    }
}