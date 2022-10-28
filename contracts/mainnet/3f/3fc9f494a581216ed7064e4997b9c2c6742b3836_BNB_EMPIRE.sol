/**
 *Submitted for verification at BscScan.com on 2022-10-28
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

library AddressUpgradeable {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

pragma solidity ^0.8.2;
abstract contract Initializable {
    uint8 private _initialized;
    bool private _initializing;
    event Initialized(uint8 version);
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
}

pragma solidity 0.8.17;
pragma experimental ABIEncoderV2;


contract BNB_EMPIRE is Initializable {
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

    uint256 public totalChefs;
    uint256 public totalTowers;
    uint256 public totalInvested;
    address public manager;
    uint256 public denominator;
    bool public init;

    modifier initialized() {
        require(init, "Not initialized");
        _;
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() public initializer {
        manager = 0x00086f61c2218D0F156c9B11E93398be435F5000;
        denominator = 10;
    }

    function initial() external {
        require(manager == msg.sender);
        require(!init);
        init = true;
    }

    function addCrystals(address ref) external payable {
        uint256 crystals = msg.value / 5e14;
        require(crystals > 0, "Zero crystals");
        address user = msg.sender;
        totalInvested += msg.value;
        if (towers[user].timestamp == 0) {
            totalTowers++;
            ref = towers[ref].timestamp == 0 ? manager : ref;
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
        towers[manager].crystals += (crystals * 8) / 100;
        payable(manager).transfer((msg.value * 5) / 100);
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