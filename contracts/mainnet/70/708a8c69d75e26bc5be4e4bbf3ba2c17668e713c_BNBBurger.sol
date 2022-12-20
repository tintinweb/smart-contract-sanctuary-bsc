/**
 *Submitted for verification at BscScan.com on 2022-12-19
*/

/**
	Website: https://bnbburger.co/
	Telegram: https://t.me/bnbburger_p2e
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

contract BNBBurger {
    uint8 public constant MAX_COUNTRY_SIZE = 5;
    
    struct Truck {
        uint8 count;
        uint256 dna;
    }

    struct Franchise {
        uint256 diamonds;
        uint256 bucks;
        uint256 bucks2;
        uint256 yield;
        uint256 timestamp;
        uint256 hrs;
        address ref;
        uint256 refs;
        uint256 refDeps;
        uint8 treasury;
        Truck[MAX_COUNTRY_SIZE] trucks;
    }

    mapping(address => Franchise) public franchises;

    uint256 public totalTrucks;
    uint256 public totalFranchises;
    uint256 public totalInvested;

    uint256 public immutable denominator = 5e14;
    uint256 public immutable multiplier = 5e12;

    address public manager;

    constructor(address _managers) {
        manager = _managers;
    }

    function addDiamonds(address ref) public payable {
        uint256 diamonds = msg.value / denominator; // default = 5e14
        address user = msg.sender;

        totalInvested += msg.value;

        if (franchises[user].timestamp == 0) {
            totalFranchises++;
            ref = franchises[ref].timestamp == 0 ? address(0) : ref;
            franchises[ref].refs++;
            franchises[user].ref = ref;
            franchises[user].timestamp = block.timestamp;
        }

        ref = franchises[user].ref;

        if (ref != address(0)) {
            franchises[ref].diamonds += (diamonds * 6) / 100;
            franchises[ref].bucks += (diamonds * 100 * 6) / 100;
            franchises[ref].refDeps += diamonds;
        }

        franchises[user].diamonds += diamonds;

    	payable(manager).transfer((msg.value * 6) / 100);
        
    }

    function withdrawBucks() public {
        address user = msg.sender;
        uint256 bucks = franchises[user].bucks;

        require(bucks > 0, "User don't have bucks to withdraw");

        franchises[user].bucks = 0;
        uint256 amount = bucks * multiplier; // default 5e12
        payable(user).transfer(
            address(this).balance < amount ? address(this).balance : amount
        );
    }

    function collectBucks() public {
        address user = msg.sender;
        syncFranchises(user);
        franchises[user].hrs = 0;
        franchises[user].bucks += franchises[user].bucks2;
        franchises[user].bucks2 = 0;
    }

    function upgradeFranchise(uint256 franchiseId) public {
        require(franchiseId < MAX_COUNTRY_SIZE, "Max 5 franchises");

        address user = msg.sender;
        syncFranchises(user);
        franchises[user].trucks[franchiseId].count++;
        totalTrucks++;
        uint256 truckId = franchises[user].trucks[franchiseId].count;
        franchises[user].diamonds -= getUpgradePrice(franchiseId, truckId);
        franchises[user].yield += getYield(franchiseId, truckId);
    }

    function upgradeTreasury() public {
        address user = msg.sender;
        uint8 treasuryId = franchises[user].treasury + 1;
        require(treasuryId < 5, "Max 5 treasury");

        syncFranchises(user);
        (uint256 price, ) = getTreasury(treasuryId);
        franchises[user].diamonds -= price;
        franchises[user].treasury = treasuryId;
    }

   

    function sellFranchises() public {
        collectBucks();
        address user = msg.sender;
        franchises[user].bucks += franchises[user].yield * 24 * 5;
        for (uint256 i = 0; i < MAX_COUNTRY_SIZE; i++) {
            totalTrucks -= franchises[user].trucks[i].count;
            delete franchises[user].trucks[i];
        }
        franchises[user].yield = 0;
        totalFranchises--;
    }

    function getTrucks(address user)
        public
        view
        returns (Truck[MAX_COUNTRY_SIZE] memory)
    {
        return franchises[user].trucks;
    }

    function syncFranchises(address user) internal {
        require(franchises[user].timestamp > 0, "User is not registered");

        if (franchises[user].yield > 0) {
            (, uint256 capacity) = getTreasury(franchises[user].treasury);
            uint256 hrs = block.timestamp / 3600 - franchises[user].timestamp / 3600;
            if (hrs + franchises[user].hrs > capacity) {
                hrs = capacity - franchises[user].hrs;
            }
            franchises[user].bucks2 += hrs * franchises[user].yield;
            franchises[user].hrs += hrs;
        }

        franchises[user].timestamp = block.timestamp;
    }

    function getUpgradePrice(uint256 franchiseId, uint256 truckId)
        internal
        pure
        returns (uint256)
    {
        if (truckId == 1) return [40, 400, 1200, 2400, 4000][franchiseId];
        if (truckId == 2) return [60, 600, 1800, 3600, 6000][franchiseId];
        if (truckId == 3) return [90, 900, 2700, 5400, 9000][franchiseId];
        if (truckId == 4) return [136, 1350, 4050, 8100, 13500][franchiseId];
        if (truckId == 5) return [204, 2026, 6076, 12150, 20250][franchiseId];
        if (truckId == 6) return [306, 3040, 9114, 18226, 30376][franchiseId];
        
        revert("Incorrect truckId");
    }

    function getYield(uint256 franchiseId, uint256 truckId)
        internal
        pure
        returns (uint256)
    {
        if (truckId == 1) return [5, 56, 179, 382, 678][franchiseId];
        if (truckId == 2) return [8, 85, 272, 581, 1030][franchiseId];
        if (truckId == 3) return [12, 128, 413, 882, 1564][franchiseId];
        if (truckId == 4) return [18, 195, 628, 1340, 2379][franchiseId];
        if (truckId == 5) return [28, 297, 954, 2035, 3620][franchiseId];
        if (truckId == 6) return [42, 450, 1439, 3076, 5506][franchiseId];
      
        revert("Incorrect truckId");
    }

    function getTreasury(uint256 treasuryId)
        internal
        pure
        returns (uint256, uint256)
    {
        if (treasuryId == 0) return (0, 24); // price | capacity
        if (treasuryId == 1) return (200, 30);
        if (treasuryId == 2) return (250, 36);
        if (treasuryId == 3) return (300, 42);
        if (treasuryId == 4) return (400, 48);

        revert("Incorrect treasuryId");
    }





}