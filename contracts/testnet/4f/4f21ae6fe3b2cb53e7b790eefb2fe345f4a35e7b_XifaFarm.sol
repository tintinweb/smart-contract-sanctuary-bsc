/**
 *Submitted for verification at BscScan.com on 2022-10-24
*/

// SPDX-License-Identifier: MIT
// website https://www.xifa.cc/
pragma solidity 0.8.17;
pragma experimental ABIEncoderV2;

contract XifaFarm{
    struct Farm {
        uint256 crystals;
        uint256 money;
        uint256 money2;
        uint256 yield;
        uint256 timestamp;
        uint256 hrs;
        address ref;
        uint256 refs;
        uint256 refDeps;
        uint8[5] farmers;
    }

    mapping(address => Farm) public farms;

    uint256 public totalFarmers;
    uint256 public totalFarms;
    uint256 public totalInvested;
    address public owner;
    address public partner;

    uint256 immutable public denominator = 10;
    bool public init;

    modifier initialized {
      require(init, 'Not initialized');
      _;
    }

    constructor() {
       owner = msg.sender;
       partner = msg.sender;
    }


    //开启农场
    function initialize() external {
      require(owner == msg.sender);
      require(!init);
      init = true;
    }

    function addCrystals(address ref) external payable {
        uint256 crystals = msg.value / 5e14; 
        require(crystals > 0, "Zero crystals");
        address user = msg.sender;
        totalInvested += msg.value;
        if (farms[user].timestamp == 0) {
            totalFarms++;
            ref = farms[ref].timestamp == 0 ? owner : ref;
            farms[ref].refs++;
            farms[user].ref = ref;
            farms[user].timestamp = block.timestamp;
        }
        ref = farms[user].ref;
        farms[ref].crystals += (crystals * 8) / 100;
        farms[ref].money += (crystals * 100 * 4) / 100;
        farms[ref].refDeps += crystals;
        farms[user].crystals += crystals;
        farms[owner].crystals += (crystals * 2) / 100;
        farms[partner].crystals += (crystals * 2) / 100;
        payable(owner).transfer((msg.value * 2) / 100);
        payable(partner).transfer((msg.value * 2) / 100);
    }

    function withdrawMoney(uint256 gold) initialized external {
        address user = msg.sender;
        require(gold <= farms[user].money && gold > 0);
        farms[user].money -= gold;
        uint256 amount = gold * 5e12;
        payable(user).transfer(address(this).balance < amount ? address(this).balance : amount);
    }

    function collectMoney() public {
        address user = msg.sender;
        syncFarm(user);
        farms[user].hrs = 0;
        farms[user].money += farms[user].money2;
        farms[user].money2 = 0;
    }

    function upgradeFarm(uint256 farmId) external {
        require(farmId < 5, "Max 5 farms");
        address user = msg.sender;
        syncFarm(user);
        farms[user].farmers[farmId]++;
        totalFarmers++;
        uint256 farmers = farms[user].farmers[farmId];
        farms[user].crystals -= getUpgradePrice(farmId, farmers) / denominator;
        farms[user].yield += getYield(farmId, farmers);
    }


     function sellFarm() external {
        collectMoney();
        address user = msg.sender;
        uint8[5] memory farmers = farms[user].farmers;
        totalFarmers -= farmers[0] + farmers[1] + farmers[2] + farmers[3] + farmers[4];
        farms[user].money += farms[user].yield * 24 * 5;
        farms[user].farmers = [0, 0, 0, 0, 0];
        farms[user].yield = 0;
    }

    function getFarmers(address addr) external view returns (uint8[5] memory) {
        return farms[addr].farmers;
    }

    function syncFarm(address user) internal {
        require(farms[user].timestamp > 0, "User is not registered");
        if (farms[user].yield > 0) {
            uint256 hrs = block.timestamp / 3600 - farms[user].timestamp / 3600;
            farms[user].money2 += hrs * farms[user].yield;
            farms[user].hrs += hrs;
        }
        farms[user].timestamp = block.timestamp;
    }

    function getUpgradePrice(uint256 farmId, uint256 farmerId) internal pure returns (uint256) {
        if (farmerId == 1) return [400, 4000, 12000, 24000, 40000][farmId];
        if (farmerId == 2) return [600, 6000, 18000, 36000, 60000][farmId];
        if (farmerId == 3) return [900, 9000, 27000, 54000, 90000][farmId];
        if (farmerId == 4) return [1360, 13500, 40500, 81000, 135000][farmId];
        if (farmerId == 5) return [2040, 20260, 60760, 121500, 202500][farmId];
        if (farmerId == 6) return [3060, 30400, 91140, 182260, 303760][farmId];
        revert("Incorrect farmerId");
    }

    function getYield(uint256 farmId, uint256 farmerId) internal pure returns (uint256) {
        if (farmerId == 1) return [5, 56, 179, 382, 678][farmId];
        if (farmerId == 2) return [8, 85, 272, 581, 1030][farmId];
        if (farmerId == 3) return [12, 128, 413, 882, 1564][farmId];
        if (farmerId == 4) return [18, 195, 628, 1340, 2379][farmId];
        if (farmerId == 5) return [28, 297, 954, 2035, 3620][farmId];
        if (farmerId == 6) return [42, 450, 1439, 3076, 5506][farmId];
        revert("Incorrect farmerId");
    }

    function modifyPartner(address addr) public {
        require(msg.sender == owner,"Only owner can modify partner");
        partner = addr;
    }

}