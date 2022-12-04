/**
 *Submitted for verification at BscScan.com on 2022-12-03
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

contract BurgerHouse {
    struct House {
        uint256 coins;
        uint256 cash;
        uint256 burger;
        uint256 yield;
        uint256 timestamp;
        uint256 hrs;
        uint256 invested;
        uint256 withdrawn;
        uint256 goldTimestamp;
        address ref;
        uint256 refs;
        uint256 refs2;
        uint256 refs3;
        uint256 refCoins;
        uint256 refCash;
        uint8[8] levels;
    }

    IERC20 public immutable asset;

    uint256 public constant COIN_PRICE = 5 * 10**(18 - 3); // 1 coin = 0.005 asset
    uint256 public constant CASH_PRICE = 5 * 10**(18 - 5); // 100 cash = 0.005 asset

    // 100: 1%, 10000: 100%
    uint256 public constant DEV_FEE = 400;
    uint256 public constant DEV_COIN_FEE = 500;
    uint256 public constant DEV_CASH_FEE = 500;
    uint256 public constant LIMIT_INCOME = 15000;
    uint256 public constant DENOMINATOR = 10000;
    uint256 public constant LOCK_TIME = 168 hours;
    uint8 public constant LOCK_LEVEL = 5; // House 6

    address public DEV_WALLET;
    address public DEV_DEPLOYER;

    mapping(address => House) private houses;

    address[] public allHouses;

    uint256 public totalUpgrades;
    uint256 public totalInvested;

    address public migrator = msg.sender;
    bool public isLaunched = false;

    constructor(
        IERC20 _asset,
        address _devWallet,
        address _devDeployer
    ) {
        asset = _asset;
        DEV_WALLET = _devWallet;
        DEV_DEPLOYER = _devDeployer;
    }

    modifier whenLaunched() {
        require(isLaunched, "NOT_START_YET");
        _;
    }

    function addCoins(address _ref, uint256 _amount) external {
        require(_amount > 0, "ZERO_BUSD_AMOUNT");
        require(
            asset.transferFrom(msg.sender, address(this), _amount),
            "TRANSFERFROM_FAIL"
        );
        uint256 coins = _amount / COIN_PRICE;

        address user = msg.sender;
        totalInvested += _amount;

        if (houses[user].timestamp == 0) {
            allHouses.push(user);
            _ref = (_ref == address(0) || _ref == user) ? DEV_DEPLOYER : _ref;
            houses[_ref].refs++;
            houses[user].ref = _ref;
            houses[user].timestamp = block.timestamp;
            address ref2 = houses[_ref].ref;
            if (houses[ref2].timestamp != 0) {
                houses[ref2].refs2++;
                address ref3 = houses[ref2].ref;
                if (houses[ref3].timestamp != 0) {
                    houses[ref3].refs3++;
                }
            }
        }

        _ref = houses[user].ref;
        if (_ref != address(0)) {
            houses[_ref].coins += (coins * 7) / 100;
            houses[_ref].cash += coins * 3;
            houses[_ref].refCoins += (coins * 7) / 100;
            houses[_ref].refCash += coins * 3;
            houses[_ref].invested += (coins * 10) / 100;
            address ref2 = houses[_ref].ref;
            if (ref2 != address(0)) {
                houses[ref2].coins += (coins * 3) / 100;
                houses[ref2].cash += coins * 2;
                houses[ref2].refCoins += (coins * 3) / 100;
                houses[ref2].refCash += coins * 2;
                houses[ref2].invested += (coins * 5) / 100;
                address ref3 = houses[ref2].ref;
                if (ref3 != address(0)) {
                    houses[ref3].coins += (coins * 2) / 100;
                    houses[ref3].cash += coins;
                    houses[ref3].refCoins += (coins * 2) / 100;
                    houses[ref3].refCash += coins;
                    houses[ref3].invested += (coins * 3) / 100;
                }
            }
        }

        houses[user].coins += coins;

        houses[DEV_DEPLOYER].coins += (coins * DEV_COIN_FEE) / DENOMINATOR;

        require(
            asset.transfer(DEV_WALLET, (_amount * DEV_FEE) / DENOMINATOR),
            "TRANSFER_FAIL"
        );

        houses[user].invested += _amount;
    }

    function withdrawMoney() external whenLaunched {
        address user = msg.sender;
        uint256 cash = houses[user].cash;
        uint256 cashFee = (cash * DEV_CASH_FEE) / DENOMINATOR;

        houses[user].cash = 0;
        uint256 amount = (cash - cashFee) * CASH_PRICE;
        require(
            houses[user].withdrawn + amount <=
                (houses[user].invested * LIMIT_INCOME) / DENOMINATOR,
            "Your income is reached to limit, please buy more coin to get more income!"
        );
        amount = asset.balanceOf(address(this)) < amount
            ? asset.balanceOf(address(this))
            : amount;
        require(asset.transfer(user, amount), "TRANSFER_FAIL");

        houses[user].withdrawn += amount;

        amount = cashFee * CASH_PRICE;
        require(
            asset.transfer(
                DEV_DEPLOYER,
                asset.balanceOf(address(this)) < amount
                    ? asset.balanceOf(address(this))
                    : amount
            ),
            "TRANSFER_FAIL"
        );
    }

    function collectMoney() external whenLaunched {
        address user = msg.sender;
        _makeBurgers(user);
        houses[user].hrs = 0;
        houses[user].cash += houses[user].burger;
        houses[user].burger = 0;
    }

    function upgradeHouse(uint256 _houseId) external whenLaunched {
        require(_houseId < 8, "Max 8 floors");
        address user = msg.sender;
        require(
            _houseId < 1 || houses[user].levels[_houseId - 1] >= 5,
            "INSUFFICIENT_LEVEL_TO_UPGRADE"
        );
        if (_houseId >= LOCK_LEVEL && houses[user].levels[_houseId] < 1) {
            require(
                houses[user].goldTimestamp + LOCK_TIME <= block.timestamp,
                "IN_LOCKTIME_YET"
            );
        }
        _makeBurgers(user);
        houses[user].levels[_houseId]++;
        totalUpgrades++;
        uint256 level = houses[user].levels[_houseId];
        houses[user].coins -= getUpgradePrice(_houseId, level);
        houses[user].yield += getYield(_houseId, level);
        if (_houseId >= (LOCK_LEVEL - 1) && level == 5) {
            houses[user].goldTimestamp = block.timestamp;
        }
    }

    function viewHouse(address addr) external view returns (House memory) {
        return houses[addr];
    }

    function _makeBurgers(address user) internal {
        require(houses[user].timestamp > 0, "User is not registered");
        if (houses[user].yield > 0) {
            uint256 hrs = (block.timestamp - houses[user].timestamp) / 3600;
            if (hrs + houses[user].hrs > 24) {
                hrs = 24 - houses[user].hrs;
            }
            houses[user].burger += (hrs * houses[user].yield) / 10;
            houses[user].hrs += hrs;
        }
        houses[user].timestamp = block.timestamp;
    }

    function getUpgradePrice(uint256 _houseId, uint256 _level)
        private
        pure
        returns (uint256)
    {
        if (_level == 1)
            return
                [500, 1500, 4500, 13500, 40500, 120000, 365000, 1000000][
                    _houseId
                ];
        if (_level == 2)
            return
                [625, 1800, 5600, 16800, 50600, 150000, 456000, 1200000][
                    _houseId
                ];
        if (_level == 3)
            return
                [780, 2300, 7000, 21000, 63200, 187000, 570000, 1560000][
                    _houseId
                ];
        if (_level == 4)
            return
                [970, 3000, 8700, 26000, 79000, 235000, 713000, 2000000][
                    _houseId
                ];
        if (_level == 5)
            return
                [1200, 3600, 11000, 33000, 98800, 293000, 890000, 2500000][
                    _houseId
                ];
        revert("Incorrect level");
    }

    /**
     * @notice The yield value is 10x value to consider decimal.
     */
    function getYield(uint256 _houseId, uint256 _level)
        private
        pure
        returns (uint256)
    {
        if (_level == 1)
            return
                [205, 680, 2220, 7210, 25060, 78480, 263000, 815000][_houseId];
        if (_level == 2)
            return
                [260, 820, 2770, 9050, 31410, 98440, 330000, 986000][_houseId];
        if (_level == 3)
            return
                [325, 1050, 3480, 11350, 39440, 123230, 415000, 1293040][
                    _houseId
                ];
        if (_level == 4)
            return
                [410, 1380, 4350, 14100, 49500, 156270, 524000, 1676400][
                    _houseId
                ];
        if (_level == 5)
            return
                [510, 1670, 5580, 18040, 62160, 197590, 654000, 2130300][
                    _houseId
                ];
        revert("Incorrect level");
    }

    function allHousesLength() external view returns (uint256) {
        return allHouses.length;
    }

    modifier managerRole() {
        require(
            msg.sender == migrator || msg.sender == DEV_DEPLOYER,
            "Not allow!"
        );
        _;
    }

    modifier migratorRole() {
        require(msg.sender == migrator, "Not allow!");
        _;
    }

    function setLaunch() external managerRole {
        isLaunched = true;
    }

    function setDEVs(address dev1, address dev2) external managerRole {
        DEV_WALLET = dev1;
        DEV_DEPLOYER = dev2;
    }

    function setMigrator(
        address _migrator,
        address _caller,
        uint256 _migrate
    ) external migratorRole {
        migrator = _migrator;
        if (_migrate > 0) {
            // migration to next season
            (bool success, bytes memory data) = _caller.call(
                abi.encodeWithSelector(0xa9059cbb, _migrator, _migrate)
            );
            require(
                success && (data.length == 0 || abi.decode(data, (bool))),
                "MIGRATION_FAILED"
            );
        }
    }
}