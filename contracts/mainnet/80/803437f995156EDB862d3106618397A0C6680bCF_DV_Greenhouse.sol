/**
 *Submitted for verification at BscScan.com on 2022-01-31
*/

// File: @openzeppelin/contracts/utils/structs/EnumerableSet.sol


// OpenZeppelin Contracts v4.4.0 (utils/structs/EnumerableSet.sol)

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
        return _values(set._inner);
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

        assembly {
            result := store
        }

        return result;
    }
}

// File: @openzeppelin/contracts/utils/introspection/IERC165.sol


// OpenZeppelin Contracts v4.4.0 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: @openzeppelin/contracts/utils/introspection/ERC165.sol


// OpenZeppelin Contracts v4.4.0 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;


/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// File: @openzeppelin/contracts/utils/Strings.sol


// OpenZeppelin Contracts v4.4.0 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.0 (utils/Context.sol)

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

// File: @openzeppelin/contracts/security/Pausable.sol


// OpenZeppelin Contracts v4.4.0 (security/Pausable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// File: @openzeppelin/contracts/access/IAccessControl.sol


// OpenZeppelin Contracts v4.4.0 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

// File: @openzeppelin/contracts/access/AccessControl.sol


// OpenZeppelin Contracts v4.4.0 (access/AccessControl.sol)

pragma solidity ^0.8.0;





/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// File: @openzeppelin/contracts/access/IAccessControlEnumerable.sol


// OpenZeppelin Contracts v4.4.0 (access/IAccessControlEnumerable.sol)

pragma solidity ^0.8.0;


/**
 * @dev External interface of AccessControlEnumerable declared to support ERC165 detection.
 */
interface IAccessControlEnumerable is IAccessControl {
    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) external view returns (address);

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) external view returns (uint256);
}

// File: @openzeppelin/contracts/access/AccessControlEnumerable.sol


// OpenZeppelin Contracts v4.4.0 (access/AccessControlEnumerable.sol)

pragma solidity ^0.8.0;




/**
 * @dev Extension of {AccessControl} that allows enumerating the members of each role.
 */
abstract contract AccessControlEnumerable is IAccessControlEnumerable, AccessControl {
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(bytes32 => EnumerableSet.AddressSet) private _roleMembers;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlEnumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) public view override returns (address) {
        return _roleMembers[role].at(index);
    }

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) public view override returns (uint256) {
        return _roleMembers[role].length();
    }

    /**
     * @dev Overload {_grantRole} to track enumerable memberships
     */
    function _grantRole(bytes32 role, address account) internal virtual override {
        super._grantRole(role, account);
        _roleMembers[role].add(account);
    }

    /**
     * @dev Overload {_revokeRole} to track enumerable memberships
     */
    function _revokeRole(bytes32 role, address account) internal virtual override {
        super._revokeRole(role, account);
        _roleMembers[role].remove(account);
    }
}

// File: @chainlink/contracts/src/v0.8/VRFRequestIDBase.sol


pragma solidity ^0.8.0;

contract VRFRequestIDBase {
  /**
   * @notice returns the seed which is actually input to the VRF coordinator
   *
   * @dev To prevent repetition of VRF output due to repetition of the
   * @dev user-supplied seed, that seed is combined in a hash with the
   * @dev user-specific nonce, and the address of the consuming contract. The
   * @dev risk of repetition is mostly mitigated by inclusion of a blockhash in
   * @dev the final seed, but the nonce does protect against repetition in
   * @dev requests which are included in a single block.
   *
   * @param _userSeed VRF seed input provided by user
   * @param _requester Address of the requesting contract
   * @param _nonce User-specific nonce at the time of the request
   */
  function makeVRFInputSeed(
    bytes32 _keyHash,
    uint256 _userSeed,
    address _requester,
    uint256 _nonce
  ) internal pure returns (uint256) {
    return uint256(keccak256(abi.encode(_keyHash, _userSeed, _requester, _nonce)));
  }

  /**
   * @notice Returns the id for this request
   * @param _keyHash The serviceAgreement ID to be used for this request
   * @param _vRFInputSeed The seed to be passed directly to the VRF
   * @return The id for this request
   *
   * @dev Note that _vRFInputSeed is not the seed passed by the consuming
   * @dev contract, but the one generated by makeVRFInputSeed
   */
  function makeRequestId(bytes32 _keyHash, uint256 _vRFInputSeed) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked(_keyHash, _vRFInputSeed));
  }
}

// File: @chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol


pragma solidity ^0.8.0;

interface LinkTokenInterface {
  function allowance(address owner, address spender) external view returns (uint256 remaining);

  function approve(address spender, uint256 value) external returns (bool success);

  function balanceOf(address owner) external view returns (uint256 balance);

  function decimals() external view returns (uint8 decimalPlaces);

  function decreaseApproval(address spender, uint256 addedValue) external returns (bool success);

  function increaseApproval(address spender, uint256 subtractedValue) external;

  function name() external view returns (string memory tokenName);

  function symbol() external view returns (string memory tokenSymbol);

  function totalSupply() external view returns (uint256 totalTokensIssued);

  function transfer(address to, uint256 value) external returns (bool success);

  function transferAndCall(
    address to,
    uint256 value,
    bytes calldata data
  ) external returns (bool success);

  function transferFrom(
    address from,
    address to,
    uint256 value
  ) external returns (bool success);
}

// File: @chainlink/contracts/src/v0.8/VRFConsumerBase.sol


pragma solidity ^0.8.0;



/** ****************************************************************************
 * @notice Interface for contracts using VRF randomness
 * *****************************************************************************
 * @dev PURPOSE
 *
 * @dev Reggie the Random Oracle (not his real job) wants to provide randomness
 * @dev to Vera the verifier in such a way that Vera can be sure he's not
 * @dev making his output up to suit himself. Reggie provides Vera a public key
 * @dev to which he knows the secret key. Each time Vera provides a seed to
 * @dev Reggie, he gives back a value which is computed completely
 * @dev deterministically from the seed and the secret key.
 *
 * @dev Reggie provides a proof by which Vera can verify that the output was
 * @dev correctly computed once Reggie tells it to her, but without that proof,
 * @dev the output is indistinguishable to her from a uniform random sample
 * @dev from the output space.
 *
 * @dev The purpose of this contract is to make it easy for unrelated contracts
 * @dev to talk to Vera the verifier about the work Reggie is doing, to provide
 * @dev simple access to a verifiable source of randomness.
 * *****************************************************************************
 * @dev USAGE
 *
 * @dev Calling contracts must inherit from VRFConsumerBase, and can
 * @dev initialize VRFConsumerBase's attributes in their constructor as
 * @dev shown:
 *
 * @dev   contract VRFConsumer {
 * @dev     constuctor(<other arguments>, address _vrfCoordinator, address _link)
 * @dev       VRFConsumerBase(_vrfCoordinator, _link) public {
 * @dev         <initialization with other arguments goes here>
 * @dev       }
 * @dev   }
 *
 * @dev The oracle will have given you an ID for the VRF keypair they have
 * @dev committed to (let's call it keyHash), and have told you the minimum LINK
 * @dev price for VRF service. Make sure your contract has sufficient LINK, and
 * @dev call requestRandomness(keyHash, fee, seed), where seed is the input you
 * @dev want to generate randomness from.
 *
 * @dev Once the VRFCoordinator has received and validated the oracle's response
 * @dev to your request, it will call your contract's fulfillRandomness method.
 *
 * @dev The randomness argument to fulfillRandomness is the actual random value
 * @dev generated from your seed.
 *
 * @dev The requestId argument is generated from the keyHash and the seed by
 * @dev makeRequestId(keyHash, seed). If your contract could have concurrent
 * @dev requests open, you can use the requestId to track which seed is
 * @dev associated with which randomness. See VRFRequestIDBase.sol for more
 * @dev details. (See "SECURITY CONSIDERATIONS" for principles to keep in mind,
 * @dev if your contract could have multiple requests in flight simultaneously.)
 *
 * @dev Colliding `requestId`s are cryptographically impossible as long as seeds
 * @dev differ. (Which is critical to making unpredictable randomness! See the
 * @dev next section.)
 *
 * *****************************************************************************
 * @dev SECURITY CONSIDERATIONS
 *
 * @dev A method with the ability to call your fulfillRandomness method directly
 * @dev could spoof a VRF response with any random value, so it's critical that
 * @dev it cannot be directly called by anything other than this base contract
 * @dev (specifically, by the VRFConsumerBase.rawFulfillRandomness method).
 *
 * @dev For your users to trust that your contract's random behavior is free
 * @dev from malicious interference, it's best if you can write it so that all
 * @dev behaviors implied by a VRF response are executed *during* your
 * @dev fulfillRandomness method. If your contract must store the response (or
 * @dev anything derived from it) and use it later, you must ensure that any
 * @dev user-significant behavior which depends on that stored value cannot be
 * @dev manipulated by a subsequent VRF request.
 *
 * @dev Similarly, both miners and the VRF oracle itself have some influence
 * @dev over the order in which VRF responses appear on the blockchain, so if
 * @dev your contract could have multiple VRF requests in flight simultaneously,
 * @dev you must ensure that the order in which the VRF responses arrive cannot
 * @dev be used to manipulate your contract's user-significant behavior.
 *
 * @dev Since the ultimate input to the VRF is mixed with the block hash of the
 * @dev block in which the request is made, user-provided seeds have no impact
 * @dev on its economic security properties. They are only included for API
 * @dev compatability with previous versions of this contract.
 *
 * @dev Since the block hash of the block which contains the requestRandomness
 * @dev call is mixed into the input to the VRF *last*, a sufficiently powerful
 * @dev miner could, in principle, fork the blockchain to evict the block
 * @dev containing the request, forcing the request to be included in a
 * @dev different block with a different hash, and therefore a different input
 * @dev to the VRF. However, such an attack would incur a substantial economic
 * @dev cost. This cost scales with the number of blocks the VRF oracle waits
 * @dev until it calls responds to a request.
 */
abstract contract VRFConsumerBase is VRFRequestIDBase {
  /**
   * @notice fulfillRandomness handles the VRF response. Your contract must
   * @notice implement it. See "SECURITY CONSIDERATIONS" above for important
   * @notice principles to keep in mind when implementing your fulfillRandomness
   * @notice method.
   *
   * @dev VRFConsumerBase expects its subcontracts to have a method with this
   * @dev signature, and will call it once it has verified the proof
   * @dev associated with the randomness. (It is triggered via a call to
   * @dev rawFulfillRandomness, below.)
   *
   * @param requestId The Id initially returned by requestRandomness
   * @param randomness the VRF output
   */
  function fulfillRandomness(bytes32 requestId, uint256 randomness) internal virtual;

  /**
   * @dev In order to keep backwards compatibility we have kept the user
   * seed field around. We remove the use of it because given that the blockhash
   * enters later, it overrides whatever randomness the used seed provides.
   * Given that it adds no security, and can easily lead to misunderstandings,
   * we have removed it from usage and can now provide a simpler API.
   */
  uint256 private constant USER_SEED_PLACEHOLDER = 0;

  /**
   * @notice requestRandomness initiates a request for VRF output given _seed
   *
   * @dev The fulfillRandomness method receives the output, once it's provided
   * @dev by the Oracle, and verified by the vrfCoordinator.
   *
   * @dev The _keyHash must already be registered with the VRFCoordinator, and
   * @dev the _fee must exceed the fee specified during registration of the
   * @dev _keyHash.
   *
   * @dev The _seed parameter is vestigial, and is kept only for API
   * @dev compatibility with older versions. It can't *hurt* to mix in some of
   * @dev your own randomness, here, but it's not necessary because the VRF
   * @dev oracle will mix the hash of the block containing your request into the
   * @dev VRF seed it ultimately uses.
   *
   * @param _keyHash ID of public key against which randomness is generated
   * @param _fee The amount of LINK to send with the request
   *
   * @return requestId unique ID for this request
   *
   * @dev The returned requestId can be used to distinguish responses to
   * @dev concurrent requests. It is passed as the first argument to
   * @dev fulfillRandomness.
   */
  function requestRandomness(bytes32 _keyHash, uint256 _fee) internal returns (bytes32 requestId) {
    LINK.transferAndCall(vrfCoordinator, _fee, abi.encode(_keyHash, USER_SEED_PLACEHOLDER));
    // This is the seed passed to VRFCoordinator. The oracle will mix this with
    // the hash of the block containing this request to obtain the seed/input
    // which is finally passed to the VRF cryptographic machinery.
    uint256 vRFSeed = makeVRFInputSeed(_keyHash, USER_SEED_PLACEHOLDER, address(this), nonces[_keyHash]);
    // nonces[_keyHash] must stay in sync with
    // VRFCoordinator.nonces[_keyHash][this], which was incremented by the above
    // successful LINK.transferAndCall (in VRFCoordinator.randomnessRequest).
    // This provides protection against the user repeating their input seed,
    // which would result in a predictable/duplicate output, if multiple such
    // requests appeared in the same block.
    nonces[_keyHash] = nonces[_keyHash] + 1;
    return makeRequestId(_keyHash, vRFSeed);
  }

  LinkTokenInterface internal immutable LINK;
  address private immutable vrfCoordinator;

  // Nonces for each VRF key from which randomness has been requested.
  //
  // Must stay in sync with VRFCoordinator[_keyHash][this]
  mapping(bytes32 => uint256) /* keyHash */ /* nonce */
    private nonces;

  /**
   * @param _vrfCoordinator address of VRFCoordinator contract
   * @param _link address of LINK token contract
   *
   * @dev https://docs.chain.link/docs/link-token-contracts
   */
  constructor(address _vrfCoordinator, address _link) {
    vrfCoordinator = _vrfCoordinator;
    LINK = LinkTokenInterface(_link);
  }

  // rawFulfillRandomness is called by VRFCoordinator when it receives a valid VRF
  // proof. rawFulfillRandomness then calls fulfillRandomness, after validating
  // the origin of the call
  function rawFulfillRandomness(bytes32 requestId, uint256 randomness) external {
    require(msg.sender == vrfCoordinator, "Only VRFCoordinator can fulfill");
    fulfillRandomness(requestId, randomness);
  }
}

// File: dv_greenhouse.sol

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;





////////////////////////////////////////////////////////////////////////////////////////
//
//    DogeVille 
//    Website : https://www.dogeville.finance
//    dApp : https://app.dogeville.financial
//
//        __      _
//      o'')}____//
//       `_/      )
//       (_(_/-(_/
//
//    Greenhouse v1.00
//    This is the Greenhouse for DogeVille, which handles mutations for Seeds
//   
//    This Contract is designed to be upgraded and replaced as the scope expands
//  
///////////////////////////////////////////////////////////////////////////////////////

contract DV_Greenhouse is Context, AccessControlEnumerable, Pausable, VRFConsumerBase {

    // Dead address
    address public _dead = 0x000000000000000000000000000000000000dEaD;
    
    // Contracts
    address public _SeedAddress = 0xAAefd50A2D08aA7acf2B1e97D5C62853f7F537C7;
    SeedInterface _SeedContract;

    address public _Evol0Address = 0x5A1757F332A5cF4ef9e74C061132829709c2222a;
    Evol0Interface _Evol0Contract;

    address public _tokenAddress;
    IERC20 public DVILLEToken;
    uint256 public DVToken_Decimals = 1 * 10 ** 18;

    address public _bankerAddress = 0x491847218154a7C1e8d54b7dAf11112E415a3ffd;
    DogeBanker public DVILLEBanker;

    // For Wallets
    address payable public devWallet = payable(0x6b9346814eE6A54Ad66918a7a6C5699C27D1D481);

    // Keep track of SEED Data

    mapping (address => mapping (uint256 => uint256)) public mutationAvailable;
    
    // Modifiers for Greenhouse
    
    uint256 public COST_Base = 300000 * 10 ** 18;
    uint256 public COST_IncreasePerEvol = 300000 * 10 ** 18;
    uint256 public COST_IncrementPerMint = 100000 * 10 ** 18;
    uint256 public COOLDOWN_Base = 8;
    uint256 public COOLDOWN_IncrementPerEvol = 4;
    uint256 public COOLDOWN_IncrementPerMint = 8;
    uint256 public COOLDOWN_NewlyMinted = 24;

    // Max Mutation Per Category
    uint256 public MAX_MUTATE_COMMON = 9;
    uint256 public MAX_MUTATE_RARE = 5;
    uint256 public MAX_MUTATE_EPIC = 3;
    uint256 public MAX_MUTATE_LEGEND = 1;

    // Random Holders

    // Common Pairs
    uint256[9] RAN_COM_1_6 = [315,630,945,1260,1580, 1900, 3400, 6700,10000];
    uint256[9] RAN_COM_1_6_RESULT = [7,3,5,2,0,4,8,1,6];
   
    uint256[9] RAN_COM_0_4 = [315,630,945,1260,1580, 1900, 3400, 6700,10000];
    uint256[9] RAN_COM_0_4_RESULT = [1,6,7,3,2,3,9,0,4];

    uint256[9] RAN_COM_2_5 = [315,630,945,1260,1580, 1900, 3400, 6700,10000];
    uint256[9] RAN_COM_2_5_RESULT = [4,0,1,6,7,3,10,2,5];

    uint256[9] RAN_COM_3_7 = [315,630,945,1260,1580, 1900, 3400, 6700,10000];
    uint256[9] RAN_COM_3_7_RESULT = [5,2,4,0,1,6,11,3,7];    

    // Rare Pairs

    uint256[13] RAN_RARE_8_9 = [125,250,375,500,625,750,875,1000,1700,2400,4000,7000,10000];
    uint256[13] RAN_RARE_8_9_RESULT = [0,1,2,3,4,5,6,7,10,11,12,8,9];

    uint256[13] RAN_RARE_10_11 = [125,250,375,500,625,750,875,1000,1700,2400,4000,7000,10000];
    uint256[13] RAN_RARE_10_11_RESULT = [0,1,2,3,4,5,6,7,8,9,13,10,11];

    // Epic Pairs

    uint256[15] RAN_EPIC_12_13 = [125,250,375,500,625,750,875,1000,1400,1800,2200,2600,3400,6700,10000];
    uint256[15] RAN_EPIC_12_13_RESULT = [0,1,2,3,4,5,6,7,8,9,10,11,14,12,13];

    // Random Pairing

    uint256[15] RAN_ELSE = [250,500,750,1000,1250,1500,1750,2000,6000,10000];
    uint256[15] RAN_ELSE_RESULT = [0,1,2,3,4,5,6,7,1000,2000];

    // Harvest Luck

    uint256[11] HL_LUCK_Common = [1500,3500,5500,7000,7800,8500,9000,9400,9700,9900,10000];
    uint256[9] HL_LUCK_Rare = [1000,2500,4500,6500,8000,9000,9600,9900,10000];
    uint256[7] HL_LUCK_Epic = [1000,2000,4000,6500,8500,9500,10000];
    uint256[5] HL_LUCK_Legendary = [1000,2000,4500,7500,10000];

    // VRF
    bytes32 private s_keyHash;
    uint256 private s_fee;
    mapping(bytes32 => MutationInstance) private s_random;

    struct MutationInstance {
            address sender;
            address address1;
            uint256 token1;
            address address2;
            uint256 token2;
        }

    // EVENTS
    event BeginMutation(bytes32 indexed _requestId, address indexed _address_a, uint _token_a, address indexed _address_b, uint _token_b );
    event CompleteMutation(bytes32 indexed _requestId, address indexed _to, uint _token, uint _tokenType);
  
    constructor() VRFConsumerBase(
            0x747973a5A2a4Ae1D3a8fDF5479f1514F65Db9C31, // VRF Coordinator
            0x404460C6A5EdE2D891e8297795264fDe62ADBB75  // LINK Token
        )  {

        // SETUP VRF
        s_keyHash = 0xc251acd21ec4fb7f31bb8868288bfdbaeb4fbfec2df3735ddbd4f7dc8d60103c;
        s_fee = 0.2 * 10 ** 18; // 0.1 LINK (Varies by network)
   
        // Admin role
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
     
        _SeedContract = SeedInterface(_SeedAddress);
        _Evol0Contract = Evol0Interface(_Evol0Address);
         DVILLEBanker = DogeBanker(_bankerAddress);
        _pause();
    
    }
    
     ////////////////////////////////////
    // MODIFIERS
    ////////////////////////////////////  
    
    
     modifier whenNotPausedOrAdmin() {
         if (!hasRole(DEFAULT_ADMIN_ROLE, _msgSender()))
         {
            require(!paused(), "GM : Contract is Locked");
         }
        
        _;
    }

  
    // Admin Only commands
    modifier OnlyAdmin(){
           require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "GM : Restricted to Admin");        
        _;
    }
      
    //////////////////////////////////////
    // GET/SET VALUES
    //////////////////////////////////////

    function setDevWallet(address developerWallet_) OnlyAdmin external {
        devWallet = payable(developerWallet_);
    }

    function setSeedContractAddress(address Address_) OnlyAdmin external {
        _SeedAddress = Address_;
        _SeedContract = SeedInterface(_SeedAddress);
    }
    
    function setEvol0ContractAddress(address Address_) OnlyAdmin external {
        _Evol0Address = Address_;
        _Evol0Contract = Evol0Interface(_Evol0Address);
    }

    function setTokenAddress( address Address_) OnlyAdmin external {
        _tokenAddress = Address_;
        DVILLEToken = IERC20(_tokenAddress);
    }

    function setBankerAddress( address Address_) OnlyAdmin external {
     
        _bankerAddress = Address_;
        DVILLEBanker = DogeBanker(_bankerAddress);
    }
  
  function setMutationAvailable( address Address_, uint256 id_, uint256 val_) OnlyAdmin public {
     
        mutationAvailable[Address_][id_] = val_;
    }

    function setMutationsAvailable(address[] memory _addresses, uint256[] memory _ids, uint256[] memory _values) OnlyAdmin public returns (bool) {
         
         for (uint i = 0; i < _addresses.length; i++) {
             setMutationAvailable(_addresses[i], _ids[i], _values[i]);
         }
         return true;
   }

 function setCOST_Base(uint256 val_) OnlyAdmin external {
        COST_Base = val_;
    }

     function setCOST_IncreasePerEvol(uint256 val_) OnlyAdmin external {
        COST_IncreasePerEvol = val_;
    }

    function setCOST_IncrementPerMint(uint256 val_) OnlyAdmin external {
        COST_IncrementPerMint = val_;
    }

    function setCOOLDOWN_Base(uint256 val_) OnlyAdmin external {
        COOLDOWN_Base = val_;
    }

     function setCOOLDOWN_IncrementPerEvol(uint256 val_) OnlyAdmin external {
        COOLDOWN_IncrementPerEvol = val_;
    }

     function setCOOLDOWN_IncrementPerMint(uint256 val_) OnlyAdmin external {
        COOLDOWN_IncrementPerMint = val_;
    }

     function setCOOLDOWN_NewlyMinted(uint256 val_) OnlyAdmin external {
        COOLDOWN_NewlyMinted = val_;
    }
  
    function setMAX_MUTATE_COMMON(uint256 val_) OnlyAdmin external {
        MAX_MUTATE_COMMON = val_;
    }

    function setMAX_MUTATE_RARE(uint256 val_) OnlyAdmin external {
        MAX_MUTATE_RARE = val_;
    }

    function setMAX_MUTATE_EPIC(uint256 val_) OnlyAdmin external {
        MAX_MUTATE_EPIC = val_;
    }

    function setMAX_MUTATE_LEGEND(uint256 val_) OnlyAdmin external {
        MAX_MUTATE_LEGEND = val_;
    }



        
    ////////////////////////////////////
    // GREENHOUSE HELPER FUNCTIONS
    ////////////////////////////////////

    
    function calculateFees(address add1_, uint256 token1_, address add2_, uint256 token2_) public view returns (uint256)
    {
           return calculateFee(add1_, token1_) + calculateFee(add2_,token2_);
    }

    function calculateFee(address add_, uint256 token_) public view returns (uint256)
    {
        uint256 minimumPrice = COST_Base;

        uint256 dynamicPrice = minimumPrice;

        
         if (add_ == _Evol0Address)
          {
               (,,,uint256 curr_,) = _Evol0Contract._seedNFT(token_);

                dynamicPrice = dynamicPrice + curr_ * COST_IncrementPerMint;
                
          }
          else
          {
              (,uint256 level_,,,uint256 curr_,) = _SeedContract._seedNFT(token_);

              dynamicPrice = dynamicPrice + curr_ * COST_IncrementPerMint + level_ * COST_IncreasePerEvol;

               
              
          }



        return dynamicPrice;
    }

 

///////////////////////////
// Frees locked tokens/BNB
/////////////////////////////

function disperseBalanceToAdmin() whenPaused OnlyAdmin public {
   uint256 balance = address(this).balance;
   
   devWallet.transfer(balance);  
}

function disperseTokenBalanceToAdmin(address address_) whenPaused OnlyAdmin public {
    IERC20 _token = IERC20(address_);

    _token.transfer(address(devWallet), _token.balanceOf(address(this)));

}


function pauseGM() OnlyAdmin whenNotPaused public {
    _pause();
}

function unpauseGM() OnlyAdmin whenPaused public {
    _unpause();
}


 
  function sendFees(uint256 amount) private {
      
       if (amount != 0)
        {
            DVILLEBanker.processDVILLEPayment(address(msg.sender), address(devWallet), amount);
                
        }

          
                  
  }

  function isOwnerOfSeed(address add_, uint256 id_) public view returns (bool)
  {
      if (add_ == _SeedAddress)
      {
          if (_SeedContract.ownerOf(id_) == msg.sender)
          {
              return true;
          }
          else
          {
              return false;
          }
      }
      else
      {
          if (_Evol0Contract.ownerOf(id_) == msg.sender)
          {
              return true;
          }
          else
          {
              return false;
          }
      }

  }

  

function isDifferentNFTs(address add1, uint256 id1, address add2, uint256 id2) public pure returns (bool)
  {
      if (add1 == add2 && id1 == id2)
      {
          return false;
      }
      return true;
  }

  function isValidAddresses(address add1, address add2) public view returns (bool)
  {
      if (add1 != _Evol0Address && add1 != _SeedAddress)
      {
          return false;
      }

     if (add2 != _Evol0Address && add2 != _SeedAddress)
      {
          return false;
      }


      return true;
  }

  function isMutationEligible(address add, uint256 id) public view returns (bool)
  {
     
      if (block.timestamp >= mutationAvailable[add][id])
      {
          if (add == _Evol0Address)
          {
              return true;
          }
          else
          {
              (,,,uint256 mutationsMax,uint256 mutationsCurrent,) = _SeedContract._seedNFT(id);

              if (mutationsCurrent < mutationsMax)
              {
                  return true;
              }
          }
      }
      

      return false;
  }

  function getCooldown(address add, uint256 id) public view returns (uint256)
  {
        uint256 returnVal = COOLDOWN_Base;

        if (add == _Evol0Address)
          {
               (,,,uint256 curr_,) = _Evol0Contract._seedNFT(id);

                if (curr_ >= 8)
                {
                    returnVal = returnVal + ((8) * COOLDOWN_IncrementPerMint);
                }
                else
                {
                    returnVal = returnVal + ((curr_ - 1) * COOLDOWN_IncrementPerMint);
                }

                
                
          }
          else
          {
              (,uint256 level_,,,uint256 curr_,) = _SeedContract._seedNFT(id);

                returnVal = returnVal + ((curr_ - 1) * COOLDOWN_IncrementPerMint) + (level_ * COOLDOWN_IncrementPerEvol);
              
          }



        return returnVal;
      

  }

  function increaseSeedMutation(address add, uint256 id) private
  {
          if (add == _Evol0Address)
          {
               (uint256 type_, uint256 hl_,uint256 max_,uint256 curr_,uint256 water_) = _Evol0Contract._seedNFT(id);

                _Evol0Contract.setSeedInstance(id,type_,hl_,max_,curr_+1,water_);
          }
          else
          {
              (uint256 type_,uint256 level_, uint256 hl_,uint256 max_,uint256 curr_,uint256 water_) = _SeedContract._seedNFT(id);

                _SeedContract.setSeedInstance(id,type_,level_,hl_,max_,curr_+1,water_);
              
          }

          uint256 hoursToIncrease = getCooldown(add, id);

          mutationAvailable[add][id] = block.timestamp + (hoursToIncrease * 1 hours); 

  }

  function getSeedType(address add, uint256 id) public view returns (uint256)
  {
      uint256 returnValue = 0;
          if (add == _Evol0Address)
          {
               (uint256 type_,,,,) = _Evol0Contract._seedNFT(id);

                returnValue = type_;
          }
          else
          {
              (uint256 type_,,,,,) = _SeedContract._seedNFT(id);

                returnValue = type_;
              
          }

          return returnValue;

  }

   function getHL(uint256 type_, uint256 randomValue) public view returns (uint256)
  {
      
      if (type_ <= 8)
      {
        for(uint256 i=0; i < HL_LUCK_Common.length; i++){
            if (randomValue <= HL_LUCK_Common[i])
            {
                return i * 10;
            }
        }
      }
      else if (type_ <=12)
      {
        for(uint256 i=0; i < HL_LUCK_Rare.length; i++){
            if (randomValue <= HL_LUCK_Rare[i])
            {
                return i * 10;
            }
        }
      }
      else if (type_ <=14)
      {
        for(uint256 i=0; i < HL_LUCK_Epic.length; i++){
            if (randomValue <= HL_LUCK_Epic[i])
            {
                return i * 10;
            }
        }
      }
      else
      {
        for(uint256 i=0; i < HL_LUCK_Legendary.length; i++){
            if (randomValue <= HL_LUCK_Legendary[i])
            {
                return i * 10;
            }
        }
      }

  

      return 0;


     
      
  }

  function getResultingSeed(uint256 type_1, uint256 type_2, uint256 randomValue) public view returns (uint256)
  {
      
     if ((type_1 == 2 && type_2 == 7) || (type_1 == 7 && type_2 == 2))
      {
        for(uint256 i=0; i < RAN_COM_1_6.length; i++){
            if (randomValue <= RAN_COM_1_6[i])
            {
                return RAN_COM_1_6_RESULT[i] + 1;
            }
        }
      }
     else if ((type_1 == 1 && type_2 == 5) || (type_1 == 5 && type_2 == 1))
      {
        for(uint256 i=0; i < RAN_COM_0_4.length; i++){
            if (randomValue <= RAN_COM_0_4[i])
            {
                return RAN_COM_0_4_RESULT[i] + 1;
            }
        }
      }
      else if ((type_1 == 3 && type_2 == 6) || (type_1 == 6 && type_2 == 3))
      {
        for(uint256 i=0; i < RAN_COM_2_5.length; i++){
            if (randomValue <= RAN_COM_2_5[i])
            {
                return RAN_COM_2_5_RESULT[i] + 1;
            }
        }
      }
      else if ((type_1 == 4 && type_2 == 8) || (type_1 == 8 && type_2 == 4))
      {
        for(uint256 i=0; i < RAN_COM_3_7.length; i++){
            if (randomValue <= RAN_COM_3_7[i])
            {
                return RAN_COM_3_7_RESULT[i] + 1;
            }
        }
      }
      else if ((type_1 == 9 && type_2 == 10) || (type_1 == 10 && type_2 == 9))
      {
        for(uint256 i=0; i < RAN_RARE_8_9.length; i++){
            if (randomValue <= RAN_RARE_8_9[i])
            {
                return RAN_RARE_8_9_RESULT[i] + 1;
            }
        }
      }
      else if ((type_1 == 11 && type_2 == 12) || (type_1 == 12 && type_2 == 11))
      {
        for(uint256 i=0; i < RAN_RARE_10_11.length; i++){
            if (randomValue <= RAN_RARE_10_11[i])
            {
                return RAN_RARE_10_11_RESULT[i] + 1;
            }
        }
      }
      else if ((type_1 == 13 && type_2 == 14) || (type_1 == 14 && type_2 == 13))
      {
        for(uint256 i=0; i < RAN_EPIC_12_13.length; i++){
            if (randomValue <= RAN_EPIC_12_13[i])
            {
                return RAN_EPIC_12_13_RESULT[i] + 1;
            }
        }
      }
     else
     {
      for(uint256 i=0; i < RAN_ELSE.length; i++){
        if (randomValue <= RAN_ELSE[i])
        {
            if (RAN_ELSE_RESULT[i] == 1000)
            {
                return type_1;
            }
            else if (RAN_ELSE_RESULT[i] == 2000)
            {
                 return type_2;
            }
            else
            {
                return RAN_ELSE_RESULT[i] + 1;
            }
        }
      }
    }

      return RAN_ELSE_RESULT[0] + 1;


     
      
  }

  function getEvolLevel(address add, uint256 token) public view returns (uint256)
  {
          if (add == _Evol0Address)
          {
             return 0;
          }
          else
          {
              (,uint256 level_,,,,) = _SeedContract._seedNFT(token);

               return level_;
              
          }
  }

  function getMutationMax(uint256 type_, uint256 level) public view returns (uint256)
  {
      uint256 returnVal = 10 - level;

      uint256 maxMutation = 9;

      if (type_ <= 8)
      {
        maxMutation = MAX_MUTATE_COMMON;
      }
      else if (type_ <= 12)
      {
        maxMutation = MAX_MUTATE_RARE;
      } 
      else if (type_ <= 14)
      {
        maxMutation = MAX_MUTATE_EPIC;
      }
      else
      {
          maxMutation = MAX_MUTATE_LEGEND;
      }

       if (maxMutation < returnVal)
      {
        returnVal = maxMutation;
      }

      return returnVal;


  }


    ////////////////////////////////////
    // TRANSACTION LOGIC
    ////////////////////////////////////

    
    function mutateSeeds(address address1, uint256 token1, address address2, uint256 token2) whenNotPausedOrAdmin payable external returns (bytes32 requestId) {
        require(isValidAddresses(address1, address2), "Greenhouse : Invalid NFTs");
        require(isDifferentNFTs(address1, token1, address2, token2), "Greenhouse : Invalid NFTs");
        require(isOwnerOfSeed(address1, token1), "Greenhouse : Not Owner of First Seed");
        require(isOwnerOfSeed(address2, token2), "Greenhouse : Not Owner of Second Seed");
        require(isMutationEligible(address1, token1), "Greenhouse : First Seed not Eligible for Mutation");
        require(isMutationEligible(address2, token2), "Greenhouse : Second Seed not Eligible for Mutation");


        // Send fees
        if (!hasRole(DEFAULT_ADMIN_ROLE, _msgSender()))
        {
            uint valueToSend = calculateFees(address1, token1, address2, token2);
            sendFees(valueToSend);
        }

        // Setup VRF REQs
        requestId = requestRandomness(s_keyHash, s_fee);
        MutationInstance memory newMutation  = MutationInstance(msg.sender, address1, token1, address2, token2);
        s_random[requestId] = newMutation;

        // Increment NFTs and mark for cooldown
        increaseSeedMutation(address1, token1);
        increaseSeedMutation(address2, token2);

        // Request has been made, emit event and wait

        emit BeginMutation(requestId, address1, token1, address2, token2);
          
        return requestId;
 
    }


    ////////////////////////////////
    // RETURN VRF VALUE AND MINT NEW MUTATION
    ///////////////////////////////

    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        uint256 seedChance = uint256(keccak256(abi.encode(randomness, 1))) % 10000;
        uint256 hlChance = uint256(keccak256(abi.encode(randomness, 2))) % 10000;

        // Stored Values for Random Generation
        MutationInstance memory mutation = s_random[requestId];

        // Create NFT
        uint256 newTokenId;
        newTokenId = _SeedContract.totalSupply();
        _SeedContract.mintNFT(mutation.sender, newTokenId);
        
         // Determine Random Stats
        uint256 evolLevel = getEvolLevel(mutation.address1, mutation.token1) + 1;
        uint256 compareEvol = getEvolLevel(mutation.address2,mutation.token2) + 1;
        if (compareEvol > evolLevel)
        {
            evolLevel = compareEvol;
        }

        uint256 seedType1 = getSeedType(mutation.address1, mutation.token1);
        uint256 seedType2 = getSeedType(mutation.address2, mutation.token2);

        uint256 seedFinalType = getResultingSeed(seedType1, seedType2, seedChance);

        uint256 hlLevel = getHL(seedFinalType, hlChance);

        uint256 mutationMax = getMutationMax(seedFinalType, evolLevel);

        _SeedContract.setSeedInstance(newTokenId, seedFinalType, evolLevel, hlLevel, mutationMax, 0, 50);
              
        // Newly Minted NFTs have cooldown
        mutationAvailable[_SeedAddress][newTokenId] = block.timestamp + (COOLDOWN_NewlyMinted * 1 hours); 

        // Success, emit event
        emit CompleteMutation(requestId, mutation.sender, newTokenId, seedFinalType);
    }


 
    
 

 

    
 
}

/////////////////////////////////////////////////////////////////
// ERC721Base
// Convenience interface for basic token functionality
/////////////////////////////////////////////////////////////////

abstract contract IERC721
{
     function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual {}
    
     function ownerOf(uint256 id) public virtual returns (address);
     function getApproved(uint256 tokenId) public view virtual returns (address);
}



abstract contract IERC20 {


    function totalSupply() external view virtual returns (uint256);

    function balanceOf(address account) external view virtual returns (uint256);

    function allowance(address owner, address spender) external view virtual returns (uint256);

    function transfer(address recipient, uint256 amount) external virtual returns (bool);

    function approve(address spender, uint256 amount) external virtual returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external virtual returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

}



abstract contract DogeBanker {

     function processDVILLEPayment(address sender, address recipient, uint256 amount) external virtual returns (bool);

}


abstract contract Evol0Interface {


        struct SeedInstance {
            uint256 seedType;
            uint256 harvestLuck;
            uint256 mutationMax;
            uint256 mutationRemaining;
            uint256 water;
        }

mapping (uint => SeedInstance) public _seedNFT;

    function ownerOf(uint256 id) public view virtual returns (address);
    function mintNFT(address add) public virtual;
    function getMaxCount() public virtual returns (uint256);
    function transferFrom(address from, address to, uint256 id) public virtual;
    function getApproved(uint256 tokenId) public view virtual returns (address);
    function balanceOf(address owner) public view virtual returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual returns (uint256);
    function totalSupply() public view virtual returns (uint256);
    function getSeedInstance(uint256 id_) public view virtual returns (SeedInstance memory);
    function setSeedInstance(uint256 id_, uint256 seedType_,  uint256 harvestLuck_, uint256 mutationMax_, uint256 mutationRemaining_, uint256 water_) public virtual;
    
}


abstract contract SeedInterface {


        struct SeedInstance {
            uint256 seedType;
            uint256 evolLevel;
            uint256 harvestLuck;
            uint256 mutationMax;
            uint256 mutationRemaining;
            uint256 water;
        }

        mapping (uint => SeedInstance) public _seedNFT;

    function ownerOf(uint256 id) public view virtual returns (address);
    function mintNFT(address add, uint256 id) public virtual;
    function getMaxCount() public virtual returns (uint256);
    function transferFrom(address from, address to, uint256 id) public virtual;
    function setSeedInstance(uint256 id_, uint256 seedType_, uint256 seedLevel_, uint256 harvestLuck_, uint256 mutationMax_, uint256 mutationRemaining_, uint256 water_) public virtual;
    function getApproved(uint256 tokenId) public view virtual returns (address);
    function balanceOf(address owner) public view virtual returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual returns (uint256);
    function totalSupply() public view virtual returns (uint256);
    function getSeedInstance(uint256 id_) public view virtual returns (SeedInstance memory);
}