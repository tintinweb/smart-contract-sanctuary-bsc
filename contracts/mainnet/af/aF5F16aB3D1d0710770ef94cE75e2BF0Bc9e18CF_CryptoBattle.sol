/**
 *Submitted for verification at BscScan.com on 2022-11-02
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

contract CryptoBattle {
    using SafeMath for uint256;

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
        uint8[5] chefs;
    }

    mapping(address => Tower) public towers;

    uint256 public startDate;
    address payable public WALLET_PROJECT;
    address payable public WALLET_MARKETING;
    address payable public WALLET_FUND;
    address payable public WALLET_SPONSOR;

    uint256 public constant PROJECT_FEE = 30; // project fee 3% of deposit
    uint256 public constant MARKETING_FEE = 30; // marketing fee 3% of deposit
    uint256 public constant FUND_FEE = 30; // fund fee 3% of deposit
    uint256 public constant SPONSOR_FEE = 30; // sponsor fee 3% of deposit

    uint256 public constant FEE_C = 15; // project fee 1.5% of crystals

    uint256 public constant PERCENTS_DIVIDER = 1000;

    uint256 public totalChefs;
    uint256 public totalTowers;
    uint256 public totalInvested;

    uint256 public immutable denominator = 10;
    bool public init;

    modifier initialized() {
        require(init, "Not initialized");
        _;
    }

    event FeePayed(address indexed user, uint256 totalAmount);

    constructor(
        address payable _walletMarketing,
        address payable _walletFund,
        address payable _walletSponsor,
        uint256 startTime
    ) {
        require(
            _walletMarketing != address(0) &&
                _walletFund != address(0) &&
                _walletSponsor != address(0)
        );

        WALLET_PROJECT = payable(msg.sender);
        WALLET_MARKETING = _walletMarketing;
        WALLET_FUND = _walletFund;
        WALLET_SPONSOR = _walletSponsor;

        if (startTime > 0) {
            startDate = startTime;
        } else {
            startDate = block.timestamp;
        }
    }

    function initializeAuto() internal {
        require(!init);
        init = true;
    }

    function UpdateStartDate(uint256 _startDate) public {
        require(
            msg.sender == WALLET_PROJECT,
            "Only developer can update start date"
        );
        require(block.timestamp < startDate, "Start date must be in future");
        require(!init);
        startDate = _startDate;
    }

    function FeePayout(uint256 msgValue, uint256 crystl) internal {
        uint256 pFee = msgValue.mul(PROJECT_FEE).div(PERCENTS_DIVIDER);
        uint256 fFee = msgValue.mul(FUND_FEE).div(PERCENTS_DIVIDER);
        uint256 mFee = msgValue.mul(MARKETING_FEE).div(PERCENTS_DIVIDER);
        uint256 sFee = msgValue.mul(SPONSOR_FEE).div(PERCENTS_DIVIDER);

        WALLET_PROJECT.transfer(pFee);
        WALLET_FUND.transfer(fFee);
        WALLET_MARKETING.transfer(mFee);
        WALLET_SPONSOR.transfer(sFee);

        towers[WALLET_PROJECT].crystals += crystl.mul(FEE_C).div(
            PERCENTS_DIVIDER
        );

        towers[WALLET_FUND].crystals += crystl.mul(FEE_C).div(PERCENTS_DIVIDER);

        towers[WALLET_MARKETING].crystals += crystl.mul(FEE_C).div(
            PERCENTS_DIVIDER
        );

        towers[WALLET_SPONSOR].crystals += crystl.mul(FEE_C).div(
            PERCENTS_DIVIDER
        );

        emit FeePayed(msg.sender, pFee.add(fFee).add(mFee).add(sFee));
    }

    function addCrystals(address ref) external payable {
        require(block.timestamp > startDate, "Contract does not launch yet");
        if (block.timestamp > startDate && !init) {
            initializeAuto();
        }
        uint256 crystals = msg.value / 5e14;
        require(crystals > 0, "Zero crystals");
        address user = msg.sender;
        totalInvested += msg.value;
        if (towers[user].timestamp == 0) {
            totalTowers++;
            ref = towers[ref].timestamp == 0 ? WALLET_PROJECT : ref;
            towers[ref].refs++;
            towers[user].ref = ref;
            towers[user].timestamp = block.timestamp;
            towers[user].treasury = 0;
        }
        ref = towers[user].ref;
        towers[ref].crystals += (crystals * 8) / 100;
        towers[ref].money += (crystals * 100 * 4) / 100;
        towers[ref].refDeps += crystals;
        towers[user].crystals += crystals;

        FeePayout(msg.value, crystals);
    }

    function withdrawMoney(uint256 gold) external initialized {
        address user = msg.sender;
        require(gold <= towers[user].money && gold > 0);
        towers[user].money -= gold;
        uint256 amount = gold * 5e12;
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
        syncTower(user);
        towers[user].chefs[towerId]++;
        totalChefs++;
        uint256 chefs = towers[user].chefs[towerId];
        towers[user].crystals -= getUpgradePrice(towerId, chefs) / denominator;
        towers[user].yield += getYield(towerId, chefs);
    }

    function upgradeTreasury() external {
        address user = msg.sender;
        uint8 treasuryId = towers[user].treasury + 1;
        syncTower(user);
        require(treasuryId < 5, "Max 5 treasury");
        (uint256 price, ) = getTreasure(treasuryId);
        towers[user].crystals -= price / denominator;
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

    function getChefs(address addr) external view returns (uint8[5] memory) {
        return towers[addr].chefs;
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
        if (chefId == 1) return [400, 4000, 12000, 24000, 40000][towerId];
        if (chefId == 2) return [600, 6000, 18000, 36000, 60000][towerId];
        if (chefId == 3) return [900, 9000, 27000, 54000, 90000][towerId];
        if (chefId == 4) return [1360, 13500, 40500, 81000, 135000][towerId];
        if (chefId == 5) return [2040, 20260, 60760, 121500, 202500][towerId];
        if (chefId == 6) return [3060, 30400, 91140, 182260, 303760][towerId];
        revert("Incorrect chefId");
    }

    function getYield(uint256 towerId, uint256 chefId)
        internal
        pure
        returns (uint256)
    {
        if (chefId == 1) return [5, 56, 179, 382, 678][towerId];
        if (chefId == 2) return [8, 85, 272, 581, 1030][towerId];
        if (chefId == 3) return [12, 128, 413, 882, 1564][towerId];
        if (chefId == 4) return [18, 195, 628, 1340, 2379][towerId];
        if (chefId == 5) return [28, 297, 954, 2035, 3620][towerId];
        if (chefId == 6) return [42, 450, 1439, 3076, 5506][towerId];
        revert("Incorrect chefId");
    }

    function getTreasure(uint256 treasureId)
        internal
        pure
        returns (uint256, uint256)
    {
        if (treasureId == 0) return (0, 24); // price | value
        if (treasureId == 1) return (2000, 30);
        if (treasureId == 2) return (2500, 36);
        if (treasureId == 3) return (3000, 42);
        if (treasureId == 4) return (4000, 48);
        revert("Incorrect treasureId");
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}