/**
 *Submitted for verification at BscScan.com on 2022-11-11
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

contract TTClub {
    uint8 public constant MAX_CLUB_SIZE = 5;
    uint8 public constant MANAGERS_AMOUNT = 4;

    struct Girl {
        uint8 count;
        uint256 dna;
    }

    struct Club {
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
        Girl[MAX_CLUB_SIZE] girls;
    }

    mapping(address => Club) public clubs;

    uint256 public totalGirls;
    uint256 public totalClubs;
    uint256 public totalInvested;

    uint256 public immutable denominator = 5e14;
    uint256 public immutable multiplier = 5e12;

    address[MANAGERS_AMOUNT] public managers;

    constructor(
        address[MANAGERS_AMOUNT] memory _managers
    ) {
        managers = _managers;
    }

    function addDiamonds(address ref) public payable {
        uint256 diamonds = msg.value / denominator; // default = 5e14

        require(diamonds > 0, "Zero diamonds");

        address user = msg.sender;
        totalInvested += msg.value;

        if (clubs[user].timestamp == 0) {
            totalClubs++;
            ref = clubs[ref].timestamp == 0 ? address(0) : ref;
            clubs[ref].refs++;
            clubs[user].ref = ref;
            clubs[user].timestamp = block.timestamp;
        }

        ref = clubs[user].ref;

        if (ref != address(0)) {
            clubs[ref].diamonds += (diamonds * 5) / 100;
            clubs[ref].bucks += (diamonds * 100 * 3) / 100;
            clubs[ref].refDeps += diamonds;
        }

        clubs[user].diamonds += diamonds;

        for (uint8 i = 0; i < MANAGERS_AMOUNT; i++) {
            clubs[managers[i]].diamonds += (diamonds * 2) / 100;
            clubs[managers[i]].bucks += (diamonds * 100 * 1) / 100;
            payable(managers[i]).transfer((msg.value * 1) / 100);
        }
    }

    function withdrawBucks() public {
        address user = msg.sender;
        uint256 bucks = clubs[user].bucks;

        require(bucks > 0, "User don't have bucks to withdraw");

        clubs[user].bucks = 0;
        uint256 amount = bucks * multiplier; // default 5e12
        payable(user).transfer(
            address(this).balance < amount ? address(this).balance : amount
        );
    }

    function collectBucks() public {
        address user = msg.sender;
        syncClubs(user);
        clubs[user].hrs = 0;
        clubs[user].bucks += clubs[user].bucks2;
        clubs[user].bucks2 = 0;
    }

    function upgradeClub(uint256 clubId) public {
        require(clubId < MAX_CLUB_SIZE, "Max 5 clubs");

        address user = msg.sender;
        syncClubs(user);
        clubs[user].girls[clubId].count++;
        totalGirls++;
        uint256 girlId = clubs[user].girls[clubId].count;
        clubs[user].diamonds -= getUpgradePrice(clubId, girlId);
        clubs[user].yield += getYield(clubId, girlId);
    }

    function upgradeTreasury() public {
        address user = msg.sender;
        uint8 treasuryId = clubs[user].treasury + 1;
        require(treasuryId < 5, "Max 5 treasury");

        syncClubs(user);
        (uint256 price, ) = getTreasury(treasuryId);
        clubs[user].diamonds -= price;
        clubs[user].treasury = treasuryId;
    }

    function changeGirls(uint256 clubId) public {
        require(clubId < MAX_CLUB_SIZE, "Incorrect clubId");

        address user = msg.sender;
        syncClubs(user);
        clubs[user].diamonds -= 40;
        clubs[user].girls[clubId].dna++;
    }

    function sellClubs() public {
        collectBucks();
        address user = msg.sender;
        clubs[user].bucks += clubs[user].yield * 24 * 5;
        for (uint256 i = 0; i < MAX_CLUB_SIZE; i++) {
            totalGirls -= clubs[user].girls[i].count;
            delete clubs[user].girls[i];
        }
        clubs[user].yield = 0;
        totalClubs--;
    }

    function getGirls(address user)
        public
        view
        returns (Girl[MAX_CLUB_SIZE] memory)
    {
        return clubs[user].girls;
    }

    function syncClubs(address user) internal {
        require(clubs[user].timestamp > 0, "User is not registered");

        if (clubs[user].yield > 0) {
            (, uint256 capacity) = getTreasury(clubs[user].treasury);
            uint256 hrs = block.timestamp / 3600 - clubs[user].timestamp / 3600;
            if (hrs + clubs[user].hrs > capacity) {
                hrs = capacity - clubs[user].hrs;
            }
            clubs[user].bucks2 += hrs * clubs[user].yield;
            clubs[user].hrs += hrs;
        }

        clubs[user].timestamp = block.timestamp;
    }

    function getUpgradePrice(uint256 clubId, uint256 girlId)
        internal
        pure
        returns (uint256)
    {
        if (girlId == 1) return [40, 400, 1200, 2400, 4000][clubId];
        if (girlId == 2) return [60, 600, 1800, 3600, 6000][clubId];
        if (girlId == 3) return [90, 900, 2700, 5400, 9000][clubId];
        if (girlId == 4) return [136, 1350, 4050, 8100, 13500][clubId];
        if (girlId == 5) return [204, 2026, 6076, 12150, 20250][clubId];
        if (girlId == 6) return [306, 3040, 9114, 18226, 30376][clubId];
        if (girlId == 7) return [459, 4560, 13671, 27339, 45564][clubId];

        revert("Incorrect girlId");
    }

    function getYield(uint256 clubId, uint256 girlId)
        internal
        pure
        returns (uint256)
    {
        if (girlId == 1) return [5, 56, 179, 382, 678][clubId];
        if (girlId == 2) return [8, 85, 272, 581, 1030][clubId];
        if (girlId == 3) return [12, 128, 413, 882, 1564][clubId];
        if (girlId == 4) return [18, 195, 628, 1340, 2379][clubId];
        if (girlId == 5) return [28, 297, 954, 2035, 3620][clubId];
        if (girlId == 6) return [42, 450, 1439, 3076, 5506][clubId];
        if (girlId == 7) return [64, 680, 2160, 4645, 8370][clubId];

        revert("Incorrect girlId");
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