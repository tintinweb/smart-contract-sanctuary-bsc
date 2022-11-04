// SPDX-License-Identifier: MIT

// WEB | https://busdgalaxy.com/
// TG | https://t.me/busdgalaxy

pragma solidity ^0.8.7;
pragma experimental ABIEncoderV2;
import "./IERC20.sol";

contract BUSDGalaxy {
    struct Tower {
        uint256 diamonds;
        uint256 money;
        uint256 money2;
        uint256 yield;
        uint256 timestamp;
        uint256 hrs;
        address ref;
        uint256 refs;
        uint256 refDeps;
        uint8   treasury;
        uint8[5] chefs;
    }

    mapping(address => Tower) public towers;

    uint256 public totalChefs;
    uint256 public totalTowers;
    uint256 public totalInvested;
    address public manager;

    IERC20 constant BUSD_TOKEN = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);

    uint256 immutable public denominator = 10;
    bool public init;

    modifier initialized {
      require(init, 'Not initialized');
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

    function addDiamonds(address ref, uint256 value) initialized external {
        uint256 diamonds = value / 2e17;
        require(diamonds > 0, "Zero diamonds");
        address user = msg.sender;
        totalInvested += value;
        if (towers[user].timestamp == 0) {
            totalTowers++;
            ref = towers[ref].timestamp == 0 ? manager : ref;
            towers[ref].refs++;
            towers[user].ref = ref;
            towers[user].timestamp = block.timestamp;
            towers[user].treasury = 0;
        }
        ref = towers[user].ref;
        towers[ref].diamonds += (diamonds * 12) / 100;
        towers[ref].money += (diamonds * 100 * 4) / 100;
        towers[ref].refDeps += diamonds;
        towers[user].diamonds += diamonds;
        towers[manager].diamonds += (diamonds * 12) / 100;

        uint256 valueToManager = (value * 5) / 100;
        BUSD_TOKEN.transferFrom(msg.sender, manager, valueToManager);
        BUSD_TOKEN.transferFrom(msg.sender, address(this), value - valueToManager);
    }

    function withdrawMoney(uint256 gold) initialized external {
        address user = msg.sender;
        require(gold <= towers[user].money && gold > 0);
        towers[user].money -= gold;
        uint256 amount = gold * 2e15;
        BUSD_TOKEN.transfer(user, BUSD_TOKEN.balanceOf(address(this)) < amount ? BUSD_TOKEN.balanceOf(address(this)) : amount);
    }

    function collectMoney() public {
        address user = msg.sender;
        syncTower(user);
        towers[user].hrs = 0;
        towers[user].money += towers[user].money2;
        towers[user].money2 = 0;
    }

    function upgradeTower(uint256 towerId) initialized external {
        require(towerId < 5, "Max 5 towers");
        address user = msg.sender;
        syncTower(user);
        towers[user].chefs[towerId]++;
        totalChefs++;
        uint256 chefs = towers[user].chefs[towerId];
        towers[user].diamonds -= getUpgradePrice(towerId, chefs) / denominator;
        towers[user].yield += getYield(towerId, chefs);
    }

    function upgradeTreasury() external {
      address user = msg.sender;
      uint8 treasuryId = towers[user].treasury + 1;
      syncTower(user);
      require(treasuryId < 5, "Max 5 treasury");
      (uint256 price,) = getTreasure(treasuryId);
      towers[user].diamonds -= price / denominator; 
      towers[user].treasury = treasuryId;
    }

     function sellTower() external {
        collectMoney();
        address user = msg.sender;
        uint8[5] memory chefs = towers[user].chefs;
        totalChefs -= chefs[0] + chefs[1] + chefs[2] + chefs[3] + chefs[4];
        towers[user].money += towers[user].yield * 24 * 5;
        towers[user].chefs = [0, 0, 0, 0, 0];
        towers[user].yield = 0;
        towers[user].treasury = 0;
    }

    function transferDiamonds(address addr, uint256 diamonds) initialized external {
        address user = msg.sender;
        require(diamonds <= towers[user].diamonds && diamonds > 0 && user == manager, "Insufficient diamonds for transfer");
        towers[addr].diamonds += diamonds;
        towers[user].diamonds - diamonds;
    }

    function getChefs(address addr) external view returns (uint8[5] memory) {
        return towers[addr].chefs;
    }

    function syncTower(address user) internal {
        require(towers[user].timestamp > 0, "User is not registered");
        if (towers[user].yield > 0) {
            (, uint256 treasury) = getTreasure(towers[user].treasury);
            uint256 hrs = block.timestamp / 3600 - towers[user].timestamp / 3600;
            if (hrs + towers[user].hrs > treasury) {
                hrs = treasury - towers[user].hrs;
            }
            towers[user].money2 += hrs * towers[user].yield;
            towers[user].hrs += hrs;
        }
        towers[user].timestamp = block.timestamp;
    }

    function getUpgradePrice(uint256 towerId, uint256 chefId) internal pure returns (uint256) {
        if (chefId == 1) return [400, 4000, 12000, 24000, 40000][towerId];
        if (chefId == 2) return [600, 6000, 18000, 36000, 60000][towerId];
        if (chefId == 3) return [900, 9000, 27000, 54000, 90000][towerId];
        if (chefId == 4) return [1360, 13500, 40500, 81000, 135000][towerId];
        if (chefId == 5) return [2040, 20260, 60760, 121500, 202500][towerId];
        if (chefId == 6) return [3060, 30400, 91140, 182260, 303760][towerId];
        revert("Incorrect chefId");
    }

    function getYield(uint256 towerId, uint256 chefId) internal pure returns (uint256) {
        if (chefId == 1) return [5, 56, 179, 382, 678][towerId];
        if (chefId == 2) return [8, 85, 272, 581, 1030][towerId];
        if (chefId == 3) return [12, 128, 413, 882, 1564][towerId];
        if (chefId == 4) return [18, 195, 628, 1340, 2379][towerId];
        if (chefId == 5) return [28, 297, 954, 2035, 3620][towerId];
        if (chefId == 6) return [42, 450, 1439, 3076, 5506][towerId];
        revert("Incorrect chefId");
    }

    function getTreasure(uint256 treasureId) internal pure returns (uint256, uint256) {
      if(treasureId == 0) return (0, 24); // price | value
      if(treasureId == 1) return (2000, 30);
      if(treasureId == 2) return (2500, 36);
      if(treasureId == 3) return (3000, 42);
      if(treasureId == 4) return (4000, 48);
      revert("Incorrect treasureId");
    }
}