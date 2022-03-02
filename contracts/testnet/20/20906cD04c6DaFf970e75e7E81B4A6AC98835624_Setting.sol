// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./DurabilitySetting.sol";

contract Setting is DurabilitySetting {

    mapping(uint => mapping(uint => uint[5])) private facilityUpgradeCost;
    mapping(uint => mapping(uint => uint)) private resourceGenerationAmount;
    uint[5] private powerLimit; // power limit: default to 10
    uint[5] private repairBaselineCost; // repair baseline cost: resource type
    uint private powerAmountForHarvest; // power amount required when harvest: default to 10
    uint private powerPerLandtoken; // power amount to buy using land token: default to 25
    uint private powerPerLumber;

    constructor() {
        // Wind Farm upgarde cost
        facilityUpgradeCost[0][1] = [0, 0, 0, 0, 0];
        facilityUpgradeCost[0][2] = [40, 6, 0, 0, 0];
        facilityUpgradeCost[0][3] = [40, 0, 6, 0, 0];
        facilityUpgradeCost[0][4] = [40, 0, 0, 6, 0];
        facilityUpgradeCost[0][5] = [40, 0, 0, 0, 6];

        // Lumber Mill upgrade cost
        facilityUpgradeCost[1][1] = [60, 0, 0, 0, 0];
        facilityUpgradeCost[1][2] = [40, 6, 0, 0, 0];
        facilityUpgradeCost[1][3] = [40, 12, 6, 0, 0];
        facilityUpgradeCost[1][4] = [40, 15, 0, 6, 0];
        facilityUpgradeCost[1][5] = [60, 20, 0, 0, 6];

        // Brick Factory upgrade cost
        facilityUpgradeCost[2][1] = [40, 8, 0, 0, 0];
        facilityUpgradeCost[2][2] = [40, 0, 10, 0, 0];
        facilityUpgradeCost[2][3] = [40, 0, 12, 6, 0];
        facilityUpgradeCost[2][4] = [40, 0, 14, 6, 0];
        facilityUpgradeCost[2][5] = [60, 0, 14, 0, 6];

        // Concrete Plant upgrade cost
        facilityUpgradeCost[3][1] = [40, 10, 10, 0, 0];
        facilityUpgradeCost[3][2] = [40, 0, 10, 0, 0];
        facilityUpgradeCost[3][3] = [40, 0, 0, 12, 6];
        facilityUpgradeCost[3][4] = [40, 0, 6, 14, 6];
        facilityUpgradeCost[3][5] = [60, 6, 6, 16, 6];

        // Steel Mill upgrade cost
        facilityUpgradeCost[4][1] = [40, 0, 10, 10, 0];
        facilityUpgradeCost[4][2] = [40, 0, 0, 0, 10];
        facilityUpgradeCost[4][3] = [40, 0, 0, 6, 12];
        facilityUpgradeCost[4][4] = [40, 0, 6, 6, 14];
        facilityUpgradeCost[4][5] = [60, 6, 6, 6, 16];

        // Initialize facility production amount
        for (uint8 i = 0; i < 5; i++) {
            if (i == 0) {
                resourceGenerationAmount[i][1] = 7;
                resourceGenerationAmount[i][2] = 10;
                resourceGenerationAmount[i][3] = 12;
                resourceGenerationAmount[i][4] = 14;
                resourceGenerationAmount[i][5] = 16;
            } else {
                resourceGenerationAmount[i][1] = 2;
                resourceGenerationAmount[i][2] = 3;
                resourceGenerationAmount[i][3] = 4;
                resourceGenerationAmount[i][4] = 5;
                resourceGenerationAmount[i][5] = 6;
            }
        }    
        
        // Initialize power production limit based on wind farm level
        powerLimit = [100, 110, 120, 125, 130];

        // Initialize harvest power amount to 10
        powerAmountForHarvest = 10;

        // Initialize repair home cost: resource type
        repairBaselineCost = [10, 1, 0, 0, 0];

        // Initialize power amount per land token
        powerPerLandtoken = 25;

        // Initialize power amount per lumber
        powerPerLumber =  20;
    }

    /// Allowd Levels : 1, 2, 3, 4, 5
    modifier onlyAllowedLevel(uint _level) {
        require(_level > 0 && _level <= 5, "Not allowed facility levels");
        _;
    }

    /// Allowed types : [0, 1, 2, 3, 4 ] = [power, lumber, brick, concrete, steel]
    modifier onlyAllowedType(uint _type) {
        require(_type < 5, "Undefined resource type");
        _;
    }

    /** 
        @notice Get facility upgrade cost based facility type and level
        @param _type: facility type
        @param _level: facility level
        @return resource array with PRECISION
    */
    function getFacilityUpgradeCost(uint _type, uint _level) external view onlyAllowedType(_type) onlyAllowedLevel(_level) returns(uint[5] memory) {
        uint[5] memory cost;
        for (uint i = 0; i < 5; i++) {
            cost[i] = uint(facilityUpgradeCost[_type][_level][i]) * PRECISION;
        }

        return cost;
    }

    /** 
        @notice Set facility upgrade cost based facility type and level
        @param _type: resource type
        @param _level: facility level
    */
    function setFacilityUpgradeCost(uint _type, uint _level, uint[5] memory _resource) external onlyOwner onlyAllowedLevel(_level) onlyAllowedType(_type)  { 
        facilityUpgradeCost[_type][_level] = _resource;
    }

    /** 
        @notice Get resource generation amount based on facility type and level
        @param _type: facility type
        @param _level: facility level
        @return generation amount
    */
    function getResourceGenerationAmount(uint _type, uint _level) external view onlyAllowedType(_type) onlyAllowedLevel(_level) returns(uint) {
        return resourceGenerationAmount[_type][_level] * PRECISION;
    }

    /** 
        @notice Set resource generation amount based on facility type and level
        @param _type: facility type
        @param _level: facility level
        @param amount: resource generation amount per type and level
    */
    function setResourceGenerationAmount(uint _type, uint _level, uint amount) external onlyOwner onlyAllowedLevel(_level) onlyAllowedType(_type) { 
        resourceGenerationAmount[_type][_level] = amount;
    }

    /** 
        @notice Get Power max capabillity per user by wind farm level
        @param level : wind farm level
        @return power limit
    */
    function getPowerLimit(uint level) external view onlyAllowedLevel(level) returns(uint) {
        return powerLimit[level-1] * PRECISION;
    }

    /** 
        @notice Set Power max capabillity per user by wind farm level
        @param level : wind farm level
        @param amount: max power amount
    */
    function setPowerLimit(uint level, uint amount) external onlyOwner onlyAllowedLevel(level) {
        powerLimit[level-1] = amount;
    }

    /** 
        @notice get power amount required when harvest
        @return power amount
    */
    function getPowerAmountForHarvest() external view returns(uint) {
        return powerAmountForHarvest * PRECISION;
    }

    /** 
        @notice set power amount required when harvest
        @param amount: power amount required for harvest 
    */
    function setPowerAmountForHarvest(uint amount) external onlyOwner {
        powerAmountForHarvest = amount;
    }    

    /** 
        @notice get repair baseline cost
        @return baselinecost -> resource type
    */
    function getRepairBaselineCost() external view returns(uint[5] memory) {
        uint[5] memory repairCost;
        for (uint i = 0; i < 5; i++) {
            repairCost[i] = uint(repairBaselineCost[i]) * PRECISION;
        }

        return repairCost;
    }

    /** 
        @notice set repair baseline cost
        @param cost: baseline cost resource type
    */
    function setRepairBaselineCost(uint[5] memory cost) external onlyOwner {
        repairBaselineCost = cost;
    }

    /** 
        @notice Get power amount per 1 land token
        @return power amount
    */
    function getPowerPerLandtoken() external view returns(uint) {
        return powerPerLandtoken;
    }

    /** 
        @notice Set power amount per 1 land token
        @param amount: power amount
    */
    function SetPowerPerLandtoken(uint amount) external onlyOwner {
        powerPerLandtoken = amount;
    }

    /** 
        @notice Get power amount per 1 lumber
        @return power amount
    */
    function getPowerPerLumber() external view returns(uint) {
        return powerPerLumber;
    }

    /** 
        @notice Set power amount per 1 lumber
        @param amount: power amount
    */
    function SetPowerPerLumber(uint amount) external onlyOwner {
        powerPerLumber = amount;
    }
}

// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./SpecialAddonSetting.sol";

contract DurabilitySetting is SpecialAddonSetting {

    uint private durabilityReductionPercent; // durability reduction percent: default to 10%
    uint private fortLastDays; // fortification last days: default to set 7 days
    uint private fortPowerCost; // power cost: default to set 2 power per 1 resource for fortification

    constructor() {
        // Initialize durability reduction percent to 10 %
        durabilityReductionPercent = 10;

        // Initialize fortification last days
        fortLastDays = 7;

        // Initialize fortification power cost
        fortPowerCost = 2;
    }

    /** 
        @notice Get durability reduction percent
        @return Reduction percent
    */
    function getDurabilityReductionPercent() external view returns(uint) {
        return durabilityReductionPercent;
    }

    /** 
        @notice Set durability reduction percent
        @param percent: Durabiity reduction percent
    */
    function setDurabilityReductionPercent(uint percent) external onlyOwner {
        durabilityReductionPercent = percent;
    }

     /** 
        @notice Get fortification last days
        @return Last days
    */
    function getFortLastDays() external view returns(uint) {
        return fortLastDays;
    }

    /** 
        @notice Set fortification last days
        @param lastDays: Fortification last days
    */
    function setFortLastDays(uint lastDays) external onlyOwner {
        fortLastDays = lastDays;
    }

    /** 
        @notice Get fortification power cost
        @return Power cost
    */
    function getFortPowerCost() external view returns(uint) {
        return fortPowerCost;
    }

    /** 
        @notice Set fortification power cost
        @param cost: Fortification power cost
    */
    function setFortPowerCost(uint cost) external onlyOwner {
        fortPowerCost = cost;
    }

}

// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./AddonSetting.sol";

contract SpecialAddonSetting is AddonSetting {

    mapping(uint => uint[5]) private toolshedBuildCost;
    mapping(uint => uint[5]) private toolshedDiscountPercent;
    uint[5] private fireplaceCost; // fireplace cost
    uint[5] private harvesterCost; // harvester cost
    uint private fireplaceBurnRatio; // fireplace burn ratio: lumber * ratio/100 = power
    uint private harvesterReductionRatio; // harvester reduction ratio: powerAmountForHarvest * ratio = currentHarvestValue;
    uint[5] toolshedSwitchCost;

    constructor () {
        // Initialize toolshoed build cost types => 1, 2, 3, 4
        toolshedBuildCost[1] = [10, 2, 0, 0, 0];
        toolshedBuildCost[2] = [10, 0, 4, 0, 0];
        toolshedBuildCost[3] = [10, 0, 0, 4, 0];
        toolshedBuildCost[4] = [10, 0, 0, 0, 4];

        // Initialize toolshoed build cost
        toolshedSwitchCost = [10, 0, 0, 0, 0];

        // Initialize toolshoed discount repair percent types => 1, 2, 3, 4
        toolshedDiscountPercent[1] = [20, 30, 0, 0, 0];
        toolshedDiscountPercent[2] = [20, 0, 30, 0, 0];
        toolshedDiscountPercent[3] = [20, 0, 0, 30, 0];
        toolshedDiscountPercent[4] = [20, 0, 0, 0, 30];

        // Initialize fireplace cost & ratio
        fireplaceCost = [0, 0, 8, 0, 0];
        fireplaceBurnRatio = 100; // lumber * ratio/100 = power

        // Initialize fireplace cost & ratio
        harvesterCost = [0, 0, 0, 0, 10];
        harvesterReductionRatio = 50; // powerAmountForHarvest * ratio = currentHarvestValue;
    }

    /// Allowd types : 1, 2, 3, 4
    modifier onlyToolshedType(uint _type) {
        require(_type > 0 && _type <= 4, "Not allowed toolshed types");
        _;
    }

    /** 
        @notice Get toolshed build cost based on type
        @param _type : toolshed type
        @return _resource array
    */
    function getToolshedBuildCost(uint _type) external view onlyToolshedType(_type) returns(uint[5] memory) {
        uint[5] memory cost;

        for (uint i = 0; i < 5; i++) {
            cost[i] = toolshedBuildCost[_type][i] * PRECISION;
        }

        return cost;
    }

    /** 
        @notice Set toolshed build cost based on type
        @param _type : toolshed type
    */
    function setToolshedBuildCost(uint _type, uint[5] memory _resource) external onlyOwner onlyToolshedType(_type) {
        toolshedBuildCost[_type] = _resource;
    }

    /** 
        @notice Get toolshed switch cost based on type
        @return _resource array
    */
    function getToolshedSwitchCost() external view returns(uint[5] memory) {
        uint[5] memory cost;

        for (uint i = 0; i < 5; i++) {
            cost[i] = toolshedSwitchCost[i] * PRECISION;
        }

        return cost;
    }

    /** 
        @notice Set toolshed switch cost
        @param _resource: resource cost in arrray
    */
    function setToolshedSwtichCost(uint8[5] memory _resource) external onlyOwner {
        toolshedSwitchCost = _resource;
    }

    /** 
        @notice Get toolshed discount percent based on type
        @param _type : toolshed type
        @return resource array
    */
    function getToolshedDiscountPercent(uint _type) external view onlyToolshedType(_type) returns(uint[5] memory)  {
        return toolshedDiscountPercent[_type];
    }

    /** 
        @notice Set toolshed discount percent based on type
        @param _type : toolshed type
    */
    function setToolshedDiscountPercent(uint _type, uint[5] memory _resource) external onlyOwner onlyToolshedType(_type) {
        toolshedDiscountPercent[_type] = _resource;
    }

    /** 
        @notice Get fireplace cost
        @return resource array (with PRECISION)
    */
    function getFireplaceCost() external view returns(uint[5] memory)  {
        uint[5] memory cost;

        for (uint i = 0; i < 5; i++) {
            cost[i] = fireplaceCost[i] * PRECISION;
        }

        return cost;
    }

    /** 
        @notice Set fireplace cost
        @param cost : fireplace cost -> resource type
    */
    function setFireplaceCost(uint[5] memory cost) external onlyOwner {
        fireplaceCost = cost;
    }

    /** 
        @notice Get fireplace burn ratio
        @return ratio value
    */
    function getFireplaceBurnRatio() external view returns (uint)  {
        return fireplaceBurnRatio;
    }

    /** 
        @notice Set fireplace burn ratio
        @param ratio : ratio value
    */
    function setFireplaceBurnRatio(uint ratio) external onlyOwner {
        fireplaceBurnRatio = ratio;
    }

    /** 
        @notice Get harvester cost
        @return resource array (with PRECISION)
    */
    function getHarvesterCost() external view returns(uint[5] memory)  {
        uint[5] memory cost;

        for (uint i = 0; i < 5; i++) {
            cost[i] = harvesterCost[i] * PRECISION;
        }

        return cost;
    }

    /** 
        @notice Set harvester cost
        @param cost : harvester cost -> resource type
    */
    function setHarvesterCost(uint[5] memory cost) external onlyOwner {
        harvesterCost = cost;
    }

    /** 
        @notice Get harvester reduction ratio
        @return ratio value
    */
    function getHarvesterReductionRatio() external view returns(uint)  {
        return harvesterReductionRatio;
    }

    /** 
        @notice Set harvester reduction ratio
        @param ratio : ratio value
    */
    function setHarvesterReductionRatio(uint ratio) external onlyOwner {
        harvesterReductionRatio = ratio;
    }
     
}

// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../settings/constants.sol";

contract AddonSetting is Ownable {

    uint[5][11] private baseAddonCost;
    uint[11] private baseAddonMultiplier;
    mapping(uint => uint[]) private baseAddonDependency;  /// addon dependency
    uint[11] private baseAddonFortDependency;  /// addon fortification dependency
    uint private baseAddonSalvagePercent;

    constructor () {
        uint[] memory dataArr1 = new uint[](1);
        uint[] memory dataArr2 = new uint[](2);

        /**
            0 : Hardwood Floors
            1 : Landscaping
            2 : Garden
            3 : Tree
            4 : Kitchen Model
            5 : Bathroom Remodel
            6 : Steel Sliding
            7 : Jacuzzi Tub -> requires [Bathroom Remodel]
            8 : Steel Application -> requires [Kitchen model]
            9 : Finished Basement -> requires [Kitcheck model and Bathroom Remodel]
            10: Root cellar
        */

        /// Initialize base addon build cost
       
        baseAddonCost[0] = [uint(40), 6, 0, 0, 0];
        baseAddonCost[1] = [uint(10), 0, 10, 0, 0];
        baseAddonCost[2] = [uint(50), 0, 0, 0, 0];
        baseAddonCost[3] = [uint(20), 4, 0, 0, 0];
        baseAddonCost[4] = [uint(20), 6, 6, 8, 0];
        baseAddonCost[5] = [uint(20), 6, 6, 8, 0];
        baseAddonCost[6] = [uint(20), 0, 0, 0, 12];
        baseAddonCost[7] = [uint(20), 0, 0, 10, 0];
        baseAddonCost[8] = [uint(20), 0, 0, 0, 8];
        baseAddonCost[9] = [uint(30), 8, 8, 8, 8];
        baseAddonCost[10] = [uint(0), 6, 10, 0, 2];

        /// Initialize base addon multiplier
        baseAddonMultiplier[0] = 110;
        baseAddonMultiplier[1] = 110;
        baseAddonMultiplier[2] = 110;
        baseAddonMultiplier[3] = 105;
        baseAddonMultiplier[4] = 150;
        baseAddonMultiplier[5] = 150;
        baseAddonMultiplier[6] = 130;
        baseAddonMultiplier[7] = 130;
        baseAddonMultiplier[8] = 130;
        baseAddonMultiplier[9] = 180;
        baseAddonMultiplier[10] = 130;

        /// Landscaping addon dependency require: Garden
        dataArr1[0] = 1;
        baseAddonDependency[2] = dataArr1;
        /// Jacuzzi Tub addon dependency require: Bathroom Remodel
        dataArr1[0] = 5;
        baseAddonDependency[7] = dataArr1;
        /// Steel appliances addon dependency require: Kitchen Model
        dataArr1[0] = 4;
        baseAddonDependency[8] = dataArr1;
        /// Finished Basement adddon dependency require: Kitchen Model & Bathroom Remodel
        dataArr2[0] = 4;
        dataArr2[1] = 5;
        baseAddonDependency[9] = dataArr2;

        /// Initialize base addon fortification dependency 1 => brick, 2 => concrete, 3 => steel
        baseAddonFortDependency[6] = 2;
        baseAddonFortDependency[9] = 3;
        baseAddonFortDependency[10] = 1;

        /// Initialie base addon salvage percent
        baseAddonSalvagePercent = 75;
    }

    /** 
        @notice Get base addon cost
        @return Base addon cost
    */
    function getBaseAddonCost() external view returns (uint[5][11] memory) {
        return baseAddonCost;
    }

    /** 
        @notice Get base addon cost
        @param id: Addon id
        @return Addon cost -> resource type
    */
    function getBaseAddonCostById(uint id) external view returns (uint[5] memory) {
        uint[5] memory cost;

        for (uint i = 0; i < 5; i++) cost[i] = baseAddonCost[id][i] * PRECISION;

        return cost;
    }

    /** 
        @notice Set base addon cost
        @param id: Addon id
        @param cost: Addon cost -> resource type
    */
    function setBaseAddonCost(uint id, uint[5] memory cost) external onlyOwner {
        baseAddonCost[id] = cost;
    }

    /** 
        @notice Get base addon multiplier
        @param id: Addon id
        @return Addon multiplier
    */
    function getBaseAddonMultiplier(uint id) external view returns (uint) {
        return baseAddonMultiplier[id];
    }

    /** 
        @notice Set base addon multiplier
        @param id: Addon id
        @param multiplier: Addon multiplier
    */
    function setBaseAddonMultiplier(uint id, uint multiplier) external onlyOwner {
        baseAddonMultiplier[id] = multiplier;
    }

    /** 
        @notice Get base addon dependency
        @param id: Addon id
        @return Addon dependency
    */
    function getBaseAddonDependency(uint id) external view returns (uint[] memory) {
        return baseAddonDependency[id];
    }

    /** 
        @notice Set base addon dependency
        @param id: Addon id
        @param dependency: dependency
    */
    function setBaseAddonDependency(uint id, uint[] memory dependency) external onlyOwner {
        baseAddonDependency[id] = dependency;
    }

    /** 
        @notice Get addon fortification dependency
        @param id : Addon id
        @return Addon fortification dependency
    */
    function getBaseAddonFortDependency(uint id) external view returns (uint) {
        return baseAddonFortDependency[id];
    }

    /** 
        @notice Set addon fortification dependency
        @param id: Addon id
        @param fortDependency: 1 => brick, 2 => concrete, 3 => steel
    */
    function setBaseAddonFortDependency(uint id, uint fortDependency) external onlyOwner {
        baseAddonFortDependency[id] = fortDependency;
    }

    /** 
        @notice Get base addon salvage percent
        @return Addon salvage percent
    */
    function getBaseAddonSalvagePercent() external view returns (uint) {
        return baseAddonSalvagePercent;
    }

    /** 
        @notice Set base addon salvage percent
        @param percent: Salvage percent
    */
    function setBaseAddonSalvagePercent(uint percent) external {
        baseAddonSalvagePercent = percent;
    }
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

// Number of secondes
uint constant SECONDS_IN_A_DAY = 600; // = 60 * 10; set 10 mins as a day
//uint constant SECONDS_IN_A_DAY = 86400; // = 60 * 60 * 24;
//uint constant SECONDS_IN_A_YEAR = 31557600; // = 60 * 60 * 24 * 365.25;
uint constant SECONDS_IN_A_YEAR = 219150; // = 60 * 10 * 365.25; set 10 mins as a day

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