//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./Addon.sol";
import "../interface/IMarketplace.sol";
import "../settings/constants.sol";
// import "hardhat/console.sol";

contract Game is Addon {

    constructor(
        address _landToken,
        address _settingAddress,
        address _houseAddress,
        address _helperAddress,
        address _validatorAddress
    ) Addon(_settingAddress, _houseAddress, _helperAddress, _validatorAddress) {
        landToken = IERC20(_landToken);
    }

    IMarketplace marketplace;
    address private stakeContractAddress;

    /**
        @notice Set Stake conract address 
        @param _settingAddress: Setting contract address
        @param _houseAddress: House contract address
        @param _helperAddress: Helper contract address
        @param _stakeAddress: Stake contract address
        @param _validatorAddress: Validator contract address
    */
    function setContractAddress(
        address _settingAddress,
        address _houseAddress,
        address _helperAddress,
        address _stakeAddress,
        address _validatorAddress
    ) external onlyOwner {
        setting = ISetting(_settingAddress);
        house = IHouse(_houseAddress);
        helper = IHelper(_helperAddress);
        validator = IValidator(_validatorAddress);
        stakeContractAddress = _stakeAddress;
    }

    function setMarketplaceContract(address _marketplaceAddress) external onlyOwner {
        marketplace = IMarketplace(_marketplaceAddress);
    }

    /** 
        @notice Repair house with given percent
        @param tokenId: House NFT Id
        @param percent: Percent to repair (with PRECISION)
    */
    function repair(uint tokenId, uint percent) external {
        address user;
        bool activated;
        uint deadTime;
        (user, activated, deadTime) = house.getOwnerAndStatus(tokenId);
        require(deadTime == 0, "House is dead");
        require(activated, "Activation required");
        require(msg.sender == user, "Repair: PD");
        require(percent > 0, "Percent should above 0");
        
        uint maxDurability;
        uint curDurability;
        uint[5] memory repairCost;
        (maxDurability, curDurability, repairCost) = helper.getRepairData(tokenId, percent);
        
        require(curDurability + percent <= maxDurability, "Overflow maximium durability");
        if (maxDurability - curDurability >= 10 * PRECISION) {
            require(percent >= 10 * PRECISION, "Should repair at least 10%");
        } else {
            require(curDurability + percent == maxDurability, "Should repair to max durability");
        }

        subResource(msg.sender, tokenId, repairCost);
        house.setAfterRepair(tokenId, curDurability + percent);

        emit Repair(msg.sender, tokenId, percent);
    }

    /** 
        @notice Upgrade facility
        @param tokenId: House NFT Id
        @param facilityType: index of facility [power, lumber, brick, concrete, steel]
    */
    function upgradeFacility(uint tokenId, uint facilityType) external {
        if (!validator.canUpgradeFacility(tokenId, facilityType, msg.sender)) return;
        
        uint facilityLevel = house.getFacilityLevel(tokenId, facilityType);
        uint[5] memory cost = setting.getFacilityUpgradeCost(facilityType, facilityLevel + 1);

        subResource(msg.sender, tokenId, cost);

        // UpdateResourceReward called from setFacilityLevel
        house.setFacilityLevel(tokenId, facilityType);

        emit UpgradeFacility(msg.sender, tokenId, facilityType, facilityLevel + 1);
    }

    /** 
        @notice Harvest token and resource reward selectively
        @param tokenId: House NFT Id
        @param harvestingReward: Trying to harvest resource reward or not, as array [token, lumber, brick, concrete, steel]
    */
    function harvest(uint tokenId, bool[5] memory harvestingReward) external {
        bool isValid;
        uint deadTime;
        uint harvestTokenAmount;
        (isValid, harvestTokenAmount, deadTime) = validator.canHarvest(tokenId, harvestingReward, msg.sender);
        if (!isValid) return;

        uint powerCost = helper.getHarvestCost(tokenId, harvestingReward);
        uint[5] memory harvestedAmount;

        if (deadTime == 0)
            subResource(msg.sender, tokenId, [powerCost, 0, 0, 0, 0]);

        if (harvestingReward[0]) {
            landToken.transfer(msg.sender, harvestTokenAmount);
        }

        if (harvestingReward[1] || harvestingReward[2] || harvestingReward[3] || harvestingReward[4]) {
            uint[5] memory resourceReward = house.getResourceReward(tokenId);

            for (uint facilityType = 1; facilityType < 5; facilityType++) {
                if (harvestingReward[facilityType]) {
                    harvestedAmount[facilityType] = resourceReward[facilityType];
                }
            }

            addResource(msg.sender, harvestedAmount);
        }

        house.setAfterHarvest(tokenId, harvestingReward, harvestTokenAmount);

        emit Harvest(msg.sender, tokenId, harvestedAmount);
    }

    /** 
        @notice Buy power using landtoken
        @param amount: landtoken amount
    */
    function buyPowerWithLandtoken(uint amount, uint tokenId) external payable {
        bool isValid;
        uint powerAmount;
        (isValid, powerAmount) = validator.canBuyPowerWithLandtoken(tokenId, amount, house.calculateUserPower(tokenId, userResources[msg.sender][0]), msg.sender);
        if (!isValid) return;

        /// auto harvest power before buy power using landtoken
        landToken.transferFrom(msg.sender, address(this), amount);
        autoPowerHarvest(msg.sender, tokenId);
        addResource(msg.sender, [powerAmount, 0, 0, 0, 0]);

        emit BuyPower(msg.sender, amount, powerAmount);
    }

    /**
        @notice Gather lumber using power
        @param amount: amount to gather
    */
    function gatherLumberWithPower(uint amount, uint tokenId) external {
        if (!validator.canGatherLumberWithPower(tokenId, amount, getLastGatherLumberTime(), msg.sender)) return;

        uint powerAmount = setting.getPowerPerLumber() * amount;
        uint[5] memory cost = [powerAmount * PRECISION, 0, 0, 0, 0];

        subResource(msg.sender, tokenId, cost);
        addResource(msg.sender, [0, amount * PRECISION, 0, 0, 0]);
        setGatherLumberTime(amount);

        emit GatherLumber(msg.sender, amount, powerAmount);
    }

    /**
        @notice Fortify and repare (Fixed 10%)
        @param tokenId: House NFT Id
        @param _type: 0 => brick, 1 => concrete, 2 => steel
    */
    function fortify(uint tokenId, uint _type) external {
        address user;
        bool activated;
        uint deadTime;
        (user, activated, deadTime) = house.getOwnerAndStatus(tokenId);
        require(deadTime == 0, "House is dead");
        require(activated, "Activation required");
        require (msg.sender == user, "Fortify: PD");
        require(_type < 3, "Invalid fortification type");

        uint[5] memory cost = setting.getFortifyCost(_type);
        subResource(user, tokenId, cost);
        house.setAfterFortify(tokenId, _type);

        emit Fortify(user, tokenId, _type);
    }

    /**
        @notice Activate house
        @param tokenId: House NFT Id
    */
    function activateHouse(uint tokenId) external {
        address user;
        bool activated;
        uint deadTime;
        (user, activated, deadTime) = house.getOwnerAndStatus(tokenId);
        require(msg.sender == user, "Activate: PD");
        require(activated == false, "Already activated");

        autoPowerHarvest(user, tokenId);
        house.activate(tokenId);

        emit Activate(user, tokenId);
    }

    /**
        @notice Withdraw landtoken from contract
        @param amount: amount to withdraw
    */
    function withdrawLandToken(uint amount) external onlyOwner {
        require(landToken.balanceOf(address(this)) >= amount, "Not enough of token balance");
        landToken.transfer(msg.sender, amount);
    }

    /**
        @notice frontload lumbers to firepit
        @param tokenId: Id of house
        @param lumberAmount : lumber amount with precision
    */
    function frontLoadFirepit(uint tokenId, uint lumberAmount) external {
        if (!validator.canFrontloadFirepit(tokenId, lumberAmount, msg.sender)) return;

        uint[5] memory cost = [uint(0), lumberAmount, 0, 0, 0];

        subResource(msg.sender, tokenId, cost);
        house.setLastFirepitTime(tokenId, lumberAmount);

        emit FrontloadFirepit(msg.sender, tokenId, lumberAmount);
    }

    /**
        @notice Buy Overdrive
        @param tokenId: Id of house
        @param facilityType: type of facility to overdrive
    */
    function buyResourceOverdrive(uint tokenId, uint facilityType) external {
        if (!validator.canBuyResourceOverdrive(tokenId, facilityType, msg.sender)) return;
        
        subResource(msg.sender, tokenId, [15 * PRECISION, 0, 0, 0, 0]);
        house.buyResourceOverdrive(tokenId, facilityType);

        emit BuyResourceOverdrive(msg.sender, tokenId, facilityType);
    }

    function buyTokenOverdrive(uint tokenId) external {
        if (!validator.canBuyTokenOverdrive(tokenId, msg.sender)) return;

        subResource(msg.sender, tokenId, [15 * PRECISION, 0, 0, 0, 0]);
        house.buyTokenOverdrive(tokenId);

        emit BuyTokenOverdrive(msg.sender, tokenId);
    }

    function onSale(uint tokenId, uint amount) external {
        address user;
        uint deadTime;
        (user, , deadTime) = house.getOwnerAndStatus(tokenId);
        require(deadTime == 0, "House is dead");
        require(msg.sender == user, "OnSale: PD");
        require(house.getDepositedBalance(tokenId) == 0, "Shoud unstake all");
        require(house.getTokenReward(tokenId) == 0, "Shoud harvest all");

        house.setOnsale(tokenId, true);
        marketplace.addItem(tokenId, amount);
        
        emit OnSale(msg.sender, tokenId, amount);
    }

    function offSale(uint tokenId) external {
        address user;
        (user, , ) = house.getOwnerAndStatus(tokenId);
        require(msg.sender == user, "OffSale: PD");
        
        house.setOnsale(tokenId, false);
        marketplace.removeItem(tokenId);

        emit OffSale(msg.sender, tokenId);
    }
}

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Resource.sol";
import "../interface/IValidator.sol";

contract Addon is Resource {

    IERC20 landToken;
    IValidator validator;

    constructor(
        address _settingAddress,
        address _houseAddress,
        address _helperAddress,
        address _validatorAddress
    ) Resource(_settingAddress, _houseAddress, _helperAddress) {
        validator = IValidator(_validatorAddress);
    }

    /** 
        @notice Buy base ddon
        @param tokenId: House NFT Id
        @param addonId: Addon id
    */
    function buyAddon(uint tokenId, uint addonId) external {
        if (!validator.canBuyAddon(tokenId, addonId, msg.sender)) return;
        
        /// Buy baseAddon: add baseAddon to house set value true
        uint[5] memory cost = setting.getBaseAddonCostById(addonId);
        subResource(msg.sender, tokenId, cost);

        house.setHasAddon(tokenId, true, addonId);

        emit BuyAddon(msg.sender, tokenId, addonId);
    }

    /** 
        @notice Salvage base addon
        @param tokenId: House NFT Id
        @param addonId: Addon id
    */
    function salvageAddon(uint tokenId, uint addonId) external {
        if (!validator.canSalvageAddon(tokenId, addonId, msg.sender)) return;

        bool[12] memory hasAddon = house.getHasAddons(tokenId);
        uint[5] memory sellCost;
        uint[5] memory salvageCost;
        (salvageCost, sellCost) = setting.getSalvageCost(addonId, hasAddon);

        subResource(msg.sender, tokenId, sellCost);
        addResource(msg.sender, salvageCost);

        house.setHasAddon(tokenId, false, addonId);

        emit SalvageAddon(msg.sender, tokenId, addonId);
    }

    /**
        @notice Fortilize Garden
        @param tokenId: House NFT Id
    */
    function fertilizeGarden(uint tokenId) external {
        if (!validator.canFertilizeGarden(tokenId, msg.sender)) return;

        subResource(msg.sender, tokenId, setting.getFertilizeGardenCost());

        // Update token reward and update lastFertilizedGardenTime
        house.fertilizeGarden(tokenId);

        emit FertilizeGarden(msg.sender, tokenId);
    }

    /**
        @notice Buy specific type of toolshed
        @param tokenId: House NFT Id
        @param _type: type of toolshed
     */
    function buyToolshed(uint tokenId, uint _type) external {
        if (!validator.canBuyToolshed(tokenId, _type, msg.sender)) return;
        
        uint[5] memory cost = setting.getToolshedBuildCost(_type);
        
        subResource(msg.sender, tokenId, cost);
        house.setToolshed(tokenId, _type);

        emit BuyToolshed(msg.sender, tokenId, _type);
    }

    /**
        @notice Switch type of toolshed
        @param tokenId: House NFT Id
        @param _type: type to switch
     */
    function switchToolshed(uint tokenId, uint _type) external {
        bool isValid;
        uint activeToolshedType;
        (isValid, activeToolshedType) = validator.canSwitchToolshed(tokenId, _type, msg.sender);
        if (!isValid) return;
        
        uint[5] memory cost = setting.getToolshedSwitchCost();
        subResource(msg.sender, tokenId, cost);
        house.setToolshed(tokenId, _type);

        emit SwitchToolshed(msg.sender, tokenId, activeToolshedType, _type);
    }

    /**
        @notice Buy fireplace
        @param tokenId: House NFT Id
    */
    function buyFireplace(uint tokenId) external {
        if (!validator.canBuyFireplace(tokenId, msg.sender)) return;
        
        uint[5] memory cost = setting.getFireplaceCost();

        subResource(msg.sender, tokenId, cost);
        house.setHasFireplace(tokenId, true);

        emit BuyFireplace(msg.sender, tokenId);
    }
    
    /**
        @notice Burn lumber to generate power on fireplace
        @param tokenId: House NFT Id
        @param lumber: Lumber amount to burn
    */
    function burnLumberToMakePower(uint tokenId, uint lumber) external {
        bool isValid;
        uint generatedPower;
        (isValid, generatedPower) = validator.canBurnLumber(tokenId, lumber, userResources[msg.sender][1], house.calculateUserPower(tokenId, userResources[msg.sender][0]), msg.sender);
        if (!isValid) return;

        /// Subtract lumber from user and add generated power to uer
        subResource(msg.sender, tokenId, [0, lumber, 0, 0, 0]);
        addResource(msg.sender, [generatedPower, 0, 0, 0, 0]);

        emit BurnLumber(msg.sender, tokenId, lumber, generatedPower);
    }

    /**
        @notice Buy harvester
        @param tokenId: House NFT Id
    */
    function buyHarvester(uint tokenId) external {
        if (!validator.canBuyHarvester(tokenId, msg.sender)) return;

        uint[5] memory cost = setting.getHarvesterCost();
        subResource(msg.sender, tokenId, cost);
        house.setHasHarvester(tokenId, true);

        emit BuyHarvester(msg.sender, tokenId);
    }

    /**
        @notice Buy concrete founcation
    */
    function buyConcreteFoundation(uint tokenId) external {
        if (!validator.canBuyConcreteFoundation(tokenId, msg.sender)) return;

        uint[5] memory cost = setting.getDurabilityDiscountCost();
        subResource(msg.sender, tokenId, cost);
        house.setHasConcreteFoundation(tokenId, true);

        emit ConcreteFoundation(msg.sender, tokenId);
    }

    /**
        @notice Hire handyman
    */
    function hireHandyman(uint tokenId) external payable {
        bool isValid;
        uint cost;
        (isValid, cost) = validator.canHireHandyman(tokenId, msg.sender);
        if (!isValid) return;

        landToken.transferFrom(msg.sender, address(this), cost);
        house.repairByHandyman(tokenId);

        emit RepairByHandyman(msg.sender, tokenId);
    }
}

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

abstract contract IMarketplace {
    function addItem(uint tokenId, uint price) public view virtual returns (uint);
    function removeItem(uint tokenId) public view virtual returns (uint);
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

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../interface/IGameEvents.sol";
import "../interface/ISetting.sol";
import "../interface/IHouse.sol";
import "../interface/IHelper.sol";
import "../settings/constants.sol";

contract Resource is Ownable, IGameEvents {
    ISetting setting;
    IHouse house;
    IHelper helper;

    mapping(address => uint[5]) public userResources;
    mapping(address => uint[3]) private lastGatherLumberTime;

    constructor(
        address _settingAddress,
        address _houseAddress,
        address _helperAddress
    ) {
        setting = ISetting(_settingAddress);
        house = IHouse(_houseAddress);
        helper = IHelper(_helperAddress);
    }

    /** 
        @notice Add resources to user's resource balance
        @param user : receiving user address, resource : resource value
    */
    function addResource(address user, uint[5] memory resource) internal {
        for (uint i = 0; i < 5; i++) {
            if(resource[i] > 0) {
                userResources[user][i] += resource[i];
            }
        }

        emit UpdateResource(user, userResources[user]);
    }

    /** 
        @notice Sub resources from user's resource balance
        @param user : user address, resource : resource value
    */
    function subResource(address user, uint tokenId, uint[5] memory resource) internal {
        require (house.calculateUserPower(tokenId, userResources[user][0]) >= resource[0], "Insufficient power");
        require (userResources[user][1] >= resource[1], "Insufficient lumber");
        require (userResources[user][2] >= resource[2], "Insufficient brick");
        require (userResources[user][3] >= resource[3], "Insufficient concrete");
        require (userResources[user][4] >= resource[4], "Insufficient steel");

        /// Before subtract, auto harvest power 
        autoPowerHarvest(user, tokenId);

        for (uint i = 0; i < 5; i++) {
            if(resource[i] > 0) {
                userResources[user][i] -= resource[i];
            }
        }

        emit UpdateResource(user, userResources[user]);
    }

    /**
        @notice Get user resources
        @return User resources
    */
    function getResource(address user, uint tokenId) public view returns (uint[5] memory) {
        uint[5] memory resource;
        resource = userResources[user];
        resource[0] = house.calculateUserPower(tokenId, userResources[user][0]);
        return resource;
    }

    /** 
        @notice Add resources to user's resource by admin
        @param user : receiving user address, resource : resource value
    */
    function addResourceByAdmin(address user, uint[5] memory resource) public onlyOwner {
        for (uint i = 0; i < 5; i++) {
            userResources[user][i] += resource[i] * PRECISION;
        }
    }

    /**
        @notice Auto harvest power when user update/repair/harvest/fortify etc
        @param user: User
    */
    function autoPowerHarvest(address user, uint tokenId) internal {
        userResources[user][0] = house.calculateUserPower(tokenId, userResources[user][0]);
        house.setPowerRewardTime(tokenId);
    }

    /**
        @notice Get last timestamp of gathering lumber
        @return timestamp
    */
    function getLastGatherLumberTime() public view returns (uint[3] memory) {
        return lastGatherLumberTime[msg.sender];
    }

    /**
        @notice Track last 2 timestamps of gathering lumber
        @param amount: amount to gather
    */
    function setGatherLumberTime(uint amount) internal {
        address user = msg.sender;

        uint nonZeroCount;
        uint i;
        for (i = 0; i < 3; i++)
            if (lastGatherLumberTime[user][i] != 0) nonZeroCount++;
        
        if (amount + nonZeroCount > 3) {
            uint overlapCount = amount + nonZeroCount - 3;
            for (i = 0; i + overlapCount < 3; i++) lastGatherLumberTime[user][i] = lastGatherLumberTime[user][i + overlapCount];
            for ( ; i < 3; i++) lastGatherLumberTime[user][i] = block.timestamp;
        } else {
            for (i = 0; i < amount; i++) lastGatherLumberTime[user][i + nonZeroCount] = block.timestamp;
        }
    }
}

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

abstract contract IValidator {
    function canRepair(uint tokenId, uint percent, address sender) external view virtual returns (bool);
    function canUpgradeFacility(uint tokenId, uint facilityType, address sender) external view virtual returns (bool);
    function canHarvest(uint tokenId, bool[5] memory harvestingReward, address sender) external view virtual returns (bool, uint, uint);
    function canBuyPowerWithLandtoken(uint tokenId, uint amount, uint totalPowerAmount, address user) external view virtual returns (bool, uint);
    function canGatherLumberWithPower(uint tokenId, uint amount, uint[3] memory lastGatherLumberTime, address sender) external view virtual returns (bool);
    function canFrontloadFirepit(uint tokenId, uint lumberAmount, address sender) external view virtual returns (bool);
    function canBuyResourceOverdrive(uint tokenId, uint facilityType, address sender) external view virtual returns (bool);
    function canBuyTokenOverdrive(uint tokenId, address sender) external view virtual returns (bool);
    function canBuyAddon(uint tokenId, uint addonId, address sender) external view virtual returns (bool);
    function canSalvageAddon(uint tokenId, uint addonId, address sender) external view virtual returns (bool);
    function canFertilizeGarden(uint tokenId, address sender) external view virtual returns (bool);
    function canBuyToolshed(uint tokenId, uint _type, address sender) external view virtual returns (bool);
    function canSwitchToolshed(uint tokenId, uint _type, address sender) external view virtual returns (bool, uint);
    function canBuyFireplace(uint tokenId, address sender) external view virtual returns (bool);
    function canBurnLumber(uint tokenId, uint lumber, uint userLumberResource, uint totalPowerAmout, address sender) external view virtual returns (bool, uint);
    function canBuyHarvester(uint tokenId, address sender) external view virtual returns (bool);
    function canBuyConcreteFoundation(uint tokenId, address sender) external view virtual returns (bool);
    function canHireHandyman(uint tokenId, address sender) external view virtual returns (bool, uint);
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

abstract contract IGameEvents {
    event UpdateResource(address indexed user, uint[5] updatedResource);
    event BuyPower(address indexed user, uint landtoken, uint power);
    event GatherLumber(address indexed user, uint lumberAmount, uint powerAmount);
    event UpgradeFacility(address indexed user, uint indexed tokenId, uint _type, uint level);
    event BuyAddon(address indexed user, uint indexed tokenId, uint addonId);
    event SalvageAddon(address indexed user, uint indexed tokenId, uint addonId);
    event BuyToolshed(address indexed user, uint indexed tokenId, uint _type);
    event SwitchToolshed(address indexed user, uint indexed tokenId, uint _fromType, uint _toType);
    event BuyFireplace(address indexed user, uint indexed tokenId);
    event BurnLumber(address indexed user, uint indexed tokenId, uint lumber, uint power);
    event BuyHarvester(address indexed user, uint indexed tokenId);
    event Repair(address indexed user, uint indexed tokenId, uint amount);
    event Fortify(address indexed user, uint indexed tokenId, uint _type);
    event Harvest(address indexed user, uint indexed tokenId, uint[5] harvestedResource);
    event Activate(address indexed user, uint indexed tokenId);
    event FrontloadFirepit(address indexed user, uint indexed tokenId, uint lumberAmount);
    event FertilizeGarden(address indexed user, uint indexed tokenId);
    event BuyResourceOverdrive(address indexed user, uint indexed tokenId, uint facilityType);
    event BuyTokenOverdrive(address indexed user, uint indexed tokenId);
    event ConcreteFoundation(address indexed user, uint indexed tokenId);
    event RepairByHandyman(address indexed user, uint indexed tokenId);
    event OnSale(address indexed user, uint indexed tokenId, uint indexed price);
    event OffSale(address indexed user, uint indexed tokenId);

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

abstract contract IHouse {
    function activate(uint tokenId) external virtual;
    function getHasAddons(uint tokenId) external view virtual returns (bool[12] memory);

    function getHousesByOwner(address _owner) public view virtual returns (uint[] memory);
    function getActiveHouseByOwner(address _owner) public view virtual returns(uint);
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
    function setPowerRewardTime(uint tokenId) external virtual;

    function getResourceReward(uint tokenId) external view virtual returns (uint[5] memory);
    function calculateUserPower(uint tokenId, uint userPowerAmount) external view virtual returns(uint);
    function calculateMaxPowerLimitByUser(uint tokenId) public view virtual returns(uint);

    function checkHavingTree(uint tokenId) external view virtual returns (bool);
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