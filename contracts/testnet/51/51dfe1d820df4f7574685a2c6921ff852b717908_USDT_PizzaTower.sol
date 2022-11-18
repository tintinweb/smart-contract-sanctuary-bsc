/**
 *Submitted for verification at BscScan.com on 2022-11-18
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-16
*/

/**
 *┌─────────────────────────────────────────────┐
 *│   Launch date: 11/19/2022 14:00:PM   UTC    │
 *│   Website: https://usdtpizza.com            │
 *└─────────────────────────────────────────────┘

██╗   ██╗███████╗██████╗ ████████╗    ██████╗ ██╗███████╗███████╗ █████╗     ████████╗ ██████╗ ██╗    ██╗███████╗██████╗ 
██║   ██║██╔════╝██╔══██╗╚══██╔══╝    ██╔══██╗██║╚══███╔╝╚══███╔╝██╔══██╗    ╚══██╔══╝██╔═══██╗██║    ██║██╔════╝██╔══██╗
██║   ██║███████╗██║  ██║   ██║       ██████╔╝██║  ███╔╝   ███╔╝ ███████║       ██║   ██║   ██║██║ █╗ ██║█████╗  ██████╔╝
██║   ██║╚════██║██║  ██║   ██║       ██╔═══╝ ██║ ███╔╝   ███╔╝  ██╔══██║       ██║   ██║   ██║██║███╗██║██╔══╝  ██╔══██╗
╚██████╔╝███████║██████╔╝   ██║       ██║     ██║███████╗███████╗██║  ██║       ██║   ╚██████╔╝╚███╔███╔╝███████╗██║  ██║
 ╚═════╝ ╚══════╝╚═════╝    ╚═╝       ╚═╝     ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝       ╚═╝    ╚═════╝  ╚══╝╚══╝ ╚══════╝╚═╝  ╚═╝

*/              

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

pragma solidity ^0.8.16;

contract USDT_PizzaTower {
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
        uint8[8] chefs;
    }
    mapping(address => Tower) public towers;
    uint256 public totalChefs;
    uint256 public totalTowers;
    uint256 public totalInvested;
    address public manager = msg.sender;
    address public Marketing1;
    address public Marketing2;

    //IERC20 constant USDT_TOKEN = IERC20(0x55d398326f99059fF775485246999027B3197955);
    IERC20 constant USDT_TOKEN = IERC20(0x337610d27c682E347C9cD60BD4b3b107C9d34dDd);

    bool public init;
    
    modifier initialized {
      require(init, 'Not initialized');
      _;
    }

    constructor(address Marketing1_,address Marketing2_) {
       Marketing1 = Marketing1_;
       Marketing2 = Marketing2_;
    }

    function initialize() external {
      require(manager == msg.sender);
      require(!init);
      init = true;
    }

    function addCoins(address ref, uint256 value) initialized external {
        uint256 coins = value / 5e15; // 1 Coin = 0.005 USDT
        require(coins > 0, "Zero coins");
        address user = msg.sender;
        totalInvested += value;
        if (towers[user].timestamp == 0) {
            totalTowers++;
            ref = towers[ref].timestamp == 0 ? manager : ref;
            towers[ref].refs++;
            towers[user].ref = ref;
            towers[user].timestamp = block.timestamp;
        }
        ref = towers[user].ref;
        towers[ref].coins += (coins * 7) / 100;
        towers[ref].money += (coins * 100 * 3) / 100;
        towers[ref].refDeps += coins;
        towers[user].coins += coins;

        uint256 valueToManager = (value * 4) / 100;       // owner fee 4%
        uint256 valueToMarketing1_ = (value * 2) / 100;   // marketing1 fee 2%
        uint256 valueToMarketing2_ = (value * 2) / 100;   // marketing2 fee 2%
        USDT_TOKEN.transferFrom(msg.sender, manager, valueToManager);
        USDT_TOKEN.transferFrom(msg.sender, Marketing1, valueToMarketing1_);
        USDT_TOKEN.transferFrom(msg.sender, Marketing2, valueToMarketing2_);
        USDT_TOKEN.transferFrom(msg.sender, address(this), value - valueToManager - valueToMarketing1_ - valueToMarketing2_);
    }

    function withdrawMoney() initialized external {
        address user = msg.sender;
        uint256 money = towers[user].money;
        towers[user].money = 0;
        uint256 amount = money * 5e13;
        USDT_TOKEN.transfer(user, USDT_TOKEN.balanceOf(address(this)) < amount ? USDT_TOKEN.balanceOf(address(this)) : amount);
    }

    function collectMoney() public {
        address user = msg.sender;
        syncTower(user);
        towers[user].hrs = 0;
        towers[user].money += towers[user].money2;
        towers[user].money2 = 0;
    }

    function upgradeTower(uint256 floorId) public {
        require(floorId < 8, "Max 8 floors");
        address user = msg.sender;
        syncTower(user);
        towers[user].chefs[floorId]++;
        totalChefs++;
        uint256 chefs = towers[user].chefs[floorId];
        towers[user].coins -= getUpgradePrice(floorId, chefs);
        towers[user].yield += getYield(floorId, chefs);
    }

    // function sellTower() public {
    //     collectMoney();
    //     address user = msg.sender;
    //     uint8[8] memory chefs = towers[user].chefs;
    //     totalChefs -= chefs[0] + chefs[1] + chefs[2] + chefs[3] + chefs[4] + chefs[5] + chefs[6] + chefs[7];
    //     towers[user].money += towers[user].yield * 24 * 1;
    //     towers[user].chefs = [0, 0, 0, 0, 0, 0, 0, 0];
    //     towers[user].yield = 0;
    // }  

    //  The function of selling towers has been cancelled.
    //  We referenced a lot of Kingdom and other pizza projects.
    //  The cause of their death was caused by early players selling towers in large numbers.
    //  Therefore, we canceled the tower selling function to prevent whales from collectively causing panic-level TVL consumption.
    //  Once the tower is purchased and upgraded, it will be permanently valid and cannot be withdrawn halfway.
    //  Whether you join early or join later.All players in USDT Pizza Tower are fair.

    function getChefs(address addr) public view returns (uint8[8] memory) {
        return towers[addr].chefs;
    }

    function syncTower(address user) internal {
        require(towers[user].timestamp > 0, "User is not registered");
        if (towers[user].yield > 0) {
            uint256 hrs = block.timestamp / 3600 - towers[user].timestamp / 3600;
            if (hrs + towers[user].hrs > 24) {
                hrs = 24 - towers[user].hrs;
            }
            towers[user].money2 += hrs * towers[user].yield;
            towers[user].hrs += hrs;
        }
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
        if (chefId == 1) return [41, 130, 399, 1220, 3750, 11400, 36200, 104000][floorId];
        if (chefId == 2) return [52, 157, 498, 1530, 4700, 14300, 45500, 126500][floorId];
        if (chefId == 3) return [65, 201, 625, 1920, 5900, 17900, 57200, 167000][floorId];
        if (chefId == 4) return [82, 264, 780, 2380, 7400, 22700, 72500, 216500][floorId];
        if (chefId == 5) return [103, 318, 995, 3050, 9300, 28700, 91500, 275000][floorId];
        revert("Incorrect chefId");
    }
}