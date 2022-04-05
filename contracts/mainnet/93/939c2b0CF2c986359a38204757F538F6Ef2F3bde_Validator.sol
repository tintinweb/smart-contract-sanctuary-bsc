// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../interface/IHouse.sol";
import "../interface/ISetting.sol";
import "../interface/IHelper.sol";
import "../settings/constants.sol";

contract Validator is Ownable {

    IERC20 landToken;
    ISetting setting;
    IHouse house;
    IHelper helper;

    address private gameContractAddress;

    constructor(
        address _landToken,
        address _settingAddress,
        address _houseAddress,
        address _helperAddres
    ) {
        landToken = IERC20(_landToken);
        setting = ISetting(_settingAddress);
        house = IHouse(_houseAddress);
        helper = IHelper(_helperAddres);
    }

    function setGameContractAddress(address _address) external onlyOwner {
        gameContractAddress = _address;
    }

    function canRepair(uint tokenId, uint percent, address sender) external view returns (bool) {
        address user;
        bool activated;
        uint deadTime;
        (user, activated, deadTime) = house.getOwnerAndStatus(tokenId);
        require(deadTime == 0, "House is dead");
        require(activated, "Activation required");
        require(sender == user, "Repair: PD");
        require(percent > 0, "Percent should above 0");

        return true;
    }

    function canUpgradeFacility(uint tokenId, uint facilityType, address sender) external view returns (bool) {
        address user;
        bool activated;
        uint deadTime;
        (user, activated, deadTime) = house.getOwnerAndStatus(tokenId);
        require(deadTime == 0, "House is dead");
        require(activated, "Activation required");
        require(sender == user, "Facility: PD");
        require(facilityType < 5, "Invalid facilty type");

        return true;
    }

    function canHarvest(uint tokenId, bool[5] memory harvestingReward, address sender) external view returns (bool, uint, uint) {
        address user;
        bool activated;
        uint deadTime;
        (user, activated, deadTime) = house.getOwnerAndStatus(tokenId);
        require(activated, "Activation required");
        require(sender == user, "Harvest: PD");
        
        uint harvestTokenAmount;

        if (harvestingReward[0]) {
            harvestTokenAmount = house.getTokenReward(tokenId);
            require(harvestTokenAmount > 0, "No amount for harvest");
            require(landToken.balanceOf(gameContractAddress) >= harvestTokenAmount, "Not enough landtoken");
        }

        return (true, harvestTokenAmount, deadTime);
    }

    function canBuyPowerWithLandtoken(uint amount, uint totalPowerAmount, address user) external view returns (bool, uint) {
        require (amount > 0, "No amount paid");
        uint powerAmount = amount * setting.getPowerPerLandtoken();
        require(totalPowerAmount + powerAmount <= house.calculateMaxPowerLimitByUser(user), "Exceed the max power limit");
        require(landToken.balanceOf(user) >= amount, "Not enought landtoken");

        return (true, powerAmount);
    }

    function canGatherLumberWithPower(uint amount, uint[3] memory lastGatherLumberTime, address sender) external view returns (bool) {
        bool havingTree = house.checkHavingTree(sender);

        if (havingTree) {
            require(amount == 1 || amount == 2 || amount == 3, "Invaild amount to gather");
        } else {
            require(amount == 1 || amount == 2, "Invaild amount to gather");
        }

        uint maxCountToGather = havingTree ? 3 : 2;
        uint countGatheredToday;

        for (uint i = 0; i < 3; i++)
            if (lastGatherLumberTime[i] + SECONDS_IN_A_DAY > block.timestamp) countGatheredToday++;

        require(countGatheredToday + amount <= maxCountToGather, "Exceed Gathering limit");

        return true;
    }

    function canFrontloadFirepit(uint tokenId, uint lumberAmount, address sender) external view returns (bool) {
        address user;
        bool activated;
        uint deadTime;
        (user, activated, deadTime) = house.getOwnerAndStatus(tokenId);
        require(deadTime == 0, "House is dead");
        require(activated, "Activation required");
        require(sender == user, "Frontload Firepit: PD");
        require(lumberAmount > 0, "No amount to fronload");
        require(lumberAmount <= 10 * PRECISION, "Exceed Frontload Lumbers");

        uint leftDays = house.getFirepitRemainDays(tokenId);
        require(leftDays + lumberAmount <= 10 * PRECISION, "Exceed Frontload Lumbers");

        return true;
    }

    function canBuyResourceOverdrive(uint tokenId, uint facilityType, address sender) external view returns (bool) {
        address user;
        bool activated;
        uint deadTime;
        (user, activated, deadTime) = house.getOwnerAndStatus(tokenId);
        require(deadTime == 0, "House is dead");
        require(activated, "Activation required");
        require(sender == user, "Buy Overdrive: PD");
        require(0 < facilityType && facilityType < 5, "Invalid facility type");
        require(house.canOverDrive(tokenId, facilityType), "Already in Overdrive");
        return true;
    }

    function canBuyTokenOverdrive(uint tokenId, address sender) external view returns (bool) {
        address user;
        bool activated;
        uint deadTime;
        (user, activated, deadTime) = house.getOwnerAndStatus(tokenId);
        require(deadTime == 0, "House is dead");
        require(activated, "Activation required");
        require(sender == user, "Buy Overdrive: PD");
        require(house.canOverDrive(tokenId, 0), "Already in Overdrive");

        return true;
    }

    function canBuyAddon(uint tokenId, uint addonId, address sender) external view returns (bool) {
        address owner;
        bool activated;
        bool[12] memory addons;
        uint deadTime;
        uint expireGardenTime;
        uint[3] memory lastFortificationTime;

        (owner, activated, deadTime, addons, expireGardenTime, lastFortificationTime) = house.getBuyAddonDetails(tokenId);
        require(deadTime == 0, "House is dead");
        require(activated, "Activation required");
        require(sender == owner, "BuyAddon: PD");
        
        require(
            addons[addonId] == false || 
            addonId == 2 && addons[2] && expireGardenTime < block.timestamp,
            "Addon already bought"
        );

        /// check dependencies
        uint[] memory dependency = setting.getBaseAddonDependency(addonId);
        bool isUnlocked = true;
        for (uint i = 0; i < dependency.length; i++) {
            if(addons[dependency[i]] == false) {
                isUnlocked = false;
            }
        }
        require(isUnlocked, "Need to buy dependency addons");

        /// Check fortification dependency
        uint fortDependency = setting.getBaseAddonFortDependency(addonId);
        if (fortDependency > 0) {
            require(lastFortificationTime[fortDependency - 1] > block.timestamp, "Doesn't meet fortification");
        }
        
        return true;
    }

    function canSalvageAddon(uint tokenId, uint addonId, address sender) external view returns (bool) {
        address user;
        bool activated;
        uint deadTime;
        (user, activated, deadTime) = house.getOwnerAndStatus(tokenId);
        require(deadTime == 0, "House is dead");
        require(activated, "Activation required");
        require(sender == user, "Salvage: PD");
        require(house.getHasAddon(tokenId, addonId), "Addon doesn't exist");

        return true;
    }

    function canFertilizeGarden(uint tokenId, address sender) external view returns (bool) {
        address user;
        bool activated;
        uint deadTime;
        (user, activated, deadTime) = house.getOwnerAndStatus(tokenId);
        require(deadTime == 0, "House is dead");
        require(activated, "Activation required");
        require(sender == user, "Fertilize Garden: PD");
        require(house.getHasAddon(tokenId, 2), "Garden should be active");

        return true;
    }

    function canBuyToolshed(uint tokenId, uint _type, address sender) external view returns (bool) {
        address user;
        bool activated;
        uint deadTime;
        (user, activated, deadTime) = house.getOwnerAndStatus(tokenId);
        require(deadTime == 0, "House is dead");
        require(activated, "Activation required");
        require(sender == user, "BuyToolshed: PD");
        require(_type > 0 && _type < 5, "Invalid Toolshed");
        bool[5] memory hasToolshed = house.getToolshed(tokenId);
        require(hasToolshed[_type] == false, "Already bought");

        return true;
    }

    function canSwitchToolshed(uint tokenId, uint _type, address sender) external view returns (bool, uint) {
        address user;
        bool activated;
        uint deadTime;
        (user, activated, deadTime) = house.getOwnerAndStatus(tokenId);
        require(deadTime == 0, "House is dead");
        require(activated, "Activation required");
        require (sender == user, "SwitchToolshed: PD");
        require (0 < _type && _type < 5, "Invalid type");

        uint activeToolshedType = house.getActiveToolshedType(tokenId);
        require (0 < activeToolshedType && activeToolshedType < 5, "Doesn't have an active one");

        bool[5] memory hasToolshed = house.getToolshed(tokenId);
        require (hasToolshed[_type] == true, "Did not buy yet");

        return (true, activeToolshedType);
    }

    function canBuyFireplace(uint tokenId, address sender) external view returns (bool) {
        address user;
        bool activated;
        uint deadTime;
        (user, activated, deadTime) = house.getOwnerAndStatus(tokenId);
        require(deadTime == 0, "House is dead");
        require(activated, "Activation required");
        require(sender == user, "BuyFireplace: PD");
        require(house.getHasFireplace(tokenId) == false, "Already have fireplace");

        return true;
    }

    function canBurnLumber(uint tokenId, uint lumber, uint userLumberResource, uint totalPowerAmout, address sender) external view returns (bool, uint) {
        address user;
        bool activated;
        uint deadTime;
        (user, activated, deadTime) = house.getOwnerAndStatus(tokenId);
        require(deadTime == 0, "House is dead");
        require(activated, "Activation required");
        require(sender == user, "BurnLumber: PD");
        require(lumber > 0, "No amount to burn");
        require(house.getHasFireplace(tokenId), "Fireplace need to be purchased"); 
        require(userLumberResource >= lumber, "Insufficient lumber");

        uint generatedPower = lumber * setting.getFireplaceBurnRatio() / 100;
        require(totalPowerAmout + generatedPower <= house.calculateMaxPowerLimitByUser(user), "Exceed the max power limit");

        return (true, generatedPower);
    }

    function canBuyHarvester(uint tokenId, address sender) external view returns (bool) {
        address user;
        bool activated;
        uint deadTime;
        (user, activated, deadTime) = house.getOwnerAndStatus(tokenId);
        require(deadTime == 0, "House is dead");
        require(activated, "Activation required");
        require(sender == user, "BuyHarvester: PD");
        require(house.getHasHarvester(tokenId) == false, "Already have harvester");

        return true;
    }

    function canBuyConcreteFoundation(uint tokenId, address sender) external view returns (bool) {
        address user;
        bool activated;
        uint deadTime;
        (user, activated, deadTime) = house.getOwnerAndStatus(tokenId);
        require(deadTime == 0, "House is dead");
        require(activated, "Activation required");
        require(sender == user, "Concrete Foundation: PD");
        require(house.getHasConcreteFoundation(tokenId) == false, "Concrete Foundation Exist");

        return true;
    }

    function canHireHandyman(uint tokenId, address sender) external view returns (bool, uint) {
        address user;
        bool activated;
        uint deadTime;
        (user, activated, deadTime) = house.getOwnerAndStatus(tokenId);
        require(deadTime == 0, "House is dead");
        require(activated, "Activation required");
        require(sender == user, "HireHandyman: PD");
        require(house.getHireHandymanHiredTime(tokenId) < block.timestamp, "Already used");

        uint amount = 1 * PRECISION;
        require(landToken.balanceOf(sender) >= amount, "Not enough landtoken");

        return (true, amount);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

abstract contract IHouse {
    function activate(uint tokenId) external virtual;
    function getHasAddons(uint tokenId) external view virtual returns (bool[12] memory);

    function getHousesByOwner(address _owner) public view virtual returns (uint[] memory);
    function getOwnerAndStatus(uint tokenId) public view virtual returns (address, bool, uint);

    function getDepositedBalance(uint tokenId) public view virtual returns (uint);
    function deposit(uint tokenId, uint balance) public virtual;
    function withdraw(uint tokenId, uint balance) public virtual;
    
    function getTokenReward(uint tokenId) public view virtual returns (uint);
    function getHasConcreteFoundation(uint tokenId) external view virtual returns (bool);
    function setHasConcreteFoundation(uint tokenId, bool hasConcreteFoundation) external virtual;
    
    function getHasAddon(uint tokenId, uint addonId) public view virtual returns (bool);
    function setHasAddon(uint tokenId, bool addon, uint addonId) public virtual;
    
    function getHasFireplace(uint tokenId) public view virtual returns (bool);
    function setHasFireplace(uint tokenId, bool hasFireplace) public virtual;
    
    function getHasHarvester(uint tokenId) public view virtual returns (bool);
    function setHasHarvester(uint tokenId, bool hasHarvester) public virtual;
    
    function getToolshed(uint tokenId) public view virtual returns (bool[5] memory);
    function setToolshed(uint tokenId, uint _type) external virtual;

    function getActiveToolshedType(uint tokenId) public view virtual returns (uint);
    
    function getFacilityLevel(uint tokenId, uint _type) public view virtual returns (uint);
    function setFacilityLevel(uint tokenId, uint _level) public virtual;
    
    function getLastFortificationTime(uint tokenId) public view virtual returns (uint[3] memory);
    function setLastFirepitTime(uint tokenId, uint amount) external virtual;

    function getFirepitRemainDays(uint tokenId) external view virtual returns (uint);

    function setAfterHarvest(uint tokenId, bool[5] memory harvestingReward, uint harvestTokenAmount) external virtual;
    function setPowerRewardTime(address user) external virtual;

    function getResourceReward(uint tokenId) external view virtual returns (uint[5] memory);
    function calculateTotalPowerReward(address user) external view virtual returns (uint);
    function calculateMaxPowerLimitByUser(address user) public view virtual returns(uint);

    function checkHavingTree(address user) external view virtual returns (bool);
    function fertilizeGarden(uint tokenId) external virtual;

    function setAfterRepair(uint tokenId, uint repairedDurability) external virtual;
    function setAfterFortify(uint tokenId, uint _type) external virtual;
    function buyResourceOverdrive(uint tokenId, uint facilityType) external virtual;
    function buyTokenOverdrive(uint tokenId) external virtual;
    function canOverDrive(uint tokenId, uint facilityType) external view virtual returns(bool);

    function getHireHandymanHiredTime(uint tokenId) public view virtual returns(uint);
    function repairByHandyman(uint tokenId) external virtual;

    function validateHarvest(uint tokenId) external view virtual returns (bool);
    function getAddonSalvageCost(uint tokenId, uint addonId) external view virtual returns(uint[5] memory, uint[5] memory);
    function getBuyAddonDetails(uint tokenId) external view virtual returns (address, bool, uint, bool[12] memory, uint, uint[3] memory);
    function getHelperDetails(uint tokenId) external view virtual returns (bool, bool, uint, uint, uint, uint, uint, uint, uint, bool, bool);
    
    function getHasaddonAndToolshedType(uint tokenId) external view virtual returns(bool[12] memory, uint);
    function setOnsale(uint tokenId, bool isSale) external virtual;
}

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

abstract contract ISetting {
    function getDetailsForMultiplierCalc(bool isRare) external view virtual returns(uint, uint, uint);
    function getDetailsForHelper(bool isRare, bool hasConcreteFoundation) external view virtual returns(uint[4] memory);
    function getFacilitySetting() external view virtual returns(uint[5][5][5] memory, uint[5][5] memory);
    function getStandardMultiplier() external view virtual returns(uint);
    function getRareMultiplier() external view virtual returns(uint);

    function getFacilityUpgradeCost(uint _type, uint _level) public view virtual returns (uint[5] memory);
    function getResourceGenerationAmount(uint _type, uint _level) public view virtual returns (uint);
    function getPowerLimit(uint level) public view virtual returns (uint);
    function getPowerAmountForHarvest() public view virtual returns (uint);
    function getRepairBaselineCost() public view virtual returns (uint[5] memory);

    function getBaseAddonCost() external view virtual returns (uint[5][12] memory);
    function getBaseAddonCostById(uint id) public view virtual returns (uint[5] memory);
    function getBaseAddonMultiplier() public view virtual returns (uint[12] memory);
    function getBaseAddonDependency(uint id) public view virtual returns (uint[] memory);
    function getBaseAddonFortDependency(uint id) public view virtual returns (uint);
    function getBaseAddonSalvagePercent() external view virtual returns (uint);

    function getDurabilitySetting() external view virtual returns(uint, uint, uint);
    function getDurabilityReductionPercent(bool hasConcreteFoundation) public view virtual returns(uint);
    function getFortLastDays() public view virtual returns (uint);
    function getFortifyCost(uint _type) public view virtual returns (uint[5] memory);

    function getToolshedSetting() external view virtual returns(uint[5][4] memory, uint[5] memory, uint[5][4] memory);
    function getSpecialAddonSetting() external view virtual returns(uint[5] memory, uint, uint[5] memory, uint, uint, uint[5] memory, uint, uint, uint, uint);
    function getToolshedBuildCost(uint _type) public view virtual returns (uint[5] memory);
    function getToolshedSwitchCost() public view virtual returns (uint[5] memory);
    function getToolshedDiscountPercent(uint _type) public view virtual returns (uint[5] memory);
    function getFireplaceCost() public view virtual returns (uint[5] memory);
    function getFireplaceBurnRatio() public view virtual returns (uint);
    function getHarvesterCost() public view virtual returns (uint[5] memory);
    function getHarvesterReductionRatio() public view virtual returns (uint);
    function getPowerPerLandtoken() public view virtual returns (uint);
    function getPowerPerLumber() external view virtual returns (uint);
    function getLastingGardenDays() external view virtual returns (uint);
    function getRequiredAddons(uint id) external view virtual returns (uint[] memory);
    function getSalvageCost(uint id, bool[12] memory hasAddon) external view virtual returns (uint[5] memory, uint[5] memory);
    function getFertilizeGardenCost() external view virtual returns (uint[5] memory);
    function getFertilizeGardenLastingDays() external view virtual returns (uint);
    function getDurabilityDiscountPercent() external view virtual returns(uint);
    function getDurabilityDiscountCost() external view virtual returns(uint[5] memory);
    function getHandymanLastDays() external view virtual returns(uint);
    function getHandymanLandCost() external view virtual returns(uint);

    function getFertilizedGardenMultiplier() external view virtual returns (uint);
    function getOverdrivePowerCost() external view virtual returns(uint);
    function getOverdriveDays() external view virtual returns(uint);
    function getResourceOverdrivePercent() external view virtual returns(uint);
    function getTokenOverdrivePercent() external view virtual returns(uint);
    function getHarvestLimit(bool isRare) external view virtual returns (uint);
    function getResourceGenerationLimit() external view virtual returns(uint);
}

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

abstract contract IHelper {
    function getCountOfFortificationAtTimestamp(uint tokenId, uint timestamp) public view virtual returns (uint);
    function getMultiplierAtTimestamp(uint tokenId, uint timestamp) public view virtual returns (uint);
    function getDurabilityAtTimestamp(uint tokenId, uint timestamp) public view virtual returns (uint);
    function getDurabilityAtBreakpoint(uint timestamp, uint durabilityReductionPercent, uint[3] memory lastFortificationTime, uint[4] memory timeData, uint lastDurability) public pure virtual returns (uint);
    function getCurrentMaxDurability(uint tokenId) public view virtual returns (uint);
    function getSumOfDurabilityWithMultiplier(uint tokenId) public view virtual returns (uint);
    function getRepairCost(uint tokenId, uint percent) external view virtual returns (uint[5] memory);
    function getHarvestCost(uint tokenId, bool[5] memory harvestingReward) external view virtual returns (uint);
    function calculateTokenReward(uint depositedBalance, uint maxTokenReward, bool[12] memory hasAddon, bool isRare, bool hasTokenBoost, bool hasConcreteFoundation, uint[3] memory lastFortificationTime, uint[4] memory timeData, uint lastDurability) external view virtual returns (uint);
    function getRepairData(uint tokenId, uint percent) external view virtual returns(uint, uint, uint[5] memory);
    function getHouseDetails(uint tokenId) public view virtual returns (uint, uint, uint, uint[5] memory, uint, uint);
}

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

// Number of secondes
uint constant SECONDS_IN_A_DAY = 86400; // = 60 * 60 * 24;
uint constant SECONDS_IN_TWO_DAY = 192800; // = 60 * 60 * 24;
uint constant SECONDS_IN_A_YEAR = 31557600; // = 60 * 60 * 24 * 365.25;

// Precision
uint constant PRECISION = 1e18;

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}