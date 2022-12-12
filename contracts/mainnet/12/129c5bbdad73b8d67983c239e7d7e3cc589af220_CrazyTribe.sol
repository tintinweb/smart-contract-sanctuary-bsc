/**
 *Submitted for verification at BscScan.com on 2022-12-12
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract CrazyTribe {
    struct Tribe {
        uint256 diamonds;
        uint256 golds;
        uint256 uncollectedGold;
        uint256 yield;
        uint256 timestamp;
        uint256 hrs;
        address ref;
        uint256 refCount;
        uint256 refDeps;
        uint8[9] miners;
    }
    mapping(address => Tribe) public tribes;
    uint256 public totalMiners;
    uint256 public totalTribes;
    uint256 public totalInvested;
    address public FEE_ADDRESS = 0x3f197fb50B327df00c280b93DD166304490191b5;

    function addDiamond(address ref) public payable {
        uint256 diamonds = msg.value / 25e12;
        require(diamonds > 0, "Insufficient diamond");
        address user = msg.sender;
        totalInvested += msg.value;
        if (tribes[user].timestamp == 0) {
            totalTribes++;
            ref = tribes[ref].timestamp == 0 ? FEE_ADDRESS : ref;
            tribes[ref].refCount++;
            tribes[user].ref = ref;
            tribes[user].timestamp = block.timestamp;
        }
        ref = tribes[user].ref;
        tribes[ref].diamonds += (diamonds * 7) / 100;
        tribes[ref].golds += diamonds * 3;
        tribes[ref].refDeps += diamonds;
        tribes[user].diamonds += diamonds;
        payable(FEE_ADDRESS).transfer((msg.value * 5) / 100);

        emit UserAddDiamond(diamonds);
    }

    function withdrawGold() public {
        address user = msg.sender;
        uint256 gold = tribes[user].golds;
        tribes[user].golds = 0; 
        uint256 amount = gold * 25e10;
        if (amount > address(this).balance) amount = address(this).balance;
        payable(user).transfer(amount);

        emit UserWithdrawGold(amount);
    }

    function convertGoldToDiamonds() public {
        address user = msg.sender;
        uint256 gold = tribes[user].golds;
        uint256 diamondAmount = gold / 100 + (gold * 6) / 10000;
        tribes[user].golds = 0; 
        tribes[user].diamonds += diamondAmount;

        emit UserConvertGoldToDiamond(diamondAmount);
    }

    function collectGold() public {
        address user = msg.sender;
        syncTribe(user);
        tribes[user].hrs = 0;
        uint256 collectAmount = tribes[user].uncollectedGold;
        tribes[user].uncollectedGold = 0;

        tribes[user].golds += collectAmount;

        emit UserCollectGold(collectAmount);
    }

    function upgradeTribe(uint256 minesId) public {
        require(minesId < 9, "Max 9 mines");
        address user = msg.sender;
        syncTribe(user);
        tribes[user].miners[minesId]++;
        totalMiners++;
        uint256 minerCount = tribes[user].miners[minesId];
        tribes[user].diamonds -= getUpgradePrice(minesId, minerCount);
        tribes[user].yield += getYield(minesId, minerCount);

        emit UserUpgradeTribe(minesId);
    }

    function sellTribe() public {
        address user = msg.sender;
        collectGold();
        uint8[9] memory miners = tribes[user].miners;
        totalMiners -= miners[0] + miners[1] + miners[2] + miners[3] + miners[4] + miners[5] + miners[6] + miners[7] + miners[8];
        tribes[user].golds += tribes[user].yield * 24 * 14;
        tribes[user].miners = [0, 0, 0, 0, 0, 0, 0, 0, 0];
        tribes[user].yield = 0;
        emit UserSellTribe();
    }

    function getMiners(address user) public view returns (uint8[9] memory) {
        return tribes[user].miners;
    }

    function syncTribe(address user) internal {
        require(tribes[user].timestamp > 0, "User is not registered");
        if (tribes[user].yield > 0) {
            uint256 hrs = block.timestamp / 3600 - tribes[user].timestamp / 3600;
            if (hrs + tribes[user].hrs > 24) {
                hrs = 24 - tribes[user].hrs;
            }
            tribes[user].uncollectedGold += hrs * tribes[user].yield;
            tribes[user].hrs += hrs;
        }
        tribes[user].timestamp = block.timestamp;
    }

    function getUpgradePrice(uint256 minesId, uint256 minerId) internal pure returns (uint256) {
        if (minerId == 1) return [760, 2280, 6840, 20520, 61560, 182400, 554800, 1520000, 4271200][minesId];
        if (minerId == 2) return [950, 2736, 8512, 25536, 76912, 228000, 693120, 1824000, 5122400][minesId];
        if (minerId == 3) return [1186, 3496, 10640, 31920, 95760, 284240, 866400, 2371200, 6657600][minesId];
        if (minerId == 4) return [1474, 4560, 13224, 39520, 120080, 357200, 1083760, 3040000, 8542400][minesId];
        if (minerId == 5) return [1824, 5472, 16720, 50160, 148960, 445360, 1352800, 3800000, 10640000][minesId];
        revert("Incorrect minerId");
    }

    function getYield(uint256 minesId, uint256 minerId) internal pure returns (uint256) {
        if (minerId == 1) return [67, 212, 649, 1983, 6085, 18468, 58492, 167580, 503975][minesId];
        if (minerId == 2) return [85, 256, 810, 2485, 7625, 23161, 73492, 203680, 615695][minesId];
        if (minerId == 3) return [106, 327, 1017, 3118, 9567, 28985, 92359, 268660, 812250][minesId];
        if (minerId == 4) return [134, 430, 1268, 3865, 11999, 36737, 116974, 348080, 1058110][minesId];
        if (minerId == 5) return [168, 518, 1617, 4950, 15067, 46408, 147535, 441750, 1352420][minesId];
        revert("Incorrect minerId");
    }

    event UserAddDiamond(uint256 diamondsReceived);
    event UserCollectGold(uint256 amountCollected);
    event UserConvertGoldToDiamond(uint256 diamondsConverted);
    event UserWithdrawGold(uint256 amount);
    event UserUpgradeTribe(uint256 minesId);
    event UserSellTribe();

}