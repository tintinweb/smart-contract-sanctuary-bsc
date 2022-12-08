// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/structs/EnumerableSet.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableSet.js.

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 * Trying to delete such a structure from storage will likely result in data corruption, rendering the structure
 * unusable.
 * See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 * In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an
 * array of EnumerableSet.
 * ====
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        bytes32[] memory store = _values(set._inner);
        bytes32[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "../interface/ISetting.sol";
import "../settings/constants.sol";

contract Resource is Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;
    
    event UpdateResource(address indexed user, uint[5] updatedResource);
    event UpgradeFacility(address indexed user, uint _type, uint level);
    event BuyHarvester(address indexed user);
    event GatherLumber(address indexed user, uint lumberAmount, uint powerAmount);
    event BuyFireplace(address indexed user);
    event BuyResourceOverdrive(address indexed user, uint facilityType);

    ISetting setting;
    EnumerableSet.AddressSet private _whitelist;
    address private backendAddress;

    mapping(address => uint[5]) public userResources;  // Having user's resource
    mapping(address => uint[5]) public facilityLevels; // User facility levels data
    mapping(address => uint[5]) public resourceReward; // Pending resources to harvest until `lastResourceRewardTime`
    mapping(address => uint[5]) public lastResourceRewardTime; // The time when updating `resourceReward`
    mapping(address => uint[3]) private lastGatherLumberTime;  // Last gather lumber time
    mapping(address => bool[5]) public hasBoost; // User boost status
    mapping(address => uint) public userTotalDepositedBalance; // User's total deposited balance for all house
    mapping(address => uint) public userHouseCount; // Count of houses that user owns
    mapping(address => bool) public userHasHarvester; // User harvester status
    mapping(address => bool) public userHasTreeAddon; // User tree addon status
    mapping(address => bool) public userHasFireplace; // User Fireplace status

    constructor(
        address _settingAddress,
        address _backendAddress
    ) {
        setting = ISetting(_settingAddress);
        backendAddress = _backendAddress;
    }

    /** 
        @notice Check msg.sender has permission to access game contract
    */
    modifier onlyHasPermission() {
        require (msg.sender == backendAddress, "Permission denied");
        _;
    }

    modifier onlyWhitelisted(address _account) {
        require(
            _whitelist.contains(_account),
            "Resource: not whitelisted address."
        );
        _;
    }

    /**
     * @notice Add an address to the whitelist.
     * @param _address Address to add to the whitelist.
     */
    function addAddressToWhitelist(address _address) external onlyOwner {
        _whitelist.add(_address);
    }

    /**
     * @notice Remove an address from the whitelist.
     * @param _address Address to remove from the whitelist.
     */
    function removeAddressFromWhitelist(address _address) external onlyOwner {
        _whitelist.remove(_address);
    }

    /** 
        @notice Add resources to user's resource balance
        @param user : receiving user address, resource : resource value
    */
    function addResource(address user, uint[5] memory resource) public onlyWhitelisted(msg.sender) {
        for (uint i = 0; i < 5; i++) {
            if(resource[i] > 0) {
                userResources[user][i] += resource[i];
            }
        }

        emit UpdateResource(user, userResources[user]);
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
        @notice Set facility levels by admin
    */
    function setFacilityLevel(address user, uint[5] memory levels) public onlyOwner {
        facilityLevels[user] = levels;
    }

    /** 
        @notice Sub resources from user's resource balance
        @param user: user address
        @param resource: resouce amount to sub
        @param powerAmount: total user's power amount
    */
    function subResource(address user, uint[5] memory resource, uint powerAmount) public onlyWhitelisted(msg.sender) {
        require (powerAmount >= resource[0], "Insufficient power");
        require (userResources[user][1] >= resource[1], "Insufficient lumber");
        require (userResources[user][2] >= resource[2], "Insufficient brick");
        require (userResources[user][3] >= resource[3], "Insufficient concrete");
        require (userResources[user][4] >= resource[4], "Insufficient steel");

        /// Before subtract, auto harvest power 
        autoPowerHarvest(user, powerAmount);

        for (uint i = 0; i < 5; i++) {
            if(resource[i] > 0) {
                userResources[user][i] -= resource[i];
            }
        }

        emit UpdateResource(user, userResources[user]);
    }

    /**
        @notice Sub resource when unstake
    */
    function subResourceWhenUnstake(address user, uint[5] memory resource) external onlyWhitelisted(msg.sender) {
        subResource(user, resource, calculateUserPowerAmount(user));
    }

    /**
        @notice Get user resources
        @return User resources
    */
    function getResource(address user) public view returns (uint[5] memory) {
        uint[5] memory resource;
        resource = userResources[user];
        resource[0] = calculateUserPowerAmount(user);
        return resource;
    }

    /**
        @notice Auto harvest power when user update/repair/harvest/fortify etc
        @param user: User
    */
    function autoPowerHarvest(address user, uint powerAmount) public onlyWhitelisted(msg.sender) {
        userResources[user][0] = powerAmount;
        lastResourceRewardTime[user][0] = block.timestamp;
    }

    /** 
        @notice Upgrade facility
        @param facilityType: index of facility [power, lumber, brick, concrete, steel]
    */
    function upgradeFacility(address user, uint facilityType, uint[5] memory cost, uint facilityLevel, uint powerAmount, uint[5] memory reward) external onlyHasPermission {
        subResource(user, cost, powerAmount);
        updateResourceReward(user, reward);
        facilityLevels[user][facilityType]++;

        emit UpgradeFacility(user, facilityType, facilityLevel + 1);
    }

    /**
        @notice Buy harvester
    */
    function buyHarvester(address user, uint[5] memory cost, uint powerAmount) external onlyHasPermission {
        subResource(user, cost, powerAmount);
        userHasHarvester[user] = true;

        emit BuyHarvester(user);
    }

    /**
        @notice Gather lumber using power
        @param amount: amount to gather
    */
    function gatherLumberWithPower(address user, uint amount, uint powerAmount) external onlyHasPermission {
        uint neededPowerAmount = setting.getPowerPerLumber() * amount;
        uint[5] memory cost = [neededPowerAmount * PRECISION, 0, 0, 0, 0];
        subResource(user, cost, powerAmount);
        setGatherLumberTime(amount, user);
        addResource(user, [0, amount * PRECISION, 0, 0, 0]);

        emit GatherLumber(user, amount, neededPowerAmount);
    }

    /**
        @notice Buy fireplace
    */
    function buyFireplace(address user, uint[5] memory cost, uint powerAmount) external onlyHasPermission {
        subResource(user, cost, powerAmount);
        userHasFireplace[user] = true;

        emit BuyFireplace(user);
    }

    /**
        @notice Buy resource overdrive
        @param user: Owner of house
    */
    function buyResourceOverdrive(address user, uint facilityType, uint powerAmount, uint[5] memory reward) external onlyHasPermission {
        subResource(user, [25 * PRECISION, 0, 0, 0, 0], powerAmount);
        updateResourceReward(user, reward);
        hasBoost[user] = [false, false, false, false, false];
        hasBoost[user][facilityType] = true;

        emit BuyResourceOverdrive(user, facilityType);
    }

    /**
        @notice Track last 2 timestamps of gathering lumber
        @param amount: amount to gather
    */
    function setGatherLumberTime(uint amount, address user) private {
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

    /** 
        @notice Store recent resource reward
        @param user: User address
    */
    function updateResourceReward(address user, uint[5] memory reward) public onlyWhitelisted(msg.sender) {
        resourceReward[user] = reward;
        
        for (uint i = 1; i < 5; i++) {
            lastResourceRewardTime[user][i] = block.timestamp;
        }
    }

    /** 
        @notice Reset resource reward
        @param user: User address
    */
    function resetResourceReward(address user, uint facilityType) external onlyWhitelisted(msg.sender) {
        resourceReward[user][facilityType] = 0;
        lastResourceRewardTime[user][facilityType] = block.timestamp;
    }

    /** 
        @notice Set windfarm facility level to 1 when activate
        @param user: User address
    */
    function checkBeforeActivate(address user) external onlyWhitelisted(msg.sender) {
        if (facilityLevels[user][0] == 0) {
            facilityLevels[user][0] = 1;
            lastResourceRewardTime[user][0] = block.timestamp;
        }
    }

    /**
        @notice Calculate recent resource reward generated
        @param user: User
        @return reward amount in array
    */
    function getResourceReward(address user) public view returns (uint[5] memory) {
        uint[5] memory reward;
        
        for (uint facilityType = 1; facilityType < 5; facilityType++) {
            if (facilityLevels[user][facilityType] == 0) continue;

            uint generationAmount = setting.getResourceGenerationAmount(facilityType, facilityLevels[user][facilityType]);

            reward[facilityType] = resourceReward[user][facilityType];
            if (hasBoost[user][facilityType]) {
                reward[facilityType] += generationAmount * (block.timestamp - lastResourceRewardTime[user][facilityType])  * 130 / 100 / SECONDS_IN_A_DAY;
            } else {
                reward[facilityType] += generationAmount * (block.timestamp - lastResourceRewardTime[user][facilityType]) / SECONDS_IN_A_DAY;
            }

            // Limit for resource harvest
            if (reward[facilityType] > 10 * PRECISION) {
                reward[facilityType] = 10 * PRECISION;
            }
        }

        return reward;
    }

    /**
        @notice Calculate user's total power amount
        @param user: User
    */
    function calculateUserPowerAmount(address user) public view returns(uint) {
        uint powerLimit;
        uint powerReward;

        powerReward = setting.getResourceGenerationAmount(0, facilityLevels[user][0]) * (block.timestamp - lastResourceRewardTime[user][0]) / SECONDS_IN_A_DAY;
        powerLimit = setting.getPowerLimit(facilityLevels[user][0]);

        if (powerReward + userResources[user][0] >= powerLimit) {
            return powerLimit;
        } else {
            return userResources[user][0] + powerReward;
        }
    }

    /**
        @notice Calculate max power limit by user based on windfarm level
        @param user: user address
        @return max power limit
    */
    function calculateMaxPowerLimitByUser(address user) public view returns(uint) {
        return setting.getPowerLimit(facilityLevels[user][0]);
    }

    /**
        @notice Get last timestamp of gathering lumber
        @return timestamp
    */
    function getLastGatherLumberTime(address user) public view returns (uint[3] memory) {
        return lastGatherLumberTime[user];
    }

    /**
        @notice Add deposit balance called from Stake contract
    */
    function addUserDepositedBalance(address user, uint amount) external onlyWhitelisted(msg.sender) {
        userTotalDepositedBalance[user] += amount;
    }

    /**
        @notice Sub deposit balance called from Stake contract
    */
    function subUserDepositedBalance(address user, uint amount) external onlyWhitelisted(msg.sender) {
        userTotalDepositedBalance[user] -= amount;
    }

    /**
        @notice Transfer deposit balance
    */
    function transferUserDepositedBalance(address fromUser, address toUser, uint amount) external onlyWhitelisted(msg.sender) {
        userTotalDepositedBalance[fromUser] -= amount;
        userTotalDepositedBalance[toUser] += amount;
    }

    /**
        @notice Get user's facility level by facility type
        @return facilityLevel
    */
    function getUserFacilityLevel(address user, uint facilityType) public view returns (uint) {
        return facilityLevels[user][facilityType];
    }

    /**
        @notice Get user's facility levels [Wind Farm, Lumber Mill, Brick Factory, Concrete Plant, Steel Mill]
        @return facilityLevels
    */
    function getFacilityLevels(address user) external view returns(uint[5] memory) {
        return facilityLevels[user];
    }

    /**
        Add user houses count
    */
    function addHouseToUser(address user) external onlyWhitelisted(msg.sender) {
        userHouseCount[user]++;
    }

    /**
        Sub user houses count
    */
    function removeHouseToUser(address user) external onlyWhitelisted(msg.sender) {
        if (userHouseCount[user] > 0) userHouseCount[user]--;
    }

    /**
        @notice Get max facility level of user
    */
    function getMaxFacilityLevel(address user) public view returns(uint) {
        return userHouseCount[user] * 5;
    }

    /**
        @notice Get User harvester status
    */
    function getHasHarvester(address user) external view returns (bool) {
        return userHasHarvester[user];
    }

    /**
        @notice Get user's boost status
    */
    function getUserHasBoost(address user) external view returns(bool[5] memory) {
        return hasBoost[user];
    }

     /**
        @notice Get user fireplace status
    */
    function getUserHasFireplace(address user) external view returns(bool) {
        return userHasFireplace[user];
    }

    /**
        @notice Get user tree addon status
    */
    function getUserHasTreeAddon(address user) external view returns(bool) {
        return userHasTreeAddon[user];
    }

    /**
        @notice Set user tree addon
    */
    function setUserHasTreeAddon(address user) external onlyWhitelisted(msg.sender) {
        userHasTreeAddon[user] = true;
    }

    /**
        @notice Get user's power cost per 1 LAND Token
        @return powerCost: Power per land token
    */
    function getBuyPowerCost(address user) public view returns(uint) {
        uint negativePower;
        if (userTotalDepositedBalance[user] <= 1000) {
            negativePower = userTotalDepositedBalance[user] / 40; // Power cost increase every 40 deposited tokens
        } else if (userTotalDepositedBalance[user] > 1000) {
            negativePower = 30;
        }
        
        return 50 - negativePower; // 1 Land => 50 power
    }
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

// Number of secondes
uint constant SECONDS_IN_A_DAY = 86400; // = 60 * 60 * 24;
uint constant SECONDS_IN_TWO_DAY = 192800; // = 60 * 60 * 24;
uint constant SECONDS_IN_A_YEAR = 31557600; // = 60 * 60 * 24 * 365.25;

// Precision
uint constant PRECISION = 1e18;