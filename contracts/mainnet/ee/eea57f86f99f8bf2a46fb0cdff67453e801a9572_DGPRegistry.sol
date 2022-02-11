/**
 *Submitted for verification at BscScan.com on 2022-02-11
*/

// File: @openzeppelin\contracts\utils\structs\EnumerableSet.sol

// SPDX-License-Identifier: MIT

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
                bytes32 lastvalue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastvalue;
                // Update the index for the moved value
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
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
     * @dev Returns the number of values on the set. O(1).
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
}

// File: contracts\library\MGPLib.sol

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library MGPLib {
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;

    function toArray(EnumerableSet.AddressSet storage addressSet) internal view returns (address[] memory content) {
        uint256 count = addressSet.length();
        content = new address[](count);
        for (uint256 index = 0; index < count; ++index) content[index] = addressSet.at(index);
    }

    function toArray(EnumerableSet.UintSet storage uintSet) internal view returns (uint256[] memory content) {
        uint256 count = uintSet.length();
        content = new uint256[](count);
        for (uint256 index = 0; index < count; ++index) content[index] = uintSet.at(index);
    }

    function toBytes(uint256 x) internal pure returns (bytes memory b) {
        b = new bytes(32);
        assembly {
            mstore(add(b, 32), x)
        }
    }

    function decodeDrifter(uint256 compositeData)
        internal
        pure
        returns (
            uint8 rarity,
            uint8 rank,
            uint8 level,
            uint8 class,
            uint16 strength,
            uint16 agility,
            uint16 intelligence,
            uint16 constitution,
            uint16 vitality,
            uint32 exp,
            uint32 remainingTime,
            uint32 totalTime
        )
    {
        rarity = uint8(compositeData);
        rank = uint8(compositeData >> 8);
        level = uint8(compositeData >> 16);
        class = uint8(compositeData >> 24);
        strength = uint16(compositeData >> 32);
        agility = uint16(compositeData >> 48);
        intelligence = uint16(compositeData >> 64);
        constitution = uint16(compositeData >> 80);
        vitality = uint16(compositeData >> 96);
        exp = uint32(compositeData >> 112);
        remainingTime = uint32(compositeData >> 144);
        totalTime = uint32(compositeData >> 176);
    }

    function decodeDrifterBasic(uint256 compositeData)
        internal
        pure
        returns (
            uint8 rarity,
            uint8 rank,
            uint8 class,
            uint32 remainingTime,
            uint32 totalTime
        )
    {
        rarity = uint8(compositeData);
        rank = uint8(compositeData >> 8);
        class = uint8(compositeData >> 24);
        remainingTime = uint32(compositeData >> 144);
        totalTime = uint32(compositeData >> 176);
    }

    function decodeDrifterLevel(uint256 compositeData)
        internal
        pure
        returns (
            uint8 rarity,
            uint8 rank,
            uint8 level,
            uint8 class,
            uint16 strength,
            uint16 agility,
            uint16 intelligence,
            uint16 constitution,
            uint16 vitality,
            uint32 exp
        )
    {
        rarity = uint8(compositeData);
        rank = uint8(compositeData >> 8);
        level = uint8(compositeData >> 16);
        class = uint8(compositeData >> 24);
        strength = uint16(compositeData >> 32);
        agility = uint16(compositeData >> 48);
        intelligence = uint16(compositeData >> 64);
        constitution = uint16(compositeData >> 80);
        vitality = uint16(compositeData >> 96);
        exp = uint32(compositeData >> 112);
    }
}

// File: contracts\interfaces\IDGPRegistry.sol

interface IDGPRegistry {
    function createProject(string calldata name) external;

    function updateProject(uint256 projectId, string calldata name) external;

    function transferProjectOwner(uint256 projectId, address newOwner) external;

    function addProjectOperator(uint256 projectId, address operator) external;

    function removeProjectOperator(uint256 projectId, address operator) external;

    function projectOperators(uint256 projectId) external view returns (address[] memory operators);

    function setParent(
        uint256 projectId,
        address target,
        address parent
    ) external;

    function ancestor(uint256 projectId, address target) external view returns (address _ancestor);

    function ancestors(
        uint256 projectId,
        address target,
        uint256 level
    ) external view returns (uint256 count, address[] memory _ancestors);
}

// File: contracts\DGP\DGPRegistry.sol

contract DGPRegistry is IDGPRegistry {
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;
    using MGPLib for EnumerableSet.AddressSet;

    event ProjectCreated(address indexed owner);
    event AddOperator(uint256 indexed projectId, address indexed operator);
    event RemoveOperator(uint256 indexed projectId, address indexed operator);
    event TransferProjectOwner(uint256 indexed projectId, address indexed newOwner);
    event BeParent(uint256 indexed projectId, address target, address parent);

    struct Project {
        string name;
        EnumerableSet.AddressSet operators;
    }

    address public constant addressZero = address(0);

    uint256 private _projectCounter;
    // account => projectIds;
    mapping(address => EnumerableSet.UintSet) private _ownedProjects;
    // project id => project
    mapping(uint256 => Project) private _projects;
    // project id => address => parent
    mapping(uint256 => mapping(address => address)) private _ancestorRegistry;
    mapping(uint256 => mapping(address => EnumerableSet.AddressSet)) private _childrenRegistry;

    constructor() {}

    /**
     * @dev Create a project
     * @param name name of the project
     */
    function createProject(string calldata name) external override {
        // get next project Id
        uint256 projectId = _projectCounter;
        // add to user's owned project id
        _ownedProjects[msg.sender].add(projectId);
        // set project name
        _projects[projectId].name = name;
        // update project counter
        _projectCounter = projectId + 1;
        emit ProjectCreated(msg.sender);
    }

    /**
     * @dev Update the name of a owned project
     * @param projectId the id of the project
     * @param name new name of the project
     */
    function updateProject(uint256 projectId, string calldata name) external override onlyProjectOwner(projectId) {
        _projects[projectId].name = name;
    }

    /**
     * @dev Transfer owner ship of a project
     * @param projectId the id of the project
     * @param newOwner new owner of the project
     */
    function transferProjectOwner(uint256 projectId, address newOwner) external override onlyProjectOwner(projectId) {
        // remove project form current owner
        _ownedProjects[msg.sender].remove(projectId);
        // add project to new owner
        _ownedProjects[newOwner].add(projectId);
        emit TransferProjectOwner(projectId, newOwner);
    }

    /**
     * @dev Add an operator to a owned project, operator can create or update parent relationship
     * @param projectId the id of the project
     * @param operator new operator for the project
     */
    function addProjectOperator(uint256 projectId, address operator) external override onlyProjectOwner(projectId) {
        require(_projects[projectId].operators.add(operator), "already an operator");
        emit AddOperator(projectId, operator);
    }

    /**
     * @dev Remove an operator from a owned project
     * @param projectId the id of the project
     * @param operator the operator to be removed
     */
    function removeProjectOperator(uint256 projectId, address operator) external override onlyProjectOwner(projectId) {
        require(_projects[projectId].operators.remove(operator), "not an operator");
        emit RemoveOperator(projectId, operator);
    }

    /**
     * @dev Get operators of a project
     * @param projectId the id of the project
     * @return operators
     */
    function projectOperators(uint256 projectId) external view override returns (address[] memory operators) {
        operators = _projects[projectId].operators.toArray();
    }

    /**
     * @dev Get the name of a project
     * @param projectId the id of the project
     * @return name of the project
     */
    function projectName(uint256 projectId) external view returns (string memory name) {
        name = _projects[projectId].name;
    }

    /**
     * @dev Set relationship through operators
     * @param projectId the id of the project
     * @param target the one will be set parent
     * @param parent parent of 'target'
     */
    function setParent(
        uint256 projectId,
        address target,
        address parent
    ) external override onlyProjectOperator(projectId) {
        // get old parent
        address oldParent = _ancestorRegistry[projectId][target];
        // if old parent is not 0x0, means it has parent before.
        // remove target from parent at first
        if (oldParent != addressZero) _childrenRegistry[projectId][oldParent].remove(target);
        // set new parent
        _ancestorRegistry[projectId][target] = parent;
        // add to parent's children
        _childrenRegistry[projectId][parent].add(target);
        emit BeParent(projectId, target, parent);
    }

    /**
     * @dev Get children count of a account
     * @param projectId the id of the project
     * @param target the target to query
     */
    function childrenCount(uint256 projectId, address target) public view returns (uint256 count) {
        count = _childrenRegistry[projectId][target].length();
    }

    /**
     * @dev Get children of a account
     * @param projectId the id of the project
     * @param target the target to query
     * @param offset the offset to query
     * @param limit the limit to query
     */
    function children(
        uint256 projectId,
        address target,
        uint256 offset,
        uint256 limit
    ) external view returns (uint256 count, address[] memory children_) {
        EnumerableSet.AddressSet storage _children = _childrenRegistry[projectId][target];
        count = childrenCount(projectId, target);
        if (offset + limit > count) limit = count - offset;
        children_ = new address[](limit);
        for (uint256 index = 0; index < limit; ++index) children_[index] = _children.at(offset + index);
    }

    /**
     * @dev Get count of the project owned
     * @param target the target to query
     */
    function projectCount(address target) public view returns (uint256 count) {
        count = _ownedProjects[target].length();
    }

    /**
     * @dev Get owned id of one user
     * @param target the target to query
     * @param offset the offset to query
     * @param limit the limit to query
     */
    function projectIds(
        address target,
        uint256 offset,
        uint256 limit
    ) external view returns (uint256 count, uint256[] memory projectIds_) {
        count = projectCount(target);
        if (offset + limit > count) limit = count - offset;
        projectIds_ = new uint256[](limit);
        for (uint256 index = 0; index < limit; ++index) projectIds_[index] = _ownedProjects[target].at(offset + index);
    }

    /**
     * @dev Get direct ancestor of one account(parent)
     * @param projectId the id of the project
     * @param target the target to query
     */
    function ancestor(uint256 projectId, address target) external view override returns (address _ancestor) {
        _ancestor = _ancestorRegistry[projectId][target];
    }

    /**
     * @dev Get multi level ancestor of one account
     * @param projectId the id of the project
     * @param target the target to query
     * @param level the levels to query
     */
    function ancestors(
        uint256 projectId,
        address target,
        uint256 level
    ) external view override returns (uint256 count, address[] memory _ancestors) {
        address parent = target;
        _ancestors = new address[](level);
        for (count = 0; count < level; ++count) {
            parent = _ancestorRegistry[projectId][parent];
            if (parent == addressZero) break;
            _ancestors[count] = parent;
        }
    }

    modifier onlyProjectOwner(uint256 projectId) {
        require(_ownedProjects[msg.sender].contains(projectId), "require owner");
        _;
    }
    modifier onlyProjectOperator(uint256 projectId) {
        require(_projects[projectId].operators.contains(msg.sender), "require operator");
        _;
    }
}