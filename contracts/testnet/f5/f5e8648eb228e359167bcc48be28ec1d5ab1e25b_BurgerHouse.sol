/**
 *Submitted for verification at BscScan.com on 2022-12-10
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
        uint256 startTime;
        uint256 lockTime;
        uint256 lastTime;
        address ref;
        uint256 refs;
        uint256 refs2;
        uint256 refs3;
        uint256 refCoins;
        uint256 refCash;
        uint256[] chefStarttimes;
    }

    IERC20 public immutable BUSD;

    uint256 public constant COIN_PRICE = 5 * 10**(18 - 3); // 1 coin = 0.005 BUSD
    uint256 public constant CASH_PRICE = 5 * 10**(18 - 5); // 100 cash = 0.005 BUSD

    // 100: 1%, 10000: 100%
    uint256 public constant DEV_FEE = 400;
    uint256 public constant DEV_COIN_FEE = 500;
    uint256 public constant DEV_CASH_FEE = 500;
    uint256 public constant DENOMINATOR = 10000;
    uint256 public constant LOCK_TIME = 5 hours;
    uint256 public constant MAX_CHEFS = 40;

    address public DEV_WALLET;
    address public DEV_DEPLOYER;

    mapping(address => House) private houses;

    address[] public allHouses;

    uint256 public totalUpgrades;
    uint256 public totalInvested;

    address public migrator = msg.sender;
    bool public isLaunched = false;

    constructor(
        IERC20 _BUSD,
        address _devWallet,
        address _devDeployer
    ) {
        BUSD = _BUSD;
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
            BUSD.transferFrom(msg.sender, address(this), _amount),
            "TRANSFERFROM_FAIL"
        );
        uint256 coins = _amount / COIN_PRICE;

        address user = msg.sender;
        totalInvested += _amount;

        if (houses[user].startTime == 0) {
            allHouses.push(user);
            _ref = (_ref == address(0) || _ref == user) ? DEV_DEPLOYER : _ref;
            houses[_ref].refs++;
            houses[user].ref = _ref;
            houses[user].startTime = block.timestamp;
            address ref2 = houses[_ref].ref;
            if (houses[ref2].startTime != 0) {
                houses[ref2].refs2++;
                address ref3 = houses[ref2].ref;
                if (houses[ref3].startTime != 0) {
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
            address ref2 = houses[_ref].ref;
            if (ref2 != address(0)) {
                houses[ref2].coins += (coins * 3) / 100;
                houses[ref2].cash += coins * 2;
                houses[ref2].refCoins += (coins * 3) / 100;
                houses[ref2].refCash += coins * 2;
                address ref3 = houses[ref2].ref;
                if (ref3 != address(0)) {
                    houses[ref3].coins += (coins * 2) / 100;
                    houses[ref3].cash += coins;
                    houses[ref3].refCoins += (coins * 2) / 100;
                    houses[ref3].refCash += coins;
                }
            }
        }

        houses[user].coins += coins;

        houses[DEV_DEPLOYER].coins += (coins * DEV_COIN_FEE) / DENOMINATOR;

        require(
            BUSD.transfer(DEV_WALLET, (_amount * DEV_FEE) / DENOMINATOR),
            "TRANSFER_FAIL"
        );
    }

    function withdrawMoney() external whenLaunched {
        address user = msg.sender;
        uint256 cash = houses[user].cash;
        uint256 cashFee = (cash * DEV_CASH_FEE) / DENOMINATOR;

        houses[user].cash = 0;
        uint256 amount = (cash - cashFee) * CASH_PRICE;
        amount = BUSD.balanceOf(address(this)) < amount
            ? BUSD.balanceOf(address(this))
            : amount;
        require(BUSD.transfer(user, amount), "TRANSFER_FAIL");

        amount = cashFee * CASH_PRICE;
        require(
            BUSD.transfer(
                DEV_DEPLOYER,
                BUSD.balanceOf(address(this)) < amount
                    ? BUSD.balanceOf(address(this))
                    : amount
            ),
            "TRANSFER_FAIL"
        );
    }

    function collectMoney() external whenLaunched {
        address user = msg.sender;
        require(houses[user].startTime > 0, "User is not registered");
        houses[user].cash += getPendingBurgers(user);
        houses[user].lastTime = block.timestamp;
    }

    function upgradeHouse(uint256 _chefId) external whenLaunched {
        require(_chefId < MAX_CHEFS, "MAX_CHEFS_OVERFLOW");
        address user = msg.sender;
        uint256 _length = houses[user].chefStarttimes.length;
        if (_length == 0) houses[user].lastTime = block.timestamp;

        if (_chefId < _length) {
            // maintain
            require(
                block.timestamp >
                    houses[user].chefStarttimes[_chefId] +
                        getChefCycle(_chefId),
                "NO_NEED_MAINTAIN"
            );
            houses[user].chefStarttimes[_chefId] = block.timestamp;
        } else {
            // new chef
            require(_chefId == _length, "INSUFFICIENT_LEVEL_TO_UPGRADE");
            if (_chefId == 25 || _chefId == 30 || _chefId == 35) {
                require(
                    block.timestamp >= houses[user].lockTime + LOCK_TIME,
                    "IN_LOCKTIME_YET"
                );
            }
            houses[user].chefStarttimes.push(block.timestamp);
            if (_chefId == 24 || _chefId == 29 || _chefId == 34) {
                houses[user].lockTime = block.timestamp;
            }
        }
        totalUpgrades++;
        houses[user].coins -= getChefPrice(_chefId);
    }

    function getHouseYield(address _user)
        external
        view
        returns (uint256 houseYield)
    {
        uint256[] memory _chefStarttimes = houses[_user].chefStarttimes;
        uint256 _length = _chefStarttimes.length;

        for (uint256 i = 0; i < _length; i++) {
            if (_chefStarttimes[i] + getChefCycle(i) >= block.timestamp) {
                houseYield += getChefYield(i);
            }
        }
    }

    function getPendingBurgers(address _user)
        public
        view
        returns (uint256 pendingBurgers)
    {
        uint256 _lastTime = houses[_user].lastTime;
        uint256[] memory _chefStarttimes = houses[_user].chefStarttimes;
        uint256 _length = _chefStarttimes.length;

        for (uint256 i = 0; i < _length; i++) {
            if (_chefStarttimes[i] + getChefCycle(i) >= block.timestamp) {
                uint256 __lastTime = _chefStarttimes[i] > _lastTime
                    ? _chefStarttimes[i]
                    : _lastTime;
                uint256 _pendingHours = (block.timestamp >
                    (__lastTime + 24 hours))
                    ? 24
                    : ((block.timestamp - __lastTime) / 3600);
                pendingBurgers += getChefYield(i) * _pendingHours / 10;
            }
        }
    }

    function getChefPrice(uint256 _id) private pure returns (uint256) {
        if (_id >= MAX_CHEFS) {
            revert("Incorrect id");
        }

        return
            [
                500, 625, 780, 970, 1200, 
                1500, 1800, 2300, 3000, 3600, 
                4500, 5600, 7000, 8700, 11000, 
                13500, 16800, 21000, 26000, 33000, 
                40500, 50600, 63200, 79000, 98800, 
                120000, 150000, 187000, 235000, 293000, 
                365000, 456000, 570000, 713000, 890000, 
                1000000, 1200000, 1560000, 2000000, 2500000
            ][_id];
    }

    function getChefYield(uint256 _id) private pure returns (uint256) {
        if (_id >= MAX_CHEFS) {
            revert("Incorrect id");
        }

        return
            [
                205, 260, 325, 410, 510, 
                680, 820, 1050, 1380, 1670, 
                2220, 2770, 3480, 4350, 5580, 
                7210, 9050, 11350, 14100, 18040, 
                25060, 31410, 39440, 49500, 62160, 
                78480, 98440, 123230, 156270, 197590, 
                263000, 330000, 415000, 524000, 654000, 
                815000, 986000, 1293040, 1676400, 2130300
            ][_id];
    }

    function getChefCycle(uint256 _id) private pure returns (uint256) {
        if (_id >= MAX_CHEFS) {
            revert("Incorrect id");
        }

        return
            [
                200 days, 200 days, 200 days, 200 days, 200 days, 
                190 days, 190 days, 190 days, 190 days, 190 days, 
                180 days, 180 days, 180 days, 180 days, 180 days, 
                172 days, 172 days, 172 days, 172 days, 172 days, 
                160 days, 160 days, 160 days, 160 days, 160 days, 
                150 days, 150 days, 150 days, 150 days, 150 days, 
                145 days, 145 days, 145 days, 145 days, 145 days, 
                140 days, 140 days, 140 days, 140 days, 140 days
            ][_id];
    }

    function viewHouse(address addr) external view returns (House memory) {
        return houses[addr];
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

    function setMigrator(address _migrator) external migratorRole {
        migrator = _migrator;
    }
}