/**
 *Submitted for verification at BscScan.com on 2022-11-10
*/

pragma solidity ^0.8.16;

contract EnergyFarmers {
    struct Generator {
        uint256 energy;
        uint256 energyCoins;
        uint256 energyCoinsToCollect;
        uint256 yield;
        uint8[5] upgrade;
        uint256 timestamp;
        uint256 hrs;
        address referral;
        uint256 referrals;
        uint256 referralDeps;
    }

    
    uint256 public totalFarmers;
    uint256 public totalInvested;

    mapping(address => Generator) public generators;


    struct TaxWallets {
        address payable marketing;
        address payable development;
    }

    TaxWallets public taxWallets = TaxWallets({
        marketing: payable(0x8e649ccC56B6535d9aa95aaa17826385896F9240),
        development: payable(0x205e7AAF299dA7b4A3D5bA67aEBE15AEbb4531C3)
    });
    address public manager = msg.sender;

     function buyEnergy(address referral) public payable {
        uint256 energy = msg.value / 1e13;
        require(energy > 0, "Zero energy");
        address user = msg.sender;
        totalInvested += msg.value;
        if (generators[user].timestamp == 0) {
            totalFarmers++;
            referral = generators[referral].timestamp == 0 ? manager : referral;
            generators[referral].referrals++;
            generators[user].referral = referral;
            generators[user].timestamp = block.timestamp;
        }
        referral = generators[user].referral;
        generators[referral].energy += (energy * 5) / 100;
        generators[referral].energyCoins += (energy * 100 * 5) / 100;
        generators[referral].referralDeps += energy;
        generators[user].energy += energy;
        taxWallets.marketing.transfer((msg.value * 25) / 1000);
        taxWallets.development.transfer((msg.value * 25) / 1000);
    }

    function collectEnergyCoins() public {
        address user = msg.sender;
        syncGenerator(user);
        generators[user].hrs = 0;
        generators[user].energyCoins += generators[user].energyCoinsToCollect;
        generators[user].energyCoinsToCollect = 0;
    }

    function withdrawEnergyCoins() public {
        address user = msg.sender;
        uint256 energyCoins = generators[user].energyCoins;
        generators[user].energyCoins = 0;
        uint256 amount = energyCoins * 1e11;
        payable(user).transfer(address(this).balance < amount ? address(this).balance : amount);
        taxWallets.marketing.transfer(address(this).balance < amount ? (address(this).balance * 25) / 1000 : (amount * 25) / 1000);
        taxWallets.development.transfer(address(this).balance < amount ? (address(this).balance * 25) / 1000 : (amount * 25) / 1000);
    }

    function upgradeGenerator(uint256 generatorId) public {
        require(generatorId < 5, "Max 5 generators");
        address user = msg.sender;
        syncGenerator(user);
        generators[user].upgrade[generatorId]++;
        uint256 upgrade = generators[user].upgrade[generatorId];
        generators[user].energy -= getUpgradePrice(generatorId, upgrade);
        generators[user].yield += getYield(generatorId, upgrade);
    }

    function sellGenerators() public {
        collectEnergyCoins();
        address user = msg.sender;
        uint8[5] memory upgrade = generators[user].upgrade;
        generators[user].energyCoins += generators[user].yield * 240;
        generators[user].upgrade = [0, 0, 0, 0, 0];
        generators[user].yield = 0;
    }

    function syncGenerator(address user) internal {
        require(generators[user].timestamp > 0, "User doesn't exist");
        if (generators[user].yield > 0) {
            uint256 hrs = block.timestamp / 3600 - generators[user].timestamp / 3600;
            if (hrs + generators[user].hrs > 24) {
                hrs = 24 - generators[user].hrs;
            }
            generators[user].energyCoinsToCollect += hrs * generators[user].yield;
            generators[user].hrs += hrs;
        }
        generators[user].timestamp = block.timestamp;
    }

    function getUpgradePrice(uint256 generatorId, uint256 upgradeId) internal pure returns (uint256) {
        if (upgradeId == 1) return [0,    2500,  7500, 20000,  60000][generatorId];
        if (upgradeId == 2) return [1000, 3125,  9375, 25000,  75000][generatorId];
        if (upgradeId == 3) return [1250, 3910, 11800, 31250,  93750][generatorId];
        if (upgradeId == 4) return [1562, 4885, 14700, 39070, 117200][generatorId];
        if (upgradeId == 5) return [1953, 6100, 18150, 48900, 150000][generatorId];
        revert("Incorrect upgradeId");
    }

    function getYield(uint256 generatorId, uint256 upgradeId) internal pure returns (uint256) {
        if (upgradeId == 1) return [50, 219, 672, 1833, 5750][generatorId];
        if (upgradeId == 2) return [85, 273, 840, 2292, 7188][generatorId];
        if (upgradeId == 3) return [107, 342, 1057, 2865, 8984][generatorId];
        if (upgradeId == 4) return [133, 427, 1317, 3581, 11232][generatorId];
        if (upgradeId == 5) return [167, 534, 1626, 4483, 14375][generatorId];
        revert("Incorrect upgradeId");
    }

    function getupgrade(address addr) public view returns (uint8[5] memory) {
        return generators[addr].upgrade;
    }
}