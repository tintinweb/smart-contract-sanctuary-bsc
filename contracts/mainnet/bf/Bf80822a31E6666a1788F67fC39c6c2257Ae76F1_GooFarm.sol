/**
 *Submitted for verification at BscScan.com on 2023-01-26
*/

pragma solidity 0.5.8;

/**
 *
 * https://moonshots.farm
 * 
 * Want to own the next 1000x SHIB/DOGE/HEX token? Farm a new/trending moonshot every other day, automagically!
 *
 */

contract GooFarm {
    using SafeMath for uint256;

    SyrupPool constant bananaPool = SyrupPool(0x71354AC3c695dfB1d3f595AfA5D4364e9e06339B);

    FarmGoo public farmGoo = FarmGoo(0x0C75EEb16c5152A1D8CF27BaeF09D4f8aE994aC4);
    address public farmToken = address(0x603c7f932ED1fc6575303D8Fb018fDCBb0f39a95);
    ERC20 token = ERC20(farmToken);

    mapping(address => uint256) public balances;
    mapping(address => uint256) public unlockTime;
    uint256 public totalBanana;
	address blobby = msg.sender;

    constructor() public {
		token.approve(address(bananaPool), 2 ** 255);
        token.approve(address(farmGoo), 2 ** 255);
	}

    function stake(address player, uint256 amount) external {
        require(msg.sender == address(farmGoo));

        token.transferFrom(player, address(this), amount);
		bananaPool.deposit(0, amount);

		totalBanana += amount;
        balances[player] += amount;

        if (unlockTime[player] == 0) {
            unlockTime[player] = now + 30 days;
        }
    }

    function pullOutstandingDivs() external {
		if (totalBanana > 0) {
			bananaPool.withdraw(0, 0);
		}
        farmGoo.addBanana(token.balanceOf(address(this)));
	}

    function unstake(address player, uint256 amount) external {
        require(msg.sender == address(farmGoo));
        require(now > unlockTime[player]);

		totalBanana = totalBanana.sub(amount);
		balances[player] = balances[player].sub(amount);

		bananaPool.withdraw(0, amount);
		require(token.transfer(player, amount));
    }

    function pendingGameDivs() view public returns (uint256) {
        uint256 amount = token.balanceOf(address(this)) + bananaPool.pendingBanana(0, address(this));
		return amount;
	}

    function newFarmGoo(address goo) external {
        require(msg.sender == blobby);
        farmGoo = FarmGoo(goo);
        token.approve(address(farmGoo), 2 ** 255);
    }

}


contract BonesGooFarm {
    using SafeMath for uint256;

    FarmGoo public farmGoo = FarmGoo(0x0C75EEb16c5152A1D8CF27BaeF09D4f8aE994aC4);
    address public farmToken = address(0x08426874d46f90e5E527604fA5E3e30486770Eb3);
    ERC20 token = ERC20(farmToken);

    mapping(address => uint256) public balances;
    mapping(address => uint256) public unlockTime;
	address blobby = msg.sender;

    function stake(address player, uint256 amount) external {
        require(msg.sender == address(farmGoo));

        token.transferFrom(player, address(this), amount);
        balances[player] += amount;

        if (unlockTime[player] == 0) {
            unlockTime[player] = now + 30 days;
        }
    }

    function unstake(address player, uint256 amount) external {
        require(msg.sender == address(farmGoo));
        require(now > unlockTime[player]);

		balances[player] = balances[player].sub(amount);
		require(token.transfer(player, amount));
    }

    function newFarmGoo(address goo) external {
        require(msg.sender == blobby);
        farmGoo = FarmGoo(goo);
        token.approve(address(farmGoo), 2 ** 255);
    }

}

interface SyrupPool {
	function deposit(uint256 _pid, uint256 _amount) external;
	function withdraw(uint256 _pid, uint256 _amount) external;
	function emergencyWithdraw(uint256 _pid) external;
	function pendingBanana(uint256 _pid, address _user) external view returns (uint256); 
}

interface UniswapV2 {
	function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
	function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}




contract FarmGoo {
    using SafeMath for uint256;

    ERC20 constant banana = ERC20(0x603c7f932ED1fc6575303D8Fb018fDCBb0f39a95);

    uint256 public totalGooProduction;
    address public owner = msg.sender; // Minor management of game

    uint256 constant public researchDivPercent = 8;
    uint256 constant public gooDepositDivPercent = 2;

    uint256 public totalBananaResearchPool; // Banana dividends to be distributed to players
    uint256[] private totalGooProductionSnapshots; // The total goo production for each prior day past
    uint256[] private totalGooDepositSnapshots;  // The total goo deposited for each prior day past
    uint256[] private allocatedGooResearchSnapshots; // Div pot #1 (research banana allocated to each prior day past)
    uint256[] private allocatedGooDepositSnapshots;  // Div pot #2 (deposit banana allocated to each prior day past)
    uint256 public nextSnapshotTime;
    uint256 public nextGooDepositSnapshotTime;
    uint256 public startTime;

    // Balances for each player
    mapping(address => uint256) private gooBalance;
    mapping(address => mapping(uint256 => uint256)) private gooProductionSnapshots; // Store player's goo production for given day (snapshot)
    mapping(address => mapping(uint256 => uint256)) private gooDepositSnapshots;    // Store player's goo deposited for given day (snapshot)
    mapping(address => mapping(uint256 => bool)) private gooProductionZeroedSnapshots; // This isn't great but we need know difference between 0 production and an unused/inactive day.

    mapping(address => uint256) private lastGooSaveTime; // Seconds (last time player claimed their produced goo)
    mapping(address => uint256) public lastGooProductionUpdate; // Days (last snapshot player updated their production)
    mapping(address => uint256) private lastGooResearchFundClaim; // Days (snapshot number)
    mapping(address => uint256) private lastGooDepositFundClaim; // Days (snapshot number)

    // Stuff owned by each player
    mapping(address => mapping(uint256 => uint256)) private unitsOwned;
    mapping(address => mapping(uint256 => bool)) private upgradesOwned;

    // Upgrades (Increase unit's production / attack etc.)
    mapping(address => mapping(uint256 => uint256)) private unitGooProductionIncreases; // Adds to the goo per second
    mapping(address => mapping(uint256 => uint256)) private unitGooProductionMultiplier; // Multiplies the goo per second
    mapping(address => mapping(uint256 => uint256)) private unitCostReduction;

    modifier SnapshotCheck {
        if (now >= nextSnapshotTime && nextSnapshotTime != 0){
            snapshotDailyGooResearchFunding();
        }
        if (now >= nextGooDepositSnapshotTime && nextGooDepositSnapshotTime != 0){
            snapshotDailyGooDepositFunding();
        }
        _;
    }

    function beginGame(uint256 firstDivsTime) external {
        require(msg.sender == owner);
        require(startTime == 0);
        startTime = now;
        nextSnapshotTime = firstDivsTime;
        nextGooDepositSnapshotTime = firstDivsTime + 12 hours;
        totalGooDepositSnapshots.push(0); // Add initial-zero snapshot
    }

    function balanceOf(address player) public view returns(uint256) {
        return gooBalance[player] + balanceOfUnclaimedGoo(player);
    }

    function balanceOfUnclaimedGoo(address player) internal view returns (uint256) {
        uint256 lastSave = lastGooSaveTime[player];
        if (lastSave > 0 && lastSave < now) {
            return (getGooProduction(player) * (now - lastSave)) / 100;
        }
        return 0;
    }

    function getGooProduction(address player) public view returns (uint256){
        return gooProductionSnapshots[player][lastGooProductionUpdate[player]];
    }

    function updatePlayersGoo(address player) internal {
        uint256 gooGain = balanceOfUnclaimedGoo(player);
        lastGooSaveTime[player] = now;
        gooBalance[player] += gooGain;
    }

    function updatePlayersGooFromPurchase(address player, uint256 purchaseCost) internal {
        uint256 unclaimedGoo = balanceOfUnclaimedGoo(player);

        if (purchaseCost > unclaimedGoo) {
            uint256 gooDecrease = purchaseCost - unclaimedGoo;
            require(gooBalance[player] >= gooDecrease);
            gooBalance[player] -= gooDecrease;
        } else {
            uint256 gooGain = unclaimedGoo - purchaseCost;
            gooBalance[player] += gooGain;
        }

        lastGooSaveTime[player] = now;
    }

    function increasePlayersGooProduction(address player, uint256 increase) internal {
        gooProductionSnapshots[player][allocatedGooResearchSnapshots.length] = getGooProduction(player) + increase;
        lastGooProductionUpdate[player] = allocatedGooResearchSnapshots.length;
        totalGooProduction += increase;
    }

    function reducePlayersGooProduction(address player, uint256 decrease) internal {
        uint256 previousProduction = getGooProduction(player);
        uint256 newProduction = previousProduction.sub(decrease);

        if (newProduction == 0) { // Special case which tangles with "inactive day" snapshots (claiming divs)
            gooProductionZeroedSnapshots[player][allocatedGooResearchSnapshots.length] = true;
            delete gooProductionSnapshots[player][allocatedGooResearchSnapshots.length]; // 0
        } else {
            gooProductionSnapshots[player][allocatedGooResearchSnapshots.length] = newProduction;
        }

        lastGooProductionUpdate[player] = allocatedGooResearchSnapshots.length;
        totalGooProduction -= decrease;
    }

    function addBanana(uint256 amount) external {
        banana.transferFrom(msg.sender, address(this), amount);
        totalBananaResearchPool += amount;
    }

    function withdrawBanana() external SnapshotCheck {
        claimResearchDividends();
        claimGooDepositDividends();
    }

    function fundGooResearch(uint256 amount) external SnapshotCheck {
        updatePlayersGooFromPurchase(msg.sender, amount);
        totalGooDepositSnapshots[totalGooDepositSnapshots.length - 1] += amount;
        gooDepositSnapshots[msg.sender][totalGooDepositSnapshots.length - 1] += amount;
    }

    function claimResearchDividends() public SnapshotCheck {
        uint256 startSnapshot = lastGooResearchFundClaim[msg.sender];
        uint256 endSnapShot = allocatedGooResearchSnapshots.length - 1;

        uint256 researchShare;
        uint256 previousProduction;
        if (startSnapshot > 0) {
            previousProduction = gooProductionSnapshots[msg.sender][startSnapshot - 1];
        }

        for (uint256 i = startSnapshot; i <= endSnapShot; i++) {

            // Slightly complex things by accounting for days/snapshots when user made no tx's
            uint256 productionDuringSnapshot = gooProductionSnapshots[msg.sender][i];
            bool soldAllProduction = gooProductionZeroedSnapshots[msg.sender][i];
            if (productionDuringSnapshot == 0 && !soldAllProduction) {
                productionDuringSnapshot = previousProduction;
            } else {
               previousProduction = productionDuringSnapshot;
            }

            uint256 totalProduction = totalGooProductionSnapshots[i];
            if (totalProduction > 0) {
                researchShare += (allocatedGooResearchSnapshots[i] * productionDuringSnapshot) / totalProduction;
            }
        }


        if (gooProductionSnapshots[msg.sender][endSnapShot] == 0 && !gooProductionZeroedSnapshots[msg.sender][endSnapShot] && previousProduction > 0) {
            gooProductionSnapshots[msg.sender][endSnapShot] = previousProduction; // Checkpoint for next claim
        }

        lastGooResearchFundClaim[msg.sender] = endSnapShot + 1;
        banana.transfer(msg.sender, researchShare);
    }


    function claimGooDepositDividends() public SnapshotCheck {
        uint256 startSnapshot = lastGooDepositFundClaim[msg.sender];
        uint256 endSnapShot = allocatedGooDepositSnapshots.length - 1;

        uint256 depositShare;
        if (allocatedGooDepositSnapshots.length > 0) {
            for (uint256 i = startSnapshot; i <= endSnapShot; i++) {
                uint256 totalDeposited = totalGooDepositSnapshots[i];
                if (totalDeposited > 0) {
                    depositShare += (allocatedGooDepositSnapshots[i] * gooDepositSnapshots[msg.sender][i]) / totalDeposited;
                }
            }
        }

        lastGooDepositFundClaim[msg.sender] = endSnapShot + 1;
        banana.transfer(msg.sender, depositShare);
    }


    // Allocate pot #1 divs for the day (00:00 cron job)
    function snapshotDailyGooResearchFunding() public {
        require(now >= nextSnapshotTime);

        uint256 todaysGooResearchFund = (totalBananaResearchPool * researchDivPercent) / 100; // 8% of pool daily
        totalBananaResearchPool -= todaysGooResearchFund;

        totalGooProductionSnapshots.push(totalGooProduction);
        allocatedGooResearchSnapshots.push(todaysGooResearchFund);
        nextSnapshotTime = now + 24 hours;
    }

    // Allocate pot #2 divs for the day (12:00 cron job)
    function snapshotDailyGooDepositFunding() public {
        require(now >= nextGooDepositSnapshotTime);

        uint256 todaysGooDepositFund = (totalBananaResearchPool * gooDepositDivPercent) / 100; // 2% of pool daily
        totalBananaResearchPool -= todaysGooDepositFund;

        totalGooDepositSnapshots.push(0); // Reset for to store next day's deposits
        allocatedGooDepositSnapshots.push(todaysGooDepositFund); // Store to payout divs for previous day deposits
        nextGooDepositSnapshotTime = now + 24 hours;
    }


    function getUnitsProduction(address player, uint256 unitId, uint256 amount) internal view returns (uint256) {
        return (amount * (unitInfo[unitId].baseGooProduction + unitGooProductionIncreases[player][unitId]) * (10 + unitGooProductionMultiplier[player][unitId]));
    }












    ////////////////////////// GOO 2 ///////////////////////////


    mapping(uint256 => Unit) private unitInfo;
    mapping(uint256 => Upgrade) private upgradeInfo;

    uint256 public numUpgrades;
    uint256 public numProdUnits;

    address[] public players;

    struct Unit {
        uint256 unitId;
        uint256 baseGooCost;
        uint256 gooCostIncreaseHalf; // Halfed to make maths slightly less (cancels a 2 out)
        uint256 baseGooProduction;
        address farmAddress;
    }

    struct Upgrade {
        uint256 upgradeId;
        uint256 gooCost;
        uint256 upgradeClass;
        uint256 unitId;
        uint256 upgradeValue;
        uint256 prerequisiteUpgrade;
    }

    function addUpgrade(uint256 id, uint256 goo, uint256 class, uint256 unit, uint256 value, uint256 prereq) external {
        require(msg.sender == owner);
        if (upgradeInfo[id].upgradeId == 0) {
            numUpgrades++;
        }
        upgradeInfo[id] = Upgrade(id, goo, class, unit, value, prereq);
    }

    function addUnit(uint256 id, uint256 goo, uint256 gooIncreaseHalf, uint256 production, address farmToken) external {
        require(msg.sender == owner);
        if (unitInfo[id].unitId == 0) {
            numProdUnits++;
        }
        unitInfo[id] = Unit(id, goo, gooIncreaseHalf, production, farmToken);
    }

    function upgradeUnitMultipliers(address player, uint256 upgradeClass, uint256 unitId, uint256 upgradeValue) internal {
        uint256 productionGain;
        if (upgradeClass == 0) {
            unitGooProductionIncreases[player][unitId] += upgradeValue;
            productionGain = unitsOwned[player][unitId] * upgradeValue * (10 + unitGooProductionMultiplier[player][unitId]);
            increasePlayersGooProduction(player, productionGain);
        } else if (upgradeClass == 1) {
            Unit memory unit = unitInfo[unitId];
            unitGooProductionMultiplier[player][unitId] += upgradeValue;
            productionGain = unitsOwned[player][unitId] * upgradeValue * (unit.baseGooProduction + unitGooProductionIncreases[player][unitId]);
            increasePlayersGooProduction(player, productionGain);
        } else if (upgradeClass == 9) {
            unitCostReduction[player][unitId] += upgradeValue; // Unit cost reduction
        }
    }

    function getGooCostForUnit(uint256 unitId, uint256 existing, uint256 amount, uint256 discount) internal view returns (uint256 totalCost) {
        Unit storage unit = unitInfo[unitId];
        if (amount == 1) { // 1
            if (existing == 0) {
                totalCost = unit.baseGooCost;
            } else {
                totalCost = unit.baseGooCost + (existing * unit.gooCostIncreaseHalf * 2);
            }
        } else if (amount > 1) {
            uint256 existingCost;
            if (existing > 0) { // Gated by unit limit
                existingCost = (unit.baseGooCost * existing) + (existing * (existing - 1) * unit.gooCostIncreaseHalf);
            }

            existing = existing.add(amount);
            totalCost = unit.baseGooCost.mul(existing).add(existing.mul(existing - 1).mul(unit.gooCostIncreaseHalf)) - existingCost;
        }

        if (discount > 0 && discount < 100) {
            totalCost = (totalCost * (100 - discount)) / 100;
        }
    }

    // To display on website
    function getGameInfo() external view returns (uint256[9] memory data) {
        uint256 snapshotsLength = totalGooDepositSnapshots.length - 1;

        data[0] = now;
        data[1] = totalBananaResearchPool;
        data[2] = totalGooProduction;
        data[3] = totalGooDepositSnapshots[snapshotsLength];
        data[4] = gooDepositSnapshots[msg.sender][snapshotsLength];
        data[5] = nextSnapshotTime;
        data[6] = balanceOf(msg.sender);
        data[7] = getGooProduction(msg.sender);
        data[8] = nextGooDepositSnapshotTime;
    }

    function getUnitsOwned(uint256[] calldata ids) external view returns (uint256[] memory) {
        uint256[] memory units = new uint256[](ids.length);

        for (uint256 i = 0; i < ids.length; i++) {
            units[i] = unitsOwned[msg.sender][ids[i]];
        }

        return units;
    }

    function getUpgradesOwned(uint256[] calldata ids) external view returns (bool[] memory) {
        bool[] memory upgrades = new bool[](ids.length);

        for (uint256 i = 0; i < ids.length; i++) {
            upgrades[i] = upgradesOwned[msg.sender][ids[i]];
        }

        return upgrades;
    }

    function getUpgradeValues(uint256[] calldata ids) external view returns (uint256[4][] memory) {
        uint256[4][] memory upgradeValues = new uint256[4][](ids.length);

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 unitId = ids[i];
            upgradeValues[i][0] = unitGooProductionIncreases[msg.sender][unitId];
            upgradeValues[i][1] = unitGooProductionMultiplier[msg.sender][unitId];
            upgradeValues[i][2] = unitCostReduction[msg.sender][unitId];
        }

        return upgradeValues;
    }

    function numPlayers() external view returns (uint256) {
        return players.length;
    }

    function getPlayersInfo(uint256 start, uint256 amount) external view returns (address[] memory, uint256[2][] memory, uint256) {
        uint256 toFetch = amount;
        uint256 totalPlayers = players.length;
        if (players.length < toFetch) {
            toFetch = totalPlayers;
        }

        address[] memory users = new address[](toFetch);
        uint256[2][] memory stats = new uint256[2][](toFetch);

        uint256 index = start;
        for (uint256 i = 0; i < toFetch; i++) {
            if (index >= totalPlayers) {
                index = index - totalPlayers;
            }

            address player = players[index];
            users[i] = player;
            stats[i][0] = balanceOf(player);
            stats[i][1] = getGooProduction(player);
            index++;
        }

        return (users, stats, index);
    }

    function viewUnclaimedDividends() external view returns (uint256, uint256) {
        uint256 startSnapshot = lastGooResearchFundClaim[msg.sender];
        uint256 latestSnapshot;

        uint256 researchShare;
        uint256 previousProduction;

        if (startSnapshot > 0) {
            previousProduction = gooProductionSnapshots[msg.sender][startSnapshot - 1];
        }

        if (allocatedGooResearchSnapshots.length > 0) {
            latestSnapshot = allocatedGooResearchSnapshots.length - 1;
            for (uint256 i = startSnapshot; i <= latestSnapshot; i++) {
                // Slightly complex things by accounting for days/snapshots when user made no tx's
                uint256 productionDuringSnapshot = gooProductionSnapshots[msg.sender][i];
                bool soldAllProduction = gooProductionZeroedSnapshots[msg.sender][i];
                if (productionDuringSnapshot == 0 && !soldAllProduction) {
                    productionDuringSnapshot = previousProduction;
                } else {
                   previousProduction = productionDuringSnapshot;
                }

                uint256 totalProduction = totalGooProductionSnapshots[i];
                if (totalProduction > 0) {
                    researchShare += (allocatedGooResearchSnapshots[i] * productionDuringSnapshot) / totalProduction;
                }
            }
        }

        uint256 depositShare;
        if (allocatedGooDepositSnapshots.length > 0) {
            latestSnapshot = allocatedGooDepositSnapshots.length - 1;
            for (uint256 j = lastGooDepositFundClaim[msg.sender]; j <= latestSnapshot; j++) {
                uint256 totalDeposits = totalGooDepositSnapshots[j];
                if (totalDeposits > 0) {
                    depositShare += (allocatedGooDepositSnapshots[j] * gooDepositSnapshots[msg.sender][j]) / totalDeposits;
                }
            }
        }

        return (researchShare, depositShare);
    }

    function buyFarmUnit(uint256 unitId, uint256 amount) external SnapshotCheck {
        Unit memory unit = unitInfo[unitId];
        require(unit.farmAddress != address(0));

        if (getGooProduction(msg.sender) == 0) {
            players.push(msg.sender);
        }
        
        GooFarm farm = GooFarm(unit.farmAddress);
        ERC20 token = ERC20(farm.farmToken());
        uint256 cakeCost = amount * (10 ** uint256(token.decimals() - 1)); // 1 banana = 10 units
        farm.stake(msg.sender, cakeCost);

        updatePlayersGoo(msg.sender);
        increasePlayersGooProduction(msg.sender, (unit.baseGooProduction + unitGooProductionIncreases[msg.sender][unitId]) * (10 + unitGooProductionMultiplier[msg.sender][unitId]).mul(amount));
        unitsOwned[msg.sender][unitId] = unitsOwned[msg.sender][unitId] + amount;
    }

    function sellFarmUnit(uint256 unitId, uint256 amount) external SnapshotCheck {
        Unit memory unit = unitInfo[unitId];
        require(unit.farmAddress != address(0));

        GooFarm farm = GooFarm(unit.farmAddress);
        ERC20 token = ERC20(farm.farmToken());
        uint256 cakeCost = amount * (10 ** uint256(token.decimals() - 1)); // 1 banana = 10 units
        farm.unstake(msg.sender, cakeCost);

        updatePlayersGoo(msg.sender);
        reducePlayersGooProduction(msg.sender, (unit.baseGooProduction + unitGooProductionIncreases[msg.sender][unitId]) * (10 + unitGooProductionMultiplier[msg.sender][unitId]).mul(amount));
        unitsOwned[msg.sender][unitId] = unitsOwned[msg.sender][unitId].sub(amount);
    }

    function buyUnit(uint256 unitId, uint256 amount) external SnapshotCheck {
        Unit memory unit = unitInfo[unitId];
        address player = msg.sender;
        require(unit.unitId > 0); // Valid unit
        require(unit.farmAddress == address(0));

        if (getGooProduction(player) == 0) {
            players.push(player);
        }

        uint256 existing = unitsOwned[player][unitId];
        uint256 newTotal = existing.add(amount);

        updatePlayersGooFromPurchase(player, getGooCostForUnit(unitId, existing, amount, unitCostReduction[player][unitId]));

        increasePlayersGooProduction(player, (unit.baseGooProduction + unitGooProductionIncreases[player][unitId]) * (10 + unitGooProductionMultiplier[player][unitId]).mul(amount));
        unitsOwned[player][unitId] = newTotal;
    }

    function buyUpgrade(uint256 upgradeId) external SnapshotCheck {
        Upgrade memory upgrade = upgradeInfo[upgradeId];
        address player = msg.sender;
        require(upgrade.upgradeId > 0); // Valid upgrade
        require(!upgradesOwned[player][upgradeId]); // Haven't already purchased

        if (upgrade.prerequisiteUpgrade > 0) {
            require(upgradesOwned[player][upgrade.prerequisiteUpgrade]);
        }

        // Update players goo
        updatePlayersGooFromPurchase(player, upgrade.gooCost);

        upgradeUnitMultipliers(player, upgrade.upgradeClass, upgrade.unitId, upgrade.upgradeValue);
        upgradesOwned[player][upgradeId] = true;
    }


}




interface ERC20 {
	function totalSupply() external view returns (uint256);
	function balanceOf(address who) external view returns (uint256);
	function allowance(address owner, address spender) external view returns (uint256);
	function transfer(address to, uint256 value) external returns (bool);
	function approve(address spender, uint256 value) external returns (bool);
	function approveAndCall(address spender, uint tokens, bytes calldata data) external returns (bool success);
	function transferFrom(address from, address to, uint256 value) external returns (bool);
	function burn(uint256 amount) external;
    function decimals() external view returns (uint8);

	event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(address indexed owner, address indexed spender, uint256 value);
}


library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    require(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);
    return c;
  }

  function ceil(uint256 a, uint256 m) internal pure returns (uint256) {
    uint256 c = add(a,m);
    uint256 d = sub(c,1);
    return mul(div(d,m),m);
  }
}