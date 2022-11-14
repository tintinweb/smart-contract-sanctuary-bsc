// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./TokenConstant.sol";
import "./Ownable.sol";

    error TreasureIdError();
    error ChefIdError();
    error AddCrystalsError();

    struct Tower {
        uint256  crystals;
        uint256  money;
        uint256  money2;
        uint256  yield;
        uint256  timestamp;
        uint256  hrs;
        address  ref;
        uint256  refs;
        uint256  refDeps;
        uint8    treasury;
        uint8[5] chefs;
    }

contract LandKingdom is Ownable {

    using TokenConstant for address;

    uint constant public denominator = 10;

    bool public init;
    uint16 public airdropCount;
    uint256 public totalChefs;
    uint256 public totalTowers;
    uint256 public totalInvested;
    uint256 public seasonTime;
    address public manager;
    address public developer;
    address public blackHole;
    address public CertificateAddress;
    address public PAPCTokenAddress;
    address[] plyers;
    address[] whiteListPlyers;
    mapping(address => Tower) public towers;
    mapping(address => bool) public whiteList;

    modifier initialized {
        require(init, "Not initialized");
        _;
    }

    modifier seasonCheck {
        require(block.timestamp >= seasonTime + 60 days, "time not reached");
        _;
    }

    constructor(address _manager, address _developer, address _blackHole, address _certificateAddress, address _PAPCTokenAddress, uint16 _airdropCount) {
        manager = _manager;
        developer = _developer;
        blackHole = _blackHole;
        CertificateAddress = _certificateAddress;
        PAPCTokenAddress = _PAPCTokenAddress;
        airdropCount = _airdropCount;
    }

    function cleanDataAndStartNewSeason() external seasonCheck {
        require(!init, "alreay init");
        init = true;
        seasonTime = block.timestamp;

        for(uint i; i < plyers.length; i++) {
            delete towers[plyers[i]];
        }

        for(uint i; i < whiteListPlyers.length; i++) {
            delete whiteList[plyers[i]];
        }

        delete plyers;
        delete whiteListPlyers;
        delete totalChefs;
        delete totalTowers;
        delete totalInvested;
    }

    function seasonEnd() external initialized seasonCheck {
        require(plyers.length >= airdropCount, "not enought count");
        init = false;

        bytes memory balance = PAPCTokenAddress.tokenCallData(TokenConstant.balanceOf(address(this)));
        uint256 userBalance = abi.decode(balance, (uint256));
        uint256 avarage = userBalance / airdropCount;

        for(uint i; i < airdropCount / 2; i++) {
            address startPlayer = plyers[i];
            address endPlayer = plyers[plyers.length - 1 - i];

            PAPCTokenAddress.tokenCall(TokenConstant.transfer(startPlayer, avarage));
            PAPCTokenAddress.tokenCall(TokenConstant.transfer(endPlayer, avarage));
        }
    }

    function addCrystals(address referral, uint256 value) external initialized {
        address user = msg.sender;

        bytes memory balance = CertificateAddress.tokenCallData(TokenConstant.balanceOf(user));
        uint256 userBalance = abi.decode(balance, (uint256));

        if(userBalance == 0) {
            if(whiteList[user]) {
                referral = blackHole;
            } else {
                bytes memory referralBalance = CertificateAddress.tokenCallData(TokenConstant.balanceOf(referral));
                uint256 referraluserBalance = abi.decode(referralBalance, (uint256));

                if (towers[referral].timestamp == 0 || referraluserBalance == 0) {
                    revert AddCrystalsError();
                }
            }
        }

        uint256 crystals = value / 1e20;
        require(crystals > 0, "zero crystals");
        totalInvested += value;

        if (towers[user].timestamp == 0) {
            totalTowers++;
            plyers.push(user);
            referral = towers[referral].timestamp == 0 ? manager : referral;
            towers[referral].refs++;
            towers[user].ref = referral;
            towers[user].timestamp = block.timestamp;
            towers[user].treasury = 0;
        }

        referral = towers[user].ref;
        towers[referral].crystals += (crystals * 8) / 100;
        towers[referral].money += (crystals * 100 * 4) / 100;
        towers[referral].refDeps += crystals;
        towers[user].crystals += crystals;
        towers[manager].crystals += (crystals * 8) / 100;

        uint256 valueToManager =  (value * 5) / 100;
        uint256 managerValue = valueToManager * 90 / 100;
        uint256 developerValue = valueToManager * 10 / 100;

        PAPCTokenAddress.tokenCall(TokenConstant.transferFrom(msg.sender, manager, managerValue));
        PAPCTokenAddress.tokenCall(TokenConstant.transferFrom(msg.sender, developer, developerValue));
        PAPCTokenAddress.tokenCall(TokenConstant.transferFrom(msg.sender, address(this), value - valueToManager));
    }

    function withdrawMoney(uint256 gold) external initialized {
        address user = msg.sender;
        require(gold <= towers[user].money && gold > 0, "not enough gold");
        towers[user].money -= gold;
        uint256 amount = gold * 1e18;

        bytes memory balance = PAPCTokenAddress.tokenCallData(TokenConstant.balanceOf(address(this)));
        uint256 userBalance = abi.decode(balance, (uint256));

        if(msg.sender == manager) {
            uint256 managerValue = amount * 90 / 100;
            uint256 developerValue = amount * 10 / 100;

            PAPCTokenAddress.tokenCall(TokenConstant.transfer(manager, userBalance < managerValue ? userBalance : managerValue));
            PAPCTokenAddress.tokenCall(TokenConstant.transfer(developer, userBalance < developerValue ? userBalance : developerValue));
        } else {
            PAPCTokenAddress.tokenCall(TokenConstant.transfer(user, userBalance < amount ? userBalance : amount));
        }
    }

    function upgradeTower(uint256 towerId) external initialized {
        require(towerId < 5, "Max 5 towers");
        address user = msg.sender;
        syncTower(user);
        towers[user].chefs[towerId]++;
        totalChefs++;
        uint256 chefs = towers[user].chefs[towerId];
        towers[user].crystals -= getUpgradePrice(towerId, chefs) / denominator;
        towers[user].yield += getYield(towerId, chefs);
    }

    function collectMoney() public {
        address user = msg.sender;
        syncTower(user);
        towers[user].hrs = 0;
        towers[user].money += towers[user].money2;
        towers[user].money2 = 0;
    }

    function upgradeTreasury() external {
        address user = msg.sender;
        uint8 treasuryId = towers[user].treasury + 1;
        syncTower(user);
        require(treasuryId < 5, "Max 5 treasury");
        (uint256 price,) = getTreasure(treasuryId);
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

    //only owner
    function initialize() external onlyOwner {
        require(!init, "alreay init");
        init = true;
        seasonTime = block.timestamp;
    }

    function setWhiteAddress(address _addr, bool _isAdd) external onlyOwner {
        whiteList[_addr] = _isAdd;

        if(_isAdd) {
            whiteListPlyers.push(_addr);
        }
    }

    function setAirDropCount(uint16 _airdropCount) external onlyOwner {
        require(_airdropCount >= 10 && _airdropCount % 2 == 0, "input error");
        airdropCount = _airdropCount;
    }

    function getChefs(address addr) external view returns (uint8[5] memory) {
        return towers[addr].chefs;
    }

    function syncTower(address user) internal {
        require(towers[user].timestamp > 0, "User is not registered");
        if (towers[user].yield > 0) {
            (, uint256 treasury) = getTreasure(towers[user].treasury);
            uint256 hrs = block.timestamp / 3600 - towers[user].timestamp / 3600;
            if (hrs + towers[user].hrs > treasury) {
                hrs = treasury - towers[user].hrs;
            }
            towers[user].money2 += hrs * towers[user].yield;
            towers[user].hrs += hrs;
        }
        towers[user].timestamp = block.timestamp;
    }

    function getUpgradePrice(uint256 towerId, uint256 chefId) internal pure returns (uint256) {
        if (chefId == 1) return [400, 4000, 12000, 24000, 40000][towerId];
        if (chefId == 2) return [600, 6000, 18000, 36000, 60000][towerId];
        if (chefId == 3) return [900, 9000, 27000, 54000, 90000][towerId];
        if (chefId == 4) return [1360, 13500, 40500, 81000, 135000][towerId];
        if (chefId == 5) return [2040, 20260, 60760, 121500, 202500][towerId];
        if (chefId == 6) return [3060, 30400, 91140, 182260, 303760][towerId];
        revert ChefIdError();
    }

    function getYield(uint256 towerId, uint256 chefId) internal pure returns (uint256) {
        if (chefId == 1) return [5, 56, 179, 382, 678][towerId];
        if (chefId == 2) return [8, 85, 272, 581, 1030][towerId];
        if (chefId == 3) return [12, 128, 413, 882, 1564][towerId];
        if (chefId == 4) return [18, 195, 682, 1340, 2379][towerId];
        if (chefId == 5) return [28, 297, 954, 2035, 3620][towerId];
        if (chefId == 6) return [42, 450, 1439, 3076, 5506][towerId];
        revert ChefIdError();
    }

    function getTreasure(uint256 treasureId) internal pure returns (uint256, uint256) {
        if(treasureId == 0) return (0, 24); // price | value
        if(treasureId == 1) return (2000, 30);
        if(treasureId == 2) return (2500, 36);
        if(treasureId == 3) return (3000, 42);
        if(treasureId == 4) return (4000, 48);
        revert TreasureIdError();
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

contract Ownable {
    // attributes
    address private _owner;

    // modifier
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    // event
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(msg.sender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

error ErrorCall(bytes);

library TokenConstant {
    function transferFrom(address from, address to, uint256 amount) external pure returns (bytes memory) {
        return abi.encodeWithSignature("transferFrom(address,address,uint256)", from, to, amount);
    }

    function transfer(address to, uint256 amount) external pure returns (bytes memory) {
        return abi.encodeWithSignature("transfer(address,uint256)", to, amount);
    }

    function balanceOf(address owner) external pure returns (bytes memory) {
        return abi.encodeWithSignature("balanceOf(address)", owner);
    }

    function tokenCallData(address callAddress, bytes memory data) internal returns (bytes memory returnData) {
        (, returnData) = callAddress.call(data);
    }

    function tokenCall(address callAddress, bytes memory callData) internal {
        (bool success, ) = callAddress.call(callData);
        if(!success) {
            revert ErrorCall(callData);
        }
    }
}