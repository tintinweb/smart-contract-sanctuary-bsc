// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

interface IPizzaCoin {
    function mint(address user, uint256 money) external;

    function burn(address user, uint256 coins) external;
}

contract PizzaTowerV2 {
    struct Tower {
        uint256 money;
        uint256 money2;
        uint256 money3;
        uint256 yield;
        uint256 timestamp;
        address ref;
        uint256 refs;
        uint256 refs2;
        uint256 refs3;
        uint256 refMoney;
        uint8[8] chefs;
    }
    mapping(address => Tower) public towers;
    uint256 public totalChefs;
    uint256 public totalTowers;

    IPizzaCoin public constant PizzaCoin = IPizzaCoin(0x732827E4AcdBfCF35E3266D261C6Bd221463d39a);

    function upgradeTower(address ref, uint256 floorId) external {
        require(floorId < 8, "Max 8 floors");
        address user = msg.sender;
        towers[user].chefs[floorId]++;
        uint256 chefs = towers[user].chefs[floorId];
        uint256 coins = getUpgradePrice(floorId, chefs);
        PizzaCoin.burn(user, coins);
        if (towers[user].timestamp == 0) {
            if (towers[ref].timestamp != 0) {
                towers[user].money += coins * 3; // 3% cashback
                towers[user].ref = ref;
                towers[ref].refs++;
                address ref2 = towers[ref].ref;
                if (towers[ref2].timestamp != 0) {
                    towers[ref2].refs2++;
                    address ref3 = towers[ref2].ref;
                    if (towers[ref3].timestamp != 0) {
                        towers[ref3].refs3++;
                    }
                }
            }
            totalTowers++;
            towers[user].timestamp = block.timestamp;
        }
        syncTower(user);
        totalChefs++;
        ref = towers[user].ref;
        if (ref != address(0)) {
            towers[ref].refMoney += coins * 7;
            towers[ref].money += coins * 7;
            address ref2 = towers[ref].ref;
            if (ref2 != address(0)) {
                towers[ref2].refMoney += coins * 3;
                towers[ref2].money += coins * 3;
                address ref3 = towers[ref2].ref;
                if (ref3 != address(0)) {
                    towers[ref3].refMoney += coins * 1;
                    towers[ref3].money += coins * 1;
                }
            }
        }
        towers[user].yield += getYield(floorId, chefs);
    }

    function withdrawMoney() external {
        address user = msg.sender;
        uint256 money = towers[user].money;
        require(money > 0, "Zero money");
        towers[user].money = 0;
        towers[user].money3 += money;
        PizzaCoin.mint(user, money);
    }

    function collectMoney() external {
        address user = msg.sender;
        syncTower(user);
        towers[user].money += towers[user].money2;
        towers[user].money2 = 0;
    }

    function getChefs(address addr) external view returns (uint8[8] memory) {
        return towers[addr].chefs;
    }

    function syncTower(address user) internal {
        uint256 timestamp = towers[user].timestamp;
        require(timestamp > 0, "User is not registered");
        towers[user].money2 += (block.timestamp / 3600 - timestamp / 3600) * towers[user].yield;
        towers[user].timestamp = block.timestamp;
    }

    function getUpgradePrice(uint256 floorId, uint256 chefId) internal pure returns (uint256) {
        if (chefId == 1) return [500, 1500, 4500, 13500, 40500, 120000, 365000, 1000000][floorId];
        if (chefId == 2) return [625, 1800, 5600, 16800, 50600, 150000, 456000, 1200000][floorId];
        if (chefId == 3) return [780, 2300, 7000, 21000, 63000, 187000, 570000, 1560000][floorId];
        if (chefId == 4) return [970, 3000, 8700, 26000, 79000, 235000, 713000, 2000000][floorId];
        if (chefId == 5) return [1200, 3600, 11000, 33000, 98000, 293000, 890000, 2500000][floorId];
        revert("Incorrect chefId");
    }

    function getYield(uint256 floorId, uint256 chefId) internal pure returns (uint256) {
        if (chefId == 1) return [52, 170, 526, 1615, 4965, 15100, 48000, 137000][floorId];
        if (chefId == 2) return [66, 206, 657, 2017, 6230, 19000, 60500, 167000][floorId];
        if (chefId == 3) return [85, 265, 826, 2530, 7800, 23800, 76000, 221000][floorId];
        if (chefId == 4) return [107, 348, 1030, 3155, 9800, 30000, 96000, 287000][floorId];
        if (chefId == 5) return [134, 419, 1310, 4030, 12350, 38000, 121000, 365000][floorId];
        revert("Incorrect chefId");
    }
}