/**
 *Submitted for verification at BscScan.com on 2022-11-15
*/

// File: contracts/interfaces/ITheOilIndustry.sol


pragma solidity ^0.8.16;
pragma abicoder v2;

interface ITheOilIndustry {
    struct Tower {
        uint256 coins;
        uint256 money;
        uint256 money2;
        uint256 yield;
        uint256 timestamp;
        uint256 hrs;
        address ref;
        uint256 refs;
        uint256 refDeps;
        uint8[8] Workers;
    }

    function sumtotalInvested(uint value ) external;
    function sumTotalTowers() external;


    function tCoins(address user, uint coin) external;
    function tCoinsRest(address user, uint coin) external;
    function tmoney(address user, uint coin) external;
    function tmoney2(address user,uint money) external;
    function ttimestamp(address user, uint time) external;
    function tyield(address user, uint yield) external;
    function tyieldSet(address user, uint yield) external;
    function tref(address user, address ref) external;
    function thrs(address user,uint hrs) external;
    function trefs(address user) external;
    function trefDeps(address user, uint coins) external;
    function tWorkers(address user, uint floorId) external;
    function tWorkersDelete(address user) external;
    
    function tmoneyWithdraw(address user, uint money) external;
    function thrsSet(address user, uint hrs)external;
    function tmoney2Set(address user, uint money) external ;
    function totalWorkersPlus(uint plus) external;
    function totalWorkersSub(uint sub) external;

    // view Functions
    function viewTower(address user) external  view returns(Tower memory);
}
// File: contracts/oil.sol


pragma solidity ^0.8.16;


contract TheOilIndustry {
    ITheOilIndustry public oilData;
    struct Tower {
        uint256 coins;
        uint256 money;
        uint256 money2;
        uint256 yield;
        uint256 timestamp;
        uint256 hrs;
        address ref;
        uint256 refs;
        uint256 refDeps;
        uint8[8] Workers;
    }
    address manager = msg.sender;

    constructor (ITheOilIndustry _newOil) {
        oilData = _newOil;
    }

    function addCoins(address ref) public payable {
        uint256 coins = msg.value / 2e13;
        require(coins > 0, "Zero coins");
        address user = msg.sender;
        oilData.sumtotalInvested(msg.value);
        ITheOilIndustry.Tower memory userTower = oilData.viewTower(msg.sender);
        if (userTower.timestamp == 0) {
            oilData.sumTotalTowers();
            ref = userTower.timestamp == 0 ? manager : ref;
            oilData.trefs(ref);
            oilData.tref(user, ref);
            oilData.ttimestamp(user, block.timestamp);
        }
        userTower = oilData.viewTower(msg.sender);
        ref = userTower.ref;
        oilData.tCoins(ref, ((coins * 7) / 100));
        oilData.tmoney(ref, ((coins * 100 * 3) / 100));
        oilData.trefDeps(ref, coins);
        oilData.tCoins(user,coins);
        payable(manager).transfer((msg.value * 3) / 100);
    }

    function withdrawMoney() public {
        address user = msg.sender;
        ITheOilIndustry.Tower memory userTower = oilData.viewTower(msg.sender);

        uint256 money = userTower.money;
        oilData.tmoney(user,0);        
        uint256 amount = money * 2e11;
        payable(user).transfer(address(this).balance < amount ? address(this).balance : amount);
    }

    function collectMoney() public {
        address user = msg.sender;
        syncTower(user);
        ITheOilIndustry.Tower memory userTower = oilData.viewTower(msg.sender);
        

        oilData.thrsSet(user, 0);
        // towers[user].hrs = 0;
        oilData.tmoney(user, userTower.money2);
        // towers[user].money += towers[user].money2;
        oilData.tmoney2Set(user, 0);
        // towers[user].money2 = 0;
    }

    function upgradeTower(uint256 floorId) public {
        require(floorId < 8, "Max 8 floors");
        address user = msg.sender;
        syncTower(user);
        oilData.totalWorkersPlus(1);
        // totalWorkers++;
        oilData.tWorkers(user,floorId);
        ITheOilIndustry.Tower memory userTower = oilData.viewTower(msg.sender);
        // towers[user].Workers[floorId]++;
        uint256 Workers = userTower.Workers[floorId];
        oilData.tCoinsRest(user, getUpgradePrice(floorId, Workers));
        // towers[user].coins -= getUpgradePrice(floorId, Workers);
        oilData.tyield(user, getYield(floorId, Workers));
        // towers[user].yield += getYield(floorId, Workers);
    }
    
    

    function sellTower() public {
        collectMoney();
        address user = msg.sender;
        uint8[8] memory Workers = getWorkers(user);
        oilData.totalWorkersSub ( Workers[0] + Workers[1] + Workers[2] + Workers[3] + Workers[4] + Workers[5] + Workers[6] + Workers[7]);
        ITheOilIndustry.Tower memory userTower = oilData.viewTower(user);
        oilData.tmoney(user, userTower.yield *24*14);
        // towers[user].money += towers[user].yield * 24 * 14;
        oilData.tWorkersDelete(user);
        // towers[user].Workers = [0, 0, 0, 0, 0, 0, 0, 0];
        oilData.tyieldSet(user, 0);
        // towers[user].yield = 0;
    }

    function works(uint256 floorId)public view returns(uint256){
        ITheOilIndustry.Tower memory userTower = oilData.viewTower(msg.sender);
        return userTower.Workers[floorId];
    }

    function getWorkers(address addr) public view returns (uint8[8] memory) {
        ITheOilIndustry.Tower memory userTower = oilData.viewTower(addr);
        return userTower.Workers;
    }

    function syncTower(address user) internal {
        ITheOilIndustry.Tower memory userTower = oilData.viewTower(msg.sender);
        require(userTower.timestamp > 0, "User is not registered");
        if (userTower.yield > 0) {
            uint256 hrs = block.timestamp / 3600 - userTower.timestamp / 3600;
            if (hrs + userTower.hrs > 24) {
                hrs = 24 -userTower.hrs;
            }
            oilData.tmoney2(user,hrs * userTower.yield);
            // towers[user].money2 += hrs * towers[user].yield;
            oilData.thrs(user, hrs);
            // towers[user].hrs += hrs;
        }
        oilData.ttimestamp(user, block.timestamp);
        // towers[user].timestamp = block.timestamp;
    }

    function getUpgradePrice(uint256 floorId, uint256 workerId) internal pure returns (uint256) {
        if (workerId == 1) return [500, 1500, 4500, 13500, 40500, 120000, 365000, 1000000][floorId];
        if (workerId == 2) return [625, 1800, 5600, 16800, 50600, 150000, 456000, 1200000][floorId];
        if (workerId == 3) return [780, 2300, 7000, 21000, 63000, 187000, 570000, 1560000][floorId];
        if (workerId == 4) return [970, 3000, 8700, 26000, 79000, 235000, 713000, 2000000][floorId];
        if (workerId == 5) return [1200, 3600, 11000, 33000, 98000, 293000, 890000, 2500000][floorId];
        revert("Incorrect workerId PRICE");
    }

    function getYield(uint256 floorId, uint256 workerId) internal pure returns (uint256) {
        if (workerId == 1) return [41, 130, 399, 1220, 3750, 11400, 36200, 104000][floorId];
        if (workerId == 2) return [52, 157, 498, 1530, 4700, 14300, 45500, 126500][floorId];
        if (workerId == 3) return [65, 201, 625, 1920, 5900, 17900, 57200, 167000][floorId];
        if (workerId == 4) return [82, 264, 780, 2380, 7400, 22700, 72500, 216500][floorId];
        if (workerId == 5) return [103, 318, 995, 3050, 9300, 28700, 91500, 275000][floorId];
        revert("Incorrect workerId YIELD");
    }
}