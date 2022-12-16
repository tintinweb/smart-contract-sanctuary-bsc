/**
 *Submitted for verification at BscScan.com on 2022-12-16
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma abicoder v2;

contract Empires {
    struct Tower {
        uint256 crystals;
        uint256 money;
        uint256 money2;
        uint256 yield;
        uint256 timestamp;
        uint256 hrs;
        address ref;
        uint256 refs;
        uint256 refDeps;
        uint8 treasury;
        uint8[5] workers;
    }

    mapping(address => Tower) public towers;

    uint256 public totalWorkers;
    uint256 public totalTowers;
    uint256 public totalInvested;
    address public manager;

    uint256 public immutable denominator = 10;
    bool public init;

    modifier initialized() {
        require(init, "Not initialized");
        _;
    }

    constructor(address manager_) {
        manager = manager_;
    }

    function initialize() external {
        require(manager == msg.sender);
        require(!init);
        init = true;
    }

    function addCrystals(address ref) external payable initialized {
        uint256 crystals = msg.value / 4e14;
        require(crystals > 0, "Zero crystals");
        address user = msg.sender;
        totalInvested += msg.value;
        if (towers[user].timestamp == 0) {
            totalTowers++;
            ref = towers[ref].timestamp == 0 ? manager : ref;
            towers[ref].refs++;
            towers[user].ref = ref;
            towers[user].timestamp = block.timestamp;
            towers[user].treasury = 0;
        }
        ref = towers[user].ref;
        towers[ref].crystals += (crystals * 8) / 100;
        towers[ref].money += (crystals * 100 * 5) / 100;
        towers[ref].refDeps += crystals;
        towers[user].crystals += crystals;
        towers[manager].crystals += (crystals * 8) / 100;
        payable(manager).transfer((msg.value * 5) / 100);
    }

    function withdrawMoney(uint256 gold) external initialized {
        address user = msg.sender;
        require(gold <= towers[user].money && gold > 0);
        towers[user].money -= gold;
        uint256 amount = gold * 4e12;
        payable(user).transfer(
            address(this).balance < amount ? address(this).balance : amount
        );
    }

    function collectMoney() public {
        address user = msg.sender;
        syncTower(user);
        towers[user].hrs = 0;
        towers[user].money += towers[user].money2;
        towers[user].money2 = 0;
    }

    function upgradeTower(uint256 towerId) external {
        require(towerId < 5, "Max 5 towers");
        address user = msg.sender;
        if (towerId > 0) {
            require(
                towers[user].workers[towerId - 1] == 5,
                "The previous tower was not upgraded"
            );
        }
        syncTower(user);
        towers[user].workers[towerId]++;
        totalWorkers++;
        uint256 workers = towers[user].workers[towerId];
        towers[user].crystals -=
            getUpgradePrice(towerId, workers) /
            denominator;
        towers[user].yield += getYield(towerId, workers);
    }

    function upgradeTreasury() external {
        address user = msg.sender;
        uint8 treasuryId = towers[user].treasury + 1;
        syncTower(user);
        require(treasuryId < 6, "Max 6 treasury");
        (uint256 price, ) = getTreasure(treasuryId);
        towers[user].crystals -= price / denominator;
        towers[user].treasury = treasuryId;
    }

    function getWorkers(address addr) external view returns (uint8[5] memory) {
        return towers[addr].workers;
    }

    function syncTower(address user) internal {
        require(towers[user].timestamp > 0, "User is not registered");
        if (towers[user].yield > 0) {
            (, uint256 treasury) = getTreasure(towers[user].treasury);
            uint256 hrs = block.timestamp /
                3600 -
                towers[user].timestamp /
                3600;
            if (hrs + towers[user].hrs > treasury) {
                hrs = treasury - towers[user].hrs;
            }
            towers[user].money2 += hrs * towers[user].yield;
            towers[user].hrs += hrs;
        }
        towers[user].timestamp = block.timestamp;
    }

    function getUpgradePrice(uint256 towerId, uint256 chefId)
        internal
        pure
        returns (uint256)
    {
        if (chefId == 1) return [500, 5000, 10000, 28000, 50000][towerId];
        if (chefId == 2) return [720, 7200, 14400, 41800, 75000][towerId];
        if (chefId == 3) return [960, 9600, 19200, 56600, 96000][towerId];
        if (chefId == 4) return [1220, 12500, 25000, 74000, 125000][towerId];
        if (chefId == 5) return [2050, 20500, 41000, 123000, 205000][towerId];
        revert("Incorrect chefId");
    }

    function getYield(uint256 towerId, uint256 chefId)
        internal
        pure
        returns (uint256)
    {
        if (chefId == 1) return [6, 68, 146, 445, 834][towerId];
        if (chefId == 2) return [9, 99, 213, 667, 1297][towerId];
        if (chefId == 3) return [13, 134, 298, 912, 1725][towerId];
        if (chefId == 4) return [16, 178, 385, 1204, 2331][towerId];
        if (chefId == 5) return [28, 298, 642, 2028, 3947][towerId];
        revert("Incorrect chefId");
    }

    function getTreasure(uint256 treasureId)
        internal
        pure
        returns (uint256, uint256)
    {
        if (treasureId == 0) return (0, 24);
        if (treasureId == 1) return (2000, 28);
        if (treasureId == 2) return (3000, 34);
        if (treasureId == 3) return (4000, 42);
        if (treasureId == 4) return (5500, 54);
        if (treasureId == 5) return (8500, 72);
        revert("Incorrect treasureId");
    }
}