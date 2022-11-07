/**
 *Submitted for verification at BscScan.com on 2022-11-07
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

contract XXXX {  
    struct Village {
        uint256 gems;
        uint256 money;
        uint256 money2;
        uint256 yield;
        uint256 timestamp;
        uint256 hrs;
        address neighbor;
        uint256 neighbors;
        uint256 neighborDeps;
        uint8 warehouse;
        uint8 truck;    
        uint8 farm;
        uint8[6] sheeps;
        bool topLeader;
        bool isGiveAway;
    }

    struct Neighbor {
        uint256 gems;
        uint256 wools;
    }

    mapping(address => Village) public villages;
    mapping(address => Neighbor) public neighborsInfo;

    uint256 public totalSheeps;
    uint256 public totalVillages;
    uint256 public totalInvested;
    address private manager;
    address private marketWallet;
    address private devWallet;

    uint256 public immutable denominator = 10;
    uint256 public immutable GEM_BONUS = 10;
    uint256 public immutable CONVERT_BONUS = 50;
    uint256 public immutable OWNER_ETHER_FEE = 5;
    uint256 public immutable OWNER_GEM_FEE = 8;
    uint256 public immutable OWNER_WITHDRAW_FEE = 2;
    uint256 public immutable LEADER_EXTRA_BONUS = 2;
    uint256 public immutable REF_GEM_BONUS = 8;
    uint256 public immutable REF_WOOL_BONUS = 4;
    uint256 public immutable PERCENT_DIVIDER = 1000;
    uint256 public immutable MAX_GIVEAWAY = 100;

    bool public init;

    event Newbie(address indexed user, uint256 bonus);
    event VillageUpgraded(address indexed user, uint256 yield, uint256 farm, uint256 time);
    event WarehouseUpgraded(address indexed user, uint8 warehouseId, uint256 time);
    event TruckUpgraded(address indexed user, uint8 truckId, uint256 time);
    event BuyGem(address indexed user, uint256 amount, uint256 gem, uint256 time);
    event SellWool(address indexed user, uint256 wool, uint256 time);
    event SellVillage(address indexed user, uint256 time);
    event ConvertWool(address indexed user, uint256 wool, uint256 gem, uint256 time);

    modifier initialized() {
        require(init, "Not initialized");
        _;
    }

    constructor(address manager_) {
        manager = manager_;
        marketWallet = address(0x65C0Ff0390ab4084181855929cFD3d2b5f272DA6); //testnet
        devWallet = address(0x984637794586129a5f23E5Ad581D879eA9067000); //testnet
    }

    function initialize() external {
        require(manager == msg.sender);
        require(!init);
        init = true;
    }

    function giveAway(address[] memory users, uint256 amount) external returns (bool){
        require(msg.sender == manager, "Only owner is allowed to giveaway");
        require(amount > 0 && amount <= MAX_GIVEAWAY, "Invalid amount");
        require(users.length > 0, "Array is empty");
        for(uint256 i = 0; i < users.length; i++){
            if(users[i] != address(0) && !villages[users[i]].isGiveAway && villages[users[i]].sheeps[0] > 0){
                villages[users[i]].gems += amount;
                villages[users[i]].isGiveAway = true;
            }
        }
        return true;
    }

    function register(address neighbor) external initialized {
        address user = msg.sender;
        require(villages[user].timestamp == 0, "just new users");
        uint256 gems;
        totalVillages++;
        if (villages[neighbor].sheeps[0] == 0) {
            neighbor = manager;
            gems += GEM_BONUS;
        } else if(neighbor != manager) {
            gems += GEM_BONUS * 2;
        }
        villages[neighbor].neighbors++;
        villages[user].neighbor = neighbor;
        villages[user].gems += gems;
        emit Newbie(msg.sender, gems);
    }

    function addGems() external payable initialized {
        //uint256 gems = msg.value / 5e14; mainnet
        uint256 gems = msg.value / 5e12; //testnet
        require(gems > 0, "Zero gems");
        address user = msg.sender;
        require(villages[user].neighbor != address(0), "first register");
        totalInvested += msg.value;
        if (villages[user].timestamp == 0) {
            villages[user].timestamp = block.timestamp;
        }
        address neighbor = villages[user].neighbor;
        uint256 RefGemBonus = REF_GEM_BONUS;
        uint256 RefWoolBonus = REF_WOOL_BONUS;
        if (villages[neighbor].topLeader) {
            RefGemBonus += LEADER_EXTRA_BONUS;
            RefWoolBonus += LEADER_EXTRA_BONUS;
        }
        villages[neighbor].gems += (gems * RefGemBonus) / 100;
        villages[neighbor].money += (gems * 100 * RefWoolBonus) / 100;
        neighborsInfo[neighbor].gems += (gems * RefGemBonus) / 100;
        neighborsInfo[neighbor].wools += (gems * 100 * RefWoolBonus) / 100;
        villages[neighbor].neighborDeps += gems;
        villages[user].gems += gems;
        villages[devWallet].gems += (gems * (OWNER_GEM_FEE / 2)) / 100;
        villages[marketWallet].gems += (gems * (OWNER_GEM_FEE / 2)) / 100;
        payable(devWallet).transfer((msg.value * (OWNER_ETHER_FEE / 2)) / 100);
        payable(marketWallet).transfer((msg.value * OWNER_ETHER_FEE / 2) / 100);
        emit BuyGem(msg.sender, msg.value, gems, block.timestamp);
    }

    function withdrawMoney(uint256 wool) external initialized {
        address user = msg.sender;
        require(wool <= villages[user].money && wool > 0);
        villages[user].money -= wool;
        //uint256 amount = wool * 5e12; mainnet
        uint256 amount = wool * 5e10; // testnet
        uint256 ownerFee = (amount * OWNER_WITHDRAW_FEE) / 100;
        payable(devWallet).transfer(ownerFee / 2);
        payable(marketWallet).transfer(ownerFee / 2);
        payable(user).transfer(
            address(this).balance < (amount - ownerFee)
                ? address(this).balance
                : (amount - ownerFee)
        );
        emit SellWool(msg.sender, wool, block.timestamp);
    }

    function convertWoolToGem(uint256 wool) external initialized {
        address user = msg.sender;
        uint256 Convertablewool = wool;
        require(
            Convertablewool <= villages[user].money && Convertablewool > 0,
            "not enough Wool"
        );
        villages[user].money -= Convertablewool;
        Convertablewool =
            Convertablewool +
            ((Convertablewool * CONVERT_BONUS) / PERCENT_DIVIDER);
        uint256 gemAmount = Convertablewool / 100;
        villages[user].gems += gemAmount;
        emit ConvertWool(msg.sender, wool, gemAmount, block.timestamp);
    }

    function collectMoney() public initialized {
        address user = msg.sender;
        syncVillage(user);
        villages[user].hrs = 0;
        villages[user].money += villages[user].money2;
        villages[user].money2 = 0;
    }

    function upgradeVillage(uint256 farmId) external initialized {
        require(farmId < 6, "Max 6 farm");
        address user = msg.sender;
        if (villages[user].sheeps[0] == 0) {
            require(farmId == 0, "Only first farm is available");
        }
        if (villages[user].farm < farmId) {
            villages[user].farm++;
            require(villages[user].farm == farmId, "farm is lock");
        }
        syncVillage(user);
        villages[user].sheeps[farmId]++;
        totalSheeps++;
        uint256 sheeps = villages[user].sheeps[farmId];
        villages[user].gems -= getUpgradePrice(farmId, sheeps) / denominator;
        villages[user].yield += getYield(farmId, sheeps);
        emit VillageUpgraded(msg.sender, villages[user].yield, villages[user].farm, block.timestamp);
    }

    function upgradeWarehouse() external initialized {
        address user = msg.sender;
        uint8 warehouseId = villages[user].warehouse + 1;
        syncVillage(user);
        require(warehouseId < 5, "Max 5 WareHouse");
        (uint256 gemPrice, uint256 woolPrice, ) = getWarehouse(warehouseId);
        villages[user].gems -= gemPrice / denominator;
        villages[user].money -= woolPrice / denominator;
        villages[user].warehouse = warehouseId;
        emit WarehouseUpgraded(msg.sender, warehouseId, block.timestamp);
    }

    function upgradeTruck() external initialized {
        address user = msg.sender;
        uint8 truckId = villages[user].truck + 1;
        syncVillage(user);
        require(truckId < 4, "Max 4 truck");
        (uint256 gemPrice, uint256 woolPrice, ) = getTruck(truckId);
        villages[user].gems -= gemPrice / denominator;
        villages[user].money -= woolPrice / denominator;
        villages[user].truck = truckId;
        emit TruckUpgraded(msg.sender, truckId, block.timestamp);
    }

    function sellVillage() external initialized {
        collectMoney();
        address user = msg.sender;
        uint8[6] memory sheeps = villages[user].sheeps;
        totalSheeps -=
            sheeps[0] +
            sheeps[1] +
            sheeps[2] +
            sheeps[3] +
            sheeps[4] +
            sheeps[5];
        villages[user].money += villages[user].yield * 24 * 5;
        villages[user].sheeps = [0, 0, 0, 0, 0, 0];
        villages[user].yield = 0;
        villages[user].warehouse = 0;
        villages[user].truck = 0;
        villages[user].farm = 0;
        emit SellVillage(msg.sender, block.timestamp);
    }

    function getSheeps(address user) external view returns (uint8[6] memory) {
        return villages[user].sheeps;
    }

    function syncVillage(address user) internal {
        require(villages[user].timestamp > 0, "User is not registered");
        if (villages[user].yield > 0) {
            (, , uint256 warehouse) = getWarehouse(villages[user].warehouse);
            //uint256 hrs = block.timestamp / 3600 - villages[user].timestamp / 3600; mainnet
            uint256 hrs = block.timestamp / 60 - villages[user].timestamp / 60; //testnet
            if (hrs + villages[user].hrs > warehouse) {
                hrs = warehouse - villages[user].hrs;
            }
            (, , uint256 truck) = getTruck(villages[user].truck);
            uint256 userYield = villages[user].yield +
                ((villages[user].yield * truck) / PERCENT_DIVIDER);
            villages[user].money2 += hrs * userYield;
            villages[user].hrs += hrs;
        }
        villages[user].timestamp = block.timestamp;
    }

    function getUpgradePrice(uint256 farmId, uint256 sheepId)
        internal
        pure
        returns (uint256)
    {
        if (sheepId == 1)
            return [400, 4000, 12000, 24000, 40000, 60000][farmId];
        if (sheepId == 2)
            return [600, 6000, 18000, 36000, 60000, 90000][farmId];
        if (sheepId == 3)
            return [900, 9000, 27000, 54000, 90000, 135000][farmId];
        if (sheepId == 4)
            return [1350, 13000, 40000, 81000, 135000, 202000][farmId];
        if (sheepId == 5)
            return [2000, 20000, 60000, 121000, 202000, 303000][farmId];
        if (sheepId == 6)
            return [3000, 30000, 91000, 182000, 303000, 455000][farmId];
        if (sheepId == 7)
            return [4500, 45000, 136000, 273000, 455000, 683000][farmId];
        if (sheepId == 8)
            return [6800, 68000, 205000, 410000, 683000, 1025000][farmId];
        if (sheepId == 9)
            return [10000, 102000, 307000, 615000, 1025000, 1537000][farmId];
        if (sheepId == 10)
            return [15000, 154000, 461000, 922000, 1537000, 2300000][farmId];
        revert("Incorrect sheepId");
    }

    function getYield(uint256 farmId, uint256 sheepId)
        internal
        pure
        returns (uint256)
    {
        if (sheepId == 1) return [5, 56, 179, 382, 678, 762][farmId];
        if (sheepId == 2) return [8, 85, 272, 581, 1030, 1142][farmId];
        if (sheepId == 3) return [12, 128, 413, 882, 1564, 1714][farmId];
        if (sheepId == 4) return [18, 195, 628, 1340, 2379, 2570][farmId];
        if (sheepId == 5) return [28, 297, 954, 2035, 3620, 3856][farmId];
        if (sheepId == 6) return [42, 450, 1439, 3076, 5506, 5783][farmId];
        if (sheepId == 7) return [63, 675, 2159, 4614, 8259, 8675][farmId];
        if (sheepId == 8) return [95, 1013, 3238, 6921, 12389, 13013][farmId];
        if (sheepId == 9) return [142, 1519, 4857, 10382, 18583, 19519][farmId];
        if (sheepId == 10)
            return [213, 2278, 7285, 15572, 27874, 29278][farmId];
        revert("Incorrect sheepId");
    }

    function getWarehouse(uint256 warehouseId)
        internal
        pure
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        if (warehouseId == 0) return (0, 0, 24); // price in gem | price in wool | value
        if (warehouseId == 1) return (2000, 0, 30);
        if (warehouseId == 2) return (2500, 0, 36);
        if (warehouseId == 3) return (3000, 20000, 42);
        if (warehouseId == 4) return (4000, 50000, 48);
        revert("Incorrect warehouseId");
    }

    function getTruck(uint256 truckId)
        internal
        pure
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        if (truckId == 0) return (0, 0, 0); // price in gem | price in wool | value
        if (truckId == 1) return (10000, 200000, 1);
        if (truckId == 2) return (40000, 1000000, 2);
        if (truckId == 3) return (100000, 3000000, 3);
        revert("Incorrect truckId");
    }

    function isTopLeader(address user) external view returns (bool status) {
        return villages[user].topLeader;
    }

    function topLeaderUpdate(address user, bool value) external {
        require(
            msg.sender == marketWallet,
            "Only owner is allowed to modify topLeader."
        );
        require(villages[user].topLeader != value, "same value");
        villages[user].topLeader = value;
    }

    function isRegister(address user) external view returns (bool) {
         if(villages[user].neighbor != address(0)){
             return true;
         }else{
             return false;
         }
    }

    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }
}