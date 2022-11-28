/**
 *Submitted for verification at BscScan.com on 2022-11-27
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
        uint256 refCoins;
        uint8 refLevel;
        uint8[8] levels;
    }

    // address public constant BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); // BUSD address
    IERC20 public constant BUSD =
        IERC20(0x7A62eE9B6cde5cdd3Fd9d82448952f8E2f99c8C0); // MockBUSD address for bsc testnet

    uint256 public constant COIN_PRICE = 5 * 10**(18 - 3); // 1 coin = 0.005 BUSD
    uint256 public constant CASH_PRICE = 5 * 10**(18 - 5); // 100 cash = 0.005 BUSD

    // 100: 1%, 10000: 100%
    uint256 public constant DEV_FEE = 400;
    uint256 public constant DEV_COIN_FEE = 500;
    uint256 public constant DEV_CASH_FEE = 500;
    uint256 public constant LIMIT_INCOME = 15000;
    uint256 public constant DENOMINATOR = 10000;
    uint256 public constant LOCK_TIME = 168 hours;
    uint8 public constant LOCK_LEVEL = 5; // House 6

    mapping(address => House) private houses;

    address[] public allHouses;

    uint256 public totalUpgrades;
    uint256 public totalInvested;

    address public manager = msg.sender;

    function addCoins(address _ref, uint256 _amount) external {
        require(_amount > 0, "ZERO_BUSD_AMOUNT");
        require(
            BUSD.transferFrom(msg.sender, address(this), _amount),
            "TRANSFERFROM_FAIL"
        );
        uint256 coins = _amount / COIN_PRICE;

        address user = msg.sender;
        totalInvested += _amount;

        uint8 refLevel = houses[_ref].refLevel;
        if (houses[user].timestamp == 0) {
            allHouses.push(user);
            houses[user].refLevel = refLevel < 3 ? refLevel + 1 : 3;
            _ref = _ref == address(0) ? manager : _ref;
            houses[_ref].refs++;
            houses[user].ref = _ref;
            houses[user].timestamp = block.timestamp;
        }

        _ref = houses[user].ref;
        refLevel = houses[user].refLevel;

        (
            uint256 refCoin,
            uint256 refCash,
            uint256 refInvested
        ) = getReferralYield(refLevel, coins, _amount);
        houses[_ref].coins += refCoin;
        houses[_ref].cash += refCash;
        houses[_ref].refCoins += coins;

        houses[user].coins += coins;

        houses[manager].coins += (coins * DEV_COIN_FEE) / DENOMINATOR;

        require(
            BUSD.transfer(manager, (_amount * DEV_FEE) / DENOMINATOR),
            "TRANSFER_FAIL"
        );

        houses[user].invested += _amount;
        houses[_ref].invested += refInvested;
    }

    function withdrawMoney() external {
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
        amount = BUSD.balanceOf(address(this)) < amount
            ? BUSD.balanceOf(address(this))
            : amount;
        require(BUSD.transfer(user, amount), "TRANSFER_FAIL");

        houses[user].withdrawn += amount;

        amount = cashFee * CASH_PRICE;
        require(
            BUSD.transfer(
                manager,
                BUSD.balanceOf(address(this)) < amount
                    ? BUSD.balanceOf(address(this))
                    : amount
            ),
            "TRANSFER_FAIL"
        );
    }

    function collectMoney() public {
        address user = msg.sender;
        _makeBurgers(user);
        houses[user].hrs = 0;
        houses[user].cash += houses[user].burger;
        houses[user].burger = 0;
    }

    function upgradeHouse(uint256 _houseId) external {
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

    function getReferralYield(
        uint8 _refLevel,
        uint256 _coins,
        uint256 _amount
    )
        private
        pure
        returns (
            uint256 refCoin,
            uint256 refCash,
            uint256 refInvested
        )
    {
        if (_refLevel < 2) {
            refCoin = (_coins * 7) / 100;
            refCash = _coins * 3;
            refInvested = (_amount * 10) / 100;
        } else if (_refLevel < 3) {
            refCoin = (_coins * 3) / 100;
            refCash = _coins * 2;
            refInvested = (_amount * 5) / 100;
        } else {
            refCoin = (_coins * 2) / 100;
            refCash = _coins;
            refInvested = (_amount * 3) / 100;
        }
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

    function setManager(address _manager) external {
        require(msg.sender == manager, "Not manager!");
        manager = _manager;
    }

    function allHousesLength() external view returns (uint256) {
        return allHouses.length;
    }
}